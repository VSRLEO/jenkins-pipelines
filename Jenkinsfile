pipeline {
  agent {
    kubernetes {
      yaml """
apiVersion: v1
kind: Pod
spec:
  serviceAccountName: jenkins
  restartPolicy: Never

  containers:
    - name: jnlp
      image: jenkins/inbound-agent:latest
      resources:
        requests:
          cpu: "100m"
          memory: "256Mi"

    - name: kaniko
      image: gcr.io/kaniko-project/executor:debug
      command:
        - /busybox/sleep
      args:
        - "999999"
      resources:
        requests:
          cpu: "200m"
          memory: "512Mi"
      volumeMounts:
        - name: docker-config
          mountPath: /kaniko/.docker
        - name: workspace-volume
          mountPath: /workspace

  volumes:
    - name: docker-config
      secret:
        secretName: dockerhub-secret

    - name: workspace-volume
      emptyDir: {}
"""
    }
  }

  environment {
    DOCKERHUB_USER = "vsrleo"   // <-- your DockerHub username
    IMAGE_NAME     = "kaniko-demo"
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
              --dockerfile=Dockerfile \
              --context=/workspace \
              --destination=docker.io/${DOCKERHUB_USER}/${IMAGE_NAME}:${BUILD_NUMBER}
          '''
        }
      }
    }
  }

  post {
    success {
      echo "Docker image pushed successfully"
    }
  }
}
