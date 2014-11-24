/*  
 Created by:Phaniraj 
 Last Modified by: Phaniraj
 Style: Force.com & Metro
 Description: This class is written to add/edit people to parent object - Plan or Decision
     
*/
public with sharing class AddEditPeopleManju{
    
    // Properties for the entire class, usage of each property is defined below 
    public List<SocialInputWrapper> existingPeopleWrapperList{get;set;}
    public List<Social_Input__c> existingPeopleList{get;set;}
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
    public User[] userSearchedArray{get;set;}
    public String searchType{get;set;}
    set<Id> existingUserId = new set<Id>();
    set<Id> existingGroupId = new set<Id>();
    public set<Id> chkIfGrpExists = new set<Id>(); 
    public Profile p{get;set;}
    public map<id,boolean> userActiveMap = new map<id,boolean>();
    set<ID> listToBeDeletedId = new set<Id>();
    List<Social_Input__c> listToBeDeletedSocialInput = new List<Social_Input__c>();
    public string decisionId{get;set;}
    public map<Id, List<string>> generalGroupMemberMap = new map<Id, List<string>>();
    
    // JSON string initialization for search table 
    public static string searchedUserJSON{get;set;}
    //Declare this variable for checking record level permission
    public static Boolean chkRecPermission{get;set;}
    // Declare this variable for UserRecordAccess  
    public List<UserRecordAccess> listUserRecordAccess{get;set;}
    GeneralInformation generalInfo = new GeneralInformation();
    
    //constructor to retrieve existing people.    
    public AddEditPeopleManju(){
        try{
          // to support IE8 Browsers, the following meta tag has been added
          Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=8');
          
          // initializing list 
            existingPeopleWrapperList = new List<SocialInputWrapper>();
            
            newPeopleToBeAdded = new List<Social_Input__c>();
            listUserRecordAccess = new List<UserRecordAccess>();
            // getting the parameter from browser
            objType = ApexPages.currentPage().getParameters().get('objType');
            
            //test
            
            // initialize array
            userSearchedArray = new User[]{};
            
            //check for the profile of the current logged in user. This is reqd to handle System admin permissions.
            p = [SELECT Name FROM Profile WHERE Id = :Userinfo.getProfileId()];
            
             // Current login user max record permission
             listUserRecordAccess = [SELECT RecordId, HasReadAccess, HasEditAccess, HasDeleteAccess,MaxAccessLevel FROM UserRecordAccess WHERE UserId=:UserInfo.getUserId() AND RecordId =:recId limit 1];
               system.debug('============listUserRecordAccess==========='+listUserRecordAccess);
             if(listUserRecordAccess.size() > 0 && listUserRecordAccess[0].MaxAccessLevel=='All'){
                 chkRecPermission=true;
                 //system.debug('============chkRecPermission==========='+chkRecPermission);
               }
            // Generate a map for User active state
            List<User> userListActiveState = [select id, isActive from User where Id != null];
            for(User u:userListActiveState){
                userActiveMap.put(u.Id,u.isActive);     
            }
            
            // If the current loggedin user is a part of Decision / Plan, get the role of the user on decision / plan
            myRole = new Social_Input__c();
            
            // get social input details of the decision
            if(objType == 'Decision'){
            
              // get the decision data 
                decisionData = [select id,Title__c,Phase__c,Add_C_I_Members__c from Decision__c where Id = : recId];
            
                // set the value for the property
                decisionId = string.valueOf(decisionData.Id);
            
                // get the current list of Social Inputs on the decision
                existingPeopleList = [select Id,User__r.isActive,User__r.Department,GroupId__c,Role__c,Is_Group__c, Group_Name__c,Name_of_the_User__c  ,Decision__r.Title__c, User__c,user__r.name,Accountable__c,Backup_for_Accountable__c, Consulted__c,Responsible__c, Informed__c,Veto_Rights__c,Role_Acceptance_Required__c,Stance_Approval_Status__c,Description__c,Decision__r.name from Social_Input__c where Decision__c =: recId];    
            
                // get the current phase of the decision
                decisionPhase = decisionData.Phase__c;
            
                //If the current loggedin user is a part of Decision / Plan, get the role of the user on decision / plan
                for(Social_Input__c s: existingPeopleList){
                    if(s.User__c == userInfo.getUserId())
                        myRole = s;     
                }
            
                // set the property value with decision title. Displayed on the page 
                headerName = existingPeopleList[0].Decision__r.Title__c;
            }
            // get social input details of the plan
            else if(objType == 'Plan'){
              // get plan details
                planData = [select id,Add_C_I_Members__c from Plan__c where Id = : recId ];
                
                // get the current list of Social Inputs on the decision
                existingPeopleList = [select Id,User__r.isActive,User__r.Department,GroupId__c,Role__c,Is_Group__c, Group_Name__c,Name_of_the_User__c , User__c,user__r.name,Accountable__c,Backup_for_Accountable__c, Consulted__c,Responsible__c, Informed__c,Veto_Rights__c,Role_Acceptance_Required__c,Stance_Approval_Status__c,Description__c,plan__r.name from Social_Input__c where Plan__c =: recId];    
                
                //If the current loggedin user is a part of Decision / Plan, get the role of the user on decision / plan
                for(Social_Input__c s: existingPeopleList){
                    if(s.User__c == userInfo.getUserId())
                        myRole = s;     
                }
                
                // set the property value with plan name. Displayed on the page 
                headerName = existingPeopleList[0].Plan__r.name;
            }
            
            //generate map for Group with Group members
            map<Id,Group> groupList = new map<Id,Group>([select id from Group where Name != null]);
            for(GroupMember groupMember : [Select g.UserOrGroupId, g.Id, g.GroupId From GroupMember g where g.Id != null]) {
                List<String> groupMemberList = generalGroupMemberMap.get(groupMember.GroupId);
                if(groupMemberList == null) {
                    groupMemberList = new List<String>();
                    generalGroupMemberMap.put(groupMember.GroupId, groupMemberList);
                }
                groupMemberList.add(groupMember.UserOrGroupId);
            }
            
            //generate wrapper list for the edit table.
            for(Social_Input__c si: existingPeopleList) {
              
              // check if the Social Input added is only a group or a User.
                if(si.User__c != null){existingUserId.add(si.User__c); }else{existingGroupId.add(si.GroupId__c);chkIfGrpExists.add(si.GroupId__c);} 
                SocialInputWrapper siw = new SocialInputWrapper();
                siw.socialRec = si;
                
                // maintain the property 'isNewUserAdded' to check if the user was already existed or was added newly. This is reqd for CI members 
                // when they have been given the permission to add/edit/delete new users. But the rule says that, they cant delete/edit existing users.
                siw.isNewUserAdded = 'ExistingUser';
                
                // if the Social Input added is only a group, we will have to get mouse over data. Data is stored in the property within the wrapper class
                if(si.Is_Group__c){
                    List<String> userToStringList = new List<String>();
                    
                    //get the group members for the group from map defined above
                    userToStringList = generalGroupMemberMap.get(si.GroupId__c);
                    
                    //property which stores the data for the group members on the edit table
                    siw.userFromGroup = listToStringConvert(userToStringList);
                    
                    // store the group name
                    siw.groupName = generalInfo.groupMap.get(si.GroupId__c).Name;
                }
                existingPeopleWrapperList.add(siw);
            } 
            
        }catch(Exception e){}        
    }
    
    // search functionality for the Add-Edit People page
    public pageReference searchUsers(){
      // initialize list 
        userSearched = new List<userWrapperClass>();
        userSearched.clear();
        userSearchedArray.clear();
        
        //get the search text from the page. This is passed as Apex:param in the action function
        String searchText = ApexPages.currentPage().getParameters().get('searchText');
        searchType = ApexPages.currentPage().getParameters().get('searchType');
        
        // '*' is not supported in the query, so replace all '*' with '%'
        if(searchText != ''){
            if(searchText.contains('*')){
                String SearchtextList=searchText.replaceAll('\\*','\\%');
                searchText = SearchtextList;
            }
        }
        
        // if the search type was 'User', the following code will execute        
        if(searchType == 'User') {
          
          //if the search text is not empty, append '%' at front and end of the search text to enable contains functionality
            if(searchText != ''){
                searchText = '%'+searchText+'%';
                
                // get the user list finding users compared with search text. 
                userSearchedArray = [select id, Name, firstname, Department from User where Id not In: existingUserId and isActive=true and (firstname like: searchText or lastname like: searchText or name like: searchText  ) Order By firstName limit 100];
            }
            
            // get the user list.
            else{
                userSearchedArray = [select id, Name, firstname, Department from User where Id not In: existingUserId and isActive=true Order By firstName limit 100];
            }
            
            // for the list generated above, generate a JSON string
            if(userSearchedArray.size() > 0){
                for(User u:userSearchedArray){
                    userWrapperClass wr = new userWrapperClass();
                    wr.selectUser = false;
                    wr.userId = u.Id;
                    wr.userName = u.Name;
                    wr.dept = u.department != null ? u.department : '';
                    wr.addedFromGroup = false;
                    wr.userImage = generalInfo.useImage.get(u.Id);
                    wr.userNameList = '';
                    wr.redirectUrl = 'User';
                    userSearched.add(wr);   
                }
                searchedUserJSON = JSON.serialize(userSearched);
            }
        }
        // if the search type was 'Group', the following code will execute  
        else {
            List<Group> userGroupList = new List<Group>();
            
            //if the search text is not empty, append '%' at front and end of the search text to enable contains functionality
            if(searchText != ''){
                searchText = '%'+searchText+'%';
                
                // get the group list finding users compared with search text.
                userGroupList = [select id, Name from Group where Name like: searchText Order By Name limit 100];
            }
            // get the Group list if search text is empty
            else{
              userGroupList = [select id,  Name from Group Order By Name limit 100];
            }
            //generate map for Group with Group members
            map<Id,List<String>> groupMembermap = new map<Id,List<String>>();
            for(GroupMember gruopMember : [Select g.UserOrGroupId, g.Id, g.GroupId From GroupMember g ]) {
                List<String> groupMemberLIst = groupMembermap.get(gruopMember.GroupId);
                if(groupMemberLIst == null) {
                    groupMemberLIst = new List<String>();
                    groupMembermap.put(gruopMember.GroupId, groupMemberLIst);
                }
                groupMemberLIst.add(gruopMember.UserOrGroupId);
            }
            
            // for the list generated above, generate a JSON string
            if(userGroupList.size() > 0){
                for(Group u : userGroupList){
                    if(u.Name != null && groupMembermap.get(u.Id) != null) {
                        userWrapperClass wr = new userWrapperClass();
                        wr.selectUser = false;
                        wr.userId = u.id;
                        wr.userName = u.Name;
                        wr.dept = '';
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
        
        // if the search text doesn't return any data, return the message.
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
      /************************ Functionality definition ************************************
          1. Certain parameters like selected users, user type(user or group), type of role(addingAsInformed,addingAsResponsibleaddingAsConsulted).
          2. Selected users array is split and added into a list and convert to set.
          3. If a User is being deleted from the page and the same user is being added, then the Social Input record has to be deleted first and new record has to be created. 
      *********************** Functionality definition *************************************/
      // get the parameters from the add functions
        String selectedUserId = ApexPages.currentPage().getParameters().get('selectedUsers');   
        String userType = ApexPages.currentPage().getParameters().get('userType');  
        String addingAsInformed = ApexPages.currentPage().getParameters().get('addingAsInformed');
        String addingAsResponsible = ApexPages.currentPage().getParameters().get('addingAsResponsible');
        String addingAsConsulted = ApexPages.currentPage().getParameters().get('addingAsConsulted');
        
        // Selected users array is split and added into a list
        String[] selectedUsersToSplit = selectedUserId.split(',');
        List<ID> selectedUserIdList = new List<Id>();
        for(Integer i = 0; i<selectedUsersToSplit.size();i++)   {
            selectedUserIdList.add(selectedUsersToSplit[i]);
        }
        
        // initialize and convert the ablve list to a set
        set<Id> selectedUserSet = new Set<Id>();
        selectedUserSet.addAll(selectedUserIdList);
        selectedUserIdList.clear();
        
        //If a User is being deleted from the page and the same user is being added, then the Social Input record has to be deleted first and new record has to be created.
        List<Id> tobeDeletedUserBeforeAdding = new List<Id>(); 
        if(listToBeDeletedId.size() > 0){
            if(userType == 'User' || (userType == 'Group' && addingAsResponsible != 'responsibleReqd' && addingAsConsulted != 'consultedReqd' && addingAsInformed == 'informedReqd')){
                for(Id s: listToBeDeletedId)    {
                    if(selectedUserSet.contains(s))
                        listToBeDeletedId.remove(s);
                        tobeDeletedUserBeforeAdding.add(s); 
                }   
            }
            if(userType == 'Group' && (addingAsResponsible == 'responsibleReqd' || addingAsConsulted == 'consultedReqd')){
                set<Id> groupMemberAndGroupId = new Set<Id>(); 
                for(GroupMember gruopMember : [Select g.UserOrGroupId, g.Id, g.GroupId From GroupMember g where g.GroupId In: selectedUserSet]){
                    groupMemberAndGroupId.add(gruopMember.UserOrGroupId);
                    groupMemberAndGroupId.add(gruopMember.GroupId);
                }
                for(Id s: listToBeDeletedId)    {
                    if(groupMemberAndGroupId.contains(s)){
                        listToBeDeletedId.remove(s);
                        tobeDeletedUserBeforeAdding.add(s);
                    }   
                }
            }
        }
        
        // delete the social input records if the user being added is deleted froom page.
        if(tobeDeletedUserBeforeAdding.size() > 0){
            listToBeDeletedSocialInput = [Select s.Veto_Rights__c, s.User__c, s.Responsible__c, s.Informed__c, s.Id, s.Group_Name__c, s.GroupId__c, s.Consulted__c, s.Backup_for_Accountable__c, s.Accountable__c,Decision__c From Social_Input__c s where (User__c in: tobeDeletedUserBeforeAdding or (Is_Group__c = true and GroupId__c in: tobeDeletedUserBeforeAdding)) and Decision__c =:decisionId];
            if(listToBeDeletedSocialInput.size() > 0){
                if(Social_Input__c.sObjectType.getDescribe().isDeletable()){
                    delete listToBeDeletedSocialInput;
                }
            }   
        }
        selectedUserIdList.addAll(selectedUserSet);
        
        // call the added user method and pass all the parameteres
        addedUser(selectedUserIdList,userType,addingAsInformed,addingAsResponsible,addingAsConsulted);
    }
   
    // group with in group functionality
    private void groupWithINGroup(List<Id> userIdList,List<Id> orignalUserList,string addingAsResponsible,String addingAsConsulted,List<id> newSocialInputId,List<Social_Input__c> newUsersToBeSaved){
        List<id> innerGroupID = new List<id>();
        for(GroupMember gruopMember : [Select g.UserOrGroupId, g.Id, g.GroupId From GroupMember g where g.GroupId In: userIdList]) {
            if(generalInfo.useNameMap.get(gruopMember.UserOrGroupId)!=null){    
                if( ( !existingUserId.contains(gruopMember.UserOrGroupId)) && userActiveMap.get(gruopMember.UserOrGroupId) == True) {
                        Social_Input__c s = new Social_Input__c();
                        s.Select_People__c = false;
                        s.User__c = gruopMember.UserOrGroupId ;
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
                        s.Role_Acceptance_Status__c = '';
                        s.Group_Name__c = 'added from '+generalInfo.groupMap.get(gruopMember.GroupId).Name+' Group';
                        s.GroupId__c = gruopMember.GroupId;
                        if(objType == 'Decision'){
                            s.Decision__c = recId;
                        }else if(objType == 'Plan'){
                            s.Plan__c = recId;
                        }
                        newSocialInputId.add(s.User__c);
                        existingUserId.add(s.User__c);
                        newUsersToBeSaved.add(s);
                    } // If individual was already the part of the deicison then the role is updated
                    else for(Integer i= 0; i <existingPeopleWrapperList.size(); i++){
                      if(existingPeopleWrapperList[i].socialRec.User__c == gruopMember.UserOrGroupId){
                          if(objType == 'Decision'){
                            if(addingAsResponsible == 'responsibleReqd'){
                                  existingPeopleWrapperList[i].socialRec.Responsible__c = true;
                              }
                              if(addingAsConsulted == 'consultedReqd'){
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
            else if(generalInfo.useNameMap.get(gruopMember.UserOrGroupId)==null && generalInfo.groupMap.get(gruopMember.UserOrGroupId)!=null){
                System.debug('------->@'+gruopMember.UserOrGroupId);
                innerGroupID.add(gruopMember.UserOrGroupId);
                orignalUserList.add(gruopMember.UserOrGroupId);
            }
        }
        if(innerGroupID!=null && innerGroupID.size()>0){
        	groupWithINGroup(innerGroupID,orignalUserList, addingAsResponsible, addingAsConsulted, newSocialInputId,newUsersToBeSaved); 
        }
    }
    
    
    // add users from search table. If a group is added, then extract people from there who doesn't exist in the existing social inputs
    public pageReference addedUser(List<Id> userIdList,String userType,String addingAsInformed,String addingAsResponsible,String addingAsConsulted){
       /*********************** Functionality definition ************************************
      1.  While adding any user of group, a List has been maintained to avoid adding duplicate users.
      2.  If the type added is User, then list of current users is checked to avoid duplicate users, and then a new Social Input Record is added to list with the assigned role
      3.  Record is added to database directly
      4.  If the type added is "GROUP" and role is either "CONSULTED" or "RESPONSIBLE", then the users are extracted from the group and are added individually
        to the decision or plan and are added directly to database. If individual was already the part of the deicison then the role is updated
      5.  If the type added is "GROUP" and role is "INFORMED" add the "GROUP" itself as SOCIAL INPUT Record
      *********************** Functionality definition *************************************/
    message = '';
        List<Social_Input__c> newUsersToBeSaved = new List<Social_Input__c>();
        
        //If the type added is User, then list of current users is checked to avoid duplicate users, and then a new Social Input Record is added to list with the assigned role
        if(userType == 'User'){
            for(Integer i = 0 ;i < userIdList.size(); i++){
                if(!existingUserId.contains(userIdList[i])){
                    Social_Input__c s = new Social_Input__c();
                    s.Select_People__c = false;
                    s.User__c = userIdList[i];
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
                    s.Role_Acceptance_Status__c = '';
                    if(objType == 'Decision'){
                        s.Decision__c = recId;
                    }else if(objType == 'Plan'){
                        s.Plan__c = recId;
                    }
                    existingUserId.add(s.User__c);
                    newUsersToBeSaved.add(s);
                }
            }
            if(newUsersToBeSaved.size () > 0){
            if(FLS.socialInputCreateable()){
                  insert newUsersToBeSaved;
                  for(Social_Input__c s: [select User__c,User__r.Department,Accountable__c,GroupId__c,Group_Name__c,Is_Group__c,User__r.name,Backup_for_Accountable__c,Consulted__c,Informed__c,Responsible__c,Stance_Approval_Status__c,Description__c,Veto_Rights__c,Role_Acceptance_Required__c from Social_Input__c where (Decision__c =: recId or Plan__c =: recId) and User__c IN : userIdList]){
                      SocialInputWrapper siw = new SocialInputWrapper();
                      siw.socialRec = s;
                      siw.isNewUserAdded = 'NewUser';
                      existingPeopleWrapperList.add(siw);
                  }
            }
            }
        }
        
        // If the type added is "GROUP" and role is either "CONSULTED" or "RESPONSIBLE", then the users are extracted from the group and are added individually
        // to the decision or plan and are added directly to database. 
        if(userType == 'Group' && (addingAsResponsible == 'responsibleReqd' || addingAsConsulted == 'consultedReqd')){
            List<id> newSocialInputId = new List<Id>();
            List<Social_Input__c> toBeUpdatedExistingRecords = new List<Social_Input__c>();
            Set<Social_Input__c> toBeUpdatedExistingRecordsSet = new Set<Social_Input__c>();
            
            // put it in method
            /*
            for(GroupMember gruopMember : [Select g.UserOrGroupId, g.Id, g.GroupId From GroupMember g where g.GroupId In: userIdList]) {
                if(generalInfo.useNameMap.get(gruopMember.UserOrGroupId)!=null){
                   groupWithINGroup(gruopMember,userIdList,addingAsResponsible,addingAsConsulted,newSocialInputId,newUsersToBeSaved); 
                }
                else if(generalInfo.useNameMap.get(gruopMember.UserOrGroupId)==null && generalInfo.groupMap.get(gruopMember.UserOrGroupId)!=null){
                    for(GroupMember groupMemberWithInGroup : [Select g.UserOrGroupId, g.Id, g.GroupId From GroupMember g where g.GroupId=:gruopMember.UserOrGroupId]){
                        groupWithINGroup(groupMemberWithInGroup,userIdList,addingAsResponsible,addingAsConsulted,newSocialInputId,newUsersToBeSaved); 
                    }	    
                }
            }*/
            
            
            groupWithINGroup(userIdList,userIdList,addingAsResponsible,addingAsConsulted,newSocialInputId,newUsersToBeSaved); 
            
            if(toBeUpdatedExistingRecordsSet.size() > 0)
              toBeUpdatedExistingRecords.addAll(toBeUpdatedExistingRecordsSet);  
             
            System.debug('----------><----------' +userIdList.size() +'---' + userIdList);
            for(Integer i = 0 ;i < userIdList.size(); i++){
                if( (! chkIfGrpExists.contains(userIdList[i]) )   ){
                  Social_Input__c s = new Social_Input__c();
                    s.Select_People__c = false;
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
                    newSocialInputId.add(userIdList[i]);
                    chkIfGrpExists.add(userIdList[i]);
                    newUsersToBeSaved.add(s);
                }
            }  
                
            if(newUsersToBeSaved.size () > 0){
              if(FLS.socialInputCreateable()){
          insert newUsersToBeSaved;
        
                  for(Social_Input__c s: [select User__c,User__r.Department,Accountable__c,GroupId__c,Group_Name__c,Is_Group__c,User__r.name,Backup_for_Accountable__c,Consulted__c,Informed__c,Responsible__c,Stance_Approval_Status__c,Description__c,Veto_Rights__c,Role_Acceptance_Required__c from Social_Input__c where (Decision__c =: recId or Plan__c =: recId) and (User__c IN : newSocialInputId OR (User__c = null and GroupId__c IN : newSocialInputId)) ]){
                      SocialInputWrapper siw = new SocialInputWrapper();
                      siw.socialRec = s;
                      siw.isNewUserAdded = 'NewUser';
                      List<String> userToStringList = new List<String>();
                      userToStringList = generalGroupMemberMap.get(s.GroupId__c);
                      siw.userFromGroup = listToStringConvert(userToStringList);
                      siw.groupName = generalInfo.groupMap.get(s.GroupId__c).Name;
                      existingPeopleWrapperList.add(siw);
                  }
              }
                newSocialInputId.clear();
            }
        }
        
        // If the type added is "GROUP" and role is "INFORMED" add the "GROUP" itself as SOCIAL INPUT Record
        if(userType == 'Group' && addingAsResponsible != 'responsibleReqd' && addingAsConsulted != 'consultedReqd' && addingAsInformed == 'informedReqd'){
            List<id> newSocialInputId = new List<Id>();
            for(Integer i = 0 ;i < userIdList.size(); i++){
                if(!chkIfGrpExists.contains(userIdList[i])){    
                    Social_Input__c s = new Social_Input__c();
                    s.Select_People__c = false;
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
                    
                    newSocialInputId.add(userIdList[i]);
                    chkIfGrpExists.add(userIdList[i]);
                    newUsersToBeSaved.add(s);
                }
            }
            if(newUsersToBeSaved.size () > 0){
                if(FLS.socialInputCreateable()){
                  insert newUsersToBeSaved;
                  for(Social_Input__c s: [select User__c,User__r.Department,Accountable__c,GroupId__c,Group_Name__c,Is_Group__c,User__r.name,Backup_for_Accountable__c,Consulted__c,Informed__c,Responsible__c,Description__c,Stance_Approval_Status__c,Veto_Rights__c,Role_Acceptance_Required__c from Social_Input__c where (Decision__c =: recId or Plan__c =: recId)  and  User__c = null and GroupId__c IN : newSocialInputId ]){
                      SocialInputWrapper siw = new SocialInputWrapper();
                      siw.socialRec = s;
                      siw.isNewUserAdded = 'NewUser';
                      List<String> userToStringList = new List<String>();
                      userToStringList = generalGroupMemberMap.get(s.GroupId__c);
                      siw.userFromGroup = listToStringConvert(userToStringList);
                      siw.groupName = generalInfo.groupMap.get(s.GroupId__c).Name;                   
                      existingPeopleWrapperList.add(siw);
                  }
                }
                newSocialInputId.clear();
            }
        }
      userSearched.clear();
      return null;
    }
    
    // Method to delete the social input records from the edit table
    public pageReference deleteThisSocialInput(){
      /********************** Functionality definition ************************************
      1.  Remove the social input record from the Edit table wrapper list and add to the list which will be maintained which will be deleted during new search or saving and redirecting to decision or plan
      2.   
      *********************** Functionality definition *************************************/
        String socialInputIdToBeDeleted = ApexPages.currentPage().getParameters().get('socialInputIdToBeDeleted'); 
        Id currentDeletedUserId ;
        for(Integer i = 0 ; i<existingPeopleWrapperList.size(); i++){
            if(existingPeopleWrapperList[i].SocialRec.User__c == socialInputIdToBeDeleted){
                existingUserId.remove(existingPeopleWrapperList[i].SocialRec.User__c);
                currentDeletedUserId = existingPeopleWrapperList[i].SocialRec.User__c;
                if(existingPeopleWrapperList[i].SocialRec.Id != null){
                  // add to the list to be deleted during new search or while saving and redirecting to decision or plan
                    listToBeDeletedId.add(existingPeopleWrapperList[i].SocialRec.User__c);   
                }   
                // remove from Edit Table wrapper list
                existingPeopleWrapperList.remove(i);
            }else if(existingPeopleWrapperList[i].SocialRec.User__c == null && existingPeopleWrapperList[i].SocialRec.GroupId__c == socialInputIdToBeDeleted){
                existingGroupId.remove(socialInputIdToBeDeleted );
                chkIfGrpExists.remove(socialInputIdToBeDeleted);
                if(existingPeopleWrapperList[i].SocialRec.Id != null){
                  // add to the list to be deleted during new search or while saving and redirecting to decision or plan
                    listToBeDeletedId.add(existingPeopleWrapperList[i].SocialRec.GroupId__c);   
                }
                // remove from Edit Table wrapper list
                existingPeopleWrapperList.remove(i);
            }
        }
        return null;
    }
    
    public pageReference deletePeople(){
        return null;    
    }
    
    public pageReference dummyRender(){
      listUserRecordAccess = [SELECT RecordId, HasReadAccess, HasEditAccess, HasDeleteAccess,MaxAccessLevel FROM UserRecordAccess WHERE UserId=:UserInfo.getUserId() AND RecordId =:recId limit 1];
               system.debug('============listUserRecordAccess==========='+listUserRecordAccess);
             if(listUserRecordAccess.size() > 0 && listUserRecordAccess[0].MaxAccessLevel=='All'){
                 chkRecPermission=true;
                 //system.debug('============chkRecPermission==========='+chkRecPermission);
               }
        return null;
    }
    
    public pageReference cancel(){
      /********************** Functionality definition ************************************
      1.  Redirect ro Decision or Plan
    *********************** Functionality definition *************************************/
        pageReference page;
        if(objType == 'Decision'){
            page = new pageReference('/apex/DecisionView?id='+recId+'&sfdc.override=1&addCol=true');
        }
        if(objType == 'Plan'){
            page = new pageReference('/apex/PlanView?id='+recId+'&sfdc.override=1&addCol=true');
        }
        feedPostAsComment();
        page.setRedirect(true);
        return page;
    }
    
    // Upsert the social inputs, and redirect to parent record
    public pageReference savePeople(){
        /********************** Functionality definition ************************************
      1.  Delete the SOCIAL INPUT Records which are to be deleted 
      2. UPSERT the SOCIAL INPUT RECORDS and redirect to page
    *********************** Functionality definition *************************************/
        if(listToBeDeletedId.size() > 0){
            listToBeDeletedSocialInput = [Select s.Veto_Rights__c, s.User__c, s.Responsible__c, s.Informed__c, s.Id, s.Group_Name__c, s.GroupId__c, s.Consulted__c, s.Backup_for_Accountable__c, s.Accountable__c,Decision__c From Social_Input__c s where (User__c in: listToBeDeletedId or (Is_Group__c = true and GroupId__c in: listToBeDeletedId)) and Decision__c =:decisionId];
            
            if(listToBeDeletedSocialInput.size() > 0){
                
                if(Social_Input__c.sObjectType.getDescribe().isDeletable()){
                    delete listToBeDeletedSocialInput;
                }
            }
        }
        for(SocialInputWrapper s: existingPeopleWrapperList){
            if(s.SocialRec.Accountable__c == false && s.SocialRec.Responsible__c == false && s.SocialRec.Consulted__c == false && s.SocialRec.Informed__c == false ){
                 ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Every People/Collaborator should be assigned with a role.');
                 ApexPages.addMessage(myMsg);
                 return null;
            }
        }
        
        pageReference page;
        if(objType == 'Decision'){
          //if(){
              if(myRole.Accountable__c || myRole.Responsible__c || myRole.Backup_for_Accountable__c || chkRecPermission==true){
                  if(FLS.decisionUpdateable()){ 
                    update decisionData;
                    system.debug('===========decisionData============='+decisionData);
                    
                    system.debug('===========myRolemyRole============='+myRole);
                     
               
                  }
              }
          //}
            page = new pageReference('/apex/DecisionView?id='+recId+'&sfdc.override=1&addCol=true');
        }
        if(objType == 'Plan'){
            if(myRole.Accountable__c || myRole.Responsible__c || myRole.Backup_for_Accountable__c || chkRecPermission==true){
                if(FLS.planUpdateable()){   
                    update planData;
                }
            }
            page = new pageReference('/apex/PlanView?id='+recId+'&sfdc.override=1&addCol=true');
        }
        
        //Set<Social_Input__c> toBeUpdatedSocialSet = new Set<Social_Input__c>();
        List<Social_Input__c> toBeUpdatedSocialList = new List<Social_Input__c>();
        for(SocialInputWrapper s: existingPeopleWrapperList){
        if(s.SocialRec.Description__c != null && s.SocialRec.Description__c.length() > 254) {
                s.SocialRec.Description__c = s.SocialRec.Description__c.substring(0,254);
            }
        if(   (  s.SocialRec.Stance_Approval_Status__c == 'Approved' ||  s.SocialRec.Stance_Approval_Status__c == 'Rejected' )&&s.SocialRec.Consulted__c == false && s.SocialRec.Responsible__c == false && s.SocialRec.Informed__c == true && s.SocialRec.Accountable__c == false && s.SocialRec.Backup_for_Accountable__c == false && decisionData.Phase__c == 'Propose')
          s.SocialRec.Stance_Approval_Status__c = ''; 
            toBeUpdatedSocialList.add(s.SocialRec);
        }
        if(toBeUpdatedSocialList.size() > 0){
        if(FLS.socialInputUpdateable()){
              update toBeUpdatedSocialList; 
        }  
        }
        feedPostAsComment();
        //upsert existingPeopleList
        page.setRedirect(true);
        return page;
    }
    
    // Upsert the social inputs, and redirect to parent record
    public pageReference saveCurrentPeople(){
    /********************** Functionality definition ************************************
      1.  Delete the SOCIAL INPUT Records which are to be deleted 
      2. UPSERT the SOCIAL INPUT RECORDS and redirect to page
    *********************** Functionality definition *************************************/
        if(listToBeDeletedId.size() > 0){
            listToBeDeletedSocialInput = [Select s.Veto_Rights__c, s.User__c, s.Responsible__c, s.Informed__c, s.Id, s.Group_Name__c, s.GroupId__c, s.Consulted__c, s.Backup_for_Accountable__c, s.Accountable__c,Decision__c From Social_Input__c s where (User__c in: listToBeDeletedId or (Is_Group__c = true and GroupId__c in: listToBeDeletedId)) and Decision__c =:decisionId];
            if(listToBeDeletedSocialInput.size() > 0){
                System.debug('----listToBeDeletedSocialInput-----------'+listToBeDeletedSocialInput);
                if(Social_Input__c.sObjectType.getDescribe().isDeletable()){
                    delete listToBeDeletedSocialInput;
                }
            }
        }
        for(SocialInputWrapper s: existingPeopleWrapperList){
            if(s.SocialRec.Accountable__c == false && s.SocialRec.Responsible__c == false && s.SocialRec.Consulted__c == false && s.SocialRec.Informed__c == false ){
                 ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Every People/Collaborator should be assigned with a role.');
                 ApexPages.addMessage(myMsg);
                 return null;
            }
        }
        
        
        pageReference page;
        if(objType == 'Decision'){
          if(myRole.Accountable__c || myRole.Responsible__c || myRole.Backup_for_Accountable__c || chkRecPermission==true){
              if(FLS.decisionUpdateable()){ 
                update decisionData;
              }
          }
          page = new pageReference('/apex/AddEditPeopleOnDecisionManju?id='+recId+'&ObjType=Decision');
        }
        if(objType == 'Plan'){
            if(myRole.Accountable__c || myRole.Responsible__c || myRole.Backup_for_Accountable__c || chkRecPermission==true){
                if(FLS.planUpdateable()){   
                    update planData;
                }
            }
            page = new pageReference('/apex/AddEditPeopleOnPlan?id='+recId+'&ObjType=Plan');
        }
        //Set<Social_Input__c> toBeUpdatedSocialSet = new Set<Social_Input__c>();
        List<Social_Input__c> toBeUpdatedSocialList = new List<Social_Input__c>();
        for(SocialInputWrapper s: existingPeopleWrapperList){
        if(s.SocialRec.Description__c != null && s.SocialRec.Description__c.length() > 254) {
                s.SocialRec.Description__c = s.SocialRec.Description__c.substring(0,254);
            }
        if(   (  s.SocialRec.Stance_Approval_Status__c == 'Approved' ||  s.SocialRec.Stance_Approval_Status__c == 'Rejected' )&&s.SocialRec.Consulted__c == false && s.SocialRec.Responsible__c == false && s.SocialRec.Informed__c == true && s.SocialRec.Accountable__c == false && s.SocialRec.Backup_for_Accountable__c == false && decisionData.Phase__c == 'Propose')
          s.SocialRec.Stance_Approval_Status__c = ''; 
            toBeUpdatedSocialList.add(s.SocialRec);
        }
        if(toBeUpdatedSocialList.size() > 0){
        if(FLS.socialInputUpdateable()){
        update toBeUpdatedSocialList;
        }   
        }
        feedPostAsComment();
        page.setRedirect(true);
        return page;
    }
    
    public String listToStringConvert(List<String> grpMemberList) {
      // convert the list to ',' seperated string
        String UserName = '';
        Integer i = 0;
        for(String str : grpMemberList) {
            if(UserName == '') {
                UserName = generalInfo.useNameMap.get(str).Name;
            }
            else {
                if(generalInfo.useNameMap.get(str)!=null){
                    if(i<4){
                      system.debug('grpMemberList----> '+str);
                        UserName = UserName + ',' + generalInfo.useNameMap.get(str).Name;
                        i++;
                    }
                }
            }
        }
        return  UserName;       
    }
    
    //Added By tanay das barman
    
    public  void feedPostAsComment(){
      system.debug('===========existingPeopleWrapperListexistingPeopleWrapperList============='+existingPeopleWrapperList.size());
      //system.debug('===========existingPeopleWrapperListexistingPeopleWrapperList============='+stList.size());
    }
    
    // get group members
    @RemoteAction
    public static String retrieveGroupMember(String GrupId) {
        GeneralInformation general = new GeneralInformation();
        List<UserGroupMemberList> UserGroupMemberList = new List<UserGroupMemberList>();
        for(GroupMember gruopMember : [Select g.UserOrGroupId, g.Id, g.GroupId From GroupMember g where g.GroupId =: GrupId]) {
            UserGroupMemberList userGroupMember = new UserGroupMemberList();
            userGroupMember.name = general.useNameMap.get(gruopMember.UserOrGroupId).Name;
            userGroupMember.userImage = general.useImage.get(gruopMember.UserOrGroupId);
            userGroupMember.department = general.useNameMap.get(gruopMember.UserOrGroupId).Department != null ? general.useNameMap.get(gruopMember.UserOrGroupId).Department : '';
            UserGroupMemberList.add(userGroupMember);
        }
        return JSON.serialize(UserGroupMemberList);
    }
    
    // wrapper classes
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
        public string isNewUserAdded{get;set;}
        public social_Input__c socialRecDummy{get;set;}
    } 
    
    public Class UserGroupMemberList {
        public String name {get;set;}
        public String userImage {get;set;}
        public String department {get;set;}
        
    }  
}