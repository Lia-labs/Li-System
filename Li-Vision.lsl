integer DIALOG_CHANNEL = -123456;
integer listenerHandle;

string ActualMenu = "Main";
string VisionMode = "None";
string EnvMode = "None";
string Dist_cam_max;
string Dist_cam_min;
string owner_name;
string owner_name_query; 


string status_camlock= "y";
string status_showloc= "n";
string status_showworldmap= "n";
string status_showminimap= "n";
string status_camtextures = "y";
string status_shownearby = "y";
string status_shownametags = "y";
string status_showhovertextworld = "y";





list MM1 = ["-","↩ Back","-","Env. 👓","-","-","M.Lock 🔑","Vision 👀","⛓ RLV"];
list MV1 = ["-","🔺 Back","-","None","-","-","Decoy", "Very Thin", "Thin", "Medium", "Thick", "Opaque"];
list MR1 = ["-","🔺 Back","-","Location ❌", "Minimap   ❌","Textures   ✔", "ShowNear  ✔", "NameTags  ✔", "HoverText ✔"];
list ME1 = ["-","🔺 Back","-","None","-","-","Green","Purple","White","Blue","Pink","Red"];


string getMenuMessage(string menuName)
{
    if (menuName == "Main")
        return "       ~Li-Vision Module~  " +
                        "\n ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  " +
                        "\n   *Vision   Mode :" +  VisionMode +
                        "\n   *Env.     Mode :" +  EnvMode;


    else if (menuName == "Vision")
        return "Vision for " + owner_name + "\nChoose a sub-option:";
    else if (menuName == "⛓ RLV")
        return "Restrictions for " + owner_name + "\nChoose a sub-option:";
    else if (menuName == "Env. 👓")
        return "Environments for " + owner_name + "\nChoose a sub-option:";
    return "Unknown menu.";
}





list getMenuButtons(string menuName)
{
    if (menuName == "Main")
        return MM1;
    else if (menuName == "Vision")
        return MV1;
    else if (menuName == "⛓ RLV")
        return MR1;
    else if (menuName == "Env. 👓")
        return ME1;
    
    return [];
}
















showMenu(string menuName, key id)
{

    llDialog(id, getMenuMessage(menuName), getMenuButtons(menuName), DIALOG_CHANNEL);
    ActualMenu = menuName;
}

rlv_vision_command (string dist_cam_min, string dist_cam_max)
{
    llOwnerSay("@camdistmax:" + dist_cam_max + "=" + status_camlock + 
    ",clear=setsphere,setsphere=n,setsphere_mode:0=force,setsphere_valuemin:0.0=force,setsphere_valuemax:1.000000=force" +
    ",setsphere_distmin:" + dist_cam_min + "=force,setsphere_distmax:" + dist_cam_max + "=force" +
    ",shownametags=" + status_shownametags +
    ",showhovertextworld=" + status_showhovertextworld +
    ",showloc=" + status_showloc +
    ",showminimap=" + status_showminimap +
    ",showworldmap=" + status_showworldmap +
    ",shownearby=" + status_shownearby +
    ",camtextures=" + status_camtextures );

    
    

}


rlv_env_command ( string R, string G, string B)
{

    llOwnerSay("@setenv_preset:midnight=force"+
    ",setenv_ambientr:"+ R +"=force"+
    ",setenv_ambientg:"+ G +"=force"+
    ",setenv_ambientb:"+ B +"=force"+
    ",setenv_distancemultiplier:99=force"+
    ",setenv_densitymultiplier:1.0=force"+
    ",setenv_hazedensity:1.0=force"+
    ",setenv_hazehorizon:1.0=force"+
    ",setenv_maxaltitude:4000=force"+
    ",setenv_scenegamma:.5=force"+
    ",setoverlay=n"+
    ",setenv=n");


}




