$ErrorActionPreference='Stop'
[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12
$folder=Join-Path $PSScriptRoot 'Private\Playit'
New-Item -ItemType Directory -Path $folder -Force | Out-Null
$temp=Join-Path $folder 'download.tmp'
Invoke-WebRequest -UseBasicParsing 'https://github.com/playit-cloud/playit-agent/releases/download/v0.17.1/playit-windows-x86_64.exe' -OutFile $temp
if ((Get-FileHash -LiteralPath $temp -Algorithm SHA256).Hash -ne 'B2BCFF05044D1B01F3D557E4FC9E8F4DF4BF8FC328DF3010380F82D9C7565684') { throw 'Playit download checksum mismatch. The agent was not installed.' }
Move-Item -LiteralPath $temp -Destination (Join-Path $folder 'playit.exe') -Force
Write-Host 'Playit installed. Open INTERNET and choose START / LINK AGENT.'
