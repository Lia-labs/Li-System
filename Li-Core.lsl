//Definitions

float onlineTimeLockStarted  = 0.0;
float TimeLockDuration = 10.0;
integer DIALOG_CHANNEL = -123479;
integer TEXTBOX_CHANNEL = -67981367;
integer listenerHandle;
integer listenerHandle_TextBox;
integer Cycles_menu = 1;
integer Timer_in_seconds =0;
string ActualMenu = "Main";


integer onlineTimeLockEnabledTimer = FALSE;
integer realTimeLockEnabledTimer = FALSE;
string Timer_Mode = "Online";

integer Key_Status = TRUE;
string Lock_Message = "Not locked";
string Key_Message = "It's Available";
key Key_Holder = NULL_KEY ;
key TextBox_target ;




string status_detach= "y";
integer Public_Mode = TRUE;
integer HIDEEN_TIMER = FALSE;

// Reset tracker
integer BOOT_TIME;

//Requests
list Sensor_Requests = [];


//Buttons Lists Definitions
list MM1 = ["-","↩ Close","-","-","Access","Settings","Lock 🔒","Take Key 🔑","Timer ⏰","-","Blindfold","-"];
list MM_TakenKey_1 = ["-","↩ Close","-","-","Access","Settings","Lock 🔒","[Key Taken]","Timer ⏰","-","Blindfold","-"];
list M_Key_Summoning = ["Summon Key","🔺 Close" ];

list M_Timer_1= ["-","🔺 Close","-","Start Timer", "-","-","RealTime ✖", "Hide Timer", "Set Timer"];
list M_Acess_1 = ["-","🔺 Close","-","Blacklist ✖","Trusted ✖","Owners ✖","➕ Blacklist", "➕ Trusted","➕ Owners"];
list select_buttons =["🔁 Re-Scan","↩ Close","Manual Input","4","5","6","1","2","3"];
list substract_buttons =["Manual Input","↩ Close",">>>","4","5","6","1","2","3"];
list M_Settings =["-","🔺 Close","-"];



//Functions
string buttonLabel(string label) { //crop to valid UTF-8 of at most 24 bytes
    string  encoded = llStringToBase64(label);
    if (llStringLength(encoded) <= 32) {
        return label; }
    integer end = 31;
    //note: if we don't do this, llBase64ToString might add a "?" for the character we cut in half
    string  tailEnc = llGetSubString(encoded, 28, 33);
    integer tail    = llBase64ToInteger(tailEnc);
    while ((tail & 0xc0) == 0x80) {
        if (end % 4 == 1) {
            end -= 2; }
        else {
            end--; } 
        tail = tail >> 8; }
    return llBase64ToString(llGetSubString(encoded, 0, end)); }


string sec_to_time( integer seconds){

    integer days; 
    integer hours;
    integer min;
    integer rest;

    days = seconds / 86400 ;
    rest = seconds % 86400 ;
    hours = rest / 3600;
    rest = rest % 3600;
    min = rest / 60;
    rest = rest %60;

    return (string)days +"days "+ (string)hours + "h "+(string)min +"m "+ (string)rest+ "s";


}

/*
integer string_to_sec(string text){

    list split = llParseString2List(text, [" "], []);
    integer sec_total = 0;
    integer a;
    
    for  (a=0 ; a < llGetListLength(split); a++){

        string value = llList2String (split, a );
        string number = llGetSubString(value, 0, -2);
        string letter = llGetSubString(value, -1, -1);

        if (letter == "d"){ sec_total += (integer)number *24*60*60;}
        else if (letter == "h"){ sec_total += (integer)number *60*60;}
        else if (letter == "m"){ sec_total += (integer)number *60;}
        else if (letter == "s"){ sec_total += (integer)number;}
           
    }

    return sec_total;

}
*/



unlock_timer(){
    status_detach = "y";
    Lock_Message = "Not locked";
    MM1 = llListReplaceList(MM1, ["Lock 🔒"], 6, 6);
    M_Timer_1= llListReplaceList(M_Timer_1, ["Start Timer"], 3, 3);
}

/*
startTimelock(){
    onlineTimeLockStarted = llGetTime();
    llSetTimerEvent(1.0);
}
    */

