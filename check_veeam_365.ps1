<#
    A Powershell script that checks the backup status of Veeam Backup for Microsoft 365.

    0 Service state is OK.
    1 Service state is WARNING.
    2 Service state is CRITICAL.
    3 Service state is UNKNOWN.

    Author David Franzen
    Copyright (c) David Franzen
    Version: v1.2

    Tested on: Veeam Backup for Microsoft 365 V6 
#>

$EXIT_OK = 0       #Service state is OK.
$EXIT_WARNING = 1  #Service state is WARNING.
$EXIT_CRITICAL = 2 #Service state is CRITICAL.
$EXIT_UNKNOWN= 3   #Service state is UNKNOWN.

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

# Checks the status of the Veeam 365 subscription
# The general license status is checked.
# It checks how many licenses are in use and whether the licenses are still valid.

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
        Write-Host "Critical:" $backupname -ForegroundColor Red
        $output_jobs_failed_counter++
        $exitcode = $EXIT_CRITICAL
    } elseif($lastStatus -eq "Warning"){
        Write-Host "Warning:" $backupname -ForegroundColor Yellow
        $output_jobs_warning_counter++
        $exitcode = $EXIT_WARNING
    } elseif($lastStatus -eq "Success")
    {
        Write-Host "Success:" $backupname
        $output_jobs_success_counter++
        $exitcode = $EXIT_OK
    }
}

ForEach($license in $licenses)
{
    $licensestatus = $license.status
    $licenseLifetime = $license.ExpirationDate
    $licenseSupport = $license.SupportExpirationDate

    $usedLicenses = $license.UsedNumber
    $totalLicenses = $license.TotalNumber

    # Checks the utilization of the licenses. If more licenses are in use than available, the exit code EXIT_WARNING is taken. 
    # Veeam allows an over-utilization of licenses of 10%.
    if($licenseLifetime){
        Write-Host "OK: License is" $licensestatus
        $exitcode = $EXIT_OK
        if($usedLicenses -ge $totalLicenses){
            Write-Host "Warning: $usedLicenses out of $totalLicenses licenses are claimed." -ForegroundColor Yellow
            $exitcode = $EXIT_WARNING
        }elseif ($usedLicenses -lt $totalLicenses){
            Write-Host "OK: $usedLicenses out of $totalLicenses licenses are claimed."
            $exitcode = $EXIT_OK
        }
    }else{
        Write-Host "Critical: License is" $licensestatus -ForegroundColor Red
        $exitcode = $EXIT_CRITICAL
    }

    <# Monitoring license lifetime.
    Veeam uses two licenses during licensing.
    Veeam 365 Backup license and Veeam 365 Support license. 
    Here the validity of the two license types is read out with a simple if else branch.
    #>

    if ($licenseSupport) {
        Write-Host "Support is valid"
        $exitcode = $EXIT_OK
    }else{
        Write-Host "Support is valid" -ForegroundColor Red
        $exitcode = $EXIT_CRITICAL
    }
}

exit $exitcode
