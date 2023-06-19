@echo off
setlocal

echo Construyendo sitio web...

cmd /c flutter clean
cmd /c flutter build web
@REM flutter build web && xcopy "build\web\*.*" "C:\Users\administrator\Documents\GitHub\contactos" /E /I /Y && cd "C:\Users\administrator\Documents\GitHub\contactos" && git add . && git commit -m "Agregando archivos generados por flutter build web" && git push
@REM --no-tree-shake-icons 
@REM flutter run -d chrome --web-renderer html
@REM flutter build web --web-renderer canvaskit --no-tree-shake-icons 
@REM flutter build web --web-renderer html --no-tree-shake-icons 

IF %ERRORLEVEL% NEQ 0 (
    echo El comando no se ejecutó correctamente. Código de error: %ERRORLEVEL%
) ELSE (
    echo El comando se ejecutó correctamente.
)

echo Copiando datos al repositorio...
xcopy "build\web\*.*" "C:\tmp\encuestas" /E /I /Y

cd "C:\tmp\encuestas"

echo Publicando sitio...
git add .

git commit -m "Agregando archivos generados por flutter build web"

git push

cd /d %~dp0

echo Arrancamos el sitio...
rem ejecutar el sitio web en el navegador
rem flutter run -d chrome

endlocal
