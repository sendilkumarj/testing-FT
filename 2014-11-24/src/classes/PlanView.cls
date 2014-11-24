/* 
    ********************************************************************** 
    Created by: Neha
    Last Modified by: Neha
    Style: Force.com & Metro
    Description: a) This is for the primary functionality on plan page
                 b) This controller performs the functionality for individual tabs 
                 c) Counting of records on individual tabs is also implemented here           
    ********************************************************************** 
 */

public with sharing class PlanView {
    
    // Kendo People tab edit permission
    public String peopleEditPermission {get;set;}

    //Initialize plan
    public Plan__c plan {get;set;} 
    
    // initialize social input 
    public Social_Input__c socialInput {get;set;}
    
    // plan id for note (15 characters)
    public String planIDNote {get;set;}
    
    // plan id (18 characters)
    public String planID {get;set;}
    
    // user locale date fromat as string 
    public static String dateFormat {get;set;}
    
    // user locale datetime fromat as string 
    public static String dateTimeFormat {get;set;}
    
    /*JSON string initialization */
    
    //For people (Socail Input) tab
    public static String socialInputJson {get;private set;}
    
    //For task and event tab
    public static String taskEventJSON {get;private set;} 
   
    //For task and event activity history tab
    public static String taskEventHistoryJSON {get;private set;} 
    
    //For relations tab
    public static String relationsJSON {get;private set;} 
    
    //For attachments tab that includes both notes and attachment
    public static String attachmentNoteJSON {get; private set;} 
    
    //For history tab. This includes activity history as well as plan history
    public static String historyJSON {get; private set;}
    
    
    public static Task updatedTask {get;set;}
    
    // Event getter setter
    public Event event {get;set;}
    
    public static String allItemJson {get; private set;}
    public static String allItemDetailJson {get; private set;}
   
    public static set<Id> recordChildId{get;set;}
    public static set<Id> recordParentId{get;set;}
    public static set<Id> decisionSet{get;set;} 
    public static map<Id, Id> recordOwnerMap;
    public static map<Id, String> recordOwnerNameMap;
    public static map<Id,String> recordPopupField1Map;
    public static map<Id,String> recordPopupField2Map;
    public static map<Id,String> recordPopupField3Map;
    public static map<Id,String> recordPopupField1NameMap;
    public static map<Id,String> recordPopupField2NameMap; 
    public static map<Id,String> recordPopupField3NameMap; 
    public static string totalHoursMints{get;private set;}
    public static string totalEstimatedHours{get;private set;}
    public static string totalActualHours{get;private set;}
    public static map<Id,Relations__c> relationMap{get;set;}
   
    public String isDeletableStr{get;set;}

    public Task newTaskToDecision{get;set;}
    
    public static GeneralInformation genralInfo;
    
    public static Social_Input__c loggedInSocialPeople;
    
   // public static Profile profile; 
    
    public Profile profileName{get;set;}
    
    public boolean canUserDelete{get;set;}
    
    public String message{get;set;}
    
    Set<Id> relationsIds = new Set<Id>();
    
    public List<Relations__c> srchRelationship{get;set;}
    public Set<Relations__c> srchRelationshipSet{get;set;}
    
    // Declare attachment count
    public Integer attachmentCount{get;set;} 
    
    //Declare chatter feed attachment count
    public Boolean  feedattachmentCount{get;set;}
     public List<Plan__Feed> chkFeedAttachment{get;set;}
    
    public static Boolean walkmeTaskVar {get; set;}
    
    // Dynamic picklist values as string
    public String taskStatusPicklist {get;set;}
    public string taskPriorityPicklist {get;set;}
    public string taskComplexityPicklist {get;set;}
    public string taskSkillPicklist {get;set;}


    //Declare this variable for checking record level permission
    public static Boolean chkRecPermission{get;set;}
    // Declare this variable for UserRecordAccess  
    public List<UserRecordAccess> listUserRecordAccess{get;set;}
    
    //--- added start on 20_2_2014-  Picklist entries same as Decision in add relation
        //variable to hold all user accessible object
        public List<SelectOption> userAccessibleobjects {get;set;}
        // set to hold all Crm objects that has to be shown under add relations popup
        public set<String>  crmObjectsSet ; 
        
        // set to hold all FT  objects that has to be shown under add relations popup
        public set<String>  ftObjectsSet ;
        
        // map to hold all object namr to label
        public Map<String,String>  objectNameLabelMap  {get;set;}
    //--- end on 20_2_2014-  Picklist entries same as Decision in add relation
    
    public Boolean showTaskPopup {get; set;}
    public Boolean newShowTaskPopup {get; set;}
    public String taskId {get; set;}
    public String taskEditable {get; set;}
    public String modeType {get; set;}
    public String newTaskRelatedId {get; set;}
    
    public List<String> lstStatusValues {get; set;}
    public List<String> lstPriorityValues {get; set;}
    
    public String planIdSubstring {get; set;}
    public String decisionIdSubstring {get; set;}
    public static string  userLocaleSidKey{get;set;}
    static{
            //variable to send user locale
            userLocaleSidKey  = UserInfo.getLocale().replace('_','-');
    } 
    //Defining constructor
    public PlanView(ApexPages.StandardController controller){
        try{
        	
        
             // Initialize attachment count
             attachmentCount = 0;
             feedattachmentCount=false;
             newShowTaskPopup = false;
             chkFeedAttachment = new List<Plan__Feed>();
             updatedTask = new Task();
            
            lstStatusValues = new List<String>();
            lstPriorityValues = new List<String>();
            
            peopleEditPermission = 'false';
            
            Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=8');
            
            // initialize General information class to get user locale date format and images from static resouces url //
            //GeneralInformation genralInfo  = new GeneralInformation();
            if(genralInfo == null ) {
                genralInfo  = new GeneralInformation();
            }
            
            // assign user locale date format as string 
            dateFormat = genralInfo.MapValuesDateFormate();
            system.debug('===dateFormat=='+dateFormat);
            // assign user locale datetime format as string 
            dateTimeFormat = genralInfo.MapValuesDateTime();
            listUserRecordAccess = new List<UserRecordAccess>();
            
            
            // Querying plan object
            plan = [Select ID,Add_C_I_Members__c , Name, All_Day_Event__c, Assigned_To__c, Assigned_To__r.Name, Description__c, End_Time__c, Location__c, Private__c, Show_Time_As__c, Start_Time__c from Plan__c where ID=: ApexPages.currentPage().getParameters().get('id')];
            
            // Initaialize plan id
            planID = plan.id;
            
            newTaskRelatedId = plan.Id;
            
            planIdSubstring = planID.substring(0,3);
            
            Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
            for(String sObj : Schema.getGlobalDescribe().keySet()){
                Schema.DescribeSObjectResult r =  gd.get(sObj).getDescribe();
                String tempName = r.getName();
                String tempPrefix = r.getKeyPrefix();
                if(tempName.equals('fingertip_a__Decision__c') || tempName.equals('Decision__c')) {
                    decisionIdSubstring = tempPrefix;
                }
             }
            
            loggedInSocialPeople = new Social_Input__c();
            if([Select id From Social_Input__c s where s.Plan__c =: plan.Id AND s.User__c =: userInfo.getUserId() ].size() > 0) {
                socialInput = [Select s.Veto_Rights__c, s.User__c, s.SystemModstamp, s.Select_People__c, s.SYS_Tab_View_Tasks__c, s.SYS_Tab_View_Social_Input__c, s.SYS_Tab_View_Relations__c, s.SYS_Tab_View_Quality__c, s.SYS_Tab_View_History__c, s.SYS_Tab_View_Attachments__c, s.SYS_Tab_View_Approvals__c, s.SYS_Tab_View_Activites__c, s.Role__c, s.Role_Acceptance_Status__c, s.Role_Acceptance_Required__c, s.Result__c, s.Responsible__c, s.Rating__c, s.Plan__c, s.OwnerId, s.Outcome__c, s.Name_of_the_User__c, s.Name, s.Mood__c, s.Like__c, s.LastModifiedDate, s.LastModifiedById, s.Is_Group__c, s.IsDeleted, s.Informed__c, s.Id, s.Group_Name__c, s.GroupId__c, s.Final_Approval_Status__c, s.Effort__c, s.Dislike__c, s.Description__c, s.Decision__c, s.CreatedDate, s.CreatedById, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c, s.Accountable__c From Social_Input__c s where s.Plan__c =: plan.Id AND s.User__c =: userInfo.getUserId() Limit 1];  
                loggedInSocialPeople = socialInput;
            }
            
            //profile = [select Name from Profile where id =: UserInfo.getProfileId()];
            //profileName = [select Name from Profile where id =: UserInfo.getProfileId()];
            //tt profile = [select Id, Name from Profile where Name=: 'System Administrator'];
            chkRecPermission = false;
            listUserRecordAccess = [SELECT RecordId, HasReadAccess, HasEditAccess, HasDeleteAccess,MaxAccessLevel FROM UserRecordAccess WHERE UserId=:UserInfo.getUserId() AND RecordId =:planId limit 1];
              // Query for current login user max record permission
            if(listUserRecordAccess.size() > 0 && listUserRecordAccess[0].MaxAccessLevel=='All'  ){
                
                    //User usr = [SELECT ProfileId FROM User where id=:UserInfo.getUserId() Limit 1];
                    PermissionSet permissionset = new PermissionSet();
                    ObjectPermissions objPermissins = new ObjectPermissions();
                    try { 
                        permissionset = [SELECT Id FROM PermissionSet where ProfileId=:userinfo.getProfileId() Limit 1];
                        objPermissins = [SELECT Id,PermissionsModifyAllRecords FROM ObjectPermissions WHERE SobjectType = 'Plan__c' AND ParentId = :permissionset.Id Limit 1 ]; 
                    } catch (exception e){
                        permissionset = [SELECT Id FROM PermissionSet where Name = 'Fingertip_Access' Limit 1];
                        objPermissins = [SELECT Id,PermissionsModifyAllRecords FROM ObjectPermissions WHERE SobjectType = 'Plan__c' AND ParentId = :permissionset.Id Limit 1 ]; 
                    }  
                        if(objPermissins.PermissionsModifyAllRecords == true){
                             chkRecPermission=true;
                        }
             }
             System.debug('chkRecPermission'+chkRecPermission);
            canUserDelete = false;
            if(chkRecPermission == true){
                canUserDelete = true;
            }
            // Querying attachment object for the count of records for the specific plan
            attachmentCount = [SELECT COUNT() FROM Attachment where ParentId =: plan.Id];
            chkFeedAttachment = [SELECT id,RelatedRecordId FROM Plan__Feed where ParentId =: plan.Id];
            if(chkFeedAttachment.size() > 0 ){
                for(Plan__Feed fi:chkFeedAttachment)
                    if(fi.RelatedRecordId != null){
                        feedattachmentCount=true;
                        break;
                    }
            }
            
            // Conversion for 18 characters id to 15 characters id for plan. Only used for note. 
            planIDNote = planID.substring(0, 15);
            
            // Call social people section method. This one is deprecated. But needed in the code from packaging perspective.
            viewPeopleTab(plan.ID, null);
            
            // Call social people section method with search feature.
            viewPeopleTabWithSearch(plan.ID, null, '');
            
            //call task event method (old method)
            //viewTaskEventTab(plan.ID, null);
            
            //call task event method
            viewTaskEventTabWithSearch(plan.ID, null, '');
            
            // Call relationship method
            viewAllRelationsTab(plan.ID, null);
            
            //call note attachment method
            //viewAttachmentNoteTab(plan.ID);
            
            //call history method
            viewHistory(plan.ID);
            
            //item tab methods
            itemView1(plan.ID);
            
            newTaskToDecision = new task(Status='Not Started',whatId = plan.Id,OwnerId = UserInfo.getUserId(),Priority = 'Normal',IsReminderSet = true,Skill_Level__c = '1'); 
            
           
          
            
            event = new Event();
            
            srchRelationship = new List<Relations__c> ();
            srchRelationshipSet = new Set<Relations__c> ();
            
           
            
            
            //Profile p = [select Name from Profile where id =: UserInfo.getProfileId()];  
            if( socialInput != null && ( chkRecPermission == true || socialInput.Accountable__c || socialInput.Responsible__c) ){
                isDeletableStr = 'True';
                peopleEditPermission = 'true';
            }else{
                isDeletableStr = 'false';
                peopleEditPermission = 'false';
            }
            //peopleEditPermission = 'true'; 
              // Dynamic picklist for tasks status & language issue fixes
            Schema.Describefieldresult statusResult = Schema.sObjectType.Task.fields.Status;
            List<Schema.PicklistEntry>  statusPickList = statusResult.getPicklistValues();
            taskStatusPicklist = '';
            
            for(Schema.PicklistEntry statusValue : statusPickList){
                taskStatusPicklist = taskStatusPicklist+  '{ \"StatusName\" :' + '\"' + statusValue.getLabel()  + '\"' + '},' ;
                lstStatusValues.add(statusValue.getLabel());
            }
            taskStatusPicklist  = taskStatusPicklist.substring(0,taskStatusPicklist.length()-1);
            // dynamic picklist for task priority
            Schema.DescribeFieldResult  priorityResult = Schema.sObjectType.Task.fields.Priority;
            priorityResult = priorityResult.getSObjectField().getDescribe();
            List<Schema.PicklistEntry>  priorityPickList = priorityResult.getPicklistValues();
            taskPriorityPicklist = '';
            for(Schema.PicklistEntry priorityValue : priorityPickList){
                taskPriorityPicklist = taskPriorityPicklist +  '{ \"PriorityName\" :' + '\"' + priorityValue.getLabel() + '\"' + '},' ;
                lstPriorityValues.add(priorityValue.getLabel());
            }
            taskPriorityPicklist = taskPriorityPicklist.substring(0,taskPriorityPicklist.length()-1);
            
            // dynamic picklist for task complexity
            Schema.DescribeFieldResult  complexityResult = Schema.sObjectType.Task.fields.Complexity__c;
            complexityResult = complexityResult.getSObjectField().getDescribe();
            List<Schema.PicklistEntry>  complexityPickList = complexityResult.getPicklistValues();
            taskComplexityPicklist = '';
            for(Schema.PicklistEntry complexityValue : complexityPickList){
                taskComplexityPicklist = taskComplexityPicklist +  '{ \"complexityName\" :' + '\"' + complexityValue.getLabel() + '\"' + '},' ;
            }
            taskComplexityPicklist = taskComplexityPicklist.substring(0,taskComplexityPicklist.length()-1);

            // dynamic picklist for task skilllvel
            Schema.DescribeFieldResult  skillResult = Schema.sObjectType.Task.fields.Skill_Level__c;
            skillResult = skillResult.getSObjectField().getDescribe();
            List<Schema.PicklistEntry>  skillPickList = skillResult.getPicklistValues(); 
            taskskillPicklist = '';
            for(Schema.PicklistEntry skillValue : skillPickList){  
                taskskillPicklist = taskskillPicklist +  '{ \"skillName\" :' + '\"' + skillValue.getLabel() + '\"' + '},' ;
            }
            taskskillPicklist = taskskillPicklist.substring(0,taskskillPicklist.length()-1);  



            // added on 20_02_2014 to add the picklist entries as in Decision start 
            //list to hold all useraccesable objects
            userAccessibleobjects = new List<SelectOption>();
             
            //Map to hold objects name and labels
            objectNameLabelMap = new Map<String,String>(); 
            
            //Initialize the crmObjectsSet to make userAccessibleobjects hold only specified values
            crmObjectsSet = new set<String>{'Account','Asset','Case','Campaign','Contact','Contract','Idea','Lead','Opportunity','Order','Price Book','Product','Quote','Quote Line Item','Solution','User' };
           
            //Initialize the ftObjectsSet to make userAccessibleobjects hold only specified values
            ftObjectsSet  = new Set<String>{ 'Decision','Plan' };
            
            
                 //get schema describe to get all object
                 List<Schema.SObjectType> globaldescribe = Schema.getGlobalDescribe().Values();     
                 
                 List<SelectOption> userAccessibleobjectsUnSorted =  new List<SelectOption>();
                 
                 for(Schema.SObjectType f : globaldescribe)
                 {   //for each object if it is viewable by user then add to userAccessibleobjects
                     if( f.getDescribe().isAccessible() && crmObjectsSet.contains(f.getDescribe().getLabel()) ){
                        userAccessibleobjectsUnSorted.add(new SelectOption(f.getDescribe().getName(),f.getDescribe().getLabel()));
                        objectNameLabelMap.put(f.getDescribe().getName(),f.getDescribe().getLabel());
                     }
                     else{
                         if( f.getDescribe().isAccessible() && ftObjectsSet.contains(f.getDescribe().getLabel()) ){
                            userAccessibleobjects.add(new SelectOption(f.getDescribe().getName(),f.getDescribe().getLabel()));
                            objectNameLabelMap.put(f.getDescribe().getName(),f.getDescribe().getLabel());
                         }
                     }
                 }
                 
                 userAccessibleobjectsUnSorted.sort();
                 userAccessibleobjects.sort();
                 userAccessibleobjects.addAll( userAccessibleobjectsUnSorted );
                System.debug(userAccessibleobjects.size());
            // added on 20_02_2014 end 
        
        }
        catch(Exception e)
        {
        	
        	
        }
       
    }
    
    //Save Plan. 
    // When a user edits the plan record, the changes made to the plan record is updated and displays the updated record.
    public void savePlan(){
       System.debug('-------planNew-------->'+plan.Start_Time__c);
        System.debug('-------planNew-------->'+plan.End_Time__c);
       if(FLS.planUpdateable()) {
           update plan;         
       }
       
       List<UserRecordAccess> listUserRecordAccess = [SELECT RecordId, HasReadAccess, HasEditAccess, HasDeleteAccess,MaxAccessLevel FROM UserRecordAccess WHERE UserId=:UserInfo.getUserId() AND RecordId =: planId limit 1];
              
       if(listUserRecordAccess.size() > 0 && listUserRecordAccess[0].MaxAccessLevel=='All'  ){
           PermissionSet permissionset = new PermissionSet();
            ObjectPermissions objPermissins = new ObjectPermissions();
            try { 
                permissionset = [SELECT Id FROM PermissionSet where ProfileId=:userinfo.getProfileId() Limit 1];
                objPermissins = [SELECT Id,PermissionsModifyAllRecords FROM ObjectPermissions WHERE SobjectType = 'Decision__c' AND ParentId = :permissionset.Id Limit 1 ]; 
            } catch (exception e){
                permissionset = [SELECT Id FROM PermissionSet where Name = 'Fingertip_Access' Limit 1];
                objPermissins = [SELECT Id,PermissionsModifyAllRecords FROM ObjectPermissions WHERE SobjectType = 'Decision__c' AND ParentId = :permissionset.Id Limit 1 ]; 
            }  
           if(objPermissins.PermissionsModifyAllRecords == true){
                chkRecPermission=true;
           }
       }
       
        plan = [Select ID,Add_C_I_Members__c , Name, All_Day_Event__c, Assigned_To__c, Assigned_To__r.Name, Description__c, End_Time__c, Location__c, Private__c, Show_Time_As__c, Start_Time__c from Plan__c where ID=: ApexPages.currentPage().getParameters().get('id')];   
    }
    
    // dummy call
    public void dummyCall() {
        plan = [Select ID,Add_C_I_Members__c , Name, All_Day_Event__c, Assigned_To__c, Assigned_To__r.Name, Description__c, End_Time__c, Location__c, Private__c, Show_Time_As__c, Start_Time__c from Plan__c where ID=: ApexPages.currentPage().getParameters().get('id')];
            
    }
    
    // Social Input Tab value update on clik event of tab
    @RemoteAction
    public static JsonExistingData tabSectionClicked(String socialInputId, String clickedTab) {
        
        JsonExistingData jsonExistingData = new JsonExistingData();
        
        if(socialInputId != null) {
            Social_Input__c socialInput = [Select s.Id, s.SYS_Tab_View_Activites__c, s.SYS_Tab_View_History__c, s.SYS_Tab_View_Tasks__c, s.SYS_Tab_View_Social_Input__c, s.SYS_Tab_View_Relations__c, s.SYS_Tab_View_Quality__c, s.SYS_Tab_View_Attachments__c, s.SYS_Tab_View_Approvals__c From Social_Input__c s where s.Id =:socialInputId ];
            
            if(clickedTab == 'people-tab') {
                socialInput.SYS_Tab_View_Social_Input__c = false;
            }
            else if (clickedTab == 'task-tab') {
                socialInput.SYS_Tab_View_Tasks__c = false; 
            }
            else if(clickedTab == 'activities-tab') {
                socialInput.SYS_Tab_View_Activites__c = false;
            }
            else if (clickedTab == 'relation-tab') {
                socialInput.SYS_Tab_View_Relations__c = false;
            }
            else if(clickedTab == 'attachment-tab') {
                socialInput.SYS_Tab_View_Attachments__c = false;
            }
            else if (clickedTab == 'history-tab') {
                socialInput.SYS_Tab_View_History__c = false;
            }
            else if(clickedTab == 'quality-tab') {
                socialInput.SYS_Tab_View_Quality__c =false;
            }
            
            if(FLS.socialInputUpdateable()) {
                update socialInput;
            }
            jsonExistingData.socialIndividual = socialInput;
        }
        return jsonExistingData;
    }
    
    // Creates a collaborator JSON string. This method is updated with search feature for peoples tab.
    @RemoteAction
    public static String viewPeopleTabWithSearch(String planId, String tobeDeletedPeopleId, String searchPhrase){
        
        // initialize General information class to get user locale date, datetime format and image static resouce url 
        // GeneralInformation genralInfo  = new GeneralInformation();
        if(genralInfo == null ) {
                genralInfo  = new GeneralInformation();
        }
         
         List<UserRecordAccess> listUserRecordAccess = [SELECT RecordId, HasReadAccess, HasEditAccess, HasDeleteAccess,MaxAccessLevel FROM UserRecordAccess WHERE UserId=:UserInfo.getUserId() AND RecordId =:planId limit 1];
              // Query for current login user max record permission
         if(listUserRecordAccess.size() > 0 && listUserRecordAccess[0].MaxAccessLevel=='All'  ){
                
                    //User usr = [SELECT ProfileId FROM User where id=:UserInfo.getUserId() Limit 1];
                    PermissionSet permissionset = new PermissionSet();
                    ObjectPermissions objPermissins = new ObjectPermissions();
                    try { 
                        permissionset = [SELECT Id FROM PermissionSet where ProfileId=:userinfo.getProfileId() Limit 1];
                        objPermissins = [SELECT Id,PermissionsModifyAllRecords FROM ObjectPermissions WHERE SobjectType = 'Plan__c' AND ParentId = :permissionset.Id Limit 1 ]; 
                    } catch (exception e){
                        permissionset = [SELECT Id FROM PermissionSet where Name = 'Fingertip_Access' Limit 1];
                        objPermissins = [SELECT Id,PermissionsModifyAllRecords FROM ObjectPermissions WHERE SobjectType = 'Plan__c' AND ParentId = :permissionset.Id Limit 1 ]; 
                    }  
                        if(objPermissins.PermissionsModifyAllRecords == true){
                             chkRecPermission=true;
                        }
         }
        // list of people(collaborators) to be deleted on collaborators.
        if(tobeDeletedPeopleId != null && tobeDeletedPeopleId != '') {
            Social_Input__c toBeDeleteSocialInput = [Select s.Veto_Rights__c, s.User__c, s.SystemModstamp, s.SYS_Tab_View_Tasks__c, s.SYS_Tab_View_Social_Input__c, s.SYS_Tab_View_Relations__c, s.SYS_Tab_View_Quality__c, s.SYS_Tab_View_Attachments__c, s.SYS_Tab_View_Approvals__c, s.Role_Acceptance_Status__c, s.Role_Acceptance_Required__c, s.Result__c, s.Responsible__c, s.Rating__c, s.Outcome__c, s.Name, s.Mood__c, s.Like__c, s.LastModifiedDate, s.LastModifiedById, s.Informed__c, s.Id, s.Final_Approval_Status__c, s.Effort__c, s.Dislike__c, s.Plan__c, s.CreatedDate, s.CreatedById, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c, s.Accountable__c From Social_Input__c s where s.Id =: tobeDeletedPeopleId ];
            if(Social_Input__c.sObjectType.getDescribe().isDeletable()){
                delete toBeDeleteSocialInput;
            }
        }
        
        List<Social_Input__c> socialInputList = new List<Social_Input__c>();
        
        // To replace * with % in search area.
        if(searchPhrase != ''){
            if(searchPhrase.contains('*')){
                String SearchtextList=searchPhrase.replaceAll('\\*','');
                searchPhrase = SearchtextList;
            }
        }
        
        // converting the search text to upper case. This is required in comparing User name or group name in for loop below.
        if(searchPhrase != ''){
            searchPhrase = searchPhrase.toUpperCase();
        }    
        
        // Querying the social input list records.
        socialInputList = [Select Group_Name__c,GroupId__c,Is_Group__c,Veto_Rights__c,Description__c, Role__c, User__c, User__r.Name, SystemModstamp, SYS_Tab_View_Tasks__c, SYS_Tab_View_Social_Input__c, SYS_Tab_View_Relations__c, SYS_Tab_View_Quality__c, SYS_Tab_View_Attachments__c, SYS_Tab_View_Approvals__c, Role_Acceptance_Status__c, Role_Acceptance_Required__c, Result__c, Responsible__c, Rating__c, Outcome__c, Name, Mood__c, Like__c, LastModifiedDate, LastModifiedById, Informed__c, Id, Final_Approval_Status__c, Effort__c, Dislike__c, Decision__c, CreatedDate, CreatedById, Consulted__c, Backup_for_Accountable__c, Approved_for__c, Accountable__c From Social_Input__c where Plan__c =: planId ];
        
        
        // contains a record of the user who is logged in.
        // Social_Input__c loggedInSocialPeople = new Social_Input__c();
        if(loggedInSocialPeople == null) {
            loggedInSocialPeople = new Social_Input__c();
            if([select id  from Social_Input__c where User__c =: userInfo.getUserId() AND Plan__c =: planId].size() > 0 ) {
                loggedInSocialPeople = [Select s.Veto_Rights__c, s.User__c, s.SystemModstamp, s.Select_People__c, s.SYS_Tab_View_Tasks__c, s.SYS_Tab_View_Social_Input__c, s.SYS_Tab_View_Relations__c, s.SYS_Tab_View_Quality__c, s.SYS_Tab_View_History__c, s.SYS_Tab_View_Attachments__c, s.SYS_Tab_View_Approvals__c, s.SYS_Tab_View_Activites__c, s.Role__c, s.Role_Acceptance_Status__c, s.Role_Acceptance_Required__c, s.Result__c, s.Responsible__c, s.Rating__c, s.Plan__c, s.OwnerId, s.Outcome__c, s.Name_of_the_User__c, s.Name, s.Mood__c, s.Like__c, s.LastModifiedDate, s.LastModifiedById, s.Is_Group__c, s.IsDeleted, s.Informed__c, s.Id, s.Group_Name__c, s.GroupId__c, s.Final_Approval_Status__c, s.Effort__c, s.Dislike__c, s.Description__c, s.Decision__c, s.CreatedDate, s.CreatedById, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c, s.Accountable__c From Social_Input__c s where User__c =: userInfo.getUserId() AND Plan__c =: planId limit 1 ];
            }
        }
        
        // Fetches the profile of the user
       /* if(profile == null) { 
            profile = new Profile();  
            profile =[Select Id,Name From Profile where Name=: 'System Administrator' limit 1];
        }*/
        
        List<SocialInput> planSocialInputList = new List<SocialInput>();
        
        set<Id> groupId = new set<Id>();
        for(Social_Input__c socialInput: socialInputList) {
            if(socialInput.Is_Group__c) {
                groupId.add(socialInput.GroupId__c);
            }
        }
        
        map<Id,List<String>> groupMembermap = new map<Id,List<String>>();
        if(groupId.size() > 0) {
            for(GroupMember gruopMember : [Select g.UserOrGroupId, g.Id, g.GroupId From GroupMember g where g.GroupId In: groupId ]) {
                List<String> groupMemberLIst = groupMembermap.get(gruopMember.GroupId);
                if(groupMemberLIst == null) {
                    groupMemberLIst = new List<String>();
                    groupMembermap.put(gruopMember.GroupId, groupMemberLIst);
                }
                groupMemberLIst.add(gruopMember.UserOrGroupId);
            }
        }
        
        // since we need to search for groups also, the loop iterates checking if search text has value or not. If the search text has a value, contains method is used to check user or group has search text in it.
        // if it has, then only it will be added on the kendo table.
        for(Social_Input__c socialInput : socialInputList){
            // if search text doesnot have any value
            if(searchPhrase != ''){
                //searching user or groups which has search text passed in. The user name is converted to upper case and is compared with search text
                if((socialInput.User__c != null && socialInput.User__r.Name.toUpperCase().contains(searchPhrase)) || (socialInput.User__c == null && genralInfo.groupMap.get(socialInput.GroupId__c).Name.toUpperCase().contains(searchPhrase))){   
                    SocialInput si = new SocialInput();
                    si.id = socialInput.id;
                    si.name = socialInput.User__c != null ? socialInput.User__r.Name : genralInfo.groupMap.get(socialInput.GroupId__c).Name;
                    si.userImage = socialInput.User__c != null ? genralInfo.useImage.get(socialInput.User__c) : '/'+ genralInfo.imageUrlMap.get('group');
                    si.role = socialInput.Role__c.replaceAll(' ',', ');
                    si.description = socialInput.Description__c != null ? socialInput.Description__c : '';
                    // The below lines are commented because the Participation Acceptance and Plan Approval columns are removed
                    // si.roleAcceptanceImage = genralInfo.imageUrlMap.get('approved');
                    si.isDeletable = false; 
                    si.groupName = socialInput.Group_Name__c != null ? String.escapeSingleQuotes(socialInput.Group_Name__c) : '';
                    si.infoImage = socialInput.Group_Name__c != null  ? genralInfo.imageUrlMap.get('info') : genralInfo.imageUrlMap.get('null'); 
                    
                    si.url = socialInput.Is_Group__c ? 'javascript:void(0)' : '/' + socialInput.User__c;
                    si.groupClassName = socialInput.Is_Group__c ? 'group-link' : '';
                    si.isGroup = socialInput.Is_Group__c;
                    si.userId = socialInput.User__c != null ? socialInput.User__c : socialInput.GroupId__c ;
                    if(socialInput.Is_Group__c) {
                        List<String> groupMemberList = groupMembermap.get(socialInput.GroupId__c);
                        si.userNameList = listToStringConvert(groupMemberList);
                    }
                    
                    
                    si.actionClassName = 'grid-action-disabled';
                    
                    if(socialInput.Accountable__c || socialInput.User__c == userInfo.getUserId()) {
                        si.isDeletable = false;
                    }
                    else {
                        if(((loggedInSocialPeople.Accountable__c || loggedInSocialPeople.Backup_for_Accountable__c || loggedInSocialPeople.Responsible__c) && loggedInSocialPeople.Role_Acceptance_Status__c == 'Approved/Accepted' ) || chkRecPermission == true) {
                            si.isDeletable =  true;
                            si.actionClassName = '';
                        }
                    }
                    si.deleteImage = genralInfo.deleteImage.get(si.isDeletable);
                    planSocialInputList.add(si);
                }
            }//if search text does not have any value.
            else{
                
                SocialInput si = new SocialInput();
                si.id = socialInput.id;
                si.name = socialInput.User__c != null ? socialInput.User__r.Name : genralInfo.groupMap.get(socialInput.GroupId__c).Name;
                System.debug('-----si.name------'+si.name);
                si.userImage = socialInput.User__c != null ? genralInfo.useImage.get(socialInput.User__c) : '/'+ genralInfo.imageUrlMap.get('group');
                si.role = socialInput.Role__c.replaceAll(' ',', ');
                si.description = socialInput.Description__c != null ? socialInput.Description__c : '';
                // The below lines are commented because the Participation Acceptance and Plan Approval columns are removed
                // si.roleAcceptanceImage = genralInfo.imageUrlMap.get('approved');
                si.isDeletable = false; 
                si.groupName = socialInput.Group_Name__c != null ? String.escapeSingleQuotes(socialInput.Group_Name__c) : '';
                si.infoImage = socialInput.Group_Name__c != null  ? genralInfo.imageUrlMap.get('info') : genralInfo.imageUrlMap.get('null'); 
                
                si.url = socialInput.Is_Group__c ? 'javascript:void(0)' : '/' + socialInput.User__c;
                si.groupClassName = socialInput.Is_Group__c ? 'group-link' : '';
                si.isGroup = socialInput.Is_Group__c;
                si.userId = socialInput.User__c != null ? socialInput.User__c : socialInput.GroupId__c ;
                if(socialInput.Is_Group__c) {
                    List<String> groupMemberList = groupMembermap.get(socialInput.GroupId__c);
                    si.userNameList = listToStringConvert(groupMemberList);
                }
                
                
                si.actionClassName = 'grid-action-disabled';
                
                if(socialInput.Accountable__c || socialInput.User__c == userInfo.getUserId()) {
                    si.isDeletable = false;
                }
                else {
                    if(((loggedInSocialPeople.Accountable__c || loggedInSocialPeople.Backup_for_Accountable__c || loggedInSocialPeople.Responsible__c) && loggedInSocialPeople.Role_Acceptance_Status__c == 'Approved/Accepted' ) || chkRecPermission == true) {
                        si.isDeletable =  true;
                        si.actionClassName = '';
                    }
                }
                si.deleteImage = genralInfo.deleteImage.get(si.isDeletable);
                planSocialInputList.add(si);
            }
            
        }
        
        socialInputJson = JSON.serialize(planSocialInputList);
        return socialInputJson;
    }
    
    // Cerate Collabrator Json String. This method is deprecated because of intorduction of search functionality. Instead we are using viewPeopleTabWithSearch. This is requiered from packaging perspective. 
    public static String viewPeopleTab(String planId, String tobeDeletedPeopleId) {
      return null;  
    }
    
    public static string viewTaskEventTab(String planId, String tobeDeletedActivitiesId ){
        return null;    
    }
    
    @RemoteAction
    public static JsonExistingData viewTaskEventTabWithSearch(String planId, String tobeDeletedActivitiesId, string searchText ){
        
        // initialize General information class to get user locale date format and image static resouce url //
        //GeneralInformation genralInfo  = new GeneralInformation();
        if(genralInfo == null ) {
            genralInfo  = new GeneralInformation();
        }
        
        walkmeTaskVar = false;
        
        // assign user locale date format as string 
        dateTimeFormat = genralInfo.MapValuesDateTime();
        
        // assign user locale date format as string 
        dateFormat = genralInfo.MapValuesDateFormate();
        
        // Delete task and event
        if(tobeDeletedActivitiesId != null && tobeDeletedActivitiesId != '') {
            if(tobeDeletedActivitiesId.startsWith('00T')) {
                if(Task.sObjectType.getDescribe().isDeletable()) {
                    delete [select Id from Task where Id =:tobeDeletedActivitiesId ];
                }
            }
            else {
                if(Event.sObjectType.getDescribe().isDeletable()) {
                    delete [select Id  from Event where Id =:tobeDeletedActivitiesId ];
                }
            }
        }
        
        // contains a record of the user who is logged in.
        //Social_Input__c loggedInSocialPeople = new Social_Input__c();
        if(loggedInSocialPeople == null) {
            loggedInSocialPeople = new Social_Input__c();
            if([select id  from Social_Input__c where User__c =: userInfo.getUserId() AND Plan__c =: planId].size() > 0 ) {
                loggedInSocialPeople = [Select s.Veto_Rights__c, s.User__c, s.SystemModstamp, s.Select_People__c, s.SYS_Tab_View_Tasks__c, s.SYS_Tab_View_Social_Input__c, s.SYS_Tab_View_Relations__c, s.SYS_Tab_View_Quality__c, s.SYS_Tab_View_History__c, s.SYS_Tab_View_Attachments__c, s.SYS_Tab_View_Approvals__c, s.SYS_Tab_View_Activites__c, s.Role__c, s.Role_Acceptance_Status__c, s.Role_Acceptance_Required__c, s.Result__c, s.Responsible__c, s.Rating__c, s.Plan__c, s.OwnerId, s.Outcome__c, s.Name_of_the_User__c, s.Name, s.Mood__c, s.Like__c, s.LastModifiedDate, s.LastModifiedById, s.Is_Group__c, s.IsDeleted, s.Informed__c, s.Id, s.Group_Name__c, s.GroupId__c, s.Final_Approval_Status__c, s.Effort__c, s.Dislike__c, s.Description__c, s.Decision__c, s.CreatedDate, s.CreatedById, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c, s.Accountable__c From Social_Input__c s where User__c =: userInfo.getUserId() AND Plan__c =: planId limit 1 ];
            }
        }
        
       /* if(profile == null) {   
            profile = new Profile();
            profile =[Select Id,Name From Profile where Name=: 'System Administrator' limit 1];
        }*/
        
        if(searchText != ''){
            if(searchText.contains('*')){
                String SearchtextList=searchText.replaceAll('\\*','\\%');
                searchText = SearchtextList;
            }
        }
        
        List<Task> taskList = new List<Task>();
        
        if(searchText != ''){
            searchText = '%'+searchText+'%';
            taskList = [select id,WhatId,Subject,ActivityDate,IsClosed,Status,Priority,OwnerId,Owner.Name,CreatedById,CreatedBy.Name,Description from Task where WhatId =: planId and Subject like : searchText ];
        }else{
            taskList = [select id,WhatId,Subject,ActivityDate,IsClosed,Status,Priority,OwnerId,Owner.Name,CreatedById,CreatedBy.Name,Description from Task where WhatId =: planId ];
        }
        
        List<Event> eventList = new List<Event>();
        
        if(searchText != ''){
            searchText = searchText+'%';
            eventList = [select id,WhatId,Subject,ActivityDate,ActivityDateTime,OwnerId,Owner.Name,CreatedById,CreatedBy.Name,Description from Event where WhatId =: planId and subject like : searchText];
        }else{
            eventList = [select id,WhatId,Subject,ActivityDate,ActivityDateTime,OwnerId,Owner.Name,CreatedById,CreatedBy.Name,Description from Event where WhatId =: planId];
        }
        
        //Querying task and event list
        //List<Task> taskList = [select id,WhatId,Subject,ActivityDate,IsClosed,Status,Priority,OwnerId,Owner.Name,CreatedById,CreatedBy.Name,Description from Task where WhatId =: planId];
        //List<Event> eventList = [select id,WhatId,Subject,ActivityDate,ActivityDateTime,OwnerId,Owner.Name,CreatedById,CreatedBy.Name,Description from Event where WhatId =: planId];
        
        // Dynamic picklist for tasks status & language issue fixes
        Schema.DescribeFieldResult  statusResult = Task.Status.getDescribe();
        List<Schema.PicklistEntry>  statusPickList = statusResult.getPicklistValues();
        
        Map<String, String> taskstatus = new Map<String, String>();
        
        for(Schema.PicklistEntry statusValue : statusPickList){
            taskstatus.put(statusValue.getValue(),statusValue.getLabel());
        }
        
        // Dynamic picklist for tasks priority & language issue fixes
        Schema.DescribeFieldResult  priorityResult = Task.Priority.getDescribe();
        List<Schema.PicklistEntry>  priorityPickList = priorityResult.getPicklistValues();
        
        Map<String, String> taskpriority = new Map<String, String>();
        
        for(Schema.PicklistEntry priorityValue : priorityPickList){
            taskpriority.put(priorityValue.getValue(),priorityValue.getLabel());
        }
        
        List<UserRecordAccess> listUserRecordAccess = [SELECT RecordId, HasReadAccess, HasEditAccess, HasDeleteAccess,MaxAccessLevel FROM UserRecordAccess WHERE UserId=:UserInfo.getUserId() AND RecordId =: planId limit 1];
              
        if(listUserRecordAccess.size() > 0 && listUserRecordAccess[0].MaxAccessLevel=='All'  ){
            PermissionSet permissionset = new PermissionSet();
            ObjectPermissions objPermissins = new ObjectPermissions();
            try { 
                permissionset = [SELECT Id FROM PermissionSet where ProfileId=:userinfo.getProfileId() Limit 1];
                objPermissins = [SELECT Id,PermissionsModifyAllRecords FROM ObjectPermissions WHERE SobjectType = 'Decision__c' AND ParentId = :permissionset.Id Limit 1 ]; 
            } catch (exception e){
                permissionset = [SELECT Id FROM PermissionSet where Name = 'Fingertip_Access' Limit 1];
                objPermissins = [SELECT Id,PermissionsModifyAllRecords FROM ObjectPermissions WHERE SobjectType = 'Decision__c' AND ParentId = :permissionset.Id Limit 1 ]; 
            }  
            if(objPermissins.PermissionsModifyAllRecords == true){
                chkRecPermission=true;
            }
        }
        
        //Initialize task event list
        List<TaskEvent> taskEventList = new List<TaskEvent>();
       
        //For task
        for(Task task : taskList){
            //if(task.Status != 'Completed'){
                TaskEvent te = new TaskEvent();
                te.id= task.id;
                te.subject = task.Subject != null ? task.Subject.capitalize() : '';
                //te.dueDate = String.valueOf(task.ActivityDate);
                //te.dueDate = task.ActivityDate == null ? '' : genralInfo.MapValuesDate(String.valueOf(task.ActivityDate.day()), String.valueOf(task.ActivityDate.month()), String.valueOf(task.ActivityDate.year()));
                te.dueDate = task.ActivityDate == null ? '' : task.ActivityDate.format();
                //added on 25-04-2014
                te.dueDateSort = task.ActivityDate != null ? task.ActivityDate: null;
                // added on 25-04-2014
                te.delayTaskClass = task.ActivityDate < date.today() && !task.IsClosed ? 'delayTask' : task.ActivityDate == null ? 'emptyDuedate' : '';
                te.status = taskstatus.get(task.Status) == null ? task.Status : taskstatus.get(task.Status) ;
                te.isTask = 'Task';
                te.priority = taskpriority.get(task.Priority) == null ? task.Priority: taskpriority.get(task.Priority); 
                te.assignedTo = task.Owner.Name;
                te.assignedToImage = genralInfo.useImage.get(task.OwnerId);
                te.comments = task.Description == null ? '' : task.Description;
                te.commentsImage = task.Description == null ? genralInfo.imageUrlMap.get('') : genralInfo.imageUrlMap.get('chat');
                te.isDeletable= false;
                te.isEditable = false; 
                te.ownerId = task.OwnerId;
                te.actionClassNameEdit = 'grid-action-disabled';
                te.actionClassNameDelete = 'grid-action-disabled';
                te.title = '';
                te.imgEditTitle = '';
                te.imgDeleteTitle = '';
                te.isSelected = false;
                te.toDisable = '';
                /*if(loggedInSocialPeople.Accountable__c || loggedInSocialPeople.Backup_for_Accountable__c || Userinfo.getProfileId() == profile.Id || (task.OwnerId == userInfo.getUserId() && loggedInSocialPeople.Responsible__c)) {
                    te.isDeletable =  true;
                    te.isEditable = true;
                    te.actionClassName = '';
                }*/
                
                //if(((loggedInSocialPeople.Responsible__c || loggedInSocialPeople.Backup_for_Accountable__c) && ((Userinfo.getuserId() == task.CreatedById) || (Userinfo.getuserId() == task.OwnerId))) || (Userinfo.getuserId() == task.OwnerId) || ((Userinfo.getProfileId() == profile.Id || loggedInSocialPeople.Accountable__c || loggedInSocialPeople.Backup_for_Accountable__c))) {
                if((Userinfo.getuserId() == task.OwnerId) || ((chkRecPermission == true || loggedInSocialPeople.Accountable__c || loggedInSocialPeople.Backup_for_Accountable__c || loggedInSocialPeople.Responsible__c))) {    //Allows editing permissions for Accountable, backup and Responisable for all task.
                    te.imgEditTitle = 'Edit';
                    te.isEditable = true;
                    te.actionClassNameEdit = '';
                } else {
                    te.toDisable = 'disabled';
                }
                
                if(!task.IsClosed && task.OwnerId == userinfo.getuserId()){
                    walkmeTaskVar = true;
                }
                
                if(Userinfo.getuserId() == task.OwnerId || chkRecPermission == true || loggedInSocialPeople.Accountable__c) {
                    te.imgDeleteTitle = 'Delete';
                    te.isDeletable =  true;
                    te.actionClassNameDelete = '';
                }
                
                if(loggedInSocialPeople.Accountable__c || (loggedInSocialPeople.Backup_for_Accountable__c && loggedInSocialPeople.Role_Acceptance_Status__c == 'Approved/Accepted') || (loggedInSocialPeople.Responsible__c && loggedInSocialPeople.Role_Acceptance_Status__c == 'Approved/Accepted')){
                    te.title = 'Edit';
                }
                te.subjectClass = te.isEditable == true ? 'hide-subject' : '' ;
                te.subjectClassLink = te.isEditable == true ? '' : 'hide-subject' ;
                
                te.editImage = genralInfo.editImage.get(te.isEditable);
                te.deleteImage = genralInfo.deleteImage.get(te.isDeletable);
                te.taskImage = genralInfo.imageUrlMap.get('checked');
                //te.url = te.isEditable ? '/'+te.id +'?retURL='+task.WhatId  :  'javascript:void(0)';
                te.url = '/'+te.Id+'?retURL='+task.WhatId;
                
                taskEventList.add(te);
            //}
        } 
        
        // For event
        for(Event event : eventList){
            //if(event.ActivityDate >= date.today()) {
                TaskEvent te = new TaskEvent();
                te.id= event.id;
                te.subject = event.Subject.capitalize();
                //te.dueDate = String.valueOf(event.ActivityDateTime);
                //te.dueDate = event.ActivityDateTime == null ? '' : event.ActivityDateTime.format(dateTimeFormat);
                te.dueDate = event.ActivityDateTime == null ? '' : event.ActivityDateTime.format();
                 //added on 25-04-2014
                te.dueDateSort = event.ActivityDateTime != null ? event.ActivityDateTime: null;
                // added on 25-04-2014
                te.isTask = 'Event';
                te.assignedTo = event.Owner.Name;
                te.status = '';
                te.priority = '';
                te.assignedToImage = genralInfo.useImage.get(event.OwnerId);
                te.isDeletable= false;
                te.isEditable = false; 
                te.comments = event.Description == null ? '' : event.Description;
                te.commentsImage = event.Description == null ? genralInfo.imageUrlMap.get('') : genralInfo.imageUrlMap.get('chat');
                te.actionClassNameEdit = 'grid-action-disabled';
                te.actionClassNameDelete = 'grid-action-disabled';
                te.ownerId = event.OwnerId;
                te.imgEditTitle = '';
                te.imgDeleteTitle = '';
                te.title = '';
                te.isSelected = false;
                te.toDisable = 'disabled';
                /*if(loggedInSocialPeople.Accountable__c || loggedInSocialPeople.Backup_for_Accountable__c || Userinfo.getProfileId() == profile.Id || (event.OwnerId == userInfo.getUserId() && loggedInSocialPeople.Responsible__c)) {
                    te.isDeletable =  true;
                    te.isEditable = true;
                    te.actionClassName = '';
                }*/
                
                if(((loggedInSocialPeople.Responsible__c || loggedInSocialPeople.Backup_for_Accountable__c || loggedInSocialPeople.Veto_Rights__c ) && ((Userinfo.getuserId() == event.CreatedById) || (Userinfo.getuserId() == event.OwnerId))) || (Userinfo.getuserId() == event.OwnerId) || ((chkRecPermission == true || loggedInSocialPeople.Accountable__c))) {
                    te.imgEditTitle = 'Edit';
                    te.imgDeleteTitle = 'Delete';
                    te.isDeletable =  true;
                    te.isEditable = true;
                    te.actionClassNameEdit = '';
                    te.actionClassNameDelete = '';
                }
                
                if(loggedInSocialPeople.Accountable__c || (loggedInSocialPeople.Backup_for_Accountable__c && loggedInSocialPeople.Role_Acceptance_Status__c == 'Approved/Accepted')){
                    te.title = 'Edit';
                }
                te.subjectClass = te.isEditable == true ? 'hide-subject' : '' ;
                te.subjectClassLink = te.isEditable == true ? '' : 'hide-subject' ;
                
                te.editImage = genralInfo.editImage.get(te.isEditable);
                te.deleteImage = genralInfo.deleteImage.get(te.isDeletable);
                te.taskImage = genralInfo.imageUrlMap.get('unchecked');
                //te.url = te.isEditable ? '/'+te.id +'?retURL='+event.WhatId  :  'javascript:void(0)';
                te.url = '/'+te.id +'?retURL='+event.WhatId;
                taskEventList.add(te);
            //}
        }
        System.debug('---------taskEventList--------->'+taskEventList);
        //serialize task and event records list
        taskEventJSON = JSON.serialize(taskEventList);
        System.debug('---------taskEventJSON--------->'+taskEventJSON);
        //Integer.valueOf(taskEventJSON);
        JsonExistingData jsonExistingData = new JsonExistingData();
        jsonExistingData.taskEvent = taskEventJSON;
        //jsonExistingData.activitiesTaskEvent = taskEventHistoryJSON;
        
        return jsonExistingData;
     }
     
     //
     @RemoteAction
     public static JsonExistingData massDeleteTaskRecords(String selectedTasks,String planId,String searchText){
        System.debug('---------searchText--------->'+searchText);
        List<String> lstTaskIds = selectedTasks != null ? selectedTasks.split(',') : new List<String>();
        if(!lstTaskIds.isEmpty()){
             if(Task.sObjectType.getDescribe().isDeletable()) {
                delete [select id from Task where Id In : lstTaskIds];
             }
        }
        
        JsonExistingData jed = new JsonExistingData();
        jed = viewTaskEventTabWithSearch(planId,'',searchText);
        System.debug('---------jed--------->'+jed);
        return jed;
     }
     
     //
     @RemoteAction
     public static JsonExistingData massEditTaskRecords(String selectedTasks,String planId,String searchText,String assignedTo,String updateDuedate,String updateStatus,String updatePriority){
        List<String> lstTaskIds = selectedTasks != null ? selectedTasks.split(',') : new List<String>();
        List<Task> lstTask = new List<Task>();
        if(!lstTaskIds.isEmpty()){
            lstTask = [select id,OwnerId,ActivityDate,Status,Priority from Task where Id IN : lstTaskIds];
        }
        for(Task t : lstTask){
            t.OwnerId = assignedTo != '000000000000000' && assignedTo != '' ? assignedTo : t.OwnerId;
            t.ActivityDate = updateDuedate != null && updateDuedate != '' ? Date.parse(updateDuedate) : t.ActivityDate;
            t.Status = updateStatus != null && updateStatus != '' && updateStatus != '--None--' ? updateStatus : t.Status;
            t.Priority = updatePriority != null && updatePriority != '' && updatePriority != '--None--'? updatePriority : t.Priority;
        }
        if(lstTask.size () > 0) {
           if(FLS.taskUpdateable()){
                update lstTask;
           }
        }
        JsonExistingData jed = new JsonExistingData();
        jed = viewTaskEventTabWithSearch(planId,'',searchText);
        System.debug('---------jed--------->'+jed);
        return jed;
     }
     
     
     //Method to Batch update Activities tab called from parseModifiedData javascript method
    @RemoteAction
    public static JsonExistingData updateActivitesTab(String modifiedDataStr, String searchText, String planId){
        
        // Dynamic picklist for tasks status & language issue fixes
        Schema.DescribeFieldResult  statusResult = Task.Status.getDescribe();
        List<Schema.PicklistEntry>  statusPickList = statusResult.getPicklistValues();
        
        Map<String, String> taskstatus = new Map<String, String>();
        
        for(Schema.PicklistEntry statusValue : statusPickList){
            taskstatus.put(statusValue.getValue(),statusValue.getLabel());
        }
        
        // Dynamic picklist for tasks priority & language issue fixes
        Schema.DescribeFieldResult  priorityResult = Task.Priority.getDescribe();
        List<Schema.PicklistEntry>  priorityPickList = priorityResult.getPicklistValues();
        
        Map<String, String> taskpriority = new Map<String, String>();
        
        for(Schema.PicklistEntry priorityValue : priorityPickList){
            taskpriority.put(priorityValue.getValue(),priorityValue.getLabel());
        }
        
        // Search text to replace * with %
        if(searchText != ''){
            if(searchText.contains('*')){
                String SearchtextList=searchText.replaceAll('\\*','\\%');
                searchText = SearchtextList;
            }
        }
        
        String modifiedData = modifiedDataStr; 
        //Deserialize the list of Activiites from the JSON string
        dataWrapActivities  pv = (dataWrapActivities) System.JSON.deserialize(modifiedData, dataWrapActivities.class);
        System.debug('------>+ Pv json' +modifiedData);
        System.debug('------>+ pv' +pv);
        List<TaskEvent> allActivites = pv.data.models;
        
        List<Task> taskActivityList = new List<Task>();
        
        // List of task for related decision.
        taskActivityList = [select Id,WhatId,OwnerId, CreatedById,Owner.Name ,ActivityDate,Status,IsClosed,Priority,Subject,Description from Task where whatId=:planId ORDER BY CreatedDate DESC ];
        
        // Creating map for task to make dynamic task instance
        Map<Id,Task> taskMap = new Map<Id,Task>();
        
        // Assinging task id in map with task object instance
        for(Task t: taskActivityList){
            taskMap.put(t.Id,t);  
        }
        
        List<Event> eventActivityList = new List<Event>();
        // List of event for related decision.
        eventActivityList = [select id,WhatId,OwnerId,Owner.Name,CreatedById,ActivityDate,ActivityDateTime,Subject,Description from Event where whatId=:planId ORDER BY CreatedDate DESC ] ;
        
        // Creating map for task to make dynamic event instance
        Map<Id,Event> eventMap = new Map<Id,Event>();
        
        // Creating a map to make event instance when updating the task
        for(Event e : eventActivityList){
            eventMap.put(e.Id,e);
        }
        
        // Assigning and updating the values for the task.
        List<Task> tobeUpdatedTask = new List<Task>();
        for(TaskEvent aw : allActivites){
            if(taskMap.get(aw.Id) != null){
                Task t = taskMap.get(aw.Id);
                t.Subject = aw.subject;
                t.Description = aw.comments;
                /*if(aw.duedate != null && aw.duedate.length() > 10)
                    t.ActivityDate = Date.valueOf(aw.duedate).addDays(1);*/
                if(aw.duedateSort != null && String.Valueof(aw.duedateSort).length() > 0){
                    t.ActivityDate = aw.duedateSort.Date();   
                } else if(aw.duedateSort == null){
                    t.ActivityDate = null;
                }
                    
                t.Status = taskstatus.get(aw.status) == null ? aw.status : taskstatus.get(aw.status);
                //t.Description = aw.comments;
                t.Priority = taskpriority.get(aw.priority) == null ? aw.priority: taskpriority.get(aw.priority);
                
                tobeUpdatedTask.add(t);
            }
        }
        if(tobeUpdatedTask.size () > 0) {
           if(FLS.taskUpdateable()){
                update tobeUpdatedTask;
           }
        }
        
        // Assigning and updating the values for the event.
        List<Event> tobeUpdatedEvent = new List<Event>();
        for(TaskEvent aw : allActivites){
            if(eventMap.get(aw.Id) != null){
                Event e = eventMap.get(aw.Id);
                e.Subject = aw.subject;
                e.Description = aw.comments;
                System.debug('------aw.duedate------>'+aw.duedate);
                /*if(aw.duedate != null && aw.duedate.length() > 10){
                    string dttm = aw.duedate;
                    string dttm2 = dttm.replace('T',' ');
                    Integer indx = dttm2.indexOf('.');
                    if(indx != -1){
                        string newstr = dttm2.substring(0,indx);
                        System.debug('------newstr------>'+newstr);
                        e.ActivityDateTime = Datetime.valueOf(newstr).addDays(1);
                        
                    }
                }*/
                if(aw.duedateSort != null && String.Valueof(aw.duedateSort).length() > 0){
                    e.ActivityDateTime = aw.duedateSort;
                } else if(aw.duedateSort == null){
                    e.ActivityDateTime = null;
                }
                tobeUpdatedEvent.add(e);
            }
        }
        if(tobeUpdatedEvent.size () > 0) {
           if(FLS.eventUpdateable()){
                update tobeUpdatedEvent;
           }
        }
        
        JsonExistingData jed = new JsonExistingData();
        jed = viewTaskEventTabWithSearch(planId,'',searchText);
        return jed;
    }
     
     @RemoteAction 
     public static string viewAllRelationsTab(String planId, String tobeDeletedRelationshipId){
        
        // initialize General information class to get user locale date format and image static resouce url //
        //GeneralInformation genralInfo  = new GeneralInformation();
        if(genralInfo == null ) {
            genralInfo  = new GeneralInformation();
        }
        List<UserRecordAccess > listUserRecordAccess = [SELECT RecordId, HasReadAccess, HasEditAccess, HasDeleteAccess,MaxAccessLevel FROM UserRecordAccess WHERE UserId=:UserInfo.getUserId() AND RecordId =:planId limit 1];
        if(listUserRecordAccess.size() > 0 && listUserRecordAccess[0].MaxAccessLevel=='All'){
            PermissionSet permissionset = new PermissionSet();
                    ObjectPermissions objPermissins = new ObjectPermissions();
                    try { 
                        permissionset = [SELECT Id FROM PermissionSet where ProfileId=:userinfo.getProfileId() Limit 1];
                        objPermissins = [SELECT Id,PermissionsModifyAllRecords FROM ObjectPermissions WHERE SobjectType = 'Plan__c' AND ParentId = :permissionset.Id Limit 1 ]; 
                    } catch (exception e){
                        permissionset = [SELECT Id FROM PermissionSet where Name = 'Fingertip_Access' Limit 1];
                        objPermissins = [SELECT Id,PermissionsModifyAllRecords FROM ObjectPermissions WHERE SobjectType = 'Plan__c' AND ParentId = :permissionset.Id Limit 1 ]; 
                    }  
                        if(objPermissins.PermissionsModifyAllRecords == true){
                             chkRecPermission=true;
                        }                           
        }
        if(tobeDeletedRelationshipId != null && tobeDeletedRelationshipId != '') {
           Relations__c toBeDeleteRelationship = [select id From Relations__c  where Id =: tobeDeletedRelationshipId ];
           if(Relations__c.sObjectType.getDescribe().isDeletable()){
                delete toBeDeleteRelationship;
           }
        }
        
        // contains a record of the user who is logged in.
        //Social_Input__c loggedInSocialPeople = new Social_Input__c();
        if(loggedInSocialPeople == null) {
            loggedInSocialPeople = new Social_Input__c();
            if([select id  from Social_Input__c where User__c =: userInfo.getUserId() AND Plan__c =: planId].size() > 0 ) {
                loggedInSocialPeople = [Select s.Veto_Rights__c, s.User__c, s.SystemModstamp, s.Select_People__c, s.SYS_Tab_View_Tasks__c, s.SYS_Tab_View_Social_Input__c, s.SYS_Tab_View_Relations__c, s.SYS_Tab_View_Quality__c, s.SYS_Tab_View_History__c, s.SYS_Tab_View_Attachments__c, s.SYS_Tab_View_Approvals__c, s.SYS_Tab_View_Activites__c, s.Role__c, s.Role_Acceptance_Status__c, s.Role_Acceptance_Required__c, s.Result__c, s.Responsible__c, s.Rating__c, s.Plan__c, s.OwnerId, s.Outcome__c, s.Name_of_the_User__c, s.Name, s.Mood__c, s.Like__c, s.LastModifiedDate, s.LastModifiedById, s.Is_Group__c, s.IsDeleted, s.Informed__c, s.Id, s.Group_Name__c, s.GroupId__c, s.Final_Approval_Status__c, s.Effort__c, s.Dislike__c, s.Description__c, s.Decision__c, s.CreatedDate, s.CreatedById, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c, s.Accountable__c From Social_Input__c s where User__c =: userInfo.getUserId() AND Plan__c =: planId limit 1 ];
            }
        }
           
        
        List<Relations> relationshipList = new List<Relations>(); 
        for(Relations__c relations : [Select id, Type__c, Strength__c, From_Relation__c, Parent_Record_Name__c, Parent_Object_Name__c, Parent_ID__c, Notes__c, To_Relation__c, Child_Record_Name__c, Child_Object_Name__c, Child_ID__c,OwnerId  From Relations__c where Type__c =: 'Relation' and (Parent_ID__c =: planId or Child_ID__c =: planId) order by lastModifiedDate DESC]){
           Relations rel = new Relations();
           rel.id = relations.id;
           if(relations.Child_Object_Name__c != 'User'){    
                rel.recordId = relations.Parent_ID__c == planId ? relations.Child_ID__c : relations.Parent_ID__c;
           } else {
                rel.recordId = relations.Parent_ID__c == planId ? relations.Child_ID__c : relations.Parent_ID__c;
                rel.recordId = rel.recordId+'?noredirect=1';
           }
           rel.recordName = relations.Parent_ID__c == planId ? (relations.Child_Record_Name__c != null ? relations.Child_Record_Name__c : '') : (relations.Parent_Record_Name__c != null ? relations.Parent_Record_Name__c : '');
           rel.objectName = relations.Parent_ID__c == planId ? relations.Child_Object_Name__c : relations.Parent_Object_Name__c;
           rel.relation = relations.Parent_ID__c == planId ?  (relations.From_Relation__c != null ? relations.From_Relation__c : '') : (relations.To_Relation__c != null ? relations.To_Relation__c : '');
           rel.strength = relations.Strength__c != null ? relations.Strength__c : '';
           rel.notes = relations.Notes__c != null ? relations.Notes__c : '';
           
           
           rel.relatedToId = relations.Parent_ID__c == planId ? relations.Parent_ID__c : relations.Child_ID__c;
           rel.Type = relations.Parent_ID__c == planId ? '1' : '2';
           
           
           rel.isDeletable= false;
           rel.isEditable = false; 
           rel.actionClassName = 'grid-action-disabled';
            
            if(loggedInSocialPeople.Accountable__c || loggedInSocialPeople.Backup_for_Accountable__c || chkRecPermission == true || (relations.OwnerId == userInfo.getUserId() && loggedInSocialPeople.Responsible__c) ) {
                rel.isDeletable =  true;
                rel.isEditable = true;
                rel.actionClassName = '';
            }
            
            rel.url = rel.isEditable ? '/apex/editRelationship?id='+rel.relatedToId+'&relId='+relations.id+'&type='+rel.Type+'&relPlan=true' : 'javascript:void(0)';
            rel.editImage = genralInfo.editImage.get(rel.isEditable);
            rel.deleteImage = genralInfo.deleteImage.get(rel.isDeletable);
           
           relationshipList.add(rel);
        }    
       
        relationsJSON = JSON.serialize(relationshipList);
        System.debug(relationsJSON );
        return relationsJSON ;
    }
    
    // To delete notes and attachment records
    @RemoteAction
    public static string deleteNotesAttachments(String planID, String attachmentID, String attachmentType){
       /*   if(attachmentType == 'Attachment') {
            if(Attachment.sObjectType.getDescribe().isDeletable()) {
                delete [select id from Attachment where Id =: attachmentID];
            }
        }
        else {
            if(Note.sObjectType.getDescribe().isDeletable()) {
                delete [select id from Note where Id =: attachmentID];
            }
        }
        return viewAttachmentNoteTab(planID); */
        return null;
    }
     
     @RemoteAction
     public static string viewAttachmentNoteTab(String planId){
          
        // initialize General information class to get user locale date format and image static resouce url //
        //GeneralInformation genralInfo  = new GeneralInformation();
        /* if(genralInfo == null ) {
            genralInfo  = new GeneralInformation();
        }
        
        // assign user locale date format as string 
        dateTimeFormat = genralInfo.MapValuesDateTime();
        
        //initialize attachment and note list
        List<AttachmentNote> attachmentNoteList = new List<AttachmentNote>();
        
        // contains a record of the user who is logged in.
        //Social_Input__c loggedInSocialPeople = new Social_Input__c();
        if(loggedInSocialPeople == null) {
            loggedInSocialPeople = new Social_Input__c();
            if([select id  from Social_Input__c where User__c =: userInfo.getUserId() AND Plan__c =: planId].size() > 0 ) {
                loggedInSocialPeople = [Select s.Veto_Rights__c, s.User__c, s.SystemModstamp, s.Select_People__c, s.SYS_Tab_View_Tasks__c, s.SYS_Tab_View_Social_Input__c, s.SYS_Tab_View_Relations__c, s.SYS_Tab_View_Quality__c, s.SYS_Tab_View_History__c, s.SYS_Tab_View_Attachments__c, s.SYS_Tab_View_Approvals__c, s.SYS_Tab_View_Activites__c, s.Role__c, s.Role_Acceptance_Status__c, s.Role_Acceptance_Required__c, s.Result__c, s.Responsible__c, s.Rating__c, s.Plan__c, s.OwnerId, s.Outcome__c, s.Name_of_the_User__c, s.Name, s.Mood__c, s.Like__c, s.LastModifiedDate, s.LastModifiedById, s.Is_Group__c, s.IsDeleted, s.Informed__c, s.Id, s.Group_Name__c, s.GroupId__c, s.Final_Approval_Status__c, s.Effort__c, s.Dislike__c, s.Description__c, s.Decision__c, s.CreatedDate, s.CreatedById, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c, s.Accountable__c From Social_Input__c s where User__c =: userInfo.getUserId() AND Plan__c =: planId limit 1 ];
            }
        }
        
        if(profile == null) { 
            profile = new Profile();  
            profile =[Select Id,Name From Profile where Name=: 'System Administrator' limit 1];
        }
        
        //Mapping fields for attachment
        for(Attachment attachment : [Select ParentId, OwnerId, Owner.Name, Name, LastModifiedDate, Id, CreatedById From Attachment where parentId =: planId]) {
            
            if(attachment.Name != String.Valueof(attachment.ParentId)) {
                AttachmentNote an = new AttachmentNote();
                an.id = attachment.Id;
                an.type = 'Attachment';
                an.name = attachment.Name;
                an.lastModifiedDate = attachment.LastModifiedDate.format(dateTimeFormat);
                an.createdByUser =  attachment.owner.Name;
                an.createdByUserImage = genralInfo.useImage.get(attachment.OwnerId);
                an.isDeletable= false;
                an.isEditable = false; 
                
                an.actionClassName = 'grid-action-disabled';
                
                if(loggedInSocialPeople.Accountable__c || loggedInSocialPeople.Backup_for_Accountable__c || Userinfo.getProfileId() == profile.Id || (attachment.OwnerId == userInfo.getUserId() && loggedInSocialPeople.Responsible__c) ) {
                    an.isDeletable =  true;
                    an.isEditable = true;
                    an.actionClassName = '';
                }
                an.deleteImage = genralInfo.deleteImage.get(an.isDeletable);
                an.editImage = genralInfo.editImage.get(an.isEditable);
                an.url = an.isEditable ? '/'+an.id+'/e?retURL='+attachment.ParentId :  'javascript:void(0)';
                attachmentNoteList.add(an);
            }
        } 
        
        //Mapping fileds for notes
        for(Note note: [Select ParentId, OwnerId, Title, owner.Name, LastModifiedDate, Id, CreatedById From Note where parentId =: planId]) {
            AttachmentNote an = new AttachmentNote();
            an.id = note.Id;
            an.type = 'Note';
            an.name = note.Title;
            an.lastModifiedDate = note.LastModifiedDate.format(dateTimeFormat);
            an.createdByUser = note.owner.Name;
            an.createdByUserImage = genralInfo.useImage.get(note.OwnerId);
            an.isDeletable= false;
            an.isEditable = false; 
            
            an.actionClassName = 'grid-action-disabled';
            
            if(loggedInSocialPeople.Accountable__c || loggedInSocialPeople.Backup_for_Accountable__c || Userinfo.getProfileId() == profile.Id || (note.OwnerId == userInfo.getUserId() && loggedInSocialPeople.Responsible__c)) {
                an.isDeletable =  true;
                an.isEditable = true;
                an.actionClassName = '';
            }
            an.deleteImage = genralInfo.deleteImage.get(an.isDeletable);
            an.editImage = genralInfo.editImage.get(an.isEditable);
            an.url = an.isEditable ? '/'+an.id+'/e?retURL='+note.ParentId :  'javascript:void(0)';
            attachmentNoteList.add(an);
        }   
        
            
        if(Userinfo.getProfileId() == profile.Id) {
         
            set<Id> relatedRecordIds = new set<Id>();
            for(FeedComment fc: [SELECT Id, RelatedRecordId  FROM FeedComment where ParentId =: planId]) {
                if(fc.RelatedRecordId != null ) {
                    relatedRecordIds.add(fc.RelatedRecordId);
                }
            }
            
            if(relatedRecordIds.SIZE() > 0 ) {
                for(ContentVersion cv: [SELECT Id, Title, OwnerId, LastModifiedDate, CreatedById  FROM ContentVersion where Id In: relatedRecordIds]) {
                    AttachmentNote att = new AttachmentNote();
                    att.id = cv.Id;
                    att.type = 'Feed Attachment';
                    att.name = cv.Title;
                    att.lastModifiedDate = cv.LastModifiedDate.format(dateTimeFormat);
                    att.createdByUser = genralInfo.useNameMap.get(cv.CreatedById).Name;
                    att.createdByUserImage = genralInfo.useImage.get(cv.CreatedById);
                
                    att.isDeletable= false;
                    att.isEditable = false; 
                    att.actionClassName = 'grid-action-disabled';
                    att.deleteImage = genralInfo.deleteImage.get(att.isDeletable);
                    att.editImage = genralInfo.editImage.get(att.isEditable);
                    
                    attachmentNoteList.add(att);    
                }
            }
            
            for(FeedItem  fi : [SELECT Type, Title, Id, LastModifiedDate, CreatedById, RelatedRecordId  FROM FeedItem  WHERE (ParentId =: planId AND Type  = 'ContentPost')]) {
                AttachmentNote att = new AttachmentNote();
                att.id = fi.Id;
                att.type = 'Feed Attachment';
                att.name = fi.Title;
                att.lastModifiedDate = fi.LastModifiedDate.format(dateTimeFormat);
                att.createdByUser = genralInfo.useNameMap.get(fi.CreatedById).Name;
                att.createdByUserImage = genralInfo.useImage.get(fi.CreatedById);
                
                att.isDeletable= false;
                att.isEditable = false; 
                att.actionClassName = 'grid-action-disabled';
                att.deleteImage = genralInfo.deleteImage.get(att.isDeletable);
                att.editImage = genralInfo.editImage.get(att.isEditable);
                att.id =  fi.RelatedRecordId ;
                
                attachmentNoteList.add(att);
            }
        }
        
        //serialize notes and attachment records list
        attachmentNoteJSON = JSON.serialize(attachmentNoteList);
        return attachmentNoteJSON; */
        
        return null;
     }
     
     // Plan History tab 
     @RemoteAction
     public static String viewHistory(String planId) {
        
        // initialize General information class to get user locale date format and image static resouce url //
        //GeneralInformation genralInfo  = new GeneralInformation();
        if(genralInfo == null ) {
            genralInfo  = new GeneralInformation();
        }
        
        dateTimeFormat = genralInfo.MapValuesDateTime();
        
        List<CommonHistory> commonHistoryList = new List<CommonHistory>();
        for(Task tt: [select id,WhatId,OwnerId, Owner.Name ,ActivityDate,Status,Priority,Subject,Description from Task where whatId=:planId and Status=:'completed' ] ){
             // for generating list of 'History Tab' (Task) 
            CommonHistory chTask = new CommonHistory();
            Time myTime1 = Time.newInstance(00, 00, 00, 00);
            if(tt.ActivityDate != null) {
                Date dt = tt.ActivityDate;
                DateTime dtTime = DateTime.newInstance(dt,myTime1);
                chTask.chDateTime = dtTime;
                chTask.duedate = dtTime.format();
            }
            chTask.status = tt.Status;
            chTask.assignedTo = tt.Owner.Name;
            chTask.assignedToId = genralInfo.useImage.get(tt.OwnerId);
            chTask.subject= tt.Subject;
            chTask.comments = tt.Description == null ? '' : tt.Description;
            chTask.relatedTo = 'Task';
            // added on 2014-04-25
            
            chTask.duedateSort= tt.ActivityDate!=null? tt.ActivityDate:null;
            // added on 2014-04-25
            commonHistoryList.add(chTask);
            //
        }
        
        for(Event ee: [select id,WhatId,OwnerId,Owner.Firstname,Owner.Lastname,ActivityDate,ActivityDateTime,Subject,Description from Event where whatId=:planId and ActivityDate < Today ]){
             // for generating list of 'History Tab' (Event)
            CommonHistory chEvent = new CommonHistory();
            
            chEvent.chDateTime = ee.ActivityDateTime;
            chEvent.duedate = ee.ActivityDateTime.format();
            chEvent.assignedTo = ee.Owner.Firstname + ee.Owner.Lastname;
            chEvent.assignedToId = genralInfo.useImage.get(ee.OwnerId);
            chEvent.comments = ee.Description == null ? '' : ee.Description;
            chEvent.relatedTo = 'Event';
             // added on 2014-04-25
            
            chEvent.duedateSort= ee.ActivityDateTime!=null? ee.ActivityDateTime:null;
            // added on 2014-04-25
            commonHistoryList.add(chEvent);
             
        }
        
        
        
        // call history class to get history data
        GenerlHistoryComponent gh = new GenerlHistoryComponent();
        List<GenerlHistoryComponent.objectHistoryLine> obhLineList = new List<GenerlHistoryComponent.objectHistoryLine>();
        gh.myObject = Schema.getGlobalDescribe().get('Plan__c').newSObject();
        gh.myObjectId = planId;
        obhLineList = gh.getObjectHistory(gh.myObjectId, gh.myObject);
        for(GenerlHistoryComponent.objectHistoryLine historyDecision : obhLineList){
            commonHistory ch=new commonHistory();
            ch.chDateTime  = historyDecision.theDate;
            if(historyDecision.theDate != null) {
                ch.duedate = historyDecision.theDate.format();
            }
            ch.relatedTo = 'Field Change';
            ch.assignedTo =historyDecision.who;
            ch.assignedToId =  genralInfo.useImage.get(historyDecision.userId);
            ch.status = (historyDecision.action.replaceAll('<b>', '')).replaceAll('</b>','');
            ch.comments = '';
             // added on 2014-04-25
            ch.duedateSort= historyDecision.theDate!=null? historyDecision.theDate:null;
            // added on 2014-04-25
            
            commonHistoryList.add(ch);
        }
        
        // sorting by datetime
        map<DateTime, List<CommonHistory>> dateTimeCommonHistoryMap = new map<DateTime, List<CommonHistory>>();
        List<CommonHistory> commonHistoryListNew = commonHistoryList.clone();
        commonHistoryList.clear();
        for(CommonHistory c: commonHistoryListNew) {
            List<commonHistory> chMappedList =  dateTimeCommonHistoryMap.get(c.chDateTime);
            if(chMappedList == null) {
                chMappedList = new List<commonHistory>();
                dateTimeCommonHistoryMap.put(c.chDateTime,chMappedList);
            }
            chMappedList.add(c);
        }
        List<DateTime> dateTimeCHList = new List<DateTime>();
        dateTimeCHList.addAll(dateTimeCommonHistoryMap.keySet());
        dateTimeCHList.sort();
        map<Integer, DateTime> stringSortMap = new map<Integer, DateTime>();
        Integer listSize = dateTimeCHList.size();
        for(DateTime s: dateTimeCHList) {
            listSize--;
            stringSortMap.put(listSize, s);
        }
        List<DateTime> newDateTimeSortedList = new List<DateTime>();
        for(Integer i=0; i< = dateTimeCHList.size() ; i++) {
             newDateTimeSortedList.add(stringSortMap.get(i));
        }
        for(DateTime d: newDateTimeSortedList) {
            if(dateTimeCommonHistoryMap.get(d) != null ) {
                List<CommonHistory> ahList = new List<CommonHistory>();
                ahList = dateTimeCommonHistoryMap.get(d);
                for(CommonHistory a : ahList) {
                    commonHistory ch=new commonHistory();
                    ch = a;
                    if(ch.duedate != '' &&  ch.duedate != null ) {
                        commonHistoryList.add(ch);
                    }
                }
            }
        }
        
        historyJson = '';
        historyJson = JSON.serialize(commonHistoryList);
        return historyJson;
    }
    
    @RemoteAction
    public static string itemView1(String planId){    
        Plan__c plan = [select id from Plan__c where id=:planId];
        planId = string.valueOf(plan.Id);
        // Map to convert pulse status to integer
        map<string,Integer> pulseStatusMap = new map<string,Integer>();
        pulseStatusMap.put('Not Given',0);
        pulseStatusMap.put('Good',1);
        pulseStatusMap.put('Minor Challenges',2);
        pulseStatusMap.put('Critical',3);
        pulseStatusMap.put('Completed',4);
        pulseStatusMap.put('Completed with Problems',5);
        
        // initialize General information class to get user locale date format and image static resouce url //
        //GeneralInformation genralInfo  = new GeneralInformation();
        if(genralInfo == null ) {
            genralInfo  = new GeneralInformation();
        }
        List<UserRecordAccess> listUserRecordAccess = [SELECT RecordId, HasReadAccess, HasEditAccess, HasDeleteAccess,MaxAccessLevel FROM UserRecordAccess WHERE UserId=:UserInfo.getUserId() AND RecordId =:planId limit 1];
        if(listUserRecordAccess.size() > 0 && listUserRecordAccess[0].MaxAccessLevel=='All'){
                PermissionSet permissionset = new PermissionSet();
                ObjectPermissions objPermissins = new ObjectPermissions();
                try { 
                    permissionset = [SELECT Id FROM PermissionSet where ProfileId=:userinfo.getProfileId() Limit 1];
                    objPermissins = [SELECT Id,PermissionsModifyAllRecords FROM ObjectPermissions WHERE SobjectType = 'Plan__c' AND ParentId = :permissionset.Id Limit 1 ]; 
                } catch (exception e){
                    permissionset = [SELECT Id FROM PermissionSet where Name = 'Fingertip_Access' Limit 1];
                    objPermissins = [SELECT Id,PermissionsModifyAllRecords FROM ObjectPermissions WHERE SobjectType = 'Plan__c' AND ParentId = :permissionset.Id Limit 1 ]; 
                }  
                        if(objPermissins.PermissionsModifyAllRecords == true){
                            chkRecPermission=true;
                        }
        }
        List<Relations__c> reltionshipList;
        reltionshipList = getPlanRelation(planId);
        recordChildId = new Set<Id>();
        recordParentId = new Set<Id>();
        decisionSet = new Set<Id>();
         
        // contains a record of the user who is logged in.
        //Social_Input__c loggedInSocialPeople = new Social_Input__c();
        if(loggedInSocialPeople == null) {
            loggedInSocialPeople = new Social_Input__c();
            if([select id  from Social_Input__c where User__c =: userInfo.getUserId() AND Plan__c =: planId].size() > 0 ) {
                loggedInSocialPeople = [Select s.Veto_Rights__c, s.User__c, s.SystemModstamp, s.Select_People__c, s.SYS_Tab_View_Tasks__c, s.SYS_Tab_View_Social_Input__c, s.SYS_Tab_View_Relations__c, s.SYS_Tab_View_Quality__c, s.SYS_Tab_View_History__c, s.SYS_Tab_View_Attachments__c, s.SYS_Tab_View_Approvals__c, s.SYS_Tab_View_Activites__c, s.Role__c, s.Role_Acceptance_Status__c, s.Role_Acceptance_Required__c, s.Result__c, s.Responsible__c, s.Rating__c, s.Plan__c, s.OwnerId, s.Outcome__c, s.Name_of_the_User__c, s.Name, s.Mood__c, s.Like__c, s.LastModifiedDate, s.LastModifiedById, s.Is_Group__c, s.IsDeleted, s.Informed__c, s.Id, s.Group_Name__c, s.GroupId__c, s.Final_Approval_Status__c, s.Effort__c, s.Dislike__c, s.Description__c, s.Decision__c, s.CreatedDate, s.CreatedById, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c, s.Accountable__c From Social_Input__c s where User__c =: userInfo.getUserId() AND Plan__c =: planId limit 1 ];
            }
        }
        
      /*  if(profile == null) { 
            profile = new Profile();  
            profile =[Select Id,Name From Profile where Name=: 'System Administrator' limit 1];
        }*/
        //Profile profileOfUser =[Select p.Name,p.Id From Profile p where p.id =: UserInfo.getProfileId() ];
         for(Relations__c r:reltionshipList ){
             recordChildId.add(r.Child_Id__c);
              if(r.Child_Object_Name__c == 'Decision'){
                 decisionSet.add(r.Child_Id__c);
             }
         }    
        
        map<Id,Social_Input__c> myRoleInDecisionMap = new map<Id,Social_Input__c>();
        map<Id,Decision__c> decisionMap = new map<Id,Decision__c>();
        map<Id,Social__c> socialMap = new map<Id,Social__c>();
        map<Id,List<Social_Input__c>> raciVetoMap = new map<Id,List<Social_Input__c>>(); 
        // approval list mapping 
        map<Id,List<Social_Input__c>> pendingRaciListMap = new map<Id,List<Social_Input__c>>();
        map<Id,List<Social_Input__c>> appRaciListMap = new map<Id,List<Social_Input__c>>();
        map<Id,List<Social_Input__c>> rejRaciListMap = new map<Id,List<Social_Input__c>>();
        system.debug( recordChildId );
        
        //Query all task ,lead, case and solution objects where status is there for status view
        map<Id,Task> taskMap = new map<Id,task>([Select id,IsClosed,status,ActivityDate,Actual_Hours__c,Complexity__c,Estimated_Hours__c,Skill_Level__c,Stage_Formula__c,Stage__c from task where id in:recordChildId]);
        map<Id,lead> leadMap = new map<Id,lead>([Select id,status  from lead where id in:recordChildId]);
        map<Id,case> caseMap = new map<Id,case>([Select id,status  from case where id in:recordChildId]);
        map<Id,solution> solutionMap = new map<Id,solution>([Select id,status  from solution where id in:recordChildId]);
        
        //check for task record acees for work view
        List<id> taskIds = new  List<id>(taskMap.keyset());
         // Query on user access records to get the record access for the logged in user. fetching based on above two task Ids list.
        List<UserRecordAccess> lstUserAccessRecords = [SELECT RecordId,HasAllAccess,HasDeleteAccess,HasEditAccess,HasTransferAccess,HasReadAccess FROM UserRecordAccess WHERE UserId =: userinfo.getUserId() AND RecordId IN : taskIds limit 200];
        Map<Id,Boolean> trackAccess = new Map<Id,Boolean>();
        Map<Id,Boolean> taskHasReadAccess = new Map<Id,Boolean>();
        for(UserRecordAccess l : lstUserAccessRecords){
            if(trackAccess.get(l.RecordId) == null){
                system.debug( '1======='+  l.HasEditAccess);
                
                trackAccess.put(l.recordId,l.HasEditAccess);
                taskHasReadAccess.put(l.recordId,l.HasReadAccess);
            }   
        }
        
        
       
        //map<Id,List<Issues__c>> issueMap = new map<Id,List<Issues__c>>();
        if(decisionSet.size() > 0){
            //decisions
            for(Decision__c dec: [select id,phase__c,Progress__c,status__c,Estimated_Revenue__c, Estimated_Investment__c, Estimated_Direct_Cost__c, Estimated_Net_Present_Value__c, Estimated_People_Involved__c, Estimated_Full_time_Equivalent_FTE__c from Decision__c where Id In: recordChildId]) {
                decisionMap.put(dec.Id, dec);
            }
            
            //social
            for(Social__c soc: [select id, Avg_Mood__c,Related_To_ID__c from Social__c where Related_To_ID__c In: recordChildId]) {
                socialMap.put(soc.Related_To_ID__c, soc);
            }
            
          
            
            List<Social_Input__c> raciList = [select id,Role_Acceptance_Status__c,Stance_Approval_Status__c,Final_Approval_Status__c,Decision__c,Veto_Rights__c,Responsible__c,Informed__c, Consulted__c, Backup_for_Accountable__c, Accountable__c  from Social_Input__c where Decision__c In: recordChildId];
            
            List<Social_Input__c> myRoleOnDecisionList = [select id,Role_Acceptance_Status__c,Final_Approval_Status__c,Decision__c,Veto_Rights__c,Responsible__c,Informed__c, Consulted__c, Backup_for_Accountable__c, Accountable__c  from Social_Input__c where Decision__c In: recordChildId and User__c =: userInfo.getUserId()];
            
            for(Social_Input__c s: myRoleOnDecisionList){
                if(myRoleInDecisionMap.get(s.Decision__c) == null)
                    myRoleInDecisionMap.put(s.Decision__c,s);   
            }
            
            for(Social_Input__c r: raciList){
                if(r.Stance_Approval_Status__c == 'Pending Approval'){
                    List<Social_Input__c> pendingRaciList =  pendingRaciListMap.get(r.Decision__c);
                    if(pendingRaciList == null) {
                     pendingRaciList = new List<Social_Input__c>();
                     pendingRaciListMap.put(r.Decision__c, pendingRaciList);
                    }
                    pendingRaciList.add(r);
                }
                if(r.Stance_Approval_Status__c == 'Approved'){
                    List<Social_Input__c> approveRaciList =  appRaciListMap.get(r.Decision__c);
                    if(approveRaciList == null) {
                     approveRaciList = new List<Social_Input__c>();
                     appRaciListMap.put(r.Decision__c, approveRaciList);
                    }
                    approveRaciList.add(r);
                }
                if(r.Stance_Approval_Status__c == 'Rejected'){
                    List<Social_Input__c> rejectRaciList =  rejRaciListMap.get(r.Decision__c);
                    if(rejectRaciList == null) {
                     rejectRaciList = new List<Social_Input__c>();
                     rejRaciListMap.put(r.Decision__c, rejectRaciList);
                    }
                    rejectRaciList.add(r);
                }
                
                raciList = raciVetoMap.get(r.Decision__c);
                if(raciList == null) {
                    raciList = new List<Social_Input__c>();
                    raciVetoMap.put(r.Decision__c,raciList);
                }
                raciList.add(r);
            }
         }
         
         ownerDetail(recordChildId);
         Double totalMins = 0;
         Double totalHrs = 0;
         Double totalDays = 0;
         Long totalEstimated = 0;
         Long totalActual = 0;
         Integer i = 0;
         
         List<AllPlanJsonWrapper> allPlanJsonWrapperList = new List<AllPlanJsonWrapper >();
        
         //itemPlanWrapperMap = new map<Id,Relationship__c>();
      
         for(Relations__c r: reltionshipList) {  
            AllPlanJsonWrapper apWrap = new AllPlanJsonWrapper();
            apWrap.Id = r.Id;
            apWrap.Name= r.Child_Record_Name__c.replaceAll('<[^>]+>',' ').replaceAll('\"','').replaceAll('\'','').replaceAll('\\\\','');
            apWrap.Minutes = r.Minutes__c == null ? '0' : r.Minutes__c;   //,Plan_Days_Duration__c
            apWrap.Hours = r.Hours__c == null ? '0' : r.Hours__c;
            apWrap.Days = r.Days__c == null ? '0' : r.Days__c;
            apWrap.Owner = recordOwnerNameMap.get(r.Child_Id__c) != null ? recordOwnerNameMap.get(r.Child_Id__c).replaceAll('<[^>]+>',' ').replaceAll('\"','').replaceAll('\'','').replaceAll('\\\\','') : '';
            apWrap.popupField1 = recordPopupField1Map.get(r.Child_Id__c) != null ? recordPopupField1Map.get(r.Child_Id__c).replaceAll('<[^>]+>',' ').replaceAll('\"','').replaceAll('\'','').replaceAll('\\\\','') : '';
            apWrap.popupField2 = recordPopupField2Map.get(r.Child_Id__c) != null ? recordPopupField2Map.get(r.Child_Id__c).replaceAll('<[^>]+>',' ').replaceAll('\"','').replaceAll('\'','').replaceAll('\\\\','') : '';
            apWrap.popupField3 = recordPopupField3Map.get(r.Child_Id__c) != null ? recordPopupField3Map.get(r.Child_Id__c).replaceAll('<[^>]+>',' ').replaceAll('\"','').replaceAll('\'','').replaceAll('\\\\','') : '';
            apWrap.popupFieldName1 = recordPopupField1NameMap.get(r.Child_Id__c) != null ? recordPopupField1NameMap.get(r.Child_Id__c) : 'Insufficient privileges';
            apWrap.popupFieldName2 = recordPopupField2NameMap.get(r.Child_Id__c) != null ? recordPopupField2NameMap.get(r.Child_Id__c) : ''; 
            apWrap.popupFieldName3 = recordPopupField3NameMap.get(r.Child_Id__c) != null ? recordPopupField3NameMap.get(r.Child_Id__c) : ''; 
            apWrap.description = r.Description__c == null ? ' ' : r.Description__c;
            apWrap.Position = String.valueOf(r.Position__c);
            apWrap.Type = r.Child_Object_Name__c;
            apWrap.typeClass  = r.Child_Object_Name__c == 'Note'? 'plan-item-bold':'plan-item-normal';
            apWrap.itemRecordId = r.Child_Id__c;
            apWrap.isDeletable= false;    
            apWrap.isEditable = false;
            apWrap.ismoveDown = false; 
            apWrap.ismoveUp = false; 
            apWrap.dragDrop = genralInfo.imageUrlMap.get('null');
            apWrap.dragDropText = '';
            System.debug(trackAccess);
            apWrap.status = '';
            apWrap.actionClassName = 'grid-action-disabled';
           // System.debug('----checking logging permissions-----'+loggedInSocialPeople.Accountable__c+'----------------'+loggedInSocialPeople.Backup_for_Accountable__c+'------------------'+loggedInSocialPeople.Responsible__c+'-------------'+profile.Id+'-----------'+userinfo.getProfileId());
            if(loggedInSocialPeople.Accountable__c || loggedInSocialPeople.Backup_for_Accountable__c || loggedInSocialPeople.Responsible__c || chkRecPermission == true) {
                apWrap.isDeletable= true;
                apWrap.isEditable = true;
                apWrap.ismoveDown = true; 
                apWrap.ismoveUp = true;
                apWrap.actionClassName = '';
                apWrap.dragDrop = genralInfo.imageUrlMap.get('dragDrop');
                apWrap.dragDropText = 'Drag to re-order the items';
            }
            apWrap.moveUp = apWrap.ismoveUp == true ? genralInfo.imageUrlMap.get('moveUp') : genralInfo.imageUrlMap.get('moveUpDisabled');
            apWrap.moveDown = apWrap.ismoveDown == true ? genralInfo.imageUrlMap.get('moveDown') : genralInfo.imageUrlMap.get('moveDownDisabled');
            apWrap.delItem = genralInfo.deleteImage.get(apWrap.isDeletable);
            apWrap.itemRecordId = r.Child_Id__c;
           
             
           
           
           
           
            apWrap.approve = appRaciListMap.get(Id.valueOf(r.Child_Id__c)) != null ? String.valueOf(appRaciListMap.get(Id.valueOf(r.Child_Id__c)).size()) : '0';
            apWrap.nostance = pendingRaciListMap.get(Id.valueOf(r.Child_Id__c)) != null ? String.valueOf(pendingRaciListMap.get(Id.valueOf(r.Child_Id__c)).size()) : '0';
            apWrap.disapprove = rejRaciListMap.get(Id.valueOf(r.Child_Id__c)) != null ? String.valueOf(rejRaciListMap.get(Id.valueOf(r.Child_Id__c)).size()) : '0';
            //apWrap.issue = issueMap.get(Id.valueOf(r.Child_Id__c)) != null ? String.valueOf(issueMap.get(Id.valueOf(r.Child_Id__c)).size()) : '' ;
            //apWrap.IssueImg= issueMap.get(Id.valueOf(r.Child_Id__c)) != null ? genralInfo.imageUrlMap.get('planFlagRed') : genralInfo.imageUrlMap.get('null');
            // if type is task then fill fields for work view             
            if( apWrap.Type == 'Task' && taskMap.get(r.Child_Id__c) != null ){
                
                //if the item is task fill details for workview
                apWrap.status  = taskMap.get(r.Child_Id__c).status == null?'':taskMap.get(r.Child_Id__c).status;
                apWrap.actualHours  = taskMap.get(r.Child_Id__c).Actual_Hours__c == null?0:taskMap.get(r.Child_Id__c).Actual_Hours__c ;
                apWrap.complexity  = taskMap.get(r.Child_Id__c).Complexity__c== null?' ':taskMap.get(r.Child_Id__c).Complexity__c ;
                apWrap.estimatedHours  = taskMap.get(r.Child_Id__c).Estimated_Hours__c==null?0:taskMap.get(r.Child_Id__c).Estimated_Hours__c;
                apWrap.skillLevel   = taskMap.get(r.Child_Id__c).Skill_Level__c == null? '1' :  taskMap.get(r.Child_Id__c).Skill_Level__c;
                apWrap.status  = taskMap.get(r.Child_Id__c).Status== null?'':taskMap.get(r.Child_Id__c).Status ; 
                // added by tanay
                apWrap.isTask = 'Task';
                apWrap.dueDatewrk  = taskMap.get(r.Child_Id__c).ActivityDate == null ? '' : taskMap.get(r.Child_Id__c).ActivityDate.format() ;   
                apWrap.delayTaskClass = taskMap.get(r.Child_Id__c).ActivityDate < date.today() && !taskMap.get(r.Child_Id__c).IsClosed ? 'delayTask' : taskMap.get(r.Child_Id__c).ActivityDate == null ? 'emptyDuedate' : '';
                apWrap.dueDateSort = taskMap.get(r.Child_Id__c).ActivityDate != null ? taskMap.get(r.Child_Id__c).ActivityDate: null;
                apWrap.isEditable  = trackAccess.get(r.Child_Id__c);
                System.debug(trackAccess.get(r.Child_Id__c));
                System.debug('==========');
                apWrap.isReadable = taskHasReadAccess.get(r.Child_Id__c);
                totalEstimated  = totalEstimated+ apWrap.estimatedHours.longValue() ;
                totalActual     = totalActual+ apWrap.actualHours.longValue();
                
            } 
            else
            if( apWrap.Type == 'Note'){
                //if the item is note fill with empty space
                apWrap.status  = '';
                apWrap.actualHours  = null;
                apWrap.complexity  = '';
                apWrap.estimatedHours  = null;
                apWrap.skillLevel   = '';  
                apWrap.status  =  '' ;   
                
            }
            else   // for case , lead, solution and  get status values 
            if(  apWrap.Type == 'Case' )
                if(caseMap.get(r.Child_Id__c) != null)
                apWrap.status  =   caseMap.get(r.Child_Id__c).status ;
            if(  apWrap.Type == 'Lead' ) 
               if(leadMap.get(r.Child_Id__c) != null)
                apWrap.status  =   leadMap.get(r.Child_Id__c).status ;   
            if(  apWrap.Type == 'Solution' )
               if(solutionMap.get(r.Child_Id__c) != null)
                apWrap.status  =   solutionMap.get(r.Child_Id__c).status ;   
              
            Decision__c dec = new Decision__c();
            if(decisionMap.get(Id.valueOf(r.Child_Id__c)) != null )
                dec = decisionMap.get(Id.valueOf(r.Child_Id__c));  
            
            
            apWrap.decisionClass = 'grid-action-disabled';
            apWrap.actionClassNameDecision = 'grid-action-disabled';
            /************* new task **********************/
            if(apWrap.Type != 'Decision'){
                apWrap.newTaskFromDecision = genralInfo.imageUrlMap.get('null');
                apWrap.newTaskFromDecisionIconTitle = '';  
                //apWrap.actionClassName = 'grid-action-disabled';
            }else{
                if(dec.Id == null){
                    apWrap.newTaskFromDecision = genralInfo.imageUrlMap.get('newTaskForDecisionDisabled');
                    apWrap.newTaskFromDecisionIconTitle = 'You are not part of the Decision, so you cannot create the task';
                    apWrap.canUserCreateTask = 'false';     
                }else{
                    if(chkRecPermission == true && dec.Phase__c != 'Close'){
                        System.debug('---condition 1----'+dec.Phase__c);
                        apWrap.decisionClass = 'new-item-decision';
                        apWrap.newTaskFromDecision = genralInfo.imageUrlMap.get('newTaskForDecision');
                        apWrap.newTaskFromDecisionIconTitle = 'Adds new task under this decision';  
                        apWrap.canUserCreateTask = 'true';      
                    }
                    else if(dec.Phase__c == 'Close'){
                        //apWrap.decisionClass = 'new-item-decision';
                        apWrap.newTaskFromDecision = genralInfo.imageUrlMap.get('newTaskForDecisionDisabled');
                        apWrap.newTaskFromDecisionIconTitle = 'The Decision is closed, so you cannot create task';  
                        apWrap.canUserCreateTask = 'false';     
                    }
                    else if(myRoleInDecisionMap.get(Id.valueOf(r.Child_Id__c)) != null){
                        apWrap.decisionClass = 'new-item-decision';
                        apWrap.newTaskFromDecision = genralInfo.imageUrlMap.get('newTaskForDecision');
                        apWrap.newTaskFromDecisionIconTitle = 'Adds new task under this decision';  
                        apWrap.canUserCreateTask = 'true';  
                        
                    }else{
                        apWrap.newTaskFromDecision = genralInfo.imageUrlMap.get('newTaskForDecisionDisabled');
                        apWrap.newTaskFromDecisionIconTitle = 'Your role of the decision does not allow you to create the task';    
                        apWrap.canUserCreateTask = 'false';
                    }
                }
            }
            
            
            if(dec.Id != null){
                String veto = 'approved';
                Integer vetNum = 0;
                Social__c soc = socialMap.get(Id.valueOf(r.Child_Id__c)); 
                List<Social_Input__c> raciList1 = new List<Social_Input__c>();
                raciList1 = r.Child_Id__c != null && raciVetoMap.get(Id.valueOf(r.Child_Id__c)) != null ? raciVetoMap.get(Id.valueOf(r.Child_Id__c)) : new List<Social_Input__c>();
                Boolean vetoPower = false;
                Boolean accoutableApproved = false;
                for(Social_Input__c si: raciList1) {
                   
                    
                    if(si.Veto_Rights__c) {
                        vetNum = vetNum + 1;
                        if(veto != 'rejected') {
                            
                            if(si.Stance_Approval_Status__c == 'Rejected'){
                                veto = 'rejected';
                            }
                            if((si.Stance_Approval_Status__c == 'Pending Approval' || si.Stance_Approval_Status__c == 'Approved') && veto != 'rejected' ){
                                veto = '';
                            }
                           
                        }
                        
                    }
                    
                    if((si.Accountable__c || si.Backup_for_Accountable__c)&& (si.Final_Approval_Status__c == 'Approved' || si.Final_Approval_Status__c == 'Rejected')  ) {
                        accoutableApproved = true;
                    }
                }
                
                if(veto == '' && accoutableApproved) {
                    veto = 'approved';
                }
                
            
                System.debug('----------------veto value--------'+veto);
                
                
                apWrap.actionClassNameDecision = '';
                       
                apWrap.phase = dec.Phase__c != null ? dec.Phase__c : '';
                apWrap.status = dec.Status__c != null ? dec.status__c : '';
                apWrap.progressValue  = pulseStatusMap.get(dec.Progress__c );
                /* *************** view4 *********** */
                //set progress indicator permission for eqach decision
                if( myRoleInDecisionMap.get(dec.id) != null)
                apWrap.piPermission =   (myRoleInDecisionMap.get(dec.id).Accountable__c || myRoleInDecisionMap.get(dec.id).Backup_for_Accountable__c || myRoleInDecisionMap.get(dec.id).responsible__c) && ( myRoleInDecisionMap.get(dec.id).Role_Acceptance_Status__c  == 'Approved/accepted' ) && ( dec.Status__c != 'Closed') ;
                apWrap.Investment = dec.Estimated_Investment__c != null ? String.valueOf(dec.Estimated_Investment__c.round()) : '';
                apWrap.DirectCost = dec.Estimated_Direct_Cost__c != null ? String.valueOf(dec.Estimated_Direct_Cost__c.round()) : '';
                apWrap.Revenue = dec.Estimated_Revenue__c != null ? String.valueOf(dec.Estimated_Revenue__c.round()) : '';
                apWrap.NetPresentValue = dec.Estimated_Net_Present_Value__c != null ? String.valueOf(dec.Estimated_Net_Present_Value__c.round()) : '';
                apWrap.PeopleInvolved = dec.Estimated_People_Involved__c != null ? String.valueOf(Integer.valueOf(dec.Estimated_People_Involved__c.round())) : '';
                apWrap.FTE = dec.Estimated_Full_time_Equivalent_FTE__c != null ? String.valueOf(dec.Estimated_Full_time_Equivalent_FTE__c) : '';
                
                /* *************** view3 *********** */
                apWrap.veto = String.valueOf(vetNum) != null ? String.valueOf(vetNum) : '' ;
                apWrap.mood = String.valueOf(soc.Avg_Mood__c) != null ? String.valueOf(math.round(soc.Avg_Mood__c)) : '';
                apWrap.moodClass = 'moodClass' + ( String.valueOf(soc.Avg_Mood__c) != null ? String.valueOf(math.round(soc.Avg_Mood__c)) : '');
                
                //apWrap.MoodImg = genralInfo.imageUrlMap.get('moodSprite');                
                /* *************** view2 *********** */
                apWrap.predictionResult = genralInfo.imageUrlMap.get(veto) != null ? genralInfo.imageUrlMap.get(veto) : genralInfo.imageUrlMap.get('null');  // to be replaced with image
            }else{
                apWrap.phase = '';
                if( !( (apWrap.Type == 'Task' ) || (apWrap.Type == 'Decision' ) || (apWrap.Type == 'Lead' ) || (apWrap.Type == 'Case' ) ||(apWrap.Type == 'Solution' ) ) )
                apWrap.status = '';
                
                /* *************** view4 *********** */
                apWrap.Investment = '';
                apWrap.DirectCost = '';
                apWrap.Revenue = '';
                apWrap.NetPresentValue = '';
                apWrap.PeopleInvolved = '';
                apWrap.FTE = '';
                
                /* *************** view3 *********** */
                apWrap.veto = '';
                apWrap.mood = '';
                
                /* *************** view2 *********** */
                apWrap.predictionResult = genralInfo.imageUrlMap.get('null');
                apWrap.MoodImg = genralInfo.imageUrlMap.get('null') ; 
            }
            
            
            allPlanJsonWrapperList.add(apWrap);
            //itemPlanWrapperMap.put(r.Id, r);
           
             
            if(r.Minutes__c != null) {
                totalMins = totalMins + Double.valueOf(r.Minutes__c);
            }
            if(r.Hours__c != null){
                totalHrs = totalHrs + Double.valueOf(r.Hours__c);
            }
            if(r.Days__c != null){
                totalDays = totalDays + Double.valueOf(r.Days__c);
            }
            
         }
        // count Mints
       
         if(totalMins  > = 60) {
            Integer hr = (totalMins/60).intValue();
            Integer mins = (totalMins - (hr * 60)).intValue();
            totalMins = mins;
            totalHrs = totalHrs + hr;
            //totalHoursMints = String.valueOf(hr) + ' hr : ' + String.valueOf(mins )  + ' mins';
         }
         if(totalHrs > 23){
            Integer days = (totalHrs/24).intValue();
            Integer hrs = (totalHrs - (days * 24)).intValue();
            totalHrs = hrs;
            totalDays = totalDays + days;   
         }
         
         
         
         String days = '';
         if(totalDays.intValue() < 2){
             days = 'day';
         }else{
             days = 'days';
         }
         
         String hours= '';
         if(totalHrs.intValue() < 2){
             hours = 'hour';
         }else{
             hours = 'hours';
         }
         
         String mins = '';
         if(totalMins.intValue() < 2){
             mins= 'min';
         }else{
             mins= 'mins';
         }
         // calulate total estmated hour and total actual hours for task object
         String estimated = '';
         if(totalEstimated < 2){
             estimated = 'hour';
         }else{
             estimated  = 'hours';
         }
         String actual = '';
         if(totalActual < 2){
             actual = 'hour';
         }else{
             actual  = 'hours';
         }
         // these variables are sent to vf page while loading
         totalHoursMints = String.valueOf(totalDays.intValue())+' '+days+' '+String.valueOf(totalHrs.intValue())+' '+hours+' '+String.valueOf(totalMins.intValue())+' '+mins;
         totalEstimatedHours = String.valueOf(totalEstimated) +' '+ estimated;
         totalActualHours = String.valueOf(totalActual) +' '+ actual;
         
         allItemJson = '';
      
         allItemJson = JSON.serialize(allPlanJsonWrapperList); 
         system.debug('============allItemJson========='+allItemJson);
         return allItemJson ;           
    } 
    
    // get all relation for plan 
    public static List<Relations__c> getPlanRelation(String PlanId) {
        System.debug('----------------------------->'+planId);
        relationMap = new map<Id,Relations__c>();
        if(planId != '' && planId != null) {
            List<Relations__c> relation = [select id,Minutes__c,Type__c,Hours__c,Days__c,Description__c,Parent_Record_Name__c, Parent_Id__c, Parent_Object_Name__c, Child_Object_Name__c, Child_Record_Name__c, Child_Id__c, Position__c  from Relations__c  where Parent_Id__c =: planId AND Type__c = 'Item'  order by Position__c asc limit 50000];
            for(relations__c r:relation){
                relationMap.put(r.Id,r);
            }
            return relation ;
        }
        else {
            return null;
        }
    }
    
    @RemoteAction
    public static String DeleteItem(String currId,String id){
        Relations__c relToBeDeleted = [select id from Relations__c where Id=:id];
        if (Relations__c.sObjectType.getDescribe().isDeletable()){
            delete relToBeDeleted ;
        }
        
        allItemJson = itemView1(currId);
        return allItemJson;
    }
    
    @RemoteAction
    Public static String moveUp(String currId,string ids){
        System.debug('---->'+ids);
        Id positionRecId = Id.valueOf(ids);
        Plan__c p = [select Id from Plan__c where Id=:currId];
        List<Relations__c> listOfRelationship = getPlanRelation(p.id);
        Relations__c toBeUpdateRelationship = relationMap.get(positionRecId);
        System.debug('---->Current Position'+toBeUpdateRelationship.Position__c);
        List<Relations__c> toBeUpdatedRelationshipList = new List<Relations__c>();
        
        if(toBeUpdateRelationship.Position__c != 1 && toBeUpdateRelationship.Position__c != null) {
            for(Relations__c  r: listOfRelationship) {
                
                if(r.Position__c == toBeUpdateRelationship.Position__c - 1 ) {
                    r.Position__c = toBeUpdateRelationship.Position__c;
                    
                    toBeUpdateRelationship.Position__c= toBeUpdateRelationship.Position__c - 1;
                    toBeUpdatedRelationshipList.add(toBeUpdateRelationship);
                    toBeUpdatedRelationshipList.add(r);
                    System.debug('hello'+r.Position__c);
                    break;
                }
            }
        }
        if(toBeUpdatedRelationshipList.size() > 0) {
            if (FLS.relationUpdateable()){
                update toBeUpdatedRelationshipList;
            }
        }
        allItemJson = itemView1(p.id);
        
        return allItemJson;
        
    }
    
    @RemoteAction
    Public static String moveDown(String currId,string ids){
        System.debug('---->'+ids);
        Id positionRecId = Id.valueOf(ids);
        Plan__c p = [select Id from Plan__c where Id=:currId];
        List<Relations__c> listOfRelationship = getPlanRelation(p.id);
        Relations__c toBeUpdateRelationship = relationMap.get(positionRecId);
        System.debug('---->Current Position'+toBeUpdateRelationship.Position__c);
        List<Relations__c> toBeUpdatedRelationshipList = new List<Relations__c>();
        
        if(toBeUpdateRelationship.Position__c < listOfRelationship.size() && toBeUpdateRelationship.Position__c != null) {
            for(Relations__c  r: listOfRelationship) {
                
                if(r.Position__c == toBeUpdateRelationship.Position__c + 1 ) {
                    r.Position__c = toBeUpdateRelationship.Position__c;
                    
                    toBeUpdateRelationship.Position__c= toBeUpdateRelationship.Position__c + 1;
                    toBeUpdatedRelationshipList.add(toBeUpdateRelationship);
                    toBeUpdatedRelationshipList.add(r);
                    System.debug('hello'+r.Position__c);
                    break;
                }
            }
        }
        if(toBeUpdatedRelationshipList.size() > 0) {
            if (FLS.relationUpdateable()){
                update toBeUpdatedRelationshipList;
            }
        }
        allItemJson = itemView1(p.id);
        
        return allItemJson;
        
    }
    
    @RemoteAction
    public static string addNoteItems(String currId,string subject,string body){
        Plan__c p = [select id, Name from plan__c where Id=:currId];
        
        Note n = new Note();
        n.body = body;
        n.Title = subject;
        n.parentId = p.Id;
        if(FLS.noteCreateable()){
            insert n;
        }
        
        Relations__c r = new Relations__c();
        r.child_Id__c = n.Id;
        r.Child_Record_Name__c = subject;
        r.Child_Object_Name__c = 'Note';
        r.Parent_Id__c = p.Id;
        r.parent_Record_Name__c = p.Name;
        r.parent_Object_Name__c = 'Plan';
        r.type__c = 'Item';
        if(FLS.relationCreateable()){
            insert r;
        }
        
        //itemView1(p.id);
        allItemJson = itemView1(p.id);
        
        return allItemJson;
    }
    
    @RemoteAction
    public static string calTotalMins(String currId){
        Plan__c p = [Select Id from Plan__c where Id =: currId];
        List<Relations__c> reltionshipList;
        reltionshipList = getPlanRelation(p.Id);
        Double totalMins = 0;
        Double totalHrs = 0;
        Double totalDays = 0;
        Long totalEstimated = 0;
        Long totalActual = 0;
        recordChildId = new set<id>();
        for(Relations__c r:reltionshipList){
            if(r.Minutes__c != null) {
                totalMins = totalMins + Double.valueOf(r.Minutes__c);
            }
            if(r.Hours__c != null){
                totalHrs = totalHrs + Double.valueOf(r.Hours__c);
            }
            if(r.Days__c != null){
                totalDays = totalDays + Double.valueOf(r.Days__c);
            }
            // add each child id to this set to query taska nd caluclate sum of estimated and actual hours
            recordChildId.add(r.child_Id__c);
        }
        map<Id,Task> taskMap = new map<Id,task>([Select id,status,Actual_Hours__c,Complexity__c,Estimated_Hours__c,Skill_Level__c,Stage_Formula__c,Stage__c from task where id in:recordChildId]);
        
        
        
        if(totalMins  > = 60) {
            Integer hr = (totalMins/60).intValue();
            Integer mins = (totalMins - (hr * 60)).intValue();
            totalMins = mins;
            totalHrs = totalHrs + hr;
            //totalHoursMints = String.valueOf(hr) + ' hr : ' + String.valueOf(mins )  + ' mins';
         }
         if(totalHrs > 23){
            Integer days = (totalHrs/24).intValue();
            Integer hrs = (totalHrs - (days * 24)).intValue();
           // totalHrs = hrs;
            totalDays = totalDays + days;   
         }
         String days = '';
         if(totalDays.intValue() < 2){
             days = 'day';
         }else{
             days = 'days';
         }
         
         String hours= '';
         if(totalHrs.intValue() < 2){
             hours = 'hour';
         }else{
             hours = 'hours';
         }
         
         String mins = '';
         if(totalMins.intValue() < 2){
             mins= 'min';
         }else{
             mins= 'mins';
         }
        
        
        totalHoursMints = String.valueOf(totalDays.intValue())+' '+days+' '+String.valueOf(totalHrs.intValue())+' '+hours+' '+String.valueOf(totalMins.intValue())+' '+mins;
        // for each relation get task from task map
        for(Relations__c r: reltionshipList) {
                //if the actual or estimated hours are not empty add it to existing one
                if( r.Child_Object_Name__c == 'Task' && taskMap.get(r.Child_Id__c) != null ){  
                    if( taskMap.get(r.Child_Id__c).Estimated_Hours__c != null)
                    totalEstimated  = totalEstimated+ taskMap.get(r.Child_Id__c).Estimated_Hours__c.longValue() ;
                    if( taskMap.get(r.Child_Id__c).Actual_Hours__c != null)
                    totalActual     = totalActual+ taskMap.get(r.Child_Id__c).Actual_Hours__c.longValue();                
                }   
        }
        String estimated = '';
        if(totalEstimated  < 2){
             estimated = 'hour';
        }else{
             estimated  = 'hours';
        }
        String actual = '';
        if(totalActual  < 2){ 
             actual = 'hour';
        }else{
             actual  = 'hours';
        }
        //calulate the string to send vf page
        totalEstimatedHours = String.valueOf(totalEstimated) +' '+ estimated;
        totalActualHours = String.valueOf(totalActual) +' '+ actual; 
        // return json object
        return '{"totalHoursMints":"'+ Decimal.valueOf(totalMins).setScale(0) +'","totalEstimatedHours":"'+Decimal.valueOf(totalHrs).setScale(0)   +'","totalActualHours":"'+totalActualHours+'"}';
    }
    @RemoteAction
    public static string saveItemModifiedData(String currId,string modifiedData){
        Plan__c p = [Select Id from Plan__c where Id =: currId];
      
        String allPlanItemJson = modifiedData;
        System.debug('--------json,,,,,,,,,,>'+allPlanItemJson);
      /*  
        allPlanItemJson = allPlanItemJson.substringAfter(',' + '\"' + 'end' + '\"'+':');
        System.debug(allPlanItemJson);
        allPlanItemJson = allPlanItemJson.substringBefore( '}],'+ '\"' + '_view' + '\"' + ':');
        System.debug(allPlanItemJson);
        
        allPlanItemJson = allPlanItemJson.substringAfter(',');
        allPlanItemJson  = '{' + allPlanItemJson + '}';
        
        
        System.debug(allPlanItemJson);
        
       // return (JSON2Apex) System.JSON.deserialize(json, JSON2Apex.class);
        */
        
        //System.debug((PlanView) System.JSON.deserialize(modifiedData, PlanView.class));
        PlanView  pv = (PlanView) System.JSON.deserialize(modifiedData, PlanView.class);
        
        System.debug(pv.Data);
        List<AllPlanJsonWrapper> allPlanView = pv.Data.models;
       
        List<Relations__c> plnList =  getPlanRelation(p.Id);
        List<Relations__c> tobeUpdatedPlanItem = new List<Relations__c>();
        List<task> tobeUpdatedPlanTask = new List<task>();
        for(AllPlanJsonWrapper d : allPlanView) {
            Relations__c r = relationMap.get(d.Id);
            
            r.Description__c = d.Description;
            r.Position__c = Decimal.valueOf(d.Position);
             system.debug('------------------->Duration'+d.Minutes);
            r.Minutes__c = d.Minutes;
            r.Hours__c = d.Hours;
            r.Days__c =  d.Days;  
            if( d.Type== 'Task' )
            {
                
                task t = new task(id=d.itemRecordId);
                t.status = d.status;
                t.Actual_Hours__c = d.actualHours;
                t.Complexity__c = d.complexity;
                t.Estimated_Hours__c  = d.estimatedHours;
                t.Skill_Level__c = d.skillLevel;
                if(d.duedateSort != null && String.Valueof(d.duedateSort).length() > 0){
                    t.ActivityDate = d.duedateSort.Date();   
                } else if(d.duedateSort == null){
                    t.ActivityDate = null;
                }
                
                tobeUpdatedPlanTask.add(t);
            }
            tobeUpdatedPlanItem.add(r);
        }
        update tobeUpdatedPlanTask;
        if(tobeUpdatedPlanItem.size () > 0) {
           if(FLS.relationUpdateable()){
                update tobeUpdatedPlanItem;
           }
        }
        allItemJson = itemView1(p.id);
        
      
        return allItemJson;
    }
    
    
    
    // Cerate Collabrator Json String 
    @RemoteAction
    public static String planItemOrderChange(String itemSrcId, String itemSrcPos, String itemDesId, String itemDesPos) {
        
        Relations__c srcRelation = [select Id, Position__c, Parent_ID__c  from Relations__c  where Id =: itemSrcId ];
        Relations__c desRelation = [select Id, Position__c  from Relations__c  where Id =: itemDesId ];
        
        srcRelation.Position__c = Decimal.valueOf(itemDesPos);
        desRelation.Position__c = Decimal.valueOf(itemSrcPos);
        
        List<Relations__c> tobeUpdatedRelations = new List<Relations__c>();
        
        // Drag and drop functionality 
     
        for(Relations__c rel : [select id,Child_Record_Name__c,Parent_Record_Name__c ,Position__c from Relations__c where Parent_ID__c =: srcRelation.Parent_ID__c order by Position__c asc]) {
            
            if(Decimal.ValueOf(itemSrcPos) > Decimal.ValueOf(itemDesPos) ) {
               system.debug('xxxxxx' + rel.Position__c +'  '+ rel.Child_Record_Name__c +' '+ rel.Parent_Record_Name__c);
                if(rel.Position__c >= Decimal.ValueOf(itemDesPos)  && rel.Position__c < Decimal.ValueOf(itemSrcPos)) {                system.debug('yyyy');

                    rel.Position__c = rel.Position__c + 1;
                    tobeUpdatedRelations.add(rel);
                }
                else if(rel.Position__c == Decimal.ValueOf(itemSrcPos)) {                system.debug('zzzz');

                    rel.Position__c = Decimal.ValueOf(itemDesPos);
                    tobeUpdatedRelations.add(rel); 
                     
                }
                   system.debug(tobeUpdatedRelations); 
            }
            else {
                if(rel.Position__c > Decimal.ValueOf(itemSrcPos)  && rel.Position__c <= Decimal.ValueOf(itemDesPos)) {
                    rel.Position__c = rel.Position__c - 1;
                    tobeUpdatedRelations.add(rel);
                }
                else if(rel.Position__c == Decimal.ValueOf(itemSrcPos)) {
                    rel.Position__c = Decimal.ValueOf(itemDesPos);
                    tobeUpdatedRelations.add(rel);  
                }
            }
                    
        }
        
        
       // tobeUpdatedRelations.add(srcRelation);
       // tobeUpdatedRelations.add(desRelation);
        
        if(FLS.relationUpdateable()) {
            update tobeUpdatedRelations;
        }
        
        return itemView1(srcRelation.Parent_ID__c);
    }
    
    
    
    //Owner Details
    public static void ownerDetail(Set<Id> recordIdList) {
        recordOwnerMap = new map<Id, Id>();
        recordOwnerNameMap = new map<Id, String>();
        recordPopupField1Map = new map<Id,String>();
        recordPopupField2Map = new map<Id,String>();
        recordPopupField3Map = new map<Id,String>();
        recordPopupField1NameMap = new map<Id,String>();
        recordPopupField2NameMap = new map<Id,String>(); 
        recordPopupField3NameMap = new map<Id,String>(); 
        
        for(Decision__c d: [select id, OwnerId, Owner.Name,Problem_Idea_Advice__c,Decision_Taken__c,Priority__c from Decision__c where Id In: recordIdList]) {
            recordOwnerMap.put(d.Id, d.OwnerId);
            recordOwnerNameMap.put(d.Id, d.Owner.Name);
            if(d.Problem_Idea_Advice__c != null  )
            recordPopupField1Map.put(d.Id, d.Problem_Idea_Advice__c.replaceAll('\n',' ')); //.replaceall('<[^>]+>',' ').replaceAll('\'',''));
            //recordPopupField1NameMap.put(d.Id, 'Problem / Idea / Advice');
            recordPopupField1NameMap.put(d.Id, 'Description');
            if(d.Decision_Taken__c!= null  )
            recordPopupField2Map.put(d.Id, d.Decision_Taken__c.replaceAll('\n',' ')); //.replaceAll('<[^>]+>',' ').replaceAll('\'',''));
            recordPopupField2NameMap.put(d.Id, 'Decision');
            recordPopupField3Map.put(d.Id, '');
            recordPopupField3NameMap.put(d.Id,'');
        }
        
        for(Task  t: [select id, OwnerId, Owner.Name, Priority, Status, Type from Task where Id In: recordIdList]) {
            recordOwnerMap.put(t.Id, t.OwnerId);
            if( t.Owner.Name != null )
            recordOwnerNameMap.put(t.Id, t.Owner.Name.replaceAll('<[^>]+>',' ').replaceAll('\'',''));
            if( t.Priority != null )
            recordPopupField1Map.put(t.Id, t.Priority.replaceAll('<[^>]+>',' ').replaceAll('\'',''));
            recordPopupField1NameMap.put(t.Id, 'Priority');
            if( t.Status != null )
            recordPopupField2Map.put(t.Id, t.Status.escapeHtml4().replaceAll('<[^>]+>',' ').replaceAll('\'',''));
            recordPopupField2NameMap.put(t.Id, 'Status'); 
            recordPopupField3Map.put(t.Id,'');
            recordPopupField3NameMap.put(t.Id,''); 
        }
        
        for(Account a: [select id, OwnerId, Owner.Name,Name,Phone,Description from Account where Id In: recordIdList]) {
            recordOwnerMap.put(a.Id, a.OwnerId);
            if(a.Owner.Name != null  )
            recordOwnerNameMap.put(a.Id, a.Owner.Name.replaceAll('<[^>]+>',' ').replaceAll('\'',''));
            recordPopupField1Map.put(a.Id, a.Name);
            recordPopupField1NameMap.put(a.Id, 'Name');
            if(a.Description != null  )
            recordPopupField2Map.put(a.Id, a.Description.replaceAll('<[^>]+>',' ').replaceAll('\'',''));
            recordPopupField2NameMap.put(a.Id, 'Description');
            recordPopupField3Map.put(a.Id, '');
            recordPopupField3NameMap.put(a.Id, '');
        }
        
        for(Contact a: [select id, OwnerId, Owner.Name,Name,LastName,FirstName,Title,MobilePhone,Description from Contact where Id In: recordIdList]) {
            recordOwnerMap.put(a.Id, a.OwnerId);
            if(a.Owner.Name != null  )
            recordOwnerNameMap.put(a.Id, a.Owner.Name.replaceAll('<[^>]+>',' '));
            //recordPopupField1Map.put(a.Id, a.FirstName != null ? a.FirstName.escapeHtml4().replaceAll('<[^>]+>',' ') : '' +' '+ a.LastName != null ? a.LastName.escapeHtml4().replaceAll('<[^>]+>',' ') : '');
            recordPopupField1Map.put(a.Id, a.Name != null ? a.Name.replaceAll('<[^>]+>','').replaceAll('\'','') : '');
            recordPopupField1NameMap.put(a.Id, 'Name');
            recordPopupField2Map.put(a.Id, a.MobilePhone);
            recordPopupField2NameMap.put(a.Id, 'Title' );
            recordPopupField3Map.put(a.Id,a.MobilePhone);
            recordPopupField3NameMap.put(a.Id, 'Mobile');
        }
        
      
        for(Plan__c a: [select id, OwnerId, Owner.Name,Start_Time__c,End_Time__c,Location__c  from Plan__c where Id In: recordIdList]) {
            recordOwnerMap.put(a.Id, a.OwnerId);
            if(a.Owner.Name != null  )
            recordOwnerNameMap.put(a.Id, a.Owner.Name.replaceAll('<[^>]+>',' '));
            recordPopupField1Map.put(a.Id, String.valueOf(a.Start_Time__c));
            recordPopupField1NameMap.put(a.Id, 'Start Date');
            recordPopupField2Map.put(a.Id, String.valueOf(a.End_Time__c));
            recordPopupField2NameMap.put(a.Id, 'End Date');
            recordPopupField3Map.put(a.Id,'');
            recordPopupField3NameMap.put(a.Id, '');
        }
        
        for(Note a: [select id, OwnerId, Owner.Name, body from Note where Id In: recordIdList]) {
            recordOwnerMap.put(a.Id, a.OwnerId);
            if(a.Owner.Name != null  )
            recordOwnerNameMap.put(a.Id, a.Owner.Name.replaceAll('<[^>]+>',' ').replaceAll('\'',''));
            if(a.body != null  )
            recordPopupField1Map.put(a.Id, a.body.replaceAll('<[^>]+>',' ').replaceAll('\'',''));
            recordPopupField1NameMap.put(a.Id, 'Body');
            recordPopupField2Map.put(a.Id, '');
            recordPopupField2NameMap.put(a.Id, '');
            recordPopupField3Map.put(a.Id, '');
            recordPopupField3NameMap.put(a.Id, '');
        }
        
        for(Asset a : [Select a.Description,a.CreatedById,a.CreatedBy.Name, a.AccountId,a.Account.Name From Asset a where Id In : recordIdList]){
            recordOwnerMap.put(a.Id, a.CreatedById);
            if(a.CreatedBy.Name != null  )
            recordOwnerNameMap.put(a.Id, a.CreatedBy.Name.replaceAll('<[^>]+>',' ').replaceAll('\'',''));
            if(a.Account.Name != null  )
            recordPopupField1Map.put(a.Id, a.Account.Name.replaceAll('<[^>]+>',' ').replaceAll('\'',''));
            recordPopupField1NameMap.put(a.Id, 'Account');
            recordPopupField2Map.put(a.Id, a.Description);
            recordPopupField2NameMap.put(a.Id, 'Description');
            recordPopupField3Map.put(a.Id, '');
            recordPopupField3NameMap.put(a.Id, '');
        }
        for(Campaign c : [Select c.StartDate, c.OwnerId,c.Owner.Name, c.EndDate From Campaign c where Id In : recordIdList]){
            recordOwnerMap.put(c.Id, c.OwnerId);
            if(c.Owner.Name != null  )
            recordOwnerNameMap.put(c.Id, c.Owner.Name.replaceAll('<[^>]+>',' ').replaceAll('\'',''));
            recordPopupField1Map.put(c.Id, String.valueOf(c.StartDate));
            recordPopupField1NameMap.put(c.Id, 'Start Date');
            recordPopupField2Map.put(c.Id, String.valueOf(c.EndDate));
            recordPopupField2NameMap.put(c.Id, 'End Date');
            recordPopupField3Map.put(c.Id, '');
            recordPopupField3NameMap.put(c.Id, '');
        }
        
        for(Contract c : [Select c.OwnerId,c.Owner.Name, c.Description, c.AccountId,c.Account.Name From Contract c where Id In : recordIdList]){
            recordOwnerMap.put(c.Id, c.OwnerId);
            if(c.Owner.Name != null  )
            recordOwnerNameMap.put(c.Id, c.Owner.Name.replaceAll('<[^>]+>',' ').replaceAll('\'',''));
            recordPopupField1Map.put(c.Id, c.Account.Name);
            recordPopupField1NameMap.put(c.Id, 'Account Name');
            recordPopupField2Map.put(c.Id, c.Description);
            recordPopupField2NameMap.put(c.Id, 'Description');
            recordPopupField3Map.put(c.Id, '');
            recordPopupField3NameMap.put(c.Id, '');
        }
        
        for(Case c : [Select c.Priority, c.OwnerId, c.Description,c.Status,c.Owner.Name From Case c where Id In : recordIdList]){
            recordOwnerMap.put(c.Id, c.OwnerId);
            if(c.Owner.Name != null  )
            recordOwnerNameMap.put(c.Id, c.Owner.Name.replaceAll('<[^>]+>',' ').replaceAll('\'',''));
            recordPopupField1Map.put(c.Id, String.valueOf(c.Priority));
            recordPopupField1NameMap.put(c.Id, 'Priority');
            recordPopupField2Map.put(c.Id, String.valueOf(c.Status));
            recordPopupField2NameMap.put(c.Id, 'Status');
            recordPopupField3Map.put(c.Id, '');
            recordPopupField3NameMap.put(c.Id, '');
        }
        for(Idea i : [Select i.Title, i.CreatedById,i.CreatedBy.Name, i.Categories, i.Body From Idea i where Id In : recordIdList]){
            recordOwnerMap.put(i.Id, i.CreatedById);
            if(i.CreatedBy.Name != null  )
            recordOwnerNameMap.put(i.Id, i.CreatedBy.Name.replaceAll('<[^>]+>',' ').replaceAll('\'',''));
            recordPopupField1Map.put(i.Id, String.valueOf(i.Categories));
            recordPopupField1NameMap.put(i.Id, 'Categories');
            recordPopupField2Map.put(i.Id, String.valueOf(i.Body));
            recordPopupField2NameMap.put(i.Id, 'Description');
            recordPopupField3Map.put(i.Id, '');
            recordPopupField3NameMap.put(i.Id, '');
        }
        for(Lead l : [Select l.Status, l.OwnerId,l.Owner.Name, l.Company From Lead l where Id In : recordIdList]){
            recordOwnerMap.put(l.Id, l.OwnerId);
            if(l.Owner.Name != null  )
            recordOwnerNameMap.put(l.Id, l.Owner.Name.replaceAll('<[^>]+>',' ').replaceAll('\'',''));
            recordPopupField1Map.put(l.Id, l.Company);
            recordPopupField1NameMap.put(l.Id, 'Company');
            recordPopupField2Map.put(l.Id, l.Status);
            recordPopupField2NameMap.put(l.Id, 'Status');
            recordPopupField3Map.put(l.Id, '');
            recordPopupField3NameMap.put(l.Id, '');
        }
        for(Opportunity o : [Select o.StageName, o.OwnerId,o.Owner.Name, o.Amount From Opportunity o where Id In : recordIdList]){
            recordOwnerMap.put(o.Id, o.OwnerId);
            if(o.Owner.Name != null  )
            recordOwnerNameMap.put(o.Id, o.Owner.Name.replaceAll('<[^>]+>',' ').replaceAll('\'',''));
            recordPopupField1Map.put(o.Id, o.StageName);
            recordPopupField1NameMap.put(o.Id, 'Stage');
            recordPopupField2Map.put(o.Id, ''+o.Amount);
            recordPopupField2NameMap.put(o.Id, 'Amount');
            recordPopupField3Map.put(o.Id, '');
            recordPopupField3NameMap.put(o.Id, '');
        }
        for(Pricebook2 p : [Select p.IsActive, p.Description, p.CreatedById,p.CreatedBy.Name From Pricebook2 p where Id In : recordIdList]){
            recordOwnerMap.put(p.Id, p.CreatedById);
            if(p.CreatedBy.Name != null  )
            recordOwnerNameMap.put(p.Id, p.CreatedBy.Name.replaceAll('<[^>]+>',' ').replaceAll('\'',''));
            recordPopupField1Map.put(p.Id, p.IsActive ? 'true' : 'false');
            recordPopupField1NameMap.put(p.Id, 'Active');
            recordPopupField2Map.put(p.Id, p.Description);
            recordPopupField2NameMap.put(p.Id, 'Description');
            recordPopupField3Map.put(p.Id, '');
            recordPopupField3NameMap.put(p.Id, '');
        }
        for(Product2 p : [Select p.Family, p.Description, p.CreatedById,p.CreatedBy.Name From Product2 p where Id In : recordIdList]){
            recordOwnerMap.put(p.Id, p.CreatedById);
            if(p.CreatedBy.Name != null  )
            recordOwnerNameMap.put(p.Id, p.CreatedBy.Name.replaceAll('<[^>]+>',' ').replaceAll('\'',''));
            recordPopupField1Map.put(p.Id, p.Family);
            recordPopupField1NameMap.put(p.Id, 'Product Family');
            recordPopupField2Map.put(p.Id, p.Description);
            recordPopupField2NameMap.put(p.Id, 'Description');
            recordPopupField3Map.put(p.Id, '');
            recordPopupField3NameMap.put(p.Id, '');
        }
        for(Quote q : [Select q.OpportunityId,q.Opportunity.Name, q.GrandTotal, q.CreatedById,q.CreatedBy.Name From Quote q where Id In : recordIdList]){
            recordOwnerMap.put(q.Id, q.CreatedById);
            if(q.CreatedBy.Name != null  )
            recordOwnerNameMap.put(q.Id, q.CreatedBy.Name.replaceAll('<[^>]+>',' ').replaceAll('\'',''));
            recordPopupField1Map.put(q.Id, q.Opportunity.Name);
            recordPopupField1NameMap.put(q.Id, 'Opportunity Name');
            recordPopupField2Map.put(q.Id, ''+q.GrandTotal);
            recordPopupField2NameMap.put(q.Id, 'Grand Total');
            recordPopupField3Map.put(q.Id, '');
            recordPopupField3NameMap.put(q.Id, '');
        }
        for(QuoteLineItem q : [Select q.TotalPrice, q.PricebookEntry.Name, q.PricebookEntryId, q.CreatedById,q.CreatedBy.Name From QuoteLineItem q where Id In : recordIdList]){
            recordOwnerMap.put(q.Id, q.CreatedById);
            if(q.CreatedBy.Name != null  )
            recordOwnerNameMap.put(q.Id, q.CreatedBy.Name.replaceAll('<[^>]+>',' ').replaceAll('\'',''));
            recordPopupField1Map.put(q.Id, q.PricebookEntry.Name);
            recordPopupField1NameMap.put(q.Id, 'Product Name');
            recordPopupField2Map.put(q.Id, ''+q.TotalPrice);
            recordPopupField2NameMap.put(q.Id, 'Total Price');
            recordPopupField3Map.put(q.Id, '');
            recordPopupField3NameMap.put(q.Id, '');
        }
        for(Solution s : [Select s.Status, s.SolutionNote, s.CreatedById,s.CreatedBy.Name From Solution s where Id In : recordIdList]){
            recordOwnerMap.put(s.Id, s.CreatedById);
            if(s.CreatedBy.Name != null  )
            recordOwnerNameMap.put(s.Id, s.CreatedBy.Name.replaceAll('<[^>]+>',' ').replaceAll('\'',''));
            recordPopupField1Map.put(s.Id, s.Status);
            recordPopupField1NameMap.put(s.Id, 'Status');
            recordPopupField2Map.put(s.Id, s.SolutionNote);
            recordPopupField2NameMap.put(s.Id, 'Description');
            recordPopupField3Map.put(s.Id, '');
            recordPopupField3NameMap.put(s.Id, '');
        }
        for(User u : [Select u.Title, u.Department, u.CreatedById,u.CreatedBy.Name From User u where Id In : recordIdList]){
            recordOwnerMap.put(u.Id, u.CreatedById);
            if(u.CreatedBy.Name != null  )
            recordOwnerNameMap.put(u.Id, u.CreatedBy.Name.replaceAll('<[^>]+>',' ').replaceAll('\'',''));
            recordPopupField1Map.put(u.Id, u.Title);
            recordPopupField1NameMap.put(u.Id, 'Title');
            recordPopupField2Map.put(u.Id, u.Department);
            recordPopupField2NameMap.put(u.Id, 'Department');
            recordPopupField3Map.put(u.Id, '');
            recordPopupField3NameMap.put(u.Id, '');
        }
    }
    
    public pageReference planClone() {
        String items = Apexpages.currentPage().getParameters().get('items');
        String people = Apexpages.currentPage().getParameters().get('people');
        String task= Apexpages.currentPage().getParameters().get('task');
        String attach= Apexpages.currentPage().getParameters().get('attach');
        String relations= Apexpages.currentPage().getParameters().get('relations');
        String resetDate= Apexpages.currentPage().getParameters().get('resetDate');
        String relateClone= Apexpages.currentPage().getParameters().get('relateClone');
        String relationValue= Apexpages.currentPage().getParameters().get('relationValue');
        String assignToMe = Apexpages.currentPage().getParameters().get('assignToMe');
         
        Plan__c plan = [Select Name, All_Day_Event__c, Assigned_To__c, Description__c, End_Time__c, Location__c, Private__c, Show_Time_As__c,Start_Time__c From Plan__c d where Id =: planId ];
        
        Plan__c clonePlan = plan.clone(false);
        clonePlan.name = 'Copy - '+ clonePlan.Name;
        if(clonePlan.name.length() > 79) {
            clonePlan.name = clonePlan.name.substring(0,79);
        }
        
        if(resetDate== 'true') {
            clonePlan.End_Time__c = null;
            clonePlan.Start_Time__c = null;
        }
       
        if(FLS.planCreateable()){
            insert clonePlan;
        }
        
        
        List<Relations__c> toBeCloneItems = new List<Relations__c>();
        Set<Id> noteRelationsId = new Set<Id>();
        Map<ID,Note> noteRelationMap = new Map<Id,Note>();
        
        Map<String,List<Relations__c>> noteRelationValueMap = new Map<String,List<Relations__c>>();
        Map<String,List<Relations__c>> taskRelationValueMap = new Map<String,List<Relations__c>>();
        
        // Create clone of relation list
        if(items == 'true') {
            for(Relations__c r : [Select r.Type__c,r.Description__c,r.From_Relation__c, r.Days__c, r.Hours__c, r.Minutes__c, r.Parent_Object_Name__c, r.Parent_ID__c, r.To_Relation__c, r.Child_Record_Name__c, r.Child_Object_Name__c, r.Child_ID__c,Position__c From Relations__c r where r.Type__c =: 'Item' and r.Parent_ID__c =: planId order by r.Position__c ASC ]){
                system.debug('---------r--------->'+r);
                if(r.Child_Object_Name__c != 'Note' && r.Child_Object_Name__c != 'Task'){   
                    Relations__c rel = new Relations__c();
                     
                    if(r.Parent_ID__c == planId) {
                        
                        rel.Parent_ID__c = clonePlan.Id;
                        rel.Parent_Record_Name__c = clonePlan.Name;
                        rel.Parent_Object_Name__c = 'Plan';
                        rel.Child_ID__c = r.Child_ID__c;
                        rel.Child_Record_Name__c = r.Child_Record_Name__c;
                        rel.Child_Object_Name__c = r.Child_Object_Name__c;
                        rel.From_Relation__c = r.From_Relation__c;
                        rel.To_Relation__c = r.To_Relation__c;
                        rel.Description__c = r.Description__c;
                        rel.Type__c = 'Item';
                        rel.Days__c = r.Days__c;
                        rel.Hours__c = r.Hours__c;
                        rel.Minutes__c = r.Minutes__c;
                        rel.Position__c = r.Position__c;
                    }
                    else {
                        rel.Parent_ID__c = r.Child_ID__c;
                        rel.Parent_Record_Name__c = r.Child_Record_Name__c;
                        rel.Parent_Object_Name__c = r.Child_Object_Name__c;
                        rel.Child_ID__c = clonePlan.Id;
                        rel.Child_Record_Name__c = clonePlan.Name;
                        rel.Child_Object_Name__c = 'Plan';
                        rel.From_Relation__c = r.To_Relation__c;
                        rel.To_Relation__c = r.From_Relation__c;
                        rel.Description__c = r.Description__c;
                        rel.Type__c = 'Item';
                        rel.Days__c = r.Days__c;
                        rel.Hours__c = r.Hours__c;
                        rel.Minutes__c = r.Minutes__c;
                        rel.Position__c = r.Position__c;
                    }
                    
                    toBeCloneItems.add(rel);
                }
                else {
                    System.debug('rel.Child_Record_Name__c'+r.Child_Record_Name__c);
                    System.debug('rel.Child_Object_Name__c'+r.Child_Object_Name__c);
                    if(r.Child_Object_Name__c == 'Task' && r.Parent_ID__c == planId){
                        Relations__c rel = new Relations__c();
                        rel.Parent_ID__c = clonePlan.Id;
                        rel.Parent_Record_Name__c = clonePlan.Name;
                        rel.Parent_Object_Name__c = 'Plan';
                        rel.Child_ID__c = r.Child_ID__c;
                        rel.Child_Record_Name__c = r.Child_Record_Name__c;
                        rel.Child_Object_Name__c = r.Child_Object_Name__c;
                        rel.From_Relation__c = r.From_Relation__c;
                        rel.To_Relation__c = r.To_Relation__c;
                        rel.Description__c = r.Description__c;
                        rel.Type__c = 'Item';
                        rel.Days__c = r.Days__c;
                        rel.Hours__c = r.Hours__c;
                        rel.Minutes__c = r.Minutes__c;
                        rel.Position__c = r.Position__c;
                        toBeCloneItems.add(rel);
                    }
                    if(r.Child_Object_Name__c == 'Note'){
                        List<Relations__c> relationList = noteRelationValueMap.get(r.Child_Record_Name__c);
                        if(relationList == null) {
                            relationList = new List<Relations__c>();
                            noteRelationValueMap.put(r.Child_Record_Name__c, relationList);
                        }
                        relationList.add(r);
                    } else if(r.Child_Object_Name__c == 'Task'){
                        List<Relations__c> relationTaskList = taskRelationValueMap.get(r.Child_Record_Name__c);
                        if(relationTaskList == null){
                            relationTaskList = new List<Relations__c>();
                            taskRelationValueMap.put(r.Child_Record_Name__c, relationTaskList);
                        }
                        relationTaskList.add(r);
                    }
                    //noteRelationValueMap.put(rel.Child_ID__c,Relations__c );
                }
            }
            
        }
        
        if(noteRelationValueMap.size() > 0) {
            List<Note> toBeClonedNote = new  List<Note>();
            for(Note  note : [select id, title,body from Note where parentId =: planId and title In: noteRelationValueMap.keyset()]) {
                Note nt = new Note();
                
                nt.title = note.title;
                nt.body = note.body;
                nt.parentId = clonePlan.Id;
                toBeClonedNote.add(nt);
            }
            if(toBeClonedNote.size() > 0) {
                if(FLS.noteCreateable()){
                    insert toBeClonedNote;
                }
            }
            
            for(Note nt : toBeClonedNote) {
                
                if(noteRelationValueMap.get(nt.title) != null) {
                    
                    for(Relations__c r: noteRelationValueMap.get(nt.title)) {
                        
                        Relations__c cloneRel = r.clone(false);
                        
                        cloneRel.Parent_ID__c = clonePlan.Id;
                        cloneRel.Parent_Record_Name__c = clonePlan.Name;
                        cloneRel.Child_ID__c = nt.Id;
                        cloneRel.Child_Record_Name__c = nt.title;
                        cloneRel.Position__c = cloneRel.Position__c;
                        cloneRel.Type__c = 'Item';
                        cloneRel.Description__c = r.Description__c;
                        cloneRel.Days__c = r.Days__c;
                        cloneRel.Hours__c = r.Hours__c;
                        cloneRel.Minutes__c = r.Minutes__c;
                        cloneRel.Position__c = r.Position__c;
                        
                        toBeCloneItems.add(cloneRel);
                    }
                }
                
            }
            
        }
        
        List<Social_Input__c> toBeCloneSocialInput = new List<Social_Input__c>();
        
        // Create clone of Collabrator list
        
        if(people == 'true') {
            for(Social_Input__c si : [Select s.Is_Group__c, s.GroupId__c, s.User__c,  s.Responsible__c, s.Informed__c, s.Consulted__c, s.Accountable__c,s.User__r.isActive From Social_Input__c s where  s.Plan__c =: PlanId ]) {
                if((si.User__r.isActive == True && si.User__c != null) || si.User__c == null){
                    if(si.User__c != Userinfo.getUserId()) {
                        Social_Input__c socialInput = new Social_Input__c();
                        socialInput.Responsible__c = si.Responsible__c;
                        socialInput.Informed__c = si.Informed__c;
                        socialInput.Consulted__c = si.Consulted__c;
                        socialInput.GroupId__c = si.GroupId__c;
                        socialInput.Is_Group__c = si.Is_Group__c;
                        socialInput.User__c = si.User__c;
                        socialInput.Plan__c = clonePlan.Id;
                        if(si.Accountable__c) {
                            socialInput.Responsible__c = true;
                        }
                        toBeCloneSocialInput.add(socialInput);
                    }
                }
            }
        }
        
        
        List<Relations__c> toBeCloneRelations = new List<Relations__c>();
        
        // Create clone of relation list
        if(relations == 'true') {
            for(Relations__c r : [Select r.Type__c, r.Strength__c, r.From_Relation__c, r.Parent_Record_Name__c, r.Parent_Object_Name__c, r.Parent_ID__c, r.Notes__c, r.To_Relation__c, r.Child_Record_Name__c, r.Child_Object_Name__c, r.Child_ID__c From Relations__c r where r.Type__c =: 'Relation' and ( r.Parent_ID__c =: planId or  r.Child_ID__c =: planId )]){
                
                Relations__c rel = new Relations__c();
                
                if(r.Parent_ID__c == planId) {
                    rel.Parent_ID__c = clonePlan.Id;
                    rel.Parent_Record_Name__c = clonePlan.Name;
                    rel.Parent_Object_Name__c = 'Plan';
                    rel.Child_ID__c = r.Child_ID__c;
                    rel.Child_Record_Name__c = r.Child_Record_Name__c;
                    rel.Child_Object_Name__c = r.Child_Object_Name__c;
                    
                }
                else {
                    rel.Parent_ID__c = r.Parent_ID__c;
                    rel.Parent_Record_Name__c = r.Parent_Record_Name__c;
                    rel.Parent_Object_Name__c = r.Parent_Object_Name__c;
                    rel.Child_ID__c = clonePlan.Id;
                    rel.Child_Record_Name__c = clonePlan.Name;
                    rel.Child_Object_Name__c = 'Plan';
                
                }
                rel.From_Relation__c = r.From_Relation__c;
                rel.To_Relation__c = r.To_Relation__c;
                rel.Strength__c = r.Strength__c;
                rel.Type__c = 'Relation';
                rel.Notes__c = r.Notes__c;
                
                toBeCloneRelations.add(rel);
            }
        }
        
        
        
        if(relateClone == 'true') {
            Relations__c rel = new Relations__c();
            
            rel.Parent_ID__c = plan.Id;
            rel.Parent_Record_Name__c = plan.name;
            rel.Parent_Object_Name__c = 'Plan';
            rel.Child_ID__c = clonePlan.Id;
            rel.Child_Record_Name__c = clonePlan.Name;
            rel.Child_Object_Name__c = 'Plan';
            rel.To_Relation__c = relationValue;
            // -- Start added on 26_02_2014 to add the reciprocal relation when clone is done. 
            //IF "To Relation" is child then "From Relation" will be Parent,IF "To Relation" is Parent then "From Relation" will be Child, IF "To Relation" is Sibling then "From Relation" will be Sibling
            //IF "To Relation" is blank then "From Relation" will blank
            rel.From_Relation__c  = rel.To_Relation__c  == 'Parent' ? 'Child' : rel.To_Relation__c  == 'Child' ? 'Parent' : rel.To_Relation__c ==  'Sibling' ? 'Sibling' : '' ;
            //-- end added on 26_02_2014 to add the reciprocal relation when clone is done.
            toBeCloneRelations.add(rel);
        }
        
        
        List<Task> toBeInsertedTask = new List<Task>();
        system.debug('----------------task value------>'+task);
        // Create clone of task list
        if(task == 'true') {
            for(Task tasks: [select Id,WhatId,OwnerId, Owner.Name ,ActivityDate,Status,Priority,Subject,Description from Task where whatId=:planId order by subject desc ] ){
                Task cloneTask = tasks.clone(false);
                cloneTask.WhatId = clonePlan.Id;
                cloneTask.Status = 'Not Started';
                if(assignToMe == 'true'){   
                    cloneTask.OwnerId = userInfo.getUserId();
                }
                if(resetDate== 'true') {
                    cloneTask.ActivityDate = null;
                }
                toBeInsertedTask.add(cloneTask);
            }
        }
        
        List<Attachment> toBeInsertedAttach = new List<Attachment>();
        //list of clone Feed Attachment 
        List<Attachment> toBeCloneFeedAttachment = new List<Attachment>();
        Set<ID> contentVersionRecordId = new Set<ID>();
        if(attach == 'true') {
             // query for RelatedRecordId in chatter feed 
             for(Plan__Feed feedItm:[SELECT ContentFileName,ParentId,RelatedRecordId FROM Plan__Feed where ParentId= :planId ]){
                if(feedItm.RelatedRecordId != null){
                    contentVersionRecordId.add(feedItm.RelatedRecordId);
                    System.debug('clonefeedItemclonefeedItemclonefeedItem'+contentVersionRecordId);
                }
            }
            
            For(ContentVersion contnVersion: [SELECT Id,Title,PathOnClient, ContentDocumentId,VersionData FROM ContentVersion WHERE ID In : contentVersionRecordId]  ){
                
                Attachment cloneAttachment = new Attachment() ;
                cloneAttachment.ParentId = clonePlan.Id;
                cloneAttachment.Name = contnVersion.PathOnClient;
                cloneAttachment.Body = contnVersion.VersionData;
                toBeCloneFeedAttachment.add(cloneAttachment);

            }
            for(Attachment attacht: [select Body,parentId,Name from Attachment where parentId=:planId ] ){
                Attachment cloneAttach = attacht.clone(false);
                cloneAttach.parentId = clonePlan.Id;
                toBeInsertedAttach.add(cloneAttach);
            }
        }
        
        
        // if the social input list avialable thn insert
        if(toBeCloneSocialInput.size() > 0) {
            if(FLS.socialInputCreateable()){
                insert toBeCloneSocialInput;
            }
        }
        
        // if the relationship list avialable thn insert
        if(toBeCloneRelations.size() > 0) {
            if(FLS.relationCreateable()){ 
                insert toBeCloneRelations;    
            }
        }
      
        // if the task list avialable thn insert
        if(toBeInsertedTask.size() > 0) {
            if(FLS.taskCreateable()){
                insert toBeInsertedTask;
            }
        }
        
        system.debug('---------taskRelationValueMap----------->'+taskRelationValueMap);
        if(taskRelationValueMap.size() > 0){
            for(Task nt : toBeInsertedTask) {
                if(taskRelationValueMap.get(nt.subject) != null) {
                    for(Relations__c r: taskRelationValueMap.get(nt.subject)) {
                        Relations__c cloneRel = r.clone(false);
                        cloneRel.Parent_ID__c = clonePlan.Id;
                        cloneRel.Parent_Record_Name__c = clonePlan.Name;
                        cloneRel.Child_ID__c = nt.Id;
                        cloneRel.Child_Record_Name__c = nt.subject;
                        cloneRel.Position__c = cloneRel.Position__c;
                        cloneRel.Type__c = 'Item';
                        cloneRel.Description__c = r.Description__c;
                        cloneRel.Days__c = r.Days__c;
                        cloneRel.Hours__c = r.Hours__c;
                        cloneRel.Minutes__c = r.Minutes__c;
                        cloneRel.Position__c = r.Position__c;
                        toBeCloneItems.add(cloneRel);
                    }
                }
            }
        }
        
        if(toBeInsertedAttach.size() > 0) {
            if(FLS.attachmentCreateable()){
                insert toBeInsertedAttach;
            }
        }
        //insert Feed Attachment list
        if(toBeCloneFeedAttachment.size() > 0 ){
            if(FLS.attachmentCreateable()) {
                insert toBeCloneFeedAttachment;
           }
        
        }
        
        if(toBeCloneItems.size() > 0) {
            System.debug('--------toBeCloneItems---------------'+toBeCloneItems);
            Map<Decimal,Relations__c> cloneItemsToBeSorted = new Map<Decimal,Relations__c>();
            for(Relations__c r: toBeCloneItems){
                cloneItemsToBeSorted.put(r.Position__c,r);
            }
            toBeCloneItems.clear();
            list<decimal> positionList = new list<decimal>();
            positionList.addAll(cloneItemsToBeSorted.keySet());
        
            //now sort them
            positionList.sort();
            for(decimal r: positionList){
                toBeCloneItems.add(cloneItemsToBeSorted.get(r));    
            }
            if(FLS.relationCreateable()){ 
               insert toBeCloneItems;
            }
        }
        pageReference p = new pageReference('/'+clonePlan.Id);
        p.setRedirect(true);
        return p;
    }
    
    
    // This function use for create new task unser the decision and 
    // edit task on plan object it self
    public void createNewTaskForDecision(){
        String decisionIdFromPlan = ApexPages.currentPage().getParameters().get('decisionId'); 
        String sendingNotification = ApexPages.currentPage().getParameters().get('sendingNotification');  
        system.debug('---------decisionIdFromPlan-------------'+sendingNotification+'------------------'+decisionIdFromPlan);
        
        
       // create new task unser the decision and 
        if(decisionIdFromPlan != '' && decisionIdFromPlan != null){
            newTaskToDecision.whatId = Id.valueOf(decisionIdFromPlan);
        } else {
            newTaskToDecision.whatId = plan.Id;
        }
        //insert newTaskToDecision;
        Database.DMLOptions dmlo = new Database.DMLOptions();
        if(sendingNotification == 'true')
            dmlo.EmailHeader.triggerUserEmail = true;
        else
            dmlo.EmailHeader.triggerUserEmail = false;
        if(FLS.taskCreateable()){
            database.insert(newTaskToDecision, dmlo);
        }
        newTaskToDecision =  new task(Status='Not Started',whatId = plan.Id,OwnerId = UserInfo.getUserId(),Priority = 'Normal',IsReminderSet = true,Skill_Level__c = '1'); 
        System.debug('-------newTaskToDecision--------->'+newTaskToDecision);
    }
    
    // create new task unser the plan as task and an item 
    public pagereference createNewTaskForPlanAsRelation(){
        
        String sendingNotification = ApexPages.currentPage().getParameters().get('sendingNotification');
        String planIdAsRelation = ApexPages.currentPage().getParameters().get('planIdAsRelation');  
        //Plan__c Plan = [ select Name from Plan__c  where id = : planId];       
        
       // create new task unser the decision and 
        
        //newTaskToDecision.whatId = Id.valueOf( planId ); 
        //insert newTaskToDecision;
        Database.DMLOptions dmlo = new Database.DMLOptions();
        if(sendingNotification == 'true')
            dmlo.EmailHeader.triggerUserEmail = true;
        else
            dmlo.EmailHeader.triggerUserEmail = false;
        if(FLS.taskCreateable()){
            
            if(planIdAsRelation != '' && planIdAsRelation != null){
                newTaskToDecision.whatId = Id.valueOf(planIdAsRelation);
            }
            
            database.insert(newTaskToDecision, dmlo);
            //Task t = [select id from Task where Id = :newTaskToDecision.id];
            if(planIdAsRelation != '' && planIdAsRelation != null){
                if(planIdAsRelation.substring(0,3) == planIdSubstring){
                    Plan__c planRel = [select Id,Name from Plan__c where Id = : Id.valueOf(planIdAsRelation)];
                    Relations__c r = new Relations__c();
                    r.child_Id__c = newTaskToDecision.id;
                    r.Child_Record_Name__c = newTaskToDecision.Subject;
                    r.Child_Object_Name__c = 'Task';
                    r.Parent_Id__c = Id.valueOf(planIdAsRelation);
                    r.parent_Record_Name__c = planRel.Name;
                    r.parent_Object_Name__c = 'Plan';
                    r.type__c = 'Item';  
                    if(FLS.relationCreateable()){
                        insert r;
                    }
                }
            }
            //system.debug(r);
        }
        newTaskToDecision = new task(Status='Not Started',whatId = plan.Id,OwnerId = UserInfo.getUserId(),Priority = 'Normal',IsReminderSet = true,Skill_Level__c = '1');        
        return null;
        
    }
    
    // edit event on plan object 
    public void updatedTask() {
        String sendingNotification = ApexPages.currentPage().getParameters().get('sendingNotification');  
        System.debug('-----sendingNotification ----'+sendingNotification );       
        System.debug('-----updatedTask ----'+updatedTask );
        if(FLS.taskUpdateable())
        {
            Database.DMLOptions dmlo = new Database.DMLOptions();  
            if(sendingNotification == 'true')
                dmlo.EmailHeader.triggerUserEmail = true;
            else
                dmlo.EmailHeader.triggerUserEmail = false;
            
            database.update(updatedTask, dmlo);  
        }
        
        updatedTask = new Task();
    }
    
    public boolean isEventUpdated {get; set;}
    public boolean isEndDateGreater {get; set;}
    
    // edit event on plan object 
    public void updatedEvent() {
        String sendingNotification = ApexPages.currentPage().getParameters().get('sendingNotification');  
        isEventUpdated = true;
        isEndDateGreater = true;
        if(FLS.eventUpdateable()) {
        	
        	// Event not getting updated directly by just updating "update event". So assigning event to new instance and updating.
        	
            Event e = new Event(Id = event.Id);
			e.StartDateTime = event.StartDateTime;
			e.EndDateTime = event.EndDateTime;
			e.Subject = event.Subject;
			e.OwnerId = event.OwnerId;
			if(event.StartDateTime != null && event.EndDateTime != null){
				if(event.StartDateTime > event.EndDateTime){
					isEndDateGreater = false;
				}
				if(event.EndDateTime > event.StartDateTime && Date.newInstance(event.StartDateTime.Year(),event.StartDateTime.month(),event.StartDateTime.day()).daysBetween(Date.newInstance(event.EndDateTime.Year(),event.EndDateTime.month(),event.EndDateTime.day())) > 14){	
					isEventUpdated = false;
				}
				if(isEventUpdated && isEndDateGreater){	
					update e;
				}
			}
        }
        
        event = new Event();
    }
     
     
    // Intialise task popup when opening from smart menu to display default values. 
    public void intialiseTask(){
        String decisionId = ApexPages.currentPage().getParameters().get('decisionId');
        newTaskToDecision = new Task();
        newTaskToDecision = new Task(Status='Not Started',OwnerId = UserInfo.getUserId(),Priority = 'Normal',IsReminderSet = true,Skill_Level__c = '1');
        if(decisionId != '' && decisionId != null){ 
            newTaskToDecision.WhatId = Id.valueOf(decisionId);
        } 
        System.debug('-----newTaskToDecision------>'+newTaskToDecision);
    }
    
    // Intialise task popup when opening from activites tab
    public void intialisePlanTask(){
        newTaskToDecision = new Task();
        newTaskToDecision = new Task(Status='Not Started',WhatId = plan.Id,OwnerId = UserInfo.getUserId(),Priority = 'Normal',IsReminderSet = true,Skill_Level__c = '1');
    }
    
    public Pagereference planPDF(){
        Pagereference pr = new Pagereference('/apex/PlanPDFGenerate?id='+planId);
        
        if(loggedInSocialPeople == null) {
            loggedInSocialPeople = new Social_Input__c();
            if([select id  from Social_Input__c where User__c =: userInfo.getUserId() AND Plan__c =: planId].size() > 0 ) {
                loggedInSocialPeople = [Select s.Veto_Rights__c, s.User__c, s.SystemModstamp, s.Select_People__c, s.SYS_Tab_View_Tasks__c, s.SYS_Tab_View_Social_Input__c, s.SYS_Tab_View_Relations__c, s.SYS_Tab_View_Quality__c, s.SYS_Tab_View_History__c, s.SYS_Tab_View_Attachments__c, s.SYS_Tab_View_Approvals__c, s.SYS_Tab_View_Activites__c, s.Role__c, s.Role_Acceptance_Status__c, s.Role_Acceptance_Required__c, s.Result__c, s.Responsible__c, s.Rating__c, s.Plan__c, s.OwnerId, s.Outcome__c, s.Name_of_the_User__c, s.Name, s.Mood__c, s.Like__c, s.LastModifiedDate, s.LastModifiedById, s.Is_Group__c, s.IsDeleted, s.Informed__c, s.Id, s.Group_Name__c, s.GroupId__c, s.Final_Approval_Status__c, s.Effort__c, s.Dislike__c, s.Description__c, s.Decision__c, s.CreatedDate, s.CreatedById, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c, s.Accountable__c From Social_Input__c s where User__c =: userInfo.getUserId() AND Plan__c =: planId limit 1 ];
            }
        }
          //integer a = 1/0;
         //Integer.valueOf(profileName.Name);
      
        if(loggedInSocialPeople.Responsible__c || loggedInSocialPeople.Accountable__c || loggedInSocialPeople.Backup_for_Accountable__c || chkRecPermission==true){
          
            if(pr != null){
                Attachment attachment = new Attachment();
                attachment.Name = 'Plan_PDF_'+System.now().year()+'_'+System.now().month()+'_'+System.now().day()+'_'+System.now().hour()+'_'+System.now().minute()+'_'+System.now().second()+'.pdf';
                attachment.ParentId = plan.id;
                attachment.body = Test.isRunningTest() ? Blob.valueOf('Test') : pr.getContent();
                if(loggedInSocialPeople.Responsible__c || loggedInSocialPeople.Accountable__c || loggedInSocialPeople.Backup_for_Accountable__c || chkRecPermission==true){
                    if(FLS.attachmentCreateable()){
                         insert attachment;
                         attachment = new Attachment(); // clears the viewstate
                    }
                }
            }
        }
        return pr;
    }
    
    
     // get to be update Task
    public void toBeUpdatedTask() {
        //updatedTask = [select id,WhatId,Subject,ActivityDate,Status,Priority,OwnerId,Owner.Name,CreatedById,CreatedBy.Name,Description from Task where Id =: ApexPages.currentPage().getParameters().get('taskId')];
        showTaskPopup = true;
        taskId = ApexPages.currentPage().getParameters().get('taskId');
        taskEditable = ApexPages.currentPage().getParameters().get('isEditable');
        modeType = ApexPages.currentPage().getParameters().get('modeType');
    }
    
    public void closeTaskPopup(){
        showTaskPopup = false;
    }
    
    //render task popup onclick of new task button 
    public void newTaskPopupComponent(){
        String relatedRecordId = ApexPages.currentPage().getParameters().get('relatedRecordId');
        if(relatedRecordId == 'Items'){
            newTaskRelatedId = plan.Id+',Items';
        } else if(relatedRecordId != null && relatedRecordId != ''){
            newTaskRelatedId = relatedRecordId;
        } else {
            newTaskRelatedId = plan.Id;
        }
        newShowTaskPopup = newShowTaskPopup == true ? false : newShowTaskPopup == false ? true : false;
    }
    
    // get to be update Event
    public void toBeUpdatedEvent () {
        event = [select id,WhatId,Subject,ActivityDate,StartDateTime,EndDateTime,ActivityDateTime,OwnerId,Owner.Name,CreatedById,CreatedBy.Name,Description from Event where Id =: ApexPages.currentPage().getParameters().get('eventId')];
    }
    
    @RemoteAction
    public static string getNoteInfo(String noteId){
        
        // initialize General information class to get user locale date format and image static resouce url //
        //GeneralInformation genralInfo  = new GeneralInformation();
        if(genralInfo == null ) {
            genralInfo  = new GeneralInformation();
        }
        
        
        // assign user locale datetime format as string 
        dateTimeFormat = genralInfo.MapValuesDateTime();
    
        List<NoteWrapper> noteWrapperList = new List<NoteWrapper>();
        
        Note note = [select id, Title, body, LastModifiedDate, LastModifiedBy.Name, CreatedDate, CreatedBy.Name   from Note where Id =: noteId];
    
        NoteWrapper nw = new NoteWrapper();
        nw.subject = note.Title;
        nw.body = note.Body;
        nw.id = note.Id;
        nw.ownerName = note.CreatedBy.Name;
        nw.createdDate  = note.CreatedDate.format(dateTimeFormat);
        nw.lastModifiedDate = note.LastModifiedDate.format(dateTimeFormat);
        nw.lastModifiedBy = note.LastModifiedBy.Name;
        noteWrapperList.add(nw);
        
        return  JSON.serialize(noteWrapperList);
        
       
    }
    
    
    @RemoteAction
    public static string editNote(String planId, String noteId,String body  ,String title ){
    
        Note note = [select id, Title, body  from Note where Id =: noteId];
        
        note.Title = title;
        note.Body = body ;
        if(FLS.noteUpdatable()){
            update note;
        }
        allItemJson = itemView1(planId);
        
        return allItemJson;
       
    }
    
    // retrieve Group member name 
    @RemoteAction
    public static String retrieveGroupMember(String GrupId) {
        
        // initialize General information class to get user locale date format and image static resouce url //
        //GeneralInformation genralInfo  = new GeneralInformation();
        if(genralInfo == null ) {
            genralInfo  = new GeneralInformation();
        }
        
        
        List<UserGroupMemberList> UserGroupMemberList = new List<UserGroupMemberList>();
        
        for(GroupMember gruopMember : [Select g.UserOrGroupId, g.Id, g.GroupId From GroupMember g where g.GroupId =: GrupId]) {
            UserGroupMemberList userGroupMember = new UserGroupMemberList();
            /*userGroupMember.name = genralInfo.useNameMap.get(gruopMember.UserOrGroupId).Name;
            userGroupMember.userImage = genralInfo.useImage.get(gruopMember.UserOrGroupId);
            userGroupMember.department = genralInfo.useNameMap.get(gruopMember.UserOrGroupId).Department == null ? '' : genralInfo.useNameMap.get(gruopMember.UserOrGroupId).Department ;*/
            userGroupMember.name = genralInfo.useNameMap.get(gruopMember.UserOrGroupId)!=null ? genralInfo.useNameMap.get(gruopMember.UserOrGroupId).Name: genralInfo.groupMap.get(gruopMember.UserOrGroupId)!=null? genralInfo.groupMap.get(gruopMember.UserOrGroupId).Name:'';
            userGroupMember.userImage = genralInfo.useImage.get(gruopMember.UserOrGroupId)!=null ? genralInfo.useImage.get(gruopMember.UserOrGroupId): '/'+ genralInfo.imageUrlMap.get('group');
            userGroupMember.department = genralInfo.useNameMap.get(gruopMember.UserOrGroupId)==null ? '' : genralInfo.useNameMap.get(gruopMember.UserOrGroupId).Department == null ? '' : genralInfo.useNameMap.get(gruopMember.UserOrGroupId).Department;
            
            UserGroupMemberList.add(userGroupMember);
        }
        return JSON.serialize(UserGroupMemberList);
    }
    
    // issues save 
    public void saveIssues() {
        
    }
    
    @RemoteAction
    public static string checkRoleOnDecision(String decisionId){
        String permissionToCreate = '';
        Social_Input__c socialInputs;
        if([Select id From Social_Input__c s where s.Decision__c =: decisionId AND s.User__c =: userInfo.getUserId() ] != null) {
           socialInputs = [Select s.Veto_Rights__c, s.User__c, s.SystemModstamp,s.SYS_Tab_View_Activites__c, s.SYS_Tab_View_History__c, s.SYS_Tab_View_Tasks__c, s.SYS_Tab_View_Social_Input__c, s.SYS_Tab_View_Relations__c, s.SYS_Tab_View_Quality__c, s.SYS_Tab_View_Attachments__c, s.SYS_Tab_View_Approvals__c, s.Role_Acceptance_Status__c, s.Role_Acceptance_Required__c, s.Result__c, s.Responsible__c, s.Rating__c, s.Outcome__c, s.Name, s.Mood__c, s.Like__c, s.LastModifiedDate, s.LastModifiedById, s.Informed__c, s.Id, s.Final_Approval_Status__c, s.Effort__c, s.Dislike__c, s.Plan__c, s.CreatedDate, s.CreatedById, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c, s.Accountable__c From Social_Input__c s where s.Decision__c =: decisionId AND s.User__c =: userInfo.getUserId() ];  
        }
        
        Profile p = [select id,Name from Profile where id =: UserInfo.getProfileId()];
        if(chkRecPermission == true || socialInputs.Accountable__c || socialInputs.Responsible__c || socialInputs.Backup_for_Accountable__c){
            permissionToCreate = 'yes';
        }else{
            permissionToCreate = 'No';
        }
        return permissionToCreate;
    }
    
    // search for items to be added as relations
     public pageReference searchItems(){
        String objectChosen = ApexPages.currentPage().getParameters().get('chooseObject');
        String searchText = ApexPages.currentPage().getParameters().get('searchText');
        srchRelationship.clear();
        srchRelationshipSet.clear();
        message = '';
            
            Id decisionId = ApexPages.currentPage().getParameters().get('id');
            List<Relations__c> lstExistingRelations = [select Id,Child_ID__c,Parent_ID__c from Relations__c where (Child_ID__c =:decisionId or Parent_ID__c =: decisionId) and Type__c = 'Relation' limit 999];
            set<Id> relIds = new set<id>();
            relIds.add(decisionId);
            for(Relations__c rel : lstExistingRelations){
                relIds.add(rel.Child_ID__c);
                relIds.add(rel.Parent_ID__c);  
            }
            if(searchText != ''){
                if(searchText.contains('*')){
                    String SearchtextList=searchText.replaceAll('\\*','\\%');
                    searchText = SearchtextList;
                }
            }
            
              
           
            if( objectChosen != 'Contract' && objectChosen != 'QuoteLineItem' && objectChosen != 'Idea' &&   objectChosen != 'Solution' &&   objectChosen != 'Case' && !objectChosen.contains('Decision__c')){
                List<sObject> records = Database.query('Select Id, Name From ' + String.escapeSingleQuotes(objectChosen) + ' Where Name like ' + '\'%'+String.escapeSingleQuotes(searchText)+'%\'' + ' limit 999 ');
                for(SObject record : records){
                    if(!relIds.contains((String) record.get('Id'))){    
                        Relations__c r = new Relations__c();
                        r.select__c = false;
                        r.Child_Record_Name__c = (String) record.get('Name');
                        r.Child_ID__c = (String) record.get('Id');
                        r.Child_Object_Name__c = objectNameLabelMap.get(objectChosen);  
                        srchRelationshipSet.add(r);  
                    }
                }           
            }
            if(objectChosen.contains('Decision__c')){
                List<Decision__c> lstDecision = [select id,Name,Title__c from Decision__c where Title__c like : '%'+String.escapeSingleQuotes(searchText)+'%' limit 999];
                for(Decision__c dec : lstDecision){
                    if(!relIds.contains(dec.Id)){    
                        Relations__c r = new Relations__c();
                        r.select__c = false;
                        r.Child_Record_Name__c = dec.Title__c;
                        r.Child_ID__c = dec.Id;
                        r.Child_Object_Name__c = 'Decision';  
                        srchRelationshipSet.add(r);  
                    }
                }
            }
            if(objectChosen == 'QuoteLineItem'  ){ 
                List<sObject> records = Database.query('Select Id, LineNumber  From ' + 'QuoteLineItem' + ' Where LineNumber like ' + '\'%'+String.escapeSingleQuotes(searchText)+'%\'' + ' limit 999 ');
                for(SObject record : records){
                         
                        if(!relIds.contains((String) record.get('Id'))){    
                            Relations__c r = new Relations__c();
                            r.select__c = false;
                            r.Child_Record_Name__c = (String) record.get('LineNumber');
                            r.Child_ID__c = (String) record.get('Id');
                            r.Child_Object_Name__c = objectNameLabelMap.get(objectChosen);
                            srchRelationshipSet.add(r);  
                        }
                }           
            }
            // For Idea section
            if(objectChosen == 'Idea'  ){
                List<sObject> records = Database.query('Select Id, Title  From ' + 'Idea' + ' Where Title like ' + '\'%'+String.escapeSingleQuotes(searchText)+'%\'' + ' limit 999 ');
                for(SObject record : records){
                        if(!relIds.contains((String) record.get('Id'))){    
                            Relations__c r = new Relations__c();
                            r.select__c = false;
                            r.Child_Record_Name__c = (String) record.get('Title');
                            r.Child_ID__c = (String) record.get('Id');
                            r.Child_Object_Name__c = objectNameLabelMap.get(objectChosen);
                            srchRelationshipSet.add(r);
                        }
                }           
            }   
            if(objectChosen == 'Solution'  ){
                List<sObject> records = Database.query('Select Id, SolutionName  From ' + 'Solution' + ' Where SolutionName like ' + '\'%'+String.escapeSingleQuotes(searchText)+'%\'' + ' limit 999 ');
                for(SObject record : records){
                        if(!relIds.contains((String) record.get('Id'))){    
                            Relations__c r = new Relations__c();
                            r.select__c = false;
                            r.Child_Record_Name__c = (String) record.get('SolutionName');
                            r.Child_ID__c = (String) record.get('Id');
                            r.Child_Object_Name__c = objectNameLabelMap.get(objectChosen);
                            srchRelationshipSet.add(r);
                        }
                }           
            }
             if(objectChosen == 'Case'  ){
                List<sObject> records = Database.query('Select Id, CaseNumber, Subject  From ' + 'Case' + ' Where CaseNumber like ' + '\'%'+String.escapeSingleQuotes(searchText)+'%\'' +  ' or Subject like ' + '\'%'+searchText+'%\''  + ' limit 999 ');
                for(SObject record : records){
                        if(!relIds.contains((String) record.get('Id'))){    
                            Relations__c r = new Relations__c();
                            r.select__c = false;
                            if( (String) record.get('Subject') == null)
                                r.Child_Record_Name__c = 'No Subject';
                            else
                                r.Child_Record_Name__c = (String) record.get('Subject');
                            r.Child_ID__c = (String) record.get('Id');
                            r.Child_Object_Name__c = objectNameLabelMap.get(objectChosen);
                            srchRelationshipSet.add(r);
                        }
                }            
            } 
             if(objectChosen == 'Contract'  ){
                List<sObject> records = Database.query('Select Id, Name, ContractNumber  From ' + 'Contract' + ' Where ContractNumber like ' + '\'%'+String.escapeSingleQuotes(searchText)+'%\'' +  ' or Name like ' + '\'%'+searchText+'%\''  + ' limit 999 ');
                for(SObject record : records){
                        if(!relIds.contains((String) record.get('Id'))){    
                            Relations__c r = new Relations__c();
                            r.select__c = false;
                            if( (String) record.get('Name') == null)
                                r.Child_Record_Name__c = 'No Name';
                            else
                                r.Child_Record_Name__c = (String) record.get('Name');
                            r.Child_ID__c = (String) record.get('Id');
                            r.Child_Object_Name__c = objectNameLabelMap.get(objectChosen);
                            srchRelationshipSet.add(r);
                        }
                }            
            } 
            for(Relations__c newRel:srchRelationshipSet){
                srchRelationship.add(newRel);
            }
       
        if(srchRelationship.size() == 0){
            message = 'No Records to Display';
        }
        
        return null;
    }
    
    
    public void cancelRelation(){
        srchRelationship.clear();
    }
    
    public void addFromSrch(){
        List<Relations__c> addItemsRelationship = new List<Relations__c>();
        Id recId = Apexpages.currentPage().getParameters().get('Id');
        System.debug('-------srchRelationship------->'+srchRelationship);
        for(Relations__c searchR:srchRelationship){
            if(searchR.select__c == true){
               searchR.Parent_Id__c = recId;
               searchR.Parent_Record_Name__c = plan.Name;
               searchR.Parent_Object_Name__c = 'Plan';
               searchR.To_Relation__c = searchR.From_Relation__c == 'Parent' ? 'Child' : searchR.From_Relation__c == 'Child' ? 'Parent' : searchR.From_Relation__c ==  'Sibling' ? 'Sibling' : '' ;
               addItemsRelationship.add(searchR);
            }
        }
        if(!addItemsRelationship.isEmpty()){
            if(FLS.relationCreateable()){ 
                 insert addItemsRelationship;
            }
        }
        srchRelationship.clear();
    }
    
    public void existingRelationsAddToSet(){
        Id recordId = ApexPages.currentPage().getParameters().get('id');
        List<Relations__c> lstRelations = [select id from Relations__c where Parent_Id__c = : recordId];
        
        for(Relations__c rel : lstRelations){
            relationsIds.add(rel.Id);
        }
    }
    
    // Wrapper class of note edit 
    public class NoteWrapper {
        public string id { get; set; }
        public string subject { get; set; }
        public string body { get; set; }
        public string ownerName { get; set; }
        public string createdDate { get; set; }
        public string lastModifiedDate { get; set; }
        public string lastModifiedBy { get; set; }
        
    }
    
    
    /*Wrapper class area */
    public class Datum
    {
        public string Type { get; set; }
        public string Status { get; set; }
        public string recordId { get; set; }
        public string Position { get; set; }
        public string Phases { get; set; }
        public string Owner { get; set; }
        public string Name { get; set; }
        public string Id { get; set; }
        public string Minutes { get; set; }
        public string Hours { get; set; }
        public string Days { get; set; }
        public string Description { get; set; }
        public string OwnerId { get; set; }
    }

    public class RootObject
    {
        public List<Datum> data { get; set; }
    }
    
    // Group member wrapper class
    public Class UserGroupMemberList {
        public String name {get;set;}
        public String userImage {get;set;}
        public String department {get;set;}
        
    } 
    
    // Wrapper class for Plan People (Social Input)
    public class SocialInput{
        public String id{get;set;}
        public String name{get;set;}
        public String userImage {get;set;} 
        public String role{get;set;}
        public String roleAcceptance{get;set;}
        public String planApproval{get;set;}
        public String roleAcceptanceImage{get;set;}
        public String planApprovalImage{get;set;}
        public String backupforAccountable{get;set;}
        public String vetoRights{get;set;}
        public String description{get;set;}
        public Boolean isDeletable {get;set;}
        public String deleteImage {get;set;}
        public String planOnApprvalForCallOut {get;set;}
        public String groupName{get;set;}
        public String infoImage{get;set;}
        public String userNameList {get;set;}
        public String url {get;set;}
        public Boolean isGroup {get;set;}
        public String groupClassName {get;set;}
        public String actionClassName {get;set;}
        public string userId{get;set;}
    }

        
    //Wrapper class for Task and Event Tab that are open or status is not completed
    public class TaskEvent {
      public String id {get;private set;}
      public String subject {get;private set;}
      public String dueDate {get;private set;}
      public String status {get;private set;}
      public String isTask {get;private set;}
      public String taskImage {get;set;}
      public String priority {get;private set;}
      public String assignedTo {get;private set;}
      public String assignedToImage {get;private set;}
      public String editImage {get;private set;}
      public Boolean isEditable {get;private set;}
      public String deleteImage {get;set;}
      public Boolean isDeletable {get;set;}
      public string url {get;set;}
      public String subjectClassLink {get; set;}
      public String subjectClass {get; set;}
      public String comments {get; set;}
      public String commentsImage {get; set;}
      public String delayTaskClass {get;set;}
      public String actionClassNameEdit {get;set;}
      public String actionClassNameDelete {get;set;}
      public String ownerId {get; set;}
      public String title {get; set;}
      public String imgEditTitle {get; set;}
      public String imgDeleteTitle {get; set;}
      public Boolean isSelected {get; set;}
      public String toDisable {get; set;}
      // added on 25-04-2014
       public datetime dueDateSort {get;private set;}
      // added on 25-04-2014
    }
    
    //Wrapper class for Task and Event Tab that are completed
    public class TaskEventHistory {
      public String id {get;private set;}
      public String subject {get;private set;}
      public String dueDate {get;private set;}
      public String isTask {get;private set;}
      public String taskImage {get;set;}
      public String priority {get;private set;}
      public String createdby {get;private set;}
      public String createdByUserImage {get;set;}
      public String editImage {get;private set;}
      public Boolean isEditable {get;private set;}
      public String deleteImage {get;set;}
      public Boolean isDeletable {get;set;}
      public string url {get;set;}
      
      public String actionClassName {get;set;}
    }
    
    // Wrapper class for relations
    public class Relations{
        public string id {get;set;}
        public string recordId{get;set;}
        public string recordName{get;set;}
        public string relation{get;set;}
        public string objectName{get;set;}
        public string strength{get;set;}
        public string notes{get;set;}
        public Boolean isEditable{get;set;}
        public Boolean isDeletable{get;set;}
        public String editImage{get;set;}
        public String deleteImage{get;set;}
        public string url {get;set;}
        public string relatedToId{get;set;}
        public string Type{get;set;}
        
        public String actionClassName {get;set;}
    }
    
    //Wrapper class for  Notes & Attachment
    public class AttachmentNote {
      public String id {get;set;}
      public String type {get;set;}
      public String name {get;set;}
      public String lastModifiedDate {get;set;}
      public String createdByUser {get;set;}
      public String createdByUserImage {get;set;}
      public String deleteImage {get;set;}
      public Boolean isDeletable {get;set;}
      public String editImage {get;set;}
      public Boolean isEditable {get;set;}
      public string url {get;set;}
      
      public String actionClassName {get;set;}
    }
    
    //Wrapper class for history tab 
    public class CommonHistory {
        public DateTime chDateTime {get;set;} // only use for sorting 
        public String subject{get; set; }
        public String duedate {get; set;}
        public String status {get; set;}
        public String assignedTo {get;set;}
        public String assignedToId {get;set;}
        public String comments {get;set;}
        public String relatedTo {get;set;}
        
        // added on 25-04-2014
        public datetime duedateSort {get; set;}
        // added on 25-04-2014
    }
    
    // Wrapper class for java remote scripting return value
    public class JsonExistingData{
        public Social_Input__c socialIndividual {get;private set;}
        public String commonHistory {get;private set;}
        public Plan__c planObject {get;set;}
        public String taskEvent {get;set;}
        public String activitiesTaskEvent {get;set;}
        public String relationsData {get;set;}
    }
    
     // Create Wrapper class for allPlanJson 
    public class AllPlanJsonWrapper {
        public String Id {get;set;}
        public String Name {get;set;}
        public String Minutes{get;set;}
        public string Hours{ get; set; }
        public string Days{ get; set; }
        public String Owner {get;set;}
        public String status {get;set;}
        public String phase{get;set;}
        public String Position {get;set;}
        public String Type {get;set;}
        public String itemRecordId {get;set;}
        public Boolean ismoveUp {get;set;}
        public String moveUp{get;set;}
        public Boolean ismoveDown {get;set;}
        public String moveDown{get;set;}
        public Boolean isDeletable {get;set;}
        public Boolean isEditable {get;set;}
        public Boolean isReadable {get;set;}
        public String delItem{get;set;}
        public String Investment {get;set;}
        public Integer progressValue {get;set;}  
        public Boolean  piPermission {get;set;}      
        public String DirectCost {get;set;}
        public String NetPresentValue {get;set;}
        public String PeopleInvolved{get;set;}
        public String FTE{get;set;} 
        public String Revenue{get;set;} 
        public String veto{get;set;}
        public String approve{get;set;}
        public String nostance{get;set;}
        public String disapprove{get;set;}
        public String issue{get;set;}
        public String mood{get;set;}
        public String moodClass{get;set;}
        public String predictionResult{get;set;}
        public String description {get;set;}
        public String popupField1{get;set;}
        public String popupField2{get;set;}
        public String popupField3{get;set;}
        public String popupFieldName1{get;set;}
        public String popupFieldName2{get;set;}
        public String popupFieldName3{get;set;}
        public String IssueImg{get;set;}
        public String MoodImg{get;set;}
        public string newTaskFromDecision{get;set;}
        public string newTaskFromDecisionIconTitle{get;set;}
        public string canUserCreateTask{get;set;}
        public string decisionClass {get;set;}
        public string dragDrop {get;set;}
        public string dragDropText {get;set;}
        
        public String actionClassName {get;set;}
        public String actionClassNameDecision {get;set;}
        public String typeClass {get;set;}
        public decimal estimatedHours {get;set;}
        public decimal actualHours {get;set;}
        public string complexity {get;set;}
        public string skillLevel {get;set;}
        // added by tanay
        public String delayTaskClass {get;set;}
        public datetime dueDateSort {get;private set;}
        public String duedatewrk {get; set;}
        public String isTask {get;private set;}
    }
    
    public Data data;
    
    public class Data {
        public List<AllPlanJsonWrapper> models;
    }
    
    public class dataActivities{
        public List<TaskEvent>  models{get; set;} 
    }
    
    public class dataWrapActivities{
        public dataActivities data{get;set;}    
    }
    
    // For drag drop functionality only 
    public void itemViewDetails() {
        planId = string.valueOf(plan.Id);
        
        // initialize General information class to get user locale date format and image static resouce url //
        //GeneralInformation genralInfo  = new GeneralInformation();
        if(genralInfo == null ) {
            genralInfo  = new GeneralInformation();
        }
        
        List<Relations__c> reltionshipList;
        reltionshipList = getPlanRelation(planId);
        recordChildId = new Set<Id>();
        decisionSet = new Set<Id>();
         
        // contains a record of the user who is logged in.
        //Social_Input__c loggedInSocialPeople = new Social_Input__c();
        if(loggedInSocialPeople == null) {
            if([select id  from Social_Input__c where User__c =: userInfo.getUserId() AND Plan__c =: planId].size() > 0 ) {
                loggedInSocialPeople = [Select s.Veto_Rights__c, s.User__c, s.SystemModstamp, s.Select_People__c, s.SYS_Tab_View_Tasks__c, s.SYS_Tab_View_Social_Input__c, s.SYS_Tab_View_Relations__c, s.SYS_Tab_View_Quality__c, s.SYS_Tab_View_History__c, s.SYS_Tab_View_Attachments__c, s.SYS_Tab_View_Approvals__c, s.SYS_Tab_View_Activites__c, s.Role__c, s.Role_Acceptance_Status__c, s.Role_Acceptance_Required__c, s.Result__c, s.Responsible__c, s.Rating__c, s.Plan__c, s.OwnerId, s.Outcome__c, s.Name_of_the_User__c, s.Name, s.Mood__c, s.Like__c, s.LastModifiedDate, s.LastModifiedById, s.Is_Group__c, s.IsDeleted, s.Informed__c, s.Id, s.Group_Name__c, s.GroupId__c, s.Final_Approval_Status__c, s.Effort__c, s.Dislike__c, s.Description__c, s.Decision__c, s.CreatedDate, s.CreatedById, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c, s.Accountable__c From Social_Input__c s where User__c =: userInfo.getUserId() AND Plan__c =: planId limit 1 ];
            }
        }
        
        Profile profileOfUser =[Select p.Name,p.Id From Profile p where p.id =: UserInfo.getProfileId() ];
         for(Relations__c r:reltionshipList ){
             recordChildId.add(r.Child_Id__c);
             if(r.Child_Object_Name__c == 'Decision'){
                 decisionSet.add(r.Child_Id__c);
             }
         } 
         
        map<Id,Social_Input__c> myRoleInDecisionMap = new map<Id,Social_Input__c>();
        map<Id,Decision__c> decisionMap = new map<Id,Decision__c>();
        map<Id,Social__c> socialMap = new map<Id,Social__c>();
        map<Id,List<Social_Input__c>> raciVetoMap = new map<Id,List<Social_Input__c>>(); 
        // approval list mapping 
        map<Id,List<Social_Input__c>> pendingRaciListMap = new map<Id,List<Social_Input__c>>();
        map<Id,List<Social_Input__c>> appRaciListMap = new map<Id,List<Social_Input__c>>();
        map<Id,List<Social_Input__c>> rejRaciListMap = new map<Id,List<Social_Input__c>>();
        if(decisionSet.size() > 0){
            //decisions
            for(Decision__c dec: [select id,phase__c,status__c, Estimated_Investment__c, Estimated_Direct_Cost__c, Estimated_Revenue__c, Estimated_Net_Present_Value__c, Estimated_People_Involved__c, Estimated_Full_time_Equivalent_FTE__c from Decision__c where Id In: recordChildId]) {
                decisionMap.put(dec.Id, dec);
            }
            
            //social
            for(Social__c soc: [select id, Avg_Mood__c,Related_To_ID__c from Social__c where Related_To_ID__c In: recordChildId]) {
                socialMap.put(soc.Related_To_ID__c, soc);
            }
            
            List<Social_Input__c> raciList = [select id,Stance_Approval_Status__c,Final_Approval_Status__c,Decision__c,Veto_Rights__c,Responsible__c,Informed__c, Consulted__c, Backup_for_Accountable__c, Accountable__c  from Social_Input__c where Decision__c In: recordChildId];
            
            List<Social_Input__c> myRoleOnDecisionList = [select id,Stance_Approval_Status__c,Role_Acceptance_Status__c,Final_Approval_Status__c,Decision__c,Decision__r.Phase__c,Veto_Rights__c,Responsible__c,Informed__c, Consulted__c, Backup_for_Accountable__c, Accountable__c  from Social_Input__c where Decision__c In: recordChildId and User__c =: userInfo.getUserId()];
            
            for(Social_Input__c s: myRoleOnDecisionList){
                if(myRoleInDecisionMap.get(s.Decision__c) == null)
                    myRoleInDecisionMap.put(s.Decision__c,s);   
            }
            
            for(Social_Input__c r: raciList){
                if((r.Final_Approval_Status__c == 'Pending Approval' && (r.Accountable__c || r.Backup_for_Accountable__c)) || (r.Stance_Approval_Status__c == 'Pending Approval' && (r.Responsible__c || r.Consulted__c || r.Veto_Rights__c))){
                    List<Social_Input__c> pendingRaciList =  pendingRaciListMap.get(r.Decision__c);
                    if(pendingRaciList == null) {
                     pendingRaciList = new List<Social_Input__c>();
                     pendingRaciListMap.put(r.Decision__c, pendingRaciList);
                    }
                    pendingRaciList.add(r);
                }
                if((r.Final_Approval_Status__c == 'Approved' && (r.Accountable__c || r.Backup_for_Accountable__c)) || (r.Stance_Approval_Status__c == 'Approved' && (r.Responsible__c || r.Consulted__c || r.Veto_Rights__c))){
                    List<Social_Input__c> approveRaciList =  appRaciListMap.get(r.Decision__c);
                    if(approveRaciList == null) {
                     approveRaciList = new List<Social_Input__c>();
                     appRaciListMap.put(r.Decision__c, approveRaciList);
                    }
                    approveRaciList.add(r);
                }
                if((r.Final_Approval_Status__c == 'Rejected' && (r.Accountable__c || r.Backup_for_Accountable__c)) || (r.Stance_Approval_Status__c == 'Rejected' && (r.Responsible__c || r.Consulted__c || r.Veto_Rights__c))){
                    List<Social_Input__c> rejectRaciList =  rejRaciListMap.get(r.Decision__c);
                    if(rejectRaciList == null) {
                     rejectRaciList = new List<Social_Input__c>();
                     rejRaciListMap.put(r.Decision__c, rejectRaciList);
                    }
                    rejectRaciList.add(r);
                }
                
                raciList = raciVetoMap.get(r.Decision__c);
                if(raciList == null) {
                    raciList = new List<Social_Input__c>();
                    raciVetoMap.put(r.Decision__c,raciList);
                }
                raciList.add(r);
            }
         }
         
         ownerDetail(recordChildId);
         Double totalMins = 0;
         Double totalHrs = 0;
         Double totalDays = 0;
         Integer i = 0;
        
         List<AllPlanJsonWrapper> allPlanJsonWrapperList = new List<AllPlanJsonWrapper >();
        
         //itemPlanWrapperMap = new map<Id,Relationship__c>();
        
         for(Relations__c r: reltionshipList) {
            AllPlanJsonWrapper apWrap = new AllPlanJsonWrapper();
            
            apWrap.Id = r.Id;
            apWrap.Name= r.Child_Record_Name__c;
            apWrap.Minutes = r.Minutes__c == null ? '0' : r.Minutes__c;   //,Plan_Days_Duration__c
            apWrap.Hours = r.Hours__c == null ? '0' : r.Hours__c;
            apWrap.Days = r.Days__c == null ? '0' : r.Days__c;
            apWrap.Owner = recordOwnerNameMap.get(r.Child_Id__c) != null ? recordOwnerNameMap.get(r.Child_Id__c) : '';
            apWrap.popupField1 = recordPopupField1Map.get(r.Child_Id__c) != null ? recordPopupField1Map.get(r.Child_Id__c) : '';
            apWrap.popupField2 = recordPopupField2Map.get(r.Child_Id__c) != null ? recordPopupField2Map.get(r.Child_Id__c) : '';
            apWrap.popupField3 = recordPopupField3Map.get(r.Child_Id__c) != null ? recordPopupField3Map.get(r.Child_Id__c) : '';
            apWrap.popupFieldName1 = recordPopupField1NameMap.get(r.Child_Id__c) != null ? recordPopupField1NameMap.get(r.Child_Id__c) : 'Insufficient privileges';
            apWrap.popupFieldName2 = recordPopupField2NameMap.get(r.Child_Id__c) != null ? recordPopupField2NameMap.get(r.Child_Id__c) : ''; 
            apWrap.popupFieldName3 = recordPopupField3NameMap.get(r.Child_Id__c) != null ? recordPopupField3NameMap.get(r.Child_Id__c) : ''; 
            apWrap.description = r.Description__c == null ? '' : r.Description__c;
            apWrap.Position = String.valueOf(r.Position__c);
            apWrap.Type = r.Child_Object_Name__c;
            apWrap.itemRecordId = r.Child_Id__c;
            apWrap.isDeletable= false;
            apWrap.isEditable = false;
            apWrap.ismoveDown = false; 
            apWrap.ismoveUp = false; 
            
            apWrap.actionClassName = 'grid-action-disabled';
            apWrap.dragDrop = genralInfo.imageUrlMap.get('null');
            apWrap.dragDropText = '';
            
            if(loggedInSocialPeople.Accountable__c || loggedInSocialPeople.Backup_for_Accountable__c || loggedInSocialPeople.Responsible__c || chkRecPermission==true) {
                apWrap.isDeletable= true;
                apWrap.isEditable = true;
                apWrap.ismoveDown = true; 
                apWrap.ismoveUp = true;
                apWrap.actionClassName = '';
                apWrap.dragDrop = genralInfo.imageUrlMap.get('dragDrop');
                apWrap.dragDropText = 'Drag to re-order the items';
            }
            apWrap.moveUp = apWrap.ismoveUp == true ? genralInfo.imageUrlMap.get('moveUp') : genralInfo.imageUrlMap.get('moveUpDisabled');
            apWrap.moveDown = apWrap.ismoveDown == true ? genralInfo.imageUrlMap.get('moveDown') : genralInfo.imageUrlMap.get('moveDownDisabled');
            apWrap.delItem = genralInfo.deleteImage.get(apWrap.isDeletable);
            apWrap.itemRecordId = r.Child_Id__c;
            apWrap.approve = appRaciListMap.get(Id.valueOf(r.Child_Id__c)) != null ? String.valueOf(appRaciListMap.get(Id.valueOf(r.Child_Id__c)).size()) : '0';
            apWrap.nostance = pendingRaciListMap.get(Id.valueOf(r.Child_Id__c)) != null ? String.valueOf(pendingRaciListMap.get(Id.valueOf(r.Child_Id__c)).size()) : '0';
            apWrap.disapprove = rejRaciListMap.get(Id.valueOf(r.Child_Id__c)) != null ? String.valueOf(rejRaciListMap.get(Id.valueOf(r.Child_Id__c)).size()) : '0';
            //apWrap.issue = issueMap.get(Id.valueOf(r.Child_Id__c)) != null ? String.valueOf(issueMap.get(Id.valueOf(r.Child_Id__c)).size()) : '' ;
            //apWrap.IssueImg= issueMap.get(Id.valueOf(r.Child_Id__c)) != null ? genralInfo.imageUrlMap.get('planFlagRed') : genralInfo.imageUrlMap.get('null');
        
            
            
           
            Decision__c dec = new Decision__c();
            if(decisionMap.get(Id.valueOf(r.Child_Id__c)) != null )
                dec = decisionMap.get(Id.valueOf(r.Child_Id__c));  
            
            system.debug('AAAA'+dec.id);
            apWrap.decisionClass = 'grid-action-disabled';
            apWrap.actionClassNameDecision = 'grid-action-disabled';
            /************* new task **********************/
            /************* new task **********************/
            if(apWrap.Type != 'Decision'){
                apWrap.newTaskFromDecision = genralInfo.imageUrlMap.get('null');
                apWrap.newTaskFromDecisionIconTitle = '';  
                //apWrap.actionClassName = 'grid-action-disabled';
            }else{
                if(dec.Id == null){
                    apWrap.newTaskFromDecision = genralInfo.imageUrlMap.get('newTaskForDecisionDisabled');
                    apWrap.newTaskFromDecisionIconTitle = 'You are not part of the Decision, so you cannot create the task';
                    apWrap.canUserCreateTask = 'false';     
                }else{
                    if(chkRecPermission==true){
                        apWrap.decisionClass = 'new-item-decision';
                        apWrap.newTaskFromDecision = genralInfo.imageUrlMap.get('newTaskForDecision');
                        apWrap.newTaskFromDecisionIconTitle = 'Adds new task under this decision fddsfsdfds';  
                        apWrap.canUserCreateTask = 'true';      
                    }
                    else if(myRoleInDecisionMap.get(Id.valueOf(r.Child_Id__c)) != null){
                        //System.debug('-phaniraj coding---'+myRoleInDecisionMap.get(Id.valueOf(r.Child_Id__c)).Accountable__c+'-----'+myRoleInDecisionMap.get(Id.valueOf(r.Child_Id__c)).Responsible__c+'------'+myRoleInDecisionMap.get(Id.valueOf(r.Child_Id__c)).Backup_for_Accountable__c+'-------'+profile.Name);
                        if(myRoleInDecisionMap.get(Id.valueOf(r.Child_Id__c)).Accountable__c == false && myRoleInDecisionMap.get(Id.valueOf(r.Child_Id__c)).Responsible__c == false && myRoleInDecisionMap.get(Id.valueOf(r.Child_Id__c)).Backup_for_Accountable__c == false && chkRecPermission!=true){
                            apWrap.newTaskFromDecision = genralInfo.imageUrlMap.get('newTaskForDecisionDisabled');
                            apWrap.newTaskFromDecisionIconTitle = 'Your role on the decision doesnot permit to create tasks';   
                            apWrap.canUserCreateTask = 'false';
                        }else{
                            apWrap.decisionClass = 'new-item-decision';
                            apWrap.newTaskFromDecision = genralInfo.imageUrlMap.get('newTaskForDecision');
                            apWrap.newTaskFromDecisionIconTitle = 'Adds new task under this decision';  
                            apWrap.canUserCreateTask = 'true';  
                        }
                    }else{
                        apWrap.newTaskFromDecision = genralInfo.imageUrlMap.get('newTaskForDecisionDisabled');
                        apWrap.newTaskFromDecisionIconTitle = 'You are not part of the Decision, so you cannot create the task';    
                        apWrap.canUserCreateTask = 'false';
                    }
                }
            }
            
            
            if(dec.Id != null){
                String veto = 'approved';
                Integer vetNum = 0;
                Social__c soc = socialMap.get(Id.valueOf(r.Child_Id__c)); 
                List<Social_Input__c> raciList1 = new List<Social_Input__c>();
                raciList1 = raciVetoMap.get(Id.valueOf(r.Child_Id__c));
                Boolean vetoPower = false;
                Boolean accoutableApproved = false;
                Integer.valueOf('x');
                for(Social_Input__c si: raciList1) {
                   
                    
                    if(si.Veto_Rights__c) {
                        vetNum = vetNum + 1;
                        if(veto != 'rejected') {
                            
                            if(si.Stance_Approval_Status__c == 'Rejected'){
                                veto = 'rejected';
                            }
                            if(si.Stance_Approval_Status__c == 'Pending Approval' && veto != 'rejected' ){
                                veto = '';
                            }
                           
                        }
                        
                    }
                    
                    if((si.Accountable__c || si.Backup_for_Accountable__c)&& si.Final_Approval_Status__c == 'Approved' ) {
                        accoutableApproved = true;
                    }
                }
                
                if(veto == '' && accoutableApproved) {
                    veto = 'approved';
                }
                
            
                System.debug('----------------veto value--------'+veto);
                
                
                apWrap.actionClassNameDecision = '';
                apWrap.piPermission = false; 
                 
                       
                apWrap.phase = dec.Phase__c != null ? dec.Phase__c : '';  
                apWrap.status = dec.Status__c != null ? dec.status__c : '';
                if( myRoleInDecisionMap.get(dec.id) != null)
                apWrap.piPermission =   (myRoleInDecisionMap.get(dec.id).Accountable__c || myRoleInDecisionMap.get(dec.id).Backup_for_Accountable__c || myRoleInDecisionMap.get(dec.id).responsible__c) && ( myRoleInDecisionMap.get(dec.id).Role_Acceptance_Status__c  == 'Approved/accepted' ) && ( dec.Status__c != 'Closed') ;

                /* *************** view4 *********** */
                apWrap.Investment = dec.Estimated_Investment__c != null ? String.valueOf(dec.Estimated_Investment__c) : '0';
                apWrap.DirectCost = dec.Estimated_Direct_Cost__c != null ? String.valueOf(dec.Estimated_Direct_Cost__c) : '0';
                apWrap.NetPresentValue = dec.Estimated_Net_Present_Value__c != null ? String.valueOf(dec.Estimated_Net_Present_Value__c) : '0';
                apWrap.PeopleInvolved = dec.Estimated_People_Involved__c != null ? String.valueOf(dec.Estimated_People_Involved__c) : '0';
                apWrap.FTE = dec.Estimated_Full_time_Equivalent_FTE__c != null ? String.valueOf(dec.Estimated_Full_time_Equivalent_FTE__c) : '0';
                /* *************** view3 *********** */
                apWrap.veto = String.valueOf(vetNum) != null ? String.valueOf(vetNum) : '' ;
                apWrap.mood = String.valueOf(soc.Avg_Mood__c) != null ? String.valueOf(math.round(soc.Avg_Mood__c)) : '';
                apWrap.MoodImg = genralInfo.imageUrlMap.get(string.valueOf(math.round(Double.valueOf(apWrap.mood)))) != null ? genralInfo.imageUrlMap.get(string.valueOf(math.round(Double.valueOf(apWrap.mood)))) : genralInfo.imageUrlMap.get('moodNoInput') ;                   
                /* *************** view2 *********** */
                apWrap.predictionResult = genralInfo.imageUrlMap.get(veto) != null ? genralInfo.imageUrlMap.get(veto) : genralInfo.imageUrlMap.get('null');  // to be replaced with image
            }else{
                apWrap.phase = '';
                apWrap.status = '';
                
                /* *************** view4 *********** */
                apWrap.Investment = '';
                apWrap.DirectCost = '';
                apWrap.NetPresentValue = '';
                apWrap.PeopleInvolved = '';
                apWrap.FTE = '';
                
                /* *************** view3 *********** */
                apWrap.veto = '';
                apWrap.mood = '';
                
                /* *************** view2 *********** */
                apWrap.predictionResult = genralInfo.imageUrlMap.get('null');
                apWrap.MoodImg = genralInfo.imageUrlMap.get('null') ; 
            }
            
            
            allPlanJsonWrapperList.add(apWrap);
            //itemPlanWrapperMap.put(r.Id, r);
            
            if(r.Minutes__c != null) {
                totalMins = totalMins + Double.valueOf(r.Minutes__c);
            }
            if(r.Hours__c != null){
                totalHrs = totalHrs + Double.valueOf(r.Hours__c);
            }
            if(r.Days__c != null){
                totalDays = totalDays + Double.valueOf(r.Days__c);
            }
         }
        // count Mints
        
         if(totalMins  > = 60) {
            Integer hr = (totalMins/60).intValue();
            Integer mins = (totalMins - (hr * 60)).intValue();
            totalMins = mins;
            totalHrs = totalHrs + hr;
            //totalHoursMints = String.valueOf(hr) + ' hr : ' + String.valueOf(mins )  + ' mins';
         }
         if(totalHrs > 23){
            Integer days = (totalHrs/24).intValue();
            Integer hrs = (totalHrs - (days * 24)).intValue();
            totalHrs = hrs;
            totalDays = totalDays + days;   
         }
         String days = '';
         if(totalDays.intValue() < 2){
             days = 'day';
         }else{
             days = 'days';
         }
         
         String hours= '';
         if(totalHrs.intValue() < 2){
             hours = 'hour';
         }else{
             hours = 'hours';
         }
         
         String mins = '';
         if(totalMins.intValue() < 2){
             mins= 'min';
         }else{
             mins= 'mins';
         }  
        
         totalHoursMints = String.valueOf(totalDays.intValue())+' '+days+' '+String.valueOf(totalHrs.intValue())+' '+hours+' '+String.valueOf(totalMins.intValue())+' '+mins;
        
         allItemJson = '';
        
         allItemJson = JSON.serialize(allPlanJsonWrapperList);
    }
    public string  sendjason()
    {
         return '[{ Id: 1, Name: \"Decision 1\", Position: 1,OrderDate:\'\' },{ Id: 2, Name: \"Decision 2\", Position: 2,OrderDate:\'\' },{ Id: 3, Name: \"Decision 3\", Position: 3,OrderDate:\'\' }]';
    }
    
     // get the user record from the Collection
    public static String listToStringConvert(List<String> grpMemberList) {
        
        
        if(genralInfo == null){
            genralInfo = new GeneralInformation();
        } 
        
        String UserName = '';
        Integer i = 0;
        for(String str : grpMemberList) {
            if(UserName == '') {
                UserName = genralInfo != null && genralInfo.useNameMap != null && str != null && genralInfo.useNameMap.get(str) != null && genralInfo.useNameMap.get(str).Name != null ? genralInfo.useNameMap.get(str).Name : '';
            }
            else {
                if(genralInfo.useNameMap.get(str)!=null){
                    if(i<4){
                        if(genralInfo != null && genralInfo.useNameMap != null && str != null && genralInfo.useNameMap.get(str) != null && genralInfo.useNameMap.get(str).Name != null){    
                            UserName = UserName + ',' + genralInfo.useNameMap.get(str).Name;
                        }
                        i++;
                    }
                }
            }
        }
        return  UserName;       
    }
     // update pulse from itemview1   
     @RemoteAction
    public static void updatePulse(String pulseStatus, String decisionId){
        Decision__c decision = new Decision__c(id = decisionId );
         //decision.Id = decisionId;
         decision.Progress__c = pulseStatus;
        if(FLS.decisionUpdateable()){
            update decision;
        }
     
    }
    
}