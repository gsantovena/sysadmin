## vm-deploy.ps1
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.Web.Deployment")

$rootDir = "test"

Function Try 
{ 
    param 
    ( 
        [ScriptBlock]$Command = $(throw "The parameter -Command is required."), 
        [ScriptBlock]$Catch   = { throw $_ }, 
        [ScriptBlock]$Finally = {} 
    ) 
    & { 
        $local:ErrorActionPreference = "SilentlyContinue" 
        trap 
        { 
            trap 
            { 
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

Function Create-Server()
{
	Try
	{
		$machine = "" | select ComputerName, UserName, Password
		$machine.ComputerName = Read-Host -prompt "Machine name"
		$fileName = $machine.ComputerName
		$machine.UserName = Read-Host -prompt "User name"
		$machine.Password = Read-Host -prompt Password -AsSecureString | ConvertFrom-SecureString
		$machine | Export-Csv $Env:SystemDrive\$rootDir\$fileName.txt
	}
	Catch
	{
		echo "EXCEPTION THROWN::[ $_ ] "
	}
}

Function ConvertTo-PlainText( [Security.SecureString] $secure )
{
	$marshal = [Runtime.InteropServices.Marshal]
	$marshal::PtrToStringAuto( $marshal::SecureStringToBSTR($secure) )
}

Function Sync-Provider($provider, $sourceLocation, $destLocation) 
{ 
	$destBaseOptions   = new-object Microsoft.Web.Deployment.DeploymentBaseOptions 
	$syncOptions       = new-object Microsoft.Web.Deployment.DeploymentSyncOptions 
	Try
	{
		$deploymentObject = [Microsoft.Web.Deployment.DeploymentManager]::CreateObject($provider, $sourceLocation) 
		$deploymentObject.SyncTo($provider, $destLocation, $destBaseOptions, $syncOptions)
	}
	Catch
	{
		echo "EXCEPTION THROWN::[ $_ ] "
		#throw $_
	}
} 

Function Sync-Server($provider, $source, $dest)
{
	Try
	{
		$sourceMachine = Import-Csv $Env:SystemDrive\$rootDir\$source.txt
		$destMachine = Import-Csv $Env:SystemDrive\$rootDir\$dest.txt
	}
	Catch
	{
		echo "EXCEPTION THROWN::[ $_ ] "
	}

	$destBaseOptions   = New-Object Microsoft.Web.Deployment.DeploymentBaseOptions
	$sourceBaseOptions = New-Object Microsoft.Web.Deployment.DeploymentBaseOptions
	$syncOptions       = New-Object Microsoft.Web.Deployment.DeploymentSyncOptions
	
	#fill in remoting information for source machine
	$sourceBaseOptions.ComputerName = $sourceMachine.ComputerName
	$sourceBaseOptions.UserName = $sourceMachine.UserName
	$password = ConvertTo-SecureString $sourceMachine.Password
	$password = ConvertTo-PlainText $password
	$sourceBaseOptions.Password = $password

	#fill in remoting information for destination machine
	$destBaseOptions.ComputerName = $destMachine.ComputerName
	$destBaseOptions.UserName = $destMachine.UserName
	$password = ConvertTo-SecureString $destMachine.Password
	$password = ConvertTo-PlainText $password
	$destBaseOptions.Password = $password
	
	Try
	{
		$providerOptions = New-Object Microsoft.Web.Deployment.DeploymentProviderOptions($provider)
		$deploymentObject = [Microsoft.Web.Deployment.DeploymentManager]::CreateObject($providerOptions, $sourceBaseOptions)
		$deploymentObject.SyncTo($destBaseOptions, $syncOptions)
	}
	Catch
	{
		echo "EXCEPTION THROWN::[ $_ ] "
	}
}

Function Sync-ServerPath($provider, $path, $source, $dest)
{
	Try
	{
		$sourceMachine = Import-Csv $Env:SystemDrive\$rootDir\$source.txt
		$destMachine = Import-Csv $Env:SystemDrive\$rootDir\$dest.txt
	}
	Catch
	{
		echo "EXCEPTION THROWN::[ $_ ] "
	}

	$destBaseOptions   = New-Object Microsoft.Web.Deployment.DeploymentBaseOptions
	$sourceBaseOptions = New-Object Microsoft.Web.Deployment.DeploymentBaseOptions
	$syncOptions       = New-Object Microsoft.Web.Deployment.DeploymentSyncOptions
	
	#fill in remoting information for source machine
	$sourceBaseOptions.ComputerName = $sourceMachine.ComputerName
	$sourceBaseOptions.UserName = $sourceMachine.UserName
	$password = ConvertTo-SecureString $sourceMachine.Password
	$password = ConvertTo-PlainText $password
	$sourceBaseOptions.Password = $password

	#fill in remoting information for destination machine
	$destBaseOptions.ComputerName = $destMachine.ComputerName
	$destBaseOptions.UserName = $destMachine.UserName
	$password = ConvertTo-SecureString $destMachine.Password
	$password = ConvertTo-PlainText $password
	$destBaseOptions.Password = $password

#	$syncOptions.WhatIf = $true;
	
	Try
	{
		$deploymentObject = [Microsoft.Web.Deployment.DeploymentManager]::CreateObject($provider, $path, $sourceBaseOptions)
		#$deploymentObject.SyncParameters.Load("StagingParameters.xml")

		$deploymentObject.SyncTo($provider, $path, $destBaseOptions, $syncOptions)
	}
	Catch
	{
		echo "EXCEPTION THROWN::[ $_ ] "
	}
}

#$provider = [Microsoft.Web.Deployment.DeploymentWellKnownProvider]::AppHostConfig
#Sync-Provider "AppHostConfig" "Default Web Site" "Test"
#Create-Server

<#
$sourceBaseOptions = New-Object Microsoft.Web.Deployment.DeploymentBaseOptions
$destinationBaseOptions = New-Object Microsoft.Web.Deployment.DeploymentBaseOptions
$syncOptions = New-Object Microsoft.Web.Deployment.DeploymentSyncOptions

$deploymentObject = [Microsoft.Web.Deployment.DeploymentManager]::CreateObject("AppPoolConfig", "", $sourceBaseOptions)

$replaceAppPoolName = New-Object Microsoft.Web.Deployment.DeploymentReplaceRule("replaceDefaultAppPool",
						"add", $null, $null, "name", "DefaultAppPool", "NewDefaultAppPool")
$skipDelete = New-Object Microsoft.Web.Deployment.DeploymentSkipRule("skipDeleteOnDestination", "Delete", "add", $null, $null)

$syncOptions.WhatIf = $true
$syncOptions.Rules.Add($replaceAppPoolName)
$syncOptions.Rules.Add($skipDelete)

$deploymentObject.SyncTo($destinationBaseOptions, $syncOptions)

	------------------------------
#>

#$app = Read-Host "IIS App"
#Sync-ServerPath AppPoolConfig search2 cpweb-a01-stg1.vm.local cpadmin-haf.vm.local
#Sync-ServerPath AppHostConfig search2 cpweb-a01-stg1.vm.local cpadmin-haf.vm.local
#Create-Server
