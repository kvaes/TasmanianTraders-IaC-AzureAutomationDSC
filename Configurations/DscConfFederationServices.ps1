Configuration DscConfFederationServices
{
	Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
    Import-DscResource -ModuleName 'xDSCDomainjoin'
    $dscDomainAdmin = Get-AutomationPSCredential -Name 'addcDomainAdmin'
	$dscDomainName = Get-AutomationVariable -Name 'addcDomainName'

    node $AllNodes.NodeName
    {
        WindowsFeature ActiveDirectoryFederationServices
        {
            Name = 'ADFS-Federation'
            Ensure = 'Present'
            IncludeAllSubFeature = $true
            DependsOn = "[WindowsFeature]WindowsInternalDatabase" 
        }
		WindowsFeature WindowsInternalDatabase
        {
            Name = 'Windows-Internal-Database'
            Ensure = 'Present'
            IncludeAllSubFeature = $true
        }
        xDSCDomainjoin JoinDomain
        {
            Domain = $dscDomainName 
            Credential = $dscDomainAdmin
        }
    }
}