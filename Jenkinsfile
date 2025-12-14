pipeline {
  agent {
    kubernetes {
      defaultContainer 'kaniko'
      yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    command:
      - /busybox/sleep
    args:
      - "999999"
    volumeMounts:
      - name: docker-config
        mountPath: /kaniko/.docker
  volumes:
  - name: docker-config
    secret:
      secretName: dockerhub-secret
"""
    }
  }

  environment {
    IMAGE_NAME = "docker.io/vsrleo/kaniko-test"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build & Push Image') {
      steps {
        container('kaniko') {
          sh '''
            /kaniko/executor \
              --context=$WORKSPACE \
              --dockerfile=$WORKSPACE/Dockerfile \
              --destination=${IMAGE_NAME}:latest
          '''
        }
      }
    }
  }
}
