
Remove-Variable * -ErrorAction SilentlyContinue
Remove-Module *
$error.Clear()

$JobId = @()
$StartTime = @()
$Status = @()
$Command = @()

$AzCopyJobs = (C:\AzCopy\azcopy.exe jobs list)

ForEach ($Line in $AzCopyJobs) {
  $JobId += ($Line | Where-Object {$_ -match 'JobId:'} | Foreach-Object {$_ -replace 'JobId: ',''})
  $StartTime += ($Line | Where-Object {$_ -match 'Start Time:'} | Foreach-Object {$_ -replace 'Start Time: ',''})
  $Status += ($Line | Where-Object {$_ -match 'Status:'} | Foreach-Object {$_ -replace 'Status: ',''})
  $Command += ($Line | Where-Object {$_ -match 'Command:'} | Foreach-Object {$_ -replace 'Command: ',''})
}

[int]$max = $JobId.Count
$Jobs = for ( $i = 0; $i -lt $max; $i++) {
      [pscustomobject] @{
      JobId = $JobId[$i]
      StartTime = $StartTime[$i]
      Status = $Status[$i]
      Command = $Command[$i]
      }
}

$Jobs

$Jobs | Select-Object -First 1 | Format-List

Write-Host "JobId: $($Jobs.JobId[0])"
Write-Host "Start Time: $($Jobs.StartTime[0])"
Write-Host "Status: $($Jobs.Status[0])"
Write-Host "Command: $($Jobs.Command[0])"