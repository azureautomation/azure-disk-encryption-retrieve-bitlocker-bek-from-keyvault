Azure Disk Encryption: Retrieve Bitlocker BEK from KeyVault
===========================================================

            

This script can be used to retrieve the Bitocker BEK files from Azure Key Vault. It supports the both standard secrets and all secrets protected by a Key Encryption Key.


Firstly to run the script there are a few things to consider:


  *  The user who is running the commands must have the ‘**unwrap**‘ permission within Key Vault

  *  Update the $adal path to the required location either SDK folder or PowerShell module directory


$adal = '${env:ProgramFiles(x86)}\Microsoft SDKs\Azure\PowerShell\ResourceManager\AzureResourceManager\AzureRM.Profile\Microsoft.IdentityModel.Clients.ActiveDirectory.dll'
$adalforms = '${env:ProgramFiles(x86)}\Microsoft SDKs\Azure\PowerShell\ResourceManager\AzureResourceManager\AzureRM.Profile\Microsoft.IdentityModel.Clients.ActiveDirectory.WindowsForms.dll'


**If you are using the Azure/AzureRM Modules downloaded straight from the PowerShell Gallery, the paths will need to be updated to your powershell module directory. e.g.* ***


$adal = '${env:ProgramFiles}\WindowsPowerShell\Modules\AzureRM.profile\1.0.4\Microsoft.IdentityModel.Clients.ActiveDirectory.dll'
$adalforms = '${env:ProgramFiles}\WindowsPowerShell\Modules\AzureRM.profile\1.0.4\Microsoft.IdentityModel.Clients.ActiveDirectory.WindowsForms.dll'

       3.  The **$adTenant** variable needs to be set to the Azure AD Tenant that is linked to the subscription. e.g. example.onmicrosoft.com** *** *
       4.  You need to have the full Versioned URL of the KEK and Secret** 

After that the script can be run with the following:**


 

Note: I worked with Azure Security Team to complete, test and validate this script, but cannot take responsibility for it's entirety.

        
    
TechNet gallery is retiring! This script was migrated from TechNet script center to GitHub by Microsoft Azure Automation product group. All the Script Center fields like Rating, RatingCount and DownloadCount have been carried over to Github as-is for the migrated scripts only. Note : The Script Center fields will not be applicable for the new repositories created in Github & hence those fields will not show up for new Github repositories.
