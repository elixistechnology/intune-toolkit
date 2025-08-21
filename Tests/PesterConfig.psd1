# Pester Configuration for Intune Toolkit Tests

@{
    # General test configuration
    Run = @{
        # Path to test files - can be overridden by Run-Tests.ps1
        Path = @(".\Tests")
        
        # Skip running tests, useful for debugging test discovery
        Skip = $false
        
        # Return test results object
        PassThru = $true
        
        # Exit with non-zero code on test failures
        Exit = $false
        
        # Throw on failures (useful for debugging)
        Throw = $false
    }
    
    # Filter configuration
    Filter = @{
        # Run tests with specific tags
        Tag = @()
        
        # Exclude tests with specific tags
        ExcludeTag = @()
        
        # Run only tests with specific lines (for debugging)
        Line = @()
        
        # Run only tests with specific full names
        FullName = @()
    }
    
    # Code coverage configuration
    CodeCoverage = @{
        # Enable code coverage
        Enabled = $false
        
        # Paths to analyze for coverage
        Path = @(".\Scripts\*.ps1")
        
        # Files to exclude from coverage
        ExcludePath = @()
        
        # Output format for coverage report
        OutputFormat = "JaCoCo"
        
        # Output path for coverage report
        OutputPath = ".\Tests\Coverage.xml"
    }
    
    # Test result output configuration
    TestResult = @{
        # Enable test result output
        Enabled = $false
        
        # Output format (NUnitXml, JUnitXml)
        OutputFormat = "NUnitXml"
        
        # Output path
        OutputPath = ".\Tests\TestResults.xml"
    }
    
    # Output configuration
    Output = @{
        # Verbosity level: None, Normal, Detailed, Diagnostic
        Verbosity = "Normal"
        
        # Stack trace verbosity: None, Filtered, Full
        StackTraceVerbosity = "Filtered"
        
        # CI format for build servers
        CIFormat = "Auto"
    }
    
    # Should configuration for assertions
    Should = @{
        # Error action for failed assertions
        ErrorAction = "Continue"
    }
    
    # Debug configuration
    Debug = @{
        # Show navigational messages for debugging
        ShowNavigationMarkers = $false
        
        # Write debug stream
        WriteDebugMessages = $false
        
        # Write debug messages to screen
        WriteDebugMessagesFrom = @("Discovery", "Skip", "Mock", "CodeCoverage")
        
        # Return filter object from Invoke-Pester for debugging
        ReturnFilterObject = $false
        
        # Write screen plugin debug messages
        WriteScreenPluginDebugMessages = $false
    }
}