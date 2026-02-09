pipeline {

  agent {
    kubernetes {
      defaultContainer 'builder'
      yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: auto-ci-cd
spec:
  serviceAccountName: jenkins
  restartPolicy: Never

  containers:
  # -------------------------------
  # BuildKit daemon (image builder)
  # -------------------------------
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
      - name: workspace
        mountPath: /workspace

  # -------------------------------
  # Builder container (git, shell)
  # -------------------------------
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
      - name: workspace
        mountPath: /workspace
    workingDir: /workspace

  # -------------------------------
  # Jenkins JNLP agent
  # -------------------------------
  - name: jnlp
    image: jenkins/inbound-agent:3355.v388858a_47b_33-3-jdk21
    env:
      - name: JENKINS_AGENT_WORKDIR
        value: /workspace
    volumeMounts:
      - name: workspace
        mountPath: /workspace

  volumes:
    - name: workspace
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

    // -------------------------------
    // Checkout source code
    // -------------------------------
    stage('Checkout Code') {
      steps {
        container('builder') {
          checkout scm
        }
      }
    }

    // -------------------------------
    // Build & Push Docker Image
    // -------------------------------
    stage('Build & Push Image') {
      steps {
        container('buildkit') {
          sh '''
            set -e

            echo "🚀 Building & Pushing Image"
            echo "IMAGE  : ${IMAGE_NAME}"
            echo "TAG    : ${IMAGE_TAG}, latest"
            echo "CTX    : /workspace"

            buildctl \
              --addr tcp://0.0.0.0:1234 \
              build \
              --frontend dockerfile.v0 \
              --local context=/workspace \
              --local dockerfile=/workspace \
              --output type=image,name=${IMAGE_NAME}:${IMAGE_TAG},push=true \
              --output type=image,name=${IMAGE_NAME}:latest,push=true
          '''
        }
      }
    }
  }

  post {
    success {
      echo "✅ Docker image successfully built & pushed"
    }
    failure {
      echo "❌ Pipeline failed"
    }
  }
}
