global class NetworkView{

    public NetworkView(DecisionTab controller) {

    }


    public NetworkView(ApexPages.StandardController controller) {

    }

   Public static string networkJson {get;set;}
   Public static integer networNodeCount {get;set;}
   static   set<String>  objectsConnectors = new  set<String> ();
   static  set<id> nodesIdset = new  set<id>();
   public  NetworkView()
   {
   
   }
   //Remote call to do autocomplete
   @remoteaction
    global static  string runSearch(string decisionName,String role,String Phase) {   
        
        
        //Query all socialinput accrding to role filter, phase filter and then the search term
        List<Social_Input__c> socialInputList  = [Select id,Decision__r.Title__c,Decision__r.name, Decision__r.id  from social_input__c where user__c =: userinfo.getUserId() and  Decision__c != null and  Decision__r.Title__c Like : '%' + decisionName +'%' and Role__c Like : '%'+role+'%' and decision__r.phase__c like: '%'+ phase +'%' order by Decision__r.lastmodifieddate  ];
        List<decisionWrapp> decisionWrappList = new  List<decisionWrapp>();
        for( Social_Input__c socialInput : socialInputList)
        {   //create objects for remote call
            decisionWrapp dw = new decisionWrapp();
            dw.decisionId = socialInput.decision__r.id;
            dw.recordName = socialInput.decision__r.Title__c;
            decisionWrappList.add(dw);
        
        }
        system.debug(   JSON.serialize(decisionWrappList) );
        return JSON.serialize(decisionWrappList);
    }  
    // class to wrapp decision name and id
    public class decisionWrapp{
        
        public string decisionId{get;set;}
        public string recordName{get;set;}
    }  
    
   
    public class linkWrapp{
        public linkWrapp(String linkId){
            
         this.value = linkId;
        }
        public string value{get;set;}
    }  
    
    
     public class graphWrapp{
        Map<string,list<linkWrapp>>  nodeMap = new  Map<string,list<linkWrapp>> ();
        Map<id,String>  nodeNameMap = new  Map<id,String>  (); 
        Map<id,nodeWrapper>  nodeDetailsMap = new  Map<id,nodeWrapper>  (); 
    }  
    
    // method to build network data 
   @Remoteaction
   global static string buildNetwork(String objectId,String objectType)
   {
    List<nodeWrapper> nodeWrapperList = new  List<nodeWrapper>() ;
    GeneralInformation     generalInfo = new GeneralInformation();     
   

    Map<string,list<linkWrapp>>  nodeMap = new  Map<string,list<linkWrapp>> ();
    Map<id,String>  nodeNameMap = new  Map<id,String>  ();
    Map<id,nodeWrapper>  nodeDetailsMap = new  Map<id,nodeWrapper>  ();
    Map<id,Attachment> attachmentRecord =  new Map<id,Attachment>();
    graphWrapp  graph = new graphWrapp();
    graph.nodeMap     = nodeMap;
    graph.nodeNameMap = nodeNameMap;
    graph.nodeDetailsMap = nodeDetailsMap ;
    
    //create center node for network    
    
    Decision__c     nodeCenter = [SELECT Id,lastmodifieddate,Name,Title__c, Status__c, phase__c,Nearest_Due_Date__c,Due_Date__c ,Priority__c,owner.id FROM Decision__c  WHERE   id =:objectId]; 
    nodesIdset.add(nodeCenter.id);
    nodeWrapper nw = new nodeWrapper();
    nw.nodeName  = nodeCenter.Title__c ;
    nw.nodeType  = 'Decision';
    nw.source    =  nodeCenter.id;
    nw.id    =  nodeCenter.id;
    nw.target    =  nodeCenter.id  ;
     //nodeWrapperList.add(nw);
    linkWrapp l = new linkWrapp(nodeCenter.id); 
    nodeMap.put( nodeCenter.id , new List<linkWrapp>{ l }); 
    nodeNameMap.put(nodeCenter.id ,nodeCenter.Title__c );
    Integer level = 0;  
    List<Task> relatedTaskList = new List<Task>();
    List<Relations__c> relatedNodeList = new List<Relations__c>();
    List<Social_input__c> relatedPeopleList = new List<Social_input__c>();
    Map<id,List<Relations__c>> decisiontoRelation = new Map<id,List<Relations__c>>();
    List<Task> relatedTaskListOld = new List<Task>();
    List<Relations__c> relatedNodeListOld = new List<Relations__c>();
    List<Social_input__c> relatedPeopleListOld = new List<Social_input__c>();  
    attachmentRecord =new Map<id,Attachment>([Select id,Name,ParentId from Attachment where Name in :nodesIdset ]);
    
    //Level is used for multiple level network 
    while(level < 2){  
        //find next level nodes which are related the last level node 
        relatedTaskList = [Select id ,subject ,WhoId , WhatId  from task where ( whatid in : nodesIdset or whoid in: nodesIdset ) AND id not in : relatedTaskListOld  ];
        relatedNodeList = [Select id,Child_ID__c,Child_Object_Name__c,Child_Record_Name__c ,Parent_Id__c,Parent_Record_Name__c,Parent_Object_Name__c ,name from Relations__c where Parent_Id__c!= null  and  Child_Id__c != null and type__c =:'Relation' and     ( Parent_Id__c in : nodesIdset or Child_Id__c in : nodesIdset )  and id not in :relatedNodeListOld  ];
        relatedPeopleList = [Select id, user__c, user__r.name, user__r.SmallPhotoUrl from Social_input__c where Decision__c in : nodesIdset or Plan__c in : nodesIdset    ];
       
        relatedTaskListOld.addAll(relatedTaskList );
        relatedNodeListOld.addAll(relatedNodeList );
        relatedPeopleListOld.addAll(relatedPeopleList );   
         system.debug(nodesIdset);
        system.debug(relatedNodeList );
        system.debug(relatedNodeListOld  );
        // For each relation object associated add it to decisionIdSet if the either Parent_ID__c or Child_ID__c  is in last level ie nodesIdset and other Parent_ID__c or Child_ID__c is decision
        Set<id> decisionIdSet = new set<id>();
        for( Relations__c Relation :relatedNodeList ){
             if( nodesIdset.contains(id.valueOf(Relation.Parent_ID__c)) && Relation.Child_Object_Name__c == 'Decision'  ){
                 decisionIdSet.add(Relation.Child_ID__c);
                 nodesIdset.add(Relation.Child_ID__c);
                 if( decisiontoRelation.get(Relation.Child_ID__c) == null) 
                      decisiontoRelation.put(Relation.Child_ID__c,new List<Relations__c>{Relation});
                 else
                      decisiontoRelation.get(Relation.Child_ID__c).add(Relation); 
            
             }
             else
             if( nodesIdset.contains(id.valueOf(Relation.Child_ID__c)) && Relation.Parent_Object_Name__c == 'Decision'  )
             {  decisionIdSet.add(Relation.Parent_ID__c); 
                nodesIdset.add(Relation.Parent_ID__c);
                if( decisiontoRelation.get(Relation.Parent_ID__c) == null)
                decisiontoRelation.put(Relation.Parent_ID__c,new List<Relations__c>{Relation});
                else
                decisiontoRelation.get(Relation.Parent_ID__c).add(Relation);
             
             }
        }   
        system.debug(decisionIdSet); system.debug(decisiontoRelation);
        // For each relation object associated add it to decisionIdSet if the either Parent_ID__c or Child_ID__c  is in last level ie nodesIdset and other Parent_ID__c or Child_ID__c is plan
         Set<id> planIdSet = new set<id>();
        for( Relations__c Relation :relatedNodeList ){
             if( nodesIdset.contains(id.valueOf(Relation.Parent_ID__c)) && Relation.Child_Object_Name__c == 'Plan'  ){
                 planIdSet.add(Relation.Child_ID__c);
                 nodesIdset.add(Relation.Child_ID__c);
                 if( decisiontoRelation.get(Relation.Child_ID__c) == null) 
                      decisiontoRelation.put(Relation.Child_ID__c,new List<Relations__c>{Relation});
                 else
                      decisiontoRelation.get(Relation.Child_ID__c).add(Relation); 
             }
             else
             if( nodesIdset.contains(id.valueOf(Relation.Child_ID__c)) && Relation.Parent_Object_Name__c == 'Plan'  ){
                 planIdSet.add(Relation.Parent_ID__c);
                 nodesIdset.add(Relation.Parent_ID__c);
                 if( decisiontoRelation.get(Relation.Parent_ID__c) == null)
                    decisiontoRelation.put(Relation.Parent_ID__c,new List<Relations__c>{Relation});
                else
                    decisiontoRelation.get(Relation.Parent_ID__c).add(Relation);
             }
        }  
        
        
           
       // Integer.valueOf( myUrgentPlanList.size()+'xxx');
        Date today   = Date.today();
        Date week1   = Date.today().addDays(7);
        Date week2   = Date.today().addDays(14);
        Date month1  = Date.today().addDays(30);
        Date lessweek1   = Date.today().addDays(-7);
        Date lessweek2   = Date.today().addDays(-14);
        Date lessmonth1  = Date.today().addDays(-30);
        
        //Map to get phase numbers
        map<string,string> phaseStringMap = new map<string,string>();
        phaseStringMap.put('Draft','1.Draft');
        phaseStringMap.put('Share','2.Share');
        phaseStringMap.put('Propose','3a.Propose'); 
        phaseStringMap.put('Decide','3b.Decide');
        phaseStringMap.put('Execute','4.Execute');
        phaseStringMap.put('Evaluate','5.Evaluate');
        phaseStringMap.put('Close','6.Close');
        
        //Map to get status color for decision status
        map<string,string> statusColorMap = new map<string,string>();
        statusColorMap.put('Undecided','ffba00');
        statusColorMap.put('Approved','23a554');
        statusColorMap.put('Rejected','c00000');
        statusColorMap.put('Executed','0f7e39');
        statusColorMap.put('Evaluated','003f75');
        statusColorMap.put('Withdrawn','f273af');
        statusColorMap.put('Cancelled','fed46c');
        statusColorMap.put('Duplicate','1ab39f');
        statusColorMap.put('Closed','373737');
        // Map to get stance color for stance status
        map<string,string> stanceColorMap = new map<string,string>();
        stanceColorMap.put('Supported','23a554');
        stanceColorMap.put('Opposed','e81b05');
        stanceColorMap.put('Pending','ff7800');
        stanceColorMap.put('Not Given','ff6600');
        stanceColorMap.put('N/A','ffba00');
        
        // Map to get mood image position for each node
        map<Integer,String> moodImagePositionMap = new Map<Integer,String>();
        moodImagePositionMap.put(0,'0px -186px');
        moodImagePositionMap.put(1,'0px -106px');
        moodImagePositionMap.put(2,'0px -122px');
        moodImagePositionMap.put(3,'0px -138px');
        moodImagePositionMap.put(4,'0px -154px');
        moodImagePositionMap.put(5,'0px -170px');
        
        //'Not Given','Very Worried','Worried','Neutral','Happy','Very Happy'
        
        //Map to mood text from mood value
        map<Integer,String> moodStatusMap = new map<Integer,String>();
        moodStatusMap.put(0,'Not Given');
        moodStatusMap.put(1,'Very Worried');
        moodStatusMap.put(2,'Worried');
        moodStatusMap.put(3,'Neutral');
        moodStatusMap.put(4,'Happy');
        moodStatusMap.put(5,'Very Happy');
        
        map<string,string> roleColorMap = new map<string,string>();
        roleColorMap.put('Approved/Accepted','#373737');
        roleColorMap.put('Not Accepted','#c00000');
        roleColorMap.put('Pending Approval','#ff6600');
        roleColorMap.put('','#d9d9d9');
        
        date todayDate = Date.today(); 
        date lastWeekDate;
        
        Set<Id> decsionIds = new set<Id>();
        Set<Id> decisionIdFromSocial = new set<Id>();
        Set<Id> planIdFromSocial = new set<Id>();
        
         
        List<Decision__c>  decisionList = [SELECT Id,lastmodifieddate,Name,Title__c, Status__c, phase__c,Nearest_Due_Date__c,Due_Date__c ,Priority__c,owner.id FROM Decision__c  WHERE ID IN:decisionIdSet   ];
        set<string> decisionIds =  new set<string>();
        for(decision__c decision : decisionList )
        decisionIds.add(decision .id); 
        attachmentRecord.putAll(new Map<id,Attachment>([Select id,Name,ParentId from Attachment where Name in :decisionIds  ]));
       
        if(level == 0)
        decisionList.add(nodeCenter);
       
        set<Id> decId = new set<Id>();
        map<Id, Social__c> smsMap = new map<Id, Social__c>();
        if(decisionList.size() > 0){
            for(Decision__c d: decisionList) {
                decId.add(d.Id);
            }
        }
        // Issues
        map<Id, Social_Input__c> myRoleForDecision = new map<Id, Social_Input__c>();
        map<Id,List<Task>> taskMap          = new map<Id,List<Task>>();
        map<Id,List<Task>> taskMapOverdue   = new map<Id,List<Task>>();
        map<Id,List<Event>> eventMap         = new map<Id,List<Event>>();
        map<Id,List<Event>> eventMapOverdue  = new map<Id,List<Event>>();  
        if(decId.size() > 0){
            
        
            // Task
            Datetime todayDT = Datetime.now();  
            for(Task ts: [select id, WhatId from Task where WhatId In: decId AND ActivityDate <: todayDate ]) {
              List<Task> taskList = taskMap.get(ts.WhatId);
              if(taskList == null) {
                taskList = new List<Task>();
                taskMap.put(ts.WhatId, taskList);
              }
              taskList.add(ts);
            }
                
            // my role in the decision 
            List<Social_Input__c> raciListForTargetObjet = [select Id, Role__c, Role_Acceptance_status__c ,Veto_Rights__c, Stance_Approval_Status__c,Consulted__c, Responsible__c, Informed__c, Backup_for_Accountable__c, Accountable__c , Decision__c from Social_Input__c where Decision__c In:decId and User__c =: UserInfo.getUserId()];
            for(Social_Input__c d: raciListForTargetObjet ) {
                myRoleForDecision.put(d.Decision__c, d);
            }
            
            // my input values for mood and rating
            List<Social__c> smsList  = [select Total_Issues__c,Total_Likes__c,Total_Dislikes__c, Avg_Mood__c, Avg_Rating__c,Related_To_ID__c   From Social__c where Related_To_ID__c In :decId];
            for(Social__c s:  smsList) {
                smsMap.put(s.Related_To_ID__c, s); 
            }
        }
        
            // for  each decision record create the card details            
            if(decisionList.size() > 0){
                for(Decision__c d: decisionList) {
                    
                        nw = new nodeWrapper();
                        nw.nodeName  =  d.Title__c ;
                        nw.nodeType  =  'Decision';
                        nw.source    =  d.id;
                        nw.id        =  d.id;
                        nw.target    =   nodeCenter.id ;
                        nodesIdset.add( d.id);
                        nodeWrapperList.add(nw); 
                        nodeDetailsMap.put(d.id,nw);
                        nodeNameMap.put(d.id ,d.Title__c );
                        nw.decisionId = string.ValueOf(d.Id);
                        nw.imageUrl  =     attachmentRecord.get(d.id)!=null?'/servlet/servlet.FileDownload?file='+attachmentRecord.get(d.id).id:'/'+generalInfo.imageUrlMap.get('lifeCycleProfilePic');
                        Datetime decisionDueDate  ;
                       //create links to this node 
                       List<Relations__c> rList = decisiontoRelation.get(d.id);
                       if( rList != null)
                       for(Relations__c r :rList  ){
                            l = new linkWrapp(      d.id   ); 
                            if( nodeMap.get( d.id ) == null )
                            nodeMap.put( d.id  , new List<linkWrapp>{  new linkWrapp(     ( id.valueOf(r.Parent_ID__c) == d.id ? r.child_ID__c :r.Parent_ID__c )   )  }); 
                            else
                            nodeMap.get( d.id ).add(    new linkWrapp(     ( id.valueOf(r.Parent_ID__c) == d.id ? r.child_ID__c :r.Parent_ID__c )   )   ); 
                            id relId1 =  ( id.valueOf(r.Parent_ID__c) == d.id ? r.child_ID__c :r.Parent_ID__c );
                            id relId2 =  ( id.valueOf(r.Parent_ID__c) != d.id ? r.child_ID__c :r.Parent_ID__c );
                            if( nodeMap.get(relId1 ) == null )
                            nodeMap.put(relId1  , new List<linkWrapp>{  new linkWrapp(    relId2   )  }); 
                            else
                            nodeMap.get(relId1 ).add(    new linkWrapp(     relId2   )); 
                            if( nodeMap.get(relId2 ) == null )
                            nodeMap.put(relId2  , new List<linkWrapp>{  new linkWrapp(    relId1  )  }); 
                            else
                            nodeMap.get(relId2 ).add(    new linkWrapp(     relId1   )); 
                        }
                      
                        //Set the nearest due date
                        if(d.Nearest_Due_Date__c != null )
                        {
                             decisionDueDate = d.Nearest_Due_Date__c;
                        }
                        nw.decisionName = d.Title__c.unescapeHtml4();
                        nw.phases = phaseStringMap.get( d.phase__c);
                        nw.status = d.status__c;
                        nw.statusColor = statusColorMap.get(nw.status); 
                        
                        // if stance is pending/Supported/Opposed show that else N/A                  
                        if(myRoleForDecision.get(d.Id) != null) {
                            if(myRoleForDecision.get(d.Id).Stance_Approval_Status__c != null)
                            {   
                                 nw.stanceApprovalStatus = myRoleForDecision.get(d.Id).Stance_Approval_Status__c == 'Pending Approval' ? 'Pending': (  myRoleForDecision.get(d.Id).Stance_Approval_Status__c == 'Approved' ? 'Supported': (  myRoleForDecision.get(d.Id).Stance_Approval_Status__c == 'Rejected' ? 'Opposed': 'N/A'  ) ) ;
                            }
                            else
                                nw.stanceApprovalStatus = 'N/A'; 
                          
                        }
                        nw.stanceApprovalStatusColor = stanceColorMap.get(nw.stanceApprovalStatus); 
                   
                        nw.priority = d.priority__c;
                        Social__c  sms = smsMap.get(d.Id);
                        nw.AverageRating = string.valueOf(sms.Avg_Rating__c);
                        nw.moodImage = generalInfo.imageUrlMap.get('newModdImage');  
                        nw.moodImagePosition = moodImagePositionMap.get(math.round(Double.valueOf(sms.Avg_Mood__c)));
                        nw.moodNumber = string.valueOf(math.round(Double.valueOf(sms.Avg_Mood__c)));
                        nw.moodStatus = moodStatusMap.get(math.round(Double.valueOf(sms.Avg_Mood__c)));
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
                        //Set role of the card holder
                        nw.Accountable = myRoleForDecision.get(d.Id) != null ? myRoleForDecision.get(d.Id).Accountable__c : false;
                        nw.Responsible = myRoleForDecision.get(d.Id) != null ? myRoleForDecision.get(d.Id).Responsible__c : false;
                        nw.Consulted = myRoleForDecision.get(d.Id) != null ? myRoleForDecision.get(d.Id).Consulted__c : false;
                        nw.Informed = myRoleForDecision.get(d.Id) != null ? myRoleForDecision.get(d.Id).Informed__c : false;
                        nw.Backup = myRoleForDecision.get(d.Id) != null ? myRoleForDecision.get(d.Id).Backup_for_Accountable__c : false;
                        nw.Veto = myRoleForDecision.get(d.Id) != null ? myRoleForDecision.get(d.Id).Veto_Rights__c : false;
                        
                        //Set color for role blocks
                        nw.AccountableRoleColor = myRoleForDecision.get(d.Id) != null && myRoleForDecision.get(d.Id).Accountable__c  ?  roleColorMap.get( myRoleForDecision.get(d.Id).Role_Acceptance_status__c ) : '#d9d9d9';
                        nw.ResponsibleRoleColor = myRoleForDecision.get(d.Id) != null && myRoleForDecision.get(d.Id).Responsible__c  ?  roleColorMap.get( myRoleForDecision.get(d.Id).Role_Acceptance_status__c ) : '#d9d9d9';
                        nw.ConsultedRoleColor = myRoleForDecision.get(d.Id) != null && myRoleForDecision.get(d.Id).Consulted__c  ?  roleColorMap.get( myRoleForDecision.get(d.Id).Role_Acceptance_status__c ) : '#d9d9d9';
                        nw.InformedRoleColor = myRoleForDecision.get(d.Id) != null && myRoleForDecision.get(d.Id).Informed__c  ?  roleColorMap.get( myRoleForDecision.get(d.Id).Role_Acceptance_status__c ) : '#d9d9d9';
                        nw.BackupRoleColor = myRoleForDecision.get(d.Id) != null && myRoleForDecision.get(d.Id).Backup_for_Accountable__c  ?  roleColorMap.get( myRoleForDecision.get(d.Id).Role_Acceptance_status__c ) : '#d9d9d9';
                        nw.VetoRoleColor = myRoleForDecision.get(d.Id) != null && myRoleForDecision.get(d.Id).Veto_Rights__c  ?  roleColorMap.get( myRoleForDecision.get(d.Id).Role_Acceptance_status__c ) : '#d9d9d9';
                        
                        //Set decision owner detials
                        nw.relevenceImage= generalInfo.imageUrlMap.get(avgRatingValue);   
                        nw.OwnerName = generalInfo.useNameMap.get(d.OwnerId).Name;
                        nw.ownerDept = generalInfo.useNameMap.get(d.OwnerId).Department;
                        nw.ownerPhoto = generalInfo.useNameMap.get(d.OwnerId).SmallPhotoUrl;
                        
                        //set pending issue count task count  like dislike counts
                        nw.pendingTaskCount = taskMap.get(d.Id) != null ? taskMap.get(d.Id).size() : 0 ;
                        nw.TotalLikes = sms.Total_Likes__c != null ? string.valueOf(sms.Total_Likes__c) : '0';
                        nw.TotalDislikes = sms.Total_Dislikes__c != null ? string.valueOf(sms.Total_Dislikes__c) : '0';
                        nw.duedateSorter  = d.lastmodifieddate;
                        if(d.Nearest_Due_Date__c != null){
                            Integer dateLeft = System.today().daysBetween(d.Nearest_Due_Date__c.date());
                            nw.deadlineState = dateLeft >= 0 ? 'Positive' : 'Negative';
                            nw.deadlineNum = generalInfo.MapValuesDate(String.valueOf(d.Nearest_Due_Date__c.day()), String.valueOf(d.Nearest_Due_Date__c.month()), String.valueOf(d.Nearest_Due_Date__c.year()));  
                        }
                        else                      
    
                        {
                           nw.deadlineNum = 'N/A';
                           nw.deadlineState =  'Positive' ;
                        }
                        
                 }
            }
        
             /*********************Plan *************************/
               System.debug(planIdSet);
               List<Plan__c>  planList        = [select id, OwnerId,   Name, lastmodifieddate, location__c, Description__c,Start_Time__c,End_Time__c from Plan__c where    id in: planIdSet ];
              
               
                Map<id,Integer> relationsMapCount  = new Map<id,Integer>();
                Map<id,Relations__c> relationsMap  =  new Map<id,Relations__c>([Select id , Parent_ID__c from Relations__c where Parent_ID__c in : planIdSet  and Type__c = 'Item' ]);
                //Map<id,Social_Input__c> planAccountables     =  new Map<id,Social_Input__c> ([select id, User__r.Name, User__r.Department from Social_Input__c where  ( Accountable__c = true or Responsible__c = true )  and id  in :  planIdFromSocial ]);
                List<User> lstUser = [select id,Name,Department from User where isActive = true];
                Map<Id,User> mapUser = new Map<Id,User>();
                for(User u : lstUser){
                    mapUser.put(u.Id,u);
                }
              //  Int
                for( Relations__c rel : relationsMap.values() ){
                     if( relationsMapCount.get(rel.Parent_ID__c) == null )
                     relationsMapCount.put(rel.Parent_ID__c,1);
                     else
                     relationsMapCount.put(rel.Parent_ID__c,relationsMapCount.get(rel.Parent_ID__c)+1);
                    // Integer.valueOf(relationsMapCount.get(rel.Parent_ID__c)+'ddd' );
                }
                
                //Integer.valueOf('zz'+[select id, WhatId from Task where WhatId In: planSet AND ActivityDate <: todayDate ].size());
                for(Task ts: [select id, WhatId from Task where WhatId In: planIdSet AND ActivityDate <: todayDate  and status !=: 'Completed' and status !=: 'Rejected' ]) {
                      
                      List<Task> taskList = taskMapOverdue.get(ts.WhatId);
                      if(taskList == null) {
                        taskList = new List<Task>();
                        taskMapOverdue.put(ts.WhatId, taskList);
                      }
                      taskList.add(ts);
                }
                 
                for(Task ts: [select id, WhatId from Task where WhatId In: planIdSet AND ( ( ActivityDate >=: todayDate ) or (  ( ActivityDate <: todayDate ) and (  ( status =: 'Completed' ) or ( status =: 'Rejected' ) )  ) )  ]) {
                        
                      List<Task> taskList = taskMap.get(ts.WhatId);
                      if(taskList == null) {
                        taskList = new List<Task>();
                        taskMap.put(ts.WhatId, taskList);
                      }
                      taskList.add(ts);
                }
                
                for(Event ts: [select id, WhatId from Event where WhatId In: planIdSet AND ActivityDate <: todayDate  ]) {
                      
                      List<Event> eventList = eventMapOverdue.get(ts.WhatId);
                      if(eventList == null) {
                        eventList = new List<Event>();
                        eventMapOverdue.put(ts.WhatId, eventList);
                      }
                      eventList.add(ts);
                }
                
                for(Event ts: [select id, WhatId from Event where WhatId In: planIdSet AND ActivityDate >=: todayDate ]) {
                      
                      List<Event> eventList = eventMap.get(ts.WhatId);
                      if(eventList == null) {
                        eventList = new List<Event>();
                        eventMap.put(ts.WhatId, eventList);
                      }
                      eventList.add(ts);
                }
                
             for( Plan__c plan : planList ){
                    if(plan.Name != null){
                        String dateFormat = generalInfo.MapValuesDateFormate();
                        nw           = new nodeWrapper();
                        nw.nodeName  =  plan.name ;
                        nw.nodeType  =  'Plan';
                        nw.source    =  plan.id;
                        nw.id        =  plan.id;
                        nw.target    =   nodeCenter.id ;
                        nodesIdset.add( plan.id);
                        nodeWrapperList.add(nw); 
                        nodeDetailsMap.put(plan.id,nw);
                        nodeNameMap.put(plan.id ,plan.name);
                        nw.decisionId = string.ValueOf(plan.Id);
                        nw.imageUrl  =     attachmentRecord.get(plan.id)!=null?'/servlet/servlet.FileDownload?file='+attachmentRecord.get(plan.id).id:'/'+generalInfo.imageUrlMap.get('lifeCycleProfilePic');

                        //create links to this node 
                        List<Relations__c> rList = decisiontoRelation.get(plan.id);
                        for(Relations__c r :rList  ){
                            l = new linkWrapp(      plan.id   ); 
                            if( nodeMap.get( plan.id ) == null )
                            nodeMap.put( plan.id  , new List<linkWrapp>{  new linkWrapp(     ( id.valueOf(r.Parent_ID__c) == plan.id ? r.child_ID__c :r.Parent_ID__c )   )  }); 
                            else
                            nodeMap.get( plan.id ).add(    new linkWrapp(     ( id.valueOf(r.Parent_ID__c) == plan.id ? r.child_ID__c :r.Parent_ID__c )   )   ); 
                            id relId1 =  ( id.valueOf(r.Parent_ID__c) == plan.id ? r.child_ID__c :r.Parent_ID__c );
                            id relId2 =  ( id.valueOf(r.Parent_ID__c) != plan.id ? r.child_ID__c :r.Parent_ID__c );
                            if( nodeMap.get(relId1 ) == null )
                            nodeMap.put(relId1  , new List<linkWrapp>{  new linkWrapp(    relId2   )  }); 
                            else
                            nodeMap.get(relId1 ).add(    new linkWrapp(     relId2   )); 
                            if( nodeMap.get(relId2 ) == null )
                            nodeMap.put(relId2  , new List<linkWrapp>{  new linkWrapp(    relId1  )  }); 
                            else
                            nodeMap.get(relId2 ).add(    new linkWrapp(     relId1   )); 
                        }
                        //nw.priority  = plan.Priority__c;
                        nw.modifieddate  = plan.lastmodifieddate != null ? String.valueOf(plan.lastmodifieddate.format(dateFormat)):'';
                        nw.startdate     = plan.Start_Time__c != null ? String.valueOf(plan.Start_Time__c.format(dateFormat)):'N/A';
                        nw.enddate       = plan.End_Time__c != null ? String.valueOf(plan.End_Time__c.format(dateFormat)):'N/A';
                        if( nw.nodeName != null){
                            nw.nodeName      = nw.nodeName.length() > 80 ? nw.nodeName.substring(0,77)+'...' :nw.nodeName.substring(0,nw.nodeName.length() )  ;
                        }
                        nw.location      = plan.location__c;  
                        if( nw.location != null){
                            nw.location      = nw.location.length() > 80 ? nw.location.substring(0,77)+'...' :nw.location.substring(0,nw.location.length() )  ;
                        }
                        nw.itemCount     = relationsMapCount != null && relationsMapCount.get(plan.id) != null ? relationsMapCount.get(plan.id) : 0;
                        nw.description   = plan.Description__c;  
                        if( nw.description != null){
                            nw.description      = nw.description.length() > 80 ? nw.description.substring(0,77)+'...' :nw.description.substring(0,nw.description.length() )  ;
                        }
                        nw.duedateSorter  = plan.lastmodifieddate;
                        //nw.itemCount     = relationsMapCount.get(plan.id);
                        //nw.accountableName = planAccountables != null && planAccountables.get(plan.id) != null ? planAccountables.get(plan.id).User__r.Name : '';
                        //nw.accountableDept = planAccountables != null && planAccountables.get(plan.id) != null ? planAccountables.get(plan.id).User__r.Department : '';
                        //nw.accountableImage = planAccountables != null && planAccountables.get(plan.id) != null ? genInfo.useImage.get(planAccountables.get(plan.id).User__r.id) : '';
                        
                        nw.accountableName = mapUser != null && mapUser.get(plan.OwnerId) != null ? mapUser.get(plan.OwnerId).Name : '';
                        nw.accountableDept = mapUser != null && mapUser.get(plan.OwnerId) != null ? mapUser.get(plan.OwnerId).Department : '';
                        nw.accountableImage = plan.OwnerId != null ? generalInfo.useImage.get(plan.OwnerId) : '';
                        
                        integer nodueTask   =  taskMap.get(plan.id) != null ? taskMap.get(plan.id).size():0;
                        integer nodueEvent  =  eventMap.get(plan.id) != null ? eventMap.get(plan.id).size():0;
                        integer dueTask     =  taskMapOverdue.get(plan.id) != null ? taskMapOverdue.get(plan.id).size():0;
                        integer dueEvent    =  eventMapOverdue.get(plan.id) != null ? eventMapOverdue.get(plan.id).size():0;
                        nw.dueCount         =  dueTask + dueEvent;  
                        nw.activityCount =   string.valueOf( nodueTask + nodueEvent ) + '/'+ string.valueOf( dueTask + dueEvent+ nodueTask + nodueEvent ) ;
                        Date planenddate = null;
                            Date planStartDate = null;
                            if(plan.End_Time__c != null ) 
                            {
                                DateTime Dt = plan.End_Time__c;
                                planenddate = Date.newInstance(Dt.year(),Dt.Month(),Dt.day());
                            }
                            if(plan.Start_Time__c != null){
                                DateTime Dt = plan.Start_Time__c;
                                planStartDate = Date.newInstance(Dt.year(),Dt.Month(),Dt.day());
                            }
                            if( planenddate != null ){
                                 Integer dateLeft = System.today().daysBetween(planenddate);
                                 nw.deadlineState = dateLeft >= 0 ? 'Positive' : 'Negative';
                            }
                            else
                            {
                                 nw.deadlineState =   'Positive';
                            }       
                     }  
                }
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            level++ ;
            
            
        }
       networNodeCount = nodeWrapperList.size();
       networkJson  = Json.serialize(graph); 
       return  networkJson;
    
    }
    
    
    
   
   
   public class nodeWrapper{
        Public string id{get;set;}  
        Public string imageUrl{get;set;}      
        Public string nodeName{get;set;}
        Public string nodeType{get;set;}
        Public string source{get;set;}
        Public string target{get;set;}
        Public boolean fixed{get;set;}
        public string deadLine{get;set;}
        public string duedate{get;set;}
        public datetime  duedateSorter{get;set;}
        public string priority{get;set;}  
        
        public String decisionId{get;set;}
        public string decisionName{get;set;}
        public string problemStatement{get;set;}
        public string decisionNameFull{get;set;}
        public string problemStatementFull{get;set;}
        public string phases{get;set;}
        public string status{get;set;}
        public string myRole{get;set;}
        public string moodImage{get;set;}
        public string relevenceImage{get;set;}
        public Decimal pendingTaskCount{get;set;}
        public Decimal pendingIssueCounts{get;set;}
        public string stanceApprovalStatus{get;set;}
        public string OwnerName{get;set;}
        public string ownerDept{get;set;}
        public string ownerPhoto{get;set;}
        public string deadlineState{get;set;}
        public string deadlineNum{get;set;}
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
        public string moodNumber{get;set;}
        public string AverageRating{get;set;}
        public string TotalLikes{get;set;}
        public string TotalDislikes{get;set;}
        public string statusColor{get;set;}
        public string stanceApprovalStatusColor{get;set;}
        public string moodImagePosition{get;set;}
        public string moodStatus{get;set;}
        //public Social__c sms {get;set;}
        
        
        public string location{get;set;}
        public string description{get;set;}
        public integer itemCount{get;set;}
        public string activityCount{get;set;}
        public string modifieddate{get;set;}
        public string startdate{get;set;}
        public string enddate{get;set;}
        public string accountableName{get;set;}
        public string accountableDept{get;set;}
        public string accountableImage{get;set;}
        public Integer dueCount{get;set;}
        
        
   }
    

}