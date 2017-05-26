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
	
	$dscSqlService = Get-AutomationPSCredential -Name 'sqlService'
	$sqlInstancePort = 65000
	$sqlInstanceDir = "D:\MSSQL\Inst"
	$sqlDataDir = "F:\MSSQL\Dat"
	$sqlLogDir = "F:\MSSQL\Log"
	$sqlTempDir = "F:\MSSQL\Tmp"
	$sqlBackupDir = "F:\MSSQL\Bck"
	$sqlInstanceFeatures = "SQLENGINE,FULLTEXT,RS,AS,IS"
	$sqlInstanceName = "MyInstance"
	$sqlSourcePath = "C:\SQLServer_13.0_Full"
	$sqlAdminAccount = "$dscDomainName\$dscDomainJoinAdminUsername"
	
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

		<#
        xFirewall DatabaseEngineFirewallRule1
        {
            Direction = "Inbound"
            Name = "SQL-Server-Database-Engine-TCP-In-1"
            DisplayName = "SQL Server Database Engine (TCP-In)"
            Description = "Inbound rule for SQL Server to allow TCP traffic for the Database Engine."
            Group = "SQL Server"
            Enabled = "True"
            Protocol = "TCP"
            LocalPort = $sqlInstancePort
            Ensure = "Present"
        }
		#>
		
		WindowsFeature ADDSTools
        {
            Ensure = "Present"
            Name = "RSAT-ADDS-Tools"
            DependsOn = "[xDSCDomainjoin]JoinDomain"
        }

		<#
        xADUser CreateSqlServerServiceAccount
        {
            DomainAdministratorCredential = $dscDomainAdmin
            DomainName = $dscDomainName
            UserName = $dscSqlService.UserName
            Password = $dscSqlService
            Ensure = "Present"
            DependsOn = "[WindowsFeature]ADDSTools"
        }
		#>
		
		WindowsFeature "NET-Framework-Core"
		{
			Ensure = "Present"
			Name = "NET-Framework-Core"
			DependsOn = "[WindowsFeature]ADDSTools"			
        }
		
		xSqlServerSetup SQLserverSetup
		{
			DependsOn = "[WindowsFeature]NET-Framework-Core"
			SourcePath = $sqlSourcePath
			SetupCredential = $dscDomainAdmin
			InstanceName = $sqlInstanceName
			Features = $sqlInstanceFeatures
			SQLSysAdminAccounts = $sqlAdminAccount
			InstallSharedDir = "C:\Program Files\Microsoft SQL Server"
			InstallSharedWOWDir = "C:\Program Files (x86)\Microsoft SQL Server"
			InstanceDir = "$sqlInstanceDir"
			InstallSQLDataDir = "$sqlDataDir"
			SQLUserDBDir = "$sqlDataDir"
			SQLUserDBLogDir = "$sqlLogDir"
			SQLTempDBDir = "$sqlTempDir"
			SQLTempDBLogDir = "$sqlTempDir"
			SQLBackupDir = "$sqlBackupDir"
			ASDataDir = "F:\Program Files\Microsoft SQL Server\MSAS11.MSSQLSERVER\OLAP\Data"
			ASLogDir = "F:\Program Files\Microsoft SQL Server\MSAS11.MSSQLSERVER\OLAP\Log"
			ASBackupDir = "F:\Program Files\Microsoft SQL Server\MSAS11.MSSQLSERVER\OLAP\Backup"
			ASTempDir = "F:\Program Files\Microsoft SQL Server\MSAS11.MSSQLSERVER\OLAP\Temp"
			ASConfigDir = "F:\Program Files\Microsoft SQL Server\MSAS11.MSSQLSERVER\OLAP\Config"
		}

		xSqlServerFirewall SQLserverFirewall
		{
			DependsOn = "[xSqlServerSetup]SQLserverSetup"
			SourcePath = $sqlSourcePath
			InstanceName = $sqlInstanceName
			Features = $sqlInstanceFeatures
		}
    }     

}