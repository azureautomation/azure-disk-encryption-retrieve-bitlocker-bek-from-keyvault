########################################################################################################################
# If $kekUrl parameter is passed, please make sure the current user has 'Unwrap' permissions on the KeyVault.
# Permissions on the KeyVault can be retrieved by running 'Get-AzureRmKeyVault' cmdlet
########################################################################################################################

Param(
  [Parameter(Mandatory = $true, 
             HelpMessage="Versioned URL of the KeyVault secret that contains plain or wrapped disk encryption key")]
  [ValidateNotNullOrEmpty()]
  [string]$secretUrl,

  [Parameter(Mandatory = $false,
             HelpMessage="Optional: Versioned URL of the key encryption key that is used to wrap the disk encryption key")]
  [ValidateNotNullOrEmpty()]
  [string]$kekUrl,

  [Parameter(Mandatory = $true,
             HelpMessage="Location where the retrieved bitlocker key (BEK) file should be placed to")]
  [ValidateNotNullOrEmpty()]
  [string]$bekFilePath

)

########################################################################################################################
# Initialize ADAL libraries and get authentication context required to make REST API called against KeyVault REST APIs. 
########################################################################################################################

# Load ADAL Assemblies
$adal = "${env:ProgramFiles(x86)}\Microsoft SDKs\Azure\PowerShell\ResourceManager\AzureResourceManager\AzureRM.Profile\Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
$adalforms = "${env:ProgramFiles(x86)}\Microsoft SDKs\Azure\PowerShell\ResourceManager\AzureResourceManager\AzureRM.Profile\Microsoft.IdentityModel.Clients.ActiveDirectory.WindowsForms.dll"
[System.Reflection.Assembly]::LoadFrom($adal)
[System.Reflection.Assembly]::LoadFrom($adalforms)
# Set Azure AD Tenant name
$adTenant = "microsoft.com" 
# Set well-known client ID for AzurePowerShell
$clientId = "1950a258-227b-4e31-a9cf-717495945fc2" 
# Set redirect URI for Azure PowerShell
$redirectUri = "urn:ietf:wg:oauth:2.0:oob"
# Set Resource URI to Azure Service Management API
$resourceAppIdURI = "https://vault.azure.net"
# Set Authority to Azure AD Tenant
$authority = "https://login.windows.net/$adTenant"
# Create Authentication Context tied to Azure AD Tenant
$authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority
# Acquire token
$authResult = $authContext.AcquireToken($resourceAppIdURI, $clientId, $redirectUri, "Auto")
# Generate auth header 
$authHeader = $authResult.CreateAuthorizationHeader()
# Set HTTP request headers to include Authorization header
$headers = @{'x-ms-version'='2014-08-01';"Authorization" = $authHeader}

########################################################################################################################
# 1. Retrieve the secret from KeyVault
# 2. If Kek is not NULL, unwrap the secret with Kek by making KeyVault REST API call
# 3. Convert Base64 string to bytes and write to the BEK file
########################################################################################################################

#Get wrapped BEK secret and place it in JSON object to send to KeyVault REST API
$getSecretRequestUrl = $secretUrl+ "?api-version=2015-06-01";
$result = Invoke-RestMethod -Method GET -Uri $getSecretRequestUrl -Headers $headers -ContentType "application/json" -Debug
$bekSecretBase64 = $result.value;

if($kekUrl)
{
    #Call KeyVault REST API to Unwrap 
    $jsonObject = @"
    {
        "alg": "RSA-OAEP",
        "value" : "$bekSecretBase64"
    }
"@

    $unwrapKeyRequestUrl = $kekUrl+ "/unwrapkey?api-version=2015-06-01";
    $result = Invoke-RestMethod -Method POST -Uri $unwrapKeyRequestUrl -Headers $headers -Body $jsonObject -ContentType "application/json" -Debug

    #Convert Base64Url string returned by KeyVault unwrap to Base64 string
    $bekSecretBase64Url = $result.value;
    $bekSecretBase64 = $bekSecretBase64Url.Replace('-', '+');
    $bekSecretBase64 = $bekSecretBase64.Replace('_', '/');
    if($bekSecretBase64.Length %4 -eq 2)
    {
        $bekSecretBase64+= '==';
    }
    elseif($bekSecretBase64.Length %4 -eq 3)
    {
        $bekSecretBase64+= '=';
    }
}

#Convert base64 string to bytes and write to BEK file
$bekFileBytes = [System.Convert]::FromBase64String($bekSecretBase64);
[System.IO.File]::WriteAllBytes($bekFilePath,$bekFileBytes)