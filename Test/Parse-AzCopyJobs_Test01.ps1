
Remove-Variable * -ErrorAction SilentlyContinue
Remove-Module *
$error.Clear()

$JobId = @()
$StartTime = @()
$Status = @()
$Command = @()

$LastAzCopyJob = (C:\AzCopy\azcopy.exe jobs list)

$JobId = ($LastAzCopyJob | Where-Object {$_ -match 'JobId:'} | Foreach-Object {$_ -replace 'JobId: ',''})
$StartTime = ($LastAzCopyJob | Where-Object {$_ -match 'Start Time:'} | Foreach-Object {$_ -replace 'Start Time: ',''})
$Statuses = ($LastAzCopyJob | Where-Object {$_ -match 'Status:'} | Foreach-Object {$_ -replace 'Status: ',''})
$Commands = ($LastAzCopyJob | Where-Object {$_ -match 'Command:'} | Foreach-Object {$_ -replace 'Command: ',''})

[int]$max = $JobId.Count
$Jobs = for ( $i = 0; $i -lt $max; $i++) {
    [pscustomobject] @{
        JobId = $JobId[$i]
        StartTime = $StartTime[$i]
        Status = $Statuses[$i]
        Command = $Commands[$i]
    }
}

$Jobs | Format-Table

$Jobs | Select-Object -First 1 | Format-List

Write-Host "JobId: $($Jobs.JobId[0])"
Write-Host "Start Time: $($Jobs.StartTime[0])"
Write-Host "Status: $($Jobs.Status[0])"
Write-Host "Command: $($Jobs.Command[0])"