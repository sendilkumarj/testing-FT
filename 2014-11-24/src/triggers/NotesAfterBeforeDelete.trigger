trigger NotesAfterBeforeDelete on Note (after delete, before delete) {
    /* 
    ***************************************************
    Created by:Neha
    Last Modified by: Neha
    Style: Force.com & Metro
    Description:This trigger is written to delete the relation/item record that relates plan record with a note record.
    The objective of the trigger is when a note record is deleted all relation records associated to the note are also deleted. 
    ***************************************************
    */
        //Setting the id for note record.
        set<Id> noteId = new set<Id>();
        //To fetch the ID's of note records
        if(Trigger.isAfter){
            for (Note relatedNotes : Trigger.old){
                noteID.add(relatedNotes.ID); 
            }
        }
        
        if(noteID.size() > 0){
            //List of topics to be deleted form items(Plan Object)
            List<Relations__c> notesToBeDeleted = [Select id from Relations__c where Child_ID__c In: noteID];
                delete notesToBeDeleted;
        }
    }