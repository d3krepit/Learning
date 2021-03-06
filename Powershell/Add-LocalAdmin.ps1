##Usage##
#Add-LocalAdmin.ps1 .\hosts.txt#
Param ([Parameter(Mandatory=$True)][string]$hosts)
[Array]$Servers = get-content $hosts

Function Add-LocalAdministrator
{
	ForEach ($Server in $Servers)
	{
		$adminUser= "UserName or GroupName you want to add to local admins"
		$domain = "Domain Name"
		([ADSI]"WinNT://$Server/Administrators,group").Add("WinNT://$domain/$adminUser")

	}#EndForEach
}#EndFunction

Function Get-LocalAdministrator
{
	ForEach ($Server in $Servers)
	{
		Write-host "------------"$Server"------------"
		
		$group= ([ADSI]"WinNT://$Server/Administrators,group")
		$members = @($group.psbase.Invoke("Members"))
		$members| foreach {$_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)}
		
		Write-host "------------------------------------------"
	}#EndForEach
}#EndFunction

#Add-LocalAdministrator
Get-LocalAdministrator