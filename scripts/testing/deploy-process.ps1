Param (
	[string]
	$Environment = "stg1"
)

#$iis_root_path = "C:\Inetpub\wwwroot"
$iis_root_path = "C:\target"
$scripts_path  = "C:\svn\sysadmin\trunk\scripts\web-deployment"
$final_config_path  = "C:\svn\sysadmin\trunk\scripts\web-deployment\finalConfigurations"

$generate_conf_script = "generate-config-files.ps1"
$deploy_script        = "deploy.ps1"

$app_dest_path = @{
	"searcher"  = "$iis_root_path\bw\Search";
	"searchapi" = "$iis_root_path\bw\Search Api";
	"vantageapi" = "$iis_root_path\VantageApi"
}

$app_svn_path = @{
	"searcher"  = "C:\svn\bw_in_velocity\Search\_PublishedWebsites\App.Web";
	"searchapi" = "C:\svn\bw_in_velocity\Search Api"
}

##
# UPDATE FROM SVN
Copy-Item -Container -Force $app_svn_path["searcher"] -Destination $app_dest_path["searcher"] -Recurse
Copy-Item -Container -Force $app_svn_path["searchapi"] -Destination $app_dest_path["searchapi"] -Recurse

##
# APPLY SPECIFIC CONFIGURATION FILES
. (Join-Path $scripts_path $generate_conf_script) -Environment $Environment
Copy-Item -Container -Force "$final_config_path\$Environment\*" -Destination $iis_root_path -Recurse

##
# GENERATING PACKAGE FILE
#. (Join-Path $scripts_path $deploy_script) -Action Create

##
# DEPLOY PACKAGE
. (Join-Path $scripts_path $deploy_script) -e $Environment -a search
. (Join-Path $scripts_path $deploy_script) -e $Environment -a searchapi

