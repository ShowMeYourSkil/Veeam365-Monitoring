<#
    Ein Powershell Skript, was den Backup Status von Veeam Backup for Microsoft 365 prüfen
    Es prüft, ob der Backup Job im Status Failed, Warning, Running, Success oder Stopped ist

    0 – Dienst ist OK.
    1 – Dienst hat eine WARNUNG.
    2 – Der Dienst befindet sich in einem KRITISCHEN Status.
    3 – Der Dienst befindet sich im Status UNBEKANNT.

    Author David Franzen
    Copyright (c) David Franzen
#>

#$output_jobs_failed_counter = 0;
#$output_jobs_warning_counter = 0;
#$output_jobs_success_counter = 0;

$jobs = Get-VBOJob
$lastStatus = $job.LastStatus
$lastRun = $job.LasRun
#$organization = $job.Organization
$backupname = $job.name

ForEach($jobisenabled in $jobs){
    $isenabled = $jobs.IsEnabled

    if ($isenabled -eq "False") {
        Write-Host "Das Backup ist" $backupname "aktiviert";
        exit 1;
    }elseif($isenabled -eq "True"){
        Write-Host "Das Backup ist" $backupname "deaktiviert";
        exit 0;
        }
    }

ForEach($job in $jobs)
{
    if($lastStatus -eq "Running"){
        Write-Host "Das Veeam 365 Backup" $backupname "läuft derzeit noch";
        #$output_jobs_success_counter++;
        exit 0;
    }
    elseif($lastStatus -eq "Failed")
    {
        Write-Host "Das Veeam 365 Backup" $backupname "ist erfolgreich gelaufen";
        #$output_jobs_failed_counter++;
        exit 2;
    } elseif($lastStatus -eq "Warning"){
        Write-Host "Das Veeam 365 Backup" $backupname "ist mit einer Warnung geendet";
        $output_jobs_warning_counter++;
        exit 1;
    } elseif($lastStatus -eq "Success")
    {
        Write-Host "Das Veeam 365 Backup" $backupname "ist erfolgreich gelaufen!";
        #$output_jobs_success_counter++;
        exit 0;
    }
}
