# AD-Lab-Builder
This repository contains scripts to efficiently create and manage Active Directory labs, enabling quick setup of users, organizational units (OUs), and policies for testing and development purposes.

# Steps to Get Started

1.  Download Files
        - Download the RandomUserData.csv and GPO_Policies.csv files.
2. Set Up Directory
        - Create a new folder on the C:\ drive named Scripts.
        - Copy the downloaded .csv files to this folder (C:\Scripts).
3. Download Scripts
        - Download all scripts from this repository and save them in the C:\Scripts folder.
        - Run PowerShell as Administrator
        - Open PowerShell ISE or PowerShell console with Administrator privileges.
4. Execute the Scripts
        - Run the scripts as needed, and your lab environment will be ready.

# What Each Script Does

1. Prepare-TestEnvironment.ps1
    Purpose: Sets up the organizational structure and users for the lab.

    Key Actions:
        - Creates an OU named Production.
        - Adds location-based sub-OUs under Production, with names derived from the RandomUserData.csv file.
        - Creates additional sub-OUs (Users, Groups, Computers, Servers) under each location.
        - Populates the Users OU with user accounts based on their respective locations.
        Note: The script generates 5,000 user accounts for the lab environment.

2. Create-GroupPolicy-TestEnvironment.ps1
    Purpose: Configures group policies based on the GPO_Policies.csv file.

    Key Actions:
        - Creates group policies listed in the CSV file.
        - Automatically identifies OUs with Users and Computers in their names across the domain.
        - Links the group policies to the identified OUs based on the policy type.

3. Delete-AllGPO-TestEnvironment.ps1
    Purpose: Removes all group policies in the domain.

    Key Actions:
        - Deletes all group policies except the default ones.
        - Ensures a clean slate for testing or lab teardown.
