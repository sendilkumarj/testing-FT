trigger TaskAfterBeforeUpdate on Task (after update, before update) {
    /*
    ******************************************************
    Created by:Neha
    Last Modified by: Neha
    Style: Force.com & Metro
    Description: This trigger is used to update the title/subject of the task record.
                 If a user edits the task title/subject, it should also update the title/subject for related items list that are displayed on plan items list.
                 Also the task comment field should be added as feed comment below the task feed item on task chatter whenever the comments are updated.
    ******************************************************
    */
    if(Trigger.isBefore){
    	
    	// This code is commented because this task is on hold.
    	// When a user creates a task who do not have permission should restrict to create a task.
        /*set<Id> parentIds = new set<Id>();
        for(Task t : Trigger.new){
            parentIds.add(t.whatId);
        }
        Map<Id,List<Social_Input__c>> decisionSocialInputMap = new Map<Id,List<Social_Input__c>>();
        List<Social_Input__c> lstSocInput = new List<Social_Input__c>();
        List<Social_Input__c> lstSocialInput = [select id,Accountable__c,Responsible__c,Consulted__c,Backup_for_Accountable__c,Informed__c,Decision__c,Plan__c from Social_Input__c where Decision__c IN : parentIds or Plan__c IN : parentIds];
        for(Social_Input__c si : lstSocialInput){
            if(si.Decision__c != null){
                if(decisionSocialInputMap.get(si.Decision__c) == null){
                    lstSocInput = new List<Social_Input__c>();
                    lstSocInput.add(si);
                    decisionSocialInputMap.put(si.Decision__c,lstSocInput);
                } else {
                    decisionSocialInputMap.get(si.Decision__c).add(si);
                }
            }
            if(si.Plan__c != null){
                if(decisionSocialInputMap.get(si.Plan__c) == null){
                    lstSocInput = new List<Social_Input__c>();
                    lstSocInput.add(si);
                    decisionSocialInputMap.put(si.Plan__c,lstSocInput);
                } else {
                    decisionSocialInputMap.get(si.Plan__c).add(si);
                }
            }
        }
        for(Task t : Trigger.new){
            if(decisionSocialInputMap != null && decisionSocialInputMap.get(t.whatId) != null){
                List<Social_Input__c> lstSI = new List<Social_Input__c>();
                lstSI = decisionSocialInputMap.get(t.whatId);
                for(Social_Input__c si : lstSI){
                    if(t.WhatId == si.Decision__c || t.WhatId == si.Plan__c){
                        if(!(si.Responsible__c || si.Accountable__c || si.Backup_for_Accountable__c || t.OwnerId == Userinfo.getUserId())){
                            t.addError('You do not have permission to edit this task.');
                        }
                    }
                }
            }
        }*/
        for(Task t : Trigger.new){
	        if(t.isClosed || t.Status == 'Completed' || t.Status == 'N/A' || t.Status == 'Rejected' || t.Status == 'Closed'){
	        	t.Task_Closed_Date__c = System.today();
	        } else {
	        	t.Task_Closed_Date__c = null;
	        }
        }
    }
    if(Trigger.isAfter){
        //Setting the id for task record.
        set<ID> taskID = new set<ID>();
        
        //Setting the id for user.
        set<ID> userID = new set<ID>();
        for(Task tsk : Trigger.new){
            userID.add(tsk.OwnerID);
        }
        
        set<String> objectList = new set<String>();
        String x; 
        String planObj;
        String decisionObj; 
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        for(String sObj : Schema.getGlobalDescribe().keySet()){
            Schema.DescribeSObjectResult r =  gd.get(sObj).getDescribe();
            String tempName = r.getName();
            String tempPrefix = r.getKeyPrefix();
            System.debug('Processing Object['+tempName + '] with Prefix ['+ tempPrefix+']');
            if(tempName.equals('fingertip_a__Decision__c') || tempName.equals('Decision__c') || tempName.equals('fingertip_a__Plan__c') || tempName.equals('Plan__c')) {
                System.debug(tempPrefix);
                objectList.add(tempPrefix);
                x = tempPrefix;
                if(tempName.contains('Decision__c')){
                	decisionObj = tempPrefix;
                } else if(tempName.contains('Plan__c')){
                	planObj = tempPrefix;
                }
            }
         }
         System.debug(x);
        
        // This code is commented bcoz now this requirement is not needed based on (R17-2-US-01).
        // This code is to generate a chatter post when a task is closed on respective parent object (plan/decision).
        /*List<FeedItem> lstFeedItems = new List<FeedItem>();
        for(Task t : Trigger.new){
            if(Trigger.isAfter){
                System.debug('-----t.whatId------>'+t.whatId);
                if(t.whatId != null ) {
                    String objetId = (String.valueOf(t.whatId)).substring(0, 3);
                    if(objectList.contains(objetId)) {
                        Task tupdate = System.trigger.oldMap.get(t.id);
                        if(tupdate.Status != t.Status && t.IsClosed){
                           
                            FeedItem post = new FeedItem();
                            post.ParentId = t.whatid;
                            post.Body = Userinfo.getName()  + ' closed the task:';
                            post.title = t.subject;
                            post.LinkUrl ='/'+t.Id;
                            lstFeedItems.add(post);
                        }
                    }
                }
            }
        }
        if(!lstFeedItems.isEmpty()){
            insert lstFeedItems;
        }*/
        //To fetch the ID of task record
        for (Task relatedTasks : Trigger.old){
            taskID.add(relatedTasks.ID);
        }
        
        if(taskID.size() > 0){
            Map<Id,String> taskMap = new map<Id,String>();
            List<Task> tasksList = [select id,Subject from Task where id In: taskID];
            for(Task task :tasksList){
                taskMap.put(task.Id,task.Subject);
            }
            //This is used for iterating the list one by one where a single record(task) is getting updated.
            List<Relations__c> relatedItemsList = new List<Relations__c>();
            //This consists the list of notes record that needs to be updated.
            List<Relations__c> tasksToBeUpdated = new List<Relations__c>();
            relatedItemsList = [select id,Child_ID__c,Child_Record_Name__c from Relations__c where Child_ID__c In: taskID];
            //This is used for iterating each items record and also updating the record subject to new value.
            for(Relations__c updatedTaskRecord : relatedItemsList){
                updatedTaskRecord.Child_Record_Name__c = taskMap.get(updatedTaskRecord.Child_ID__c);
                tasksToBeUpdated.add(updatedTaskRecord);
            }
            update tasksToBeUpdated;
        }
        // Creating feed comments when a comment is given is task comment under feeditem.
        // (R18-2-US-02) Comment written in the Task should be propagated to the Decision Chatter
        set<Id> taskIds = new set<Id>();
        map<Id,String> mapComments = new map<Id,String>();
         map<Id,String> mapStatus = new map<Id,String>();
        for(Task t : Trigger.new){
        	if(t.whatId != null){
	            String objetId = (String.valueOf(t.whatId)).substring(0, 3); // taking first 3 char's of parentid
	            if(objectList.contains(objetId)) {  // to check parentid is plan or decision
	                taskIds.add(t.Id); // Collecting all the task ids for which comments are changed
	                System.debug('----------t.Description------->'+t.Description);
	                System.debug('----------Trigger.oldMap.get(t.Id).Description------->'+Trigger.oldMap.get(t.Id).Description);
	            	if(t.Description != Trigger.oldMap.get(t.Id).Description) { // Checking for task parentid should not be empty and old comment should not be same as new comment
	                    mapComments.put(t.Id,t.Description); // mapping task id with task comment
	                }
	                if(Trigger.oldMap.get(t.Id).Status != t.Status && t.IsClosed){	// Checking for the task status change and task is closed.
	                	mapStatus.put(t.Id,t.Status);  // mapping task id with task status
	                }
	            }
        	}
        }
        // Calling future method to insert feedcomment under task feeditem.
        if(!mapComments.isEmpty()){	
        	FutureMethodController.insertFeedComments(taskIds,mapComments,'Update');
        }
        System.debug('----------mapStatus------->'+mapStatus);
        if(!mapStatus.isEmpty()){
        	// Calling future method to insert feedcomment under task feeditem when a task is closed.
        	FutureMethodController.closeChatterComment(taskIds,mapStatus);
        }
        set<Id> taskNewIds = new set<Id>();
        for(Task t : Trigger.new){
            if(t.WhatId != null && t.Description == null && Trigger.oldMap.get(t.Id).Description != null){ // Checking for task parentid should not be empty. The task comment is updated to null/empty and old comment should have value
                String objetId = (String.valueOf(t.whatId)).substring(0, 3); // taking first 3 char's of parentid
                if(objectList.contains(objetId)) { // to check parentid is plan or decision
                    taskNewIds.add(t.Id); // Collecting all the task ids for which comments are changed to null.
                }
            }
        } 
        // Calling future method to insert feedcomment and put the value as 'Task comment field content deleted.'
        if(!taskNewIds.isEmpty()){	
        	FutureMethodController.insertNullFeedComment(taskNewIds);
        }
        
        set<Id> planIds = new set<Id>();
        set<Id> decisionIds = new set<Id>();
        for(Task t : Trigger.new){
        	if(t.WhatId != null){
        		String objetId = (String.valueOf(t.whatId)).substring(0, 3); // taking first 3 char's of parentid
        		if(decisionObj == objetId){
        			decisionIds.add(t.whatId);
        		} else if(planObj == objetId){
        			planIds.add(t.whatId);
        		}
        	}
        }
        
        FutureMethodController.decisionPlanRecordsUpdate(decisionIds,planIds);
        /*if(!decisionIds.isEmpty()){
	        List<Decision__c> lstDecision = [select id,Update_Manager__c from Decision__c where Id IN : decisionIds];
	        for(Decision__c d : lstDecision){
	        	d.Update_Manager__c = d.Update_Manager__c + 1;
	        }
	        if(!lstDecision.isEmpty()){
	        	update lstDecision;
	        }
    	}
        if(!planIds.isEmpty()){	
        	List<Plan__c> lstPlan = [select id,Update_Manager__c from Plan__c where Id IN : planIds];
        	for(Plan__c p : lstPlan){
        		p.Update_Manager__c = p.Update_Manager__c + 1;
        	}
        	if(!lstPlan.isEmpty()){
        		update lstPlan;
        	}
        }*/
        PermissionSet permissionset = new PermissionSet();
        List<PermissionSet> permissionsetAccess = new List<PermissionSet>();
        List<ObjectPermissions> objPermissins = new List<ObjectPermissions>();
        try { 
            permissionset = [SELECT Id FROM PermissionSet where ProfileId=:userinfo.getProfileId() Limit 1];
            objPermissins = [SELECT Id,PermissionsModifyAllRecords FROM ObjectPermissions WHERE SobjectType = 'Decision__c' AND ParentId = :permissionset.Id Limit 1 ]; 
        } catch (exception e){
            permissionsetAccess = [SELECT Id FROM PermissionSet where Name = 'Fingertip_Access' Limit 1];
        } 
        if(permissionsetAccess.size() > 0 || objPermissins.size() > 0){
	        set<Id> lowIds = new set<Id>();
	        set<Id> highIds = new set<Id>();
	        set<Id> mediumIds = new set<Id>();
	        for(Task t : Trigger.new){
	        	if(t.IsClosed != Trigger.oldMap.get(t.Id).IsClosed){
		        	if(t.IsClosed && t.ActivityDate < System.today()){
		        		if(t.Priority == 'Low'){
		        			lowIds.add(t.OwnerId);
		        		}
		        		if(t.Priority == 'High'){
		        			highIds.add(t.OwnerId);
		        		}
		        		if(t.Priority == 'Normal'){
		        			mediumIds.add(t.OwnerId);
		        		}
		        	}
	        	}
	        }
	        RankingDatabaseDefination.missingTaskDeadline(lowIds,'low');
	        RankingDatabaseDefination.missingTaskDeadline(highIds,'high'); 
	        RankingDatabaseDefination.missingTaskDeadline(mediumIds,'medium');
        }
    }
}