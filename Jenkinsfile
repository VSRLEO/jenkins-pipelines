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

    stage('Checkout Code') {
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

    stage('Build & Push Image') {
      steps {
        container('buildkit') {
          sh """
            set -e
            echo "Building image"
            echo "Image: ${IMAGE_NAME}"
            echo "Tag  : ${IMAGE_TAG}"

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
      echo "IMAGE BUILD & PUSH SUCCESSFUL"
    }
    failure {
      echo "PIPELINE FAILED"
    }
  }
}
