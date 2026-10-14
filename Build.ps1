$ErrorActionPreference='Stop'
$runtime=Join-Path $PSScriptRoot 'Runtime'
if (!(Test-Path -LiteralPath (Join-Path $runtime 'System\UCC.exe'))) { throw 'Run Setup.ps1 first.' }
$build=Join-Path $PSScriptRoot ('Builds\'+[DateTime]::Now.ToString('yyyyMMdd-HHmmss-fff'))
$system=Join-Path $build 'System'
New-Item -ItemType Directory -Path $system -Force | Out-Null
Get-ChildItem -LiteralPath (Join-Path $runtime 'System') -File | Where-Object { $_.Extension -in '.u','.dll','.int','.exe' -and $_.Name -notin 'NicksCoop.u','PLBase.u','PLGame.u','NicksCoopPL.u','PLCoopAudit.u' } | Copy-Item -Destination $system
foreach ($name in @('NicksCoop','PLBase','PLGame','NicksCoopPL','PLCoopAudit')) {
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot "Source\$name") -Destination $build -Recurse
}
$paths=(Get-Content -LiteralPath (Join-Path $runtime 'System\Client.ini') | Where-Object { $_ -match '^Paths=' }) -join "`r`n"
$ini=[IO.File]::ReadAllText((Join-Path $PSScriptRoot 'Source\Build.template.ini')).Replace('@ASSET_PATHS@',$paths)
[IO.File]::WriteAllText((Join-Path $system 'Build.ini'),$ini,[Text.Encoding]::Default)
[IO.File]::WriteAllText((Join-Path $system 'Postal2.ini'),$ini,[Text.Encoding]::Default)
Copy-Item -LiteralPath (Join-Path $runtime 'System\DefUser.ini') -Destination $system
Push-Location $system
try {
    & .\UCC.exe make ini=Build.ini unattended 2>&1 | Tee-Object -FilePath (Join-Path $build 'compile.log')
    $compileLog=Join-Path $build 'compile.log'
    $compileText=[IO.File]::ReadAllText($compileLog)
    if ($LASTEXITCODE -ne 0 -or $compileText -notmatch 'Success - 0 error\(s\)' -or !(Test-Path -LiteralPath (Join-Path $system 'NicksCoopPL.u'))) {
        throw "Compilation failed. See $compileLog. UCC may return exit code 0 even on failure."
    }
} finally { Pop-Location }
Write-Host "Build output: $system. Send the same build to every player; do not mix compiled packages."