VisionRestrictions(string Mode)
{
    if (Mode == "None"){
        
        llOwnerSay("@clear=cam"+
        ",clear=setsphere"+
        ",shownametags=y"+
        ",showhovertextworld=y"+
        ",showloc=y"+
        ",showminimap=y"+
        ",showworldmap=y"+
        ",shownearby=y"+
        ",setoverlay=y"+
        ",camtextures=y");
        VisionMode = Mode;
        
        }

    else if (Mode == "Decoy"){
        
        string Dist_cam = "10000000000000000";
        rlv_vision_command(Dist_cam,Dist_cam);      
        VisionMode = Mode;
        
        }

    else if (Mode == "Very Thin"){
        
        Dist_cam_max = "3";
        Dist_cam_min = "2.75";
        rlv_vision_command(Dist_cam_min,Dist_cam_max);      
        VisionMode = Mode;
        
        }
    
    else if (Mode == "Thin"){
        
        Dist_cam_max = "2.5";
        Dist_cam_min = "2.25";
        rlv_vision_command(Dist_cam_min,Dist_cam_max);          
        VisionMode = Mode;
        
        }
    
    else if (Mode == "Medium"){
        
        Dist_cam_max = "2";
        Dist_cam_min = "1.75";
        rlv_vision_command(Dist_cam_min,Dist_cam_max);          
        VisionMode = Mode;
        
        }
    
    
    else if (Mode == "Thick"){
        
        Dist_cam_max = "1.5";
        Dist_cam_min = "1.25";
        rlv_vision_command(Dist_cam_min,Dist_cam_max);           
        VisionMode = Mode;
        
        }

    else if (Mode == "Opaque"){
        
        Dist_cam_max = "1";
        Dist_cam_min = "0.75";
        rlv_vision_command(Dist_cam_min,Dist_cam_max);           
        VisionMode = Mode;
        
        }
    

}




