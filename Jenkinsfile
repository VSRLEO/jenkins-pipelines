pipeline {
  agent {
    kubernetes {
      label "auto-ci-cd"
      defaultContainer "builder"
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
      - name: jenkins-home
        mountPath: /home/jenkins/agent

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
      - name: jenkins-home
        mountPath: /home/jenkins/agent

  volumes:
  - name: docker-config
    secret:
      secretName: dockerhub-secret
  - name: jenkins-home
    emptyDir: {}
"""
    }
  }

  environment {
    DOCKER_IMAGE = "docker.io/vsr11144/jenkins-buildkit-test"
    IMAGE_TAG    = "${BUILD_NUMBER}"
  }

  stages {

    stage("Checkout Code") {
      steps {
        checkout scm
        sh '''
          echo "Workspace:"
          pwd
          ls -la
          echo "Frontend directory:"
          ls -la frontend
        '''
      }
    }

    stage("Build & Push Image") {
      steps {
        container("builder") {
          sh '''
            set -e
            echo "Building image"
            echo "Image: ${DOCKER_IMAGE}"
            echo "Tag  : ${IMAGE_TAG}"

            buildctl --addr tcp://0.0.0.0:1234 build \
              --frontend dockerfile.v0 \
              --local context=frontend \
              --local dockerfile=frontend \
              --output type=image,name=${DOCKER_IMAGE}:${IMAGE_TAG},push=true \
              --output type=image,name=${DOCKER_IMAGE}:latest,push=true
          '''
        }
      }
    }
  }

  post {
    success {
      echo "✅ IMAGE PUSHED SUCCESSFULLY"
    }
    failure {
      echo "❌ PIPELINE FAILED"
    }
  }
}
