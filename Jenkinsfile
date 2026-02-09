pipeline {

  agent {
    kubernetes {
      defaultContainer 'builder'
      yaml """
apiVersion: v1
kind: Pod
spec:
  serviceAccountName: jenkins
  restartPolicy: Never

  containers:
  # ===============================
  # BuildKit container
  # ===============================
  - name: buildkit
    image: moby/buildkit:v0.13.2
    args:
      - "--addr"
      - "tcp://0.0.0.0:1234"
    securityContext:
      privileged: true
    volumeMounts:
      - name: jenkins-home
        mountPath: /home/jenkins/agent
      - name: docker-config
        mountPath: /root/.docker

  # ===============================
  # Builder container (git + shell)
  # ===============================
  - name: builder
    image: docker:27-cli
    command: ["cat"]
    tty: true
    env:
      - name: DOCKER_CONFIG
        value: /root/.docker
    volumeMounts:
      - name: jenkins-home
        mountPath: /home/jenkins/agent
      - name: docker-config
        mountPath: /root/.docker

  # ===============================
  # Jenkins inbound agent
  # ===============================
  - name: jnlp
    image: jenkins/inbound-agent:3355.v388858a_47b_33-3-jdk21
    env:
      - name: JENKINS_AGENT_WORKDIR
        value: /home/jenkins/agent
    volumeMounts:
      - name: jenkins-home
        mountPath: /home/jenkins/agent

  volumes:
    - name: jenkins-home
      emptyDir: {}
    - name: docker-config
      secret:
        secretName: dockerhub-secret
"""
    }
  }

  environment {
    IMAGE_NAME = "docker.io/vsr11144/myapp"
    IMAGE_TAG  = "${BUILD_NUMBER}"
  }

  stages {

    // ===============================
    // Checkout (Jenkins-managed)
    // ===============================
    stage('Checkout Code') {
      steps {
        checkout scm
        sh '''
          echo "📂 Workspace:"
          pwd
          ls -la
          ls -la frontend
        '''
      }
    }

    // ===============================
    // Build & Push Docker Image
    // ===============================
    stage('Build & Push Image') {
      steps {
        container('buildkit') {
          sh """
            set -e

            echo "🚀 Building & Pushing Image"
            echo "IMAGE : ${IMAGE_NAME}"
            echo "TAG   : ${IMAGE_TAG}"

            buildctl \
              --addr tcp://0.0.0.0:1234 \
              build \
              --frontend dockerfile.v0 \
              --local context=\$PWD/frontend \
              --local dockerfile=\$PWD/frontend \
              --output type=image,name=${IMAGE_NAME}:${IMAGE_TAG},push=true \
              --output type=image,name=${IMAGE_NAME}:latest,push=true
          """
        }
      }
    }
  }

  post {
    success {
      echo "✅ IMAGE BUILT & PUSHED SUCCESSFULLY"
    }
    failure {
      echo "❌ PIPELINE FAILED"
    }
  }
}
