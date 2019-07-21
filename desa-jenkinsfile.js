pipeline {
        agent { node { label "${LANGUAGE}" } }
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
        git_organizacion = "${GIT_ORGA}"
//      #################################################
//      #       proyecto en donde se va a ejecutar      #
//      #################################################
        proyecto = "${GIT_PROYECTO}"
//      #################################################
//      #       Set env sonar gogs etc                  #
//      #################################################
        SONAR = "http://sonarqube-cicd.devopenshift.bancogalicia.com.ar/"
        NEXUS = "http://nexus3-cicd.devopenshift.bancogalicia.com.ar/"
        GITPUSHER = "gitpusher:Galicia2019"
        GOGS = "http://git.bancogalicia.com.ar/"
        GOGS_URL = "git.bancogalicia.com.ar/"
        
//      #################################################
//      #       SET DEVOPS SCRIPT Y URL GIT             #
//      #################################################
        devops_script = "devops/scripts-v1/${LANGUAGE}.sh"
        }
        stages{
        stage ('Obtener Codigo Fuente')
        {
                steps{
                sh 'git config --global user.email "jenkins"'
                sh 'git config --global user.name "jenkins"'
                checkout(
                [
                        $class: 'GitSCM',
                        branches:
                        [
                                [name: 'refs/heads/' + "$GIT_BRANCH"]
                        ],
                        doGenerateSubmoduleConfigurations: false,
                        extensions: [],
                        submoduleCfg: [],
                        userRemoteConfigs:
                        [
                                [credentialsId: '', url: "${env.GOGS}${env.git_organizacion}/${GIT_REPO}"]
                        ]
                ])
                sh "git clone ${env.GOGS}/Devops-Master/devops.git"
                }
        }
        stage('Compilar')
        {steps{
               sh "./${devops_script} --compilar"
        }
        }
        stage('Carga De Variables')
        {steps{
                sh "./${devops_script} --carga-variables"
        }
        }
        stage("Generar Docker")
        {steps{
                sh "./${devops_script} --generar-docker ${proyecto} ${APP_NAME}"
                openshiftDeploy depCfg: "${APP_NAME}",namespace: "${env.proyecto}",verbose: 'false'
                openshiftVerifyDeployment(namespace: "${env.proyecto}", depCfg: "${APP_NAME}")
        }
        }

        stage('Analisis de Codigo')
        {steps{
                sh "./${devops_script} --analizar"
        }
        }

        stage('Test Unitarios')
        {steps{
                sh './${devops_script} --test-unitarios'
        }
        }
        }

        post {
        always {
            echo 'Run completed'
           
        }
        success {
            echo 'Successfully!'
          
        }
        failure {
            echo 'Failed!'
          
        }
        
        }
}
