trigger TaskAfterBeforeDelete on Task (after delete, before delete) {
    /* 
    ******************************************************
    Created by:Neha
    Last Modified by: Neha
    Style: Force.com & Metro
    Description:This trigger is written to delete the task record from items of plan object.
    The objective of the trigger is when a task record is deleted all relation records associated to the task are all deleted. 
    *******************************************************
    */
        //Setting the id for task record.
        set<ID> taskID = new set<ID>();
        //To fetch the ID's of task records
        if(Trigger.isAfter){
            for (Task relatedTask : Trigger.old){
                taskID.add(relatedTask.ID); 
            }
        }
        
        if(taskID.size() > 0){
            //List of plans to be deleted form items(Plan Object)
            List<Relations__c> tasksToBeDeleted = [Select id from Relations__c where Child_ID__c In: taskID];
                delete tasksToBeDeleted;
        }
    }