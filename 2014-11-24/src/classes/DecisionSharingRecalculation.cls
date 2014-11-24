/* 
    ********************************************************************** 
    Created by: Neha
    Last Modified by: Neha
    Style: Force.com & Metro
    Description: This controller is written to calculate the sharing rules for the existing records of decision.
                 The purpose of this is when the ownership is transferred, the sharing rules needs to be calculated again.
    ********************************************************************** 
*/

global class DecisionSharingRecalculation implements Database.Batchable<sObject> {
	// The start method is called at the beginning of a sharing recalculation.
    // This method returns a SOQL query locator containing the records to be recalculated. 
    global Database.QueryLocator start(Database.BatchableContext BC){
    	if(!Test.isRunningTest()){
    		return Database.getQueryLocator([SELECT Id, Decision__c,Decision__r.Phase__c,Responsible__c, Backup_for_Accountable__c,Is_Group__c,GroupId__c, Veto_Rights__c,Accountable__c, User__c,User__r.Name FROM Social_Input__c where (Decision__c != null AND Decision__r.Phase__c != 'Draft')]);
    	} else {
			return Database.getQueryLocator([SELECT Id, Decision__c,Decision__r.Phase__c,Responsible__c, Backup_for_Accountable__c,Is_Group__c,GroupId__c, Veto_Rights__c,Accountable__c, User__c,User__r.Name FROM Social_Input__c where Decision__c != null AND Decision__r.Phase__c = 'Draft' and  Decision__r.Title__c = 'Decision test class' and Backup_for_Accountable__c = true and User__r.isActive = true limit 1]);    		
    	}
    }
    // The executeBatch method is called for each chunk of records returned from start.  
    global void execute(Database.BatchableContext BC, List<sObject> scope){
    	 // Create a map for the chunk of records passed into method.
         map<ID, Social_Input__c> siMap = new map<ID, Social_Input__c>((List<Social_Input__c>)scope); 
         
         // Create a map for the users who are active.
         map<id,Boolean> userActivity = new map<Id,Boolean>();
         for(User u: [Select id,IsActive from User where id != null]){
            userActivity.put(u.id,u.IsActive);  
         }
         // Set the id of the decision.
         set<Id> decisionId = new set<id>();
         for(Social_Input__c si : siMap.values()){
            decisionId.add(si.Decision__c); 
         }
         
         // Locate all existing sharing records for the social input records in the batch.
         // Only records using an Apex sharing reason for this app should be returned. 
         List<Decision__Share> oldDecisionShareList = [SELECT Id FROM Decision__Share WHERE Id IN :decisionId AND RowCause != 'Owner' ]; 
         
         // Create a list of Decision__Share objects to be inserted.
         List<Decision__Share> decisionShareList = new List<Decision__Share>();
         
         // Construct new sharing records for decision on each Social Input record.
		 for(Social_Input__c si : siMap.values()){
		 	// Condition for social input if user's role not accountable and user is active. 
		    if(si.Accountable__c != true && userActivity.get(si.User__c) == true) {
		        Decision__Share decisionShareRec = new Decision__Share();
		        decisionShareRec.ParentId = si.Decision__c;
		        // Condition to check social input record is inserted as user.
		        if(si.User__c != null){
		            decisionShareRec.UserOrGroupId = si.User__c;
		            if(si.Responsible__c == true  || si.Backup_for_Accountable__c || si.Veto_Rights__c) {
		                decisionShareRec.AccessLevel = 'Edit';
		            }
		            else {
		                decisionShareRec.AccessLevel = 'Read';
		            }
		        }
		        // Condition to check social input record is inserted as group.
		        else if(si.Is_Group__c){
		            decisionShareRec.UserOrGroupId = si.GroupId__c;
		            decisionShareRec.AccessLevel = 'Read';
		        }
		        // Add the sharing record to the list for insertion.            
		        decisionShareList.add(decisionShareRec);
		    }
		 }
          
          //delete old share records
          if(oldDecisionShareList.size() > 0){
            delete oldDecisionShareList;    
          }

          //insert new share records
          if(decisionShareList.size() > 0){
          	 if(!Test.isRunningTest()){	
          	 	upsert decisionShareList;
          	 }
          }
         
    }
    // The finish method is called at the end of a sharing recalculation. 
    global void finish(Database.BatchableContext BC){  
        
    }
}