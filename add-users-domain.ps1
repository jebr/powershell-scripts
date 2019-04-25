<#
.KORTE BESCHRIJVING
    Dit script zal gebruikers toevoegen aan het domein middels import uit users.csv. Alle gebruikers zullen in verschillende Organizational units (OU) geplaatst worden. 
	Voor de OU wordt de kolom "Department" gebruikt. Voordat het script wordt uitgevoerd zullen alle OU's aangemaakt moeten worden. 
	Het aanmaken van OU's kan met het script "add-ou-domain.ps1".

.HANDLEIDING
    1. Vul de complete gegevens van de gebruikers in de CSV
    2. Plaats de users.csv op dezelfde locatie als het Powershell script
	3. Wijzig de waarden bij $DomainName en $DomainPath
    4. Start het script als Administrator
    5. Controleer of alle gebruikers zijn aangemaakt en in de OU's zijn geplaats.

.NOTITIE
    Bestandsnaam    : add-users-domain.ps1
    Auteur          : Jeroen Brauns

.LINK
    Github          : https://github.com/jebr/poweshell-scripts
	
.VOORBEELD USERS.CSV
	GivenName,Insertion,Surname,Email,Password,Department,AccountName
	Klaas," ",Vaak,klaasvaak@gmail.com,password1!,Sales,Klva
	Jan," van den ",Berg,jvdberg@yahoo.com,password123!,Support,Jabe
	
	!!LET OP!! de " " en spaties bij de kolom "Insertion"
	
.UITLEG KOLOMMEN
	GivenName	=	Voornaam
	Insertion	=	Tussenvoegsel
	Surname		=	Achternaam
	Email		=	E-mailadres (inlognaam)
	Password	=	Wachtwoord
	Department	=	Afdeling (OU)
	AccountName	=	Account naam (inlognaam pre-2000 server)
#>

#Variabelen
$Location = Get-Location #Locatie bepalen van het script
$Users = "$Location\users.csv" #Gerbuikers csv bestand
$DomainName = "systemen.local" # Volledige domain naam
$DomainPath = "dc=systemen, dc=local" # SUB- en TOP Domein

$ImportUsers = Import-Csv $Users

#This will self elevate the script so with a UAC prompt since this script needs to be run as an Administrator in order to function properly.
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    $arguments = "&" + $MyInvocation.MyCommand.Definition + "" 
    Write-Host "You didn't run this script as an Administrator. This script will self elevate to run as an Administrator." -ForegroundColor "White"
    Start-Sleep 1
    Start-Process "powershell.exe" -Verb RunAs -ArgumentList $arguments
    Break
}

Set-ExecutionPolicy Unrestricted

#Toevoegen gebruikers
Foreach($user in $ImportUsers){

    $Name = $user.GivenName + $user.Insertion + $user.Surname
    $GivenName = $user.GivenName
    $Surname = $user.Surname
    $DisplayName = $Name
    $Department = $user.Department
    $OUPath = "ou=$Department, $DomainPath"
    $SamAccountName = $user.AccountName
    $UserPrincipalName = $user.Email
    $SecurePass = ConvertTo-SecureString $user.Password -AsPlainText -Force

    #Syntax gebruikers toevoegen uit CSV
    New-ADUser -Name $Name -GivenName $GivenName -Surname $Surname -DisplayName $DisplayName -Path $OUPath -AccountPassword $SecurePass -SamAccountName $SamAccountName -ChangePasswordAtLogon $true -UserPrincipalName $UserPrincipalName -Enable $true -Department $Department
}

