#Creates all users in C:\Users.txt and adds them to the Administrators group.

$users = get-content C:\Users.txt


Foreach($user in $users){

$password = "Pa$$w0rd"
$objOu = [adsi]"WinNT://$env:computername"
$objUser = $objOU.Create("User", $user)
$objUser.SetPassword($password)
$objUser.SetInfo()
$objUser.SetInfo()

net localgroup administrators /add $user
}
