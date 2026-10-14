param([string]$GamePath = 'C:\Program Files (x86)\Steam\steamapps\common\POSTAL2Complete', [switch]$CheckOnly)
$ErrorActionPreference = 'Stop'
$GamePath = (Resolve-Path -LiteralPath $GamePath).Path
$dlc = Join-Path $GamePath 'Paradise Lost'
$payload = Join-Path $PSScriptRoot 'Payload'
$runtime = Join-Path $PSScriptRoot 'Runtime'
$system = Join-Path $runtime 'System'
$manifest = Get-Content -LiteralPath (Join-Path $payload 'compatibility.json') -Raw | ConvertFrom-Json
foreach ($entry in $manifest) {
    $file = Join-Path $GamePath $entry.path
    if (!(Test-Path -LiteralPath $file)) { throw "Missing file: $file" }
    if ((Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash -ne $entry.sha256) {
        throw "File version mismatch: $file. This build requires the verified 5025 files."
    }
}
if ($CheckOnly) { Write-Host 'Game file compatibility verified.'; exit 0 }
if (Test-Path -LiteralPath $runtime) { throw 'Runtime already exists. For a fresh installation, extract the package into a new folder to preserve existing saves.' }
$workshop = Join-Path $GamePath 'WorkshopContent\737631813'
if (!(Test-Path -LiteralPath (Join-Path $workshop 'UCC_SERVER.zip'))) { throw 'Missing Nicks Coop Workshop item 737631813 (UCC_SERVER.zip). Install Nicks Coop from Steam first.' }
# Install into a sibling directory. A failed copy must not leave a partial
# Runtime that blocks the next setup attempt or appears ready to the launcher.
$destinationRuntime=$runtime
$runtime=Join-Path $PSScriptRoot ('Runtime.installing-'+[Guid]::NewGuid().ToString('N'))
$system=Join-Path $runtime 'System'
New-Item -ItemType Directory -Path $system -Force | Out-Null
foreach ($origin in @((Join-Path $GamePath 'System'), (Join-Path $dlc 'System'))) {
    Get-ChildItem -LiteralPath $origin -File | Where-Object { $_.Extension -in '.u','.dll','.int' } | Copy-Item -Destination $system -Force
}
Copy-Item -LiteralPath (Join-Path $dlc 'System\ParadiseLost.exe') -Destination (Join-Path $system 'PLCoop5025.exe')
Copy-Item -LiteralPath (Join-Path $dlc 'System\ParadiseLost.int') -Destination (Join-Path $system 'PLCoop5025.int')
Copy-Item -LiteralPath (Join-Path $dlc 'System\ParadiseLostSplash.bmp') -Destination (Join-Path $system 'PLCoop5025Splash.bmp')
foreach ($folder in @('KarmaData','Music')) {
    $dest = Join-Path $runtime $folder
    New-Item -ItemType Directory -Path $dest -Force | Out-Null
    foreach ($origin in @((Join-Path $GamePath $folder), (Join-Path $dlc $folder))) {
        if (Test-Path -LiteralPath $origin) { Get-ChildItem -LiteralPath $origin -File | Copy-Item -Destination $dest -Force }
    }
}
$compiler = Join-Path $runtime 'CompilerArchive'
Expand-Archive -LiteralPath (Join-Path $workshop 'UCC_SERVER.zip') -DestinationPath $compiler
$ucc = @(Get-ChildItem -LiteralPath $compiler -Recurse -Filter UCC.exe)
if ($ucc.Count -ne 1) { throw 'The archive must contain exactly one UCC.exe.' }
Copy-Item -LiteralPath $ucc[0].FullName -Destination $system
Get-ChildItem -LiteralPath (Join-Path $payload 'System') -File | Copy-Item -Destination $system -Force
foreach ($name in @('NicksCoopCustomMods.ini','NicksCoopInvReplace.ini')) {
    Copy-Item -LiteralPath (Join-Path $workshop $name) -Destination $system
}
$paths = @('Paths=..\System\*.u')
foreach ($root in @($dlc,$GamePath)) {
    foreach ($pair in @(@('Maps','fuk'),@('Textures','utx'),@('Sounds','uax'),@('StaticMeshes','usx'),@('Animations','ukx'),@('Music','ogg'))) {
        $paths += 'Paths=' + (Join-Path $root ($pair[0] + '\*.' + $pair[1]))
    }
}
$config = [IO.File]::ReadAllText((Join-Path $payload 'Runtime.template.ini')).Replace('@ASSET_PATHS@',($paths -join "`r`n"))
foreach ($name in @('PLCoop5025.ini','Server.ini','Client.ini')) { [IO.File]::WriteAllText((Join-Path $system $name),$config,[Text.Encoding]::Default) }
Copy-Item -LiteralPath (Join-Path $GamePath 'System\DefUser.ini') -Destination (Join-Path $system 'DefUser.ini')
Copy-Item -LiteralPath (Join-Path $GamePath 'System\DefUser.ini') -Destination (Join-Path $system 'PLCoopUser.ini')
[IO.File]::WriteAllText((Join-Path $system 'steam_appid.txt'),'223470',[Text.Encoding]::ASCII)
$setupRoot=[IO.Path]::GetFullPath($PSScriptRoot).TrimEnd('\')
foreach ($setupTarget in @($runtime,$destinationRuntime)) {
    if ([IO.Path]::GetDirectoryName([IO.Path]::GetFullPath($setupTarget)) -ne $setupRoot) { throw 'Unexpected installation destination.' }
}
Move-Item -LiteralPath $runtime -Destination $destinationRuntime
Write-Host 'Setup complete. You can now play. The original game was not modified.'
