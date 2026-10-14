param([ValidateSet('Menu','New','Continue','Join','ListenNew','ListenContinue')][string]$Mode='Menu', [string]$Address='', [string]$PlayerName='', [ValidateRange(2,8)][int]$MaxPlayers=4, [ValidateRange(1024,65535)][int]$Port=7777, [switch]$Fullscreen, [ValidateRange(0,15)][int]$Character=0, [ValidateRange(0,14)][int]$Difficulty=5)
$ErrorActionPreference='Stop'
function Set-CampaignDifficulty([string]$Text, [int]$Index) {
    if($Index -lt 0 -or $Index -gt 14) { throw 'Difficulty must be between 0 and 14.' }
    # Same presets and mode flags as the original Nick's Coop host menu.
    $values=[ordered]@{
        GameDifficulty=[Math]::Min($Index,10)
        GameDifficultyNumber=$Index
        bLieberMode=($Index -eq 0)
        bHestonMode=($Index -in @(10,13))
        bTheyHateMeMode=($Index -in @(12,13,14))
        bInsaneoMode=($Index -in @(11,14))
        bExpertMode=($Index -in @(13,14))
        bLudicrousMode=$false
        bCustomMode=$false
    }
    # GameDifficulty is inherited as globalconfig from Engine.GameInfo;
    # the preset number and special-mode flags belong to P2GameInfo.
    $engine=[regex]::Match($Text,'(?ms)^\[Engine\.GameInfo\]\r?\n(?<body>.*?)(?=^\[|\z)')
    $engineBody=if($engine.Success){$engine.Groups['body'].Value}else{''}
    $engineBody=[regex]::Replace($engineBody,'(?im)^\s*GameDifficulty=[^\r\n]*\r?\n?','').TrimEnd()
    $engineBlock="[Engine.GameInfo]`r`n"+$engineBody+"`r`nGameDifficulty="+[Math]::Min($Index,10)+"`r`n"
    if($engine.Success) {$Text=$Text.Remove($engine.Index,$engine.Length).Insert($engine.Index,$engineBlock)}
    else {$Text+="`r`n"+$engineBlock}
    $section=[regex]::Match($Text,'(?ms)^\[Postal2Game\.P2GameInfo\]\r?\n(?<body>.*?)(?=^\[|\z)')
    $body=if($section.Success){$section.Groups['body'].Value}else{''}
    $keys=($values.Keys | ForEach-Object {[regex]::Escape($_)}) -join '|'
    $body=[regex]::Replace($body,'(?im)^\s*('+$keys+')=[^\r\n]*\r?\n?','').TrimEnd()
    $block="[Postal2Game.P2GameInfo]`r`n"+$body+"`r`n"
    foreach($key in $values.Keys) { $block+=$key+'='+$values[$key]+"`r`n" }
    if($section.Success) {return $Text.Remove($section.Index,$section.Length).Insert($section.Index,$block)}
    return $Text+"`r`n"+$block
}
$system=Join-Path $PSScriptRoot 'Runtime\System'
if (!(Test-Path -LiteralPath (Join-Path $system 'PLCoop5025.exe'))) { throw 'Run SET UP in the launcher first.' }
if ($Mode -eq 'Menu') {
    Write-Host "Tony's coop: Paradise Lost - experimental build"
    Write-Host '1 New campaign (server + your game)'
    Write-Host '2 Continue from the last map transition'
    Write-Host '3 Join a friend'
    Write-Host '4 New campaign as listen host (experimental)'
    Write-Host '5 Continue as listen host (experimental)'
    $choice=Read-Host 'Choice'
    $modes=@{'1'='New';'2'='Continue';'3'='Join';'4'='ListenNew';'5'='ListenContinue'}
    if (!$modes.ContainsKey($choice)) { throw 'Invalid choice.' }
    $Mode=$modes[$choice]
}
if (!$PlayerName) { $PlayerName=Read-Host 'Your nickname (letters, numbers, underscore or hyphen)' }
if ($PlayerName -notmatch '^[A-Za-z0-9_-]{1,24}$') { throw 'Use 1-24 letters A-Z, numbers, hyphens or underscores.' }
$characters=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'Characters.json') -Raw | ConvertFrom-Json
$skin=[string]$characters[$Character].Skin
if ($skin -and $skin -notmatch '^[A-Za-z0-9_.]+$') { throw 'Invalid character definition.' }
$lock=[IO.File]::Open((Join-Path $system 'launcher.lock'),[IO.FileMode]::OpenOrCreate,[IO.FileAccess]::ReadWrite,[IO.FileShare]::None)
$server=$null
$relay=$null
try {
    # Older installations copied the skeleton files but omitted their search path.
    # Repair all launcher configurations before any client or server starts.
    foreach ($iniName in @('Client.ini','Server.ini','PLCoop5025.ini','TestClient.ini')) {
        $iniPath=Join-Path $system $iniName
        if (!(Test-Path -LiteralPath $iniPath)) { continue }
        $iniText=[IO.File]::ReadAllText($iniPath)
        if ($iniText -notmatch '(?im)^Paths=\.\.\\KarmaData\\\*\.ka\s*$') {
            $iniText=$iniText.Replace('[Core.System]',"[Core.System]`r`nPaths=..\KarmaData\*.ka")
            [IO.File]::WriteAllText($iniPath,$iniText,[Text.Encoding]::Default)
        }
    }
    if ($Mode -eq 'Join') {
        if (!$Address) { $Address=Read-Host 'Host IP address (or IP:port)' }
        if ($Address -notmatch '^[A-Za-z0-9][A-Za-z0-9.-]*(?::[0-9]{1,5})?$') { throw 'Invalid address.' }
        if ($Address.Contains(':')) {
            $remotePort=[int]($Address.Split(':')[-1])
            if ($remotePort -lt 1 -or $remotePort -gt 65535) { throw 'The remote port must be between 1 and 65535.' }
        }
        $url=$Address+'?Name='+$PlayerName+'?PLHostKey='
    } else {
        $save=Join-Path $system 'NicksCoopSave.ini'
        $newGame=$Mode -in @('New','ListenNew')
        $map='PL-intro.fuk'
        if ($newGame) { Write-Host 'Intro: only you, the host, can press ENTER to begin after your friends join.' }
        if ($newGame) {
            if (Test-Path -LiteralPath $save) {
                $backup=Join-Path $PSScriptRoot ('SaveBackups\'+[DateTime]::Now.ToString('yyyyMMdd-HHmmss-fff'))
                New-Item -ItemType Directory -Path $backup -Force | Out-Null
                Move-Item -LiteralPath $save -Destination (Join-Path $backup 'NicksCoopSave.ini')
                Write-Host "Previous progress was backed up to $backup"
            }
        } else {
            if (!(Test-Path -LiteralPath $save)) { throw 'No saved progress exists yet.' }
            $match=[regex]::Match([IO.File]::ReadAllText($save),'(?im)^CoopSave_ServerNextLevel=(.+)$')
            if (!$match.Success) { throw 'No map-transition checkpoint is available.' }
            $map=$match.Groups[1].Value.Trim()
            if ($map -notmatch '^[A-Za-z0-9_.#?=&-]+$' -or $map -notmatch '^(?i:PL-)') { throw 'Unexpected checkpoint map.' }
            $map=($map -split '\?Game=',2)[0]
        }
        $configPath=Join-Path $system 'Server.ini'
        $config=[IO.File]::ReadAllText($configPath)
        if($newGame) { $config=Set-CampaignDifficulty $config $Difficulty; Write-Host "New campaign difficulty preset: $Difficulty." }
        $hostKey=[Guid]::NewGuid().ToString('N')+[Guid]::NewGuid().ToString('N')
        $config=[regex]::Replace($config,'(?im)^PLSessionHostKey=.*\r?\n?','')
        $hostSection='(?im)^\[NicksCoopPL\.CoopPLGameInfo\]\s*\r?$'
        if ([regex]::IsMatch($config,$hostSection)) {
            $config=[regex]::Replace($config,$hostSection,('[NicksCoopPL.CoopPLGameInfo]'+"`r`nPLSessionHostKey=$hostKey"),1)
        } else { $config+="`r`n[NicksCoopPL.CoopPLGameInfo]`r`nPLSessionHostKey=$hostKey`r`n" }
        $config=[regex]::Replace($config,'(?im)^bAutoSave_FirstRun=.*$',('bAutoSave_FirstRun='+$newGame.ToString()))
        [IO.File]::WriteAllText($configPath,$config,[Text.Encoding]::Default)
        $url=$map+'?Game=NicksCoopPL.CoopPLGameInfo?MaxPlayers='+$MaxPlayers+'?Name='+$PlayerName
        if ($Mode -like 'Listen*') { $url+='?listen?PLHostKey='+$hostKey }
        else {
            $relayExe=Join-Path $PSScriptRoot 'PLCoopRelay.exe'
            if (!(Test-Path -LiteralPath $relayExe)) { throw 'PLCoopRelay.exe is missing. Extract the complete launcher package.' }
            # Reserve the public port for a persistent relay. Unreal uses a separate
            # local port, which may close briefly when the engine replaces its map.
            $probeSocket=New-Object Net.Sockets.UdpClient(0)
            try { $serverPort=$probeSocket.Client.LocalEndPoint.Port } finally { $probeSocket.Close() }
            if ($serverPort -eq $Port) { throw 'Could not select a separate server port. Please retry.' }
            $relayLog=Join-Path $system 'PLCoopRelay.log'
            $relay=Start-Process -FilePath $relayExe -ArgumentList @($Port,$serverPort,$PID,('"'+$relayLog+'"')) -WorkingDirectory $system -WindowStyle Hidden -PassThru
            $relayReady=$false
            for($attempt=0;$attempt -lt 50;$attempt++) {
                Start-Sleep -Milliseconds 100
                if($relay.HasExited) { throw 'The UDP relay could not start. See Runtime\System\PLCoopRelay.log; the game port may already be in use.' }
                if(Test-Path -LiteralPath $relayLog) {
                    $relayReader=New-Object IO.StreamReader([IO.File]::Open($relayLog,[IO.FileMode]::Open,[IO.FileAccess]::Read,[IO.FileShare]::ReadWrite))
                    try { $relayReady=$relayReader.ReadToEnd().Contains("READY UDP $Port -> 127.0.0.1:$serverPort") } finally { $relayReader.Dispose() }
                    if($relayReady) { break }
                }
            }
            if(!$relayReady) { throw 'The UDP relay did not become ready. See Runtime\System\PLCoopRelay.log.' }
            Write-Host "Stable public UDP port: $Port. Keep your Playit tunnel pointing to 127.0.0.1:$Port."
            $server=Start-Process -FilePath (Join-Path $system 'UCC.exe') -ArgumentList @('server',$url,"-port=$serverPort",'ini=Server.ini','log=PLCoop-Server.log','-unattended','-forcelogflush') -WorkingDirectory $system -WindowStyle Hidden -PassThru
            Start-Sleep -Seconds 10
            if ($server.HasExited) { throw 'The server exited. See Runtime\System\PLCoop-Server.log.' }
            $url='127.0.0.1:'+$serverPort+'?Name='+$PlayerName+'?PLHostKey='+$hostKey
        }
    }
    $ini='Client.ini'
    if ($Mode -like 'Listen*') { $ini='Server.ini' }
    Write-Host 'Starting the game. The local server will stop when you close the game.'
    $display='-windowed'
    if ($Fullscreen) {
        Add-Type -Path (Join-Path $PSScriptRoot 'Source\Launcher\WindowMode.cs')
        $monitor=[ParadiseLostCoop.WindowMode]::CaptureMonitor()
        $width=$monitor.Right-$monitor.Left
        $height=$monitor.Bottom-$monitor.Top
        # A separate client config avoids saving desktop-sized window geometry
        # over the player's ordinary windowed settings or server configuration.
        $displayConfig=[IO.File]::ReadAllText((Join-Path $system $ini))
        $displayConfig=[regex]::Replace($displayConfig,'(?im)^StartupFullscreen=.*$','StartupFullscreen=False')
        $displayConfig=[regex]::Replace($displayConfig,'(?im)^WindowedViewportX=.*$',"WindowedViewportX=$width")
        $displayConfig=[regex]::Replace($displayConfig,'(?im)^WindowedViewportY=.*$',"WindowedViewportY=$height")
        $ini='BorderlessClient.ini'
        [IO.File]::WriteAllText((Join-Path $system $ini),$displayConfig,[Text.Encoding]::Default)
        Write-Host "Borderless window: ${width}x${height}."
    }
    $url+='?Skin='+$skin
    $gameArgs=@($url,"ini=$ini",'userini=PLCoopUser.ini','log=PLCoop-Player.log',$display,'-newwindow')
    if ($Mode -like 'Listen*') { $gameArgs+="-port=$Port" }
    $game=Start-Process -FilePath (Join-Path $system 'PLCoop5025.exe') -ArgumentList $gameArgs -WorkingDirectory $system -PassThru
    if ($Fullscreen) {
        if(![ParadiseLostCoop.WindowMode]::WaitForExit($game,$monitor)) {
            Write-Warning 'No game viewport was found for borderless mode. Check the game startup log.'
        }
    } else { $game.WaitForExit() }
    if ($game.ExitCode -ne 0) { throw "The game exited with code $($game.ExitCode). See Runtime\System\PLCoop-Player.log." }
    if ($server -and $server.HasExited -and $server.ExitCode -ne 0) { throw "The server exited with code $($server.ExitCode). See Runtime\System\PLCoop-Server.log." }
    if ($relay -and $relay.HasExited -and $relay.ExitCode -ne 0) { throw 'The UDP relay stopped. See Runtime\System\PLCoopRelay.log.' }
} finally {
    if ($server -and !$server.HasExited) { $server.Kill(); $server.WaitForExit() }
    if ($relay -and !$relay.HasExited) { $relay.Kill(); $relay.WaitForExit() }
    $lock.Dispose()
}
