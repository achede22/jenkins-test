#!/bin/bash

    # CARGA LAS VARIABLES DE ENTORNO AL POD

        # llama a funciones que sólo se ejecutan una vez
        # y no son un stage
      #  cp devops/binarios/oc ${GIT_REPO}/oc # load oc
      #  cp devops/binarios/jq-linux64 ${GIT_REPO}/jquery # load jquery

        cd ${GIT_REPO} ;ls -c1 # change directory

        ./oc version
        oc version
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