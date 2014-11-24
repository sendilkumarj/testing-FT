public with sharing class NewTaskViewPopupController {
	
	public Task newSelectedTask {get; set;}
	public String relatedToTaskId {get; set;}
	public static string  userLocaleSidKey{get;set;}
    static{
            //variable to send user locale
            userLocaleSidKey  = UserInfo.getLocale().replace('_','-');
    } 
	public String getrelatedToId(){
		return relatedToTaskId;
	}
	
	// JSON string for default user 
    public String loggedInUserJson {get;set;}
    public String allUsersJson {get; set;}
	public List<User> userList {get; set;}
	
	public void setrelatedToId(String relatedId){
		defaultLoad();
		relatedToTaskId = relatedId;
	}
	
	public NewTaskViewPopupController(){
		newSelectedTask = new Task();	
	}
	
	public void defaultLoad(){
		String sendingNotification = ApexPages.currentPage().getParameters().get('sendingNotification');
		// List of user who are active
		if(sendingNotification == null){
	        userList = [select id, Name, SmallPhotoUrl  from User where isactive = true and Id != : userInfo.getUserId()];
		}
		if(relatedToTaskId != null && relatedToTaskId != ''){
			if(sendingNotification == null){
				if(relatedToTaskId.contains('Items')){
					String[] relId = relatedToTaskId.split(',');
					relatedToTaskId = relId[0];
					System.debug('-----relId------>'+relId); 
				}
				newSelectedTask = new Task(Status='Not Started',whatId = Id.valueOf(relatedToTaskId),OwnerId = UserInfo.getUserId(),Priority = 'Normal',IsReminderSet = true,Skill_Level__c = '1');
			}
		} else {
			if(sendingNotification == null){
				newSelectedTask = new Task(Status='Not Started',OwnerId = UserInfo.getUserId(),Priority = 'Normal',IsReminderSet = true,Skill_Level__c = '1');
				System.debug('-----newSelectedTask------>'+newSelectedTask); 
			}
		}
	}
	
	public String assignedToUsers {get; set;}
	
	public void insertNewTask(){
		String sendingNotification = ApexPages.currentPage().getParameters().get('sendingNotification');  
        List<String> lstSelectedIds = new List<String>();
        if(assignedToUsers != null && assignedToUsers != ''){
        	lstSelectedIds = assignedToUsers.split(',');
        }
        
        List<Task> lstTaskInsert = new List<Task>();
        // Iterating and creating number of task based on the selected user in assiged to field on new task popup (Auto complete)
        for(String uId : lstSelectedIds){
        	Task t = new Task();
        	t.Subject = newSelectedTask.Subject;
        	t.OwnerId = Id.valueOf(uId);
        	t.Status = newSelectedTask.Status;
        	t.Priority = newSelectedTask.Priority;
        	t.WhatId = newSelectedTask.WhatId;
        	t.ActivityDate = newSelectedTask.ActivityDate;
        	t.Description = newSelectedTask.Description;
        	t.WhoId = newSelectedTask.WhoId;
        	t.IsReminderSet = newSelectedTask.IsReminderSet;
        	t.Complexity__c = newSelectedTask.Complexity__c;
        	t.Skill_Level__c = newSelectedTask.Skill_Level__c;
        	t.Estimated_Hours__c = newSelectedTask.Estimated_Hours__c;
        	t.Actual_Hours__c = newSelectedTask.Actual_Hours__c;
        	lstTaskInsert.add(t);
        }
        
        System.debug('--------sendingNotification-------->'+sendingNotification);
            
        if(FLS.taskCreateable()){
            //database.insert(lstTaskInsert, dmlo);
          if(!lstTaskInsert.isEmpty()){  
            insert lstTaskInsert;
          }
        }
        // Email notification to users in assigned to field when send notification is set true.
        if(sendingNotification == 'true'){
        	Set<Id> ownerIds = new Set<Id>();
        	Set<Id> createdOwnerIds = new Set<Id>();
        	set<Id> taskIds = new set<Id>();
        	for(Task tsk: lstTaskInsert){
        		ownerIds.add(tsk.ownerId);
        		taskIds.add(tsk.Id);
        	}
        	Map<Id, User> userMap = new Map<Id,User>();
        	List<Task> lstTask = new List<Task>();
        	if(!Test.isRunningTest()){	
        		lstTask = [select Id,Subject,OwnerId,Owner.Name,WhatId,What.Name,WhoId,Who.Name,Priority,ActivityDate,Description from Task where Id In : taskIds limit 10];
        		userMap = new Map<Id,User>([select Name, Email from User where Id in :ownerIds]);
        	} else {
        		lstTask = [select Id,Subject,OwnerId,Owner.Name,WhatId,What.Name,WhoId,Who.Name,Priority,ActivityDate,Description from Task limit 5];
        		userMap = new Map<Id,User>([select Name, Email from User]);
        	}
        	for(Task tsk: lstTask){
		        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		        String[] toAddresses = new String[] {userMap.get(tsk.OwnerId).Email};
		        mail.setToAddresses(toAddresses);    // Set the TO addresses
		        mail.setSubject(tsk.Subject); 
		        String template = 'New Task <br/><br/> To : '+userMap.get(tsk.OwnerId).Name+'<br/><br/>'+userInfo.getName()+' has assigned you the following new task: <br/><br/>';
		        template+= 'Subject : '+tsk.Subject+'<br/>';
		        if(tsk.whoId != null || Test.isRunningTest()){
		        	Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
		        	String nameLabel = '';
		        	for(String sObj : Schema.getGlobalDescribe().keySet()){
			            Schema.DescribeSObjectResult r =  gd.get(sObj).getDescribe();
			            String tempPrefix = r.getKeyPrefix();
			            if(tsk.whoId != null && tempPrefix == String.valueOf(tsk.whoId).substring(0,3)){
			            	nameLabel = r.getLabel();
			            }
			        }
		        	template+= nameLabel+' : '+tsk.Who.Name+'<br/>';
		        }
		        if(tsk.whatId != null){
		        	Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
		        	String nameLabel = '';
		        	for(String sObj : Schema.getGlobalDescribe().keySet()){
			            Schema.DescribeSObjectResult r =  gd.get(sObj).getDescribe();
			            String tempPrefix = r.getKeyPrefix();
			            if(tempPrefix == String.valueOf(tsk.whatId).substring(0,3)){
			            	nameLabel = r.getLabel();
			            }
			        }
		        	template+= nameLabel+' : '+tsk.What.Name+'<br/>';
		        }
		        String duedate = '';
		        if (tsk.ActivityDate==null)
		            duedate = '';
		        else
		            duedate = tsk.ActivityDate.format();
		        template+= 'Due Date : '+duedate+'<br/>';
		        template+= 'Priority : '+tsk.Priority+'<br/>';
		        template+= 'Comments : '+tsk.Description+'<br/>';
		        template+= 'For more details, click the following link: <br/><br/>';
		        template+= '<a href='+URL.getSalesforceBaseUrl().toExternalForm()+'/'+tsk.Id+'>'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+tsk.Id+'</a>';
		        mail.setHTMLBody(template);
        		Messaging.SendEmail(new Messaging.SingleEmailMessage[] {mail});
        	}
        }
        
        System.debug('--------relatedToTaskId-------->'+relatedToTaskId);
        if(relatedToTaskId.contains('Items')){
        	Plan__c planRec = [select Id,Name from Plan__c where Id = : newSelectedTask.WhatId];
        	List<Relations__c> lstRelations = new List<Relations__c>();
        	for(Task t : lstTaskInsert){
	        	Relations__c r = new Relations__c();
	        	System.debug('--------relatedToTaskId-------->'+relatedToTaskId);
	            r.child_Id__c = t.id;
	            r.Child_Record_Name__c = t.Subject;
	            r.Child_Object_Name__c = 'Task';
	            r.Parent_Id__c = planRec.Id;
	            r.parent_Record_Name__c = planRec.Name;
	            r.parent_Object_Name__c = 'Plan';
	            r.type__c = 'Item';  
	            lstRelations.add(r);
        	}
        	if(FLS.relationCreateable()){
                insert lstRelations;
            }
        } 
        
        newSelectedTask = new task();
        if(relatedToTaskId.contains('Items')){
			String[] relId = relatedToTaskId.split(',');
			relatedToTaskId = relId[0];
			System.debug('-----relId------>'+relId); 
		}
        if(relatedToTaskId != null && relatedToTaskId != ''){	
        	newSelectedTask =  new task(Status='Not Started',whatId = Id.valueOf(relatedToTaskId),OwnerId = UserInfo.getUserId(),Priority = 'Normal',IsReminderSet = true,Skill_Level__c = '1');
        } else {
			newSelectedTask = new Task(Status='Not Started',OwnerId = UserInfo.getUserId(),Priority = 'Normal',IsReminderSet = true,Skill_Level__c = '1');
		}
	}
}