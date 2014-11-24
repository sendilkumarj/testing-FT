/*  
 Created by:Phaniraj 
 Last Modified by: Phaniraj
 Style: Force.com & Metro
 Description: This class is written to add/edit people to parent object - Plan or Decision
*/
public with sharing class AddEditPeopleClone{
    
    public List<SocialInputWrapper> existingPeopleWrapperList{get;set;}
   // 
    public List<Social_Input__c> existingPeopleList{get;set;}
    public List<User> allUsers{get;set;}
    public List<Id> existingPeopleId{get;set;}
    public List<userWrapperClass> userSearched{get;set;}
    public Id recId = ApexPages.currentPage().getParameters().get('id');
    public string headerName{get;set;}
    public string objType{get;set;}
    public string decisionPhase{get;set;}
    public Decision__c decisionData{get;set;}
    public Plan__c planData{get;set;}
    public Social_Input__c myRole{get;set;}
    public string message {get;set;}
    public List<social_Input__c> newPeopleToBeAdded{get;set;}
    public List<User> searchUserText{get;set;}
    public User[] userSearchedArray{get;set;}
    public String searchType{get;set;}
    set<Id> existingUserId = new set<Id>();
    set<Id> existingGroupId = new set<Id>();
    
    public Profile p{get;set;}
    
    set<ID> listToBeDeletedId = new set<Id>();
    List<Social_Input__c> listToBeDeletedSocialInput = new List<Social_Input__c>();
    
    public map<Id, List<string>> generalGroupMemberMap = new map<Id, List<string>>();
    
    // JSON string initialization for search table 
    public static string searchedUserJSON{get;set;}
    
    GeneralInformation generalInfo = new GeneralInformation();
    
    //constructor to retrieve existing people.    
    public AddEditPeopleClone(){
        try{
            existingPeopleWrapperList = new List<SocialInputWrapper>();
            newPeopleToBeAdded = new List<Social_Input__c>();
            objType = ApexPages.currentPage().getParameters().get('objType');
            searchUserText = new List<User>();
            userSearchedArray = new User[]{};
            p = [SELECT Name FROM Profile WHERE Id = :Userinfo.getProfileId()];
            system.debug('===============objType============='+objType);
            // get social input details of the decision
            if(objType == 'Decision'){
                decisionData = [select id,Title__c,Phase__c,Add_C_I_Members__c from Decision__c where Id = : recId];
                existingPeopleList = [select Id,GroupId__c,Role__c,Is_Group__c, Group_Name__c,Name_of_the_User__c  ,Decision__r.Title__c, User__c,user__r.name,Accountable__c,Backup_for_Accountable__c, Consulted__c,Responsible__c, Informed__c,Veto_Rights__c,Role_Acceptance_Required__c,Description__c,Decision__r.name from Social_Input__c where Decision__c =: recId];    
                decisionPhase = decisionData.Phase__c;
                if([Select id From Social_Input__c s where s.Decision__c =: decisionData.Id AND s.User__c =: userInfo.getUserId() limit 1].size() == 1) {
                    myRole =[select id,Name,owner.Profile.name,Role__c,Accountable__c,Consulted__c,Informed__c,Backup_for_Accountable__c,Veto_Rights__c,Responsible__c from Social_Input__c where User__c =: userInfo.getUserId() AND  Decision__c =: recId ];
                }
                headerName = existingPeopleList[0].Decision__r.Title__c;
            }
            // get social input details of the plan
            else if(objType == 'Plan'){
                planData = [select id,Add_C_I_Members__c from Plan__c where Id = : recId ];
                existingPeopleList = [select id,User__c,Role__c,Is_Group__c,GroupId__c,Name_of_the_User__c , Group_Name__c ,user__r.name,Accountable__c,Backup_for_Accountable__c, Consulted__c,Responsible__c, Informed__c,Veto_Rights__c,Role_Acceptance_Required__c,Description__c,Plan__r.name from Social_Input__c where Plan__c =: recId];    
                if([Select id From Social_Input__c s where s.Plan__c =: planData.Id AND s.User__c =: userInfo.getUserId() limit 1].size() == 1) {
                    myRole =[select id,Name,owner.Profile.name,Role__c,Accountable__c,Consulted__c,Informed__c,Responsible__c,Backup_for_Accountable__c,Veto_Rights__c from Social_Input__c where User__c =: userInfo.getUserId() AND  Plan__c =: recId ];
                }
                headerName = existingPeopleList[0].Plan__r.name;
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
                if(si.GroupId__c != null){
                  existingGroupId.add(si.GroupId__c);  
                }
                SocialInputWrapper siw = new SocialInputWrapper();
                siw.socialRec = si;
                if(si.Is_Group__c){
                    List<String> userToStringList = new List<String>();
                    userToStringList = generalGroupMemberMap.get(si.GroupId__c);
                    siw.userFromGroup = listToStringConvert(userToStringList);
                    siw.groupName = generalInfo.groupMap.get(si.GroupId__c).Name;
                }
                
                existingPeopleWrapperList.add(siw);
            } 
            system.debug('===============existingPeopleWrapperList============='+existingPeopleWrapperList.size());
            
        }catch(Exception e){}        
    }
    
    // search new users or groups
    public pageReference searchUsers(){
        userSearched = new List<userWrapperClass>();
        userSearched.clear();
        userSearchedArray.clear();
        String searchText = ApexPages.currentPage().getParameters().get('searchText');
        searchType = ApexPages.currentPage().getParameters().get('searchType');
        
        System.debug('---------------->srch txt'+searchText);
        
        if(searchText != ''){
            if(searchText.contains('*')){
                String SearchtextList=searchText.replaceAll('\\*','\\%');
                searchText = SearchtextList;
            }
        }
        
        if(searchType == 'User') {
            if(searchText != ''){
                userSearchedArray = [select id, Name, firstname, Department from User where Id not In: existingUserId and isActive=true and (firstname like: searchText or lastname like: searchText ) Order By firstName limit 100];
            }
            else{
                userSearchedArray = [select id, Name, firstname, Department from User where Id not In: existingUserId and isActive=true Order By firstName limit 100];
            }
            if(userSearchedArray.size() > 0){
                for(User u:userSearchedArray){
                    userWrapperClass wr = new userWrapperClass();
                    wr.selectUser = false;
                    wr.userId = u.Id;
                    wr.userName = u.Name;
                    wr.dept = u.department;
                    wr.addedFromGroup = false;
                    wr.userImage = generalInfo.useImage.get(u.Id);
                    wr.userNameList = '';
                    wr.redirectUrl = 'User';
                    userSearched.add(wr);   
                }
                searchedUserJSON = JSON.serialize(userSearched);
            }
        }
        // search groups
        else {
            List<Group> userGroupList = new List<Group>();
            if(searchText != ''){
                userGroupList = [select id, Name from Group where Id not In: existingGroupId and Name like: searchText Order By Name limit 100];
            }
            else{
                userGroupList = [select id,  Name from Group where Id not In: existingGroupId Order By Name limit 100];
            }
            map<Id,List<String>> groupMembermap = new map<Id,List<String>>();
            for(GroupMember gruopMember : [Select g.UserOrGroupId, g.Id, g.GroupId From GroupMember g where g.GroupId not In: existingGroupId ]) {
                List<String> groupMemberLIst = groupMembermap.get(gruopMember.GroupId);
                if(groupMemberLIst == null) {
                    groupMemberLIst = new List<String>();
                    groupMembermap.put(gruopMember.GroupId, groupMemberLIst);
                }
                groupMemberLIst.add(gruopMember.UserOrGroupId);
            }
            if(userGroupList.size() > 0){
                for(Group u : userGroupList){
                    if(u.Name != null) {
                        userWrapperClass wr = new userWrapperClass();
                        wr.selectUser = false;
                        wr.userId = u.id;
                        wr.userName = u.Name;
                        wr.addedFromGroup = true;
                        wr.userImage = '/'+generalInfo.imageUrlMap.get('group');
                        wr.userNameList = listToStringConvert(groupMembermap.get(u.Id));
                        wr.userGruopId = u.Id;
                        wr.redirectUrl = 'Group';
                        userSearched.add(wr);
                    }   
                }
                searchedUserJSON = JSON.serialize(userSearched);
            }
        }
        
        if(userSearched.size() == 0 && (searchType == 'User' || searchType == 'Group') ){
            return null;
        }else if(userSearched.size() > 0 && searchType == 'Group'){
            message ='Members of selected groups will be expanded and added as individual contributors';
        }else{
        
        }
        return null;
    }
    
    //get the adding tyope (user or group) and pass to approiate method
    public void addingUserBasedOnType(){ 
        String selectedUserId = ApexPages.currentPage().getParameters().get('selectedUsers');   
        String userType = ApexPages.currentPage().getParameters().get('userType');  
        String addingAsInformed = ApexPages.currentPage().getParameters().get('addingAsInformed');
        String addingAsResponsible = ApexPages.currentPage().getParameters().get('addingAsResponsible');
        String addingAsConsulted = ApexPages.currentPage().getParameters().get('addingAsConsulted');
        String[] selectedUsersToSplit = selectedUserId.split(',');
        List<ID> selectedUserIdList = new List<Id>();
        for(Integer i = 0; i<selectedUsersToSplit.size();i++)   {
            selectedUserIdList.add(selectedUsersToSplit[i]);
        }
        addedUser(selectedUserIdList,userType,addingAsInformed,addingAsResponsible,addingAsConsulted);
    }
   
    
    // add users from search table. If a group is added, then extract people from there who doesn't exist in the existing social inputs
    public pageReference addedUser(List<Id> userIdList,String userType,String addingAsInformed,String addingAsResponsible,String addingAsConsulted){
        message = '';
        if(userType == 'User'){
            for(Integer i = 0 ;i < userIdList.size(); i++){
            //for(Id wr:userIdList){
                Social_Input__c s = new Social_Input__c();
                s.Select_People__c = false;
                s.User__c = userIdList[i];
                s.Name_of_the_User__c = generalInfo.useNameMap.get(userIdList[i]).Name;
                s.Accountable__c = false;
                s.Backup_for_Accountable__c = false;
                if(addingAsConsulted == 'consultedReqd'){
                  s.Consulted__c = true;
                }
                if(addingAsInformed == 'informedReqd'){
                  s.Informed__c = true;
                }
                if(addingAsResponsible == 'responsibleReqd'){
                  s.Responsible__c = true;
                }
                s.Description__c = '';
                s.Veto_Rights__c = false;
                s.Role_Acceptance_Required__c = false;
                if(objType == 'Decision'){
                    s.Decision__c = recId;
                }else if(objType == 'Plan'){
                    s.Plan__c = recId;
                }
                existingPeopleList.add(s);
                existingUserId.add(s.User__c);
                SocialInputWrapper siw = new SocialInputWrapper();
                siw.socialRec = s;
                existingPeopleWrapperList.add(siw);
            }
        }
        
        if(userType == 'Group' && (addingAsResponsible == 'responsibleReqd' || addingAsConsulted == 'consultedReqd')){
            for(GroupMember gruopMember : [Select g.UserOrGroupId, g.Id, g.GroupId From GroupMember g where g.GroupId In: userIdList]) {
                if(!existingUserId.contains(gruopMember.UserOrGroupId)) {
                    Social_Input__c s = new Social_Input__c();
                    s.Select_People__c = false;
                    s.User__c = gruopMember.UserOrGroupId;
                    s.Name_of_the_User__c = generalInfo.useNameMap.get(gruopMember.UserOrGroupId).Name;
                    s.Accountable__c = false;
                    s.Backup_for_Accountable__c = false;
                    if(addingAsResponsible == 'responsibleReqd'){
                        s.Responsible__c = true;
                    }else{
                        s.Responsible__c = false;   
                    }
                    if(addingAsConsulted == 'consultedReqd'){
                        s.Consulted__c = true;
                    }else{
                        s.Consulted__c = false; 
                    }
                    s.Informed__c = false;
                    s.Description__c = '';
                    s.Veto_Rights__c = false;
                    s.Role_Acceptance_Required__c = false;
                    s.Group_Name__c = 'added from '+generalInfo.groupMap.get(gruopMember.GroupId).Name+' Group';
                    s.GroupId__c = gruopMember.GroupId;
                    if(objType == 'Decision'){
                        s.Decision__c = recId;
                    }else if(objType == 'Plan'){
                        s.Plan__c = recId;
                    }
                    existingGroupId.add(gruopMember.GroupId);
                    existingPeopleList.add(s);
                    existingUserId.add(s.User__c);
                    SocialInputWrapper siw = new SocialInputWrapper();
                    siw.socialRec = s;
                    existingPeopleWrapperList.add(siw);
                }else for(Integer i= 0; i <existingPeopleWrapperList.size(); i++){
                  if(existingPeopleWrapperList[i].socialRec.User__c == gruopMember.UserOrGroupId){
                    if(objType == 'Decision'){
                      if(addingAsResponsible == 'responsibleReqd'  && (decisionData.Phase__c == 'Share' || decisionData.Phase__c == 'Draft')){
                            existingPeopleWrapperList[i].socialRec.Responsible__c = true;
                        }
                        if(addingAsConsulted == 'consultedReqd' && (decisionData.Phase__c == 'Share' || decisionData.Phase__c == 'Draft')){
                            existingPeopleWrapperList[i].socialRec.Consulted__c = true;
                        }
                    }else if(objType == 'Plan'){
                      if(addingAsResponsible == 'responsibleReqd'){
                            existingPeopleWrapperList[i].socialRec.Responsible__c = true;
                        }
                        if(addingAsConsulted == 'consultedReqd'){
                            existingPeopleWrapperList[i].socialRec.Consulted__c = true;
                        }
                    }else{}
                    existingPeopleWrapperList[i].socialRec.Group_Name__c = 'added from '+generalInfo.groupMap.get(gruopMember.GroupId).Name+' Group';
                    existingPeopleWrapperList[i].socialRec.GroupId__c = gruopMember.GroupId;    
                  }  
                } 
            }
            
            for(Integer i = 0 ;i < userIdList.size(); i++){
              Social_Input__c s = new Social_Input__c();
                s.Select_People__c = false;
                //s.User__c = userIdList[i];
                //s.Name_of_the_User__c = generalInfo.groupMap.get(userIdList[i]).Name;
                s.Accountable__c = false;
                s.Backup_for_Accountable__c = false;
                s.Consulted__c = false;
                s.Informed__c = true;
                s.Description__c = '';
                s.Responsible__c = false;
                s.Veto_Rights__c = false;
                s.Role_Acceptance_Required__c = false;
                s.Group_Name__c = 'added from '+generalInfo.groupMap.get(userIdList[i]).Name+' Group';
                s.GroupId__c = userIdList[i];
                s.Is_Group__c = true;
                if(objType == 'Decision'){
                    s.Decision__c = recId;
                }else if(objType == 'Plan'){
                    s.Plan__c = recId;
                }
                existingGroupId.add(userIdList[i]);
                existingPeopleList.add(s);
                //existingUserId.add(s.User__c);
                SocialInputWrapper siw = new SocialInputWrapper();
                siw.socialRec = s;
                List<String> userToStringList = new List<String>();
                userToStringList = generalGroupMemberMap.get(userIdList[i]);
                siw.userFromGroup = listToStringConvert(userToStringList);
                siw.groupName = generalInfo.groupMap.get(userIdList[i]).Name;
                existingPeopleWrapperList.add(siw);
          }
        }
        
        if(userType == 'Group' && addingAsResponsible != 'responsibleReqd' && addingAsConsulted != 'consultedReqd' && addingAsInformed == 'informedReqd'){
            for(Integer i = 0 ;i < userIdList.size(); i++){
              Social_Input__c s = new Social_Input__c();
                s.Select_People__c = false;
                s.Name_of_the_User__c = generalInfo.groupMap.get(userIdList[i]).Name;
                s.Accountable__c = false;
                s.Backup_for_Accountable__c = false;
                s.Consulted__c = false;
                s.Informed__c = true;
                s.Description__c = '';
                s.Responsible__c = false;
                s.Veto_Rights__c = false;
                s.Role_Acceptance_Required__c = false;
                s.Group_Name__c = 'added from '+generalInfo.groupMap.get(userIdList[i]).Name+' Group';
                s.GroupId__c = userIdList[i];
                s.Is_Group__c = true;
                if(objType == 'Decision'){
                    s.Decision__c = recId;
                }else if(objType == 'Plan'){
                    s.Plan__c = recId;
                }
                existingGroupId.add(userIdList[i]);
                existingPeopleList.add(s);
                //existingUserId.add(s.User__c);
                SocialInputWrapper siw = new SocialInputWrapper();
                siw.socialRec = s;
                List<String> userToStringList = new List<String>();
                userToStringList = generalGroupMemberMap.get(userIdList[i]);
                siw.userFromGroup = listToStringConvert(userToStringList);
                siw.groupName = generalInfo.groupMap.get(userIdList[i]).Name;
                existingPeopleWrapperList.add(siw);
          }
        }
      userSearched.clear();
      return null;
    }
    
    public pageReference deletePeople(){
        String existType = ApexPages.currentPage().getParameters().get('existType');   
        String socialInputId = ApexPages.currentPage().getParameters().get('socialInputId');
        String userType = ApexPages.currentPage().getParameters().get('userType');  
        //Id recordId = ApexPages.currentPage().getParameters().get('recordsId');
        
        
        List<SocialInputWrapper> existingPeopleWrapperListClone = new List<SocialInputWrapper>();
        existingPeopleWrapperListClone.addAll(existingPeopleWrapperList);
        
        System.debug('--existType-----------socialInputId-------------'+existType+'--------------'+socialInputId+'--------------'+userType);
        
        
       
        
        for(Integer i=0;i<existingPeopleWrapperList.size(); i++){
            if(userType == 'User'){
                if(existingPeopleWrapperList[i].socialRec.User__c == socialInputId){
                    existingUserId.remove(socialInputId);
                    if(existType == 'Exist'){
                        listToBeDeletedId.add(existingPeopleWrapperList[i].socialRec.Id);           
                    }
                    existingPeopleWrapperList.remove(i);
                }
            }else{
                if(existingPeopleWrapperList[i].socialRec.GroupId__c == socialInputId && existingPeopleWrapperList[i].socialRec.User__c == null){
                    System.debug('--------social rec group to be deleted------------'+existingPeopleWrapperList[i].socialRec.GroupId__c);
                    existingGroupId.remove(socialInputId);
                    if(existType == 'Exist'){
                        listToBeDeletedId.add(existingPeopleWrapperList[i].socialRec.Id);           
                    }
                    existingPeopleWrapperList.remove(i);    
                }   
            }
        }
        for(Integer i= 0;i <existingPeopleList.size();i++){
            if(userType == 'User'){
                if(existingPeopleList[i].User__c == socialInputId){
                    existingPeopleList.remove(i);       
                }
            }else{
                if(existingPeopleList[i].GroupId__c == socialInputId){
                    existingPeopleList.remove(i);
                }   
            }   
        }
        
        return null;
    }
    
    public pageReference cancel(){
        pageReference page;
        if(objType == 'Decision'){
            page = new pageReference('/apex/DecisionView?id='+recId+'&sfdc.override=1&addCol=true');
        }
        if(objType == 'Plan'){
            page = new pageReference('/apex/PlanView?id='+recId+'&sfdc.override=1&addCol=true');
        }
        page.setRedirect(true);
        return page;
    }
    
    // Upsert the social inputs, and redirect to parent record
    public pageReference savePeople(){
        if(listToBeDeletedId.size() > 0){
            listToBeDeletedSocialInput = [Select s.Veto_Rights__c, s.User__c, s.Responsible__c, s.Informed__c, s.Id, s.Group_Name__c, s.GroupId__c, s.Consulted__c, s.Backup_for_Accountable__c, s.Accountable__c From Social_Input__c s where Id in: listToBeDeletedId];
            if(listToBeDeletedSocialInput.size() > 0){
                delete listToBeDeletedSocialInput;
            }
        }
        if(existingPeopleList.size() == 0){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'There has to be atleast one collaborator');
            ApexPages.addMessage(myMsg);
            return null;    
        }
        for(Social_input__c s:existingPeopleList){                                                                           
            if(s.Accountable__c == false && s.Responsible__c == false && s.Consulted__c == false && s.Informed__c == false && s.Backup_for_Accountable__c == false && s.Veto_Rights__c == false){
                 ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Every People/Collaborator should be assigned with a role.');
                 ApexPages.addMessage(myMsg);
                 return null;
            }
        }
        
        /*Boolean chkForAccountableCount = false;
        for(Social_input__c s:existingPeopleList){                                                                           
            if(s.Accountable__c){
                chkForAccountableCount = true;
                //break;      
            }
        }
        System.debug('sfdsfdsfdsfdsfdsfdsfdsfds'+chkForAccountableCount);
        if(!chkForAccountableCount){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Atleast one collaborator should be accountable.');
            ApexPages.addMessage(myMsg);
            return null;    
        }*/
        
        pageReference page;
        if(objType == 'Decision'){
          if(p.Name != 'System Administrator'){
              if(myRole.Accountable__c || myRole.Responsible__c || myRole.Backup_for_Accountable__c){
                  update decisionData;
              }
          }
            page = new pageReference('/apex/DecisionView?id='+recId+'&sfdc.override=1&addCol=true');
        }
        if(objType == 'Plan'){
          if(p.Name != 'System Administrator'){ 
              if(myRole.Accountable__c || myRole.Responsible__c || myRole.Backup_for_Accountable__c){
                  update planData;
              }
          }
            page = new pageReference('/apex/PlanView?id='+recId+'&sfdc.override=1&addCol=true');
        }
        if(Schema.sObjectType.Social_Input__c.fields.Accountable__c.isUpdateable() && Schema.sObjectType.Social_Input__c.fields.Accountable__c.isCreateable() && Schema.sObjectType.Social_Input__c.fields.Responsible__c.isUpdateable() && Schema.sObjectType.Social_Input__c.fields.Responsible__c.isCreateable() && Schema.sObjectType.Social_Input__c.fields.Consulted__c.isUpdateable() && Schema.sObjectType.Social_Input__c.fields.Consulted__c.isCreateable() && Schema.sObjectType.Social_Input__c.fields.Informed__c.isUpdateable() && Schema.sObjectType.Social_Input__c.fields.Informed__c.isCreateable() && Schema.sObjectType.Social_Input__c.fields.Backup_for_Accountable__c.isUpdateable() && Schema.sObjectType.Social_Input__c.fields.Backup_for_Accountable__c.isCreateable() && Schema.sObjectType.Social_Input__c.fields.Veto_Rights__c.isUpdateable() && Schema.sObjectType.Social_Input__c.fields.Veto_Rights__c.isCreateable() && Schema.sObjectType.Social_Input__c.fields.User__c.isCreateable() && Schema.sObjectType.Social_Input__c.fields.User__c.isUpdateable() && Schema.sObjectType.Social_Input__c.fields.Name_of_the_User__c.isCreateable() && Schema.sObjectType.Social_Input__c.fields.Name_of_the_User__c.isUpdateable() && Schema.sObjectType.Social_Input__c.fields.Description__c.isCreateable() && Schema.sObjectType.Social_Input__c.fields.Description__c.isUpdateable() ) {
            List<Social_Input__c> existingPeopleList1 = new List<Social_Input__c>();

            for( Social_Input__c socialInput: existingPeopleList) {
                
                if(!listToBeDeletedId.contains(socialInput.Id)) {
                    Boolean info = true;
                    if(socialInput.Id == null && socialInput.Accountable__c) {
                        socialInput.Accountable__c = false;
                        if(socialInput.Informed__c == false) {
                            socialInput.Informed__c = true;
                            info = false;
                        }
                        insert socialInput;
                        socialInput.Accountable__c = true;
                        socialInput.Informed__c = info;
                        existingPeopleList1.add(socialInput);
                    }
                    else {
                        existingPeopleList1.add(socialInput);
                    }
                }
            }
            upsert existingPeopleList1;
        }
        
        page.setRedirect(true);
        return page;
    }
    
    // Upsert the social inputs, and redirect to parent record
    public pageReference saveCurrentPeople(){
        if(listToBeDeletedId.size() > 0){
            listToBeDeletedSocialInput = [Select s.Veto_Rights__c, s.User__c, s.Responsible__c, s.Informed__c, s.Id, s.Group_Name__c, s.GroupId__c, s.Consulted__c, s.Backup_for_Accountable__c, s.Accountable__c From Social_Input__c s where Id in: listToBeDeletedId];
            if(listToBeDeletedSocialInput.size() > 0){
                Delete listToBeDeletedSocialInput;
            }
        }
        if(existingPeopleList.size() == 0){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'There has to be atleast one collaborator');
            ApexPages.addMessage(myMsg);
            return null;    
        }
        for(Social_input__c s:existingPeopleList){                                                                           
            if(s.Accountable__c == false && s.Responsible__c == false && s.Consulted__c == false && s.Informed__c == false && s.Backup_for_Accountable__c == false && s.Veto_Rights__c == false){
                 ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'Every People/Collaborator should be assigned with a role.');
                 ApexPages.addMessage(myMsg);
                 return null;
            }
        }
        
        /*Boolean chkForAccountableCount = false;
        for(Social_input__c s:existingPeopleList){                                                                           
            if(s.Accountable__c){
                chkForAccountableCount = true;
                //break;      
            }
        }System.debug('sfdsfdsfdsfdsfdsfdsfdsfds'+chkForAccountableCount);
        if(!chkForAccountableCount){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Atleast one collaborator should be accountable.');
            ApexPages.addMessage(myMsg);
            return null;    
        }*/
        
        pageReference page;
        if(objType == 'Decision'){
          if(p.Name != 'System Administrator'){
              if(myRole.Accountable__c || myRole.Responsible__c || myRole.Backup_for_Accountable__c){
                  update decisionData;
              }
          }
          page = new pageReference('/apex/AddEditPeopleOnDecision?id='+recId+'&ObjType=Decision');
        }
        if(objType == 'Plan'){
          if(p.Name != 'System Administrator'){ 
              if(myRole.Accountable__c || myRole.Responsible__c || myRole.Backup_for_Accountable__c){
                  update planData;
              }
          }
          page = new pageReference('/apex/AddEditPeopleOnDecision?id='+recId+'&ObjType=Plan');
        }
        if(Schema.sObjectType.Social_Input__c.fields.Accountable__c.isUpdateable() && Schema.sObjectType.Social_Input__c.fields.Accountable__c.isCreateable() && Schema.sObjectType.Social_Input__c.fields.Responsible__c.isUpdateable() && Schema.sObjectType.Social_Input__c.fields.Responsible__c.isCreateable() && Schema.sObjectType.Social_Input__c.fields.Consulted__c.isUpdateable() && Schema.sObjectType.Social_Input__c.fields.Consulted__c.isCreateable() && Schema.sObjectType.Social_Input__c.fields.Informed__c.isUpdateable() && Schema.sObjectType.Social_Input__c.fields.Informed__c.isCreateable() && Schema.sObjectType.Social_Input__c.fields.Backup_for_Accountable__c.isUpdateable() && Schema.sObjectType.Social_Input__c.fields.Backup_for_Accountable__c.isCreateable() && Schema.sObjectType.Social_Input__c.fields.Veto_Rights__c.isUpdateable() && Schema.sObjectType.Social_Input__c.fields.Veto_Rights__c.isCreateable() && Schema.sObjectType.Social_Input__c.fields.User__c.isCreateable() && Schema.sObjectType.Social_Input__c.fields.User__c.isUpdateable() && Schema.sObjectType.Social_Input__c.fields.Name_of_the_User__c.isCreateable() && Schema.sObjectType.Social_Input__c.fields.Name_of_the_User__c.isUpdateable() && Schema.sObjectType.Social_Input__c.fields.Description__c.isCreateable() && Schema.sObjectType.Social_Input__c.fields.Description__c.isUpdateable() ) {
            List<Social_Input__c> existingPeopleList1 = new List<Social_Input__c>();

            for( Social_Input__c socialInput: existingPeopleList) {
                
                if(!listToBeDeletedId.contains(socialInput.Id)) {
                    Boolean info = true;
                    if(socialInput.Id == null && socialInput.Accountable__c) {
                        socialInput.Accountable__c = false;
                        if(socialInput.Informed__c == false) {
                            socialInput.Informed__c = true;
                            info = false;
                        }
                        insert socialInput;
                        socialInput.Accountable__c = true;
                        socialInput.Informed__c = info;
                        existingPeopleList1.add(socialInput);
                    }
                    else {
                        existingPeopleList1.add(socialInput);
                    }
                }
            }
            upsert existingPeopleList1;
        }
        //upsert existingPeopleList
        page.setRedirect(true);
        return page;
       //return null;
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
    
    @RemoteAction
    public static String retrieveGroupMember(String GrupId) {
        GeneralInformation general = new GeneralInformation();
        
        
        List<UserGroupMemberList> UserGroupMemberList = new List<UserGroupMemberList>();
        
        for(GroupMember gruopMember : [Select g.UserOrGroupId, g.Id, g.GroupId From GroupMember g where g.GroupId =: GrupId]) {
            UserGroupMemberList userGroupMember = new UserGroupMemberList();
            userGroupMember.name = general.useNameMap.get(gruopMember.UserOrGroupId).Name;
            userGroupMember.userImage = general.useImage.get(gruopMember.UserOrGroupId);
            userGroupMember.department = general.useNameMap.get(gruopMember.UserOrGroupId).Department;
            UserGroupMemberList.add(userGroupMember);
        }
        return JSON.serialize(UserGroupMemberList);
    }
    
    public Class userWrapperClass{
        public boolean selectUser{get;set;}
        public String userName{get;set;}
        public String dept{get;set;}
        public String userId{get;set;}
        public String userGruopId{get;set;}
        public Boolean addedFromGroup {get;set;}
        public String userNameList {get;set;}
        public String redirectUrl{get;set;}
        public string userImage{get;set;}
    } 
    
    public Class SocialInputWrapper{
        public Social_Input__c socialRec{get;set;}
        //public List<String> usersFromGroupList{get;set;}
        public string userFromGroup{get;set;}
        public string groupName{get;set;}
    } 
    
    public Class UserGroupMemberList {
        public String name {get;set;}
        public String userImage {get;set;}
        public String department {get;set;}
        
    }  
}