$ConfigData = @{
    AllNodes = @(
        @{
            NodeName = "ADFS"
            PSDscAllowPlainTextPassword = $True
			PSDscAllowDomainUser = $True
        }
    )
}
