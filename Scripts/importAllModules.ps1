#Requires -Version 3.0
#Requires -Module AzureRM.Resources

Param(
	[string] $moduleAutomationAccount = "tasmaniantradersautomation",
	[string] $moduleResourceGroup = "tt-automation",
	[bool] $Force = $false
)

$cfgPath = "$PSScriptRoot/../Modules" 

Get-ChildItem -Path $cfgPath | Where-Object { $_.Name -like "*Modules*" } | Where-Object { $_.Name -like "*.ps1" } | ForEach-Object {
    Write-Information -MessageData "Processing $_.Name"
    $moduleConfigFile = "../Modules/$($_.Name)"
    $moduleConfigFileFullContent = (Get-Content $moduleConfigFile | Out-String)
    Invoke-Expression $moduleConfigFileFullContent
    foreach ($module in $modules.GetEnumerator()) {
        . $PSScriptRoot"/importModule.ps1" -moduleName $($module.Name) -moduleVersion $($module.Value) -moduleAutomationAccount $moduleAutomationAccount -moduleResourceGroup $moduleResourceGroup -Force $Force
    }
}