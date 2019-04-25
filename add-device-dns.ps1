<#
.KORTE BESCHRIJVING
    Dit script

.HANDLEIDING
    1.

.NOTITIE
    Bestandsnaam    : add-device-dns.ps1
    Auteur          : Jeroen Brauns

.LINK
    Github          : https://github.com/jebr/poweshell-scripts
#>

#Variabelen
$Location = Get-Location #Locatie bepalen van het script
$Devices = "$Location\devices.csv" #Gerbuikers csv bestand
$DomainName = "systemen.local" # Volledige domain naam
$DomainPath = "dc=systemen, dc=local" # SUB- en TOP Domein

$ImportDevices = Import-Csv $Devices

#This will self elevate the script so with a UAC prompt since this script needs to be run as an Administrator in order to function properly.
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    $arguments = "&" + $MyInvocation.MyCommand.Definition + "" 
    Write-Host "You didn't run this script as an Administrator. This script will self elevate to run as an Administrator." -ForegroundColor "White"
    Start-Sleep 1
    Start-Process "powershell.exe" -Verb RunAs -ArgumentList $arguments
    Break
}

Set-ExecutionPolicy Unrestricted

foreach($device in $ImportDevices){
    Add-DnsServerResourceRecordA -IPv4Address 10.50.6.112 -ZoneName Systemen
}
