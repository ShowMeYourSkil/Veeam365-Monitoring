<#
    A Powershell script that checks the backup status of Veeam Backup for Microsoft 365.

    0 Service state is OK.
    1 Service state is WARNING.
    2 Service state is CRITICAL.
    3 Service state is UNKNOWN.

    Author David Franzen
    Copyright (c) David Franzen
    Version: v1.2
#>

$EXIT_OK = 0       #Service state is OK.
$EXIT_WARNING = 1  #Service state is WARNING.
$EXIT_CRITICAL = 2 #Service state is CRITICAL.
$EXIT_UNKOWN = 3   #Service state is UNKNOWN.

$output_jobs_failed_counter = 0
$output_jobs_warning_counter = 0
$output_jobs_success_counter = 0
$output_jobs_running_counter = 0
$output_jobs_disabled_counter = 0

$jobs = Get-VBOJob
$lastStatus = $job.LastStatus
$lastRun = $job.LasRun

$exitcode = $EXIT_OK

$licenses = Get-VBOLicense

#Imports the Veeam365 Powershell module
$VeeamModulePath = "C:\Program Files\Veeam\Backup365\Veeam.Archiver.PowerShell"
$env:PSModulePath = $env:PSModulePath + "$([System.IO.Path]::PathSeparator)$VeeamModulePath"
Import-Module Veeam.Archiver.PowerShell

#Checks the status of the Veeam 365 subscription
ForEach($license in $licenses)
{
    $licensestatus = $license.status
    $licenseLifetime = $license.ExpirationDate
    $licenseSupport = $license.SupportExpirationDate

    $usedLicenses = $license.UsedNumber
    $totalLicenses = $license.TotalNumber

    if($licensestatus -eq "Valid"){
        Write-Host "OK: License is" $licensestatus
        $exitcode = $EXIT_OK
        if($usedLicenses -gt $totalLicenses){
            Write-Host "$usedLicenses out of $totalLicenses licenses are claimed."
            $exitcode = $EXIT_WARNING
        }elseif ($usedLicenses -lt $totalLicenses){
            Write-Host "$usedLicenses out of $totalLicenses licenses are claimed."
        }
    }else{
        Write-Host "Critical: License is" $licensestatus
        $exitcode = $EXIT_CRITICAL
    }

    if ($licenseLifetime) {
        Write-Host "License ist gueltig"
        $exitcode = $EXIT_OK
    }else{
        Write-Host "License ist ungueltig"
        $exitcode = $EXIT_CRITICAL
    }
    if ($licenseSupport) {
        Write-Host "Support ist vorhanden"
        $exitcode = $EXIT_OK
    }else{
        Write-Host "Support ist ausgelaufen"
        $exitcode = $EXIT_CRITICAL
    }
}

# Check the status of the backup jobs
ForEach($job in $jobs)
{
    $lastStatus = $job.LastStatus
    $backupname = $job.name
    #$runtime = $lastRun.CreationTime.toString("dd.MM.yyyy")

    if($lastStatus -eq "Running"){
        Write-Host "Running:" $backupname - $runtime
        $exitcode = $EXIT_OK
    }
    elseif($lastStatus -eq "Failed")
    {
        Write-Host "Critical:" $backupname;
        $output_jobs_failed_counter++;
        $exitcode = $EXIT_CRITICAL
    } elseif($lastStatus -eq "Warning"){
        Write-Host "Warning:" $backupname;
        $output_jobs_warning_counter++;
        $exitcode = $EXIT_WARNING
    } elseif($lastStatus -eq "Success")
    {
        Write-Host "Success:" $backupname;
        $output_jobs_success_counter++;
        $exitcode = $EXIT_OK
    }
}

exit $exitcode
