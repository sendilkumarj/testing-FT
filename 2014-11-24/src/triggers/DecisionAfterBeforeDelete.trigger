/*
DecisionAfterBeforeDelete
Created : Piyush Parmar
Modified by : Piyush Parmar
Description:This trigger is written to delete the all the records that are related to a decision.
            The objective of the trigger is when a decision is deleted all records that are associated with the decision object should also get deleted. 
*/

trigger DecisionAfterBeforeDelete on Decision__c (after delete, before delete) {

    
    set<Id> decisionId = new set<Id>();
    
    for(Decision__c decision: Trigger.old) {
        decisionId.add(decision.Id);
    }
    
    System.debug('decisionId ---------->'+decisionId);
    // query all Social Input records for deleted decision
    List<Social_Input__c> toBeDeletedSocialInputList = [select id from Social_Input__c where Decision__c In: decisionId];
    
    // query all social records for deleted decision
    List<Social__c> toBeDeletedSocialList = [select id from Social__c where Related_To_ID__c In: decisionId];
    
    // query all Timing records for deleted decision
    List<Timing__c> toBeDeletedTimingList = [select id from Timing__c where Related_To_ID__c In: decisionId];
    
    
    // query all Relations records for deleted decision
    List<Relations__c> toBeDeletedRelationsList = [select id from Relations__c where Child_ID__c In: decisionId OR Parent_ID__c In: decisionId ];
    
    // query all Tag Junction records for deleted decision
    List<Tag_Junction__c> toBeDeletedTagJunctionList = [select id from Tag_Junction__c where Related_To_ID__c In: decisionId];
    
    
    // delete Social Input records
    if(toBeDeletedSocialInputList.size() > 0) {
        delete toBeDeletedSocialInputList;
    }
    
    // delete Social records
    if(toBeDeletedSocialList.size() > 0) {
        delete toBeDeletedSocialList;
    }
    
    // delete Timing records
    if(toBeDeletedTimingList.size() > 0) {
        delete toBeDeletedTimingList;
    }
    
    // delete Relations records
    if(toBeDeletedRelationsList.size() > 0) {
        delete toBeDeletedRelationsList;
    }
    
    // delete Tag Junction records
    if(toBeDeletedTagJunctionList.size() > 0) {
        delete toBeDeletedTagJunctionList;
    }
}