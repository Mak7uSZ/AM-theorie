param([Parameter(Mandatory = $true)][string]$LuauPath)

& (Join-Path $PSScriptRoot 'run-studio-script-test.ps1') -LuauPath $LuauPath `
    -Spec 'client-ui.spec.luau' -ScriptPath 'StarterPlayerScripts/ClientController.client.lua'
