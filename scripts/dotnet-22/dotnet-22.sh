#!/bin/bash -x
f_leer_parametros ()
{
        while [[ $# > 0 ]] ; do
                case $1 in
                        -c|--compilar)
                                f_compilar
                                shift
                        ;;
                        -t|--test-unitarios)
                                f_test_unitarios
                                shift
                        ;;
                        --preparar-sonar)
                                f_preparar_sonar
                                shift
                        ;;
                        -a|--analizar)
                                f_analizar
                                shift
                        ;;
                        -r|--release)
                                f_release_netcore
                                shift
                        ;;
                        --generar-docker)
                                f_generar_docker_from_dir "$2" "$3"
                                shift
                                shift
                                shift
                        ;;
                        -g|--generar-docker-homo)
                                f_generar_docker_homo
                                shift
                        ;;
                        -g|--generar-docker-prod)
                                f_generar_docker_prod
                                shift
                        ;;
                        -g|--generar-docker-dev)
                                f_generar_docker_dev
                                shift
                        ;;
                        --patch-homo)
                                f_patch_homo
                                shift
                        ;;
                        --patch-prod)
                                f_patch_prod
                                shift
                        ;;

                        --carga-variables)
                                f_carga_variables
                                shift
                        ;;

                        *)
                                f_problema "1" "Parámetro no soportado $1"
                        ;;
                esac
                shift
        done
}
f_muestra ()
{
        echo "$(date) : $@"
}
f_problema ()
{
        if [ $1 -gt 0 ] ;then
                f_muestra "Error ::: $2"
                exit 1
        else
                f_muestra "$3"
        fi
}
f_patch_homo ()
{
        f_unset_proxy

        oc patch dc ${APP_NAME} --patch "{\"spec\": { \"triggers\": [ { \"type\": \"ImageChange\", \"imageChangeParams\": { \"containerNames\": [ \"${APP_NAME}\" ], \"from\": { \"kind\": \"ImageStreamTag\", \"namespace\": \"${proyecto}\", \"name\": \"${APP_NAME}:$(echo $version|sed '1q')\"}}}]}}" -n ${proyecto}
        f_problema "$?" "CRITICAL oc patch dc" "oc patch dc - OK "

}
f_patch_prod ()
{
        oc patch dc ${APP_NAME} --patch "{\"spec\": { \"triggers\": [ { \"type\": \"ImageChange\", \"imageChangeParams\": { \"containerNames\": [ \"${APP_NAME}\" ], \"from\": { \"kind\": \"ImageStreamTag\", \"namespace\": \"${proyecto}\", \"name\": \"${APP_NAME}:$(echo $version|sed '1q')\"}}}]}}" -n ${proyecto}

}

f_push_nexus ()
{

        export http_proxy=http://app-proxy.bancogalicia.com.ar:80
        export https_proxy=http://app-proxy.bancogalicia.com.ar:80
        export HTTP_PROXY=http://app-proxy.bancogalicia.com.ar:80
        export HTTPS_PROXY=http://app-proxy.bancogalicia.com.ar:80
        ls -ltra MS.N.Core/
        ls -ltra MS.N.Core/ |wc -l
        echo "llego aca "
        dotnet pack  ${archivo_proyecto}
        ls -ltra MS.N.Core/|wc -l
        ls -ltra MS.N.Core/


}

f_compilar ()
{
	# nuget sources Add -Name NexusGalicia -Source ${NEXUS} -UserName dev1 -Password dev1

        f_unset_proxy
        f_muestra "Repository Manager: ${NEXUS}"
		curl -v ${NEXUS} | grep Nexus
        
        f_muestra "################################################################# Compilando...."
        dotnet build ${DOTNET_STARTUP_PROJECT} -v n
        #dotnet build ${PROJECT_FOLDERS} -v n
        
        f_problema "$?" "Problemas al compilar" "Ok"
        
        #dotnet clean  ${PROJECT_FOLDERS}
        #f_problema "$?" "Problemas al compilar" "Ok"
}
f_test_unitarios ()
{
        if [[ ! -z "${DOTNET_STARTUP_PROJECT_test}" && -e ${DOTNET_STARTUP_PROJECT_test} ]]
        then
                f_muestra "########################  Ejecutando Test en ${DOTNET_STARTUP_PROJECT_test}"
                dotnet test ${DOTNET_STARTUP_PROJECT_test}
                f_problema "$?" "Problemas al ejecutar los test unitarios" "Ok"
        else
                f_muestra "No se estableció proyecto de Test..."
        fi
}

