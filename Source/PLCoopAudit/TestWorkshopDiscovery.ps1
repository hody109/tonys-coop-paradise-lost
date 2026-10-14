$ErrorActionPreference = 'Stop'
$tokens = $null
$parseErrors = $null
$setup = Join-Path $PSScriptRoot '..\..\Setup.ps1'
$ast = [System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path $setup), [ref]$tokens, [ref]$parseErrors)
if ($parseErrors.Count) { throw 'Setup.ps1 syntax errors.' }
$finder = $ast.Find({param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq 'Find-NicksCoopWorkshop'}, $true)
if (!$finder) { throw 'Workshop discovery function missing.' }
# Load only the production discovery function, without installing the game.
. ([scriptblock]::Create($finder.Extent.Text))
$tempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\')
$fixture = Join-Path $tempRoot ('TonyCoop-WorkshopTest-' + [Guid]::NewGuid().ToString('N'))
$game = Join-Path $fixture 'Steam Library\steamapps\common\POSTAL2Complete'
$legacy = Join-Path $game 'WorkshopContent\737631813'
$steam = Join-Path $fixture 'Steam Library\steamapps\workshop\content\223470\737631813'
try {
    New-Item -ItemType Directory -Path $game,$legacy,$steam -Force | Out-Null
    $failed = $false
    try { Find-NicksCoopWorkshop $game | Out-Null } catch { $failed = $_.Exception.Message.Contains('incomplete') }
    if (!$failed) { throw 'Missing files must produce an actionable error.' }
    foreach ($name in @('UCC_SERVER.zip','NicksCoopCustomMods.ini','NicksCoopInvReplace.ini')) {
        [IO.File]::WriteAllText((Join-Path $steam $name),'fixture')
    }
    if ((Find-NicksCoopWorkshop $game) -ne $steam) { throw 'Steam library location was not found.' }
    [IO.File]::WriteAllText((Join-Path $legacy 'UCC_SERVER.zip'),'fixture')
    if ((Find-NicksCoopWorkshop $game) -ne $steam) { throw 'Incomplete legacy installation hid complete Steam files.' }
    foreach ($name in @('NicksCoopCustomMods.ini','NicksCoopInvReplace.ini')) {
        [IO.File]::WriteAllText((Join-Path $legacy $name),'fixture')
    }
    if ((Find-NicksCoopWorkshop $game) -ne $legacy) { throw 'Legacy location compatibility failed.' }
    Write-Host 'PASS: Steam library, legacy location, incomplete fallback and missing-file diagnostics.'
} finally {
    $resolvedFixture = [IO.Path]::GetFullPath($fixture)
    if ([IO.Path]::GetDirectoryName($resolvedFixture) -ne $tempRoot -or [IO.Path]::GetFileName($resolvedFixture) -notlike 'TonyCoop-WorkshopTest-*') { throw 'Unexpected test cleanup path.' }
    if (Test-Path -LiteralPath $resolvedFixture) { Remove-Item -LiteralPath $resolvedFixture -Recurse -Force }
}
