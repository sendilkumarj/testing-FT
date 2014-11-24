public with sharing class DecisionTabClone {
	
	//Json for user data
	public String userDataJSON {get;set;} 
	// JSON string for default user 
    public String defaultUserJSON {get;set;}
    
    public DecisionTabClone(){
    	viewPeople();
    }
    
    public string viewPeople(){
        
        // List of user who are active
        List<User> userList = [select id, Name, SmallPhotoUrl  from User where isactive = true];
        
        // Initialize existing user list
        List<UserData> userDataJSONList = new List<UserData>();
        
        // Initialize default user list
        List<UserData> defaultUserJSONList = new List<UserData>();
        
        UserData defaultUser = new UserData();
        defaultUser.id = userinfo.getuserId();
        defaultUser.name =  String.escapeSingleQuotes(Userinfo.getName());
        defaultUserJSONList.add(defaultUser);
        // Mapping fileds for list of existing users
        Integer i=0;
        for(User u: userList){
            UserData existingUser = new UserData();
            existingUser.id = String.valueof(u.Id);
            existingUser.name =  String.escapeSingleQuotes(u.Name);
            existingUser.url = u.SmallPhotoUrl;
            userDataJSONList.add(existingUser);
        } 
        
        // serialize defaultUser and existingUser list
        defaultUserJSON = JSON.serialize(defaultUserJSONList);
       
        userDataJSON = JSON.serialize(userDataJSONList);
        
        return userDataJSON;
    }
    
    public void dummyMethod(){
        
    }
    
    //Wrapper class section
    public class UserData{
        public String id {get;set;}
        public String name{get;set;}
        public String url {get;set;}
    }
}