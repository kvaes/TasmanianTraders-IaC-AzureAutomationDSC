#Requires -Version 3.0
#Requires -Module AzureRM.Resources

Param(
	[string] $dscAutomationAccount = "tasmaniantradersautomation",
	[string] $dscResourceGroup = "tt-automation"
)

$cfgPath = "$PSScriptRoot/../Configurations" 

Get-ChildItem -Path $cfgPath | Where-Object { $_.Name -notlike "*ConfigData*" } | Where-Object { $_.Name -like "*.ps1" } | ForEach-Object {
    Write-Information -MessageData "Processing $_.Name"
    $dscConfigFile = "../Configurations/$($_.Name)"
    $dscConfigDataFile = "../Configurations/$($_.BaseName)-ConfigData.ps1"
    . $PSScriptRoot"/importConfiguration.ps1" -dscConfigFile $dscConfigFile -dscDataConfigFile $dscConfigDataFile -dscAutomationAccount $dscAutomationAccount -dscResourceGroup $dscResourceGroup
}