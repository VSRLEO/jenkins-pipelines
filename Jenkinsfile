podTemplate(
  label: "kaniko-agent",
  containers: [
    containerTemplate(
      name: 'jnlp',
      image: 'jenkins/inbound-agent:latest'
    ),
    containerTemplate(
      name: 'kaniko',
      image: 'gcr.io/kaniko-project/executor:debug',
      command: '/busybox/cat',
      ttyEnabled: true
    )
  ],
  volumes: [
    secretVolume(
      secretName: 'dockerhub-secret',
      mountPath: '/kaniko/.docker'
    )
  ]
) {
  node("kaniko-agent") {
    container('kaniko') {

      stage('Verify Workspace') {
        sh 'ls -la'
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
