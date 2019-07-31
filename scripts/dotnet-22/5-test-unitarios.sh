#!/bin/bash

#    TEST UNITARIOS .NET en el worker

        export DOTNET_STARTUP_PROJECT_test=$( find * -type f | grep -i "Test.csproj$" | grep -v -i user ) # ARCHIVO .test.csproj
        export DOTNET_STARTUP_PROJECT=$( find * -type f | grep ".csproj$" | grep -v -i test ) # ARCHIVO .csproj
        export PROJECT_APPS=$( find * -type f -printf "%f\n" | grep ".csproj$" | grep -v -i test ) # varios ARCHIVOS .csproj
        export PROJECT_SOLUTION=$( find * -type f | grep ".sln$" | grep -v -i test ) # ARCHIVO .sln
        export PROJECT_FOLDERS=$(dirname $DOTNET_STARTUP_PROJECT) 
        export My_PATH=$(pwd)
  
    dotnet test ${DOTNET_STARTUP_PROJECT_test}