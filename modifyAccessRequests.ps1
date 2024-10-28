# This script allows users to request access to sharepoint sites if they do not have access. 

# -------------PLEASE READ---------------
# This script uses PNP Powershell. In order to connect to PNP powershell, you must create an azure app registration first. You will need the Client ID of your app registration and the Tenant ID of your azure tenant
# PNP no longer supports username/password so you must create and install a certificate then upload it to your azure app registration that you created for PNP. 
# Create cert using New-SelfSignedCertificate -CertStoreLocation Cert:\CurrentUser\My -DnsName "PnP-Certificate" -KeyLength 2048 -KeyAlgorithm RSA -NotAfter (Get-Date).AddYears(1) -FriendlyName "PnP Authentication Certificate"
# From Azure, go to your newly created app registration and navigate to certificates. Upload your certificate.
# Be sure to grab your certificate thumbprint. You'll need it to connect.

# Install PNP Powershell
Install-Module -Name "PnP.PowerShell"

# Set variables
$AdminSiteURL = "https://YOUR_SHAREPOINT_ADMIN_URL"
$clientId = "YOUR APP PNP APP REGISTRATION CLIENT ID"
$tenantId = "YOUR ORGS TENANT ID"
$thumbprint = "YOUR CERTIFICATE THUMBPRINT"

Connect-PnPOnline -AzureEnvironment USGovernmentHigh -Url $adminSiteUrl -ClientId $clientId -Tenant $tenantId -Thumbprint $thumbprint

$siteCollections = Get-PnPTenantSite

# Loop through each site collection and update access request settings and sharing capabilities
foreach ($site in $siteCollections) {
    try {
        # Connect to the site
        Connect-PnPOnline -Url $site.Url -ClientId $clientId -Tenant $tenantId -Thumbprint $thumbprint
        
        # Get the web object
        $Web = Get-PnPWeb
        
        # Enable Access Request for the site to the Owners Group
        $Web.SetUseAccessRequestDefaultAndUpdate($True)
        $Web.Update()
        $Web.Context.ExecuteQuery()


        # Output the updated site URL
        Write-Host "Access requests enabled and sharing restricted for: $($site.Url)"
    }
    catch {
        # Handle any errors that occur during the connection or update
        Write-Host "Failed to update access requests and sharing for: $($site.Url). Error: $_"
    }
}

# Disconnect from SharePoint
Disconnect-PnPOnline