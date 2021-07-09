@echo off

:: Setup Directories
if not exist output\bin mkdir output\bin
if not exist output\obj mkdir output\obj

:: Build DLL
cl /nologo /O2 /GL /GS- /GR- /MD /Fo:output\obj\ /Fe:output\bin\voxel.dll *.cpp /link /incremental:no /ltcg /dll

:: Copy DLL
copy /Y "output\bin\voxel.dll" "..\gml\extensions\ext_voxel\voxel.dll"