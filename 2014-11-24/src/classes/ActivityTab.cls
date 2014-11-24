public with sharing class ActivityTab {    
                 
    public static String activitiesJson {get; set;} 
    
    public static GeneralInformation genralInfo;
    
    // Dynamic picklist values as string
    public String taskStatusPicklist {get;set;}
    public string taskPriorityPicklist {get;set;} 
    
    public static String dateTimeFormat {get;set;}
    public Date todayDate{get;set;} 
    
    public boolean newShowTaskPopup {get; set;}
    
    //variable to send user locale 
    public static string  userLocaleSidKey{get;set;}
    static{
            //set user locale here
            userLocaleSidKey  = UserInfo.getLocale().replace('_','-');
    } 
    public ActivityTab(WorkbenchHomePage whp){
        
        // Dynamic picklist for tasks status & language issue fixes
        Schema.Describefieldresult statusResult = Schema.sObjectType.Task.fields.Status;
        statusResult = statusResult.getSObjectField().getDescribe();
        List<Schema.PicklistEntry>  statusPickList = statusResult.getPicklistValues();
        taskStatusPicklist = '';
        newShowTaskPopup = false;
        for(Schema.PicklistEntry statusValue : statusPickList){
            taskStatusPicklist = taskStatusPicklist+  '{ \"StatusName\" :' + '\"' + statusValue.getLabel()  + '\"' + '},' ;
        }
        taskStatusPicklist  = taskStatusPicklist.substring(0,taskStatusPicklist.length()-1);
        // dynamic picklist for task priority
        Schema.DescribeFieldResult  priorityResult = Schema.sObjectType.Task.fields.Priority;
        priorityResult = priorityResult.getSObjectField().getDescribe();
        List<Schema.PicklistEntry>  priorityPickList = priorityResult.getPicklistValues();
        taskPriorityPicklist = '';
        for(Schema.PicklistEntry priorityValue : priorityPickList){
            taskPriorityPicklist = taskPriorityPicklist +  '{ \"PriorityName\" :' + '\"' + priorityValue.getLabel() + '\"' + '},' ;
        }
        taskPriorityPicklist = taskPriorityPicklist.substring(0,taskPriorityPicklist.length()-1);     
         todayDate = Date.today();
        classicTab();
    }
    
    @RemoteAction
    public static string classicTab(){
        
        if(genralInfo == null ) {
            genralInfo  = new GeneralInformation();
        }
        
        dateTimeFormat = genralInfo.MapValuesDateTime();
        
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
        
        List<Task> lstTask = [select Id,WhatId,whoId,What.Name,Who.Name,OwnerId, CreatedById,CreatedBy.Name,Owner.Name ,ActivityDate,Status,IsClosed,Priority,Subject,Description,LastModifiedDate from Task ORDER BY LastModifiedDate DESC limit 400];
        
        List<Id> taskIds = new List<Id>();
        for(Task t : lstTask){
            taskIds.add(t.Id);
        }
        
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
        Map<Id,Boolean> deleteAccess = new Map<Id,Boolean>();
        for(UserRecordAccess l : lstUserAccessRecords){
            if(trackAccess.get(l.RecordId) == null){
                trackAccess.put(l.recordId,l.HasEditAccess);
                readAccess.put(l.recordId,l.HasReadAccess);
                deleteAccess.put(l.recordId,l.HasDeleteAccess);
            }   
        }
        if(taskList2.size() > 0){
            List<UserRecordAccess> lstUserAccessRecords1 = [SELECT RecordId,HasAllAccess,HasDeleteAccess,HasEditAccess,HasTransferAccess,HasReadAccess FROM UserRecordAccess WHERE UserId =: userinfo.getUserId() AND RecordId IN : taskList2 limit 200];   
            for(UserRecordAccess l : lstUserAccessRecords1){
                if(trackAccess.get(l.RecordId) == null){
                    trackAccess.put(l.recordId,l.HasEditAccess);
                    readAccess.put(l.recordId,l.HasReadAccess);
                    deleteAccess.put(l.recordId,l.HasDeleteAccess);
                }   
            }
        }
        
        List<ActivitiesTaskEvent> taskEventList = new List<ActivitiesTaskEvent>();
        // Binding wrraper list with all the task records.
        for(Task task: lstTask){
            if(readAccess != null && task.Id != null && readAccess.get(task.Id) != null && readAccess.get(task.Id)){
                ActivitiesTaskEvent act = new ActivitiesTaskEvent();
                act.id = task.Id;
                act.subject = task.Subject != null ? task.Subject.capitalize() : '';
                act.isTask = 'Task';
                act.ownerId = task.OwnerId;
                act.duedate = task.ActivityDate == null ? '' : genralInfo.MapValuesDate(String.valueOf(task.ActivityDate.day()), String.valueOf(task.ActivityDate.month()), String.valueOf(task.ActivityDate.year()));
                act.delayTaskClass = task.ActivityDate < date.today() && !task.IsClosed ? 'delayTask' : task.ActivityDate == null ? 'emptyDuedate' : '';
                act.priority = taskpriority.get(task.Priority) == null ?  task.Priority: taskpriority.get(task.Priority);
                act.createdByName = task.Owner.Name;
                act.comments = task.Description == null ? '' : task.Description.length() > 50 ? task.Description.replaceAll('\"','\'').substring(0,50) + '...' : task.Description.replaceAll('\"','\'');
                act.isDeletable= false;
                act.isEditable = false;
                act.actionClassNameDelete = 'grid-action-disabled';
                act.Status = taskstatus.get(task.Status) == null ? task.Status : taskstatus.get(task.Status) ;
                act.url = '/'+act.Id+'?retURL='+task.WhatId;
                act.lastActivityDate = task.LastModifiedDate.format();
                act.assignedByName = task.CreatedBy.Name;
                act.assignedBy = task.CreatedById;
                act.relatedToName = task.WhatId != null ? task.What.Name : task.whoId != null ? task.Who.Name : '';
                act.relatedToId = task.WhatId != null ? String.valueof(task.WhatId) : task.whoId != null ? String.valueof(task.WhoId) : '';
                act.recordAccess = trackAccess != null && trackAccess.get(task.Id) != null && trackAccess.get(task.Id) ? trackAccess.get(task.Id) : false;
                act.title = trackAccess != null && trackAccess.get(task.Id) != null && trackAccess.get(task.Id) ? 'Edit' : '';
                act.icon = genralInfo.imageUrlMap.get('activity');
                System.debug('---------deleteAccess.get(task.Id)------------>'+deleteAccess.get(task.Id));
                System.debug('---------task.id------------>'+task.id);
                act.deleteImage = deleteAccess != null && deleteAccess.get(task.Id) != null ? genralInfo.deleteImage.get(deleteAccess.get(task.Id)) : '';
                
                // start added on 25-04-2014
                act.lastActivityDateSort = task.LastModifiedDate!=null ? task.LastModifiedDate :null;
                act.duedateSort = task.ActivityDate != null ? task.ActivityDate : null;
                // end added on 25-04-2014
                taskEventList.add(act);
            }
        }
        
        activitiesJson = JSON.serialize(taskEventList);
        return activitiesJson;
    }
    
    @RemoteAction
    public static string updateActivities(string jsonModifiedData){
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
        
        List<ActivitiesTaskEvent> taskEventList = (List<ActivitiesTaskEvent>)System.JSON.deserialize(jsonModifiedData, List<ActivitiesTaskEvent>.class);
        
        set<Id> setIds = new set<Id>();
        for(ActivitiesTaskEvent ate : taskEventList){
            setIds.add(ate.id);
        }
        
        List<Task> lstTask = [select Id,WhatId,whoId,What.Name,Who.Name,OwnerId, CreatedById,CreatedBy.Name,Owner.Name ,ActivityDate,Status,IsClosed,Priority,Subject,Description,LastModifiedDate from Task where Id IN : setIds];
        
        for(Task t : lstTask){
            for(ActivitiesTaskEvent ate : taskEventList){
                if(t.Id == ate.id){
                    if(ate.subject != null){	
                    	t.Subject = ate.subject.length() > 255 ? ate.subject.substring(0,254) : ate.subject;
                    }
                    /*if(ate.duedate != null && ate.duedate.length() > 10)
                        t.ActivityDate = Date.valueOf(ate.duedate).addDays(1);
                    */
                    if(ate.duedateSort != null && String.Valueof(ate.duedateSort).length() > 0){
                        t.ActivityDate = ate.duedateSort.Date();
                    } else if(ate.duedateSort == null){
                    	t.ActivityDate = null;
                    }
                        
                    t.status = taskstatus.get(ate.status) == null ? ate.status : taskstatus.get(ate.status);
                    t.priority = taskpriority.get(ate.priority) == null ? ate.priority: taskpriority.get(ate.priority);
                }
            }
        }
        
        if(!lstTask.isEmpty() && FLS.taskUpdateable()){
            update lstTask;
        }
        
        String updatedJson = classicTab();
        return updatedJson;
    }
    
    //render task popup onclick of new task button 
    public void newTaskPopupComponent(){
    	newShowTaskPopup = newShowTaskPopup == true ? false : newShowTaskPopup == false ? true : false;
    	System.debug('------Executed------->');
    }
    
    //Wrapper class for activties tab (Plan object)
    public class ActivitiesTaskEvent {
        public String id {get;set;}
        public String subject {get;set;}
        public String status {get;set;}
        public String isTask {get;set;}
        public String duedate {get;set;} 
        public String priority {get;set;} 
        public String createdByName {get;set;}
        public Boolean isEditable {get;set;}
        public Boolean isDeletable {get;set;}
        public String deleteImage {get;set;}
        public string url {get;set;}
        public String comments {get; set;} 
        public string delayTaskClass {get;set;}
        public String subjectClassLink {get; set;}
        public String actionClassNameDelete {get;set;}
        public String ownerId {get; set;}
        public String title {get; set;}
        public String icon {get; set;}
        public String lastActivityDate {get; set;}
        public String assignedByName {get; set;}
        public String assignedBy {get; set;}
        public String relatedToName {get; set;}
        public String relatedToId {get; set;}
        public Boolean recordAccess {get; set;}
        
        // added on 25-04-2014
        public datetime lastActivityDateSort {get; set;}
        public dateTime duedateSort {get;set;}
        // added on 25-04-2014
    }
}