#!/bin/bash -x

f_menu()
{
    echo "
    GRUPO_ms-supervisor
        - ms-supervisor.
        - backend-ms-supervisor.

    GRUPO_ms-priorizacion-cliente-ticket
        - ms-priorizacion-cliente-ticket
        - backend-ms-priorizacion-cliente-ticket

    GRUPO_ms-pantallas-dinamicas
        - ms-pantallas-dinamicas
        - backend-ms-pantallas-dinamicas
        
    GRUPO_ms-datos-operador
        - ms-datos-operador
        - backend ms-datos-operador

    GRUPO_ms-consulta-datos-persona-empresa
        - ms-consulta-datos-persona-empresa.
        - backend-ms-consulta-datos-persona-empresa.

    GRUPO_ms-televisor
        - ms-televisor 
        - backend-ms-televisor 

    GRUPO_ms-server-comunicacion
        - ms-server-comunicacion
        - backend-ms-server-comunicacion

    GRUPO_ms-tickets
        - ms-tickets
        - backend-ms-tickets

    GRUPO_impresion-ticket
        - impresion-ticket

    GRUPO_cqrs
        - cqrs

    GRUPO_ui
        - ui-supervisor  (Node.Js)
        - ui-llamador   (NET-CORE)
        - ui-monitor    (Node.Js)
        - ui-totem  (Node.Js)
        - ui-monitor-ultimos (Node.Js)

    GRUPO_abm
        - abm

    ESCANEAR TODOS LOS REPO
        - todos los anteriores
    " tee devops/scripts/repo_list.txt
}

f_repo_list()
{
echo "
GRUPO_ms-supervisor
GRUPO_ms-priorizacion-cliente-ticket
GRUPO_ms-pantallas-dinamicas
GRUPO_ms-datos-operador
GRUPO_ms-consulta-datos-persona-empresa
GRUPO_ms-televisor
GRUPO_ms-server-comunicacion
GRUPO_ms-tickets
GRUPO_impresion-ticket
GRUPO_cqrs
GRUPO_ui
GRUPO_abm
ESCANEAR TODOS LOS REPO
" >> repo_list.txt
}

f_muestra ()
{
        echo "$(date) : $@"
}

f_ms-supervisor()
{
  git clone --depth=1 --branch ${GIT_BRANCH} ${GOGS}${git_organizacion}/ms-supervisor
  git clone --depth=1 --branch ${GIT_BRANCH} ${GOGS}${git_organizacion}/backend-ms-supervisor
}

f_ms-priorizacion-cliente-ticket()
{
  git clone --depth=1 --branch ${GIT_BRANCH} ${GOGS}${git_organizacion}/ms-priorizacion-cliente-ticket
  git clone --depth=1 --branch ${GIT_BRANCH} ${GOGS}${git_organizacion}/backend-ms-priorizacion-cliente-ticket
}

f_ms-pantallas-dinamicas()
{
     git clone --depth=1 --branch ${GIT_BRANCH} ${GOGS}${git_organizacion}/ms-pantallas-dinamicas
     git clone --depth=1 --branch ${GIT_BRANCH} ${GOGS}${git_organizacion}/backend-ms-pantallas-dinamicas
}

f_ms-datos-operador()
{
     git clone --depth=1 --branch ${GIT_BRANCH} ${GOGS}${git_organizacion}/ms-datos-operador
     git clone --depth=1 --branch ${GIT_BRANCH} ${GOGS}${git_organizacion}/backend-ms-datos-operador
}

f_ms-consulta-datos-persona-empresa()
{
     git clone --depth=1 --branch ${GIT_BRANCH} ${GOGS}${git_organizacion}/ms-consulta-datos-persona-empresa
     git clone --depth=1 --branch ${GIT_BRANCH} ${GOGS}${git_organizacion}/backend-ms-consulta-datos-persona-empresa
}

f_ms-televisor()
{
     git clone --depth=1 --branch ${GIT_BRANCH} ${GOGS}${git_organizacion}/ms-televisor
     git clone --depth=1 --branch ${GIT_BRANCH} ${GOGS}${git_organizacion}/backend-ms-televisor
}

f_ms-tickets()
{
    git clone --depth=1 --branch ${GIT_BRANCH} ${GOGS}${git_organizacion}/ms-tickets
    git clone --depth=1 --branch ${GIT_BRANCH} ${GOGS}${git_organizacion}/backend-ms-tickets
}

f_ms-server-comunicacion()
{
    git clone --depth=1 --branch ${GIT_BRANCH} ${GOGS}${git_organizacion}/ms-server-comunicacion
    git clone --depth=1 --branch ${GIT_BRANCH} ${GOGS}${git_organizacion}/backend-ms-server-comunicacion
}
 
