#!/bin/bash

	cd src
	archivo_proyecto=$(ls *.csproj)
	ls -ltra

  dotnet build $archivo_proyecto -v n
	cat /home/jenkins/.nuget/NuGet/NuGet.Config

  dotnet clean $archivo_proyecto
