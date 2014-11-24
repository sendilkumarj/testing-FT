trigger TaskAfterBeforeInsert on Task (after insert, before insert) {
    /*
    **************************************************
    Created by:Neha
    Last Modified by: Neha
    Style: Force.com & Metro
    Description: The objective of this trigger is to bold and unbold the number of records within the tab.
                 If a new record is added to the task object and the user has not visited the tab since the addition of the new record then the number on tab will be bold indicating the user to view the tab, else this number is unbold.   
                 Also the task comment field should be added as feed comment below the task feed item on task chatter.
    ***************************************************
    */
    if(trigger.isBefore){
    	for(Task t : Trigger.new){
	        if(t.isClosed || t.Status == 'Completed' || t.Status == 'N/A' || t.Status == 'Rejected' || t.Status == 'Closed'){
	        	t.Task_Closed_Date__c = System.today();
	        } else {
	        	t.Task_Closed_Date__c = null;
	        }
	        System.debug('-------t.Task_Closed_Date__c-------->'+t.Task_Closed_Date__c);
        }
    }
    RankingDatabaseDefination rdd = new RankingDatabaseDefination();
    if(trigger.isAfter){
        //Setting the id for decision record.
        set<ID> parentID = new set<ID>();
        
        set<ID> userID = new set<ID>();
        for(Task tsk : Trigger.new){
            userID.add(tsk.OwnerID);
        }
        // To check whether the object is decision or plan dynamically
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
                System.debug('--------Decision or Plan--------->'+tempPrefix);
                objectList.add(tempPrefix);
                x = tempPrefix;
                if(tempName.contains('Decision__c')){
                	decisionObj = tempPrefix;
                } else if(tempName.contains('Plan__c')){
                	planObj = tempPrefix;
                }
            }
         }
        
        // This code is commented bcoz now this requirement is not needed based on (R17-2-US-01) .
        // This code is to generate a chatter post when a task is closed on respective parent object (plan/decision).
        /*List<FeedItem> feedItemList =  new  List<FeedItem>(); 
        for(Task t : Trigger.new){
            if(trigger.isAfter){
                if(t.whatId != null ) {
                    String objetId = (String.valueOf(t.whatId)).substring(0, 3);
                    if(objectList.contains(objetId)) {
                       // Task tupdate = System.trigger.oldMap.get(t.id);
                        if(t.IsClosed){
                            FeedItem post = new FeedItem();
                            post.ParentId = t.whatid;
                            post.Body = Userinfo.getName()  + ' closed the task:';
                            post.title = t.subject;
                            post.LinkUrl = '/'+ t.id;
                            feedItemList.add(post);
                           //insert post;
                                       
                        }
                    }
                }
            }
        }
        
        insert feedItemList;*/
        
        //To fetch the ID's of note records
        List<Social_Input__c> toBeUpdatedSocialInputList = new List<Social_Input__c>();
        
        for (Task task : Trigger.new){
            if(task.whatid != null ) {
                parentID .add(task.whatid);
            }
        } 
        
        if(parentID.size() > 0){
            //This contains list of tasks record related to decision to be updated
            List<Social_Input__c> decisionTaskRecord = [Select id, SYS_Tab_View_Tasks__c from Social_Input__c where Decision__c In: parentID Or Plan__c In: parentID];
            //This is used for iterating each task record for decision and updating the checkbox  value to true
           
                for(Social_Input__c socialInput: decisionTaskRecord) {
                    socialInput.SYS_Tab_View_Tasks__c = true;
                    //This updates the list of note records.
                    toBeUpdatedSocialInputList.add(socialInput);
                }
           
        }
        
        if(toBeUpdatedSocialInputList.size() > 0) {
            update toBeUpdatedSocialInputList;
        }
        
        // Creating feed comments when a comment is given is task comment under feeditem.
        // (R18-2-US-02) Comment written in the Task should be propagated to the Decision Chatter
        set<Id> taskIds = new set<Id>();
        map<Id,String> mapComments = new map<Id,String>();
        map<Id,String> mapStatus = new map<Id,String>();
        for(Task t : Trigger.new){
        	if(t.whatId != null){
        		String objetId = (String.valueOf(t.whatId)).substring(0, 3); // taking first 3 char's of parentid
        		taskIds.add(t.Id); // Collecting all the task ids that are inserted
        		if(objectList.contains(objetId)) { // to check parentid is plan or decision
        			if(t.Description != null) { // Checking for task parentid should not be empty and comment should not be empty
        				mapComments.put(t.Id,t.Description); // mapping task id with task comment
        			}
        			if(t.IsClosed){	
                    	mapStatus.put(t.Id,t.Status); // mapping task id with task status
                    }
        		}
        	}
        }
        // Calling future method to insert feedcomment under task feeditem.
        FutureMethodController.insertFeedComments(taskIds,mapComments,'Insert');
        if(!mapStatus.isEmpty()){
        	// Calling future method to insert feedcomment under task feeditem when a task is closed.
        	FutureMethodController.closeChatterComment(taskIds,mapStatus);
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
	        for(Task t : trigger.new){
		        if(t.CreatedById == t.OwnerId){	
		        	rdd.calculatePoints('Create a task for self', '');
		        } else if(t.CreatedById != t.OwnerId){
		        	rdd.calculatePoints('Create a task for other', '');
		        }
	        }
        }
    }
}