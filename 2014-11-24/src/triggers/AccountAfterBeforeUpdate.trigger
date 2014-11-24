/* 
    Created by:Phaniraj
    Last Modified by: 
    Style: Force.com & Metro
    Description:This trigger is written to Update Relationship records where the Account is reffered to. When a account Name is updated, all the related relationship records are also to be updated.
    
    */
    
trigger AccountAfterBeforeUpdate on Account (Before Update, After Update) {
    if(trigger.isAfter){
        set<Id> accountId = new set<Id>();
        for(Account a:Trigger.new){
            Account aOld = System.Trigger.oldMap.get(a.Id);
            if(a.Name != aOld.Name){
                accountId.add(a.id);    
            }  
        }
        
        if(accountId.size() > 0){
            Map<Id,String> accountMap = new map<Id,String>();
            List<Account> accList = [select id,Name from Account where id In: accountID];
            for(Account acc :accList){
                accountMap.put(acc.Id,acc.Name);
            }
            //This is used for iterating the list one by one where a single record(plan) is getting updated.
            List<Relations__c> relatedItemsList = new List<Relations__c>();
            //This consists the list of Account record that needs to be updated.
            List<Relations__c> accountToBeUpdated = new List<Relations__c>();
            relatedItemsList = [select id,Parent_ID__c,Parent_Record_Name__c,Child_ID__c,Child_Record_Name__c from Relations__c where Parent_ID__c In: accountId OR Child_ID__c In: accountId];
            //This is used for iterating each items record and also updating the record Name to new value.
            for(Relations__c updatedAccRecord : relatedItemsList){
              //Updates the plan record name where the plan is parent.This change reflects on item list of plan as well as on relation object. 
              if(accountMap.get(updatedAccRecord.Parent_ID__c)!= null){
                    updatedAccRecord.Parent_Record_Name__c = accountMap.get(updatedAccRecord.Parent_ID__c);
                }
                //Updates the plan record name where the plan is child.This change reflects on item list of plan as well as on relation object.
                if(accountMap.get(updatedAccRecord.Child_ID__c)!= null){
                    updatedAccRecord.Child_Record_Name__c = accountMap.get(updatedAccRecord.Child_ID__c);
                }
                accountToBeUpdated.add(updatedAccRecord);
            }
            update accountToBeUpdated;
        }
    
    }
}