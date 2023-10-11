<#
    A Powershell script that checks the status of Veeam Backup for Microsoft 365.

    0 Service state is OK.
    1 Service state is WARNING.
    2 Service state is CRITICAL.
    3 Service state is UNKNOWN.

    Author David Franzen
    Copyright (c) David Franzen
    Version: v1.3

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

#Imports the Veeam365 Powershell module
$VeeamModulePath = "C:\Program Files\Veeam\Backup365\Veeam.Archiver.PowerShell"
$env:PSModulePath = $env:PSModulePath + "$([System.IO.Path]::PathSeparator)$VeeamModulePath"
Import-Module Veeam.Archiver.PowerShell

$jobs = Get-VBOJob
$jobCounter = $jobs.Count
$lastStatus = $job.LastStatus
$lastRun = $job.LasRun

$exitcode = $EXIT_OK

$licenses = Get-VBOLicense

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
        Write-Host "Running:" $backupname
        $exitcode = $EXIT_OK
    }
    elseif($lastStatus -eq "Failed")
    {
        $critical_jobs += "Critical: $backupname`n"
        $output_jobs_failed_counter++
        $exitcode = $EXIT_CRITICAL
    } elseif($lastStatus -eq "Warning"){
        $warning_jobs += "Warning: $backupname`n"
        $output_jobs_warning_counter++
        $exitcode = $EXIT_WARNING
    } elseif($lastStatus -eq "Success")
    {
        #Write-Host "Success:" $backupname
        $output_jobs_success_counter++
        $successful_jobs = "{0} of {1} jobs successful." -f $output_jobs_success_counter,$jobCounter
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
        $license_status = "OK: License is $licensestatus"
<<<<<<< HEAD
        $output_jobs_success_counter++
        $exitcode = $EXIT_OK
        if($usedLicenses -gt $totalLicenses){
            $license_usage = "Warning: $usedLicenses out of $totalLicenses licenses are claimed."
            $output_jobs_warning_counter++
            $exitcode = $EXIT_WARNING
        }elseif ($usedLicenses -lt $totalLicenses){
            $license_usage = "OK: $usedLicenses out of $totalLicenses licenses are claimed."
            $output_jobs_success_counter++
=======
        $exitcode = $EXIT_OK
        if($usedLicenses -ge $totalLicenses){
            $license_usage = "Warning: $usedLicenses out of $totalLicenses licenses are claimed."
            $exitcode = $EXIT_WARNING
        }elseif ($usedLicenses -lt $totalLicenses){
            $license_usage = "OK: $usedLicenses out of $totalLicenses licenses are claimed."
>>>>>>> 164938a3f1a6e8096a16b322e4de22fdcbf823cd
            $exitcode = $EXIT_OK
        }
    }else{
        $license_status = "Critical: License is $licensestatus"
<<<<<<< HEAD
        $output_jobs_failed_counter++
=======
>>>>>>> 164938a3f1a6e8096a16b322e4de22fdcbf823cd
    }
}
    <# Monitoring license lifetime.
    Veeam uses two licenses during licensing.
    Veeam 365 Backup license and Veeam 365 Support license.
    Here the validity of the two license types is read out with a simple if else branch.
    #>

    if ($licenseLifetime) {
<<<<<<< HEAD
        $support_status = "OK: Support is valid"
        $output_jobs_success_counter++
        $exitcode = $EXIT_OK
    }else{
        $support_status = "Critical: Support is invalid (no license found)"
        $output_jobs_failed_counter++
=======
        $support_status = "Support is valid"
        $exitcode = $EXIT_OK
    }else{
        $support_status = "Support is invalid (no license found)"
>>>>>>> 164938a3f1a6e8096a16b322e4de22fdcbf823cd
        $exitcode = $EXIT_CRITICAL
    }

    if($output_jobs_failed_counter -gt 0){
<<<<<<< HEAD
        write-Host "$successful_jobs $license_status, $license_usage $support_status`n$critical_jobs $warning_jobs"
        $exitcode = $EXIT_CRITICAL
    }
    elseif($output_jobs_warning_counter -gt 0){
        write-Host "$successful_jobs $license_status, $license_usage $support_status`n$warning_jobs"
        $exitcode = $EXIT_WARNING
    }
    elseif ($output_jobs_success_counter -gt 0) {
        Write-Host "$successful_jobs $licensestatus, $license_usage $support_status"
        $exitcode = $EXIT_OK
    }
    else{
        write-Host "$successful_jobs $license_status, $license_usage $support_status"
        $exitcode = $EXIT_OK
=======
        write-Host "Failed Jobs founds. $successful_jobs $license_status, $license_usage $support_status`n$critical_jobs $warning_jobs"
    }
    elseif($output_jobs_warning_counter -gt 0){
        write-Host "Failed Jobs founds. $successful_jobs $license_status, $license_usage $support_status`n$warning_jobs"
    }
    else{
        write-Host "$successful_jobs $license_status, $license_usage $support_status"
>>>>>>> 164938a3f1a6e8096a16b322e4de22fdcbf823cd
    }

    exit $exitcode

catch[System.SystemException]{
    Write-Host $_
     exit $EXIT_UNKNOWN
}