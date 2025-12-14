pipeline {
  agent {
    kubernetes {
      label "kaniko"
      defaultContainer 'jnlp'

      yaml """
apiVersion: v1
kind: Pod
spec:
  serviceAccountName: jenkins
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    imagePullPolicy: Always
    args:
      - "--dockerfile=Dockerfile"
      - "--context=\$(WORKSPACE)"
      - "--destination=vsr11144/netflix-clone:latest"
      - "--verbosity=info"
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

  stages {
    stage('Build & Push Image') {
      steps {
        echo "Building and pushing Docker image using Kaniko"
      }
    }
  }
}