f_analizar_DISABLED () # binario en .zip
{       # add sonar sources to Stt.DatosOperador.MS 
	# SONAR_SOURCES=$(ls -c1 | grep -v "devops")

        # token SacaTuTurno ---> d5df2105b25114088597d9d6a0ebfecaa376819b

        mkdir -p sonar-scanner-msbuild
        pwd
        ls -c1
        unzip devops/binarios/sonar-scanner-msbuild-4.6.0.1930-netcoreapp2.0.zip -d sonar-scanner-msbuild

        chmod 775 sonar-scanner-msbuild/**/bin/*
        chmod 775 sonar-scanner-msbuild/**/lib/*.jar

        echo "sonar.sources=." >> sonar-scanner-msbuild/sonar-scanner-3.3.0.1492/conf/sonar-scanner.properties

	## UNZIPPED FOLDER sonar-scanner-3.3.0.1492

        #dotnet ./sonar-scanner-msbuild/SonarScanner.MSBuild.dll begin /k:${sonarkey} /d:sonar.host.url=${SONAR}
        # /home/jenkins/sonar-scanner-3.2.0.1227-linux/bin/sonar-scanner \

        f_muestra "Proyectos a Escanear"
        for APP in $(echo $PROJECT_APPS); do echo "Proyecto $APP"; done
        
        number=0 ### app counter, start variable

        for BASE_DIR in $(echo $PROJECT_FOLDERS); do

                CURRENT_LATEST_FOLDER=$(echo $BASE_DIR | rev | cut -d"/" -f1 | rev) # Name of the latest folder in path
                CURRENT_PROJECT_FOLDER=$(echo $BASE_DIR | cut -d"/" -f1 )

                number=`echo "$number + 1" | bc` ; echo $number ### app counter , para usar en el "cut" y tener el nombre de la última carpeta

                echo $LATEST_FOLDER | cur -d" " -f$number
                f_muestra "---------------------------------------------- Analizando $LATEST_FOLDER"

                ./sonar-scanner-msbuild/sonar-scanner-3.3.0.1492/bin/sonar-scanner \
                -Dsonar.host.url=${SONAR} \
                -Dsonar.login=admin \
                -Dsonar.password=admin \
                -Dsonar.projectKey=$CURRENT_LATEST_FOLDER -X \
                -Dsonar.projectBaseDir=$BASE_DIR

	         f_problema "$?" "CRITICAL HUBO UN PROBLEMA ANALIZANDO CON SONAR" "SONAR OK"
        done
 
        # dotnet build ${DOTNET_STARTUP_PROJECT}
        # dotnet ./sonar-scanner-msbuild/SonarScanner.MSBuild.dll end
        # f_muestra "Liberando espacio"
        # df -h
        # rm ./devops/sonar-scanner-msbuild-4.2.0.1214-netcoreapp2.0.zip
        # dotnet clean ${DOTNET_STARTUP_PROJECT}
        # rm -rf ./sonar-scanner-msbuild
        # rm -rf .sonarqube
        # df -h

        # f_problema "$?" "Problemas al analizar con Sonar" "Ok"
}

f_analizar ()  
# dotnet tool , sin descomprimir el ZIP
# con SONAR as dotnet core global tool - .Net Core 2.1
# https://www.nuget.org/packages/dotnet-sonarscanner/
# https://docs.sonarqube.org/display/SCAN/Analyzing+with+SonarQube+Scanner+for+MSBuild

{
        export PATH="$PATH:/home/jenkins/.dotnet/tools" ############## to install dotnet tool
                
        f_muestra "---------------------------------------------- Instalando SonarQube Scanner (dotnet tool)"
                dotnet tool install --global dotnet-sonarscanner
                dotnet-sonarscanner /h ##### show help

        number=0        ### app counter, start variable
         
        f_muestra "#################################################################### bucle for"
        # For loop, in chase that find more than one .csproj files found
        # Between the "begin" and "end" steps, you need to build your project, 
        # execute tests and generate code coverage data. 
        # This part is specific to your needs and it is not detailed here.
        for BASE_DIR in $(echo $PROJECT_FOLDERS); do

                PWD=$(pwd) #present working directory, out of the loop
                # Load new variables inside "for loop"   
                CURRENT_LATEST_FOLDER=$(echo $BASE_DIR | rev | cut -d"/" -f1 | rev) # Name of the latest folder in path
                CURRENT_PROJECT_FOLDER=$(echo $BASE_DIR | cut -d"/" -f1 )

                # varios archivos .sln en una linea, separados por espacio
                f_muestra "$PROJECT_SOLUTION "

                ### app counter , para usar en el "cut" y separar $CURRENT_PROJECT_SOLUTION
                number=`echo "$number + 1" | bc` ; echo $number 
                CURRENT_PROJECT_SOLUTION=$( echo $PROJECT_SOLUTION | cut -d" " -f$number )
                CURRENT_DOTNET_STARTUP_PROJECT=$( echo $DOTNET_STARTUP_PROJECT | cut -d" " -f$number )

                # sonnar_setting 
                f_muestra "---------------------------------------------- Analizando $LATEST_FOLDER"
                        #/name:$CURRENT_LATEST_FOLDER \
                        #       When executing the begin phase, at least the project key must be defined.
                        # Other properties can dynamically be defined with '/d:'. For example, '/d:sonar.verbose=true'.
                        # A settings file can be used to define properties. 
                        # If no settings file path is given, the file SonarQube.Analysis.xml in the installation directory will be used.
                        # Only the token should be passed during the end phase, if it was used during the begin phase

                export SONNAR_SETTINGS=$(find * -type f | grep "Analysis.xml$" )

                f_muestra "---------------------------------------------- SonarQube Settings"
                        cat $SONNAR_SETTINGS
                f_muestra "---------------------------------------------- SonarQube Settings"
                
                #   Note that the following properties cannot be set through an MSBuild project file 
                #  or an SonarQube.Analysis.xml file:
                        # sonar.projectName, sonar.projectKey, sonar.projectVersion
                pwd ; ls -lah 
                dotnet-sonarscanner begin \
                        /d:sonar.projectBaseDir=${PWD}/$CURRENT_PROJECT_FOLDER \
                        /k:$CURRENT_LATEST_FOLDER \
                        /n:$CURRENT_PROJECT_FOLDER \
                        /s:${PWD}/devops/scripts/SonarQube.Analysis.xml

                f_muestra "---------------------------------------------- SonarQube Compila"
                dotnet build ${CURRENT_DOTNET_STARTUP_PROJECT}

                # Credentials must be passed in both begin and end steps or not at all
                # Unrecognized command line argument: /k: /n: /s: projectBaseDir
                                               
                dotnet sonarscanner end # || echo "Failed $CURRENT_PROJECT_FOLDER " >> Sonar_Failed.log || f_analizar  # START AGAIN IF ERROR
                        # si falla el análisis, falla el pipeline

        # ####################################################################

	        f_problema "$?" "CRITICAL HUBO UN PROBLEMA ANALIZANDO CON SONAR" "SONAR OK"
        done
        
       # f_muestra "############################################################### SONAR FAILED IN : "
       # cat Sonar_Failed.log
       # f_muestra "############################################################### "
}

f_generar_docker_dev ()
{
        f_muestra "Generar docker DEV"
        oc start-build ${APP_NAME} --from-dir=./ --follow -n ${dev_proyecto} || exit 1 #Salir si Falla
}

f_generar_docker_homo ()
{
        f_muestra "Generar docker HOMO"
        oc start-build ${APP_NAME} --from-dir=./ --follow -n ${homo_proyecto}
}
f_generar_docker_prod ()
{
        f_muestra "Generar docker PROD"
        oc start-build ${APP_NAME} --from-dir=./ --follow -n ${prod_proyecto}
}
f_check_variable ()
{
        if [ -z $1 ] ; then
                f_problema "1" "No existe la variable $2 = $1"
        fi
}
f_generar_docker_from_dir () 
{
        # WARNING: Specifying --build-loglevel with binary builds is not supported.
        # WARNING: Specifying environment variables with binary builds is not supported.
	
    f_muestra "---------------------------------------------- OpenShift Compila"
        
        # from PROJECT_APPS to PROJECT_DLL --> replace .csproj by .dll
        export PROJECT_DLL=$(echo ${PROJECT_APPS} | sed 's/csproj/dll/')

          oc version
          oc project ${proyecto}
          ls -c1 ${PROJECT_FOLDERS}
           # bin/Debug/netcoreapp2.2/Stt.PantallasDinamicas.MS.dll
         
         # ./devops/binarios/oc start-build ${APP_NAME} --from-file=${PROJECT_FOLDERS}/bin/Debug/netcoreapp2.2/${PROJECT_DLL} -n ${proyecto}
           oc start-build ${APP_NAME} --from-dir=${PROJECT_FOLDERS} -n ${proyecto} --follow

    f_problema "$?" "fallo el build" "build OK"


}
f_unset_proxy ()
{
        unset http_proxy
        unset https_proxy
        unset no_proxy
        unset HTTP_PROXY
        unset HTTPS_PROXY
        unset no_proxy

        echo "$http_proxy"
        echo "$https_proxy"
}

f_set_proxy ()
{
        export http_proxy=http://app-proxy.bancogalicia.com.ar:80
        export https_proxy=http://app-proxy.bancogalicia.com.ar:80
        export HTTP_PROXY=http://app-proxy.bancogalicia.com.ar:80
        export HTTPS_PROXY=http://app-proxy.bancogalicia.com.ar:80
        export no_proxy=".bancogalicia.com.ar,.cluster.local,.svc,10.0.78.3,10.0.78.4,10.0.78.5,10.254.16.0/20,10.254.16.1,10.254.32.0/20,127.0.0.1,dookubinf01.bancogalicia.com.ar,dookubinf02.bancogalicia.com.ar,dookubinf03.bancogalicia.com.ar,dookubmas01.bancogalicia.com.ar,dookubmas02.bancogalicia.com.ar,dookubmas03.bancogalicia.com.ar,dookubnod01.bancogalicia.com.ar,dookubnod02.bancogalicia.com.ar,dookubnod03.bancogalicia.com.ar,localhost"

        echo "$http_proxy"
        echo "$https_proxy"
}

f_release_netcore ()
{
        if [ "$APP_NAME" == "msngenerarcuix" ]; then
                ls -la
                echo "soy cuix"
                old_version="$(sed '1q' version|sed 's/ //g')"
                new_version="$(echo ${old_version}|awk -F"." '{print $1"."$2"."$3+1}')"
                echo "${new_version}" > version
                sed -i '/^$/d'  version
                git checkout master
                git add "version"
                git commit -m "change version to ${new_version}"
                git tag -a ${new_version} -m "nueva version ${new_version}"
                git tag
                GIT_REPO="${GOGS:0:7}${GITPUSHER}"@"${GOGS:7}""${git_organizacion}"/"${GIT_REPO}"
                git push ${GIT_REPO} master
                git push ${GIT_REPO} --tags
                exit 0
        fi

	cd ${GIT_REPO} #change path

        ls -ltra
        #path=$(echo ${APP_NAME} | sed 's/msn//g'|sed 's/.*/\u&/' | sed 's/^\(.\{0\}\)/MS.N./')
        #ln -s $path/version version
        old_version="$(sed '1q' version|sed 's/ //g')"
        new_version="$(echo ${old_version}|awk -F"." '{print $1"."$2"."$3+1}')"
        echo "${new_version}" > version
        sed -i '/^$/d'  version
        git checkout master
        git add "version"
        git commit -m "change version to ${new_version}"
        git tag -a ${new_version} -m "nueva version ${new_version}"
        git tag
        GIT_REPO="${GOGS:0:7}${GITPUSHER}"@"${GOGS:7}""${git_organizacion}"/"${GIT_REPO}"
        git push ${GIT_REPO} master
        git push ${GIT_REPO} --tags
        return 0
}

