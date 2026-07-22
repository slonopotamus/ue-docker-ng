$ErrorActionPreference = "stop"

$setupScript = $args[0]

$code = Get-Content -Path $setupScript -Raw -Encoding UTF8

# Comment out the version selector call, since we don't need shell integration
$selectorCall = ".\Engine\Binaries\Win64\UnrealVersionSelector-Win64-Shipping.exe /register"
$code = $code.Replace($selectorCall, "@rem " + $selectorCall)

# Add output so we can see when script execution is complete, and ensure `pause` is not called on error
$code = $code.Replace("rem Done!", "echo Done!`r`nexit /b 0")
$code = $code.Replace("pause", "@rem pause")

Set-Content -Path $setupScript -Value $code -Encoding UTF8 -NoNewline

# Print the patched code to stderr for debug purposes
Write-Output "PATCHED ${setupScript}:`n`n$code"
