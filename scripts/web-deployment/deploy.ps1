Param(
	[Parameter(Mandatory=$true)]
	[Alias("e")]
	[string] 
	$Environment
	,
	[Parameter(Mandatory=$true)]
	[ValidateSet("search","searchapi","vantageapi","dummy")]
	[string] 
	$App
	,
	[Parameter(Mandatory=$false)]
	[Alias("w")]
	[array]  
	$Webservers
	,
	[array]  
	$Websites = @()
	,
	[string] 
	$PackageFileName
	,
	[Alias("u")][switch]$UpdateFromSvn
	,
	[switch]$Backup
	,
	[switch]$Restore
	,
	[switch]$WhatIf
)
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.Web.Deployment")

Function Try { 
    Param ( 
        [ScriptBlock]$Command = $(throw "The Parameter -Command is required."), 
        [ScriptBlock]$Catch   = { throw $_ }, 
        [ScriptBlock]$Finally = {} 
    ) 
    & { 
        $local:ErrorActionPreference = "SilentlyContinue" 
        trap { 
            trap { 
                & { 
                    trap { throw $_ } 
                    &$Finally 
                } 
                throw $_ 
            } 
            $_ | & { &$Catch } 
        } 
        &$Command 
    } 
    & { 
        trap { throw $_ } 
        &$Finally 
    } 
}

Function NoNameYet {
	Param($path, $server, $action)
	
	$destBaseOptions   = New-Object Microsoft.Web.Deployment.DeploymentBaseOptions
	$sourceBaseOptions = New-Object Microsoft.Web.Deployment.DeploymentBaseOptions
	$syncOptions       = New-Object Microsoft.Web.Deployment.DeploymentSyncOptions

	$syncOptions.WhatIf = $WhatIf

	if ($action -eq "Backup") {
		$sourceProvider = "AppHostConfig"
		$sourcePath = $path
		$sourceBaseOptions.ComputerName = $server

		$destProvider = "Package"
		$destPath = "FILENAME"
	} else {
		$sourceProvider = "Package"
		$sourcePath = "FILENAME"
		
		$destProvider   = "AppHostConfig"
		$destPath = $path
		$destBaseOptions.ComputerName = $server
	}

	$deploymentObject = [Microsoft.Web.Deployment.DeploymentManager]::CreateObject($sourceProvider, $sourcePath, $sourceBaseOptions)
	$deploymentObject.SyncTo($destProvider, $destPath, $destBaseOptions, $syncOptions)
}

Function BackupFrom-ServerPath {
	Param($path, $source)

	NoNameYet $path $source "Backup"
}

Function RestoreTo-ServerPath {
	Param($path, $dest)

	NoNameYet $path $dest "Restore"
}

Function ConvertTo-PlainText {
	Param([security.securestring]$secure)

   $marshal = [Runtime.InteropServices.Marshal] 
   $marshal::PtrToStringAuto( $marshal::SecureStringToBSTR($secure) ) 
}

Function Sync-ServerPath {
	Param($provider, $path, $source, $dest)

<#
	Try {
		$sourceMachine = Import-Csv $Env:SystemDrive\$rootDir\$source.txt
		$destMachine = Import-Csv $Env:SystemDrive\$rootDir\$dest.txt
	} Catch {
		echo "EXCEPTION THROWN::[ $_ ] "
	}
#>

	$destBaseOptions   = New-Object Microsoft.Web.Deployment.DeploymentBaseOptions
	$sourceBaseOptions = New-Object Microsoft.Web.Deployment.DeploymentBaseOptions
	$syncOptions       = New-Object Microsoft.Web.Deployment.DeploymentSyncOptions
	
	$destBaseOptions.ComputerName = $dest
	$sourceBaseOptions.ComputerName = $source

<#
	$sourceBaseOptions.ComputerName = $sourceMachine.ComputerName
	$sourceBaseOptions.UserName = $sourceMachine.UserName
	$password = ConvertTo-SecureString $sourceMachine.Password
	$password = ConvertTo-PlainText $password
	$sourceBaseOptions.Password = $password

	$destBaseOptions.ComputerName = $destMachine.ComputerName
	$destBaseOptions.UserName = $destMachine.UserName
	$password = ConvertTo-SecureString $destMachine.Password
	$password = ConvertTo-PlainText $password
	$destBaseOptions.Password = $password
#>	
	
	$syncOptions.WhatIf = $WhatIf
	
	Try
	{
		$deploymentObject = [Microsoft.Web.Deployment.DeploymentManager]::CreateObject($provider, $path, $sourceBaseOptions)
		#$deploymentObject.SyncParameters.Load("StagingParameters.xml")

		$deploymentObject.SyncTo($provider, $path, $destBaseOptions, $syncOptions)
	}
	Catch
	{
		Write-Host "EXCEPTION THROWN::[ $_ ] " -Foreground Red
	}
}

Function GetPort {
	Param([string]$dc, [string]$ws, [string]$app, [string]$website)

	return (GetWebsites $dc $ws $app).Get_Item($website)
}

Function GetWebsites {
	Param([string]$dc, [string]$ws, [string]$app)
	
	return (GetApps $dc $ws).Get_Item($app)
}

Function GetApps {
	Param([string]$dc, [string]$ws)
	
	return (GetWebservers $dc).Get_Item($ws)
}

Function GetWebservers {
	Param([string] $dc)

	$environment = $global:environments.Get_Item($dc)

	return $environment.Webservers
}

Function GetListedWebservers {
	Param([string] $dc)
	
	if ($Webservers -ne $null) {
		$s = @{}
		$w = GetWebservers $dc
		$Webservers | ForEach-Object {
			if ($w.ContainsKey($_) -And !$s.ContainsKey($_)) {
				$s.Add($_, (GetApps $dc $_))
			}
		}
		return $s
	} else {
		return GetWebservers $dc
	}
}

