<#
.SYNOPSIS
    Test runner script for Intune Toolkit using Pester

.DESCRIPTION
    This script runs all Pester tests for the Intune Toolkit. It provides options for different
    test configurations and outputs results in various formats.

.PARAMETER TestPath
    Path to specific test file or directory to run. Defaults to all tests in Tests directory.

.PARAMETER OutputFormat
    Output format for test results. Valid options: NUnitXml, JUnitXml, Console. Default: Console

.PARAMETER OutputFile
    File path to save test results when using XML output formats.

.PARAMETER PassThru
    Return the Pester result object for further processing.

.PARAMETER ShowSummary
    Show summary of test results. Default: true

.EXAMPLE
    .\Run-Tests.ps1
    Runs all tests with default console output

.EXAMPLE
    .\Run-Tests.ps1 -TestPath "Tests\Functions.Tests.ps1" -OutputFormat NUnitXml -OutputFile "TestResults.xml"
    Runs specific test file and saves results as NUnit XML

.NOTES
    Author: Intune Toolkit Project
    Requires: Pester 5.0+
#>

param(
    [string]$TestPath = ".\Tests",
    [ValidateSet("Console", "NUnitXml", "JUnitXml")]
    [string]$OutputFormat = "Console",
    [string]$OutputFile = "",
    [switch]$PassThru,
    [bool]$ShowSummary = $true
)

# Ensure we're in the correct directory (script root)
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ScriptRoot

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Intune Toolkit Test Runner" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Check if Pester is available
try {
    Import-Module Pester -MinimumVersion 5.0 -ErrorAction Stop
    $pesterVersion = (Get-Module Pester).Version
    Write-Host "✓ Pester $pesterVersion loaded successfully" -ForegroundColor Green
} catch {
    Write-Host "✗ Failed to load Pester module (version 5.0+ required)" -ForegroundColor Red
    Write-Host "  Install Pester with: Install-Module -Name Pester -Force -SkipPublisherCheck" -ForegroundColor Yellow
    exit 1
}

# Verify test path exists
if (!(Test-Path $TestPath)) {
    Write-Host "✗ Test path '$TestPath' not found" -ForegroundColor Red
    exit 1
}

Write-Host "Test Path: $TestPath" -ForegroundColor Gray
Write-Host "Output Format: $OutputFormat" -ForegroundColor Gray

if ($OutputFile) {
    Write-Host "Output File: $OutputFile" -ForegroundColor Gray
}

Write-Host ""

# Configure Pester
$PesterConfiguration = @{
    Run = @{
        Path = $TestPath
        PassThru = $true
    }
    Output = @{
        Verbosity = 'Normal'
    }
    Should = @{
        ErrorAction = 'Continue'
    }
}

# Configure output format
switch ($OutputFormat) {
    "NUnitXml" {
        if (!$OutputFile) {
            $OutputFile = "TestResults-NUnit.xml"
        }
        $PesterConfiguration.TestResult = @{
            Enabled = $true
            OutputFormat = 'NUnitXml'
            OutputPath = $OutputFile
        }
    }
    "JUnitXml" {
        if (!$OutputFile) {
            $OutputFile = "TestResults-JUnit.xml"
        }
        $PesterConfiguration.TestResult = @{
            Enabled = $true
            OutputFormat = 'JUnitXml'
            OutputPath = $OutputFile
        }
    }
}

# Run the tests
Write-Host "Running tests..." -ForegroundColor Yellow
Write-Host ""

$TestResults = Invoke-Pester -Configuration $PesterConfiguration

# Display summary
if ($ShowSummary) {
    Write-Host ""
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host "Test Summary" -ForegroundColor Cyan
    Write-Host "=====================================" -ForegroundColor Cyan
    
    $totalTests = $TestResults.TotalCount
    $passedTests = $TestResults.PassedCount
    $failedTests = $TestResults.FailedCount
    $skippedTests = $TestResults.SkippedCount
    
    Write-Host "Total Tests:   $totalTests" -ForegroundColor White
    Write-Host "Passed Tests:  $passedTests" -ForegroundColor Green
    
    if ($failedTests -gt 0) {
        Write-Host "Failed Tests:  $failedTests" -ForegroundColor Red
    } else {
        Write-Host "Failed Tests:  $failedTests" -ForegroundColor Green
    }
    
    if ($skippedTests -gt 0) {
        Write-Host "Skipped Tests: $skippedTests" -ForegroundColor Yellow
    } else {
        Write-Host "Skipped Tests: $skippedTests" -ForegroundColor Green
    }
    
    $duration = $TestResults.Duration
    Write-Host "Duration:      $($duration.TotalSeconds.ToString('F2')) seconds" -ForegroundColor Gray
    
    Write-Host ""
    
    if ($failedTests -eq 0) {
        Write-Host "✓ All tests passed!" -ForegroundColor Green
        $exitCode = 0
    } else {
        Write-Host "✗ Some tests failed!" -ForegroundColor Red
        $exitCode = 1
        
        # Show failed test details
        Write-Host ""
        Write-Host "Failed Tests:" -ForegroundColor Red
        foreach ($test in $TestResults.Tests | Where-Object { $_.Result -eq 'Failed' }) {
            Write-Host "  - $($test.ExpandedPath): $($test.ErrorRecord.Exception.Message)" -ForegroundColor Red
        }
    }
    
    if ($OutputFile) {
        Write-Host ""
        Write-Host "Test results saved to: $OutputFile" -ForegroundColor Gray
    }
}

# Return results if requested
if ($PassThru) {
    return $TestResults
}

# Set appropriate exit code for CI/CD scenarios
exit $exitCode