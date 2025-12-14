podTemplate(
  label: 'kaniko-agent',
  containers: [
    containerTemplate(
      name: 'jnlp',
      image: 'jenkins/inbound-agent:latest',
      args: '-url http://jenkins.jenkins.svc.cluster.local:8080 -workDir=/home/jenkins/agent',
      ttyEnabled: true
    ),
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
  node('kaniko-agent') {
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
