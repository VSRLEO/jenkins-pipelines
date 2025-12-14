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
  containers:
    - name: kaniko
      image: gcr.io/kaniko-project/executor:latest
      command:
        - /kaniko/executor
      args:
        - --dockerfile=/workspace/Dockerfile
        - --context=/workspace
        - --destination=docker.io/vsr11144/netflix-clone-app:${BUILD_NUMBER}
        - --destination=docker.io/vsr11144/netflix-clone-app:latest
        - --verbosity=info
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

  stages {

    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build & Push Image') {
      steps {
        container('kaniko') {
          sh 'echo "Kaniko build running..."'
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
