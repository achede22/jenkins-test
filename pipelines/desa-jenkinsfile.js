pipeline {
        agent { node { label "${LANGUAGE}" } }

        // El pipeline se cancela si pasa de 10 minutos
        options {
                skipDefaultCheckout()
                disableConcurrentBuilds()
                timeout(20)
                buildDiscarder(logRotator(numToKeepStr: '10')) 

        }
        environment {
//      #################################################
//      #               Organizacion Git                #
//      #################################################
        git_organizacion = "achede22" // tu GIT // achede22  // "${GIT_ORGA}"
//      #################################################
//      #       proyecto en donde se va a ejecutar      #
//      #################################################
        proyecto = "${GIT_PROYECTO}" // tu Journey , tu Tribu
        APP_NAME = "mi_microservicio" // microservicio
//      #################################################
//      #       Set env sonar GIT etc                  #
//      #################################################
        GITPUSHER = "gitpusher:GIT_PUSHER"
        GIT = "http://github.com/"
        GIT_URL = "github.com/"
        GIT_REPO "hola-mundo"
        GIT_REPO_devops = "openshift-okd"
        
//      #################################################
//      #       SET DEVOPS SCRIPT Y URL GIT             #
//      #################################################
        devops_script = "openshift-okd/scripts/${LANGUAGE}/"
        }
        stages{
                stage ('Descargar Repos')
                {
                        sh 'git config --global user.email "jenkins"'
                        sh 'git config --global user.name "jenkins"'
                        
                        // https://github.com/achede22/hola.mundo
                        sh 'echo "--------------------------------------- Descargar Repo ${GIT_REPO}"'
                        sh 'git clone --depth=1 --branch ${GIT_BRANCH} ${GIT}${git_organizacion}/${GIT_REPO}'
                        
                        // https://github.com/achede22/openshift-okd 
                        sh 'echo "--------------------------------------- Descargar Repo DevOps"'
                        sh 'git clone --depth=1 --branch master  ${GIT}${git_organizacion}/${GIT_REPO_devops}'
                }
         
                stage('Carga De Variables')
                {
                        sh 'bash ${devops_script}/1-carga-variables.sh'
                }
         
                stage('Compilar')
                {
                         sh 'echo "------------------------------------------------------------- Compilar"'
                         sh 'bash ${devops_script}/2-compilar.sh'
                }
         
                stage("Crear Imagen ${env.proyecto}")
                {
                        timeout(time:600, unit:'SECONDS'){
                        sh 'echo "------------------------------------------------------------- Image Build"'
                        sh 'bash ${devops_script}/3-crear-imagen.sh ${proyecto} ${APP_NAME}'
                        }
                }
         
                stage('Análisis de SonarQube')
                {
                        sh 'echo "------------------------------------------------------------- Análisis de Código"'
                        sh 'bash ${devops_script}/4-compilar.sh'
                }
                 
          //     stage('Test Unitarios')
          //      
          //            sh 'echo "------------------------------------------------------------- Test Unitarios"'
          //            sh 'bash ${devops_script}/5-test-unitarios.sh'
          //       }
         
         }
