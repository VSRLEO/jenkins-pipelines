pipeline {
  agent {
    kubernetes {
      label "kaniko-build"
      defaultContainer 'jnlp'
      yaml """
apiVersion: v1
kind: Pod
spec:
  restartPolicy: Never
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

  stages {
    stage('Build & Push Image with Kaniko') {
      steps {
        container('kaniko') {
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
}
