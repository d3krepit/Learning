#Reset Users in C:\Users.txt 's password to the Pa$$w0rd 
$users = (get-content C:\Users.txt)

Foreach($user in $users){
$userob = [adsi]"WinNT://$env:computername/$user"
$userob.SetPassword("Temp.Password")
}