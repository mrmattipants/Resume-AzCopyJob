
Remove-Variable * -ErrorAction SilentlyContinue
Remove-Module *
$error.Clear()

#$Testing = 1
$AzProcess = (Get-Process azcopy -ErrorAction SilentlyContinue | Select-Object *) 

If (!$AzProcess) {

    $JobId = @()
    $StartTime = @()
    $Status = @()
    $Command = @()
    $i = 0
    $AzCopyPath = "C:\AzCopy"
    $SASToken = "sv=2019-07-07&sr=c&si=AccessPolicy-casrch-R&sig=bTbJkXAz179jTNGg6BBuJwKgUuh6U6A%2F3BIIemCV2Lc%3D&sip=54.183.150.191&timeout=1800"
    $AzCopyJob = (azcopy.exe jobs list)

    pushd $AzCopyPath
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

    If ($Testing) {
        $Jobs
        $Jobs | Select-Object -First 1 | Format-List
        Write-Host "JobId: $($Jobs.JobId[0])"
        Write-Host "Start Time: $($Jobs.StartTime[0])"
        Write-Host "Status: $($Jobs.Status[0])"
        Write-Host "Command: $($Jobs.Command[0])"
    } else {
        If ($Jobs.Status[0] -eq "InProgress") {
            azcopy.exe jobs resume $Jobs.JobId[0] --source-sas $SASToken
        } else {
            Write-Host "AzCopy Job was $($Jobs.Status[0])!"
        }
    }

    popd

} else {
    Write-Host "AzCopy.exe is Running!"
}