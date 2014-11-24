/*
 Created by:Phaniraj
 Last Modified by: Phaniraj
 Style: Force.com & Metro
 Description: This class is written to get all the decision details in the workbench. Decisions are filtered based on the filters changed by the user.
*/
public with sharing class WorkbenchDecisionView{
    public List<WorkbenchDecisionWrapper> WorkbenchDecisionWrapperList{get;set;}
    public long nowinmilliseconds{get;set;}
    public string test {get;set;}
    
    //
    public GeneralInformation genralInfo;
    
    //public String dateTimeFormat {get;set;}
    
    //constructor to build decision list to which the user has access to
    public WorkbenchDecisionView(){
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=8');
        genralInfo  = new GeneralInformation();
        nowinmilliseconds  = system.now().getTime();
        //dateTimeFormat = genralInfo.MapValuesDateTime();
        try{
            getMyDecisions();    
        }catch(Exception e){}
    }
    
   
    
    public void getMyDecisions(){
        // get the filter parameters fot decision filtering.
        string timeFrame =  ApexPages.currentPage().getParameters().get('timeFrame');
        string roleOfUser =  ApexPages.currentPage().getParameters().get('roleOfUser');
        string phases =  ApexPages.currentPage().getParameters().get('phases');
        string status =  ApexPages.currentPage().getParameters().get('status');
        string userId =  ApexPages.currentPage().getParameters().get('userId');
        string searchDecisionText =  ApexPages.currentPage().getParameters().get('searchDecisionText');
        
        if(searchDecisionText != '' && searchDecisionText != null){
            if(searchDecisionText.contains('*')){
                String SearchtextList = searchDecisionText.replaceAll('\\*','\\%');
                searchDecisionText = SearchtextList;
            }
        }
        
        System.debug('------------searchDecisionText----------------->'+searchDecisionText);
        
        map<string,string> roleColorMap = new map<string,string>();
        roleColorMap.put('Approved/Accepted','#373737');
        roleColorMap.put('Not Accepted','#c00000');
        roleColorMap.put('Pending Approval','#ff6600');
        roleColorMap.put('','#d9d9d9');
        
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
        
        
        map<Integer,String> moodImagePositionMap = new Map<Integer,String>();
        moodImagePositionMap.put(0,'0px -186px');
        moodImagePositionMap.put(1,'0px -106px');
        moodImagePositionMap.put(2,'0px -122px');
        moodImagePositionMap.put(3,'0px -138px');
        moodImagePositionMap.put(4,'0px -154px');
        moodImagePositionMap.put(5,'0px -170px');
        //moodImagePositionMap.put(0,'icon-neutral');
        //moodImagePositionMap.put(1,'icon-angry');
        //moodImagePositionMap.put(2,'icon-Sad');
        //moodImagePositionMap.put(3,'icon-neutral');
        //moodImagePositionMap.put(4,'icon-smiley');
        //moodImagePositionMap.put(5,'icon-happy');
        
        //'Not Given','Very Worried','Worried','Neutral','Happy','Very Happy'
        
        map<Integer,String> moodStatusMap = new map<Integer,String>();
        moodStatusMap.put(0,'Not Given');
        moodStatusMap.put(1,'Very Worried');
        moodStatusMap.put(2,'Worried');
        moodStatusMap.put(3,'Neutral');
        moodStatusMap.put(4,'Happy');
        moodStatusMap.put(5,'Very Happy');
        
        map<string,Integer> pulseStatusMap = new map<string,Integer>();
            pulseStatusMap.put('Not Given',0);
            pulseStatusMap.put('Good',1);
            pulseStatusMap.put('Minor Challenges',2);
            pulseStatusMap.put('Critical',3);
            pulseStatusMap.put('Completed',4);
            pulseStatusMap.put('Completed with Problems',5);
        
        date todayDate = Date.today(); 
        date lastWeekDate;
        if(timeFrame == '1 Week' || timeFrame == null) {
            lastWeekDate = todayDate.addDays(-7);
        }
        else if(timeFrame == '2 Weeks') {
            lastWeekDate = todayDate.addDays(-14);
        }
        else if(timeFrame == '3 Weeks') {
            lastWeekDate = todayDate.addDays(-21);
        }
        else if(timeFrame == '4 Weeks') {
            lastWeekDate = todayDate.addDays(-28);
        }
        else if(timeFrame == '2 Months') {
            lastWeekDate = todayDate.addMonths(-2);
        }
        else if(timeFrame == '3 Months') {
            lastWeekDate = todayDate.addMonths(-3);
        }
        else if(timeFrame == '4 Months') {
            lastWeekDate = todayDate.addMonths(-4);
        }
        else  {
            lastWeekDate = todayDate.addYears(-10);
        }
        
        Time t = Time.newInstance(0, 0, 0, 0);
        Datetime weekMonthAgo = DateTime.newInstanceGmt(lastWeekDate, t);
        
        if(status == null){
            status = 'All';
        }
        
        if(phases == null){
            phases = 'All';
        }
        if(roleOfUser == null){
            roleOfUser = 'All'; 
        }
        
        string owner;
        if(userId == null || userId == 'default'){
            owner = UserInfo.getUserId();
        }else{
            owner = userId;
        }
        
        Set<Id> decisionIdFromSocial = new set<Id>();
        List<Social_Input__c> mySocialInputList = new List<Social_Input__c>();
        if(roleOfUser == 'Accountable'){
            system.debug('-------roleOfUser-----------'+roleOfUser);
            mySocialInputList = [select Decision__c from Social_Input__c where User__c =: owner and Accountable__c = true and Decision__c != null];
        }else if(roleOfUser == 'Responsible'){
            system.debug('-------roleOfUser-----------'+roleOfUser);
            mySocialInputList = [select Decision__c from Social_Input__c where User__c =: owner and Responsible__c = true and Decision__c != null];
        }else if(roleOfUser == 'Consulted'){
            system.debug('-------roleOfUser-----------'+roleOfUser);
            mySocialInputList = [select Decision__c from Social_Input__c where User__c =: owner and Consulted__c = true and Decision__c != null];
        }else if(roleOfUser == 'Informed'){
            system.debug('-------roleOfUser-----------'+roleOfUser);
         //Query all group where I am a part and then get all socialinput to consider informed group
            Map<id,Group> groupMap = new Map<id,Group>([ Select id  from Group where id in ( Select GroupId  from Groupmember where  UserOrGroupId =:owner )]);
            
            mySocialInputList = [select Decision__c from Social_Input__c where GroupId__c  in : groupMap.keyset() and Informed__c = true and Decision__c != null];
          
            mySocialInputList.addAll([select Decision__c from Social_Input__c where User__c =: owner and Informed__c = true and Decision__c != null]);
        
        }else{
           //Query all group where I am a part and then get all socialinput to consider informed group
            Map<id,Group> groupMap = new Map<id,Group>([ Select id  from Group where id in ( Select GroupId  from Groupmember where  UserOrGroupId =:owner )]);
            
            mySocialInputList = [select Decision__c from Social_Input__c where GroupId__c  in : groupMap.keyset() and Informed__c = true and Decision__c != null];
             
            mySocialInputList.addAll([select Decision__c from Social_Input__c where User__c =: owner and (Accountable__c = true or Responsible__c = true or Consulted__c = true or Informed__c = true) and Decision__c != null]);
        }
        for(Social_Input__c s: mySocialInputList){
            decisionIdFromSocial.add(s.decision__c);        
        }
        
        // get the decision list 
        List<Decision__c>  decisionList = new List<Decision__c>();
        if(status == 'All') {
          if(phases != 'All'){
            if(searchDecisionText != '' && searchDecisionText != null){
                searchDecisionText = '%'+searchDecisionText+'%';    
                decisionList  = [SELECT Id,Name,Progress__c,Title__c, Status__c,Due_Date__c, phase__c,Priority__c,owner.id FROM Decision__c where  ID IN:decisionIdFromSocial and Phase__c =: phases  and LastModifiedDate >= :weekMonthAgo and Title__c like : '%'+searchDecisionText+'%' Order By LastModifiedDate desc limit 200];
            } else {
                decisionList  = [SELECT Id,Name,Progress__c,Title__c, Status__c,Due_Date__c, phase__c,Priority__c,owner.id FROM Decision__c where  ID IN:decisionIdFromSocial and Phase__c =: phases  and LastModifiedDate >= :weekMonthAgo Order By LastModifiedDate desc limit 200];
            }
          }
          else{
            if(searchDecisionText != '' && searchDecisionText != null){
                searchDecisionText = '%'+searchDecisionText+'%';
                decisionList  = [SELECT Id,Name,Progress__c,Title__c, Status__c,Due_Date__c, phase__c ,Priority__c,owner.id FROM Decision__c  WHERE  ID IN:decisionIdFromSocial and    LastModifiedDate >= :weekMonthAgo and Title__c like : '%'+searchDecisionText+'%' Order By LastModifiedDate desc limit 200];
            } else {
                decisionList  = [SELECT Id,Name,Progress__c,Title__c, Status__c,Due_Date__c, phase__c ,Priority__c,owner.id FROM Decision__c  WHERE  ID IN:decisionIdFromSocial and    LastModifiedDate >= :weekMonthAgo Order By LastModifiedDate desc limit 200];
            }
          }
        }
        else {
            if(searchDecisionText != '' && searchDecisionText != null){
                searchDecisionText = '%'+searchDecisionText+'%';
                decisionList  = [SELECT Id,Name,Title__c, Progress__c,Status__c, phase__c,Due_Date__c ,Priority__c,owner.id FROM Decision__c  WHERE   ID IN:decisionIdFromSocial and  Status__c =:status  and  LastModifiedDate >= :weekMonthAgo and Title__c like : '%'+searchDecisionText+'%' Order By LastModifiedDate desc limit 200];
            } else {    
                decisionList  = [SELECT Id,Name,Title__c, Progress__c,Status__c, phase__c,Due_Date__c ,Priority__c,owner.id FROM Decision__c  WHERE   ID IN:decisionIdFromSocial and  Status__c =:status  and  LastModifiedDate >= :weekMonthAgo Order By LastModifiedDate desc limit 200];
            }
        }
        
        
        set<Id> decId = new set<Id>();
        map<Id, Social__c> smsMap = new map<Id, Social__c>();
        if(decisionList.size() > 0){
            for(Decision__c d: decisionList) {
                decId.add(d.Id);
            }
        }
        
        
        // Issues
        //map<Id,List<Issues__c>> issueMap = new map<Id,List<Issues__c>>();
        map<Id, Social_Input__c> myRoleForDecision = new map<Id, Social_Input__c>();
        map<Id,List<Task>> taskMap = new map<Id,List<Task>>();
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
            for(Task ts: [select id, WhatId from Task where WhatId In: decId AND ActivityDate <: todayDate and isClosed = false]) {
              
              List<Task> taskList = taskMap.get(ts.WhatId);
              if(taskList == null) {
                taskList = new List<Task>();
                taskMap.put(ts.WhatId, taskList);
              }
              taskList.add(ts);
            }
            
            // my role in the decision
            List<Social_Input__c> raciListForTargetObjet = [select Id, Role__c, Veto_Rights__c,Role_Acceptance_status__c, Stance_Approval_Status__c,Consulted__c, Responsible__c, Informed__c, Backup_for_Accountable__c, Accountable__c , Decision__c from Social_Input__c where Decision__c In:decId and User__c =: UserInfo.getUserId()];
            for(Social_Input__c d: raciListForTargetObjet ) {
                myRoleForDecision.put(d.Decision__c, d);
            }
            
            // my input values for mood and rating
            List<Social__c> smsList  = [select Total_Issues__c,Mood_Count__c,Total_Likes__c,Total_Dislikes__c, Avg_Mood__c, Avg_Rating__c,Related_To_ID__c   From Social__c where Related_To_ID__c In :decId];
            for(Social__c s:  smsList) {
                smsMap.put(s.Related_To_ID__c, s);
            }
        }
        
        // create a wrapper list of all the values of decision along with social values
        WorkbenchDecisionWrapperList = new List <WorkbenchDecisionWrapper>();
        if(decisionList.size() > 0){
            for(Decision__c d: decisionList) {
                WorkbenchDecisionWrapper dvw = new WorkbenchDecisionWrapper ();
                dvw.decisionId = string.ValueOf(d.Id);
                dvw.decisionName = d.Title__c.unescapeHtml4();
                System.debug('=============='+dvw.decisionName );
                dvw.phases = d.phase__c;
                dvw.status = d.status__c;
                dvw.pulseStatusInt = pulsestatusmap.get(d.Progress__c);
                dvw.statusColor = statusColorMap.get(dvw.status);
                if(myRoleForDecision.get(d.Id) != null) {
                    if(myRoleForDecision.get(d.Id).Stance_Approval_Status__c != null)
                    {   
                             dvw.stanceApprovalStatus = myRoleForDecision.get(d.Id).Stance_Approval_Status__c == 'Pending Approval' ? 'Pending': (  myRoleForDecision.get(d.Id).Stance_Approval_Status__c == 'Approved' ? 'Supported': (  myRoleForDecision.get(d.Id).Stance_Approval_Status__c == 'Rejected' ? 'Opposed': 'N/A'  ) ) ;
                    }
                    else
                        dvw.stanceApprovalStatus = 'N/A';   
                }
                else
                dvw.stanceApprovalStatus = 'N/A';
                if(dvw.stanceApprovalStatus == 'N/A'){
                    dvw.stanceApprovalStatusColor = 'ffba00';
                }else if(dvw.stanceApprovalStatus == 'Pending'){
                    dvw.stanceApprovalStatusColor = 'ff7800';       
                }else if(dvw.stanceApprovalStatus == 'Supported'){
                    dvw.stanceApprovalStatusColor = '23a554';
                }
                else if(dvw.stanceApprovalStatus == 'Opposed'){
                    dvw.stanceApprovalStatusColor = 'e81b05';
                }
                dvw.priority = d.priority__c;
                dvw.sms = smsMap.get(d.Id);
                dvw.AverageRating = string.valueOf(dvw.sms.Avg_Rating__c);
                dvw.moodImage = genralInfo.imageUrlMap.get('newModdImage');  
                dvw.moodImagePosition = moodImagePositionMap.get(math.round(Double.valueOf(dvw.sms.Avg_Mood__c)));
                dvw.moodNumber = string.valueOf(dvw.sms.Mood_Count__c);
                dvw.moodStatus = moodStatusMap.get(math.round(Double.valueOf(dvw.sms.Avg_Mood__c)));
                String avgRatingValue ='';
                if(dvw.sms.Avg_Rating__c ==  1.0) {
                    avgRatingValue = 'star11';
                }
                    
                if(dvw.sms.Avg_Rating__c > 1.0 && dvw.sms.Avg_Rating__c < 2.0 ) {
                    avgRatingValue = 'star1.51';
                }
                    
                if(dvw.sms.Avg_Rating__c ==  2.0) {
                    avgRatingValue = 'star21';
                }
                    
                if(dvw.sms.Avg_Rating__c > 2.0 && dvw.sms.Avg_Rating__c < 3.0 ) {
                    avgRatingValue = 'star2.51';
                }
                    
                if(dvw.sms.Avg_Rating__c ==  3.0) {
                    avgRatingValue = 'star31';
                }
                    
                if(dvw.sms.Avg_Rating__c > 3.0 && dvw.sms.Avg_Rating__c < 4.0 ) {
                    avgRatingValue = 'star3.51';
                }
                    
                if(dvw.sms.Avg_Rating__c ==  4.0) {
                    avgRatingValue = 'star41';
                }
                
                if(dvw.sms.Avg_Rating__c > 4.0 && dvw.sms.Avg_Rating__c < 5.0 ) {
                    avgRatingValue = 'star4.51';
                }
                
                if(dvw.sms.Avg_Rating__c ==  5.0) {
                    avgRatingValue = 'star51';
                }
                
                if(dvw.sms.Avg_Rating__c == 0.0) {
                    avgRatingValue = 'null';
                }
                
                dvw.Accountable = myRoleForDecision.get(d.Id) != null ? myRoleForDecision.get(d.Id).Accountable__c : false;
                dvw.Responsible = myRoleForDecision.get(d.Id) != null ? myRoleForDecision.get(d.Id).Responsible__c : false;
                dvw.Consulted = myRoleForDecision.get(d.Id) != null ? myRoleForDecision.get(d.Id).Consulted__c : false;
                dvw.Informed = myRoleForDecision.get(d.Id) != null ? myRoleForDecision.get(d.Id).Informed__c : false;
                dvw.Backup = myRoleForDecision.get(d.Id) != null ? myRoleForDecision.get(d.Id).Backup_for_Accountable__c : false;
                dvw.Veto = myRoleForDecision.get(d.Id) != null ? myRoleForDecision.get(d.Id).Veto_Rights__c : false;
                
                
                dvw.AccountableRoleColor = myRoleForDecision.get(d.Id) != null && myRoleForDecision.get(d.Id).Accountable__c  ?  roleColorMap.get( myRoleForDecision.get(d.Id).Role_Acceptance_status__c ) : '#d9d9d9';
                dvw.ResponsibleRoleColor = myRoleForDecision.get(d.Id) != null && myRoleForDecision.get(d.Id).Responsible__c  ?  roleColorMap.get( myRoleForDecision.get(d.Id).Role_Acceptance_status__c ) : '#d9d9d9';
                dvw.ConsultedRoleColor = myRoleForDecision.get(d.Id) != null && myRoleForDecision.get(d.Id).Consulted__c  ?  roleColorMap.get( myRoleForDecision.get(d.Id).Role_Acceptance_status__c ) : '#d9d9d9';
                dvw.InformedRoleColor = myRoleForDecision.get(d.Id) != null && myRoleForDecision.get(d.Id).Informed__c  ?  roleColorMap.get( myRoleForDecision.get(d.Id).Role_Acceptance_status__c ) : '#d9d9d9';
                dvw.BackupRoleColor = myRoleForDecision.get(d.Id) != null && myRoleForDecision.get(d.Id).Backup_for_Accountable__c  ?  roleColorMap.get( myRoleForDecision.get(d.Id).Role_Acceptance_status__c ) : '#d9d9d9';
                dvw.VetoRoleColor = myRoleForDecision.get(d.Id) != null && myRoleForDecision.get(d.Id).Veto_Rights__c  ?  roleColorMap.get( myRoleForDecision.get(d.Id).Role_Acceptance_status__c ) : '#d9d9d9';
                
                dvw.roleApprovalStatus =   myRoleForDecision.get(d.Id) != null ? myRoleForDecision.get(d.Id).Role_Acceptance_status__c: 'N/A';
                
                
                dvw.relevenceImage= genralInfo.imageUrlMap.get(avgRatingValue);
                dvw.OwnerName = genralInfo.useNameMap.get(d.OwnerId).Name;
                dvw.ownerDept = genralInfo.useNameMap.get(d.OwnerId).Department;
                dvw.ownerPhoto = genralInfo.useNameMap.get(d.OwnerId).SmallPhotoUrl;
                //dvw.pendingIssueCounts = issueMap.get(d.Id) != null ? issueMap.get(d.Id).size() : 0 ;
                dvw.pendingTaskCount = taskMap.get(d.Id) != null ? taskMap.get(d.Id).size() : 0 ;
                dvw.TotalLikes = dvw.sms.Total_Likes__c != null ? string.valueOf(dvw.sms.Total_Likes__c) : '0';
                dvw.TotalDislikes = dvw.sms.Total_Dislikes__c != null ? string.valueOf(dvw.sms.Total_Dislikes__c) : '0';
                if(d.Due_Date__c != null){
                    Integer dateLeft = System.today().daysBetween(d.Due_Date__c.date());
                    dvw.deadlineState = dateLeft > 0 ? 'Positive' : 'Negative';
                    dvw.deadlineNum = genralInfo.MapValuesDate(String.valueOf(d.Due_Date__c.day()), String.valueOf(d.Due_Date__c.month()), String.valueOf(d.Due_Date__c.year()));  
                }
                else
                {
                  dvw.deadlineNum = 'N/A';
                  dvw.deadlineState =  'Positive' ;
                }
                WorkbenchDecisionWrapperList.add(dvw);
            }
        }
        
     
    }
       // pulse in command center 
     @RemoteAction
        public static void updatePulse(String pulseStatus, String decisionId){
            Decision__c decision = new Decision__c(Id = decisionId);
             decision.Progress__c = pulseStatus;
            if(FLS.decisionUpdateable()){
                update decision;
            }
        }
        
        
    public class WorkbenchDecisionWrapper{
        public String cardType {get;set;}
        public String decisionId{get;set;}
        public string decisionName{get;set;}
        public string phases{get;set;}
        public string status{get;set;}
        public string priority{get;set;}
        public string myRole{get;set;}
        public string moodImage{get;set;}
        public string relevenceImage{get;set;}
        public Integer pendingTaskCount{get;set;}
        public Decimal pendingIssueCounts{get;set;}
        public string stanceApprovalStatus{get;set;}
        public string roleApprovalStatus{get;set;}
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
        public Integer pulseStatusInt{get;set;}
        public Social__c sms {get;set;}
    }
    
      @remoteAction 
      public static string   decisionCards(String searchDecisionText,string timeFrame, String roleOfUser,String phases,string status,string userId,Boolean resetdataSetUpperBound,String cardTypes,Long dataSetUpperBound){  
        GeneralInformation genralInfo  = new GeneralInformation();
        List <WorkbenchDecisionWrapper> WorkbenchDecisionWrapperList = new List <WorkbenchDecisionWrapper>();
      
          
        if( resetdataSetUpperBound )
         dataSetUpperBound  = system.now().getTime();
        system.debug(phases);
        if(searchDecisionText != '' && searchDecisionText != null){
            if(searchDecisionText.contains('*')){
                String SearchtextList = searchDecisionText.replaceAll('\\*','\\%');
                searchDecisionText = SearchtextList;
            }
        }
        
        
        system.debug(dataSetUpperBound);
        
        System.debug('------------searchDecisionText----------------->'+searchDecisionText);
        
        map<string,string> roleColorMap = new map<string,string>();
        roleColorMap.put('Approved/Accepted','#373737');
        roleColorMap.put('Not Accepted','#c00000');
        roleColorMap.put('Pending Approval','#ff6600');
        roleColorMap.put('','#d9d9d9');
        
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
        
        
        map<Integer,String> moodImagePositionMap = new Map<Integer,String>();
        moodImagePositionMap.put(0,'0px -186px');
        moodImagePositionMap.put(1,'0px -106px');
        moodImagePositionMap.put(2,'0px -122px');
        moodImagePositionMap.put(3,'0px -138px');
        moodImagePositionMap.put(4,'0px -154px');
        moodImagePositionMap.put(5,'0px -170px');
        //moodImagePositionMap.put(0,'icon-neutral');
        //moodImagePositionMap.put(1,'icon-angry');
        //moodImagePositionMap.put(2,'icon-Sad');
        //moodImagePositionMap.put(3,'icon-neutral');
        //moodImagePositionMap.put(4,'icon-smiley');
        //moodImagePositionMap.put(5,'icon-happy');
        
        //'Not Given','Very Worried','Worried','Neutral','Happy','Very Happy'
        
        map<Integer,String> moodStatusMap = new map<Integer,String>();
        moodStatusMap.put(0,'Not Given');
        moodStatusMap.put(1,'Very Worried');
        moodStatusMap.put(2,'Worried');
        moodStatusMap.put(3,'Neutral');
        moodStatusMap.put(4,'Happy');
        moodStatusMap.put(5,'Very Happy');
        
        map<string,Integer> pulseStatusMap = new map<string,Integer>();
            pulseStatusMap.put('Not Given',0);
            pulseStatusMap.put('Good',1);
            pulseStatusMap.put('Minor Challenges',2);
            pulseStatusMap.put('Critical',3);
            pulseStatusMap.put('Completed',4);
            pulseStatusMap.put('Completed with Problems',5);
        
        date todayDate = Date.today(); 
        date lastWeekDate;
        if(timeFrame == '1 Week' || timeFrame == null) {
            lastWeekDate = todayDate.addDays(-7);
        }
        else if(timeFrame == '2 Weeks') {
            lastWeekDate = todayDate.addDays(-14);
        }
        else if(timeFrame == '3 Weeks') {
            lastWeekDate = todayDate.addDays(-21);
        }
        else if(timeFrame == '4 Weeks') {
            lastWeekDate = todayDate.addDays(-28);
        }
        else if(timeFrame == '2 Months') {
            lastWeekDate = todayDate.addMonths(-2);
        }
        else if(timeFrame == '3 Months') {
            lastWeekDate = todayDate.addMonths(-3);
        }
        else if(timeFrame == '4 Months') {
            lastWeekDate = todayDate.addMonths(-4);
        }
        else  {
            lastWeekDate = todayDate.addYears(-10);
        }
        
        Time t = Time.newInstance(0, 0, 0, 0);
        Datetime weekMonthAgo = DateTime.newInstanceGmt(lastWeekDate, t);
        
        if(status == null){
            status = 'All';
        }
        
        if(phases == null){
            phases = 'All';
        }
        if(roleOfUser == null){
            roleOfUser = 'All'; 
        }
        
        string owner;
        if(userId == null || userId == 'default'){
            owner = UserInfo.getUserId();
        }else{
            owner = userId;
        }
        Datetime  dataSetUpperBoundTime =   datetime.newInstance(dataSetUpperBound);
        Set<Id> decisionIdFromSocial = new set<Id>();
        List<Social_Input__c> mySocialInputList = new List<Social_Input__c>();
          system.debug(status);
          system.debug(phases);
          system.debug(searchDecisionText);  
        
        if(status == 'All')
        status = '%'; 
        if(searchDecisionText != '' && searchDecisionText != null) 
        searchDecisionText = '%'+searchDecisionText+'%'; 
        else
        searchDecisionText = '%' ; 
          system.debug(status);
          system.debug(phases);
          system.debug(searchDecisionText);  
          system.debug(weekMonthAgo);  
          system.debug(dataSetUpperBoundTime);  
           
            
        if(roleOfUser == 'Accountable'){
            system.debug('-------roleOfUser-----------'+roleOfUser);
            mySocialInputList = [select Decision__c from Social_Input__c where User__c =: owner and Accountable__c = true and Decision__c != null and Decision__r.Status__c Like: status and Decision__r.phase__c Like: phases  and Decision__r.Title__c Like: searchDecisionText and  Decision__r.lastmodifieddate >=: weekMonthAgo  and  Decision__r.lastmodifieddate<: dataSetUpperBoundTime order by Decision__r.lastmodifieddate desc limit 6 ];
        }else if(roleOfUser == 'Responsible'){
            system.debug('-------roleOfUser-----------'+roleOfUser);
            mySocialInputList = [select Decision__c from Social_Input__c where User__c =: owner and Responsible__c = true and Decision__c != null and Decision__r.Status__c Like: status and Decision__r.phase__c Like: phases  and Decision__r.Title__c Like: searchDecisionText and  Decision__r.lastmodifieddate >=: weekMonthAgo and Decision__r.lastmodifieddate<: dataSetUpperBoundTime order by Decision__r.lastmodifieddate desc limit 6];
        }else if(roleOfUser == 'Consulted'){
            system.debug('-------roleOfUser-----------'+roleOfUser);
            mySocialInputList = [select Decision__c from Social_Input__c where User__c =: owner and Consulted__c = true and Decision__c != null and Decision__r.Status__c Like: status and Decision__r.phase__c Like: phases  and Decision__r.Title__c Like: searchDecisionText and  Decision__r.lastmodifieddate >=: weekMonthAgo and Decision__r.lastmodifieddate<: dataSetUpperBoundTime order by Decision__r.lastmodifieddate desc limit 6];
        }else if(roleOfUser == 'Informed'){
            system.debug('-------roleOfUser-----------'+roleOfUser);
         //Query all group where I am a part and then get all socialinput to consider informed group
            Map<id,Group> groupMap = new Map<id,Group>([ Select id  from Group where id in ( Select GroupId  from Groupmember where  UserOrGroupId =:owner )]);
            
            mySocialInputList = [select Decision__c from Social_Input__c where GroupId__c  in : groupMap.keyset() and Informed__c = true and Decision__c != null and Decision__r.Status__c Like: status and Decision__r.phase__c =: phases  and Decision__r.Title__c =: searchDecisionText and  Decision__r.lastmodifieddate >=: weekMonthAgo and Decision__r.lastmodifieddate<: dataSetUpperBoundTime order by Decision__r.lastmodifieddate desc  limit 6];
          
            mySocialInputList.addAll([select Decision__c from Social_Input__c where User__c =: owner and Informed__c = true and Decision__c != null and Decision__r.Status__c Like: status and Decision__r.phase__c Like: phases  and Decision__r.Title__c Like: searchDecisionText and  Decision__r.lastmodifieddate >=: weekMonthAgo and Decision__r.lastmodifieddate<: dataSetUpperBoundTime order by Decision__r.lastmodifieddate desc  limit 6]);
           
            mySocialInputList = [select Decision__c from Social_Input__c where id in:mySocialInputList  order by Decision__r.lastmodifieddate desc  limit 6];
       
        }else{
           //Query all group where I am a part and then get all socialinput to consider informed group
            Map<id,Group> groupMap = new Map<id,Group>([ Select id  from Group where id in ( Select GroupId  from Groupmember where  UserOrGroupId =:owner )]);
	        mySocialInputList = [select Decision__c from Social_Input__c where GroupId__c  in : groupMap.keyset() and Informed__c = true and Decision__c != null and Decision__r.Status__c Like: status and Decision__r.phase__c Like: phases  and Decision__r.Title__c Like: searchDecisionText and  Decision__r.lastmodifieddate >=: weekMonthAgo and Decision__r.lastmodifieddate<: dataSetUpperBoundTime order by Decision__r.lastmodifieddate desc  limit 6];
            set<id> mySocialInputListDecision  = new set<id>();
            for(Social_Input__c s: mySocialInputList){
            	mySocialInputListDecision.add(s.decision__c);         
            }
            mySocialInputList.addAll([select Decision__c from Social_Input__c where User__c =: owner and (Accountable__c = true or Responsible__c = true or Consulted__c = true or Informed__c = true) and  Decision__c not in:mySocialInputListDecision   and Decision__c != null and Decision__r.Status__c Like: status and Decision__r.phase__c Like:  phases  and Decision__r.Title__c Like: searchDecisionText and  Decision__r.lastmodifieddate >=: weekMonthAgo and Decision__r.lastmodifieddate<: dataSetUpperBoundTime order by Decision__r.lastmodifieddate desc  limit 6]);
            mySocialInputList = [select Decision__c from Social_Input__c where id in:mySocialInputList  order by Decision__r.lastmodifieddate desc  limit 6];
        }
        for(Social_Input__c s: mySocialInputList){
            system.debug(s.decision__c);
            decisionIdFromSocial.add(s.decision__c);        
        }
        
    system.debug( decisionIdFromSocial );
        
       List<Decision__c> decisionList  = [SELECT Id,Name,Title__c, Progress__c,Status__c, phase__c,Due_Date__c ,lastModifieddate,Priority__c,owner.id FROM Decision__c  WHERE   ID IN:decisionIdFromSocial      Order By LastModifiedDate desc limit 200];
       
        set<Id> decId = new set<Id>();
        map<Id, Social__c> smsMap = new map<Id, Social__c>();
        if(decisionList.size() > 0){
            for(Decision__c d: decisionList) {
                decId.add(d.Id);
            }
        }
        
        
        // Issues
        //map<Id,List<Issues__c>> issueMap = new map<Id,List<Issues__c>>();
        map<Id, Social_Input__c> myRoleForDecision = new map<Id, Social_Input__c>();
        map<Id,List<Task>> taskMap = new map<Id,List<Task>>();
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
            for(Task ts: [select id, WhatId from Task where WhatId In: decId AND ActivityDate <: todayDate and isClosed = false]) {
              
              List<Task> taskList = taskMap.get(ts.WhatId);
              if(taskList == null) {
                taskList = new List<Task>();
                taskMap.put(ts.WhatId, taskList);
              }
              taskList.add(ts);
            }
            
            // my role in the decision
            List<Social_Input__c> raciListForTargetObjet = [select Id, Role__c, Veto_Rights__c,Role_Acceptance_status__c, Stance_Approval_Status__c,Consulted__c, Responsible__c, Informed__c, Backup_for_Accountable__c, Accountable__c , Decision__c from Social_Input__c where Decision__c In:decId and User__c =: UserInfo.getUserId()];
            for(Social_Input__c d: raciListForTargetObjet ) {
                myRoleForDecision.put(d.Decision__c, d);
            }
            
            // my input values for mood and rating
            List<Social__c> smsList  = [select Total_Issues__c,Mood_Count__c,Total_Likes__c,Total_Dislikes__c, Avg_Mood__c, Avg_Rating__c,Related_To_ID__c   From Social__c where Related_To_ID__c In :decId];
            for(Social__c s:  smsList) {
                smsMap.put(s.Related_To_ID__c, s);
            }
        }
        Long lastModifiedDate  =dataSetUpperBound; 
        // create a wrapper list of all the values of decision along with social values
        if(decisionList.size() > 0){
            for(Decision__c d: decisionList) {
                WorkbenchDecisionWrapper dvw = new WorkbenchDecisionWrapper ();
                dvw.cardType = 'Decision';
                dvw.decisionId = string.ValueOf(d.Id);
                dvw.decisionName = d.Title__c.unescapeHtml4();
                System.debug('=============='+dvw.decisionName );
                dvw.phases = d.phase__c;
                if(lastModifiedDate >= d.lastModifiedDate.getTime())
                lastModifiedDate  = d.lastModifiedDate.getTime();
                dvw.status = d.status__c;
                dvw.pulseStatusInt = pulsestatusmap.get(d.Progress__c);
                dvw.statusColor = statusColorMap.get(dvw.status);
                if(myRoleForDecision.get(d.Id) != null) {
                    if(myRoleForDecision.get(d.Id).Stance_Approval_Status__c != null)
                    {   
                             dvw.stanceApprovalStatus = myRoleForDecision.get(d.Id).Stance_Approval_Status__c == 'Pending Approval' ? 'Pending': (  myRoleForDecision.get(d.Id).Stance_Approval_Status__c == 'Approved' ? 'Supported': (  myRoleForDecision.get(d.Id).Stance_Approval_Status__c == 'Rejected' ? 'Opposed': 'N/A'  ) ) ;
                    }
                    else
                        dvw.stanceApprovalStatus = 'N/A';   
                }
                else
                dvw.stanceApprovalStatus = 'N/A';
                if(dvw.stanceApprovalStatus == 'N/A'){
                    dvw.stanceApprovalStatusColor = 'ffba00';
                }else if(dvw.stanceApprovalStatus == 'Pending'){
                    dvw.stanceApprovalStatusColor = 'ff7800';       
                }else if(dvw.stanceApprovalStatus == 'Supported'){
                    dvw.stanceApprovalStatusColor = '23a554';
                }
                else if(dvw.stanceApprovalStatus == 'Opposed'){
                    dvw.stanceApprovalStatusColor = 'e81b05';
                }
                dvw.priority = d.priority__c;
                dvw.sms = smsMap.get(d.Id);
                dvw.AverageRating = string.valueOf(dvw.sms.Avg_Rating__c);
                dvw.moodImage = genralInfo.imageUrlMap.get('newModdImage');  
                dvw.moodImagePosition = moodImagePositionMap.get(math.round(Double.valueOf(dvw.sms.Avg_Mood__c)));
                dvw.moodNumber = string.valueOf(dvw.sms.Mood_Count__c);
                dvw.moodStatus = moodStatusMap.get(math.round(Double.valueOf(dvw.sms.Avg_Mood__c)));
                String avgRatingValue ='';
                if(dvw.sms.Avg_Rating__c ==  1.0) {
                    avgRatingValue = 'star11';
                }
                    
                if(dvw.sms.Avg_Rating__c > 1.0 && dvw.sms.Avg_Rating__c < 2.0 ) {
                    avgRatingValue = 'star1.51';
                }
                    
                if(dvw.sms.Avg_Rating__c ==  2.0) {
                    avgRatingValue = 'star21';
                }
                    
                if(dvw.sms.Avg_Rating__c > 2.0 && dvw.sms.Avg_Rating__c < 3.0 ) {
                    avgRatingValue = 'star2.51';
                }
                    
                if(dvw.sms.Avg_Rating__c ==  3.0) {
                    avgRatingValue = 'star31';
                }
                    
                if(dvw.sms.Avg_Rating__c > 3.0 && dvw.sms.Avg_Rating__c < 4.0 ) {
                    avgRatingValue = 'star3.51';
                }
                    
                if(dvw.sms.Avg_Rating__c ==  4.0) {
                    avgRatingValue = 'star41';
                }
                
                if(dvw.sms.Avg_Rating__c > 4.0 && dvw.sms.Avg_Rating__c < 5.0 ) {
                    avgRatingValue = 'star4.51';
                }
                
                if(dvw.sms.Avg_Rating__c ==  5.0) {
                    avgRatingValue = 'star51';
                }
                
                if(dvw.sms.Avg_Rating__c == 0.0) {
                    avgRatingValue = 'null';
                }
                
                dvw.Accountable = myRoleForDecision.get(d.Id) != null ? myRoleForDecision.get(d.Id).Accountable__c : false;
                dvw.Responsible = myRoleForDecision.get(d.Id) != null ? myRoleForDecision.get(d.Id).Responsible__c : false;
                dvw.Consulted = myRoleForDecision.get(d.Id) != null ? myRoleForDecision.get(d.Id).Consulted__c : false;
                dvw.Informed = myRoleForDecision.get(d.Id) != null ? myRoleForDecision.get(d.Id).Informed__c : false;
                dvw.Backup = myRoleForDecision.get(d.Id) != null ? myRoleForDecision.get(d.Id).Backup_for_Accountable__c : false;
                dvw.Veto = myRoleForDecision.get(d.Id) != null ? myRoleForDecision.get(d.Id).Veto_Rights__c : false;
                
                
                dvw.AccountableRoleColor = myRoleForDecision.get(d.Id) != null && myRoleForDecision.get(d.Id).Accountable__c  ?  roleColorMap.get( myRoleForDecision.get(d.Id).Role_Acceptance_status__c ) : '#d9d9d9';
                dvw.ResponsibleRoleColor = myRoleForDecision.get(d.Id) != null && myRoleForDecision.get(d.Id).Responsible__c  ?  roleColorMap.get( myRoleForDecision.get(d.Id).Role_Acceptance_status__c ) : '#d9d9d9';
                dvw.ConsultedRoleColor = myRoleForDecision.get(d.Id) != null && myRoleForDecision.get(d.Id).Consulted__c  ?  roleColorMap.get( myRoleForDecision.get(d.Id).Role_Acceptance_status__c ) : '#d9d9d9';
                dvw.InformedRoleColor = myRoleForDecision.get(d.Id) != null && myRoleForDecision.get(d.Id).Informed__c  ?  roleColorMap.get( myRoleForDecision.get(d.Id).Role_Acceptance_status__c ) : '#d9d9d9';
                dvw.BackupRoleColor = myRoleForDecision.get(d.Id) != null && myRoleForDecision.get(d.Id).Backup_for_Accountable__c  ?  roleColorMap.get( myRoleForDecision.get(d.Id).Role_Acceptance_status__c ) : '#d9d9d9';
                dvw.VetoRoleColor = myRoleForDecision.get(d.Id) != null && myRoleForDecision.get(d.Id).Veto_Rights__c  ?  roleColorMap.get( myRoleForDecision.get(d.Id).Role_Acceptance_status__c ) : '#d9d9d9';
                
                dvw.roleApprovalStatus =   myRoleForDecision.get(d.Id) != null ? myRoleForDecision.get(d.Id).Role_Acceptance_status__c: 'N/A';
                
                
                dvw.relevenceImage= genralInfo.imageUrlMap.get(avgRatingValue);
                dvw.OwnerName = genralInfo.useNameMap.get(d.OwnerId).Name;
                dvw.ownerDept = genralInfo.useNameMap.get(d.OwnerId).Department;
                dvw.ownerPhoto = genralInfo.useNameMap.get(d.OwnerId).SmallPhotoUrl;
                //dvw.pendingIssueCounts = issueMap.get(d.Id) != null ? issueMap.get(d.Id).size() : 0 ;
                dvw.pendingTaskCount = taskMap.get(d.Id) != null ? taskMap.get(d.Id).size() : 0 ;
                dvw.TotalLikes = dvw.sms.Total_Likes__c != null ? string.valueOf(dvw.sms.Total_Likes__c) : '0';
                dvw.TotalDislikes = dvw.sms.Total_Dislikes__c != null ? string.valueOf(dvw.sms.Total_Dislikes__c) : '0';
                if(d.Due_Date__c != null){
                    Integer dateLeft = System.today().daysBetween(d.Due_Date__c.date());
                    dvw.deadlineState = dateLeft > 0 ? 'Positive' : 'Negative';
                    dvw.deadlineNum = genralInfo.MapValuesDate(String.valueOf(d.Due_Date__c.day()), String.valueOf(d.Due_Date__c.month()), String.valueOf(d.Due_Date__c.year()));  
                }
                else
                {
                  dvw.deadlineNum = 'N/A';
                  dvw.deadlineState =  'Positive' ;
                }
                WorkbenchDecisionWrapperList.add(dvw);
            }
        }
       cardsWarapper tw =  new cardsWarapper ();
 
       tw.importantWrapperList =  WorkbenchDecisionWrapperList;
       tw.columnTimeLowerBound =  String.valueOf(system.now().getTime());
       tw.columnTimeUpperBound =  String.valueOf(system.now().getTime()); 
       tw.dataSetUpperBound    =  string.valueOf(lastModifiedDate);
       tw.phase    =   phases; 
       tw.columnId    =    '0';
       system.debug(tw);
       return  JSON.serialize(tw);
    }
    
    public class cardsWarapper{
        
        List<WorkbenchDecisionWrapper > importantWrapperList{get;set;}
        String  columnTimeLowerBound{get;set;}
        String  columnTimeUpperBound{get;set;}
        String  dataSetUpperBound{get;set;}
        String  columnId{get;set;}
        String  phase{get;set;}
        String  done{get;set;}
     }
}