# Intune Toolkit - Testing Framework

This directory contains the testing infrastructure for the Intune Toolkit using **Pester**, the PowerShell testing framework.

## Overview

The testing framework provides comprehensive unit tests for the core functionality of the Intune Toolkit, including:

- **Functions.ps1** - Core utility functions for Graph API interactions, platform detection, and data formatting
- **Main.ps1** - Application initialization, logging setup, and UI loading
- **Logging** - Log file management and message formatting

## Test Structure

```
Tests/
├── Functions.Tests.ps1     # Tests for core utility functions
├── Logging.Tests.ps1       # Tests for logging functionality  
├── Main.Tests.ps1          # Tests for main application initialization
├── PesterConfig.psd1       # Pester configuration file
└── README.md              # This file
```

## Requirements

- **PowerShell 7.0+** (same as main application)
- **Pester 5.0+** (PowerShell testing framework)

## Installation

Pester is typically included with PowerShell, but you can ensure you have the latest version:

```powershell
Install-Module -Name Pester -Force -SkipPublisherCheck
```

## Running Tests

### Quick Start

Run all tests with default settings:

```powershell
.\Run-Tests.ps1
```

### Advanced Usage

```powershell
# Run specific test file
.\Run-Tests.ps1 -TestPath "Tests\Functions.Tests.ps1"

# Generate XML test results for CI/CD
.\Run-Tests.ps1 -OutputFormat NUnitXml -OutputFile "TestResults.xml"

# Generate JUnit XML format
.\Run-Tests.ps1 -OutputFormat JUnitXml -OutputFile "TestResults-JUnit.xml"

# Return test results for further processing
$results = .\Run-Tests.ps1 -PassThru
```

### Direct Pester Usage

You can also run tests directly with Pester:

```powershell
# Run all tests
Invoke-Pester .\Tests

# Run specific test file
Invoke-Pester .\Tests\Functions.Tests.ps1

# Run with coverage
Invoke-Pester .\Tests -CodeCoverage .\Scripts\*.ps1
```

## Test Categories

### Functions.Tests.ps1
Tests for core utility functions including:
- `Get-PlatformApps` - Platform detection from OData types
- `Format-ApplicationType` - Application type formatting
- `Set-WindowIcon` - Window icon setting functionality
- `Get-GraphData` - Graph API data retrieval with pagination
- `Get-AllSecurityGroups` - Security group retrieval
- `Get-AllAssignmentFilters` - Assignment filter management

### Logging.Tests.ps1
Tests for logging infrastructure:
- `Write-IntuneToolkitLog` - Log message formatting and file operations
- Log file creation and management
- Multi-threaded logging scenarios
- Error handling in logging operations

### Main.Tests.ps1
Tests for application initialization:
- PowerShell version validation
- Log file setup and backup
- XAML loading and UI initialization
- Script import and dependency management

## Mocking Strategy

The tests use extensive mocking to:
- **Avoid external dependencies** - No actual Microsoft Graph API calls
- **Prevent file system side effects** - Mock file operations
- **Enable UI testing** - Mock WPF components
- **Ensure test isolation** - Each test runs independently

## Continuous Integration

The test framework is designed to work with CI/CD systems:

```yaml
# Example GitHub Actions step
- name: Run Tests
  shell: pwsh
  run: |
    .\Run-Tests.ps1 -OutputFormat NUnitXml -OutputFile "TestResults.xml"
    
- name: Publish Test Results
  uses: dorny/test-reporter@v1
  if: always()
  with:
    name: PowerShell Tests
    path: TestResults.xml
    reporter: java-junit
```

## Test Coverage

While comprehensive mocking is used, the tests focus on:
- ✅ **Business logic validation** - Core function behavior
- ✅ **Error handling** - Exception scenarios and graceful degradation
- ✅ **Input validation** - Parameter handling and edge cases
- ✅ **Output formatting** - Data transformation correctness

## Best Practices

When adding new tests:

1. **Follow naming conventions** - `Function.Tests.ps1` for function tests
2. **Use descriptive test names** - Clear "Should do X when Y" format
3. **Mock external dependencies** - Avoid file system, network, UI operations
4. **Test edge cases** - Empty inputs, null values, error conditions
5. **Keep tests focused** - One concept per test
6. **Use proper test structure** - Describe/Context/It blocks

## Troubleshooting

### Common Issues

**Pester version conflicts:**
```powershell
# Remove old Pester versions and install latest
Get-Module Pester -ListAvailable | Remove-Module -Force
Install-Module -Name Pester -Force -SkipPublisherCheck
```

**Import errors:**
- Ensure you're running from the repository root directory
- Check that all script files exist and are accessible
- Verify PowerShell execution policy allows script execution

**Mock failures:**
- Review mock parameter filters for accuracy
- Check that mocked functions/commands are spelled correctly
- Ensure mock scopes are appropriate (script, module, global)

### Getting Help

- [Pester Documentation](https://pester.dev/)
- [PowerShell Testing Best Practices](https://docs.microsoft.com/powershell/scripting/dev-cross-plat/testing/pester-concepts)
- Check existing tests for patterns and examples

## Contributing

When contributing new functionality:

1. **Add corresponding tests** for any new functions
2. **Update existing tests** if modifying existing functions  
3. **Run all tests** before submitting changes
4. **Follow established patterns** in existing test files
5. **Document any new test utilities** or mocking strategies

## Future Enhancements

Planned improvements to the testing framework:

- **Integration tests** with actual Graph API (optional)
- **Performance testing** for large data scenarios
- **UI automation tests** using PowerShell UI testing tools
- **Code coverage reporting** and quality gates
- **Parameterized tests** for data-driven scenarios