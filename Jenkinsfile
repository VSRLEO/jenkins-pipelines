pipeline {
    // Note: The 'label' option is deprecated. 'inheritFrom' is preferred for static templates.
    agent {
        kubernetes {
            cloud 'kubernetes'
            label "kaniko-${env.BUILD_NUMBER}"
            defaultContainer 'jnlp'

            // --- CORRECTED KUBERNETES POD YAML ---
            yaml """
apiVersion: v1
kind: Pod
spec:
  serviceAccountName: jenkins
  restartPolicy: Never

  volumes:
    - name: docker-config
      secret:
        secretName: dockerhub-secret

  containers:
    - name: jnlp
      image: jenkins/inbound-agent:latest
      # The JNLP container will run automatically and connect to Jenkins

    - name: kaniko
      image: gcr.io/kaniko-project/executor:latest
      # We use a placeholder command to keep the container running and idle
      # until the pipeline explicitly calls it in a 'container()' block.
      command:
        - /busybox/sh
      args:
        - -c
        - 'tail -f /dev/null' # This command runs forever, keeping the Kaniko container alive.
      volumeMounts:
        - name: docker-config
          mountPath: /kaniko/.docker
"""
        }
    }

    stages {

        stage('Checkout') {
            steps {
                echo "⏳ Starting source code checkout..."
                checkout scm
                echo "✅ Checkout complete."
            }
        }

        stage('Build & Push Image') {
            steps {
                container('kaniko') {
                    echo "🚀 Kaniko build & push started..."
                    // Execute the Kaniko command INSIDE the running 'kaniko' container.
                    // This ensures the workspace is populated with the source code first.
                    sh """
                        /kaniko/executor \
                          --dockerfile=/home/jenkins/agent/workspace/Dockerfile \
                          --context=/home/jenkins/agent/workspace \
                          --destination=docker.io/vsr11144/netflix-clone-app:${BUILD_NUMBER} \
                          --destination=docker.io/vsr11144/netflix-clone-app:latest \
                          --verbosity=info
                    """
                    echo "✅ Image built and pushed successfully."
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline finished successfully. Image: vsr11144/netflix-clone-app:${BUILD_NUMBER}"
        }
        failure {
            echo "❌ Kaniko build failed. Check Kaniko container logs for details."
        }
        always {
            // Optional cleanup task if needed
        }
    }
}
