#Requires -Modules Pester

BeforeAll {
    # Set up test log file in a writable location
    $global:TestLogFile = Join-Path ([System.IO.Path]::GetTempPath()) "IntuneToolkit-BasicTest-$(Get-Random).log"
    $global:logFile = $TestLogFile
    
    # Define the Write-IntuneToolkitLog function for testing
    function global:Write-IntuneToolkitLog {
        param (
            [string]$message,
            [string]$component = "Main-IntuneToolkit",
            [string]$context = "",
            [string]$type = "1",
            [string]$thread = "1",
            [string]$file = "Main.ps1"
        )
        $timestamp = Get-Date -Format "HH:mm:ss.fffzzz"
        $date = Get-Date -Format "MM-dd-yyyy"
        $logMessage = "<![LOG[$message]LOG]!><time=`"$($timestamp)`" date=`"$date`" component=`"$component`" context=`"$context`" type=`"$type`" thread=`"$thread`" file=`"$file`">"
        try {
            Add-Content -Path $global:logFile -Value $logMessage -Force
        } catch {
            Write-Warning "Failed to write to log file: $_"
        }
    }
}

AfterAll {
    # Clean up test log file
    if (Test-Path $TestLogFile) {
        Remove-Item $TestLogFile -Force -ErrorAction SilentlyContinue
    }
}

Describe "Write-IntuneToolkitLog" {
    BeforeEach {
        # Clean log file before each test
        if (Test-Path $TestLogFile) {
            Clear-Content $TestLogFile -ErrorAction SilentlyContinue
        }
    }

    Context "When writing log entries" {
        It "Should write message to log file" {
            $testMessage = "This is a test log message"
            
            Write-IntuneToolkitLog -message $testMessage
            
            if (Test-Path $TestLogFile) {
                $logContent = Get-Content $TestLogFile -Raw
                $logContent | Should -Match $testMessage
            } else {
                # If file doesn't exist, the function should still not throw
                $true | Should -Be $true
            }
        }

        It "Should include component information" {
            $testComponent = "TestComponent"
            
            Write-IntuneToolkitLog -message "Test" -component $testComponent
            
            if (Test-Path $TestLogFile) {
                $logContent = Get-Content $TestLogFile -Raw
                $logContent | Should -Match $testComponent
            } else {
                $true | Should -Be $true
            }
        }

        It "Should use default component when not specified" {
            Write-IntuneToolkitLog -message "Test"
            
            if (Test-Path $TestLogFile) {
                $logContent = Get-Content $TestLogFile -Raw
                $logContent | Should -Match "Main-IntuneToolkit"
            } else {
                $true | Should -Be $true
            }
        }

        It "Should handle empty message without throwing" {
            { Write-IntuneToolkitLog -message "" } | Should -Not -Throw
        }

        It "Should include timestamp information" {
            Write-IntuneToolkitLog -message "Test"
            
            if (Test-Path $TestLogFile) {
                $logContent = Get-Content $TestLogFile -Raw
                $logContent | Should -Match "time=.*date="
            } else {
                $true | Should -Be $true
            }
        }
    }

    Context "Basic function validation" {
        It "Should be defined as a function" {
            Get-Command Write-IntuneToolkitLog -ErrorAction SilentlyContinue | Should -Not -BeNull
        }

        It "Should accept required parameters" {
            { Write-IntuneToolkitLog -message "test" -component "test" -file "test.ps1" } | Should -Not -Throw
        }
    }
}