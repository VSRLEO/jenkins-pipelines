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
      - name: workspace-volume
        mountPath: /home/jenkins/agent

  - name: builder
    image: docker:27-cli
    command: ["cat"]
    tty: true
    volumeMounts:
      - name: workspace-volume
        mountPath: /home/jenkins/agent

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
    IMAGE_NAME = "docker.io/vsr11144/jenkins-buildkit-test"
    IMAGE_TAG  = "${BUILD_NUMBER}"
  }

  stages {

    stage("Build & Push Image (BuildKit)") {
      steps {
        container("buildkit") {
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
      echo "✅ IMAGE BUILT AND PUSHED SUCCESSFULLY"
    }
    failure {
      echo "❌ PIPELINE FAILED"
    }
  }
}
