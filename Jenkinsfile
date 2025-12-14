def label = "kaniko-${UUID.randomUUID()}"

podTemplate(
  label: label,
  containers: [
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
  node(label) {
    container('kaniko') {
      sh '''
        /kaniko/executor \
          --context $WORKSPACE \
          --dockerfile Dockerfile \
          --destination docker.io/vsrleo/kaniko-test:latest \
          --verbosity info
      '''
    }
  }
}
