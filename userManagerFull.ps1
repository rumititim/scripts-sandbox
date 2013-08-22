################Константы
$password = "SamePassw0rd!23"
$description = ""
$managedGroups = "testgr1", "testgr2", "testgr3"
$serverList = "ismagulo1"
$datas = Import-Csv .\userControl.csv           


###############   Functions    ######################################################################################
Function test-adsiPC($pc)             ######  This function is test server availability thru [adsi]         #########
{                                   
$computer = "ismagulo1"
 TRAP { CONTINUE}
 $exist = $null
 $exist = [ADSI]::Exists("WinNT://$pc,computer")
if ($exist -ne 'True') {$False}
else {$True}
}
                                                                                                            ##########
##################################################################################        End Functions     ##########





##########################   Block of code to clear all groups membership  ###########################
foreach ($localServer in $serverList)
{  
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
            $computer = [ADSI]"WinNT://$localServer,computer"
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
    
    ###   Проверка
    Write-Host "Local server - "$localServer "Local User - "$localUser "Local Role Num"$localRoleNum
    ###
    
    if ((!(test-adsiPC $localServer)) -or ($localRoleNum -eq ""))
        {
        Write-Warning "$localserver is unavailable or Role Number = $localRoleNum  null"
        } 
        
    else
        
        {
           
        $computer = [ADSI]"WinNT://$localserver,computer" 
        
        $localUsers = $computer.Children | where {$_.SchemaClassName -eq 'user'}  |  % {$_.name[0].ToString()}
        $localGroups = $computer.Children | where {$_.SchemaClassName -eq 'group'}  |  % {$_.name[0].ToString()}
    
    
    
    
    
        if ($localusers -Contains $data.USERNAME)    #####Проверям сущестует ли пользователь на сервере#############
            {                                           #######################################################
            $usrExist = 1                                   ###############################################
            }                                                     #####################################
            

        Write-Host "usrExist - " $usrExist

  


#####Выбираем дейстие в заисимости от роли##############################

        switch ($localRoleNum) 
            {
            0               #######  Роль 0        Удаление пользователя ##########   
                {
                if ($usrExist -eq 1)     
                    {
                    $computer.delete("user",$localUser)
                    Write-Host User $localUser was deleted from $localServer
                    }
                }
        
            1              #######  Роль 1        Создание пользователя добавление в группу ##########   
                {
                if ($usrExist -eq 0) 
                    {
                    $user = $computer.Create("user", $data.username)
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
                $group = [ADSI]"WinNT://$localServer/testgr1,group"
                $group.add("WinNT://$localuser,user")
                Write-Host User $localUser was added to group testgr1 on server $localServer
                }
            
            
            2              #######  Роль 1        Создание пользователя добавление в группу ##########   
                {
                if ($usrExist -eq 0) 
                    {
                    $user = $computer.Create("user", $data.username)
                    }
                else
                    {
                    [ADSI]$user="WinNT://$localserver/$localuser,User"
                    }
                $user.SetPassword($password)
                $user.Setinfo()
                $user.description = $description
                $user.UserFlags = 65536
                $group = [ADSI]"WinNT://$localServer/testgr2,group"
                $group.add("WinNT://$localuser,user")
                Write-Host User $localUser was added to group testgr2 on server $localServer
                }
            
            3              #######  Роль 1        Создание пользователя добавление в группу ##########   
                {
                if ($usrExist -eq 0) 
                    {
                    $user = $computer.Create("user", $data.username)
                    }
                else
                    {
                    [ADSI]$user="WinNT://$localserver/$localuser,User"
                    }
                $user.SetPassword($password)
                $user.Setinfo()
                $user.description = $description
                $user.UserFlags = 65536
                $group = [ADSI]"WinNT://$localServer/testgr3,group"
                $group.add("WinNT://$localuser,user")
                Write-Host User $localUser was added to group testgr3 on server $localServer
                }
        
        
            }
        
        }
        
        
        
         
         
        Write-Output "*****************************************"   
        
}




