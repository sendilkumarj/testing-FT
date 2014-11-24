public with sharing class StrategyMap {
    
    public List<RecordsWrapper> lstRecordsWrapper {get; set;}
    
    map<string,string> phaseStringMap;
    map<string,string> statusColorMap;
    public GeneralInformation genralInfo;
    map<Integer,String> moodImagePositionMap;
    map<Integer,String> moodStatusMap;
    map<string,string> stanceColorMap;
    public String dateFormat {get;set;}
    public List<TopicEntity> lstTopicEntity {get; set;}
    map<string,string> roleColorMap;
    //public Boolean topicSelected{get; set;}
    //variable to hold user locale for kendo culture
    public static string  userLocaleSidKey{get;set;}
    static{
            //set user locale here
            userLocaleSidKey  = UserInfo.getLocale().replace('_','-');
    }
    Boolean loadConstructor = false;
    
    public Boolean gettopicSelected(){
        return loadConstructor;
    }
    public void settopicSelected(Boolean objTopic){
        System.debug('-------objTopic------->'+objTopic);
        if(objTopic = true){
            defaultLoad();
        }
        loadConstructor = objTopic;
    }
    
    public StrategyMap(){
        //defaultLoad();
    }
    
    public void defaultLoad(){
        //System.debug('-------topicSelected------->'+topicSelected);
        if(Apexpages.currentPage().getParameters().get('loadConstructor') != null){ 
            loadConstructor = Boolean.valueOf(Apexpages.currentPage().getParameters().get('loadConstructor'));
        }
        System.debug('-------loadConstructor------->'+loadConstructor);
        if(loadConstructor == false){
            lstRecordsWrapper = new List<RecordsWrapper>();
            
            //String topicString = '[{ "text": "Row 1", "items": [  { "text": "New Topic" },  { "text": "bar1" },{ "text": "bar2" },{ "text": "bar3" }] },{ "text": "Row 2", "items": [{ "text": "bar1" },{ "text": "bar2" },{ "text": "bar3" } ] },{ "text": "Row 3", "items": [{ "text": "bar1" },{ "text": "bar2" },{ "text": "bar3" } ] }  ]';
            if(genralInfo == null){  
                genralInfo = new GeneralInformation();     
            } 
            dateFormat = genralInfo.MapValuesDateFormate();
            
            // mapping the values to get the related values for Phases, Status, Mood, Mood status, stance color
          
            roleColorMap = new map<string,string>();
            roleColorMap.put('Approved/Accepted','#373737');
            roleColorMap.put('Not Accepted','#c00000');
            roleColorMap.put('Pending Approval','#ff6600');
            roleColorMap.put('','#d9d9d9');
        
          
            phaseStringMap = new map<string,string>();
            phaseStringMap.put('Draft','1.Draft');
            phaseStringMap.put('Share','2.Share');
            phaseStringMap.put('Propose','3a.Propose'); 
            phaseStringMap.put('Decide','3b.Decide');
            phaseStringMap.put('Execute','4.Execute');
            phaseStringMap.put('Evaluate','5.Evaluate');
            phaseStringMap.put('Close','6.Close');
            
            statusColorMap = new map<string,string>();
            statusColorMap.put('Undecided','ffba00');
            statusColorMap.put('Approved','23a554');
            statusColorMap.put('Rejected','c00000');
            statusColorMap.put('Executed','0f7e39');
            statusColorMap.put('Evaluated','003f75');
            statusColorMap.put('Withdrawn','f273af');
            statusColorMap.put('Cancelled','fed46c');
            statusColorMap.put('Duplicate','1ab39f');
            statusColorMap.put('Closed','373737');
            
            moodImagePositionMap = new Map<Integer,String>();
            moodImagePositionMap.put(0,'0px -186px');
            moodImagePositionMap.put(1,'0px -106px');
            moodImagePositionMap.put(2,'0px -122px');
            moodImagePositionMap.put(3,'0px -138px');
            moodImagePositionMap.put(4,'0px -154px');
            moodImagePositionMap.put(5,'0px -170px');
                
            moodStatusMap = new map<Integer,String>();
            moodStatusMap.put(0,'Not Given');
            moodStatusMap.put(1,'Very Worried');
            moodStatusMap.put(2,'Worried');
            moodStatusMap.put(3,'Neutral');
            moodStatusMap.put(4,'Happy');
            moodStatusMap.put(5,'Very Happy');
            
            stanceColorMap = new map<string,string>();
            stanceColorMap.put('Supported','23a554');
            stanceColorMap.put('Opposed','e81b05');
            stanceColorMap.put('Pending','ff7800');
            stanceColorMap.put('Not Given','ff6600');
            stanceColorMap.put('N/A','ffba00');
            
          
            
            // To get the json data form custom settings
            
            List<Topic_Selected_Data__c>  TopicsCustomSettingList  = [Select id ,Topic_Json__c from  Topic_Selected_Data__c order by RecordNumber__c asc];
            
            String jsonData = '';
            for(Topic_Selected_Data__c tsd : TopicsCustomSettingList){
                jsonData = jsonData+''+tsd.Topic_Json__c;
            }
            System.debug('----jsonData------>'+jsonData);
            
            // Deserializing the json data and wrapping to a class.
            
            jsonTopicRows = (List<TopicRow>)JSON.deserialize(jsonData,List<TopicRow>.class);
            
            set<String> setTopicNames = new set<String>();
            for(TopicRow tr : jsonTopicRows){
                if(tr.items != null){   
                    for(Topics t : tr.items){
                        setTopicNames.add(t.text);
                    }
                }
            }
            List<Topic> lstTopic = new List<Topic>();
            if(!setTopicNames.isEmpty()){   
                lstTopic = [select id,Name from Topic where Name IN :setTopicNames];
            }
            set<Id> setTopicIds = new set<Id>();
            map<Id,String> mapTopicIds = new map<Id,String>();
            for(Topic t : lstTopic){
                mapTopicIds.put(t.Id,t.Name);
                setTopicIds.add(t.Id);
            }
            
            // Based on the topic selected from the admin tool topic records are fetched.
            List<TopicAssignment> topicAssignmentList = new List<TopicAssignment>();
            if(!setTopicIds.isEmpty()){
                
                topicAssignmentList = [SELECT EntityId, TopicId FROM TopicAssignment where TopicId IN: setTopicIds order by createddate desc limit 1000];
                //topicAssignmentList = [SELECT EntityId, TopicId, TYPEOF EntityId When Decision__c THEN Id END From TopicAssignment where TopicId IN: setTopicIds order by createddate desc limit 1000]; 
            }
            set<Id> setEntityIds = new set<Id>();
            lstTopicEntity = new List<TopicEntity>();
            for(TopicAssignment ta : topicAssignmentList){
                TopicEntity te = new TopicEntity();
                te.topicId = ta.TopicId;
                te.topicName = mapTopicIds.get(ta.TopicId);
                te.entityId = ta.EntityId;
                lstTopicEntity.add(te); 
                setEntityIds.add(ta.EntityId);
            }
            System.debug('-----setEntityIds------>'+setEntityIds);
                // Fetching social input records based on the logged in user roles
            if(!setEntityIds.isEmpty()){    
                List<Social_Input__c>    mySocialInputList        = [select id, Decision__c, Decision__r.Title__c,Decision__r.Problem_Idea_Advice__c,Decision__r.Decision_Taken__c, Decision__r.OwnerId, Decision__r.Phase__c,Role__c,Decision__r.Nearest_Due_Date__c from Social_Input__c where User__c =: UserInfo.getUserId() and Decision__r.phase__c != 'Close' and Decision__c != null and Decision__c IN : setEntityIds order by lastmodifieddate DESC NULLS LAST limit 1000];
                //List<Social_Input__c>    myUrgentPlanList         = [select id, Plan__c,Plan__r.Name,Plan__r.lastmodifieddate,Plan__r.location__c, Plan__r.Description__c,Plan__r.Start_Time__c,Plan__r.End_Time__c from Social_Input__c where User__c =: UserInfo.getUserId() and Plan__r.LastModifiedDate < : System.now() and Plan__r.LastModifiedDate > : System.now().addYears(-1) and Plan__c != null  order by Plan__r.End_Time__c DESC NULLS LAST limit 1000];
               
                 //Query all group where I am a part and then get all socialinput to consider informed group
                Map<id,Group> groupMap = new Map<id,Group>([ Select id  from Group where id in ( Select GroupId  from Groupmember where  UserOrGroupId =:UserInfo.getUserId() )]);
                
                mySocialInputList.addAll([select Id, Role__c, Veto_Rights__c, Stance_Approval_Status__c,Consulted__c, Responsible__c, Informed__c, Backup_for_Accountable__c, Accountable__c , Decision__c from Social_Input__c where Decision__c != null and  Informed__c =:true and  GroupId__c in : groupMap.keyset()  ]);

               
                Set<Id> decisionIdFromSocial = new set<Id>();
                Set<Id> planIdFromSocial = new set<Id>();
                
                for(Social_Input__c s: mySocialInputList){
                    System.debug('-----s.decision__c------>'+s.decision__c);
                    decisionIdFromSocial.add(s.decision__c);    
                }
                /*for(Social_Input__c s: myUrgentPlanList){
                    planIdFromSocial.add(s.Plan__r.id);    
                }*/
                
                // Fetching decision decision records based on the default filters.
                List<Decision__c> lstDecision = new List<Decision__c>();
                if(!decisionIdFromSocial.isEmpty()){
                    lstDecision = [select Id,Name,Title__c, Progress__c,Status__c, phase__c,Nearest_Due_Date__c,Due_Date__c ,Priority__c,owner.id from Decision__c where Id IN : setEntityIds and Id IN : decisionIdFromSocial and Phase__c != 'Close' and LastModifiedDate < : System.now() and LastModifiedDate > : System.now().addYears(-1) order by LastModifiedDate desc];
                    //system.debug('======>'+lstDecision.size()+'====>'+decisionIdFromSocial+'====>'+setEntityIds.containsall(decisionIdFromSocial)+'======>Topic id'+topicAssignmentList+'===>');
                }
                set<Id> decId = new set<Id>();
                map<Id, Social__c> smsMap = new map<Id, Social__c>();
                for(Decision__c d: lstDecision) {
                    decId.add(d.Id);
                }
                // Declaring maps to get related decision or plan records.
                //map<Id,List<Issues__c>> issueMap = new map<Id,List<Issues__c>>();
                map<Id, Social_Input__c> myRoleForDecision = new map<Id, Social_Input__c>();
                map<Id,List<Task>> taskMap          = new map<Id,List<Task>>();
                map<Id,List<Task>> taskMapOverdue   = new map<Id,List<Task>>();
                map<Id,List<Event>> eventMap         = new map<Id,List<Event>>();
                map<Id,List<Event>> eventMapOverdue  = new map<Id,List<Event>>();
                date todayDate = Date.today(); 
                
                
                map<string,Integer> pulseStatusMap = new map<string,Integer>();
                pulseStatusMap.put('Not Given',0);
                pulseStatusMap.put('Good',1);
                pulseStatusMap.put('Minor Challenges',2);
                pulseStatusMap.put('Critical',3);
                pulseStatusMap.put('Completed',4);
                pulseStatusMap.put('Completed with Problems',5);
                
                // This execute if there are any decision realted to topics based on the filters
                if(decId.size() > 0){
                    /*for(Issues__c iss: [select id, Related_To_ID__c from Issues__c where Related_To_ID__c In: decId AND Status__c = 'Raised']) {
                      List<Issues__c> issueList = issueMap.get(iss.Related_To_ID__c);
                      if(issueList == null) {
                        issueList = new List<Issues__c>();
                        issueMap.put(iss.Related_To_ID__c, issueList);
                      }
                      issueList.add(iss);
                    }*/
                
                    // Task
                    Datetime todayDT = Datetime.now();  
                    for(Task ts: [select id, WhatId from Task where WhatId In: decId AND ActivityDate <: todayDate  and isClosed = false]) {
                      List<Task> taskList = taskMap.get(ts.WhatId);
                      if(taskList == null) {
                        taskList = new List<Task>();
                        taskMap.put(ts.WhatId, taskList);
                      }
                      taskList.add(ts);
                    }
                    
                    // my role in the decision 
                    
            
                    
                    List<Social_Input__c> raciListForTargetObjet = [select Id, Role__c, Veto_Rights__c, Stance_Approval_Status__c,Role_Acceptance_Status__c,Consulted__c, Responsible__c, Informed__c, Backup_for_Accountable__c, Accountable__c , Decision__c from Social_Input__c where Decision__c In:decId and  User__c =: UserInfo.getUserId()  ];
                    
                    
                    for(Social_Input__c d: raciListForTargetObjet ) {
                        myRoleForDecision.put(d.Decision__c, d);  
                    }
                    
                    // my input values for mood and rating
                    List<Social__c> smsList  = [select Total_Issues__c,Total_Likes__c,Total_Dislikes__c, Avg_Mood__c, Avg_Rating__c,Related_To_ID__c   From Social__c where Related_To_ID__c In :decId];
                    for(Social__c s:  smsList) {
                        smsMap.put(s.Related_To_ID__c, s); 
                    }
                }
                
                set<Id> planIds = new set<id>();
                List<Plan__c> lstPlan = [select id,Name from Plan__c where Id IN : setEntityIds order by LastModifiedDate desc];
                for(Plan__c p : lstPlan){
                    planIds.add(p.Id);
                }
                System.debug('-----lstDecision------>'+lstDecision);
                
                for(Decision__c d : lstDecision){
                    RecordsWrapper rw = new RecordsWrapper();
                    rw.recName = d.Title__c.unescapeHtml4();
                    rw.priority = d.priority__c;
                    rw.recId = d.Id;
                    rw.objName = 'Decision';
                    if(phaseStringMap != null && phaseStringMap.get(d.phase__c) != null){   
                        rw.Phase = d.phase__c != null ? phaseStringMap.get(d.phase__c) : '';
                    }
                    rw.status = d.status__c;
                    if(statusColorMap != null && statusColorMap.get(rw.status) != null){    
                        rw.statusColor = rw.status != null ? statusColorMap.get(rw.status) : '';
                    }
                    if(myRoleForDecision.get(d.Id) != null) {
                        if(myRoleForDecision.get(d.Id).Stance_Approval_Status__c != null) {   
                            rw.stanceApprovalStatus = myRoleForDecision.get(d.Id).Stance_Approval_Status__c == 'Pending Approval' ? 'Pending': (myRoleForDecision.get(d.Id).Stance_Approval_Status__c == 'Approved' ? 'Supported': (myRoleForDecision.get(d.Id).Stance_Approval_Status__c == 'Rejected' ? 'Opposed': 'N/A')) ;
                        } else {
                            rw.stanceApprovalStatus = 'N/A'; 
                        }
                    }
                    else  
                    rw.stanceApprovalStatus = 'N/A';
                    
                    if(stanceColorMap != null && stanceColorMap.get(rw.stanceApprovalStatus) != null){  
                        rw.stanceApprovalStatusColor = rw.stanceApprovalStatus != null ? stanceColorMap.get(rw.stanceApprovalStatus) : '';
                    }
                    rw.pulseStatusInt = pulsestatusmap.get(d.Progress__c);
                    Social__c  sms = smsMap != null && smsMap.get(d.Id) != null ? smsMap.get(d.Id) : null;
                    rw.AverageRating = string.valueOf(sms.Avg_Rating__c);
                    rw.moodImage = genralInfo.imageUrlMap.get('newModdImage');
                    rw.moodImagePosition = moodImagePositionMap.get(math.round(Double.valueOf(sms.Avg_Mood__c)));
                    rw.moodNumber = string.valueOf(math.round(Double.valueOf(sms.Avg_Mood__c)));
                    rw.moodStatus = moodStatusMap.get(math.round(Double.valueOf(sms.Avg_Mood__c)));
                    String avgRatingValue ='';
                    if(sms.Avg_Rating__c ==  1.0) {
                        avgRatingValue = 'star11';
                    }
                    if(sms.Avg_Rating__c > 1.0 && sms.Avg_Rating__c < 2.0 ) {
                        avgRatingValue = 'star1.51';
                    }
                        
                    if(sms.Avg_Rating__c ==  2.0) {
                        avgRatingValue = 'star21';
                    }
                    if( sms.Avg_Rating__c > 2.0 && sms.Avg_Rating__c < 3.0 ) {
                        avgRatingValue = 'star2.51';
                    }
                    if( sms.Avg_Rating__c ==  3.0) {
                        avgRatingValue = 'star31';
                    }
                    if( sms.Avg_Rating__c > 3.0 && sms.Avg_Rating__c < 4.0 ) {
                        avgRatingValue = 'star3.51';
                    }
                    if( sms.Avg_Rating__c ==  4.0) {
                        avgRatingValue = 'star41';
                    }
                    if( sms.Avg_Rating__c > 4.0 && sms.Avg_Rating__c < 5.0 ) {
                        avgRatingValue = 'star4.51';
                    }
                    if( sms.Avg_Rating__c ==  5.0) {
                        avgRatingValue = 'star51';
                    }
                    if( sms.Avg_Rating__c == 0.0) {
                        avgRatingValue = 'null';
                    }
                    rw.Accountable = myRoleForDecision.get(d.Id) != null ? myRoleForDecision.get(d.Id).Accountable__c : false;
                    rw.Responsible = myRoleForDecision.get(d.Id) != null ? myRoleForDecision.get(d.Id).Responsible__c : false;
                    rw.Consulted = myRoleForDecision.get(d.Id) != null ? myRoleForDecision.get(d.Id).Consulted__c : false;
                    rw.Informed = myRoleForDecision.get(d.Id) != null ? myRoleForDecision.get(d.Id).Informed__c : false;
                    rw.Backup = myRoleForDecision.get(d.Id) != null ? myRoleForDecision.get(d.Id).Backup_for_Accountable__c : false;
                    rw.Veto = myRoleForDecision.get(d.Id) != null ? myRoleForDecision.get(d.Id).Veto_Rights__c : false;
                   
                    rw.AccountableRoleColor = myRoleForDecision.get(d.Id) != null && myRoleForDecision.get(d.Id).Accountable__c  ?  roleColorMap.get( myRoleForDecision.get(d.Id).Role_Acceptance_status__c ) : '#d9d9d9';
                    rw.ResponsibleRoleColor = myRoleForDecision.get(d.Id) != null && myRoleForDecision.get(d.Id).Responsible__c  ?  roleColorMap.get( myRoleForDecision.get(d.Id).Role_Acceptance_status__c ) : '#d9d9d9';
                    rw.ConsultedRoleColor = myRoleForDecision.get(d.Id) != null && myRoleForDecision.get(d.Id).Consulted__c  ?  roleColorMap.get( myRoleForDecision.get(d.Id).Role_Acceptance_status__c ) : '#d9d9d9';
                    rw.InformedRoleColor = myRoleForDecision.get(d.Id) != null && myRoleForDecision.get(d.Id).Informed__c  ?  roleColorMap.get( myRoleForDecision.get(d.Id).Role_Acceptance_status__c ) : '#d9d9d9';
                    rw.BackupRoleColor = myRoleForDecision.get(d.Id) != null && myRoleForDecision.get(d.Id).Backup_for_Accountable__c  ?  roleColorMap.get( myRoleForDecision.get(d.Id).Role_Acceptance_status__c ) : '#d9d9d9';
                    rw.VetoRoleColor = myRoleForDecision.get(d.Id) != null && myRoleForDecision.get(d.Id).Veto_Rights__c  ?  roleColorMap.get( myRoleForDecision.get(d.Id).Role_Acceptance_status__c ) : '#d9d9d9';
                   
                    rw.roleApprovalStatus =   myRoleForDecision.get(d.Id) != null ? myRoleForDecision.get(d.Id).Role_Acceptance_status__c: 'N/A';
                   
                   
                    rw.relevenceImage= genralInfo.imageUrlMap.get(avgRatingValue);
                    rw.OwnerName = genralInfo.useNameMap.get(d.OwnerId).Name;
                    rw.ownerDept = genralInfo.useNameMap.get(d.OwnerId).Department;
                    rw.ownerPhoto = genralInfo.useNameMap.get(d.OwnerId).SmallPhotoUrl;
                    
                    //rw.pendingIssueCounts = issueMap.get(d.Id) != null ? issueMap.get(d.Id).size() : 0 ;
                    rw.pendingTaskCount = taskMap.get(d.Id) != null ? taskMap.get(d.Id).size() : 0 ;
                    rw.TotalLikes = string.valueOf(sms.Total_Likes__c);
                    rw.TotalDislikes = string.valueOf(sms.Total_Dislikes__c);
                    rw.duedateSorter  = d.Nearest_Due_Date__c;
                    if(d.Nearest_Due_Date__c != null){
                        Integer dateLeft = System.today().daysBetween(d.Nearest_Due_Date__c.date());
                        rw.deadlineState = dateLeft >= 0 ? 'Positive' : 'Negative';
                        rw.deadlineNum = genralInfo.MapValuesDate(String.valueOf(d.Nearest_Due_Date__c.day()), String.valueOf(d.Nearest_Due_Date__c.month()), String.valueOf(d.Nearest_Due_Date__c.year()));  
                    }
                    else
                    {
                       rw.deadlineNum = 'N/A';
                       rw.deadlineState =  'Positive' ;
                    }
                    lstRecordsWrapper.add(rw);
                }
                
                // This section is to fetch data related to Plan.
                /*if(!planIdFromSocial.isEmpty()){
                    Set<Id> planSet = new set<Id>();
                    for( Social_Input__c sin : myUrgentPlanList ){
                        planSet.add(sin.plan__c);  
                    }  
                    Map<id,Integer> relationsMapCount  = new Map<id,Integer>();
                    Map<id,Relations__c> relationsMap  =  new Map<id,Relations__c>([Select id , Parent_ID__c from Relations__c where Parent_ID__c in : planSet and Parent_ID__c In :  planIdFromSocial ]);
                    Map<id,Social_Input__c> planAccountables     =  new Map<id,Social_Input__c> ([select id, User__r.Name, User__r.Department from Social_Input__c where Plan__r.id  in :  planIdFromSocial and Plan__r.id IN : planSet ]);
                  //  Int
                    for( Relations__c rel : relationsMap.values() ){
                         if( relationsMapCount.get(rel.Parent_ID__c) == null )
                         relationsMapCount.put(rel.Parent_ID__c,1);
                         else
                         relationsMapCount.put(rel.Parent_ID__c,relationsMapCount.get(rel.Parent_ID__c)+1);
                        // Integer.valueOf(relationsMapCount.get(rel.Parent_ID__c)+'ddd' );
                    }
                    if(!planSet.isEmpty() && !planIdFromSocial.isEmpty()){
                        //Integer.valueOf('zz'+[select id, WhatId from Task where WhatId In: planSet AND ActivityDate <: todayDate ].size());
                        for(Task ts: [select id, WhatId from Task where WhatId In: planSet and whatId IN : planIdFromSocial AND ActivityDate <: todayDate  and status !=: 'Completed' and status !=: 'Rejected' ]) {
                              
                              List<Task> taskList = taskMapOverdue.get(ts.WhatId);
                              if(taskList == null) {
                                taskList = new List<Task>();
                                taskMapOverdue.put(ts.WhatId, taskList);
                              }
                              taskList.add(ts);
                        }
                         
                        for(Task ts: [select id, WhatId from Task where WhatId In: planSet and whatId IN : planIdFromSocial AND ( ( ActivityDate >=: todayDate ) or (  ( ActivityDate <: todayDate ) and (  ( status =: 'Completed' ) or ( status =: 'Rejected' ) )  ) )  ]) {
                                
                              List<Task> taskList = taskMap.get(ts.WhatId);
                              if(taskList == null) {
                                taskList = new List<Task>();
                                taskMap.put(ts.WhatId, taskList);
                              }
                              taskList.add(ts);
                        }
                                
                        for(Event ts: [select id, WhatId from Event where WhatId In: planSet and whatId IN : planIdFromSocial AND ActivityDate <: todayDate  ]) {
                              
                              List<Event> eventList = eventMapOverdue.get(ts.WhatId);
                              if(eventList == null) {
                                eventList = new List<Event>();
                                eventMapOverdue.put(ts.WhatId, eventList);
                              }
                              eventList.add(ts);
                        }
                        
                        for(Event ts: [select id, WhatId from Event where WhatId In: planSet AND whatId IN : planIdFromSocial and ActivityDate >=: todayDate ]) {
                              
                              List<Event> eventList = eventMap.get(ts.WhatId);
                              if(eventList == null) {
                                eventList = new List<Event>();
                                eventMap.put(ts.WhatId, eventList);
                              }
                              eventList.add(ts);
                        }
                        
                        for( Social_Input__c plan : myUrgentPlanList ){
                            if(planIds.contains(plan.Plan__r.id)){    
                                RecordsWrapper pw = new RecordsWrapper();
                                //pw.priority  = plan.Priority__c;
                                pw.objName     =  'Plan'; 
                                pw.recId       =  plan.Plan__r.id;
                                pw.modifieddate  = plan.Plan__r.lastmodifieddate != null ? String.valueOf(plan.Plan__r.lastmodifieddate.format(dateFormat)):'';
                                pw.startdate     = plan.Plan__r.Start_Time__c != null ? String.valueOf(plan.Plan__r.Start_Time__c.format(dateFormat)):'';
                                pw.enddate       = plan.Plan__r.End_Time__c != null ? String.valueOf(plan.Plan__r.End_Time__c.format(dateFormat)):'';
                                pw.recName     = plan.Plan__r.Name;
                                if( pw.recName != null){
                                    pw.recName      = pw.recName.length() > 80 ? pw.recName.substring(0,77)+'...' :pw.recName.substring(0,pw.recName.length() )  ;
                                }
                                pw.location      = plan.Plan__r.location__c;  
                                if( pw.location != null){
                                    pw.location      = pw.location.length() > 80 ? pw.location.substring(0,77)+'...' :pw.location.substring(0,pw.location.length() )  ;
                                }
                                pw.itemCount     = relationsMapCount.get(plan.id);
                                pw.description   = plan.Plan__r.Description__c;  
                                if( pw.description != null){
                                    pw.description      = pw.description.length() > 80 ? pw.description.substring(0,77)+'...' :pw.description.substring(0,pw.description.length() )  ;
                                }
                                pw.duedateSorter  = plan.Plan__r.End_Time__c;
                                pw.itemCount     = relationsMapCount.get(plan.Plan__r.id);
                                if(planAccountables.get(plan.id) != null){
                                    pw.accountableName = planAccountables.get(plan.id).User__r.Name;
                                    pw.accountableDept = planAccountables.get(plan.id).User__r.Department;
                                    pw.accountableImage = genralInfo.useImage.get(planAccountables.get(plan.id).User__r.id);
                                }
                                integer nodueTask   =  taskMap.get(plan.Plan__r.id) != null ? taskMap.get(plan.Plan__r.id).size():0;
                                integer nodueEvent  =  eventMap.get(plan.Plan__r.id) != null ? eventMap.get(plan.Plan__r.id).size():0;
                                integer dueTask     =  taskMapOverdue.get(plan.Plan__r.id) != null ? taskMapOverdue.get(plan.Plan__r.id).size():0;
                                integer dueEvent    =  eventMapOverdue.get(plan.Plan__r.id) != null ? eventMapOverdue.get(plan.Plan__r.id).size():0;
                                pw.dueCount         =  dueTask + dueEvent;  
                                pw.activityCount =   string.valueOf( nodueTask + nodueEvent ) + '/'+ string.valueOf( dueTask + dueEvent+ nodueTask + nodueEvent ) ;
                                lstRecordsWrapper.add(pw);
                            }
                        }
                    }
                }*/
            }
        }
        System.debug('-------lstRecordsWrapper--------->'+lstRecordsWrapper);
        loadConstructor = true;
    }
    
    // returns the month in integer which is passed to the method
    // stores the Month Name as the key and Values as its integer value. 
    private static Integer monthToInteger(String monthName){
        
        Map<String, Integer> mapMonthToInteger = new Map<String, Integer>{'Jan' => 1, 'Feb'=>2 ,'Mar'=>3,'Apr'=>4,'May'=>5,'Jun'=>6,'Jul'=>7,'Aug'=>8,'Sep'=>9,'Oct'=>10,'Nov' =>11,'Dec'=>12};
        
        return  mapMonthToInteger.get(monthName);
    }
    
    public void topicStrategyMap(){
        
        System.debug('----Go Method------>');
        // Getting the data based on the filters selected.
        String  datepickerFrom = Apexpages.currentPage().getParameters().get('datepickerFrom');
        String datepickerTo = Apexpages.currentPage().getParameters().get('datepickerTo');
        String roleOfUser = Apexpages.currentPage().getParameters().get('roleOfUser');
        String phases = Apexpages.currentPage().getParameters().get('phases');
        String userId = Apexpages.currentPage().getParameters().get('userId');
        String typeSelected = Apexpages.currentPage().getParameters().get('type');
        String status = Apexpages.currentPage().getParameters().get('status');
        String searchText = Apexpages.currentPage().getParameters().get('searchText');
        
        if(searchText != '' && searchText != null){
            if(searchText.contains('*')){
                String SearchtextList = searchText.replaceAll('\\*','\\%');
                searchText = SearchtextList;
            }
        }
        
        lstRecordsWrapper = new List<RecordsWrapper>();
        
        // parsing the date values based the values fetched from front end and converting it into datetime format.
        // -- start --added to get the date in unique form for all local 20-02-2014
            /* 
            Logic 1 : Get the attribute of the data time for both "From Date" and "To Date"
                  2 : Split by the ',' remove the first entry put it in to date time
                  3 : Second entry contains the date and month.
                  4 : third entry contains year 
                  5: Create Date time using GMT and add all the month year and date 
                   
            */
            DateTime fromDateTime;
            if(datepickerFrom != null){ 
                List<String> splitFromDate = datepickerFrom.split(':');
                if(splitFromDate != null && splitFromDate.size() > 1){
                    System.debug('From Start Date ------ > '+datepickerFrom +'--'+ fromDateTime);
                    System.debug('-----splitFromDate----->'+splitFromDate);
                    List<String> lstFromDate = splitFromDate.get(0).split(' ');
                    System.debug('-----lstFromDate----->'+lstFromDate);
                    if(lstFromDate != null && lstFromDate.size() > 4){  
                        Integer monthInInteger = StrategyMap.monthToInteger(lstFromDate[1]);
                        Integer dateInInteger = Integer.valueOf(lstFromDate[2]);
                        Integer year = Integer.valueOf(lstFromDate[3]);
                        fromDateTime = Datetime.newInstanceGmt( year,monthInInteger,dateInInteger,0,0,1);
                    } 
                }
            }
            DateTime toDateTime;
            if(datepickerTo != null){   
                List<String> splitFromDate = datepickerTo.split(':');
                if(splitFromDate != null && splitFromDate.size() > 1){
                    List<String> lstFromDate = splitFromDate.get(0).split(' ');
                    if(lstFromDate != null && lstFromDate.size() > 4){  
                        Integer monthInInteger = StrategyMap.monthToInteger(lstFromDate[1]);
                        Integer dateInInteger = Integer.valueOf(lstFromDate[2]);
                        Integer year = Integer.valueOf(lstFromDate[3]);
                        toDateTime = Datetime.newInstanceGmt( year,monthInInteger,dateInInteger,23,59,59);
                    } 
                }
            }
            System.debug('From Start Date ------ > '+datepickerFrom +'--'+ fromDateTime);
            System.debug('To Date ---------> '+datepickerTo+'--'+ toDateTime);
        
            
        
        //----end -- added on 20-02-2014
        
      
        List<Topic_Selected_Data__c> lstTSD = Topic_Selected_Data__c.getall().values();
        
        String jsonData = '';
        for(Topic_Selected_Data__c tsd : lstTSD){
            jsonData = tsd.Topic_Json__c+''+jsonData;
        }
        System.debug('----jsonData------>'+jsonData);
        // Deserializing the json data and wrapping to a class.
        jsonTopicRows = (List<TopicRow>)JSON.deserialize(jsonData,List<TopicRow>.class);
        
        set<String> setTopicNames = new set<String>();
        for(TopicRow tr : jsonTopicRows){
            if(tr.items != null){   
                for(Topics t : tr.items){
                    setTopicNames.add(t.text);
                }
            }
        }
        // Based on the topic selected from the admin tool topic records are fetched.
        List<Topic> lstTopic = [select id,Name from Topic where Name IN :setTopicNames];
        set<Id> setTopicIds = new set<Id>();
        map<Id,String> mapTopicIds = new map<Id,String>();
        for(Topic t : lstTopic){
            mapTopicIds.put(t.Id,t.Name);
            setTopicIds.add(t.Id);
        }
        List<TopicAssignment> topicAssignmentList=[SELECT EntityId, TopicId FROM TopicAssignment where TopicId IN: setTopicIds limit 1000];
        set<Id> setEntityIds = new set<Id>();
        lstTopicEntity = new List<TopicEntity>();
        for(TopicAssignment ta : topicAssignmentList){
            TopicEntity te = new TopicEntity();
            te.topicId = ta.TopicId;
            te.topicName = mapTopicIds.get(ta.TopicId);
            te.entityId = ta.EntityId;
            lstTopicEntity.add(te); 
            setEntityIds.add(ta.EntityId);
        }
        
        //List<Decision__c> lstDecision = [select Id,Name,Title__c, Status__c, phase__c,Nearest_Due_Date__c,Due_Date__c ,Priority__c,owner.id from Decision__c where Id IN : setEntityIds and Id IN : decisionIdFromSocial and Phase__c != 'Close' order by LastModifiedDate desc];
        
        List<String> lstType = typeSelected.split(',');
        set<String> setType = new set<String>();
        System.debug('----lstType------>'+lstType);
        setType.addAll(lstType);
        System.debug('----setType------>'+setType);
        
        set<Id> planIds = new set<id>();
        //List<Plan__c> lstPlan = [select id,Name from Plan__c where Id IN : setEntityIds order by LastModifiedDate desc];
        /*for(Plan__c p : lstPlan){
            planIds.add(p.Id);
        }*/
        date todayDate = Date.today(); 
        
        string owner;
        if(userId == null || userId == 'default'){
            owner = UserInfo.getUserId();
        }else{
            owner = userId;
        }
        
        List<String> lstroleOfUser = roleOfUser.split(',');
        set<String> setroleOfUser = new set<String>();
        System.debug('----lstroleOfUser------>'+lstroleOfUser);
        setroleOfUser.addAll(lstroleOfUser);
        System.debug('----setroleOfUser------>'+setroleOfUser);
        
        //map<Id,List<Issues__c>> issueMap = new map<Id,List<Issues__c>>();
        map<Id, Social_Input__c> myRoleForDecision = new map<Id, Social_Input__c>();
        map<Id,List<Task>> taskMap          = new map<Id,List<Task>>();
        map<Id,List<Task>> taskMapOverdue   = new map<Id,List<Task>>();
        map<Id,List<Event>> eventMap         = new map<Id,List<Event>>();
        map<Id,List<Event>> eventMapOverdue  = new map<Id,List<Event>>();
        // this code will work when the user selects Decision from show only dropdown.
        if(setType.contains('Decision')){
             // Fetching social input records based on the logged in user roles.
            Set<Id> decisionIdFromSocial = new set<Id>();
            List<Social_Input__c> mySocialInputList = new List<Social_Input__c>();
            if(setroleOfUser.contains('Accountable')){
                system.debug('-------roleOfUser-----------'+roleOfUser);
                List<Social_Input__c> mySocialInputListAcc = [select Decision__c from Social_Input__c where User__c =: owner and Accountable__c = true and Decision__c != null];
                mySocialInputList.addAll(mySocialInputListAcc);
            }
            if(setroleOfUser.contains('Responsible')){
                system.debug('-------roleOfUser-----------'+roleOfUser);
                List<Social_Input__c> mySocialInputListRes = [select Decision__c from Social_Input__c where User__c =: owner and Responsible__c = true and Decision__c != null];
                mySocialInputList.addAll(mySocialInputListRes);
            }
            if(setroleOfUser.contains('Consulted')){
                system.debug('-------roleOfUser-----------'+roleOfUser);
                List<Social_Input__c> mySocialInputListCon = [select Decision__c from Social_Input__c where User__c =: owner and Consulted__c = true and Decision__c != null];
                mySocialInputList.addAll(mySocialInputListCon);
            }
            if(setroleOfUser.contains('Informed')){
                system.debug('-------roleOfUser-----------'+roleOfUser);
                    
                   
                
                List<Social_Input__c> mySocialInputListInfo = [select Decision__c from Social_Input__c where User__c =: owner and Informed__c = true and Decision__c != null];
                
                //Query all group where I am a part and then get all socialinput to consider informed group
                Map<id,Group> groupMap = new Map<id,Group>([ Select id  from Group where id in ( Select GroupId  from Groupmember where  UserOrGroupId =:UserInfo.getUserId() )]);
                
                mySocialInputList.addAll([select Id, Role__c, Veto_Rights__c, Stance_Approval_Status__c,Consulted__c, Responsible__c, Informed__c, Backup_for_Accountable__c, Accountable__c , Decision__c from Social_Input__c where Decision__c != null and  Informed__c =:true and  GroupId__c in : groupMap.keyset()  ]);
                
                mySocialInputList.addAll(mySocialInputListInfo);
            }
            System.debug('----mySocialInputList------>'+mySocialInputList);
            for(Social_Input__c s: mySocialInputList){
                decisionIdFromSocial.add(s.decision__c);    
            }
            String decisionQuery = 'select Id,Name,Title__c, Status__c,Progress__c, phase__c,Nearest_Due_Date__c,Due_Date__c ,Priority__c,owner.id from Decision__c where Id != null ';
            System.debug('----setEntityIds------>'+setEntityIds);
            decisionQuery = decisionQuery + ' and Id IN : setEntityIds ';
            System.debug('----decisionIdFromSocial------>'+decisionIdFromSocial);
            decisionQuery = decisionQuery + ' and Id IN : decisionIdFromSocial ';
            
            if(datepickerFrom != ''){
                decisionQuery = decisionQuery + ' and LastModifiedDate > : fromDateTime ';
            }
            
            if(datepickerTo != ''){
                decisionQuery = decisionQuery + ' and LastModifiedDate < : toDateTime ';
            }
            
            set<String> setPhase = new set<String>();
            if(phases != null || phases != ''){
                List<String> lstPhase = phases.split(',');
                setPhase.addAll(lstPhase);
                decisionQuery = decisionQuery + ' and Phase__c IN : setPhase ';
            }
            
            if(phases == 'Draft,Execute,Share,Propose,Decide,Evaluate'){
                List<String> lstStatus = status.split(',');
                set<String> setStatus = new set<String>();
                setStatus.addAll(lstStatus);
                if(setPhase.contains('Draft') || setPhase.contains('Share') || setPhase.contains('Propose')){
                    decisionQuery = decisionQuery + ' and Status__c IN : setStatus ';
                }
            }
            if(searchText != '' && searchText != null){
                decisionQuery = decisionQuery + ' and Title__c like  \'%'+searchText+ '%\'';
            }
            List<Decision__c> lstDecision = Database.query(decisionQuery);
            
            set<Id> decId = new set<Id>();
            map<Id, Social__c> smsMap = new map<Id, Social__c>();
            for(Decision__c d: lstDecision) {
                decId.add(d.Id);
            }
            // Issues
            
            if(decId.size() > 0){
                /*for(Issues__c iss: [select id, Related_To_ID__c from Issues__c where Related_To_ID__c In: decId AND Status__c = 'Raised']) {
                  List<Issues__c> issueList = issueMap.get(iss.Related_To_ID__c);
                  if(issueList == null) {
                    issueList = new List<Issues__c>();
                    issueMap.put(iss.Related_To_ID__c, issueList);
                  }
                  issueList.add(iss);
                }*/
            
                // Task
                Datetime todayDT = Datetime.now();  
                for(Task ts: [select id, WhatId from Task where WhatId In: decId AND ActivityDate <: todayDate  and isClosed = false]) {
                  List<Task> taskList = taskMap.get(ts.WhatId);
                  if(taskList == null) {
                    taskList = new List<Task>();
                    taskMap.put(ts.WhatId, taskList);
                  }
                  taskList.add(ts);
                }
                
                // my role in the decision 
                List<Social_Input__c> raciListForTargetObjet = [select Id, Role__c, Veto_Rights__c,Role_Acceptance_Status__c,Stance_Approval_Status__c,Consulted__c, Responsible__c, Informed__c, Backup_for_Accountable__c, Accountable__c , Decision__c from Social_Input__c where Decision__c In:decId and User__c =: UserInfo.getUserId()];
                for(Social_Input__c d: raciListForTargetObjet ) {
                    myRoleForDecision.put(d.Decision__c, d);
                }
                
                // my input values for mood and rating
                List<Social__c> smsList  = [select Total_Issues__c,Total_Likes__c,Total_Dislikes__c, Avg_Mood__c, Avg_Rating__c,Related_To_ID__c   From Social__c where Related_To_ID__c In :decId];
                for(Social__c s:  smsList) {
                    smsMap.put(s.Related_To_ID__c, s); 
                }
            }
            
            System.debug('-----lstDecision------>'+lstDecision);
             map<string,Integer> pulseStatusMap = new map<string,Integer>();
            pulseStatusMap.put('Not Given',0);
            pulseStatusMap.put('Good',1);
            pulseStatusMap.put('Minor Challenges',2);
            pulseStatusMap.put('Critical',3);
            pulseStatusMap.put('Completed',4);
            pulseStatusMap.put('Completed with Problems',5);
            
            for(Decision__c d : lstDecision){
                RecordsWrapper rw = new RecordsWrapper();
                rw.recName = d.Title__c.unescapeHtml4();
                rw.priority = d.priority__c;
                rw.recId = d.Id;
                rw.objName = 'Decision';
                rw.pulseStatusInt = pulsestatusmap.get(d.Progress__c);
                if(phaseStringMap != null && phaseStringMap.get(d.phase__c) != null){   
                    rw.Phase = d.phase__c != null ? phaseStringMap.get(d.phase__c) : '';
                }
                rw.status = d.status__c;
                if(statusColorMap != null && statusColorMap.get(rw.status) != null){    
                    rw.statusColor = rw.status != null ? statusColorMap.get(rw.status) : '';
                }
                if(myRoleForDecision.get(d.Id) != null) {
                    if(myRoleForDecision.get(d.Id).Stance_Approval_Status__c != null) {   
                        rw.stanceApprovalStatus = myRoleForDecision.get(d.Id).Stance_Approval_Status__c == 'Pending Approval' ? 'Pending': (myRoleForDecision.get(d.Id).Stance_Approval_Status__c == 'Approved' ? 'Supported': (myRoleForDecision.get(d.Id).Stance_Approval_Status__c == 'Rejected' ? 'Opposed': 'N/A')) ;
                    } else {
                        rw.stanceApprovalStatus = 'N/A'; 
                    }
                }
                if(stanceColorMap != null && stanceColorMap.get(rw.stanceApprovalStatus) != null){  
                    rw.stanceApprovalStatusColor = rw.stanceApprovalStatus != null ? stanceColorMap.get(rw.stanceApprovalStatus) : '';
                }
                Social__c  sms = smsMap != null && smsMap.get(d.Id) != null ? smsMap.get(d.Id) : null;
                rw.AverageRating = string.valueOf(sms.Avg_Rating__c);
                rw.moodImage = genralInfo != null && genralInfo.imageUrlMap.get('newModdImage') != null ? genralInfo.imageUrlMap.get('newModdImage') : '';
                rw.moodImagePosition = moodImagePositionMap != null && sms.Avg_Mood__c != null && moodImagePositionMap.get(math.round(Double.valueOf(sms.Avg_Mood__c))) != null ? moodImagePositionMap.get(math.round(Double.valueOf(sms.Avg_Mood__c))) : '';
                rw.moodNumber = sms.Avg_Mood__c != null ? string.valueOf(math.round(Double.valueOf(sms.Avg_Mood__c))) : '';
                rw.moodStatus = sms.Avg_Mood__c != null && moodStatusMap.get(math.round(Double.valueOf(sms.Avg_Mood__c))) != null ? moodStatusMap.get(math.round(Double.valueOf(sms.Avg_Mood__c))) : '';
                String avgRatingValue ='';
                if(sms.Avg_Rating__c ==  1.0) {
                    avgRatingValue = 'star11';
                }
                if(sms.Avg_Rating__c > 1.0 && sms.Avg_Rating__c < 2.0 ) {
                    avgRatingValue = 'star1.51';
                }
                    
                if(sms.Avg_Rating__c ==  2.0) {
                    avgRatingValue = 'star21';
                }
                if( sms.Avg_Rating__c > 2.0 && sms.Avg_Rating__c < 3.0 ) {
                    avgRatingValue = 'star2.51';
                }
                if( sms.Avg_Rating__c ==  3.0) {
                    avgRatingValue = 'star31';
                }
                if( sms.Avg_Rating__c > 3.0 && sms.Avg_Rating__c < 4.0 ) {
                    avgRatingValue = 'star3.51';
                }
                if( sms.Avg_Rating__c ==  4.0) {
                    avgRatingValue = 'star41';
                }
                if( sms.Avg_Rating__c > 4.0 && sms.Avg_Rating__c < 5.0 ) {
                    avgRatingValue = 'star4.51';
                }
                if( sms.Avg_Rating__c ==  5.0) {
                    avgRatingValue = 'star51';
                }
                if( sms.Avg_Rating__c == 0.0) {
                    avgRatingValue = 'null';
                }
                rw.Accountable = myRoleForDecision.get(d.Id) != null ? myRoleForDecision.get(d.Id).Accountable__c : false;
                rw.Responsible = myRoleForDecision.get(d.Id) != null ? myRoleForDecision.get(d.Id).Responsible__c : false;
                rw.Consulted = myRoleForDecision.get(d.Id) != null ? myRoleForDecision.get(d.Id).Consulted__c : false;
                rw.Informed = myRoleForDecision.get(d.Id) != null ? myRoleForDecision.get(d.Id).Informed__c : false;
                rw.Backup = myRoleForDecision.get(d.Id) != null ? myRoleForDecision.get(d.Id).Backup_for_Accountable__c : false;
                rw.Veto = myRoleForDecision.get(d.Id) != null ? myRoleForDecision.get(d.Id).Veto_Rights__c : false;
                
                rw.AccountableRoleColor = myRoleForDecision.get(d.Id) != null && myRoleForDecision.get(d.Id).Accountable__c  ?  roleColorMap.get( myRoleForDecision.get(d.Id).Role_Acceptance_status__c ) : '#d9d9d9';
                rw.ResponsibleRoleColor = myRoleForDecision.get(d.Id) != null && myRoleForDecision.get(d.Id).Responsible__c  ?  roleColorMap.get( myRoleForDecision.get(d.Id).Role_Acceptance_status__c ) : '#d9d9d9';
                rw.ConsultedRoleColor = myRoleForDecision.get(d.Id) != null && myRoleForDecision.get(d.Id).Consulted__c  ?  roleColorMap.get( myRoleForDecision.get(d.Id).Role_Acceptance_status__c ) : '#d9d9d9';
                rw.InformedRoleColor = myRoleForDecision.get(d.Id) != null && myRoleForDecision.get(d.Id).Informed__c  ?  roleColorMap.get( myRoleForDecision.get(d.Id).Role_Acceptance_status__c ) : '#d9d9d9';
                rw.BackupRoleColor = myRoleForDecision.get(d.Id) != null && myRoleForDecision.get(d.Id).Backup_for_Accountable__c  ?  roleColorMap.get( myRoleForDecision.get(d.Id).Role_Acceptance_status__c ) : '#d9d9d9';
                rw.VetoRoleColor = myRoleForDecision.get(d.Id) != null && myRoleForDecision.get(d.Id).Veto_Rights__c  ?  roleColorMap.get( myRoleForDecision.get(d.Id).Role_Acceptance_status__c ) : '#d9d9d9';
               
                rw.roleApprovalStatus =   myRoleForDecision.get(d.Id) != null ? myRoleForDecision.get(d.Id).Role_Acceptance_status__c: 'N/A';
               
                rw.relevenceImage= genralInfo.imageUrlMap.get(avgRatingValue);
                rw.OwnerName = genralInfo.useNameMap.get(d.OwnerId).Name;
                rw.ownerDept = genralInfo.useNameMap.get(d.OwnerId).Department;
                rw.ownerPhoto = genralInfo.useNameMap.get(d.OwnerId).SmallPhotoUrl;
                
                //rw.pendingIssueCounts = issueMap.get(d.Id) != null ? issueMap.get(d.Id).size() : 0 ;
                rw.pendingTaskCount = taskMap.get(d.Id) != null ? taskMap.get(d.Id).size() : 0 ;
                rw.TotalLikes = string.valueOf(sms.Total_Likes__c);
                rw.TotalDislikes = string.valueOf(sms.Total_Dislikes__c);
                rw.duedateSorter  = d.Nearest_Due_Date__c;
                if(d.Nearest_Due_Date__c != null){
                    Integer dateLeft = System.today().daysBetween(d.Nearest_Due_Date__c.date());
                    rw.deadlineState = dateLeft >= 0 ? 'Positive' : 'Negative';
                    rw.deadlineNum = genralInfo.MapValuesDate(String.valueOf(d.Nearest_Due_Date__c.day()), String.valueOf(d.Nearest_Due_Date__c.month()), String.valueOf(d.Nearest_Due_Date__c.year()));  
                }
                else
                {
                   rw.deadlineNum = 'N/A';
                   rw.deadlineState =  'Positive' ;
                }
                lstRecordsWrapper.add(rw);
            }
        }
        // this code will work when the user selects Plan from show only dropdown.
        if(setType.contains('Plan')){
            List<Social_Input__c> myUrgentPlanList = new List<Social_Input__c>();
            Set<Id> planIdFromSocial = new set<Id>();
            if(setroleOfUser.contains('Accountable')){
                system.debug('-------roleOfUser-----------'+roleOfUser);
                List<Social_Input__c> myUrgentPlanListAcc = [select Plan__c,Decision__c,Plan__r.id,Plan__r.LastModifiedDate,Plan__r.Start_Time__c,Plan__r.End_Time__c,Plan__r.Name,Plan__r.location__c,Plan__r.Description__c from Social_Input__c where User__c =: owner and Accountable__c = true and Plan__c != null];
                myUrgentPlanList.addAll(myUrgentPlanListAcc);
            }
            if(setroleOfUser.contains('Responsible')){
                system.debug('-------roleOfUser-----------'+roleOfUser);
                List<Social_Input__c> myUrgentPlanListRec = [select Plan__c,Decision__c,Plan__r.id,Plan__r.LastModifiedDate,Plan__r.Start_Time__c,Plan__r.End_Time__c,Plan__r.Name,Plan__r.location__c,Plan__r.Description__c from Social_Input__c where User__c =: owner and Responsible__c = true and Plan__c != null];
                myUrgentPlanList.addAll(myUrgentPlanListRec);
            }
            if(setroleOfUser.contains('Consulted')){
                system.debug('-------roleOfUser-----------'+roleOfUser);
                List<Social_Input__c> myUrgentPlanListCon = [select Plan__c,Decision__c,Plan__r.id,Plan__r.LastModifiedDate,Plan__r.Start_Time__c,Plan__r.End_Time__c,Plan__r.Name,Plan__r.location__c,Plan__r.Description__c from Social_Input__c where User__c =: owner and Consulted__c = true and Plan__c != null];
                myUrgentPlanList.addAll(myUrgentPlanListCon);
            }
            if(setroleOfUser.contains('Informed')){
                system.debug('-------roleOfUser-----------'+roleOfUser);
                List<Social_Input__c> myUrgentPlanListInfo = [select Plan__c,Decision__c,Plan__r.id,Plan__r.LastModifiedDate,Plan__r.Start_Time__c,Plan__r.End_Time__c,Plan__r.Name,Plan__r.location__c,Plan__r.Description__c from Social_Input__c where User__c =: owner and Informed__c = true and Plan__c != null];
               
                Map<id,Group> groupMap = new Map<id,Group>([ Select id  from Group where id in ( Select GroupId  from Groupmember where  UserOrGroupId =:UserInfo.getUserId() )]);
                
                myUrgentPlanList.addAll([select Plan__c,Decision__c,Plan__r.id,Plan__r.LastModifiedDate,Plan__r.Start_Time__c,Plan__r.End_Time__c,Plan__r.Name,Plan__r.location__c,Plan__r.Description__c from Social_Input__c where GroupId__c in: groupMap.keyset() and Informed__c = true and Plan__c != null]);

               
                myUrgentPlanList.addAll(myUrgentPlanListInfo);
            }
            for(Social_Input__c s: myUrgentPlanList){
                planIdFromSocial.add(s.Plan__r.id);    
            }
            
            Map<id,Integer> relationsMapCount  = new Map<id,Integer>();
            Map<id,Social_Input__c> planAccountables = new Map<id,Social_Input__c>();
            Map<id,Relations__c> relationsMap  =  new Map<id,Relations__c>([Select id , Parent_ID__c from Relations__c where Parent_ID__c in : planIdFromSocial  ]);
            planAccountables     =  new Map<id,Social_Input__c> ([select id, User__r.Name, User__r.Department from Social_Input__c where  Accountable__c = true  and Plan__r.id  in :  planIdFromSocial ]);
          //  Int
            for( Relations__c rel : relationsMap.values() ){
                 if( relationsMapCount.get(rel.Parent_ID__c) == null )
                 relationsMapCount.put(rel.Parent_ID__c,1);
                 else
                 relationsMapCount.put(rel.Parent_ID__c,relationsMapCount.get(rel.Parent_ID__c)+1);
                // Integer.valueOf(relationsMapCount.get(rel.Parent_ID__c)+'ddd' );
            }
            
            //Integer.valueOf('zz'+[select id, WhatId from Task where WhatId In: planSet AND ActivityDate <: todayDate ].size());
            for(Task ts: [select id, WhatId from Task where WhatId In: planIdFromSocial AND ActivityDate <: todayDate  and status !=: 'Completed' and status !=: 'Rejected' ]) {
                  
                  List<Task> taskList = taskMapOverdue.get(ts.WhatId);
                  if(taskList == null) {
                    taskList = new List<Task>();
                    taskMapOverdue.put(ts.WhatId, taskList);
                  }
                  taskList.add(ts);
            }
             
            for(Task ts: [select id, WhatId from Task where WhatId In: planIdFromSocial AND ( ( ActivityDate >=: todayDate ) or (  ( ActivityDate <: todayDate ) and (  ( status =: 'Completed' ) or ( status =: 'Rejected' ) )  ) )  ]) {
                    
                  List<Task> taskList = taskMap.get(ts.WhatId);
                  if(taskList == null) {
                    taskList = new List<Task>();
                    taskMap.put(ts.WhatId, taskList);
                  }
                  taskList.add(ts);
            }
                    
            for(Event ts: [select id, WhatId from Event where WhatId In: planIdFromSocial AND ActivityDate <: todayDate  ]) {
                  
                  List<Event> eventList = eventMapOverdue.get(ts.WhatId);
                  if(eventList == null) {
                    eventList = new List<Event>();
                    eventMapOverdue.put(ts.WhatId, eventList);
                  }
                  eventList.add(ts);
            }
            
            for(Event ts: [select id, WhatId from Event where WhatId In: planIdFromSocial AND ActivityDate >=: todayDate ]) {
                  
                  List<Event> eventList = eventMap.get(ts.WhatId);
                  if(eventList == null) {
                    eventList = new List<Event>();
                    eventMap.put(ts.WhatId, eventList);
                  }
                  eventList.add(ts);
            }
            set<Id> planDuplicateIds = new set<Id>();
            for( Social_Input__c plan : myUrgentPlanList ){
                if(planIds.contains(plan.Plan__r.id) && !planDuplicateIds.contains(plan.Plan__r.id)){
                    planDuplicateIds.add(plan.Plan__r.id);
                    RecordsWrapper pw = new RecordsWrapper();
                    //pw.priority  = plan.Priority__c;
                    pw.objName     =  'Plan'; 
                    pw.recId       =  plan.Plan__r.id;
                    pw.modifieddate  = plan.Plan__r.lastmodifieddate != null ? String.valueOf(plan.Plan__r.lastmodifieddate.format(dateFormat)):'';
                    pw.startdate     = plan.Plan__r.Start_Time__c != null ? String.valueOf(plan.Plan__r.Start_Time__c.format(dateFormat)):'';
                    pw.enddate       = plan.Plan__r.End_Time__c != null ? String.valueOf(plan.Plan__r.End_Time__c.format(dateFormat)):'';
                    pw.recName     = plan.Plan__r.Name;
                    if( pw.recName != null){
                        pw.recName      = pw.recName.length() > 80 ? pw.recName.substring(0,77)+'...' :pw.recName.substring(0,pw.recName.length() )  ;
                    }
                    pw.location      = plan.Plan__r.location__c;  
                    if( pw.location != null){
                        pw.location      = pw.location.length() > 80 ? pw.location.substring(0,77)+'...' :pw.location.substring(0,pw.location.length() )  ;
                    }
                    pw.itemCount     = relationsMapCount.get(plan.id);
                    pw.description   = plan.Plan__r.Description__c;  
                    if( pw.description != null){
                        pw.description      = pw.description.length() > 80 ? pw.description.substring(0,77)+'...' :pw.description.substring(0,pw.description.length() )  ;
                    }
                    pw.duedateSorter  = plan.Plan__r.End_Time__c;
                    pw.itemCount     = relationsMapCount.get(plan.Plan__r.id);
                    system.debug('-------planAccountables.get(plan.id)-----------'+planAccountables.get(plan.id));
                    system.debug('-------roleOfUser-----------'+roleOfUser);
                    if(planAccountables.get(plan.id) != null){    
                        pw.accountableName = planAccountables.get(plan.id).User__r.Name;
                        pw.accountableDept = planAccountables.get(plan.id).User__r.Department;
                        pw.accountableImage = genralInfo.useImage.get(planAccountables.get(plan.id).User__r.id);
                    }
                    integer nodueTask   =  taskMap.get(plan.Plan__r.id) != null ? taskMap.get(plan.Plan__r.id).size():0;
                    integer nodueEvent  =  eventMap.get(plan.Plan__r.id) != null ? eventMap.get(plan.Plan__r.id).size():0;
                    integer dueTask     =  taskMapOverdue.get(plan.Plan__r.id) != null ? taskMapOverdue.get(plan.Plan__r.id).size():0;
                    integer dueEvent    =  eventMapOverdue.get(plan.Plan__r.id) != null ? eventMapOverdue.get(plan.Plan__r.id).size():0;
                    pw.dueCount         =  dueTask + dueEvent;  
                    pw.activityCount =   string.valueOf( nodueTask + nodueEvent ) + '/'+ string.valueOf( dueTask + dueEvent+ nodueTask + nodueEvent ) ;
                    lstRecordsWrapper.add(pw);
                }
            }
        }
    }
    
    public class RecordsWrapper {
        public String recId {get; set;}
        public String priority {get; set;}
        public String recName {get; set;}
        public String objName {get; set;}
        public String duedate {get; set;}
        public String status {get; set;}
        public String Phase {get; set;}
        public String myStance {get; set;}
        public String myRole {get;set;}
        public String decisionBy {get; set;}
        public String quality {get; set;}
        public String averageRelevance {get; set;}
        public string TotalLikes{get;set;}
        public string TotalDislikes{get;set;}
        public string moodImagePosition{get;set;}
        public string statusColor{get; set;}
        public string moodStatus{get;set;}
        public string stanceApprovalStatusColor{get;set;}
        public string averageRating {get; set;}
        public string moodNumber{get;set;}
        public Boolean Accountable{get;set;}
        public Boolean Responsible{get;set;}
        public Boolean Consulted{get;set;}
        public Boolean Informed{get;set;}
        public Boolean Backup{get;set;}
        public Boolean Veto{get;set;}
        
        public String AccountableRoleColor{get;set;}
        public String ResponsibleRoleColor{get;set;}
        public String ConsultedRoleColor{get;set;}
        public String InformedRoleColor{get;set;}
        public String BackupRoleColor{get;set;}
        public String VetoRoleColor{get;set;}  
        public String roleApprovalStatus{get;set;} 
        public string relevenceImage{get;set;}
        public string OwnerName{get;set;}
        public string ownerDept{get;set;}
        public string ownerPhoto{get;set;}
        public Integer pendingTaskCount{get;set;}
        public Decimal pendingIssueCounts{get;set;}
        public string stanceApprovalStatus{get;set;}
        public datetime  duedateSorter{get;set;}
        public string moodImage{get;set;}
        public string deadlineState{get;set;}
        public string deadlineNum{get;set;}
        public string modifieddate{get;set;}
        public string location{get;set;}
        public string description{get;set;}
        public integer itemCount{get;set;}
        public string accountableName{get;set;}
        public string accountableDept{get;set;}
        public string accountableImage{get;set;}
        public Integer dueCount{get;set;}
        public string activityCount{get;set;}
        public String startDate {get; set;}
        public String endDate {get; set;}
        public Integer pulseStatusInt{get;set;}
        public Integer compareTo(Object compareTo) {
             RecordsWrapper appdata = (RecordsWrapper) compareTo; 
             if (this.duedateSorter == appdata.duedateSorter) {
                if( this.objName  ==   appdata.objName )
                return 0;
                else
                {
                  if (  this.objName   >   appdata.objName  )
                  return 2;  
                  return -2;                     
                }
             }
              
             if (  this.duedateSorter   >   appdata.duedateSorter  )
              return 1;  
              return -1; 
         }
    }
    
    class TopicRow {
        public String text{get;set;}
        public  List<Topics> items{get;set;}
    }
    class Topics {
        public string text{get;set;}
    }
    
    public class TopicEntity {
        public String topicId {get; set;}
        public String topicName {get; set;}
        public String entityId {get; set;}
    } 
    
    public List<TopicRow> jsonTopicRows {get;set;}

}