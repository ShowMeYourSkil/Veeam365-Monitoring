# Intro 

This check monitors the backup status and health of Veeam Backup for Microsoft 365 (Veeam 365). 
If something is wrong with your Veeam Backup for Microsoft 365, you will receive an alert in Icinga/Nagios.

If you have any wishes or suggestions you are welcome to let me know by submitting an issue or a pull request. 😄

---

# Features

## Monitoring of backup jobs

If there is a problem with your backup (backup could not be completed successfully or the job ended with a warning) you will be informed about it.

## Monitoring of the licenses

The check monitors whether and how long your Veeam 365 license is valid. 
If your license is overused or the lifetime is about to end or has already ended, you will receive an alert. 

---

# Other
I have developed the Powershell script using the Official Powershell Module of Veeam 365.

---

- *https://helpcenter.veeam.com/docs/vbo365/powershell/veeam_psreference.html?ver=70*

  *Veeam 365 Powershell References*
  
---
Copyright (c) 2023 David Franzen

Covered by MIT License.
