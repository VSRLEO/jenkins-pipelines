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
    args:
      - --addr
      - tcp://0.0.0.0:1234
    securityContext:
      privileged: true
    volumeMounts:
      - name: docker-config
        mountPath: /root/.docker

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

  volumes:
  - name: docker-config
    secret:
      secretName: dockerhub-secret
"""
    }
  }

  environment {
    IMAGE_NAME = "docker.io/vsr11144/jenkins-buildkit-test"
    IMAGE_TAG  = "${BUILD_NUMBER}"
  }

  stages {

    stage("Build & Push Image") {
      steps {
        container("builder") {
          sh '''
            set -eux

            echo "Workspace:"
            pwd
            ls -la
            ls -la frontend

            buildctl --addr tcp://0.0.0.0:1234 build \
              --frontend dockerfile.v0 \
              --local context=frontend \
              --local dockerfile=frontend \
              --output type=image,name=${IMAGE_NAME}:${IMAGE_TAG},push=true \
              --output type=image,name=${IMAGE_NAME}:latest,push=true
          '''
        }
      }
    }
  }

  post {
    success {
      echo "✅ IMAGE PUSHED TO DOCKER HUB"
    }
    failure {
      echo "❌ PIPELINE FAILED"
    }
  }
}
