$ESservers = @{
	"es.haf1.vm.local" = 9200;
	"es.haf2.vm.local" = 9200;
	"a01.vm.local"     = 9200;
	"192.168.10.112"   = 8200
}

$Indexes = @{
	"bwenhancedclick"  = 25;
	"bwleadcollection" = 120;
	"bwsalecollection" = 720;
	"bwsessions"       = 168
}

$RootPath = "C:\deleteOldElasticSearchDocs"
$Command = "${RootPath}\ElasticSearchDeleteByQuery.exe"

$ESservers.GetEnumerator() | ForEach-Object {
	$Server = $_.Key
	$Port   = $_.Value

	$Indexes.GetEnumerator() | ForEach-Object {
		$Index = $_.Key
		$TTL   = $_.Value

		$Params = @($Server, $Port, $Index, $TTL, "timestamp", "off")

		Get-Date -Format "yyyy-MM-dd HH:mm:ss" >> CleanES.log
		& $Command $Params >> CleanES.log
	}
	
}