showMenu(string menuName, key id)
{
    string PATH;
    list buttons;

    //PATH 
    if (menuName == "Main")
        {PATH = "MAIN_MENU/";}

    else if (menuName == "Main_TakenKey")
        {PATH = "MAIN_MENU/";}

    else if (menuName == "Access")
        {PATH = "MAIN_MENU/ ACCESS/";}

    else if (menuName == "Timer")
        {PATH = "MAIN_MENU/ TIMER/";}

    else if (menuName == "Key_Summoning")
        {PATH = "MAIN_MENU/ KEY SUMMONING/";}
    
    else if (menuName == "NoAccess")
        {PATH = "MAIN_MENU/";}

    else if (menuName == "Settings")
        {PATH = "MAIN_MENU/ SETTINGS/";}

    else {PATH = "MAIN_MENU/";}

    llLinksetDataWrite("_ur:"+(string)id, PATH);



    //BUTTONS FOR DIALOGUE
    if (menuName == "Main")
        {buttons = MM1;}

    else if (menuName == "Main_TakenKey")
        {buttons = MM_TakenKey_1;}

    else if (menuName == "Access")
        {buttons =  M_Acess_1;}
    
    else if (menuName == "Timer")
        {buttons =  M_Timer_1;}

    else if (menuName == "Key_Summoning")
        {buttons = M_Key_Summoning;}
    
    else if (menuName == "NoAccess")
        {buttons = ["Close"];}

    else if (menuName == "Settings")
        {buttons = M_Settings;}

    else {buttons = [];}

    string message;

    // MESSAGE FOR DIALOGUE
    if (menuName == "Main" || menuName == "Main_TakenKey"){
        
        message = "\n PATH: " + PATH + "\n"+ "\n";
        message += "Main Menu"+
                "\n Lock    🔐:  " + Lock_Message +
                "\n Key     🔑:  " + Key_Message +
                "\n Total locked time : "  ;
        }
    else if (menuName == "NoAccess")
        {message= "You don't have access";}

    else if (menuName == "Access")
        {
            message = "\n PATH: " + PATH + "\n"+ "\n";
            message += "Access Menu";
        }

    else if (menuName == "Settings")
        {
            message = "\n PATH: " + PATH + "\n"+ "\n";
            message += "Settings Menu";
        }

    else if (menuName == "Timer")
        {
            message = "\n PATH: " + PATH + "\n"+ "\n";
            message += "Timer Menu" + "\n"+"Timer : " + sec_to_time(Timer_in_seconds);
        }

    else if (menuName == "Key_Summoning")
        {message= "As a owner u can summon the key back to the set. Choose between calling it back or go back to the previous menu";}

    else 
        {message= "Unknown menu.";}


    if (Key_Status == FALSE && Key_Holder != id && menuName == "Main"){
        menuName= "Main_TakenKey";}

    llDialog(id, message, buttons, DIALOG_CHANNEL);
    ActualMenu = menuName;
}


