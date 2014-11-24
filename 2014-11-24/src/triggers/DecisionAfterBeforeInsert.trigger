/*
DecisionAfterBeforeInsert
Created : Piyush Parmar
Modified by : Piyush Parmar
Description:
The trigger is written to insert accountable user, social record and inserts timing records.
The objective of the trigger is, when a decision record is created, 
1) The user who creates the record will be added as accountable.
2) The social records are created.
3) The Nearest Due Date is updated with Decison Due Date.
4) If private then Decision Name is assigned with ...
5) The timing records are created for each pahses.
*/


trigger DecisionAfterBeforeInsert on Decision__c (after insert, before insert) {

    // initialize social object 
    List<Social__c> toBeInsertedSocialList = new List<Social__c>(); 
    
    // initialize social object 
    List<Social_Input__c> toBeInsertedSocialInputList  = new List<Social_Input__c>(); 
    
    // initialize timing object 
    List<Timing__c> toBeInsertedTimigList = new List<Timing__c>();
    
    // 
    List<String> stageNo = new List<String>{'1','2','3a','3b','4','5','6'};
    
    set<Id> decisionId = new set<Id>();
    RankingDatabaseDefination rdd = new RankingDatabaseDefination();
    for(Decision__c decision: Trigger.new) {
        if(Trigger.isBefore){
            decision.SYS_Accountable__c = decision.OwnerId;
            if(decision.Due_Date__c != null){
                decision.Nearest_Due_Date__c = decision.Due_Date__c;
            }
            if(decision.Private__c == true){
                decision.Name = '...';
            }
            else {
                decision.Name = decision.Title__c;
                if(decision.name.length() > 79) {
                    decision.Name = decision.Name.substring(0,79);
                }
            }
        }
        
        if(Trigger.isAfter) {
            
            // insert social records for each decision
            Social__c social = new Social__c();
            social.Related_To_ID__c = decision.Id;
            social.Related_To_Name__c = decision.Name;
            social.Related_To_Object__c = 'Decision';
            toBeInsertedSocialList.add(social);
            
            // insert people as accountable records for each decision 
            // If it is not create from quick decision
            if(!decision.Approved_when_Created__c) {
                
                Social_Input__c socialInput = new Social_Input__c();
                socialInput.Accountable__c = true;
                socialInput.Role_Acceptance_Required__c = false;
                socialInput.Role_Acceptance_Status__c = 'Approved/Accepted';
                socialInput.User__c = decision.OwnerId;
                socialInput.Decision__c = decision.Id;
                toBeInsertedSocialInputList.add(socialInput);
            }
            
            // create timing records for each phases dynamically  
            Schema.DescribeFieldResult phasesPickListresult = Decision__c.Phase__c.getDescribe();
            List<Schema.PicklistEntry> phasesPickList = phasesPickListresult.getPicklistValues();
            
            Integer i = 0;
            for(Schema.PicklistEntry f : phasesPickList){
            
                Timing__c timing = new Timing__c();
                if(f.getValue() == 'Draft') {
                    timing.Actual_Start_Date__c = decision.CreatedDate;
                }
                
                timing.Stage_no__c = stageNo[i];
                timing.Related_To_ID__c = decision.Id;
                //timing.Decision__c = decision.Id;
                if(decision.Due_Date__c != null && f.getValue() == 'Propose'){
                    timing.Stage__c = f.getValue();
                    timing.End_Date_Time__c = decision.Due_Date__c;
                }else{
                    timing.Stage__c = f.getValue();
                }
                timing.Related_To_Name__c = decision.Name;
                timing.Related_To_Object__c = 'Decision';
                toBeInsertedTimigList.add(timing);
                i++;
            }
            
            // added for relationship record to be insert when child decision has to be created from popular section
            /*if(decision.Parent_Decision__c != null) {
                
                Relations__c relations = new Relations__c();
                relations.Child_ID__c
            }*/
            rdd.calculatePoints('Create a decision', decision.Decision_Type__c);
        }
        
        if(Trigger.isBefore){
        	if(decision.Status__c == 'Approved'){
        		decision.test__c = true;
        	}
        }
    }
    
    // insert social records 
    if(toBeInsertedSocialList.size() > 0) {
        insert toBeInsertedSocialList;
    }
    
    // insert socialInput (Accountable) records
    if(toBeInsertedSocialInputList .size() > 0) {
        insert toBeInsertedSocialInputList ;
    }
    
    // insert timing records for each phases, which help to track phase timing 
    if(toBeInsertedTimigList.size() > 0) {
        insert toBeInsertedTimigList;
    }
}