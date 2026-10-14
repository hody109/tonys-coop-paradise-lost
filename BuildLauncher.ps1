$ErrorActionPreference='Stop'
$compiler=Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319\csc.exe'
if (!(Test-Path -LiteralPath $compiler)) { $compiler=Join-Path $env:WINDIR 'Microsoft.NET\Framework\v4.0.30319\csc.exe' }
if (!(Test-Path -LiteralPath $compiler)) { throw '.NET Framework 4 compiler not found.' }
$source=Join-Path $PSScriptRoot 'Source\Launcher\Launcher.cs'
$playit=Join-Path $PSScriptRoot 'Source\Launcher\Playit.cs'
$output=Join-Path $PSScriptRoot 'TonysCoopParadiseLost.exe'
& $compiler /nologo /target:winexe "/out:$output" /reference:System.Windows.Forms.dll /reference:System.Drawing.dll $source $playit (Join-Path $PSScriptRoot 'Source\Launcher\MusicDeck.cs')
if ($LASTEXITCODE -ne 0) { throw 'Launcher compilation failed. Close the running launcher before rebuilding.' }
& $compiler /nologo /target:winexe ("/out:"+(Join-Path $PSScriptRoot 'PLCoopRelay.exe')) (Join-Path $PSScriptRoot 'Source\Launcher\UdpRelay.cs')
if ($LASTEXITCODE -ne 0) { throw 'UDP relay compilation failed. Close the running game before rebuilding.' }
Write-Host 'Launcher build succeeded.'
