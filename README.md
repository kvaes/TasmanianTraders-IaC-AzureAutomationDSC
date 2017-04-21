# Automation Foundation for deploying DSC configs to Azure VMs

This repository contains the code that can be used to deploy DSC configurations to Azure VMs via Azure Automation.

There are several subdirectories ;
* Automation Account ; This is an ARM template to deploy an Automation Account. It includes a credential & variable example.
* Configurations ; This contains the DSC configurations and their companion config data.
* Modules ; This contains all the modules needed for the configurations. 
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

  # Integration Examples

  An example towards provisioning Active Directory domain controllers can be found [here](https://github.com/kvaes/TasmanianTraders-IaC-ActiveDirectory). That repository contains an ARM template to deploy a domain controller, which will connect back to an Azure Automation Account looking for a given DSC configuration. Depending on what type of DC you select, it will link the right DSC configuration as provisioned by this repository.
