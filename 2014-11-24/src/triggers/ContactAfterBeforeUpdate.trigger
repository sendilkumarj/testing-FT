/* 
    Created by:Phaniraj
    Last Modified by: 
    Style: Force.com & Metro
    Description:This trigger is written to Update Relationship records where the Contact is reffered to. When a Contact Name is updated, all the related relationship records are also to be updated.
    
    */
    
    trigger ContactAfterBeforeUpdate on Contact (Before Update, After Update) {
        if(trigger.isAfter){
            set<Id> ContactId = new set<Id>();
            for(Contact c:Trigger.new){
                Contact cOld = System.Trigger.oldMap.get(c.Id);
                if((c.FirstName != cOld.FirstName) || (c.LastName != cOld.LastName)){
                    ContactId.add(c.id);    
                }  
            }
            
            if(ContactId.size() > 0){
                Map<Id,String> ContactMap = new map<Id,String>();
                List<Contact> conList = [select id,Name from Contact where id In: ContactID];
                for(Contact con :conList){
                    ContactMap.put(con.Id,con.Name);
                }
                //This is used for iterating the list one by one where a single record(plan) is getting updated.
                List<Relations__c> relatedItemsList = new List<Relations__c>();
                //This consists the list of Contact record that needs to be updated.
                List<Relations__c> ContactToBeUpdated = new List<Relations__c>();
                relatedItemsList = [select id,Parent_ID__c,Parent_Record_Name__c,Child_ID__c,Child_Record_Name__c from Relations__c where Parent_ID__c In: ContactId OR Child_ID__c In: ContactId];
                //This is used for iterating each items record and also updating the record Name to new value.
                for(Relations__c updatedconRecord : relatedItemsList){
                  //Updates the plan record name where the plan is parent.This change reflects on item list of plan as well as on relation object. 
                  if(ContactMap.get(updatedconRecord.Parent_ID__c)!= null){
                        updatedconRecord.Parent_Record_Name__c = ContactMap.get(updatedconRecord.Parent_ID__c);
                    }
                    //Updates the plan record name where the plan is child.This change reflects on item list of plan as well as on relation object.
                    if(ContactMap.get(updatedconRecord.Child_ID__c)!= null){
                        updatedconRecord.Child_Record_Name__c = ContactMap.get(updatedconRecord.Child_ID__c);
                    }
                    ContactToBeUpdated.add(updatedconRecord);
                }
                update ContactToBeUpdated;
            }
        
        }
    }