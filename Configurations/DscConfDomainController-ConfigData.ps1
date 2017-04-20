$ConfigData = @{
    AllNodes = @(
        @{
            NodeName = "DomainController"
            PSDscAllowPlainTextPassword = $True
			PSDscAllowDomainUser = $True
        }
    )
}
