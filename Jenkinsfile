podTemplate(
  label: 'kaniko-agent',
  yaml: """
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
  - name: jnlp
    image: jenkins/inbound-agent:latest
    volumeMounts:
    - name: docker-config
      mountPath: /kaniko/.docker
  volumes:
  - name: docker-config
    secret:
      secretName: dockerhub-secret
"""
) {

  node('kaniko-agent') {

    stage('Checkout Source') {
      checkout scm
    }

    container('kaniko') {

      stage('Verify Docker Auth') {
        sh '''
          ls -la /kaniko/.docker
          cat /kaniko/.docker/config.json
        '''
      }

      stage('Build & Push Image') {
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
