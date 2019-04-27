<#
.KORTE BESCHRIJVING
    Dit script voegt reservering van IP-adressen toe aan de DHCP server.

.HANDLEIDING
    1. Vul alle gegevens in de CSV
    2. Plaats de dhcp-devices.csv op dezelfde locatie als het Powershell script
    3. Start het script als Administrator
    4. Controleer of alle apparaten zijn toegevoegd aan de DHCP reservering

.NOTITIE
    Bestandsnaam    : set-dhcp-reservation.ps1
    Auteur          : Jeroen Brauns

.LINK
    Github          : https://github.com/jebr/poweshell-scripts

.VOORBEELD DHCP-DEVICES.CSV


.UITLEG KOLOMMEN

#>

#Variabelen
$Location = Get-Location #Locatie bepalen van het script
$Devices = "$Location\dhcp-devices.csv" #Gerbuikers csv bestand
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


