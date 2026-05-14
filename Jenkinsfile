pipeline {
  agent {
    kubernetes {
      yaml """
apiVersion: v1
kind: Pod
spec:
  serviceAccountName: jenkins

  containers:

  # =====================================================
  # BuildKit Container
  # =====================================================
  - name: buildkit
    image: moby/buildkit:v0.13.2

    securityContext:
      privileged: true

    args:
      - "--addr"
      - "tcp://0.0.0.0:1234"

    volumeMounts:
      - name: docker-config
        mountPath: /root/.docker

      - name: workspace
        mountPath: /home/jenkins/agent

  # =====================================================
  # SonarQube Scanner Container
  # =====================================================
  - name: sonar
    image: sonarsource/sonar-scanner-cli:latest

    command:
      - cat

    tty: true

    volumeMounts:
      - name: workspace
        mountPath: /home/jenkins/agent

  # =====================================================
  # Jenkins Agent Container
  # =====================================================
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

  # =====================================================
  # Environment Variables
  # =====================================================
  environment {

    IMAGE_NAME = "docker.io/vsr11144/jenkins-buildkit-test"

    # SonarQube Token From Jenkins Credentials
    SONAR_AUTH_TOKEN = credentials('sonar-token')
  }

  stages {

    # =====================================================
    # Checkout Source Code
    # =====================================================
    stage("Checkout") {
      steps {
        checkout scm
      }
    }

    # =====================================================
    # SonarQube Scan
    # =====================================================
    stage("SonarQube Scan") {

      steps {

        container("sonar") {

          withSonarQubeEnv('sonarqube') {

            sh '''
              set -eux

              sonar-scanner \
                -Dsonar.projectKey=jenkins-buildkit-test \
                -Dsonar.sources=frontend \
                -Dsonar.host.url=http://10.0.1.134:9000 \
                -Dsonar.login=$SONAR_AUTH_TOKEN
            '''
          }
        }
      }
    }

    # =====================================================
    # DockerHub Authentication
    # =====================================================
    stage("Write DockerHub Auth (TEST ONLY)") {

      steps {

        container("buildkit") {

          sh '''
            set -eux

            mkdir -p /root/.docker

            cat <<EOF > /root/.docker/config.json
{
  "auths": {
    "https://index.docker.io/v1/": {
      "auth": "dnNyMTExNDQ6ZGNrcl9wYXRfY1g1SFl4OHZIekFPMTNqWU5MQlV0czZWb3dJ"
    }
  }
}
EOF
          '''
        }
      }
    }

    # =====================================================
    # Build & Push Docker Image
    # =====================================================
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
              --output type=image,name=${IMAGE_NAME}:latest,push=true
          '''
        }
      }
    }
  }

  # =====================================================
  # Post Actions
  # =====================================================
  post {

    success {

      echo "✅ SONARQUBE SCAN COMPLETED"
      echo "✅ IMAGE BUILT & PUSHED TO DOCKER HUB"
    }

    failure {

      echo "❌ PIPELINE FAILED"
    }
  }
}
