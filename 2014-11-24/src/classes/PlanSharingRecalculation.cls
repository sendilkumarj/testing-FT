/* 
    ********************************************************************** 
    Created by: Neha
    Last Modified by: Neha
    Style: Force.com & Metro
    Description: This controller is written to calculate the sharing rules for the existing records of plan.
                 The purpose of this is when the ownership is transferred, the sharing rules needs to be calculated again.
    ********************************************************************** 
*/

global class PlanSharingRecalculation implements Database.Batchable<sObject> {
	// The start method is called at the beginning of a sharing recalculation.
    // This method returns a SOQL query locator containing the records to be recalculated. 
	global Database.QueryLocator start(Database.BatchableContext BC){
		if(!Test.isRunningTest()){
			return Database.getQueryLocator([SELECT Id, Plan__c,Responsible__c, Backup_for_Accountable__c,Is_Group__c,GroupId__c, Veto_Rights__c,Accountable__c, User__c,User__r.Name,plan__r.LastModifiedDate  FROM Social_Input__c where plan__c != null]);
		} else {
			return Database.getQueryLocator([SELECT Id, Plan__c,Responsible__c, Backup_for_Accountable__c,Is_Group__c,GroupId__c, Veto_Rights__c,Accountable__c, User__c,User__r.Name,plan__r.LastModifiedDate  FROM Social_Input__c where plan__c != null and plan__r.Name = 'test plan' limit 200]);
		}
    }
    // The executeBatch method is called for each chunk of records returned from start.  
	global void execute(Database.BatchableContext BC, List<sObject> scope){
		 // Create a map for the chunk of records passed into method.
		 map<ID, Social_Input__c> siMap = new Map<ID, Social_Input__c>((List<Social_Input__c>)scope); 
		 
		 // Create a map for the users who are active.
		 map<id,Boolean> userActivity = new map<Id,Boolean>();
		 for(User u: [Select id,IsActive from User where id != null]){
            userActivity.put(u.id,u.IsActive);  
         }
         // Set the id of the plan.
		 set<Id> planId = new set<id>();
		 for(Social_Input__c si : siMap.values()){
		 	planId.add(si.Plan__c);	
		 }
		 
		 // Locate all existing sharing records for the social input records in the batch.
         // Only records using an Apex sharing reason for this app should be returned. 
		 List<Plan__Share> oldPlanShareList = [SELECT Id FROM Plan__Share WHERE Id IN :planId AND RowCause != 'Owner' ]; 
		 
		 // Create a list of Plan__Share objects to be inserted.
		 List<Plan__Share> planShareList = new List<Plan__Share>();
		 
		 // Construct new sharing records for plan on each Social Input record.
		 for(Social_Input__c si : siMap.values()){
		 	// Condition for social input if user's role not accountable and user is active.
		  	if(si.Accountable__c != true && userActivity.get(si.User__c) == true) {
		  		Plan__Share planShareRec = new Plan__Share();
			  	planShareRec.ParentId = si.Plan__c;
			  	// Condition to check social input record is inserted as user.
			  	if(si.User__c != null){
		            planShareRec.UserOrGroupId = si.User__c;
		            if(si.Responsible__c == true  || si.Backup_for_Accountable__c || si.Veto_Rights__c) {
		                planShareRec.AccessLevel = 'Edit';
		            }
		            else {
		            	planShareRec.AccessLevel = 'Read';
		            }
		  		}
		  		// Condition to check social input record is inserted as group.
		  		else if(si.Is_Group__c){
		  			planShareRec.UserOrGroupId = si.GroupId__c;
		            planShareRec.AccessLevel = 'Read';
		        }
		        // Add the sharing record to the list for insertion.     
	            planShareList.add(planShareRec);
		  	}
		 }
		  
		 //delete old share records
		 if(oldPlanShareList.size() > 0){
		  	 delete oldPlanShareList;	
		 }
		 //insert new share records
		 if(planShareList.size() > 0){
		 	upsert planShareList;
		 }
	}
	// The finish method is called at the end of a sharing recalculation. 
	global void finish(Database.BatchableContext BC){  
		
	}
}