f_carga_variables ()
{
        # llama a funciones que sólo se ejecutan una vez
        # y no son un stage
        cp devops/binarios/oc ${GIT_REPO}/oc # load oc
        cp devops/binarios/jq-linux64 ${GIT_REPO}/jquery # load jquery

        cd ${GIT_REPO} ;ls -c1 # change directory

        ./oc version
        ./oc version | grep 3.11 && echo "ERROR: oc version 3.11 found" && exit 1

        oc project ${proyecto}

        f_muestra "########################################################################## Carga de Variables"

        f_muestra "#-------------------------------------------------------------  Variables al ConfigMap"
                # Mostrar las variables de entorno a cargar
                cat variables/${proyecto} || exit 1 || echo "Error: No existe el archivo variables/${proyecto}"

                # "ELIMINAR el configMap completo, no falla si configMap no existe"
                ./oc delete configmap ${APP_NAME} -n ${proyecto} --ignore-not-found=true 

                # "CARGAR nuevas variables desde el repo al ConfigMap"
                ./oc create configmap ${APP_NAME} --from-env-file=variables/${proyecto} -n ${proyecto}


        f_muestra "#-------------------------------------------------------------  Variables al DeploymentConfig (dc)"

                 # "CREA una variable para que no falle el paso de eliminar todas"
                ./oc set env dc ${APP_NAME} TZ="America/Argentina/Buenos_Aires" -n ${proyecto} # oc 3.9

                # "EXPORTA el DeploymentConfig."
                ./oc export dc ${APP_NAME} -o json > /tmp/DC.json || exit 1 

                # "ELIMINA todas las varibles del DeploymentConfig en json"
                ./jquery 'del(.spec.template.spec.containers[].env)' /tmp/DC.json > /tmp/DCmodified.json

                # "IMPORTA el DeploymentConfig modificado sin variables de entorno"
                ./oc replace -f /tmp/DCmodified.json

                # "CARGAR nuevas variables desde ConfigMap al DeploymentConfig"
                ./oc set env dc ${APP_NAME} --from configmap/${APP_NAME}


        f_muestra "#-------------------------------------------------------------  Variables al Build Config (bc) "

                # "CREA una variable para que no falle el paso de eliminar todas"
                ./oc set env bc ${APP_NAME} TZ="America/Argentina/Buenos_Aires" -n ${proyecto}

                # "EXPORTA el BuildConfig"
                ./oc export bc ${APP_NAME} -o json > /tmp/BC.json || exit 1

                # "ELIMINA todas las varibles del BuildConfig en json"
                ./jquery 'del(.spec.strategy.sourceStrategy.env)' /tmp/BC.json > /tmp/BCmodified.json

                # "IMPORTA el BuildConfig modificado sin variables de entorno"
                ./oc replace -f /tmp/BCmodified.json

                # "CARGAR nuevas variables desde ConfigMap al BuildConfig"
                ./oc set env bc ${APP_NAME} --from configmap/${APP_NAME} 

        f_muestra "##########################################################################  RESULTADOS "
                f_muestra "variables de entorno en el ConfigMap -------------------------------------"
                ./oc describe configmap ${APP_NAME} || exit 1

                f_muestra "variables de entorno en el DeploymentConfig -------------------------------------"
                ./oc env dc ${APP_NAME} --list || exit 1

                f_muestra "variables de entorno en el BuildConfig -------------------------------------"
                ./oc env bc ${APP_NAME} --list || exit 1
        
                rm -f oc
                rm -f jquery
		cd ..  # change back directory
                pwd
}

