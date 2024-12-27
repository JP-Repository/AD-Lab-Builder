<#
.SYNOPSIS
    Script to create and link Group Policy Objects (GPOs) based on a CSV input file.

.DESCRIPTION
    This script reads a CSV file containing GPO names and types, creates the specified GPOs if they do not exist, 
    and links them to appropriate Organizational Units (OUs) based on their type (User or Computer).

.NOTES
    Script Name    : CreateAndLinkGPOs.ps1
    Version        : 0.1
    Author         : [Your Name]
    Approved By    : [Approver's Name]
    Date           : [Today's Date]
    Purpose        : Automate the creation and linking of GPOs to OUs.

.PREREQUISITES
    - Active Directory module must be installed.
    - Appropriate permissions to create GPOs and link them to OUs.
    - Input file (CSV) containing GPO details with columns `GPOName` and `Type`.

.PARAMETERS
    None.

.EXAMPLE
    .\CreateAndLinkGPOs.ps1
    This will create and link GPOs based on the details in the specified CSV file.

#>

# Start of Script

# Import the Active Directory module
Import-Module ActiveDirectory

# Import the CSV file containing GPO names and types
$gpoCsvPath = "C:\Scripts\GPO_Policies.csv" # Update the path as needed
$gpoData = Import-Csv -Path $gpoCsvPath

# Progress bar setup
$totalGPOs = $gpoData.Count
$currentProgress = 0

# Loop through each GPO in the CSV
foreach ($gpo in $gpoData) {
    $gpoName = $gpo.GPOName
    $gpoType = $gpo.Type

    # Create the GPO if it doesn't already exist
    if (-not (Get-GPO -Name $gpoName -ErrorAction SilentlyContinue)) {
        try {
            New-GPO -Name $gpoName -Comment "Created by script for $gpoType policies"
            Write-Host "Created GPO: $gpoName" -ForegroundColor Green
        } catch {
            Write-Host "Failed to create GPO '$gpoName': $_" -ForegroundColor Red
            continue
        }
    } else {
        Write-Host "GPO '$gpoName' already exists. Skipping creation..." -ForegroundColor Yellow
    }

    # If the GPO type is "User", search for all OUs with "Users" in their name
    if ($gpoType -eq "User") {
        $ouPath = Get-ADOrganizationalUnit -Filter "Name -like '*Users*'" # Search for all OUs with "Users" in their name
        Write-Host "Found the following OUs for User GPO '$gpoName':"
        $ouPath | ForEach-Object { Write-Host $_.DistinguishedName }
    } elseif ($gpoType -eq "Computer") {
        $ouPath = Get-ADOrganizationalUnit -Filter "Name -like '*Computers*'" # Search for all OUs with "Computers" in their name
        Write-Host "Found the following OUs for Computer GPO '$gpoName':"
        $ouPath | ForEach-Object { Write-Host $_.DistinguishedName }
    } else {
        Write-Host "Skipping unknown GPO type: $gpoType" -ForegroundColor Yellow
        continue
    }

    # Check if any OUs were found
    if ($ouPath.Count -eq 0) {
        Write-Host "No OUs found for GPO '$gpoName'. Skipping GPO linking..." -ForegroundColor Red
        continue
    }

    # Link the GPO to the OU(s)
    foreach ($ou in $ouPath) {
        try {
            Write-Host "Attempting to link GPO '$gpoName' to OU '$($ou.DistinguishedName)'..."
            New-GPLink -Name $gpoName -Target $ou.DistinguishedName -Enforced No
            Write-Host "Successfully linked GPO '$gpoName' to OU '$($ou.DistinguishedName)'" -ForegroundColor Green
        } catch {
            Write-Host "Failed to link GPO '$gpoName' to OU '$($ou.DistinguishedName)': $_" -ForegroundColor Red
        }
    }

    # Update the progress bar
    $currentProgress++
    Write-Progress -Activity "Creating and Linking GPOs" -Status "Processing $currentProgress of $totalGPOs" -PercentComplete (($currentProgress / $totalGPOs) * 100)
}

Write-Host "GPO creation and linking process completed!" -ForegroundColor Cyan

# End of Script
