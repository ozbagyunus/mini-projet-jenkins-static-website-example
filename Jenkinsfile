pipeline {
  agent none

  environment {
    IMAGE_NAME        = "${PARAM_IMAGE_NAME}"
    IMAGE_TAG         = "latest"
    APP_NAME          = "ozbag-static-site"

    DOCKERHUB_ID      = "ozbagyunus"
    DOCKERHUB_CRED    = credentials('dockerhub_ozbagyunus')

    INTERNAL_PORT     = "80"
    APP_EXPOSED_PORT  = "8090"                    // pour les tests locaux du conteneur dans Jenkins
    EXTERNAL_PORT     = "${PARAM_PORT_EXPOSED}"   // pour staging/prod sur la plateforme

    CONTAINER_IMAGE   = "${DOCKERHUB_ID}/${IMAGE_NAME}:${IMAGE_TAG}"

    STG_API_ENDPOINT  = "ip10-0-55-5-d673q3e57ed000f1a2pg-1993.direct.docker.labs.eazytraining.fr"
    PROD_API_ENDPOINT = "ip10-0-55-6-d673q3e57ed000f1a2pg-1993.direct.docker.labs.eazytraining.fr"
  }

  parameters {
    string(name: 'PARAM_IMAGE_NAME', defaultValue: 'mini-projet-static-website', description: 'Docker image name')
    string(name: 'PARAM_PORT_EXPOSED', defaultValue: '80', description: 'External port for staging/prod deploy')
  }

  stages {

    /* ============ CI PIPELINE ============ */

    stage('BUILD') {
      agent any
      steps {
        script {
          sh 'docker build -t ${DOCKERHUB_ID}/$IMAGE_NAME:$IMAGE_TAG .'
        }
      }
    }

    stage('CODE QUALITY') {
      agent any
      steps {
        script {
          // Simple et efficace pour un mini-projet :
          // - vérifie que le HTML existe
          // - vérifie qu’il y a au moins une balise <html> et <title> (anti “fichier vide”)
          sh '''
            test -f index.html
            grep -qi "<html" index.html
            grep -qi "<title" index.html
          '''
          // Si tu veux un vrai lint (optionnel) : htmlhint / stylelint (nécessite node)
          // sh 'npm ci && npx htmlhint "**/*.html"'
        }
      }
    }

    stage('TESTS') {
      agent any
      steps {
        script {
          sh '''
            echo "Cleaning existing container if exist"
            docker ps -a | grep -i $IMAGE_NAME && docker rm -f $IMAGE_NAME || true

            echo "Run container for tests..."
            docker run --name $IMAGE_NAME -d -p $APP_EXPOSED_PORT:$INTERNAL_PORT ${DOCKERHUB_ID}/$IMAGE_NAME:$IMAGE_TAG
            sleep 3

            echo "HTTP smoke test"
            curl -fsS http://172.17.0.1:$APP_EXPOSED_PORT | grep -qi "<html\\|<!doctype"

            echo "Stopping test container"
            docker stop $IMAGE_NAME || true
            docker rm $IMAGE_NAME || true
          '''
        }
      }
    }

    stage('PACKAGE') {
      agent any
      steps {
        script {
          sh '''
            echo $DOCKERHUB_CRED_PSW | docker login -u $DOCKERHUB_CRED_USR --password-stdin
            docker push ${DOCKERHUB_ID}/$IMAGE_NAME:$IMAGE_TAG
          '''
        }
      }
    }

    /* ============ CD PIPELINE ============ */

    stage('REVIEW/TEST') {
      agent any
      steps {
        script {
          // Ici on “valide l’artefact package” avant déploiement :
          // on pull l’image depuis DockerHub (comme si on était en environnement d’intégration)
          sh '''
            docker pull ${CONTAINER_IMAGE}

            docker ps -a | grep -i ${IMAGE_NAME}-review && docker rm -f ${IMAGE_NAME}-review || true
            docker run --name ${IMAGE_NAME}-review -d -p 8090:${INTERNAL_PORT} ${CONTAINER_IMAGE}
            sleep 3

            curl -fsS http://172.17.0.1:8090 | grep -qi "<html\\|<!doctype"

            docker stop ${IMAGE_NAME}-review || true
            docker rm ${IMAGE_NAME}-review || true
          '''
        }
      }
    }

    stage('STAGING') {
  agent any
  steps {
    script {
      sh """
        echo  {\\"your_name\\":\\"${APP_NAME}\\",\\"container_image\\":\\"${CONTAINER_IMAGE}\\",\\"external_port\\":\\"${EXTERNAL_PORT}\\",\\"internal_port\\":\\"${INTERNAL_PORT}\\"}  > data.json
        cat data.json
        curl -v -X POST https://${STG_API_ENDPOINT}/staging -H 'Content-Type: application/json' --data-binary @data.json  2>&1 | grep 200
      """
    }
  }
}



    stage('PRODUCTION') {
  when {
    anyOf {
      branch 'main'
      branch 'master'
    }
  }
  agent any
  steps {
    script {
      sh """
        echo  {\\"your_name\\":\\"${APP_NAME}\\",\\"container_image\\":\\"${CONTAINER_IMAGE}\\",\\"external_port\\":\\"${EXTERNAL_PORT}\\",\\"internal_port\\":\\"${INTERNAL_PORT}\\"}  > data.json
        cat data.json
        curl -v -X POST https://${PROD_API_ENDPOINT}/prod -H 'Content-Type: application/json' --data-binary @data.json  2>&1 | grep 200
      """
    }
  }
}

}
