pipeline {
  agent {
    kubernetes {
      label 'kaniko'
      // Define the custom container here, not inside a 'yaml' block
      containerTemplate {
        name 'kaniko'
        image 'gcr.io/kaniko-project/executor:debug'
        command '/busybox/cat'
        tty true
        volumeMounts {
          volumeMount {
            mountPath '/kaniko/.docker'
            name 'docker-config'
          }
        }
      }
      
      // Define the required volume here
      volumes {
        secret {
          secretName 'dockerhub-secret'
          mountPath '/kaniko/.docker'
          name 'docker-config'
        }
      }
    }
  }

  environment {
    IMAGE_NAME = "docker.io/vsrleo/kaniko-test"
  }

  stages {
    stage('Build & Push') {
      steps {
        // Run the steps inside the custom 'kaniko' container
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
