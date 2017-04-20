#Requires -Version 3.0
#Requires -Module AzureRM.Resources

Param(
    [string] $dscConfigFile,
    [string] $dscDataConfigFile,
	[string] $dscAutomationAccount = "tasmaniantradersautomation",
	[string] $dscResourceGroup = "tt-automation"
)

Function Import-DscConfiguration ($dscConfigFile, $dscDataConfigFile, $dscAutomationAccount, $dscResourceGroup) {

	$dscConfigFileFull = (Get-Item $dscConfigFile).FullName
	$dscDataConfigFileFull = (Get-Item $dscDataConfigFile).FullName
	$dscConfigFileName = [io.path]::GetFileNameWithoutExtension($dscConfigFile)
	$dscDataConfigFileName = [io.path]::GetFileNameWithoutExtension($dscDataConfigFile)
	$dsc = Get-AzureRmAutomationDscConfiguration -ResourceGroupName $dscResourceGroup -AutomationAccountName $dscAutomationAccount -Name $dscConfigFileName -erroraction 'silentlycontinue'
	if ($dsc) { 
		Write-Information -MessageData  "Configuration $dscConfigFileName Already Exists"
	} else {
		Write-Information -MessageData  "Importing & compiling configuration $dscConfigFileName with config data $dscDataConfigFileName"
		Import-AzureRmAutomationDscConfiguration -AutomationAccountName $dscAutomationAccount -ResourceGroupName $dscResourceGroup -Published -SourcePath $dscConfigFileFull
        $dscDataConfigFileFullContent = (Get-Content $dscDataConfigFileFull | Out-String)
        Invoke-Expression $dscDataConfigFileFullContent
		$CompilationJob = Start-AzureRmAutomationDscCompilationJob -ResourceGroupName $dscResourceGroup -AutomationAccountName $dscAutomationAccount -ConfigurationName $dscConfigFileName -ConfigurationData $ConfigData
		while($null -eq $CompilationJob.EndTime -and $null -eq $CompilationJob.Exception)           
		{
			$CompilationJob = $CompilationJob | Get-AzureRmAutomationDscCompilationJob
			Start-Sleep -Seconds 3
			Write-Information -MessageData "."
		}
		Write-Information -MessageData  "!"
		$CompilationJob | Get-AzureRmAutomationDscCompilationJobOutput
	}
}

Import-DscConfiguration $dscConfigFile $dscDataConfigFile $dscAutomationAccount $dscResourceGroup