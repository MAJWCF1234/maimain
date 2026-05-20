@echo off
setlocal EnableDelayedExpansion
title Mai AI - Memory Optimized Edition

:: Change to the directory where this batch file lives (so paths work)
set "SCRIPT_DRIVE=%~d0"
set "SCRIPT_PATH=%~dp0"
if not defined SCRIPT_PATH set "SCRIPT_PATH=%CD%\"
if not "%SCRIPT_PATH:~-1%"=="\" set "SCRIPT_PATH=%SCRIPT_PATH%\"
cd /d "%SCRIPT_PATH%" 2>nul
if errorlevel 1 (
    echo WARNING: Could not change to script directory. Using current directory.
)

echo.
echo ============================================
echo   Mai AI - Memory Optimized Edition
echo   Utilities + Launch
echo ============================================
echo.

:: --- 1. Find Python (prefer venv in project root) ---
set "PYTHON="
if exist "%~dp0venv\Scripts\python.exe" set "PYTHON=%~dp0venv\Scripts\python.exe"
if exist "%~dp0.venv\Scripts\python.exe" set "PYTHON=%~dp0.venv\Scripts\python.exe"
if not defined PYTHON if exist "%~dp0..\venv\Scripts\python.exe" set "PYTHON=%~dp0..\venv\Scripts\python.exe"
if defined PYTHON goto :found_python
where python >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=*" %%i in ('where python 2^>nul') do (
        set "CAND=%%i"
        echo !CAND! | findstr /i "python.exe" >nul 2>&1 && set "PYTHON=%%i" && goto :found_python
    )
)
:: Prefer py launcher if no python.exe found (avoids Windows Store stub)
where py >nul 2>&1
if %errorlevel% equ 0 if not defined PYTHON (
    for /f "tokens=*" %%i in ('py -3 -c "import sys; print(sys.executable)" 2^>nul') do set "PYTHON=%%i" && goto :found_python
)
if exist "%LOCALAPPDATA%\Programs\Python\Python311\python.exe" set "PYTHON=%LOCALAPPDATA%\Programs\Python\Python311\python.exe"
if exist "C:\Python311\python.exe" set "PYTHON=C:\Python311\python.exe"
if exist "%LOCALAPPDATA%\Programs\Python\Python312\python.exe" set "PYTHON=%LOCALAPPDATA%\Programs\Python\Python312\python.exe"
if not defined PYTHON (
    echo ERROR: Python not found. Install Python 3.11 or 3.12 and add it to PATH.
    pause
    exit /b 1
)
if "%PYTHON%"=="" (
    echo ERROR: Python path is empty.
    pause
    exit /b 1
)
:found_python
echo [1/4] Using Python: %PYTHON%
if exist "%PYTHON%" (
    "%PYTHON%" --version 2>nul
    if errorlevel 1 (
        echo WARNING: Python version check failed. Continuing anyway.
    )
) else (
    echo WARNING: Python executable not found at %PYTHON%
)
echo.

:: --- 2. Install/upgrade dependencies (root) ---
echo [2/4] Installing/upgrading dependencies...
if exist "%~dp0requirements.txt" (
    "%PYTHON%" -m pip install -q -r "%~dp0requirements.txt" --upgrade 2>nul
    if errorlevel 1 (
        "%PYTHON%" -m pip install -r "%~dp0requirements.txt" --upgrade
    ) else (
        echo      requirements.txt OK.
    )
) else (
    echo      No requirements.txt in root; skipping.
)
if exist "%~dp0Newtype\requirements.txt" (
    "%PYTHON%" -m pip install -q -r "%~dp0Newtype\requirements.txt" --upgrade 2>nul
    if errorlevel 1 (
        "%PYTHON%" -m pip install -r "%~dp0Newtype\requirements.txt" --upgrade
    )
    echo      Newtype\requirements.txt OK.
)
echo.

:: --- 3. Utilities: ensure folders and files ---
echo [3/4] Utilities (folders, training)... 
set "TRAIN_DIR=%~dp0training"
if not defined TRAIN_DIR set "TRAIN_DIR=training"
if "%TRAIN_DIR%"=="training" set "TRAIN_DIR=%SCRIPT_PATH%training"
if not exist "%TRAIN_DIR%" (
    mkdir "%TRAIN_DIR%" 2>nul
    if not exist "%TRAIN_DIR%" (
        echo      WARNING: Could not create training folder.
    )
)
set "INIT_KNOW=%TRAIN_DIR%\initial_knowledge.txt"
if not exist "%INIT_KNOW%" (
    copy /y nul "%INIT_KNOW%" >nul 2>&1
    if not exist "%INIT_KNOW%" (
        echo. > "%INIT_KNOW%"
    )
    if exist "%INIT_KNOW%" (
        echo      Created training\initial_knowledge.txt
    )
)
echo      Done.
echo.

