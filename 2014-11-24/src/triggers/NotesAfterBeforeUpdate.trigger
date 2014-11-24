trigger NotesAfterBeforeUpdate on Note (after update, before update) {
    /*
    *************************************************
    Created by:Neha
    Last Modified by: Neha
    Style: Force.com & Metro
    Description:This trigger is used to update the title/subject of a note record. 
    If a user edits the note title/subject, it should also update the title/subject for related items list that are displayed on plan 
    items list.
    *************************************************
    */
        //Setting the id for note record.
        set<ID> noteID = new set<ID>();
        //To fetch the ID of note record
        if(Trigger.isAfter){
            for (Note relatedNotes : Trigger.old){
                noteID.add(relatedNotes.ID);    
            }
        }
        
        if(noteID.size() > 0){
            Map<Id,String> noteMap = new map<Id,String>();
            List<Note> notesList = [select id,Title from Note where id In: noteID];
            for(Note note :notesList){
                noteMap.put(note.Id,note.title);
            }
            //This is used for iterating the list one by one where a single record(note) is getting updated.
            List<Relations__c> relatedItemsList = new List<Relations__c>();
            //This consists the list of notes record that needs to be updated.
            List<Relations__c> notesToBeUpdated = new List<Relations__c>();
            relatedItemsList = [select id,Child_ID__c,Child_Record_Name__c from Relations__c where Child_ID__c In: noteID];
            //This is used for iterating each items record also updating the record title/subject to new value.
            for(Relations__c updatedNoteRecord : relatedItemsList){
                updatedNoteRecord.Child_Record_Name__c = noteMap.get(updatedNoteRecord.Child_ID__c);
                notesToBeUpdated.add(updatedNoteRecord);
            }
            update notesToBeUpdated;
        }
    }