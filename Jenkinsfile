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
  # -----------------------------
  # BuildKit (Docker image build)
  # -----------------------------
  - name: buildkit
    image: moby/buildkit:v0.13.2
    args:
      - "--addr"
      - "tcp://0.0.0.0:1234"
    securityContext:
      privileged: true
    volumeMounts:
      - name: docker-config
        mountPath: /root/.docker
      - name: jenkins-workspace
        mountPath: /home/jenkins/agent

  # -----------------------------
  # Builder (git + shell)
  # -----------------------------
  - name: builder
    image: docker:27-cli
    command: ["cat"]
    tty: true
    env:
      - name: DOCKER_CONFIG
        value: /root/.docker
    volumeMounts:
      - name: docker-config
        mountPath: /root/.docker
      - name: jenkins-workspace
        mountPath: /home/jenkins/agent
    workingDir: /home/jenkins/agent/workspace/auto-ci-cd

  # -----------------------------
  # Jenkins JNLP agent
  # -----------------------------
  - name: jnlp
    image: jenkins/inbound-agent:3355.v388858a_47b_33-3-jdk21
    env:
      - name: JENKINS_AGENT_WORKDIR
        value: /home/jenkins/agent
    volumeMounts:
      - name: jenkins-workspace
        mountPath: /home/jenkins/agent

  volumes:
    - name: jenkins-workspace
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
    APP_DIR    = "/home/jenkins/agent/workspace/auto-ci-cd/frontend"
  }

  stages {

    // -----------------------------
    // Checkout Code
    // -----------------------------
    stage('Checkout Code') {
      steps {
        container('builder') {
          checkout scm
          sh '''
            echo "📁 Workspace contents:"
            ls -la /home/jenkins/agent/workspace/auto-ci-cd
          '''
        }
      }
    }

    // -----------------------------
    // Build & Push Docker Image
    // -----------------------------
    stage('Build & Push Image') {
      steps {
        container('buildkit') {
          sh """
            set -e

            echo "🚀 Building & Pushing Image"
            echo "IMAGE  : ${IMAGE_NAME}"
            echo "TAG    : ${IMAGE_TAG}"
            echo "APP DIR: ${APP_DIR}"

            ls -la ${APP_DIR}

            buildctl \
              --addr tcp://0.0.0.0:1234 \
              build \
              --frontend dockerfile.v0 \
              --local context=${APP_DIR} \
              --local dockerfile=${APP_DIR} \
              --output type=image,name=${IMAGE_NAME}:${IMAGE_TAG},push=true \
              --output type=image,name=${IMAGE_NAME}:latest,push=true
          """
        }
      }
    }
  }

  post {
    success {
      echo "✅ Docker image built and pushed successfully"
    }
    failure {
      echo "❌ Pipeline failed"
    }
  }
}
