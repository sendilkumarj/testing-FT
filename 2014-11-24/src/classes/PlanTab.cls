public with sharing class PlanTab {
    
    //For Decison tab gereral info class
    public static GeneralInformation generalInformationVar{get;set;}
    public static String dateTimeFormat {get;set;} 
    public static String dateFormat {get;set;} 
    
    // Plan record in JSON form
    public static String planJSON {get;private set;}
    
    public static Boolean chkRecPermission{get;set;}
    public static string  userLocaleSidKey{get;set;}
    static{
            //variable to send user locale
            userLocaleSidKey  = UserInfo.getLocale().replace('_','-');
    } 
    public PlanTab(){
        chkRecPermission = false;
        planJSON = '';
        planRecords();
    }
    
    @RemoteAction
    public static string planRecords(){
        
        if(generalInformationVar==null){
             generalInformationVar= new GeneralInformation();
        }
        dateTimeFormat = generalInformationVar.MapValuesDateTime();
        
        // assign user locale date format as string 
        dateFormat = generalInformationVar.MapValuesDateFormate();
        
        List<Plan__c> lstPlan = [select id,Name,Add_C_I_Members__c,All_Day_Event__c,OwnerId,Owner.Name,Assigned_To__c,Description__c,End_Time__c,Location__c,Private__c,Show_Time_As__c,Start_Time__c,Update_Manager__c,LastModifiedDate from Plan__c ORDER BY LastModifiedDate DESC limit 1000];
        
        set<Id> planIds = new set<Id>();
        for(Plan__c p : lstPlan){
            planIds.add(p.id);
        }
        
        // All -Activity  input record 
        Map<id,Task> taskCompleteRecords = new Map<id,Task>();
        taskCompleteRecords  = new Map<id,Task>([Select id,WhatId,Subject,Status,isClosed,ActivityDate  from Task where WhatId IN : planIds]);
        
        // map - plan id as key and Task as Key
        // group the plan records and the Task input record
        Map<id,List<Task>> planTaskAssociationComplete = new Map<id,List<Task>>();
        System.debug('-------->taskCompleteRecords');
        for(id taskKeys : taskCompleteRecords.keySet()){
            List<Task> lplanTaskInput = planTaskAssociationComplete.get(taskCompleteRecords.get(taskKeys).WhatId);
            
            if(lplanTaskInput==null){
                lplanTaskInput = new  List<Task>();
                planTaskAssociationComplete.put(taskCompleteRecords.get(taskKeys).WhatId,lplanTaskInput);
            }
            lplanTaskInput.add(taskCompleteRecords.get(taskKeys));
        }
        
        // All - feedItem
        Map<id,Plan__Feed> feedItems = new Map<id,Plan__Feed>();
        feedItems  =new Map<id,Plan__Feed>([Select id, ParentId,CommentCount,LikeCount,InsertedById,Type from Plan__Feed where ParentId IN : planIds ]);
        // map - Planid as key and feeditem input
        // group the Plan records and the feed items
        Map<id,List<Plan__Feed>>  PlanfeedItems= new Map<id,List<Plan__Feed>>();
        for(id feedKeys : feedItems.keySet()){
            List<Plan__Feed> lPlanFeed = PlanfeedItems.get(feedItems.get(feedKeys).ParentId);
            if(lPlanFeed==null){
                lPlanFeed = new  List<Plan__Feed>();
                PlanfeedItems.put(feedItems.get(feedKeys).ParentId,lPlanFeed);
            }
            lPlanFeed.add(feedItems.get(feedKeys));
        }
        
         // All - feedItemTask
       // get all the task associated with Plan
        Map<id,TaskFeed> taskFeedItems = new Map<id,TaskFeed>();
        // map - Planid as key and feeditemTask input
        // group the Plan records and the feed items Task
        Map<id,List<TaskFeed>>  PlantaskfeedItems= new Map<id,List<TaskFeed>>();
        if(taskCompleteRecords!=null && taskCompleteRecords.keyset()!=null){        
            taskFeedItems  =new Map<id,TaskFeed>([Select id, ParentId,CommentCount,LikeCount,InsertedById from TaskFeed where ParentId in:taskCompleteRecords.keyset() ]);
            
            for(id taskFeedKeys : taskFeedItems.keySet()){
                List<TaskFeed> lPlanTaskFeed = PlantaskfeedItems.get(taskCompleteRecords.get(taskFeedItems.get(taskFeedKeys).ParentId).WhatId);
                if(lPlanTaskFeed==null){
                    lPlanTaskFeed = new  List<TaskFeed>();
                    PlantaskfeedItems.put(taskCompleteRecords.get(taskFeedItems.get(taskFeedKeys).ParentId).WhatId,lPlanTaskFeed);
                }
                lPlanTaskFeed.add(taskFeedItems.get(taskFeedKeys));
            }
            System.debug('taskFeedItems ----->'+taskFeedItems + ' '+taskCompleteRecords.keyset() +'------ '+PlantaskfeedItems);
        }
         
        
          // All - feedItemEvent
       // get all the Event associated with Plan
        Map<id,Event> eventCompleteRecords = new Map<id,Event>();
        eventCompleteRecords  = new Map<id,Event>([Select id,WhatId from Event where WhatId IN : planIds ]);
       
        Map<id,EventFeed> eventFeedItems = new Map<id,EventFeed>();
        // map - Planid as key and feeditemEvent input
        // group the Plan records and the feed items event
        Map<id,List<EventFeed>>  planEventfeedItems = new Map<id,List<EventFeed>>();
        if(eventCompleteRecords!=null && eventCompleteRecords.keyset()!=null){        
            eventFeedItems  =new Map<id,EventFeed>([Select id, ParentId,CommentCount,LikeCount,InsertedById from EventFeed where ParentId in:eventCompleteRecords.keyset() ]);
            
            for(id eventFeedKeys : eventFeedItems.keySet()){
                List<EventFeed> lPlanEventFeed = planEventfeedItems.get(eventCompleteRecords.get(eventFeedItems.get(eventFeedKeys).ParentId).WhatId);
                if(lPlanEventFeed==null){
                    lPlanEventFeed = new  List<EventFeed>();
                    planEventfeedItems.put(eventCompleteRecords.get(eventFeedItems.get(eventFeedKeys).ParentId).WhatId,lPlanEventFeed);
                }
                lPlanEventFeed.add(eventFeedItems.get(eventFeedKeys));
            }
            System.debug('eventFeedItems ----->'+eventFeedItems + ' '+eventCompleteRecords.keyset() +'------ '+PlantaskfeedItems);
        }
        
        List<Social_Input__c> lstSocialInput = [Select id, Name,Decision__c,Plan__c,Mood__c,Role__c,Accountable__c,Backup_for_Accountable__c,Responsible__c,Role_Acceptance_Status__c from Social_Input__c where User__c = : userInfo.getUserId()];
        Map<Id,Social_Input__c> mapPlanSocialInput = new Map<Id,Social_Input__c>();
        for(Social_Input__c si : lstSocialInput){
            mapPlanSocialInput.put(si.Plan__c,si);
        }
        
        List<Relations__c> lstItems = [select id,Parent_Object_Name__c,Child_Object_Name__c,Child_ID__c,Parent_ID__c from Relations__c where Type__c = 'Item' and Parent_Id__c IN : planIds and Child_Object_Name__c = 'Decision'];
        Map<Id,List<Relations__c>> mapPlanItemDecisions = new Map<Id,List<Relations__c>>();
        for(Relations__c rel : lstItems){
            List<Relations__c> lstRelations = mapPlanItemDecisions.get(rel.Parent_Id__c);
            if(lstRelations == null){
                lstRelations = new  List<Relations__c>();
                mapPlanItemDecisions.put(rel.Parent_Id__c,lstRelations);
            }
            lstRelations.add(rel);
        }
        
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
        
        List<PlanWrapper> lstPlanWrapper = new List<PlanWrapper>();
        // Wrapping all plan records.
        for(Plan__c p : lstPlan){
            PlanWrapper pw = new PlanWrapper();
            pw.id = '/'+p.Id;
            pw.subject = p.Name;
            pw.lastActivityDate = String.valueOf(p.LastModifiedDate.format());
            pw.description = p.Description__c != null ? p.Description__c : '';
            pw.planStartDate = p.Start_Time__c != null ? String.valueOf(p.Start_Time__c.format()) : '';
            pw.planEndDate = p.End_Time__c != null ? String.valueOf(p.End_Time__c.format()) : '';
            pw.assignTo = p.Owner.Name;
            pw.assignToId = p.OwnerId;
            pw.decisions = mapPlanItemDecisions != null && mapPlanItemDecisions.get(p.Id) != null ? mapPlanItemDecisions.get(p.Id).size() : 0;
            
            pw.isEditable = false;
            pw.title = '';
            if(chkRecPermission == true || mapPlanSocialInput!= null && mapPlanSocialInput.get(p.Id) != null && (mapPlanSocialInput.get(p.Id).Accountable__c || mapPlanSocialInput.get(p.Id).Backup_for_Accountable__c || mapPlanSocialInput.get(p.Id).Responsible__c)){
                pw.isEditable = true;
                pw.title = 'Edit';
            }
            
            ActivityCountWrapper activityCountWrapperInst= new ActivityCountWrapper();
            PlanTab.activityCalculation(planTaskAssociationComplete != null ? planTaskAssociationComplete.get(p.Id) : null, activityCountWrapperInst);
            
           
            pw.activitiesCount = string.valueOf( activityCountWrapperInst.totalActivityCompleted );
            pw.taskCount =       string.valueOf(activityCountWrapperInst.totalCount);
          
            pw.activityColour = activityCountWrapperInst.delayedTaskCount > 0 ? 'delayTask' : (activityCountWrapperInst.totalCount > 0 && activityCountWrapperInst.totalCount == activityCountWrapperInst.totalActivityCompleted) ? 'completedAllTask' : 'emptyDuedateTask';
            
            FeedItemWrapper feedItemWrap = new FeedItemWrapper();
            PlanTab.chatterPostCount(planfeedItems.get(p.Id),feedItemWrap);
             
            FeedItemWrapper feedItemWrapTask = new FeedItemWrapper();
            PlanTab.chatterTaskPostCount(plantaskfeedItems.get(p.Id),feedItemWrapTask);
             
            FeedItemWrapper feedItemWrapEvent = new FeedItemWrapper();
            PlanTab.chatterEventPostCount(planEventfeedItems.get(p.Id),feedItemWrapEvent);
             
            pw.chatterPosts = feedItemWrap.postCount+feedItemWrapTask.postCount+feedItemWrapEvent.postCount;
            pw.chatterPostLikes= feedItemWrap.likeCount+feedItemWrapTask.likeCount+feedItemWrapEvent.likeCount;
            pw.thanksBadges = feedItemWrap.thanksBadgeCount;
            
            // start added on 24-04-2014
            pw.lastActivityDateSort = p.LastModifiedDate;
            pw.planStartDateSort = p.Start_Time__c != null ? p.Start_Time__c: null;
            pw.planEndDateSort = p.End_Time__c != null ? p.End_Time__c: null;
            // end added on 24-04-2014
            
            lstPlanWrapper.add(pw);
        }
        
        planJSON = JSON.serialize(lstPlanWrapper);
        return planJSON;
    }
    
    
    //Updating plan records based on the input from Kendo.
    @RemoteAction
    public static string updatePlans(String jsonModifiedData){
        
        List<PlanWrapper> lstPlanWrapper = (List<PlanWrapper>)System.JSON.deserialize(jsonModifiedData, List<PlanWrapper>.class);
        set<Id> planIds = new set<Id>();
        for(PlanWrapper pw : lstPlanWrapper){
            planIds.add(pw.id.replaceAll('/',''));
        }
        List<Plan__c> lstPlan = [select id,Name,Add_C_I_Members__c,All_Day_Event__c,OwnerId,Owner.Name,Assigned_To__c,Description__c,End_Time__c,Location__c,Private__c,Show_Time_As__c,Start_Time__c,Update_Manager__c,LastModifiedDate from Plan__c where Id IN : planIds limit 1000];
        
        for(Plan__c p : lstPlan){
            for(PlanWrapper pw : lstPlanWrapper){
                if(p.Id == Id.valueOf(pw.id.replaceAll('/',''))){
                    p.Name = pw.subject;
                    p.Description__c = pw.description;
                    //System.debug('------pw.planStartDate------>'+pw.planStartDate+'--------'+String.valueof(pw.planStartDateSort).length());
                    if(pw.planStartDateSort!=null){
                        p.Start_Time__c = pw.planStartDateSort;
                    } else {
                        p.Start_Time__c = null;
                    }
                    if(pw.planStartDateSort != null && String.valueof(pw.planStartDateSort).length() > 8){
                       if(!String.valueof(pw.planStartDateSort).contains('AM') && !String.valueof(pw.planStartDateSort).contains('PM')){     
                            string dttm = String.valueof(pw.planStartDateSort);
                            string dttm2 = dttm.replace('T',' ');
                            System.debug('------dttm2------>'+dttm2);
                            dttm2 = dttm2.replaceAll('/.','/');
                            System.debug('------dttm2------>'+dttm2);
                            if(dttm2.contains('.000Z')){    
                                p.Start_Time__c = Datetime.valueOfGmt(dttm2);
                            } 
                       }
                    }
                    //System.debug('------pw.planEndDate------>'+pw.planEndDate +'---'+ String.Valueof(pw.planEndDateSort).length());
                    if(pw.planEndDateSort!=null){
                        p.End_Time__c = pw.planEndDateSort;
                    } else {
                        p.End_Time__c = null;
                    }
                    if(pw.planEndDateSort != null && String.valueof(pw.planEndDateSort).length() > 8){
                        if(!String.valueof(pw.planEndDateSort).contains('AM') && !String.valueof(pw.planEndDateSort).contains('PM')){    
                            string dttm = String.valueof(pw.planEndDateSort);
                            string dttm2 = dttm.replace('T',' ');
                            System.debug('------dttm2------>'+dttm2);
                            dttm2 = dttm2.replaceAll('/.','/');
                            System.debug('------dttm2------>'+dttm2);
                            if(dttm2.contains('.000Z')){        
                                p.End_Time__c = Datetime.valueOfGmt(dttm2);
                            }
                        }
                    }
                }
            }
        }
        if(!lstPlan.isEmpty()){
            update lstPlan;
        }
        
        String updatedJson = planRecords();
        return updatedJson;
    }
    //Activity calculation 
    private static void activityCalculation(List<Task> taskRecord,ActivityCountWrapper activityCountWrapperInst){
        if(taskRecord!=null && taskRecord.size()>0){
            
            activityCountWrapperInst.totalCount=taskRecord.size();
            activityCountWrapperInst.totalActivityCompleted =0;
            for(Task activiTaskRec:taskRecord){
                if(activiTaskRec.isClosed){
                    activityCountWrapperInst.totalActivityCompleted++;
                }
                
                if(!activiTaskRec.isClosed && activiTaskRec.ActivityDate<System.Today() ){
                    activityCountWrapperInst.delayedTaskCount++;
                    System.debug('---activityCountWrapperInst.delayedTaskCount++'+activityCountWrapperInst.delayedTaskCount++);
                }
            }
            
        }
    }
    
    // this method is used to get the chatter post count, feedpost counts and likes  
   private static void chatterPostCount(List<Plan__Feed> feedItems,FeedItemWrapper feedItemWrap ){
        //system.debug('---Chatter Post'+feedItems);
        if(feedItems!=null){
            for(Plan__Feed feedItem:feedItems){
                feedItemWrap.postCount+=feedItem.CommentCount;
                feedItemWrap.likeCount+=feedItem.LikeCount;
                if(feedItem.InsertedById==userInfo.getUserId()){
                    feedItemWrap.mylikeCount+=feedItem.LikeCount;
                }
                if(feedItem.type == 'RypplePost'){
                  feedItemWrap.thanksBadgeCount++;
                }
            }
            feedItemWrap.postCount+=feedItems.size();
             system.debug('---Chatter Post'+feedItemWrap.postCount);
             system.debug('---Chatter Post'+feedItemWrap.LikeCount);
        }
    }
    
    // this method is used to get the chatter post count, feedpost counts and likes for task  
   private static void chatterTaskPostCount(List<TaskFeed> feedTaskItems,FeedItemWrapper feedItemWrap ){
        //system.debug('---Chatter Post feedTaskItems'+feedTaskItems);
        if(feedTaskItems!=null){
            for(TaskFeed feedItem:feedTaskItems){
                feedItemWrap.postCount+=feedItem.CommentCount;
                feedItemWrap.likeCount+=feedItem.LikeCount;
                if(feedItem.InsertedById==userInfo.getUserId()){
                    feedItemWrap.mylikeCount+=feedItem.LikeCount;
                }
            }
            feedItemWrap.postCount+=feedTaskItems.size();
             system.debug('---Chatter Post task'+feedItemWrap.postCount);
             system.debug('---Chatter Post task'+feedItemWrap.LikeCount);
        }
    }
    
      // this method is used to get the chatter post count, feedpost counts and likes for task  
   private static void chatterEventPostCount(List<EventFeed> feedEventItems,FeedItemWrapper feedItemWrap ){
        //system.debug('---Chatter Post feedTaskItems'+feedTaskItems);
        if(feedEventItems!=null){
            for(EventFeed feedItem:feedEventItems){
                feedItemWrap.postCount+=feedItem.CommentCount;
                feedItemWrap.likeCount+=feedItem.LikeCount;
                if(feedItem.InsertedById==userInfo.getUserId()){
                    feedItemWrap.mylikeCount+=feedItem.LikeCount;
                }
            }
            feedItemWrap.postCount+=feedEventItems.size();
             system.debug('---Chatter Post task'+feedItemWrap.postCount);
             system.debug('---Chatter Post task'+feedItemWrap.LikeCount);
        }
    }
    
    // Plan wrapper class
    public class PlanWrapper {
        public String id {get; set;}
        public String subject {get; set;}
        public String lastActivityDate {get; set;}
        public String description {get; set;}
        public String planStartDate {get; set;}
        public String planEndDate {get; set;}
        public String assignTo {get; set;}
        public String assignToId {get; set;}
        public Integer decisions {get; set;}
        public String taskCount{get;set;}
        public String activitiesCount{get;set;}
        public String activityColour{get;set;}
        public integer chatterPosts{get;set;}
        public integer chatterPostLikes{get;set;}
        public Integer thanksBadges{get; set;}
        public Boolean isEditable {get; set;}
        public String title {get; set;}
        
        // start added on 24-04-2014
         public datetime lastActivityDateSort {get; set;}
         public datetime planStartDateSort {get; set;}
         public datetime planEndDateSort {get; set;}
        // end added on 24-04-2014
    }
    
    // wrapper for Activity count
    public class ActivityCountWrapper{
        public integer totalCount=0;
        public integer totalActivityCompleted=0;
        public integer delayedTaskCount=0;
    }
    
    // wrapper class to get the Chatter related info
     public class FeedItemWrapper {
        public integer postCount=0;
        public integer likeCount=0;
        public integer mylikeCount=0;
        public integer thanksBadgeCount=0;
        //constructor
        public FeedItemWrapper(){
            
        }
     }
}