f_dotnet_startup_project ()
{
        #sólo para dotnet, reemplaza la variable DOTNET_STARTUP_PROJECT   
        # cd /tmp/workspace/${proyecto}/${proyecto}-${APP_NAME}-pipeline/

        export DOTNET_STARTUP_PROJECT_test=$( find * -type f | grep -i "Test.csproj$" | grep -v -i user ) # ARCHIVO .test.csproj
        export DOTNET_STARTUP_PROJECT=$( find * -type f | grep ".csproj$" | grep -v -i test ) # ARCHIVO .csproj
        export PROJECT_APPS=$( find * -type f -printf "%f\n" | grep ".csproj$" | grep -v -i test ) # varios ARCHIVOS .csproj
        export PROJECT_SOLUTION=$( find * -type f | grep ".sln$" | grep -v -i test ) # ARCHIVO .sln
        export PROJECT_FOLDERS=$(dirname $DOTNET_STARTUP_PROJECT) 
        export My_PATH=$(pwd)
}


main ()
{
        #carga la variable DOTNET_STARTUP_PROJECT
        f_dotnet_startup_project     
	f_unset_proxy
		
        f_muestra "Iniciando...."
        #f_check_variable "${APP_NAME}" "app"
        #f_check_variable "${dev_proyecto}" "dev_proyecto"
        #f_check_variable "${homo_proyecto}" "homo_proyecto"
        #f_check_variable "${prod_proyecto}" "prod_proyecto"
        # f_check_variable "${DOTNET_STARTUP_PROJECT}" "DOTNET_STARTUP_PROJECT" # lo declara la función f_dotnet_startup_project
        # f_check_variable "${carpeta_proyecto}" "carpeta_proyecto"
        #f_check_variable "${SONAR}" "SONAR"
        # f_check_variable "${sonarkey}" "sonar_key"
        f_leer_parametros "$@"

}
main $@
exit 0


