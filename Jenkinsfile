pipeline {
  agent {
    kubernetes {
      label "kaniko"
      defaultContainer 'kaniko'
      yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    command:
    - /busybox/sleep
    args:
    - "999999"
    volumeMounts:
    - name: docker-config
      mountPath: /kaniko/.docker
  volumes:
  - name: docker-config
    secret:
      secretName: dockerhub-secret
"""
    }
  }

  environment {
    IMAGE_NAME = "docker.io/vsrleo/myapp"
  }

  stages {
    stage('Build & Push Image') {
      steps {
        container('kaniko') {
          sh """
            /kaniko/executor \
              --dockerfile=\${WORKSPACE}/Dockerfile \
              --context=\${WORKSPACE} \
              --destination=\${IMAGE_NAME}:\${BUILD_NUMBER} \
              --verbosity=info
          """
        }
      }
    }
  }
}
