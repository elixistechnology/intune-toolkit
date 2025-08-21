#Requires -Version 7.0
<#
.SYNOPSIS
    Quick validation script to test basic Intune Toolkit functionality

.DESCRIPTION
    This script provides a quick way to validate that core functions are working
    without requiring the full test suite. Useful for development and troubleshooting.

.EXAMPLE
    .\Test-BasicFunctionality.ps1
#>

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Intune Toolkit - Basic Function Test" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: Import Functions.ps1 and define logging function
Write-Host "Test 1: Loading core functions..." -ForegroundColor Yellow
try {
    . .\Scripts\Functions.ps1
    
    # Define logging function for testing
    function Write-IntuneToolkitLog {
        param (
            [string]$message,
            [string]$component = "Test",
            [string]$context = "",
            [string]$type = "1",
            [string]$thread = "1",
            [string]$file = "Test.ps1"
        )
        $timestamp = Get-Date -Format "HH:mm:ss.fffzzz"
        $date = Get-Date -Format "MM-dd-yyyy"
        $logMessage = "<![LOG[$message]LOG]!><time=`"$($timestamp)`" date=`"$date`" component=`"$component`" context=`"$context`" type=`"$type`" thread=`"$thread`" file=`"$file`">"
        if ($global:logFile) {
            Add-Content -Path $global:logFile -Value $logMessage -Force -ErrorAction SilentlyContinue
        }
    }
    
    Write-Host "✓ Core functions loaded successfully" -ForegroundColor Green
} catch {
    Write-Host "✗ Failed to load core functions: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 2: Test Get-PlatformApps function
Write-Host "`nTest 2: Testing Get-PlatformApps function..." -ForegroundColor Yellow
try {
    $testResult = Get-PlatformApps -odataType "#microsoft.graph.win32LobApp"
    if ($testResult -eq "Windows") {
        Write-Host "✓ Get-PlatformApps working correctly" -ForegroundColor Green
    } else {
        Write-Host "✗ Get-PlatformApps returned unexpected result: $testResult" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ Get-PlatformApps failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Test Format-ApplicationType function
Write-Host "`nTest 3: Testing Format-ApplicationType function..." -ForegroundColor Yellow
try {
    $testResult = Format-ApplicationType -odataType "#microsoft.graph.win32LobApp"
    if ($testResult -and $testResult.Length -gt 0 -and $testResult -notlike "*microsoft.graph*") {
        Write-Host "✓ Format-ApplicationType working correctly" -ForegroundColor Green
    } else {
        Write-Host "✗ Format-ApplicationType returned unexpected result: $testResult" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ Format-ApplicationType failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 4: Test logging function
Write-Host "`nTest 4: Testing Write-IntuneToolkitLog function..." -ForegroundColor Yellow
$testLogFile = "$env:TEMP\IntuneToolkit-QuickTest.log"
try {
    # Clean up any existing test log
    if (Test-Path $testLogFile) {
        Remove-Item $testLogFile -Force
    }
    
    # Set global log file for testing
    $global:logFile = $testLogFile
    
    Write-IntuneToolkitLog -message "Quick test message" -component "QuickTest"
    
    if (Test-Path $testLogFile) {
        $logContent = Get-Content $testLogFile -Raw
        if ($logContent -and $logContent.Contains("Quick test message")) {
            Write-Host "✓ Write-IntuneToolkitLog working correctly" -ForegroundColor Green
        } else {
            Write-Host "✗ Write-IntuneToolkitLog did not write expected content" -ForegroundColor Red
        }
    } else {
        Write-Host "✗ Write-IntuneToolkitLog did not create log file" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ Write-IntuneToolkitLog failed: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    # Clean up test log file
    if (Test-Path $testLogFile) {
        Remove-Item $testLogFile -Force -ErrorAction SilentlyContinue
    }
}

# Test 5: Test PowerShell version
Write-Host "`nTest 5: Checking PowerShell version..." -ForegroundColor Yellow
$psVersion = $PSVersionTable.PSVersion
if ($psVersion -ge [Version]"7.0.0") {
    Write-Host "✓ PowerShell version $psVersion is supported" -ForegroundColor Green
} else {
    Write-Host "✗ PowerShell version $psVersion is not supported (7.0+ required)" -ForegroundColor Red
}

# Test 6: Check if GUI assemblies are available (optional on Linux)
Write-Host "`nTest 6: Testing GUI assemblies (optional)..." -ForegroundColor Yellow
try {
    Add-Type -AssemblyName PresentationFramework -ErrorAction Stop
    Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
    Write-Host "✓ GUI assemblies loaded successfully" -ForegroundColor Green
} catch {
    if ($IsLinux -or $IsMacOS) {
        Write-Host "⚠ GUI assemblies not available on this platform (expected on Linux/macOS)" -ForegroundColor Yellow
    } else {
        Write-Host "✗ Failed to load GUI assemblies: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Basic functionality test completed!" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "For comprehensive testing, run: .\Run-Tests.ps1" -ForegroundColor Gray