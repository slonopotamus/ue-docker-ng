$ErrorActionPreference = "stop"

function Strip-JsonComments {
    param([string]$text)

    # Remove /* */ block comments (may span multiple lines)
    $result = $text -replace '(?s)/\*.*?\*/', ' '

    # Remove // line comments (// at start of line or preceded by whitespace)
    $lines = $result -split "`n"
    $cleaned = foreach ($line in $lines) {
        if ($line -match '^\s*//') {
            continue
        }
        $line
    }

    return $cleaned -join "`n"
}

$commonComponents = @(
    "Microsoft.Net.ComponentGroup.DevelopmentPrerequisites",
    "Microsoft.VisualStudio.Component.NuGet",
    "Microsoft.VisualStudio.Workload.VCTools",
    "Microsoft.VisualStudio.Workload.MSBuildTools"
)

$vs2022ExtraComponents = @(
    "Microsoft.NetCore.Component.SDK"
)

$windowsSdkPath = $args[0]
$jsonRaw = Get-Content -Path $windowsSdkPath -Raw -Encoding UTF8
$windowsSdkJson = Strip-JsonComments $jsonRaw | ConvertFrom-Json

if (-not $windowsSdkJson) {
    throw "Failed to parse Windows SDK JSON from $windowsSdkPath"
}

$vsVersion = $windowsSdkJson.MinimumVisualStudio2022Version
if (-not $vsVersion) {
    throw "Windows_SDK.json is missing 'MinimumVisualStudio2022Version' field"
}

$components = $commonComponents + $vs2022ExtraComponents + `
    $windowsSdkJson.VisualStudioSuggestedComponents + `
    $windowsSdkJson.VisualStudio2022SuggestedComponents

# UE-5.4 has buggy component version
$components = $components | Where-Object { $_ -ne "Microsoft.VisualStudio.Component.Windows10SDK.22621" }
if ($components -notcontains "Microsoft.VisualStudio.Component.Windows11SDK.22621") {
    $components += "Microsoft.VisualStudio.Component.Windows11SDK.22621"
}

# Deduplicate and sort
$components = $components | Sort-Object -Unique

$versionMajor = $vsVersion.Split(".", 2)[0]
$channelUrl = "https://aka.ms/vs/$versionMajor/release.ltsc.$vsVersion/channel"

$installerPath = "C:\vs_buildtools.exe"

Write-Output "Downloading Visual Studio $vsVersion installer..."
Invoke-WebRequest -Uri "https://aka.ms/vs/17/release/vs_buildtools.exe" -OutFile $installerPath

$argv = @(
    "--quiet",
    "--wait",
    "--channelUri", $channelUrl,
    "--productId", "Microsoft.VisualStudio.Product.BuildTools",
    "--norestart",
    "--nocache",
    "--installPath", "C:\BuildTools",
    "--locale", "en-US"
)

Write-Output "Installing Visual Studio $vsVersion..."
Write-Output "Components:"
foreach ($component in $components) {
    $argv += "--add", $component
    Write-Output " * $component"
}

& $installerPath $argv