f_cqrs(){
    git clone --depth=1 --branch ${GIT_BRANCH} ${GOGS}${git_organizacion}/cqrs
}

f_ui()
{
  #  git clone --depth=1 --branch ${GIT_BRANCH} ${GOGS}${git_organizacion}/ui-supervisor
    git clone --depth=1 --branch ${GIT_BRANCH} ${GOGS}${git_organizacion}/ui-llamador
  #  git clone --depth=1 --branch ${GIT_BRANCH} ${GOGS}${git_organizacion}/ui-monitor
  #  git clone --depth=1 --branch ${GIT_BRANCH} ${GOGS}${git_organizacion}/ui-totem
  #  git clone --depth=1 --branch ${GIT_BRANCH} ${GOGS}${git_organizacion}/ui-monitor-ultimos
}

f_abm()
{
    git clone --depth=1 --branch ${GIT_BRANCH} ${GOGS}${git_organizacion}/abm
}

f_impresion-ticket()
{
    git clone --depth=1 --branch ${GIT_BRANCH} ${GOGS}${git_organizacion}/impresion-ticket
}

f_todos_los_repo()
{
    f_ms-supervisor
    f_ms-priorizacion-cliente-ticket
    f_ms-pantallas-dinamicas
    f_ms-datos-operador
    f_ms-consulta-datos-persona-empresa
    f_ms-televisor
    f_ms-tickets
    f_ms-server-comunicacion
    f_cqrs
    f_abm
    f_ui
}

f_analizar ()  
# dotnet tool , sin descomprimir el ZIP
# con SONAR as dotnet core global tool - .Net Core 2.1
# https://www.nuget.org/packages/dotnet-sonarscanner/
# https://docs.sonarqube.org/display/SCAN/Analyzing+with+SonarQube+Scanner+for+MSBuild

{
        f_dotnet_startup_project # load variables

        export PATH="$PATH:/home/jenkins/.dotnet/tools" ############## to install dotnet tool
                
        f_muestra "---------------------------------------------- Instalando SonarQube Scanner (dotnet tool)"
                dotnet tool install --global dotnet-sonarscanner
                dotnet-sonarscanner /h ##### show help

        number=0        ### app counter, start variable
         
        f_muestra "#################################################################### bucle for"
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
                # START AGAIN IF ERROR
                dotnet sonarscanner end || echo "Failed $CURRENT_PROJECT_FOLDER " >> Sonar_Failed.log || f_analizar

        # ####################################################################

	        f_problema "$?" "CRITICAL HUBO UN PROBLEMA ANALIZANDO CON SONAR" "SONAR OK"
        done
        
        f_muestra "################################################################ SONAR FAILED IN : "
        cat Sonar_Failed.log
        f_muestra "############################################################### "
}

f_dotnet_startup_project ()
{
        #sólo para dotnet, reemplaza la variable DOTNET_STARTUP_PROJECT
        
        # cd /tmp/workspace/${proyecto}/${proyecto}-${APP_NAME}-pipeline/
        export DOTNET_STARTUP_PROJECT=$( find * -type f | grep ".csproj$" | grep -v -i test )
        export PROJECT_APPS=$( find * -type f -printf "%f\n" | grep ".csproj$" | grep -v -i test )
        export PROJECT_SOLUTION=$( find * -type f | grep ".sln$" | grep -v -i test ) # ARCHIVO .sln
        export PROJECT_FOLDERS=$(dirname $DOTNET_STARTUP_PROJECT) 
}

    echo "------------------------------------------------------ $1"
    echo "$1" | grep "menu" && f_menu
    echo "$1" | grep "repo_list" && f_repo_list
    echo "$1" | grep "GRUPO_ms-supervisor" && f_ms-supervisor
    echo "$1" | grep "GRUPO_ms-priorizacion-cliente-ticket" && f_ms-priorizacion-cliente-ticket
    echo "$1" | grep "GRUPO_ms-pantallas-dinamicas" && f_ms-pantallas-dinamicas
    echo "$1" | grep "GRUPO_ms-datos-operador" && f_ms-datos-operador
    echo "$1" | grep "GRUPO_ms-televisor" && f_ms-televisor
    echo "$1" | grep "GRUPO_ms-tickets" && f_ms-ticket
    echo "$1" | grep "GRUPO_ms-consulta-datos-persona-empresa" && f_ms-consulta-datos-persona-empresa
    echo "$1" | grep "GRUPO_ms-server-comunicacion" && f_ms-server-comunicacion
    echo "$1" | grep "GRUPO_cqrs" && f_cqrs
    echo "$1" | grep "GRUPO_ui" && f_ui
    echo "$1" | grep "GRUPO_abm" && f_abm
    echo "$1" | grep "ESCANEAR" && f_todos_los_repo
    echo "$1" | grep "analizar" && f_analizar

exit 0

