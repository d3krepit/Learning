Import-Module activedirectory

$array = @()

get-content "C:\Users\John.Palu.GLOBALMOVE\users.txt"|ForEach-object{

get-aduser $_ -properties DisplayName,GivenName,Surname,Company,Enabled | Select-Object DisplayName,GivenName,Surname,Company,Enabled|%{

$obj = New-Object PSObject
$obj|Add-Member NoteProperty DisplayName $_.DisplayName
$obj|Add-Member NoteProperty FirstName $_.GivenName
$obj|Add-Member NoteProperty LastName $_.Surname
$obj|Add-Member NoteProperty Company $_.Company
$obj|Add-Member NoteProperty Enabled $_.Enabled
$array+=$obj

}

}
$array|export-csv -notypeinformation C:\Users.csv