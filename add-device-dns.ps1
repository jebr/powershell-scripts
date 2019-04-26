<#
.KORTE BESCHRIJVING
    Dit script zal apparaten toevoegen aan de DNS (A record).

.HANDLEIDING
    1. Vul de complete gegevens van de aparaten in de CSV
    2. Plaats de devices.csv op dezelfde locatie als het Powershell script
    3. Wijzig de waarden bij $DomainName en $DomainPath
    4. Start het script als Administrator
    5. Controleer of alle apparaten zijn toegevoegd aan de DNS

.NOTITIE
    Bestandsnaam    : add-device-dns.ps1
    Auteur          : Jeroen Brauns

.LINK
    Github          : https://github.com/jebr/poweshell-scripts

.VOORBEELD DEVICES.CSV
    IPv4Address,Name,ZoneName
    10.11.1.50,AP-00-01,systemen.local

.UITLEG KOLOMMEN
    IPv4Address		=	IP-adres apparaat
	Name			=	Apparaat naam
	ZoneName		=	Domeinnaam
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

#Toevoegen apparaten
foreach($device in $ImportDevices){

    $IPv4Address = $device.IPv4Address
    $Name = $device.Name
    $ZoneName = $device.ZoneName

    #Syntax apparaten toevoegan aan DNS
    Add-DnsServerResourceRecordA -IPv4Address $IPv4Address -Name $Name -ZoneName $ZoneName
}
