trigger ContactAfterBeforeDelete on Contact (after delete, before delete) {
    /* 
    ***********************************************
    Created by:Neha
    Last Modified by: Neha
    Style: Force.com & Metro
    Description:This trigger is written to delete the relation record that relates plan or decision record with an contact record.
    The objective of the trigger is when a contact record is deleted all relation records associated to the contact are all deleted. 
    ***********************************************
    */
        //Setting the id for contact record.
        set<ID> contactID = new set<ID>();
        //To fetch the ID's of contact records
        if(Trigger.isAfter){
            for(Contact contact:Trigger.old){
                contactID.add(contact.ID);
            }
        }
        
        if(contactID.size() > 0){
            //List of contacts to be deleted form relations
            List<Relations__c> contactsToBeDeleted = [Select id,Parent_ID__c,Child_ID__c from Relations__c where Parent_ID__c In: contactID OR Child_ID__c In: contactID];
            delete contactsToBeDeleted;
        }
    }