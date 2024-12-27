<#
.SYNOPSIS
    Script to delete all Group Policy Objects (GPOs) in the domain.

.DESCRIPTION
    This script retrieves all existing GPOs in the domain and deletes them. 
    It provides a confirmation of the GPOs to be deleted and handles errors gracefully.

.NOTES
    Script Name    : DeleteAllGPOs.ps1
    Version        : 0.1
    Author         : [Your Name]
    Approved By    : [Approver's Name]
    Date           : [Today's Date]
    Purpose        : Automate the deletion of all GPOs in the domain.

.PREREQUISITES
    - Active Directory module must be installed.
    - Appropriate permissions to manage and delete GPOs.

.PARAMETERS
    None.

.EXAMPLE
    .\DeleteAllGPOs.ps1
    This will delete all GPOs in the domain.

#>

# Start of Script

# Import the Active Directory module
Import-Module ActiveDirectory

# Get all GPOs
$gpos = Get-GPO -All

# Check if there are any GPOs to delete
if ($gpos.Count -eq 0) {
    Write-Host "No GPOs found to delete." -ForegroundColor Yellow
} else {
    Write-Host "The following GPOs will be deleted:" -ForegroundColor Red
    $gpos | ForEach-Object { Write-Host $_.DisplayName }

    # Delete all GPOs
    foreach ($gpo in $gpos) {
        try {
            Write-Host "Attempting to delete GPO '$($gpo.DisplayName)'..."
            Remove-GPO -Guid $gpo.Id -Confirm:$false
            Write-Host "Successfully deleted GPO '$($gpo.DisplayName)'" -ForegroundColor Green
        } catch {
            Write-Host "Failed to delete GPO '$($gpo.DisplayName)': $_" -ForegroundColor Red
        }
    }
}

Write-Host "GPO deletion process completed!" -ForegroundColor Cyan

# End of Script
