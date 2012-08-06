Param(
	[Parameter(Mandatory=$true)]
	[Alias("e")]	
	[string] $Environment
)

$root_dir = Split-Path $MyInvocation.MyCommand.Path

$EnvConfFolder = "{0}\specificConfig\{1}" -F $root_dir, $Environment
$TemplateFolder = "{0}\configurationTemplates\{1}" -F $root_dir, $Environment
$OutputFolder = "{0}\finalConfigurations\{1}" -F $root_dir, $Environment

$ConfBotsFolder = "{0}\configurationBots" -F $root_dir
$NhConfBot = "{0}\NHConfBot\apply.ps1" -F $ConfBotsFolder
$XmlConfBot = "{0}\XmlSectionBot\apply.ps1" -F $ConfBotsFolder

$SearchTemplateFolder = "{0}\{1}" -F $TemplateFolder , "Search"
$SearchApiTemplateFolder = "{0}\{1}" -F $TemplateFolder , "SearchApi"

$SearchEnvConfFolder = "{0}\{1}" -F $EnvConfFolder , "Search"
$SearchApiEnvConfFolder = "{0}\{1}" -F $EnvConfFolder , "SearchApi"

#$SearchOutputFolder = "{0}\{1}" -F $OutputFolder , "Search"
#$SearchApiOutputFolder = "{0}\{1}" -F $OutputFolder , "Search Api"
$SearchOutputFolder = "{0}\{1}" -F $OutputFolder , "search"
$SearchApiOutputFolder = "{0}\{1}" -F $OutputFolder , "searchapi"

Write-Verbose $EnvConfFolder
Write-Verbose $TemplateFolder
Write-Verbose $OutputFolder
Write-Verbose $SearchTemplateFolder
Write-Verbose $SearchApiTemplateFolder
Write-Verbose $SearchEnvConfFolder
Write-Verbose $SearchApiEnvConfFolder

#Search nhibernate configuration

$template_file = "{0}\hibernate.cfg.xml" -F $SearchTemplateFolder
$config_file = "{0}\nhibernate.config" -F $SearchEnvConfFolder
$output_file = "{0}\hibernate.cfg.xml" -F $SearchOutputFolder

$command = "{0} –t {1} -e {2} -o `"{3}`"" -F $NhConfBot, $template_file, $config_file, $output_file
 
Invoke-Expression $command 

#SearchApi nhibernate configuration

$template_file = "{0}\hibernate.cfg.xml" -F $SearchApiTemplateFolder
$config_file = "{0}\nhibernate.config" -F $SearchApiEnvConfFolder
$output_file = "{0}\hibernate.cfg.xml" -F $SearchApiOutputFolder

$command = "{0} –t {1} -e {2} -o `"{3}`"" -F $NhConfBot, $template_file, $config_file, $output_file
 
Invoke-Expression $command 

#Search configuration configuration

$template_file = "{0}\web.config" -F $SearchTemplateFolder
$config_file = "{0}\sectionMap.xml" -F $SearchEnvConfFolder
$output_file = "{0}\web.config" -F $SearchOutputFolder

$command = "{0} –t {1} -e {2} -o `"{3}`"" -F $XmlConfBot, $template_file, $config_file, $output_file
 
Invoke-Expression $command 

#SearchApi configuration configuration

$template_file = "{0}\web.config" -F $SearchApiTemplateFolder
$config_file = "{0}\sectionMap.xml" -F $SearchApiEnvConfFolder
$output_file = "{0}\web.config" -F $SearchApiOutputFolder

$command = "{0} –t {1} -e {2} -o `"{3}`"" -F $XmlConfBot, $template_file, $config_file, $output_file
 
Invoke-Expression $command 

Write-Verbose "Done."
