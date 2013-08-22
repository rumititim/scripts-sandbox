################Константы
$password = "SamePassw0rd!23"
##$localGroupName = "Remote Desktop Users"    
$description = "Tester user"
$usrExist = 0
$managedGroups = "testgr1", "testgr2", "testgr3"
$serverList = "ismagulo1"
$role1 = "testgr1"
$role2 = "testgr2"
$datas = Import-Csv .\userControl.csv           #Получаем данные с csv


foreach ($server in $serverList)
  {  
foreach ($managedGroup in $managedGroups) 
        {
        if([ADSI]::Exists("WinNT://$localserver/$managedGroup,group")) 
            { 
            $computer = [ADSI]"WinNT://$localserver,computer"
            $computer.psbase.Children.Remove("WinNT://$localserver/$managedGroup")
            }
        else
            {
            Write-Warning "Local group '$managedGroup' doesn't exist on computer '$localServer'" 
            }
        $tempGroup = $computer.Create("Group", $managedGroup)
        $tempGroup.setInfo()
        }
  }  





#Орабатываем данные
foreach ($data in $datas) 
    {
    $localServer = $data.server
    $localUser = $data.username
    $localRoleNum = $data.ROLENUM
    
    ###   Проверка
    $localServer
    $localUser
    $localRoleNum
    ###
    
    
    if([ADSI]::Exists("WinNT://$localserver,computer")) 
        { 
        $computer = [ADSI]"WinNT://$localserver,computer" 
        }
    $localUsers = $computer.Children | where {$_.SchemaClassName -eq 'user'}  |  % {$_.name[0].ToString()}
    $localGroups = $computer.Children | where {$_.SchemaClassName -eq 'group'}  |  % {$_.name[0].ToString()}
    
    
    
    
    
    if ($localusers -Contains $data.USERNAME)    #####Проверям сущестует ли пользователь на сервере#############
        {                                           #######################################################
        $usrExist = 1                                   ###############################################
        }                                                     #####################################
            

    

  


#####Выбираем дейстие в заисимости от роли##############################

    switch ($localRoleNum) 
        {
        0               #######  Роль 0        Удаление пользователя ##########   
            {
                if ($usrExist -eq 1)     
                    {
                $computer.delete("user",$localUser)
                    }
            }
        
        1              #######  Роль 1        Создание пользователя добавление в группу ##########   
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
                $group = [ADSI]"WinNT://$localServer/testgr1,group"
                $group.add("WinNT://$localuser,user")
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
            }
        
        
        }  
        
       
        
    }




