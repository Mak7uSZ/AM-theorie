param([Parameter(Mandatory = $true)][string]$LuauPath)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$testSource = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'server-session.spec.luau') -Raw
$topicSource = Get-Content -LiteralPath (Join-Path $projectRoot 'src\ReplicatedStorage\TopicContent.lua') -Raw
$serverSource = Get-Content -LiteralPath (Join-Path $projectRoot 'src\ServerScriptService\Boot.server.lua') -Raw
$testSource = $testSource.Replace('--[[TOPIC_CONTENT]]', $topicSource).Replace('--[[SERVER_SOURCE]]', $serverSource)
$temporaryScript = Join-Path ([System.IO.Path]::GetTempPath()) ('am-theory-test-' + [guid]::NewGuid().ToString('N') + '.luau')
try {
    [System.IO.File]::WriteAllText($temporaryScript, $testSource, [System.Text.UTF8Encoding]::new($false))
    & $LuauPath $temporaryScript
    if ($LASTEXITCODE -ne 0) { throw 'Server session checks failed.' }
} finally {
    Remove-Item -LiteralPath $temporaryScript -ErrorAction SilentlyContinue
}
