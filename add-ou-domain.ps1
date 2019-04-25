<#
.KORTE BESCHRIJVING
    Dit script zal Organizational Unit's (OU) aanmaken middels import uit ou.csv.

.HANDLEIDING
    1. Vul de gewenste OU's in de ou.csv
    2. Plaats de ou.csv op dezelfde locatie als het Powershell script
    3. Start het script als Administrator
    4. Controleer of alle OU's aangemaakt zijn

.NOTITIE
    Bestandsnaam    : add-ou-domain.ps1
    Auteur          : Jeroen Brauns

.LINK
    Github          : https://github.com/jebr/poweshell-scripts
#>

#Variabelen
$Location = Get-Location #Locatie bepalen van het script
$OU = "$Location\ou.csv" #Groepen uit csv bestand
$DomainPath = "dc=systemen, dc=local" # SUB- en TOP Domein

#Importeren CSV
$ImportOU = Import-Csv $OU

#This will self elevate the script so with a UAC prompt since this script needs to be run as an Administrator in order to function properly.
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    $arguments = "&" + $MyInvocation.MyCommand.Definition + "" 
    Write-Host "You didn't run this script as an Administrator. This script will self elevate to run as an Administrator." -ForegroundColor "White"
    Start-Sleep 1
    Start-Process "powershell.exe" -Verb RunAs -ArgumentList $arguments
    Break
}

Set-ExecutionPolicy Unrestricted

#Aanmaken van OU's (Groepen)
foreach($group in $ImportOU){
    New-ADOrganizationalUnit -Name $group.OU -DisplayName $group.OU -Path $DomainPath -ProtectedFromAccidentalDeletion $false
}

