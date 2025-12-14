podTemplate(
  containers: [
    containerTemplate(
      name: 'kaniko',
      image: 'gcr.io/kaniko-project/executor:debug',
      command: '/busybox/cat',
      ttyEnabled: true
    )
  ],
  volumes: [
    secretVolume(secretName: 'dockerhub-secret', mountPath: '/kaniko/.docker')
  ]
) {
  node {
    container('kaniko') {
      sh '''
        /kaniko/executor \
          --context $WORKSPACE \
          --dockerfile Dockerfile \
          --destination docker.io/vsrleo/kaniko-test:latest
      '''
    }
  }
}
