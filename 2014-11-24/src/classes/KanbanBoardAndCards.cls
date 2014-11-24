public without sharing class KanbanBoardAndCards {

    // dummy call from visualforce for rerender the page.
    public PageReference dummyCall() { 
        return null;
    }
    
    public List<String> stageValues {get; set;}
    public List<String> statusValues {get; set;} 
    public List<Task> lstTask {get; set;}
    public transient List<kanBanTaskWrapper> kanBanTaskWrapperList{get; set;}
    public set<String> statusValuesTemp {get; set;}
    public GeneralInformation genInfo = new GeneralInformation();
    public static GeneralInformation genralInfoTime;
     public static String dateTimeFormat {get;set;}
    
    public Id recId {get; set;}
    public String recName {get; set;}
    public String selectedView {get; set;}
    public String lookUpRecordsJson {get;set;}
    public Task newTask {get; set;}
    public Task newSelectedTask {get; set;}
    public string editDisable {get; set;}
    public boolean chatDisable {get; set;}
    public Map<String,Integer> statusCountMap {get; set;}
    public string delimited_string_with_map_keys{get;set;}
    public List<AggregateResult> statusCount{get;set;}
     public string taskStatusPicklist {get;set;}
    //variable to send user locale 
    public static string  userLocaleSidKey{get;set;}
    static{
            //set user locale here
            userLocaleSidKey  = UserInfo.getLocale().replace('_','-');
    }
    public Boolean showTaskPopup {get; set;}
    public Boolean newShowTaskPopup {get; set;}  
    public String taskId {get; set;}
    public String taskEditable {get; set;}
    public String modeType {get; set;}
    public Task newTaskToDecision{get;set;}  
    public Task updatedTask {get;set;}
    // Defining Constructor
    public KanbanBoardAndCards(){
        if(genralInfoTime == null ) {
            genralInfoTime  = new GeneralInformation();
        }
        dateTimeFormat = genralInfoTime.MapValuesDateFormate(); 
        delimited_string_with_map_keys ='';
        showTaskPopup = false;
        newShowTaskPopup = false; 
        newTask = new Task();
        newTask.OwnerId = UserInfo.getUserId();
        newTaskToDecision = new task(Status='Not Started', OwnerId = UserInfo.getUserId(),Priority = 'Normal',IsReminderSet = true,Skill_Level__c = '1'); 
        updatedTask = new Task();
      
      
        // dynamic picklist for task status
        
            Schema.DescribeFieldResult  priorityResult = Schema.sObjectType.Task.fields.Status;
            priorityResult = priorityResult.getSObjectField().getDescribe();
            List<Schema.PicklistEntry>  priorityPickList = priorityResult.getPicklistValues();
         taskStatusPicklist = '';
          for(Schema.PicklistEntry priorityValue : priorityPickList){
                taskStatusPicklist = taskStatusPicklist +  '{ \"StatusName\" :' + '\"' + priorityValue.getLabel() + '\"' + '},' ;
         }
        taskStatusPicklist  = taskStatusPicklist.substring(0,taskStatusPicklist.length()-1);
        viewAllTasks();
        //taskRecId ='00TN00000032sFVMAY';
        //priorityTaskLst=[select id ,Priority from Task where Id in :]
        system.debug('=============kanBanTaskWrapperList========================='+kanBanTaskWrapperList);
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
      // Intialise task popup when opening from activites tab
    public void intialiseDecisionTask(){
        newTaskToDecision = new Task();
        newTaskToDecision = new Task(Status='Not Started', OwnerId = UserInfo.getUserId(),Priority = 'Normal',IsReminderSet = true,Skill_Level__c = '1');
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
    
    // Method to get all the default task records to be loaded on Kanbanboard. 
    public pageReference viewAllTasks(){
        /* ******************* My Code ****************
        statusValues = new List<String>();
        stageValues = new List<String>();
        statusValuesTemp = new set<String>();
        kanBanTaskWrapperList = new list<kanBanTaskWrapper>();
        
        Schema.DescribeFieldResult  stageResult = Task.Stage__c.getDescribe();
        List<Schema.PicklistEntry>  stagePickList = stageResult.getPicklistValues();
        
        for(Schema.PicklistEntry stageValue : stagePickList){
            stageValues.add(stageValue.getValue());
        }
        
        Schema.DescribeFieldResult  statusResult = Task.Status.getDescribe();
        List<Schema.PicklistEntry>  statusPickList = statusResult.getPicklistValues();
        
        
        for(Schema.PicklistEntry statusValue : statusPickList){
            statusValues.add(statusValue.getValue()); 
        }
        
        lstTask = [select id,Status,Stage__c,Priority,ActivityDate,Subject,OwnerId,Owner.Name,complexity__c,Description,whatId,createdById from Task order by lastModifiedDate desc limit 10 ];
        Set<Id> taskWhatIdSet = new set<Id>();
        for(task t:lstTask){
            taskWhatIdSet.add(t.WhatId);    
        }
        Map<Id,String> relatedToTitle = new Map<Id,String>();
        List<Decision__c> decisionTitle = [select id, Title__c from Decision__c where Id in: taskWhatIdSet];
        for(Decision__c d: decisionTitle){
            relatedToTitle.put(d.Id,d.Title__c);
        }
        
        List<plan__c> planTitle = [select id, Name from Plan__c where Id in: taskWhatIdSet];
        for(Plan__c d: planTitle){
            relatedToTitle.put(d.Id,d.Name);
        } 
        
        for(Task t: lstTask){
            kanBanTaskWrapper k = new kanBanTaskWrapper();
            k.kanbanTask = t;
            k.taskSubject = t.Subject ;
            k.userImg = genInfo.useNameMap.get(t.OwnerId).SmallPhotoUrl;
            k.priorityImage = genInfo.imageUrlMap.get(t.Priority);
            if(t.ActivityDate != null){
                Integer dateLeft = System.today().daysBetween(t.ActivityDate);
                k.deadlineState = dateLeft > 0 ? 'Positive' : 'Negative';
                k.deadlineNum = k.deadlineState == 'Positive' ? string.valueOf(dateLeft) : string.valueOf(dateLeft).substring(1,string.valueOf(dateLeft).length());  
            }  
            k.relatedTo = relatedToTitle.get(t.WhatId) != null ? relatedToTitle.get(t.WhatId) : '';
            k.comments = t.Description == null ? '' : t.Description.length() > 80 ? t.Description.substring(0,77)+'...' : t.Description;
            k.userAssigneeName = t.OwnerId == userInfo.getUserId() ? t.Owner.Name : genInfo.useNameMap.get(t.CreatedById).Name;
            k.userAssignImgUrl = t.OwnerId == userInfo.getUserId() ? genInfo.useImage.get(t.OwnerId) : genInfo.useImage.get(t.CreatedById);
            k.userAssigneeDept = t.OwnerId == userInfo.getUserId() ? genInfo.useNameMap.get(t.OwnerId).Department : genInfo.useNameMap.get(t.CreatedById).Department;
            k.userAssigneeTemplate = t.OwnerId == userInfo.getUserId() ? 'ASSIGNED' : 'ASSIGNED TO';
            kanBanTaskWrapperList.add(k);   
        }
        
        ****************** my code ends *****************/
        statusCountMap = new Map<String,Integer>();
        statusCount= new List<AggregateResult>();
        
        
        statusValues = new List<String>();
        stageValues = new List<String>();
        newTask.IsReminderSet = true;
        kanBanTaskWrapperList = new list<kanBanTaskWrapper>();
        // Fetching dynamic picklist values for task stage values
        Schema.DescribeFieldResult  stageResult = Task.Stage__c.getDescribe();
        List<Schema.PicklistEntry>  stagePickList = stageResult.getPicklistValues();
        
        for(Schema.PicklistEntry stageValue : stagePickList){
            stageValues.add(stageValue.getValue());
        }
        
        // Fetching dynamic picklist values for task status values
        Schema.DescribeFieldResult  statusResult = Task.Status.getDescribe();
        List<Schema.PicklistEntry>  statusPickList = statusResult.getPicklistValues();
        
        for(Schema.PicklistEntry statusValue : statusPickList){
            statusValues.add(statusValue.getValue()); 
        }
        
        // getting default task records to on load
        lstTask = [select id,Status,Stage__c,Priority,whatId,What.Name, whoId, Who.Name,isclosed,ActivityDate,Subject,OwnerId,Owner.Name,complexity__c,Description,createdById from Task where OwnerId = : userinfo.getUserId() and ( ActivityDate = NEXT_N_DAYS : 6 or ActivityDate = TODAY ) and Subject != null order by lastModifiedDate desc limit 400];
         
        List<Id> taskIds = new List<Id>();
        for(Task t : lstTask){
            taskIds.add(t.Id);
        }
        statusCount=[SELECT count(Id),Status FROM Task where Id IN : taskIds AND OwnerId =  : userinfo.getUserId()  and Subject != null group by status  limit 400];
         system.debug('statusCountstatusCountstatusCountstatusCountstatusCountstatusCountstatusCountstatusCountstatusCountstatusCountstatusCount: '+statusCount);
        // Creating two decision list of ids which will store 200 ids each in the lists.
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
        statusCountMap  = new Map<string,integer>();
        delimited_string_with_map_keys ='';
        
        // Bulding wrapper class to show kanban cards based on filters applied.
        for(Task t: lstTask){
            if(readAccess.get(t.Id)){
                /*kanBanTaskWrapper k = new kanBanTaskWrapper();
                k.kanbanTask = t;
                k.userImg = genInfo.useNameMap.get(t.OwnerId).SmallPhotoUrl;
                k.priorityImage = genInfo.imageUrlMap.get(t.Priority);
                k.recordAccess = trackAccess.get(t.Id);
                kanBanTaskWrapperList.add(k);
                */
                if( ! delimited_string_with_map_keys.contains(t.status ))
                delimited_string_with_map_keys +=   t.status;
                if( statusCountMap.get(t.status) == null )
                 statusCountMap.put(t.status,1);
                else
                 statusCountMap.put(   t.status,  statusCountMap.get(t.status) +  1);
                 
                kanBanTaskWrapper k = new kanBanTaskWrapper();
                k.kanbanTask = t;
                k.taskSubject = t.Subject ;
                k.userImg = genInfo.useNameMap.get(t.OwnerId).SmallPhotoUrl;
                k.priorityImage = genInfo.imageUrlMap.get(t.Priority);
                if(t.ActivityDate != null){
                    Integer dateLeft = System.today().daysBetween(t.ActivityDate);
                    k.deadlineState = dateLeft > 0 ? 'Positive' : 'Negative';
                    k.deadlineNum = k.deadlineState == 'Positive' ? string.valueOf(dateLeft) : string.valueOf(dateLeft).substring(1,string.valueOf(dateLeft).length());  
                }  
                k.relatedTo = t.What.Name != null ?  t.What.Name : t.Who.Name != null ? t.Who.Name : ' ';
                k.relatedToId = t.WhatId != null ?  t.WhatId : t.WhoId != null ? t.WhoId : null;
                k.comments = t.Description == null ? '' : t.Description.length() > 80 ? t.Description.substring(0,77)+'...' : t.Description;
                /*   task owner assigned by*/
                k.userAssigneeName = t.Owner.Name ;
                k.userAssignImgUrl = genInfo.useImage.get(t.OwnerId) ;
                k.userAssigneeDept = genInfo.useNameMap.get(t.OwnerId).Department ;
                /* task created by assigned to*/
                k.userAssignedName = genInfo.useNameMap.get(t.CreatedById).Name ;
                k.userAssignedImgUrl = genInfo.useImage.get(t.CreatedById) ;
                k.userAssignedDept = genInfo.useNameMap.get(t.CreatedById).Department ;
                k.recordAccess = trackAccess.get(t.Id);
                k.lockImg = k.recordAccess == true ? genInfo.imageUrlMap.get('') : genInfo.imageUrlMap.get('lock'); 
                k.priorityValue= t.Priority;
                k.isClosed = t.isClosed;
                kanBanTaskWrapperList.add(k);  
            
            }
        }
        return null;
    }
    
    public void searchFilter(){
        statusCount= new List<AggregateResult>();
        String assignedId = '';
        String dueDateSelected = '';
        List<String> userSelected ;
        String dateField = '';
        String startField = '';
        String endField = '';
        Boolean chkUserFilter = False;
        Boolean chkAssignedTo = False;
        String searchTaskText = '';
        
        // Getting the parameters on click of GO button which are passed.
        assignedId = Apexpages.currentPage().getParameters().get('assignedId');
        dueDateSelected = Apexpages.currentPage().getParameters().get('dueDateSelected');
        userSelected = Apexpages.currentPage().getParameters().get('userSelected').split(',');
        dateField = Apexpages.currentPage().getParameters().get('dateField');
        searchTaskText = Apexpages.currentPage().getParameters().get('searchTaskText');
        
        if(searchTaskText != '' && searchTaskText != null){
            if(searchTaskText.contains('*')){
                String SearchtextList = searchTaskText.replaceAll('\\*','\\%');
                searchTaskText = SearchtextList;
            }
        }
        
        system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'+userSelected);
        lstTask = new List<Task>();
        kanBanTaskWrapperList = new list<kanBanTaskWrapper>();
        Id userId = userinfo.getUserId();
       /* if(userSelected[0] == 'Default')
            userId = userinfo.getUserId();
        else
            userId = userSelected[0]; */
        if(dateField =='DUE_DATE'){
            // building dynamic query based on filters applied for task object.
            String query = 'select id,Status,Stage__c,Priority,ActivityDate,whatId, What.Name,isClosed, whoId, Who.Name,Subject,OwnerId,Owner.Name,complexity__c,Description,createdById from Task where Subject != null and (whatId = null or whatId != null) ';
            
            if(assignedId == 'AssignedTo'){
                query = query + ' and OwnerId In :userSelected' ;
                chkAssignedTo = true;
            } else if(assignedId == 'AssignedBy'){
                query = query + ' and CreatedById In : userSelected ';
                chkUserFilter = true;
            }
            if(dueDateSelected != ''){
                if(dueDateSelected == 'Overdue'){
                    query = query + ' and ( ActivityDate = LAST_N_YEARS : 10 or ActivityDate = THIS_YEAR ) and  ActivityDate < TODAY and isClosed = false ';
                }else if(dueDateSelected == 'All'){
                    query = query; 
                } else if(dueDateSelected == 'today'){
                    query = query + ' and ( ActivityDate = NEXT_N_DAYS : 0  or ActivityDate = TODAY ) ';
                }else if(dueDateSelected == 'tomorrow'){
                    query = query + ' and ActivityDate = NEXT_N_DAYS : 1 ';
                }else if(dueDateSelected == 'next7'){
                    query = query + ' and ( ActivityDate = NEXT_N_DAYS : 6 or ActivityDate = TODAY) ';
                } else if(dueDateSelected == 'next30'){
                    query = query + ' and (ActivityDate = NEXT_N_DAYS : 29  or ActivityDate = TODAY )';
                } else if(dueDateSelected == 'next60'){
                    query = query + ' and ( ActivityDate = NEXT_N_DAYS : 59  or ActivityDate = TODAY ) ';
                } else if(dueDateSelected == 'next90'){
                    query = query + ' and ( ActivityDate = NEXT_N_DAYS : 89  or ActivityDate = TODAY ) ';
                }else if(dueDateSelected == 'next120'){
                    query = query + ' and ( ActivityDate = NEXT_N_DAYS : 119  or ActivityDate = TODAY ) ';
                }else if(dueDateSelected == 'yesterday'){
                    query = query + ' and ( ActivityDate = YESTERDAY ) ';
                }else if(dueDateSelected == 'last7'){
                    query = query + ' and ( ActivityDate = LAST_N_DAYS: 6  or ActivityDate = TODAY ) ';
                }else if(dueDateSelected == 'last30'){
                    query = query + ' and ( ActivityDate = LAST_N_DAYS: 29  or ActivityDate = TODAY ) ';
                }else if(dueDateSelected == 'last60'){
                    query = query + ' and ( ActivityDate = LAST_N_DAYS: 59  or ActivityDate = TODAY ) ';
                }else if(dueDateSelected == 'last90'){
                    query = query + ' and ( ActivityDate = LAST_N_DAYS: 89  or ActivityDate = TODAY ) ';
                }else if(dueDateSelected == 'last120'){
                    query = query + ' and ( ActivityDate = LAST_N_DAYS: 119  or ActivityDate = TODAY ) ';
                }else if(dueDateSelected == 'lastnext7'){
                    query = query + ' and ( ActivityDate = LAST_N_DAYS: 6  or ActivityDate = TODAY or ActivityDate = NEXT_N_DAYS : 6 ) ';
                }else if(dueDateSelected == 'lastnext14'){
                    query = query + ' and ( ActivityDate = LAST_N_DAYS: 13  or ActivityDate = TODAY or ActivityDate = NEXT_N_DAYS : 13 ) ';
                }else if(dueDateSelected == 'custom'){
                    startField = Apexpages.currentPage().getParameters().get('startField');
                    endField = Apexpages.currentPage().getParameters().get('endField');
                     //system.debug('dd'+endField);
                     if(startField =='' || endField == ''){
                        query = query;
                     }else{ 
                         String startFieldstring = startField+'T00:00:00z';
                         String endFieldstring = endField+'T00:00:00z';
                         query = query + ' and  (ActivityDate  >= '+ startField +' '+'and ActivityDate <= '+ endField +')'   ;
                     }
                }
            } 
            if(searchTaskText != '' && searchTaskText != null){
                query = query + ' and Subject like  \'%'+searchTaskText+ '%\'';
            }
            query = query + ' order by lastModifiedDate desc limit 400';
            
            System.debug('----------query----------->'+query);
            //lstTask = [select id,Status,Stage__c,Priority,ActivityDate,Subject,OwnerId,Owner.Name from Task where WhatId = : selectedRec order by lastModifiedDate desc];
            lstTask = Database.query(query);
            system.debug('lstTasklstTasklstTask======'+lstTask);
            // Creating two decision list of ids which will store 200 ids each in the lists.
        }else if(dateField =='CREATED_DATE'){
            // building dynamic query based on filters applied for task object.
            String query = 'select id,Status,Stage__c,Priority,CreatedDate,ActivityDate,whatId, What.Name, whoId, Who.Name,Subject,OwnerId,Owner.Name,complexity__c,isclosed,Description,createdById from Task where Subject != null and (whatId = null or whatId != null) ';
            
            if(assignedId == 'AssignedTo'){
                query = query + ' and OwnerId In :userSelected ';
                chkAssignedTo = true;
            } else if(assignedId == 'AssignedBy'){
                query = query + ' and CreatedById In :userSelected';
                chkUserFilter = true;
            }
            if(dueDateSelected != ''){
                if(dueDateSelected == 'Overdue'){
                    query = query + ' and ( CreatedDate = LAST_N_YEARS : 10 or CreatedDate = THIS_YEAR ) and  CreatedDate < TODAY and isClosed = false ';
                }else if(dueDateSelected == 'All'){
                    query = query; 
                } else if(dueDateSelected == 'today'){
                    query = query + ' and ( CreatedDate = NEXT_N_DAYS : 0  or CreatedDate = TODAY ) ';
                }else if(dueDateSelected == 'tomorrow'){
                    query = query + ' and CreatedDate = NEXT_N_DAYS : 1 ';
                }else if(dueDateSelected == 'yesterday'){
                    query = query + ' and ( CreatedDate = YESTERDAY ) ';
                }else if(dueDateSelected == 'next7'){
                    query = query + ' and ( CreatedDate = NEXT_N_DAYS : 6 or CreatedDate = TODAY) ';
                } else if(dueDateSelected == 'next30'){
                    query = query + ' and (CreatedDate = NEXT_N_DAYS : 29  or CreatedDate = TODAY )';
                } else if(dueDateSelected == 'next60'){
                    query = query + ' and ( CreatedDate = NEXT_N_DAYS : 59  or CreatedDate = TODAY ) ';
                } else if(dueDateSelected == 'next90'){
                    query = query + ' and ( CreatedDate = NEXT_N_DAYS : 89  or CreatedDate = TODAY ) ';
                }else if(dueDateSelected == 'next120'){
                    query = query + ' and ( CreatedDate = NEXT_N_DAYS : 119  or CreatedDate = TODAY ) ';
                }else if(dueDateSelected == 'last7'){
                    query = query + ' and ( CreatedDate = LAST_N_DAYS: 6  or CreatedDate = TODAY ) ';
                }else if(dueDateSelected == 'last30'){
                    query = query + ' and ( CreatedDate = LAST_N_DAYS: 29  or CreatedDate = TODAY ) ';
                }else if(dueDateSelected == 'last60'){
                    query = query + ' and ( CreatedDate = LAST_N_DAYS: 59  or CreatedDate = TODAY ) ';
                }else if(dueDateSelected == 'last90'){
                    query = query + ' and ( CreatedDate = LAST_N_DAYS: 89  or CreatedDate = TODAY ) ';
                }else if(dueDateSelected == 'last120'){
                    query = query + ' and ( CreatedDate = LAST_N_DAYS: 119  or CreatedDate = TODAY ) ';
                }else if(dueDateSelected == 'lastnext7'){
                    query = query + ' and ( CreatedDate = LAST_N_DAYS: 6  or CreatedDate = TODAY or CreatedDate = NEXT_N_DAYS : 6 ) ';
                }else if(dueDateSelected == 'lastnext14'){
                    query = query + ' and ( CreatedDate = LAST_N_DAYS: 13  or CreatedDate = TODAY or CreatedDate = NEXT_N_DAYS : 13 ) ';
                }
                else if(dueDateSelected == 'custom'){
                    startField = Apexpages.currentPage().getParameters().get('startField');
                    endField = Apexpages.currentPage().getParameters().get('endField');
                     //system.debug('dd'+endField);
                     if(startField =='' || endField == ''){
                        query = query;
                     }else{ 
                        String startFieldstring = startField+'T00:00:00z';
                        String endFieldstring = endField+'T00:00:00z';
                        query = query + ' and (CreatedDate  >= '+ startFieldstring +' '+'and CreatedDate <= '+ endFieldstring +')';
                     }
                }
            } 
            if(searchTaskText != '' && searchTaskText != null){
                searchTaskText = '%'+searchTaskText+'%';
                query = query + ' and Subject like : searchTaskText ';
            }
            query = query + ' order by CreatedDate desc limit 400';
            
            System.debug('----------query----------->'+query);
            //lstTask = [select id,Status,Stage__c,Priority,CreatedDate,Subject,OwnerId,Owner.Name from Task where WhatId = : selectedRec order by CreatedDate desc];
            lstTask = Database.query(query);
            system.debug('lstTasklstTasklstTask======'+lstTask);
        }else if(dateField =='LAST_UPDATE'){
            // building dynamic query based on filters applied for task object.
            String query = 'select id,Status,Stage__c,Priority,LastModifiedDate,ActivityDate,whatId, What.Name, whoId, Who.Name,Subject,isclosed,OwnerId,Owner.Name,complexity__c,Description,createdById from Task where Subject != null and (whatId = null or whatId != null) ';
            
            if(assignedId == 'AssignedTo'){
                query = query + ' and OwnerId In :userSelected ';
                chkAssignedTo = true;
            } else if(assignedId == 'AssignedBy'){
                query = query + ' and CreatedById In :userSelected';
                chkUserFilter = true;
            }
            if(dueDateSelected != ''){
                if(dueDateSelected == 'Overdue'){
                    query = query + ' and ( LastModifiedDate = LAST_N_YEARS : 10 or LastModifiedDate = THIS_YEAR ) and  LastModifiedDate < TODAY and isClosed = false ';
                }else if(dueDateSelected == 'All'){
                    query = query; 
                } else if(dueDateSelected == 'today'){
                    query = query + ' and ( LastModifiedDate = NEXT_N_DAYS : 0  or LastModifiedDate = TODAY ) ';
                }else if(dueDateSelected == 'tomorrow'){
                    query = query + ' and LastModifiedDate = NEXT_N_DAYS : 1 ';
                }else if(dueDateSelected == 'yesterday'){
                    query = query + ' and ( LastModifiedDate = YESTERDAY ) ';
                }else if(dueDateSelected == 'next7'){
                    query = query + ' and ( LastModifiedDate = NEXT_N_DAYS : 6 or LastModifiedDate = TODAY) ';
                } else if(dueDateSelected == 'next30'){
                    query = query + ' and (LastModifiedDate = NEXT_N_DAYS : 29  or LastModifiedDate = TODAY )';
                } else if(dueDateSelected == 'next60'){
                    query = query + ' and ( LastModifiedDate = NEXT_N_DAYS : 59  or LastModifiedDate = TODAY ) ';
                } else if(dueDateSelected == 'next90'){
                    query = query + ' and ( LastModifiedDate = NEXT_N_DAYS : 89  or LastModifiedDate = TODAY ) ';
                }else if(dueDateSelected == 'next120'){
                    query = query + ' and ( LastModifiedDate = NEXT_N_DAYS : 119  or LastModifiedDate = TODAY ) ';
                }else if(dueDateSelected == 'last7'){
                    query = query + ' and ( LastModifiedDate = LAST_N_DAYS: 6  or LastModifiedDate = TODAY ) ';
                }else if(dueDateSelected == 'last30'){
                    query = query + ' and ( LastModifiedDate = LAST_N_DAYS: 29  or LastModifiedDate = TODAY ) ';
                }else if(dueDateSelected == 'last60'){
                    query = query + ' and ( LastModifiedDate = LAST_N_DAYS: 59  or LastModifiedDate = TODAY ) ';
                }else if(dueDateSelected == 'last90'){
                    query = query + ' and ( LastModifiedDate = LAST_N_DAYS: 89  or LastModifiedDate = TODAY ) ';
                }else if(dueDateSelected == 'last120'){
                    query = query + ' and ( LastModifiedDate = LAST_N_DAYS: 119  or LastModifiedDate = TODAY ) ';
                }else if(dueDateSelected == 'lastnext7'){
                    query = query + ' and ( LastModifiedDate = LAST_N_DAYS: 6  or LastModifiedDate = TODAY or LastModifiedDate = NEXT_N_DAYS : 6 ) ';
                }else if(dueDateSelected == 'lastnext14'){
                    query = query + ' and ( LastModifiedDate = LAST_N_DAYS: 13  or LastModifiedDate = TODAY or LastModifiedDate = NEXT_N_DAYS : 13 ) ';
                }else if(dueDateSelected == 'custom'){
                    startField = Apexpages.currentPage().getParameters().get('startField');
                    endField = Apexpages.currentPage().getParameters().get('endField');
                     //system.debug('dd'+endField);
                     if(startField =='' || endField == ''){
                        query = query;
                     }else{     
                        String startFieldstring = startField+'T00:00:00z';
                        String endFieldstring = endField+'T00:00:00z';
                        query = query + ' and  (LastModifiedDate  >= '+ startFieldstring +' '+'and LastModifiedDate <= '+ endFieldstring +')';
                     }
                }
            } 
            if(searchTaskText != '' && searchTaskText != null){
                searchTaskText = '%'+searchTaskText+'%';
                query = query + ' and Subject like : searchTaskText ';
            }
            query = query + ' order by lastModifiedDate desc limit 400';
            
            System.debug('----------query----------->'+query);
            //lstTask = [select id,Status,Stage__c,Priority,LastModifiedDate,Subject,OwnerId,Owner.Name from Task where WhatId = : selectedRec order by lastModifiedDate desc];
            lstTask = Database.query(query);
            system.debug('lstTasklstTasklstTask======'+lstTask);
        }else if(dateField =='Not_DUE_DATE'){
            Boolean chkPreviousDay =false;
            // building dynamic query based on filters applied for task object.
            String query = 'select id,Status,Stage__c,Priority,ActivityDate,whatId, What.Name,isClosed, whoId, Who.Name,Subject,OwnerId,Owner.Name,complexity__c,Description,createdById from Task where Subject != null and (whatId = null or whatId != null) ';
            
            if(assignedId == 'AssignedTo'){
                query = query + ' and OwnerId In :userSelected ';
                chkAssignedTo = true;
            } else if(assignedId == 'AssignedBy'){
                query = query + ' and CreatedById In : userSelected ';
                chkUserFilter = true;
            }
            if(dueDateSelected != ''){
               if(dueDateSelected == 'Overdue'){
                    query = query + ' and ( ActivityDate = LAST_N_YEARS : 10 or ActivityDate = THIS_YEAR ) and  ActivityDate < TODAY and isClosed = false ';
                }else if(dueDateSelected == 'All'){
                    query = query + ' and ( ActivityDate > TODAY or ActivityDate = TODAY or ActivityDate = null ) ';
                } else if(dueDateSelected == 'today'){
                    query = query + ' and ( ActivityDate = NEXT_N_DAYS : 0  or ActivityDate = TODAY ) ';
                }else if(dueDateSelected == 'tomorrow'){
                    query = query + ' and ActivityDate = NEXT_N_DAYS : 1 ';
                }else if(dueDateSelected == 'next7'){
                    query = query + ' and ( ActivityDate = NEXT_N_DAYS : 6 or ActivityDate = TODAY) ';
                } else if(dueDateSelected == 'next30'){
                    query = query + ' and (ActivityDate = NEXT_N_DAYS : 29  or ActivityDate = TODAY )';
                } else if(dueDateSelected == 'next60'){
                    query = query + ' and ( ActivityDate = NEXT_N_DAYS : 59  or ActivityDate = TODAY ) ';
                } else if(dueDateSelected == 'next90'){
                    query = query + ' and ( ActivityDate = NEXT_N_DAYS : 89  or ActivityDate = TODAY ) ';
                }else if(dueDateSelected == 'next120'){
                    query = query + ' and ( ActivityDate = NEXT_N_DAYS : 119  or ActivityDate = TODAY ) ';
                }else if(dueDateSelected == 'yesterday'){
                    //query = query + ' and ( ActivityDate = YESTERDAY ) ';
                    chkPreviousDay = true;
                }else if(dueDateSelected == 'last7'){
                  query = query + ' and   ActivityDate = TODAY  ';
                }else if(dueDateSelected == 'last30'){
                    query = query + ' and   ActivityDate = TODAY  ';
                    //chkPreviousDay = true;
                }else if(dueDateSelected == 'last60'){
                    query = query + ' and   ActivityDate = TODAY ';
                    
                }else if(dueDateSelected == 'last90'){
                   query = query + ' and   ActivityDate = TODAY  ';
                }else if(dueDateSelected == 'last120'){
                   query = query + ' and   ActivityDate = TODAY  ';
                }else if(dueDateSelected == 'lastnext7'){
                    query = query + ' and ( ActivityDate = TODAY or ActivityDate = NEXT_N_DAYS : 6 ) ';
                }else if(dueDateSelected == 'lastnext14'){
                    query = query + ' and ( ActivityDate = TODAY or ActivityDate = NEXT_N_DAYS : 13 ) ';
                }else if(dueDateSelected == 'custom'){
                    startField = Apexpages.currentPage().getParameters().get('startField');
                    endField = Apexpages.currentPage().getParameters().get('endField');
                     //system.debug('dd'+endField);
                     if(startField =='' || endField == ''){
                        query = query;
                     }else{ 
                        query = query + ' and  ActivityDate >= '+startField + ' and  ActivityDate <= '+endField + ' and  ActivityDate >= TODAY'  ;
                     }
                }
            } 
            if(searchTaskText != '' && searchTaskText != null){
                query = query + ' and Subject like : \'%'+searchTaskText+ '%\'';
            }
            query = query + ' order by lastModifiedDate desc limit 400';
             System.debug('----------query----------->'+query);
            //System.debug('----------query----------->'+kanBanTaskWrapperList.size()); 
            //lstTask = [select id,Status,Stage__c,Priority,ActivityDate,Subject,OwnerId,Owner.Name from Task where WhatId = : selectedRec order by lastModifiedDate desc];
            if(!chkPreviousDay){
                lstTask = Database.query(query);
            }
             if(chkPreviousDay){
                lstTask.clear();
             }
            system.debug('lstTasklstTasklstTask======'+lstTask);
            // Creating two decision list of ids which will store 200 ids each in the lists.   
        }else if(dateField =='Not_CREATED_DATE'){
        
            // building dynamic query based on filters applied for task object.
            String query = 'select id,Status,Stage__c,Priority,CreatedDate,ActivityDate,whatId, What.Name,isClosed, whoId, Who.Name,Subject,OwnerId,Owner.Name,complexity__c,Description,createdById from Task where Subject != null and (whatId = null or whatId != null) and ( ActivityDate > TODAY or ActivityDate = TODAY or ActivityDate = null ) ';
            
            if(assignedId == 'AssignedTo'){
                query = query + ' and OwnerId In :userSelected';
                chkAssignedTo = true;
            } else if(assignedId == 'AssignedBy'){
                query = query + ' and CreatedById In :userSelected ';
                chkUserFilter = true;
            }
            if(dueDateSelected != ''){
                if(dueDateSelected == 'Overdue'){
                    query = query + ' and ( CreatedDate = LAST_N_YEARS : 10 or CreatedDate = THIS_YEAR ) and  CreatedDate < TODAY and isClosed = false ';
                }else if(dueDateSelected == 'All'){
                    query = query; 
                } else if(dueDateSelected == 'today'){
                    query = query + ' and ( CreatedDate = NEXT_N_DAYS : 0  or CreatedDate = TODAY ) ';
                }else if(dueDateSelected == 'tomorrow'){
                    query = query + ' and CreatedDate = NEXT_N_DAYS : 1 ';
                }else if(dueDateSelected == 'yesterday'){
                    query = query + ' and ( CreatedDate = YESTERDAY ) ';
                }else if(dueDateSelected == 'next7'){
                    query = query + ' and ( CreatedDate = NEXT_N_DAYS : 6 or CreatedDate = TODAY) ';
                } else if(dueDateSelected == 'next30'){
                    query = query + ' and (CreatedDate = NEXT_N_DAYS : 29  or CreatedDate = TODAY )';
                } else if(dueDateSelected == 'next60'){
                    query = query + ' and ( CreatedDate = NEXT_N_DAYS : 59  or CreatedDate = TODAY ) ';
                } else if(dueDateSelected == 'next90'){
                    query = query + ' and ( CreatedDate = NEXT_N_DAYS : 89  or CreatedDate = TODAY ) ';
                }else if(dueDateSelected == 'next120'){
                    query = query + ' and ( CreatedDate = NEXT_N_DAYS : 119  or CreatedDate = TODAY ) ';
                }else if(dueDateSelected == 'last7'){
                    query = query + ' and ( CreatedDate = LAST_N_DAYS: 6  or CreatedDate = TODAY ) ';
                }else if(dueDateSelected == 'last30'){
                    query = query + ' and ( CreatedDate = LAST_N_DAYS: 29  or CreatedDate = TODAY ) ';
                }else if(dueDateSelected == 'last60'){
                    query = query + ' and ( CreatedDate = LAST_N_DAYS: 59  or CreatedDate = TODAY ) ';
                }else if(dueDateSelected == 'last90'){
                    query = query + ' and ( CreatedDate = LAST_N_DAYS: 89  or CreatedDate = TODAY ) ';
                }else if(dueDateSelected == 'last120'){
                    query = query + ' and ( CreatedDate = LAST_N_DAYS: 119  or CreatedDate = TODAY ) ';
                }else if(dueDateSelected == 'lastnext7'){
                    query = query + ' and ( CreatedDate = LAST_N_DAYS: 6  or CreatedDate = TODAY or CreatedDate = NEXT_N_DAYS : 6 ) ';
                }else if(dueDateSelected == 'lastnext14'){
                    query = query + ' and ( CreatedDate = LAST_N_DAYS: 13  or CreatedDate = TODAY or CreatedDate = NEXT_N_DAYS : 13 ) ';
                }else if(dueDateSelected == 'custom'){
                    startField = Apexpages.currentPage().getParameters().get('startField');
                    endField = Apexpages.currentPage().getParameters().get('endField');
                     system.debug('dd'+endField);
                     if(startField =='' || endField == ''){
                        query = query;
                     }else{
                        String startFieldstring = startField+'T00:00:00z';
                        String endFieldstring = endField+'T00:00:00z';
                        query = query + ' and  (CreatedDate  >= '+ startFieldstring +' '+'and CreatedDate <= '+ endFieldstring +')';
                     }
                }
            } 
            if(searchTaskText != '' && searchTaskText != null){
                searchTaskText = '%'+searchTaskText+'%';
                query = query + ' and Subject like : searchTaskText ';
            }
            query = query + ' order by CreatedDate desc limit 400';
            
            System.debug('----------query----------->'+query);
            //lstTask = [select id,Status,Stage__c,Priority,CreatedDate,Subject,OwnerId,Owner.Name from Task where WhatId = : selectedRec order by CreatedDate desc];
            lstTask = Database.query(query);
            system.debug('lstTasklstTasklstTask======'+lstTask);
        }else if(dateField =='Not_LAST_UPDATE'){
            // building dynamic query based on filters applied for task object.
            String query = 'select id,Status,Stage__c,Priority,LastModifiedDate,ActivityDate,whatId, What.Name, whoId, Who.Name,Subject,OwnerId,isClosed,Owner.Name,complexity__c,Description,createdById from Task where Subject != null and (whatId = null or whatId != null) and ( ActivityDate > TODAY or ActivityDate = TODAY or ActivityDate = null )';
            
            if(assignedId == 'AssignedTo'){
                query = query + ' and OwnerId In :userSelected';
                chkAssignedTo = true;
            } else if(assignedId == 'AssignedBy'){
                query = query + ' and CreatedById In :userSelected';
                chkUserFilter = true;
            }
            if(dueDateSelected != ''){
                if(dueDateSelected == 'Overdue'){
                    query = query + ' and ( LastModifiedDate = LAST_N_YEARS : 10 or LastModifiedDate = THIS_YEAR ) and  LastModifiedDate < TODAY and isClosed = false ';
                }else if(dueDateSelected == 'All'){
                    query = query; 
                } else if(dueDateSelected == 'today'){
                    query = query + ' and ( LastModifiedDate = NEXT_N_DAYS : 0  or LastModifiedDate = TODAY ) ';
                }else if(dueDateSelected == 'tomorrow'){
                    query = query + ' and LastModifiedDate = NEXT_N_DAYS : 1 ';
                }else if(dueDateSelected == 'yesterday'){
                    query = query + ' and ( LastModifiedDate = YESTERDAY ) ';
                }else if(dueDateSelected == 'next7'){
                    query = query + ' and ( LastModifiedDate = NEXT_N_DAYS : 6 or LastModifiedDate = TODAY) ';
                } else if(dueDateSelected == 'next30'){
                    query = query + ' and (LastModifiedDate = NEXT_N_DAYS : 29  or LastModifiedDate = TODAY )';
                } else if(dueDateSelected == 'next60'){
                    query = query + ' and ( LastModifiedDate = NEXT_N_DAYS : 59  or LastModifiedDate = TODAY ) ';
                } else if(dueDateSelected == 'next90'){
                    query = query + ' and ( LastModifiedDate = NEXT_N_DAYS : 89  or LastModifiedDate = TODAY ) ';
                }else if(dueDateSelected == 'next120'){
                    query = query + ' and ( LastModifiedDate = NEXT_N_DAYS : 119  or LastModifiedDate = TODAY ) ';
                }else if(dueDateSelected == 'last7'){
                    query = query + ' and ( LastModifiedDate = LAST_N_DAYS: 6  or LastModifiedDate = TODAY ) ';
                }else if(dueDateSelected == 'last30'){
                    query = query + ' and ( LastModifiedDate = LAST_N_DAYS: 29  or LastModifiedDate = TODAY ) ';
                }else if(dueDateSelected == 'last60'){
                    query = query + ' and ( LastModifiedDate = LAST_N_DAYS: 59  or LastModifiedDate = TODAY ) ';
                }else if(dueDateSelected == 'last90'){
                    query = query + ' and ( LastModifiedDate = LAST_N_DAYS: 89  or LastModifiedDate = TODAY ) ';
                }else if(dueDateSelected == 'last120'){
                    query = query + ' and ( LastModifiedDate = LAST_N_DAYS: 119  or LastModifiedDate = TODAY ) ';
                }else if(dueDateSelected == 'lastnext7'){
                    query = query + ' and ( LastModifiedDate = LAST_N_DAYS: 6  or LastModifiedDate = TODAY or LastModifiedDate = NEXT_N_DAYS : 6 ) ';
                }else if(dueDateSelected == 'lastnext14'){
                    query = query + ' and ( LastModifiedDate = LAST_N_DAYS: 13  or LastModifiedDate = TODAY or LastModifiedDate = NEXT_N_DAYS : 13 ) ';
                }else if(dueDateSelected == 'custom'){
                    startField = Apexpages.currentPage().getParameters().get('startField');
                    endField = Apexpages.currentPage().getParameters().get('endField');
                     //system.debug('dd'+endField);
                     if(startField =='' || endField == ''){
                        query = query;
                     }else{
                        
                        String startFieldstring = startField+'T00:00:00z';
                        String endFieldstring = endField+'T00:00:00z';
                        query = query + ' and  (LastModifiedDate  >= '+ startFieldstring +' '+'and LastModifiedDate <= '+ endFieldstring +')';
                     }
                }
            } 
            if(searchTaskText != '' && searchTaskText != null){
                searchTaskText = '%'+searchTaskText+'%'; 
                query = query + ' and Subject like : searchTaskText ';
            }
            query = query + ' order by lastModifiedDate desc limit 400';
            
            System.debug('----------query----------->'+query);
            //lstTask = [select id,Status,Stage__c,Priority,LastModifiedDate,Subject,OwnerId,Owner.Name from Task where WhatId = : selectedRec order by lastModifiedDate desc];
            lstTask = Database.query(query);
            system.debug('lstTasklstTasklstTask======'+lstTask);
        }
        List<Id> taskIds = new List<Id>();
        for(Task t : lstTask){
            taskIds.add(t.Id);
        }
        /*if(chkUserFilter != true || chkAssignedTo == true  ){
            statusCount=[SELECT count(Id),Status FROM Task where Id IN : taskIds AND OwnerId =  : userId and Subject != null group by status  limit 400];
             system.debug('statusCountstatusCountstatusCountstatusCountstatusCountstatusCountstatusCountstatusCountstatusCountstatusCountstatusCount: '+statusCount);
         }else{
            statusCount=[SELECT count(Id),Status FROM Task where Id IN : taskIds AND CreatedById =  : userId and Subject != null group by status  limit 400];
   
         } 
         if(statusCount.size() > 0){
             for(AggregateResult a:statusCount){
             }   
         }
         for(String s:statusValues){
             }*/
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
        
        //List<UserRecordAccess> lstUserAccessRecords = [SELECT RecordId,HasAllAccess,HasDeleteAccess,HasEditAccess,HasTransferAccess,HasReadAccess FROM UserRecordAccess WHERE UserId =: userinfo.getUserId() AND RecordId IN : taskIds limit 200];
        // Bulding wrapper class to show kanban cards based on filters applied.
        statusCountMap  = new Map<string,integer>();    
        delimited_string_with_map_keys ='';
        for(Task t: lstTask){
            if(readAccess != null && t != null && t.Id != null && t.whatId == null && t.whoId == null){
                /*kanBanTaskWrapper k = new kanBanTaskWrapper();
                k.kanbanTask = t;
                k.userImg = genInfo.useNameMap.get(t.OwnerId).SmallPhotoUrl;
                k.priorityImage = genInfo.imageUrlMap.get(t.Priority);
                k.recordAccess = trackAccess.get(t.id);
                kanBanTaskWrapperList.add(k);*/
                if( ! delimited_string_with_map_keys.contains(t.status ))
                delimited_string_with_map_keys +=   t.status;
                if( statusCountMap.get(t.status) == null )
                 statusCountMap.put(t.status,1);
                else
                 statusCountMap.put(   t.status,  statusCountMap.get(t.status) +  1);
                kanBanTaskWrapper k = new kanBanTaskWrapper();
                k.kanbanTask = t;
                k.taskSubject = t.Subject ;
                k.userImg = genInfo.useNameMap.get(t.OwnerId).SmallPhotoUrl;
                k.priorityImage = genInfo.imageUrlMap.get(t.Priority);
                if(t.ActivityDate != null){
                    Integer dateLeft = System.today().daysBetween(t.ActivityDate);
                    k.deadlineState = dateLeft >= 0 ? 'Positive' : 'Negative';
                    k.deadlineNum = k.deadlineState == 'Positive' ? string.valueOf(dateLeft) : string.valueOf(dateLeft).substring(1,string.valueOf(dateLeft).length());  
                }  
                
                k.relatedTo = t.What.Name != null ?  t.What.Name : t.Who.Name != null ? t.Who.Name : ' ';
                k.relatedToId = t.WhatId != null ?  t.WhatId : t.WhoId != null ? t.WhoId : null;
                k.chatterPermission = true;
                if(t.OwnerId != userinfo.getUserId()){
                    k.chatterPermission = false;
                }
                k.isClosed = t.isClosed;
                k.comments = t.Description == null ? '' : t.Description.length() > 80 ? t.Description.substring(0,77)+'...' : t.Description;
                /*   task owner assigned by*/
                k.userAssigneeName = t.Owner.Name ;
                k.userAssignImgUrl = genInfo.useImage.get(t.OwnerId) ;
                k.userAssigneeDept = genInfo.useNameMap.get(t.OwnerId).Department ;
                /* task created by assigned to*/
                k.userAssignedName = genInfo.useNameMap.get(t.CreatedById).Name ;
                k.userAssignedImgUrl = genInfo.useImage.get(t.CreatedById) ;
                k.userAssignedDept = genInfo.useNameMap.get(t.CreatedById).Department ;
                k.recordAccess = trackAccess.get(t.Id);
                k.lockImg = k.recordAccess == true ? genInfo.imageUrlMap.get('') : genInfo.imageUrlMap.get('lock');
                k.priorityValue=t.Priority;  
                kanBanTaskWrapperList.add(k);  
                    //system.debug('kanBanTaskWrapperListkanBanTaskWrapperListkanBanTaskWrapperListkanBanTaskWrapperList22'+kanBanTaskWrapperList);
            } else if(readAccess != null && t != null && t.Id != null && readAccess.get(t.Id) != null && readAccess.get(t.Id)){
                /*kanBanTaskWrapper k = new kanBanTaskWrapper();
                k.kanbanTask = t;
                k.userImg = genInfo.useNameMap.get(t.OwnerId).SmallPhotoUrl;
                k.priorityImage = genInfo.imageUrlMap.get(t.Priority);
                k.recordAccess = trackAccess.get(t.id);
                kanBanTaskWrapperList.add(k);*/
                if( ! delimited_string_with_map_keys.contains(t.status ))
                delimited_string_with_map_keys +=   t.status;
                if( statusCountMap.get(t.status) == null )
                 statusCountMap.put(t.status,1);
                else
                 statusCountMap.put(   t.status,  statusCountMap.get(t.status) +  1);
                kanBanTaskWrapper k = new kanBanTaskWrapper();
                k.kanbanTask = t;
                k.taskSubject = t.Subject ;
                k.userImg = genInfo.useNameMap.get(t.OwnerId).SmallPhotoUrl;
                k.priorityImage = genInfo.imageUrlMap.get(t.Priority);
                k.chatterPermission = true;
                if(t.ActivityDate != null){
                    Integer dateLeft = System.today().daysBetween(t.ActivityDate);
                    k.deadlineState = dateLeft >= 0 ? 'Positive' : 'Negative';
                    k.deadlineNum = k.deadlineState == 'Positive' ? string.valueOf(dateLeft) : string.valueOf(dateLeft).substring(1,string.valueOf(dateLeft).length());  
                }
                k.isClosed = t.isClosed;
                k.relatedTo = t.What.Name != null ?  t.What.Name : t.Who.Name != null ? t.Who.Name : ' ';
                k.relatedToId = t.WhatId != null ?  t.WhatId : t.WhoId != null ? t.WhoId : null; 
                k.comments = t.Description == null ? '' : t.Description.length() > 80 ? t.Description.substring(0,77)+'...' : t.Description;
                /*   task owner assigned by*/
                k.userAssigneeName = t.Owner.Name ;
                k.userAssignImgUrl = genInfo.useImage.get(t.OwnerId) ;
                k.userAssigneeDept = genInfo.useNameMap.get(t.OwnerId).Department ;
                /* task created by assigned to*/
                k.userAssignedName = genInfo.useNameMap.get(t.CreatedById).Name ;
                k.userAssignedImgUrl = genInfo.useImage.get(t.CreatedById) ;
                k.userAssignedDept = genInfo.useNameMap.get(t.CreatedById).Department ;
                k.recordAccess = trackAccess.get(t.Id);
                k.lockImg = k.recordAccess == true ? genInfo.imageUrlMap.get('') : genInfo.imageUrlMap.get('lock');
                k.priorityValue=t.Priority;  
                kanBanTaskWrapperList.add(k);  
                    //system.debug('kanBanTaskWrapperListkanBanTaskWrapperListkanBanTaskWrapperListkanBanTaskWrapperList22'+kanBanTaskWrapperList);
            } 
        }
        System.debug('-------kanBanTaskWrapperList------------>'+kanBanTaskWrapperList);
    }
    
    // Method to create new task on kanban board.
    public void createNewTask(){
        String sendingNotification = ApexPages.currentPage().getParameters().get('sendingNotification');
        string recRelatedWhatId = ApexPages.currentPage().getParameters().get('recRelatedWhatId');
        string selectedObj = ApexPages.currentPage().getParameters().get('selectedObj');
        System.debug('-------recRelatedWhatId------'+recRelatedWhatId);
        Database.DMLOptions dmlo = new Database.DMLOptions();
        if(sendingNotification == 'true')
            dmlo.EmailHeader.triggerUserEmail = true;
        else
            dmlo.EmailHeader.triggerUserEmail = false;
        
        if(FLS.taskCreateable()){
            /*if(recRelatedWhatId != null && recRelatedWhatId != ''){
                if(selectedObj != 'Contacts'){  
                    newTask.WhatId = Id.valueOf(recRelatedWhatId);
                } else {
                    newTask.WhoId = Id.valueOf(recRelatedWhatId);
                }
            }*/
            String leadPrefix = Schema.GetGlobalDescribe().get('Lead').getDescribe().getKeyPrefix();
            String sWhoId = String.Valueof(newTask.whoid);
            if(sWhoId!=null && sWhoId!='' && sWhoId.startsWith(leadPrefix) ){
                newTask.WhatId=null;
            }
            try{
                database.insert(newTask, dmlo);
            system.debug('-----'+newTask.id+leadPrefix+String.Valueof(newTask.whoid)+'-----------');
            }catch(Exception e){
                throw e;
            }
        }   
        newTask = new Task(OwnerId = UserInfo.getUserId());
        newTask.IsReminderSet = true;
    }
    
    // Method to update task record from task popup.
    @RemoteAction
    public static string updateTask(Id taskId, string status){
        //Task t = [select id from Task where id=:taskId];
        //t.priority =  protity;
        //update t;
        Task t = new Task(id=taskId,status=status);
        if(FLS.taskUpdateable()){       
            update t;
        }
        return null ;
    }
    
    // Method to update task record from task popup.
    public pageReference updateTaskDetails(){
        String lookUpRecId = ApexPages.currentPage().getParameters().get('lookUpRecId');
        String sendingNotification = ApexPages.currentPage().getParameters().get('sendingNotification');
        String selectedObjInEditTask = ApexPages.currentPage().getParameters().get('selectedObjInEditTask');
        
        Database.DMLOptions dmlo = new Database.DMLOptions();
        if(sendingNotification == 'true')
            dmlo.EmailHeader.triggerUserEmail = true;
        else
            dmlo.EmailHeader.triggerUserEmail = false;
        
        if(FLS.taskUpdateable()){
            /*if(lookUpRecId != null && lookUpRecId != ''){
                if(selectedObjInEditTask != 'Contacts'){    
                    newSelectedTask.WhatId = Id.valueOf(lookUpRecId);
                } else {
                    newSelectedTask.WhoId = Id.valueOf(lookUpRecId);
                }
            }*/
            String leadPrefix = Schema.GetGlobalDescribe().get('Lead').getDescribe().getKeyPrefix();
            String sWhoId = String.Valueof(newSelectedTask.whoid);
            if(sWhoId!=null && sWhoId!='' && sWhoId.startsWith(leadPrefix) ){
                newSelectedTask.WhatId=null;
            }
            database.update(newSelectedTask, dmlo);
        }
        
        String accountPrefix   =  Schema.Account.getSObjectType().getDescribe().getKeyPrefix();
        String contactPrefix   =  Schema.Contact.getSObjectType().getDescribe().getKeyPrefix();
        String decisionPrefix  =  Schema.Decision__c.getSObjectType().getDescribe().getKeyPrefix(); 
        String planPrefix      =  Schema.Plan__c.getSObjectType().getDescribe().getKeyPrefix();
        
        relatedToObject = 'Decisions';
        if(newSelectedTask.whatId != null){
            if(accountPrefix == (String.valueOf(newSelectedTask.whatId)).substring(0, 3)){
                relatedToObject = 'Accounts';
            } else if(contactPrefix == (String.valueOf(newSelectedTask.whatId)).substring(0, 3)){
                relatedToObject = 'Contacts';
            } else if(planPrefix == (String.valueOf(newSelectedTask.whatId)).substring(0, 3)){
                relatedToObject = 'Plans';
            } else {
                relatedToObject = 'Decisions';
            }
        }
        return null;
    }
    
    // Method to get all task details 
    public Id taskRecId {get; set;}
    public String relatedToObject {get; set;}
    public pageReference taskDetails(){
        Id taskSelectedId = ApexPages.currentPage().getParameters().get('taskSelectedId');
        String taskRecordAccess = ApexPages.currentPage().getParameters().get('recordAccess');
        String chatPermission = ApexPages.currentPage().getParameters().get('chatPermission');
        
        if(taskRecordAccess == 'true'){
            editDisable = 'true';
        } else {
            editDisable = 'false';
        }
        if(chatPermission == 'true'){
            chatDisable = true;
        } else {
            chatDisable = false;
        }
        newSelectedTask = [select id,whoid,Status,Stage__c,IsReminderSet,ReminderDateTime,Priority,ActivityDate,Subject,Skill_Level__c,Actual_Hours__c,Estimated_Hours__c,Stage_Formula__c,OwnerId,Owner.Name,complexity__c,Description,whatId,what.Name,createdById from Task where Id = : taskSelectedId];
        recId = newSelectedTask.whatId;
        recName = newSelectedTask.what.Name;
        taskId = newSelectedTask.Id;
        showTaskPopup = true;
        String accountPrefix   =  Schema.Account.getSObjectType().getDescribe().getKeyPrefix();
        String contactPrefix   =  Schema.Contact.getSObjectType().getDescribe().getKeyPrefix();
        String decisionPrefix  =  Schema.Decision__c.getSObjectType().getDescribe().getKeyPrefix(); 
        String planPrefix      =  Schema.Plan__c.getSObjectType().getDescribe().getKeyPrefix();
        
        relatedToObject = 'Decisions';
        if(newSelectedTask.whatId != null){
            if(accountPrefix == (String.valueOf(newSelectedTask.whatId)).substring(0, 3)){
                relatedToObject = 'Accounts';
            } else if(contactPrefix == (String.valueOf(newSelectedTask.whatId)).substring(0, 3)){
                relatedToObject = 'Contacts';
            } else if(planPrefix == (String.valueOf(newSelectedTask.whatId)).substring(0, 3)){
                relatedToObject = 'Plans';
            } else {
                relatedToObject = 'Decisions';
            }
        }
        
        System.debug('-------newSelectedTask--------->'+newSelectedTask);
        
        return null;
    }
    
      @RemoteAction
     public static Task getTaskById( String id,String status){
     // system.debug('++++++++++++++++++'+i v);
      Task t= new task(id=id,
      Status=status);
      update t;
      return t;
     }
    
    public class kanBanTaskWrapper{
        public string taskSubject{get;set;}
        public task kanbanTask{get;set;}
        public string userImg{get;set;}
        public string priorityImage{get;set;}
        public string priorityValue{get;set;}
        public string deadlineState{get;set;}
        public string deadlineNum{get;set;}
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
        public boolean chatterPermission{get; set;} 
        public boolean isClosed {get; set;}
    }
}