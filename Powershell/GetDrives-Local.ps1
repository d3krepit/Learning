$computer = $env:COMPUTERNAME
$outFile = "C:\$computer.csv"

Foreach ($computer in $computers){
Get-WmiObject Win32_LogicalDisk -Filter "DriveType=3"  |Select-Object SystemName, DeviceID | Export-Csv $outFile -NoTypeInformation -Force

#@{ Name = "Size (GB)"; Expression = { "{0:N1}" -f ($_.size / 1GB) } },
#@{ Name = "Free Space (GB)"; Expression = { "{0:N1}" -f ($_.freespace / 1GB) } },
#@{ Name = "Free Space (%)"; Expression = { "{0:P2}" -f (($_.freespace / 1GB) / ($_.size / 1GB)) } }| export-csv $outFile -NotypeInformation -Force
} 