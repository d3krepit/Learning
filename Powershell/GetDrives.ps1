$computers = (Get-Content C:\servers.txt)
$outFile = "C:\Drives.csv"

foreach ($computer in $computers) {
    $disks = Get-WmiObject -Class Win32_LogicalDisk -ComputerName $computer -Filter 'DriveType=3'

    $info = @{
        ComputerName=$computer      
	    DiskSize=($disks|foreach {"{0:N1}" -f ($_.size / 1GB)}) -join ";"
        FreeSpaceGB= ($disks | foreach { "{0}{1:N0}" -f $_.Caption,($_.freespace/1GB) }) -join ';'
		"FreeSpace %"= ($disks | foreach { "{0:P2}" -f (($_.freespace / 1GB) / ($_.size / 1GB)) }) -join ";"
    }

    $object = New-Object -TypeName PSObject -Property $info 
}
$object|export-csv $outfile -notypeinformation -force