default
{

    state_entry()
    {
        
        llOwnerSay("Core available:"+(string)llGetFreeMemory( )+"b");
        key owner_id = llGetOwner();
        listenerHandle = llListen(DIALOG_CHANNEL, "", "", "");
        listenerHandle_TextBox= llListen(TEXTBOX_CHANNEL, "", "", "");

        llLinksetDataDelete("Trusted");
        llLinksetDataDelete("Blacklist");       

    }

    touch_start(integer total_number) {   
        string Menu;
        key user = llDetectedKey(0);
        
        if (llListFindList(llCSV2List(llLinksetDataRead("Owners")), [(string)user]) != -1|| llListFindList(llCSV2List(llLinksetDataRead("Trusted")), [(string)user]) != -1 || Public_Mode) {
            
            if (llListFindList(llCSV2List(llLinksetDataRead("Blacklist")), [(string)user]) != -1){

                Menu ="NoAccess";  
            }
            else{
                Menu = "Main";
            }

        } else {
            Menu ="NoAccess";  
        }
        showMenu(Menu,user);

    }

    listen(integer channel, string name, key id, string message)
    {

        string Menu;
        integer M_Call =FALSE;
        string errorMessage = "";
        string TB_message;
        integer TB_Call = FALSE;
        integer S_Call = FALSE;
        integer D_Call = FALSE;
        integer Add_Call =FALSE;
        key Add_Target;
        integer Del_Call =FALSE;
        key Del_Target;
        string target_key;
        
        if (llListFindList(llCSV2List(llLinksetDataRead("Blacklist")), [(string)id]) != -1){
            if (message =="Close") {}
            else{
            Menu ="NoAccess";
            M_Call= TRUE;
            }
        }

        else if (message == "Blindfold")
        {
            if (Key_Holder == id){
                llMessageLinked(LINK_THIS, 9000, "submenu_request", id);
            }
            else{
                errorMessage = "Only the key holder can apply restrictions";
                Menu = "Main";
                M_Call= TRUE;
                
            }
        }

        else if (message == "Access")
        {   
            Menu = "Access";
            M_Call = TRUE;
            
        }

        else if (message == "Lock 🔒" || message == "Unlock 🔓") {
            string agentLink = "secondlife:///app/agent/" + (string)id + "/about";

            if (message == "Lock 🔒") {
                if ((Key_Holder == NULL_KEY && Key_Status == TRUE) || Key_Holder == id) {
                    
                    if (Key_Holder == NULL_KEY) {
                        Key_Holder = id;
                        Key_Status = FALSE;
                        Key_Message = "The key is held by " + agentLink;
                        MM1 = llListReplaceList(MM1, ["Leave Key 🔑"], 7, 7);
                    }

                    
                    if (Key_Holder == id) {
                        status_detach = "n";
                        Lock_Message = "Locked by " + agentLink;
                        MM1 = llListReplaceList(MM1, ["Unlock 🔓"], 6, 6);
                    } else {
                        errorMessage = "You need to hold the key to be able to lock";
                    }
                } else {
                    errorMessage = "You need to hold the key to be able to lock";
                }
            } else { 
                if (Key_Holder == id) {
                    status_detach = "y";
                    Lock_Message = "Not locked";
                    MM1 = llListReplaceList(MM1, ["Lock 🔒"], 6, 6);
                } else {
                    errorMessage = "You need to hold the key to unlock";
                }
            }

            Menu = "Main";
            M_Call = TRUE;
        }

        else if (message == "Take Key 🔑" || message == "Leave Key 🔑") {
            string agentLink = "secondlife:///app/agent/" + (string)id + "/about";

            if (message == "Take Key 🔑") {
                if (Key_Status == TRUE) {
                    Key_Status = FALSE;
                    Key_Holder = id;
                    Key_Message = "The key is held by " + agentLink;
                    MM1 = llListReplaceList(MM1, ["Leave Key 🔑"], 7, 7);
                } else {
                    errorMessage = "Someone else is holding the key";
                }
            } else if (Key_Holder == id) {
                Key_Status = TRUE;
                Key_Holder = NULL_KEY;
                Key_Message = "It's Available";
                MM1 = llListReplaceList(MM1, ["Take Key 🔑"], 7, 7);
            } else {
                errorMessage = "You don't have the key, someone else is holding it";
            }

            Menu = "Main";
            M_Call = TRUE;
        }


        // TEXTBOX_CHANNEL TRIGGER
        else if (channel == TEXTBOX_CHANNEL){
            
            if ( llLinksetDataRead("_ur:"+(string)id) == "MAIN_MENU/ TIMER/"){


                list split = llParseString2List(message, [" "], []);
                integer sec_total = 0;
                integer a;
                
                for  (a=0 ; a < llGetListLength(split); a++){

                    string value = llList2String (split, a );
                    string number = llGetSubString(value, 0, -2);
                    string letter = llGetSubString(value, -1, -1);

                    if (letter == "d"){ sec_total += (integer)number *24*60*60;}
                    else if (letter == "h"){ sec_total += (integer)number *60*60;}
                    else if (letter == "m"){ sec_total += (integer)number *60;}
                    else if (letter == "s"){ sec_total += (integer)number;}
                }

                Timer_in_seconds = sec_total;
                TimeLockDuration = sec_total;
                Menu = "Timer";
                M_Call= TRUE;
                //llOwnerSay(sec_to_time(sec_total));

            }




            

            else if ( llSubStringIndex(llLinksetDataRead("_ur:"+(string)id), "MAIN_MENU/ ACCESS/ ADDING/") != -1 || llSubStringIndex(llLinksetDataRead("_ur:"+(string)id), "MAIN_MENU/ ACCESS/ REMOVING/") != -1 ){
                if ( llSubStringIndex(llLinksetDataRead("_ur:"+(string)id), "MAIN_MENU/ ACCESS/ ADDING/") != -1){

                    target_key = llGetSubString( llLinksetDataRead("_ur:"+(string)id), 27,-2);
                    
                }
                else{
                    target_key = llGetSubString( llLinksetDataRead("_ur:"+(string)id), 29,-2);
                    
                }

                if ((key)message != NULL_KEY) 
                {   
                    if ( llSubStringIndex(llLinksetDataRead("_ur:"+(string)id), "MAIN_MENU/ ACCESS/ ADDING/") != -1){
                        Add_Target =(key)message;
                        Add_Call = TRUE;
                        
                    }
                    else{
                        Del_Target =(key)message;
                        Del_Call = TRUE;
                        
                    }
                           
                    Menu = "Access";
                    M_Call= TRUE;
                    
                    
                }
                else {
                    
                    errorMessage ="The introduced value is not a valid key, please try again";
                    TextBox_target = id;
                    S_Call = TRUE;
                    
                }
            }
        }

        

        else if (message == "[Key Taken]")
        {    
            string menu;
            if ((llListFindList(llCSV2List(llLinksetDataRead("Owners")), [(string)id])) != -1 ){
                menu ="Key_Summoning";
                
            }
            else{
                menu = "Main";
            }

            Menu = "Main";
            M_Call= TRUE;
            
                
        }

        else if (message == "Summon Key" )
        {
            Key_Holder = NULL_KEY ;
            Key_Status = TRUE;
            Key_Message ="It's Available";
            MM1 = llListReplaceList(MM1, ["Take Key 🔑"], 7, 7); 
            
            Menu = "Main";
            M_Call= TRUE;
              
        }
        
        else if (message == "Settings" )
        {
            Menu = "Settings";
            M_Call= TRUE;
              
        }

        else if (message == "Timer ⏰" )
        {
            Menu = "Timer";
            M_Call= TRUE;
              
        }

        else if (message == "🔺 Close" && llSubStringIndex(llLinksetDataRead("_ur:"+(string)id), "MAIN_MENU/ ACCESS/ ADDING/") == -1)
        {
            
            Menu = "Main";
            M_Call= TRUE;
                
        }

        else if (llLinksetDataRead("_ur:"+(string)id) == "MAIN_MENU/ TIMER/"){

            if (message == "Set Timer"){
                
                TB_message = "\n"+"Path: " + llLinksetDataRead("_ur:"+(string)id) + "\n"+ "\n"; 
                TB_message += "Please add the time in the next format :"+
                            "\n"+"d- days/ h-hours/ m-minutes/ s- seconds"+
                            "\n"+"As a example : 1h 15m 59s";
                TB_Call = TRUE;
            }

            else if (message == "Start Timer"){

                if (Timer_Mode == "Online"){
                    
                    onlineTimeLockStarted = llGetTime();
                    //llSetTimerEvent(1.0);
                    onlineTimeLockEnabledTimer = TRUE;
                    

                }
                else{

                    
                    onlineTimeLockStarted = llGetUnixTime();
                    realTimeLockEnabledTimer = TRUE;

                }


                llSetTimerEvent(1.0);
                M_Timer_1= llListReplaceList(M_Timer_1, ["Stop Timer"], 3, 3);

                Menu = "Timer";
                M_Call= TRUE;

            }

            else if (message == "RealTime ✖" || message == "RealTime ✔️") {

                if (message == "RealTime ✖"){

                    if (onlineTimeLockEnabledTimer){

                        onlineTimeLockEnabledTimer = FALSE;
                        llSetTimerEvent(0.0);

                        float timeleft = TimeLockDuration - llGetTime();
                        onlineTimeLockStarted = llGetUnixTime(); 
                        TimeLockDuration = timeleft;
                        llSetTimerEvent(1);

                        realTimeLockEnabledTimer = TRUE;
                        M_Timer_1= llListReplaceList(M_Timer_1, ["RealTime ✔️"], 6, 6);
                        Timer_Mode = "RealTime";



                    }
                    else {
                        M_Timer_1 = llListReplaceList(M_Timer_1, ["RealTime ✔️"], 6, 6);
                        Timer_Mode = "RealTime";
                    }
     
                }
                else{
                    
                    if (realTimeLockEnabledTimer){

                        realTimeLockEnabledTimer = FALSE;
                        llSetTimerEvent(0.0);

                        float timeleft = TimeLockDuration - llGetUnixTime();

                        
                        onlineTimeLockStarted = llGetTime(); 
                        TimeLockDuration = timeleft;
                        llSetTimerEvent(1);

                        onlineTimeLockEnabledTimer = TRUE;
                        M_Timer_1 = llListReplaceList(M_Timer_1, ["RealTime ✖"], 6, 6);
                        Timer_Mode = "Online";

                        
                    }
                    else {
                        M_Timer_1= llListReplaceList(M_Timer_1, ["RealTime ✖"], 6, 6);
                        Timer_Mode = "Online";

                    }
                    
                }

                
                Menu = "Timer";
                M_Call= TRUE;
                llOwnerSay(Timer_Mode);
            }



        }

        else if (llLinksetDataRead("_ur:"+(string)id) == "MAIN_MENU/ ACCESS/")
        {
            /*
            if ( message == "Show Owners" || message == "Show Trusted" || message == "Show Blacklist" ){
                string storageKey =llGetSubString(message, 5, -1 );
                list TempList = llCSV2List(llLinksetDataRead(storageKey));
                integer Length = llGetListLength(TempList);
                integer a;
                string text = " \n"+ storageKey +" :\n~~~~~~~~~~~~~~~~";
                if (Length != 0) {
                    for (a = 0; a < Length; ++a) {
                        string user = llList2String(TempList, a);
                        if (user != "") {  text += "\n    secondlife:///app/agent/" + user + "/about";
                        }
                    }
                    text += "\n~~~~~~~~~~~~~~~~";
                    llRegionSayTo(id, 0, text);
                } else {
                    llRegionSayTo(id, 0,"The list is empty.");
                }
                
                Menu = "Access";
                M_Call= TRUE;
            }
            */

            if ( message == "➕ Owners" || message == "➕ Trusted" ||  message == "➕ Blacklist"){
                string PATH ="MAIN_MENU/ ACCESS/ ADDING/";
                TextBox_target = id;
                ActualMenu= message;
                PATH += " "+llGetSubString(ActualMenu, 2, -1)+"/";
                Sensor_Requests += [id];
                Sensor_Requests += [""];
                S_Call = TRUE;
                llLinksetDataWrite("_ur:"+(string)id, PATH);

                

            }
            
            else if ( message == "Blacklist ✖" || message == "Trusted ✖" || message == "Owners ✖" ){
                string PATH ="MAIN_MENU/ ACCESS/ REMOVING/";
                ActualMenu = message;
                D_Call = TRUE;
                PATH +=  " "+llGetSubString(ActualMenu, 0, -3)+"/";
                Cycles_menu = 1;
                llLinksetDataWrite("_ur:"+(string)id, PATH);

                

            }
            

        }


        else if (llSubStringIndex(llLinksetDataRead("_ur:"+(string)id), "MAIN_MENU/ ACCESS/ ADDING/") != -1)
        {       
                if ( message == "🔁 Re-Scan" ){
                    //TextBox_target = id;
                    Sensor_Requests += [id];
                    Sensor_Requests += [""];
                    S_Call = TRUE;
                    
                    
                }
                else if ( message == "↩ Close" ){

                    ActualMenu= "Access" ;
                    Menu = ActualMenu;
                    M_Call= TRUE;

                
                }
                else if ( message == "Manual Input" ){

                    TB_message = "Please writte the key of the avatar u want to introduce: ";
                    TB_Call = TRUE;
                    
                }

                else if ( message == "-"){
                    //TextBox_target = id;
                    Sensor_Requests += [id];
                    Sensor_Requests  += [""];
                    S_Call = TRUE;
                }

                else {
                    Sensor_Requests += [id];
                    Sensor_Requests += [message];
                    S_Call = TRUE;
                    //llOwnerSay((string)message);
                }
            


        }

        else if (llSubStringIndex(llLinksetDataRead("_ur:"+(string)id), "MAIN_MENU/ ACCESS/ REMOVING/") != -1)
        {
            target_key = llGetSubString( llLinksetDataRead("_ur:"+(string)id), 29,-2);
            
            integer list_lenght =llGetListLength(llCSV2List(llLinksetDataRead(target_key)));
            integer Cycles_menu_max = llCeil(((float)list_lenght/6.0 ));
            
            integer a;
                for (a = 1; a < 7; ++a){

                    if (message == (string)a ){
                        if (list_lenght > (a-1)){

                            list detected_keys = llCSV2List(llLinksetDataRead(target_key));
                            Del_Target =llList2Key(detected_keys,  (a-1 + ((integer)Cycles_menu-1)*6));
                            Del_Call = TRUE;
                            
                            Menu = "Access";
                            M_Call= TRUE;

                        }
                        else {
                            
                            errorMessage = "That's not an available option";
                            D_Call = TRUE;
                            
                        }                              
                    }
                }
                
                if ( message == "↩ Close" ){

                    ActualMenu= "Access" ;
                    Menu = ActualMenu;
                    M_Call= TRUE;

                }
                else if ( message == "Manual Input" ){

                    TB_message = "Please writte the key of the avatar u want to remove: ";
                    TB_Call = TRUE;
                    

                }

                else if ( message == ">>>" || message == "<<<" ){
                    if ( message == ">>>" ){
                        if ( (Cycles_menu +1) <= (integer)Cycles_menu_max ){
                            Cycles_menu += 1 ;
                            if ((Cycles_menu +1) != 1){
                            substract_buttons = llListReplaceList(substract_buttons, ["<<<"], 0, 0);
                            }
                        }
                    }
                    else if ( message == "<<<" ){
                        if ( (Cycles_menu - 1) > 0 ){
                            Cycles_menu -= 1 ;
                            if ((Cycles_menu) == 1){
                                substract_buttons = llListReplaceList(substract_buttons, ["Manual Input"], 0, 0);
                            }
                        }
                    }
                    D_Call = TRUE;
                    
                }   
        }
        

        else if (message == "-")
        {   
            
            Menu = ActualMenu;
            M_Call= TRUE;
            
        }

        else
        {
            llOwnerSay("You selected: " + message);
        }


        
        // Textbox Dialogue Call
        if (TB_Call){llTextBox( id,TB_message,TEXTBOX_CHANNEL);}
        // Sensor Call
        if (S_Call){
            //Sensor_Requests += [id];
            llSensor("", NULL_KEY, AGENT_BY_LEGACY_NAME, 20.0, PI);
        }

        // Handles the dialogue to delete keys from the data_links
        if (D_Call){
            
            string targetmenu = llGetSubString( llLinksetDataRead("_ur:"+(string)id), 29,-2);;
            
            list detected = llCSV2List(llLinksetDataRead(targetmenu));
            integer Lenght = llGetListLength(detected);
            string text = "Select the avatar you want to remove"+"\n-----------------------";
            integer limit;
            if (Lenght <= (Cycles_menu * 6 -1)){
                limit = Lenght;
            }else{
                limit = Cycles_menu * 6 -1;
            }

            integer a;
            integer b = 1 ;
            for (a= 0 + ((Cycles_menu-1) * 6) ; a <= (limit); ++a)
            {   
                if (llList2String(detected, a) != "") {  
                text += "\n "+(string)(b) + ")  " +"secondlife:///app/agent/" + llList2String(detected, a) + "/about";
                b += 1;
                }
            }

            llDialog(id,text, substract_buttons, DIALOG_CHANNEL);}
        
        // Handles all the adding and deleted calls inside the listsener, so i don't need to be hadled out of it
        if (Add_Call || Del_Call){

            list Data;
            string check_list = (llLinksetDataRead(target_key));  
           
            if (check_list ==""){
                Data = [];
            }else {
                Data =llCSV2List(check_list);
            }
            integer index;
            if (Add_Call){index = llListFindList(Data, [(string)Add_Target]);}
            if (Del_Call){index = llListFindList(Data, [(string)Del_Target]);}
            
             if (index != -1) {
                if (Add_Call){errorMessage = "The avatar is already on the list";}
                if (Del_Call){Data = llDeleteSubList(Data, index, index);}
                
            } else {
                if (Add_Call){Data += [Add_Target];}
                if (Del_Call){errorMessage = "The avatar isn't on the list";}
                
            }

            llLinksetDataWrite(target_key, llList2CSV(Data));  
        }

        llRegionSayTo( id , 0 , errorMessage);
        if (M_Call){showMenu(Menu,id);}  
    }

    sensor(integer num_detected)
    {
        integer requests_lenght;
        integer Lenght_Requests = llGetListLength(Sensor_Requests);
        
        for (requests_lenght=0 ; requests_lenght < Lenght_Requests; requests_lenght +=2 ){
            
            string name =  llList2String(Sensor_Requests, requests_lenght +1);
            if (name== ""){

                list S_buttons = ["🔁 Re-Scan","↩ Close","Manual Input"];
                integer Lenght = 6;
                integer a = 0;
                string text = "Select the avatar you want to add"+"\n-----------------------";

                for (a = 0; a < (Lenght); ++a)
                {
                    if (llDetectedKey(a) != NULL_KEY){
                        text += "\n "+(string)(a+1) + ")  " + "secondlife:///app/agent/" + (string)llDetectedKey(a) + "/about";
                        S_buttons += llGetSubString(buttonLabel(llDetectedName(a)), 0, -9);
                    }
                    else{
                        S_buttons +=  "-";
                    }
                }

                llDialog(llList2Key(Sensor_Requests,requests_lenght), text, S_buttons, DIALOG_CHANNEL);
            
            }
            else {

                integer Lenght = 6;
                integer a = 0;

                for (a = 0; a < (Lenght); ++a)
                {
                    if (llGetSubString(buttonLabel(llDetectedName(a)), 0, -9) == name){


                        string target_user = "_ur:" + llList2String(Sensor_Requests,requests_lenght);
                        //llOwnerSay((string)target_user);

                        string target_key = llGetSubString( llLinksetDataRead(target_user), 27,-2);
                        //llOwnerSay (target_key);
                        list Data;

                        string check_list = (llLinksetDataRead(target_key));  
                        
                        
                        if (check_list ==""){
                            Data = [];
                        }else {
                            Data =llCSV2List(check_list);
                        }
                        integer index;
                        index = llListFindList(Data, [(string)llDetectedKey(a)]);
                        

                        if (index != -1) {
                            llRegionSayTo( llList2Key(Sensor_Requests,requests_lenght) , 0 , "The avatar is already on the list");
                            //llOwnerSay ("The avatar is already on the list");
                            
                            
                        } else {
                            Data += [llDetectedKey(a)];
                            
                        }

                        llLinksetDataWrite(target_key, llList2CSV(Data));  
                        showMenu("Access",llList2Key(Sensor_Requests,requests_lenght));


                    }
                }

            }
        }

        Sensor_Requests = [];
    }

    link_message(integer sender, integer num, string message, key id)
    {
        if (num == 9001 && message == "return_to_main")
        {
            
            
            showMenu("Main",id);
        }
    }

    timer(){
        if (onlineTimeLockEnabledTimer){
            if (llGetTime() - onlineTimeLockStarted > TimeLockDuration){
                llOwnerSay("Unlocked");
                onlineTimeLockEnabledTimer = FALSE;
                llSetTimerEvent(0.0);
                unlock_timer();
                

            }
        }

        if (realTimeLockEnabledTimer){
            if ( llGetUnixTime() - onlineTimeLockStarted > TimeLockDuration ){
                llOwnerSay("Unlocked");
                realTimeLockEnabledTimer = FALSE;
                llSetTimerEvent(0.0);
                unlock_timer();
            }
        }
    }

}
