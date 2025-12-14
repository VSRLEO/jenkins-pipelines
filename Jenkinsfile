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
    - name: docker-config
      secret:
        secretName: dockerhub-secret

  containers:
    - name: jnlp
      image: jenkins/inbound-agent:latest

    - name: kaniko
      image: gcr.io/kaniko-project/executor:latest
      command:
        - /kaniko/executor
      args:
        - --dockerfile=/home/jenkins/agent/workspace/Dockerfile
        - --context=/home/jenkins/agent/workspace
        - --destination=docker.io/vsr11144/netflix-clone-app:${BUILD_NUMBER}
        - --destination=docker.io/vsr11144/netflix-clone-app:latest
        - --verbosity=info
      volumeMounts:
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
          echo "🚀 Kaniko build & push started"
        }
      }
    }
  }

  post {
    success {
      echo "Image built and pushed to DockerHub"
    }
    failure {
      echo " Kaniko build failed"
    }
  }
}
