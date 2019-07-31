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
                        -a|--analizar)
				f_analizar "$2"
                                shift
                        ;;
                        -r|--release)
				f_release
                                shift
                        ;;
                        --merge)
                                f_merge
                                shift        
                        ;;
			--generar-docker)
                                f_generar_docker "$2" "$3"
                                shift
				shift
				shift
                        ;;
			-g|--generar-docker-dev)
				f_generar_docker_dev
				shift
			;;
			--generar-docker-homo)
                                f_generar_docker_homo
                                shift
                        ;;
			--generar-docker-prod)
                                f_generar_docker_prod
                                shift
                        ;;
			--generar-docker-qa)
                                f_generar_docker_qa
                                shift
                        ;;
			--generar-docker-ux)
                                f_generar_docker_ux
                                shift
                        ;;
                        --enviar-whatsapp)
                                f_whatsapp_enviar 1150429848 "$2 : aprobar build ${BUILD_URL}input"
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
                                f_problema "1" "CRITICAL PARAMETRO NO SOPORTADO $1"
                        ;;
                esac
                shift
        done
}
f_compilar ()
{
	f_muestra "---------------------------------------------------------- Compilando Aplicacion"
	if [ ! -z $HTTP_PROXY ]; then
		npm config set proxy $HTTP_PROXY
	fi
	if [ ! -z $http_proxy ]; then
        	npm config set proxy $http_proxy
	fi
        if [ ! -z $HTTPS_PROXY ]; then
        	npm config set https-proxy $HTTPS_PROXY
	fi
	if [ ! -z $https_proxy ]; then
        	npm config set https-proxy $https_proxy
       	fi
        if [ -n "$NPM_MIRROR" ]; then
		npm config set registry $NPM_MIRROR
        fi
	f_muestra " Versiones de Software "

        npm --version
        node --version
        nyc --version

	echo $no_proxy
        echo $NO_PROXYG

        npm install npm -g
        npm install --verbose

#       oc start-build ${APP_NAME} --from-dir=./ROOT --follow
	f_problema "$?" "CRITICAL HUBO UN PROBLEMA EN COMPILAR" "COMPILO OK"
}
f_test_unitarios ()
{
#	unset http_proxy
#        unset https_proxy 
#        unset no_proxy
#	return 0
#	f_muestra "Test Unitarios - TODAVIA NO HAY TEST UNITARIOS REVIZAR"
#	npm run -d prod & 
#	sleep 10
#	npm run test
#	f_problema "$?" "CRITICAL HUBO UN PROBLEMA EN LOS TEST UNITARIOS" "TEST UNITARIOS OK"

 # copiado de journey paquetes
	unset http_proxy
        unset https_proxy 
        unset no_proxy
	f_muestra "Test Unitarios - TODAVIA NO HAY TEST UNITARIOS REVIZAR"
	npm install --global nyc
	npm install --global mocha
	npm --version
	node --version
	nyc --version

#	POD_NAME=$(oc get pods | grep Running | grep $APP_NAME | cut -d" " -f 1)
#	oc exec $POD_NAME "CI=true ; npm run test" # non-interactive mode, inside MASTER POD

        npm run -d prod &
        sleep 10
        CI=true npm run test # inside SLAVE pod

#	sed -i 's/^/export /' variables/${proyecto}
#	source variables/${proyecto}
#	nyc --temp-directory --check-coverage --lines 35 --all --reporter=lcov mocha --recursive --exit
#	f_problema "$?" "CRITICAL HUBO UN PROBLEMA EN LOS TEST UNITARIOS" "TEST UNITARIOS OK"

}