:: --- 4. Ensure standalone frontend dependencies (best-effort) ---
echo [4/5] Checking standalone frontend runtime...
set "STANDALONE_APP=%~dp0standalone_frontend"
if exist "%STANDALONE_APP%\main.js" (
    if not exist "%STANDALONE_APP%\node_modules\electron\dist\electron.exe" (
        set "NPM_CMD="
        where npm >nul 2>&1 && set "NPM_CMD=npm"
        if not defined NPM_CMD where npm.cmd >nul 2>&1 && set "NPM_CMD=npm.cmd"
        if defined NPM_CMD (
            echo      Electron runtime missing. Installing frontend dependencies...
            pushd "%STANDALONE_APP%" 2>nul && (
                call !NPM_CMD! install
                popd 2>nul
            ) || (
                cd /d "%STANDALONE_APP%" 2>nul
                call !NPM_CMD! install
            )
        ) else (
            echo      WARNING: npm not found. Cannot auto-install Electron runtime.
            echo      Install Node.js (includes npm), then rerun this launcher.
        )
    ) else (
        echo      Standalone runtime present.
    )
) else (
    echo      standalone_frontend\main.js not found; skipping frontend dependency check.
)
echo.

:: --- 5. Launch standalone app (fallback to desktop shell) ---
set "EXIT_CODE=0"
for %%I in ("%~dp0..") do set "WORKSPACE_ROOT=%%~fI"
set "ELECTRON_EXE="

if defined MAI_FRONTEND_ELECTRON if exist "%MAI_FRONTEND_ELECTRON%" set "ELECTRON_EXE=%MAI_FRONTEND_ELECTRON%"
if exist "%STANDALONE_APP%\node_modules\electron\dist\electron.exe" set "ELECTRON_EXE=%STANDALONE_APP%\node_modules\electron\dist\electron.exe"
if not defined ELECTRON_EXE if exist "%WORKSPACE_ROOT%\maionline\node_modules\electron\dist\electron.exe" set "ELECTRON_EXE=%WORKSPACE_ROOT%\maionline\node_modules\electron\dist\electron.exe"

if exist "%STANDALONE_APP%\main.js" if defined ELECTRON_EXE goto :launch_standalone

echo WARNING: Standalone frontend runtime not available. Falling back to Qt desktop.
goto :launch_desktop

:launch_standalone
echo [5/5] Launching Mai Standalone...
echo.
set "MAI_BACKEND_PYTHON=%PYTHON%"
set "MAI_WORKSPACE_ROOT=%WORKSPACE_ROOT%"
pushd "%STANDALONE_APP%" 2>nul && (
  "%ELECTRON_EXE%" "%STANDALONE_APP%"
  set "EXIT_CODE=!errorlevel!"
  popd 2>nul
) || (
  cd /d "%STANDALONE_APP%" 2>nul
  "%ELECTRON_EXE%" "%STANDALONE_APP%"
  set "EXIT_CODE=!errorlevel!"
)
goto :launch_done

:launch_desktop
if not exist "%~dp0mai_phoenix_desktop.py" (
    echo ERROR: mai_phoenix_desktop.py not found in "%~dp0"
    pause
    set "EXIT_CODE=1"
    goto :launch_done
)
echo [5/5] Booting Mai Phoenix Desktop...
echo.
pushd "%~dp0" 2>nul && (
  "%PYTHON%" "%~dp0mai_phoenix_desktop.py"
  set "EXIT_CODE=!errorlevel!"
  popd 2>nul
) || (
  cd /d "%~dp0" 2>nul
  "%PYTHON%" "%~dp0mai_phoenix_desktop.py"
  set "EXIT_CODE=!errorlevel!"
)
:launch_done
if not "%EXIT_CODE%"=="0" (
    echo.
    echo App exited with code %EXIT_CODE%. Press any key to close.
    pause >nul
)
endlocal 2>nul & exit /b %EXIT_CODE%
