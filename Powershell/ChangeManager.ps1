$users = Get-Content C:\users.txt
$manager = "Kenneth Kehoe"

Foreach ($user in $users){
Set-ItemProperty -Filter "sAMAccountName=$user" -path * -name manager -value "CN=$manager,OU=Users,OU=Users_And_Groups,DC=S24,DC=local"
}