trigger PlanAfterBeforeInsert on Plan__c (after insert, before insert) {
    /*
    **********************************************
    Created by:Neha
    Last Modified by: Neha
    Style: Force.com & Metro
    Description: The trigger is written to insert accountable user and social records.
                 The objective of the trigger is, when a plan record is created, 
                 1) The user who creates the record will be added as accountable.
                 2) The social records are created.
    **********************************************
    */
    
    // initialize social object 
    List<Social__c> toBeInsertedSocialList = new List<Social__c>(); 
    
    // initialize social object 
    List<Social_Input__c> toBeInsertedSocialInputList = new List<Social_Input__c>(); 
    
    set<Id> decisionId = new set<Id>();
    for(Plan__c plan: Trigger.new) {
        
        if(Trigger.isAfter) {
            
            // insert social records for each decision
            Social__c social = new Social__c();
            social.Related_To_ID__c = plan.Id;
            social.Related_To_Name__c = plan.Name;
            social.Related_To_Object__c = 'Plan';
            toBeInsertedSocialList.add(social);
            
            // insert people as accountable records for each decision 
            
            Social_Input__c socialInput = new Social_Input__c();
            socialInput.Accountable__c = true;
            socialInput.User__c = plan.OwnerId;
            socialInput.Plan__c = plan.Id;
            
            toBeInsertedSocialInputList.add(socialInput);
            
            
        }
    }
    
    // insert social records 
    if(toBeInsertedSocialList.size() > 0) {
        insert toBeInsertedSocialList;
    }
    
    // insert people (Accountable) records
    if(toBeInsertedSocialInputList.size() > 0) {
        insert toBeInsertedSocialInputList;
    }
}