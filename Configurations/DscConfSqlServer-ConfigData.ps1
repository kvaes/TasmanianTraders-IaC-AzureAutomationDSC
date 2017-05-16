$ConfigData = @{
    AllNodes = @(
        @{
            NodeName = "Standalone"
            PSDscAllowPlainTextPassword = $True
			PSDscAllowDomainUser = $True
        }
    )
}
