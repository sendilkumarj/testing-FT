trigger PlanAfterBeforeDelete on Plan__c (after delete, before delete) {
    /* 
    ***********************************************
    Created by:Neha
    Last Modified by: Neha
    Style: Force.com & Metro
    Description:This trigger is written to delete the plan record from the database.
    The objective of the trigger is when a plan record is deleted all relation records associated to the plan are also deleted. 
    ***********************************************
    */
        //Setting the id for note record.
        set<ID> planID = new set<ID>();
        //To fetch the ID's of note records
        if(Trigger.isAfter){
            for (Plan__c relatedPlan : Trigger.old){
                planID.add(relatedPlan.ID); 
            }
        }
        
        if(planID.size() > 0){
            //List of plans to be deleted form items(Plan Object)
            List<Relations__c> plansToBeDeleted = [Select id from Relations__c where Parent_ID__c In: planID OR Child_ID__c In: planID];
                delete plansToBeDeleted;
        }
    }