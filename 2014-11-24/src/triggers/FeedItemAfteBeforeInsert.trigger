/*
**************************************************
Created by:Neha
Last Modified by: Neha
Style: Force.com & Metro
Description: The objective of the trigger is to update the parent last modified date of an object based on chatter feeds.
             Any post or an feed is inserted to decision or plan object the last modified date is updated.
***************************************************
*/
    
trigger FeedItemAfteBeforeInsert on FeedItem (after insert, before insert) {
	if(trigger.isAfter){
		//To check whether the object is decision or plan dynamically
        set<String> objectList = new set<String>();
        String x;
        String planObj;
        String decisionObj; 
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        for(String sObj : Schema.getGlobalDescribe().keySet()){
            Schema.DescribeSObjectResult r =  gd.get(sObj).getDescribe();
            String tempName = r.getName();
            String tempPrefix = r.getKeyPrefix();
            if(tempName.equals('fingertip_a__Decision__c') || tempName.equals('Decision__c') || tempName.equals('fingertip_a__Plan__c') || tempName.equals('Plan__c')) {
                objectList.add(tempPrefix);
                x = tempPrefix;
                if(tempName.contains('Decision__c')){
                	decisionObj = tempPrefix;
                } else if(tempName.contains('Plan__c')){
                	planObj = tempPrefix;
                }
            }
        }
        // To fetch the first 3 characters of an object id.  
        set<Id> planIds = new set<Id>();
        set<Id> decisionIds = new set<Id>();
        for(FeedItem f : Trigger.new){
        	if(f.ParentId != null){
        		String objetId = (String.valueOf(f.ParentId)).substring(0, 3); // taking first 3 char's of object id
        		if(decisionObj == objetId){
        			decisionIds.add(f.ParentId);
        		} else if(planObj == objetId){
        			planIds.add(f.ParentId);
        		}
        	}
        }
        // Call without sharing class to update decision and plan records.
        FutureMethodController.decisionPlanRecordsUpdate(decisionIds,planIds);	
	}
}