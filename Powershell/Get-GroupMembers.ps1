Import-Module ActiveDirectory

$OU= 'OU=Users_And_Groups,DC=Globalmove,DC=local'


function Get-GroupMemberShipList{
    Param( [switch]$printformat )
     $membership=Get-ADGroup -Filter * -searchBase $OU |
     ForEach-Object{
          $hash=@{GroupName=$_.Name;Member=''}
          $_ | Get-ADGroupMember -ea 0 -recurs |
               ForEach-Object{
                    $hash.Member=$_.SamAccountName
                    New-Object psObject -Property $hash
               }
          }
     if($printformat){  
          $membership | 
              sort groupname,member | 
              export-csv -path C:\GlobalMoveMembers.csv
     }else{
          $membership
     }
}
Get-GroupMemberShipList -print