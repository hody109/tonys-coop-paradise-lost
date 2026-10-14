$ErrorActionPreference='Stop'
$launcher=Get-Content -LiteralPath (Join-Path $PSScriptRoot '../../Launch.ps1') -Raw
$lines=($launcher -split "`n") | Where-Object {$_ -match '^\s*\$iniText=\[regex\]::Replace.*(SliderPawnGoal|BodiesSliderMax)'}
if($lines.Count -ne 3){throw 'Missing population migrations'}
$iniText="[Settings]`r`nSliderPawnGoal=12`r`nCoopSliderPawnGoalMax=12`r`nBodiesSliderMax=8`r`n"
foreach($line in $lines){Invoke-Expression $line}
if($iniText -notmatch 'SliderPawnGoal=30' -or $iniText -notmatch 'CoopSliderPawnGoalMax=30' -or $iniText -notmatch 'BodiesSliderMax=25'){throw 'Legacy defaults did not migrate'}
$custom="[Settings]`r`nSliderPawnGoal=42`r`nCoopSliderPawnGoalMax=42`r`nBodiesSliderMax=19`r`n"
$iniText=$custom
foreach($line in $lines){Invoke-Expression $line}
if($iniText -cne $custom){throw 'Custom settings changed'}
'PASS: legacy defaults migrate and custom settings remain unchanged.'
