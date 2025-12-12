pipeline {
  agent {
    kubernetes {
      label "kaniko-build-${env.BUILD_NUMBER}"
      defaultContainer 'jnlp'
      yaml """
apiVersion: v1
kind: Pod
spec:
  serviceAccountName: jenkins
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:latest
    command:
      - cat
    tty: true
    volumeMounts:
      - name: kaniko-secret
        mountPath: /kaniko/.docker
      - name: workspace
        mountPath: /workspace
  - name: kubectl
    image: bitnami/kubectl:latest
    command:
      - cat
    tty: true
    volumeMounts:
      - name: kubeconfig
        mountPath: /root/.kube
  volumes:
    - name: kaniko-secret
      secret:
        secretName: dockerhub-secret
    - name: workspace
      emptyDir: {}
    - name: kubeconfig
      emptyDir: {}
"""
    }
  }

  environment {
    DOCKER_REGISTRY = "docker.io"
    DOCKER_IMAGE    = "netflix-clone-app"
    IMAGE_REPO      = "${DOCKER_REGISTRY}/${DOCKER_USER}/${DOCKER_IMAGE}"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout([$class: 'GitSCM', branches: [[name: '*/main']], userRemoteConfigs: [[url: env.GIT_REPO_URL ?: 'https://github.com/VSRLEO/Netflix-Repo.git']]])
        sh 'cp -r . /workspace || true'
        sh 'ls -la /workspace'
      }
    }

    stage('Prepare credentials') {
      steps {
        // Get username from Jenkins credential 'dockerhub' (created by init groovy)
        script {
          // This just ensures credential is referenced for auditing; actual Docker auth used by Kaniko via secret mount
          withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
            echo "Using DockerHub user: ${DOCKER_USER}"
            // expose DOCKER_USER to environment for IMAGE_REPO interpolation
            env.DOCKER_USER = DOCKER_USER
            env.IMAGE_REPO = "${DOCKER_REGISTRY}/${DOCKER_USER}/${DOCKER_IMAGE}"
          }
        }
      }
    }

    stage('Build & Push (Kaniko)') {
      steps {
        container('kaniko') {
          sh '''
            # Kaniko expects the build context under /workspace and the docker config in /kaniko/.docker/config.json
            # Build and push with tag = build number (immutable)
            /kaniko/executor \
              --dockerfile=/workspace/Dockerfile \
              --context=dir:///workspace \
              --destination=${DOCKER_REGISTRY}/${DOCKER_USER}/${DOCKER_IMAGE}:${BUILD_NUMBER} \
              --destination=${DOCKER_REGISTRY}/${DOCKER_USER}/${DOCKER_IMAGE}:latest
          '''
        }
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        // Provide kubeconfig as a Jenkins-file-credential with id 'kubeconfig'
        withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG_FILE')]) {
          container('kubectl') {
            sh '''
              # place kubeconfig into the expected mount for this pod
              mkdir -p /root/.kube
              cp "${KUBECONFIG_FILE}" /root/.kube/config
              chmod 600 /root/.kube/config

              # Attempt to update an existing deployment; if it doesn't exist, create it
              if kubectl get deployment netflix-deploy >/dev/null 2>&1; then
                kubectl set image deployment/netflix-deploy netflix-container=${DOCKER_REGISTRY}/${DOCKER_USER}/${DOCKER_IMAGE}:${BUILD_NUMBER} --record
              else
                kubectl create deployment netflix-deploy --image=${DOCKER_REGISTRY}/${DOCKER_USER}/${DOCKER_IMAGE}:${BUILD_NUMBER}
                kubectl expose deployment netflix-deploy --port=80 --target-port=8080 --type=ClusterIP
              fi

              # Optional: rollout status
              kubectl rollout status deployment/netflix-deploy --timeout=120s || true
            '''
          }
        }
      }
    }
  }

  post {
    success {
      echo "Build and deploy successful: ${DOCKER_REGISTRY}/${DOCKER_USER}/${DOCKER_IMAGE}:${BUILD_NUMBER}"
    }
    failure {
      echo "Pipeline failed. Check console output for details."
    }
  }
}
