<#
.SYNOPSIS
    Script to create organizational units (OUs) and users in Active Directory based on a CSV file.

.DESCRIPTION
    This script reads user data from a CSV file, creates location-based OUs under a base Production OU, 
    and creates sub-OUs (Users, Groups, Computers, Servers) under each location. 
    It then creates user accounts in the appropriate OUs.

.NOTES
    Script Name    : CreateUsersAndOUs.ps1
    Version        : 0.1
    Author         : [Your Name]
    Approved By    : [Approver's Name]
    Date           : [Today's Date]
    Purpose        : Automate the creation of OUs and user accounts in Active Directory.

.PREREQUISITES
    - Active Directory module must be installed.
    - Appropriate permissions to create OUs and user accounts in Active Directory.
    - Input CSV file with the required user details.

.PARAMETERS
    None.

.EXAMPLE
    .\CreateUsersAndOUs.ps1
    This will create OUs and users in Active Directory based on the provided CSV file.

#>

# Start of Script

# Import the Active Directory module
Import-Module ActiveDirectory

# Path to the CSV file
$csvPath = "C:\Scripts\RandomUserData.csv"

# Import the CSV data
$users = Import-Csv -Path $csvPath

# Define the base Production OU
$productionOU = "OU=Production,DC=contoso,DC=com"  # Update with your domain

# Create the Production OU if it doesn't exist
if (-not (Get-ADOrganizationalUnit -Filter {DistinguishedName -eq $productionOU} -ErrorAction SilentlyContinue)) {
    New-ADOrganizationalUnit -Name "Production" -Path "DC=contoso,DC=com"
    Write-Host "Created Production OU" -ForegroundColor Green
}

# Initialize the progress bar
$totalUsers = $users.Count
$currentCount = 0

# Loop through each user and create OUs, sub-OUs, and users
foreach ($user in $users) {
    $currentCount++
    $progressPercent = [math]::Round(($currentCount / $totalUsers) * 100, 2)
    Write-Progress -Activity "Creating Users and OUs" -Status "Processing $currentCount of $totalUsers ($progressPercent%)" -PercentComplete $progressPercent

    $location = $user.Location

    # Create the location-based OU under Production if it doesn't exist
    $locationOU = "OU=$location,$productionOU"
    if (-not (Get-ADOrganizationalUnit -Filter {DistinguishedName -eq $locationOU} -ErrorAction SilentlyContinue)) {
        New-ADOrganizationalUnit -Name $location -Path $productionOU
        Write-Host "Created OU for location: $location" -ForegroundColor Green
    }

    # Create sub-OUs under the location-based OU if they don't exist
    $subOUs = @("Users", "Groups", "Computers", "Servers")
    foreach ($subOU in $subOUs) {
        $subOUPath = "OU=$subOU,$locationOU"
        if (-not (Get-ADOrganizationalUnit -Filter {DistinguishedName -eq $subOUPath} -ErrorAction SilentlyContinue)) {
            New-ADOrganizationalUnit -Name $subOU -Path $locationOU
            Write-Host "Created $subOU OU under $location" -ForegroundColor Green
        }
    }

    # Set user properties for creation
    $userParams = @{
        Name               = $user.DisplayName
        GivenName          = $user.FirstName
        Surname            = $user.LastName
        SamAccountName     = $user.SamAccountName
        DisplayName        = $user.DisplayName
        UserPrincipalName  = "$($user.SamAccountName)@yourdomain.com"
        Department         = $user.Department
        Title              = $user.JobTitle
        Description        = $user.Description
        EmailAddress       = $user.EmailAddress
        Path               = "OU=Users,$locationOU"
        AccountPassword    = (ConvertTo-SecureString "P@ssw0rd!" -AsPlainText -Force)
        Enabled            = $true
    }

    # Create the user
    try {
        New-ADUser @userParams
        Write-Host "Created user: $($user.DisplayName) in $location" -ForegroundColor Green
    } catch {
        Write-Host "Failed to create user: $($user.DisplayName). Error: $_" -ForegroundColor Red
    }
}

Write-Host "Script execution completed!" -ForegroundColor Green

# End of Script
