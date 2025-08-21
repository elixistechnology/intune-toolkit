#Requires -Modules Pester

BeforeAll {
    # Define Write-IntuneToolkitLog function if not already defined
    function global:Write-IntuneToolkitLog {
        param (
            [string]$message,
            [string]$component = "Test",
            [string]$context = "",
            [string]$type = "1",
            [string]$thread = "1", 
            [string]$file = "Test.ps1"
        )
        # Mock implementation - do nothing
    }
    
    # Import the module/script being tested
    try {
        . "$PSScriptRoot\..\Scripts\Functions.ps1"
    } catch {
        Write-Warning "Could not import Functions.ps1: $_"
    }
}

Describe "Get-PlatformApps" {
    Context "When given valid OData types" {
        It "Should return 'Android' for Android app types" {
            Get-PlatformApps -odataType "#microsoft.graph.androidStoreApp" | Should -Be "Android"
            Get-PlatformApps -odataType "#microsoft.graph.androidLobApp" | Should -Be "Android"
            Get-PlatformApps -odataType "#microsoft.graph.androidManagedStoreApp" | Should -Be "Android"
            Get-PlatformApps -odataType "#microsoft.graph.androidForWorkApp" | Should -Be "Android"
        }

        It "Should return 'iOS' for iOS app types" {
            Get-PlatformApps -odataType "#microsoft.graph.iosStoreApp" | Should -Be "iOS"
            Get-PlatformApps -odataType "#microsoft.graph.iosLobApp" | Should -Be "iOS"
            Get-PlatformApps -odataType "#microsoft.graph.iosVppApp" | Should -Be "iOS"
            Get-PlatformApps -odataType "#microsoft.graph.iosWebClip" | Should -Be "iOS"
        }

        It "Should return 'Windows' for Windows app types" {
            Get-PlatformApps -odataType "#microsoft.graph.win32LobApp" | Should -Be "Windows"
            Get-PlatformApps -odataType "#microsoft.graph.windowsUniversalAppX" | Should -Be "Windows"
            Get-PlatformApps -odataType "#microsoft.graph.windowsStoreApp" | Should -Be "Windows"
            Get-PlatformApps -odataType "#microsoft.graph.windowsMicrosoftEdgeApp" | Should -Be "Windows"
        }

        It "Should return 'macOS' for macOS app types" {
            Get-PlatformApps -odataType "#microsoft.graph.macOSLobApp" | Should -Be "macOS"
            Get-PlatformApps -odataType "#microsoft.graph.macOSMicrosoftEdgeApp" | Should -Be "macOS"
            Get-PlatformApps -odataType "#microsoft.graph.macOSDmgApp" | Should -Be "macOS"
            Get-PlatformApps -odataType "#microsoft.graph.macOSPkgApp" | Should -Be "macOS"
        }

        It "Should return 'Web' for web app types" {
            Get-PlatformApps -odataType "#microsoft.graph.webApp" | Should -Be "Web"
        }
    }

    Context "When given invalid or unknown input" {
        It "Should return 'Unknown' for unrecognized OData types" {
            Get-PlatformApps -odataType "#microsoft.graph.unknownAppType" | Should -Be "Unknown"
            Get-PlatformApps -odataType "invalidType" | Should -Be "Unknown"
        }

        It "Should return 'Unknown' for empty or null input" {
            Get-PlatformApps -odataType "" | Should -Be "Unknown"
            Get-PlatformApps -odataType $null | Should -Be "Unknown"
        }
    }
}

Describe "Format-ApplicationType" {
    Context "When given valid OData types" {
        It "Should handle empty or null input" {
            Format-ApplicationType -odataType "" | Should -Be ""
            Format-ApplicationType -odataType $null | Should -Be ""
        }

        It "Should remove Microsoft Graph prefix" {
            $result = Format-ApplicationType -odataType "#microsoft.graph.testApp"
            $result | Should -Not -Match "microsoft\.graph\."
        }
        
        It "Should format basic application types" {
            $result = Format-ApplicationType -odataType "#microsoft.graph.win32LobApp"
            $result | Should -Not -BeNullOrEmpty
            $result.Length | Should -BeGreaterThan 0
        }
    }
}