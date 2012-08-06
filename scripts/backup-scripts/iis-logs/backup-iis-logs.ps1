param(
	$App       = $(throw "You must specify an application (searcher|searchapi)"),
	$Server     = $(throw "You must specify a source server"),
	$DestServer = $(throw "You must specify a destination server"),
	$Username   = $(throw "You must specify a username"),
	$Password   = $(throw "You must specify a password"),
	$Range      = $(throw "You must specify a range for the IIS logs")
)

$y = Get-Date (Get-Date).AddDays(-1) -Format yyMMdd
$logdir = "c:\inetpub\logs\logfiles\w3svc"
#$DestServer = "zabbix.healthcare.com"

foreach ($i in ${Range}) {
	$params = @( "-r", "-l", $Username, "-pw", $Password,
		"${logdir}${i}\u_ex${y}.log",
		"${DestServer}:${App}/${Server}/w3svc${i}/"
	)
	
	& pscp $params
}
