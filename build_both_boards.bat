@echo off
REM =========================================================================
REM ZMK Firmware Build Script - Multi-Board Support
REM =========================================================================
REM Builds firmware for 2 shields (dumbpad_nano, ethapadm) x 2 boards (nice!nano, BlueMicro840)
REM 
REM Features:
REM   - Bluetooth Low Energy (BLE)
REM   - RGB Underglow (8 LEDs)
REM   - Rotary Encoder (EC11)
REM   - USB HID
REM   - 3 Layers: Default, DaVinci Resolve, Bluetooth Config
REM 
REM Outputs:
REM   - nice_nano_dumbpad_nano.uf2      (4x4 matrix keypad)
REM   - nice_nano_ethapadm.uf2          (8 button + OLED)
REM   - bluemicro840_dumbpad_nano.uf2   (4x4 matrix keypad)
REM   - bluemicro840_ethapadm.uf2       (8 button + OLED)
REM =========================================================================
echo.
echo ===================================================================
echo   ZMK Firmware Build - Dumbpad ^& EthaPad
echo   Boards: nice!nano + BlueMicro840
echo ===================================================================
echo.
setlocal

set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"

echo [1/7] Preparing environment...
if exist "%ROOT%\venv\Scripts\activate.bat" (
    call "%ROOT%\venv\Scripts\activate.bat"
) else (
    echo WARNING: venv activation script not found. Continuing with current environment.
)

if not defined ZEPHYR_SDK_INSTALL_DIR (
    set "ZEPHYR_SDK_INSTALL_DIR=D:\zephyr-sdk-0.17.3"
)

echo Using ZEPHYR_SDK_INSTALL_DIR=%ZEPHYR_SDK_INSTALL_DIR%

echo [2/7] Building dumbpad_nano (nice_nano)...
west build -d "%ROOT%\build-dumbpad" -p always -b nice_nano -s "%ROOT%\app" -- -DSHIELD=dumbpad_nano
if errorlevel 1 goto :fail_dumbpad

if not exist "%ROOT%\build-dumbpad\zephyr\zmk.uf2" goto :fail_dumbpad
copy /Y "%ROOT%\build-dumbpad\zephyr\zmk.uf2" "%ROOT%\build-dumbpad\zephyr\nice_nano_dumbpad_nano.uf2" >nul

echo [3/7] Building ethapadm (nice_nano)...
west build -d "%ROOT%\build-ethapadm" -p always -b nice_nano -s "%ROOT%\app" -- -DSHIELD=ethapadm
if errorlevel 1 goto :fail_ethapadm

if not exist "%ROOT%\build-ethapadm\zephyr\zmk.uf2" goto :fail_ethapadm
copy /Y "%ROOT%\build-ethapadm\zephyr\zmk.uf2" "%ROOT%\build-ethapadm\zephyr\nice_nano_ethapadm.uf2" >nul

echo [4/7] Building dumbpad_nano (bluemicro840)...
west build -d "%ROOT%\build-dumbpad-bm840" -p always -b bluemicro840 -s "%ROOT%\app" -- -DSHIELD=dumbpad_nano
if errorlevel 1 goto :fail_dumbpad_bm840

if not exist "%ROOT%\build-dumbpad-bm840\zephyr\zmk.uf2" goto :fail_dumbpad_bm840
copy /Y "%ROOT%\build-dumbpad-bm840\zephyr\zmk.uf2" "%ROOT%\build-dumbpad-bm840\zephyr\bluemicro840_dumbpad_nano.uf2" >nul

echo [5/7] Building ethapadm (bluemicro840)...
west build -d "%ROOT%\build-ethapadm-bm840" -p always -b bluemicro840 -s "%ROOT%\app" -- -DSHIELD=ethapadm
if errorlevel 1 goto :fail_ethapadm_bm840

if not exist "%ROOT%\build-ethapadm-bm840\zephyr\zmk.uf2" goto :fail_ethapadm_bm840
copy /Y "%ROOT%\build-ethapadm-bm840\zephyr\zmk.uf2" "%ROOT%\build-ethapadm-bm840\zephyr\bluemicro840_ethapadm.uf2" >nul

echo [6/7] Verifying build artifacts...
echo.
echo ===== nice!nano Firmware =====
if exist "%ROOT%\build-dumbpad\zephyr\nice_nano_dumbpad_nano.uf2" (
    echo   [OK] nice_nano_dumbpad_nano.uf2
) else (
    echo   [WARN] nice_nano_dumbpad_nano.uf2 not found
)
if exist "%ROOT%\build-ethapadm\zephyr\nice_nano_ethapadm.uf2" (
    echo   [OK] nice_nano_ethapadm.uf2
) else (
    echo   [WARN] nice_nano_ethapadm.uf2 not found
)
echo.
echo ===== BlueMicro840 Firmware =====
if exist "%ROOT%\build-dumbpad-bm840\zephyr\bluemicro840_dumbpad_nano.uf2" (
    echo   [OK] bluemicro840_dumbpad_nano.uf2
) else (
    echo   [WARN] bluemicro840_dumbpad_nano.uf2 not found
)
if exist "%ROOT%\build-ethapadm-bm840\zephyr\bluemicro840_ethapadm.uf2" (
    echo   [OK] bluemicro840_ethapadm.uf2
) else (
    echo   [WARN] bluemicro840_ethapadm.uf2 not found
)
echo.
echo Features: BLE, RGB Underglow, Rotary Encoder, USB HID
echo BLE Names: "Dumbpad" / "EthaPad"

echo.
echo [7/7] All builds completed successfully!
exit /b 0

:fail_dumbpad
echo ERROR: dumbpad_nano build failed.
exit /b 1

:fail_ethapadm
echo ERROR: ethapadm build failed.
exit /b 1

:fail_dumbpad_bm840
echo ERROR: dumbpad_nano BlueMicro840 build failed.
exit /b 1

:fail_ethapadm_bm840
echo ERROR: ethapadm BlueMicro840 build failed.
exit /b 1
