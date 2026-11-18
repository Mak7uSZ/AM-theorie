param([Parameter(Mandatory = $true)][string]$LuauPath)

& (Join-Path $PSScriptRoot 'run-studio-script-test.ps1') -LuauPath $LuauPath `
    -Spec 'server-session.spec.luau' -ScriptPath 'ServerScriptService/Boot.server.lua' -IncludeServerModules
