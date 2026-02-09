pipeline {
  agent {
    kubernetes {
      defaultContainer 'builder'
      yaml """
apiVersion: v1
kind: Pod
spec:
  serviceAccountName: jenkins
  restartPolicy: Never
  containers:
  - name: buildkit
    image: moby/buildkit:v0.13.2
    args:
      - "--addr"
      - "tcp://0.0.0.0:1234"
    env:
      - name: DOCKER_CONFIG
        value: /root/.docker
    securityContext:
      privileged: true
    volumeMounts:
      - name: jenkins-home
        mountPath: /home/jenkins/agent
      - name: docker-config
        mountPath: /root/.docker
  
  - name: builder
    image: docker:27-cli
    command: ["cat"]
    tty: true
    env:
      - name: DOCKER_CONFIG
        value: /root/.docker
    volumeMounts:
      - name: jenkins-home
        mountPath: /home/jenkins/agent
      - name: docker-config
        mountPath: /root/.docker

  - name: jnlp
    image: jenkins/inbound-agent:3355.v388858a_47b_33-3-jdk21
    # ... rest of jnlp config ...

  volumes:
    - name: jenkins-home
      emptyDir: {}
    - name: docker-config
      secret:
        secretName: dockerhub-secret
        # Map the internal key to the filename Docker expects
        items:
          - key: .dockerconfigjson
            path: config.json
"""
    }
  }
  # ... rest of the pipeline ...
}
