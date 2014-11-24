trigger NoteAfterBeforeInsert on Note (after insert, before insert) {
    /*
    ****************************************
    Created by:Neha
    Last Modified by: Neha
    Style: Force.com & Metro
    Description: The objective of this trigger is to bold and unbold the number of records within the tab.
    If a new record is added to the note object and the user has not visited the tab since the addition of the new record then the number on tab will be bold indicating the user
    to view the tab, else this number is unbold.  
    ****************************************
    */
        //Setting the id for decision record.
        set<ID> decisionID = new set<ID>();
        //Setting the id for plan record.
        set<ID> planID = new set<ID>();
        
        //To fetch the ID's of note records
        List<Social_Input__c> toBeUpdatedSocialInputList = new List<Social_Input__c>();
        if(trigger.isAfter){
            for (Note notes : Trigger.new){
                decisionID.add(notes.ParentId); 
                planID.add(notes.ParentId);  
            } 
        }
        
        if(decisionID.size() > 0){
            //This contains list of notes record related to decision to be updated
            List<Social_Input__c> decisionNotesRecord = [Select id, SYS_Tab_View_Attachments__c from Social_Input__c where Decision__c In: decisionID];
            //This is used for iterating each note record for decision and updating the checkbox  value to true
            for(Social_Input__c socialInput: decisionNotesRecord) {
                socialInput.SYS_Tab_View_Attachments__c = true;
                //This updates the list of note records.
                toBeUpdatedSocialInputList.add(socialInput);
            }
        }
        
        if(planID.size() > 0){
            //This contains list of notes record related to plan to be updated
            List<Social_Input__c> planNotesRecord = [Select id, SYS_Tab_View_Attachments__c from Social_Input__c where Plan__c In: planID];
            //This is used for iterating each note record for plan and updating the checkbox  value to true
            for(Social_Input__c socialInput: planNotesRecord) {
                socialInput.SYS_Tab_View_Attachments__c = true;
                //This updates the list of note records.
                toBeUpdatedSocialInputList.add(socialInput);
            }
        }
        
        if(toBeUpdatedSocialInputList.size() > 0) {
            update toBeUpdatedSocialInputList;
        }
    }