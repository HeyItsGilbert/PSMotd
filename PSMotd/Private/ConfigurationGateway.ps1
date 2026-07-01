$script:MOTDConfigurationIdentity = @{
    Name        = 'PSMOTD'
    CompanyName = 'PSMOTD'
}
$script:MOTDConfigurationDefaultScope = 'User'
<#
.SYNOPSIS
Loads the layered PSMotd configuration from the owned configuration identity.
#>

function Import-MOTDConfiguration {
    [CmdletBinding()]
    Param()

    Import-Configuration @script:MOTDConfigurationIdentity
}

<#
.SYNOPSIS
Saves PSMotd configuration data through the owned configuration identity.
#>
function Save-MOTDConfig {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]
        $InputObject,

        [Parameter()]
        [ValidateSet('User', 'Enterprise', 'Machine')]
        [string]
        $Scope = $script:MOTDConfigurationDefaultScope
    )

    process {
        $InputObject | Export-Configuration -Scope $Scope @script:MOTDConfigurationIdentity
    }
}
