pipeline {
  agent {
    kubernetes {
      cloud 'kubernetes'
      label "kaniko-${env.BUILD_NUMBER}"
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
        - name: docker-config
          mountPath: /kaniko/.docker
        - name: workspace
          mountPath: /workspace
  volumes:
    - name: docker-config
      secret:
        secretName: dockerhub-secret
    - name: workspace
      emptyDir: {}
"""
    }
  }

  environment {
    DOCKER_REGISTRY = "docker.io"
    DOCKER_USER     = "vsr11144"
    DOCKER_IMAGE    = "netflix-clone-app"
  }

  stages {

    stage('Checkout') {
      steps {
        checkout([
          $class: 'GitSCM',
          branches: [[name: '*/main']],
          userRemoteConfigs: [[
            url: 'https://github.com/VSRLEO/Netflix-Repo.git'
          ]]
        ])
      }
    }

    stage('Build & Push Image (Kaniko)') {
      steps {
        container('kaniko') {
          sh '''
            /kaniko/executor \
              --dockerfile=Dockerfile \
              --context=dir:///workspace \
              --destination=${DOCKER_REGISTRY}/${DOCKER_USER}/${DOCKER_IMAGE}:${BUILD_NUMBER} \
              --destination=${DOCKER_REGISTRY}/${DOCKER_USER}/${DOCKER_IMAGE}:latest
          '''
        }
      }
    }
  }

  post {
    success {
      echo "Image pushed successfully to Docker Hub"
    }
    failure {
      echo "Pipeline failed"
    }
  }
}
