@echo off
powershell -NoProfile -ExecutionPolicy unrestricted -Command "c:\Sysadmin_stuff\BackupIISLogs\backup-iis-logs.ps1 -App searchapi -Server stuff2 -DestServer zabbix.healthcare.com -Username hiflogs -Password Vantage123 -Range 3,4,5,6"
