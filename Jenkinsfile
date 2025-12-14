def agentLabel = "kaniko-agent-${UUID.randomUUID()}"

podTemplate(
  label: agentLabel,
  containers: [
    containerTemplate(
      name: 'jnlp',
      image: 'jenkins/inbound-agent:latest',
      args: '${computer.jnlpmac} ${computer.name}'
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
  node(agentLabel) {
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
