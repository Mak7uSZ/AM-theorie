param(
    [Parameter(Mandatory = $true)][string]$LuauPath,
    [Parameter(Mandatory = $true)][string]$Spec,
    [Parameter(Mandatory = $true)][string]$ScriptPath,
    [switch]$IncludeServerModules
)

$ErrorActionPreference = 'Stop'
$sourceRoot = Join-Path (Split-Path -Parent $PSScriptRoot) 'src'
$specSource = Get-Content -LiteralPath (Join-Path $PSScriptRoot $Spec) -Raw -Encoding utf8
$scriptSource = Get-Content -LiteralPath (Join-Path $sourceRoot $ScriptPath) -Raw -Encoding utf8
$moduleMounts = @'
local loaders, loaded = {}, {}
local function require(module)
	local load = assert(loaders[module], "Missing loader for " .. module.Name)
	if loaded[module] == nil then
		loaded[module] = load()
	end
	return loaded[module]
end

local function mountModule(serviceName, path, load)
	local parent = game:GetService(serviceName)
	local names = string.split(path, "/")
	for index = 1, #names - 1 do
		local name = names[index]
		local folder = parent:FindFirstChild(name)
		if not folder then
			folder = Instance.new("Folder")
			folder.Name, folder.Parent = name, parent
		end
		parent = folder
	end
	local module = Instance.new("ModuleScript")
	module.Name, module.Parent = names[#names], parent
	loaders[module] = load
end
'@

$services = @('ReplicatedStorage')
if ($IncludeServerModules) { $services += 'ServerScriptService' }
foreach ($service in $services) {
    $servicePath = Join-Path $sourceRoot $service
    $modules = Get-ChildItem -LiteralPath $servicePath -Filter '*.lua' -File -Recurse |
        Where-Object { $_.Name -notlike '*.server.lua' -and $_.Name -notlike '*.client.lua' }
    foreach ($module in $modules) {
        $relativePath = $module.FullName.Substring($servicePath.Length + 1).Replace('\', '/')
        $modulePath = ConvertTo-Json -InputObject ($relativePath -replace '\.lua$') -Compress
        $moduleSource = Get-Content -LiteralPath $module.FullName -Raw -Encoding utf8
        $moduleMounts += "`nmountModule(`"$service`", $modulePath, function()`n$moduleSource`nend)`n"
    }
}

$testSource = $specSource.Replace('--[[STUDIO_MODULES]]', $moduleMounts).Replace('--[[GAME_SOURCE]]', $scriptSource)
$temporaryScript = Join-Path ([System.IO.Path]::GetTempPath()) ('am-theory-test-' + [guid]::NewGuid().ToString('N') + '.luau')
try {
    [System.IO.File]::WriteAllText($temporaryScript, $testSource, [System.Text.UTF8Encoding]::new($false))
    & $LuauPath $temporaryScript
    if ($LASTEXITCODE -ne 0) { throw "$Spec failed." }
} finally {
    Remove-Item -LiteralPath $temporaryScript -ErrorAction SilentlyContinue
}
