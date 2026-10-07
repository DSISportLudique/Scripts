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
$Csvfile = "C:\blois.csv"
$Users = Import-Csv $Csvfile
Write-Host $Users

# The password for the new user
$Password = "P@ssw0rd1234"

# Import the Active Directory module
Import-Module ActiveDirectory

# Loop through each user
foreach ($User in $Users) {
    # TODO: refactor: 8spaces tab + try catch only arount the creations: (the ifs)
    try {
	# create a login name
	Write-Host USER: $User
	$name = $($User.psobject.properties.value -split ';')[0] -replace ' ', '_'
	$surname = $($User.psobject.properties.value -split ';')[1]
	$service = $($User.psobject.properties.value -split ';')[2]
	$fullname = $name + " " + $surname

    	$logname = $name
    	$logname += "." + $surname.Substring(0, [Math]::Min($surname.Length, 3))
	$logname = $logname.ToLower()
	Write-Host len $logname.Length
	if ($logname.Length -gt 20) {
		$logname = $name -replace '_', ''
		$logname = $logname.ToLower()
		#$logname += . + $surname.Substring(0, [Math]::Min($surname.Length, 3))

		#if ($name.Length < 20) {
		#	$logname = $name
		#}
	}

	$mail = $logname + "@blois.sportludique.fr"

	Write-Host "nom: $name"
	Write-Host "prenom: $surname"
	Write-Host "logname: $logname"
	Write-Host "service: $service"
        # Define the parameters using a hashtable
        $NewUserParams = @{
            Name                  = $name
            Surname               = $name
	    GivenName 		  = $surname
	    DisplayName		  = $fullname
	    EmailAddress 	  = $mail
	    Path		  = "ou=$service,ou=BLO-Services,dc=blo,dc=blois,dc=sportludique,dc=fr"
	    SamAccountName	  = $logname
	    AccountPassword  	  = (ConvertTo-SecureString "$Password" -AsPlainText -Force)
            Enabled               = $true # Enable the User in the AD
            ChangePasswordAtLogon = $true # Set the "User must change password at next logon"
        }

	if ( Get-ADOrganizationalUnit -Filter {Name -Like $service} ) {
		Write-Host "The OU $service already exists"
	}
	else {
		Write-Host Creating OU: $service
		New-ADOrganizationalUnit -Name $service -ProtectedFromAccidentalDeletion $False -Path "ou=BLO-Services,dc=blo,dc=blois,dc=sportludique,dc=fr"
	}
        # Check to see if the user already exists in AD
        if ( Get-ADUser -Filter {SamAccountName -eq "$logname"} ) {

            # Give a warning if user exists
            Write-Host "A user with username $logname already exists in Active Directory." -ForegroundColor Yellow
        
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

while ($true) {}