f_analizar ()
{
	f_muestra "Analizando con sonar"
                f_muestra "compilando set proxy para sonar"
        if [ ! -z $HTTP_PROXY ]; then
                npm config set proxy $HTTP_PROXY
        fi
        if [ ! -z $http_proxy ]; then
                npm config set proxy $http_proxy
        fi
        if [ ! -z $HTTPS_PROXY ]; then
                npm config set https-proxy $HTTPS_PROXY
        fi
        if [ ! -z $https_proxy ]; then
                npm config set https-proxy $https_proxy
        fi
        if [ -n "$NPM_MIRROR" ]; then
                npm config set registry $NPM_MIRROR
        fi
        export http_proxy=http://app-proxy.bancogalicia.com.ar:80
        export https_proxy=http://app-proxy.bancogalicia.com.ar:80
        export HTTP_PROXY=http://app-proxy.bancogalicia.com.ar:80
        export HTTPS_PROXY=http://app-proxy.bancogalicia.com.ar:80
#        export SONAR_TOKEN=c63bbd014c1edc346b8548270562f73ef91e7969
#        npm install -g sonarqube-scanner
#        ls -latr /home/jenkins/
#        mkdir -p /home/jenkins/sonar-scanner-3.2.0.1227-linux
#        cp -r devops/binarios/sonar-scanner-3.2.0.1227-linux/* /home/jenkins/sonar-scanner-3.2.0.1227-linux/
#        chmod -R 777 /home/jenkins/sonar-scanner-3.2.0.1227-linux 
#        sonar-scanner
#        sonar
#	f_problema "$?" "CRITICAL HUBO UN PROBLEMA ANALIZANDO CON SONAR" "SONAR OK"

# copiado de journey-paquetes
	proyecto=${1} 
 	mkdir -p /home/jenkins/sonar-scanner-3.2.0.1227-linux
        cp -r devops/binarios/sonar-scanner-3.2.0.1227-linux/* /home/jenkins/sonar-scanner-3.2.0.1227-linux/ # carpeta binarios 
        chmod -R 777 /home/jenkins/sonar-scanner-3.2.0.1227-linux 
	export JAVA_TOOL_OPTIONS="-XX:+UnlockExperimentalVMOptions -Dsun.zip.disableMemoryMapping=true"
      #  /home/jenkins/sonar-scanner-3.2.0.1227-linux/bin/sonar-scanner -Dsonar.host.url=http://sonarqube-cicd.devopenshift.bancogalicia.com.ar  -Dsonar.login=admin -Dsonar.password=admin  -Dsonar.projectKey=${proyecto} -Dsonar.typescript.eslint.reportPaths=getStringArray -Dsonar.javascript.lcov.reportPaths=coverage/lcov.info

	#empresas	
	/home/jenkins/sonar-scanner-3.2.0.1227-linux/bin/sonar-scanner -Dsonar.host.url=${SONAR} -Dsonar.login=admin -Dsonar.password=admin -Dsonar.projectKey=${repositorio}-homo -X 

	f_problema "$?" "CRITICAL HUBO UN PROBLEMA ANALIZANDO CON SONAR" "SONAR OK"

}

f_release ()
{
	old_version="$(sed '1q' version|sed 's/ //g')"
	new_version="$(echo ${old_version}|awk -F"." '{print $1"."$2"."$3+1}')"
#	sed -i "s|${old_version}|${new_version}|g" version
	echo "${new_version}" > version
	sed -i '/^$/d'  version
	git checkout master
	git add "version" 
	git commit -m "change version to ${new_version}"
#	git show-ref
#	git push -u origin HEAD:master
	git tag -a v${new_version} -m "nueva version ${new_version}"
        git tag
#       GIT_REPO="${GIT_REPO:0:7}${GITPUSHER}@${GIT_REPO:7}"
        GIT_REPO="${GOGS:0:7}${GITPUSHER}"@"${GOGS:7}""${git_organizacion}"/"${GIT_REPO}"
        git push ${GIT_REPO} master
        git push ${GIT_REPO} --tags
        return 0
}
f_generar_docker_qa ()
{
        unset http_proxy
        unset https_proxy 
        unset no_proxy
        ${oc} project ${qa_proyecto}
        ${oc} start-build ${APP_NAME} --from-repo . --follow -n ${qa_proyecto}
        f_problema "$?" "fallo el build" "build OK"
}
f_generar_docker_ux ()
{
        unset http_proxy
        unset https_proxy 
        unset no_proxy
        oc project ${ux_proyecto}
        oc start-build ${APP_NAME} --from-repo . --follow -n ${ux_proyecto}
        f_problema "$?" "fallo el build" "build OK"
}
f_generar_docker_dev ()
{
	unset http_proxy
	unset https_proxy 
	unset no_proxy
	ls -atlrh 
	find -iname oc
	echo uso el oc local
        oc project ${dev_proyecto}
        oc start-build ${APP_NAME} --from-repo . --follow -n ${dev_proyecto}
	f_problema "$?" "loco fallo el build" "build OK"
}
f_generar_docker_homo ()
{
        unset http_proxy
        unset https_proxy 
        unset no_proxy
        oc project ${homo_proyecto}
        oc start-build ${APP_NAME} --from-repo . --follow -n ${homo_proyecto}
        f_problema "$?" "loco fallo el build" "build OK"
}
f_generar_docker_prod ()
{
        unset http_proxy
        unset https_proxy 
        unset no_proxy
        oc project ${prod_proyecto}
        oc start-build ${APP_NAME} --from-repo . --follow -n ${prod_proyecto}
        f_problema "$?" "loco fallo el build" "build OK"
}
f_check_variable ()
{
#       echo "1 = $1 | 2 = $2 "
        if [ -z "$1" ] || [ -z "$2" ] ; then
                f_problema "1" "no existe la variable $2 = $1"
        fi
}
f_generar_docker ()
{
        proyecto=${1}
        aplicacion=${2}
        f_unset_proxy
        oc project ${proyecto}
        oc start-build ${aplicacion} --from-repo . --follow -n ${proyecto}
        f_problema "$?" "fallo el build ${oc} start-build ${aplicacion} --from-repo . --follow -n ${proyecto}" "build OK"
}
f_muestra ()
{
        echo "$(date) : $@"
}
f_problema ()
{
        if [ $1 -gt 0 ] ;then
                f_muestra "$2"
                exit 1
        else
                f_muestra "$3"
        fi
}
f_unset_proxy ()
{
        unset http_proxy
        unset https_proxy
        unset no_proxy
        unset HTTP_PROXY
        unset HTTPS_PROXY
        unset no_proxy
}
f_patch_homo ()
{
        f_unset_proxy
        oc patch dc ${APP_NAME} --patch "{\"spec\": { \"triggers\": [ { \"type\": \"ImageChange\", \"imageChangeParams\": { \"containerNames\": [ \"${APP_NAME}\" ], \"from\": { \"kind\": \"ImageStreamTag\", \"namespace\": \"${homo_proyecto}\", \"name\": \"${APP_NAME}:$(echo $version|sed '1q')\"}}}]}}" -n ${homo_proyecto}
        f_problema "$?" "CRITICAL oc patch dc" "oc patch dc - OK "
}
f_patch_prod ()
{
        oc patch dc ${APP_NAME} --patch "{\"spec\": { \"triggers\": [ { \"type\": \"ImageChange\", \"imageChangeParams\": { \"containerNames\": [ \"${APP_NAME}\" ], \"from\": { \"kind\": \"ImageStreamTag\", \"namespace\": \"${prod_proyecto}\", \"name\": \"${APP_NAME}:${version}\"}}}]}}" -n ${prod_proyecto}
}

f_carga_variables ()
{

                        # "Establecer proyecto"
                        oc project ${proyecto}

        #-----  Variables al ConfigMap"

                # "ELIMINAR el configMap completo, no falla si configMap no existe"
                       oc delete configmap ${APP_NAME} -n ${proyecto} --ignore-not-found=true

                # "CARGAR nuevas variables desde el repo al ConfigMap"
                       oc create configmap ${APP_NAME} --from-env-file=variables/${proyecto} -n ${proyecto}


        #-----  Variables al DeploymentConfig (dc)"

                # "EXPORTA el DeploymentConfig."
                        oc export dc ${APP_NAME} -o json > DC.json

                # "ELIMINA todas las varibles del DeploymentConfig en json"
                        devops/binarios/jq-linux64 'del(.spec.template.spec.containers[].env)' DC.json > DCmodified.json

                # "IMPORTA el DeploymentConfig modificado sin variables de entorno"
                        oc replace -f DCmodified.json

                # "CARGAR nuevas variables desde ConfigMap al DeploymentConfig"
                       oc set env dc/${APP_NAME} --from configmap/${APP_NAME}



        #-----  Variables al Build Config (bc) "

                # "CREA una variable para que no falle el paso de eliminar todas"
                      oc set env bc/${APP_NAME} TZ="America/Argentina/Buenos_Aires" -n ${proyecto}

                # "EXPORTA el BuildConfig"
                        oc export bc ${APP_NAME} -o json > BC.json

                # "ELIMINA todas las varibles del BuildConfig en json"
                        devops/binarios/jq-linux64 'del(.spec.template.spec.containers[].env)' BC.json > BCmodified.json

                # "IMPORTA el BuildConfig modificado sin variables de entorno"
                        oc replace -f BCmodified.json

                # "CARGAR nuevas variables desde ConfigMap al DeploymentConfig"
                       oc set env dc/${APP_NAME} --from configmap/${APP_NAME}

                # LISTAR las variables de entorno en el BuildConfig
                oc env bc ${APP_NAME} --list

}

f_merge ()
{
        GIT_REPO="${GIT_REPO:0:7}${GITPUSHER}@${GIT_REPO:7}"
        git push ${GIT_REPO} master
        return 0
}

main ()
{
	http_proxy=http://app-proxy.bancogalicia.com.ar:80
	https_proxy=http://app-proxy.bancogalicia.com.ar:80
	f_check_variable "${APP_NAME}" "APP_NAME"
	f_check_variable "${dev_proyecto}" "dev_proyecto"
	f_check_variable "${homo_proyecto}" "homo_proyecto"
	f_check_variable "${prod_proyecto}" "prod_proyecto"
	f_leer_parametros "$@"
}
main "$@"
exit 0 
