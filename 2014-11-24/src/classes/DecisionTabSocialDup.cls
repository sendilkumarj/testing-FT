/* 
    ********************************************************************** 
    Created by: Manjunath
    Last Modified by: Manjunath
    Style: Force.com & Metro
    Description: a) This is for the primary functionality on Decision
                 b) It displays the decision Records. 
                 c) Created wrapper class in to count the activity count , chatter likes/post and Stance count
                 d) grouping of the social input record, Attachement,Task 
                 d) brough the the workbench code to the page
                             
    ********************************************************************** 
 */
 
public with sharing class DecisionTabSocialDup {
    // getter and setters 
    
    //For Decison tab gereral info class
    public static GeneralInformation generalInformationVar{get;set;}
    
    // decision record in JSON form
    public static String decisionJSON {get;private set;} 
    
    // converts the date to local format 
    public static String dateFormat {get;set;}
    
    public static String dateTimeFormat {get;set;} 
    
    //Declare this variable for checking record level permission
    public static Boolean chkRecPermission{get;set;}
    
    //Json for user data
    public String userDataJSON {get;set;} 
    // JSON string for default user 
    public String defaultUserJSON {get;set;}
    
    //Default Constructor DecisionTab.
    public DecisionTabSocialDup(){
        decisionJSON='';
        configData();
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
    
    //Constructor DecisionTab.
    public DecisionTabSocialDup(ApexPages.StandardController controller){
        configData();
    }
    // configure Data - Default Constructure
    private void configData(){
        generalInformationVar= new GeneralInformation();
        dateFormat = generalInformationVar.MapValuesDateFormate();
        
        dateTimeFormat = generalInformationVar.MapValuesDateTime();
        chkRecPermission = false;
        DecisionRecord('');
        //buildSocialTabData('');
        //buildFinancialTabData('');
    }
    
    @RemoteAction 
    public static string DecisionRecord(String phase) {
        //initilize the generlInformation 
        // 
        if(generalInformationVar==null){
             generalInformationVar= new GeneralInformation();
        }
        dateFormat = generalInformationVar.MapValuesDateFormate();
        dateTimeFormat = generalInformationVar.MapValuesDateTime();
        // holds the first 1000 decision record in this map
        Map<id,Decision__c> decisionRecords = new Map<id,Decision__c>();
        //decisionRecords =new Map<id,Decision__c>([Select d.Name, d.Id,d.Title__c,d.LastActivityDate,d.Due_Date__c,d.Nearest_Due_Date__c ,d.Phase__c,d.Status__c,Owner.Name,Decision_Type__c From Decision__c d where id='a06O000000JV3wJ']);
        
        //decisionRecords =new Map<id,Decision__c>([Select d.Name, d.Id,d.Title__c,d.LastModifiedDate,d.Due_Date__c,d.Nearest_Due_Date__c ,d.Phase__c,d.Status__c,Owner.Name,Decision_Type__c From Decision__c d where id='a06O000000JKJnmIAH']);
        if(phase==null || phase==''){
            decisionRecords =new Map<id,Decision__c>([Select d.Name, d.Id,d.Title__c,d.LastModifiedDate,d.Due_Date__c,d.Nearest_Due_Date__c ,d.Phase__c,d.Status__c,Owner.Name,Decision_Type__c From Decision__c d where Phase__c != 'Close' limit 1000]);
        }
        else if(phase=='Close'){
            decisionRecords =new Map<id,Decision__c>([Select d.Name, d.Id,d.Title__c,d.LastModifiedDate,d.Due_Date__c,d.Nearest_Due_Date__c ,d.Phase__c,d.Status__c,Owner.Name,Decision_Type__c From Decision__c d limit 1000]);
        }
        
        // wrapper class constructed to generated the JSON string
        List<DecisionRecordWrapper> listDecisionRecordWrapper = new List<DecisionRecordWrapper>();
        
        // to get the decisionicon from the Attchement
        Map<id,Attachment> attachmentRecord =  new Map<id,Attachment>();
        attachmentRecord =new Map<id,Attachment>([Select id,Name,ParentId,Body from Attachment where Name in :decisionRecords.keySet() ]);
        
        // group Attchment with the Decision Id
        Map<id,Attachment> decisionAttachementAssociation  = new Map<id,Attachment >();
        for(id attachmentKey: attachmentRecord.keySet()){
            decisionAttachementAssociation.put(attachmentRecord.get(attachmentKey).ParentId,attachmentRecord.get(attachmentKey));
        }
        
        // LOGGED IN USER -social input record 
        Map<id,Social_Input__c> socialInputRecords = new Map<id,Social_Input__c>();
        socialInputRecords  =new Map<id,Social_Input__c>([Select id, Name,Decision__c,Mood__c,Role__c,Accountable__c,Backup_for_Accountable__c,Responsible__c,Role_Acceptance_Status__c from Social_Input__c where User__c = : userInfo.getUserId()]);
        
        // map - Decisionid as key and social input
        Map<id,Social_Input__c> decisionSocialAssociation = new Map<id,Social_Input__c>();
        List<id> socialInputKeys = new List<id>();
        socialInputKeys.addall(socialInputRecords.keySet());
        for(integer i=0;i<socialInputKeys.size();i++){
            decisionSocialAssociation.put(socialInputRecords.get(socialInputKeys.get(i)).Decision__c,socialInputRecords.get(socialInputKeys.get(i)));
            system.debug('DecisionTab-Class-->'+socialInputKeys.get(i)+'--'+socialInputRecords.get(socialInputKeys.get(i))+'--size'+socialInputRecords.size());
        }
       
        
        // All -social input record 
        Map<id,Social_Input__c> socialInputRecordsComplete = new Map<id,Social_Input__c>();
        socialInputRecordsComplete  =new Map<id,Social_Input__c>([Select id, Name,Decision__c,Stance_Approval_Status__c,Mood__c,Role__c,Accountable__c,Backup_for_Accountable__c,Responsible__c,Role_Acceptance_Status__c from Social_Input__c where Decision__c in:decisionRecords.keyset() and (Responsible__c = true or Consulted__c = true or Backup_for_Accountable__c = true or Accountable__c = true)  ]);
        
        // map - Decisionid as key and social input
        // group the decision records and the social input record
        Map<id,List<Social_Input__c>> decisionSocialAssociationComplete = new Map<id,List<Social_Input__c>>();
        for(id socialKeys : socialInputRecordsComplete.keySet()){
            List<Social_Input__c> lDecisionSocialInput = decisionSocialAssociationComplete.get(socialInputRecordsComplete.get(socialKeys).Decision__c);
            if(lDecisionSocialInput==null){
                lDecisionSocialInput = new  List<Social_Input__c>();
                decisionSocialAssociationComplete.put(socialInputRecordsComplete.get(socialKeys).Decision__c,lDecisionSocialInput);
            }
            lDecisionSocialInput.add(socialInputRecordsComplete.get(socialKeys));
        }   
        
        System.debug('-------->taskCompleteRecords');
        // All -Activity  input record 
        Map<id,Task> taskCompleteRecords = new Map<id,Task>();
        taskCompleteRecords  = new Map<id,Task>([Select id,WhatId,Subject,Status,isClosed,ActivityDate  from Task where WhatId in: decisionRecords.keySet()]);
        
        // map - Decisionid as key and Task as Key
        // group the decision records and the Task input record
        Map<id,List<Task>> decisionTaskAssociationComplete = new Map<id,List<Task>>();
        System.debug('-------->taskCompleteRecords');
        for(id taskKeys : taskCompleteRecords.keySet()){
            List<Task> lDecisionTaskInput = decisionTaskAssociationComplete.get(taskCompleteRecords.get(taskKeys).WhatId);
            
            if(lDecisionTaskInput==null){
                lDecisionTaskInput = new  List<Task>();
                decisionTaskAssociationComplete.put(taskCompleteRecords.get(taskKeys).WhatId,lDecisionTaskInput);
            }
            lDecisionTaskInput.add(taskCompleteRecords.get(taskKeys));
        } 
        
        
        // All - feedItem
        Map<id,Decision__Feed> feedItems = new Map<id,Decision__Feed>();
        feedItems  =new Map<id,Decision__Feed>([Select id, ParentId,CommentCount,LikeCount,InsertedById from Decision__Feed where ParentId in:decisionRecords.keyset() ]);
        // map - Decisionid as key and feeditem input
        // group the decision records and the feed items
        Map<id,List<Decision__Feed>>  decisionfeedItems= new Map<id,List<Decision__Feed>>();
        for(id feedKeys : feedItems.keySet()){
            List<Decision__Feed> lDecisionFeed = decisionfeedItems.get(feedItems.get(feedKeys).ParentId);
            if(lDecisionFeed==null){
                lDecisionFeed = new  List<Decision__Feed>();
                decisionfeedItems.put(feedItems.get(feedKeys).ParentId,lDecisionFeed);
            }
            lDecisionFeed.add(feedItems.get(feedKeys));
        }
        
         // All - feedItemTask
       // get all the task associated with decision
        Map<id,TaskFeed> taskFeedItems = new Map<id,TaskFeed>();
        // map - Decisionid as key and feeditemTask input
        // group the decision records and the feed items Task
        Map<id,List<TaskFeed>>  decisiontaskfeedItems= new Map<id,List<TaskFeed>>();
        if(taskCompleteRecords!=null && taskCompleteRecords.keyset()!=null){        
            taskFeedItems  =new Map<id,TaskFeed>([Select id, ParentId,CommentCount,LikeCount,InsertedById from TaskFeed where ParentId in:taskCompleteRecords.keyset() ]);
            
            for(id taskFeedKeys : taskFeedItems.keySet()){
                List<TaskFeed> lDecisionTaskFeed = decisiontaskfeedItems.get(taskCompleteRecords.get(taskFeedItems.get(taskFeedKeys).ParentId).WhatId);
                if(lDecisionTaskFeed==null){
                    lDecisionTaskFeed = new  List<TaskFeed>();
                    decisiontaskfeedItems.put(taskCompleteRecords.get(taskFeedItems.get(taskFeedKeys).ParentId).WhatId,lDecisionTaskFeed);
                }
                lDecisionTaskFeed.add(taskFeedItems.get(taskFeedKeys));
            }
            System.debug('taskFeedItems ----->'+taskFeedItems + ' '+taskCompleteRecords.keyset() +'------ '+decisiontaskfeedItems);
        }
         
        
          // All - feedItemEvent
       // get all the Event associated with decision
        Map<id,Event> eventCompleteRecords = new Map<id,Event>();
        eventCompleteRecords  = new Map<id,Event>([Select id,WhatId from Event where WhatId in: decisionRecords.keySet()]);
       
        Map<id,EventFeed> eventFeedItems = new Map<id,EventFeed>();
        // map - Decisionid as key and feeditemEvent input
        // group the decision records and the feed items event
        Map<id,List<EventFeed>>  decisionEventfeedItems= new Map<id,List<EventFeed>>();
        if(eventCompleteRecords!=null && eventCompleteRecords.keyset()!=null){        
            eventFeedItems  =new Map<id,EventFeed>([Select id, ParentId,CommentCount,LikeCount,InsertedById from EventFeed where ParentId in:eventCompleteRecords.keyset() ]);
            
            for(id eventFeedKeys : eventFeedItems.keySet()){
                List<EventFeed> lDecisionEventFeed = decisionEventfeedItems.get(eventCompleteRecords.get(eventFeedItems.get(eventFeedKeys).ParentId).WhatId);
                if(lDecisionEventFeed==null){
                    lDecisionEventFeed = new  List<EventFeed>();
                    decisionEventfeedItems.put(eventCompleteRecords.get(eventFeedItems.get(eventFeedKeys).ParentId).WhatId,lDecisionEventFeed);
                }
                lDecisionEventFeed.add(eventFeedItems.get(eventFeedKeys));
            }
            System.debug('eventFeedItems ----->'+eventFeedItems + ' '+eventCompleteRecords.keyset() +'------ '+decisiontaskfeedItems);
        }
         
        // get all the relation for the Records.
        // realtionRecord
        //Map<id,List<Relations__c>> decisionRelationAssociation = new Map<id,List<Relations__c>>();
        //associatedRelWithDecision(decisionRelationAssociation,decisionRecords.keyset());         
        
        system.debug('--------decisionRecords.keySet()----->'+decisionRecords.keySet());  
        List<Id> lstIds = new List<Id>();
        lstIds.addAll(decisionRecords.keySet());
        // query if only record is there
        if(lstIds!=null && lstIds.size()>0){
            List<UserRecordAccess> listUserRecordAccess = [SELECT RecordId, HasReadAccess, HasEditAccess, HasDeleteAccess,MaxAccessLevel FROM UserRecordAccess WHERE UserId=:UserInfo.getUserId() AND RecordId = : lstIds[0] limit 1];
            system.debug('--------listUserRecordAccess----->'+listUserRecordAccess);      
            if(listUserRecordAccess.size() > 0 && listUserRecordAccess[0].MaxAccessLevel=='All'  ){
                chkRecPermission=true;
            }
        }
        system.debug('--------chkRecPermission----->'+chkRecPermission);
        // used to generate the Jason string by putting the value in the wrapper class 
        for(id decisionRecordsId : decisionRecords.keyset()){
            DecisionRecordWrapper individualDecisionRecordWrapper = new DecisionRecordWrapper();
            individualDecisionRecordWrapper.id=decisionRecords.get(decisionRecordsId).id;
            individualDecisionRecordWrapper.name = decisionRecords.get(decisionRecordsId).Name;
            //individualDecisionRecordWrapper.icon = decisionAttachementAssociation.get(decisionRecordsId)!=null?'/servlet/servlet.FileDownload?file='+decisionAttachementAssociation.get(decisionRecordsId).id:'/resource/1394626713000/Images/newDecisionLifeCycle/LifeCycle-profilePic-130x130.jpg';
            system.debug('------>'+generalInformationVar.imageUrlMap.get('lifeCycleProfilePic'));
            individualDecisionRecordWrapper.icon = decisionAttachementAssociation.get(decisionRecordsId)!=null?'/servlet/servlet.FileDownload?file='+decisionAttachementAssociation.get(decisionRecordsId).id:'/'+generalInformationVar.imageUrlMap.get('lifeCycleProfilePic');
            system.debug('------>individualDecisionRecordWrapper.icon'+individualDecisionRecordWrapper.icon);
            individualDecisionRecordWrapper.title = decisionRecords.get(decisionRecordsId).Title__c;
            individualDecisionRecordWrapper.lastActivityDate = decisionRecords.get(decisionRecordsId).LastModifiedDate!=null?String.valueof(decisionRecords.get(decisionRecordsId).LastModifiedDate.format(dateTimeFormat)):'';
            individualDecisionRecordWrapper.nextDueDate = decisionRecords.get(decisionRecordsId).Nearest_Due_Date__c!=null?String.Valueof(decisionRecords.get(decisionRecordsId).Nearest_Due_Date__c.format(dateTimeFormat)):'' ;
            individualDecisionRecordWrapper.phase = decisionRecords.get(decisionRecordsId).Phase__c;
            individualDecisionRecordWrapper.status = decisionRecords.get(decisionRecordsId).Status__c;
            individualDecisionRecordWrapper.accountable = decisionRecords.get(decisionRecordsId).Owner.Name;
            
            // pass the  StanceWrapper class
            StanceWrapper stanceWrapperInst= new StanceWrapper();
            DecisionTabSocialDup.stanceCalculation(decisionSocialAssociationComplete!=null?decisionSocialAssociationComplete.get(decisionRecordsId):null,stanceWrapperInst);
            individualDecisionRecordWrapper.stance =decisionRecords.get(decisionRecordsId).Phase__c!='Share' && decisionRecords.get(decisionRecordsId).Phase__c!='Draft' ? stanceWrapperInst.totalApprovedOrRejected+'/'+stanceWrapperInst.totalCount: 'N/A';
            individualDecisionRecordWrapper.dType  = decisionRecords.get(decisionRecordsId).Decision_Type__c!=null?String.Valueof(decisionRecords.get(decisionRecordsId).Decision_Type__c):'' ;
            
            individualDecisionRecordWrapper.isEditable = false;
             if(((chkRecPermission == true || decisionSocialAssociation.get(decisionRecordsId) != null && (decisionSocialAssociation.get(decisionRecordsId).Accountable__c || decisionSocialAssociation.get(decisionRecordsId).Backup_for_Accountable__c || decisionSocialAssociation.get(decisionRecordsId).Responsible__c) && decisionSocialAssociation.get(decisionRecordsId).Role_Acceptance_Status__c == 'Approved/Accepted'))) {    //Allows editing permissions for Accountable, backup and Responisable for all task.
                individualDecisionRecordWrapper.isEditable = true;
             }
             system.debug('--->individualDecisionRecordWrapper.isEditable'+individualDecisionRecordWrapper.isEditable);
            
            // Social input record  
            Social_Input__c lSocialInputRecord = decisionSocialAssociation.get(decisionRecords.get(decisionRecordsId).id);
            if(lSocialInputRecord!=null && lSocialInputRecord.Role__c!=null){
                individualDecisionRecordWrapper.myRole  = lSocialInputRecord.Role__c;
            }else{
                
                individualDecisionRecordWrapper.myRole ='';
            }
            
            //
             ActivityCountWrapper activityCountWrapperInst= new ActivityCountWrapper();
             DecisionTabSocialDup.activityCalculation(decisionTaskAssociationComplete!=null?decisionTaskAssociationComplete.get(decisionRecordsId):null,activityCountWrapperInst);
            
             individualDecisionRecordWrapper.activitiesTask =activityCountWrapperInst.totalActivityCompleted+'/'+activityCountWrapperInst.totalCount;
             individualDecisionRecordWrapper.readsOfDecision = '';
             
             FeedItemWrapper feedItemWrap = new FeedItemWrapper();
             DecisionTabSocialDup.chatterPostCount(decisionfeedItems.get(decisionRecordsId),feedItemWrap);
             
             FeedItemWrapper feedItemWrapTask = new FeedItemWrapper();
             DecisionTabSocialDup.chatterTaskPostCount(decisiontaskfeedItems.get(decisionRecordsId),feedItemWrapTask);
             
             FeedItemWrapper feedItemWrapEvent = new FeedItemWrapper();
             DecisionTabSocialDup.chatterEventPostCount(decisionEventfeedItems.get(decisionRecordsId),feedItemWrapEvent);
             
             individualDecisionRecordWrapper.chatterPosts = feedItemWrap.postCount+feedItemWrapTask.postCount+feedItemWrapEvent.postCount;
             individualDecisionRecordWrapper.chatterPostLikes= feedItemWrap.likeCount+feedItemWrapTask.likeCount+feedItemWrapEvent.likeCount;
             individualDecisionRecordWrapper.chatterPostLikesForME= feedItemWrap.mylikeCount+feedItemWrapTask.mylikeCount+feedItemWrapEvent.mylikeCount;
             individualDecisionRecordWrapper.thanksBadgesForMe= '';
             individualDecisionRecordWrapper.thanksBadges='';
             //System.debug('System Now--->'+System.Now().format(dateTimeFormat) +'Field Value :'+decisionRecords.get(decisionRecordsId).Nearest_Due_Date__c.format(dateTimeFormat) +'-->'+stanceWrapperInst.totalApprovedOrRejected+ ' '+stanceWrapperInst.totalCount+' '+individualDecisionRecordWrapper.stance+'--'+String.valueof(DateTime.parse(decisionRecords.get(decisionRecordsId).Nearest_Due_Date__c.format(dateTimeFormat)) > DateTime.parse(System.Now().format(dateTimeFormat))));
             //individualDecisionRecordWrapper.stanceColour=(decisionRecords.get(decisionRecordsId).Nearest_Due_Date__c!=null && individualDecisionRecordWrapper.stance!='N/A' && ((decisionRecords.get(decisionRecordsId).Nearest_Due_Date__c.format(dateTimeFormat) < System.Now().format(dateTimeFormat) && stanceWrapperInst.totalApprovedOrRejected==stanceWrapperInst.totalCount) || (decisionRecords.get(decisionRecordsId).Nearest_Due_Date__c.format(dateTimeFormat) > System.Now().format(dateTimeFormat) && stanceWrapperInst.totalApprovedOrRejected==stanceWrapperInst.totalCount)))?'completedAllTask':(decisionRecords.get(decisionRecordsId).Nearest_Due_Date__c!=null && individualDecisionRecordWrapper.stance!='N/A' && decisionRecords.get(decisionRecordsId).Nearest_Due_Date__c.format(dateTimeFormat) < System.Now().format(dateTimeFormat) && stanceWrapperInst.totalApprovedOrRejected<stanceWrapperInst.totalCount)?'delayTask': 'emptyDuedateTask';
             //individualDecisionRecordWrapper.stanceColour=(decisionRecords.get(decisionRecordsId).Nearest_Due_Date__c!=null && individualDecisionRecordWrapper.stance!='N/A' && ((decisionRecords.get(decisionRecordsId).Nearest_Due_Date__c.format(dateTimeFormat) < System.Now().format(dateTimeFormat) && stanceWrapperInst.totalApprovedOrRejected==stanceWrapperInst.totalCount) || (DateTime.parse(decisionRecords.get(decisionRecordsId).Nearest_Due_Date__c.format(dateTimeFormat)) > DateTime.parse(System.Now().format(dateTimeFormat)) && stanceWrapperInst.totalApprovedOrRejected==stanceWrapperInst.totalCount)))?'completedAllTask':(decisionRecords.get(decisionRecordsId).Nearest_Due_Date__c!=null && individualDecisionRecordWrapper.stance!='N/A' && DateTime.parse(decisionRecords.get(decisionRecordsId).Nearest_Due_Date__c.format(dateTimeFormat)) < DateTime.parse(System.Now().format(dateTimeFormat)) && stanceWrapperInst.totalApprovedOrRejected<stanceWrapperInst.totalCount)?'delayTask': 'emptyDuedateTask';
             
             //individualDecisionRecordWrapper.stanceColour=(decisionRecords.get(decisionRecordsId).Nearest_Due_Date__c!=null && individualDecisionRecordWrapper.stance!='N/A' && ((DateTime.parse(decisionRecords.get(decisionRecordsId).Nearest_Due_Date__c.format(dateTimeFormat)) < DateTime.parse(System.Now().format(dateTimeFormat)) && stanceWrapperInst.totalApprovedOrRejected==stanceWrapperInst.totalCount) || (DateTime.parse(decisionRecords.get(decisionRecordsId).Nearest_Due_Date__c.format(dateTimeFormat)) > DateTime.parse(System.Now().format(dateTimeFormat)) && stanceWrapperInst.totalApprovedOrRejected==stanceWrapperInst.totalCount)))?'completedAllTask':(decisionRecords.get(decisionRecordsId).Nearest_Due_Date__c!=null && individualDecisionRecordWrapper.stance!='N/A' && DateTime.parse(decisionRecords.get(decisionRecordsId).Nearest_Due_Date__c.format(dateTimeFormat)) < DateTime.parse(System.Now().format(dateTimeFormat)) && stanceWrapperInst.totalApprovedOrRejected<stanceWrapperInst.totalCount)?'delayTask': 'emptyDuedateTask';
             individualDecisionRecordWrapper.stanceColour=(decisionRecords.get(decisionRecordsId).Due_Date__c!=null && individualDecisionRecordWrapper.stance!='N/A' && ((DateTime.parse(decisionRecords.get(decisionRecordsId).Due_Date__c.format(dateTimeFormat)) < DateTime.parse(System.Now().format(dateTimeFormat)) && stanceWrapperInst.totalApprovedOrRejected==stanceWrapperInst.totalCount) || (DateTime.parse(decisionRecords.get(decisionRecordsId).Due_Date__c.format(dateTimeFormat)) > DateTime.parse(System.Now().format(dateTimeFormat)) && stanceWrapperInst.totalApprovedOrRejected==stanceWrapperInst.totalCount)))?'completedAllTask':(decisionRecords.get(decisionRecordsId).Due_Date__c!=null && individualDecisionRecordWrapper.stance!='N/A' && DateTime.parse(decisionRecords.get(decisionRecordsId).Due_Date__c.format(dateTimeFormat)) < DateTime.parse(System.Now().format(dateTimeFormat)) && stanceWrapperInst.totalApprovedOrRejected<stanceWrapperInst.totalCount)?'delayTask': 'emptyDuedateTask';
             
             individualDecisionRecordWrapper.activityColour=activityCountWrapperInst.delayedTaskCount>0?'delayTask':(activityCountWrapperInst.totalCount>0 && activityCountWrapperInst.totalCount==activityCountWrapperInst.totalActivityCompleted)? 'completedAllTask':'emptyDuedateTask';
             listDecisionRecordWrapper.add(individualDecisionRecordWrapper);
            
        }
        decisionJSON = JSON.serialize(listDecisionRecordWrapper);
        system.debug('---->Json Input'+decisionJSON);
        return decisionJSON;
    }
    
   //stance calculation 
    private static void stanceCalculation(List<Social_Input__c> socialRecord,StanceWrapper stanceWrapperInst){
        //system.debug('---socialRecord.size()'+socialRecord);
        if(socialRecord!=null && socialRecord.size()>0){
            stanceWrapperInst.totalCount=socialRecord.size();
            stanceWrapperInst.totalApprovedOrRejected =0;
            for(Social_Input__c sIRecord:socialRecord){
                if(sIRecord.Stance_Approval_Status__c=='Approved' || sIRecord.Stance_Approval_Status__c=='Rejected'){
                    stanceWrapperInst.totalApprovedOrRejected++;
                }
            }
        }
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
   private static void chatterPostCount(List<Decision__Feed> feedItems,FeedItemWrapper feedItemWrap ){
        //system.debug('---Chatter Post'+feedItems);
        if(feedItems!=null){
            for(Decision__Feed feedItem:feedItems){
                feedItemWrap.postCount+=feedItem.CommentCount;
                feedItemWrap.likeCount+=feedItem.LikeCount;
                if(feedItem.InsertedById==userInfo.getUserId()){
                    feedItemWrap.mylikeCount+=feedItem.LikeCount;
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
    
   /*public static void associatedRelWithDecision(map<id,List<Relations__c>> decisionRelationAssociation,set<id> decisionRecordsID){
        // map - Decisionid as key and RealtionRecords input
        map<id,Relations__c> relationRecords = new map<id,Relations__c>();
        relationRecords =new Map<id,Relations__c>([Select id, Name,Parent_Object_Name__c,Parent_ID__c from Relations__c where Parent_Object_Name__c='Decision' and Parent_ID__c in: decisionRecordsID ]);
        for(id relationRecordsKey :RelationRecords.keySet()){
            List<Relations__c> groupedRelationRecords = new List<Relations__c> ();
            if(decisionRelationAssociation.get(relationRecords.get(relationRecordsKey).Parent_ID__c)!=null){
                groupedRelationRecords = decisionRelationAssociation.get(relationRecords.get(relationRecordsKey).Parent_ID__c);
                groupedRelationRecords.add(relationRecords.get(relationRecordsKey));
            }
            else{
                groupedRelationRecords.add(relationRecords.get(relationRecordsKey));
            }
            decisionRelationAssociation.put(relationRecords.get(relationRecordsKey).Parent_ID__c,groupedRelationRecords);
            
        }
        
    }*/
    
     // update decision Record batch contribution
     @RemoteAction
     public static string updateDecisions(string jsonModifiedData){
        //List<DecisionRecordWrapper>  deserialisedDecisionRec = (List<DecisionRecordWrapper>) System.JSON.deserialize(jsonModifiedData, List<DecisionRecordWrapper>.class);
        String modifiedData = jsonModifiedData; 
        system.debug('---->'+jsonModifiedData);
        // to deserialize the Contribution 
        dataWrapDecisions dataDeserialized =new dataWrapDecisions();
        List<DecisionRecordWrapper> deserialisedDecisionRec  = new List<DecisionRecordWrapper>();
        deserialisedDecisionRec =  (List<DecisionRecordWrapper>)JSON.deserialize(modifiedData, List<DecisionRecordWrapper>.class);
        System.debug('---->'+(deserialisedDecisionRec ));
       
        set<id> decisionIds = new set<id>();
        for(DecisionRecordWrapper decisionRec :deserialisedDecisionRec){
            //Decision__c dec = new Decision__c(id = decisionRec.id);
            decisionIds.add(decisionRec.id);
        }
        Map<id,Decision__c> updateDecision =new Map<id,Decision__c>();
        updateDecision =new Map<id,Decision__c>([Select d.Name, d.Id,d.Title__c,d.LastActivityDate,d.Due_Date__c,d.Nearest_Due_Date__c ,d.Phase__c,d.Status__c,Owner.Name,Decision_Type__c,Estimated_Revenue__c, Estimated_Revenue_Desc__c, Estimated_People_Involved__c, Estimated_People_Involved_Desc__c, Estimated_Net_Present_Value__c, Estimated_Net_Present_Value_Desc__c, Estimated_Investment__c, Estimated_Investment_Desc__c, Estimated_Full_time_Equivalent_FTE__c, Estimated_Full_time_Equivalent_Desc__c, Estimated_Direct_Cost__c, Estimated_Direct_Cost_Desc__c, Actual_Revenue__c, Actual_Revenue_Desc__c, Actual_People_Involved__c, Actual_People_Involved_Desc__c, Actual_Net_Present_Value__c, Actual_Net_Present_Value_Desc__c, Actual_Investment__c, Actual_Investment_Desc__c, Actual_Full_time_Equivalent_FTE__c, Actual_Full_time_Equivalent_Desc__c, Actual_Direct_Cost__c, Actual_Direct_Cost_Desc__c  From Decision__c d where id in:decisionIds]);
        List<Decision__c> toUpdateDecision =new  List<Decision__c>();
        for(DecisionRecordWrapper decisionRec :deserialisedDecisionRec){
            Decision__c decRec = updateDecision.get(decisionRec.id);
            decRec.Title__c = decisionRec.title;
            System.debug('------->'+decisionRec.name);
            toUpdateDecision.add(decRec);
            //decRec.
        }
        if(FLS.decisionUpdateable()){
            update toUpdateDecision;
        }
        String jEditedDataWrapper = DecisionTabSocialDup.DecisionRecord('');
        //String jEditedDataWrapper ='';
        return jEditedDataWrapper;
     }
     
     
    // Wrapper class for DecisionRecord tab
    public class DecisionRecordWrapper {
        public String id {get;set;}
        public String name {get;set;}
        public String icon {get;set;}
        public String title {get;set;}
        public String lastActivityDate {get;set;}
        public String nextDueDate {get;set;}
        public String dType {get;set;}
        public String phase {get;set;}
        public String status {get;set;}
        public String myRole {get;set;}
        public String accountable {get;set;}
        public String stance {get;set;}
        public String activitiesTask{get;set;}
        public String readsOfDecision{get;set;}
        public integer chatterPosts{get;set;}
        public integer chatterPostLikes{get;set;}
        public integer chatterPostLikesForME{get;set;}
        public String thanksBadgesForMe{get;set;}
        public String thanksBadges{get;set;}
        public Boolean isEditable{get;set;}
        public String stanceColour{get;set;}
        public String activityColour{get;set;}
    }
     
    public class Models {
        public List<DecisionRecordWrapper> wrapperRec{get;set;}
    }
    
    public class dataWrapDecisions{
        public Models data{get;set;}    
    }
    
    // wrapper class to get the Chatter related info
     public class FeedItemWrapper {
        public integer postCount=0;
        public integer likeCount=0;
        public integer mylikeCount=0;
        //constructor
        public FeedItemWrapper(){
            
        }
     }
     
     // wrapper for stance count
     public class StanceWrapper{
        public integer totalCount=0;
        public integer totalApprovedOrRejected=0;
        
     }
     
     // wrapper for Activity count
     public class ActivityCountWrapper{
        public integer totalCount=0;
        public integer totalActivityCompleted=0;
        public integer delayedTaskCount=0;
     }
        
        
    // Start added on 2_4_2014  
    // Wrapper class for DecisionRecord Social tab
     
    public static string socialTabJsonData{get;set;} 
    public static string starImage{get;set;}
    
    public class SocialTabWrapper {
        public String id {get;set;}
        public String name {get;set;}
        public String icon {get;set;}
        public String title {get;set;}
        public String lastActivityDate {get;set;}
        public String myRole {get;set;}
        public String accountable {get;set;}
        public string myMood {get;set;}
        public string moodImg{get;set;}
        public string averageMood {get;set;}
        public Decimal likes {get;set;}
        public Decimal unlikes {get;set;}
        public Decimal relevance {get;set;}
        
        public string outcome {get;set;}
        public string effort {get;set;}
        // social input Record.
        public Social__c socialRecord{get;set;}
        public string moodClass{get;set;}
        public string myMoodClass{get;set;}
        public string relevanceClass {get;set;}
        public string relevanceStars{get;set;}
        public string relevanceStarPosition {get;set;}
        // record editable
        public Boolean isEditable{get;set;}
       
    }   
    
    @RemoteAction
     public static string buildSocialTabData(string phase){
        socialTabJsonData='';
        if(generalInformationVar==null){
             generalInformationVar= new GeneralInformation();
        }
        dateFormat = generalInformationVar.MapValuesDateFormate();
        dateTimeFormat = generalInformationVar.MapValuesDateTime();
        // holds the first 1000 decision record in this map
        Map<id,Decision__c> decisionRecords = new Map<id,Decision__c>();
        //decisionRecords =new Map<id,Decision__c>([Select d.Name, d.Id,d.Title__c,d.LastModifiedDate,d.Due_Date__c,d.Nearest_Due_Date__c ,d.Phase__c,d.Status__c,Owner.Name,Decision_Type__c From Decision__c d where id='a06O000000JUlNpIAL']);
        if(phase==null || phase==''){
            decisionRecords =new Map<id,Decision__c>([Select d.Name, d.Id,d.Title__c,d.LastModifiedDate,d.Due_Date__c,d.Nearest_Due_Date__c ,d.Phase__c,d.Status__c,Owner.Name,Decision_Type__c From Decision__c d where Phase__c != 'Close' limit 1000]);
        }
        else if(phase=='Close'){
            decisionRecords =new Map<id,Decision__c>([Select d.Name, d.Id,d.Title__c,d.LastModifiedDate,d.Due_Date__c,d.Nearest_Due_Date__c ,d.Phase__c,d.Status__c,Owner.Name,Decision_Type__c From Decision__c d limit 1000]);
        }
        
        // wrapper class constructed to generated the JSON string
        List<SocialTabWrapper> listDecisionRecordWrapper = new List<SocialTabWrapper>();    
       
        // to get the decisionicon from the Attchement
        Map<id,Attachment> attachmentRecord =  new Map<id,Attachment>();
        // group Attchment with the Decision Id
        Map<id,Attachment> decisionAttachementAssociation  = new Map<id,Attachment >();
        groupDecisionIcon(decisionRecords.keySet(),decisionAttachementAssociation,attachmentRecord);
        
        // LOGGED IN USER -social input record 
        Map<id,Social_Input__c> socialInputRecords = new Map<id,Social_Input__c>();
        // map - Decisionid as key and social input
        Map<id,Social_Input__c> decisionSocialInputAssociation = new Map<id,Social_Input__c>();
        loggedInUserSocialRecords(decisionSocialInputAssociation,socialInputRecords);
        
        // LOGGED IN USER -social input record 
        Map<id,Social__c> socialRecords = new Map<id,Social__c>();
        // map - Decisionid as key and social input
        Map<id,Social__c> decisionSocialAssociation = new Map<id,Social__c>();
        groupDecisionSocialRecords(decisionRecords.keySet(),decisionSocialAssociation,socialRecords);
        
        // record is editable
            chkRecPermission= false;
            system.debug('--------decisionRecords.keySet()----->'+decisionRecords.keySet());  
            List<Id> lstIds = new List<Id>();
            lstIds.addAll(decisionRecords.keySet());
            // query if only record is there
            if(lstIds!=null && lstIds.size()>0){
                List<UserRecordAccess> listUserRecordAccess = [SELECT RecordId, HasReadAccess, HasEditAccess, HasDeleteAccess,MaxAccessLevel FROM UserRecordAccess WHERE UserId=:UserInfo.getUserId() AND RecordId = : lstIds[0] limit 1];
                system.debug('--------listUserRecordAccess----->'+listUserRecordAccess);      
                if(listUserRecordAccess.size() > 0 && listUserRecordAccess[0].MaxAccessLevel=='All'  ){
                    chkRecPermission=true;
                }
            }
        
        
        
        // create the Json String for social 
        List<SocialTabWrapper> listSocialTabWrapper = new List<SocialTabWrapper>();
        for(id decisionRecordsId : decisionRecords.keyset()){
            SocialTabWrapper individualSocialTabWrapper = new SocialTabWrapper();
            individualSocialTabWrapper.id=decisionRecords.get(decisionRecordsId).id;
            individualSocialTabWrapper.name = decisionRecords.get(decisionRecordsId).Name;
            individualSocialTabWrapper.icon = decisionAttachementAssociation.get(decisionRecordsId)!=null?'/servlet/servlet.FileDownload?file='+decisionAttachementAssociation.get(decisionRecordsId).id:'/'+generalInformationVar.imageUrlMap.get('lifeCycleProfilePic');
            individualSocialTabWrapper.title = decisionRecords.get(decisionRecordsId).Title__c;
            individualSocialTabWrapper.lastActivityDate = decisionRecords.get(decisionRecordsId).LastModifiedDate!=null?decisionRecords.get(decisionRecordsId).LastModifiedDate.format(dateTimeFormat):'';
            individualSocialTabWrapper.accountable = decisionRecords.get(decisionRecordsId).Owner.Name;
            
            // social input record. To get the Role and mymood
            Social_Input__c lSocialInputRecord = decisionSocialInputAssociation.get(decisionRecords.get(decisionRecordsId).id);
            if(lSocialInputRecord!=null ){
                individualSocialTabWrapper.myRole  =  lSocialInputRecord.Role__c!=null?lSocialInputRecord.Role__c:'';
                individualSocialTabWrapper.myMood =  lSocialInputRecord.Mood__c!=null?String.valueOf(lSocialInputRecord.Mood__c):'0';
            }else{
                individualSocialTabWrapper.myRole ='';
                individualSocialTabWrapper.myMood =String.valueOf(0);
                
           
            }
            
            individualSocialTabWrapper.myMoodClass = 'moodClass' + individualSocialTabWrapper.myMood;  
            
            // social Record.
            individualSocialTabWrapper.socialRecord= decisionSocialAssociation.get(decisionRecordsId);
            
            if(individualSocialTabWrapper.socialRecord!=null ){
                individualSocialTabWrapper.averageMood =String.valueOf(individualSocialTabWrapper.socialRecord.Avg_Mood__c) != null ? String.valueOf(math.round(individualSocialTabWrapper.socialRecord.Avg_Mood__c)) : '0';
                individualSocialTabWrapper.moodClass = 'moodClass' + individualSocialTabWrapper.averageMood;  
                individualSocialTabWrapper.likes =individualSocialTabWrapper.socialRecord.Total_Likes__c!=null? individualSocialTabWrapper.socialRecord.Total_Likes__c:0;
                individualSocialTabWrapper.unlikes =individualSocialTabWrapper.socialRecord.Total_DisLikes__c!=null? individualSocialTabWrapper.socialRecord.Total_DisLikes__c :0;
                individualSocialTabWrapper.relevance =individualSocialTabWrapper.socialRecord.Avg_Rating__c!= null ? individualSocialTabWrapper.socialRecord.Avg_Rating__c: 0;
                avgStarImgCalculation(individualSocialTabWrapper.socialRecord,individualSocialTabWrapper);
                //individualSocialTabWrapper.relevanceClass = starImagePosition;
                
                 //commneted to display number
                    individualSocialTabWrapper.outcome = individualSocialTabWrapper.socialRecord.Avg_Result__c!=null? mapValueToText(individualSocialTabWrapper.socialRecord.Avg_Result__c):'';
                    individualSocialTabWrapper.effort = individualSocialTabWrapper.socialRecord.Avg_Effort__c !=null? mapValueToText(individualSocialTabWrapper.socialRecord.Avg_Effort__c ):'';
                
                /*individualSocialTabWrapper.outcome = individualSocialTabWrapper.socialRecord.Avg_Result__c!=null? individualSocialTabWrapper.socialRecord.Avg_Result__c:0;
                    individualSocialTabWrapper.effort = individualSocialTabWrapper.socialRecord.Avg_Effort__c !=null? individualSocialTabWrapper.socialRecord.Avg_Effort__c :0;
                */
            //Avg_Rating__c
            }
            else{
                individualSocialTabWrapper.averageMood ='0';
                individualSocialTabWrapper.moodClass = 'moodClass' + individualSocialTabWrapper.averageMood;  
                individualSocialTabWrapper.likes =0;
                individualSocialTabWrapper.unlikes =0;
                individualSocialTabWrapper.relevance =0;
                individualSocialTabWrapper.outcome =''; 
                individualSocialTabWrapper.effort =''; 
            }
            
            individualSocialTabWrapper.isEditable = false;
            if(((chkRecPermission == true || decisionSocialInputAssociation.get(decisionRecordsId) != null && (decisionSocialInputAssociation.get(decisionRecordsId).Accountable__c || decisionSocialInputAssociation.get(decisionRecordsId).Backup_for_Accountable__c || decisionSocialInputAssociation.get(decisionRecordsId).Responsible__c) && decisionSocialInputAssociation.get(decisionRecordsId).Role_Acceptance_Status__c == 'Approved/Accepted'))) {    //Allows editing permissions for Accountable, backup and Responisable for all task.
                individualSocialTabWrapper.isEditable = true;
            }
            
            
            listSocialTabWrapper.add(individualSocialTabWrapper);
        }
        
        socialTabJsonData = JSON.serialize(listSocialTabWrapper);
        return socialTabJsonData;
     }
     
     // groups the Decision Records and the attachemnt which has logo.
     public static void groupDecisionIcon(set<id> decisionRecordIds,Map<id,Attachment> decisionAttachementAssociation,Map<id,Attachment> attachmentRecord){
        if(decisionRecordIds!=null){
            attachmentRecord =new Map<id,Attachment>([Select id,Name,ParentId,Body from Attachment where Name in :decisionRecordIds]);
            for(id attachmentKey: attachmentRecord.keySet()){
                decisionAttachementAssociation.put(attachmentRecord.get(attachmentKey).ParentId,attachmentRecord.get(attachmentKey));
            }   
        }
     }
     
     // groups the Decision Records and the logged in Socialinput records
     public static void loggedInUserSocialRecords(Map<id,Social_Input__c> decisionSocialAssociation ,Map<id,Social_Input__c> socialInputRecords){
        socialInputRecords  =new Map<id,Social_Input__c>([Select id, Name,Decision__c,Mood__c,Role__c,Accountable__c,Backup_for_Accountable__c,Responsible__c,Role_Acceptance_Status__c,Result__c,Effort__c  from Social_Input__c where User__c = : userInfo.getUserId()]);
        for(id socialInputRecordKey: socialInputRecords.keySet()){
            decisionSocialAssociation.put(socialInputRecords.get(socialInputRecordKey).Decision__c,socialInputRecords.get(socialInputRecordKey));
            //system.debug('DecisionTab-Class-->'+socialInputKeys.get(i)+'--'+socialInputRecords.get(socialInputKeys.get(i))+'--size'+socialInputRecords.size());
        }
     }
     
     // groups the Decision Records and the logged in Social records
     public static void groupDecisionSocialRecords(set<id> decisionRecordIds,Map<id,Social__c> decisionSocialAssociation,Map<id,Social__c> socialRecords){
        socialRecords  =new Map<id,Social__c>([select id, Total_Issues__c,Total_Likes__c, Total_DisLikes__c, Avg_Mood__c, Avg_Rating__c,Related_To_ID__c,Avg_Result__c,Avg_Effort__c,lastModifieddate From Social__c where Related_To_ID__c In : decisionRecordIds  order by lastModifieddate desc]);
        for(id socialRecordKey: socialRecords.keySet()){
            decisionSocialAssociation.put(socialRecords.get(socialRecordKey).Related_To_ID__c,socialRecords.get(socialRecordKey));
            //system.debug('DecisionTab-Class-->'+socialInputKeys.get(i)+'--'+socialInputRecords.get(socialInputKeys.get(i))+'--size'+socialInputRecords.size());
        }
     }
     
      public static void avgStarImgCalculation(Social__c social,SocialTabWrapper individualSocialTabWrapper ){
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
             starImage = generalInformationVar.imageUrlMap.get('AllStars');
             String starImagePosition = generalInformationVar.imageUrlMap.get(avgRatingValue);
             individualSocialTabWrapper.relevanceStarPosition=starImagePosition;
             //System.debug('--------------Enetr method ------->'+avgRatingValue +'  '+starImagePosition);
        
    }
    
    public static string mapValueToText (Decimal Value){
        if(Value > 0 && Value<=1){
            return 'Very Low';
        }   
        else if(Value > 1 && Value<=2){
            return 'Low';
        }
        else if(Value > 2 && Value<=3){
            return 'Medium';
        }
        else if(Value > 3 && Value<=4){
            return 'High';
        }
        else if(Value > 4 && Value<=5){
            return 'Very High';
        }
        return '';
    }
    
    
    //created this method to display the Financial View Data.
    public static string financialTabJsonData{get;set;}
     
    public class FinancialTabWrapper {
        public String id {get;set;}
        public String name {get;set;}
        public String icon {get;set;}
        public String title {get;set;}
        public Decimal investmentEstimate{get;set;}
        public Decimal investmentActual{get;set;}
        public Decimal investmentPercent{get;set;}
        public Decimal directCostEstimate{get;set;}
        public Decimal directCostActual{get;set;}
        public Decimal directCostPercent{get;set;}
        public Decimal revenueEstimate{get;set;}
        public Decimal revenueActual{get;set;}
        public Decimal revenuePercent{get;set;}
        public Decimal NPVEstimate{get;set;}
        public Decimal NPVActual{get;set;}
        public Decimal NPVPercent{get;set;}
        public Decimal peopleInvolvedEstimate{get;set;}
        public Decimal peopleInvolvedinvestmentActual{get;set;}
        public Decimal peopleInvolvedPercent{get;set;}
        public Decimal FTEEstimate{get;set;}
        public Decimal FTEActual{get;set;}
        public Decimal FTEPercent{get;set;}
        
        //colour
        public string investmentPercentColour{get;set;}
        public string directCostPercentColour{get;set;}
        public string revenuePercentColour{get;set;}
        public string NPVPercentColour{get;set;}
        public string peopleInvolvedPercentColour{get;set;}
        public string FTEPercentColour{get;set;}
       
        // Editable
        public Boolean isEditable{get;set;}
        public Boolean isEditableActual{get;set;}
        public Boolean isEditableEstimate{get;set;}
        public Boolean chkRecPermissionFinancial=false;
    }   
     
    @RemoteAction
     public static string buildFinancialTabData(string phase){
        financialTabJsonData='';
        if(generalInformationVar==null){
             generalInformationVar= new GeneralInformation();
        }
        dateFormat = generalInformationVar.MapValuesDateFormate();
        dateTimeFormat = generalInformationVar.MapValuesDateTime();
        // holds the first 1000 decision record in this map
        Map<id,Decision__c> decisionRecords = new Map<id,Decision__c>();
        decisionRecords =new Map<id,Decision__c>([Select d.Name, d.Id,d.Title__c,Phase__c ,Estimated_Revenue__c, Estimated_Revenue_Desc__c, Estimated_People_Involved__c, Estimated_People_Involved_Desc__c, Estimated_Net_Present_Value__c, Estimated_Net_Present_Value_Desc__c, Estimated_Investment__c, Estimated_Investment_Desc__c, Estimated_Full_time_Equivalent_FTE__c, Estimated_Full_time_Equivalent_Desc__c, Estimated_Direct_Cost__c, Estimated_Direct_Cost_Desc__c, Actual_Revenue__c, Actual_Revenue_Desc__c, Actual_People_Involved__c, Actual_People_Involved_Desc__c, Actual_Net_Present_Value__c, Actual_Net_Present_Value_Desc__c, Actual_Investment__c, Actual_Investment_Desc__c, Actual_Full_time_Equivalent_FTE__c, Actual_Full_time_Equivalent_Desc__c, Actual_Direct_Cost__c, Actual_Direct_Cost_Desc__c ,Owner.Name,Decision_Type__c From Decision__c d where id='a06O000000JUlNpIAL']);
        if(phase==null || phase==''){
            decisionRecords =new Map<id,Decision__c>([Select d.Name, d.Id,d.Title__c,Phase__c ,Estimated_Revenue__c, Estimated_Revenue_Desc__c, Estimated_People_Involved__c, Estimated_People_Involved_Desc__c, Estimated_Net_Present_Value__c, Estimated_Net_Present_Value_Desc__c, Estimated_Investment__c, Estimated_Investment_Desc__c, Estimated_Full_time_Equivalent_FTE__c, Estimated_Full_time_Equivalent_Desc__c, Estimated_Direct_Cost__c, Estimated_Direct_Cost_Desc__c, Actual_Revenue__c, Actual_Revenue_Desc__c, Actual_People_Involved__c, Actual_People_Involved_Desc__c, Actual_Net_Present_Value__c, Actual_Net_Present_Value_Desc__c, Actual_Investment__c, Actual_Investment_Desc__c, Actual_Full_time_Equivalent_FTE__c, Actual_Full_time_Equivalent_Desc__c, Actual_Direct_Cost__c, Actual_Direct_Cost_Desc__c ,Owner.Name,Decision_Type__c From Decision__c d where Phase__c != 'Close' limit 1000]);
        }
        else if(phase=='Close'){
            decisionRecords =new Map<id,Decision__c>([Select d.Name, d.Id,d.Title__c,Phase__c ,Estimated_Revenue__c, Estimated_Revenue_Desc__c, Estimated_People_Involved__c, Estimated_People_Involved_Desc__c, Estimated_Net_Present_Value__c, Estimated_Net_Present_Value_Desc__c, Estimated_Investment__c, Estimated_Investment_Desc__c, Estimated_Full_time_Equivalent_FTE__c, Estimated_Full_time_Equivalent_Desc__c, Estimated_Direct_Cost__c, Estimated_Direct_Cost_Desc__c, Actual_Revenue__c, Actual_Revenue_Desc__c, Actual_People_Involved__c, Actual_People_Involved_Desc__c, Actual_Net_Present_Value__c, Actual_Net_Present_Value_Desc__c, Actual_Investment__c, Actual_Investment_Desc__c, Actual_Full_time_Equivalent_FTE__c, Actual_Full_time_Equivalent_Desc__c, Actual_Direct_Cost__c, Actual_Direct_Cost_Desc__c ,Owner.Name,Decision_Type__c From Decision__c d limit 1000]);
        } 
        
        // wrapper class constructed to generated the JSON string
        List<SocialTabWrapper> listDecisionRecordWrapper = new List<SocialTabWrapper>();    
       
        // to get the decisionicon from the Attchement
        Map<id,Attachment> attachmentRecord =  new Map<id,Attachment>();
        // group Attchment with the Decision Id
        Map<id,Attachment> decisionAttachementAssociation  = new Map<id,Attachment >();
        groupDecisionIcon(decisionRecords.keySet(),decisionAttachementAssociation,attachmentRecord);
        
        // LOGGED IN USER -social input record 
        Map<id,Social_Input__c> socialInputRecords = new Map<id,Social_Input__c>();
        // map - Decisionid as key and social input
        Map<id,Social_Input__c> decisionSocialInputAssociation = new Map<id,Social_Input__c>();
        loggedInUserSocialRecords(decisionSocialInputAssociation,socialInputRecords);
        
        /*// LOGGED IN USER -social input record 
        Map<id,Social__c> socialRecords = new Map<id,Social__c>();
        // map - Decisionid as key and social input
        Map<id,Social__c> decisionSocialAssociation = new Map<id,Social__c>();
        groupDecisionSocialRecords(decisionRecords.keySet(),decisionSocialAssociation,socialRecords);
        */
        
        // record is editable
            chkRecPermission= false;
            system.debug('--------decisionRecords.keySet()----->'+decisionRecords.keySet());  
            List<Id> lstIds = new List<Id>();
            lstIds.addAll(decisionRecords.keySet());
            // query if only record is there
            if(lstIds!=null && lstIds.size()>0){
                List<UserRecordAccess> listUserRecordAccess = [SELECT RecordId, HasReadAccess, HasEditAccess, HasDeleteAccess,MaxAccessLevel FROM UserRecordAccess WHERE UserId=:UserInfo.getUserId() AND RecordId = : lstIds[0] limit 1];
                system.debug('--------listUserRecordAccess----->'+listUserRecordAccess);      
                if(listUserRecordAccess.size() > 0 && listUserRecordAccess[0].MaxAccessLevel=='All'  ){
                    chkRecPermission=true;
                }
            }
        
        
        // create the Json String for social 
        List<FinancialTabWrapper> listFinancialTabWrapper = new List<FinancialTabWrapper>();
        for(id decisionRecordsId : decisionRecords.keyset()){
            FinancialTabWrapper individualFinancialTabWrapper = new FinancialTabWrapper();
            individualFinancialTabWrapper.id=decisionRecords.get(decisionRecordsId).id;
            individualFinancialTabWrapper.name = decisionRecords.get(decisionRecordsId).Name;
            individualFinancialTabWrapper.icon = decisionAttachementAssociation.get(decisionRecordsId)!=null?'/servlet/servlet.FileDownload?file='+decisionAttachementAssociation.get(decisionRecordsId).id:'/'+generalInformationVar.imageUrlMap.get('lifeCycleProfilePic');
            individualFinancialTabWrapper.title = decisionRecords.get(decisionRecordsId).Title__c;
            individualFinancialTabWrapper.investmentEstimate =decisionRecords.get(decisionRecordsId).Estimated_Investment__c!=null ?decisionRecords.get(decisionRecordsId).Estimated_Investment__c:0;
            individualFinancialTabWrapper.investmentActual =decisionRecords.get(decisionRecordsId).Actual_Investment__c!=null ?decisionRecords.get(decisionRecordsId).Actual_Investment__c:0;
            individualFinancialTabWrapper.investmentPercent =decisionRecords.get(decisionRecordsId).Actual_Investment__c!=null && decisionRecords.get(decisionRecordsId).Actual_Investment__c!=0 ?((individualFinancialTabWrapper.investmentEstimate/individualFinancialTabWrapper.investmentActual)*100).setScale(2):0;
            
            individualFinancialTabWrapper.directCostEstimate =decisionRecords.get(decisionRecordsId).Estimated_Direct_Cost__c!=null?decisionRecords.get(decisionRecordsId).Estimated_Direct_Cost__c:0;
            individualFinancialTabWrapper.directCostActual =decisionRecords.get(decisionRecordsId).Actual_Direct_Cost__c!=null?decisionRecords.get(decisionRecordsId).Actual_Direct_Cost__c:0;
            individualFinancialTabWrapper.directCostPercent =decisionRecords.get(decisionRecordsId).Actual_Direct_Cost__c!=null && decisionRecords.get(decisionRecordsId).Actual_Direct_Cost__c!=0 ?((decisionRecords.get(decisionRecordsId).Estimated_Direct_Cost__c/decisionRecords.get(decisionRecordsId).Actual_Direct_Cost__c)*100).setScale(2):0;
            
            individualFinancialTabWrapper.revenueEstimate =decisionRecords.get(decisionRecordsId).Estimated_Revenue__c!=null?decisionRecords.get(decisionRecordsId).Estimated_Revenue__c:0;
            individualFinancialTabWrapper.revenueActual =decisionRecords.get(decisionRecordsId).Actual_Revenue__c!=null ? decisionRecords.get(decisionRecordsId).Actual_Revenue__c:0;
            individualFinancialTabWrapper.revenuePercent =decisionRecords.get(decisionRecordsId).Actual_Revenue__c!=null && decisionRecords.get(decisionRecordsId).Actual_Revenue__c!=0 ?((decisionRecords.get(decisionRecordsId).Estimated_Revenue__c/decisionRecords.get(decisionRecordsId).Actual_Revenue__c)*100).setScale(2):0;
            
            individualFinancialTabWrapper.NPVEstimate =decisionRecords.get(decisionRecordsId).Estimated_Net_Present_Value__c!=null? decisionRecords.get(decisionRecordsId).Estimated_Net_Present_Value__c:0 ;
            individualFinancialTabWrapper.NPVActual =decisionRecords.get(decisionRecordsId).Actual_Net_Present_Value__c!=null? decisionRecords.get(decisionRecordsId).Actual_Net_Present_Value__c:0;
            individualFinancialTabWrapper.NPVPercent =decisionRecords.get(decisionRecordsId).Actual_Net_Present_Value__c!=null && decisionRecords.get(decisionRecordsId).Actual_Net_Present_Value__c!=0 ?((decisionRecords.get(decisionRecordsId).Estimated_Net_Present_Value__c/decisionRecords.get(decisionRecordsId).Actual_Net_Present_Value__c)*100).setScale(2):0;
            
            individualFinancialTabWrapper.peopleInvolvedEstimate =decisionRecords.get(decisionRecordsId).Estimated_People_Involved__c!=null?decisionRecords.get(decisionRecordsId).Estimated_People_Involved__c:0;
            individualFinancialTabWrapper.peopleInvolvedinvestmentActual =decisionRecords.get(decisionRecordsId).Actual_People_Involved__c!=null? decisionRecords.get(decisionRecordsId).Actual_People_Involved__c:0;
            individualFinancialTabWrapper.peopleInvolvedPercent =decisionRecords.get(decisionRecordsId).Actual_People_Involved__c!=null && decisionRecords.get(decisionRecordsId).Actual_People_Involved__c!=0 ?((decisionRecords.get(decisionRecordsId).Estimated_People_Involved__c/decisionRecords.get(decisionRecordsId).Actual_People_Involved__c)*100).setScale(2):0;
            
            individualFinancialTabWrapper.FTEEstimate =decisionRecords.get(decisionRecordsId).Estimated_Full_time_Equivalent_FTE__c!=null? decisionRecords.get(decisionRecordsId).Estimated_Full_time_Equivalent_FTE__c:0;
            individualFinancialTabWrapper.FTEActual =decisionRecords.get(decisionRecordsId).Actual_Full_time_Equivalent_FTE__c!=null? decisionRecords.get(decisionRecordsId).Actual_Full_time_Equivalent_FTE__c:0;
            individualFinancialTabWrapper.FTEPercent =decisionRecords.get(decisionRecordsId).Actual_Full_time_Equivalent_FTE__c!=null && decisionRecords.get(decisionRecordsId).Actual_Full_time_Equivalent_FTE__c!=0 ?((decisionRecords.get(decisionRecordsId).Estimated_Full_time_Equivalent_FTE__c/decisionRecords.get(decisionRecordsId).Actual_Full_time_Equivalent_FTE__c)*100).setScale(2):0;
            
            // for color the values
            individualFinancialTabWrapper.investmentPercentColour=(individualFinancialTabWrapper.investmentPercent!=null && individualFinancialTabWrapper.investmentPercent >100 )? 'delayTask':(individualFinancialTabWrapper.investmentPercent!=null && individualFinancialTabWrapper.investmentPercent <100 && individualFinancialTabWrapper.investmentPercent >0)? 'completedAllTask':'emptyDuedateTask';
            individualFinancialTabWrapper.directCostPercentColour=(individualFinancialTabWrapper.directCostPercent!=null && individualFinancialTabWrapper.directCostPercent >100 )? 'delayTask':(individualFinancialTabWrapper.directCostPercent!=null && individualFinancialTabWrapper.directCostPercent <100 && individualFinancialTabWrapper.directCostPercent >0)? 'completedAllTask':'emptyDuedateTask';
            individualFinancialTabWrapper.revenuePercentColour=(individualFinancialTabWrapper.revenuePercent!=null && individualFinancialTabWrapper.revenuePercent >100 )? 'delayTask':(individualFinancialTabWrapper.revenuePercent!=null && individualFinancialTabWrapper.revenuePercent <100 && individualFinancialTabWrapper.revenuePercent >0)? 'completedAllTask':'emptyDuedateTask';
            individualFinancialTabWrapper.NPVPercentColour=(individualFinancialTabWrapper.NPVPercent!=null && individualFinancialTabWrapper.NPVPercent >100 )? 'delayTask':(individualFinancialTabWrapper.NPVPercent!=null && individualFinancialTabWrapper.NPVPercent <100 && individualFinancialTabWrapper.NPVPercent >0)? 'completedAllTask':'emptyDuedateTask';
            individualFinancialTabWrapper.peopleInvolvedPercentColour=(individualFinancialTabWrapper.peopleInvolvedPercent!=null && individualFinancialTabWrapper.peopleInvolvedPercent >100 )? 'delayTask':(individualFinancialTabWrapper.peopleInvolvedPercent!=null && individualFinancialTabWrapper.peopleInvolvedPercent <100 && individualFinancialTabWrapper.peopleInvolvedPercent >0)? 'completedAllTask':'emptyDuedateTask';
            individualFinancialTabWrapper.FTEPercentColour=(individualFinancialTabWrapper.FTEPercent!=null && individualFinancialTabWrapper.FTEPercent >100 )? 'delayTask':(individualFinancialTabWrapper.FTEPercent!=null && individualFinancialTabWrapper.FTEPercent <100 && individualFinancialTabWrapper.FTEPercent >0)? 'completedAllTask':'emptyDuedateTask';
            
            // to give the edit permission
            
            individualFinancialTabWrapper.isEditable = false;
            individualFinancialTabWrapper.isEditableActual = false;
            individualFinancialTabWrapper.isEditableEstimate = false;
            if(((chkRecPermission == true || decisionSocialInputAssociation.get(decisionRecordsId) != null && (decisionSocialInputAssociation.get(decisionRecordsId).Accountable__c || decisionSocialInputAssociation.get(decisionRecordsId).Backup_for_Accountable__c || decisionSocialInputAssociation.get(decisionRecordsId).Responsible__c) && decisionSocialInputAssociation.get(decisionRecordsId).Role_Acceptance_Status__c == 'Approved/Accepted'))) {    //Allows editing permissions for Accountable, backup and Responisable for all task.
                individualFinancialTabWrapper.isEditable = true;
                if(decisionRecords.get(decisionRecordsId).Phase__c=='Evaluate' || decisionRecords.get(decisionRecordsId).Phase__c=='Decide' || decisionRecords.get(decisionRecordsId).Phase__c=='Execute'   ){
                    individualFinancialTabWrapper.isEditableActual = true;
                    
                }
                else if(decisionRecords.get(decisionRecordsId).Phase__c=='Share' || decisionRecords.get(decisionRecordsId).Phase__c=='Propose' || decisionRecords.get(decisionRecordsId).Phase__c=='Decide' || decisionRecords.get(decisionRecordsId).Phase__c=='Evaluate' || decisionRecords.get(decisionRecordsId).Phase__c=='Execute' ){
                    individualFinancialTabWrapper.isEditableEstimate = true;
                    
                }
            }
            
            listFinancialTabWrapper.add(individualFinancialTabWrapper);
        }
        system.debug('listFinancialTabWrapper ------>'+listFinancialTabWrapper);
        financialTabJsonData = JSON.serialize(listFinancialTabWrapper);
        return financialTabJsonData;
     }
    
     // update decision Record batch Social
     @RemoteAction
     public static string updateDecisionsSocial(string jsonModifiedData){
        //List<DecisionRecordWrapper>  deserialisedDecisionRec = (List<DecisionRecordWrapper>) System.JSON.deserialize(jsonModifiedData, List<DecisionRecordWrapper>.class);
        String modifiedData = jsonModifiedData; 
        system.debug('---->'+jsonModifiedData);
        // to deserialize the Contribution 
        dataWrapDecisions dataDeserialized =new dataWrapDecisions();
        List<SocialTabWrapper> deserialisedDecisionRec  = new List<SocialTabWrapper>();
        deserialisedDecisionRec =  (List<SocialTabWrapper>)JSON.deserialize(modifiedData, List<SocialTabWrapper>.class);
        System.debug('---->'+(deserialisedDecisionRec ));
       
        set<id> decisionIds = new set<id>();
        for(SocialTabWrapper decisionRec :deserialisedDecisionRec){
            //Decision__c dec = new Decision__c(id = decisionRec.id);
            decisionIds.add(decisionRec.id);
        }
        Map<id,Decision__c> updateDecision =new Map<id,Decision__c>();
        updateDecision =new Map<id,Decision__c>([Select d.Name, d.Id,d.Title__c,d.LastActivityDate,d.Due_Date__c,d.Nearest_Due_Date__c ,d.Phase__c,d.Status__c,Owner.Name,Decision_Type__c,Estimated_Revenue__c, Estimated_Revenue_Desc__c, Estimated_People_Involved__c, Estimated_People_Involved_Desc__c, Estimated_Net_Present_Value__c, Estimated_Net_Present_Value_Desc__c, Estimated_Investment__c, Estimated_Investment_Desc__c, Estimated_Full_time_Equivalent_FTE__c, Estimated_Full_time_Equivalent_Desc__c, Estimated_Direct_Cost__c, Estimated_Direct_Cost_Desc__c, Actual_Revenue__c, Actual_Revenue_Desc__c, Actual_People_Involved__c, Actual_People_Involved_Desc__c, Actual_Net_Present_Value__c, Actual_Net_Present_Value_Desc__c, Actual_Investment__c, Actual_Investment_Desc__c, Actual_Full_time_Equivalent_FTE__c, Actual_Full_time_Equivalent_Desc__c, Actual_Direct_Cost__c, Actual_Direct_Cost_Desc__c  From Decision__c d where id in:decisionIds]);
        List<Decision__c> toUpdateDecision =new  List<Decision__c>();
        for(SocialTabWrapper decisionRec :deserialisedDecisionRec){
            Decision__c decRec = updateDecision.get(decisionRec.id);
            decRec.Title__c = decisionRec.title;
            System.debug('------->'+decisionRec.name);
            toUpdateDecision.add(decRec);
            //decRec.
        }
        if(FLS.decisionUpdateable()){
            update toUpdateDecision;
        }
        String jEditedDataWrapper = DecisionTabSocialDup.buildSocialTabData('');
        //String jEditedDataWrapper ='';
        return jEditedDataWrapper;
     }
     
      @RemoteAction
     public static string updateDecisionsFinancial(string jsonModifiedData){
        //List<DecisionRecordWrapper>  deserialisedDecisionRec = (List<DecisionRecordWrapper>) System.JSON.deserialize(jsonModifiedData, List<DecisionRecordWrapper>.class);
        String modifiedData = jsonModifiedData; 
        system.debug('---->jsonModifiedData'+jsonModifiedData);
        // to deserialize the Contribution 
        dataWrapDecisions dataDeserialized =new dataWrapDecisions();
        List<FinancialTabWrapper> deserialisedDecisionRec  = new List<FinancialTabWrapper>();
        deserialisedDecisionRec =  (List<FinancialTabWrapper>)JSON.deserialize(modifiedData, List<FinancialTabWrapper>.class);
        System.debug('---->'+(deserialisedDecisionRec ));
       
        set<id> decisionIds = new set<id>();
        for(FinancialTabWrapper decisionRec :deserialisedDecisionRec){
            //Decision__c dec = new Decision__c(id = decisionRec.id);
            decisionIds.add(decisionRec.id);
        }
        Map<id,Decision__c> updateDecision =new Map<id,Decision__c>();
        updateDecision =new Map<id,Decision__c>([Select d.Name, d.Id,d.Title__c,d.LastActivityDate,d.Due_Date__c,d.Nearest_Due_Date__c ,d.Phase__c,d.Status__c,Owner.Name,Decision_Type__c,Estimated_Revenue__c, Estimated_Revenue_Desc__c, Estimated_People_Involved__c, Estimated_People_Involved_Desc__c, Estimated_Net_Present_Value__c, Estimated_Net_Present_Value_Desc__c, Estimated_Investment__c, Estimated_Investment_Desc__c, Estimated_Full_time_Equivalent_FTE__c, Estimated_Full_time_Equivalent_Desc__c, Estimated_Direct_Cost__c, Estimated_Direct_Cost_Desc__c, Actual_Revenue__c, Actual_Revenue_Desc__c, Actual_People_Involved__c, Actual_People_Involved_Desc__c, Actual_Net_Present_Value__c, Actual_Net_Present_Value_Desc__c, Actual_Investment__c, Actual_Investment_Desc__c, Actual_Full_time_Equivalent_FTE__c, Actual_Full_time_Equivalent_Desc__c, Actual_Direct_Cost__c, Actual_Direct_Cost_Desc__c  From Decision__c d where id in:decisionIds]);
        List<Decision__c> toUpdateDecision =new  List<Decision__c>();
        for(FinancialTabWrapper decisionRec :deserialisedDecisionRec){
            Decision__c decRec = updateDecision.get(decisionRec.id);
            decRec.Title__c = decisionRec.title;
            decRec.Estimated_Investment__c =decisionRec.investmentEstimate;
            decRec.Actual_Investment__c= decisionRec.investmentActual;
            decRec.Estimated_Direct_Cost__c =decisionRec.directCostEstimate;
            decRec.Actual_Direct_Cost__c =decisionRec.directCostActual;
            decRec.Estimated_Revenue__c =decisionRec.revenueEstimate;
            decRec.Actual_Revenue__c =decisionRec.revenueActual;
            decRec.Estimated_Net_Present_Value__c =decisionRec.NPVEstimate;
            decRec.Actual_Net_Present_Value__c =decisionRec.NPVActual;
            decRec.Estimated_People_Involved__c =decisionRec.peopleInvolvedEstimate;
            decRec.Actual_People_Involved__c =decisionRec.peopleInvolvedinvestmentActual;
            decRec.Estimated_Full_time_Equivalent_FTE__c =decisionRec.FTEEstimate;
            decRec.Actual_Full_time_Equivalent_FTE__c =decisionRec.FTEActual;

            System.debug('------->'+decisionRec.name);
            toUpdateDecision.add(decRec);
            //decRec.
        }
        if(FLS.decisionUpdateable()){
            update toUpdateDecision;
        }
        String jEditedDataWrapper = DecisionTabSocialDup.buildFinancialTabData('');
        //String jEditedDataWrapper ='';
        return jEditedDataWrapper;
        
     }
     
    // end 2_4_2014
}