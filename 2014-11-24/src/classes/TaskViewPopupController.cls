public without   sharing class TaskViewPopupController {
	
	
	public String taskId;
	
	public String gettaskIdToEdit(){
        return taskId;
    }
    //set method to pass task id from vf pages
    public void settaskIdToEdit(String taskSelectedId){
        System.debug('-------taskSelectedId------->'+taskSelectedId);
        System.debug('-------taskRecId------->'+taskRecId);
        if(taskSelectedId != taskRecId){
	        showTaskDetails();
	        taskId = taskSelectedId;
        }
    }
    
	public Id taskRecId {get; set;}
	public Id taskChatterId {get; set;}
	public Task newSelectedTask {get; set;}
	
	public TaskViewPopupController(){
		
	}
	// Fetching task details on load of task popup and on update of task data on popup.
	public void showTaskDetails(){
		if(taskId != null){
			System.debug('-------taskId------->'+taskId);
			taskRecId = Id.valueOf(taskId);
			taskChatterId = Id.valueOf(taskId);
			String sendingNotification = ApexPages.currentPage().getParameters().get('sendingNotification');
			if(sendingNotification == null){	
				newSelectedTask = [select id,whoid,Status,Stage__c,IsReminderSet,ReminderDateTime,Priority,ActivityDate,Subject,Skill_Level__c,Actual_Hours__c,Estimated_Hours__c,Stage_Formula__c,OwnerId,Owner.Name,complexity__c,Description,whatId,what.Name,createdById from Task where Id = : Id.valueOf(taskId)];
			}
		}
		taskRecId = null;
	}
	
	// Method to update task record from task popup.
    public void updateTaskDetails(){
        String sendingNotification = ApexPages.currentPage().getParameters().get('sendingNotification');
        System.debug('----------sendingNotification---------->'+sendingNotification);
        
        Database.DMLOptions dmlo = new Database.DMLOptions();
        if(sendingNotification == 'true')
            dmlo.EmailHeader.triggerUserEmail = true;
        else
            dmlo.EmailHeader.triggerUserEmail = false;
        
        if(FLS.taskUpdateable()){
            String leadPrefix = Schema.GetGlobalDescribe().get('Lead').getDescribe().getKeyPrefix();
            String sWhoId = String.Valueof(newSelectedTask.whoid);
            if(sWhoId!=null && sWhoId!='' && sWhoId.startsWith(leadPrefix) ){
            	newSelectedTask.WhatId=null;
            }
            System.debug('----------newSelectedTask---------->'+newSelectedTask);
           //update newSelectedTask;
           
           database.update(newSelectedTask, dmlo); 
        }
    }
}