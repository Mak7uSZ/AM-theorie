param([Parameter(Mandatory = $true)][string]$LuauPath)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$testSource = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'client-ui.spec.luau') -Raw
$topicSource = Get-Content -LiteralPath (Join-Path $projectRoot 'src\ReplicatedStorage\TopicContent.lua') -Raw
$clientSource = Get-Content -LiteralPath (Join-Path $projectRoot 'src\StarterPlayerScripts\ClientController.client.lua') -Raw
$testSource = $testSource.Replace('--[[TOPIC_CONTENT]]', $topicSource).Replace('--[[CLIENT_SOURCE]]', $clientSource)
$temporaryScript = Join-Path ([System.IO.Path]::GetTempPath()) ('am-theory-client-test-' + [guid]::NewGuid().ToString('N') + '.luau')
try {
    [System.IO.File]::WriteAllText($temporaryScript, $testSource, [System.Text.UTF8Encoding]::new($false))
    & $LuauPath $temporaryScript
    if ($LASTEXITCODE -ne 0) { throw 'Client UI checks failed.' }
} finally {
    Remove-Item -LiteralPath $temporaryScript -ErrorAction SilentlyContinue
}
