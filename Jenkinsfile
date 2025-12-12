pipeline {
  agent {
    kubernetes {
      label "kaniko-build-${env.BUILD_NUMBER}"
      defaultContainer 'jnlp'
      yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:latest
    args: ["--dockerfile=/workspace/Dockerfile","--context=/workspace","--destination=${DOCKER_REGISTRY}/${DOCKER_USER}/${DOCKER_IMAGE}:\${BUILD_NUMBER}","--insecure"] 
    volumeMounts:
      - name: kaniko-secret
        mountPath: /kaniko/.docker
  volumes:
    - name: kaniko-secret
      secret:
        secretName: dockerhub-secret
"""
    }
  }
  environment {
    DOCKER_REGISTRY = "docker.io"
    DOCKER_USER     = credentials('dockerhub-username') // alternative: use credentials plugin for username/token
    DOCKER_IMAGE    = "netflix-clone-app"
  }
  stages {
    stage('Checkout') {
      steps {
        checkout([$class: 'GitSCM', branches: [[name: '*/main']], userRemoteConfigs: [[url: 'https://github.com/VSRLEO/Netflix-Repo.git']]])
        sh 'ls -la'
      }
    }
    stage('Build & Push with Kaniko') {
      steps {
        container('kaniko') {
          sh '''
            /kaniko/executor \
              --dockerfile=/workspace/Dockerfile \
              --context=dir:///workspace \
              --destination=${DOCKER_REGISTRY}/${DOCKER_USER}/${DOCKER_IMAGE}:${BUILD_NUMBER}
          '''
        }
      }
    }
    stage('Deploy to Kubernetes') {
      steps {
        // Either call kubectl (requires kubectl available) or use Kubernetes API
        withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG_FILE')]) {
          sh '''
            kubectl set image deployment/netflix-deploy netflix-container=${DOCKER_REGISTRY}/${DOCKER_USER}/${DOCKER_IMAGE}:${BUILD_NUMBER} --record || \
            kubectl create deployment netflix-deploy --image=${DOCKER_REGISTRY}/${DOCKER_USER}/${DOCKER_IMAGE}:${BUILD_NUMBER}
          '''
        }
      }
    }
  }
}