default
{
    
    state_entry()
    {   
        llOwnerSay("Vision available:"+(string)llGetFreeMemory( )+"b");
        key owner_id = llGetOwner();
        owner_name_query = llRequestDisplayName(owner_id);

    }


    dataserver(key queryid, string data)
    {
        if ( owner_name_query == queryid )
        {
            owner_name = data;
            
        }

    }


    link_message(integer sender, integer num, string message, key id)
    {
    if (num == 9000 && message == "submenu_request")
    {
        key user = id; 
       
        
        if (listenerHandle)
        {
            llListenRemove(listenerHandle);
        }
        listenerHandle = llListen(DIALOG_CHANNEL, "", user, "");
        showMenu("Main",user);
    }
    }

    



    


    listen(integer channel, string name, key id, string message)
    {
        if (message == "↩ Back")
        {
            
            llMessageLinked(LINK_THIS, 9001, "return_to_main", id);
            

        }


        else if (message == "Vision 👀")
        {
            showMenu("Vision",id);
        }
        else if (message == "🔺 Back")
        {
            showMenu("Main",id);
        }
        else if (message == "⛓ RLV")
        {
            showMenu("⛓ RLV",id);
        }

        else if (message == "Env. 👓")
        {
            showMenu("Env. 👓",id);
        }
    
        else if (message == "M.Lock 🔑" || message == "M.Lock 🔒")
        {
        
            string newLabel;
            string newStatus;

            if (message == "M.Lock 🔑") {
                newLabel = "M.Lock 🔒";
                newStatus = "n";
            } else {
                newLabel = "M.Lock 🔑";
                newStatus = "y";
            }

            MM1 = llListReplaceList(MM1, [newLabel], 6, 6); 
            status_camlock = newStatus;

            if (VisionMode != "None") {
                llOwnerSay("@camdistmax:" + Dist_cam_max + "=" + status_camlock
                );
            }

            showMenu("Main", id);

        }

        else if (ActualMenu == "Vision"){

            if (message == "None")
            {
                VisionRestrictions(message);
                showMenu("Vision",id);
            }

            if (message == "Decoy")
            {
                VisionRestrictions(message);
                showMenu("Vision",id);
            }


            else if (message == "Very Thin")
            {
                VisionRestrictions(message);
                showMenu("Vision",id);
            }

            else if (message == "Thin")
            {
                VisionRestrictions(message);
                showMenu("Vision",id);
            }

            else if (message == "Medium")
            {
                VisionRestrictions(message);
                showMenu("Vision",id);
            }

            else if (message == "Thick")
            {
                VisionRestrictions(message);
                showMenu("Vision",id);
            }

            else if (message == "Opaque")
            {
                VisionRestrictions(message);
                showMenu("Vision",id);
            }

            else if (message == "-")
            {   
            
            showMenu(ActualMenu,id);
            }

        }

        else if (ActualMenu == "⛓ RLV"){

        if (message == "Location ❌" || message == "Location ✔")
        {

            string newLabel;
            string newStatus;

            if (message == "Location ❌") {
                newLabel = "Location ✔";
                newStatus = "y";
            } else {
                newLabel = "Location ❌";
                newStatus = "n";
            }

            MR1 = llListReplaceList(MR1, [newLabel], 3, 3); 
            status_showworldmap = newStatus;
            status_showloc = newStatus;

            if (VisionMode != "None") {
                llOwnerSay(
                "@showloc="+ status_showloc +",showworldmap="+ status_showworldmap
                );
            }

            showMenu("⛓ RLV",id);
            
        }  

        else if (message == "Minimap   ❌" || message == "Minimap   ✔")
        {

            string newLabel;
            string newStatus;

            if (message == "Minimap   ❌") {
                newLabel = "Minimap   ✔";
                newStatus = "y";
            } else {
                newLabel = "Minimap   ❌";
                newStatus = "n";
            }

            MR1 = llListReplaceList(MR1, [newLabel], 4, 4); 
            status_showminimap = newStatus;
            

            if (VisionMode != "None") {
                llOwnerSay(
                    "@showminimap="+ status_showminimap
                );
            }

            showMenu("⛓ RLV",id);
            
        }  


        else if (message == "Textures   ✔" || message == "Textures   ❌")
        {

            string newLabel;
            string newStatus;

            if (message == "Textures   ✔") {
                newLabel = "Textures   ❌";
                newStatus = "n";
            } else {
                newLabel = "Textures   ✔";
                newStatus = "y";
            }

            MR1 = llListReplaceList(MR1, [newLabel], 5, 5); 
            status_camtextures = newStatus;
            

            if (VisionMode != "None") {
                llOwnerSay(
                    "@camtextures="+ status_camtextures
                );
            }

            showMenu("⛓ RLV",id);
            
        } 

        else if (message == "ShowNear  ✔" || message == "ShowNear  ❌")
        {

            string newLabel;
            string newStatus;

            if (message == "ShowNear  ✔") {
                newLabel = "ShowNear  ❌";
                newStatus = "n";
            } else {
                newLabel = "ShowNear  ✔";
                newStatus = "y";
            }

            MR1 = llListReplaceList(MR1, [newLabel], 6, 6); 
            status_shownearby = newStatus;
            

            if (VisionMode != "None") {
                llOwnerSay(
                    "@shownearby="+ status_shownearby
                );
            }

            showMenu("⛓ RLV",id);
            
        } 

        else if (message == "NameTags  ✔" || message == "NameTags  ❌")
        {

            string newLabel;
            string newStatus;

            if (message == "NameTags  ✔") {
                newLabel = "NameTags  ❌";
                newStatus = "n";
            } else {
                newLabel = "NameTags  ✔";
                newStatus = "y";
            }

            MR1 = llListReplaceList(MR1, [newLabel], 7, 7); 
            status_shownametags = newStatus;
            

            if (VisionMode != "None") {
                llOwnerSay(
                    "@shownametags="+ status_shownametags
                );
            }

            showMenu("⛓ RLV",id);
            
        }

        else if (message == "HoverText ✔" || message == "HoverText ❌")
        {

            string newLabel;
            string newStatus;

            if (message == "HoverText ✔") {
                newLabel = "HoverText ❌";
                newStatus = "n";
            } else {
                newLabel = "HoverText ✔";
                newStatus = "y";
            }

            MR1 = llListReplaceList(MR1, [newLabel], 8, 8); 
            status_showhovertextworld = newStatus;
            

            if (VisionMode != "None") {
                llOwnerSay(
                    "@showhovertextworld="+ status_showhovertextworld
                );
            }

            showMenu("⛓ RLV",id);
            

        }


        else if (message == "-")
        {   
            
            showMenu(ActualMenu,id);
        }


        }

        else if (ActualMenu == "Env. 👓")
        {

            if (message == "None")
            {
            
                if (VisionMode == "None") {
                    llOwnerSay("@setenv=y"); 
                }

                llOwnerSay("@setenv_preset:Sunset=force");
                EnvMode =message;
                showMenu("Env. 👓",id);
            }

            else if (message == "Green")
            {
                rlv_env_command("0.0","1.0","0.0");
                EnvMode =message;
                showMenu("Env. 👓",id);
            }
            
            else if (message == "Purple")
            {
                rlv_env_command("0.29","0.0","0.5");
                EnvMode =message;
                showMenu("Env. 👓",id);
            }
            
            else if (message == "White")
            {
                rlv_env_command("0.5","0.5","0.5");
                EnvMode =message;
                showMenu("Env. 👓",id);
            }

            else if (message == "Blue")
            {
                rlv_env_command("0.0","0.0","1.0");
                EnvMode =message;
                showMenu("Env. 👓",id);
            }

            else if (message == "Pink")
            {   
                rlv_env_command("0.5","0.0","0.5");
                EnvMode =message;
                showMenu("Env. 👓",id);
            }

            else if (message == "Red")
            {
                rlv_env_command("1.0","0.0","0.0");
                EnvMode =message;
                showMenu("Env. 👓",id);
            }

            else if (message == "-")
        {   
            
            showMenu(ActualMenu,id);
        }


        }



        else if (message == "-")
        {   
            
            showMenu(ActualMenu,id);
        }
        else
        {
            llOwnerSay("You selected: " + message);
        }


    }



}
