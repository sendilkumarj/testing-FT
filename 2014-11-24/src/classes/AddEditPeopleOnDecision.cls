/*  
 Created by:Phaniraj 
 Last Modified by: Phaniraj
 Style: Force.com & Metro
 Description: This class is written to add/edit people to parent object - Plan or Decision
     
*/
public with sharing class AddEditPeopleOnDecision{
    
	public Id recId{get;set;}
    public String objType{get;set;}
    public social_Input__c myRole {get;set;}
    public string headerName{get;set;}
    public string decisionPhase{get;set;}
    public Decision__c decisionData{get;set;}
    public List<Social_Input__c> existingPeopleList = new List<Social_Input__c>();
    set<Id> existingUserId = new set<Id>();
    
    public map<Id, List<string>> generalGroupMemberMap = new map<Id, List<string>>();
    
    // JSON string initialization for search table 
    public static string searchedUserJSON{get;set;}
    
    GeneralInformation generalInfo = new GeneralInformation();
    
    public List<SocialInputWrapper> existingPeopleWrapperList{get;set;}

    public AddEditPeopleOnDecision(){
    	try{
     		recId = ApexPages.currentPage().getParameters().get('id');		
     		objType = ApexPages.currentPage().getParameters().get('objType');
     		myRole = new Social_Input__c ();
     		existingPeopleWrapperList = new List<SocialInputWrapper>();
     		if(objType == 'Decision'){
                decisionData = [select id,Title__c,Phase__c,Add_C_I_Members__c from Decision__c where Id = : recId];
                existingPeopleList = [select Id,User__r.isActive,GroupId__c,Role__c,Is_Group__c, Group_Name__c,Name_of_the_User__c  ,Decision__r.Title__c, User__c,user__r.name,Accountable__c,Backup_for_Accountable__c, Consulted__c,Responsible__c, Informed__c,Veto_Rights__c,Role_Acceptance_Required__c,Description__c,Decision__r.name from Social_Input__c where Decision__c =: recId];    
                decisionPhase = decisionData.Phase__c;
                for(Social_Input__c s: existingPeopleList){
                	if(s.User__c == userInfo.getUserId())
                		myRole = s;		
                }
                //if([Select id From Social_Input__c s where s.Decision__c =: decisionData.Id AND s.User__c =: userInfo.getUserId() limit 1].size() == 1) {
                    //myRole =[select id,Name,owner.Profile.name,Role__c,Accountable__c,Consulted__c,Informed__c,Backup_for_Accountable__c,Veto_Rights__c,Responsible__c from Social_Input__c where User__c =: userInfo.getUserId() AND  Decision__c =: recId ];
                //}
                headerName = existingPeopleList[0].Decision__r.Title__c;
            }
            
            map<Id,Group> groupList = new map<Id,Group>([select id from Group where Name != null]);
            for(GroupMember groupMember : [Select g.UserOrGroupId, g.Id, g.GroupId From GroupMember g where g.GroupId In: groupList.keyset()]) {
                List<String> groupMemberList = generalGroupMemberMap.get(groupMember.GroupId);
                if(groupMemberList == null) {
                    groupMemberList = new List<String>();
                    generalGroupMemberMap.put(groupMember.GroupId, groupMemberList);
                }
                groupMemberList.add(groupMember.UserOrGroupId);
            }
            
            for(Social_Input__c si: existingPeopleList) {
                existingUserId.add(si.User__c);
                //if(si.GroupId__c != null){
                  //existingGroupId.add(si.GroupId__c);  
                //}
                SocialInputWrapper siw = new SocialInputWrapper();
                siw.socialRec = si;
                if(si.Is_Group__c){
                    List<String> userToStringList = new List<String>();
                    userToStringList = generalGroupMemberMap.get(si.GroupId__c);
                    siw.userFromGroup = listToStringConvert(userToStringList);
                    siw.groupName = generalInfo.groupMap.get(si.GroupId__c).Name;
                    siw.addedNewUser = 'oldUser';
                }
                
                existingPeopleWrapperList.add(siw);
            } 
            
     	}catch(Exception e){
     	
     	}  

     } 
     
     public String listToStringConvert(List<String> grpMemberList) {
        String UserName = '';
        Integer i = 0;
        for(String str : grpMemberList) {
            if(UserName == '') {
                UserName = generalInfo.useNameMap.get(str).Name;
            }
            else {
                if(i<4){
                    UserName = UserName + ',' + generalInfo.useNameMap.get(str).Name;
                    i++;
                }
            }
        }
        return  UserName;       
    }
     
     
     public Class SocialInputWrapper{
        public Social_Input__c socialRec{get;set;}
        //public List<String> usersFromGroupList{get;set;}
        public string addedNewUser{get;set;}
        public string userFromGroup{get;set;}
        public string groupName{get;set;}
    } 


}