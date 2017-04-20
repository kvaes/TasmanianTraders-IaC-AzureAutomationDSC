Configuration DscConfDomainController
{
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
    Import-DscResource -ModuleName 'xActiveDirectory'
    $dscDomainAdmin = Get-AutomationPSCredential -Name 'addcDomainAdmin'
	$dscDomainName = Get-AutomationVariable -Name 'addcDomainName'
	$dscSafeModePassword = $dscDomainAdmin

    node $AllNodes.NodeName
    {
		WindowsFeature ADDSInstall 
        { 
            Ensure = "Present" 
            Name = "AD-Domain-Services" 
        } 
        xWaitForADDomain DscForestWait 
        { 
            DomainName = $dscDomainName
            DomainUserCredential = $dscDomainAdmin 
            RetryCount =  1440
            RetryIntervalSec = 60
            DependsOn = "[WindowsFeature]ADDSInstall" 
        } 
        xADDomainController SecondDC
        {
            DomainName = $dscDomainName
            DomainAdministratorCredential = $dscDomainAdmin
            SafemodeAdministratorPassword = $dscSafeModePassword
			DependsOn = "[xWaitForADDomain]DscForestWait" 
        }
    }        

}