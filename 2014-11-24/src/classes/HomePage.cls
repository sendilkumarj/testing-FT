/*
 Created by:Phaniraj
 Last Modified by: Phaniraj 
 Style: Force.com & Metro
 Description: This class is written for setting up the backend data of home page.
*/

global with sharing class HomePage{
    public string myDecisliimitionsJson{get;set;}
    public static string myIssuesJson{get;set;}
    public static string myTasksJson{get;set;}
    public string myTeamTasksJson{get;set;}
    public string decisionHighlightJson{get;set;}
     // user locale date fromat as string 
    public String dateFormat {get;set;}
    public String toDoJason {get;set;}
    public static final Long    nowinmilliseconds{get;set;}
    public static String dateFormatStatic {get;set;}
    public static String dateTimeFormatStatic {get;set;}
    public GeneralInformation genInfo {get;set;}
    // user locale datetime fromat as string 
    public static String dateTimeFormat {get;set;}
    public static List<myCollegueTaskWrapper> myCollegueTaskWrapperList{get;set;} 
    public static List<myDecisionsWrapper> myDecisionsWrapperList{get;set;}
    public static List<myTasksWrapper> myTasksWrapperList{get;set;}
    public static List<myTasksWrapper> myTeamTasksWrapperList{get;set;}
    public static List<pendingApprovalWrapper> pendingApprovalList{get;set;}
    public static string approvalJSON{get;set;}
    public static string urgentApprovalJSON{get;set;}
    public static string urgentTaskJSON{get;set;}
    public static string urgentIssuesJSON{get;set;}
    public static string urgentDecisionJSON{get;set;} 
    public static string pendingApprovalJSON{get;set;}
    public static string myCollegueTaskJSON{get;set;}
    // Dynamic picklist values as string
    public String taskStatusPicklist {get;set;}
    public string taskPriorityPicklist {get;set;}
    
    public static string decisionHighlightsJson{get;set;}
    public static list<string> importantListHeaders{get;set;}
    public static map<id,social__c> socialDetails{get;set;}
    
    // View task popup variables
    public String taskId {get; set;}
    public String taskEditable {get; set;}
    public String modeType {get; set;}
    public Boolean showTaskPopup {get; set;}
    
    public static GeneralInformation genralInfo;
    
    //chart links
    public string linkDecisionCreated{get;set;} 
    public string linkDecisionCreatedByUser{get;set;} 
    public string linkDecisionProgress {get;set;}
    
    public boolean   decisionCheckboxSelected{get;set;}
    public boolean   planCheckboxSelected{get;set;}
    public boolean   taskCheckboxSelected{get;set;}
    public boolean   approvalCheckboxSelected{get;set;}
    public string    urgentTabsCountJason{get;set;}
    
    public boolean walkmeDecisionVar {get; set;}
    
    public Integer overdueCount{get;set;}
    public Integer todayCount{get;set;}
    public Integer weekCount{get;set;}
    public Integer monthCount{get;set;}
    public Integer noDeadlineCount{get;set;}
    public static string  userLocaleSidKey{get;set;}
    static{
            // variable to send current time
            nowinmilliseconds =  System.currentTimeMillis();
            //variable to send user locale
            userLocaleSidKey  = UserInfo.getLocale().replace('_','-');
            if(genralInfo == null ) {
               genralInfo  = new GeneralInformation();
               dateFormatStatic = genralInfo.MapValuesDateFormate();                        
            } 
    }
    
    // constructor
    public HomePage(){
        
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=8');  
        // create my decision list for kendo table
        //myDecisions('');
        
        walkmeDecisionVar = false;
        showTaskPopup = false;
        
        // List<Decision__c> myDecisionList = [select Id, Name,Title__c, phase__c, lastModifieddate, due_Date__c from decision__c where OwnerId=: UserInfo.getUserId() and phase__c != 'Close' and Title__c != null order by lastModifieddate desc];
        List<Decision__c> myDecisionList = [select Id, Name,Title__c, Progress__c ,phase__c, lastModifieddate, due_Date__c,CreatedById from decision__c where Title__c != null order by lastModifieddate desc];
        
        for(Decision__c d:myDecisionList){
            if(d.CreatedById == userinfo.getuserId()){
                walkmeDecisionVar = true;
                break;
            }
        }
        
            map<string,Integer> pulseStatusMap = new map<string,Integer>();
            pulseStatusMap.put('Not Given',0);
            pulseStatusMap.put('Good',1);
            pulseStatusMap.put('Minor Challenges',2);
            pulseStatusMap.put('Critical',3);
            pulseStatusMap.put('Completed',4);
            pulseStatusMap.put('Completed with Problems',5);
        
       
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
         
        // Code for dynamic picklist
        
        // dynamic picklist for task status
        Schema.DescribeFieldResult  statusResult1 = Task.Status.getDescribe();
        List<Schema.PicklistEntry>  statusPickList1 = statusResult1.getPicklistValues();
        taskStatusPicklist = '';
        Integer  i=0;
         for(Schema.PicklistEntry statusValue1 : statusPickList1){
            taskStatusPicklist = taskStatusPicklist+  ',{StatusValue:'+'\"'+statusValue1.getLabel() +'\"'+', StatusName :' + '\"' + statusValue1.getLabel()  + '\"' + '}' ;
            i++;
        }
        taskStatusPicklist  = taskStatusPicklist.replaceFirst(',','');

     
        // dynamic picklist for task priority
        Schema.DescribeFieldResult  priorityResult1 = Task.Priority.getDescribe();
        List<Schema.PicklistEntry>  priorityPickList1 = priorityResult1.getPicklistValues();
        taskPriorityPicklist = '';
        for(Schema.PicklistEntry priorityValue1 : priorityPickList1){
            taskPriorityPicklist = taskPriorityPicklist +  '{ PriorityName :' + '\"' + priorityValue1.getLabel() + '\"' + '},' ;
        }
        
        
        
               
        //chart links
        importantListHeaders = new list<String>{'Overdue','Today','1 week','1 month+','No deadline' };
        List<Report>  reportDecisionCreated = [Select r.Name, r.Id From Report r where r.Name ='Decisions Created'];
        linkDecisionCreated = '#';
        if(reportDecisionCreated.size() > 0) {  
            linkDecisionCreated = reportDecisionCreated[0].Id;
        }
        // Reports for Decisions Created by users
        List<Report>  reportDecisionCreatedByUser = [Select r.Name, r.Id From Report r where r.Name ='Decisions Created by users'];
        linkDecisionCreatedByUser = '#';
        if(reportDecisionCreatedByUser.size() > 0) {
            linkDecisionCreatedByUser = reportDecisionCreatedByUser[0].Id;   
        }
        // Reports for Decision Progress
        List<Report>  reportDecisionProgress = [Select r.Name, r.Id From Report r where r.Name ='Decision Progress'];
        linkDecisionProgress = '#';
        if(reportDecisionProgress.size() > 0) {
            linkDecisionProgress = reportDecisionProgress[0].Id;
        }
        
      
     
    }
    
    global static string assignedTaskData(){
        return null;
    }
    
    @RemoteAction
    global static string assignedTaskDataWithSearchTimeFrame(String searchText , String timeSelected){
        // initialize General information class to get user locale date format and image static resouce url        
        if(genralInfo == null ) {
            genralInfo  = new GeneralInformation();
        }
        Date todaysDate = System.today();
        
        // These conditions are based on user slected dropdown
        if(timeSelected == '24hours'){
            todaysDate = todaysDate.addDays(1);
        } else if(timeSelected == '48hours'){
            todaysDate = todaysDate.addDays(2);
        } else if(timeSelected == '' || timeSelected == '7days'){
            todaysDate = todaysDate.addDays(7);
        } else if(timeSelected == '1month'){
            todaysDate = todaysDate.addMonths(1);
        } else if(timeSelected == 'All'){
            todaysDate = todaysDate.addYears(10);
        }
        
        // Search text to replace * with %
        if(searchText != ''){
            if(searchText.contains('*')){
                String SearchtextList=searchText.replaceAll('\\*','\\%');
                searchText = SearchtextList;
            }
        }
        
        myCollegueTaskWrapperList = new List<myCollegueTaskWrapper>();
        List<Task> assignedTaskList = new List<Task>();
        if(searchText != ''){
            searchText = searchText+'%';
            if(timeSelected == 'All'){
                // This query is used when user selects "All" from the drop down, which will query all the records even when due date is null
                assignedTaskList = [select Subject, whatId, What.Name, whoId, Who.Name, activityDate, status, priority,CreatedById, ownerId from task where IsClosed = false and createdById =: UserInfo.getUserId() and OwnerId !=: UserInfo.getUserId() and Subject like : '%'+searchText+'%'  Order by ActivityDate DESC NULLS LAST ];
            } else {
                assignedTaskList = [select Subject, whatId, What.Name, whoId, Who.Name, activityDate, status, priority,CreatedById, ownerId from task where activityDate <=: todaysDate and IsClosed = false and createdById =: UserInfo.getUserId() and OwnerId !=: UserInfo.getUserId() and Subject like : '%'+searchText+'%'  Order by ActivityDate DESC ];
            }
        } else {
            if(timeSelected == 'All'){
                // This query is used when user selects "All" from the drop down, which will query all the records even when due date is null
                assignedTaskList = [select Subject, whatId, What.Name, whoId, Who.Name, activityDate, status, priority,CreatedById, ownerId from task where IsClosed = false and createdById =: UserInfo.getUserId() and OwnerId !=: UserInfo.getUserId() Order by ActivityDate DESC NULLS LAST ];
            } else {
                assignedTaskList = [select Subject, whatId, What.Name, whoId, Who.Name, activityDate, status, priority,CreatedById, ownerId from task where activityDate <=: todaysDate and IsClosed = false and createdById =: UserInfo.getUserId() and OwnerId !=: UserInfo.getUserId() Order by ActivityDate DESC ];
            }
        }
        
        // Dynamic picklist tasks status& language issue fixes
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
        
        for(task t:assignedTaskList){
            myCollegueTaskWrapper wr = new myCollegueTaskWrapper();
            wr.Subject = t.Subject;
            wr.Id = t.Id;
            wr.relatedToName = t.What.Name != null  ?  t.What.Name : t.Who.Name != null ? t.Who.Name : ' ';
            wr.relatedToId = t.WhatId != null ?  t.WhatId : t.WhoId != null ? t.WhoId : null;
            wr.DueDate = t.ActivityDate != null ? t.ActivityDate.format(): '';   
            wr.Status = taskstatus.get(t.status) == null ? t.status: taskstatus.get(t.status);
            wr.StatusImage = genralInfo.imageUrlMap.get(t.Status);
            wr.Priority= taskpriority.get(t.Priority) == null ? t.Priority: taskpriority.get(t.Priority); 
            wr.AssignedId = t.OwnerId;
            wr.AssignedName = genralInfo.useNameMap.get(t.OwnerId).Name;
            wr.typeOfTask = 'Task';
            wr.dueDateSort = t.ActivityDate != null ? t.ActivityDate: null;   
            myCollegueTaskWrapperList.add(wr);
        }
        
        myCollegueTaskJSON = JSON.serialize(myCollegueTaskWrapperList);
        return myCollegueTaskJSON;
    }
    
    // approval table 
    @RemoteAction
    global static string approvalTab() {
        
        //GeneralInformation genralInfo  = new GeneralInformation();
        // initialize General information class to get user locale date format and image static resouce url
        if(genralInfo == null ) {
            genralInfo  = new GeneralInformation();
        }
        dateTimeFormat = genralInfo.MapValuesDateTime();
        
        map<Id,Decision__c> decisionMap = new map<Id,Decision__c> ([Select id,Name,Title__c,Due_Date__c from Decision__c]);
        map<Id,Social_Input__c> socialInputMap = new map<Id,Social_Input__c> ([Select s.Veto_Rights__c, s.User__c,s.Stance_Approval_Status__c,s.Role__c, s.Role_Acceptance_Status__c, s.Role_Acceptance_Required__c, s.Responsible__c, s.Informed__c, s.Id, s.Final_Approval_Status__c, s.Decision__c,s.Decision__r.Title__c,s.Decision__r.Problem_Idea_Advice__c,s.Decision__r.Decision_Taken__c,s.Decision__r.Due_Date__c, s.CreatedDate, s.CreatedById, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c, s.Accountable__c From Social_Input__c s where  s.User__c =: userInfo.getUserId() and s.Decision__c !=null order by lastModifiedDate desc ]);
        List<ApprovalWrapper> approvalWrapperList = new List<ApprovalWrapper>();
        for(ProcessInstanceWorkitem piw : [Select p.ProcessInstance.Status, p.ProcessInstance.TargetObjectId, p.ProcessInstanceId, p.Id, p.CreatedDate, p.CreatedBy.Name, p.CreatedById, p.Actor.Name, p.ActorId From ProcessInstanceWorkitem p where  p.ActorId =: Userinfo.getUserId() AND p.ProcessInstance.TargetObjectId IN: socialInputMap .keyset() order by p.CreatedDate desc]) {
            ApprovalWrapper aw = new ApprovalWrapper();
            aw.id = piw.Id;
            aw.decisionId = socialInputMap.get(piw.ProcessInstance.TargetObjectId).Decision__c;
            aw.Title = socialInputMap.get(piw.ProcessInstance.TargetObjectId).Decision__r.Title__c;
            aw.problemStmt = socialInputMap.get(piw.ProcessInstance.TargetObjectId).Decision__r.Problem_Idea_Advice__c != null?  string.escapeSingleQuotes(socialInputMap.get(piw.ProcessInstance.TargetObjectId).Decision__r.Problem_Idea_Advice__c) : '';
            aw.decision = socialInputMap.get(piw.ProcessInstance.TargetObjectId).Decision__r.Decision_Taken__c != null ? string.escapeSingleQuotes(socialInputMap.get(piw.ProcessInstance.TargetObjectId).Decision__r.Decision_Taken__c) : '';
            aw.step = socialInputMap.get(piw.ProcessInstance.TargetObjectId).Stance_Approval_Status__c == null ? 'Role Acceptance' : socialInputMap.get(piw.ProcessInstance.TargetObjectId).Final_Approval_Status__c == null ? 'Stance Approval' : 'Decision Approval';
            // Condtions for diaplaying action icons based on approvals
            aw.approveImg = aw.step == 'Role Acceptance' ? genralInfo.imageUrlMap.get('roleApprovalImg') : aw.step == 'Stance Approval' ? genralInfo.imageUrlMap.get('personalApprovalImg') : genralInfo.imageUrlMap.get('finalApprovalImg');
            aw.titleHover = aw.step == 'Role Acceptance' ? 'Accept/Reject' : aw.step == 'Stance Approval' ? 'Support/Oppose' : 'Approve/Reject';
            aw.status = piw.ProcessInstance.Status;
            aw.statusImage = genralInfo.imageUrlMap.get('pending');
            aw.createdBy = piw.CreatedBy.Name;
            if( socialInputMap.get(piw.ProcessInstance.TargetObjectId).Role__c != null  )
            aw.userRole = socialInputMap.get(piw.ProcessInstance.TargetObjectId).Role__c.replaceAll(' ',', ');
            aw.vetoRights = socialInputMap.get(piw.ProcessInstance.TargetObjectId).Veto_Rights__c;
            aw.backupRights = socialInputMap.get(piw.ProcessInstance.TargetObjectId).Backup_for_Accountable__c;
           // aw.createdDate = String.valueOf(piw.CreatedDate.format(dateTimeFormat)); //.format(dateTimeFormat);
            aw.dueDate = socialInputMap.get(piw.ProcessInstance.TargetObjectId).Decision__r.Due_Date__c == null ? '':String.valueOf(socialInputMap.get(piw.ProcessInstance.TargetObjectId).Decision__r.Due_Date__c.format(dateTimeFormat)) ; //.format(dateTimeFormat);
            
            //start added on 21-4-2014
            aw.dueDateSort = socialInputMap.get(piw.ProcessInstance.TargetObjectId).Decision__r.Due_Date__c != null ?socialInputMap.get(piw.ProcessInstance.TargetObjectId).Decision__r.Due_Date__c:null;
            //end added on 21-4-2014
            
            approvalWrapperList.add(aw);
        }    
        // serialize records list
        approvalJSON = JSON.serialize(approvalWrapperList);
        return approvalJSON;
    }
    
    // Cerates Collabrator Json String. This method is deprecated because of intorduction of search functionality. Instead we are using UrgentApprovalTabWithSearchTimeFrame. This method is requiered from packaging perspective.
    global static string UrgentApprovalTab() {
        return null;
    }
    
    // Creates urgent approvals JSON string. This method is updated with search feature for peoples tab.
    @RemoteAction
    global static string UrgentApprovalTabWithSearchTimeFrame(String searchText , String timeSelected) {
        // initialize General information class to get user locale date format and image static resouce url
        if(genralInfo == null ) {
            genralInfo  = new GeneralInformation();
        }
        
        dateTimeFormat = genralInfo.MapValuesDateTime();
        DateTime todaysDate = DateTime.now();
        
        // Code for the time frames for approvals
        if(timeSelected == '24hours'){
            todaysDate = todaysDate.addDays(1);
        } else if(timeSelected == '48hours'){
            todaysDate = todaysDate.addDays(2);
        } else if(timeSelected == '' || timeSelected == '7days'){
            todaysDate = todaysDate.addDays(7);
        } else if(timeSelected == '1month'){
            todaysDate = todaysDate.addMonths(1);
        } else if(timeSelected == 'All'){
            todaysDate = todaysDate.addYears(10);
        }
       
        // To replace * with % in searh area.
        if(searchText != ''){
            if(searchText.contains('*')){
                String SearchtextList=searchText.replaceAll('\\*','\\%');
                searchText = SearchtextList;
            }
        }
        
        map<Id,Social_Input__c> socialInputMap = new map<Id,Social_Input__c>();
        
        // Condition for search text when it contains value
        if(searchText != ''){
            socialInputMap = new map<Id,Social_Input__c> ([Select s.Veto_Rights__c,s.Stance_Approval_Status__c, s.User__c, s.Role_Acceptance_Status__c, s.Role_Acceptance_Required__c,s.Role__c, s.Responsible__c, s.Informed__c, s.Id, s.Final_Approval_Status__c, s.Decision__c,s.Decision__r.Title__c,s.Decision__r.Problem_Idea_Advice__c,s.Decision__r.Decision_Taken__c, s.CreatedDate, s.CreatedById, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c, s.Accountable__c,s.Decision__r.Due_Date__c,s.Decision__r.OwnerId From Social_Input__c s where  s.User__c =: userInfo.getUserId() and s.Decision__c != null and s.Decision__r.Title__c like : '%'+searchText+'%']);
        } else {
            socialInputMap = new map<Id,Social_Input__c> ([Select s.Veto_Rights__c,s.Stance_Approval_Status__c, s.User__c, s.Role_Acceptance_Status__c, s.Role_Acceptance_Required__c,s.Role__c, s.Responsible__c, s.Informed__c, s.Id, s.Final_Approval_Status__c, s.Decision__c,s.Decision__r.Title__c,s.Decision__r.Problem_Idea_Advice__c,s.Decision__r.Decision_Taken__c, s.CreatedDate, s.CreatedById, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c, s.Accountable__c,s.Decision__r.Due_Date__c,s.Decision__r.OwnerId From Social_Input__c s where  s.User__c =: userInfo.getUserId() and s.Decision__c != null]);
        }
        
        set<id> SocialDecisionId = new set<id>(); 
        for(id socialInputId : socialInputMap.keyset()){
            SocialDecisionId.add(socialInputMap.get(socialInputId).Decision__c);
        }
        List<Timing__c> TimingRecords = new List<Timing__c>();
        if(timeSelected == 'All'){  
            TimingRecords =[Select id,End_Date_Time__c,Related_To_ID__c from Timing__c where Related_To_ID__c in:SocialDecisionId and Stage__c='Propose'];
        } else {
            TimingRecords =[Select id,End_Date_Time__c,Related_To_ID__c from Timing__c where Related_To_ID__c in:SocialDecisionId and Stage__c='Propose' and End_Date_Time__c <=: todaysDate];
        }
        List<UrgentApprovalWrapper> approvalWrapperList = new List<UrgentApprovalWrapper>();
        for(ProcessInstanceWorkitem piw : [Select p.ProcessInstance.Status, p.ProcessInstance.TargetObjectId, p.ProcessInstanceId, p.Id, p.CreatedDate, p.CreatedBy.Name, p.CreatedById, p.Actor.Name, p.ActorId From ProcessInstanceWorkitem p where  p.ActorId =: Userinfo.getUserId() AND p.ProcessInstance.TargetObjectId IN: socialInputMap.keyset() order by p.CreatedDate desc ]) {
           for(Timing__c t : TimingRecords){
               if(socialInputMap.get(piw.ProcessInstance.TargetObjectId).Final_Approval_Status__c != null || socialInputMap.get(piw.ProcessInstance.TargetObjectId).Stance_Approval_Status__c != null){
                  if(socialInputMap.get(piw.ProcessInstance.TargetObjectId).Decision__c == t.Related_To_ID__c){  
                    UrgentApprovalWrapper aw = new UrgentApprovalWrapper();
                    aw.id = piw.Id;
                    aw.decisionId = socialInputMap.get(piw.ProcessInstance.TargetObjectId).Decision__c;
                    aw.Title = socialInputMap.get(piw.ProcessInstance.TargetObjectId).Decision__r.Title__c;
                    aw.problemStmt = socialInputMap.get(piw.ProcessInstance.TargetObjectId).Decision__r.Problem_Idea_Advice__c != null?  string.escapeSingleQuotes(socialInputMap.get(piw.ProcessInstance.TargetObjectId).Decision__r.Problem_Idea_Advice__c) : '';
                    aw.decision = socialInputMap.get(piw.ProcessInstance.TargetObjectId).Decision__r.Decision_Taken__c != null ? string.escapeSingleQuotes(socialInputMap.get(piw.ProcessInstance.TargetObjectId).Decision__r.Decision_Taken__c) : '';
                    aw.step = socialInputMap.get(piw.ProcessInstance.TargetObjectId).Final_Approval_Status__c == null ? 'Stance Approval' : socialInputMap.get(piw.ProcessInstance.TargetObjectId).Stance_Approval_Status__c == null ? 'Role Acceptance' : 'Decision Approval';
                    // Condtions for diaplaying action icons based on approvals
                    aw.approveImg = aw.step == 'Role Acceptance' ? genralInfo.imageUrlMap.get('roleApprovalImg') : aw.step == 'Stance Approval' ? genralInfo.imageUrlMap.get('personalApprovalImg') : genralInfo.imageUrlMap.get('finalApprovalImg');
                    aw.titleHover = aw.step == 'Role Acceptance' ? 'Accept/Reject' : aw.step == 'Stance Approval' ? 'Support/Oppose' : 'Approve/Reject';
                    aw.status = piw.ProcessInstance.Status;
                    aw.statusImage = genralInfo.imageUrlMap.get('pending');
                    aw.OwnerId = socialInputMap.get(piw.ProcessInstance.TargetObjectId).Decision__r.OwnerId;
                    aw.Owner = genralInfo.useNameMap.get(aw.OwnerId).Name;
                    aw.myRole = socialInputMap.get(piw.ProcessInstance.TargetObjectId).Role__c.replaceAll(' ',', '); 
                    //aw.DueDate = socialInputMap.get(piw.ProcessInstance.TargetObjectId).Decision__r.Due_Date__c != null ? String.valueOf(socialInputMap.get(piw.ProcessInstance.TargetObjectId).Decision__r.Due_Date__c.format(dateTimeFormat)):''; //.format(dateTimeFormat);
                    aw.DueDate = t.End_Date_Time__c != null ? String.valueOf(t.End_Date_Time__c.format(dateTimeFormat)) : '';
                    aw.fieldTitle1 = 'Problem Statement';
                    aw.fieldTitle2 = 'Decision';
                    aw.vetoRights = socialInputMap.get(piw.ProcessInstance.TargetObjectId).Veto_Rights__c;
                    aw.backupRights = socialInputMap.get(piw.ProcessInstance.TargetObjectId).Backup_for_Accountable__c;
                   
                    // start added on 22-04-2014
                    aw.dueDateSort = socialInputMap.get(piw.ProcessInstance.TargetObjectId).Decision__r.Due_Date__c != null ? socialInputMap.get(piw.ProcessInstance.TargetObjectId).Decision__r.Due_Date__c:null; //.format(dateTimeFormat);
                    // end added on 22-04-2014
                    approvalWrapperList.add(aw);
                  }
               }
           }
        }    
        
        // serialize records list
        urgentApprovalJSON = JSON.serialize(approvalWrapperList);
        return urgentApprovalJSON;
    }
    
    global static string UrgentTaskTab(){
        return null;
    }
    
    @RemoteAction
    global static string UrgentTaskTabWithSearchTimeFrame(String searchText , String timeSelected){
        // initialize General information class to get user locale date format and image static resouce url
        if(genralInfo == null ) {
            genralInfo  = new GeneralInformation();
        }
        Date todaysDate = System.today();
        dateTimeFormat = genralInfo.MapValuesDateTime();
        
        // These conditions are based on user slected dropdown
        if(timeSelected == '24hours'){
            todaysDate = todaysDate.addDays(1);
        } else if(timeSelected == '48hours'){
            todaysDate = todaysDate.addDays(2);
        } else if(timeSelected == '' || timeSelected == '7days'){
            todaysDate = todaysDate.addDays(7);
        } else if(timeSelected == '1month'){
            todaysDate = todaysDate.addMonths(1);
        } else if(timeSelected == 'All'){
            todaysDate = todaysDate.addYears(10);
        }
        
        // Search text to replace * with %
        if(searchText != ''){
            if(searchText.contains('*')){
                String SearchtextList=searchText.replaceAll('\\*','\\%');
                searchText = SearchtextList;
            }
        }
        
        List<Task> urgentTaskList = new List<Task>();
        if(searchText != ''){
            searchText = searchText+'%';
            if(timeSelected == 'All'){
                // This query is used when user selects "All" from the drop down, which will query all the records even when due date is null
                urgentTaskList = [Select t.Id, t.ActivityDate , t.WhatId, t.WhoId, t.What.Name, t.Who.Name, t.Subject, t.Status, t.Priority,t.ownerId,t.Owner.Name , t.CreatedById,t.CreatedBy.Name From Task t where t.Owner.id =: UserInfo.getUserId() and t.Subject like : '%'+searchText+'%' and t.IsClosed = false  order by t.ActivityDate DESC NULLS LAST ];
            } else {
                urgentTaskList = [Select t.Id, t.ActivityDate , t.WhatId, t.WhoId, t.What.Name, t.Who.Name, t.Subject, t.Status, t.Priority,t.ownerId,t.Owner.Name , t.CreatedById,t.CreatedBy.Name From Task t where t.ActivityDate <=: todaysDate and t.Owner.id =: UserInfo.getUserId() and t.Subject like : '%'+searchText+'%' and t.IsClosed = false  order by t.ActivityDate DESC,  id ];
            }
        } else {
            if(timeSelected == 'All'){
                // This query is used when user selects "All" from the drop down, which will query all the records even when due date is null
                urgentTaskList = [Select t.Id, t.ActivityDate , t.WhatId, t.WhoId, t.What.Name, t.Who.Name, t.Subject, t.Status, t.Priority,t.ownerId,t.Owner.Name , t.CreatedById,t.CreatedBy.Name From Task t where t.Owner.id =: UserInfo.getUserId() and t.IsClosed = false  order by t.ActivityDate DESC NULLS LAST ];
            } else {
                urgentTaskList = [Select t.Id, t.ActivityDate , t.WhatId, t.WhoId, t.What.Name, t.Who.Name, t.Subject, t.Status, t.Priority,t.ownerId,t.Owner.Name , t.CreatedById,t.CreatedBy.Name From Task t where t.ActivityDate <=: todaysDate and t.Owner.id =: UserInfo.getUserId() and t.IsClosed = false  order by t.ActivityDate DESC ,id ];
            }
        }
        
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
        
        List<urgentTaskWrapper> urgentTaskWrapperList = new List<urgentTaskWrapper>();
        for(Task t:urgentTaskList){
            urgentTaskWrapper tr = new urgentTaskWrapper();
            tr.Id = t.Id;
            tr.title = t.subject;
            tr.relatedToId = t.WhatId != null ?  t.WhatId : t.WhoId != null ? t.WhoId : null; 
            tr.relatedTo =  t.What.Name != null && t.What.Name != '...' ?  t.What.Name.replace('\'','') : t.Who.Name != null ? t.Who.Name.replace('\'','')  : ''; 
            tr.DueDate =  t.ActivityDate != null ? genralInfo.MapValuesDate(String.valueOf(t.ActivityDate.day()), String.valueOf(t.ActivityDate.month()), String.valueOf(t.ActivityDate.year())) : '';
            tr.status = taskstatus.get(t.status) == null ? t.status: taskstatus.get(t.status); 
            tr.Priority= taskpriority.get(t.Priority) == null ? t.Priority: taskpriority.get(t.Priority); 
            tr.CreatedById = t.CreatedById;
            tr.CreatedBy = t.CreatedBy.Name;
            //start added on 22-04-2014
            //tr.dueDateSort =  t.ActivityDate != null ?t.ActivityDate: null;
            tr.dueDateSort =  t.ActivityDate;
            //end added on 22-04-2014
            urgentTaskWrapperList.add(tr);  
        }
        // serialize records list
        urgentTaskJSON = JSON.serialize(urgentTaskWrapperList);
        return urgentTaskJSON;
    }
    
    @RemoteAction
    global static string saveModifiedData(string modifiedDataStr){
        return null;
    }
    
    @RemoteAction
    global static string saveModifiedDataWithSearchTimeFrame(string modifiedDataStr , String selectedTimeFrame, String searchValue){
        System.debug(modifiedDataStr );
        System.debug(selectedTimeFrame); 
        Date todaysDate = System.today();
        
        // These conditions are based on user selected dropdown
        if(selectedTimeFrame == '24hours'){
            todaysDate = todaysDate.addDays(1);
        } else if(selectedTimeFrame == '48hours'){
            todaysDate = todaysDate.addDays(2);
        } else if(selectedTimeFrame == '' || selectedTimeFrame == '7days'){
            todaysDate = todaysDate.addDays(7);
        } else if(selectedTimeFrame == '1month'){
            todaysDate = todaysDate.addMonths(1);
        } else if(selectedTimeFrame == 'All'){
            todaysDate = todaysDate.addYears(10);
        }
        System.debug('------todaysDate------>'+todaysDate);
        List<Task> urgentTaskList = new List<Task>();
        if(selectedTimeFrame == 'All'){
            // This query is used when user selects "All" from the drop down, which will query all the records even when due date is null
            urgentTaskList = [Select t.Id, t.ActivityDate , t.WhatId, t.Subject, t.Status, t.Priority,t.ownerId,t.Owner.Name , t.CreatedById,t.CreatedBy.Name From Task t where t.OwnerId =: UserInfo.getUserId() and t.IsClosed = false  order by t.ActivityDate ASC];
        } else {
            urgentTaskList = [Select t.Id, t.ActivityDate , t.WhatId, t.Subject, t.Status, t.Priority,t.ownerId,t.Owner.Name , t.CreatedById,t.CreatedBy.Name From Task t where t.ActivityDate <=: todaysDate and t.OwnerId =: UserInfo.getUserId() and t.IsClosed = false  order by t.ActivityDate ASC];
        }
        System.debug('------urgentTaskList------>'+urgentTaskList);
        Map<Id,Task> urgentTaskMap = new Map<Id,Task>();
        
        for(Task t: urgentTaskList){
            urgentTaskMap.put(t.Id,t);  
        }
        String modifiedData = modifiedDataStr; 
        
        DataWrap  pv = (DataWrap ) System.JSON.deserialize(modifiedDataStr, DataWrap.class); 
        System.debug(pv);
         System.debug(urgentTaskList );
        List< urgentTaskWrapper> allUrgentTask = pv.data.models;
        
       
        
        //List<Relations__c> plnList =  getPlanRelation(p.Id);
        
        List<Task> tobeUpdatedTask = new List<Task>();
       // system.debug('-----------Due date---------------'+dataList[0].DueDate);
        
         // Dynamic picklist tasks status & language issue fixes
        Schema.DescribeFieldResult  statusResult = Task.Status.getDescribe();
        List<Schema.PicklistEntry>  statusPickList = statusResult.getPicklistValues();
        
        Map<String, String> taskstatus = new Map<String, String>();
        
        for(Schema.PicklistEntry statusValue : statusPickList){
           taskstatus.put(statusValue.getLabel(),statusValue.getValue());
        }
        
        // Dynamic picklist for tasks priority & language issue fixes
        Schema.DescribeFieldResult  priorityResult = Task.Priority.getDescribe();
        List<Schema.PicklistEntry>  priorityPickList = priorityResult.getPicklistValues();
        
        Map<String, String> taskpriority = new Map<String, String>();
        
        for(Schema.PicklistEntry priorityValue : priorityPickList){
            taskpriority.put(priorityValue.getValue(),priorityValue.getLabel());
        }
        System.debug(urgentTaskMap);
        for(urgentTaskWrapper ut : allUrgentTask ) {
            if(urgentTaskMap.get(ut.Id) != null){
                Task t = urgentTaskMap.get(ut.Id);
                if(ut.title != null){
                    t.Subject = ut.title.length() > 255 ? ut.title.substring(0,254) : ut.title;
                }
                if(ut.dueDateSort == null){
                    t.ActivityDate = null;
                } else {
                   // t.ActivityDate = Date.valueOf(ut.DueDate).addDays(1);
                   t.ActivityDate = ut.dueDateSort.date();
                   //t.ActivityDate = Date.valueOf(ut.dueDateSort.date()).addDays(1);
                    
                } 
                t.Status = taskstatus.get(ut.Status) == null ? ut.Status : taskstatus.get(ut.Status);
                t.Priority = taskpriority.get(ut.Priority) == null ? ut.Priority: taskpriority.get(ut.Priority);
                
                tobeUpdatedTask.add(t);
            }
        }
        if(tobeUpdatedTask.size () > 0) {
           if(FLS.taskUpdateable()){
                update tobeUpdatedTask;
           }
        }
        urgentTaskJSON = UrgentTaskTabWithSearchTimeFrame(searchValue ,selectedTimeFrame);
        
        return urgentTaskJSON;
    }
    
    
    @RemoteAction
    global static String updateIssuesData(string modifiedDataStr){
        return null;
    }
    
    @RemoteAction
    global static String updateIssuesDataWithSearchTimeFrame(string modifiedDataStr, String selectedTimeFrame, String searchValue){
       
        return null;
    }
    
    global static string UrgentDecisionTab(){
        return null;
    }
    
    @RemoteAction
    global static string UrgentDecisionTabWithSearchTimeFrame(String searchText , String timeSelected){
        if(genralInfo == null ) {
            genralInfo  = new GeneralInformation();
        }
        dateTimeFormat = genralInfo.MapValuesDateTime();
        DateTime todaysDate = DateTime.now();
        
        // These conditions are based on user slected dropdown
        if(timeSelected == '24hours'){
            todaysDate = todaysDate.addDays(1);
        } else if(timeSelected == '48hours'){
            todaysDate = todaysDate.addDays(2);
        } else if(timeSelected == '' || timeSelected == '7days'){
            todaysDate = todaysDate.addDays(7);
        } else if(timeSelected == '1month'){
            todaysDate = todaysDate.addMonths(1);
        } else if(timeSelected == 'All'){
            todaysDate = todaysDate.addYears(10);
        }
        
         if(searchText != ''){
            if(searchText.contains('*')){
                String SearchtextList=searchText.replaceAll('\\*','\\%');
                searchText = SearchtextList;
            }
        }
        List<Social_Input__c> myUrgentDecisionList = new List<Social_Input__c>();
        if(searchText != ''){
            searchText = searchText+'%';
            if(timeSelected == 'All'){
                // This query is used when user selects "All" from the drop down, which will query all the records even when due date is null
                myUrgentDecisionList = [select id, Decision__c, Decision__r.Title__c,Decision__r.Problem_Idea_Advice__c,Decision__r.Decision_Taken__c, Decision__r.OwnerId, Decision__r.Phase__c,Role__c,Decision__r.Nearest_Due_Date__c from Social_Input__c where User__c =: UserInfo.getUserId() and (Accountable__c = true or Backup_for_Accountable__c = true or Responsible__c = true) and Decision__r.phase__c != 'Close' and Decision__r.Title__c like : '%'+searchText+'%' order by Decision__r.Nearest_Due_Date__c DESC NULLS LAST ];
            } else {
                myUrgentDecisionList = [select id, Decision__c, Decision__r.Title__c,Decision__r.Problem_Idea_Advice__c,Decision__r.Decision_Taken__c, Decision__r.OwnerId, Decision__r.Phase__c,Role__c,Decision__r.Nearest_Due_Date__c from Social_Input__c where User__c =: UserInfo.getUserId() and (Accountable__c = true or Backup_for_Accountable__c = true or Responsible__c = true) and Decision__r.Nearest_Due_Date__c != null and Decision__r.Nearest_Due_Date__c <=: todaysDate and Decision__r.phase__c != 'Close' and Decision__r.Title__c like : '%'+searchText+'%' order by Decision__r.Nearest_Due_Date__c DESC  ]; 
            }
        } else {
            if(timeSelected == 'All'){
                // This query is used when user selects "All" from the drop down, which will query all the records even when due date is null
                myUrgentDecisionList = [select id, Decision__c, Decision__r.Title__c,Decision__r.Problem_Idea_Advice__c,Decision__r.Decision_Taken__c, Decision__r.OwnerId, Decision__r.Phase__c,Role__c,Decision__r.Nearest_Due_Date__c from Social_Input__c where User__c =: UserInfo.getUserId() and (Accountable__c = true or Backup_for_Accountable__c = true or Responsible__c = true) and Decision__r.phase__c != 'Close' order by Decision__r.Nearest_Due_Date__c DESC NULLS LAST limit 1000];
            } else {
                myUrgentDecisionList = [select id, Decision__c, Decision__r.Title__c,Decision__r.Problem_Idea_Advice__c,Decision__r.Decision_Taken__c, Decision__r.OwnerId, Decision__r.Phase__c,Role__c,Decision__r.Nearest_Due_Date__c from Social_Input__c where User__c =: UserInfo.getUserId() and (Accountable__c = true or Backup_for_Accountable__c = true or Responsible__c = true) and Decision__r.Nearest_Due_Date__c != null and Decision__r.Nearest_Due_Date__c <=: todaysDate and Decision__r.phase__c != 'Close' order by Decision__r.Nearest_Due_Date__c DESC limit 1000];
            }
        } 
        
        List<urgentDecisionWrapper> urgentDecisionWrapperList = new List<urgentDecisionWrapper>();
        for(Social_Input__c s: myUrgentDecisionList){
            if(s.Decision__c != null && s.Decision__r.Title__c != null){
                urgentDecisionWrapper  u = new urgentDecisionWrapper(); 
                u.Id = s.Id;
                u.decisionId = s.Decision__c;
                System.debug('----s.Decision__c------'+s.Decision__c);
                u.decisionTitle = s.Decision__r.Title__c;
                u.problemStatement = s.Decision__r.Problem_Idea_Advice__c;
                u.decisionTaken = s.Decision__r.Decision_Taken__c != null ? s.Decision__r.Decision_Taken__c : '';
                u.phase = s.Decision__r.Phase__c;
                u.phaseImg = genralInfo.imageUrlMap.get(s.Decision__r.Phase__c);
                u.dueDate =  s.Decision__r.Nearest_Due_Date__c == null ? '' : String.valueOf(s.Decision__r.Nearest_Due_Date__c.format(dateTimeFormat)); //.format(dateTimeFormat);
                u.myRole = s.Role__c.replaceAll(' ',', ');
                u.ownerId = s.Decision__r.OwnerId;
                System.debug('------s.Decision__r.OwnerId-------'+s.Decision__r.OwnerId);
                u.ownerName = genralInfo != null && genralInfo.useNameMap != null && s.Decision__r.OwnerId != null && genralInfo.useNameMap.get(s.Decision__r.OwnerId) != null ? genralInfo.useNameMap.get(s.Decision__r.OwnerId).Name : '';
                System.debug('------u.ownerName-------'+u.ownerName);
                u.fieldTitle1 = 'Problem Statement';
                u.fieldTitle2 = 'Decision';
                // start added on 22-4-2014
                u.dueDateSort =  s.Decision__r.Nearest_Due_Date__c != null ? s.Decision__r.Nearest_Due_Date__c: null; //.format(dateTimeFormat); 
                //end added on 22-4-2014
                urgentDecisionWrapperList.add(u);
            }
        }
        
        // serialize records list
        urgentDecisionJSON = JSON.serialize(urgentDecisionWrapperList);
        
        return urgentDecisionJSON;
    }
    
    global static string pendingApprovals(){
        return null;
    }
    
    @RemoteAction
    global static string pendingApprovalsWithSearchTimeFrame(String searchText , String timeSelected){
        if(genralInfo == null ) {
            genralInfo  = new GeneralInformation();
        }
        
        dateTimeFormat = genralInfo.MapValuesDateTime();
        DateTime todaysDate = DateTime.now();
        
        // These conditions are based on user slected dropdown
        if(timeSelected == '24hours'){
            todaysDate = todaysDate.addDays(1);
        } else if(timeSelected == '48hours'){
            todaysDate = todaysDate.addDays(2);
        } else if(timeSelected == '' || timeSelected == '7days'){
            todaysDate = todaysDate.addDays(7);
        } else if(timeSelected == '1month'){
            todaysDate = todaysDate.addMonths(1);
        } else if(timeSelected == 'All'){
            todaysDate = todaysDate.addYears(10);
        }
        List<String> phaseString = new List<String>{'Decide','Execute','Evaluate'} ;
        Map<Id,Social_Input__c> decisionSocialMap = new Map<Id,Social_Input__c>() ;
        List<Social_Input__c> socialInputWithMyDecision = new List<Social_Input__c>();
        if(searchText != ''){
            if(searchText.contains('*')){
                String SearchtextList=searchText.replaceAll('\\*','\\%');
                searchText = SearchtextList;
            }
        }
        if(searchText != ''){
            searchText = searchText+'%';
            if(timeSelected == 'All'){
                // This query is used when user selects "All" from the drop down, which will query all the records even when due date is null
                socialInputWithMyDecision = [Select id, User__c,Decision__c,Decision__r.Title__c,Role__c,Decision__r.Nearest_Due_Date__c,Decision__r.Status__c,Decision__r.Priority__c, Decision__r.phase__c, Final_Approval_Status__c from Social_Input__c where Decision__r.Phase__c in : phaseString and (Final_Approval_Status__c = 'Approved' or Final_Approval_Status__c = 'Rejected' or Stance_Approval_Status__c = 'Approved' or Stance_Approval_Status__c = 'Rejected') and User__c =: UserInfo.getUserId() and (Accountable__c = true or Backup_for_Accountable__c = true) and Decision__r.Title__c like : '%'+searchText+'%' order by Decision__r.Nearest_Due_Date__c desc NULLS LAST limit 100];
            } else {
                socialInputWithMyDecision = [Select id, User__c,Decision__c,Decision__r.Title__c,Role__c,Decision__r.Nearest_Due_Date__c,Decision__r.Status__c,Decision__r.Priority__c, Decision__r.phase__c, Final_Approval_Status__c from Social_Input__c where Decision__r.Phase__c in : phaseString and (Final_Approval_Status__c = 'Approved' or Final_Approval_Status__c = 'Rejected' or Stance_Approval_Status__c = 'Approved' or Stance_Approval_Status__c = 'Rejected') and User__c =: UserInfo.getUserId() and (Accountable__c = true or Backup_for_Accountable__c = true) and Decision__r.Nearest_Due_Date__c != null and Decision__r.Nearest_Due_Date__c <=: todaysDate and Decision__r.Title__c like : '%'+searchText+'%' order by Decision__r.Nearest_Due_Date__c desc limit 100];   
            }
        } else {
            if(timeSelected == 'All'){
                // This query is used when user selects "All" from the drop down, which will query all the records even when due date is null
                socialInputWithMyDecision = [Select id, User__c,Decision__c,Decision__r.Title__c,Role__c,Decision__r.Nearest_Due_Date__c,Decision__r.Status__c,Decision__r.Priority__c, Decision__r.phase__c, Final_Approval_Status__c from Social_Input__c where Decision__r.Phase__c in : phaseString and (Final_Approval_Status__c = 'Approved' or Final_Approval_Status__c = 'Rejected' or Stance_Approval_Status__c = 'Approved' or Stance_Approval_Status__c = 'Rejected') and User__c =: UserInfo.getUserId() and (Accountable__c = true or Backup_for_Accountable__c = true) order by Decision__r.Nearest_Due_Date__c desc NULLS LAST limit 100];
            } else {
                socialInputWithMyDecision = [Select id, User__c,Decision__c,Decision__r.Title__c,Role__c,Decision__r.Nearest_Due_Date__c,Decision__r.Status__c,Decision__r.Priority__c, Decision__r.phase__c, Final_Approval_Status__c from Social_Input__c where Decision__r.Phase__c in : phaseString and (Final_Approval_Status__c = 'Approved' or Final_Approval_Status__c = 'Rejected' or Stance_Approval_Status__c = 'Approved' or Stance_Approval_Status__c = 'Rejected') and User__c =: UserInfo.getUserId() and (Accountable__c = true or Backup_for_Accountable__c = true) and Decision__r.Nearest_Due_Date__c != null and Decision__r.Nearest_Due_Date__c <=: todaysDate order by Decision__r.Nearest_Due_Date__c desc limit 100];
            }
        }   
        Set<Id> socialDecisions = new set<Id>();
        
        for(Social_Input__c s : socialInputWithMyDecision){
            socialDecisions.add(s.Decision__c); 
            decisionSocialMap.put(s.Decision__c,s);
        }
        map<Id,List<String>> pendingApprovalUserMap = new map<Id,List<String>>();
        List<Social_Input__c> socialPendingApprovals = [Select id, User__c,Decision__c from Social_Input__c where Decision__c IN : socialDecisions and (Final_Approval_Status__c = 'Pending Approval' or Stance_Approval_Status__c = 'Pending Approval') and User__c !=: UserInfo.getUserId()];
        for(Social_Input__c s : socialPendingApprovals){
            List<String> pendingApprovalUserList = pendingApprovalUserMap.get(s.Decision__c);
            if(pendingApprovalUserList == null) {
                pendingApprovalUserList = new List<String>();
                pendingApprovalUserMap.put(s.Decision__c, pendingApprovalUserList);
            }
            pendingApprovalUserList.add(string.ValueOf(s.User__c));
        }
        System.debug('-------Pending list-----'+pendingApprovalUserMap);
        pendingApprovalList = new List<pendingApprovalWrapper>();
        for(Id s : socialDecisions){
            if(pendingApprovalUserMap.get(s) != null){
                pendingApprovalWrapper wr = new pendingApprovalWrapper();
                wr.Id = string.valueOf(s);
                wr.title = decisionSocialMap.get(s).Decision__r.Title__c;
                wr.pendingApprovers = listToStringConvert(pendingApprovalUserMap.get(s));
                wr.myRole = decisionSocialMap.get(s).Role__c.replaceAll(' ',', ');
                wr.DueDate = decisionSocialMap != null && decisionSocialMap.get(s) != null && decisionSocialMap.get(s).Decision__r.Nearest_Due_Date__c != null ? string.valueOf(decisionSocialMap.get(s).Decision__r.Nearest_Due_Date__c.format(dateTimeFormat)) : '';
                wr.status = decisionSocialMap.get(s).Decision__r.Status__c;
                wr.priority = decisionSocialMap.get(s).Decision__r.priority__c;
                wr.phase = decisionSocialMap.get(s).Decision__r.phase__c;  
                wr.phaseImg = genralInfo.imageUrlMap.get(wr.phase); 
                
                //start added on 22-04-2014
                wr.dueDateSort = decisionSocialMap != null && decisionSocialMap.get(s) != null && decisionSocialMap.get(s).Decision__r.Nearest_Due_Date__c != null ?decisionSocialMap.get(s).Decision__r.Nearest_Due_Date__c: null;
                // end added on 22-04-2014
                pendingApprovalList.add(wr);    
            }
        }
        pendingApprovalJSON = JSON.serialize(pendingApprovalList);
        return pendingApprovalJSON;
    }
    
    global static String urgentIssuesTab(){
        return null;
    } 
    
    @RemoteAction
    global static String urgentIssuesTabWithSearchTimeFrame(String searchText , String timeSelected){
        
                return '';
    } 
    
    // my tasks
    @RemoteAction
    global static string myTasks(){
        //GeneralInformation genInfo = new GeneralInformation();
       /* 
        if(genralInfo == null ) {
            genralInfo  = new GeneralInformation();
        }
        
        // assign user locale date format as string 
        dateFormatStatic = genralInfo.MapValuesDateFormate();
        System.debug('----dateFormatStatic--------'+dateFormatStatic);
        
        
        dateTimeFormat = genralInfo.MapValuesDateTime();
        List<Task> myTask = [select Id,subject, ActivityDate, Status, Priority, CreatedBy.Name,lastModifieddate,whatId from Task where Owner.id =: UserInfo.getUserId() and IsClosed = false order by    id];
        
        map<Id,String> DecisionPlanNameMap = new map<Id,String>();
        List<Id> taskWhatIdList = new List<Id>();
        for(Task t:myTask){
            taskWhatIdList.add(t.WhatId);   
        }
        
        // Dynamic picklist tasks status & language issue fixes
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
        
        for(Decision__c d:[select id,Title__c from Decision__c where Id in:taskWhatIdList]){
            String nameValue =  DecisionPlanNameMap.get(d.Id);
            if(nameValue == null){
                DecisionPlanNameMap.put(d.Id,d.Title__c);   
            } 
        }
        for(Plan__c d:[select id,Name from Plan__c where Id in:taskWhatIdList]){
            String nameValue =  DecisionPlanNameMap.get(d.Id);
            if(nameValue == null){
                DecisionPlanNameMap.put(d.Id,d.Name);   
            } 
        }
        
        myTasksWrapperList = new List<myTasksWrapper>();
        for(Task d:myTask){
            if(d.Subject != null){
                myTasksWrapper myD = new myTasksWrapper();
                myD.Id = d.Id;
                myD.Subject = string.escapeSingleQuotes(d.Subject);
                myD.DueDate = d.ActivityDate != null ?  String.valueOf(d.ActivityDate)  : '';
                myD.status = taskstatus.get(d.status) == null ?d.status: taskstatus.get(d.status);
                myD.StatusImg = genralInfo.imageUrlMap.get(d.Status);
                myD.Priority = taskpriority.get(d.Priority) == null ? d.Priority: taskpriority.get(d.Priority); 
                myD.CreatedBy = d.CreatedBy.Name;
                myD.relatedTo = DecisionPlanNameMap.get(d.WhatId) != null ? DecisionPlanNameMap.get(d.WhatId) : '' ;
                myD.relatedToId = d.WhatId;
                myD.dateFormatToBeSet = genralInfo.MapValuesDateFormate();
                myTasksWrapperList.add(myD);
            }
        }
        
        myTasksJson = JSON.serialize(myTasksWrapperList);
        return myTasksJson;*/
        return null;
    }
    
    
    // updating my tasks
    @RemoteAction
    global static string updateMyTask(string recodsId,string  recodsSubject,string  recodsPriority,string  recodsStatus, string recodsDueDate){
        
        // Dynamic picklist tasks status & language issue fixes
       /* Schema.DescribeFieldResult  statusResult = Task.Status.getDescribe();
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
        
        Task myTask = [select id,status,priority,subject,ActivityDate from Task where id=:recodsId];
        myTask.subject = recodsSubject;
        myTask.status = taskstatus.get(recodsStatus) == null ?recodsStatus : taskstatus.get(recodsStatus);
        myTask.Priority= taskpriority.get(recodsPriority) == null ? recodsPriority : taskpriority.get(recodsPriority);
        Date dueDate;
        System.debug('------------------due date-------->'+recodsDueDate);
        if(recodsDueDate != 'null' && recodsDueDate != ''&& recodsDueDate != null){
            List<String> dueDateSplit = new List<String>();
            dueDateSplit = recodsDueDate.split(',');
            Integer monthOfDate = Integer.valueOf(dueDateSplit[0]);
            Integer dateOfDate = Integer.valueOf(dueDateSplit[1]);
            Integer yearOfDate = Integer.valueOf(dueDateSplit[2]);
            dueDate =  date.newinstance(yearOfDate, monthOfDate, dateOfDate);
            myTask.ActivityDate = dueDate;
        }
        if((Schema.sObjectType.Task.fields.Subject.isUpdateable()) && (Schema.sObjectType.Task.fields.Status.isUpdateable()) && (Schema.sObjectType.Task.fields.ActivityDate.isUpdateable()) && (Schema.sObjectType.Task.fields.Priority.isUpdateable())){
            update myTask;
        }
        if(recodsStatus != 'Completed'){
            
           // return null;    
        }
        myTasksJson = myTasks();
        return myTasksJson;*/
        return null;
    }
    
    @RemoteAction
    global static string updateMyCollegueTask(string recodsId,string  recodsSubject,string  recodsPriority,string  recodsStatus, string recodsDueDate){
        
        /*Task myTask = [select id,status,priority,subject,ActivityDate from Task where id=:recodsId];
        myTask.subject = recodsSubject;
        myTask.status = recodsStatus ;
        myTask.priority = recodsPriority;
        Date dueDate;
        System.debug('------------------due date-------->'+recodsDueDate);
        if(recodsDueDate != 'null' && recodsDueDate != ''&& recodsDueDate != null){
            List<String> dueDateSplit = new List<String>();
            dueDateSplit = recodsDueDate.split(',');
            Integer monthOfDate = Integer.valueOf(dueDateSplit[0]);
            Integer dateOfDate = Integer.valueOf(dueDateSplit[1]);
            Integer yearOfDate = Integer.valueOf(dueDateSplit[2]);
            dueDate =  date.newinstance(yearOfDate, monthOfDate, dateOfDate);
            myTask.ActivityDate = dueDate;
        }
        if((Schema.sObjectType.Task.fields.Subject.isCreateable()) && (Schema.sObjectType.Task.fields.Status.isCreateable()) && (Schema.sObjectType.Task.fields.ActivityDate.isCreateable()) && (Schema.sObjectType.Task.fields.Priority.isCreateable())){
            update myTask;
        }
        myTasksJson = assignedTaskData();
        return myTasksJson;*/
        
        return null;
    }
    
    //Method to select decisions filtered by role
     @RemoteAction
    global static String myDecisions(String myRole){
         
        //Use different queries to get decision data base on role
        List<Social_Input__c> mySocialInputList = new List<Social_Input__c>();
        if( myRole == 'Accountable'){          
         mySocialInputList  = [select Id, Decision__r.id, Decision__r.Name,Decision__r.Title__c, Decision__r.phase__c, Decision__r.lastModifieddate, Decision__r.due_Date__c from social_input__c  where User__c =: UserInfo.getUserId() and Accountable__c =: true and  Decision__r.phase__c != 'Close' and Decision__r.Title__c != null order by lastModifieddate desc];
        }
        if( myRole == 'Responsible' ){          
         mySocialInputList  = [select Id, Decision__r.id,  Decision__r.Name,Decision__r.Title__c, Decision__r.phase__c, Decision__r.lastModifieddate, Decision__r.due_Date__c from social_input__c where User__c =: UserInfo.getUserId() and Responsible__c =: true and  Decision__r.phase__c != 'Close' and Decision__r.Title__c != null order by lastModifieddate desc];
        }
        if( myRole == 'Consulted' ){            
         mySocialInputList  = [select Id, Decision__r.id,  Decision__r.Name,Decision__r.Title__c, Decision__r.phase__c, Decision__r.lastModifieddate, Decision__r.due_Date__c from social_input__c where User__c =: UserInfo.getUserId() and Consulted__c =: true and  Decision__r.phase__c != 'Close' and Decision__r.Title__c != null order by lastModifieddate desc];
        }
        if( myRole == 'Informed' ){         
         
         
         //Query all group where I am a part and then get all socialinput to consider informed group
         Map<id,Group> groupMap = new Map<id,Group>([ Select id  from Group where id in ( Select GroupId  from Groupmember where  UserOrGroupId =:UserInfo.getUserId() )]);
         
         mySocialInputList  = [select Id, Decision__r.id,  Decision__r.Name,Decision__r.Title__c, Decision__r.phase__c, Decision__r.lastModifieddate, Decision__r.due_Date__c from social_input__c where User__c =: UserInfo.getUserId() and Informed__c =: true and  Decision__r.phase__c != 'Close' and Decision__r.Title__c != null order by lastModifieddate desc];
        
         mySocialInputList.addAll([select Id, Decision__r.id,  Decision__r.Name,Decision__r.Title__c, Decision__r.phase__c, Decision__r.lastModifieddate, Decision__r.due_Date__c from social_input__c where GroupId__c in : groupMap.keyset()   and Informed__c =: true and  Decision__r.phase__c != 'Close' and Decision__r.Title__c != null order by lastModifieddate desc]);

        }
        if( myRole == 'Backup' ){           
         mySocialInputList  = [select Id, Decision__r.id,  Decision__r.Name,Decision__r.Title__c, Decision__r.phase__c, Decision__r.lastModifieddate, Decision__r.due_Date__c from social_input__c where User__c =: UserInfo.getUserId() and Backup_for_Accountable__c =: true and  Decision__r.phase__c != 'Close' and Decision__r.Title__c != null order by lastModifieddate desc];
        }
        if( myRole == 'Veto' ){             
         mySocialInputList  = [select Id, Decision__r.id,  Decision__r.Name,Decision__r.Title__c, Decision__r.phase__c, Decision__r.lastModifieddate, Decision__r.due_Date__c from social_input__c where User__c =: UserInfo.getUserId() and Veto_Rights__c =: true and  Decision__r.phase__c != 'Close' and Decision__r.Title__c != null order by lastModifieddate desc];
        }
        if( myRole == 'All' ){   
            
         //Query all group where I am a part and then get all socialinput to consider informed group
         Map<id,Group> groupMap = new Map<id,Group>([ Select id  from Group where id in ( Select GroupId  from Groupmember where  UserOrGroupId =:UserInfo.getUserId() )]);
                
         mySocialInputList  = [select Id, Decision__r.id,  Decision__r.Name,Decision__r.Title__c, Decision__r.phase__c, Decision__r.lastModifieddate, Decision__r.due_Date__c from social_input__c where User__c =: UserInfo.getUserId() and Decision__r.phase__c != 'Close' and Decision__r.Title__c != null order by lastModifieddate desc];
            
         mySocialInputList.addAll([select Id, Decision__r.id,  Decision__r.Name,Decision__r.Title__c, Decision__r.phase__c, Decision__r.lastModifieddate, Decision__r.due_Date__c from social_input__c where GroupId__c in : groupMap.keyset()   and Informed__c =: true and  Decision__r.phase__c != 'Close' and Decision__r.Title__c != null order by lastModifieddate desc]);
        
        } 
        genralInfo = new GeneralInformation();       
        String dateFormat      = genralInfo.MapValuesDateFormate(); 
        dateTimeFormat  = genralInfo.MapValuesDateTime();   
        myDecisionsWrapperList = new List<myDecisionsWrapper>(); 
        //Iterate all social input and get relevent data.  
        for(Social_Input__c s:mySocialInputList){
            myDecisionsWrapper myD = new myDecisionsWrapper();
            myD.Id = s.Decision__r.id ; 
            myD.Name = s.Decision__r.Title__c != null ? s.Decision__r.Title__c : '';
            myD.phaseImg = genralInfo.imageUrlMap.get(s.Decision__r.Phase__c);
            myD.phase = s.Decision__r.Phase__c;
            myD.lastModifiedDate = String.valueOf(s.Decision__r.lastModifiedDate.format(dateTimeFormat));
            myD.duedate =  s.Decision__r.due_Date__c == null ? ' ' : s.Decision__r.due_Date__c.format(); // string.valueOf(d.due_Date__c); //
            
            // start --added to sort the date field in the home page
            myD.lastModifiedDateSort = s.Decision__r.lastModifiedDate;
            myD.dueDateSort = s.Decision__r.due_Date__c;
            // end -- added to sort the date field in the home page
           
            myDecisionsWrapperList.add(myD);
        }   
        
        //myDecisionsJson = JSON.serialize(myDecisionsWrapperList);
        return ( JSON.serialize(myDecisionsWrapperList) );    
         
    }         
       
        
        
     // decision Approva /reject
    @RemoteAction
    global static String approvedReject1(String decisionId, String processInstanceitemId, String action, String comment,String typeOfApproval ) {
        return null;
    } 
    
    @RemoteAction
    global static String approvedRejectWithSearchTimeFrame(String decisionId, String processInstanceitemId, String action, String comment,String typeOfApproval, String timeSelected , String searchText ) {
            Social_Input__c logedInsocialInput = [Select  s.Role__c , s.Role_Acceptance_Status__c , s.Accountable__c, s.Backup_for_Accountable__c, s.Responsible__c,s.Consulted__c,s.Informed__c,s.Veto_Rights__c,s.Stance_Approval_Status__c,s.Final_Approval_Status__c   From Social_Input__c s where s.Decision__c =: decisionId and s.User__c =: userInfo.getUserId() ];
            Decision__c currentDecision  = [Select ownerid,Nearest_Due_Date__c from Decision__c  where id =: decisionid  ];
            Approval.ProcessWorkItemRequest processWorkItemRequest = new Approval.ProcessWorkItemRequest();
            ProcessInstanceWorkitem processInstanceWorkitem = [Select p.ProcessInstance.Status, p.ProcessInstance.TargetObjectId, p.ProcessInstanceId, p.Id, p.CreatedDate, p.CreatedBy.Name, p.CreatedById, p.Actor.Name, p.ActorId From ProcessInstanceWorkitem p where  p.id=: processInstanceitemId];    
            System.debug('--------------------------process id'+processInstanceWorkitem.id);
            //processWorkItemRequest = processInstanceWorkitem;        
            processWorkItemRequest.setWorkitemId(processInstanceWorkitem.id);
            processWorkItemRequest.setComments(comment);
            processWorkItemRequest.setAction(action); 
            System.debug('--------------------------process id'+processWorkItemRequest);
            Approval.ProcessResult pr = Approval.process(processWorkItemRequest);
            Social_Input__c socialInput = [Select s.Veto_Rights__c, s.User__c,s.Stance_Approval_Status__c, s.SystemModstamp, s.SYS_Tab_View_Activites__c, s.SYS_Tab_View_History__c, s.SYS_Tab_View_Tasks__c, s.SYS_Tab_View_Social_Input__c, s.SYS_Tab_View_Relations__c, s.SYS_Tab_View_Quality__c, s.SYS_Tab_View_Attachments__c, s.SYS_Tab_View_Approvals__c, s.Role_Acceptance_Status__c, s.Role_Acceptance_Required__c, s.Result__c, s.Responsible__c, s.Rating__c, s.Outcome__c, s.Name, s.Mood__c, s.Like__c, s.LastModifiedDate, s.LastModifiedById, s.Informed__c, s.Id, s.Final_Approval_Status__c, s.Effort__c, s.Dislike__c, s.Decision__c, s.CreatedDate, s.CreatedById, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c, s.Accountable__c From Social_Input__c s where s.Id =: processInstanceWorkitem.ProcessInstance.TargetObjectId ];
            //If the current user approves stance or final decison a chatter post is created.
            String roleString  =  '';
            String proposeChatterPostId = '';
            // Checks for logged in users role status
            if( logedInsocialInput.Role_Acceptance_Status__c == 'Approved/Accepted'  ){
                Decision__c decisionQryUpdatedFeedID  =[select id,FeedItem_Id_Propose__c from Decision__c where id =:decisionId Limit 1];
                proposeChatterPostId =decisionQryUpdatedFeedID.FeedItem_Id_Propose__c;
                //if no propose chatter post exist then create new one and make comment.
                if( proposeChatterPostId == ''){
                
                    /*FeedItem post = new FeedItem();
                    post.ParentId =  decisionId;  
                    post.Body =      'The decision has been proposed'  ;
                    post.type = 'TextPost';                   
                    post.Title = decisionid;  
                    post.createdbyid = currentDecision.ownerid;
                    if( FLS.FeedItemCreatable()) 
                    insert post; 
                    proposeChatterPostId  =  post.id;*/
                    
                    
                    Decision__c decisionQry  =[select id,Problem_Idea_Advice__c,Decision_Taken__c,ownerid from Decision__c where id =:currentDecision.id Limit 1];
                    Id userId=currentDecision.ownerid;
                    User usr = [Select id,name from User where id=:decisionQry.ownerid Limit 1];
                    //String postText='The following decision has been proposed:'+'\n'+'\n'+'"'+decisionQry.Decision_Taken__c+'"'+'\n'+'\n'+usr.name+' '+'needs your personal stance.';
                    String postText='Here is the proposed Decision, read it and give your Stance.'+'\n'+'\n'+'Decision:'+'\n'+'"'+decisionQry.Decision_Taken__c+'"'+'\n'+'\n'+'(hint: it’s done in the command center)';
                    DecisionView.mentionTextPostPropose( usr.id, postText, currentDecision.id);
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
                        List<Decision__Feed> feedList = [ Select id,title from Decision__Feed where parentId=:decisionId order by createddate desc ];
                        for( Decision__Feed feed:feedList)
                        {
                            if( feed.title ==  String.valueOf(decisionid ) )
                            {
                                proposeChatterPostId = feed.id;
                                break;
                            }
                        } 
                         // Creates a feed comment
                        FeedComment chatterComment = new FeedComment();
                        chatterComment.feedItemId =  proposeChatterPostId;  
                        comment = comment.length() > 1000 ? comment.substring(0,890) + '...':comment;
                        // Display chatter comment to show loggedin use has Rejected the decision with  his role and comments provided in stance
                        chatterComment.CommentBody =    'Has rejected the Decision'   + ' as '+  roleString +   (    (  comment != null &&( comment.trim().length() != 0 ) ) ?'\nwith Comment:\n \"' +comment +'\".' : '.' );
                        if( FLS.FeedItemCreatable())    
                        insert chatterComment;    
             }
             if(logedInsocialInput.Final_Approval_Status__c == 'Pending Approval'){
               map<Id, List<Timing__c>> decisionIdtimingListMap = new map<Id, List<Timing__c>>();
            
                for(Timing__c timing : [Select t.Start_Date_Time__c, t.Stage__c, t.Related_To_ID__c, t.End_Date_Time__c, t.Elapsed_Time__c, t.Difference__c, t.Actual_Start_Date__c, t.Actual_End_Date__c From Timing__c t where t.Related_To_ID__c =: decisionId]) {
                    
                    List<Timing__c> timingList = decisionIdtimingListMap.get(timing.Related_To_ID__c);
                    if(timingList == null ) {
                        timingList = new List<Timing__c>();
                        decisionIdtimingListMap.put(timing.Related_To_ID__c, timingList);
                    }
                    timingList.add(timing);
                }
                
                map<String, Timing__c> phasestimingMap = new map<String, Timing__c>();
                
                for(Timing__c timing : decisionIdtimingListMap.get(decisionId)) {
                    phasestimingMap.put(timing.Stage__c, timing);
                }
            
                DateTime toBeUpdatedNearestDueDate;
                
                //calculate nearest due date
                Timing__c decide = phasestimingMap.get('Decide');
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
                currentDecision.Nearest_Due_Date__c = toBeUpdatedNearestDueDate;
                
                if(FLS.decisionUpdateable()) {
                    update currentDecision;
                }
             }
             
            if(typeOfApproval == 'items'){
                approvalJSON = approvalTab();
                return approvalJSON;
            } else { 
                urgentApprovalJSON = UrgentApprovalTabWithSearchTimeFrame(searchText , timeSelected);
                return urgentApprovalJSON;  
            }
    } 
    
    public static String listToStringConvert(List<String> grpMemberList) {
        String UserName = '';
        Integer i = 0;
        for(String str : grpMemberList) {
            if(UserName == '') {
                UserName = genralInfo.useNameMap.get(str).Name;
            }
            else {
                    UserName = UserName + ',' + genralInfo.useNameMap.get(str).Name;
                    i++;
            }
        }
        return  UserName;       
    }   
    
    // decision Approva /reject for packaging purpose only.
    @RemoteAction
    global static String approvedReject(String decisionId, String processInstanceitemId, String action, String comment) {
        return null;   
    }
    
    @RemoteAction
    global static string DecisionHighlist(){
        // create decision list of all the decisions
        if(genralInfo == null ) {
            genralInfo  = new GeneralInformation();
        }
        dateTimeFormat = genralInfo.MapValuesDateTime();
        
        List<Decision__c> decisionList = [select id, Name,Title__c, phase__c, lastModifiedDate,Due_Date__c,Owner.Id,Owner.Name from Decision__c where phase__c != 'Draft' and phase__c != 'Close' and Title__c != null order by lastModifieddate desc limit 500];
        Set<Id> decisionId = new set<Id>();
        for(Decision__c d:decisionList){
            decisionId.add(d.id);
        }
        
        // social values for all the decisions in the decision highlight 
        map<Id,Social__c> socialDecisionHighlight = new map<Id,Social__c>();
        
        List<Social__c> smsList  = [select id, Total_Issues__c,Total_Likes__c, Total_DisLikes__c, Avg_Mood__c, Avg_Rating__c,Related_To_ID__c,lastModifieddate From Social__c where Related_To_ID__c In : decisionId  order by lastModifieddate desc];
        for(Social__c s:  smsList) {
            socialDecisionHighlight.put(s.Related_To_ID__c, s);
        }
        
        // generate decision hightlight json string
        List<decisionHighlight> decisionHighlightList = new List<decisionHighlight>();
        for(Decision__c d:decisionList){
           decisionHighlight dw = new decisionHighlight();
           dw.sms = new Social__c();
           dw.Id = d.Id;
           dw.title = d.Title__c != null ? string.escapeSingleQuotes(d.Title__c) : ''; 
           dw.phase = d.phase__c;
           dw.phaseImg = genralInfo.imageUrlMap.get(d.Phase__c);
           dw.lastModifiedDate = string.valueOf(d.lastModifiedDate.format(dateTimeFormat));
           dw.DueDate = d.due_Date__c == null ? ' ' :  string.valueOf(d.due_Date__c.format(dateTimeFormat));
           dw.owner = d.Owner.Name;
           dw.sms = socialDecisionHighlight.get(d.Id);
           if(dw.sms.Total_Likes__c != null && dw.sms.Total_DisLikes__c != null){
               dw.likeValue = dw.sms.Total_Likes__c - dw.sms.Total_DisLikes__c;
               if(dw.likeValue > 0){
                   dw.likeImg = genralInfo.imageUrlMap.get('likeUp');
               }else if(dw.likeValue < 0){
                   dw.likeImg = genralInfo.imageUrlMap.get('likeDown');
               }else{
                   dw.likeImg = genralInfo.imageUrlMap.get('likeNeutral');
               }
           }else{
               dw.likeValue = 0.0;
               dw.likeImg = genralInfo.imageUrlMap.get('likeNeutral');    
           }
           dw.mood = String.valueOf(dw.sms.Avg_Mood__c) != null ? String.valueOf(math.round(dw.sms.Avg_Mood__c)) : '';
           dw.moodClass = 'moodClass' + dw.mood;  
            String avgRatingValue ='';
            if(dw.sms.Avg_Rating__c ==  1.0) {  
                avgRatingValue = 'star11';
            }
                
            if(dw.sms.Avg_Rating__c > 1.0 && dw.sms.Avg_Rating__c < 2.0 ) {
                avgRatingValue = 'star1.51';
            }
                
            if(dw.sms.Avg_Rating__c ==  2.0) {
                avgRatingValue = 'star21';
            }
                
            if(dw.sms.Avg_Rating__c > 2.0 && dw.sms.Avg_Rating__c < 3.0 ) {
                avgRatingValue = 'star2.51';
            }
                
            if(dw.sms.Avg_Rating__c ==  3.0) {
                avgRatingValue = 'star31';
            }
                
            if(dw.sms.Avg_Rating__c > 3.0 && dw.sms.Avg_Rating__c < 4.0 ) {
                avgRatingValue = 'star3.51';
            }
                
            if(dw.sms.Avg_Rating__c ==  4.0) {
                avgRatingValue = 'star41';
            }
            
            if(dw.sms.Avg_Rating__c > 4.0 && dw.sms.Avg_Rating__c < 5.0 ) {
                avgRatingValue = 'star4.51';
            }
            
            if(dw.sms.Avg_Rating__c ==  5.0) {
                avgRatingValue = 'star51';
            }
            
            if(dw.sms.Avg_Rating__c == 0.0) {
                avgRatingValue = 'null';
            }
            dw.starImage = genralInfo.imageUrlMap.get(avgRatingValue);
            dw.starValue = dw.sms.Avg_Rating__c;  
            //dw.issueValue = dw.sms.Total_Issues__c;
            //dw.issueImg = dw.issueValue  > 0 ? genralInfo.imageUrlMap.get('planFlagRed') : genralInfo.imageUrlMap.get('');  
            
            // start added on 21-04-2014
            dw.lastModifiedDateSort = d.lastModifiedDate;
            dw.DueDateSort = d.due_Date__c != null ? d.due_Date__c:null;
            // end added on 21-04-2014
            decisionHighlightList.add(dw);
        } 
        decisionHighlightsJson = JSON.serialize(decisionHighlightList);
        return decisionHighlightsJson;
    }    
    
    @RemoteAction 
    global static HomeChartsWrapper DefineHomeCharts(){
        String decisionProgress ;
        String decisionUserCreatedBy; 
        String lastWeekDecisionSize;
        String twoWeekAgoDecisionSize ;
        String threeWeekAgoDecisionSize; 
        String fourWeekAgoDecisionSize;
        
        date myDate = Date.today();
        date weekStart =  myDate.toStartofWeek();
        Date lastWeekDate = weekStart.addDays(-7);
        Time t = Time.newInstance(0, 0, 0, 0);
        Datetime weekStartDateTime = Datetime.newInstance(lastWeekDate, t);
        
        List<Decision__c> lastWeekDecision = [SELECT Id FROM Decision__c  WHERE CreatedDate = LAST_WEEK];
        lastWeekDecisionSize = String.valueOf(lastWeekDecision.size());
        System.debug('----------lastWeekDecisionSize--------->'+lastWeekDecisionSize);
        Date twoWeekAgoDate = weekStart.addDays(-14);
        Datetime twoWeekAgoDateStartDateTime = Datetime.newInstance(twoWeekAgoDate, t);
        List<Decision__c> twoWeekAgoDecision = [select id from Decision__c WHERE CreatedDate < : weekStartDateTime AND  CreatedDate > : twoWeekAgoDateStartDateTime];
        twoWeekAgoDecisionSize = String.valueOf(twoWeekAgoDecision.size());
        System.debug('----------twoWeekAgoDecisionSize--------->'+twoWeekAgoDecisionSize);
        Date threeWeekAgoDate = weekStart.addDays(-21);
        Datetime threeWeekAgoDateStartDateTime = Datetime.newInstance(threeWeekAgoDate, t);
        List<Decision__c> threeWeekAgoDecision = [select id from Decision__c WHERE CreatedDate < : twoWeekAgoDateStartDateTime AND  CreatedDate > : threeWeekAgoDateStartDateTime];
        threeWeekAgoDecisionSize = String.valueOf(threeWeekAgoDecision.size());
        System.debug('----------threeWeekAgoDecisionSize--------->'+threeWeekAgoDecisionSize);
        Date fourWeekAgoDate = weekStart.addDays(-28);
        Datetime fourWeekAgoDateStartDateTime = Datetime.newInstance(fourWeekAgoDate, t);
        List<Decision__c> fourWeekAgoDecision = [select id from Decision__c WHERE CreatedDate < : threeWeekAgoDateStartDateTime AND  CreatedDate > : fourWeekAgoDateStartDateTime];
        fourWeekAgoDecisionSize = String.valueOf(fourWeekAgoDecision.size());
        System.debug('----------fourWeekAgoDecisionSize--------->'+fourWeekAgoDecisionSize);
        List<AggregateResult> argDecisionProgress = [select Phase__c, COUNT(id) c from Decision__c where Phase__c <>'Draft' OR  Phase__c <>'Close'  GROUP BY Phase__c];
        
        List<kendoObject> kendoObjectList = new List<kendoObject>();
       
        for(AggregateResult a: argDecisionProgress) {
            
            kendoObject kObj = new kendoObject();
            kObj.xAxis = (String)a.get('Phase__c');
            kObj.yAxis = (Integer)a.get('c');
            kendoObjectList.add(kObj);
        }
        
        decisionProgress = JSON.serialize(kendoObjectList);
       
        List<User> usrList = [Select u.LastName, u.Id, u.FirstName From User u where u.IsActive = true ];
        map<Id,String> userNameMap = new map<Id,String>(); 
        for(User u: usrList ) {
            String uName;
            if(u.FirstName != null && u.FirstName != '') {
                uName = (u.FirstName.substring(0,1)).toUpperCase() +'.'+u.LastName; 
            }
            else {
                uName = u.LastName;
            }
            userNameMap.put(u.Id,uName);
        }
        
        List<AggregateResult> argrDecisionUserCreatedBy  = [select OwnerID, COUNT(id) c from Decision__c   GROUP BY OwnerID limit 10];
        System.debug(argrDecisionUserCreatedBy);
        
        kendoObjectList.clear();
        for(AggregateResult a: argrDecisionUserCreatedBy) {
            if(userNameMap.get((ID)a.get('OwnerID')) != null){
                kendoObject kObj = new kendoObject();
                kObj.xAxis = userNameMap.get((ID)a.get('OwnerID')) ;
                kObj.yAxis = (Integer)a.get('c');
                kendoObjectList.add(kObj);
            }
        }     
        
        decisionUserCreatedBy = JSON.serialize(kendoObjectList);
        
        HomeChartsWrapper wr = new HomeChartsWrapper();
        wr.lastWeekDecisionSizeStr = lastWeekDecisionSize ;
        wr.twoWeekAgoDecisionSizeStr = twoWeekAgoDecisionSize; 
        wr.threeWeekAgoDecisionSizeStr = threeWeekAgoDecisionSize;
        wr.fourWeekAgoDecisionSize = fourWeekAgoDecisionSize;
        wr.decisionProgressStr = decisionProgress;
        wr.decisionCreatedStr = decisionUserCreatedBy;
        return wr;
    }
    
    public static Map<String,List<importantWrapper>> importantWrapperMap{get;set;}
    public static Map<String,Integer> importantWrapperMapCount{get;set;}
    
    @RemoteAction 
    public static   void  importantView(){
        importantWrapperMap  = new Map<String,List<importantWrapper>>();
        importantWrapperMapCount =  new Map<String,Integer>();
        importantWrapperMap.put('overdue',new List<importantWrapper>());
        importantWrapperMap.put('today',new List<importantWrapper>());
        importantWrapperMap.put('1week',new List<importantWrapper>());
        importantWrapperMap.put('2week',new List<importantWrapper>());
        importantWrapperMap.put('1month',new List<importantWrapper>());
        
        List<Social_Input__c>    myUrgentDecisionList     = [select id, Decision__c, Decision__r.Title__c,Decision__r.Problem_Idea_Advice__c,Decision__r.Decision_Taken__c, Decision__r.OwnerId, Decision__r.Phase__c,Role__c,Decision__r.Nearest_Due_Date__c from Social_Input__c where User__c =: UserInfo.getUserId() and (Accountable__c = true or Backup_for_Accountable__c = true) and Decision__r.phase__c != 'Close'   order by Decision__r.Nearest_Due_Date__c DESC NULLS LAST limit 100];
        List<Social_Input__c>    myUrgentPlanList         = [select id, Plan__c, Plan__r.Description__c,Plan__r.Start_Time__c,Plan__r.End_Time__c from Social_Input__c where User__c =: UserInfo.getUserId() and (Accountable__c = true or Backup_for_Accountable__c = true) and Plan__c != null and Plan__r.End_Time__c < : System.now() order by Plan__r.End_Time__c DESC NULLS LAST limit 100];
        List<Task>               urgentTaskList           = [Select t.Id, t.ActivityDate , t.WhatId, t.Subject, t.Status, t.Priority,t.ownerId,t.Owner.Name , t.CreatedById,t.CreatedBy.Name From Task t where t.Owner.id =: UserInfo.getUserId()   and t.IsClosed = false  order by t.ActivityDate DESC NULLS LAST];
        Map<id,Social_Input__c>  socialInputMap           = new Map<id,Social_Input__c>([Select s.Role__c,s.Decision__r.Due_Date__c,s.Decision__r.Title__c,s.Final_Approval_Status__c , s.Decision__c , s.User__r.Name, s.Stance_Approval_Status__c, s.User__c, s.Role_Acceptance_Status__c  From Social_Input__c s where  s.User__c =: userInfo.getUserId() and s.Decision__c != null order by s.Decision__r.Due_Date__c,s.Decision__r.LastModifiedDate DESC NULLS LAST]);
        List<ProcessInstanceWorkitem> ProcessInstanceList = [Select  p.ProcessInstance.Status, p.ProcessInstance.TargetObjectId, p.ProcessInstanceId, p.Id, p.CreatedDate, p.CreatedBy.Name, p.CreatedById, p.Actor.Name, p.ActorId From ProcessInstanceWorkitem p where  p.ActorId =: Userinfo.getUserId() AND p.ProcessInstance.TargetObjectId IN: socialInputMap.keyset() order by p.CreatedDate desc ]  ;
            
        Date today   = Date.today();
        Date week1   = Date.today().addDays(7);
        Date week2   = Date.today().addDays(14);
        Date month1  = Date.today().addDays(30);
        Date lessweek1   = Date.today().addDays(-7);
        Date lessweek2   = Date.today().addDays(-14);
        Date lessmonth1  = Date.today().addDays(-30);
        
        Datetime decisionDueDate  ;
        for( Social_Input__c DecisionCard : myUrgentDecisionList  )
        {
            importantWrapper wrapp =  new importantWrapper();
            wrapp.cardId           =  DecisionCard.Decision__c;
            wrapp.cardType         =  'Decision';
            wrapp.cardTitle        =  DecisionCard.Decision__r.Title__c;
            decisionDueDate        =  DecisionCard.Decision__r.Nearest_Due_Date__c;
            if( decisionDueDate < today )
            {
                importantWrapperMap.get('overdue').add( wrapp );
            }
            if( decisionDueDate == today )
            {
                importantWrapperMap.get('today').add( wrapp );
            }
            if( decisionDueDate > today && decisionDueDate <= week1  )
            {
                importantWrapperMap.get('1week').add( wrapp );
            }
            if( decisionDueDate > week1 && decisionDueDate <= week2  )
            {
                importantWrapperMap.get('2week').add( wrapp );
            }
            if( decisionDueDate > week2 && decisionDueDate <= month1  )
            {
                importantWrapperMap.get('1month').add( wrapp );
            }    
            
        }
        
        Datetime planEndDate  ;
        Datetime planStartDate;
        for( Social_Input__c planCard : myUrgentPlanList  )
        {
            planEndDate            =  planCard.plan__r.End_Time__c;
            planStartDate          =  planCard.plan__r.Start_Time__c;
            importantWrapper wrapp =  new importantWrapper();
            wrapp.cardId           =  planCard.plan__C;
            wrapp.cardType         =  'Plan';
            wrapp.cardTitle        =  planCard.Plan__r.Description__c;
            //if( planStartDate  < System.now() )
            //{
                //importantWrapperMap.get('overdue').add( wrapp );
            //}
            if( planStartDate  < today && planEndDate > today)
            {
                importantWrapperMap.get('today').add( wrapp );
            }
            if( planStartDate < today && planStartDate >= lessweek1  )
            {
                importantWrapperMap.get('1week').add( wrapp );
            }
            if( planStartDate < lessweek1 && planStartDate >= lessweek2  )
            {
                importantWrapperMap.get('2week').add( wrapp );
            }
            if( planStartDate < lessweek2 && planStartDate >= lessmonth1  )
            {
                importantWrapperMap.get('1month').add( wrapp );
            }    
        }
        for( Task taskCard : urgentTaskList  )
        {
            importantWrapper wrapp =  new importantWrapper();
            wrapp.cardId           =  taskCard.id;
            wrapp.cardType         =  'Task';
            wrapp.cardTitle        =  taskCard.subject;
            if( taskCard.activitydate  < today )
            {
                importantWrapperMap.get('overdue').add( wrapp );
            }
            if( taskCard.activitydate  == today )
            {
                importantWrapperMap.get('today').add( wrapp );
            }
            if( taskCard.activitydate > today && taskCard.activitydate <= week1  )
            {
                importantWrapperMap.get('1week').add( wrapp );
            }
            if( taskCard.activitydate > week1 && taskCard.activitydate <= week2  )
            {
                importantWrapperMap.get('2week').add( wrapp );
            }
            if( taskCard.activitydate > week2 && taskCard.activitydate <= month1  )
            { 
                importantWrapperMap.get('1month').add( wrapp );
            }    
        }  
      
      //  integer.valueOf(importantWrapperMapCount ); 
        for( ProcessInstanceWorkitem  approvalCard: ProcessInstanceList  )
        { 
            Social_Input__c loggedInSocialPeople = socialInputMap.get(approvalCard.ProcessInstance.TargetObjectId);
            Datetime duedatetime   = loggedInSocialPeople.Decision__r.Due_Date__c != null ?  loggedInSocialPeople.Decision__r.Due_Date__c : datetime.now().addDays(32);
            importantWrapper wrapp =  new importantWrapper();
            wrapp.cardId           =  approvalCard.id;
            wrapp.cardType         =  'Approval';
            wrapp.cardTitle        =  loggedInSocialPeople.Decision__r.Title__c;
            if( duedatetime  < today )
            {
                importantWrapperMap.get('overdue').add( wrapp );
            }
            if( duedatetime  == today )
            {
                importantWrapperMap.get('today').add( wrapp );
            }
            if( duedatetime > today && duedatetime <= week1  )
            {
                importantWrapperMap.get('1week').add( wrapp );
            }
            if( duedatetime > week1 && duedatetime <= week2  )
            {
                importantWrapperMap.get('2week').add( wrapp );
            }
            if( duedatetime > week2 && duedatetime <= month1  )
            {
                importantWrapperMap.get('1month').add( wrapp );
            }    
            
        }  
    }  
    
      @RemoteAction
     public static Task getTaskById( String id,String status){
     // system.debug('++++++++++++++++++'+i v);
      Task t= new task(id=id,
      Status=status);
      update t;
      return t;
     }
     
      // get to be update Task
    public void toBeUpdatedTask() {
        //updatedTask = [select id,WhatId,Subject,ActivityDate,Status,Priority,OwnerId,Owner.Name,CreatedById,CreatedBy.Name,Description from Task where Id =: ApexPages.currentPage().getParameters().get('taskId')];
        showTaskPopup = true;
        taskId = ApexPages.currentPage().getParameters().get('taskId');
        taskEditable = ApexPages.currentPage().getParameters().get('isEditable');
        modeType = ApexPages.currentPage().getParameters().get('modeType');
    }
     
   public class toDoWarapeer{
        
        List<importantWrapper> importantWrapperList{get;set;}
        String  columnTimeLowerBound{get;set;}
        String  columnTimeUpperBound{get;set;}
        String  dataSetUpperBound{get;set;}
        String  columnId{get;set;}
        String  done{get;set;}
     }
    
    public class importantWrapper implements Comparable { 
        public string cardType{get;set;}
        public string cardTitle{get;set;}
        public string cardId{get;set;}
        public string deadLine{get;set;}
        public string duedate{get;set;}
        public datetime  duedateSorter{get;set;}
        public Long  lastmodifiedTime{get;set;}
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
        public string roleApprovalStatus{get;set;}
        public string AverageRating{get;set;}
        public string TotalLikes{get;set;}
        public string TotalDislikes{get;set;}
        public string statusColor{get;set;}
        public string stanceApprovalStatusColor{get;set;}
        public string moodImagePosition{get;set;}
        public string moodStatus{get;set;}
        //public Social__c sms {get;set;}
        public Integer pulseStatusInt{get;set;}
        
        public string taskSubject{get;set;}
        public string taskId{get;set;}
        public string activitydate{get;set;}
        public task kanbanTask{get;set;}
        public string userImg{get;set;}
        public string priorityImage{get;set;}
        public string relatedTo{get;set;}
        public string relatedToId{get;set;}
        public string comments{get;set;}
        public string userAssignImgUrl{get;set;}
        public string userAssigneeName{get;set;}
        public string userAssigneeDept{get;set;}
        //public string userAssigneeTemplate{get;set;}
        
        public string userAssignedImgUrl{get;set;}
        public string userAssignedName{get;set;}
        public string userAssignedDept{get;set;}
        //public string userAssignedTemplate{get;set;}
        public boolean recordAccess{get;set;}
        public string lockImg{get;set;}
        
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
        
         Public String id{get;set;}
         Public String subject{get;set;}
         Public String title{get;set;}
         Public String decisionImage{get;set;}
         Public String requestedPhoto{get;set;}
         Public String nameOfRequeste{get;set;}
         Public String typeOfApproval{get;set;}
         Public String approvalStatus{get;set;}
         Public String socialInputId{get;set;}
         Public String role{get;set;}
         
         public boolean showOvelay {get; set;}
         public String showApprovalOvelay {get; set;}
         public Id approvalProcessId {get; set;}
         // public Integer pulseStatusInt{get;set;}
         public importantWrapper() {
            itemCount = 0;
         }
         
         public Integer compareTo(Object compareTo)    
         {
                 importantWrapper appdata = (importantWrapper) compareTo; 
                 if (   this.duedateSorter  ==   appdata.duedateSorter   )
                 {
                    if( this.cardType  ==   appdata.cardType )
                    return 0;
                    else
                    {
                          if (  this.cardType   >   appdata.cardType  )
                          return 2;  
                          return -2;                     
                    }
                 }
                  
                 if (  this.duedateSorter   <   appdata.duedateSorter  )
                  return 1;  
                  return -1; 
         }  
    }
    global class HomeChartsWrapper{
        public string lastWeekDecisionSizeStr{get;set;}
        public string twoWeekAgoDecisionSizeStr{get;set;}
        public string threeWeekAgoDecisionSizeStr{get;set;}
        public string fourWeekAgoDecisionSize{get;set;}
        public string decisionProgressStr{get;set;}
        public string decisionCreatedStr{get;set;}
    }
    
    global class kendoObject {
        public String xAxis {get;set;}
        public Integer yAxis {get;set;}
    }
    
    public class ApprovalWrapper{
        public string id{get;set;}
        public string step{get;set;}
        public string Title{get;set;}
        public string decisionId{get;set;}
        public string status{get;set;}
        public string statusImage{get;set;}
        public string createdDate{get;set;}
        public string createdBy{get;set;}
        public string approveImg{get;set;}
        public string problemStmt{get;set;}
        public string decision{get;set;}
        public string dueDate{get;set;}
        public String userRole {get; set;}
        public Boolean vetoRights {get; set;}
        public Boolean backupRights {get; set;}
        public String titleHover {get; set;}
        // added on 21-04-2014 to sort the date fields
        public dateTime dueDateSort{get;set;}
        
    }
    
    public class UrgentApprovalWrapper{
        public string id{get;set;}
        public string step{get;set;}
        public string Title{get;set;}
        public string decisionId{get;set;}
        public string status{get;set;}
        public string statusImage{get;set;}
        public string DueDate{get;set;}
        public string Owner{get;set;}
        public string OwnerId{get;set;}
        public string approveImg{get;set;}
        public string problemStmt{get;set;}
        public string decision{get;set;}
        public string myRole{get;set;}
        public string fieldTitle1{get;set;}
        public string fieldTitle2{get;set;}
        public Boolean vetoRights {get; set;}
        public Boolean backupRights {get; set;}
        public String titleHover {get; set;}
        // added on 21-04-2014 to sort the date fields
        public dateTime dueDateSort{get;set;}
    }
    
    public class decisionHighlight{
        public string Id{get;set;}
        public string title{get;set;}
        public string phase{get;set;}
        public string phaseImg{get;set;}
        public string lastModifiedDate{get;set;}
        public string DueDate{get;set;}
        public string owner{get;set;}
        public Social__c sms{get;set;}
        public decimal likeValue{get;set;}
        public string likeImg{get;set;}
        public string mood{get;set;}
        public string moodImg{get;set;}
        public string moodClass{get;set;}
        
        public decimal starValue{get;set;}
        public string starImage{get;set;}
        public decimal issueValue{get;set;}
        public string startImage{get;set;}
        public string issueImg{get;set;}
        // started added on 21-04-2014
        public DateTime lastModifiedDateSort{get;set;}
        public DateTime DueDateSort{get;set;}
        // end added on 21-04-2014
    }
    
    public class myDecisionsWrapper{
        public string Id{get;set;}
        public string Name{get;set;}
        public string phase{get;set;}
        public string phaseImg{get;set;}
        public string lastModifiedDate{get;set;}
        public string dueDate{get;set;}
        // added on 21-04-2014 to sort the date fields
        public dateTime lastModifiedDateSort{get;set;}
        public dateTime dueDateSort{get;set;}
        public Integer pulseStatusInt{get;set;}
    }
    
    public class myTasksWrapper{
        public string Id{get;set;}
        public string Subject{get;set;}
        public string DueDate{get;set;}
        public string Status{get;set;}
        public string StatusImg{get;set;} 
        public string Priority{get;set;}
        public string CreatedBy{get;set;}
        public string AssignedTo{get;set;}
        public String relatedTo{get;set;}
        public String relatedToId{get;set;}
        public string dateFormatToBeSet{get;set;}        
    }
    
    public class urgentDecisionWrapper{
        public string Id{get;set;}
        public string decisionId{get;set;}
        public string decisionTitle{get;set;}
        public string problemStatement{get;set;}
        public string decisionTaken{get;set;}
        public string phaseImg{get;set;}
        public string phase{get;set;}
        public string dueDate{get;set;}
        public string myRole{get;set;}
        public string ownerId{get;set;}
        public string ownerName{get;set;} 
        public string fieldTitle1{get;set;}
        public string fieldTitle2{get;set;}
        // start added on 22-4-2014
        public datetime dueDateSort{get;set;}
       
        // end added on 22-4-2014
    }
    
    public class urgentTaskWrapper{
        public string Id{get;set;}
        public string title{get;set;}
        public string relatedToId{get;set;}
        public string relatedTo{get;set;}
        public string DueDate{get;set;}
        public string status{get;set;}
        public string priority{get;set;}
        public string CreatedById{get;set;}
        public string CreatedBy{get;set;}
        // added on 22-04-2014
         public datetime dueDateSort{get;set;}
        //added on 22-04-2014
    }
    
    public class pendingApprovalWrapper{
        public string Id{get;set;}
        public string title{get;set;}
        public string pendingApprovers{get;set;}
        public string myRole{get;set;}
        public string DueDate{get;set;}
        public string status{get;set;}
        public string priority{get;set;}
        public string phase{get;set;}
        public string phaseImg{get;set;}
        // start added on 22-4-2014
        public datetime dueDateSort{get;set;}
        // end added on 22-4-2014
    }
    
    public class myCollegueTaskWrapper{
        public string Id{get;set;}
        public string Subject{get;set;}
        public string DueDate{get;set;}
        public string Status{get;set;}
        public string StatusImage{get;set;} 
        public string Priority{get;set;}
        public string AssignedId{get;set;}
        public string AssignedName{get;set;}
        public string relatedToName{get;set;}
        public string relatedToId{get;set;}
        public String typeOfTask{get;set;}
        // start added on 22-4-2014
        public datetime dueDateSort{get;set;}
        // end added on 22-4-2014
    }
    
    public class Datum
    {
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
    
    public class UrgentIssuesWrapper{
        public String relatedToObject {get; set;}
        public String relatedToId {get; set;}
        public String assignTo {get; set;}
        public String issueId {get; set;}
        public String issueName {get; set;}
        public String status {get; set;}
        public String type {get; set;}
        public String priority {get; set;}
        public String comments {get; set;}
        public String ownerId {get; set;}
    }
    
    public class IssuesDatum {
        public String relatedToObject {get; set;}
        public String relatedToId {get; set;}
        public String assignTo {get; set;}
        public String issueId {get;set;}
        public String issueName {get; set;}
        public String status {get; set;}
        public String type {get; set;}
        public String priority {get; set;}
        public String comments {get; set;}
    }   
    
    public class IssuesRootObject {
        public List<IssuesDatum> data {get; set;}
    }
    
    public class data {
        public List<urgentTaskWrapper>  models{get; set;}
    }
    
    public class dataIssues{
        public List<UrgentIssuesWrapper>  models{get; set;} 
    }
    
    public class dataWrapIssues{
        public dataIssues data{get;set;}    
    }
    public class dataWrap {
        public data data   {get; set;}
    }
    public class RootObject
    {
        public List<Datum> data { get; set; } 
    }
    
    // Method for important section
      public void viewImportantCards(){  
        
        
     }
     @RemoteAction
    global static string UrgentTabsCount(String searchText , String timeSelected){
        // initialize General information class to get user locale date format and image static resouce url
        if(genralInfo == null ) {
            genralInfo  = new GeneralInformation();
        }
        UrgentTabsCounterWrapper tabCountWrapp = new UrgentTabsCounterWrapper();
        Date todaysDate = System.today();
        dateTimeFormat = genralInfo.MapValuesDateTime();
        // Code to get count of urgent tasks
        // These conditions are based on user slected dropdown
        if(timeSelected == '24hours'){
            todaysDate = todaysDate.addDays(1);
        } else if(timeSelected == '48hours'){
            todaysDate = todaysDate.addDays(2);
        } else if(timeSelected == '' || timeSelected == '7days'){
            todaysDate = todaysDate.addDays(7);
        } else if(timeSelected == '1month'){
            todaysDate = todaysDate.addMonths(1);
        } else if(timeSelected == 'All'){
            todaysDate = todaysDate.addYears(10);
        }
        
        // Search text to replace * with %
        if(searchText != ''){
            if(searchText.contains('*')){
                String SearchtextList=searchText.replaceAll('\\*','\\%');
                searchText = SearchtextList;
            }
        }
        
        List<Task> urgentTaskList = new List<Task>();
        if(searchText != ''){
            searchText = searchText+'%';
            if(timeSelected == 'All'){
                // This query is used when user selects "All" from the drop down, which will query all the records even when due date is null
                tabCountWrapp.urgentTaskCount = [Select count()  From Task t where t.Owner.id =: UserInfo.getUserId() and t.Subject like : '%'+searchText+'%' and t.IsClosed = false     ];
            } else {
                tabCountWrapp.urgentTaskCount = [Select count() From Task t where t.ActivityDate <=: todaysDate and t.Owner.id =: UserInfo.getUserId() and t.Subject like : '%'+searchText+'%' and t.IsClosed = false   ];
            }
        } else {
            if(timeSelected == 'All'){
                // This query is used when user selects "All" from the drop down, which will query all the records even when due date is null
                tabCountWrapp.urgentTaskCount  = [Select  count() From Task t where t.Owner.id =: UserInfo.getUserId() and t.IsClosed = false   ];
            } else {
                tabCountWrapp.urgentTaskCount  = [Select  count() From Task t where t.ActivityDate <=: todaysDate and t.Owner.id =: UserInfo.getUserId() and t.IsClosed = false  ];
            }
        }
        //Count for approval tab  
        Map<id,Social_Input__c> socialInputMap =  new Map<id,Social_Input__c>();
        if(searchText != ''){
            socialInputMap =  new Map<id,Social_Input__c>([Select Decision__c,Final_Approval_Status__c ,Stance_Approval_Status__c, id From Social_Input__c s where  s.User__c =: userInfo.getUserId() and s.Decision__c != null and s.Decision__r.Title__c like : '%'+searchText+'%']);
        } else {
            socialInputMap =  new Map<id,Social_Input__c>([Select Decision__c,Final_Approval_Status__c ,Stance_Approval_Status__c, id  From Social_Input__c s where  s.User__c =: userInfo.getUserId() and s.Decision__c != null]);
        }
        set<id> SocialDecisionId = new set<id>(); 
        for(id socialInputId : socialInputMap.keyset()){
            SocialDecisionId.add(socialInputMap.get(socialInputId).Decision__c);
        }
        List<Timing__c> TimingRecords = new List<Timing__c>();
        if(timeSelected == 'All'){  
            TimingRecords =[Select id,End_Date_Time__c,Related_To_ID__c from Timing__c where Related_To_ID__c in:SocialDecisionId and Stage__c='Propose'];
        } else {
            TimingRecords =[Select id,End_Date_Time__c,Related_To_ID__c from Timing__c where Related_To_ID__c in:SocialDecisionId and Stage__c='Propose' and End_Date_Time__c <=: todaysDate];
        }
        tabCountWrapp.urgentApprovalCount = 0;
        for(ProcessInstanceWorkitem piw : [Select p.ProcessInstance.Status, p.ProcessInstance.TargetObjectId, p.ProcessInstanceId, p.Id, p.CreatedDate, p.CreatedBy.Name, p.CreatedById, p.Actor.Name, p.ActorId From ProcessInstanceWorkitem p where  p.ActorId =: Userinfo.getUserId() AND p.ProcessInstance.TargetObjectId IN: socialInputMap.keyset() order by p.CreatedDate desc ]) {
            for(Timing__c t : TimingRecords){
               if(socialInputMap.get(piw.ProcessInstance.TargetObjectId).Final_Approval_Status__c != null || socialInputMap.get(piw.ProcessInstance.TargetObjectId).Stance_Approval_Status__c != null){
                    if(socialInputMap.get(piw.ProcessInstance.TargetObjectId).Decision__c == t.Related_To_ID__c){  
                     tabCountWrapp.urgentApprovalCount ++;
                    }
                }
            }
        }
        
        List<Social_Input__c> myUrgentDecisionList = new List<Social_Input__c>();
        if(searchText != ''){
            searchText = searchText+'%';
            if(timeSelected == 'All'){
                // This query is used when user selects "All" from the drop down, which will query all the records even when due date is null
                tabCountWrapp.urgentDecisionCount = [select  count() from Social_Input__c where User__c =: UserInfo.getUserId() and (Accountable__c = true or Backup_for_Accountable__c = true or Responsible__c = true) and Decision__r.phase__c != 'Close' and Decision__r.Title__c like : '%'+searchText+'%'   limit 1000];
            } else {
                tabCountWrapp.urgentDecisionCount = [select  count()  from Social_Input__c where User__c =: UserInfo.getUserId() and (Accountable__c = true or Backup_for_Accountable__c = true or Responsible__c = true) and Decision__r.Nearest_Due_Date__c != null and Decision__r.Nearest_Due_Date__c <=: todaysDate and Decision__r.phase__c != 'Close' and Decision__r.Title__c like : '%'+searchText+'%'  limit 1000]; 
            }
        } else {
            if(timeSelected == 'All'){
                // This query is used when user selects "All" from the drop down, which will query all the records even when due date is null
                tabCountWrapp.urgentDecisionCount = [select  count() from Social_Input__c where User__c =: UserInfo.getUserId() and (Accountable__c = true or Backup_for_Accountable__c = true or Responsible__c = true) and Decision__r.phase__c != 'Close'   limit 1000];
            } else {
                tabCountWrapp.urgentDecisionCount  = [select count() from Social_Input__c where User__c =: UserInfo.getUserId() and (Accountable__c = true or Backup_for_Accountable__c = true or Responsible__c = true) and Decision__r.Nearest_Due_Date__c != null and Decision__r.Nearest_Due_Date__c <=: todaysDate and Decision__r.phase__c != 'Close'  limit 1000];
            }
        }
        if(searchText != ''){
            searchText = searchText+'%';
            if(timeSelected == 'All'){
                // This query is used when user selects "All" from the drop down, which will query all the records even when due date is null
                tabCountWrapp.urgentAssignedDelayedCount = [select count()  from task where IsClosed = false and createdById =: UserInfo.getUserId() and OwnerId !=: UserInfo.getUserId() and Subject like : '%'+searchText+'%'];
            } else {
                tabCountWrapp.urgentAssignedDelayedCount = [select count() from task where activityDate <=: todaysDate and IsClosed = false and createdById =: UserInfo.getUserId() and OwnerId !=: UserInfo.getUserId() and Subject like : '%'+searchText+'%'];
            }
        } else {
            if(timeSelected == 'All'){
                // This query is used when user selects "All" from the drop down, which will query all the records even when due date is null
                tabCountWrapp.urgentAssignedDelayedCount = [select count() from task where IsClosed = false and createdById =: UserInfo.getUserId() and OwnerId !=: UserInfo.getUserId()     ];
            } else { 
                tabCountWrapp.urgentAssignedDelayedCount = [select count() from task where activityDate <=: todaysDate and IsClosed = false and createdById =: UserInfo.getUserId() and OwnerId !=: UserInfo.getUserId()   ];
            }
        }
        List<String> phaseString = new List<String>{'Decide','Execute','Evaluate'} ;
        List<Social_Input__c> socialInputWithMyDecision = new List<Social_Input__c>() ;
        Map<Id,Social_Input__c> decisionSocialMap = new Map<Id,Social_Input__c>() ;
        
        tabCountWrapp.urgentPendingApproverCount = 0;
        
        if(searchText != ''){
            if(searchText.contains('*')){
                String SearchtextList=searchText.replaceAll('\\*','\\%');
                searchText = SearchtextList;
            }
        }
        if(searchText != ''){
            searchText = searchText+'%';
            if(timeSelected == 'All'){
                // This query is used when user selects "All" from the drop down, which will query all the records even when due date is null
                socialInputWithMyDecision = [Select id, User__c,Decision__c,Decision__r.Title__c,Role__c,Decision__r.Nearest_Due_Date__c,Decision__r.Status__c,Decision__r.Priority__c, Decision__r.phase__c, Final_Approval_Status__c from Social_Input__c where Decision__r.Phase__c in : phaseString and (Final_Approval_Status__c = 'Approved' or Final_Approval_Status__c = 'Rejected' or Stance_Approval_Status__c = 'Approved' or Stance_Approval_Status__c = 'Rejected') and User__c =: UserInfo.getUserId() and (Accountable__c = true or Backup_for_Accountable__c = true) and Decision__r.Title__c like : '%'+searchText+'%' order by Decision__r.Nearest_Due_Date__c desc NULLS LAST limit 100];
            } else {
                socialInputWithMyDecision = [Select id, User__c,Decision__c,Decision__r.Title__c,Role__c,Decision__r.Nearest_Due_Date__c,Decision__r.Status__c,Decision__r.Priority__c, Decision__r.phase__c, Final_Approval_Status__c from Social_Input__c where Decision__r.Phase__c in : phaseString and (Final_Approval_Status__c = 'Approved' or Final_Approval_Status__c = 'Rejected' or Stance_Approval_Status__c = 'Approved' or Stance_Approval_Status__c = 'Rejected') and User__c =: UserInfo.getUserId() and (Accountable__c = true or Backup_for_Accountable__c = true) and Decision__r.Nearest_Due_Date__c != null and Decision__r.Nearest_Due_Date__c <=: todaysDate and Decision__r.Title__c like : '%'+searchText+'%' order by Decision__r.Nearest_Due_Date__c desc limit 100];   
            }
        } else {
            if(timeSelected == 'All'){
                // This query is used when user selects "All" from the drop down, which will query all the records even when due date is null
                socialInputWithMyDecision = [Select id, User__c,Decision__c,Decision__r.Title__c,Role__c,Decision__r.Nearest_Due_Date__c,Decision__r.Status__c,Decision__r.Priority__c, Decision__r.phase__c, Final_Approval_Status__c from Social_Input__c where Decision__r.Phase__c in : phaseString and (Final_Approval_Status__c = 'Approved' or Final_Approval_Status__c = 'Rejected' or Stance_Approval_Status__c = 'Approved' or Stance_Approval_Status__c = 'Rejected') and User__c =: UserInfo.getUserId() and (Accountable__c = true or Backup_for_Accountable__c = true) order by Decision__r.Nearest_Due_Date__c desc NULLS LAST limit 100];
            } else {
                socialInputWithMyDecision = [Select id, User__c,Decision__c,Decision__r.Title__c,Role__c,Decision__r.Nearest_Due_Date__c,Decision__r.Status__c,Decision__r.Priority__c, Decision__r.phase__c, Final_Approval_Status__c from Social_Input__c where Decision__r.Phase__c in : phaseString and (Final_Approval_Status__c = 'Approved' or Final_Approval_Status__c = 'Rejected' or Stance_Approval_Status__c = 'Approved' or Stance_Approval_Status__c = 'Rejected') and User__c =: UserInfo.getUserId() and (Accountable__c = true or Backup_for_Accountable__c = true) and Decision__r.Nearest_Due_Date__c != null and Decision__r.Nearest_Due_Date__c <=: todaysDate order by Decision__r.Nearest_Due_Date__c desc limit 100];
            }
        }   
        Set<Id> socialDecisions = new set<Id>();
        
        for(Social_Input__c s : socialInputWithMyDecision){
            socialDecisions.add(s.Decision__c); 
            decisionSocialMap.put(s.Decision__c,s);
        }
        map<Id,List<String>> pendingApprovalUserMap = new map<Id,List<String>>();
        List<Social_Input__c> socialPendingApprovals = [Select id, User__c,Decision__c from Social_Input__c where Decision__c IN : socialDecisions and (Final_Approval_Status__c = 'Pending Approval' or Stance_Approval_Status__c = 'Pending Approval') and User__c !=: UserInfo.getUserId()];
        for(Social_Input__c s : socialPendingApprovals){
            List<String> pendingApprovalUserList = pendingApprovalUserMap.get(s.Decision__c);
            if(pendingApprovalUserList == null) {
                pendingApprovalUserList = new List<String>();
                pendingApprovalUserMap.put(s.Decision__c, pendingApprovalUserList);
            }
            pendingApprovalUserList.add(string.ValueOf(s.User__c));
        }
        System.debug('-------Pending list-----'+pendingApprovalUserMap);
        pendingApprovalList = new List<pendingApprovalWrapper>();
        for(Id s : socialDecisions){
            if(pendingApprovalUserMap.get(s) != null){ 
                tabCountWrapp.urgentPendingApproverCount++;
            }
            
        }
        return JSON.serialize( tabCountWrapp );
    }
     // pulse in command center 
     @RemoteAction
    public static void updatePulse(String pulseStatus, String decisionId){
        Decision__c decision = new Decision__c(id = decisionId );
         //decision.Id = decisionId;
         decision.Progress__c = pulseStatus;
        if(FLS.decisionUpdateable()){
            update decision;
        }
     
    }
     Public set<Id> decisionIds{get;set;}
     Public set<Id> planIds{get;set;}
     Public set<Id> decisionApprovalIds{get;set;}
     Public set<Id> taskIds{get;set;}
     
     public class  UrgentTabsCounterWrapper{
        public integer urgentTaskCount {get;set;}
        public integer urgentDecisionCount {get;set;}
        public integer urgentApprovalCount {get;set;}
        public integer urgentAssignedDelayedCount {get;set;}  
        public integer urgentPendingApproverCount {get;set;}       
     }
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
        // Method for important section  
        // This method is called for all columns with the following parameters
        // searchAll = false for all call from else true for  all recrusive,
        // cardTypes =Type cards required..
        // dataSetUpperBound = the last modified dates upper bound for a column in millisecond
        // columnUpperBound = for the upper bound of due date for a column in millisecond
        // columnLowerBound = for the upper bound of due date for a column in millisecond
      @remoteaction  
      public static string  viewImportantColumnCards(Boolean searchAll,String cardTypes,Long dataSetUpperBound,Long columnUpperBound,Long columnLowerBound){  
        if(genralInfo == null){  
         genralInfo = new GeneralInformation();     
        }
          
        Long millisecondGmt = System.now().getTime(); // Time now in millis
        DateTime  timeUpperBound; // Date time to filter last modifieddate field
        DateTime  timeLowerBound; // Date time to filter last modifieddate field
        DateTime  columnTimeLowerBound ;   // Date time to filter due date field
        DateTime  columnTimeUpperBound ; // Date time to filter due date field
        Date  columnDateLowerBound  ; // Date time to filter task activity date field
        Date  columnDateUpperBound ; // Date time to filter task activity date field
        
        if( searchAll == true  ) {   
            timeUpperBound  =    DateTime.newInstance( dataSetUpperBound ); 
            timeLowerBound  =    DateTime.newInstance( 0 );  // if complete search then last use least possible value
        }
        else{  
            if(  dataSetUpperBound  == columnUpperBound  )
            timeUpperBound  =    DateTime.newInstance( system.now().getTime() );  // if call is for a new column set upper bound as now 
            else
            timeUpperBound  =    DateTime.newInstance( dataSetUpperBound );   
            timeLowerBound  =    DateTime.newInstance( dataSetUpperBound ).addMonths(-1);  // if not complete search search for last month
        }
        
        
         columnTimeLowerBound  =    DateTime.newInstance( columnLowerBound );   //create datetime for column lower bound
         columnTimeUpperBound  =    DateTime.newInstance( columnUpperBound );   // create datetime for column upper bound
        //variables to select the set of recods for diferent columns
         columnDateLowerBound  =    Date.newInstance( columnTimeLowerBound.year(), columnTimeLowerBound.month(), columnTimeLowerBound.day() ); //create datetime for column lower bound
         columnDateUpperBound  =    Date.newInstance( columnTimeUpperBound.year(), columnTimeUpperBound.month(), columnTimeUpperBound.day() ); // create datetime for column upper bound
        // cardTypes can containg APDT A fro approval P for plan D for decision and T for task
        Boolean decisionCheckboxSelected = cardTypes.contains('D'); 
        Boolean planCheckboxSelected = cardTypes.contains('P');  
        Boolean taskCheckboxSelected = cardTypes.contains('T');  
        Boolean approvalCheckboxSelected = cardTypes.contains('A');
        
        system.debug(dataSetUpperBound);
        system.debug(timeUpperBound);
        system.debug(timeLowerBound);
        system.debug(columnDateLowerBound);
        system.debug(columnDateUpperBound);
         
         
        List<Social_Input__c>    mySocialInputList ;      
        List<Social_Input__c>    myUrgentPlanList ;
        List<Task>               importantTaskList ;
        Map<id,Social_Input__c>  socialInputMap   ;
        List<ProcessInstanceWorkitem> ProcessInstanceList ;   
        
        // Queries to be executed  for today column 
        if(   columnUpperBound - columnLowerBound  ==  86400000L ){
            if(decisionCheckboxSelected)
            mySocialInputList        = [select id,lastmodifieddate, Decision__c,Decision__r.lastmodifieddate, Decision__r.Title__c,Decision__r.Problem_Idea_Advice__c,Decision__r.Decision_Taken__c, Decision__r.OwnerId, Decision__r.Phase__c,Role__c,Decision__r.Nearest_Due_Date__c from Social_Input__c where User__c =: UserInfo.getUserId() and (Accountable__c = true or Backup_for_Accountable__c = true or Responsible__c = true) and  Decision__c != null and Decision__r.phase__c != 'Close' and Decision__r.lastmodifieddate >=: timeLowerBound and Decision__r.lastmodifieddate <: timeUpperBound  and Decision__r.Nearest_Due_Date__c >=: columnTimeLowerBound and Decision__r.Nearest_Due_Date__c <: columnTimeUpperBound and Decision__r.Nearest_Due_Date__c != null  order by Decision__r.lastmodifieddate DESC NULLS LAST  ];
            if(planCheckboxSelected)
            myUrgentPlanList         = [select id,lastmodifieddate,Plan__r.OwnerId, Plan__c,Plan__r.Name,Plan__r.lastmodifieddate,Plan__r.location__c, Plan__r.Description__c,Plan__r.Start_Time__c,Plan__r.End_Time__c from Social_Input__c where User__c =: UserInfo.getUserId() and (Accountable__c = true or Backup_for_Accountable__c = true or Responsible__c = true) and Plan__c != null and Plan__r.lastmodifieddate <: timeUpperBound and Plan__r.lastmodifieddate >=: timeLowerBound  and Plan__r.Start_Time__c <=: columnTimeLowerBound and  Plan__r.End_Time__c >=: columnTimeLowerBound    order by Plan__r.lastmodifieddate DESC ];
            if(taskCheckboxSelected)
            importantTaskList        = [Select t.Id,t.lastmodifieddate,t.Description , t.ActivityDate ,t.What.Name, t.Who.Name, t.WhoId, t.WhatId, t.Subject, t.Status, t.Priority,t.ownerId,t.Owner.Name , t.CreatedById,t.CreatedBy.Name From Task t where t.Owner.id =: UserInfo.getUserId()   and t.IsClosed = false  and lastmodifieddate >=: timeLowerBound  and lastmodifieddate <: timeUpperBound and activitydate =: columnDateLowerBound  and activitydate != null order by lastmodifieddate  DESC ];
            if(approvalCheckboxSelected)
            socialInputMap           = new Map<id,Social_Input__c>([Select id,lastmodifieddate, Accountable__c,Responsible__c,Consulted__c,Informed__c,Backup_for_Accountable__c,Veto_Rights__c, Role__c,Decision__r.Nearest_Due_Date__c,Decision__r.Due_Date__c,Decision__r.Title__c,Decision__r.Decision_Taken__c ,Decision__r.lastmodifieddate,Decision__r.status__c,Decision__r.Problem_Idea_Advice__c ,Final_Approval_Status__c , Decision__c , User__r.Name, User__r.department,Stance_Approval_Status__c, User__c, Role_Acceptance_Status__c  from Social_Input__c where User__c =: UserInfo.getUserId()  and  Decision__c != null   order by Decision__r.lastmodifieddate DESC  ]);
        } 
        else  
        // queries to be executed for Overdue column
        if( columnLowerBound == 0 && columnUpperBound != 0 ){
            if(decisionCheckboxSelected)
            mySocialInputList        = [select id,lastmodifieddate, Decision__c,Decision__r.lastmodifieddate, Decision__r.Title__c,Decision__r.Problem_Idea_Advice__c,Decision__r.Decision_Taken__c, Decision__r.OwnerId, Decision__r.Phase__c,Role__c,Decision__r.Nearest_Due_Date__c from Social_Input__c where User__c =: UserInfo.getUserId() and (Accountable__c = true or Backup_for_Accountable__c = true or Responsible__c = true) and  Decision__c != null and Decision__r.phase__c != 'Close' and Decision__r.lastmodifieddate >=: timeLowerBound and Decision__r.lastmodifieddate <: timeUpperBound  and Decision__r.Nearest_Due_Date__c >=: columnTimeLowerBound and Decision__r.Nearest_Due_Date__c <: columnTimeUpperBound and Decision__r.Nearest_Due_Date__c != null  order by Decision__r.lastmodifieddate DESC NULLS LAST  ];
            if(planCheckboxSelected)
            myUrgentPlanList         = [select id,lastmodifieddate,Plan__r.OwnerId, Plan__c,Plan__r.Name,Plan__r.lastmodifieddate,Plan__r.location__c, Plan__r.Description__c,Plan__r.Start_Time__c,Plan__r.End_Time__c from Social_Input__c where User__c =: UserInfo.getUserId() and (Accountable__c = true or Backup_for_Accountable__c = true or Responsible__c = true) and Plan__c != null and Plan__r.lastmodifieddate <: timeUpperBound and Plan__r.lastmodifieddate >=: timeLowerBound  and  Plan__r.Start_Time__c >=: columnTimeLowerBound  and Plan__r.Start_Time__c <: columnTimeUpperBound    order by Plan__r.lastmodifieddate DESC  limit 0];
            if(taskCheckboxSelected)
            importantTaskList        = [Select t.Id,t.lastmodifieddate,t.Description , t.ActivityDate ,t.What.Name, t.Who.Name, t.WhoId, t.WhatId, t.Subject, t.Status, t.Priority,t.ownerId,t.Owner.Name , t.CreatedById,t.CreatedBy.Name From Task t where t.Owner.id =: UserInfo.getUserId()   and t.IsClosed = false  and lastmodifieddate >=: timeLowerBound  and lastmodifieddate <: timeUpperBound and activitydate >=: columnDateLowerBound  and activitydate <: columnDateUpperBound  and activitydate != null order by lastmodifieddate  DESC ];
            if(approvalCheckboxSelected)
            socialInputMap           = new Map<id,Social_Input__c>([Select id,lastmodifieddate, Accountable__c,Responsible__c,Consulted__c,Informed__c,Backup_for_Accountable__c,Veto_Rights__c, Role__c,Decision__r.Nearest_Due_Date__c,Decision__r.Due_Date__c,Decision__r.Title__c,Decision__r.Decision_Taken__c ,Decision__r.lastmodifieddate,Decision__r.status__c,Decision__r.Problem_Idea_Advice__c ,Final_Approval_Status__c , Decision__c , User__r.Name, User__r.department,Stance_Approval_Status__c, User__c, Role_Acceptance_Status__c  from Social_Input__c where User__c =: UserInfo.getUserId()  and  Decision__c != null   order by Decision__r.lastmodifieddate DESC  ]);
        } 
        else
        // Queries to be executed for 1 month
        if(    columnUpperBound == 32503660200000L && columnLowerBound != 0 )    
        {  
            if(decisionCheckboxSelected)
            mySocialInputList        = [select id,lastmodifieddate, Decision__c,Decision__r.lastmodifieddate, Decision__r.Title__c,Decision__r.Problem_Idea_Advice__c,Decision__r.Decision_Taken__c, Decision__r.OwnerId, Decision__r.Phase__c,Role__c,Decision__r.Nearest_Due_Date__c from Social_Input__c where User__c =: UserInfo.getUserId() and (Accountable__c = true or Backup_for_Accountable__c = true or Responsible__c = true) and  Decision__c != null and Decision__r.phase__c != 'Close' and Decision__r.lastmodifieddate >=: timeLowerBound and Decision__r.lastmodifieddate <: timeUpperBound  and Decision__r.Nearest_Due_Date__c >=: columnTimeLowerBound and Decision__r.Nearest_Due_Date__c <: columnTimeUpperBound and Decision__r.Nearest_Due_Date__c != null  order by Decision__r.lastmodifieddate DESC NULLS LAST  ];
            if(planCheckboxSelected)            
            myUrgentPlanList         = [select id,lastmodifieddate,Plan__r.OwnerId, Plan__c,Plan__r.Name,Plan__r.lastmodifieddate,Plan__r.location__c, Plan__r.Description__c,Plan__r.Start_Time__c,Plan__r.End_Time__c from Social_Input__c where User__c =: UserInfo.getUserId() and (Accountable__c = true or Backup_for_Accountable__c = true or Responsible__c = true) and Plan__c != null and Plan__r.lastmodifieddate <: timeUpperBound and Plan__r.lastmodifieddate >=: timeLowerBound  and Plan__r.Start_Time__c >=: system.now().addDays(7) and  Plan__r.start_Time__c <=: system.now().addDays(30)    order by Plan__r.lastmodifieddate DESC ];
            if(taskCheckboxSelected)            
            importantTaskList        = [Select t.Id,t.lastmodifieddate,t.Description , t.ActivityDate ,t.What.Name, t.Who.Name, t.WhoId, t.WhatId, t.Subject, t.Status, t.Priority,t.ownerId,t.Owner.Name , t.CreatedById,t.CreatedBy.Name From Task t where t.Owner.id =: UserInfo.getUserId()   and t.IsClosed = false  and lastmodifieddate >=: timeLowerBound  and lastmodifieddate <: timeUpperBound and activitydate >: columnDateLowerBound  and activitydate <: columnDateUpperBound  and activitydate != null order by lastmodifieddate  DESC ];
            if(approvalCheckboxSelected)
            socialInputMap           = new Map<id,Social_Input__c>([Select id,lastmodifieddate, Accountable__c,Responsible__c,Consulted__c,Informed__c,Backup_for_Accountable__c,Veto_Rights__c, Role__c,Decision__r.Nearest_Due_Date__c,Decision__r.Due_Date__c,Decision__r.Title__c,Decision__r.Decision_Taken__c ,Decision__r.lastmodifieddate,Decision__r.status__c,Decision__r.Problem_Idea_Advice__c ,Final_Approval_Status__c , Decision__c , User__r.Name, User__r.department,Stance_Approval_Status__c, User__c, Role_Acceptance_Status__c  from Social_Input__c where User__c =: UserInfo.getUserId()  and  Decision__c != null   order by Decision__r.lastmodifieddate DESC  ]);
        }   
        else 
        //Queries to be executed for 1 week
        if(    columnUpperBound != 0 && columnLowerBound != 0 )    
        {  
            if(decisionCheckboxSelected)
            mySocialInputList        = [select id,lastmodifieddate, Decision__c,Decision__r.lastmodifieddate, Decision__r.Title__c,Decision__r.Problem_Idea_Advice__c,Decision__r.Decision_Taken__c, Decision__r.OwnerId, Decision__r.Phase__c,Role__c,Decision__r.Nearest_Due_Date__c from Social_Input__c where User__c =: UserInfo.getUserId() and (Accountable__c = true or Backup_for_Accountable__c = true or Responsible__c = true) and  Decision__c != null and Decision__r.phase__c != 'Close' and Decision__r.lastmodifieddate >=: timeLowerBound and Decision__r.lastmodifieddate <: timeUpperBound  and Decision__r.Nearest_Due_Date__c >=: columnTimeLowerBound and Decision__r.Nearest_Due_Date__c <: columnTimeUpperBound and Decision__r.Nearest_Due_Date__c != null  order by Decision__r.lastmodifieddate DESC NULLS LAST  ];
            if(planCheckboxSelected)            
            myUrgentPlanList         = [select id,lastmodifieddate,Plan__r.OwnerId, Plan__c,Plan__r.Name,Plan__r.lastmodifieddate,Plan__r.location__c, Plan__r.Description__c,Plan__r.Start_Time__c,Plan__r.End_Time__c from Social_Input__c where User__c =: UserInfo.getUserId() and (Accountable__c = true or Backup_for_Accountable__c = true or Responsible__c = true) and Plan__c != null and Plan__r.lastmodifieddate <: timeUpperBound and Plan__r.lastmodifieddate >=: timeLowerBound  and Plan__r.Start_Time__c >=: system.now().addDays(0) and  Plan__r.start_Time__c <=: system.now().addDays(7)    order by Plan__r.lastmodifieddate DESC ];
            if(taskCheckboxSelected)            
            importantTaskList        = [Select t.Id,t.lastmodifieddate,t.Description , t.ActivityDate ,t.What.Name, t.Who.Name, t.WhoId, t.WhatId, t.Subject, t.Status, t.Priority,t.ownerId,t.Owner.Name , t.CreatedById,t.CreatedBy.Name From Task t where t.Owner.id =: UserInfo.getUserId()   and t.IsClosed = false  and lastmodifieddate >=: timeLowerBound  and lastmodifieddate <: timeUpperBound and activitydate >=: columnDateLowerBound  and activitydate <=: columnDateUpperBound  and activitydate != null order by lastmodifieddate  DESC ];
            if(approvalCheckboxSelected)
            socialInputMap           = new Map<id,Social_Input__c>([Select id,lastmodifieddate, Accountable__c,Responsible__c,Consulted__c,Informed__c,Backup_for_Accountable__c,Veto_Rights__c, Role__c,Decision__r.Nearest_Due_Date__c,Decision__r.Due_Date__c,Decision__r.Title__c,Decision__r.Decision_Taken__c ,Decision__r.lastmodifieddate,Decision__r.status__c,Decision__r.Problem_Idea_Advice__c ,Final_Approval_Status__c , Decision__c , User__r.Name, User__r.department,Stance_Approval_Status__c, User__c, Role_Acceptance_Status__c  from Social_Input__c where User__c =: UserInfo.getUserId()  and  Decision__c != null   order by Decision__r.lastmodifieddate DESC  ]);
        }   
        else
        // Queries to be executed for  No deadline
        if( columnLowerBound == 0 && columnUpperBound == 0 ){
            if(decisionCheckboxSelected)
            mySocialInputList        = [select id,lastmodifieddate, Decision__c,Decision__r.lastmodifieddate, Decision__r.Title__c,Decision__r.Problem_Idea_Advice__c,Decision__r.Decision_Taken__c, Decision__r.OwnerId, Decision__r.Phase__c,Role__c,Decision__r.Nearest_Due_Date__c from Social_Input__c where User__c =: UserInfo.getUserId() and (Accountable__c = true or Backup_for_Accountable__c = true or Responsible__c = true) and  Decision__c != null and Decision__r.phase__c != 'Close' and Decision__r.lastmodifieddate >=: timeLowerBound and Decision__r.lastmodifieddate <: timeUpperBound  and Decision__r.Nearest_Due_Date__c =: null  order by lastmodifieddate  DESC  ];
            if(planCheckboxSelected)            
            myUrgentPlanList         = [select id,lastmodifieddate,Plan__r.OwnerId, Plan__c,Plan__r.Name,Plan__r.lastmodifieddate,Plan__r.location__c, Plan__r.Description__c,Plan__r.Start_Time__c,Plan__r.End_Time__c from Social_Input__c where User__c =: UserInfo.getUserId() and (Accountable__c = true or Backup_for_Accountable__c = true or Responsible__c = true) and Plan__c != null and  Plan__r.Start_Time__c = null and Plan__r.lastmodifieddate <: timeUpperBound and Plan__r.lastmodifieddate >=: timeLowerBound     order by Plan__r.End_Time__c DESC ];
            if(taskCheckboxSelected)            
            importantTaskList        = [Select t.Id,t.lastmodifieddate,t.Description , t.ActivityDate ,t.What.Name, t.Who.Name, t.WhoId, t.WhatId, t.Subject, t.Status, t.Priority,t.ownerId,t.Owner.Name , t.CreatedById,t.CreatedBy.Name From Task t where t.Owner.id =: UserInfo.getUserId()   and t.IsClosed = false  and lastmodifieddate >=: timeLowerBound  and lastmodifieddate <: timeUpperBound and activitydate = null  order by lastmodifieddate   ]; 
            if(approvalCheckboxSelected)
            socialInputMap           = new Map<id,Social_Input__c>([Select id,lastmodifieddate, Accountable__c,Responsible__c,Consulted__c,Informed__c,Backup_for_Accountable__c,Veto_Rights__c, Role__c,Decision__r.Nearest_Due_Date__c,Decision__r.Due_Date__c,Decision__r.Title__c,Decision__r.Decision_Taken__c ,Decision__r.lastmodifieddate,Decision__r.status__c,Decision__r.Problem_Idea_Advice__c ,Final_Approval_Status__c , Decision__c , User__r.Name, User__r.department,Stance_Approval_Status__c, User__c, Role_Acceptance_Status__c  from Social_Input__c where User__c =: UserInfo.getUserId()  and  Decision__c != null and   Decision__r.lastmodifieddate >=: timeLowerBound and Decision__r.lastmodifieddate <: timeUpperBound   order by lastmodifieddate DESC ]);
        }       
        set<id> decisionIds = new set<id>();   
          
       // Integer.valueOf( myUrgentPlanList.size()+'xxx');
        Date today   = Date.today();
        Date week1   = Date.today().addDays(7);
        Date week2   = Date.today().addDays(14);
        Date month1  = Date.today().addDays(30);
        Date lessweek1   = Date.today().addDays(-7);
        Date lessweek2   = Date.today().addDays(-14);
        Date lessmonth1  = Date.today().addDays(-30);
        
        //Map to convert phase to specific values
        map<string,string> phaseStringMap = new map<string,string>();
        phaseStringMap.put('Draft','1.Draft');
        phaseStringMap.put('Share','2.Share');
        phaseStringMap.put('Propose','3a.Propose');  
        phaseStringMap.put('Decide','3b.Decide');
        phaseStringMap.put('Execute','4.Execute');
        phaseStringMap.put('Evaluate','5.Evaluate'); 
        phaseStringMap.put('Close','6.Close');
        
        // Map to convert pulse status to integer
        map<string,Integer> pulseStatusMap = new map<string,Integer>();
        pulseStatusMap.put('Not Given',0);
        pulseStatusMap.put('Good',1);
        pulseStatusMap.put('Minor Challenges',2);
        pulseStatusMap.put('Critical',3);
        pulseStatusMap.put('Completed',4);
        pulseStatusMap.put('Completed with Problems',5);
        // Map to set color for each  status    
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
        // Map to convert  stance to colors
        map<string,string> stanceColorMap = new map<string,string>();
        stanceColorMap.put('Supported','23a554');
        stanceColorMap.put('Opposed','e81b05');
        stanceColorMap.put('Pending','ff7800');
        stanceColorMap.put('Not Given','ff6600');
        stanceColorMap.put('N/A','ffba00');
        // Map to convert role to colors
        map<string,string> roleColorMap = new map<string,string>();
        roleColorMap.put('Approved/Accepted','#373737');
        roleColorMap.put('Not Accepted','#c00000');
        roleColorMap.put('Pending Approval','#ff6600');
        roleColorMap.put('','#d9d9d9');
        
        // Map to return modd image position for each mood value
        map<Integer,String> moodImagePositionMap = new Map<Integer,String>();
        moodImagePositionMap.put(0,'0px -186px');
        moodImagePositionMap.put(1,'0px -106px');
        moodImagePositionMap.put(2,'0px -122px');
        moodImagePositionMap.put(3,'0px -138px');
        moodImagePositionMap.put(4,'0px -154px');
        moodImagePositionMap.put(5,'0px -170px');
        
        //'Not Given','Very Worried','Worried','Neutral','Happy','Very Happy'
        //Map to convert mood to text 
        map<Integer,String> moodStatusMap = new map<Integer,String>();
        moodStatusMap.put(0,'Not Given');
        moodStatusMap.put(1,'Very Worried');
        moodStatusMap.put(2,'Worried');
        moodStatusMap.put(3,'Neutral');
        moodStatusMap.put(4,'Happy');
        moodStatusMap.put(5,'Very Happy');
        
        date todayDate = Date.today(); 
        date lastWeekDate;
        
        Set<Id> decsionIds = new set<Id>();
        Set<Id> decisionIdFromSocial = new set<Id>();
        Set<Id> planIdFromSocial = new set<Id>();
        
        
       
        
        
        // Issues
        map<Id, Social_Input__c> myRoleForDecision = new map<Id, Social_Input__c>();
        map<Id,List<Task>> taskMap          = new map<Id,List<Task>>();
        map<Id,List<Task>> taskMapOverdue   = new map<Id,List<Task>>();
        map<Id,List<Event>> eventMap         = new map<Id,List<Event>>();
        map<Id,List<Event>> eventMapOverdue  = new map<Id,List<Event>>();
        
        
        List<importantWrapper> listw = new List<importantWrapper>();
        // Process all decision cards
        if( decisionCheckboxSelected )
        {       // get the decision list 
                for(Social_Input__c s: mySocialInputList){
                    decisionIdFromSocial.add(s.decision__c);    
                }
                List<Decision__c>  decisionList = [SELECT Id,Progress__c,lastmodifieddate,Name,Title__c, Status__c, phase__c,Nearest_Due_Date__c,Due_Date__c ,Priority__c,owner.id FROM Decision__c  WHERE ID IN:decisionIdFromSocial ];
                set<Id> decId = new set<Id>();
                map<Id, Social__c> smsMap = new map<Id, Social__c>();
                if(decisionList.size() > 0){
                    for(Decision__c d: decisionList) {
                        decId.add(d.Id);
                    }
                }
                // create a wrapper list of all the values of decision along with social values
                List <importantWrapper> importantWrapperList   = new List <importantWrapper>();
            
                if(decId.size() > 0){
                
                }
            
                // Task
                Datetime todayDT = Datetime.now();  
                for(Task ts: [select id, WhatId from Task where WhatId In: decId AND ActivityDate <: todayDate and isClosed = false]) {
                  List<Task> taskList = taskMap.get(ts.WhatId);
                  if(taskList == null) {
                    taskList = new List<Task>();
                    taskMap.put(ts.WhatId, taskList);
                  taskList.add(ts);
                  } 
               } 
                // my role in the decision 
                List<Social_Input__c> raciListForTargetObjet = [select Id, Role_Acceptance_status__c,Final_Approval_Status__c, Role__c, Veto_Rights__c, Stance_Approval_Status__c,Consulted__c, Responsible__c, Informed__c, Backup_for_Accountable__c, Accountable__c , Decision__c from Social_Input__c where Decision__c In:decId and User__c =: UserInfo.getUserId()];
                for(Social_Input__c d: raciListForTargetObjet ) {
                    myRoleForDecision.put(d.Decision__c, d);
                }
                 
                // my input values for mood and rating
                List<Social__c> smsList  = [select Total_Issues__c,Total_Likes__c,Total_Dislikes__c, Avg_Mood__c, Avg_Rating__c,Related_To_ID__c   From Social__c where Related_To_ID__c In :decId];
                for(Social__c s:  smsList) {
                    smsMap.put(s.Related_To_ID__c, s); 
                }
                
                ProcessInstanceList = [Select  p.ProcessInstance.Status, p.ProcessInstance.TargetObjectId, p.ProcessInstanceId, p.Id, p.CreatedDate, p.CreatedBy.Name, p.CreatedById, p.Actor.Name, p.ActorId From ProcessInstanceWorkitem p where  p.ActorId =: Userinfo.getUserId() AND p.ProcessInstance.TargetObjectId IN: socialInputMap.keyset() order by p.CreatedDate desc ];
                map<Id,Id> mapSocailInputApprovals = new map<Id,Id>();
                for(ProcessInstanceWorkitem piwi : ProcessInstanceList){
                	mapSocailInputApprovals.put(piwi.ProcessInstance.TargetObjectId,piwi.Id);
                } 
            if(decisionList.size() > 0){  
                for(Decision__c d: decisionList) {
                    decisionIds.add(d.id);
                    importantWrapper dvw = new importantWrapper ();
                    dvw.decisionId = string.ValueOf(d.Id);
                    dvw.cardType   = 'Decision';
                    Datetime decisionDueDate  ;
                    if(d.Nearest_Due_Date__c != null )
                    {
                         decisionDueDate = d.Nearest_Due_Date__c;
                    }
                    dvw.decisionName = d.Title__c.unescapeHtml4();
                    System.debug('=============='+dvw.decisionName );
                    
                    dvw.phases = phaseStringMap.get( d.phase__c);
                    dvw.status = d.status__c;
                    dvw.statusColor = statusColorMap.get(dvw.status);                   
                    if(myRoleForDecision.get(d.Id) != null) {
                        if(myRoleForDecision.get(d.Id).Stance_Approval_Status__c != null)
                        {   
                             dvw.stanceApprovalStatus = myRoleForDecision.get(d.Id).Stance_Approval_Status__c == 'Pending Approval' ? 'Pending': (  myRoleForDecision.get(d.Id).Stance_Approval_Status__c == 'Approved' ? 'Supported': (  myRoleForDecision.get(d.Id).Stance_Approval_Status__c == 'Rejected' ? 'Opposed': 'N/A'  ) ) ;
                        }
                        else
                            dvw.stanceApprovalStatus = 'N/A'; 
                                  
                      
                    }
                    dvw.stanceApprovalStatusColor = stanceColorMap.get(dvw.stanceApprovalStatus); 
                    dvw.pulseStatusInt = pulsestatusmap.get(d.Progress__c);
                    dvw.priority = d.priority__c;
                    Social__c  sms = smsMap.get(d.Id);
                 
                    dvw.AverageRating = string.valueOf(sms.Avg_Rating__c);
                    dvw.moodImage = genralInfo.imageUrlMap.get('newModdImage');  
                    dvw.moodImagePosition = moodImagePositionMap.get(math.round(Double.valueOf(sms.Avg_Mood__c)));
                    dvw.moodNumber = string.valueOf(math.round(Double.valueOf(sms.Avg_Mood__c)));
                    dvw.moodStatus = moodStatusMap.get(math.round(Double.valueOf(sms.Avg_Mood__c)));
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
                    //set role for each decision
                    dvw.Accountable = myRoleForDecision.get(d.Id) != null ? myRoleForDecision.get(d.Id).Accountable__c : false;
                    dvw.Responsible = myRoleForDecision.get(d.Id) != null ? myRoleForDecision.get(d.Id).Responsible__c : false;
                    dvw.Consulted = myRoleForDecision.get(d.Id) != null ? myRoleForDecision.get(d.Id).Consulted__c : false;
                    dvw.Informed = myRoleForDecision.get(d.Id) != null ? myRoleForDecision.get(d.Id).Informed__c : false;
                    dvw.Backup = myRoleForDecision.get(d.Id) != null ? myRoleForDecision.get(d.Id).Backup_for_Accountable__c : false;
                    dvw.Veto = myRoleForDecision.get(d.Id) != null ? myRoleForDecision.get(d.Id).Veto_Rights__c : false;
                    dvw.role = myRoleForDecision.get(d.Id) != null ? myRoleForDecision.get(d.Id).Role__c : '';
                    //Set  colore for each role
                    dvw.AccountableRoleColor = myRoleForDecision.get(d.Id) != null && myRoleForDecision.get(d.Id).Accountable__c  ?  roleColorMap.get( myRoleForDecision.get(d.Id).Role_Acceptance_status__c ) : '#d9d9d9';
                    dvw.ResponsibleRoleColor = myRoleForDecision.get(d.Id) != null && myRoleForDecision.get(d.Id).Responsible__c  ?  roleColorMap.get( myRoleForDecision.get(d.Id).Role_Acceptance_status__c ) : '#d9d9d9';
                    dvw.ConsultedRoleColor = myRoleForDecision.get(d.Id) != null && myRoleForDecision.get(d.Id).Consulted__c  ?  roleColorMap.get( myRoleForDecision.get(d.Id).Role_Acceptance_status__c ) : '#d9d9d9';
                    dvw.InformedRoleColor = myRoleForDecision.get(d.Id) != null && myRoleForDecision.get(d.Id).Informed__c  ?  roleColorMap.get( myRoleForDecision.get(d.Id).Role_Acceptance_status__c ) : '#d9d9d9';
                    dvw.BackupRoleColor = myRoleForDecision.get(d.Id) != null && myRoleForDecision.get(d.Id).Backup_for_Accountable__c  ?  roleColorMap.get( myRoleForDecision.get(d.Id).Role_Acceptance_status__c ) : '#d9d9d9';
                    dvw.VetoRoleColor = myRoleForDecision.get(d.Id) != null && myRoleForDecision.get(d.Id).Veto_Rights__c  ?  roleColorMap.get( myRoleForDecision.get(d.Id).Role_Acceptance_status__c ) : '#d9d9d9';
                   
                    dvw.roleApprovalStatus =   myRoleForDecision.get(d.Id) != null ? myRoleForDecision.get(d.Id).Role_Acceptance_status__c: 'N/A';
                    dvw.showOvelay = false;
                    if(myRoleForDecision.get(d.Id) != null){
	                    dvw.showOvelay = myRoleForDecision.get(d.Id).Stance_Approval_Status__c == 'Pending Approval' || myRoleForDecision.get(d.Id).Role_Acceptance_Status__c == 'Pending Approval' || myRoleForDecision.get(d.Id).Final_Approval_Status__c == 'Pending Approval' ? true : false;
	                    dvw.showApprovalOvelay = myRoleForDecision.get(d.Id).Stance_Approval_Status__c == 'Pending Approval' ? 'Stance' : myRoleForDecision.get(d.Id).Role_Acceptance_Status__c == 'Pending Approval' ? 'role' : myRoleForDecision.get(d.Id).Final_Approval_Status__c == 'Pending Approval' ? 'Final' : '';
                    }
                    if(dvw.showOvelay){	
                    	dvw.approvalProcessId = mapSocailInputApprovals.get(myRoleForDecision.get(d.Id).Id);
                    }
                    dvw.relevenceImage= genralInfo.imageUrlMap.get(avgRatingValue);   
                    dvw.OwnerName = genralInfo.useNameMap.get(d.OwnerId).Name;
                    dvw.ownerDept = genralInfo.useNameMap.get(d.OwnerId).Department;
                    dvw.ownerPhoto = genralInfo.useNameMap.get(d.OwnerId).SmallPhotoUrl;      
                    
                    dvw.pendingTaskCount = taskMap.get(d.Id) != null ? taskMap.get(d.Id).size() : 0 ;
                    dvw.TotalLikes = sms.Total_Likes__c != null ? string.valueOf(sms.Total_Likes__c) : '0';
                    dvw.TotalDislikes = sms.Total_Dislikes__c != null ? string.valueOf(sms.Total_Dislikes__c) : '0';
                    dvw.duedateSorter  = d.lastmodifieddate;  
                    dvw.lastmodifiedTime = d.lastmodifieddate.getTime();
                    if(d.Nearest_Due_Date__c != null){
                         
                        dvw.deadlineState = (   d.Nearest_Due_Date__c.gettime() - System.now().gettime() )>= 0 ? 'Positive' : 'Negative';
                        dvw.deadlineNum = genralInfo.MapValuesDate(String.valueOf(d.Nearest_Due_Date__c.day()), String.valueOf(d.Nearest_Due_Date__c.month()), String.valueOf(d.Nearest_Due_Date__c.year()));  
                    }
                    else    
                    {
                       dvw.deadlineNum = 'N/A';
                       dvw.deadlineState =  'Positive' ;
                    }
                    listw.add(dvw);     
                 }
            }
        }
         // Process all task cards
        if( taskCheckboxSelected )
        {   
                
                // Begin Task section 
                Id userId = userinfo.getUserId(); 
              
                // Creating two decision list of ids which will store 200 ids each in the lists.
                List<Id> taskIds = new List<Id>();
                //set<Id> taskWhatIds = new set<Id>();
                for(Task t : importantTaskList){
                    taskIds.add(t.Id);
                    //taskWhatIds.add(t.whatId);
                }
                
                // Query on user access records to get the record access for the logged in user. fetching based on above two task Ids list.
                List<Id> taskList1 =  new List<Id>();
                List<Id> taskList2 =  new List<Id>();
                if(taskIds.size() > 200){
                    for(Integer i=0;i<199;i++){
                        taskList1.add(taskIds[i]);
                    }
                    for(Integer j=200;j<taskIds.size();j++){
                        taskList2.add(taskIds[j]);
                    }
                }else{
                    taskList1.addAll(taskIds);
                }
                
                // Query on user access records to get the record access for the logged in user. fetching based on above two task Ids list.
                List<UserRecordAccess> lstUserAccessRecords = [SELECT RecordId,HasAllAccess,HasDeleteAccess,HasEditAccess,HasTransferAccess,HasReadAccess FROM UserRecordAccess WHERE UserId =: userinfo.getUserId() AND RecordId IN : taskList1 limit 200];
                Map<Id,Boolean> trackAccess = new Map<Id,Boolean>();
                Map<Id,Boolean> readAccess = new Map<Id,Boolean>();
                for(UserRecordAccess l : lstUserAccessRecords){
                    if(trackAccess.get(l.RecordId) == null){
                        trackAccess.put(l.recordId,l.HasEditAccess);
                        readAccess.put(l.recordId,l.HasReadAccess);
                    }   
                }
                if(taskList2.size() > 0){
                    List<UserRecordAccess> lstUserAccessRecords1 = [SELECT RecordId,HasAllAccess,HasDeleteAccess,HasEditAccess,HasTransferAccess,HasReadAccess FROM UserRecordAccess WHERE UserId =: userinfo.getUserId() AND RecordId IN : taskList2 limit 200];   
                    for(UserRecordAccess l : lstUserAccessRecords1){
                        if(trackAccess.get(l.RecordId) == null){
                            trackAccess.put(l.recordId,l.HasEditAccess);
                            readAccess.put(l.recordId,l.HasReadAccess);
                        }   
                    } 
                } 
                
                Map<string,integer> statusCountMap  = new Map<string,integer>();    
                 for(Task t: importantTaskList){
                    if(readAccess != null && t != null && t.Id != null && readAccess.get(t.Id) != null && readAccess.get(t.Id)){
                        /*kanBanTaskWrapper k = new kanBanTaskWrapper();
                        k.kanbanTask = t;
                        k.userImg = genInfo.useNameMap.get(t.OwnerId).SmallPhotoUrl;
                        k.priorityImage = genInfo.imageUrlMap.get(t.Priority);
                        k.recordAccess = trackAccess.get(t.id);
                        kanBanTaskWrapperList.add(k);*/
                        if( statusCountMap.get(t.status) == null )
                         statusCountMap.put(t.status,1);
                        else
                         statusCountMap.put(   t.status,  statusCountMap.get(t.status) +  1);
                        importantWrapper k = new importantWrapper();
                        k.cardId = t.id; 
                        k.kanbanTask = t;  
                        k.taskId     = t.id;
                        k.cardType   = 'Task';
                        k.status     = t.status; 
                        k.activitydate  =    t.activitydate != null ? String.valueOf( t.activitydate.format()):'N/A';
                        k.priority = t.priority;
                        k.taskSubject = t.Subject == null ? '' : t.Subject.length() > 80 ? t.Subject.substring(0,77)+'...' : t.Subject;
                        k.userImg = genralInfo.useNameMap.get(t.OwnerId).SmallPhotoUrl;
                        k.priorityImage = genralInfo.imageUrlMap.get(t.Priority);
                        k.duedateSorter  = t.lastmodifieddate;
                        k.lastmodifiedTime = t.lastmodifieddate.getTime();
                        millisecondGmt = millisecondGmt >  t.lastmodifieddate.getTime() ?  t.lastmodifieddate.getTime() : millisecondGmt;    
                        if(t.ActivityDate != null){
                            Integer dateLeft = System.today().daysBetween(t.ActivityDate);
                            k.deadlineState = dateLeft >= 0 ? 'Positive' : 'Negative';
                            k.deadlineNum = k.deadlineState == 'Positive' ? string.valueOf(dateLeft) : string.valueOf(dateLeft).substring(1,string.valueOf(dateLeft).length());  
                        }  
                        else
                        {
                            
                          k.deadlineState = 'Positive';
                          
                        }
                        k.relatedTo = t.What.Name != null ?  t.What.Name : t.Who.Name != null ? t.Who.Name : ' '; 
                        k.relatedToId = t.WhatId != null ?  t.WhatId : t.WhoId != null ? t.WhoId : null;
                        k.comments = t.Description == null ? '' : t.Description.length() > 80 ? t.Description.substring(0,77)+'...' : t.Description;
                        /*   task owner assigned by*/
                        k.userAssigneeName = t.Owner.Name ;
                        k.userAssignImgUrl = genralInfo.useImage.get(t.OwnerId) ;
                        k.userAssigneeDept = genralInfo.useNameMap.get(t.OwnerId).Department ;
                        /* task created by assigned to*/
                        k.userAssignedName = genralInfo.useNameMap.get(t.CreatedById).Name ;
                        k.userAssignedImgUrl = genralInfo.useImage.get(t.CreatedById) ;
                        k.userAssignedDept = genralInfo.useNameMap.get(t.CreatedById).Department ;
                        k.recordAccess = trackAccess.get(t.Id);
                        k.lockImg = k.recordAccess == true ? genralInfo.imageUrlMap.get('') : genralInfo.imageUrlMap.get('lock');
                        listw.add(k);
                       
                    }    
                }
        }
        
        //Process all plan cards
        if(  planCheckboxSelected )   
        {
                Set<Id> planSet = new set<Id>();   
                for( Social_Input__c sin : myUrgentPlanList ){
                    planSet.add(sin.plan__c);  
                }  
                Map<id,Integer> relationsMapCount  = new Map<id,Integer>();
                Map<id,Relations__c> relationsMap  =  new Map<id,Relations__c>([Select id , Parent_ID__c from Relations__c where Parent_ID__c in : planSet and Type__c = 'Item'  ]);
                Map<id,Social_Input__c> planAccountables     =  new Map<id,Social_Input__c> ([select id, User__r.Name, User__r.Department from Social_Input__c where  ( Accountable__c = true or Responsible__c = true )  and Plan__r.id  in :  planIdFromSocial ]);
                List<User> lstUser = [select id,Name,Department from User where isActive = true];
                Map<Id,User> mapUser = new Map<Id,User>();
                for(User u : lstUser){
                    mapUser.put(u.Id,u);
                }
                for( Relations__c rel : relationsMap.values() ){
                     if( relationsMapCount.get(rel.Parent_ID__c) == null )
                     relationsMapCount.put(rel.Parent_ID__c,1);
                     else
                     relationsMapCount.put(rel.Parent_ID__c,relationsMapCount.get(rel.Parent_ID__c)+1);
                }
                
                for(Task ts: [select id, WhatId from Task where WhatId In: planSet AND ActivityDate <: todayDate  and status !=: 'Completed' and status !=: 'Rejected' ]) {
                      
                      List<Task> taskList = taskMapOverdue.get(ts.WhatId);
                      if(taskList == null) {
                        taskList = new List<Task>();
                        taskMapOverdue.put(ts.WhatId, taskList);
                      }
                      taskList.add(ts);
                }
                 
                for(Task ts: [select id, WhatId from Task where WhatId In: planSet AND ( ( ActivityDate >=: todayDate ) or (  ( ActivityDate <: todayDate ) and (  ( status =: 'Completed' ) or ( status =: 'Rejected' ) )  ) )  ]) {
                        
                      List<Task> taskList = taskMap.get(ts.WhatId);
                      if(taskList == null) {
                        taskList = new List<Task>();
                        taskMap.put(ts.WhatId, taskList);
                      }
                      taskList.add(ts);
                }
                
                for(Event ts: [select id, WhatId from Event where WhatId In: planSet AND ActivityDate <: todayDate  ]) {
                      
                      List<Event> eventList = eventMapOverdue.get(ts.WhatId);
                      if(eventList == null) {
                        eventList = new List<Event>();
                        eventMapOverdue.put(ts.WhatId, eventList);
                      }
                      eventList.add(ts);
                }
                
                for(Event ts: [select id, WhatId from Event where WhatId In: planSet AND ActivityDate >=: todayDate ]) {
                      
                      List<Event> eventList = eventMap.get(ts.WhatId);
                      if(eventList == null) {
                        eventList = new List<Event>();
                        eventMap.put(ts.WhatId, eventList);
                      }
                      eventList.add(ts);
                }
                
                for( Social_Input__c plan : myUrgentPlanList ){
                    if(plan.Plan__r.Name != null){
                        importantWrapper pw = new importantWrapper();
                       // pw.priority  =  plan.Plan__r.Priority__c; 
                        pw.cardType     =  'Plan'; 
                        pw.cardId       =  plan.Plan__r.id;
                        pw.modifieddate  = plan.Plan__r.lastmodifieddate != null ? String.valueOf(plan.Plan__r.lastmodifieddate.format(dateFormatStatic)):'';
                        pw.startdate     = plan.Plan__r.Start_Time__c != null ? String.valueOf(plan.Plan__r.Start_Time__c.format(dateFormatStatic)):'N/A';
                        pw.enddate       = plan.Plan__r.End_Time__c != null ? String.valueOf(plan.Plan__r.End_Time__c.format(dateFormatStatic)):'N/A';
                        pw.cardTitle     = plan.Plan__r.Name;
                        if( pw.cardTitle != null){
                            pw.cardTitle      = pw.cardTitle.length() > 80 ? pw.cardTitle.substring(0,77)+'...' :pw.cardTitle.substring(0,pw.cardTitle.length() )  ;
                        }
                        pw.location      = plan.Plan__r.location__c;  
                        if( pw.location != null){
                            pw.location      = pw.location.length() > 80 ? pw.location.substring(0,77)+'...' :pw.location.substring(0,pw.location.length() )  ;
                        }
                        pw.itemCount     = relationsMapCount != null && relationsMapCount.get(plan.Plan__r.id) != null ? relationsMapCount.get(plan.plan__r.id) : 0;
                        pw.description   = plan.Plan__r.Description__c;  
                        if( pw.description != null){
                            pw.description      = pw.description.length() > 80 ? pw.description.substring(0,77)+'...' :pw.description.substring(0,pw.description.length() )  ;
                        }
                        pw.duedateSorter  = plan.Plan__r.lastmodifieddate;
                        pw.lastmodifiedTime = plan.Plan__r.lastmodifieddate.getTime();
                        pw.itemCount     = relationsMapCount.get(plan.Plan__r.id) != null?relationsMapCount.get(plan.Plan__r.id):0 ;
                        pw.accountableName = planAccountables != null && planAccountables.get(plan.id) != null ? planAccountables.get(plan.id).User__r.Name : '';
                        pw.accountableDept = planAccountables != null && planAccountables.get(plan.id) != null ? planAccountables.get(plan.id).User__r.Department : '';
                        pw.accountableImage = planAccountables != null && planAccountables.get(plan.id) != null ? genralInfo.useImage.get(planAccountables.get(plan.id).User__r.id) : '';
                        
                        pw.accountableName = mapUser != null && mapUser.get(plan.Plan__r.OwnerId) != null ? mapUser.get(plan.Plan__r.OwnerId).Name : '';
                        pw.accountableDept = mapUser != null && mapUser.get(plan.Plan__r.OwnerId) != null ? mapUser.get(plan.Plan__r.OwnerId).Department : '';
                        pw.accountableImage = plan.Plan__r.OwnerId != null ? genralInfo.useImage.get(plan.Plan__r.OwnerId) : '';
                        
                        integer nodueTask   =  taskMap.get(plan.Plan__r.id) != null ? taskMap.get(plan.Plan__r.id).size():0;
                        integer nodueEvent  =  eventMap.get(plan.Plan__r.id) != null ? eventMap.get(plan.Plan__r.id).size():0;
                        integer dueTask     =  taskMapOverdue.get(plan.Plan__r.id) != null ? taskMapOverdue.get(plan.Plan__r.id).size():0;
                        integer dueEvent    =  eventMapOverdue.get(plan.Plan__r.id) != null ? eventMapOverdue.get(plan.Plan__r.id).size():0;
                        pw.dueCount         =  dueTask + dueEvent;  
                        pw.activityCount =   string.valueOf( nodueTask + nodueEvent ) + '/'+ string.valueOf( dueTask + dueEvent+ nodueTask + nodueEvent ) ;
                            Date planenddate = null;  
                            Date planStartDate = null;
                            if(plan.Plan__r.End_Time__c != null ) 
                            {
                                DateTime Dt = plan.Plan__r.End_Time__c;
                                planenddate = Date.newInstance(Dt.year(),Dt.Month(),Dt.day());
                            }
                            if(plan.Plan__r.Start_Time__c != null){
                                DateTime Dt = plan.Plan__r.Start_Time__c;
                                planStartDate = Date.newInstance(Dt.year(),Dt.Month(),Dt.day());
                            }
                            if( planenddate != null ){
                                 Integer dateLeft = System.today().daysBetween(planenddate);
                                 pw.deadlineState = dateLeft >= 0 ? 'Positive' : 'Negative';
                            }
                            else
                            {  
                                 pw.deadlineState =   'Positive';
                            } 
                            listw.add(pw);
                               
                     }  
                }
         }
         //************************** Plan Sectison ends  here ************************//
        
        //*************************** Approval Section *******************************//
        if( approvalCheckboxSelected )
        {
            ProcessInstanceList = [Select  p.ProcessInstance.Status, p.ProcessInstance.TargetObjectId, p.ProcessInstanceId, p.Id, p.CreatedDate, p.CreatedBy.Name, p.CreatedById, p.Actor.Name, p.ActorId From ProcessInstanceWorkitem p where  p.ActorId =: Userinfo.getUserId() AND p.ProcessInstance.TargetObjectId IN: socialInputMap.keyset() order by p.CreatedDate desc ]  ;
            for(Social_Input__c socialInput :socialInputMap.values() ){
              decsionIds.add( socialInput.Decision__c  ); 
            }
            Map<id,Decision__c> DecisionMap = new Map<id,Decision__c>([Select id ,LastModifiedDate ,Title__c,Accountable__c,Priority__c,OwnerId from Decision__c where id in: decsionIds ]);
            Map<id,Decision__c> socialToDecisionMap = new Map<id,Decision__c>();
            for(social_Input__C  sc: socialInputMap.values())
            {
                socialToDecisionMap.put(Sc.id, DecisionMap.get( sc.Decision__c)); 
            }  
            Map<id,Timing__c> timingMap = new Map<id,Timing__c>([Select id ,Related_To_ID__c ,End_Date_Time__c,Actual_End_Date__c from Timing__c where Stage__c=:'Propose' and Related_To_ID__c in :decsionIds  order by End_Date_Time__c ]);
            Map<id,Timing__c> decisiontoTimingMap =  new Map<id,Timing__c>();
            for( Timing__c t: timingMap.values() ){
             decisiontoTimingMap.put(t.Related_To_ID__c ,t) ;
            }
            for(ProcessInstanceWorkitem piw : ProcessInstanceList ) {
               Social_Input__c loggedInSocialPeople = socialInputMap.get(piw.ProcessInstance.TargetObjectId);
                if(loggedInSocialPeople.Decision__r != null){
	               if(loggedInSocialPeople.Final_Approval_Status__c != null || loggedInSocialPeople.Role_Acceptance_Status__c != null || loggedInSocialPeople.Stance_Approval_Status__c != null){
	                    importantWrapper  aw = new importantWrapper();
	                    aw.cardType          = 'Approval';
	                    aw.id                = piw.Id;
	                    aw.title             = loggedInSocialPeople.Decision__r.Title__c ;
	                    
	                    if( loggedInSocialPeople.Decision__r.Decision_Taken__c != null){
	                        aw.decisionName      = loggedInSocialPeople.Decision__r.Decision_Taken__c.replaceAll('<[^>]+>',' ');
	                        aw.decisionNameFull  = aw.decisionName;
	                        aw.decisionName      = aw.decisionName.length() > 80 ? aw.decisionName.substring(0,77)+'...' :aw.decisionName.substring(0,aw.decisionName.length() )  ;
	                    }
	                     
	                    if( loggedInSocialPeople.Decision__r.Problem_Idea_Advice__c != null){
	                       aw.problemStatement      = loggedInSocialPeople.Decision__r.Problem_Idea_Advice__c.replaceAll('<[^>]+>',' ');
	                       aw.problemStatementFull  = aw.problemStatement;
	                       aw.problemStatement      = aw.problemStatement.length() > 80 ? aw.problemStatement.substring(0,77)+'...' :aw.problemStatement.substring(0,aw.problemStatement.length() )  ;
	
	                    } 
	                    
	                    aw.duedateSorter     = loggedInSocialPeople.Decision__r.lastmodifieddate;
	                    aw.lastmodifiedTime = loggedInSocialPeople.Decision__r.lastmodifieddate.getTime();
	                    Datetime decisionDueDate  ;
	                    if(decisiontoTimingMap.get( loggedInSocialPeople.Decision__c).End_Date_Time__c != null||decisiontoTimingMap.get( loggedInSocialPeople.Decision__c).Actual_End_Date__c  != null )
	                    {
	                         Datetime duedate =  decisiontoTimingMap.get( loggedInSocialPeople.Decision__r.id).End_Date_Time__c != null? decisiontoTimingMap.get( loggedInSocialPeople.Decision__r.id).End_Date_Time__c: decisiontoTimingMap.get( loggedInSocialPeople.Decision__r.id).Actual_End_Date__c;
	                         decisionDueDate = duedate ;
	                    }
	                    if( decisionDueDate != null ){
	                            
	                             aw.deadlineState = (  decisionDueDate.gettime() - System.now().gettime() )>= 0 ? 'Positive' : 'Negative';
	                    }
	                    else
	                    {
	                              aw.deadlineState = 'Positive';
	                    }
	                    aw.duedate           = decisionDueDate != null ? String.valueOf(decisionDueDate.format(dateFormatStatic)):'N/A'; //.format(dateTimeFormat);
	                    aw.requestedPhoto    = DecisionMap.get(loggedInSocialPeople.Decision__c).ownerId  != null ? genralInfo.useImage.get(DecisionMap.get(loggedInSocialPeople.Decision__c).ownerId ) : '/'+ genralInfo.imageUrlMap.get('group');
	                    aw.typeOfApproval    = loggedInSocialPeople.Role_Acceptance_Status__c == 'Pending Approval' ?  'Role' : (  loggedInSocialPeople.Stance_Approval_Status__c == 'Pending Approval' ? 'Stance': ( loggedInSocialPeople.Final_Approval_Status__c == 'Pending Approval' ) ? 'Decision': 'NONE' );
	                    aw.approvalStatus    = loggedInSocialPeople.Decision__r.status__c;
	                    aw.decisionId        = loggedInSocialPeople.Decision__c;
	                    aw.socialInputId     =  loggedInSocialPeople.id;
	                    aw.nameOfRequeste    =  DecisionMap.get(loggedInSocialPeople.Decision__c).ownerId  != null ? genralInfo.useNameMap.get( ( DecisionMap.get(loggedInSocialPeople.Decision__c).ownerId ) ).Name : '';
	                    aw.ownerDept         =  DecisionMap.get(loggedInSocialPeople.Decision__c).ownerId  != null ? genralInfo.useNameMap.get( ( DecisionMap.get(loggedInSocialPeople.Decision__c).ownerId ) ).Department : '';
	                    aw.priority          =  socialToDecisionMap.get(String.valueOf(piw.ProcessInstance.TargetObjectId)).Priority__c; 
	                    aw.subject           =  socialToDecisionMap.get(String.valueOf(piw.ProcessInstance.TargetObjectId)).Title__c;  
	                    aw.Accountable       =  loggedInSocialPeople.Accountable__c;    
	                    aw.Responsible       =  loggedInSocialPeople.Responsible__c; 
	                    aw.Consulted         =  loggedInSocialPeople.Consulted__c;    
	                    aw.Informed          =  loggedInSocialPeople.Informed__c;    
	                    aw.AccountableRoleColor =  loggedInSocialPeople.Accountable__c  ?  roleColorMap.get( loggedInSocialPeople.Role_Acceptance_status__c ) : '#d9d9d9';
	                    aw.ResponsibleRoleColor = loggedInSocialPeople.Responsible__c  ?  roleColorMap.get( loggedInSocialPeople.Role_Acceptance_status__c ) : '#d9d9d9';
	                    aw.ConsultedRoleColor =  loggedInSocialPeople.Consulted__c  ?  roleColorMap.get( loggedInSocialPeople.Role_Acceptance_status__c ) : '#d9d9d9';
	                    aw.InformedRoleColor =   loggedInSocialPeople.Informed__c  ?  roleColorMap.get( loggedInSocialPeople.Role_Acceptance_status__c ) : '#d9d9d9';
	                    aw.BackupRoleColor =    loggedInSocialPeople.Backup_for_Accountable__c  ?  roleColorMap.get( loggedInSocialPeople.Role_Acceptance_status__c ) : '#d9d9d9';
	                    aw.VetoRoleColor = loggedInSocialPeople.Veto_Rights__c  ?  roleColorMap.get( loggedInSocialPeople.Role_Acceptance_status__c ) : '#d9d9d9';
	                    aw.Backup            =  loggedInSocialPeople.Backup_for_Accountable__c;    
	                    aw.Veto              =  loggedInSocialPeople.Veto_Rights__c;    
	                    aw.role                = loggedInSocialPeople.Role__c;
	                    if( aw.duedateSorter >= timeLowerBound && aw.duedateSorter < timeUpperBound  ){
	                        if(   columnUpperBound - columnLowerBound  ==  86400000L ){
	                            if( decisionDueDate  == system.now() || ( ( decisionDueDate > system.now() && decisionDueDate <= system.now().adddays(1) ) ) )
	                            {
	                                 listw.add(aw); 
	                            } 
	                        } 
	                        else
	                        if( columnLowerBound == 0 && columnUpperBound != 0 ){
	                            if(   decisionDueDate < System.now()  )  
	                            {
	                                  listw.add(aw); 
	                            } 
	                        } 
	                        else
	                        if( columnLowerBound != 0 && columnUpperBound != 0 )
	                        {
	                            if( columnTimeLowerBound < decisionDueDate  && columnTimeUpperBound >= decisionDueDate  )
	                            {
	                                  listw.add(aw); 
	                            }   
	                        }       
	                        else  
	                        if( columnLowerBound == 0 && columnUpperBound == 0 ){
	                            if( decisionDueDate == null )
	                            {
	                                  listw.add(aw); 
	                            }
	                        }    
	                    }
	                   
	                     
	                }
            	}   
            }
        } 
       toDoWarapeer tw =  new toDoWarapeer();
       tw.done    =  '';
       if( searchAll == false && listw.size()<5 ){        
           
            toDoWarapeer  toDoWarap =  (toDoWarapeer)Json.deserialize( HomePage.viewImportantColumnCards(true,cardTypes,timeLowerBound.getTime(),columnUpperBound,columnLowerBound), toDoWarapeer.class);
            listw.addAll( toDoWarap.importantWrapperList ); 
            tw.done    =  'done'; 
       }
      /// listw.sort();  
       tw.importantWrapperList = listw;
       tw.columnTimeLowerBound = String.valueOf(columnLowerBound);
       tw.columnTimeUpperBound =  String.valueOf(columnUpperBound); 
       tw.dataSetUpperBound    =  String.valueOf(timeLowerBound.getTime());
       if( tw.importantWrapperList.size() == 0 )
       tw.done    =  'done';
       if( columnUpperBound > 0 && columnLowerBound  ==  0 ){
            tw.columnId  =  '0';
        }
        else
        if( columnUpperBound - columnLowerBound  == 86400000L){
            tw.columnId  =  '1';
        }        
        else
        if( columnUpperBound - columnLowerBound  == 518400000L){
            tw.columnId  =  '2';
        }   
        else
        if( columnUpperBound    == 32503660200000L ){
            tw.columnId  =  '3';
        }
        else
        if( columnUpperBound == 0 && columnLowerBound  == 0){
            tw.columnId  =  '4';
        } 
       return Json.serialize( tw );
        
        
     }
     
     //Methodto calculate count for each column the type card is the input to this method
     @remoteaction  
     public static string importantCount(String cardTypes)
     {
            //cardTypes = 'T'  ;    
            DateTime  columnTimeLowerBound  =  Datetime.valueOf(0) ;  
            DateTime  columnTimeUpperBound  =  Datetime.valueOf(nowinmilliseconds);
            Date  columnDateLowerBound  =  Date.newInstance( columnTimeLowerBound.year(), columnTimeLowerBound.month(), columnTimeLowerBound.day() ); 
            Date  columnDateUpperBound  =  Date.newInstance( columnTimeUpperBound.year(), columnTimeUpperBound.month(), columnTimeUpperBound.day() );
            Integer decisionCount = 0;
            Integer planCount   = 0;
            Integer taskcount  = 0;
            Integer OverdueCount = 0;
            
            // Overdue column count calculation as no plan will come under over due 0 is considered
            if(cardTypes.contains('D'))  
            decisionCount        = [select count() from Social_Input__c where User__c =: UserInfo.getUserId() and (Accountable__c = true or Backup_for_Accountable__c = true or Responsible__c = true) and  Decision__c != null and Decision__r.phase__c != 'Close'   and Decision__r.Nearest_Due_Date__c >=: columnTimeLowerBound and Decision__r.Nearest_Due_Date__c <: columnTimeUpperBound and Decision__r.Nearest_Due_Date__c != null    ];
            if(cardTypes.contains('T'))
            taskcount            = [Select count() from Task t where t.Owner.id =: UserInfo.getUserId()   and t.IsClosed = false  and activitydate >=: columnDateLowerBound  and activitydate <: columnDateUpperBound  and activitydate !=: null ];
            OverdueCount =   decisionCount + 0 +  taskcount + (cardTypes.contains('A')?HomePage.approvalCount(columnTimeLowerBound,columnTimeUpperBound):0);
            
            //Today column count calculation
            columnTimeLowerBound  =  Datetime.valueOf(nowinmilliseconds) ;  
            columnTimeUpperBound  =  Datetime.valueOf(nowinmilliseconds+86400000L);
            columnDateLowerBound  =  Date.newInstance( columnTimeLowerBound.year(), columnTimeLowerBound.month(), columnTimeLowerBound.day() ); 
            columnDateUpperBound  =  Date.newInstance( columnTimeUpperBound.year(), columnTimeUpperBound.month(), columnTimeUpperBound.day() );
            
           
            if(cardTypes.contains('D'))
            decisionCount        = [select count() from Social_Input__c where User__c =: UserInfo.getUserId() and (Accountable__c = true or Backup_for_Accountable__c = true or Responsible__c = true) and  Decision__c != null and Decision__r.phase__c != 'Close'   and Decision__r.Nearest_Due_Date__c >=: columnTimeLowerBound and Decision__r.Nearest_Due_Date__c <: columnTimeUpperBound and Decision__r.Nearest_Due_Date__c != null    ];
            if(cardTypes.contains('P') )
            planCount            = [select count() from Social_Input__c where User__c =: UserInfo.getUserId() and (Accountable__c = true or Backup_for_Accountable__c = true or Responsible__c = true) and Plan__c != null and  Plan__r.Start_Time__c <=: system.now() and  Plan__r.End_Time__c >=: system.now()  ];
            if(cardTypes.contains('T'))
            taskcount            = [Select count() from Task t where t.Owner.id =: UserInfo.getUserId()   and t.IsClosed = false  and activitydate >=: columnDateLowerBound  and activitydate <: columnDateUpperBound  and activitydate !=: null ];
             
            Integer todayCount = decisionCount + plancount +  taskcount +  (cardTypes.contains('A')?HomePage.approvalCount(columnTimeLowerBound,columnTimeUpperBound):0);
            
            // 1 week column calculation
            columnTimeLowerBound  =  Datetime.valueOf(nowinmilliseconds+86400000L) ;  
            columnTimeUpperBound  =  Datetime.valueOf(nowinmilliseconds+604800000L);
            columnDateLowerBound  =  Date.newInstance( columnTimeLowerBound.year(), columnTimeLowerBound.month(), columnTimeLowerBound.day() ); 
            columnDateUpperBound  =  Date.newInstance( columnTimeUpperBound.year(), columnTimeUpperBound.month(), columnTimeUpperBound.day() );
            
            if(cardTypes.contains('D'))
            decisionCount        = [select count() from Social_Input__c where User__c =: UserInfo.getUserId() and (Accountable__c = true or Backup_for_Accountable__c = true or Responsible__c = true) and  Decision__c != null and Decision__r.phase__c != 'Close'   and Decision__r.Nearest_Due_Date__c >=: columnTimeLowerBound and Decision__r.Nearest_Due_Date__c <: columnTimeUpperBound and Decision__r.Nearest_Due_Date__c != null    ];
            if(cardTypes.contains('P'))
            planCount            = [select count() from Social_Input__c where User__c =: UserInfo.getUserId() and (Accountable__c = true or Backup_for_Accountable__c = true or Responsible__c = true) and Plan__c != null and Plan__r.Start_Time__c >=: system.now().addDays(0) and  Plan__r.start_Time__c <=: system.now().addDays(7)     ];
            if(cardTypes.contains('T'))
            taskcount            = [Select count() from Task t where t.Owner.id =: UserInfo.getUserId()   and t.IsClosed = false  and activitydate >=: columnDateLowerBound  and activitydate <=: columnDateUpperBound  and activitydate !=: null ];
           
            Integer weekCount = decisionCount + planCount +  taskcount +  (cardTypes.contains('A')?HomePage.approvalCount(columnTimeLowerBound,columnTimeUpperBound):0);
            // ! month count calculation
            columnTimeLowerBound  =  Datetime.valueOf(nowinmilliseconds+604800000L) ;  
            columnTimeUpperBound  =  Datetime.valueOf(32503660200000L);
            columnDateLowerBound  =  Date.newInstance( columnTimeLowerBound.year(), columnTimeLowerBound.month(), columnTimeLowerBound.day() ); 
            columnDateUpperBound  =  Date.newInstance( columnTimeUpperBound.year(), columnTimeUpperBound.month(), columnTimeUpperBound.day() );
 
            if(cardTypes.contains('D'))
            decisionCount        = [select count() from Social_Input__c where User__c =: UserInfo.getUserId() and (Accountable__c = true or Backup_for_Accountable__c = true or Responsible__c = true) and  Decision__c != null and Decision__r.phase__c != 'Close'   and Decision__r.Nearest_Due_Date__c >=: columnTimeLowerBound and Decision__r.Nearest_Due_Date__c <: columnTimeUpperBound and Decision__r.Nearest_Due_Date__c != null    ];
            if(cardTypes.contains('P'))
            planCount            = [select count() from Social_Input__c where User__c =: UserInfo.getUserId() and (Accountable__c = true or Backup_for_Accountable__c = true or Responsible__c = true) and Plan__c != null  and Plan__r.Start_Time__c >=: system.now().addDays(7) and  Plan__r.start_Time__c <=: system.now().addDays(30)     ];
            
            if(cardTypes.contains('T'))
            taskcount            = [Select count() from Task t where t.Owner.id =: UserInfo.getUserId()   and t.IsClosed = false  and activitydate >: columnDateLowerBound  and activitydate <=: columnDateUpperBound  and activitydate !=: null ];
            
            Integer monthCount = decisionCount + planCount +  taskcount +  (cardTypes.contains('A')?HomePage.approvalCount(columnTimeLowerBound,columnTimeUpperBound):0);
             
            //No deadline count calculation
            if(cardTypes.contains('D'))
            decisionCount        = [select count() from Social_Input__c where User__c =: UserInfo.getUserId() and (Accountable__c = true or Backup_for_Accountable__c = true or Responsible__c = true) and  Decision__c != null and Decision__r.phase__c != 'Close' and Decision__r.Nearest_Due_Date__c = null    ];
            if(cardTypes.contains('P'))
            planCount            = [select count() from Social_Input__c where User__c =: UserInfo.getUserId() and (Accountable__c = true or Backup_for_Accountable__c = true or Responsible__c = true) and Plan__c != null and   Plan__r.Start_Time__c  =:null    ];
            if(cardTypes.contains('T'))         
            taskcount            = [Select count() from Task t where t.Owner.id =: UserInfo.getUserId()   and t.IsClosed = false  and activitydate =: null   ];
            
            Integer noDeadlineCount = decisionCount + planCount +  taskcount +  (cardTypes.contains('A')?HomePage.approvalCount(Datetime.valueOf(0),Datetime.valueOf(0)):0);
          
            return  '{"OverdueCount":"'+OverdueCount+'","todayCount":"'+todayCount+'","weekCount":"'+weekCount+'","monthCount":"'+monthCount+'","noDeadlineCount":"'+noDeadlineCount+'"}';
        
     }
     //Methos to calculate approval count for each column
     public static  integer approvalCount(Datetime columnTimeLowerBound,Datetime columnTimeUpperBound){
            //Query all socialinput count
            Map<id,Social_Input__c> socialInputMap=new  Map<id,Social_Input__c> ([Select id,Decision__c,Final_Approval_Status__c,Role_Acceptance_Status__c,Stance_Approval_Status__c ,Decision__r.id from Social_Input__c where User__c =: UserInfo.getUserId()  and  Decision__c != null    ]);
            //Query all process instance
            List<ProcessInstanceWorkitem> ProcessInstanceList = [Select  p.ProcessInstance.Status, p.ProcessInstance.TargetObjectId, p.ProcessInstanceId, p.Id, p.CreatedDate, p.CreatedBy.Name, p.CreatedById, p.Actor.Name, p.ActorId From ProcessInstanceWorkitem p where  p.ActorId =: Userinfo.getUserId() AND p.ProcessInstance.TargetObjectId IN: socialInputMap.values() order by p.CreatedDate desc ]  ;
            set<id> decsionIds = new set<id>();
            for(Social_Input__c socialInput :socialInputMap.values() ){
              decsionIds.add( socialInput.Decision__c  ); 
            }
            Map<id,Decision__c> DecisionMap = new Map<id,Decision__c>([Select id ,LastModifiedDate ,Title__c,Accountable__c,Priority__c,OwnerId from Decision__c where id in: decsionIds ]);
            Map<id,Decision__c> socialToDecisionMap = new Map<id,Decision__c>();
            for(social_Input__C  sc: socialInputMap.values())
            {
                socialToDecisionMap.put(Sc.id, DecisionMap.get( sc.Decision__c)); 
            }  
            Map<id,Timing__c> timingMap = new Map<id,Timing__c>([Select id ,Related_To_ID__c ,End_Date_Time__c,Actual_End_Date__c from Timing__c where Stage__c=:'Propose' and Related_To_ID__c in :decsionIds  order by End_Date_Time__c ]);
            Map<id,Timing__c> decisiontoTimingMap =  new Map<id,Timing__c>();
            for( Timing__c t: timingMap.values() ){
             decisiontoTimingMap.put(t.Related_To_ID__c ,t) ;
            }           
            Integer counter =0;
            for(ProcessInstanceWorkitem piw : ProcessInstanceList ) {
               Social_Input__c loggedInSocialPeople = socialInputMap.get(piw.ProcessInstance.TargetObjectId);
               //If any approval pending then
               if(loggedInSocialPeople.Final_Approval_Status__c != null || loggedInSocialPeople.Role_Acceptance_Status__c != null || loggedInSocialPeople.Stance_Approval_Status__c != null){
                    Datetime decisionDueDate  ;
                    Long columnLowerBound =  columnTimeLowerBound.getTime();
                    Long columnUpperBound =  columnTimeUpperBound.getTime();
                    //  if the propose end date or propose actual end date is not null then
                    if(decisiontoTimingMap.get( loggedInSocialPeople.Decision__c).End_Date_Time__c != null||decisiontoTimingMap.get( loggedInSocialPeople.Decision__c).Actual_End_Date__c  != null )
                    {    
                            decisionDueDate =  decisiontoTimingMap.get( loggedInSocialPeople.Decision__r.id).End_Date_Time__c != null? decisiontoTimingMap.get( loggedInSocialPeople.Decision__r.id).End_Date_Time__c: decisiontoTimingMap.get( loggedInSocialPeople.Decision__r.id).Actual_End_Date__c;
                    } 
                    // Column for once day
                    if(   columnUpperBound - columnLowerBound  ==  86400000L ){
                        if( decisionDueDate  == system.now() || ( ( decisionDueDate > system.now() && decisionDueDate <= system.now().adddays(1) ) ) )
                        {
                             counter++;  
                        } 
                    } 
                    else
                    //column for overdue
                    if( columnLowerBound == 0 && columnUpperBound != 0 ){
                        if(   decisionDueDate < System.now()  )  
                        {
                              counter++; 
                        } 
                    } 
                    else
                    // for 1 week and 1 month column
                    if( columnLowerBound != 0 && columnUpperBound != 0 )
                    {
                        if( columnTimeLowerBound < decisionDueDate  && columnTimeUpperBound >= decisionDueDate  )
                        {
                              counter++;  
                        }   
                    }   
                    // for overdue
                    if( columnLowerBound == columnUpperBound  )
                    {
                        if( decisionDueDate == null  )
                        {
                              counter++;  
                        }   
                    } 
                }
            }
      return counter;
     }
}