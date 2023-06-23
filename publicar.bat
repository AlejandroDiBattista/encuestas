@echo off

echo Construyendo sitio web...

cmd /c flutter clean
cmd /c flutter build web 
@REM cmd /c flutter build web --no-tree-shake-icons 
@REM cmd /c flutter run -d chrome --web-renderer html
@REM cmd /c flutter build web --web-renderer canvaskit --no-tree-shake-icons 
@REM cmd /c flutter build web --web-renderer html --no-tree-shake-icons 

IF %ERRORLEVEL% NEQ 0 (
    echo El comando no se ejecutó correctamente. Código de error: %ERRORLEVEL%
) ELSE (
    echo El comando se ejecutó correctamente.
)

@REM echo Copiando datos al repositorio...

echo Publicando sitio...
git add .

git commit -m "Publicando nueva version"

git push