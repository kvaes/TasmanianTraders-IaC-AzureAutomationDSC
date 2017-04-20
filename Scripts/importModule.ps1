#Requires -Version 3.0
#Requires -Module AzureRM.Resources

Param(
	[Parameter(Mandatory=$true)]
    [string] $moduleName,
	[Parameter(Mandatory=$true)]
    [string] $moduleVersion,
	[string] $moduleAutomationAccountName = "tasmaniantradersautomation",
	[string] $moduleResourceGroup = "tt-automation",
	[bool] $Force = $false
)

Function Import-DscModule ($moduleName, $moduleVersion, $moduleAutomationAccountName, $moduleResourceGroup)
{
	$module1 = Get-AzureRmAutomationModule -AutomationAccountName $moduleAutomationAccountName -ResourceGroupName $moduleResourceGroup -Name $moduleName  -erroraction 'silentlycontinue'
	if (!$module1) { 
		Write-Information -MessageData  "Importing $moduleName module with version $moduleVersion into the Automation Account $moduleAutomationAccountName" 
		Set-StrictMode -off

        $ModuleContentUrl = "https://www.powershellgallery.com/api/v2/package/$moduleName/$moduleVersion"

        do {
            $ActualUrl = $ModuleContentUrl
            $ModuleContentUrl = (Invoke-WebRequest -UseBasicParsing -Uri $ModuleContentUrl -MaximumRedirection 0 -ErrorAction Ignore).Headers.Location 
        } while($ModuleContentUrl -ne $Null)

        New-AzureRmAutomationModule `
            -ResourceGroupName $moduleResourceGroup `
            -AutomationAccountName $moduleAutomationAccountName `
            -Name $moduleName `
            -ContentLink $ActualUrl

		$importDone = ""
		while(!$importDone)           
		{
			$importDone = Get-AzureRmAutomationModule -ResourceGroupName $moduleResourceGroup -AutomationAccountName $moduleAutomationAccountName -Name $moduleName -ErrorAction SilentlyContinue| Where-Object {$_.ProvisioningState -eq 'Succeeded'}
			Start-Sleep -Seconds 3
			Write-Information -MessageData "."
		}
		Write-Information -MessageData  "!"
	}
}

Import-DscModule  $moduleName $moduleVersion $moduleAutomationAccountName $moduleResourceGroup