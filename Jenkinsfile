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
  restartPolicy: Never

  volumes:
    - name: workspace
      emptyDir: {}
    - name: docker-config
      secret:
        secretName: dockerhub-secret

  containers:
    - name: jnlp
      image: jenkins/inbound-agent:latest
      volumeMounts:
        - name: workspace
          mountPath: /workspace

    - name: kaniko
      image: gcr.io/kaniko-project/executor:latest
      args:
        - "--dockerfile=/workspace/Dockerfile"
        - "--context=/workspace"
        - "--destination=docker.io/vsr11144/netflix-clone-app:${BUILD_NUMBER}"
        - "--destination=docker.io/vsr11144/netflix-clone-app:latest"
        - "--verbosity=info"
      volumeMounts:
        - name: workspace
          mountPath: /workspace
        - name: docker-config
          mountPath: /kaniko/.docker
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
        container('kaniko') {
          echo "Kaniko build started"
        }
      }
    }
  }

  post {
    success {
      echo "Docker image built and pushed successfully"
    }
    failure {
      echo "Kaniko build failed"
    }
  }
}
