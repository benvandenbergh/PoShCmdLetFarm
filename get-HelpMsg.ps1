Function get-HelpMsg {
    [CmdletBinding()]
    param(
    [Parameter(Position=0, ParameterSetName="Value")]
    [ComponentModel.Win32Exception]$MessageID = 5
    )
    $MessageID | Select-Object *
}