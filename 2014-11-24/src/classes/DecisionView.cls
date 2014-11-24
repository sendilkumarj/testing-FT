/* 
    ********************************************************************** 
    Created by: Piyush Parmar
    Last Modified by: Piyush Parmar
    Style: Force.com & Metro
    Description: a) This is for the primary functionality on decision page
                 b) This controller performs the functionality for individual tabs 
                 c) Social timingcommand center functionalities
                 d) Social tools ex. like, dislike, star rating, mood, outcome rating
                 e) Timing update
                 f) delete related list object records (Social Input, Task, Event, Activities, Relations, Attachment, Issues)           
                 g) Approval process 
                 h) Add tag on decision
    ********************************************************************** 
 */

Public with sharing class DecisionView {
 
    // initialize decision for getter setter
    public Decision__c decision {get;set;}  
    
    // initialize social input for getter setter // 
    public Social_Input__c socialInput {get;set;}
    
     // initialize social input for getter setter //
    public Social__c  social {get;set;}
    
    // json string for people (Socail Input)  tab
    public static String decisionSocialInputJson {get;private set;}
    
    // json string for activity tab
    public static String activitiesTaskEventJson {get;private set;}
    
    // json string for relationship tab
    public static String relationshipJson {get;private set;}
    
     // json string for activity tab
    public static String taskEventJson {get;private set;}
    
    // json string for History Tab 
    public static String historyJson {get;private set;}
    
    // json string for attachment  tab
    public static String attachmentNoteJson {get;private set;}
    
    // json string for issues quality tab
    public static String issuesQualityJson {get;private set;}
    
    // json string for timing tab
    public static String timeSectionJSON {get;private set;}
    
     // json string for timing tab
    public static String approvalJSON {get;private set;}    
    
    //  json string for mtrix tab
    public static String matrixSectionJSON {get;private set;}    
    //Matrix icon url
    public static String iconMatrix {get;private set;}    
    //  json string for mtrix tab
    public static String matrixSectionTitle {get;private set;}    
    
    // user locale date fromat as string 
    public static String dateFormat {get;set;}
    
    // user locale datetime fromat as string 
    public static String dateTimeFormat {get;set;}
    
    // json string for tag list
    public String tagJson {get;set;}
    
    //Json contribution
    public static String jsonContribution {get; set;}
    
    // Decision id for (15 characters)
    public String decisionID {get;set;}
    
    public String profileName {get;set;}    
    
    public User sysAdmin {get;set;}
    
    public String imageURLonDecision{get;set;} // to get image in decision
    
    public static GeneralInformation genralInfo;
    
    public Task updatedTask {get;set;}
    
    // Event getter setter
    public Event event {get;set;}
    
    public Profile UserProfile{get;set;}
    
    public static Profile profile; 
    
    public static Social_Input__c loggedInSocialPeople;
    
    public Integer weekDayNumber{get;set;}
    
    public Task task {get;set;}
    
    public String message{get;set;}
    
    // Declare attachment count
    public Integer attachmentCount{get;set;}
    
    //Declare chatter feed attachment count
    public Boolean  feedattachmentCount{get;set;}
    public List<Decision__Feed> chkFeedAttachment{get;set;}

    // Declare the variable.
    String DecID;
    
    // Initialize star image for average relevance
    public string starImage {get;set;}
    public string starImagePosition {get;set;}
    
    public List<Relations__c> srchRelationship{get;set;}
    public Set<Relations__c> srchRelationshipSet{get;set;}
    Set<Id> relationsIds = new Set<Id>();
    
    // Dynamic picklist values as string
    public String taskStatusPicklist {get;set;}
    public string taskPriorityPicklist {get;set;}

    // Create map.
    // Mapping average mood with mood text
    map<Integer,String> avgMoodValueMap = new map<Integer,String>();
    
    public string avgMood{get; set;}
    
   //Declare this variable for checking record level permission
    public static Boolean chkRecPermission{get;set;}
    // Declare this variable for UserRecordAccess  
    public List<UserRecordAccess> listUserRecordAccess{get;set;}
    //variable to hold all user accessible object
    public List<SelectOption> userAccessibleobjects {get;set;}
    // set to hold all Crm objects that has to be shown under add relations popup
    public set<String>  crmObjectsSet ; 
    
    // set to hold all FT  objects that has to be shown under add relations popup
    public set<String>  ftObjectsSet ;
    
    // map to hold all object namr to label
    public Map<String,String>  objectNameLabelMap  {get;set;}
     
    // set variable to collect all topics that are selected in admin tool
    public List<String> setTopics {get; set;}
    
    //Topic selected list wrapper declaration
    public List<TopicAssigned> lstTopicAssigned {get; set;}
    List<TopicAssignment> topicAssignmentList;
    public String selectedTopics {get; set;}
    List<Topic_Selected_Data__c>  TopicsSelectedCustomSettingList;
    
    public string progress{get;set;}
    
    public static Boolean walkmeTaskVar {get; set;}
    
    public Boolean showTaskPopup {get; set;}
    public Boolean newShowTaskPopup {get; set;}
    public String taskId {get; set;}
    public String taskEditable {get; set;}
    public String modeType {get; set;}
    
    public Task newTaskToDecision{get;set;}
    //variable to capture decision save status 
    public string  decisonSaveStatus { get;  set;}
    public List<String> lstStatusValues {get; set;}
    public List<String> lstPriorityValues {get; set;}    
    //variable to send user locale 
    public static string  userLocaleSidKey{get;set;}
    static{
            //set user locale here
            userLocaleSidKey  = UserInfo.getLocale().replace('_','-');
    }    
    
    public DecisionView(ApexPages.StandardController controller) {
        // initialize General information class to get user locale date format and image static resouce url //
        //GeneralInformation genralInfo  = new GeneralInformation();
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=8');
        if(genralInfo == null ) {
            genralInfo  = new GeneralInformation();
        }
        // Initialize attachment count
        attachmentCount = 0;
        feedattachmentCount=false;
        chkFeedAttachment = new List<Decision__Feed>();
        listUserRecordAccess = new List<UserRecordAccess>();
         //list to hold all useraccesable objects
        userAccessibleobjects = new List<SelectOption>();
        
        showTaskPopup = false;
        newShowTaskPopup = false;
        // variable to store decision save status
        decisonSaveStatus =  'Success';
        //Map to hold objects name and labels
        objectNameLabelMap = new Map<String,String>(); 
        
        //Initialize the crmObjectsSet to make userAccessibleobjects hold only specified values
        crmObjectsSet = new set<String>{'Account','Asset','Case','Campaign','Contact','Contract','Idea','Lead','Opportunity','Order','Price Book','Product','Quote','Quote Line Item','Solution','User' };
       
        //Initialize the ftObjectsSet to make userAccessibleobjects hold only specified values
        ftObjectsSet  = new Set<String>{ 'Decision','Plan' };
        // Records the current decision id
        DecID = ApexPages.currentPage().getParameters().get('id');
        
        // assign user locale date format as string 
        dateFormat = genralInfo.MapValuesDateFormate();
        
        // assign user locale DATE-TIME format as string - this is added by phaniraj
        dateTimeFormat = genralInfo.MapValuesDateTime();
        
        // Mapping average mood values with mood text.
        avgMoodValueMap.put(0,'Not Given');
        avgMoodValueMap.put(1,'Very Worried');
        avgMoodValueMap.put(2,'Worried');
        avgMoodValueMap.put(3,'Neutral');
        avgMoodValueMap.put(4,'Happy');
        avgMoodValueMap.put(5,'Very Happy');
        
        selectedTopics = '';
        
        lstStatusValues = new List<String>();
        lstPriorityValues = new List<String>();
        
        try {
            
           // Decision__c decisionProgressChk = [select id , Progress__c from Decision__c where id =:DecID Limit 1];
           
            List<String> weekDays = new List<String>{'Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'};
            date myDate = date.today();
            date weekStart = myDate.toStartofWeek();
            Datetime dt = DateTime.newInstance(weekStart, Time.newInstance(0, 0, 0, 0));
            String weekDay =dt.format('EEEE');
            System.debug('Day : ' + weekDay);
            
            for(Integer i = 0; i < weekDays.size(); i++ ){
                if(weekDays[i] == weekDay)
                    weekDayNumber = i;      
            }
        
            //decision = [select ID, Name,Tag__c,Add_C_I_Members__c, Plain_Tag__c, Title__c, Decision_Type__c, Decision_Approach__c, Category__c, Decision_Making_Style__c, Priority__c, Private__c, Estimated_Investment__c, Estimated_Direct_Cost__c, Estimated_Net_Present_Value__c, Estimated_People_Involved__c, Estimated_Full_time_Equivalent_FTE__c, Actual_Investment__c, Actual_Direct_Cost__c, Actual_Net_Present_Value__c, Actual_People_Involved__c, Actual_Full_time_Equivalent_FTE__c, Phase__c, Status__c, Valid_From__c, Valid_Until__c, Point_of_No_Return__c, Due_Date__c, Estimated_People_Involved_Desc__c, Estimated_Net_Present_Value_Desc__c, Estimated_Investment_Desc__c, Estimated_Full_time_Equivalent_Desc__c, Estimated_Direct_Cost_Desc__c, Actual_People_Involved_Desc__c, Actual_Net_Present_Value_Desc__c, Actual_Investment_Desc__c, Actual_Full_time_Equivalent_Desc__c, Actual_Direct_Cost_Desc__c, Identifier__c, Estimated_Revenue__c, Estimated_Revenue_Desc__c, Actual_Revenue__c, Actual_Revenue_Desc__c from Decision__c where ID =: ApexPages.currentPage().getParameters().get('id')];
            
            // For field sets. Call getDecisionDetails method       
            this.decision = getDecisionDetails();
            
              if(decision.Progress__c == 'Not Given'){
                progress ='notGiven';
            }else If(decision.Progress__c == 'Good'){
                progress ='good';
            }
            else If(decision.Progress__c == 'Minor Challenges'){
                progress ='minorChallenges';
            }
             else If(decision.Progress__c == 'Critical'){
                progress ='critical';
             }
              else If(decision.Progress__c == 'Completed'){
                progress ='completed';
              }
              else If(decision.Progress__c == 'Completed with Problems'){
                progress ='completedProb';
              }
             
             
             newTaskToDecision = new task(Status='Not Started',whatId = decision.Id,OwnerId = UserInfo.getUserId(),Priority = 'Normal',IsReminderSet = true,Skill_Level__c = '1'); 
             
           // profile =[Select Name From Profile where Name=: 'System Administrator' limit 1];
              // Query for current login user max record permission
             listUserRecordAccess = [SELECT RecordId, HasReadAccess, HasEditAccess, HasDeleteAccess,MaxAccessLevel FROM UserRecordAccess WHERE UserId=:UserInfo.getUserId() AND RecordId =:DecID limit 1];
                system.debug('============listUserRecordAccess==========='+listUserRecordAccess);
             
              if(listUserRecordAccess.size() > 0 && listUserRecordAccess[0].MaxAccessLevel=='All'  ){
                
                    //User usr = [SELECT ProfileId FROM User where id=:UserInfo.getUserId() Limit 1];
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
            loggedInSocialPeople = new Social_Input__c();
            if([Select id From Social_Input__c s where s.Decision__c =: ApexPages.currentPage().getParameters().get('id') AND s.User__c =: userInfo.getUserId() ].size() > 0) {
                socialInput = [Select s.Veto_Rights__c, s.User__c,s.Stance_Approval_Status__c, s.SystemModstamp, s.Select_People__c, s.SYS_Tab_View_Tasks__c, s.SYS_Tab_View_Social_Input__c, s.SYS_Tab_View_Relations__c, s.SYS_Tab_View_Quality__c, s.SYS_Tab_View_History__c, s.SYS_Tab_View_Attachments__c, s.SYS_Tab_View_Approvals__c, s.SYS_Tab_View_Activites__c, s.Role__c, s.Role_Acceptance_Status__c, s.Role_Acceptance_Required__c, s.Result__c, s.Responsible__c, s.Rating__c, s.Plan__c, s.OwnerId, s.Outcome__c, s.Name_of_the_User__c, s.Name, s.Mood__c, s.Like__c, s.LastModifiedDate, s.LastModifiedById, s.Is_Group__c, s.IsDeleted, s.Informed__c, s.Id, s.Group_Name__c, s.GroupId__c, s.Final_Approval_Status__c, s.Effort__c, s.Dislike__c, s.Description__c, s.Decision__c, s.CreatedDate, s.CreatedById, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c, s.Accountable__c From Social_Input__c s where s.Decision__c =:ApexPages.currentPage().getParameters().get('id')  AND s.User__c =: userInfo.getUserId() ];  
                System.debug('------role acceptance-------------------'+socialInput);
                System.debug('------role acceptance-------------------'+UserInfo.getUserName());
                loggedInSocialPeople = socialInput;
            }
            
            String decisioIdStr = decision.Id;
            decisionID = decisioIdStr.substring(0, 15);
            
            // Querying attachment object for the count of records for the specific decision
            attachmentCount = [SELECT COUNT() FROM Attachment where ParentId =: DecID];
            chkFeedAttachment = [SELECT id,RelatedRecordId FROM Decision__Feed  where ParentId =: DecID];
            if(chkFeedAttachment.size() > 0 ){
                for(Decision__Feed fi:chkFeedAttachment)
                    if(fi.RelatedRecordId != null){
                        feedattachmentCount=true;
                        break;
                    }
            }
            
            // fetching the topics selected from admin tool
            setTopics = new List<String>();
            List<Topic> lstTopic = [select id,Name from Topic limit 999];
            if(!lstTopic.isEmpty()){
                lstTopic.sort();
            }
            for(Topic t : lstTopic){
                setTopics.add(t.Name);
            }
            set<String> setTopicsAssigned = new set<String>();
            topicAssignmentList = new List<TopicAssignment>();
            topicAssignmentList = [SELECT EntityId, TopicId,Topic.Name FROM TopicAssignment where EntityId = : decision.Id limit 1000];
            for(TopicAssignment ta : topicAssignmentList){  
                setTopicsAssigned.add(ta.Topic.Name);
                selectedTopics = selectedTopics+','+ta.Topic.Name;
            }
            selectedTopics = selectedTopics.replaceFirst(',','');
            System.debug('-------setTopicsAssigned-------->'+setTopicsAssigned);
            lstTopicAssigned = new List<TopicAssigned>();
            for(String st : setTopics){
                TopicAssigned ta = new TopicAssigned();
                ta.TopicName = st;
                if(setTopicsAssigned.contains(st)){ 
                    System.debug('-------st-------->'+st);
                    ta.TopicSelected = 'selected';
                }
                lstTopicAssigned.add(ta);
            } 
            System.debug('-------lstTopicAssigned-------->'+lstTopicAssigned);
            // Call social people section method. This one is deprecated. But needed in the code from packaging perspective.
            viewSocialPeople(decision.Id, null);
            
            // Call social people section method with searrch feature.
            viewSocialPeopleTabWithSearch(decision.id, null,'');
            
            //contributionTab();
            
            // Call timing section method
            timingTab(decision.Id); 
            
            // Call history  section method
            //viewHistory(decision.Id);
            
            /*   *******************************  this method is not required now as we are using standard related list from salesforce *********************************   */
            /*   *******************************  when this is to be reverted to kendo table developer will have to uncomment the following code *********************************   */
            // Call attachment and notes  section method
            //attachmentNoteView(decision.Id); 
            
            // Call quality section method
            //issuesQuality(decision.Id, null);
            
            //old task event method
            //activitiesTab(decision.Id, null);
            
            // Call actvities for task and event
            activitiesTabWithSearch(decision.Id, null,'');
            
            // Call ralationship section method
            viewAllRelationships(decision.Id, null);
            
            // Call ralationship section method 
            approvalTab(decision.Id);
            
            //Call decision matrix tab
            matrixDataTab(decision.Id);
            
            attachment = new Attachment ();
            
            attachmentUpdate = new Attachment ();
            
            updatedTask = new Task();
            
            event = new Event();
            
            showImageOnDecision();
            
            srchRelationship = new List<Relations__c> ();
            srchRelationshipSet = new Set<Relations__c> ();
            // 
            tagJson = jsonStringTagGenerate();
            
            social = [Select s.Total_Rating__c, s.Total_Likes__c, s.Total_Effort__c, s.Total_Dislikes__c, s.Result_Count__c, s.Related_To_ID__c, s.Rating_Count__c, s.Mood_Count__c, s.Effort_Count__c, s.Avg_Result__c, s.Avg_Rating__c, s.Avg_Mood__c, s.Avg_Effort__c From Social__c s where s.Related_To_ID__c =: decision.Id];
            // Getting the average mood value.
            avgMood = avgMoodValueMap.get(Integer.valueOf(social.Avg_Mood__c));   
            
            // Call average star calulation method
            avgStarImgCalculation();
            
            // initialize isssues
            
            //UserProfile = [Select p.Name From Profile p where p.Id =: userInfo.getProfileId() ];
           // profileName = UserProfile.Name;
            
           // system.debug('===profileName======'+profileName);
            
            //get schema describe to get all object
            List<Schema.SObjectType> globaldescribe = Schema.getGlobalDescribe().Values();     
             
             List<SelectOption> userAccessibleobjectsUnSorted =  new List<SelectOption>();
             
             for(Schema.SObjectType f : globaldescribe)
             {   //for each object if it is viewable by user then add to userAccessibleobjects
                 if( f.getDescribe().isAccessible() && crmObjectsSet.contains(f.getDescribe().getLabel()) ){
                    userAccessibleobjectsUnSorted.add(new SelectOption(f.getDescribe().getName(),f.getDescribe().getLabel()));
                    objectNameLabelMap.put(f.getDescribe().getName(),f.getDescribe().getLabel());
                 }
                 else
                 if( f.getDescribe().isAccessible() && ftObjectsSet.contains(f.getDescribe().getLabel()) ){
                    userAccessibleobjects.add(new SelectOption(f.getDescribe().getName(),f.getDescribe().getLabel()));
                    objectNameLabelMap.put(f.getDescribe().getName(),f.getDescribe().getLabel());
                 }
             }
             
             userAccessibleobjectsUnSorted.sort();
             userAccessibleobjects.sort();
             userAccessibleobjects.addAll( userAccessibleobjectsUnSorted );
             
            // Dynamic picklist for tasks status & language issue fixes
            Schema.Describefieldresult statusResult = Schema.sObjectType.Task.fields.Status;
            statusResult = statusResult.getSObjectField().getDescribe();
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
        }
        catch(Exception e) {
            
        }
    }
    
    // Calculates the average relevance of decision and assign appropriate image to the value.
    public void avgStarImgCalculation(){
          System.debug('--------------Enetr method ------->');
            String avgRatingValue ='';
            if(social.Avg_Rating__c ==  1.0) {
                avgRatingValue = 'star1';
            }
            if(social.Avg_Rating__c > 1.0 && social.Avg_Rating__c < 2.0 ) {
                avgRatingValue = 'star1.5';
            }
                
            if(social.Avg_Rating__c ==  2.0) {
                avgRatingValue = 'star2';
            }
                
            if(social.Avg_Rating__c > 2.0 && social.Avg_Rating__c < 3.0 ) {
                avgRatingValue = 'star2.5';
            }
                
            if(social.Avg_Rating__c ==  3.0) {
                avgRatingValue = 'star3';
            }
                
            if(social.Avg_Rating__c > 3.0 && social.Avg_Rating__c < 4.0 ) {
                avgRatingValue = 'star3.5';
            }
                
            if(social.Avg_Rating__c ==  4.0) {
                avgRatingValue = 'star4';
            }
            
            if(social.Avg_Rating__c > 4.0 && social.Avg_Rating__c < 5.0 ) {
                avgRatingValue = 'star4.5';
            }
            
            if(social.Avg_Rating__c ==  5.0) {
                avgRatingValue = 'star5';
            }
            
            if(social.Avg_Rating__c == 0.0) {
                avgRatingValue = 'star';
            }
            starImage = genralInfo.imageUrlMap.get('AllStars');
            starImagePosition = genralInfo.imageUrlMap.get(avgRatingValue);
    }
    
    // Fetching the field form the Field Sets. 
    public List<Schema.FieldSetMember> getFields() { // getCustomerSpecificFeilds
        return SObjectType.Decision__c.FieldSets.Customer_Specific.getFields();
    }
    
    // For Field sets. Querying the fields form the Field Sets dynamically.
     public Decision__c getDecisionDetails(){
        String query = 'SELECT ';
        for(Schema.FieldSetMember f : this.getFields()){
            query += f.getFieldPath() + ', ';
        }
        query += 'ID, Name, Nearest_Due_Date__c ,Progress__c,Decision_Taken__c,Problem_Idea_Advice__c, Title__c,Tag__c,Add_C_I_Members__c, Plain_Tag__c, Decision_Type__c, Decision_Approach__c, Category__c, Decision_Making_Style__c, Priority__c, Private__c, Estimated_Investment__c, Estimated_Direct_Cost__c, Estimated_Net_Present_Value__c, Estimated_People_Involved__c, Estimated_Full_time_Equivalent_FTE__c, Actual_Investment__c, Actual_Direct_Cost__c, Actual_Net_Present_Value__c, Actual_People_Involved__c, Actual_Full_time_Equivalent_FTE__c, Phase__c, Status__c, Point_of_No_Return__c, Due_Date__c, Estimated_People_Involved_Desc__c, Estimated_Net_Present_Value_Desc__c, Estimated_Investment_Desc__c, Estimated_Full_time_Equivalent_Desc__c, Estimated_Direct_Cost_Desc__c, Actual_People_Involved_Desc__c, Actual_Net_Present_Value_Desc__c, Actual_Investment_Desc__c, Actual_Full_time_Equivalent_Desc__c, Actual_Direct_Cost_Desc__c, Identifier__c, Estimated_Revenue__c, Estimated_Revenue_Desc__c, Actual_Revenue__c, Actual_Revenue_Desc__c,Reason_for_Close__c from Decision__c where ID =: DecID';
        return Database.query(query);
     }
   
   
     // get to be update Task
    public void toBeUpdatedTask() {
        //updatedTask = [select id,WhatId,Subject,ActivityDate,Status,Priority,OwnerId,Owner.Name,CreatedById,CreatedBy.Name,Description from Task where Id =: ApexPages.currentPage().getParameters().get('taskId')];
        showTaskPopup = true;
        taskId = ApexPages.currentPage().getParameters().get('taskId');
        taskEditable = ApexPages.currentPage().getParameters().get('isEditable');
        modeType = ApexPages.currentPage().getParameters().get('modeType');
    }
    //render task popup onclick of close button 
    public void closeTaskPopup(){
        showTaskPopup = false;
    }
    //render task popup onclick of new task button 
    public void newTaskPopupComponent(){
        newShowTaskPopup = newShowTaskPopup == true ? false : newShowTaskPopup == false ? true : false;
    }
    
    // get to be update Event 
    public void toBeUpdatedEvent () {
        event = [select id,WhatId,EndDateTime,Subject,ActivityDate,StartDateTime ,ActivityDateTime,OwnerId,Owner.Name,CreatedById,CreatedBy.Name,Description from Event where Id =: ApexPages.currentPage().getParameters().get('eventId')];
    }
    
    // Intialise task popup when opening from activites tab
    public void intialiseDecisionTask(){
        newTaskToDecision = new Task();
        newTaskToDecision = new Task(Status='Not Started',WhatId = decision.Id,OwnerId = UserInfo.getUserId(),Priority = 'Normal',IsReminderSet = true,Skill_Level__c = '1');
        System.debug('---------newTaskToDecision---------->'+newTaskToDecision);
    }
    
    
    // edit event on decision object 
    public void updatedTask() {
      String sendingNotification = ApexPages.currentPage().getParameters().get('sendingNotification');   
      System.debug('-----sendingNotification ----'+sendingNotification );
      
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
    
    // edit event on decision object 
    public void updatedEvent() {
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
    
    // This function use for create new task unser the decision and 
    // edit task on plan object it self
    public void createNewTaskForDecision(){
        String sendingNotification = ApexPages.currentPage().getParameters().get('sendingNotification');  
        
        //insert newTaskToDecision;
        Database.DMLOptions dmlo = new Database.DMLOptions();
        if(sendingNotification == 'true')
            dmlo.EmailHeader.triggerUserEmail = true;
        else
            dmlo.EmailHeader.triggerUserEmail = false;
        if(FLS.taskCreateable()){
            database.insert(newTaskToDecision, dmlo);
        }
        newTaskToDecision = new task();
        newTaskToDecision =  new task(Status='Not Started',whatId = decision.Id,OwnerId = UserInfo.getUserId(),Priority = 'Normal',IsReminderSet = true,Skill_Level__c = '1'); 
        System.debug('-------newTaskToDecision--------->'+newTaskToDecision);
    }
    
    // Social Section
    // change individuals user input mood value
    @RemoteAction
    Public static JsonExistingData socialCommand(String socialInputId, String updatedField, String inputValues) {
        
        JsonExistingData jsonExistingData = new JsonExistingData();
        
        Social_Input__c socialInput = [Select s.Veto_Rights__c,s.Stance_Approval_Status__c, s.User__c, s.SystemModstamp, s.SYS_Tab_View_Tasks__c, s.SYS_Tab_View_Social_Input__c, s.SYS_Tab_View_Relations__c, s.SYS_Tab_View_Quality__c, s.SYS_Tab_View_Attachments__c, s.SYS_Tab_View_Approvals__c, s.Role_Acceptance_Status__c, s.Role_Acceptance_Required__c, s.Result__c, s.Responsible__c, s.Rating__c, s.Outcome__c, s.Name, s.Mood__c, s.Like__c, s.LastModifiedDate, s.LastModifiedById, s.Informed__c, s.Id, s.Final_Approval_Status__c, s.Effort__c, s.Dislike__c, s.Decision__c,s.Decision__r.phase__c, s.CreatedDate, s.CreatedById, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c, s.Accountable__c From Social_Input__c s where s.Id =: socialInputId ];
        
        if(Schema.Sobjecttype.Social_Input__c.fields.Mood__c.isUpdateable()) {
            if(updatedField == 'Mood') {
                socialInput.Mood__c = Decimal.valueOf(inputValues);
            }
            else if (updatedField == 'Rating') {
                socialInput.Rating__c = Decimal.valueOf(inputValues);
            }
            else if(updatedField == 'Result') {
                if(socialInput.Effort__c == 0.0 || socialInput.Effort__c == null) {
                     socialInput.Effort__c = 3;
                }
                socialInput.Result__c = Decimal.valueOf(inputValues);
            }
            else if (updatedField == 'Effort') {
                if(socialInput.Result__c == 0.0 || socialInput.Result__c == null) {
                     socialInput.Result__c = 3;
                }
                socialInput.Effort__c = Decimal.valueOf(inputValues);
            }
            else if (updatedField == 'Like') {
                socialInput.Like__c = 1;
                socialInput.Dislike__c = 0;
            }
            else if (updatedField == 'Dislike') {
                socialInput.Dislike__c = 1;
                socialInput.Like__c = 0;
            }
            
            if(FLS.socialInputUpdateable()) {
                update socialInput;
            }
        }
        
        Social__c  social = [Select s.Total_Rating__c, s.Total_Likes__c, s.Total_Effort__c, s.Total_Dislikes__c, s.Result_Count__c, s.Related_To_ID__c, s.Rating_Count__c, s.Mood_Count__c, s.Effort_Count__c, s.Avg_Result__c, s.Avg_Rating__c, s.Avg_Mood__c, s.Avg_Effort__c From Social__c s where s.Related_To_ID__c =: socialInput.Decision__c];
        jsonExistingData.socialIndividual = socialInput;
        jsonExistingData.socialOverall = social;
        
        return jsonExistingData;
    }
    // End Social Section
    
    //Method to Batch update Activities tab called from parseModifiedData javascript method
    
    @RemoteAction
    public static JsonExistingData updateActivitesTab(String modifiedDataStr, String searchText, String decisionId){
        
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
        List<ActivitiesTaskEvent> allActivites = pv.data.models;
        
        List<Task> taskActivityList = new List<Task>();
        
        // List of task for related decision.
        taskActivityList = [select Id,WhatId,OwnerId, CreatedById,Owner.Name ,ActivityDate,Status,IsClosed,Priority,Subject,Description from Task where whatId=:decisionId ORDER BY CreatedDate DESC ];
        
        // Creating map for task to make dynamic task instance
        Map<Id,Task> taskMap = new Map<Id,Task>();
        
        // Assinging task id in map with task object instance
        for(Task t: taskActivityList){
            taskMap.put(t.Id,t);  
        }
        
        List<Event> eventActivityList = new List<Event>();
        // List of event for related decision.
        eventActivityList = [select id,WhatId,OwnerId,Owner.Name,CreatedById,ActivityDate,ActivityDateTime,Subject,Description from Event where whatId=:decisionId ORDER BY CreatedDate DESC ] ;
        
        // Creating map for task to make dynamic event instance
        Map<Id,Event> eventMap = new Map<Id,Event>();
       
        // Assinging task id in map with task object instance
        for(Event e : eventActivityList){
            eventMap.put(e.Id,e);
        }
         
        // Assigning and updating the values for the task.
        List<Task> tobeUpdatedTask = new List<Task>();
        for(ActivitiesTaskEvent aw : allActivites){
            if(taskMap.get(aw.Id) != null){
                Task t = taskMap.get(aw.Id);
                t.Subject = aw.subject;
                System.debug('------aw.duedate-------->'+aw.duedate);
                /*if(aw.duedate != null && aw.duedate.length() > 10)
                    t.ActivityDate = Date.valueOf(aw.duedate).addDays(1);*/
                if(aw.duedateSort != null && String.Valueof(aw.duedateSort).length() > 10){
                    t.ActivityDate = aw.duedateSort.date();    
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
        for(ActivitiesTaskEvent aw : allActivites){
            if(eventMap.get(aw.Id) != null){
                Event e = eventMap.get(aw.Id);
                e.Subject = aw.subject;
                /*if(aw.duedate != null && aw.duedate.length() > 10)
                    e.ActivityDate = Date.valueOf(aw.duedate).addDays(1);*/
                if(aw.duedateSort != null && String.Valueof(aw.duedateSort).length() > 10){
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
        jed = activitiesTabWithSearch(decisionId,'',searchText);
        return jed;
    }
    
    // Phases changes on decision
    @RemoteAction
     public static JsonExistingData decisionPhaseChangeDecide(String decisionId, String socialInputId, String phaseValue, String reasonForClose, String comments  ) {
        
        System.debug('-----phaseValue-----');
        Decision__c decision = [select id, Name, Title__c, Phase__c, Status__c from Decision__c where Id =: decisionId]; // This is dprected because of field sets query.
       
        Social_Input__c socialInput = [Select s.Veto_Rights__c,s.Stance_Approval_Status__c, s.User__c, s.SystemModstamp, s.SYS_Tab_View_Activites__c, s.SYS_Tab_View_History__c, s.SYS_Tab_View_Tasks__c, s.SYS_Tab_View_Social_Input__c, s.SYS_Tab_View_Relations__c, s.SYS_Tab_View_Quality__c, s.SYS_Tab_View_Attachments__c, s.SYS_Tab_View_Approvals__c, s.Role_Acceptance_Status__c, s.Role_Acceptance_Required__c, s.Result__c, s.Responsible__c, s.Rating__c, s.Outcome__c, s.Name, s.Mood__c, s.Like__c, s.LastModifiedDate, s.LastModifiedById, s.Informed__c, s.Id, s.Final_Approval_Status__c, s.Effort__c, s.Dislike__c, s.Decision__c, s.CreatedDate, s.CreatedById, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c, s.Accountable__c From Social_Input__c s where s.Id =: socialInputId ];
        System.debug('Social Input Value'+socialInput);
        // initialize map of decision id v/s timing data
        map<Id, List<Timing__c>> decisionIdtimingListMap = new map<Id, List<Timing__c>>();
        
        for(Timing__c timing : [Select t.Start_Date_Time__c, t.Stage__c, t.Related_To_ID__c, t.End_Date_Time__c, t.Elapsed_Time__c, t.Difference__c, t.Actual_Start_Date__c, t.Actual_End_Date__c From Timing__c t where t.Related_To_ID__c =: decision.Id]) {
            
            List<Timing__c> timingList = decisionIdtimingListMap.get(timing.Related_To_ID__c);
            if(timingList == null ) {
                timingList = new List<Timing__c>();
                decisionIdtimingListMap.put(timing.Related_To_ID__c, timingList);
            }
            timingList.add(timing);
        }
        
        map<String, Timing__c> phasestimingMap = new map<String, Timing__c>();
        
        for(Timing__c timing : decisionIdtimingListMap.get(decision.Id)) {
            phasestimingMap.put(timing.Stage__c, timing);
        }
        
        DateTime toBeUpdatedNearestDueDate;
          
        decision.Phase__c = 'Propose';
        decision.Status__c = 'Undecided';
        
        //calculate nearest due date
        Timing__c decide = phasestimingMap.get('Propose');
        Timing__c approve = phasestimingMap.get('Decide');
        Timing__c execute = phasestimingMap.get('Execute');
        Timing__c evaluate = phasestimingMap.get('Evaluate');
        Timing__c close = phasestimingMap.get('Close');
        
        if(close.End_Date_Time__c != null)
            toBeUpdatedNearestDueDate = close.End_Date_Time__c;
        if(close.Start_Date_Time__c != null)
            toBeUpdatedNearestDueDate = close.Start_Date_Time__c;
        if(evaluate.End_Date_Time__c != null)
            toBeUpdatedNearestDueDate = evaluate.End_Date_Time__c;
        if(evaluate.Start_Date_Time__c != null)
            toBeUpdatedNearestDueDate = evaluate.Start_Date_Time__c;
        if(execute.End_Date_Time__c != null)
            toBeUpdatedNearestDueDate = execute.End_Date_Time__c;
        if(execute.Start_Date_Time__c != null)
            toBeUpdatedNearestDueDate = execute.Start_Date_Time__c;
        if(approve.End_Date_Time__c != null)
            toBeUpdatedNearestDueDate = approve.End_Date_Time__c;
        if(approve.Start_Date_Time__c != null)
            toBeUpdatedNearestDueDate = approve.Start_Date_Time__c;
        if(decide.End_Date_Time__c != null)
            toBeUpdatedNearestDueDate = decide.End_Date_Time__c;
        
        if(close.End_Date_Time__c == null && close.Start_Date_Time__c == null && evaluate.End_Date_Time__c == null && evaluate.Start_Date_Time__c == null && execute.End_Date_Time__c == null && execute.Start_Date_Time__c == null && approve.End_Date_Time__c == null && approve.Start_Date_Time__c == null && decide.End_Date_Time__c == null)
            toBeUpdatedNearestDueDate = null;   
        
        System.debug('------toBeUpdatedNearestDueDate---decide---------'+toBeUpdatedNearestDueDate);
        
        // update nearest due date
        decision.Nearest_Due_Date__c = toBeUpdatedNearestDueDate;
        
        if(FLS.decisionUpdateable()) {
            update decision;
            
        }
        
        socialInput = [Select s.Veto_Rights__c, s.User__c,s.Stance_Approval_Status__c, s.SystemModstamp, s.SYS_Tab_View_Activites__c, s.SYS_Tab_View_History__c, s.SYS_Tab_View_Tasks__c, s.SYS_Tab_View_Social_Input__c, s.SYS_Tab_View_Relations__c, s.SYS_Tab_View_Quality__c, s.SYS_Tab_View_Attachments__c, s.SYS_Tab_View_Approvals__c, s.Role_Acceptance_Status__c, s.Role_Acceptance_Required__c, s.Result__c, s.Responsible__c, s.Rating__c, s.Outcome__c, s.Name, s.Mood__c, s.Like__c, s.LastModifiedDate, s.LastModifiedById, s.Informed__c, s.Id, s.Final_Approval_Status__c, s.Effort__c, s.Dislike__c, s.Decision__c, s.CreatedDate, s.CreatedById, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c, s.Accountable__c From Social_Input__c s where s.Id =: socialInputId ];
        System.debug('Social Input Value'+socialInput);
        JsonExistingData jsonExistingData = new JsonExistingData();
        jsonExistingData.commonHistory = viewHistory(decisionId);
        jsonExistingData.decisionObject = decision;
        jsonExistingData.socialIndividual = socialInput;
        jsonExistingData.timingObject = timingTab(decisionId);
        jsonExistingData.peopleObject = viewSocialPeopleTabWithSearch(decisionId, null, '');
        jsonExistingData.approvalObject = approvalTab(decisionId);
        return jsonExistingData;
    }
    
    
    // Phases changes on decision
    @RemoteAction
    public static JsonExistingData decisionPhaseChange(String decisionId, String socialInputId, String phaseValue, String reasonForClose, String comments  ) {
        
        Decision__c decision = [select id, Name, Title__c,Due_Date__c, Phase__c, Status__c,ownerid from Decision__c where Id =: decisionId];
        
        Social_Input__c socialInput = [Select s.Name_of_the_User__c,s.Veto_Rights__c,s.Stance_Approval_Status__c, s.User__c, s.SystemModstamp, s.SYS_Tab_View_Activites__c, s.SYS_Tab_View_History__c, s.Final_Approval_Status__c, s.SYS_Tab_View_Tasks__c, s.SYS_Tab_View_Social_Input__c, s.SYS_Tab_View_Relations__c, s.SYS_Tab_View_Quality__c, s.SYS_Tab_View_Attachments__c, s.SYS_Tab_View_Approvals__c, s.Role_Acceptance_Status__c, s.Role_Acceptance_Required__c, s.Result__c, s.Responsible__c, s.Rating__c, s.Outcome__c, s.Name, s.Mood__c, s.Like__c, s.LastModifiedDate, s.LastModifiedById, s.Informed__c, s.Id, s.Effort__c, s.Dislike__c, s.Decision__c, s.CreatedDate, s.CreatedById, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c From Social_Input__c s where s.Id =: socialInputId ];
 
        // initialize map of decision id v/s timing data
        map<Id, List<Timing__c>> decisionIdtimingListMap = new map<Id, List<Timing__c>>();
        
        for(Timing__c timing : [Select t.Start_Date_Time__c, t.Stage__c, t.Related_To_ID__c, t.End_Date_Time__c, t.Elapsed_Time__c, t.Difference__c, t.Actual_Start_Date__c, t.Actual_End_Date__c From Timing__c t where t.Related_To_ID__c =: decision.Id]) {
            
            List<Timing__c> timingList = decisionIdtimingListMap.get(timing.Related_To_ID__c);
            if(timingList == null ) {
                timingList = new List<Timing__c>();
                decisionIdtimingListMap.put(timing.Related_To_ID__c, timingList);
            }
            timingList.add(timing);
        }
        
        map<String, Timing__c> phasestimingMap = new map<String, Timing__c>();
        
        for(Timing__c timing : decisionIdtimingListMap.get(decision.Id)) {
            phasestimingMap.put(timing.Stage__c, timing);
        }
        
        DateTime toBeUpdatedNearestDueDate;
        
        System.debug('----------phaseValue------->'+phaseValue);
        System.debug('----------decision.Due_Date__c------->'+decision.Due_Date__c);
        
        if(phaseValue == 'Share') {
            
            //calculate nearest due date
            Timing__c share = phasestimingMap.get('Share');
            Timing__c decide = phasestimingMap.get('Propose');
            Timing__c approve = phasestimingMap.get('Decide');
            Timing__c execute = phasestimingMap.get('Execute');
            Timing__c evaluate = phasestimingMap.get('Evaluate');
            Timing__c close = phasestimingMap.get('Close');
            
            if(close.End_Date_Time__c != null)
                toBeUpdatedNearestDueDate = close.End_Date_Time__c;
            if(close.Start_Date_Time__c != null)
                toBeUpdatedNearestDueDate = close.Start_Date_Time__c;
            if(evaluate.End_Date_Time__c != null)
                toBeUpdatedNearestDueDate = evaluate.End_Date_Time__c;
            if(evaluate.Start_Date_Time__c != null)
                toBeUpdatedNearestDueDate = evaluate.Start_Date_Time__c;
            if(execute.End_Date_Time__c != null)
                toBeUpdatedNearestDueDate = execute.End_Date_Time__c;
            if(execute.Start_Date_Time__c != null)
                toBeUpdatedNearestDueDate = execute.Start_Date_Time__c;
            if(approve.End_Date_Time__c != null)
                toBeUpdatedNearestDueDate = approve.End_Date_Time__c;
            if(approve.Start_Date_Time__c != null)
                toBeUpdatedNearestDueDate = approve.Start_Date_Time__c;
            if(decide.End_Date_Time__c != null)
                toBeUpdatedNearestDueDate = decide.End_Date_Time__c;
            if(decide.Start_Date_Time__c != null)
                toBeUpdatedNearestDueDate = decide.Start_Date_Time__c;
            if(share.End_Date_Time__c != null)
                toBeUpdatedNearestDueDate = share.End_Date_Time__c;
            
            if(close.End_Date_Time__c == null && close.Start_Date_Time__c == null && evaluate.End_Date_Time__c == null && evaluate.Start_Date_Time__c == null && execute.End_Date_Time__c == null && execute.Start_Date_Time__c == null && approve.End_Date_Time__c == null && approve.Start_Date_Time__c == null && decide.End_Date_Time__c == null && decide.Start_Date_Time__c == null && share.End_Date_Time__c == null)
                toBeUpdatedNearestDueDate = null;
            
            System.debug('------toBeUpdatedNearestDueDate---share---------'+decision.Phase__c);
            
            // update nearest due date
            decision.Nearest_Due_Date__c = toBeUpdatedNearestDueDate;
            
            if(decision.Phase__c == 'Propose' || decision.Phase__c == 'Decide' || decision.Phase__c == 'Execute' || decision.Phase__c == 'Evaluate' || decision.Phase__c == 'Close'){
                decision.Due_Date__c = null;
                decision.Nearest_Due_Date__c = null;
            }
            decision.Phase__c = 'Share';
            decision.Status__c = 'Undecided';
        }
        else if(phaseValue == 'Propose') {
            System.debug('-----phaseValue-------------propose--------------'+phaseValue);
            decision.Phase__c = 'Propose';
            decision.Status__c = 'Undecided';
            
            //calculate nearest due date
            Timing__c decide = phasestimingMap.get('Propose');
            Timing__c approve = phasestimingMap.get('Decide');
            Timing__c execute = phasestimingMap.get('Execute');
            Timing__c evaluate = phasestimingMap.get('Evaluate');
            Timing__c close = phasestimingMap.get('Close');
            
            if(close.End_Date_Time__c != null)
                toBeUpdatedNearestDueDate = close.End_Date_Time__c;
            if(close.Start_Date_Time__c != null)
                toBeUpdatedNearestDueDate = close.Start_Date_Time__c;
            if(evaluate.End_Date_Time__c != null)
                toBeUpdatedNearestDueDate = evaluate.End_Date_Time__c;
            if(evaluate.Start_Date_Time__c != null)
                toBeUpdatedNearestDueDate = evaluate.Start_Date_Time__c;
            if(execute.End_Date_Time__c != null)
                toBeUpdatedNearestDueDate = execute.End_Date_Time__c;
            if(execute.Start_Date_Time__c != null)
                toBeUpdatedNearestDueDate = execute.Start_Date_Time__c;
            if(approve.End_Date_Time__c != null)
                toBeUpdatedNearestDueDate = approve.End_Date_Time__c;
            if(approve.Start_Date_Time__c != null)
                toBeUpdatedNearestDueDate = approve.Start_Date_Time__c;
            if(decide.End_Date_Time__c != null)
                toBeUpdatedNearestDueDate = decide.End_Date_Time__c;
                
            if(close.End_Date_Time__c == null && close.Start_Date_Time__c == null && evaluate.End_Date_Time__c == null && evaluate.Start_Date_Time__c == null && execute.End_Date_Time__c == null && execute.Start_Date_Time__c == null && approve.End_Date_Time__c == null && approve.Start_Date_Time__c == null && decide.End_Date_Time__c == null)
                toBeUpdatedNearestDueDate = null;
            
            // update nearest due date
            decision.Nearest_Due_Date__c = toBeUpdatedNearestDueDate;
        }
        else if(phaseValue == 'Decide') {
            decision.Reason_for_close__c = 'Cancelled';
            decision.Phase__c = 'Decide';
            decision.Status__c = 'Approved';
            
            // calculate nearest due date
            
            Timing__c approve = phasestimingMap.get('Decide');
            Timing__c execute = phasestimingMap.get('Execute');
            Timing__c evaluate = phasestimingMap.get('Evaluate');
            Timing__c close = phasestimingMap.get('Close');
            
            if(close.End_Date_Time__c != null)
                toBeUpdatedNearestDueDate = close.End_Date_Time__c;
            if(close.Start_Date_Time__c != null)
                toBeUpdatedNearestDueDate = close.Start_Date_Time__c;
            if(evaluate.End_Date_Time__c != null)
                toBeUpdatedNearestDueDate = evaluate.End_Date_Time__c;
            if(evaluate.Start_Date_Time__c != null)
                toBeUpdatedNearestDueDate = evaluate.Start_Date_Time__c;
            if(execute.End_Date_Time__c != null)
                toBeUpdatedNearestDueDate = execute.End_Date_Time__c;
            if(execute.Start_Date_Time__c != null)
                toBeUpdatedNearestDueDate = execute.Start_Date_Time__c;
            if(approve.End_Date_Time__c != null)
                toBeUpdatedNearestDueDate = approve.End_Date_Time__c;
            
            if(close.End_Date_Time__c == null && close.Start_Date_Time__c == null && evaluate.End_Date_Time__c == null && evaluate.Start_Date_Time__c == null && execute.End_Date_Time__c == null && execute.Start_Date_Time__c == null && approve.End_Date_Time__c == null)
                toBeUpdatedNearestDueDate = null;
            
            // update nearest due date
            decision.Nearest_Due_Date__c = toBeUpdatedNearestDueDate;
        }
        else if(phaseValue == 'Execute') {
            decision.Reason_for_close__c = 'Executed';
            decision.Phase__c= 'Execute';
            decision.Status__c = 'Approved' ;
            
            //calculate nearest due date
            Timing__c execute = phasestimingMap.get('Execute');
            Timing__c evaluate = phasestimingMap.get('Evaluate');
            Timing__c close = phasestimingMap.get('Close');
            
            if(close.End_Date_Time__c != null)
                toBeUpdatedNearestDueDate = close.End_Date_Time__c;
            if(close.Start_Date_Time__c != null)
                toBeUpdatedNearestDueDate = close.Start_Date_Time__c;
            if(evaluate.End_Date_Time__c != null)
                toBeUpdatedNearestDueDate = evaluate.End_Date_Time__c;
            if(evaluate.Start_Date_Time__c != null)
                toBeUpdatedNearestDueDate = evaluate.Start_Date_Time__c;
            if(execute.End_Date_Time__c != null)
                toBeUpdatedNearestDueDate = execute.End_Date_Time__c;
            
            if(close.End_Date_Time__c == null && close.Start_Date_Time__c == null && evaluate.End_Date_Time__c == null && evaluate.Start_Date_Time__c == null && execute.End_Date_Time__c == null)
                toBeUpdatedNearestDueDate = null;
            
            System.debug('------toBeUpdatedNearestDueDate-----execute-------'+toBeUpdatedNearestDueDate);
            
            // update nearest due date
            decision.Nearest_Due_Date__c = toBeUpdatedNearestDueDate;
        }
        else if(phaseValue == 'Evaluate') {
            decision.Reason_for_close__c = 'Evaluated';
            decision.Phase__c = 'Evaluate';
            if( decision.Status__c == 'Approved' )
            decision.Status__c = 'Executed' ;
            
            //calculate nearest due date
            Timing__c evaluate = phasestimingMap.get('Evaluate');
            Timing__c close = phasestimingMap.get('Close');
            
            if(close.End_Date_Time__c != null)
                toBeUpdatedNearestDueDate = close.End_Date_Time__c;
            if(close.Start_Date_Time__c != null)
                toBeUpdatedNearestDueDate = close.Start_Date_Time__c;
            if(evaluate.End_Date_Time__c != null)
                toBeUpdatedNearestDueDate = evaluate.End_Date_Time__c;
            
            if(close.End_Date_Time__c == null && close.Start_Date_Time__c == null && evaluate.End_Date_Time__c == null)
                toBeUpdatedNearestDueDate = null;
            
            // update nearest due date
            decision.Nearest_Due_Date__c = toBeUpdatedNearestDueDate;
        }
        else if(phaseValue == 'Close') {
            decision.Phase__c = 'Close';
            // Updated the status to closed irrespective of whether closed from any phase.
            decision.Status__c = 'Closed';
            decision.Reason_for_close__c = reasonForClose;
            decision.Comments__c = comments;
            decision.Nearest_Due_Date__c = null;
        }
        if(FLS.decisionUpdateable()) {
            System.debug('----------decision.Due_Date__c------->'+decision.Nearest_Due_Date__c);
            update decision;
            
            System.debug('----------decision.Due_Date__c------->'+decision.Nearest_Due_Date__c);
            
            //Create a chatter post when decision is shared
            if( FLS.FeedItemCreatable() && phaseValue == 'Share') 
            {
                Id userId=decision.ownerid;
                String unitPost;
                Decision__c decisionQry  =[select id,Problem_Idea_Advice__c from Decision__c where id =:decisionId Limit 1];
                User usr = [Select id,name from User where id=:decision.ownerid Limit 1];
                
                if(decisionQry.Problem_Idea_Advice__c != null && decisionQry.Problem_Idea_Advice__c.length() > 3500){
                     unitPost = decisionQry.Problem_Idea_Advice__c.substring(0,3500);
                     unitPost += '... Readmore in Fingertip';
                }else{
                        if(decisionQry.Problem_Idea_Advice__c == null){
                            unitPost = '';
                        }else{
                            unitPost = decisionQry.Problem_Idea_Advice__c;
                        }
                        
                }
                
                String postText='I just shared this decision with you. Let’s get good insights and collaboration going!'+'\n'+'\n'+'Here is the description:'+'\n'+'\n'+'"'+unitPost+'"'+'\n';
                //System.debug('mentionTextPost'+postText+'userId'+userId+'userId'+userId);
                mentionTextPost( userId, postText, decisionId);
            } 
            //Create a chatter post when decision is proposed with then keep title as decision id for qurying later
            if( FLS.FeedItemCreatable() && phaseValue == 'Propose') 
            {
                Decision__c decisionQry  =[select id,Problem_Idea_Advice__c,Decision_Taken__c from Decision__c where id =:decisionId Limit 1];
                Id userId=decision.ownerid;
                
                User usr = [Select id,name from User where id=:decision.ownerid Limit 1];
                //String postText='The following decision has been proposed:'+'\n'+'\n'+'"'+decisionQry.Decision_Taken__c+'"'+'\n'+'\n'+usr.name+' '+'needs your personal stance.';
                String postText='Here is the proposed Decision, read it and give your Stance.'+'\n'+'\n'+'Decision:'+'\n'+'"'+decisionQry.Decision_Taken__c+'"'+'\n'+'\n'+'(hint: it’s done in the command center)';
                mentionTextPostPropose( usr.id , postText, decisionId);
                
                /*FeedItem post = new FeedItem();
                post.ParentId =  decision.Id;  
                post.Body =      'The decision has been proposed'  ;
                post.type = 'TextPost';                   
                post.Title = decision.id;  
                post.createdbyid = decision.ownerid;
                insert post;*/   
            }  
            if( FLS.FeedItemCreatable() && phaseValue == 'Execute') 
            {
                Decision__c decisionQry  =[select id,Problem_Idea_Advice__c,Decision_Taken__c from Decision__c where id =:decisionId Limit 1];
                Id userId=decision.ownerid;
                User usr = [Select id,name from User where id=:decision.ownerid Limit 1];
                String postText='The decision is good to go, let’s Execute!'+'\n';
                mentionTextPostPropose( usr.id, postText, decisionId);
            }
            if( FLS.FeedItemCreatable() && phaseValue == 'Evaluate') 
            {
                Decision__c decisionQry  =[select id,Problem_Idea_Advice__c,Decision_Taken__c from Decision__c where id =:decisionId Limit 1];
                Id userId=decision.ownerid;
                User usr = [Select id,name from User where id=:decision.ownerid Limit 1];
                String postText='We have Executed the Decision and it is time to Evaluate its Outcome.'+'\n'+'Rate the overall Result and Effort put into the decision.'+'\n'+'\n'+'It would be great that you would share your key learning and take away from this decision. Put it as a comment!'+'\n'+'\n'+'(hint: it’s done in the command center)'+'\n';
                mentionTextPostPropose( usr.id, postText, decisionId);
            }     
        }
        
        socialInput = [Select s.Veto_Rights__c, s.User__c, s.SystemModstamp, s.SYS_Tab_View_Activites__c,s.Stance_Approval_Status__c, s.SYS_Tab_View_History__c, s.SYS_Tab_View_Tasks__c, s.SYS_Tab_View_Social_Input__c, s.SYS_Tab_View_Relations__c, s.SYS_Tab_View_Quality__c, s.SYS_Tab_View_Attachments__c, s.SYS_Tab_View_Approvals__c, s.Role_Acceptance_Status__c, s.Role_Acceptance_Required__c, s.Result__c, s.Responsible__c, s.Rating__c, s.Outcome__c, s.Name, s.Mood__c, s.Like__c, s.LastModifiedDate, s.LastModifiedById, s.Informed__c, s.Id, s.Final_Approval_Status__c, s.Effort__c, s.Dislike__c, s.Decision__c, s.CreatedDate, s.CreatedById, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c, s.Accountable__c From Social_Input__c s where s.Id =: socialInputId ];
        System.debug('-----------Social Input Value--------'+socialInput);
        System.debug('-----------Social Input Value Final_Approval_Status__c--------'+socialInput.Final_Approval_Status__c);
        JsonExistingData jsonExistingData = new JsonExistingData();
        jsonExistingData.commonHistory = viewHistory(decisionId);
        jsonExistingData.decisionObject = decision;
        jsonExistingData.socialIndividual = socialInput;
        jsonExistingData.timingObject = timingTab(decisionId);
        jsonExistingData.peopleObject = viewSocialPeopleTabWithSearch(decisionId, null, '');
        jsonExistingData.approvalObject = approvalTab(decisionId);
        return jsonExistingData;
    }
 
    
       //addded by Tanay das barman
       //** Create and post a message to Chatter (Mention List)
     public static ConnectApi.MentionSegmentInput addMentionSegment(Id thisId) {
        ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
        mentionSegment.id = thisId;
        system.debug('mentionSegmentmentionSegment'+mentionSegment);
        return mentionSegment;
    }
    // Call this method fromshare phase for chatter feed. 
     public static void mentionTextPost(Id userId, String postText,Id decisionId) {
        
        //Initialize Chatter Connect Api.
        ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
        /** Combine the needed messageSegments into one coherent messageInput**/
        ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
        messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        ConnectApi.TextSegmentInput textSegment;
        messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        Boolean oneTimeExecution= true;
        
        List<Social_Input__c> lstSocialInput = [Select s.Informed__c,s.Decision__r.OwnerId,s.Veto_Rights__c,s.Responsible__c,s.Accountable__c,s.Consulted__c,s.Role_Acceptance_Status__c,s.Is_Group__c,s.User__c, s.Backup_for_Accountable__c,s.Role__c From Social_Input__c s where Decision__c=:decisionId];
        List<Social_Input__c> lstSocialInput1 = new List<Social_Input__c>();
        List<Social_Input__c> lstSocialInput2 = new List<Social_Input__c>();
        if(lstSocialInput.size() > 25){
            for(Integer i = 0 ; i < 24 ; i++){
                lstSocialInput1.add(lstSocialInput[i]);
            }
            for(Integer j = 24; j < lstSocialInput.size() ; j++){
                lstSocialInput2.add(lstSocialInput[j]);
            }
        }
        if(!lstSocialInput1.isEmpty()){
            lstSocialInput.clear();
            lstSocialInput.addAll(lstSocialInput1);
        }
        
        for (Social_Input__c si : lstSocialInput) {
            if(oneTimeExecution){
              textSegment = new ConnectApi.TextSegmentInput();
              textSegment.text = '\n'+postText+'\n';
               messageInput.messageSegments.add(textSegment);
               oneTimeExecution=false;
            }
           if(si.User__c==userId){
                continue;
                }
                //This is for Accountable Collaborator.
           else if(((si.Backup_for_Accountable__c== true &&  si.Informed__c == true ) && ( si.Responsible__c == false && si.Consulted__c == false   ) ) && !si.Is_Group__c && si.Role_Acceptance_Status__c !='Not Accepted'){
                messageInput.messageSegments.add(addMentionSegment(si.User__c));
                textSegment = new ConnectApi.TextSegmentInput();
                textSegment.text ='   '+ '[Backup For Accountable],';
                messageInput.messageSegments.add(textSegment);
            }
                //This is for Responsible Collaborator.
           else if((si.Role__c=='Responsible' || (si.Responsible__c == true && si.Accountable__c == false && si.Consulted__c == false   ) )&& si.Backup_for_Accountable__c== false && !si.Is_Group__c && si.Role_Acceptance_Status__c !='Not Accepted'){
                messageInput.messageSegments.add(addMentionSegment(si.User__c));
                textSegment = new ConnectApi.TextSegmentInput();
                textSegment.text = '  '+'[Responsible],';
                messageInput.messageSegments.add(textSegment);
           } 
           //This is for consulted Collaborator.
           else if((si.Role__c=='Consulted' || (si.Consulted__c == true && si.Accountable__c == false && si.Responsible__c == false  )) && si.Backup_for_Accountable__c== false && !si.Is_Group__c && si.Role_Acceptance_Status__c !='Not Accepted'){
                messageInput.messageSegments.add(addMentionSegment(si.User__c));
                textSegment = new ConnectApi.TextSegmentInput();
                textSegment.text = '  '+'[Consulted],';
                messageInput.messageSegments.add(textSegment);
           } 
           //This is for Bacup Accountable/Responsible/Consulted Collaborator.
            if(si.Backup_for_Accountable__c == true  && si.Responsible__c == true && si.Consulted__c == true && !si.Is_Group__c && si.Role_Acceptance_Status__c !='Not Accepted' ){
                messageInput.messageSegments.add(addMentionSegment(si.User__c));
                textSegment = new ConnectApi.TextSegmentInput();
                textSegment.text = '  '+'[Backup For Accountable][Responsible][Consulted],';
                messageInput.messageSegments.add(textSegment);
           }
           //This is for Backup Accountable/Responsible Collaborator.
            else if(si.Backup_for_Accountable__c== true  && si.Responsible__c == true && si.Consulted__c != true && !si.Is_Group__c && si.Role_Acceptance_Status__c !='Not Accepted' ){
                messageInput.messageSegments.add(addMentionSegment(si.User__c));
                textSegment = new ConnectApi.TextSegmentInput();
                textSegment.text ='  '+'[Backup For Accountable][Responsible],';
                messageInput.messageSegments.add(textSegment);
           }
           //This is for Backup Accountable/Consulted Collaborator.
            else if(si.Backup_for_Accountable__c == true && si.Responsible__c != true && si.Consulted__c == true && !si.Is_Group__c && si.Role_Acceptance_Status__c !='Not Accepted' ){
                messageInput.messageSegments.add(addMentionSegment(si.User__c));
                textSegment = new ConnectApi.TextSegmentInput();
                textSegment.text = '  '+'[Backup For Accountable][Consulted],';
                messageInput.messageSegments.add(textSegment);
           }
           //This is for Responsible/Consulted Collaborator.
            else if((si.Accountable__c != true || si.Backup_for_Accountable__c != true) && si.Responsible__c == true && si.Consulted__c == true && !si.Is_Group__c && si.Role_Acceptance_Status__c !='Not Accepted' ){
                messageInput.messageSegments.add(addMentionSegment(si.User__c));
                textSegment = new ConnectApi.TextSegmentInput();
                textSegment.text = '  '+'[Responsible][Consulted],';
                messageInput.messageSegments.add(textSegment);
           }
           
         /*  else if((si.Role__c=='Informed'|| si.Backup_for_Accountable__c== true) && !si.Is_Group__c ){
                messageInput.messageSegments.add(addMentionSegment(si.User__c));
                textSegment = new ConnectApi.TextSegmentInput();
                textSegment.text = '[Informed],';
                messageInput.messageSegments.add(textSegment);
           } */
        }       
     // add the text that was passed
      input.body = messageInput;
    // post it
    
    ConnectApi.FeedItem fi = ConnectApi.ChatterFeeds.postFeedItem(null, ConnectApi.FeedType.Record, decisionId, input, null);
    Decision__c decision = new Decision__c(id = decisionId,
                                           FeedItem_Id__c = fi.Id ); 
		try{
    		update decision;
		}catch(Exception e){
		
			FutureMethodController.feedIdUpdateOnDecision(decisionId,fi.Id );
		}
    	
    if(!lstSocialInput2.isEmpty()){
        mentionTextPostForMoreUsers(lstSocialInput2,fi.Id,userId,postText);
    }
     //This is for veto  Collaborator. 
    Boolean vetoOoneTimeExecution = true;
    //Initialize Chatter Connect Api locaally.
           ConnectApi.CommentInput inputcomment = new ConnectApi.CommentInput();
           messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
           
           Id shareFeedId = fi.Id ;
           
              for (Social_Input__c si:[Select s.Informed__c,s.Veto_Rights__c,s.Responsible__c,s.Accountable__c,s.Consulted__c,s.Role_Acceptance_Status__c,s.Is_Group__c,s.User__c, s.Backup_for_Accountable__c,s.Role__c From Social_Input__c s where Decision__c=:decisionId]) {
                if(vetoOoneTimeExecution && si.Veto_Rights__c == true ){
                  textSegment = new ConnectApi.TextSegmentInput();
                  textSegment.text = '\n'+'I have given you Veto rights for this Decision. Please note that if you reject, the decision can’t go forward!'+'\n';
                   messageInput.messageSegments.add(textSegment);
                   vetoOoneTimeExecution=false;
                }
               if(si.User__c==userId){
                    continue;
                    }
                    //This is for Veto Collaborator.
               else if(si.Veto_Rights__c == true && !si.Is_Group__c && si.Role_Acceptance_Status__c !='Not Accepted'){
                    messageInput.messageSegments.add(addMentionSegment(si.User__c));
                    textSegment = new ConnectApi.TextSegmentInput();
                    textSegment.text ='   '+ '[Veto],';
                    messageInput.messageSegments.add(textSegment);
                }
       }
       
       if(!vetoOoneTimeExecution){
         inputcomment.body = messageInput;   
         ConnectApi.Comment commentRep = ConnectApi.ChatterFeeds.postComment(null, shareFeedId, inputcomment, null);    
       }
       
    System.debug('----------decision.Due_Date__c------->'+decision.Due_Date__c);
  }  
  
  public static void mentionTextPostForMoreUsers(List<Social_Input__c> lstSocialInput, Id feedId, Id userId, String postText){
        ConnectApi.TextSegmentInput textSegment;
        ConnectApi.CommentInput inputcomment = new ConnectApi.CommentInput();
        ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
        messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        Boolean oneTimeExecution= true;
        
        set<Social_Input__c> lstSocialInput1 = new set<Social_Input__c>();
        set<Social_Input__c> lstSocialInput2 = new set<Social_Input__c>();
        if(lstSocialInput.size() > 25){
            for(Integer i = 0 ; i < 24 ; i++){
                lstSocialInput1.add(lstSocialInput[i]);
            }
            for(Integer j = 25; j < lstSocialInput.size() ; j++){
                lstSocialInput2.add(lstSocialInput[j]);
            }
        } else {
            lstSocialInput1.addAll(lstSocialInput);
        }
        if(!lstSocialInput1.isEmpty()){
            lstSocialInput.clear();
            lstSocialInput.addAll(lstSocialInput1);
        }
        
        for (Social_Input__c si : lstSocialInput1) {
            userId = si.Decision__r.OwnerId;
            if(oneTimeExecution){
              textSegment = new ConnectApi.TextSegmentInput();
              textSegment.text = '\n'+postText+'\n\n';
               messageInput.messageSegments.add(textSegment);
               oneTimeExecution=false;
            } else if(userId == null){
                textSegment = new ConnectApi.TextSegmentInput();
                textSegment.text = '\n'+postText+'\n\n';
               messageInput.messageSegments.add(textSegment);
               oneTimeExecution=false;
            }
            if(si.User__c==userId){
                continue;
            }
                //This is for Accountable Collaborator.
           else if(((si.Backup_for_Accountable__c== true &&  si.Informed__c == true ) && ( si.Responsible__c == false && si.Consulted__c == false   ) ) && !si.Is_Group__c && si.Role_Acceptance_Status__c !='Not Accepted'){
                messageInput.messageSegments.add(addMentionSegment(si.User__c));
                textSegment = new ConnectApi.TextSegmentInput();
                textSegment.text ='   '+ '[Backup For Accountable],';
                messageInput.messageSegments.add(textSegment);
            }
                //This is for Responsible Collaborator.
           else if((si.Role__c=='Responsible' || (si.Responsible__c == true && si.Accountable__c == false && si.Consulted__c == false   ) )&& si.Backup_for_Accountable__c== false && !si.Is_Group__c && si.Role_Acceptance_Status__c !='Not Accepted'){
                messageInput.messageSegments.add(addMentionSegment(si.User__c));
                textSegment = new ConnectApi.TextSegmentInput();
                textSegment.text = '  '+'[Responsible],';
                messageInput.messageSegments.add(textSegment);
           } 
           //This is for consulted Collaborator.
           else if((si.Role__c=='Consulted' || (si.Consulted__c == true && si.Accountable__c == false && si.Responsible__c == false  )) && si.Backup_for_Accountable__c== false && !si.Is_Group__c && si.Role_Acceptance_Status__c !='Not Accepted'){
                messageInput.messageSegments.add(addMentionSegment(si.User__c));
                textSegment = new ConnectApi.TextSegmentInput();
                textSegment.text = '  '+'[Consulted],';
                messageInput.messageSegments.add(textSegment);
           } 
           //This is for Bacup Accountable/Responsible/Consulted Collaborator.
            if(si.Backup_for_Accountable__c == true  && si.Responsible__c == true && si.Consulted__c == true && !si.Is_Group__c && si.Role_Acceptance_Status__c !='Not Accepted' ){
                messageInput.messageSegments.add(addMentionSegment(si.User__c));
                textSegment = new ConnectApi.TextSegmentInput();
                textSegment.text = '  '+'[Backup For Accountable][Responsible][Consulted],';
                messageInput.messageSegments.add(textSegment);
           }
           //This is for Backup Accountable/Responsible Collaborator.
            else if(si.Backup_for_Accountable__c== true  && si.Responsible__c == true && si.Consulted__c != true && !si.Is_Group__c && si.Role_Acceptance_Status__c !='Not Accepted' ){
                messageInput.messageSegments.add(addMentionSegment(si.User__c));
                textSegment = new ConnectApi.TextSegmentInput();
                textSegment.text ='  '+'[Backup For Accountable][Responsible],';
                messageInput.messageSegments.add(textSegment);
           }
           //This is for Backup Accountable/Consulted Collaborator.
            else if(si.Backup_for_Accountable__c == true && si.Responsible__c != true && si.Consulted__c == true && !si.Is_Group__c && si.Role_Acceptance_Status__c !='Not Accepted' ){
                messageInput.messageSegments.add(addMentionSegment(si.User__c));
                textSegment = new ConnectApi.TextSegmentInput();
                textSegment.text = '  '+'[Backup For Accountable][Consulted],';
                messageInput.messageSegments.add(textSegment);
           }
           //This is for Responsible/Consulted Collaborator.
            else if((si.Accountable__c != true || si.Backup_for_Accountable__c != true) && si.Responsible__c == true && si.Consulted__c == true && !si.Is_Group__c && si.Role_Acceptance_Status__c !='Not Accepted' ){
                messageInput.messageSegments.add(addMentionSegment(si.User__c));
                textSegment = new ConnectApi.TextSegmentInput();
                textSegment.text = '  '+'[Responsible][Consulted],';
                messageInput.messageSegments.add(textSegment);
           }
        }
        inputcomment.body = messageInput;
        ConnectApi.Comment commentRep = ConnectApi.ChatterFeeds.postComment(null, feedId, inputcomment, null); 
        
        if(!lstSocialInput2.isEmpty()){
            List<Social_Input__c> lstSocialInput3 = new List<Social_Input__c>();
            lstSocialInput3.addAll(lstSocialInput2);
            mentionTextPostForMoreUsers(lstSocialInput3,feedId,userId,postText);
        }
  }
  
   // Call this method fromshare phase for chatter feed. 
     public static id mentionTextPostPropose(Id userId, String postText,Id decisionId) {
        system.debug('--------------Decide Start');
        //Initialize Chatter Connect Api.
        ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
        /** Combine the needed messageSegments into one coherent messageInput**/
        ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
        messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        ConnectApi.TextSegmentInput textSegment;
        messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        Boolean oneTimeExecution= true;
   
        List<Social_Input__c> lstSocialInput = [Select s.Informed__c,s.Decision__r.OwnerId,s.Veto_Rights__c,s.Responsible__c,s.Accountable__c,s.Consulted__c,s.Role_Acceptance_Status__c,s.Is_Group__c,s.User__c, s.Backup_for_Accountable__c,s.Role__c From Social_Input__c s where Decision__c=:decisionId];
        List<Social_Input__c> lstSocialInput1 = new List<Social_Input__c>();
        List<Social_Input__c> lstSocialInput2 = new List<Social_Input__c>();
        if(lstSocialInput.size() > 25){
            for(Integer i = 0 ; i < 24 ; i++){
                lstSocialInput1.add(lstSocialInput[i]);
            }
            for(Integer j = 25; j < lstSocialInput.size() ; j++){
                lstSocialInput2.add(lstSocialInput[j]);
            }
        }
        if(!lstSocialInput1.isEmpty()){
            lstSocialInput.clear();
            lstSocialInput.addAll(lstSocialInput1);
        }
        
        for (Social_Input__c si : lstSocialInput) {
            if(oneTimeExecution){
              textSegment = new ConnectApi.TextSegmentInput();
              textSegment.text = '\n'+postText+'\n';
               messageInput.messageSegments.add(textSegment);
               oneTimeExecution=false;
            }
           if(si.User__c==userId){
                continue;
                }
                //This is for Accountable Collaborator.
           else if(((si.Backup_for_Accountable__c== true &&  si.Informed__c == true ) && ( si.Responsible__c == false && si.Consulted__c == false   ) ) && !si.Is_Group__c && si.Role_Acceptance_Status__c !='Not Accepted'){
                messageInput.messageSegments.add(addMentionSegment(si.User__c));
                textSegment = new ConnectApi.TextSegmentInput();
                if(si.Veto_Rights__c){
                    textSegment.text ='   '+ '[Backup For Accountable][Veto],';
                }else{
                 textSegment.text ='   '+ '[Backup For Accountable],';
                }
                messageInput.messageSegments.add(textSegment);
            }
                //This is for Responsible Collaborator.
           else if((si.Role__c=='Responsible' || (si.Responsible__c == true && si.Accountable__c == false && si.Consulted__c == false   ) )&& si.Backup_for_Accountable__c== false && !si.Is_Group__c && si.Role_Acceptance_Status__c !='Not Accepted'){
                messageInput.messageSegments.add(addMentionSegment(si.User__c));
                textSegment = new ConnectApi.TextSegmentInput();
                if(si.Veto_Rights__c){
                    textSegment.text = '  '+'[Responsible][Veto],';
                }else{
                    textSegment.text = '  '+'[Responsible],';
                }
                messageInput.messageSegments.add(textSegment);
           } 
           //This is for consulted Collaborator.
           else if((si.Role__c=='Consulted' || (si.Consulted__c == true && si.Accountable__c == false && si.Responsible__c == false  )) && si.Backup_for_Accountable__c== false && !si.Is_Group__c && si.Role_Acceptance_Status__c !='Not Accepted'){
                messageInput.messageSegments.add(addMentionSegment(si.User__c));
                textSegment = new ConnectApi.TextSegmentInput();
                 if(si.Veto_Rights__c){
                    textSegment.text = '  '+'[Consulted][Veto],';
                 }else{
                    textSegment.text = '  '+'[Consulted],';
                 }
                messageInput.messageSegments.add(textSegment);
           } 
           //This is for Bacup Accountable/Responsible/Consulted Collaborator.
            if(si.Backup_for_Accountable__c == true  && si.Responsible__c == true && si.Consulted__c == true && !si.Is_Group__c && si.Role_Acceptance_Status__c !='Not Accepted' ){
                messageInput.messageSegments.add(addMentionSegment(si.User__c));
                textSegment = new ConnectApi.TextSegmentInput();
                if(si.Veto_Rights__c){
                    textSegment.text = '  '+'[Backup For Accountable][Responsible][Consulted][Veto],';
                }else{
                     textSegment.text = '  '+'[Backup For Accountable][Responsible][Consulted],';
                } 
                messageInput.messageSegments.add(textSegment);
           }
           //This is for Backup Accountable/Responsible Collaborator.
            else if(si.Backup_for_Accountable__c== true  && si.Responsible__c == true && si.Consulted__c != true && !si.Is_Group__c && si.Role_Acceptance_Status__c !='Not Accepted' ){
                messageInput.messageSegments.add(addMentionSegment(si.User__c));
                textSegment = new ConnectApi.TextSegmentInput();
                if(si.Veto_Rights__c){
                    textSegment.text = '  '+'[Backup For Accountable][Responsible][Veto],';
                }else{
                    textSegment.text ='  '+'[Backup For Accountable][Responsible],';
                }
                messageInput.messageSegments.add(textSegment);
           }
           //This is for Backup Accountable/Consulted Collaborator.
            else if(si.Backup_for_Accountable__c == true && si.Responsible__c != true && si.Consulted__c == true && !si.Is_Group__c && si.Role_Acceptance_Status__c !='Not Accepted' ){
                messageInput.messageSegments.add(addMentionSegment(si.User__c));
                textSegment = new ConnectApi.TextSegmentInput();
                if(si.Veto_Rights__c){
                    textSegment.text = '  '+'[Backup For Accountable][Consulted][Veto],';
                }else{
                 textSegment.text = '  '+'[Backup For Accountable][Consulted],';
                } 
                messageInput.messageSegments.add(textSegment);
           }
           //This is for Responsible/Consulted Collaborator.
            else if((si.Accountable__c != true || si.Backup_for_Accountable__c != true) && si.Responsible__c == true && si.Consulted__c == true && !si.Is_Group__c && si.Role_Acceptance_Status__c !='Not Accepted' ){
                messageInput.messageSegments.add(addMentionSegment(si.User__c));
                textSegment = new ConnectApi.TextSegmentInput();
                if(si.Veto_Rights__c){
                    textSegment.text = '  '+'[Responsible][Consulted][Veto],';
                }else{
                    textSegment.text = '  '+'[Responsible][Consulted],';
                }
                messageInput.messageSegments.add(textSegment);
           }
           
         /*  else if((si.Role__c=='Informed'|| si.Backup_for_Accountable__c== true) && !si.Is_Group__c ){
                messageInput.messageSegments.add(addMentionSegment(si.User__c));
                textSegment = new ConnectApi.TextSegmentInput();
                textSegment.text = '[Informed],';
                messageInput.messageSegments.add(textSegment);
           } */
        }       
     // add the text that was passed
      input.body = messageInput;
    // post it
    
    ConnectApi.FeedItem fi = ConnectApi.ChatterFeeds.postFeedItem(null, ConnectApi.FeedType.Record, decisionId, input, null);
    System.debug('fifififififififififififififififififififi'+fi);
    Decision__c decisionRec = [Select id,Phase__c,SYS_From_Quick_Decision__c from Decision__c where id=:decisionId ] ;
    System.debug('----------------------------> Debug'+ decisionRec.Phase__c);
    if(decisionRec.Phase__c=='Propose'){
         Decision__c decision = new Decision__c(id = decisionId,FeedItem_Id_Propose__c = fi.Id );
         if(FLS.decisionUpdateable()){
             try{
             	update decision;
             }catch(Exception e){
             	FutureMethodController.ProposefeedIdUpdateOnDecision(decisionId,fi.Id);
             } 
         }
    }
    else if(decisionRec.Phase__c=='Execute'){
        
         Decision__c decision = new Decision__c(id = decisionId,FeedItem_Id_Execute__c= fi.Id );
         update decision;
    }else if(decisionRec.Phase__c=='Evaluate'){
        
         Decision__c decision = new Decision__c(id = decisionId,FeedItem_Id_Evaluate__c = fi.Id );
         update decision;
    }  
     else if(decisionRec.Phase__c=='Share'){
        
         Decision__c decision = new Decision__c(id = decisionId,FeedItem_Id__c = fi.Id );
         update decision;
    } 
    else if(decisionRec.Phase__c=='Decide' && decisionRec.SYS_From_Quick_Decision__c==true ){
        // system.debug('--------------Decide Start');
         Decision__c decision = new Decision__c(id = decisionId,FeedItem_Id_Propose__c  = fi.Id );
         if(FLS.decisionUpdateable()){
             try{
             	update decision;
             }catch(Exception e){
             	FutureMethodController.ProposefeedIdUpdateOnDecision(decisionId,fi.Id);
             } 
         }
    } 
    
    if(!lstSocialInput2.isEmpty()){
        mentionTextPostForMoreUsers(lstSocialInput2,fi.Id,userId,postText);
    }
    
    return fi.Id;
    //update decision;
             
    //System.debug('----------decision.Due_Date__c------->'+decision.Due_Date__c);   
  }  
     
    
    // to delete notes and attachment  records
    @RemoteAction
    public static string deleteNotesAttachments(String decisionId, String attchmentId, String attamentType){
        /*
        if(attamentType == 'Attachment') {
            if (FLS.attachmentUpdateable()){
                Attachment attachment = [select id from Attachment where Id =: attchmentId];
                attachment.Name = 'ToBeDeletedCustomAttachment';
                update  attachment;
            }
        }
        else {
            if(Note.sObjectType.getDescribe().isDeletable()) {
                delete [select id from Note where Id =: attchmentId];
            }
        }
        */
        return attachmentNoteView(decisionId);
    }
    
    // Action Function for Intelligent Table
    
    @RemoteAction 
    public static String upateTimingTab(String phasesId, String plannedStartDate, String plannedEndDate, String comments ) {
        
        // String to date time base on user locale
        Timing__c toBeUpdatedTiming = [Select t.Id, t.Actual_End_Date__c, t.Actual_Start_Date__c, t.Start_Date_Time__c, t.Stage__c, t.Related_To_ID__c, t.End_Date_Time__c, t.Elapsed_Time__c, t.Difference__c, t.Comments__c From Timing__c t where t.Id = : phasesId];
        
        DateTime currentEnteredSmallDate;
        Boolean checkForStartDate = false;
        System.debug('------plannedStartDate-----------------'+plannedStartDate+'-----'+plannedEndDate);        
        if(plannedStartDate != null && plannedStartDate != '' && !plannedStartDate.contains('NaN') && plannedStartDate!= 'null' && plannedStartDate.contains(',')) {
            List<String> partStart=  plannedStartDate.split(',');
            //toBeUpdatedTiming.Start_Date_Time__c  = DateTime.parse(plannedStartDate);
            toBeUpdatedTiming.Start_Date_Time__c  = DateTime.valueOf(partStart[0] + '-' + partStart[1] + '-' + partStart[2] + ' ' + partStart[3] + ':' + partStart[4] +  ':' + partStart[5]);
            currentEnteredSmallDate = DateTime.valueOf(partStart[0] + '-' + partStart[1] + '-' + partStart[2] + ' ' + partStart[3] + ':' + partStart[4] +  ':' + partStart[5]);
            checkForStartDate = true;
        }
        else {
            if(plannedStartDate == null || plannedStartDate == '' || plannedStartDate == 'null') {    
                toBeUpdatedTiming.Start_Date_Time__c = null;
            }
        }
        if(plannedEndDate != null && plannedEndDate != '' && !plannedEndDate.contains('NaN') && plannedEndDate!= 'null' && plannedEndDate.contains(',')) {
            List<String> partEnd=  plannedEndDate.split(',');
            //toBeUpdatedTiming.End_Date_Time__c = DateTime.parse(plannedEndDate);
            toBeUpdatedTiming.End_Date_Time__c = DateTime.valueOf(partEnd[0] + '-' + partEnd[1] + '-' + partEnd[2] + ' ' + partEnd[3] + ':' + partEnd[4] +  ':' + partEnd[5]);
            if(!checkForStartDate){
                currentEnteredSmallDate = DateTime.valueOf(partEnd[0] + '-' + partEnd[1] + '-' + partEnd[2] + ' ' + partEnd[3] + ':' + partEnd[4] +  ':' + partEnd[5]);
                System.debug('-------Nearest Due Date-------hello---------'+DateTime.valueOf(partEnd[0] + '-' + partEnd[1] + '-' + partEnd[2] + ' ' + partEnd[3] + ':' + partEnd[4] +  ':' + partEnd[5]));
            }
        }
        else {
            if(plannedEndDate == null || plannedEndDate == '' || plannedEndDate == 'null') {
                toBeUpdatedTiming.End_Date_Time__c = null;
            }
        }
        if(!comments.contains('~NaN~')){
            toBeUpdatedTiming.Comments__c = comments;
        }
        System.debug('-------Nearest Due Date----------------'+currentEnteredSmallDate);
        
        if(FLS.timingUpdateable()) {
            update toBeUpdatedTiming;
        }
        
        String currentDecisionId ;
        
        if(toBeUpdatedTiming.Stage__c == 'Propose') {
            Decision__c decision = [Select  d.Valid_Until__c, d.Valid_From__c,d.Nearest_Due_Date__c, d.Title__c, d.Tag__c, d.SystemModstamp, d.Status__c, d.SYS_From_Quick_Decision__c, d.Reason_for_Close__c, d.Problem_Idea_Advice__c, d.Private__c, d.Priority__c, d.Point_of_No_Return__c, d.Phase__c, d.Parent_Decision__c, d.OwnerId, d.Name, d.LastModifiedDate, d.LastModifiedById, d.LastActivityDate, d.IsDeleted, d.Id, d.Estimated_People_Involved__c, d.Estimated_Net_Present_Value__c, d.Estimated_Investment__c, d.Estimated_Full_time_Equivalent_FTE__c, d.Estimated_Direct_Cost__c, d.Due_Date__c, d.Decision_Taken__c, d.Decision_Type__c, d.Decision_Making_Style__c, d.Decision_Approach__c, d.Category__c, d.CreatedDate, d.CreatedById, d.Comments__c, d.Approved_when_Created__c, d.Add_C_I_Members__c, d.Actual_People_Involved__c, d.Actual_Net_Present_Value__c, d.Actual_Investment__c, d.Actual_Full_time_Equivalent_FTE__c, d.Actual_Direct_Cost__c, d.Accountable__c, d.Estimated_Revenue__c, d.Estimated_Revenue_Desc__c, d.Actual_Revenue__c, d.Actual_Revenue_Desc__c From Decision__c d where d.Id =: toBeUpdatedTiming.Related_To_ID__c];
            System.debug('------decision.Nearest_Due_Date__c--------------'+decision.Nearest_Due_Date__c + '--------------currentEnteredSmallDate--------'+currentEnteredSmallDate);
            //if(decision.Nearest_Due_Date__c == null || (currentEnteredSmallDate != null && decision.Nearest_Due_Date__c > currentEnteredSmallDate)){
                //decision.Nearest_Due_Date__c = currentEnteredSmallDate;
            //}
            decision.Due_Date__c = toBeUpdatedTiming.End_Date_Time__c;
            currentDecisionId = string.valueOf(decision.id);
            if(FLS.decisionUpdateable()) {
                update decision;
            }
            
        }else{
            currentDecisionId = string.valueOf(toBeUpdatedTiming.Related_To_ID__c); 
        }
        
        UpdateNearestDueDate.updateAllDeicisons(currentDecisionId); 
        return timingTab(toBeUpdatedTiming.Related_To_ID__c);
    }
    
    // End Action Function
    
    // old task event method
    // Activity of task and event Tab
    public static String activitiesTab(String decisionId, String tobeDeletedActivitiesId) {
        return null;
    }
    
    // Activity of task and event Tab
    @RemoteAction 
    public static JsonExistingData activitiesTabWithSearch(String decisionId, String tobeDeletedActivitiesId,string searchText) {
        
        //GeneralInformation genralInfo  = new GeneralInformation();
        // initialize General information class to get user locale date format and image static resouce url
        if(genralInfo == null ) {
            genralInfo  = new GeneralInformation();
        }
        
        walkmeTaskVar = false;
        
        dateTimeFormat = genralInfo.MapValuesDateTime();
        dateFormat = genralInfo.MapValuesDateFormate();
        
        // Delete task or event record
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
        
        //List<ActivitiesTaskEvent> activitiesTaskEventList = new List<ActivitiesTaskEvent>();
        List<ActivitiesTaskEvent> taskEventList = new List<ActivitiesTaskEvent>();
        
        //Social_Input__c loggedInSocialPeople = new Social_Input__c();
        if(loggedInSocialPeople == null) {
            loggedInSocialPeople = new Social_Input__c();
            if([select id  from Social_Input__c where User__c =: userInfo.getUserId() AND Decision__c =: decisionId].size() > 0 ) {
                loggedInSocialPeople = [Select s.Veto_Rights__c, s.User__c, s.SystemModstamp,s.Stance_Approval_Status__c, s.Select_People__c, s.SYS_Tab_View_Tasks__c, s.SYS_Tab_View_Social_Input__c, s.SYS_Tab_View_Relations__c, s.SYS_Tab_View_Quality__c, s.SYS_Tab_View_History__c, s.SYS_Tab_View_Attachments__c, s.SYS_Tab_View_Approvals__c, s.SYS_Tab_View_Activites__c, s.Role__c, s.Role_Acceptance_Status__c, s.Role_Acceptance_Required__c, s.Result__c, s.Responsible__c, s.Rating__c, s.Plan__c, s.OwnerId, s.Outcome__c, s.Name_of_the_User__c, s.Name, s.Mood__c, s.Like__c, s.LastModifiedDate, s.LastModifiedById, s.Is_Group__c, s.IsDeleted, s.Informed__c, s.Id, s.Group_Name__c, s.GroupId__c, s.Final_Approval_Status__c, s.Effort__c, s.Dislike__c, s.Description__c, s.Decision__c, s.CreatedDate, s.CreatedById, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c, s.Accountable__c From Social_Input__c s where User__c =: userInfo.getUserId() AND Decision__c =: decisionId limit 1 ];
            }
        }
           
      /*  if(profile == null) { 
            profile = new Profile();  
            profile =[Select Name From Profile where Name=: 'System Administrator' limit 1];
        }*/
        
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
        
        // To replace * with % in searh area.
        if(searchText != ''){
            if(searchText.contains('*')){
                String SearchtextList=searchText.replaceAll('\\*','\\%');
                searchText = SearchtextList;
            }
        }
        
        List<UserRecordAccess> listUserRecordAccess = [SELECT RecordId, HasReadAccess, HasEditAccess, HasDeleteAccess,MaxAccessLevel FROM UserRecordAccess WHERE UserId=:UserInfo.getUserId() AND RecordId =: decisionId limit 1];
              
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
        
        List<Task> taskActivityList = new List<Task>();
        
        if(searchText != ''){
            searchText = '%'+searchText+'%';
            taskActivityList = [select Id,WhatId,OwnerId, CreatedById,Owner.Name ,ActivityDate,Status,IsClosed,Priority,Subject,Description from Task where whatId=:decisionId and subject like : searchText ORDER BY CreatedDate DESC ];
        }else{
            taskActivityList = [select Id,WhatId,OwnerId, CreatedById,Owner.Name ,ActivityDate,Status,IsClosed,Priority,Subject,Description from Task where whatId=:decisionId ORDER BY CreatedDate DESC ];
        }
        
        Integer taskEventRecordNumber = 1;
        
        for(Task task: taskActivityList ){
            ActivitiesTaskEvent act = new ActivitiesTaskEvent();
            act.recordNumber = taskEventRecordNumber++;
            act.id = task.Id;
            act.subject = task.Subject.capitalize();
            act.isTask = 'Task';
            act.ownerId = task.OwnerId;
            System.debug('---------task.ActivityDate------------>'+task.ActivityDate);
            //act.duedate = task.ActivityDate == null ? '' : genralInfo.MapValuesDate(String.valueOf(task.ActivityDate.day()), String.valueOf(task.ActivityDate.month()), String.valueOf(task.ActivityDate.year()));
            act.duedate = task.ActivityDate == null ? '' : task.ActivityDate.format();
           // act.duedate = String.valueOf(task.ActivityDate);
            System.debug('---------act.duedate------------>'+act.duedate);
            act.delayTaskClass = task.ActivityDate < date.today() && !task.IsClosed ? 'delayTask' : task.ActivityDate == null ? 'emptyDuedate' : '';
            act.priority = taskpriority.get(task.Priority) == null ?  task.Priority: taskpriority.get(task.Priority);
            act.createdByName = task.Owner.Name;
            act.createdByImage = genralInfo.useImage.get(task.OwnerId);
            act.isTaskImage = genralInfo.imageUrlMap.get('checked');
            act.comments = task.Description == null ? '' : task.Description.replaceAll('\"','\'');
            act.commentsImage = task.Description == null ? genralInfo.imageUrlMap.get('') : genralInfo.imageUrlMap.get('chat');
            act.isDeletable= false;
            act.isEditable = false; 
            act.actionClassNameEdit = 'grid-action-disabled';
            act.actionClassNameDelete = 'grid-action-disabled';
            act.roleAcceptanceStatus = loggedInSocialPeople.Role_Acceptance_Status__c;
            act.title = '';
            act.imgEditTitle = '';
            act.imgDeleteTitle = '';
            act.isSelected = false;
            act.toDisable = '';
            /*if(loggedInSocialPeople.Accountable__c || loggedInSocialPeople.Backup_for_Accountable__c || Userinfo.getProfileId() == profile.Id  || (loggedInSocialPeople.Responsible__c && userInfo.getUserId() == task.OwnerId) ) {
                act.isDeletable =  true;
                act.isEditable = true;
                act.actionClassName = '';
            }*/
            
            // The below condition is deprecated as the responsible person can also edit all tasks
            //if(((loggedInSocialPeople.Responsible__c) && ((Userinfo.getuserId() == task.CreatedById) || (Userinfo.getuserId() == task.OwnerId))) || (Userinfo.getuserId() == task.OwnerId) || ((Userinfo.getProfileId() == profile.Id || loggedInSocialPeople.Accountable__c || (loggedInSocialPeople.Backup_for_Accountable__c && loggedInSocialPeople.Role_Acceptance_Status__c == 'Approved/Accepted')))) {
            //Conditions for editing permissions for Accountable, backup and Responisable when the role is accepted for all task.
            if((Userinfo.getuserId() == task.OwnerId) || ((chkRecPermission == true || loggedInSocialPeople.Accountable__c || (loggedInSocialPeople.Backup_for_Accountable__c && loggedInSocialPeople.Role_Acceptance_Status__c == 'Approved/Accepted') || (loggedInSocialPeople.Responsible__c && loggedInSocialPeople.Role_Acceptance_Status__c == 'Approved/Accepted')))) {    
                act.imgEditTitle = 'Edit';
                act.isEditable = true;
                act.actionClassNameEdit = '';
            } else {
                act.toDisable = 'disabled';
            }
            
            if(!task.IsClosed && task.OwnerId == userinfo.getuserId()){
                walkmeTaskVar = true;
            }
            
            if(Userinfo.getuserId() == task.OwnerId || chkRecPermission == true || loggedInSocialPeople.Accountable__c) {
                act.imgDeleteTitle = 'Delete';
                act.isDeletable =  true;
                act.actionClassNameDelete = '';
            } 
            // Conditions to display edit tooltip on hover of task if the task is editable for Accountable Responsible and Backup and also if the role is accepetd
            if(loggedInSocialPeople.Accountable__c || (loggedInSocialPeople.Backup_for_Accountable__c && loggedInSocialPeople.Role_Acceptance_Status__c == 'Approved/Accepted') || (loggedInSocialPeople.Responsible__c && loggedInSocialPeople.Role_Acceptance_Status__c == 'Approved/Accepted')){
                act.title = 'Edit';
            }
            
            act.subjectClass = act.isEditable == true ? 'hide-subject' : '' ;
            act.subjectClassLink = act.isEditable == true ? '' : 'hide-subject' ;
            act.url = '/'+act.Id+'?retURL='+task.WhatId; //act.isEditable ? '/'+act.Id+'?retURL='+task.WhatId : 'javascript:void(0)';
            act.editImage = genralInfo.editImage.get(act.isEditable);
            act.deleteImage = genralInfo.deleteImage.get(act.isDeletable);
            act.Status = taskstatus.get(task.Status) == null ? task.Status : taskstatus.get(task.Status) ;
            act.statusImage = genralInfo.imageUrlMap.get(act.status);
            // added on 2014-04-25
            act.duedateSort = task.ActivityDate != null? task.ActivityDate :null;
            // added on 2014-04-25
           // if(task.Status=='Completed') {
           //     activitiesTaskEventList.add(act);
           //  }
           //  else {
                taskEventList.add(act);
           // }
        }
        
        List<Event> eventActivityList = new List<Event>();
        
        if(searchText != ''){
            searchText = searchText+'%';
            eventActivityList = [select id,EndDateTime,WhatId,OwnerId,Owner.Name,CreatedById,ActivityDate,ActivityDateTime,Subject,Description from Event where whatId=:decisionId and subject like : searchText ORDER BY CreatedDate DESC ] ;
        }else{
            eventActivityList = [select id,EndDateTime,WhatId,OwnerId,Owner.Name,CreatedById,ActivityDate,ActivityDateTime,Subject,Description from Event where whatId=:decisionId ORDER BY CreatedDate DESC ] ;
        }
        
        for(Event event : eventActivityList){
            ActivitiesTaskEvent act = new ActivitiesTaskEvent();
            act.recordNumber = taskEventRecordNumber++;
            act.id = event.Id;
            act.subject = event.Subject.capitalize();
            act.isTask = 'Event';
            //act.duedate = event.ActivityDateTime == null ? '' : event.ActivityDateTime.format(dateTimeFormat);
            //act.duedate = String.valueOf(event.ActivityDateTime);
            act.duedate = event.ActivityDate != null ? event.ActivityDate.format() : '';
            act.createdByName = event.Owner.Name;
            act.createdByImage = genralInfo.useImage.get(event.OwnerId);
            act.isTaskImage = genralInfo.imageUrlMap.get('unchecked');
            act.comments = event.Description == null ? '' : event.Description.replaceAll('\"','\'');
            act.commentsImage = event.Description == null ? genralInfo.imageUrlMap.get('') : genralInfo.imageUrlMap.get('chat');
            act.isDeletable= false;
            act.isEditable = false;
            act.ownerId = event.OwnerId;
            act.actionClassNameEdit = 'grid-action-disabled';
            act.actionClassNameDelete = 'grid-action-disabled';
            act.title = '';
            act.imgEditTitle = '';
            act.imgDeleteTitle = '';
            act.isSelected = false;
            act.toDisable = 'disabled';
            /*if(loggedInSocialPeople.Accountable__c || loggedInSocialPeople.Backup_for_Accountable__c || Userinfo.getProfileId() == profile.Id || (loggedInSocialPeople.Responsible__c && userInfo.getUserId() == event.OwnerId)) {
                act.isDeletable =  true;
                act.isEditable = true;
                act.actionClassName = '';
            }*/
            
            if(((loggedInSocialPeople.Responsible__c || loggedInSocialPeople.Backup_for_Accountable__c || loggedInSocialPeople.Veto_Rights__c ) && ((Userinfo.getuserId() == event.CreatedById) || (Userinfo.getuserId() == event.OwnerId))) || (Userinfo.getuserId() == event.OwnerId) || ((chkRecPermission == true || loggedInSocialPeople.Accountable__c))) {
                act.imgEditTitle = 'Edit';
                act.imgDeleteTitle = 'Delete';
                act.isDeletable =  true;
                act.isEditable = true;
                act.actionClassNameEdit = '';
                act.actionClassNameDelete = ''; 
            }
            
            act.subjectClass = act.isEditable == true ? 'hide-subject' : '' ;
            act.subjectClassLink = act.isEditable == true ? '' : 'hide-subject' ;
            act.url = act.isEditable ? '/'+act.Id+'?retURL='+event.WhatId  : 'javascript:void(0)';
            act.editImage = genralInfo.editImage.get(act.isEditable);
            act.deleteImage = genralInfo.deleteImage.get(act.isDeletable);
            act.status = '';
            act.priority = '';
            act.statusImage = genralInfo.imageUrlMap.get('null');
            
            if(loggedInSocialPeople.Accountable__c || (loggedInSocialPeople.Backup_for_Accountable__c && loggedInSocialPeople.Role_Acceptance_Status__c == 'Approved/Accepted')){
                act.title = 'Edit';
            }
            act.duedateSort = event.ActivityDate != null ? event.ActivityDate : null;
           // if(event.ActivityDate < date.today()) {
           //    activitiesTaskEventList.add(act);
           // }
           // else {
                taskEventList.add(act);
            //}
        }
        
        //activitiesTaskEventJson = JSON.serialize(activitiesTaskEventList);
        taskEventJson = JSON.serialize(taskEventList);
        
        JsonExistingData jsonExistingData = new JsonExistingData();
        jsonExistingData.taskEvent = taskEventJson;
        //jsonExistingData.activitiesTaskEvent = activitiesTaskEventJson;
        return jsonExistingData;
    
    }
    
    //
     @RemoteAction
     public static JsonExistingData massDeleteTaskRecords(String selectedTasks,String decisionId,String searchText){
        System.debug('---------searchText--------->'+searchText);
        List<String> lstTaskIds = selectedTasks != null ? selectedTasks.split(',') : new List<String>();
        if(!lstTaskIds.isEmpty()){
             if(Task.sObjectType.getDescribe().isDeletable()) { 
                delete [select id from Task where Id In : lstTaskIds];
             }
        }
        
        JsonExistingData jed = new JsonExistingData();
        jed = activitiesTabWithSearch(decisionId,'',searchText);
        System.debug('---------jed--------->'+jed);
        return jed;
     }
    
     //
     @RemoteAction
     public static JsonExistingData massEditTaskRecords(String selectedTasks,String decisionId,String searchText,String assignedTo,String updateDuedate,String updateStatus,String updatePriority){
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
        jed = activitiesTabWithSearch(decisionId,'',searchText);
        System.debug('---------jed--------->'+jed);
        return jed;
     }
    
     // Decision relationship tab 
    @RemoteAction
    public static string viewAllRelationships(String decisionId, String tobeDeletedRelationshipId){
        
        //GeneralInformation genralInfo  = new GeneralInformation();
        if(genralInfo == null ) {
            genralInfo  = new GeneralInformation();
        }
        
        if(tobeDeletedRelationshipId != null && tobeDeletedRelationshipId != '') {
            Relations__c toBeDeleteRelationship = [select id From Relations__c  where Id =: tobeDeletedRelationshipId ];
            if (Relations__c.sObjectType.getDescribe().isDeletable()){
                delete toBeDeleteRelationship;
            }
        }
        
        //Social_Input__c loggedInSocialPeople = new Social_Input__c();
        if(loggedInSocialPeople == null) {
            loggedInSocialPeople = new Social_Input__c();
            if([select id  from Social_Input__c where User__c =: userInfo.getUserId() AND Decision__c =: decisionId].size() > 0 ) {
                loggedInSocialPeople = [Select s.Veto_Rights__c, s.User__c, s.SystemModstamp,s.Stance_Approval_Status__c, s.Select_People__c, s.SYS_Tab_View_Tasks__c, s.SYS_Tab_View_Social_Input__c, s.SYS_Tab_View_Relations__c, s.SYS_Tab_View_Quality__c, s.SYS_Tab_View_History__c, s.SYS_Tab_View_Attachments__c, s.SYS_Tab_View_Approvals__c, s.SYS_Tab_View_Activites__c, s.Role__c, s.Role_Acceptance_Status__c, s.Role_Acceptance_Required__c, s.Result__c, s.Responsible__c, s.Rating__c, s.Plan__c, s.OwnerId, s.Outcome__c, s.Name_of_the_User__c, s.Name, s.Mood__c, s.Like__c, s.LastModifiedDate, s.LastModifiedById, s.Is_Group__c, s.IsDeleted, s.Informed__c, s.Id, s.Group_Name__c, s.GroupId__c, s.Final_Approval_Status__c, s.Effort__c, s.Dislike__c, s.Description__c, s.Decision__c, s.CreatedDate, s.CreatedById, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c, s.Accountable__c From Social_Input__c s where User__c =: userInfo.getUserId() AND Decision__c =: decisionId limit 1 ];
            }
        }
           
        List<UserRecordAccess> listUserRecordAccess = [SELECT RecordId, HasReadAccess, HasEditAccess, HasDeleteAccess,MaxAccessLevel FROM UserRecordAccess WHERE UserId=:UserInfo.getUserId() AND RecordId =: decisionId limit 1];
              
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
        
        List<Relationship> relationshipList = new List<Relationship>(); 
        for(Relations__c r : [Select r.OwnerId, r.id, r.Type__c, r.Strength__c, r.From_Relation__c, r.Parent_Record_Name__c, r.Parent_Object_Name__c, r.Parent_ID__c, r.Notes__c, r.To_Relation__c, r.Child_Record_Name__c, r.Child_Object_Name__c, r.Child_ID__c From Relations__c r where ( r.Parent_ID__c =: decisionId or  r.Child_ID__c =: decisionId ) ORDER BY r.CreatedDate DESC NULLS LAST]){
            Relationship rel = new Relationship();
            rel.id = r.id;
            if(r.Child_Object_Name__c != 'User'){   
                rel.recordId = r.Parent_ID__c == decisionId ? r.Child_ID__c : r.Parent_ID__c;
            } else {
                rel.recordId = r.Parent_ID__c == decisionId ? r.Child_ID__c : r.Parent_ID__c;
                rel.recordId = rel.recordId+'?noredirect=1';
            }
            rel.recordName = r.Parent_ID__c == decisionId ? (r.Child_Record_Name__c != null ? r.Child_Record_Name__c : '') : (r.Parent_Record_Name__c != null ? r.Parent_Record_Name__c : '');
            rel.objectName = r.Parent_ID__c == decisionId ? r.Child_Object_Name__c : r.Parent_Object_Name__c;
            rel.relation = r.Parent_ID__c == decisionId ?  (r.From_Relation__c != null ? r.From_Relation__c : '') : (r.To_Relation__c != null ? r.To_Relation__c : '');
            rel.strength = r.Strength__c == null ? '' : r.Strength__c;
            rel.notes = r.Notes__c == null  ? '' : r.Notes__c ;
            string relatedToId = r.Parent_ID__c == decisionId? r.Parent_ID__c : r.Child_ID__c;
            string Type = r.Parent_ID__c == decisionId ? '1' : '2';
            rel.isDeletable= false;
            rel.isEditable = false; 
            rel.actionClassName = 'grid-action-disabled';
            
            if(loggedInSocialPeople.Accountable__c    || loggedInSocialPeople.Backup_for_Accountable__c || chkRecPermission == true  || (loggedInSocialPeople.Responsible__c && userInfo.getUserId() == r.OwnerId)) {
                rel.isDeletable =  true;
                rel.isEditable = true;
                rel.actionClassName = '';
            }
            
            rel.url = rel.isEditable ? '/apex/editRelationship?id='+relatedToId+'&relId='+r.id+'&type='+Type+'&relPlan=false' : 'javascript:void(0)';
            //rel.url = rel.isEditable ? '/'+rel.Id+'' : 'javascript:void(0)';
            rel.editImage = genralInfo.editImage.get(rel.isEditable);
            rel.deleteImage = genralInfo.deleteImage.get(rel.isDeletable);
            relationshipList.add(rel);
        }    
        relationshipJson = JSON.serialize(relationshipList);
        return relationshipJson;
    }
    
    
    // Decision History tab 
     @RemoteAction
     public static String viewHistory(String decisionId) {
        
        //GeneralInformation genralInfo  = new GeneralInformation();
        
        if(genralInfo == null ) {
            genralInfo  = new GeneralInformation();
        }
        
        dateTimeFormat = genralInfo.MapValuesDateTime();
        
        List<CommonHistory> commonHistoryList = new List<CommonHistory>();
        for(Task tt: [select id,WhatId,OwnerId, Owner.Name ,ActivityDate,Status,Priority,Subject,Description from Task where whatId=:decisionId and Status=:'completed' ] ){
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
            // added on 25-04-2014
            chTask.duedateSort =tt.ActivityDate!=null?tt.ActivityDate:null;
            // added on 25-04-2014
            commonHistoryList.add(chTask);
            //
        }
        
        for(Event ee: [select id,WhatId,OwnerId,Owner.Firstname,Owner.Lastname,ActivityDate,ActivityDateTime,Subject,Description from Event where whatId=:decisionId and ActivityDate < Today ]){
             // for generating list of 'History Tab' (Event)
            CommonHistory chEvent = new CommonHistory();
            
            chEvent.chDateTime = ee.ActivityDateTime;
            chEvent.duedate = ee.ActivityDateTime.format();
            chEvent.assignedTo = ee.Owner.Firstname + ee.Owner.Lastname;
            chEvent.assignedToId = genralInfo.useImage.get(ee.OwnerId);
            chEvent.comments = ee.Description == null ? '' : ee.Description;
            chEvent.relatedTo = 'Event';
            // added on 25-04-2014
            chEvent.duedateSort =ee.ActivityDateTime!=null?ee.ActivityDateTime:null;
            // added on 25-04-2014
            commonHistoryList.add(chEvent);
            
        }
        List<Social_Input__c>  socialInputList = [select id  from Social_Input__c where  Decision__c =: decisionId];
        set<Id> socialInputId = new set<Id>();
        for(Social_Input__c s: socialInputList) {
            socialInputId.add(s.Id);
        }
        List<ProcessInstance> processInstanceList = [Select (Select Id, IsPending, ProcessInstanceId, StepStatus, OriginalActorId, ActorId,Actor.Name,OriginalActor.Name, RemindersSent, Comments, CreatedDate, CreatedById From StepsAndWorkitems Order By CreatedDate) hs , TargetObjectId  From ProcessInstance p where TargetObjectId In: socialInputId];
        for(ProcessInstance p: processInstanceList ) {
            List<ProcessInstanceHistory> phiList = new List<ProcessInstanceHistory>();
            phiList = p.StepsAndWorkitems;
            for(ProcessInstanceHistory pi : phiList ) {
             
               
                if(pi.StepStatus != 'Started' ){
                      System.debug('--------TTT-----'+ pi.Comments);
                    commonHistory ah = new commonHistory();
                    ah.relatedTo = 'Approval / Acceptance';
                    ah.chDateTime = pi.CreatedDate;
                    ah.duedate = pi.CreatedDate.format(); 
                    ah.status = pi.StepStatus;
                    ah.assignedTo = pi.Actor.Name;
                    ah.assignedToId = genralInfo.useImage.get(pi.Actor.Id);
                    ah.comments = pi.Comments == null ? '' : pi.Comments ;
                    // added on 25-04-2014
                    ah.duedateSort = pi.CreatedDate!=null? pi.CreatedDate:null;
                    // added on 25-04-2014
                    commonHistoryList.add(ah);
                }
            }
        }
        
        Decision__c decision = [select id, Name, Phase__c, Status__c from Decision__c where Id =: decisionId];
        
        
        List<Decision__History> decisionHistoryList= [select CreatedDate from Decision__History where ParentId = :decision.Id ];
        
        // call history class to get history data
        GenerlHistoryComponent gh = new GenerlHistoryComponent();
        List<GenerlHistoryComponent.objectHistoryLine> obhLineList = new List<GenerlHistoryComponent.objectHistoryLine>();
        gh.myObject = Schema.getGlobalDescribe().get('Decision__c').newSObject();
        gh.myObjectId = decisionId;
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
            // added on 25-04-2014
            ch.duedateSort = historyDecision.theDate!=null? historyDecision.theDate:null;
            // added on 25-04-2014
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
    
    // Creates a collaborator JSON string. This method is updated with search feature for peoples tab.
    @RemoteAction
    public static String viewSocialPeopleTabWithSearch(String decisionId, String tobeDeletedPeopleId, String searchPhrase){
        // Query for current login user max record permission
           List<UserRecordAccess>  listUserRecordAccess = [SELECT RecordId, HasReadAccess, HasEditAccess, HasDeleteAccess,MaxAccessLevel FROM UserRecordAccess WHERE UserId=:UserInfo.getUserId() AND RecordId =:decisionId limit 1];
                system.debug('============listUserRecordAccess==========='+listUserRecordAccess);
             
              if(listUserRecordAccess.size() > 0 && listUserRecordAccess[0].MaxAccessLevel=='All'  ){
                
                    //User usr = [SELECT ProfileId FROM User where id=:UserInfo.getUserId() Limit 1];
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
         
        // initialize General information class to get user locale date format and image static resouce url
        //GeneralInformation genralInfo  = new GeneralInformation();
        if(genralInfo == null ) {
            genralInfo  = new GeneralInformation();
        }
       
        // Mapping for approval comment
        Map<Id,String> siApprovalComment = new Map<Id,String>();
        
        //Map<Id,String> processInstanceComments = new Map<Id,String>();
        if(tobeDeletedPeopleId != null && tobeDeletedPeopleId != '') {
            Social_Input__c toBeDeleteSocialInput = [Select s.Veto_Rights__c, s.User__c,s.Stance_Approval_Status__c, s.SystemModstamp, s.SYS_Tab_View_Tasks__c, s.SYS_Tab_View_Social_Input__c, s.SYS_Tab_View_Relations__c, s.SYS_Tab_View_Quality__c, s.SYS_Tab_View_Attachments__c, s.SYS_Tab_View_Approvals__c, s.Role_Acceptance_Status__c, s.Role_Acceptance_Required__c, s.Result__c, s.Responsible__c, s.Rating__c, s.Outcome__c, s.Name, s.Mood__c, s.Like__c, s.LastModifiedDate, s.LastModifiedById, s.Informed__c, s.Id, s.Final_Approval_Status__c, s.Effort__c, s.Dislike__c, s.Decision__c, s.CreatedDate, s.CreatedById, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c, s.Accountable__c From Social_Input__c s where s.Id =: tobeDeletedPeopleId Limit 50000];
            if (Social_Input__c.sObjectType.getDescribe().isDeletable()){
                delete toBeDeleteSocialInput;
            }
        }
        
        List<Social_Input__c> socialInputList = new List<Social_Input__c>();
         Map<id,Social_Input__c> socialInputMap  = new Map<id,Social_Input__c>();
        // To replace * with % in searh area.
        if(searchPhrase != ''){
            if(searchPhrase.contains('*')){
                String SearchtextList=searchPhrase.replaceAll('\\*','\\%');
                searchPhrase = SearchtextList;
            }
        }
        
        // converting the search text to upper case. This is required in comparing User name or group name in for loop below.
        if(searchPhrase != ''){
            searchPhrase = searchPhrase.toUpperCase();
        } 
        
        //Query all social input and assign to map so this can be used for finding Final approval and Stance approval  during adding entirs to siApprovalComment
        socialInputMap  = new Map<id,Social_Input__c>( [Select s.Group_Name__c,s.GroupId__c,s.Is_Group__c,s.Stance_Approval_Status__c,  s.Description__c, s.Veto_Rights__c, s.Role__c, s.User__c, s.User__r.Name, s.SystemModstamp, s.SYS_Tab_View_Tasks__c, s.SYS_Tab_View_Social_Input__c, s.SYS_Tab_View_Relations__c, s.SYS_Tab_View_Quality__c, s.SYS_Tab_View_Attachments__c, s.SYS_Tab_View_Approvals__c, s.Role_Acceptance_Status__c, s.Role_Acceptance_Required__c, s.Result__c, s.Responsible__c, s.Rating__c, s.Outcome__c, s.Name, s.Mood__c, s.Like__c, s.LastModifiedDate, s.LastModifiedById, s.Informed__c, s.Id, s.Final_Approval_Status__c, s.Effort__c, s.Dislike__c, s.Decision__c, s.CreatedDate, s.CreatedById, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c, s.Accountable__c,s.Decision__r.phase__c From Social_Input__c s where s.Decision__c =: decisionId Limit 50000 ]);
        socialInputList = socialInputMap.values();
        
        //Social_Input__c loggedInSocialPeople = new Social_Input__c();
        if(loggedInSocialPeople == null) {
            loggedInSocialPeople = new Social_Input__c();
            if([select id  from Social_Input__c where User__c =: userInfo.getUserId() AND Decision__c =: decisionId].size() > 0 ) {
                loggedInSocialPeople = [Select s.Veto_Rights__c, s.User__c,s.Stance_Approval_Status__c, s.SystemModstamp, s.Select_People__c, s.SYS_Tab_View_Tasks__c, s.SYS_Tab_View_Social_Input__c, s.SYS_Tab_View_Relations__c, s.SYS_Tab_View_Quality__c, s.SYS_Tab_View_History__c, s.SYS_Tab_View_Attachments__c, s.SYS_Tab_View_Approvals__c, s.SYS_Tab_View_Activites__c, s.Role__c, s.Role_Acceptance_Status__c, s.Role_Acceptance_Required__c, s.Result__c, s.Responsible__c, s.Rating__c, s.Plan__c, s.OwnerId, s.Outcome__c, s.Name_of_the_User__c, s.Name, s.Mood__c, s.Like__c, s.LastModifiedDate, s.LastModifiedById, s.Is_Group__c, s.IsDeleted, s.Informed__c, s.Id, s.Group_Name__c, s.GroupId__c, s.Final_Approval_Status__c, s.Effort__c, s.Dislike__c, s.Description__c, s.Decision__c, s.CreatedDate, s.CreatedById, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c, s.Accountable__c From Social_Input__c s where User__c =: userInfo.getUserId() AND Decision__c =: decisionId limit 1 ];
            }
        }
     
       /* if(profile == null) {   
            profile = new Profile();
            profile =[Select Name From Profile where Name =: 'System Administrator' limit 1];
        }
        */
        List<DecisionSocialInput> decisionSocialInputList = new List<DecisionSocialInput>();
        
        // For approval comment on people tab
        set<Id> groupId = new set<Id>();
        for(Social_Input__c socialInput: socialInputList) {
            if(socialInput.Is_Group__c) {
                groupId.add(socialInput.GroupId__c);
            }
        }
        
        set<Id> socialInputId = new set<Id>();
        for(Social_Input__c s: socialInputList) {
            socialInputId.add(s.Id);
        }
        
        /*List<ProcessInstance> processInstanceList = [Select (Select Id, IsPending, ProcessInstanceId, StepStatus, OriginalActorId, ActorId,Actor.Name,OriginalActor.Name, RemindersSent, Comments, CreatedDate, CreatedById From StepsAndWorkitems Order By CreatedDate) hs , TargetObjectId  From ProcessInstance p where TargetObjectId In: socialInputId];
        Set<Id> processInstanceIdSet = new set<Id>();
        for(ProcessInstance p : processInstanceList){
            processInstanceIdSet.add(p.id);     
        }
        
        List<ProcessInstanceStep> processStepList = [select comments,ProcessInstanceId from ProcessInstanceStep where processInstanceId in : processInstanceIdSet ];
        for(ProcessInstanceStep p: processStepList ) {
            processInstanceComments.put(p.processInstanceId,p.comments)  ;  
        }
        
        for(ProcessInstance p : processInstanceList){
            siApprovalComment.put(p.TargetObjectId,processInstanceComments.get(p.id));  
        }
        System.debug('-----Approval comment--'+siApprovalComment);*/
        //Query all Process instance from social input to get comments
        List<ProcessInstance> processInstanceList = [Select (Select Id, IsPending, ProcessInstanceId,ProcessInstance.TargetObjectId , StepStatus, OriginalActorId, ActorId,Actor.Name,OriginalActor.Name, RemindersSent, Comments, CreatedDate, CreatedById From StepsAndWorkitems Order By CreatedDate ) hs , TargetObjectId,lastModifiedDate  From ProcessInstance p where Status != 'Removed' and TargetObjectId  In: socialInputId order by lastModifiedDate desc Limit 50000];
        Set<Id> processUserId = new Set<Id>();
        Set<Id> processUserIdNew = new Set<Id>();
        // Loop over all process instances
        for(ProcessInstance p: processInstanceList ) {
            List<ProcessInstanceHistory> phiList = new List<ProcessInstanceHistory>();
            phiList = p.StepsAndWorkitems;
            for(ProcessInstanceHistory pi : phiList ) {
                // Loop over all   ProcessInstanceHistory
               
                // section to get all comments since all ProcessInstanceHistory are in order first   all decison approvals will come then all stance approval 
                // to get the last comment use the  processUserIdNew and processUserId sets, if only mystance is fired then processUserId should not contain OriginalActorId 
                //if Decison approval fired processUserIdNew should not contain OriginalActorId and processUserId should contain OriginalActorId
                if( ( pi.StepStatus != 'Started' && pi.StepStatus != 'Recalled' ) && ( !processUserId.contains(pi.OriginalActorId) ) && ( ( socialInputMap.get( pi.ProcessInstance.TargetObjectId ).Final_Approval_Status__c != 'Pending Approval' ) && ( socialInputMap.get( pi.ProcessInstance.TargetObjectId ).Final_Approval_Status__c != 'Approved' ) &&  ( socialInputMap.get( pi.ProcessInstance.TargetObjectId ).Final_Approval_Status__c != 'Rejected' )  )  ){
                    processUserId.add(pi.OriginalActorId);
                    siApprovalComment.put(pi.OriginalActorId,pi.Comments);
                }
                if( (  pi.StepStatus != 'Started' && pi.StepStatus != 'Recalled' ) && (( socialInputMap.get( pi.ProcessInstance.TargetObjectId ).Final_Approval_Status__c == 'Pending Approval' ) || ( socialInputMap.get( pi.ProcessInstance.TargetObjectId ).Final_Approval_Status__c == 'Approved' ) ||  ( socialInputMap.get( pi.ProcessInstance.TargetObjectId ).Final_Approval_Status__c == 'Rejected' )  )  ){
                   
                    if( processUserId.contains(pi.OriginalActorId) &&  !processUserIdNew.contains(pi.OriginalActorId) )
                    {    
                         processUserIdNew.add(pi.OriginalActorId);
                         siApprovalComment.put(pi.OriginalActorId,pi.Comments);
                    }
                    processUserId.add(pi.OriginalActorId);  
                }
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
            if( genralInfo.useNameMap.get(gruopMember.UserOrGroupId)==null || (  genralInfo.useNameMap.get(gruopMember.UserOrGroupId) !=null && genralInfo.useNameMap.get(gruopMember.UserOrGroupId).isActive == true ) )
                groupMemberLIst.add(gruopMember.UserOrGroupId);
            }
        }

        for(Social_Input__c socialInput : socialInputList){
            // if search text has the search criteria.
            if(searchPhrase != ''){
                //searching user or groups which has search text passed in. The user name is converted to upper case and is compared with search text
                if((socialInput.User__c != null && socialInput.User__r.Name.toUpperCase().contains(searchPhrase)) || (socialInput.User__c == null && genralInfo.groupMap.get(socialInput.GroupId__c).Name.toUpperCase().contains(searchPhrase))){
                    DecisionSocialInput socialInputWrap = new DecisionSocialInput();
                    socialInputWrap.userId = socialInput.User__c != null ? socialInput.User__c : socialInput.GroupId__c ;
                    socialInputWrap.id = socialInput.id;
                    socialInputWrap.name = socialInput.User__c != null ? socialInput.User__r.Name : genralInfo.groupMap.get(socialInput.GroupId__c).Name;
                    socialInputWrap.userImage = socialInput.User__c != null ? genralInfo.useImage.get(socialInput.User__c) : '/'+ genralInfo.imageUrlMap.get('group');
                    socialInputWrap.role = socialInput.Role__c.replaceAll(' ',', ');
                    socialInputWrap.roleAcceptance = socialInput.Role_Acceptance_Status__c == null ? '' : socialInput.Role_Acceptance_Status__c;
                    socialInputWrap.roleAcceptanceFor = 'Test';
                    //socialInputWrap.roleAcceptanceImage = socialInput.Role_Acceptance_Status__c == 'Approved/Accepted' ? genralInfo.imageUrlMap.get('approved') : socialInput.Role_Acceptance_Status__c == 'Not Accepted' ? genralInfo.imageUrlMap.get('rejected')  : socialInput.Role_Acceptance_Status__c == 'Pending Approval' ? genralInfo.imageUrlMap.get('pending') : genralInfo.imageUrlMap.get('null')  ;
                    if(socialInput.Decision__r.phase__c == 'Draft'){
                        if(socialInput.Accountable__c)
                            socialInputWrap.roleAcceptanceImage = genralInfo.imageUrlMap.get('approved');
                        else
                            socialInputWrap.roleAcceptanceImage = socialInput.Role_Acceptance_Required__c ? genralInfo.imageUrlMap.get('') : genralInfo.imageUrlMap.get('approved');
                    }else{ 
                        socialInputWrap.roleAcceptanceImage = socialInput.Role_Acceptance_Status__c == 'Approved/Accepted' ? genralInfo.imageUrlMap.get('approved') : socialInput.Role_Acceptance_Status__c == 'Not Accepted' ? genralInfo.imageUrlMap.get('rejected')  : socialInput.Role_Acceptance_Status__c == 'Pending Approval' ? genralInfo.imageUrlMap.get('pending') : genralInfo.imageUrlMap.get('null')  ;   
                    }
                    socialInputWrap.decisionApproval = socialInput.Stance_Approval_Status__c == null ? '' : socialInput.Stance_Approval_Status__c;
                    socialInputWrap.decisionApprovalFor = socialInput.Approved_for__c != null ?String.escapeSingleQuotes(socialInput.Approved_for__c): '';
                    
                    socialInputWrap.decisionApprovalImage = socialInput.Stance_Approval_Status__c == 'Approved' ? genralInfo.imageUrlMap.get('approved') : socialInput.Stance_Approval_Status__c == 'Rejected' ? genralInfo.imageUrlMap.get('rejected')  : socialInput.Stance_Approval_Status__c == 'Pending Approval' ? genralInfo.imageUrlMap.get('pending') : genralInfo.imageUrlMap.get('null')  ;
                    socialInputWrap.backupforAccountable = socialInput.Backup_for_Accountable__c == true ? genralInfo.imageUrlMap.get('checked') : genralInfo.imageUrlMap.get('unchecked');
                    socialInputWrap.vetoRights = socialInput.Veto_Rights__c  == true ? genralInfo.imageUrlMap.get('checked') : genralInfo.imageUrlMap.get('unchecked'); 
                    socialInputWrap.description = socialInput.Description__c != null ?String.escapeSingleQuotes(socialInput.Description__c): '';
                    socialInputWrap.groupName = socialInput.GroupId__c != null ? String.escapeSingleQuotes(genralInfo.groupMap.get(socialInput.GroupId__c).Name) : '';
                    socialInputWrap.infoImage = socialInput.GroupId__c != null  ? genralInfo.imageUrlMap.get('info') : genralInfo.imageUrlMap.get('null'); 
        
                    socialInputWrap.url = socialInput.Is_Group__c ? 'javascript:void(0)' : '/' + socialInput.User__c;
                    socialInputWrap.groupClassName = socialInput.Is_Group__c ? 'group-link' : '';
                    socialInputWrap.isGroup = socialInput.Is_Group__c;
                    socialInputWrap.userNameList = '';
                    if(socialInput.Is_Group__c) {
                        if(groupMembermap.get(socialInput.GroupId__c) != null){
                            List<String> groupMemberList = groupMembermap.get(socialInput.GroupId__c);
                            socialInputWrap.userNameList = listToStringConvert(groupMemberList);
                        }
                    }
                    socialInputWrap.isDeletable = false; 
                    socialInputWrap.actionClassName = 'grid-action-disabled';
                    //if(socialInput.Decision__r.phase__c != 'Close'){
                        if(socialInput.Accountable__c || socialInput.User__c == userInfo.getUserId()) {
                            socialInputWrap.isDeletable = false;
                        }
                        else {
                            if(((loggedInSocialPeople.Accountable__c || loggedInSocialPeople.Backup_for_Accountable__c || loggedInSocialPeople.Responsible__c) && loggedInSocialPeople.Role_Acceptance_Status__c == 'Approved/Accepted') || chkRecPermission == true) {
                                socialInputWrap.isDeletable =  true;
                                socialInputWrap.actionClassName = '';
                            }
                        }
                    //}
                    socialInputWrap.deleteImage = genralInfo.deleteImage.get(socialInputWrap.isDeletable);
                    // Conditions for approval comments.
                    if(socialInput.Accountable__c || socialInput.Responsible__c || socialInput.Consulted__c || socialInput.Backup_for_Accountable__c){
                        if(socialInput.Decision__r.phase__c == 'Propose' || socialInput.Decision__r.phase__c == 'Decide' || socialInput.Decision__r.phase__c == 'Execute' || socialInput.Decision__r.phase__c == 'Evaluate' ||  socialInput.Decision__r.phase__c == 'Close'){
                            socialInputWrap.approvalComment = siApprovalComment.get(socialInput.User__c) != null && socialInput.Role_Acceptance_Status__c == 'Approved/Accepted' ? siApprovalComment.get(socialInput.User__c) : '';
                            socialInputWrap.approvalCommentsImage = siApprovalComment.get(socialInput.User__c) != null && socialInput.Role_Acceptance_Status__c == 'Approved/Accepted' ? genralInfo.imageUrlMap.get('chat') : genralInfo.imageUrlMap.get('') ;
                        }
                        if(socialInput.Decision__r.phase__c == 'Draft' || socialInput.Decision__r.phase__c == 'Share'){
                            socialInputWrap.approvalComment = '';
                            socialInputWrap.approvalCommentsImage = genralInfo.imageUrlMap.get('') ;
                        }
                    }
                    // When approval comments is not provided or null.
                    else { 
                        socialInputWrap.approvalComment = '';
                        socialInputWrap.approvalCommentsImage = genralInfo.imageUrlMap.get('') ;    
                    }
                    decisionSocialInputList.add(socialInputWrap);

                    
                }
            }
            // If search text has no criteria
            else{
                DecisionSocialInput socialInputWrap = new DecisionSocialInput();
                socialInputWrap.userId = socialInput.User__c != null ? socialInput.User__c : socialInput.GroupId__c ;
                socialInputWrap.id = socialInput.id;
                socialInputWrap.name = socialInput.User__c != null ? socialInput.User__r.Name : genralInfo.groupMap.get(socialInput.GroupId__c).Name;
                socialInputWrap.userImage = socialInput.User__c != null ? genralInfo.useImage.get(socialInput.User__c) : '/'+ genralInfo.imageUrlMap.get('group');
                socialInputWrap.role = socialInput.Role__c.replaceAll(' ',', ');
                socialInputWrap.roleAcceptance = socialInput.Role_Acceptance_Status__c == null ? '' : socialInput.Role_Acceptance_Status__c;
                socialInputWrap.roleAcceptanceFor = 'Test';
                //socialInputWrap.roleAcceptanceImage = socialInput.Role_Acceptance_Status__c == 'Approved/Accepted' ? genralInfo.imageUrlMap.get('approved') : socialInput.Role_Acceptance_Status__c == 'Not Accepted' ? genralInfo.imageUrlMap.get('rejected')  : socialInput.Role_Acceptance_Status__c == 'Pending Approval' ? genralInfo.imageUrlMap.get('pending') : genralInfo.imageUrlMap.get('null')  ;
                if(socialInput.Decision__r.phase__c == 'Draft'){
                    if(socialInput.Accountable__c)
                        socialInputWrap.roleAcceptanceImage = genralInfo.imageUrlMap.get('approved');
                    else
                        socialInputWrap.roleAcceptanceImage = socialInput.Role_Acceptance_Required__c ? genralInfo.imageUrlMap.get('') : genralInfo.imageUrlMap.get('approved');
                }else{ 
                    socialInputWrap.roleAcceptanceImage = socialInput.Role_Acceptance_Status__c == 'Approved/Accepted' ? genralInfo.imageUrlMap.get('approved') : socialInput.Role_Acceptance_Status__c == 'Not Accepted' ? genralInfo.imageUrlMap.get('rejected')  : socialInput.Role_Acceptance_Status__c == 'Pending Approval' ? genralInfo.imageUrlMap.get('pending') : genralInfo.imageUrlMap.get('null')  ;   
                }
                socialInputWrap.decisionApproval = socialInput.Stance_Approval_Status__c == null ? '' : socialInput.Stance_Approval_Status__c;
                socialInputWrap.decisionApprovalFor = socialInput.Approved_for__c != null ?String.escapeSingleQuotes(socialInput.Approved_for__c): '';
                
                socialInputWrap.decisionApprovalImage = socialInput.Stance_Approval_Status__c == 'Approved' ? genralInfo.imageUrlMap.get('approved') : socialInput.Stance_Approval_Status__c == 'Rejected' ? genralInfo.imageUrlMap.get('rejected')  : socialInput.Stance_Approval_Status__c == 'Pending Approval' ? genralInfo.imageUrlMap.get('pending') : genralInfo.imageUrlMap.get('null')  ;
                socialInputWrap.backupforAccountable = socialInput.Backup_for_Accountable__c == true ? genralInfo.imageUrlMap.get('checked') : genralInfo.imageUrlMap.get('unchecked');
                socialInputWrap.vetoRights = socialInput.Veto_Rights__c  == true ? genralInfo.imageUrlMap.get('checked') : genralInfo.imageUrlMap.get('unchecked'); 
                socialInputWrap.description = socialInput.Description__c != null ?String.escapeSingleQuotes(socialInput.Description__c): '';
                socialInputWrap.groupName = socialInput.GroupId__c != null ? String.escapeSingleQuotes(genralInfo.groupMap.get(socialInput.GroupId__c).Name) : '';
                socialInputWrap.infoImage = socialInput.GroupId__c != null  ? genralInfo.imageUrlMap.get('info') : genralInfo.imageUrlMap.get('null'); 
    
                socialInputWrap.url = socialInput.Is_Group__c ? 'javascript:void(0)' : '/' + socialInput.User__c;
                socialInputWrap.groupClassName = socialInput.Is_Group__c ? 'group-link' : '';
                socialInputWrap.isGroup = socialInput.Is_Group__c;
                socialInputWrap.userNameList = '';
                if(socialInput.Is_Group__c) {
                    if(groupMembermap.get(socialInput.GroupId__c) != null){
                        List<String> groupMemberList = groupMembermap.get(socialInput.GroupId__c);
                        socialInputWrap.userNameList = listToStringConvert(groupMemberList);
                    }
                }
                socialInputWrap.isDeletable = false; 
                socialInputWrap.actionClassName = 'grid-action-disabled';
                //if(socialInput.Decision__r.phase__c != 'Close'){
                    if(socialInput.Accountable__c || socialInput.User__c == userInfo.getUserId()) {
                        socialInputWrap.isDeletable = false;
                    }
                    else {
                        if(((loggedInSocialPeople.Accountable__c || loggedInSocialPeople.Backup_for_Accountable__c || loggedInSocialPeople.Responsible__c) && loggedInSocialPeople.Role_Acceptance_Status__c == 'Approved/Accepted') || chkRecPermission == true) {
                            socialInputWrap.isDeletable =  true;
                            socialInputWrap.actionClassName = '';
                        }
                    }
                //}
                socialInputWrap.deleteImage = genralInfo.deleteImage.get(socialInputWrap.isDeletable);
                // Conditions for approval comments.
                if(socialInput.Accountable__c || socialInput.Responsible__c || socialInput.Consulted__c || socialInput.Backup_for_Accountable__c){
                    if(socialInput.Decision__r.phase__c == 'Propose' || socialInput.Decision__r.phase__c == 'Decide' || socialInput.Decision__r.phase__c == 'Execute' || socialInput.Decision__r.phase__c == 'Evaluate' || socialInput.Decision__r.phase__c == 'Close'){
                        socialInputWrap.approvalComment = siApprovalComment.get(socialInput.User__c) != null && socialInput.Role_Acceptance_Status__c == 'Approved/Accepted' ? siApprovalComment.get(socialInput.User__c) : '';
                        socialInputWrap.approvalCommentsImage = siApprovalComment.get(socialInput.User__c) != null && socialInput.Role_Acceptance_Status__c == 'Approved/Accepted' ? genralInfo.imageUrlMap.get('chat') : genralInfo.imageUrlMap.get('') ;
                    }
                    if(socialInput.Decision__r.phase__c == 'Draft' || socialInput.Decision__r.phase__c == 'Share'){
                        socialInputWrap.approvalComment = '';
                        socialInputWrap.approvalCommentsImage = genralInfo.imageUrlMap.get('') ;
                    }
                }
                // When approval comments is not provided or null.
                else { 
                    socialInputWrap.approvalComment = '';
                    socialInputWrap.approvalCommentsImage = genralInfo.imageUrlMap.get('') ;    
                }
                decisionSocialInputList.add(socialInputWrap);
            }
        }
        System.debug('--------decisionSocialInputList--------->'+decisionSocialInputList);
        decisionSocialInputJson = JSON.serialize(decisionSocialInputList);
        return decisionSocialInputJson;
    } 
    
    // Cerate Collabrator Json String. This method is deprecated because of intorduction of search functionality. Instead we are using viewSocialPeopleTabWithSearch. This is requiered from packaging perspective. 
    public static String viewSocialPeople(String decisionId, String tobeDeletedPeopleId) {
        return null;
    }
    
    @RemoteAction
    public static String retrieveGroupMember(String GrupId) {
        //GeneralInformation genralInfo  = new GeneralInformation();
        
        if(genralInfo == null ) {
            genralInfo  = new GeneralInformation();
        }
        
        List<UserGroupMemberList> UserGroupMemberList = new List<UserGroupMemberList>();
        for(GroupMember gruopMember : [Select g.UserOrGroupId, g.Id, g.GroupId From GroupMember g where g.GroupId =: GrupId]) {
            UserGroupMemberList userGroupMember = new UserGroupMemberList();
            userGroupMember.name = genralInfo.useNameMap.get(gruopMember.UserOrGroupId)!=null ? genralInfo.useNameMap.get(gruopMember.UserOrGroupId).Name: genralInfo.groupMap.get(gruopMember.UserOrGroupId)!=null? genralInfo.groupMap.get(gruopMember.UserOrGroupId).Name:'';
            userGroupMember.userImage = genralInfo.useImage.get(gruopMember.UserOrGroupId)!=null ? genralInfo.useImage.get(gruopMember.UserOrGroupId): '/'+ genralInfo.imageUrlMap.get('group');
            userGroupMember.department = genralInfo.useNameMap.get(gruopMember.UserOrGroupId)==null ? '' : genralInfo.useNameMap.get(gruopMember.UserOrGroupId).Department == null ? '' : genralInfo.useNameMap.get(gruopMember.UserOrGroupId).Department;
            system.debug(gruopMember.UserOrGroupId + ''+userGroupMember.name+genralInfo.groupMap.get(gruopMember.UserOrGroupId));
           
            if( genralInfo.groupMap.get(gruopMember.UserOrGroupId) !=null || (  genralInfo.useNameMap.get(gruopMember.UserOrGroupId) !=null && genralInfo.useNameMap.get(gruopMember.UserOrGroupId).isActive == true ) )
            UserGroupMemberList.add(userGroupMember);
        }
        return JSON.serialize(UserGroupMemberList);
    }
    
    // Method to extract group members names.
    
    
    
    // Attachment and Notes tab
    @RemoteAction
    public static string attachmentNoteView(String decisionId) {
        List<AttachmentNote> attachmentNoteList = new List<AttachmentNote>();
        // initialize General information class to get user locale date format and image static resouce url //
        //GeneralInformation genralInfo  = new GeneralInformation();
        /*
        if(genralInfo == null ) {
            genralInfo  = new GeneralInformation();
        }
        
        // assign user locale date format as string 
        dateTimeFormat = genralInfo.MapValuesDateTime();
        
        List<AttachmentNote> attachmentNoteList = new List<AttachmentNote>();
        
        
        //Social_Input__c loggedInSocialPeople = new Social_Input__c();
        if(loggedInSocialPeople == null) {
            loggedInSocialPeople = new Social_Input__c();
            if([select id  from Social_Input__c where User__c =: userInfo.getUserId() AND Decision__c =: decisionId].size() > 0 ) {
                loggedInSocialPeople = [Select s.Veto_Rights__c, s.User__c, s.SystemModstamp, s.Select_People__c, s.SYS_Tab_View_Tasks__c, s.SYS_Tab_View_Social_Input__c, s.SYS_Tab_View_Relations__c, s.SYS_Tab_View_Quality__c, s.SYS_Tab_View_History__c, s.SYS_Tab_View_Attachments__c, s.SYS_Tab_View_Approvals__c, s.SYS_Tab_View_Activites__c, s.Role__c, s.Role_Acceptance_Status__c, s.Role_Acceptance_Required__c, s.Result__c, s.Responsible__c, s.Rating__c, s.Plan__c, s.OwnerId, s.Outcome__c, s.Name_of_the_User__c, s.Name, s.Mood__c, s.Like__c, s.LastModifiedDate, s.LastModifiedById, s.Is_Group__c, s.IsDeleted, s.Informed__c, s.Id, s.Group_Name__c, s.GroupId__c, s.Final_Approval_Status__c, s.Effort__c, s.Dislike__c, s.Description__c, s.Decision__c, s.CreatedDate, s.CreatedById, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c, s.Accountable__c From Social_Input__c s where User__c =: userInfo.getUserId() AND Decision__c =: decisionId limit 1 ];
            }
        }
           
        if(profile == null) {   
            profile = new Profile();
            profile =[Select Name From Profile where Name=: 'System Administrator' limit 1];
        }
        
        for(Attachment a : [Select a.ParentId, a.OwnerId, a.owner.Name,  a.Name, a.LastModifiedDate, a.Id, a.CreatedById From Attachment a where a.parentId =: decisionId ORDER BY a.CreatedDate ]) {
            
            if(a.Name != String.Valueof(a.ParentId)) {
                AttachmentNote att = new AttachmentNote();
                att.id = a.Id;
                att.type = 'Attachment';
                att.name = a.Name;
                att.lastModifiedDate = a.LastModifiedDate.format(dateTimeFormat);
                att.createdByUser =  a.owner.Name;
                att.createdByUserImage = genralInfo.useImage.get(a.OwnerId);
                
                att.isDeletable= false;
                att.isEditable = false; 
                att.actionClassName = 'grid-action-disabled';
                
                if(loggedInSocialPeople.Accountable__c || loggedInSocialPeople.Backup_for_Accountable__c || Userinfo.getProfileId() == profile.Id || (loggedInSocialPeople.Responsible__c && userInfo.getUserId() == a.OwnerId)) {
                    att.isDeletable =  true;
                    att.isEditable = true;
                    att.actionClassName = '';
                }
                att.deleteImage = genralInfo.deleteImage.get(att.isDeletable);
                att.editImage = genralInfo.editImage.get(att.isEditable);
                att.url = att.isEditable ? '/'+att.id+'/e?retURL='+decisionId +'' :  'javascript:void(0)';
                    
                attachmentNoteList.add(att);
            }
        }  
        
        for(Note a : [Select a.ParentId, a.OwnerId,a.Title, a.owner.Name, a.LastModifiedDate, a.Id, a.CreatedById From Note a where a.parentId =: decisionId ORDER BY a.CreatedDate DESC ]) {
            AttachmentNote att = new AttachmentNote();
            att.id = a.Id;
            att.type = 'Note';
            att.name = a.Title;
            att.lastModifiedDate = a.LastModifiedDate.format(dateTimeFormat);
            att.createdByUser = a.owner.Name;
            att.createdByUserImage = genralInfo.useImage.get(a.OwnerId);
            
            att.isDeletable= false;
            att.isEditable = false; 
            att.actionClassName = 'grid-action-disabled';
            
            if(loggedInSocialPeople.Accountable__c || loggedInSocialPeople.Backup_for_Accountable__c || Userinfo.getProfileId() == profile.Id || (loggedInSocialPeople.Responsible__c && userInfo.getUserId() == a.OwnerId)) {
                att.isDeletable =  true;
                att.isEditable = true;
                att.actionClassName = '';
            }
            att.deleteImage = genralInfo.deleteImage.get(att.isDeletable);
            att.editImage = genralInfo.editImage.get(att.isEditable);
            att.url = att.isEditable ? '/'+att.id+'/e?retURL='+decisionId +'' :  'javascript:void(0)';
            
            attachmentNoteList.add(att);
        }
        
        if(Userinfo.getProfileId() == profile.Id) {
            set<Id> relatedRecordIds = new set<Id>();
            for(FeedComment fc: [SELECT Id, RelatedRecordId  FROM FeedComment where ParentId =: decisionId]) {
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
            
            for(FeedItem  fi : [SELECT Type, Title, Id, LastModifiedDate, CreatedById, RelatedRecordId  FROM FeedItem  WHERE (ParentId =: decisionId AND Type  = 'ContentPost')]) {
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
        
        attachmentNoteJson = JSON.serialize(attachmentNoteList);
        
        return attachmentNoteJson; */
        return null;
    }
    // END Attachment and Notes tab
   
    
    // generate json string for Quality tab
    @RemoteAction
    public static string issuesQuality(String decisionId, String issuesId) {
        
        if(issuesId != null && issuesId != '') {
            
        }
        
        // initialize General information class to get user locale date format and image static resouce url //
        //GeneralInformation genralInfo  = new GeneralInformation();
        
        if(genralInfo == null ) {
            genralInfo  = new GeneralInformation();
        }
        
        // assign user locale date format as string 
        dateTimeFormat = genralInfo.MapValuesDateTime();
        
        List<UserRecordAccess> listUserRecordAccess = [SELECT RecordId, HasReadAccess, HasEditAccess, HasDeleteAccess,MaxAccessLevel FROM UserRecordAccess WHERE UserId=:UserInfo.getUserId() AND RecordId =: decisionId limit 1];
              
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
        
        //Social_Input__c loggedInSocialPeople = new Social_Input__c();
        if(loggedInSocialPeople == null) {
            loggedInSocialPeople = new Social_Input__c();
            if([select id  from Social_Input__c where User__c =: userInfo.getUserId() AND Decision__c =: decisionId].size() > 0 ) {
                loggedInSocialPeople = [Select s.Veto_Rights__c,s.Stance_Approval_Status__c, s.User__c, s.SystemModstamp, s.Select_People__c, s.SYS_Tab_View_Tasks__c, s.SYS_Tab_View_Social_Input__c, s.SYS_Tab_View_Relations__c, s.SYS_Tab_View_Quality__c, s.SYS_Tab_View_History__c, s.SYS_Tab_View_Attachments__c, s.SYS_Tab_View_Approvals__c, s.SYS_Tab_View_Activites__c, s.Role__c, s.Role_Acceptance_Status__c, s.Role_Acceptance_Required__c, s.Result__c, s.Responsible__c, s.Rating__c, s.Plan__c, s.OwnerId, s.Outcome__c, s.Name_of_the_User__c, s.Name, s.Mood__c, s.Like__c, s.LastModifiedDate, s.LastModifiedById, s.Is_Group__c, s.IsDeleted, s.Informed__c, s.Id, s.Group_Name__c, s.GroupId__c, s.Final_Approval_Status__c, s.Effort__c, s.Dislike__c, s.Description__c, s.Decision__c, s.CreatedDate, s.CreatedById, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c, s.Accountable__c From Social_Input__c s where User__c =: userInfo.getUserId() AND Decision__c =: decisionId limit 1 ];
            }
        }
        
      /*  if(profile == null) {   
            profile = new Profile();
            profile =[Select Name From Profile where Name=: 'System Administrator' limit 1];
        }*/

        // initialize issues quality list 
        List<IssuesQuality> issuesQualityList = new List<IssuesQuality>();
        
        // serialize records list
        return issuesQualityJson;
    }
    // End Quality tab section
    
    // generate json string for timing tab
    @RemoteAction
    public static string timingTab(String decisionId) {
         // initialize General information class to get user locale date format and image static resouce url //
        //GeneralInformation genralInfo  = new GeneralInformation();
        
        if(genralInfo == null ) {
            genralInfo  = new GeneralInformation();
        }
        
        // assign user locale date format as string 
        dateTimeFormat = genralInfo.MapValuesDateTime();
        
        timeSectionJSON = '';
        
        List<String> phases = new List<String>{'Draft', 'Share' , 'Propose', 'Decide' , 'Execute', 'Evaluate', 'Close'};
        
        Decision__c decision = [select id, Name, Phase__c, Status__c from Decision__c where Id =: decisionId];
        
        //Social_Input__c loggedInSocialPeople = new Social_Input__c();
        if(loggedInSocialPeople == null) {
            loggedInSocialPeople = new Social_Input__c();
            if([select id  from Social_Input__c where User__c =: userInfo.getUserId() AND Decision__c =: decisionId].size() > 0 ) {
                loggedInSocialPeople = [Select s.Veto_Rights__c, s.User__c, s.SystemModstamp,s.Stance_Approval_Status__c, s.Select_People__c, s.SYS_Tab_View_Tasks__c, s.SYS_Tab_View_Social_Input__c, s.SYS_Tab_View_Relations__c, s.SYS_Tab_View_Quality__c, s.SYS_Tab_View_History__c, s.SYS_Tab_View_Attachments__c, s.SYS_Tab_View_Approvals__c, s.SYS_Tab_View_Activites__c, s.Role__c, s.Role_Acceptance_Status__c, s.Role_Acceptance_Required__c, s.Result__c, s.Responsible__c, s.Rating__c, s.Plan__c, s.OwnerId, s.Outcome__c, s.Name_of_the_User__c, s.Name, s.Mood__c, s.Like__c, s.LastModifiedDate, s.LastModifiedById, s.Is_Group__c, s.IsDeleted, s.Informed__c, s.Id, s.Group_Name__c, s.GroupId__c, s.Final_Approval_Status__c, s.Effort__c, s.Dislike__c, s.Description__c, s.Decision__c, s.CreatedDate, s.CreatedById, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c, s.Accountable__c From Social_Input__c s where User__c =: userInfo.getUserId() AND Decision__c =: decisionId limit 1 ];
            }
        }
        
        List<TimeSection> timeSectionList = new List<TimeSection>();
        
        Boolean isRead = false;
        Integer i=0;
        for(Timing__c timing : [Select t.Id,t.Stage_No__c, t.Actual_End_Date__c, t.Actual_Start_Date__c, t.Start_Date_Time__c, t.Stage__c, t.Related_To_ID__c, t.End_Date_Time__c, t.Elapsed_Time__c, t.Difference__c, t.Comments__c From Timing__c t where t.Related_To_ID__c = : decisionId Order by Stage_No__c]) {
            
            
            // initialize timing section  wrapper object 
            TimeSection ts = new TimeSection();
            ts.id = timing.Id;
            ts.phasesNo = timing.Stage_No__c;
            ts.phases = timing.Stage__c;
            ts.plannedStart =  timing.Start_Date_Time__c == null ? '' :  string.valueOf(timing.Start_Date_Time__c );
            ts.plannedEnd = timing.End_Date_Time__c == null ? '':  string.valueOf(timing.End_Date_Time__c);
            ts.actualStartTime =   timing.Actual_Start_Date__c == null ? '' : string.valueOf( timing.Actual_Start_Date__c );
            ts.actualEndTime =  timing.Actual_End_Date__c == null ? '': string.valueOf( timing.Actual_End_Date__c) ;
            ts.elapsedTime = timing.Elapsed_Time__c == null ? '' : timing.Elapsed_Time__c;
            ts.diffToPalnned = timing.Difference__c == null ? '' : timing.Difference__c;
            ts.timingComment = timing.Comments__c == null ? '' : timing.Comments__c;
            
            if(phases[i] == decision.Phase__c && !isRead) {
                isRead = true;  
            }
            
            if(isRead &&  (loggedInSocialPeople.Accountable__c || loggedInSocialPeople.Responsible__c   || loggedInSocialPeople.Backup_for_Accountable__c ) && loggedInSocialPeople.Role_Acceptance_Status__c == 'Approved/Accepted' ) {
                ts.isReadOnly = false;
            }
            else { 
                ts.isReadOnly = true;
            }
            
            if(decision.Phase__c == 'Close') {
                ts.isReadOnly = true;
            }
            
            ts.currentPhases = decision.Phase__c;
            ts.kendoDateTimeFormat = '{0:' + dateTimeFormat +'}';
            timeSectionList.add(ts);
            
            i++;
        }
        
        // serialize records list
        timeSectionJSON = JSON.serialize(timeSectionList);
        system.debug(timeSectionJSON);         
        return timeSectionJSON;
    } 
    // End timing tab section
    
    //  decision matrix tab to get matrix data
    @RemoteAction
    public static String matrixDataTab(String decisionId) {        
        //Query decision matrix data 
        Decision__c decision = [Select Matrix_Data__c From Decision__c where Id =: decisionId ];
        //pass matrix data to page
         if(genralInfo == null ) {
            genralInfo  = new GeneralInformation();
        }
        matrixSectionJSON = decision.Matrix_Data__c != null ? decision.Matrix_Data__c.replaceAll('\'','') : '';
        return decision.Matrix_Data__c; 
    
     }
     
    @RemoteAction
    public static void saveMatrixDataTab(String decisionId, String matrixJSON) {        
        //update the data to data base 
        Decision__c decision = [Select Matrix_Data__c From Decision__c where Id =: decisionId ];
     
        decision.Matrix_Data__c = matrixJSON;
        if(FLS.decisionUpdateable()){
            update decision;
        }
    
     }
    // Generate json string for Approval tab
    @RemoteAction
    public static string approvalTab(String decisionId) {
        
        //GeneralInformation genralInfo  = new GeneralInformation();
        // initialize General information class to get user locale date format and image static resouce url
        if(genralInfo == null ) {
            genralInfo  = new GeneralInformation();
        }
        dateTimeFormat = genralInfo.MapValuesDateTime();
        
        //Social_Input__c loggedInSocialPeople = new Social_Input__c();
        if(loggedInSocialPeople == null) {
            loggedInSocialPeople = new Social_Input__c();
            if([select id  from Social_Input__c where User__c =: userInfo.getUserId() AND Decision__c =: decisionId].size() > 0 ) {
                loggedInSocialPeople = [Select s.Veto_Rights__c, s.User__c, s.SystemModstamp,s.Stance_Approval_Status__c, s.Select_People__c, s.SYS_Tab_View_Tasks__c, s.SYS_Tab_View_Social_Input__c, s.SYS_Tab_View_Relations__c, s.SYS_Tab_View_Quality__c, s.SYS_Tab_View_History__c, s.SYS_Tab_View_Attachments__c, s.SYS_Tab_View_Approvals__c, s.SYS_Tab_View_Activites__c, s.Role__c, s.Role_Acceptance_Status__c, s.Role_Acceptance_Required__c, s.Result__c, s.Responsible__c, s.Rating__c, s.Plan__c, s.OwnerId, s.Outcome__c, s.Name_of_the_User__c, s.Name, s.Mood__c, s.Like__c, s.LastModifiedDate, s.LastModifiedById, s.Is_Group__c, s.IsDeleted, s.Informed__c, s.Id, s.Group_Name__c, s.GroupId__c, s.Final_Approval_Status__c, s.Effort__c, s.Dislike__c, s.Description__c, s.Decision__c, s.CreatedDate, s.CreatedById, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c, s.Accountable__c From Social_Input__c s where User__c =: userInfo.getUserId() AND Decision__c =: decisionId limit 1 ];
            }
        }
        
        String userRole = '';
        
        // Assigning the role of the user logged in
        if(loggedInSocialPeople != null){
            userRole = loggedInSocialPeople.Role__c;    
        }
        
        List<ApprovalWrapper> approvalWrapperList = new List<ApprovalWrapper>();
        for(ProcessInstanceWorkitem piw : [Select p.ProcessInstance.Status, p.ProcessInstance.TargetObjectId, p.ProcessInstanceId, p.Id, p.CreatedDate, p.CreatedBy.Name, p.CreatedById, p.Actor.Name, p.ActorId From ProcessInstanceWorkitem p where  p.ActorId =: Userinfo.getUserId() AND p.ProcessInstance.TargetObjectId =: loggedInSocialPeople.Id]) {
            ApprovalWrapper aw = new ApprovalWrapper();
            aw.id = piw.Id;
            aw.step = loggedInSocialPeople.Role_Acceptance_Status__c == 'Pending Approval' ? 'Role Acceptance' : loggedInSocialPeople.Stance_Approval_Status__c == 'Pending Approval' ? 'My Stance' : 'Decision Approval'; //
            aw.stepTitle = loggedInSocialPeople.Role_Acceptance_Status__c == 'Pending Approval' ? 'Accept/Reject' : loggedInSocialPeople.Stance_Approval_Status__c == 'Pending Approval' ? 'Support/Oppose' : 'Approve/Reject';
            // Condtions for diaplaying action icons based on approvals
            aw.stepImage = aw.step == 'Role Acceptance' ? genralInfo.imageUrlMap.get('roleApprovalImg') : aw.step == 'My Stance' ? genralInfo.imageUrlMap.get('personalApprovalImg') : genralInfo.imageUrlMap.get('finalApprovalImg');   
            aw.status = piw.ProcessInstance.Status;
            aw.statusImage = genralInfo.imageUrlMap.get('pending');
            aw.createdDate = piw.CreatedDate.format(dateTimeFormat);
            aw.roleOfUser = userRole;
            approvalWrapperList.add(aw);
        }    
        // serialize records list
        approvalJSON = JSON.serialize(approvalWrapperList);
        return approvalJSON;
    }
    
    // Social Input Tab value update on clik event of tab
    @RemoteAction
    public static JsonExistingData tabSectionClicked(String socialInputId, String clickedTab) {
        
        JsonExistingData jsonExistingData = new JsonExistingData();
        
        if(socialInputId != null) {
            Social_Input__c socialInput = [Select s.Id, s.SYS_Tab_View_Activites__c,s.Stance_Approval_Status__c, s.SYS_Tab_View_History__c, s.SYS_Tab_View_Tasks__c, s.SYS_Tab_View_Social_Input__c, s.SYS_Tab_View_Relations__c, s.SYS_Tab_View_Quality__c, s.SYS_Tab_View_Attachments__c, s.SYS_Tab_View_Approvals__c From Social_Input__c s where s.Id =:socialInputId ];
            
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
    
 
    // decision Approva /reject
    @RemoteAction
    public static JsonExistingData approvedReject(String decisionId, String processInstanceitemId, String action, String comment ) {
        String newComment = comment;
        
         
        JsonExistingData jsonExistingData = new JsonExistingData();
        
        Social_Input__c logedInsocialInput = [Select  s.Role__c , s.Role_Acceptance_Status__c , s.Accountable__c, s.Backup_for_Accountable__c, s.Responsible__c,s.Consulted__c,s.Informed__c,s.Veto_Rights__c,s.Stance_Approval_Status__c,s.Final_Approval_Status__c   From Social_Input__c s where s.Decision__c =: decisionId and s.User__c =: userInfo.getUserId() ];
        
      
        
            Approval.ProcessWorkItemRequest processWorkItemRequest = new Approval.ProcessWorkItemRequest();
            ProcessInstanceWorkitem processInstanceWorkitem = [Select p.ProcessInstance.Status, p.ProcessInstance.TargetObjectId, p.ProcessInstanceId, p.Id, p.CreatedDate, p.CreatedBy.Name, p.CreatedById, p.Actor.Name, p.ActorId From ProcessInstanceWorkitem p where  p.id=: processInstanceitemId];    
            
            //processWorkItemRequest = processInstanceWorkitem;        
            processWorkItemRequest.setWorkitemId(processInstanceWorkitem.id);
            System.debug('-----Checking comments in approval------------------'+newComment+'-----------------------'+comment);
             
            processWorkItemRequest.setComments(comment);
           
            processWorkItemRequest.setAction(action); 
            Approval.ProcessResult pr = Approval.process(processWorkItemRequest);
            
            
            List<ApprovalWrapper> approvalWrapperList = new List<ApprovalWrapper>();
           
            Decision__c decision = [select id,FeedItem_Id_Propose__c, Name, Phase__c, Status__c ,ownerid from Decision__c where Id =: decisionId];
            
            Social_Input__c socialInput = [Select s.Veto_Rights__c, s.User__c,s.Stance_Approval_Status__c, s.SystemModstamp, s.SYS_Tab_View_Activites__c, s.SYS_Tab_View_History__c, s.SYS_Tab_View_Tasks__c, s.SYS_Tab_View_Social_Input__c, s.SYS_Tab_View_Relations__c, s.SYS_Tab_View_Quality__c, s.SYS_Tab_View_Attachments__c, s.SYS_Tab_View_Approvals__c, s.Role_Acceptance_Status__c, s.Role_Acceptance_Required__c, s.Result__c, s.Responsible__c, s.Rating__c, s.Outcome__c, s.Name, s.Mood__c, s.Like__c, s.LastModifiedDate, s.LastModifiedById, s.Informed__c, s.Id, s.Final_Approval_Status__c, s.Effort__c, s.Dislike__c, s.Decision__c,Decision__r.phase__c, s.CreatedDate, s.CreatedById, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c, s.Accountable__c From Social_Input__c s where s.Id =: processInstanceWorkitem.ProcessInstance.TargetObjectId ];
            //If the current user approves stance or final decison a chatter post is created.
            String roleString  =  '';
            String proposeChatterPostId = '';
            // Checks for logged in users role status
            if( logedInsocialInput.Role_Acceptance_Status__c == 'Approved/Accepted'  ){
                 proposeChatterPostId  =  decision.FeedItem_Id_Propose__c; 
                //if no propose chatter post exist then create new one and make comment.
                if( decision.FeedItem_Id_Propose__c  == '' || decision.FeedItem_Id_Propose__c  == null ){
                    system.debug('-------------- Approved while creating' );
                    Decision__c decisionQry  =[select id,Problem_Idea_Advice__c,Decision_Taken__c,ownerid from Decision__c where id =:decisionId Limit 1];
                    Id userId=decision.ownerid;
                    //System.debug('-----decision-------------decision.Decision_Taken__c'+decision.Decision_Taken__c+decisionId+'--'+decision.ownerid);
                    User usr = [Select id,name from User where id=:decisionQry.ownerid Limit 1];
                    //String postText='The following decision has been proposed:'+'\n'+'\n'+'"'+decisionQry.Decision_Taken__c+'"'+'\n'+'\n'+usr.name+' '+'needs your personal stance.';
                    String postText='Here is the proposed Decision, read it and give your Stance.'+'\n'+'\n'+'Decision:'+'\n'+'"'+decisionQry.Decision_Taken__c+'"'+'\n'+'\n'+'(hint: it’s done in the command center)';
                    if(logedInsocialInput.Accountable__c || logedInsocialInput.Backup_for_Accountable__c || logedInsocialInput.Responsible__c){	
                    	mentionTextPostPropose( usr.id, postText, decisionId);
                    }
                    /*FeedItem post = new FeedItem();
                    post.ParentId =  decision.Id;  
                    post.Body =      'The decision has been proposed'  ;
                    post.type = 'TextPost';                   
                    post.Title = decision.id;  
                    post.createdbyid = decision.ownerid;
                    if( FLS.FeedItemCreatable()) 
                    insert post;*/ 
                    //proposeChatterPostId  =  post.id;
                    Decision__c decisionQryUpdated  =[select id,FeedItem_Id_Propose__c from Decision__c where id =:decisionId Limit 1];
                    proposeChatterPostId  =  decisionQryUpdated.FeedItem_Id_Propose__c; 
                }
                // Creates a feed comment
                FeedComment chatterComment = new FeedComment();
                chatterComment.feedItemId =  proposeChatterPostId;  
                comment = comment.length() > 1000 ? comment.substring(0,890) + '...':comment;
                // Role string to diplay each role separated with ',' and  'and'
                roleString  =  roleString + ( logedInsocialInput.Accountable__c ? ' Accountable,':'' );
                roleString  =  roleString + ( logedInsocialInput.Responsible__c ? ' Responsible,':'' );
                roleString  =  roleString + ( logedInsocialInput.Consulted__c ? ' Consulted,':'' );
                roleString  =  roleString + ( logedInsocialInput.Informed__c ? ' Informed,':'' );
                roleString  =  roleString + ( logedInsocialInput.Backup_for_Accountable__c ? ' Backup,':'' );
                roleString  =  roleString + ( logedInsocialInput.Veto_Rights__c ? ' Veto,':'' );
                roleString  =  roleString.reverse(); 
                roleString  =  roleString.replaceFirst(',','');
                roleString  =  roleString.replaceFirst(',',' dna ');
                roleString  =  roleString.reverse();
                //Display chatter comment to show loggedin user has Approved/Rejected OR Supported/Opposed  the deciison with his role and comments provided in stance
                chatterComment.CommentBody = 'Has ' +  ( ( logedInsocialInput.Stance_Approval_Status__c == 'Pending Approval' ) ?   ( action == 'Approve' ? 'supported the decision' : 'opposed the decision' ) :  ( logedInsocialInput.Final_Approval_Status__c == 'Pending Approval' ?  ( action == 'Approve' ? 'approved the decision': 'rejected the decision' ) : '' ) ) + ' as '+  roleString +   (    (  comment != null &&( comment.trim().length() != 0 ) ) ?'\nwith Comment:\n \"' +comment +'\".' : '.' );
                if( FLS.FeedItemCreatable())    
                insert chatterComment;  
            }
            //if current user rejected stance create a chatter post for decision rejection
            if( logedInsocialInput.Role_Acceptance_Status__c == 'Approved/Accepted' && socialInput.Stance_Approval_Status__c == 'Rejected' && socialInput.Veto_Rights__c && action == 'Reject' ) 
            {
                         // Creates a feed comment 
                        FeedComment chatterComment = new FeedComment();
                        chatterComment.feedItemId =  proposeChatterPostId;  
                        comment = comment.length() > 1000 ? comment.substring(0,890) + '...':comment;
                        // Display chatter comment to show loggedin use has Rejected the decision with  his role and comments provided in stance
                        chatterComment.CommentBody =    'Has rejected the Decision'   + ' as '+  roleString +   (    (  comment != null &&( comment.trim().length() != 0 ) ) ?'\nwith Comment:\n \"' +comment +'\".' : '.' );
                        if( FLS.FeedItemCreatable())    
                        insert chatterComment;    
             }
            
            jsonExistingData.commonHistory = viewHistory(decisionId);
            jsonExistingData.decisionObject = decision;
            jsonExistingData.socialIndividual = socialInput;
            jsonExistingData.timingObject = timingTab(decisionId);
            jsonExistingData.peopleObject = viewSocialPeopleTabWithSearch(decisionId, null, '');
            System.debug('--------peopleObject---------------------'+jsonExistingData.peopleObject);
            jsonExistingData.approvalObject = JSON.serialize(approvalWrapperList);
         
            return jsonExistingData;
    }    
    
    // Cerate Clone Json String for decision, people, tasks, relations and attachments.
    @RemoteAction
    public static String decisionCopy(String decisionId, Boolean people, Boolean reasetDate, Boolean tasks, Boolean relationships, Boolean isRelatedTo, Boolean assignToMe, String relation, Boolean attachments) {
        // Query decision
        Decision__c decision = [Select  d.Valid_Until__c, d.Valid_From__c, d.Title__c, d.Tag__c, d.SystemModstamp, d.Status__c, d.SYS_From_Quick_Decision__c, d.Reason_for_Close__c, d.Problem_Idea_Advice__c, d.Private__c, d.Priority__c, d.Point_of_No_Return__c, d.Phase__c, d.Parent_Decision__c, d.OwnerId, d.Name, d.LastModifiedDate, d.LastModifiedById, d.LastActivityDate, d.IsDeleted, d.Id, d.Estimated_People_Involved__c, d.Estimated_Net_Present_Value__c, d.Estimated_Investment__c, d.Estimated_Full_time_Equivalent_FTE__c, d.Estimated_Direct_Cost__c, d.Due_Date__c, d.Decision_Taken__c, d.Decision_Type__c, d.Decision_Making_Style__c, d.Decision_Approach__c, d.Category__c, d.CreatedDate, d.CreatedById, d.Comments__c, d.Approved_when_Created__c, d.Add_C_I_Members__c, d.Actual_People_Involved__c, d.Actual_Net_Present_Value__c, d.Actual_Investment__c, d.Actual_Full_time_Equivalent_FTE__c, d.Actual_Direct_Cost__c, d.Accountable__c,d.Estimated_People_Involved_Desc__c, d.Estimated_Net_Present_Value_Desc__c, d.Estimated_Investment_Desc__c, d.Estimated_Full_time_Equivalent_Desc__c, d.Estimated_Direct_Cost_Desc__c, d.Actual_People_Involved_Desc__c, d.Actual_Net_Present_Value_Desc__c, d.Actual_Investment_Desc__c, d.Actual_Full_time_Equivalent_Desc__c, d.Actual_Direct_Cost_Desc__c,d.Estimated_Revenue__c, d.Estimated_Revenue_Desc__c, d.Actual_Revenue__c, d.Actual_Revenue_Desc__c From Decision__c d where d.Id =: decisionId];
        
        // Clone decision 
        Decision__c cloneDecision = decision.clone(false);
        cloneDecision.Phase__c= 'Draft';
        cloneDecision.Status__c = 'Undecided';
        cloneDecision.Title__c = 'Copy - '+ cloneDecision.Title__c;
        if(cloneDecision.Title__c.length() > 129) {
            cloneDecision.Title__c = cloneDecision.Title__c.substring(0,129);
        }
        // Resets important dates when cloning decision.
        if(reasetDate) {
            cloneDecision.Due_Date__c = null;
            cloneDecision.Valid_Until__c = null;
            cloneDecision.Valid_From__c = null; 
            cloneDecision.Point_of_No_Return__c = null; 
        }
        cloneDecision.OwnerId = userInfo.getUserId();
        
        // inserts copy of the decision.
        if(FLS.decisionCreateable()) {
            insert cloneDecision;
        }
        
        // Clone people.
        // Creates a list to add people.
        List<Social_Input__c> toBeCloneSocialInput = new List<Social_Input__c>();
        
        // Clone collabrator list for QCD.
        if(cloneDecision.Approved_when_Created__c) {
            Social_Input__c socialInput = new Social_Input__c();
            socialInput.Accountable__c = true;
            socialInput.User__c = cloneDecision.OwnerId;
            socialInput.Decision__c = cloneDecision.Id;
            toBeCloneSocialInput.add(socialInput);
        }
        // Clone collaborator list for decision.
        if(people){
            for(Social_Input__c si : [Select s.Is_Group__c,s.User__r.isActive,s.Stance_Approval_Status__c, s.Role_Acceptance_Required__c, s.GroupId__c, s.Veto_Rights__c, s.User__c,s.Description__c,  s.Responsible__c, s.Informed__c, s.Consulted__c, s.Backup_for_Accountable__c, s.Accountable__c From Social_Input__c s where s.Decision__c =: decisionId]) {
                if((si.User__r.isActive == True && si.User__c != null) || si.User__c == null){
                    if(si.User__c != userInfo.getUserId()) {
                    
                        Social_Input__c socialInput = new Social_Input__c();
                        socialInput.Responsible__c = si.Responsible__c;
                        if(si.Accountable__c) {
                            si.Accountable__c = false;
                            socialInput.Responsible__c = true;
                        }
                        socialInput.Informed__c = si.Informed__c;
                        socialInput.Consulted__c = si.Consulted__c;
                        socialInput.Backup_for_Accountable__c = si.Backup_for_Accountable__c;
                        socialInput.Veto_Rights__c = si.Veto_Rights__c;
                        socialInput.User__c = si.User__c;
                        socialInput.GroupId__c = si.GroupId__c;
                        socialInput.Is_Group__c = si.Is_Group__c;
                        socialInput.Decision__c = cloneDecision.Id;
                        socialInput.Description__c = si.Description__c;
                        socialInput.Role_Acceptance_Required__c = si.Role_Acceptance_Required__c;
                        toBeCloneSocialInput.add(socialInput);
                    }
                }
            }
        }
        
        // Clone relations.
        // Creates a list to add relations.
        List<Relations__c> toBeCloneRelations = new List<Relations__c>();
        
        // Clone relations list
        if(relationships) {
            for(Relations__c r : [Select r.Type__c, r.Strength__c, r.From_Relation__c, r.Parent_Record_Name__c, r.Parent_Object_Name__c, r.Parent_ID__c, r.Notes__c, r.To_Relation__c, r.Child_Record_Name__c, r.Child_Object_Name__c, r.Child_ID__c From Relations__c r where r.Type__c =: 'Relation' and ( r.Parent_ID__c =: decisionId or  r.Child_ID__c =: decisionId )]){
                Relations__c rel = new Relations__c();
                if(r.Parent_ID__c == decisionId) {
                    rel.Parent_ID__c = cloneDecision.Id;
                    rel.Parent_Record_Name__c = cloneDecision.Title__c;
                    rel.Parent_Object_Name__c = 'Decision';
                    rel.Child_ID__c = r.Child_ID__c;
                    rel.Child_Record_Name__c = r.Child_Record_Name__c;
                    rel.Child_Object_Name__c = r.Child_Object_Name__c;
                }
                else {
                    rel.Parent_ID__c = r.Parent_ID__c;
                    rel.Parent_Record_Name__c = r.Parent_Record_Name__c;
                    rel.Parent_Object_Name__c = r.Parent_Object_Name__c;
                    rel.Child_ID__c = cloneDecision.Id;
                    rel.Child_Record_Name__c = cloneDecision.Title__c;
                    rel.Child_Object_Name__c = 'Decision';
                }
                rel.From_Relation__c = r.From_Relation__c;
                rel.To_Relation__c = r.To_Relation__c;
                rel.Strength__c = r.Strength__c;
                rel.Notes__c = r.Notes__c;
                toBeCloneRelations.add(rel);
            }
        }
        // Creates a relation record of decision from where it is cloned.
        if(isRelatedTo) {
            Relations__c rel = new Relations__c();
            rel.Parent_ID__c = decision.Id;
            rel.Parent_Record_Name__c = decision.Title__c;
            rel.Parent_Object_Name__c = 'Decision';
            rel.Child_ID__c = cloneDecision.Id;
            rel.Child_Record_Name__c = cloneDecision.Title__c;
            rel.Child_Object_Name__c = 'Decision';
            rel.To_Relation__c = relation;
              // -- Start added on 26_02_2014 to add the reciprocal relation when clone is done. 
            //IF "To Relation" is child then "From Relation" will be Parent,IF "To Relation" is Parent then "From Relation" will be Child, IF "To Relation" is Sibling then "From Relation" will be Sibling
            //IF "To Relation" is blank then "From Relation" will blank
            rel.From_Relation__c  = rel.To_Relation__c  == 'Parent' ? 'Child' : rel.To_Relation__c  == 'Child' ? 'Parent' : rel.To_Relation__c ==  'Sibling' ? 'Sibling' : '' ;
            //-- end added on 26_02_2014 to add the reciprocal relation when clone is done.
            toBeCloneRelations.add(rel);
        }
        
        // Clone tasks.
        // Creates a list to add tasks.
        List<Task> toBeInsertedTask = new List<Task>();
        
        // Clone task list
        if(tasks) {
            for(Task task: [select Id,WhatId,OwnerId, Owner.Name ,ActivityDate,Status,Priority,Subject,Description from Task where whatId=:decisionId order by subject desc] ){
                Task cloneTask = task.clone(false);
                cloneTask.WhatId = cloneDecision.Id;
                cloneTask.Status = 'Not Started';
                if(assignToMe){
                    cloneTask.OwnerId = userInfo.getUserId();
                }
                if(reasetDate) {
                    cloneTask.ActivityDate = null;
                }
                toBeInsertedTask.add(cloneTask);
            }
        }
        
        // Clone attachments
        // Creates a list to add attachments.
        List<Attachment>  toBeCloneAttachments = new List<Attachment>();
        //list of clone Feed Attachment 
        List<Attachment> toBeCloneFeedAttachment = new List<Attachment>();
        Set<ID> contentVersionRecordId = new Set<ID>();
        // To check whether the copy attachments is checked or not.
        if(attachments){
            // Clone attachment list  
            // query for RelatedRecordId in chatter feed 
             for(Decision__Feed feedItm:[SELECT ContentFileName,ParentId,RelatedRecordId FROM Decision__Feed where ParentId= :decisionId ]){
                if(feedItm.RelatedRecordId != null){
                    contentVersionRecordId.add(feedItm.RelatedRecordId);
                    System.debug('clonefeedItemclonefeedItemclonefeedItem'+contentVersionRecordId);
                }
            }
            // query for chatter feed Attactment in ContentVersion 
            For(ContentVersion contnVersion: [SELECT Id,Title,PathOnClient, ContentDocumentId,VersionData FROM ContentVersion WHERE ID In : contentVersionRecordId]  ){
                
                Attachment cloneAttachment = new Attachment() ;
                cloneAttachment.ParentId = cloneDecision.Id;
                cloneAttachment.Name = contnVersion.PathOnClient;
                cloneAttachment.Body = contnVersion.VersionData;
                toBeCloneFeedAttachment.add(cloneAttachment);

            }
                     
            for(Attachment attachment : [select id, Name, Body from Attachment where ParentId =: decisionId]){
                    if(attachment.Name == decisionId ){
                        continue;
                    }
                    Attachment cloneAttachment = attachment.clone(false);
                    cloneAttachment.ParentId = cloneDecision.Id;
                    cloneAttachment.Name = attachment.Name;
                    cloneAttachment.Body = attachment.Body;
                    toBeCloneAttachments.add(cloneAttachment);
                }
            
            
        }
        
        // inserts attachment lists.
        if(toBeCloneAttachments.size() > 0  ) {
           if(FLS.attachmentCreateable()) {
                insert toBeCloneAttachments;
           }
        }
        
        //insert Feed Attachment list
        if(toBeCloneFeedAttachment.size() > 0 ){
            if(FLS.attachmentCreateable()) {
                insert toBeCloneFeedAttachment;
           }
        
        }
        
        // inserts social input lists.
        if(toBeCloneSocialInput.size() > 0) {
            if(FLS.socialInputCreateable()) {
                insert toBeCloneSocialInput;
            }
        }
        
       // inserts relations lists.
        if(toBeCloneRelations.size() > 0) {
            if(FLS.relationCreateable()) {
                insert toBeCloneRelations;
            }
        }
        
       // inserts tasks lists.
        if(toBeInsertedTask.size() > 0) {
            if(FLS.taskCreateable()){
                insert toBeInsertedTask;
            }
        }
        
       /* if(addAsRelationId.length() > 1){
                system.debug('addAsRelationIdaddAsRelationIdaddAsRelationId'+addAsRelationId.length());
                // Relation record is create when a new Decision is created from standard object.
                DecisionQuickCreate.addAsRelation(objectChosen,addAsRelationId,cloneDecision.Id,cloneDecision.Title__c);
             pageReference   decisionViewPage = new pageReference('/apex/DecisionView?id='+cloneDecision.Id);
                decisionViewPage.setRedirect(true);
            } */
        
        // returns the id of the decision to be cloned.
        return cloneDecision.Id;    
    }
    
    // Cerate Clone Json String. This method is deprecated because of intorduction of copy attachment functionality. Instead we are using decisionCopy. This  method is requiered from packaging perspective.
    @RemoteAction
    public static String decisionClone1(String decisionId, Boolean people, Boolean reasetDate, Boolean tasks, Boolean relationships, Boolean isRelatedTo, Boolean assignToMe, String relation ) {
        return null;
    }
    // This method is also deprecated. But required from packaging perspective.
    @RemoteAction
    public static String decisionClone(String decisionId, Boolean people, Boolean reasetDate, Boolean tasks, Boolean relationships, Boolean isRelatedTo, String relation ) {
       return null;
    }
    
    
    // approval click from phases arrow 
    // provide approval ProcessInstanceWorkitem id and step
    @RemoteAction
    public static ApprovalWrapper  approvalFromPhasesArrow(string decisionId, String socialInputId) {
        
        //GeneralInformation genralInfo  = new GeneralInformation();
        
        if(genralInfo == null ) {
            genralInfo  = new GeneralInformation();
        }
        //dateTimeFormat = genralInfo.MapValuesDateTime();
         
        //Social_Input__c loggedInSocialPeople = new Social_Input__c();
        if(loggedInSocialPeople == null) {
            loggedInSocialPeople = new Social_Input__c();
            if([select id  from Social_Input__c where User__c =: userInfo.getUserId() AND Decision__c =: decisionId].size() > 0 ) {
                loggedInSocialPeople = [Select s.Veto_Rights__c, s.User__c,s.Stance_Approval_Status__c, s.SystemModstamp, s.Select_People__c, s.SYS_Tab_View_Tasks__c, s.SYS_Tab_View_Social_Input__c, s.SYS_Tab_View_Relations__c, s.SYS_Tab_View_Quality__c, s.SYS_Tab_View_History__c, s.SYS_Tab_View_Attachments__c, s.SYS_Tab_View_Approvals__c, s.SYS_Tab_View_Activites__c, s.Role__c, s.Role_Acceptance_Status__c, s.Role_Acceptance_Required__c, s.Result__c, s.Responsible__c, s.Rating__c, s.Plan__c, s.OwnerId, s.Outcome__c, s.Name_of_the_User__c, s.Name, s.Mood__c, s.Like__c, s.LastModifiedDate, s.LastModifiedById, s.Is_Group__c, s.IsDeleted, s.Informed__c, s.Id, s.Group_Name__c, s.GroupId__c, s.Final_Approval_Status__c, s.Effort__c, s.Dislike__c, s.Description__c, s.Decision__c, s.CreatedDate, s.CreatedById, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c, s.Accountable__c From Social_Input__c s where User__c =: userInfo.getUserId() AND Decision__c =: decisionId limit 1 ];
            }
        }
        
        ApprovalWrapper aw = new ApprovalWrapper();
        for(ProcessInstanceWorkitem piw : [Select p.ProcessInstance.Status, p.ProcessInstance.TargetObjectId, p.ProcessInstanceId, p.Id, p.CreatedDate, p.CreatedBy.Name, p.CreatedById, p.Actor.Name, p.ActorId From ProcessInstanceWorkitem p where  p.ActorId =: Userinfo.getUserId() AND p.ProcessInstance.TargetObjectId =: loggedInSocialPeople.Id]) {
            
            aw.id = piw.Id;
            //aw.step = loggedInSocialPeople.Role_Acceptance_Status__c == 'Pending Approval' ? 'Role Acceptance' : 'Decision Approval';
            aw.step = loggedInSocialPeople.Role_Acceptance_Status__c == 'Pending Approval' ? 'Role Acceptance' : loggedInSocialPeople.Stance_Approval_Status__c == 'Pending Approval' ? 'My Stance' : 'Decision Approval'; //
            //aw.stepTitle = loggedInSocialPeople.Role_Acceptance_Status__c == 'Pending Approval' ? 'Accept / Reject' : 'Approve / Reject';
            aw.stepTitle = loggedInSocialPeople.Role_Acceptance_Status__c == 'Pending Approval' ? 'Accept / Reject' : loggedInSocialPeople.Stance_Approval_Status__c == 'Pending Approval' ? 'Approve / Reject' : 'Decision Approval'; //'Approve / Reject'; 
            aw.stepImage = genralInfo.imageUrlMap.get('approveImg');
            aw.status = piw.ProcessInstance.Status;
            aw.statusImage = genralInfo.imageUrlMap.get('pending');
        
        }
        return aw;
    }
    
    // tag json generate 
    public string jsonStringTagGenerate() {
        List<Tag__c> tagList = [select name from Tag__c limit 50000 ];
        List<TagWrapper> tagWrapperList = new List<TagWrapper>();
        String tagJsonString = '';
        for(Tag__c tg: tagList) {
             tagJsonString = tagJsonString  + '\"' + tg.Name + '\"'  + ',';
         }
         if(tagJsonString.length() > 1) {
             tagJsonString = tagJsonString.substring(0, tagJsonString.length() - 1);
         }
        
        //tagJsonString = JSON.serialize(tagWrapperList);
        return tagJsonString;
    }
    
    @RemoteAction
    public static String updateTaskRec(String recId){
        Task t = [select Id,WhatId,OwnerId, Owner.Name ,ActivityDate,Status,Priority,Subject,Description from Task where Id = : recId];
        
        return JSON.serialize(t);
    }
    
    
    // ******************* Decision Tag insert  ***********//
    @RemoteAction
    public static String insertTag(String decisionId, String tagValue){
        Decision__c decision = [select Tag__c,Name,Plain_Tag__c, Id from Decision__c where Id =: decisionId];
        if(tagValue != null && tagValue != '') {
            decision.Plain_Tag__c = tagValue;
            Tag__c tag;
            tagValue = tagValue.replaceAll(' ','');
            map<String, Id> tagMaping = new map<String, Id>();
            if(tagValue.contains(',')) {
                List<String> tagList  = tagValue.split(',');
                set<String> tagSetList = new set<String>();
                for(String s: tagList) {
                    tagSetList.add(s);
                }
                List<Tag__c> tagItemList = [select id, Name from Tag__c where Name In:tagSetList];
                set<String> tagAlredyInserted = new set<String>();
                List<String> tagNotInserted = new List<String>();
                if(tagItemList.size() > 0 ) {
                    // to check which tag name is already inserted 
                    for(Tag__c tg: tagItemList) {
                      tagMaping.put(tg.Name, tg.Id);
                        if(tagSetList.contains(tg.Name)) {
                            tagAlredyInserted.add(tg.Name);
                        }
                    }
                    
                    // to check which tag name is not already inserted 
                    for(String s: tagList) {
                      if(!tagAlredyInserted.contains(s)) {
                            tagNotInserted.add(s);
                        }
                    }
                    
                    // already inserted tag on Tag_Junction__c
                    set<String> alerdyInsertedJunctionSet = new set<String>(); 
                    List<Tag_Junction__c> alerdyInsertedJunctionList = [select Tag_Name__r.Name, Related_To_ID__c  from  Tag_Junction__c where Related_To_ID__c =: decisionId ];
                    if(alerdyInsertedJunctionList.size() > 0) {
                        if (Tag_Junction__c.sObjectType.getDescribe().isDeletable()){
                            delete alerdyInsertedJunctionList;
                        }
                    }
                    
                    // get all tag which are inserted 
                    List<Tag__c> tagAlredyInsertedTagList = [select id, Name from Tag__c where Name In:tagAlredyInserted]; 
                    List<Tag_Junction__c> tagJunctionList = new List<Tag_Junction__c>(); 
                    
                    // insert junction object with inserted Tag 
                    for(Tag__c ti:  tagAlredyInsertedTagList) {
                        tagMaping.put(ti.Name, ti.Id);
                        
                        Tag_Junction__c tjo = new Tag_Junction__c(Related_To_Name__c =decision.Name, Related_To_Object__c = 'Decision' ,Related_To_ID__c = decisionId,Tag_Name__c = ti.id);
                        tagJunctionList.add(tjo);
                        
                    }
                    
                    
                    List<Tag__c> toBeinsertTagList = new List<Tag__c>();
                    // insert TAG which is not inserted 
                    for(String s: tagNotInserted) {
                        
                        if(s != ' ') {
                            tag= new Tag__c(Name = s);
                            toBeinsertTagList.add(tag);
                        }
                    }
                    if(toBeinsertTagList.size() > 0 ) {
                        if (FLS.tagCreateable()) {
                            insert toBeinsertTagList;
                        }
                        else {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access'));
                        }
                    }
                    
                    // insert junction object with new inserted Tag 
                    for(Tag__c tg : toBeinsertTagList) {
                        tagMaping.put(tg.Name, tg.Id);
                        //  if(!alerdyInsertedJunctionSet.contains(tg.Name)){
                        Tag_Junction__c tjo = new Tag_Junction__c(Related_To_Name__c =decision.Name, Related_To_Object__c = 'Decision' ,Related_To_ID__c = decisionId,Tag_Name__c = tg.id);
                        tagJunctionList.add(tjo);
                         //  }
                    }
                    
                    if(tagJunctionList.size() > 0) {
                        if (FLS.tagJunctionCreateable()) {
                            insert tagJunctionList;
                        }
                        else {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access')); 
                        }
                    }
                }
                else {
                    
                    // all records insert 
                    List<Tag__c> toBeinsertTagList = new List<Tag__c>();
                    for(String s: tagList) {
                        if(s != ' ' ) {
                            tag = new Tag__c(Name = s);
                            toBeinsertTagList.add(tag);
                        }
                    }
                    
                    if(toBeinsertTagList.size() > 0 ) {
                        if (FLS.tagCreateable()) {
                            insert toBeinsertTagList;
                        }
                        else {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access'));
                        }
                    }
                    
                    // already inserted tag on Tag_Junction__c
                    set<String> alerdyInsertedJunctionSet = new set<String>(); 
                    List<Tag_Junction__c> alerdyInsertedJunctionList = [select Tag_Name__c, Related_To_ID__c  from  Tag_Junction__c where Related_To_ID__c =: decisionId ];
                    
                    if(alerdyInsertedJunctionList.size() > 0) {
                        if(Tag_Junction__c.sObjectType.getDescribe().isDeletable()) {
                            delete alerdyInsertedJunctionList;
                        }
                    }
                    
                    // insert junction object with new inserted Tag 
                    List<Tag_Junction__c> tagJunctionList = new List<Tag_Junction__c>(); 
                    for(Tag__c tg : toBeinsertTagList) {
                        tagMaping.put(tg.Name, tg.Id);
                        //  if(!alerdyInsertedJunctionSet.contains(tg.Name)){
                        Tag_Junction__c tjo = new Tag_Junction__c(Related_To_Name__c =decision.Name, Related_To_Object__c = 'Decision' ,Related_To_ID__c = decisionId,Tag_Name__c = tg.id);
                        tagJunctionList.add(tjo);
                        //  }
                    }
                    
                    if(tagJunctionList.size() > 0) {
                        if (FLS.tagJunctionCreateable()) {
                            insert tagJunctionList;
                        }
                        else {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access'));
                        }
                    }
                }
                String  tagTobeInsert = '';
                for(String s: tagList) {
                    String rplcString  = '<a href=' + '\"' + '/' + tagMaping.get(s)  + '\"' + 'target=' + '\"' +'_blank' + '\"' + '>' +s+ '</a>';
                    // descn.Tags__c =   descn.Tags__c + rplcString + ', ' ;
                    tagTobeInsert = tagTobeInsert + rplcString + ', ' ;
                }
                
                if(tagTobeInsert.length() > 3) {
                    tagTobeInsert = tagTobeInsert.substring(0,tagTobeInsert.length()-2);
                }
               
                decision.Tag__c = tagTobeInsert;
            }
            else {
                
                if([select id, Name from Tag__c where Name =: tagValue limit 1].size() > 0 ) {
                    tag = [select id, Name from Tag__c where Name =: tagValue limit 1 ];
                    tagMaping.put(tag.Name, tag.Id);
                }
                else {
                    if(tagValue != '') {
                        tag= new Tag__c(Name = tagValue);
                        if(FLS.tagCreateable()) {
                            insert tag;
                            tagMaping.put(tag.Name, tag.Id);
                        }
                    }
                }
               
                // already inserted tag on Tag_Junction__c
                set<String> alerdyInsertedJunctionSet = new set<String>(); 
                List<Tag_Junction__c> alerdyInsertedJunctionList = [select Tag_Name__c, Related_To_ID__c  from  Tag_Junction__c where Related_To_ID__c =: decisionId];
                if(alerdyInsertedJunctionList.size() > 0) {
                    if(Tag_Junction__c.sObjectType.getDescribe().isDeletable()){
                        delete alerdyInsertedJunctionList;
                    }
                }
             
               
               if(!alerdyInsertedJunctionSet.contains(tagValue)){
                    Tag_Junction__c tjo = new Tag_Junction__c(Related_To_Name__c =decision.Name, Related_To_Object__c = 'Decision' ,Related_To_ID__c = decisionId,Tag_Name__c = tag.id);
                    if(FLS.tagJunctionCreateable()){
                        insert tjo;
                    }
               }
               
               String rplcString  = '<a href=' + '\"' + '/' + tagMaping.get(tagValue)  + '\"' + 'target=' + '\"' +'_blank' + '\"' + '>' +tagValue+ '</a>';
               
               decision.Tag__c = rplcString ;
            }
            
            if(FLS.decisionUpdateable()) {
                update decision;
            }
        }
        return decision.Tag__c;
    }
    
    // *******************  Outcomes scatter chart ***************** //
    @RemoteAction
    public static String kendoScatter(String decisionId) {
        
        //GeneralInformation genralInfo  = new GeneralInformation();
        
        if(genralInfo == null ) {
            genralInfo  = new GeneralInformation();
        }
        
        List<OutComewrapper> outComewrapperList = new List<OutComewrapper>();
       
        for(Social_Input__c socialInput : [SELECT User__r.Name,Stance_Approval_Status__c,Result__c, Effort__c from  Social_Input__c where Decision__c =: decisionId ]) {
            if(socialInput.Effort__c != null && socialInput.Result__c != null && socialInput.Effort__c != 0 && socialInput.Result__c != 0 ) {
               // series = series + '{ name: ' +  '\"'  + String.escapeSingleQuotes(d.User__r.Name) + '\"'+  ', data: [[' + String.valueof(d.Effort__c.intValue()) + ','+ String.valueof(d.Result__c.intValue()) + ']] },';
               OutComewrapper oc = new OutComewrapper();
               oc.userName = String.escapeSingleQuotes(socialInput.User__r.Name);
               oc.userImage = genralInfo.useImage.get(socialInput.User__c);
               
               oc.xAxis = String.valueof(socialInput.Effort__c);
               oc.yAxis = String.valueof(socialInput.Result__c);
               outComewrapperList.add(oc);
            } 
        }
    
        return JSON.serialize(outComewrapperList);
    }
    
    public void tagUpdate() {
        decision = [select ID,Add_C_I_Members__c, Name, Tag__c, Plain_Tag__c, Title__c, Problem_Idea_Advice__c, Decision_Taken__c, Decision_Type__c, Decision_Approach__c, Decision_Making_Style__c, Category__c, Priority__c, Private__c, Estimated_Investment__c, Estimated_Direct_Cost__c, Estimated_Net_Present_Value__c, Estimated_People_Involved__c, Estimated_Full_time_Equivalent_FTE__c, Actual_Investment__c, Actual_Direct_Cost__c, Actual_Net_Present_Value__c, Actual_People_Involved__c, Actual_Full_time_Equivalent_FTE__c, Phase__c, Status__c, Valid_From__c, Valid_Until__c, Point_of_No_Return__c, Due_Date__c from Decision__c where ID =: ApexPages.currentPage().getParameters().get('id')];
        
    }
    
    // Get plan List 
    
    @RemoteAction
    public static String getPlanListItem(String searchValue) {
        System.debug('-------searchValue----->'+searchValue);
        
        if(searchValue != ''){
            if(searchValue.contains('*')){
                String searchValueList=searchValue.replaceAll('\\*','\\%');
                searchValue = searchValueList;
            }
        }
        
        //GeneralInformation genralInfo  = new GeneralInformation();
        
        if(genralInfo == null ) {
            genralInfo  = new GeneralInformation();
        }
        dateTimeFormat = genralInfo.MapValuesDateTime();
        dateFormat = genralInfo.MapValuesDateFormate();
        
        List<Social_Input__c>  socialInputList = new List<Social_Input__c>();
        if(searchValue != '') {
            searchValue = searchValue+'%';
            socialInputList = [select Plan__c, Plan__r.Name,Stance_Approval_Status__c, Plan__r.lastmodifiedDate from Social_Input__c where Plan__c != null AND ( Responsible__c = true OR Accountable__c = true) AND User__c =: userInfo.getUserId() AND (Plan__r.Name like: '%'+searchValue+'%') order by Plan__r.lastmodifiedDate desc limit 50];
        } else {
            socialInputList = [select Plan__c, Plan__r.Name,Stance_Approval_Status__c, Plan__r.lastmodifiedDate from Social_Input__c where Plan__c != null AND ( Responsible__c = true OR Accountable__c = true) AND User__c =: userInfo.getUserId() order by Plan__r.lastmodifiedDate desc limit 50];
        }
        
        List<planItem> planItemList = new List<planItem>();
        
        for(Social_Input__c socialInput : socialInputList) {
            planItem pi = new planItem();
            pi.name = socialInput.Plan__r.Name != null ? socialInput.Plan__r.Name : 'Plan Name' ;
            pi.lastmodifiedDate = socialInput.Plan__r.lastmodifiedDate != null ? socialInput.Plan__r.lastmodifiedDate.format(dateTimeFormat) : String.valueOf(System.now());
            pi.planId = socialInput.Plan__c;
            planItemList.add(pi);
        }
        return JSON.serialize(planItemList);
    }
    
    // Adding selected Plan
    @RemoteAction
    public static string addSelectedPlan(String planIds,String descId,String descTitle){
        String [] arrIds = planIds.split(',');
        set<Id> setId = new set<Id>(); 
        for(String arr : arrIds){
            setId.add(arr);
        }
        List<Plan__c> lstPlan = [Select Id,Name from Plan__c where Id IN : setId];
        List<Relations__c> lstRelation = new List<Relations__c>();
        for(Plan__c p : lstPlan){
            Relations__c rel = new Relations__c();
            rel.Child_ID__c = descId;
            rel.Child_Object_Name__c = 'Decision';
            rel.Child_Record_Name__c = descTitle;
            rel.Parent_ID__c = p.Id;
            rel.Parent_Object_Name__c = 'Plan';
            rel.Parent_Record_Name__c = p.Name;
            rel.Type__c = 'Item';
            lstRelation.add(rel);
        }
        if(!lstRelation.isEmpty()){
            if(FLS.relationCreateable()){
                insert lstRelation;
            }
            
        }
        return null;
    }
    
    public void existingRelationsAddToSet(){
        Id recordId = ApexPages.currentPage().getParameters().get('id');
        List<Relations__c> lstRelations = [select id from Relations__c where Parent_Id__c = : recordId];
        
        for(Relations__c rel : lstRelations){
            relationsIds.add(rel.Id);
        }
    }
    
    // search for items to be added as relations
    public pageReference searchItems(){
        String objectChosen = ApexPages.currentPage().getParameters().get('chooseObject');
        String searchText = ApexPages.currentPage().getParameters().get('searchText');
        srchRelationship.clear();
        srchRelationshipSet.clear();
        message = '';
            
            Id decisionId = ApexPages.currentPage().getParameters().get('id');
            List<Relations__c> lstExistingRelations = [select Id,Child_ID__c,Parent_ID__c from Relations__c where Child_ID__c =:decisionId or Parent_ID__c =: decisionId limit 999];
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
            
           // Integer.valueof( searchText )  ;           
           
            if( objectChosen != 'Contract' && objectChosen != 'QuoteLineItem' && objectChosen != 'Idea' &&   objectChosen != 'Solution' &&   objectChosen != 'Case' && !objectChosen.contains('Decision__c')){
                List<sObject> records = Database.query('Select Id, Name From ' + String.escapeSingleQuotes(objectChosen) + ' Where Name like ' + '\'%'+String.escapeSingleQuotes(searchText)+'%\'' + ' limit 999 ');
                                                                 
                for(SObject record : records){
                          //system.debug('================='+record);
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
        for(Relations__c searchR:srchRelationship){
            if(searchR.select__c == true){
               searchR.Parent_Id__c = recId;
               searchR.Parent_Record_Name__c = decision.Title__c;
               searchR.Parent_Object_Name__c = 'Decision';
               searchR.To_Relation__c = searchR.From_Relation__c == 'Parent' ? 'Child' : searchR.From_Relation__c == 'Child' ? 'Parent' : searchR.From_Relation__c ==  'Sibling' ? 'Sibling' : '' ;
               addItemsRelationship.add(searchR);
            }
        }
        if(!addItemsRelationship.isEmpty()){
            if(Schema.SObjectType.Relations__c.fields.Parent_Record_Name__c.isCreateable() && Schema.SObjectType.Relations__c.fields.Parent_Id__c.isCreateable() && Schema.SObjectType.Relations__c.fields.Parent_Object_Name__c.isCreateable() && Schema.SObjectType.Relations__c.fields.Child_Id__c.isCreateable() && Schema.SObjectType.Relations__c.fields.Child_Object_Name__c.isCreateable() && Schema.SObjectType.Relations__c.fields.Child_Record_Name__c.isCreateable() && Schema.SObjectType.Relations__c.fields.Description__c.isCreateable() && Schema.SObjectType.Relations__c.fields.From_Relation__c.isCreateable() && Schema.SObjectType.Relations__c.fields.Strength__c.isCreateable() && Schema.SObjectType.Relations__c.fields.Notes__c.isCreateable() && Schema.SObjectType.Relations__c.fields.Type__c.isCreateable() && Schema.SObjectType.Relations__c.fields.To_Relation__c.isCreateable()){ 
                 insert addItemsRelationship;
            }
        }
        srchRelationship.clear();
    }
    
    //update nearest due date after approval or reject 
    @RemoteAction 
    public static string updateDecisionNearestDueDate(string decisionId){
        UpdateNearestDueDate.updateAllDeicisons(decisionId);    
        return null;
    }
    
    // issues save 
    public void saveIssues() {
       
         
    }
    
    // ******************************* Dummy Call *******************///
    public void dummyCall() {
        // For Field sets. Querying the fields form the Field Sets dynamically.
        String query = 'SELECT ';
        for(Schema.FieldSetMember f : SObjectType.Decision__c.FieldSets.Customer_Specific.getFields()){
            query += f.getFieldPath() + ', ';
        }
        query += 'ID, Name, Title__c,Decision_Taken__c,Problem_Idea_Advice__c, Tag__c,Add_C_I_Members__c, Plain_Tag__c, Decision_Type__c, Decision_Approach__c, Category__c, Decision_Making_Style__c, Priority__c, Private__c, Estimated_Investment__c, Estimated_Direct_Cost__c, Estimated_Net_Present_Value__c, Estimated_People_Involved__c, Estimated_Full_time_Equivalent_FTE__c, Actual_Investment__c, Actual_Direct_Cost__c, Actual_Net_Present_Value__c, Actual_People_Involved__c, Actual_Full_time_Equivalent_FTE__c, Phase__c, Status__c, Point_of_No_Return__c, Due_Date__c, Estimated_People_Involved_Desc__c, Estimated_Net_Present_Value_Desc__c, Estimated_Investment_Desc__c, Estimated_Full_time_Equivalent_Desc__c, Estimated_Direct_Cost_Desc__c, Actual_People_Involved_Desc__c, Actual_Net_Present_Value_Desc__c, Actual_Investment_Desc__c, Actual_Full_time_Equivalent_Desc__c, Actual_Direct_Cost_Desc__c, Identifier__c, Estimated_Revenue__c, Estimated_Revenue_Desc__c, Actual_Revenue__c, Actual_Revenue_Desc__c,Reason_for_Close__c from Decision__c where ID =: decisionId';
        decision = Database.query(query); 
        decisonSaveStatus = 'Success';  
        //decision = [select ID, Name,Tag__c,Add_C_I_Members__c, Plain_Tag__c, Title__c, Decision_Type__c, Decision_Approach__c, Category__c, Decision_Making_Style__c, Priority__c, Private__c, Estimated_Investment__c, Estimated_Direct_Cost__c, Estimated_Net_Present_Value__c, Estimated_People_Involved__c, Estimated_Full_time_Equivalent_FTE__c, Actual_Investment__c, Actual_Direct_Cost__c, Actual_Net_Present_Value__c, Actual_People_Involved__c, Actual_Full_time_Equivalent_FTE__c, Phase__c, Status__c, Valid_From__c, Valid_Until__c, Point_of_No_Return__c, Due_Date__c, Estimated_People_Involved_Desc__c, Estimated_Net_Present_Value_Desc__c, Estimated_Investment_Desc__c, Estimated_Full_time_Equivalent_Desc__c, Estimated_Direct_Cost_Desc__c, Actual_People_Involved_Desc__c, Actual_Net_Present_Value_Desc__c, Actual_Investment_Desc__c, Actual_Full_time_Equivalent_Desc__c, Actual_Direct_Cost_Desc__c, Identifier__c,Estimated_Revenue__c, Estimated_Revenue_Desc__c, Actual_Revenue__c, Actual_Revenue_Desc__c from Decision__c where ID =: ApexPages.currentPage().getParameters().get('id')];
    }
    
    
    // ************************** Wrapper calss Section ************************************//
    
    public class TagWrapper {
        public String name {get;set;}
    }
    
    // Wrapper class for Decision People (Social Input )
    public class DecisionSocialInput{
        public String id{get;set;}
        public String name{get;set;}
        public String userImage {get;set;} 
        public String role{get;set;}
        public String roleAcceptance{get;set;}
        public String decisionApproval{get;set;}
        public String roleAcceptanceFor{get;set;}
        public String decisionApprovalFor{get;set;}
        public String roleAcceptanceImage{get;set;}
        public String decisionApprovalImage{get;set;}
        public String backupforAccountable{get;set;}
        public String vetoRights{get;set;}
        public String description{get;set;}
        public Boolean isDeletable {get;set;}
        public String deleteImage {get;set;}
        public String decisionOnApprvalForCallOut {get;set;}
        public String approvalComment {get;set;}
        public String approvalCommentsImage {get; set;}
        
        public String infoImage {get;set;}
        public String groupName {get;set;}
        public String userNameList {get;set;}
        public String url {get;set;}
        public Boolean isGroup {get;set;}
        public String groupClassName {get;set;}
        
        public String userId {get;set;}
        public String actionClassName {get;set;}
    }
    
    //Wrapper class for activties tab (Plan object)
    public class ActivitiesTaskEvent {
        public String id {get;set;}
        public String subject {get;set;}
        public String status {get;set;}
        public String statusImage {get;set;}
        public String isTask {get;set;}
        public String isTaskImage {get;set;}
        public String duedate {get;set;} 
        public String priority {get;set;} 
        public String createdByName {get;set;}
        public String createdByImage {get;set;}
        public Boolean isEditable {get;set;}
        public Boolean isDeletable {get;set;}
        public String deleteImage {get;set;}
        public String editImage{get;set;}
        public string url {get;set;}
        public String comments {get; set;} 
        public string delayTaskClass {get;set;}
        public String subjectClassLink {get; set;}
        public String subjectClass {get; set;}
        public String actionClassNameEdit {get;set;}
        public String actionClassNameDelete {get;set;}
        public String commentsImage {get; set;}
        public String ownerId {get; set;}
        public Integer recordNumber{get;set;}
        public String roleAcceptanceStatus {get; set;}
        public String title {get; set;}
        public String imgEditTitle {get; set;}
        public String imgDeleteTitle {get; set;}
        public Boolean isSelected {get; set;}
        public String toDisable {get; set;}
        //added on 2014-04-25
        public datetime duedateSort {get;set;} 
        // added on 2014-04-25
    }
    
     // Wrapper class fro relationship
    public class Relationship{
        public string id {get;set;}
        public string recordId{get;set;}
        public string recordName{get;set;}
        public string relation{get;set;}
        public string objectName{get;set;}
        public string strength{get;set;}
        public string notes{get;set;}
        public Boolean isEditable{get;set;}
        public string url {get;set;}
        public Boolean isDeletable{get;set;}
        public String editImage{get;set;}
        public String deleteImage{get;set;}
        
        public String actionClassName {get;set;}
    }
    
    //Wrapper class for history tab (Plan object)
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
    
    // Wrapper class for timing Section
    public class TimeSection {
        public String id {get;private set;}
        public String phasesNo {get;private set;}
        public String phases {get;private set;}
        public string plannedStart {get;private set;}
        public string plannedEnd {get;private set;}
        public string actualStartTime {get;private set;}
        public string actualEndTime {get;private set;}
        public String elapsedTime {get;private set;}
        public String diffToPalnned {get;private set;}
        public String timingComment {get;private set;}
        public Boolean isReadOnly {get;private set;}
        public String currentPhases {get;private set;}
        public String kendoDateTimeFormat {get;private set;} 
      
    }
    
    // Wrapper class for issues and quality 
    public class IssuesQuality {
        public String issueId {get;private set;}
        public String issueName {get;private set;}
        public String status {get;private set;}
        public String type {get;private set;}
        public String priority {get;private set;}
        public String comments {get;private set;}
        public String deleteImage {get;set;}
        public Boolean isDeletable {get;set;}
        public String editImage {get;set;}
        public Boolean isEditable {get;set;}
        public string url {get;set;}
        public string createdByName {get; set;}
        public String actionClassNameDelete {get;set;}
        public String actionClassNameEdit {get;set;}
    }
    
     //Wrapper class for Attachment and Notes tab
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
    
    // Wrapper class for Approval tab
    public class ApprovalWrapper {
        public String id {get;set;}
        public String step {get;set;}
        public String stepTitle {get;set;}
        public String stepImage {get;set;}
        public String status {get;set;}
        public String statusImage {get;set;}
        public String createdDate {get;set;}
        public string roleOfUser{get;set;}
    }
    
    // Wrapper class for java remote scripting return value. 
    Public class JsonExistingData{
        
        public Social_Input__c socialIndividual {get;private set;}
        public Social__c socialOverall {get;private set;}
        public String commonHistory {get;private set;}
        public Decision__c decisionObject {get;set;}
        public String taskEvent {get;set;}
        public String activitiesTaskEvent {get;set;}
        public String timingObject {get;set;}
        public String approvalObject {get;set;}
        public String peopleObject {get;set;}
        public String errorMsg {get;set;}
    }
    
    // kendo scatter chart for accountable and responsiable 
    public class OutComewrapper {
        public String userName;
        public String userImage;
        public String xAxis;
        public String yAxis;
    }
    
    
    // Group member wrapper class
    public Class UserGroupMemberList {
        public String name {get;set;}
        public String userImage {get;set;}
        public String department {get;set;}
        
    }  
    
    // Plan list wrapper class\
    public Class planItem {
        public String name {get;set;}
        public String lastmodifiedDate {get;set;}
        public Boolean isSelected {get; set;}
        public String planId {get; set;}
    }
    
    
    // wrapper class to bind all the activites
    
    public class activiesWrapper{
        public string Id{get;set;}
        public string title{get;set;}
        public string relatedToId{get;set;}
        public string relatedTo{get;set;}
        public string DueDate{get;set;}
        public string status{get;set;}
        public string priority{get;set;}
        public string CreatedById{get;set;}
        public string CreatedBy{get;set;}
    }
    
    /*
    public class data {
        public List<ActivitiesTaskEvent>  models{get; set;}
    }
    
    public class dataWrap {
        public data data1  {get; set;}
    }
    */
    
    // Wrapper classes to bind json data select from admin tool
    class Topics {
        public string text{get;set;}
    }
    class TopicRow {
        public String text{get;set;}
        public  List<Topics> items{get;set;}
    }
    
    public class TopicAssigned {
        public String TopicName {get; set;}
        public String TopicSelected {get; set;}
        public TopicAssigned(){
            TopicSelected = '';
        }
    }
    
    public class dataActivities{
        public List<ActivitiesTaskEvent>  models{get; set;} 
    }
    
    public class dataWrapActivities{
        public dataActivities data{get;set;}    
    }
    // *************************************** //
        
    // For general tab section
    
    // Code to convert RTF 
    public void decisionRTFUpdate(){
        String kendoRtfProblemstatement = Apexpages.currentPage().getParameters().get('ProblemStatementValue');
        String kendoRtfDecision = Apexpages.currentPage().getParameters().get('DecisionValue');
        String topicMultiSelect = Apexpages.currentPage().getParameters().get('TopicMultiSelect');
        
        List<String> lstTopics = topicMultiSelect.split(',');
        
        topicAssignmentList = [SELECT EntityId, TopicId,Topic.Name FROM TopicAssignment where EntityId = : decision.Id limit 1000];
        if(!topicAssignmentList.isEmpty()){
           // if(FLS.topicAssignmentDeletable()){  
                 delete topicAssignmentList;
           // }
        }
        
        List<Topic> lstTopic = [select id,Name from Topic where Name IN : lstTopics];
        
        List<TopicAssignment> lstTopicAssignment = new List<TopicAssignment>();
        for(String topic : lstTopics){
            for(Topic t : lstTopic){
                if(t.Name == topic){
                    TopicAssignment ta = new TopicAssignment();
                    ta.EntityId = decision.Id;
                    ta.TopicId = t.Id;
                    lstTopicAssignment.add(ta);
                }
            }
        }
        //System.debug('-------FLS.topicAssignmentCreateable()-------->'+FLS.topicAssignmentCreateable());
        if(!lstTopicAssignment.isEmpty()){
            //if(FLS.topicAssignmentCreateable()){
                insert lstTopicAssignment;
           // }
        }
        selectedTopics = '';
        if(topicMultiSelect != null && topicMultiSelect != 'null'){
            selectedTopics = topicMultiSelect;
        }
        System.debug('--------selectedTopics--------->'+selectedTopics);
        lstTopicAssigned.clear();
        set<String> setTopicsNew = new set<String>();
        setTopicsNew.addAll(lstTopics);
        for(String st : setTopics){
            TopicAssigned ta = new TopicAssigned();
            ta.TopicName = st;
            if(setTopicsNew.contains(st)){  
                System.debug('-------st-------->'+st);
                ta.TopicSelected = 'selected';
            }
            lstTopicAssigned.add(ta);
        }
        
        kendoRtfProblemstatement  = removeHTML(kendoRtfProblemstatement);
        kendoRtfDecision = removeHTML(kendoRtfDecision);
        
        Decision__c decisionPhase = [select id,Phase__c from Decision__c where Id =:  decision.Id];
        
        if(FLS.decisionUpdateable()) {
            decision.Problem_Idea_Advice__c = kendoRtfProblemstatement; 
            decision.Decision_Taken__c = kendoRtfDecision;
            decision.Phase__c =  decisionPhase.Phase__c;
            update decision;
             
            Timing__c timeRec = [select id,End_Date_Time__c from Timing__c where Stage__c = 'Propose' and Related_To_ID__c=:decision.Id];
            timeRec.End_Date_Time__c = decision.Due_Date__c;
            if(FLS.timingUpdateable()) {
                update timeRec;
            }
            UpdateNearestDueDate.updateAllDeicisons(string.valueOf(decision.Id));
        }
        decisonSaveStatus = 'Success';
    } 
    public void dummyCall2(){
        decisonSaveStatus= 'Fail';
    }
    
    public void decisionRTFUpdateDecide() {
        String kendoRtfProblemstatement = Apexpages.currentPage().getParameters().get('ProblemStatementValue1');
        String kendoRtfDecision = Apexpages.currentPage().getParameters().get('DecisionValue1');
        //kendoRtfProblemstatement  = removeHTML(kendoRtfProblemstatement);
        //kendoRtfDecision = removeHTML(kendoRtfDecision);
        
        if(FLS.decisionUpdateable()) {
            decision.Problem_Idea_Advice__c = kendoRtfProblemstatement; 
            decision.Decision_Taken__c = kendoRtfDecision;
            decision.Phase__c = 'Propose';
            //CheckforRecrussion.isRTFUpdate = true;
            update decision;
            
            Timing__c timeRec = [select id,End_Date_Time__c from Timing__c where Stage__c = 'Propose' and Related_To_ID__c=:decision.Id];
            timeRec.End_Date_Time__c = decision.Due_Date__c;
            if(FLS.timingUpdateable()) {
                update timeRec;
            }
            UpdateNearestDueDate.updateAllDeicisons(string.valueOf(decision.Id));
        }
        decisonSaveStatus = 'Success';
        
    }
    
    private String removeHTML(String htmlString) { 
        String noHTMLString = '';
        if(htmlString != null) {
            noHTMLString = htmlString.replaceAll('&amp;', '&'); 
            noHTMLString = noHTMLString.replaceAll('&quot', '\"');
            noHTMLString = noHTMLString.replaceAll('&#039;', '\'');
            noHTMLString = noHTMLString.replaceAll('&lt;', '<');
            noHTMLString = noHTMLString.replaceAll('&gt;', '>');
        }
        return noHTMLString;
    }
    
    private String stripHTML(String htmlString) { 
        String noHTMLString = '';
        if(htmlString != null) {
            noHTMLString = htmlString.replaceAll('&','&amp;'); 
            noHTMLString = noHTMLString.replaceAll('\"','&quot');
            noHTMLString = noHTMLString.replaceAll('\'','#039;');
            noHTMLString = noHTMLString.replaceAll( '<',' &lt; ');
            noHTMLString = noHTMLString.replaceAll('>',' &gt; ');
        }
        return noHTMLString;
    }    
   
    // PDF generate
    public Pagereference decisionPDFGenerate() {
        pageReference decisionPDF= new pageReference('/apex/DecisionPDFGenerate?id='+ApexPages.currentPage().getParameters().get('id'));
        
        if(loggedInSocialPeople == null) {
            loggedInSocialPeople = new Social_Input__c();
            if([select id  from Social_Input__c where User__c =: userInfo.getUserId() AND Decision__c =: decisionId].size() > 0 ) {
                loggedInSocialPeople = [Select s.Veto_Rights__c,s.Stance_Approval_Status__c, s.User__c, s.SystemModstamp, s.Select_People__c, s.SYS_Tab_View_Tasks__c, s.SYS_Tab_View_Social_Input__c, s.SYS_Tab_View_Relations__c, s.SYS_Tab_View_Quality__c, s.SYS_Tab_View_History__c, s.SYS_Tab_View_Attachments__c, s.SYS_Tab_View_Approvals__c, s.SYS_Tab_View_Activites__c, s.Role__c, s.Role_Acceptance_Status__c, s.Role_Acceptance_Required__c, s.Result__c, s.Responsible__c, s.Rating__c, s.Plan__c, s.OwnerId, s.Outcome__c, s.Name_of_the_User__c, s.Name, s.Mood__c, s.Like__c, s.LastModifiedDate, s.LastModifiedById, s.Is_Group__c, s.IsDeleted, s.Informed__c, s.Id, s.Group_Name__c, s.GroupId__c, s.Final_Approval_Status__c, s.Effort__c, s.Dislike__c, s.Description__c, s.Decision__c, s.CreatedDate, s.CreatedById, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c, s.Accountable__c From Social_Input__c s where User__c =: userInfo.getUserId() AND Decision__c =: decisionId limit 1 ];
            }
        }
        if(loggedInSocialPeople.Responsible__c || loggedInSocialPeople.Accountable__c || loggedInSocialPeople.Backup_for_Accountable__c || chkRecPermission==true){
            if(decisionPDF != null){
                attachment = new Attachment();
                attachment.Name = 'Decision_PDF_'+System.now().year()+'_'+System.now().month()+'_'+System.now().day()+'_'+System.now().hour()+'_'+System.now().minute()+'_'+System.now().second()+'.pdf';
                attachment.ParentId = decision.id;
                attachment.body = Test.isRunningTest() ? Blob.valueOf('Test') : decisionPDF.getContent();
                if(FLS.attachmentCreateable()){
                     insert attachment;
                     attachment = new Attachment(); // clears the viewstate
                }
            }
        }
        return decisionPDF;
    }
    
    public Attachment attachment{get;set;}
    public Attachment attachmentUpdate{get;set;}
    public Blob fileBody {get;set;}  
    public Blob fileBodyUpdate {get;set;}  
    
    public PageReference uploadDecisionImage() {
    
        if(fileBody != null){  
            attachment = new Attachment();
            attachment.Name = String.valueOf(decision.Id);
            attachment.ParentId = decision.id;
            attachment.body = fileBody;
            attachment.IsPrivate = false;
            imageURLonDecision ='';
            if(FLS.attachmentCreateable()){
                 insert attachment;
                 attachment = new attachment(); // clears the viewstate
            }
            pageReference page = new pageReference('/'+decision.Id);
            page.setRedirect(true);
            return page;
        }else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please select the image file to be uploaded.'));         
            pageReference page = new pageReference('/'+decision.Id);
            page.setRedirect(true);
            return page;
        }
    }
   
    public PageReference updateDecisionImage(){
    
       //if( SystemValidator.DecisionView_uploadDecisionImage() =='FALSE')
       // return null;
       if(fileBodyUpdate != null)  {
       
           attachmentUpdate = new Attachment();
           attachmentUpdate.body = fileBodyUpdate; 
           attachmentUpdate.Name = String.valueOf(decision.Id);
           attachmentUpdate.ParentId = decision.Id;
           attachmentUpdate.IsPrivate = false;
           if(FLS.attachmentCreateable()){    
               insert attachmentUpdate;
               attachmentUpdate = new Attachment(); // clears the viewstate
           }
           
            pageReference page = new pageReference('/'+decision.Id);
            page.setRedirect(true);
            return page;
       }else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please select the image file to be uploaded.'));         
            pageReference page = new pageReference('/'+decision.Id);
            page.setRedirect(true);
            return page;
        }
    }
   
    public pageReference cancelUploadImage(){
        pageReference page = new pageReference('/'+decision.Id);
        page.setRedirect(true);
        return page;
    }
    
    public pageReference customDelete(){
        if(FLS.decisionDeletable()){
            delete decision;
        }
        pageReference page = new pageReference('/apex/DecisionTab');
        page.setRedirect(true);
        return page;
    }
    
    public pageReference deleteUploadImage(){
        String attachmentName = string.valueOf(decision.Id);
        List<Attachment> attachmentList = [select id,body from Attachment WHERE ParentID =: decision.id  AND Name=:decision.id limit 1];
        if (FLS.attachmentUpdateable()){
            attachmentList[0].Name = 'ToBeDeletedCustomAttachment';
            update  attachmentList[0];
        }
        pageReference page = new pageReference('/'+decision.Id);
        page.setRedirect(true);
        return page;  
    }
   
    public void showImageOnDecision(){
        List<Attachment> attachments = [select id,body from Attachment WHERE ParentID =: decision.id  AND Name=:decision.id limit 1];
   
        if(attachments.size()>0){
            //attachment = attachments[0];
            imageURLonDecision='/servlet/servlet.FileDownload?file=';
            imageURLonDecision=imageURLonDecision+attachments[0].id;
            
        }  
    }
    
    // pulse in command center 
     @RemoteAction
    public static void updatePulse(String pulseStatus, String decisionId){
        Decision__c decision = new Decision__c();
         decision.Id = decisionId;
         decision.Progress__c = pulseStatus;
        if(FLS.decisionUpdateable()){
            update decision;
        }
     
    }

      @RemoteAction
    public static JsonExistingData decisionPhaseChangewithRTF(String problemStatemnt, String decisionStatemnt, String decisionId, String socialInputId, String phaseValue, String reasonForClose, String comments  ) {
        
        Decision__c decision = [select id, Name, Title__c, Phase__c, Status__c from Decision__c where Id =: decisionId];
        System.debug('-----------problemStatemnt--------'+problemStatemnt);
        System.debug('-----------decisionStatemnt--------'+decisionStatemnt);
        decision.Problem_Idea_Advice__c = problemStatemnt; 
        decision.Decision_Taken__c = decisionStatemnt;
        decision.Phase__c = 'Propose';
       
        if(FLS.decisionUpdateable()){
            update decision;
        }
        Social_Input__c socialInput = [Select s.Veto_Rights__c,s.Stance_Approval_Status__c, s.User__c, s.SystemModstamp, s.SYS_Tab_View_Activites__c, s.SYS_Tab_View_History__c, s.Final_Approval_Status__c, s.SYS_Tab_View_Tasks__c, s.SYS_Tab_View_Social_Input__c, s.SYS_Tab_View_Relations__c, s.SYS_Tab_View_Quality__c, s.SYS_Tab_View_Attachments__c, s.SYS_Tab_View_Approvals__c, s.Role_Acceptance_Status__c, s.Role_Acceptance_Required__c, s.Result__c, s.Responsible__c, s.Rating__c, s.Outcome__c, s.Name, s.Mood__c, s.Like__c, s.LastModifiedDate, s.LastModifiedById, s.Informed__c, s.Id, s.Effort__c, s.Dislike__c, s.Decision__c, s.CreatedDate, s.CreatedById, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c From Social_Input__c s where s.Id =: socialInputId ];
        System.debug('-----------Social Input Value--------'+socialInput);
        System.debug('-----------Social Input Value Final_Approval_Status__c--------'+socialInput.Final_Approval_Status__c);
        // initialize map of decision id v/s timing data
        map<Id, List<Timing__c>> decisionIdtimingListMap = new map<Id, List<Timing__c>>();
        
        for(Timing__c timing : [Select t.Start_Date_Time__c, t.Stage__c, t.Related_To_ID__c, t.End_Date_Time__c, t.Elapsed_Time__c, t.Difference__c, t.Actual_Start_Date__c, t.Actual_End_Date__c From Timing__c t where t.Related_To_ID__c =: decision.Id]) {
            
            List<Timing__c> timingList = decisionIdtimingListMap.get(timing.Related_To_ID__c);
            if(timingList == null ) {
                timingList = new List<Timing__c>();
                decisionIdtimingListMap.put(timing.Related_To_ID__c, timingList);
            }
            timingList.add(timing);
        }
        
        map<String, Timing__c> phasestimingMap = new map<String, Timing__c>();
        
        for(Timing__c timing : decisionIdtimingListMap.get(decision.Id)) {
            phasestimingMap.put(timing.Stage__c, timing);
        }
        
        DateTime toBeUpdatedNearestDueDate;
        if(phaseValue == 'Propose') {
            System.debug('-----phaseValue-------------propose--------------'+phaseValue);
            decision.Phase__c = 'Propose';
            decision.Status__c = 'Undecided';
            
            //calculate nearest due date
            Timing__c decide = phasestimingMap.get('Propose');
            Timing__c approve = phasestimingMap.get('Decide');
            Timing__c execute = phasestimingMap.get('Execute');
            Timing__c evaluate = phasestimingMap.get('Evaluate');
            Timing__c close = phasestimingMap.get('Close');
            
            if(close.End_Date_Time__c != null)
                toBeUpdatedNearestDueDate = close.End_Date_Time__c;
            if(close.Start_Date_Time__c != null)
                toBeUpdatedNearestDueDate = close.Start_Date_Time__c;
            if(evaluate.End_Date_Time__c != null)
                toBeUpdatedNearestDueDate = evaluate.End_Date_Time__c;
            if(evaluate.Start_Date_Time__c != null)
                toBeUpdatedNearestDueDate = evaluate.Start_Date_Time__c;
            if(execute.End_Date_Time__c != null)
                toBeUpdatedNearestDueDate = execute.End_Date_Time__c;
            if(execute.Start_Date_Time__c != null)
                toBeUpdatedNearestDueDate = execute.Start_Date_Time__c;
            if(approve.End_Date_Time__c != null)
                toBeUpdatedNearestDueDate = approve.End_Date_Time__c;
            if(approve.Start_Date_Time__c != null)
                toBeUpdatedNearestDueDate = approve.Start_Date_Time__c;
            if(decide.End_Date_Time__c != null)
                toBeUpdatedNearestDueDate = decide.End_Date_Time__c;
                
            if(close.End_Date_Time__c == null && close.Start_Date_Time__c == null && evaluate.End_Date_Time__c == null && evaluate.Start_Date_Time__c == null && execute.End_Date_Time__c == null && execute.Start_Date_Time__c == null && approve.End_Date_Time__c == null && approve.Start_Date_Time__c == null && decide.End_Date_Time__c == null)
                toBeUpdatedNearestDueDate = null;
            
            System.debug('------toBeUpdatedNearestDueDate---propose---------'+toBeUpdatedNearestDueDate);
            
            // update nearest due date
            decision.Nearest_Due_Date__c = toBeUpdatedNearestDueDate;
        }
         
        
        if(FLS.decisionUpdateable()) {
            update decision;
            System.debug('-----decision-------------'+decision.Decision_Taken__c );
            
            // create a chatter post when a decision is proposed 
            if( FLS.FeedItemCreatable() && decision.Phase__c == 'Propose') 
            {   //Integer.valueOf('aa');
                
                Decision__c decisionQry  =[select id,Problem_Idea_Advice__c,Decision_Taken__c,ownerid from Decision__c where id =:decisionId Limit 1];
                Id userId=decision.ownerid;
                System.debug('-----decision-------------decision.Decision_Taken__c'+decision.Decision_Taken__c+decisionId+'--'+decision.ownerid);
                User usr = [Select id,name from User where id=:decisionQry.ownerid Limit 1];
                //String postText='The following decision has been proposed:'+'\n'+'\n'+'"'+decision.Decision_Taken__c+'"'+'\n'+'\n'+usr.name+' '+'needs your personal stance.';
                String postText='Here is the proposed Decision, read it and give your Stance.'+'\n'+'\n'+'Decision:'+'\n'+'"'+decision.Decision_Taken__c+'"'+'\n'+'\n'+'(hint: it’s done in the command center)';
                mentionTextPostPropose( usr.id, postText, decisionId);
                
                /*FeedItem post = new FeedItem();
                post.ParentId =  decision.Id;  
                post.Body =      'The decision has been proposed'  ;
                post.type = 'TextPost';                   
                post.Title = decision.id;  
                post.createdbyid = decision.ownerid;
                insert post;*/         
            }   
            System.debug('-----Decision phase-------------'+decision.Phase__c);
        }
        
        socialInput = [Select s.Veto_Rights__c, s.User__c, s.SystemModstamp, s.SYS_Tab_View_Activites__c,s.Stance_Approval_Status__c, s.SYS_Tab_View_History__c, s.SYS_Tab_View_Tasks__c, s.SYS_Tab_View_Social_Input__c, s.SYS_Tab_View_Relations__c, s.SYS_Tab_View_Quality__c, s.SYS_Tab_View_Attachments__c, s.SYS_Tab_View_Approvals__c, s.Role_Acceptance_Status__c, s.Role_Acceptance_Required__c, s.Result__c, s.Responsible__c, s.Rating__c, s.Outcome__c, s.Name, s.Mood__c, s.Like__c, s.LastModifiedDate, s.LastModifiedById, s.Informed__c, s.Id, s.Final_Approval_Status__c, s.Effort__c, s.Dislike__c, s.Decision__c, s.CreatedDate, s.CreatedById, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c, s.Accountable__c From Social_Input__c s where s.Id =: socialInputId ];
        System.debug('-----------Social Input Value--------'+socialInput);
        System.debug('-----------Social Input Value Final_Approval_Status__c--------'+socialInput.Final_Approval_Status__c);
        JsonExistingData jsonExistingData = new JsonExistingData();
        jsonExistingData.commonHistory = viewHistory(decisionId);
        jsonExistingData.decisionObject = decision;
        jsonExistingData.socialIndividual = socialInput;
        jsonExistingData.timingObject = timingTab(decisionId);
        jsonExistingData.peopleObject = viewSocialPeopleTabWithSearch(decisionId, null, '');
        jsonExistingData.approvalObject = approvalTab(decisionId);
          
        return jsonExistingData;
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
    @remoteAction
    public static void Test(){
    }
    
    // Wrapper onject to hold points
    public class historyPointWrapper{
         public decimal newValue {get;set;}
         public decimal oldValue {get;set;}
         public long  changedDate {get;set;}
         public string  phaseValue {get;set;}
    }
    // wrapper to hold plot band
    public class plotband{ 
         public long  fromband {get;set;}
         public long  toband {get;set;}
    }
    // Wrapper to hold avarge and individuals line points
    public class historyLineWrapper{
     public list<historyPointWrapper> moodLine {get;set;}
     public list<historyPointWrapper> averageMoodLine {get;set;}
     public list<plotband>   plotBands {get;set;}
     public long   graphMindate {get;set;}  // min x axis date
     public long   graphMaxdate {get;set;}  //max x axis  date
    }
    
    @remoteAction
    public static string socialGraph(String sosialInputId){  
      // Query social and social input object for  the given person
      Social_Input__c socialInput  =[  SELECT  Decision__c FROM Social_Input__c where id =: sosialInputId];
      Social__c social  =[  SELECT   id FROM Social__c  where Related_To_ID__c  =: socialInput.Decision__c]; 
      
      List<Social_Input__History>  socialInputHistory  =[  SELECT CreatedById,CreatedDate,Field,Id,IsDeleted,NewValue,OldValue,ParentId FROM Social_Input__History where ParentId =: sosialInputId order by createddate asc];
      
      
      List<Social__History>  socialHistory  =[  SELECT CreatedById,CreatedDate,Field,Id,IsDeleted,NewValue,OldValue,ParentId FROM Social__History where parentid =: social.id order by createddate asc]; 
      historyLineWrapper historyLine  = new historyLineWrapper();
      historyLine.moodLine            = new list<historyPointWrapper>();
      historyLine.averageMoodLine     = new list<historyPointWrapper>();
      historyLine.plotBands           = new list<plotband>();
      Map<long,string> timeTophase   =  new  Map<long,string>();
        for(  Social__History history :socialHistory){
               if(history.Field == 'Average_Mood__c'){
                    historyPointWrapper historypoint = new historyPointWrapper();
                    historypoint.newValue  = (Decimal)(history.NewValue);
                    historypoint.oldValue  = (Decimal)(history.OldValue);
                    historypoint.changedDate  = history.CreatedDate.getTime(); 
                    historyLine.averageMoodLine.add(historypoint);
                }  
        }
        for(  Social_Input__History history :socialInputHistory){
            if(history.Field == 'Mood__c'){
                historyPointWrapper historypoint = new historyPointWrapper();
                historypoint.newValue  = (Decimal)(history.NewValue);
                historypoint.oldValue  = (Decimal)(history.OldValue);
                historypoint.changedDate  = history.CreatedDate.getTime();  
                historyLine.moodLine.add(historypoint);
            }
          
        }
        
        // Get timing records to get phase
        for(Timing__c t : [Select id ,Actual_End_Date__c,Actual_Start_Date__c,Stage__c from Timing__c where Related_To_ID__c =: socialInput.decision__c order by  Stage_No__c asc ])    
        {
             // Grpah starts from decision created date so draft start 
             if(t.Stage__c == 'Draft')
             historyLine.graphMindate = t.Actual_Start_Date__c.getTime();  
             // add plot bans for x axis here 
             if( t.Actual_Start_Date__c != null){  
                  plotband  band = new plotband();
                  band.fromband  =  t.Actual_Start_Date__c.getTime();
                  band.toband    =  ( t.Actual_End_Date__c != null ) && ( t.Actual_End_Date__c != t.Actual_Start_Date__c   )  ? t.Actual_End_Date__c.getTime(): System.now().getTime() ;
                  historyLine.plotBands.add(band);
             }
        }  
        
        historyLine.graphMaxdate = System.now().getTime(); 
        return  JSON.serialize(historyLine);
      }
      
    //For contribution tab
    @remoteAction
    public static string contributionTab(String decisionId){
        set<Id> setUserIds = new set<Id>();
        List<contributionWrapperClass> lstContributionWrapperClass = new List<contributionWrapperClass>();
        System.debug('---------decisionId--------->'+decisionId);
        List<Social_Input__c> lstSocialInput = [select id,User__c,Decision__c,User__r.Name,Accountable__c,Backup_for_Accountable__c,User__r.SmallPhotoUrl from Social_Input__c where Decision__c = : decisionId and Is_Group__c = false];
        for(Social_Input__c si : lstSocialInput){
            setUserIds.add(si.User__c);
        }
        
        map<Id,Decision__Feed> mapDecisionFeed = new map<Id,Decision__Feed>([select CommentCount,ContentDescription,ContentFileName,ContentSize,ContentType,CreatedById,CreatedDate,Id,InsertedById,IsDeleted,LastModifiedDate,LikeCount,LinkUrl,ParentId,RelatedRecordId,SystemModstamp,Title,Type FROM Decision__Feed where ParentId = : decisionId]);
        List<FeedComment> lstFeedComment = new List<FeedComment>();
         
        List<Task> lstTask = [select id,Status,isClosed,Task_Closed_Date__c,ActivityDate,CreatedById,OwnerId from Task where whatId = : decisionId and (OwnerId IN : setUserIds or CreatedById IN : setUserIds)];
        set<Id> taskIds = new set<Id>();
        for(Task t : lstTask){
            taskIds.add(t.Id);
        }
        List<TaskFeed> lstTaskFeed = [select id,ParentId,CreatedById,RelatedRecordId,LikeCount from TaskFeed where ParentId IN : taskIds];
        set<Id> setIds = new set<Id>();
        setIds.addAll(mapDecisionFeed.keySet());
        for(TaskFeed tf : lstTaskFeed){
            setIds.add(tf.Id);
        }
        if(setIds != null){    
            lstFeedComment = FutureMethodController.returnFeedComment(setIds);
        }
        List<Relations__c> lstRelations = [select Id,CreatedById from Relations__c where (Parent_ID__c = : decisionId or Child_ID__c = : decisionId) and CreatedById IN : setUserIds];
        List<Attachment> lstAttachment = [select Id,CreatedById from Attachment where CreatedById IN : setUserIds and ParentId = : decisionId];
        List<Timing__c> lstTiming = [select Id,Related_To_ID__c,Actual_End_Date__c,End_Date_Time__c,Stage__c from Timing__c where Related_To_ID__c = : decisionId];
        System.debug('-------lstTiming--------->'+lstTiming);
        System.debug('-------lstTiming--------->'+lstTiming.size());
        for(Social_Input__c si : lstSocialInput){
            contributionWrapperClass socialInputWrap = new contributionWrapperClass();
            socialInputWrap.userId = si.User__c != null ? si.User__c : '' ;
            socialInputWrap.recId = si.id;
            socialInputWrap.userName = si.User__c != null ? si.User__r.Name : '';
            socialInputWrap.userImage = si.User__c != null ? si.User__r.SmallPhotoUrl : '';
            socialInputWrap.userURL = si.User__c != null ? '/'+si.User__c : '';
            socialInputWrap.chtrPostCreatedNo = 0;
            socialInputWrap.chtrCommentReceivedNo = 0;
            socialInputWrap.fileUploadedNo = 0;
            socialInputWrap.chtrLikeReceivedNo = 0;
            if(mapDecisionFeed != null){
                for(Decision__Feed df : mapDecisionFeed.values()){
                    if(si.User__c != null && df.CreatedById == si.User__c){
                        socialInputWrap.chtrPostCreatedNo = socialInputWrap.chtrPostCreatedNo + 1;
                        for(FeedComment fc : lstFeedComment){
                            if(fc.FeedItemId == df.Id && si.User__c != fc.CreatedById){
                                socialInputWrap.chtrCommentReceivedNo = socialInputWrap.chtrCommentReceivedNo + 1;
                            }
                        }
                        socialInputWrap.chtrLikeReceivedNo = socialInputWrap.chtrLikeReceivedNo + df.LikeCount;
                        if(df.RelatedRecordId != null){
                            socialInputWrap.fileUploadedNo = socialInputWrap.fileUploadedNo + 1;
                        }
                    }
                }
            }
            for(TaskFeed df : lstTaskFeed){
                if(si.User__c != null && df.CreatedById == si.User__c){
                    socialInputWrap.chtrPostCreatedNo = socialInputWrap.chtrPostCreatedNo + 1;
                    for(FeedComment fc : lstFeedComment){
                        if(fc.FeedItemId == df.Id && si.User__c != fc.CreatedById){
                            socialInputWrap.chtrCommentReceivedNo = socialInputWrap.chtrCommentReceivedNo + 1;
                        }
                    }
                    socialInputWrap.chtrLikeReceivedNo = socialInputWrap.chtrLikeReceivedNo + df.LikeCount;
                    if(df.RelatedRecordId != null){
                        socialInputWrap.fileUploadedNo = socialInputWrap.fileUploadedNo + 1;
                    }
                }
            }
            for(Attachment att : lstAttachment){
                if(si.User__c != null && att.CreatedById == si.User__c){
                    socialInputWrap.fileUploadedNo = socialInputWrap.fileUploadedNo + 1;
                }
            } 
            socialInputWrap.chtrCommentCreatedNo = 0;
            for(FeedComment fc : lstFeedComment){
                if(si.User__c != null && fc.CreatedById == si.User__c){
                    socialInputWrap.chtrCommentCreatedNo = socialInputWrap.chtrCommentCreatedNo + 1;
                    if(fc.RelatedRecordId != null){
                        socialInputWrap.fileUploadedNo = socialInputWrap.fileUploadedNo + 1;
                    }
                }
            } 
            socialInputWrap.taskCreatedNo = 0;
            socialInputWrap.taskReceivedNo = 0;
            socialInputWrap.taskCompletedNo = 0;
            socialInputWrap.taskOverDueNo = 0;
            socialInputWrap.taskDueDateViolatedNo = 0;
            for(Task t : lstTask){
                if(si.User__c != null && t.CreatedById == si.User__c){
                    socialInputWrap.taskCreatedNo = socialInputWrap.taskCreatedNo + 1;
                }
                if(si.User__c != null && t.OwnerId == si.User__c){
                    socialInputWrap.taskReceivedNo = socialInputWrap.taskReceivedNo + 1;
                    if(t.Status == 'Completed'){
                        socialInputWrap.taskCompletedNo = socialInputWrap.taskCompletedNo + 1;
                    }
                    if(!t.isClosed && t.ActivityDate < System.today()){
                        socialInputWrap.taskOverDueNo = socialInputWrap.taskOverDueNo + 1;
                    }
                    if(t.isClosed && t.ActivityDate < t.Task_Closed_Date__c){
                        socialInputWrap.taskDueDateViolatedNo = socialInputWrap.taskDueDateViolatedNo + 1;
                        System.debug('----------socialInputWrap.taskDueDateViolatedNo--------->'+socialInputWrap.taskDueDateViolatedNo);
                    }
                }
            }
            for(Timing__c t : lstTiming){
                if(t.End_Date_Time__c < t.Actual_End_Date__c){
                    if(si.Accountable__c || si.Backup_for_Accountable__c){  
                        socialInputWrap.taskDueDateViolatedNo = socialInputWrap.taskDueDateViolatedNo + 1;
                    }
                }
            }
            socialInputWrap.relationshipCreatedNo = 0;
            for(Relations__c r : lstRelations){
                if(si.User__c != null && r.CreatedById == si.User__c){
                    socialInputWrap.relationshipCreatedNo = socialInputWrap.relationshipCreatedNo + 1;
                }
            }
            lstContributionWrapperClass.add(socialInputWrap);
        }
        jsonContribution = JSON.serialize(lstContributionWrapperClass);
        return jsonContribution;
    }
    
    // wrapper class of contribution tab.
    public Class contributionWrapperClass{
        public String recId {get;set;}
        public String userName{get;set;}
        public String userId{get;set;}
        public String userURL{get; set;}
        public String redirectUrl{get;set;}
        public string userImage{get;set;}
        public integer chtrPostCreatedNo{get;set;}
        public integer chtrCommentCreatedNo{get;set;}
        public integer chtrCommentReceivedNo{get;set;}
        public integer chtrLikeReceivedNo{get;set;}
        public integer chtrLikeGivenNo{get;set;}
        public integer taskCreatedNo{get;set;}
        public integer taskReceivedNo{get;set;}
        public integer taskCompletedNo{get;set;}
        public integer taskOverDueNo{get;set;}
        public integer relationshipCreatedNo{get;set;}
        public integer fileUploadedNo{get;set;}
        public integer taskDueDateViolatedNo{get;set;}
    } 
    
   
    
     @remoteAction
    public static void saveClassification(String decisionId,String decisionType, String priority,String topics){
        Decision__c decision = new Decision__c(id=decisionId);
        decision.Decision_Type__c = decisionType;
        decision.Priority__c = priority;
        update decision;
        List<String> lstTopics = topics.trim().split(',');
        system.debug(topics); 
        List<TopicAssignment > topicAssignmentList = [SELECT EntityId, TopicId,Topic.Name FROM TopicAssignment where EntityId = : decision.Id limit 1000];
        if(!topicAssignmentList.isEmpty()){
           // if(FLS.topicAssignmentDeletable()){  
                 delete topicAssignmentList;
           // }
        }
        
        List<Topic> lstTopic = [select id,Name from Topic where Name IN : lstTopics];
        
        List<TopicAssignment> lstTopicAssignment = new List<TopicAssignment>();
        for(String topic : lstTopics){
            for(Topic t : lstTopic){
                if(t.Name == topic){
                    TopicAssignment ta = new TopicAssignment();
                    ta.EntityId = decision.Id;
                    ta.TopicId = t.Id;
                    lstTopicAssignment.add(ta);
                }
            }
        }
        //System.debug('-------FLS.topicAssignmentCreateable()-------->'+FLS.topicAssignmentCreateable());
        if(!lstTopicAssignment.isEmpty()){
            //if(FLS.topicAssignmentCreateable()){
                insert lstTopicAssignment;
           // }
        }
        
        
    }
}