<#
    A Powershell script that checks the backup status of Veeam Backup for Microsoft 365.

    0 Service state is OK.
    1 Service state is WARNING.
    2 Service state is CRITICAL.
    3 Servuce state is UNKNOWN.

    Author David Franzen
    Copyright (c) David Franzen
    Version: v1.2
#>

$output_jobs_failed_counter = 0;
$output_jobs_warning_counter = 0;
$output_jobs_success_counter = 0;
$output_jobs_running_counter = 0;
$output_jobs_disabled_counter = 0;

$jobs = Get-VBOJob
$lastStatus = $job.LastStatus
$lastRun = $job.LasRun
#$organization = $job.Organization
$backupname = $job.name

$VeeamModulePath = "C:\Program Files\Veeam\Backup365\Veeam.Archiver.PowerShell"
$env:PSModulePath = $env:PSModulePath + "$([System.IO.Path]::PathSeparator)$VeeamModulePath"
Import-Module Veeam.Archiver.PowerShell

ForEach($job in $jobs)
{
    $lastStatus = $job.LastStatus
    $isenabled = $jobs.IsEnabled
    if ($isenabled -eq "True") {
        Write-Host "Disabled: $backupname ($lastRun)";
        $output_jobs_disabled_counter++;
        exit 1;
    }elseif($lastStatus -eq "Running"){
        Write-Host "The BackupJob $backupname running"
        exit 0;
    }
    elseif($lastStatus -eq "Failed")
    {
        Write-Host "Critical: $backupname ($lastRun)";
        $output_jobs_failed_counter++;
        exit 2;
    } elseif($lastStatus -eq "Warning"){
        Write-Host "Warning: $backupname ($lastRun)";
        $output_jobs_warning_counter++;
        exit 1;
    } elseif($lastStatus -eq "Success")
    {
        Write-Host "Success: $backupname ($lastRun)";
        $output_jobs_success_counter++;
        exit 0;
    }
}

$output_jobs_success_counter = $output_jobs_running_counter + $output_jobs_success_counter;
