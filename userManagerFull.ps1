################Global constants
$password = "SamePassw0rd!23"
$description = ""
$managedGroups = "testgr1", "testgr2", "testgr3"
$serverList = "ismagulo1"
$datas = Import-Csv .\userControl.csv
##################################           


###############   FUNCTIONS    ######################################################################################

Function test-adsiPC($pc)             ######  function to test server availability by [adsi]         #########
{                                   
 TRAP { CONTINUE}
 $exist = $null
 $exist = [ADSI]::Exists("WinNT://$pc,computer")
if ($exist -ne 'True') {$False}
else {$True}
}     ########################################################################

Function create-localuser($role)      #######    Function to create user and add to cpetial role (group)
{ 
if ($usrExist -eq 0) 
   {
   $user = $computer.Create("user", $localUser)
   Write-Host User $localUser was created on server $localServer
   }
else
   {
   [ADSI]$user="WinNT://$localserver/$localuser,User"
   }
$user.SetPassword($password)
$user.Setinfo()
$user.description = $description
$user.UserFlags = 65536
$group = [ADSI]"WinNT://$localServer/$role,group"
$group.add("WinNT://$localuser,user")
Write-Host User $localUser was added to role $role on server $localServer
 }   ##########################################################################
                                                                                                            ##########
##################################################################################        End FUNCTIONS     ##########





##########################   Block of code to clear all groups membership  ###########################
foreach ($localServer in $serverList)
{
  $computer = [ADSI]"WinNT://$localServer,computer"
  foreach ($managedGroup in $managedGroups) 
        {
        if([ADSI]::Exists("WinNT://$localServer/$managedGroup,group")) 
            { 
            $group = [ADSI]"WinNT://$localServer/$managedGroup,group"
            $members= $group.psbase.invoke("Members") |     %{$_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)}
            if ($members -ne $null) 
                {
                foreach ($member in $members)
                    {
                    $group.Remove("WinNT://$localServer/$member")
                    }
                $members = $null
                }
            }
        else
            {
            Write-Warning "Local group '$managedGroup' doesn't exist on server '$localServer'. Creating...done" 
            $group = $computer.Create("Group", $managedGroup)
            $group.setInfo()
            }
        
        }
}   
                                                                                                            ############
##################################################################################        End of block   ###############




##############################################################   Main Block   ##############################################
foreach ($data in $datas) 
{
    Write-Output "************"
    $localServer = $data.server
    $localUser = $data.username
    $localRoleNum = $data.ROLENUM
    $usrExist = 0
    
    ###   Log
    Write-Host "Local server - "$localServer "Local User - "$localUser "Local Role Num"$localRoleNum
    ###
    
    ############################  Check - if servers are available, if roleNums are exist 
    if ((!(test-adsiPC $localServer)) -or ($localRoleNum -eq ""))
        {
        Write-Warning "$localserver is unavailable or Role Number = $localRoleNum  null"
        } 
        
    else
    #################  Check is done  - main code   
        {
        $computer = [ADSI]"WinNT://$localServer,computer"
        $localUsers = $computer.Children | where {$_.SchemaClassName -eq 'user'}  |  % {$_.name[0].ToString()}
        $localGroups = $computer.Children | where {$_.SchemaClassName -eq 'group'}  |  % {$_.name[0].ToString()}
        if ($localusers -Contains $data.USERNAME)    #####Проверям сущестует ли пользователь на сервере#############
            {                                           #######################################################
            $usrExist = 1                                   ###############################################
            }                                                     #####################################
        Write-Host "usrExist - " $usrExist

#####Choosing action, based on the role number##############################

        switch ($localRoleNum) 
            {
            0               #######  Role 0        Delete user ##########   
                {
                if ($usrExist -eq 1)     
                    {
                    $computer.delete("user",$localUser)
                    Write-Host User $localUser was deleted from $localServer
                    }
                }
        
            1              #######  Role 1        create user and add to role 1 ##########   
                {
                create-localuser -role testgr1
                }
            
            2              #######  Role 2        create user and add to role 2 ##########   
                {
                create-localuser -role testgr2
                }
            3              #######  Role 3        create user and add to role 3 ##########   
                {
                create-localuser -role testgr3
                }
            }   #####  end of SWITCH block
        }    #####  end of ELSE block    
  Write-Output "*****************************************"   
}  #####end of FOREACH block
        
        
         
         
       




