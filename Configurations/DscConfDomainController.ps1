Configuration DscConfDomainController
{
    Import-DscResource -ModuleName xActiveDirectory, xStorage, PSDesiredStateConfiguration, xDSCDomainjoin
    $dscDomainAdmin = Get-AutomationPSCredential -Name 'addcDomainAdmin'
	$dscDomainName = Get-AutomationVariable -Name 'addcDomainName'
    $dscDomainNetbiosName = Get-AutomationVariable -Name 'addcDomainNetbiosName'
	$dscSafeModePassword = $dscDomainAdmin
	$DomainRoot = "DC=$($dscDomainAdmin -replace '\.',',DC=')"

    node FirstDC
    {

	    WindowsFeature DNS 
        { 
            Ensure = "Present" 
            Name = "DNS"		
        }

	    WindowsFeature DnsTools
	    {
	        Ensure = "Present"
            Name = "RSAT-DNS-Server"
            DependsOn = "[WindowsFeature]DNS"
	    }

        xWaitforDisk Disk2
        {
            DiskNumber = 2
            RetryIntervalSec = 20
            RetryCount = 30
        }

        xDisk ADDataDisk {
            DiskNumber = 2
            DriveLetter = "F"
            DependsOn = "[xWaitForDisk]Disk2"
        }

        WindowsFeature ADDSInstall 
        { 
            Ensure = "Present" 
            Name = "AD-Domain-Services"
	        DependsOn="[WindowsFeature]DNS" 
        } 

        WindowsFeature ADDSTools
        {
            Ensure = "Present"
            Name = "RSAT-ADDS-Tools"
            DependsOn = "[WindowsFeature]ADDSInstall"
        }

        WindowsFeature ADAdminCenter
        {
            Ensure = "Present"
            Name = "RSAT-AD-AdminCenter"
            DependsOn = "[WindowsFeature]ADDSInstall"
        }
         
        xADDomain FirstDS 
        {
            DomainName = $dscDomainName
            DomainAdministratorCredential = $dscDomainAdmin
            SafemodeAdministratorPassword = $dscSafeModePassword
            DomainNetBIOSName = $dscDomainNetbiosName
            DatabasePath = "F:\NTDS"
            LogPath = "F:\NTDS"
            SysvolPath = "F:\SYSVOL"
	        DependsOn = "[xDisk]ADDataDisk"
        } 
		
		xADUser FirstUser 
        { 
            DomainName = $dscDomainName 
            DomainAdministratorCredential = $dscDomainAdmin
            UserName = $dscDomainAdmin.Username 
            Password = $dscDomainAdmin
            Ensure = "Present" 
            DependsOn = "[xADDomain]FirstDS" 
        } 
		
		xADGroup FirstUserAddToAdmins
		{
			GroupName = "G_$RootOU"
			GroupScope = 'Global'
			Description = "Designated administrators of the domain"
			Category = 'Security'
			Members = $dscDomainAdmin.Username 
			Path = "OU=Users,$DomainRoot"
			Ensure = 'Present'
			DependsOn = "[xADUser]FirstUser" 
		}
    }      

    
    node AdditionalDC
    {

	    WindowsFeature DNS 
        { 
            Ensure = "Present" 
            Name = "DNS"		
        }

	    WindowsFeature DnsTools
	    {
	        Ensure = "Present"
            Name = "RSAT-DNS-Server"
            DependsOn = "[WindowsFeature]DNS"
	    }

        xWaitforDisk Disk2
        {
            DiskNumber = 2
            RetryIntervalSec = 20
            RetryCount = 30
			DependsOn = "[WindowsFeature]ADAdminCenter" 
        }

        xDisk ADDataDisk {
            DiskNumber = 2
            DriveLetter = "F"
            DependsOn = "[xWaitForDisk]Disk2"
        }

        WindowsFeature ADDSInstall 
        { 
            Ensure = "Present" 
            Name = "AD-Domain-Services"
	        DependsOn="[WindowsFeature]DNS" 
        } 

        WindowsFeature ADDSTools
        {
            Ensure = "Present"
            Name = "RSAT-ADDS-Tools"
            DependsOn = "[WindowsFeature]ADDSInstall"
        }

        WindowsFeature ADAdminCenter
        {
            Ensure = "Present"
            Name = "RSAT-AD-AdminCenter"
            DependsOn = "[WindowsFeature]ADDSInstall"
        }
		
        xDSCDomainjoin JoinDomain
		{
			Domain = $dscDomainName 
			Credential = $dscDomainAdmin
			DependsOn = "[xDisk]ADDataDisk"
		}
		
        xADDomainController SecondDC
        {
            DomainName = $dscDomainName
            DomainAdministratorCredential = $dscDomainAdmin
            SafemodeAdministratorPassword = $dscSafeModePassword
			DatabasePath = "F:\NTDS"
            LogPath = "F:\NTDS"
            SysvolPath = "F:\SYSVOL"
			DependsOn = "[xDSCDomainjoin]JoinDomain" 
        }
    }     

}