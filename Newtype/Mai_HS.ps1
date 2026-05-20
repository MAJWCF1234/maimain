<#
.SYNOPSIS
    Mai Phoenix Desktop - High-Speed Edition Generator
.DESCRIPTION
    Generates and launches Mai Phoenix Desktop with proprietary HSB brain format and 5-50x performance improvements
.NOTES
    Author: MAJWCF1234
    Date: 2025-01-27
    Version: 2.0 (High-Speed Edition)
#>

$Global:MaiAppJob = $null

try {
    #region Utility Functions
    function Write-VerifiedFile {
        param([string]$FilePath, [string]$Content)
        try {
            Set-Content -Path $FilePath -Value $Content -Encoding UTF8 -Force
            if (-not (Test-Path -Path $FilePath) -or (Get-Item $FilePath).Length -eq 0) {
                throw "Failed to write or verify content for file: $FilePath"
            }
        }
        catch {
            throw "An exception occurred while writing to '$FilePath': $_"
        }
    }

    function Get-PythonExecutable {
        Write-Host "Looking for system Python installation..."
        $pythonPaths = @(
            (Get-Command python -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source -First 1),
            "$env:LOCALAPPDATA\Programs\Python\Python3*\python.exe",
            "C:\Python3*\python.exe",
            "C:\Program Files\Python*\python.exe"
        )
        
        foreach ($path in $pythonPaths) {
            if (-not $path) { continue }
            $resolvedPath = $null
            if ($path -match '\*') {
                $found = Get-ChildItem -Path $path -ErrorAction SilentlyContinue | Select-Object -First 1
                if ($found) { $resolvedPath = $found.FullName }
            } else {
                if (Test-Path -LiteralPath $path) { $resolvedPath = $path }
            }
            if ($resolvedPath) {
                try {
                    $version = & $resolvedPath --version 2>&1
                    if ($version -match "Python 3\.") {
                        Write-Host "SUCCESS: Found Python at: $resolvedPath" -ForegroundColor Green
                        Write-Host "Version: $version" -ForegroundColor Green
                        return $resolvedPath
                    }
                }
                catch {
                    continue
                }
            }
        }
        
        Write-Host "ERROR: No suitable Python installation found!" -ForegroundColor Red
        Write-Host "Please install Python 3.7+ and try again." -ForegroundColor Red
        throw "Python installation required"
    }
    #endregion

    #region Main Setup
    Write-Host "="*60 -ForegroundColor Cyan
    Write-Host "MAI PHOENIX DESKTOP - HIGH-SPEED EDITION v2.0" -ForegroundColor Cyan
    Write-Host "="*60 -ForegroundColor Cyan
    Write-Host "Generating High-Speed Mai Phoenix with HSB Brain Format" -ForegroundColor Yellow
    Write-Host ""

    # Get Python executable
    $PythonExePath = Get-PythonExecutable
    if (-not $PythonExePath -or -not (Test-Path -LiteralPath $PythonExePath)) {
        throw "Python executable not found or invalid: $PythonExePath"
    }
    $ScriptDir = if ($PSScriptRoot) { $PSScriptRoot.Trim() } else { (Get-Location).Path }
    if (-not $ScriptDir) { $ScriptDir = "." }
    if (-not (Test-Path -Path $ScriptDir -PathType Container)) {
        $ScriptDir = (Get-Location).Path
    }
    # Create training directory (under script dir)
    $trainingDir = Join-Path -Path $ScriptDir -ChildPath "training"
    New-Item -Path $trainingDir -ItemType Directory -Force | Out-Null
    $initKnowPath = Join-Path -Path $trainingDir -ChildPath "initial_knowledge.txt"
    Write-VerifiedFile -FilePath $initKnowPath -Content "Hello world. My name is Mai. I am a generative AI system using statistical patterns and semantic clustering without any preset responses. I generate all my responses from learned statistical patterns and semantic relationships. I can understand context through statistical co-occurrence and semantic clustering. I learn from conversations and adapt my responses based on the patterns I observe. I am designed to be a true statistical generative model that competes with transformer-based systems through pattern learning and semantic understanding."
    
    # Create requirements.txt (in script dir)
    $reqPath = Join-Path -Path $ScriptDir -ChildPath "requirements.txt"
    Write-VerifiedFile -FilePath $reqPath -Content "PySide6`npsutil`nnumpy`nmatplotlib"
    
    # Check if high-speed files exist (in script dir)
    $requiredFiles = @("mai_phoenix_hs_desktop.py", "storage_engine.py", "hsb_format.py", "hsb_viewer.py")
    Write-Host "Checking for high-speed Mai Phoenix files..." -ForegroundColor Yellow
    
    foreach ($file in $requiredFiles) {
        $filePath = Join-Path -Path $ScriptDir -ChildPath $file
        if (-not $filePath -or -not (Test-Path -LiteralPath $filePath)) {
            Write-Host "ERROR: Required file missing: $file" -ForegroundColor Red
            Write-Host "Please ensure all high-speed Mai Phoenix files are present." -ForegroundColor Red
            throw "High-speed Mai Phoenix files missing"
        }
        Write-Host "✅ Found: $file" -ForegroundColor Green
    }
    
    Write-Host "✅ All high-speed Mai Phoenix files verified!" -ForegroundColor Green
    Write-Host ""
    #endregion

    #region Dependency Installation
    Write-Host "Installing dependencies..." -ForegroundColor Yellow
    try {
        # First, try to fix any corrupted packages
        Write-Host "Checking for corrupted packages..." -ForegroundColor Yellow
        if (Test-Path -Path $ScriptDir -PathType Container) {
            Set-Location -Path $ScriptDir -ErrorAction SilentlyContinue
        }
        & $PythonExePath -m pip install --force-reinstall --no-deps PySide6 psutil numpy matplotlib --quiet
        
        # Then install normally
        & $PythonExePath -m pip install PySide6 psutil numpy matplotlib --quiet --upgrade
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Standard install failed. Trying individual packages..." -ForegroundColor Yellow
            $packages = @("PySide6", "psutil", "numpy", "matplotlib")
            foreach ($package in $packages) {
                if (-not $package) { continue }
                Write-Host "Installing $package..." -ForegroundColor Yellow
                & $PythonExePath -m pip install $package --quiet --upgrade
            }
        }
        
        Write-Host "✅ Dependencies installation completed!" -ForegroundColor Green
    }
    catch {
        Write-Host "WARNING: Dependency installation had issues: $_" -ForegroundColor Yellow
        Write-Host "Continuing anyway - the application may still work." -ForegroundColor Yellow
    }
    #endregion

    #region Application Launch
    Write-Host ""
    Write-Host "--- Launching Mai Phoenix Desktop - High-Speed Edition ---" -ForegroundColor Yellow
    Write-Host "Features:" -ForegroundColor Cyan
    Write-Host "  - Proprietary HSB brain format (.hsb)" -ForegroundColor White
    Write-Host "  - 5-50x faster than SQLite" -ForegroundColor White
    Write-Host "  - Automatic SQLite to HSB conversion" -ForegroundColor White
    Write-Host "  - Columnar storage with vectorized operations" -ForegroundColor White
    Write-Host "  - Lock-free design eliminates threading bottlenecks" -ForegroundColor White
    Write-Host "  - Memory-mapped file access for maximum speed" -ForegroundColor White
    Write-Host "  - Built-in HSB brain viewer/editor" -ForegroundColor White
    Write-Host ""
    
    # Launch the high-speed Mai Phoenix (working directory = script dir so script is found)
    Write-Host "Starting Mai Phoenix Desktop..." -ForegroundColor Green
    $hsDesktopScript = Join-Path -Path $ScriptDir -ChildPath "mai_phoenix_hs_desktop.py"
    if (-not (Test-Path -LiteralPath $hsDesktopScript)) {
        throw "mai_phoenix_hs_desktop.py not found at: $hsDesktopScript"
    }
    $Global:MaiAppJob = Start-Process -FilePath $PythonExePath -ArgumentList $hsDesktopScript -WorkingDirectory $ScriptDir -PassThru -WindowStyle Normal
    
    if ($Global:MaiAppJob) {
        Write-Host "✅ Mai Phoenix Desktop launched successfully!" -ForegroundColor Green
        Write-Host "Process ID: $($Global:MaiAppJob.Id)" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "The high-speed Mai Phoenix Desktop is now running!" -ForegroundColor Yellow
        Write-Host "You can also open the HSB brain viewer with: python hsb_viewer.py" -ForegroundColor Cyan
    }
    else {
        Write-Host "❌ Failed to launch Mai Phoenix Desktop" -ForegroundColor Red
        throw "Application launch failed"
    }
    #endregion

}
catch {
    Write-Host ""
    Write-Host "❌ ERROR: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "1. Ensure Python 3.7+ is installed" -ForegroundColor White
    Write-Host "2. Ensure all required files are present:" -ForegroundColor White
    Write-Host "   - mai_phoenix_hs_desktop.py" -ForegroundColor White
    Write-Host "   - storage_engine.py" -ForegroundColor White
    Write-Host "   - hsb_format.py" -ForegroundColor White
    Write-Host "   - hsb_viewer.py" -ForegroundColor White
    Write-Host "3. Try running manually: python mai_phoenix_hs_desktop.py" -ForegroundColor White
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "Setup complete! Mai Phoenix Desktop - High-Speed Edition is running." -ForegroundColor Green
Write-Host "Press Ctrl+C to stop monitoring (the app will continue running)." -ForegroundColor Cyan
Write-Host ""

# Monitor the application
try {
    while ($Global:MaiAppJob -and -not $Global:MaiAppJob.HasExited) {
        Start-Sleep -Seconds 5
    }
    if ($Global:MaiAppJob -and $Global:MaiAppJob.HasExited) {
        Write-Host "Mai Phoenix Desktop has exited." -ForegroundColor Yellow
    }
}
catch {
    Write-Host "Monitoring interrupted." -ForegroundColor Yellow
}
finally {
    try {
        if ($Global:MaiAppJob) {
            $Global:MaiAppJob.Dispose()
        }
    } catch { }
    $Global:MaiAppJob = $null
}
