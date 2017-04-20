
#Requires -Version 3.0
#Requires -Module AzureRM.Resources

Param(
    [string] $dscRegisterFilter,
    [string] $dscDataConfigFile,
    [string] $dscRegisterResourceGroupVirtualMachine,
    [string] $dscRegisterConfigName,
	[string] $dscRegisterResourceGroupAutomationAccount = "tasmaniantradersautomation",
	[string] $dscRegisterAutomationAccountName = "tt-automation"
)

Function Add-AllNodesFromResourcegroupViaFilter ($dscRegisterFilter, $dscRegisterResourceGroupAutomationAccount, $dscRegisterAutomationAccountName, $dscRegisterResourceGroupVirtualMachine, $dscRegisterConfigName)
{   
	Write-Information -MessageData  "Registering Windows virtual machines with filter $dscRegisterFilter in order to apply config $dscRegisterConfigName" 
	Get-AzureRMVM -ResourceGroupName $dscRegisterResourceGroupVirtualMachine | Where-Object { $_.Name -like $dscRegisterFilter } | ForEach-Object { 
		$dscVMName = $_.Name
		$dscVM = Get-AzureRmAutomationDscNode -ResourceGroupName $dscRegisterResourceGroupAutomationAccount -AutomationAccountName $dscRegisterAutomationAccountName -Name $_.Name -ErrorAction SilentlyContinue
		if (!$dscVM) {
			Write-Information -MessageData  "Registering $dscVMName" 
			Register-AzureRmAutomationDscNode -AutomationAccountName $dscRegisterAutomationAccountName -ResourceGroupName $dscRegisterResourceGroupAutomationAccount -AzureVMName $_.Name -AzureVMResourceGroup $_.ResourceGroupName -AzureVMLocation $_.Location -NodeConfigurationName $dscRegisterConfigName -RebootNodeIfNeeded $true
		} else {
			Write-Information -MessageData  "Skipping $dscVMName, as it is already registered" 
		}
	}
}

Add-AllNodesFromResourcegroupViaFilter $dscRegisterFilter $dscRegisterResourceGroupAutomationAccount $dscRegisterAutomationAccountName $dscRegisterResourceGroupVirtualMachine $dscRegisterConfigName