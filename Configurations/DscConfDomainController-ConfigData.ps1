$ConfigData = @{
    AllNodes = @(
        @{
            NodeName = "FirstDC"
            PSDscAllowPlainTextPassword = $True
			PSDscAllowDomainUser = $True
        },
        @{
            NodeName = "AdditionalDC"
            PSDscAllowPlainTextPassword = $True
			PSDscAllowDomainUser = $True
        }
    )
}
