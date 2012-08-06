Param(
	[Parameter(Mandatory=$true)]
	[Alias("t")]	
	[string] $TemplateFile
	,
	[Parameter(Mandatory=$true)]
	[Alias("e")]
	[string] 
	$EnvironmentConfigurationFile
	,
	[Parameter(Mandatory=$true)]
	[Alias("o")]
	[string]  
	$OutputFile	
)

$ScriptDirectory = Split-Path $MyInvocation.MyCommand.Path
. (Join-Path $ScriptDirectory "ReplaceXmlSection.ps1")

ReplaceWebConfigSections $TemplateFile $EnvironmentConfigurationFile $OutputFile	