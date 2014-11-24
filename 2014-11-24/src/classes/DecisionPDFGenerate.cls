/*
 Created by:Neha
 Last Modified by: Neha
 Style: Force.com & Metro
 Description: This controleer is used for decision PDF generate. 
 The objective of the controller is to query the database for Decision, relations, collaborators, task and activities.
*/

public with sharing class DecisionPDFGenerate{
    
    public Decision__c decision {get;set;}
    
    // Initialize relations list
    public List<Relations__c> relationList {get;set;}
    public List<Relations__c> relationList1 {get;set;}
    
    // Initialize task event list
    public List<TaskEvent> taskEventList {get;set;}
    
    // Initialize task event list
    public List<TaskEventHistory> taskEventHistoryList {get;set;}
    
    // user locale date fromat as string 
    public static String dateFormat {get;set;}
    
    // user locale datetime fromat as string 
    public static String dateTimeFormat {get;set;}
    
     // Initialize Timing list
    public List<Timing__c> timingList {get; set;}
    
    // Initialize Attachment list
    public List<Attachment> attachmentList {get; set;}
    
    // Initialize Note list
    public List<Note> noteList {get; set;}
    
    
    // Initialize FeedItem list
    public List<FeedItemWrapper> feedsList {get; set;}
    // 
    public List<CommonHistory> commonHistoryList {get; set;}
    
    public List<SocialInputWrapper> socialInputWrapperList {get; set;}
    
    GeneralInformation genralInfo  = new GeneralInformation();
    public String currentDateTime {get; set;}
    
    public String selectedTopics {get; set;}
    
    // Defining constructor
    public DecisionPDFGenerate(ApexPages.StandardController controller){
         // initialize General information class to get user locale date format and images from static resouces url //
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=8');  
        // assign user locale date format as string 
        dateFormat = genralInfo.MapValuesDateFormate();
        
        // assign user locale datetime format as string 
        dateTimeFormat = genralInfo.MapValuesDateTime(); 
        currentDateTime = System.now().format(dateTimeFormat);
        selectedTopics = '';
        decision = [Select ID, Name, Title__c, Problem_Idea_Advice__c,Private__c,Estimated_Investment_Desc__c,Estimated_Direct_Cost_Desc__c,Estimated_Revenue_Desc__c,Estimated_Net_Present_Value_Desc__c,Estimated_People_Involved_Desc__c,Estimated_Full_time_Equivalent_Desc__c,Actual_Investment_Desc__c,Actual_Direct_Cost_Desc__c,Actual_Revenue_Desc__c,Actual_Net_Present_Value_Desc__c,Actual_People_Involved_Desc__c,Actual_Full_time_Equivalent_Desc__c,Estimated_Revenue__c ,Actual_Revenue__c,Identifier__c, Decision_Taken__c, Decision_Type__c, Decision_Approach__c, Category__c, Decision_Making_Style__c, Priority__c, Estimated_Investment__c, Estimated_Direct_Cost__c, Estimated_Net_Present_Value__c, Estimated_People_Involved__c, Estimated_Full_time_Equivalent_FTE__c, Actual_Investment__c, Actual_Direct_Cost__c, Actual_Net_Present_Value__c, Actual_People_Involved__c, Actual_Full_time_Equivalent_FTE__c, Valid_From__c, Valid_Until__c, Point_of_No_Return__c, Due_Date__c, Status__c from Decision__c where ID =: ApexPages.currentPage().getParameters().get('id')];
        
        // Fetching Timing for related decision
        timingList = [Select t.Id,t.Stage_No__c, t.Actual_End_Date__c, t.Actual_Start_Date__c, t.Start_Date_Time__c, t.Stage__c, t.Related_To_ID__c, t.End_Date_Time__c, t.Elapsed_Time__c, t.Difference__c, t.Comments__c From Timing__c t where t.Related_To_ID__c = : decision.Id order by t.Stage_No__c asc];
         
        // Fetching Attachemnt and Notes related to decision
        attachmentList = [Select a.ParentId, a.OwnerId, a.owner.Name,  a.Name, a.LastModifiedDate, a.Id, a.CreatedById From Attachment a where a.parentId =: decision.Id and a.Name != : decision.Id ORDER BY a.CreatedDate ];
        noteList = [Select a.ParentId, a.OwnerId,a.Title, a.owner.Name,a.Body, a.LastModifiedDate, a.Id, a.CreatedById From Note a where a.parentId =: decision.Id ORDER BY a.CreatedDate DESC ];
        
         
       List<TopicAssignment> topicAssignmentList = [SELECT EntityId, TopicId,Topic.Name FROM TopicAssignment where EntityId = : decision.Id limit 1000];
        for(TopicAssignment ta : topicAssignmentList){  
            selectedTopics = selectedTopics+','+ta.Topic.Name;
        }
        selectedTopics = selectedTopics.replaceFirst(',','');
         
       // Call relation method
        viewRelation(); 
        
        // Call task and event method
        viewTaskEvent();
        
        // Call view method
        viewHistory(decision.Id);
        
        // Call view method
        viewChatter(decision.Id);
        
        // Call people method
        List<Social_Input__c> lstSocailInput = [select id,User__r.Name,Role__c,Role_Acceptance_Status__c,GroupId__c,Final_Approval_Status__c,Stance_Approval_Status__c,Backup_for_Accountable__c,Veto_Rights__c from Social_Input__c where Decision__c = : controller.getId()];
        socialInputWrapperList = new List<SocialInputWrapper>();
        for(Social_Input__c si : lstSocailInput){
            SocialInputWrapper siw = new SocialInputWrapper();
            siw.socInput = si;
            if(si.User__r.Name != null){
                siw.usrGrpName = si.User__r.Name;   
            } else {
                siw.usrGrpName = genralInfo.groupMap.get(si.GroupId__c).Name;
            }
            socialInputWrapperList.add(siw);
        } 
        

    }
    
    public void viewRelation(){
         
        relationList = [Select ID, Name,Child_ID__c,Child_Object_Name__c,Child_Record_Name__c,Child_Relation__c,Strength__c,Notes__c,Parent_ID__c,Parent_Object_Name__c,Parent_Record_Name__c,Parent_Relation__c from Relations__c where Type__c = 'Relation' AND Child_Id__c =: decision.ID];
        relationList1 = [Select ID, Name,Child_ID__c,Child_Object_Name__c,Child_Record_Name__c,Child_Relation__c,Strength__c,Notes__c,Parent_ID__c,Parent_Object_Name__c,Parent_Record_Name__c,Parent_Relation__c from Relations__c where Type__c = 'Relation' AND Parent_ID__c =:  decision.ID];
        
    }
    
    
    public void viewTaskEvent(){
        
        //Querying task and event list
        List<Task> taskList = [select id,Subject,ActivityDate,Status,Priority,OwnerId,Owner.Name,CreatedById,CreatedBy.Name from Task where WhatId =: decision.ID];
        List<Event> eventList = [select id,Subject,ActivityDate,OwnerId,Owner.Name,CreatedById,CreatedBy.Name from Event where WhatId =: decision.ID];
        
        // Initialize task event list
        taskEventList = new List<TaskEvent>();
        
        //For task
        for(Task task : taskList){
            if(task.Status != 'Completed'){
                TaskEvent te = new TaskEvent();
                te.id= task.id;
                te.subject = task.Subject;
                te.dueDate = String.valueOf(task.ActivityDate);
                te.status = task.Status;
                te.isTask = 'true';
                te.priority = task.Priority;
                te.assignedTo = task.Owner.Name;
                taskEventList.add(te);
            }
        }
        
        // For event
        for(Event event : eventList){
            if(event.ActivityDate >= date.today()) {
                TaskEvent te = new TaskEvent();
                te.id= event.id;
                te.subject = event.Subject;
                te.dueDate =  String.valueOf(event.ActivityDate);
                te.isTask = 'false';
                te.assignedTo = event.Owner.Name;
                taskEventList.add(te);
            }
        }
        
        // Initialize task event list
        taskEventHistoryList = new List<TaskEventHistory>();
        //For task that are completed
        for(Task task : taskList){
            if(task.Status == 'Completed'){
                TaskEventHistory teh = new TaskEventHistory();
                teh.subject = task.Subject;
                teh.dueDate = String.valueOf(task.ActivityDate);
                teh.isTask = 'true';
                teh.priority = task.Priority;
                teh.createdby = task.CreatedBy.Name;
                teh.status = task.Status;
                teh.assignedTo = task.Owner.Name;
                taskEventHistoryList.add(teh);
            }
        }
        
        // For event that are completed
        for(Event event : eventList){
            if(event.ActivityDate < date.today()) {
                TaskEventHistory teh = new TaskEventHistory();
                teh.id= event.id;
                teh.subject = event.Subject;
                teh.dueDate =  String.valueOf(event.ActivityDate);
                teh.isTask = 'false';
                teh.createdby = event.Owner.Name;
                taskEventHistoryList.add(teh);
            }
        }
    }
    
    public void viewHistory(String decisionId) {
        
        //GeneralInformation genralInfo  = new GeneralInformation();
        
        dateTimeFormat = genralInfo.MapValuesDateTime();
        
        commonHistoryList = new List<CommonHistory>();
        for(Task tt: [select id,WhatId,OwnerId, Owner.Name ,ActivityDate,Status,Priority,Subject,Description from Task where whatId=:decisionId and Status=:'completed' ] ){
             // for generating list of 'History Tab' (Task) 
            CommonHistory chTask = new CommonHistory();
            Time myTime1 = Time.newInstance(00, 00, 00, 00);
            if(tt.ActivityDate != null) {
                Date dt = tt.ActivityDate;
                DateTime dtTime = DateTime.newInstance(dt,myTime1);
                chTask.chDateTime = dtTime;
                chTask.duedate = dtTime.format(dateTimeFormat);
            }
            chTask.status = tt.Status;
            chTask.assignedTo = tt.Owner.Name;
            chTask.assignedToId = genralInfo.useImage.get(tt.OwnerId);
            chTask.subject= tt.Subject;
            chTask.comments = tt.Description == null ? '' : tt.Description;
            chTask.relatedTo = 'Task';
            commonHistoryList.add(chTask);
            //
        }
        
        for(Event ee: [select id,WhatId,OwnerId,Owner.Firstname,Owner.Lastname,ActivityDate,ActivityDateTime,Subject,Description from Event where whatId=:decisionId and ActivityDate < Today ]){
             // for generating list of 'History Tab' (Event)
            CommonHistory chEvent = new CommonHistory();
            chEvent.subject = ee.Subject;
            chEvent.chDateTime = ee.ActivityDateTime;
            chEvent.duedate = ee.ActivityDateTime.format(dateTimeFormat);
            chEvent.assignedTo = ee.Owner.Firstname + ee.Owner.Lastname;
            chEvent.assignedToId = genralInfo.useImage.get(ee.OwnerId);
            chEvent.comments = ee.Description == null ? '' : ee.Description;
            chEvent.relatedTo = 'Event';
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
                    commonHistory ah = new commonHistory();
                    
                    ah.chDateTime = pi.CreatedDate;
                    ah.duedate = pi.CreatedDate.format(dateTimeFormat); 
                    ah.relatedTo = 'Approval';
                    ah.status = pi.StepStatus;
                    ah.assignedTo = pi.Actor.Name;
                    ah.assignedToId = genralInfo.useImage.get(pi.Actor.Id);
                    ah.comments = pi.Comments == null ? '' : pi.Comments ;
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
                ch.duedate = historyDecision.theDate.format(dateTimeFormat);
            }
            ch.relatedTo = 'Field Change';
            ch.assignedTo =historyDecision.who;
            ch.assignedToId =  genralInfo.useImage.get(historyDecision.userId);
            ch.status = (historyDecision.action.replaceAll('<b>', '')).replaceAll('</b>','');
            ch.comments = '';
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
    }
    
        public void viewChatter(String planRecordId) {
     
     
     Decision__Feed[] items = [SELECT CreatedBy.name,   Body, LikeCount,Title ,CreatedDate,   (SELECT CreatedBy.Name,CommentBody,createddate  FROM FeedComments order by createddate ) FROM Decision__Feed WHERE Type != 'TrackedChange' AND ParentId =:planRecordId order by createddate ];
    
    // Map to store values
     Map<id, List<FeedCommentWrapper>> commentsMap = new Map<id, List<FeedCommentWrapper>>();
    
     // map the keys to a empty list to avoid nulls later
     for (Decision__Feed item:items) {
        commentsMap.put(item.id, new List<FeedCommentWrapper>());
     }
    
    
     for (Decision__Feed item:items) {
        
        for (FeedComment comment : item.FeedComments) {
            FeedCommentWrapper CommentWrapper  = new FeedCommentWrapper();         
            CommentWrapper.body            = comment.CommentBody;
            CommentWrapper.createdDate     = comment.createddate.format(dateTimeFormat);
            CommentWrapper.createdBy       = comment.CreatedBy.name;   
            commentsMap.get(item.id).add(CommentWrapper);
        }
     }
     
     feedsList = new List<FeedItemWrapper>();
       for( Decision__Feed feed :items){
            FeedItemWrapper FeedItem = new FeedItemWrapper();
            FeedItem.title  = feed.Title;
            FeedItem.body            = feed.Body;
            FeedItem.createdDate     = feed.createddate.format(dateTimeFormat);
            FeedItem.createdBy       = feed.CreatedBy.name;        
            FeedItem.feedCommentList  = commentsMap.get(feed.id);
            feedsList.add(FeedItem);
       }  
    }
    // Wrapper class section
    
    //Wrapper class for history tab (Plan object)
    public class CommonHistory {
        public DateTime chDateTime {get;set;} // only use for sorting 
        public String subject {get; set;}
        public String duedate {get; set;}
        public String status {get; set;}
        public String assignedTo {get;set;}
        public String assignedToId {get;set;}
        public String comments {get;set;}
        public String relatedTo {get;set;}
    }
    
    //Wrapper class for Task and Event Tab that are open or status is not completed
    public class TaskEvent {
      public String id {get;set;}
      public String subject {get;set;}
      public String dueDate {get;set;}
      public String status {get;set;}
      public String isTask {get;set;}
      public String priority {get;set;}
      public String assignedTo {get;set;}
    }
    
    //Wrapper class for Task and Event Tab that are completed
    public class TaskEventHistory {
      public String id {get;set;}
      public String subject {get;set;}
      public String dueDate {get;set;}
      public String isTask {get;set;}
      public String priority {get;set;}
      public String createdby {get;set;}
      public String status {get; set;}
      public String assignedTo {get;set;}
    }
    
    public class SocialInputWrapper {
        public Social_Input__c socInput {get; set;}
        public String usrGrpName {get; set;}
    }
    
     public class FeedItemWrapper {
      
      public String  title{get;set;}
      public String  body{get;set;}
      public String  createdBy{get;set;}
      public Integer likeCount{get;set;}
      public Integer commentCount{get;set;}
      public String  createdDate{get;set;} 
      public List<FeedCommentWrapper> feedCommentList{get;set;} 
    }
    
     public class FeedCommentWrapper {
      
      public String  title{get;set;}
      public String  body{get;set;}
      public String  createdBy{get;set;}
      public Integer likeCount{get;set;}
      public Integer commentCount{get;set;}
      public String  createdDate{get;set;} 
      public List<FeedComment> feedCommentList{get;set;} 
    }
}