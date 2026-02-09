pipeline {
  agent {
    kubernetes {
      yaml """
apiVersion: v1
kind: Pod
spec:
  serviceAccountName: jenkins

  containers:
  - name: buildkit
    image: moby/buildkit:v0.13.2
    securityContext:
      privileged: true
    args: ["--addr", "tcp://0.0.0.0:1234"]
    volumeMounts:
      - name: docker-config
        mountPath: /root/.docker
      - name: workspace
        mountPath: /home/jenkins/agent

  - name: docker
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
        mountPath: /home/jenkins/agent

  - name: jnlp
    image: jenkins/inbound-agent:3355.v388858a_47b_33-3-jdk21
    volumeMounts:
      - name: workspace
        mountPath: /home/jenkins/agent

  volumes:
    - name: docker-config
      emptyDir: {}
    - name: workspace
      emptyDir: {}
"""
    }
  }

  environment {
    IMAGE_NAME = "docker.io/vsr11144/jenkins-buildkit-test"
  }

  stages {

    stage("Checkout") {
      steps {
        checkout scm
      }
    }

    stage("Docker Login (TEST ONLY)") {
      steps {
        container("docker") {
          sh '''
            set -eux
            echo "dckr_pat_cX5HYx8vHzAO13jYNLBUts6VowI" | docker login \
              -u vsr11144 \
              --password-stdin
          '''
        }
      }
    }

    stage("Build & Push Image (BuildKit)") {
      steps {
        container("buildkit") {
          sh '''
            set -eux

            buildctl \
              --addr tcp://0.0.0.0:1234 \
              build \
              --frontend dockerfile.v0 \
              --local context=frontend \
              --local dockerfile=frontend \
              --output type=image,name=${IMAGE_NAME}:${BUILD_NUMBER},push=true \
              --output type=image,name=${IMAGE_NAME}:latest,push=true \
              --registry-auth
          '''
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
