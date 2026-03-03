@echo off
setlocal

set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"

echo [1/5] Preparing environment...
if exist "%ROOT%\venv\Scripts\activate.bat" (
    call "%ROOT%\venv\Scripts\activate.bat"
) else (
    echo WARNING: venv activation script not found. Continuing with current environment.
)

if not defined ZEPHYR_SDK_INSTALL_DIR (
    set "ZEPHYR_SDK_INSTALL_DIR=D:\zephyr-sdk-0.17.3"
)

echo Using ZEPHYR_SDK_INSTALL_DIR=%ZEPHYR_SDK_INSTALL_DIR%

echo [2/5] Building dumbpad_nano...
west build -d "%ROOT%\build-dumbpad" -p always -b nice_nano -s "%ROOT%\app" -- -DSHIELD=dumbpad_nano
if errorlevel 1 goto :fail_dumbpad

if not exist "%ROOT%\build-dumbpad\zephyr\zmk.uf2" goto :fail_dumbpad
copy /Y "%ROOT%\build-dumbpad\zephyr\zmk.uf2" "%ROOT%\build-dumbpad\zephyr\nice_nano_dumbpad_nano.uf2" >nul

echo [3/5] Building ethapadm...
west build -d "%ROOT%\build-ethapadm" -p always -b nice_nano -s "%ROOT%\app" -- -DSHIELD=ethapadm
if errorlevel 1 goto :fail_ethapadm

if not exist "%ROOT%\build-ethapadm\zephyr\zmk.uf2" goto :fail_ethapadm
copy /Y "%ROOT%\build-ethapadm\zephyr\zmk.uf2" "%ROOT%\build-ethapadm\zephyr\nice_nano_ethapadm.uf2" >nul

echo [4/5] Build artifacts:
echo   %ROOT%\build-dumbpad\zephyr\nice_nano_dumbpad_nano.uf2
echo   %ROOT%\build-ethapadm\zephyr\nice_nano_ethapadm.uf2

echo [5/5] Done.
exit /b 0

:fail_dumbpad
echo ERROR: dumbpad_nano build failed.
exit /b 1

:fail_ethapadm
echo ERROR: ethapadm build failed.
exit /b 1
