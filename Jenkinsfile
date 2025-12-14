def podLabel = "kaniko-agent-${UUID.randomUUID().toString()}"

podTemplate(
  label: podLabel,
  containers: [
    containerTemplate(
      name: 'kaniko',
      image: 'gcr.io/kaniko-project/executor:debug',
      command: '/busybox/cat',
      ttyEnabled: true,
      envVars: [
        envVar(key: 'DOCKER_CONFIG', value: '/kaniko/.docker')
      ]
    )
  ],
  volumes: [
    secretVolume(
      secretName: 'dockerhub-secret',
      mountPath: '/kaniko/.docker'
    )
  ]
) {

  node(podLabel) {

    stage('Checkout') {
      checkout scm
    }

    stage('Build & Push Image') {
      container('kaniko') {
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
