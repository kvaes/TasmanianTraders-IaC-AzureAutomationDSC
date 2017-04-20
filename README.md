# Automation Foundation for deploying DSC configs to Azure VMs

This repository contains the code that can be used to deploy DSC configurations to Azure VMs via Azure Automation.

There are several subdirectories ;
* Automation Account ; This is an ARM template to deploy an Automation Account. It includes a credential & variable example.
* Configurations ; This contains the DSC configurations and their companion config data.
* Scripts ; Here you can find the scripts you can use to deploy.
  * importModule ; This will import a DSC module from the powershell gallery and into your automation account
  * importAllModules ; This will import all the modules presented inthe "Modules" directory (filtered on the pattern "Modules" in the file name)
  * importConfiguration ; This will import a configuration & compile it
  * importAllConfiguration ; This will import all the configurations present in the "Configurations" directory

# Scripts Examples

* importModule
  * importModule.ps1 -moduleName xActiveDirectory -moduleVersion "2.13.0"
  * importModule.ps1 -moduleName xDSCDomainjoin -moduleVersion "1.1"
* importAllModules
  * importAllModules.ps1 
  * importAllModules.ps1 -moduleAutomationAccount MyAutomationAccount -moduleResourceGroup RG-AutomationAccount
* importConfiguration
  * importConfiguration.ps1 -dscConfigFile ..\Configurations\DscConfDomainController.ps1 -dscDataConfigFile ..\Configurations\DscConfDomainController-ConfigData.ps1
  * importConfiguration.ps1 -dscConfigFile ..\Configurations\DscConfDomainController.ps1 -dscDataConfigFile ..\Configurations\DscConfDomainController-ConfigData.ps1 -dscAutomationAccount MyAutomationAccount -dscResourceGroup RG-AutomationAccount
  * importConfiguration.ps1 -dscConfigFile ..\Configurations\DscConfDomainController.ps1 -dscDataConfigFile ..\Configurations\DscConfDomainController-ConfigData.ps1 -Force $true
* importAllConfigurations
  * importAllConfigurations.ps1 
  * importAllConfigurations.ps1 -dscAutomationAccount MyAutomationAccount -dscResourceGroup RG-AutomationAccount
  * importAllConfigurations.ps1 -Force $true
