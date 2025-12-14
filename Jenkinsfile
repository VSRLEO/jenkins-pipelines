pipeline {
  agent {
    kubernetes {
      label "kaniko-agent"
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
    env:
      - name: DOCKER_CONFIG
        value: /kaniko/.docker
    volumeMounts:
      - name: docker-config
        mountPath: /kaniko/.docker/config.json
        subPath: .dockerconfigjson
      - name: workspace-volume
        mountPath: /home/jenkins/agent
  - name: jnlp
    image: jenkins/inbound-agent:latest
    volumeMounts:
      - name: docker-config
        mountPath: /kaniko/.docker/config.json
        subPath: .dockerconfigjson
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

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build & Push Image') {
      steps {
        sh '''
          /kaniko/executor \
            --context $WORKSPACE \
            --dockerfile Dockerfile \
            --destination docker.io/vsr11144/kaniko-test:latest \
            --verbosity info
        '''
      }
    }
  }
}
