$ESBServices = @{
	"HifABTracking"       = "abtracking.config";
	"HifCallTracking"     = "calltracking.config";
	"HifFiltering"        = "filtering.config";
	"HifFwParams"         = "fwparams.config";
	"HifPayment"          = "payment.config";
	"HifSuperbidTracking" = "superbidtracking.config";
	"HifTracking"         = "tracking.config"
}

$command = ".\Rhino.ServiceBus.Host.exe"
$actions = @("Deploy", "Install")

$assembly = "BrokersWeb.Messages.Processor.dll"

$actions | ForEach-Object {
	$action = $_

	$ESBServices.GetEnumerator() | ForEach-Object {
		$sn = $_.Key
		$cf = $_.Value

		$params = @(
			"/Name:${sn}",
			"/Assembly:${assembly}",
			"/ConfigFile:${cf}",
			"/Action:${action}"
		)
		
		& $command $params
	}
}
