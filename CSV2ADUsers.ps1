<#
    .SYNOPSIS
    Import-ADUsers.ps1

    .DESCRIPTION
    Import Active Directory users from CSV file.

    .LINK
    alitajran.com/import-ad-users-from-csv-powershell

    .NOTES
    Written by: ALI TAJRAN
    Website:    alitajran.com
    LinkedIn:   linkedin.com/in/alitajran

    .CHANGELOG
    V2.00, 02/11/2024 - Refactored script
#>

# Define the CSV file location and import the data
$Csvfile = "C:\temp\ImportADUsers.csv"
$Users = Import-Csv $Csvfile

# The password for the new user
$Password = "P@ssw0rd1234"

# Import the Active Directory module
Import-Module ActiveDirectory

# Loop through each user
foreach ($User in $Users) {
    try {
	# create a login name
    	$logname = $User.'NOM' -replace ' ', '_'
    	$logname += $User.'PRENOM'

        # Define the parameters using a hashtable
        $NewUserParams = @{
            Name                  = $User.'PRENOM'
            Surname               = $User.'NOM'
            Service               = $User.'SERVICE'
            Enabled               = $true # Enable the User in the AD
            ChangePasswordAtLogon = $true # Set the "User must change password at next logon"
        }

        # Check to see if the user already exists in AD
        if (Get-ADUser -Filter "SamAccountName -eq '$($logname)'") {

            # Give a warning if user exists
            Write-Host "A user with username $($logname) already exists in Active Directory." -ForegroundColor Yellow
        }
        else {
            # User does not exist then proceed to create the new user account
            # Account will be created in the OU provided by the $User.OU variable read from the CSV file
            New-ADUser @NewUserParams
            Write-Host "The user $($logname) is created successfully." -ForegroundColor Green
        }
    }
    catch {
        # Handle any errors that occur during account creation
        Write-Host "Failed to create user $($logname) - $($_.Exception.Message)" -ForegroundColor Red
    }
}
