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
    command: ["cat"]
    tty: true
    volumeMounts:
      - name: kaniko-secret
        mountPath: /kaniko/.docker
      - name: workspace
        mountPath: /workspace
  - name: kubectl
    image: bitnami/kubectl:latest
    command: ["cat"]
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
  }

  stages {
    stage('Checkout') {
      steps {
        checkout([$class: 'GitSCM',
          branches: [[name: '*/main']],
          userRemoteConfigs: [[url: env.GIT_REPO_URL ?: 'https://github.com/VSRLEO/Netflix-Repo.git']]
        ])
      }
    }

    stage('Prepare credentials') {
      steps {
        script {
          withCredentials([usernamePassword(
            credentialsId: 'dockerhub',
            usernameVariable: 'DOCKER_USER',
            passwordVariable: 'DOCKER_PASS'
          )]) {
            env.DOCKER_USER = DOCKER_USER
          }
        }
      }
    }

    stage('Build & Push (Kaniko)') {
      steps {
        container('kaniko') {
          sh '''
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
        withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG_FILE')]) {
          container('kubectl') {
            sh '''
              mkdir -p /root/.kube
              cp "${KUBECONFIG_FILE}" /root/.kube/config
              chmod 600 /root/.kube/config

              if kubectl get deployment netflix-deploy >/dev/null 2>&1; then
                kubectl set image deployment/netflix-deploy netflix-container=${DOCKER_REGISTRY}/${DOCKER_USER}/${DOCKER_IMAGE}:${BUILD_NUMBER}
              else
                kubectl create deployment netflix-deploy --image=${DOCKER_REGISTRY}/${DOCKER_USER}/${DOCKER_IMAGE}:${BUILD_NUMBER}
                kubectl expose deployment netflix-deploy --port=80 --target-port=8080 --type=ClusterIP
              fi

              kubectl rollout status deployment/netflix-deploy --timeout=120s || true
            '''
          }
        }
      }
    }
  }

  post {
    success {
      echo "Build and deploy successful"
    }
    failure {
      echo "Pipeline failed"
    }
  }
}
