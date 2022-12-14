
Remove-Variable * -ErrorAction SilentlyContinue
Remove-Module *
$error.Clear()

#$Testing = 1
$AzProcess = (Get-Process azcopy -ErrorAction SilentlyContinue | Select-Object *) 

If (!$AzProcess) {
    
    $i = 0
    $JobId = @()
    $StartTime = @()
    $Status = @()
    $Command = @()
    $AzCopyPath = "C:\AzCopy"
    $SourceSASToken = "sv=2020-01-30&sr=c&si=AccessPolicy-polname-R&sig=-REDACTED-&sip=192.168.10.150&timeout=1800"
    $DestinationToken = "sv=2020-01-30&sr=c&si=AccessPolicy-polname-R&sig=-REDACTED-&sip=192.168.10.150&timeout=1800"
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
            azcopy.exe jobs resume $Jobs.JobId[0] --source-sas $SourceSASToken --destination-sas $DestinationToken
        } else {
            Write-Host "AzCopy Job was $($Jobs.Status[0])!"
        }
    }

    popd

} else {
    Write-Host "AzCopy.exe is Running!"
}