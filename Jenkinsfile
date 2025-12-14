pipeline {
  agent {
    kubernetes {
      label "kaniko"
      defaultContainer 'jnlp'
      yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    args:
      - "--dockerfile=\$(WORKSPACE)/Dockerfile"
      - "--context=\$(WORKSPACE)"
      - "--destination=docker.io/vsrleo/myapp:\${BUILD_NUMBER}"
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

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build & Push Image') {
      steps {
        echo "Building and pushing image using Kaniko"
      }
    }
  }
}
