Configuration DscConfSqlServer
{
    Import-DscResource -ModuleName xActiveDirectory, xStorage, PSDesiredStateConfiguration, xDSCDomainjoin, xComputerManagement, xSQLServer, xSQLps, xNetworking
    $dscDomainAdmin = Get-AutomationPSCredential -Name 'addcDomainAdmin'
	$dscDomainName = Get-AutomationVariable -Name 'addcDomainName'
    $dscDomainNetbiosName = Get-AutomationVariable -Name 'addcDomainNetbiosName'
	$dscSafeModePassword = $dscDomainAdmin
	$DomainRoot = "DC=$($dscDomainAdmin -replace '\.',',DC=')"
	$dscDomainJoinAdminUsername = $dscDomainAdmin.UserName
	$dscDomainJoinAdmin = new-object -typename System.Management.Automation.PSCredential -argumentlist "$dscDomainName\$dscDomainJoinAdminUsername", $dscDomainAdmin.Password
	
	$DatabaseEnginePort1 = 1433
	$dscSqlService = Get-AutomationPSCredential -Name 'sqlService'
	
    node Standalone
    {

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
		
		xWaitForADDomain DscForestWait 
        { 
            DomainName = $dscDomainName
            DomainUserCredential = $dscDomainAdmin
            RetryCount = 15
            RetryIntervalSec = 60
			DependsOn = "[xDisk]ADDataDisk"			
        }

        xDSCDomainjoin JoinDomain
		{
			Domain = $dscDomainName 
			Credential = $dscDomainJoinAdmin
			DependsOn = "[xWaitForADDomain]DscForestWait"
        }

        xFirewall DatabaseEngineFirewallRule1
        {
            Direction = "Inbound"
            Name = "SQL-Server-Database-Engine-TCP-In-1"
            DisplayName = "SQL Server Database Engine (TCP-In)"
            Description = "Inbound rule for SQL Server to allow TCP traffic for the Database Engine."
            Group = "SQL Server"
            Enabled = "True"
            Protocol = "TCP"
            LocalPort = $DatabaseEnginePort1
            Ensure = "Present"
        }

        xSqlLogin AddDomainAdminAccountToSysadminServerRole
        {
            Name = $dscDomainAdmin.UserName
            LoginType = "WindowsUser"
            ServerRoles = "sysadmin"
            Enabled = $true
            Credential = $dscDomainAdmin
			DependsOn = "[xDSCDomainjoin]JoinDomain"
        }

        xADUser CreateSqlServerServiceAccount
        {
            DomainAdministratorCredential = $dscDomainAdmin
            DomainName = $dscDomainName
            UserName = $sqlService.UserName
            Password = $sqlService
            Ensure = "Present"
            DependsOn = "[xSqlLogin]AddDomainAdminAccountToSysadminServerRole"
        }

        xSqlLogin AddSqlServerServiceAccountToSysadminServerRole
        {
            Name = $sqlService.UserName
            LoginType = "WindowsUser"
            ServerRoles = "sysadmin"
            Enabled = $true
            Credential = $dscDomainAdmin
            DependsOn = "[xADUser]CreateSqlServerServiceAccount"
        }

        xSqlServer ConfigureSqlServerWithAlwaysOn
        {
            InstanceName = $env:COMPUTERNAME
            SqlAdministratorCredential = $dscDomainAdmin
            ServiceCredential = $sqlService
            MaxDegreeOfParallelism = 1
            FilePath = "F:\DATA"
            LogPath = "F:\LOG"
            DomainAdministratorCredential = $dscDomainJoinAdmin
            DependsOn = "[xSqlLogin]AddSqlServerServiceAccountToSysadminServerRole"
        }

    }     

}