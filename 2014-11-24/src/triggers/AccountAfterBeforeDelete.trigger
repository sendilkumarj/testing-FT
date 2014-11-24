trigger AccountAfterBeforeDelete on Account (after delete, before delete) {
    /* 
    ********************************************************************** 
    Created by:Neha
    Last Modified by: Neha
    Style: Force.com & Metro
    Description:This trigger is written to delete the relation record that relates plan or decision record with an account record.
    The objective of the trigger is when an account record is deleted all relation records associated to the account are all deleted. 
    ********************************************************************** 
    */
        //Setting the id for account record.
        set<ID> accountID = new set<ID>();
        //To fetch the ID's of account records
        if(Trigger.isAfter){
            for(Account account:Trigger.old){
                accountID.add(account.ID);
            }
        }
        
        if(accountID.size() > 0){
            //List of accounts to be deleted form relations
            List<Relations__c> accountsToBeDeleted = [Select id,Parent_ID__c,Child_ID__c from Relations__c where Parent_ID__c In: accountID OR Child_ID__c In: accountID];
            delete accountsToBeDeleted;
        }
    }