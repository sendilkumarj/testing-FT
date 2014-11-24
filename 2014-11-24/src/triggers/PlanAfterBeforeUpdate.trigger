trigger PlanAfterBeforeUpdate on Plan__c (after update, before update) {
    /*
    **********************************************
    Created by:Neha
    Last Modified by: Phaniraj on 07-01-2013
    Style: Force.com & Metro
    Description: This trigger is used to update the plan title/subject of a plan record.
    The objective of trigger is to reflect the title/subject change on all relation records associated with the plan.
    **********************************************
    */
    // Setting the id for plan record.
    set<ID> planID = new set<ID>();
    set<ID> planOwnerSwap = new set<Id>();
    
    // Create a map for the plan current owner.
    map<id,id> planCurrentOwnerId = new map<id,id>();
    // Create a map for the plan old owner.
    map<id,id> planIdOldOwnerMap = new map<id,id>();
    
    if(Trigger.isAfter){
        for(Plan__c plan : Trigger.new){
        	if(Trigger.oldMap.get(plan.Id).Update_Manager__c == plan.Update_Manager__c){
	            Plan__c pOld = System.Trigger.oldMap.get(plan.Id);
	            // Condition to check when owner id is changed.
	            if(plan.OwnerId != pOld.OwnerId){
	            	planIdOldOwnerMap.put(plan.Id,pOld.OwnerId);	
	            	planCurrentOwnerId.put(plan.Id,plan.OwnerId);	
	            	planOwnerSwap.add(plan.ID);	
	            }
	            if(plan.Name != pOld.Name)            
	                planID.add(plan.ID);
        	}
        }
    }
    
    if(planID.size() > 0){
        Map<Id,String> planMap = new map<Id,String>();
        List<Plan__c> planList = [select id,Name from Plan__c where id In: planID];
        for(Plan__c plan :planList){
            planMap.put(plan.Id,plan.Name);
        }
        //This is used for iterating the list one by one where a single record(plan) is getting updated.
        List<Relations__c> relatedItemsList = new List<Relations__c>();
        //This consists the list of plan record that needs to be updated.
        List<Relations__c> planToBeUpdated = new List<Relations__c>();
        relatedItemsList = [select id,Parent_ID__c,Parent_Record_Name__c,Child_ID__c,Child_Record_Name__c from Relations__c where Parent_ID__c In: planID OR Child_ID__c In: planID];
        //This is used for iterating each items record and also updating the record Name to new value.
        for(Relations__c updatedPlanRecord : relatedItemsList){
            //Updates the plan record name where the plan is parent.This change reflects on item list of plan as well as on relation object. 
            if(planMap.get(updatedPlanRecord.Parent_ID__c)!= null){
                updatedPlanRecord.Parent_Record_Name__c = planMap.get(updatedPlanRecord.Parent_ID__c);
            }
            //Updates the plan record name where the plan is child.This change reflects on item list of plan as well as on relation object.
            if(planMap.get(updatedPlanRecord.Child_ID__c)!= null){
                updatedPlanRecord.Child_Record_Name__c = planMap.get(updatedPlanRecord.Child_ID__c);
            }
            planToBeUpdated.add(updatedPlanRecord);
        }
        update planToBeUpdated;
    }
    
    // For transfer ownership
    if(planOwnerSwap.size() > 0){
    	// Call transferOwnershipForPlan method from TransferOwnership controller.
    	TransferOwnership.transferOwnershipForPlan(planOwnerSwap,planIdOldOwnerMap,planCurrentOwnerId);
    }
    
   
}