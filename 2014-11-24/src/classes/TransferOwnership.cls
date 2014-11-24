/* 
    ********************************************************************** 
    Created by: Neha
    Last Modified by: Neha
    Style: Force.com & Metro
    Description: This controller is written to transfer the ownership of record to somebody else. 
                 The purpose is when an ownership is transferred [Accountable] to somebody else,
                 that user becomes accountable and will have complete access to the record. 
    ********************************************************************** 
*/

public without sharing class TransferOwnership{
	// Static method to transfer ownership for plan.
    public static void transferOwnershipForPlan(set<id> planId,map<id,id> planIdOldOwnerMap,map<id,id> planOwnerId){
    	// Create a map for the social input records related to plan.
        Map<Id,List<Social_Input__c>> planSocialInputMap = new Map<Id,List<Social_Input__c>>();
        
        // Construct new list of plan social input records for plan on each Social Input record.
        for(Social_Input__c si : [Select id,Name,Accountable__c,User__c,Plan__c From Social_Input__c where Plan__c IN: planId]){
            List<Social_Input__c> planSIList = planSocialInputMap.get(si.Plan__c);
            if(planSIList == null) {
                planSIList = new List<Social_Input__c>();
                planSocialInputMap.put(si.Plan__c,planSIList );
            } 
            // Add the social input record to the list for insertion.                                                         
            planSIList.add(si);
        }
        // This consists the list of social input record that needs to be updated.
        List<Social_Input__c> toUpdateSocialInputList = new List<Social_Input__c>();
        // This consists the list of social input record that needs to be deleted.
        List<Social_Input__c> toDeleteSocialInputList = new List<Social_Input__c>();
        // This consists the list of social input record that needs to be inserted.
        List<Social_Input__c> toBeInsertedSocialList = new List<Social_Input__c>();
        
        for(Id p:PlanId){
        	// Declare a variable for the social input record to be deleted.
            Boolean chkForExistingUserToBeDeleted = false;
        	for(Social_Input__c s: planSocialInputMap.get(p) ){
                if(s.User__c == planOwnerId.get(p) && s.User__c != planIdOldOwnerMap.get(p)){
                    s.Accountable__c = true;
                    chkForExistingUserToBeDeleted = true;
                    toUpdateSocialInputList.add(s);
                    break;
                }
            } 
            // Condition to check if the owner is part of plan.
            if(chkForExistingUserToBeDeleted == true){
                for(Social_Input__c s: planSocialInputMap.get(p)){
                    if(s.Accountable__c == true && s.User__c == planIdOldOwnerMap.get(p)){
                        s.Accountable__c = false;
                        toDeleteSocialInputList.add(s); 
                        break;
                    }
                }   
            }
           // Condition to check if the owner is not part of plan.
			if(chkForExistingUserToBeDeleted == false){
				Social_Input__c newSocial = new Social_Input__c(User__c = planOwnerId.get(p),Accountable__c = true,plan__c = p);
				toBeInsertedSocialList.add(newSocial);	
				for(Social_Input__c s: planSocialInputMap.get(p)){
                    if(s.Accountable__c == true && s.User__c == planIdOldOwnerMap.get(p)){
                        s.Accountable__c = false;
                        toDeleteSocialInputList.add(s); 
                        break;
                    }
                }   
			}
        }
        
        // delete social input records
        if(toDeleteSocialInputList.size() > 0 && FLS.socialInputDeletable()){
        	delete toDeleteSocialInputList;
        }   
        // update social input records
        if(toUpdateSocialInputList.size() > 0 && FLS.socialInputUpdateable()){
        	update toUpdateSocialInputList;
        }  
        // insert social input records
        if(toBeInsertedSocialList.size() > 0 && FLS.socialInputCreateable()){
			insert toBeInsertedSocialList;
		}  
    }
    
    // Static method to transfer ownership for decision.
    public static void transferOwnershipForDecision(set<id> decisionId,map<id,id> decisionIdOldOwnerMap,map<id,id> decisionOwnerId){
    	// Create a map for the social input records related to decision.
	    Map<Id,List<Social_Input__c>> decisionSocialInputMap = new Map<Id,List<Social_Input__c>>();
	    
	    	// Construct new list of decision social input records for decision on each Social Input record.
	        for(Social_Input__c si : [Select id,Name,Accountable__c,User__c,Decision__c From Social_Input__c where Decision__c IN: decisionId]){
	            List<Social_Input__c> decisionSIList = decisionSocialInputMap.get(si.Decision__c);
	            if(decisionSIList == null) {
	                decisionSIList = new List<Social_Input__c>();
	                decisionSocialInputMap.put(si.Decision__c,decisionSIList );
	            }                                                      
	            decisionSIList.add(si);
	        }
	        // This consists the list of social input record that needs to be updated.
	        List<Social_Input__c> toUpdateSocialInputList = new List<Social_Input__c>();
	        // This consists the list of social input record that needs to be deleted.
	        List<Social_Input__c> toDeleteSocialInputList = new List<Social_Input__c>();
	        // This consists the list of social input record that needs to be inserted.
	        List<Social_Input__c> toBeInsertedSocialList = new List<Social_Input__c>();
	        
	        for(Id d:decisionId){
	        	// Declare a variable for the social input record to be deleted.
	            Boolean chkForExistingUserToBeDeleted = false;
	        	for(Social_Input__c s: decisionSocialInputMap.get(d) ){
	                if(s.User__c == decisionOwnerId.get(d) && s.User__c != decisionIdOldOwnerMap.get(d)){
	                    s.Accountable__c = true;
	                    chkForExistingUserToBeDeleted = true;
	                    toUpdateSocialInputList.add(s);
	                    break;
	                }
	            } 
	            // Condition to check if the owner is part of decision.
	            if(chkForExistingUserToBeDeleted == true){
	                for(Social_Input__c s: decisionSocialInputMap.get(d)){
	                    if(s.Accountable__c == true && s.User__c == decisionIdOldOwnerMap.get(d)){
	                        s.Accountable__c = false;
	                        toDeleteSocialInputList.add(s); 
	                        break;
	                    }
	                }   
	            }
	            // Condition to check if the owner is not part of decision.
				if(chkForExistingUserToBeDeleted == false){
					Social_Input__c newSocial = new Social_Input__c(User__c = decisionOwnerId.get(d),Accountable__c = true,Decision__c = d);
					toBeInsertedSocialList.add(newSocial);	
					for(Social_Input__c s: decisionSocialInputMap.get(d)){
	                    if(s.Accountable__c == true && s.User__c == decisionIdOldOwnerMap.get(d)){
	                        s.Accountable__c = false;
	                        toDeleteSocialInputList.add(s); 
	                        break;
	                    }
	                }   
				}
	        }
	        
	        // delete social input records
	        if(toDeleteSocialInputList.size() > 0 && FLS.socialInputDeletable()){
	        	delete toDeleteSocialInputList;
	        }   
	         // update social input records
	        if(toUpdateSocialInputList.size() > 0 && FLS.socialInputUpdateable()){
	        	update toUpdateSocialInputList;
	        }  
	         // insert social input records
	        if(toBeInsertedSocialList.size() > 0 && FLS.socialInputCreateable()){
				insert toBeInsertedSocialList;
			}  	
    }
}