Function GetEnvironment {
	Param([string] $dc)

	return $global:environments.Get_Item($dc)
}

Function GetEnvironments {
	Param($path = $(throw "You must specify a config file"))

	$config = [xml](get-content $path)
	$environments = @{}
	
	$config.configuration.appsettings.environments.environment | ForEach-Object {
		$webservers = @{}
		$_.webserver | ForEach-Object {
			$apps = @{}
			$_.app | ForEach-Object {
				$websites = @{}
				$_.website | ForEach-Object {
					$websites.Add($_.name, $_.port)
				}
				$apps.Add($_.name, $websites)
			}
			$webservers.Add($_.name, $apps)
		}
		$environment = "" | Select-Object Name, Preffix, Suffix, Webservers
		$environment.Name       = $_.name
		$environment.Preffix    = $_.preffix
		$environment.Suffix     = $_.suffix
		$environment.Webservers = $webservers
		
		$environments.Add($_.name, $environment)
	}
	
	return $environments;
}

Function GetConfig {
	Param($path = $(throw "You must specify a config file"))
	
	$config = [xml](Get-Content $path)

	$vars = @{}
	$config.configuration.appsettings.configurationvars.add | ForEach-Object {
		$vars.Add($_.name, $_.value)
	}

	$webapps = @{}
	$config.configuration.appsettings.configurationvars.webapps.add | ForEach-Object {
		$webapp = "" | Select-Object Name, Svn_Path, Dest_Path, Specific_Conf
		$webapp.Name = $_.name
		$webapp.Svn_Path = $_.svn_path
		$webapp.Dest_Path = $_.dest_path
		$webapp.Specific_Conf = $_.specific_conf -eq "true"
		
		$webapps.Add($_.name, $webapp)
	}
	$vars.Add("webapps", $webapps)
	
	return $vars
}

Function TestFunctions {
	GetWebservers "haf1"
	GetApps "haf1" "cpweb-a01-haf1"
	GetWebsites "haf1" "cpweb-a01-haf1" "searchapi"
	GetPort "haf1" "cpweb-a01-haf1" "searchapi" "searchapi2"

	$a = GetWebsites "haf1" "cpweb-a01-haf1" "searchapi"
	foreach ($website in $a.GetEnumerator()) {
		"{0} = {1}" -f $website.Key, $website.Value
	}

	$global:environments.Get_Item("stg1").Get_Item("cpweb-a01-stg1").Get_Item("search").Get_Item("search3")
	GetPort "stg1" "cpweb-a01-stg1" "search" "search3"
}

Function GetFirstWebsiteOnly {
	if ($Websites -eq $null) {
		$ws = GetWebsites $Environment $Webservers[0] $App
		
		return ($ws.GetEnumerator() | Sort-Object Name)[0].Key
	}
	
	return $Websites[0]
}

Function GetAllWebsites {
	Param([string]$ws)
	
	if ($Websites -eq $null) {
		$w = GetWebsites $Environment $ws $App
		
		$a = @()
		($w.GetEnumerator() | Sort-Object Name) | %{ $a += $_.Key }
		return $a
		#return ($w.GetEnumerator() | Sort-Object Name)
	}
	
	return $Websites
}

Function FormatHostname {
	Param($preffix, $hostname, $suffix)
	
	return "{0}{1}{2}" -f $preffix, $hostname, $suffix
}

Function UpdateFromSvn {
	$generate_conf_script = "generate-config-files.ps1"

	$src      = Join-Path $global:conf["svn_path"] $global:conf["webapps"][$App].Svn_Path
	$dst      = Join-Path $global:conf["iis_root_path"] $global:conf["webapps"][$App].Dest_Path
	$src_conf = Join-Path $global:conf["final_config_path"] (Join-Path $Environment (Join-Path $App *))

	##
	# UPDATE FROM SVN
	Copy-Item -Container -Force $src -Destination $dst -Recurse

	if ($global:conf["webapps"][$App].Specific_Conf) {
		##
		# APPLY SPECIFIC CONFIGURATION FILES
		. (Join-Path $root_dir $generate_conf_script) -Environment $Environment
		Copy-Item -Container -Force $src_conf -Destination $dst -Recurse -Verbose
	}

}

Function DoDeploy {
	Param( $AdminServer )

	$e = GetEnvironment $Environment
	
	(GetListedWebservers $Environment).GetEnumerator() | Sort-Object Name | ForEach-Object {
		$webserver = FormatHostname $e.Preffix $_.Key $e.Suffix
		Write-Host ([String]::Format("Deploying {0}:", $webserver)) -Foreground Yellow
		(GetWebsites $Environment $_.Key $App).GetEnumerator() | Sort-Object Name | ForEach-Object {
			Write-Host ([String]::Format("`t Sync-ServerPath {0} {1} {2} {3}", "AppHostConfig", $_.Key, $AdminServer, $webserver))
			Sync-ServerPath "AppHostConfig" $_.Key $AdminServer $webserver 
		}
	}
}

$root_dir  = Split-Path $MyInvocation.MyCommand.Path
$conf_file = Join-Path  $root_dir deploy.config

$global:conf         = GetConfig $conf_file
$global:environments = GetEnvironments $conf_file

if (!$global:environments.ContainsKey($Environment)) {
	Throw "'{0}' does not have any configuration for that environment!" -F $conf_file
}

if (!$global:conf["webapps"].ContainsKey($App)) {
	Throw "'{0}' does not have any configuration for that web application!" -F $Environment
}

if ($UpdateFromSvn) {
	UpdateFromSvn
} else {
	#DoDeploy $global:conf["admin_server"]

	# TESTING
	#Sync-ServerPath $provider $path $source $dest
}

