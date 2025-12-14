pipeline {
  agent {
    kubernetes {
      label 'kaniko-agent'
      defaultContainer 'kaniko'
      yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: kaniko
spec:
  restartPolicy: Never
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    tty: true
    env:
      - name: DOCKER_CONFIG
        value: /kaniko/.docker
    command:
      - /busybox/cat
    volumeMounts:
      - name: docker-config
        mountPath: /kaniko/.docker
      - name: workspace-volume
        mountPath: /home/jenkins/agent
  - name: jnlp
    image: jenkins/inbound-agent:latest
    volumeMounts:
      - name: docker-config
        mountPath: /kaniko/.docker
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
    IMAGE_NAME = "docker.io/vsr11144/kaniko-test"
    IMAGE_TAG  = "latest"
  }

  stages {

    stage('Checkout Source') {
      steps {
        checkout scm
      }
    }

    stage('Verify Workspace') {
      steps {
        sh '''
          echo "Workspace contents:"
          ls -la
          test -f Dockerfile
        '''
      }
    }

    stage('Build & Push Image') {
      steps {
        sh '''
          /kaniko/executor \
            --context /home/jenkins/agent/workspace/auto-kaniko-cicd \
            --dockerfile Dockerfile \
            --destination ${IMAGE_NAME}:${IMAGE_TAG} \
            --verbosity info
        '''
      }
    }
  }
}
