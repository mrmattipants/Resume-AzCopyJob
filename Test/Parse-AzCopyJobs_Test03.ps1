
Remove-Variable * -ErrorAction SilentlyContinue
Remove-Module *
$error.Clear()

$JobId = @()
$StartTime = @()
$Status = @()
$Command = @()

$i = 0
$AzCopyJob = (C:\AzCopy\azcopy.exe jobs list)

$AzCopyJob | Select-Object -Skip 4 | ForEach-Object {
    $line = $_
    switch (++$i % 5) {
        1 { $JobId += ($Line | Where-Object {$_ -match 'JobId:'} | Foreach-Object {$_ -replace 'JobId: ',''}) }
        2 { $StartTime += ($Line | Where-Object {$_ -match 'Start Time:'} | Foreach-Object {$_ -replace 'Start Time: ',''}) }
        3 { $Status += ($Line | Where-Object {$_ -match 'Status:'} | Foreach-Object {$_ -replace 'Status: ',''}) }
        4 { $Command += ($Line | Where-Object {$_ -match 'Command:'} | Foreach-Object {$_ -replace 'Command: ',''}) }
        default {}
    }
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