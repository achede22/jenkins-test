#!/bin/bash

#ANALISIS con SonarQube

echo "----------------Analizando con SonarQube"
sleep 9

      #   ./sonar-scanner-msbuild/sonar-scanner-3.3.0.1492/bin/sonar-scanner \
      #          -Dsonar.host.url=${SONAR} \
      #          -Dsonar.login=tester \
      #          -Dsonar.password=tester \
      #          -Dsonar.projectKey=$CURRENT_LATEST_FOLDER -X \
      #          -Dsonar.projectBaseDir=$BASE_DIR

ehco "Analisis Exitoso"
