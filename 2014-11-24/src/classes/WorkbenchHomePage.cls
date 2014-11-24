/*
 Created by:Phaniraj
 Last Modified by: Phaniraj
 Style: Force.com & Metro
 Description: This class is written to get all the users in the organization in the workbench
*/
public with sharing class WorkbenchHomePage{
    // Variable to diable the Enhance list in Activity Tab: --added on 02_03_2014
    public boolean isEnahanceListEnabled {get;set;}
    
    //public List<User> userList{get;set;}
    
    public  set<Id> accountableData;
    public String userDataJSON {get;set;} 
    
    // JSON string for default user 
    public String defaultUserJSON {get;set;}
    
    // 
    public String loggedInUserId {get;set;}
    
    public static GeneralInformation genralInfo;
    public static String dateFormat {get;set;}
    
    public Boolean isTopic {get; set;}
    
    public List<User> userList {get; set;}
    
    
    //constructor creates a list of all the users
    public WorkbenchHomePage(){
        //-- added on 02_02_2014 Start 
        isEnahanceListEnabled =false;
        //-- added on 02_02_2014 End
        
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=8');
        
        isTopic = false;
        userList = new List<User>();
        if(genralInfo == null ) {
            genralInfo  = new GeneralInformation();
        }
        dateFormat = genralInfo.MapValuesDateFormate();
        accountableData= new set<Id>(); 
        viewPeople();
    } 
    
    
     public string viewPeople(){
        
        
        
        // List of user who are active
        userList = [select id, Name, SmallPhotoUrl  from User where isactive = true and Id != : userInfo.getUserId()];
        
        // Initialize existing user list
        List<UserData> userDataJSONList = new List<UserData>();
        
        // Initialize default user list
        List<UserData> defaultUserJSONList = new List<UserData>();
        
        // Mapping fields for default user (That is accountable)
        loggedInUserId = userinfo.getuserId();
        
        UserData defaultUser = new UserData();
        defaultUser.id = userinfo.getuserId();
        defaultUser.name =  String.escapeSingleQuotes(Userinfo.getName());
        defaultUserJSONList.add(defaultUser);
        accountableData.add(userinfo.getuserId());
        System.debug('--------default user---------------------->' + defaultUserJSONList);
        // Mapping fileds for list of existing users
        Integer i=0;
        for(User u: userList){
            UserData existingUser = new UserData();
            existingUser.id = String.valueof(u.Id);
            existingUser.name =  String.escapeSingleQuotes(u.Name);
            existingUser.url = u.SmallPhotoUrl;
            userDataJSONList.add(existingUser);
        } 
        
        system.debug('-------user id--------'+accountableData);
        
        // serialize defaultUser and existingUser list
        defaultUserJSON = JSON.serialize(defaultUserJSONList);
       
        userDataJSON = JSON.serialize(userDataJSONList);
        
        return userDataJSON;
        
    }
    
    // Code to render topic workbench
    public void displayType(){
        isTopic = true;
    }
    
    public void dummyMethod(){
        
    }
    // added on  02_02_2014 to set the boolean value to to true to diaply the enahnced list
    // called by the onclick action of the icon on the activitytab page.
    public void  displayActivityTabEnhanceList(){
        if(isEnahanceListEnabled == false){    
            isEnahanceListEnabled =true;
        } else {
            isEnahanceListEnabled =false;
        }
        
        //return null;
    } 
    
    //Wrapper class section
    public class UserData{
        public String id {get;set;}
        public String name{get;set;}
        public String url {get;set;}
    }
    
}