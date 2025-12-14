pipeline {
  agent none

  stages {
    stage('Build & Push Image with Kaniko') {
      agent {
        kubernetes {
          label 'kaniko'
          defaultContainer 'kaniko'
          yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    command:
      - /busybox/cat
    tty: true
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
        IMAGE_NAME = "docker.io/vsrleo/kaniko-test"
      }

      steps {
        sh '''
          /kaniko/executor \
            --context $WORKSPACE \
            --dockerfile $WORKSPACE/Dockerfile \
            --destination $IMAGE_NAME:latest \
            --verbosity info
        '''
      }
    }
  }
}
