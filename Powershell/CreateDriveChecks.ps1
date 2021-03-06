$csv = Import-Csv C:\Drives.csv

foreach ($line in $csv) {
$drive = $line.DeviceID
$hostname= $line.SystemName

[string]$string = 
"define service {
	service_description		Drive Space - " + $drive + "
	use		                Generic Service No Warning
	host_name		        " + $hostname + " 
	check_command			check_nrpe!CheckDriveSize!ShowAll MinWarn=15% MinCrit=10% Drive=" +  $drive + " 
}"
Write-output $string
}