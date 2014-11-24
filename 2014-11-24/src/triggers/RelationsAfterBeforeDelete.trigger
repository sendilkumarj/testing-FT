/*
Created by: Phaniraj
Modifiedby
Style: Metro & Force.com
Description: This trigger is used to reset the position of the items in plan when an item is deleted and also deletes note record on an item.
             The objective of trigger is when an item is deleted from plan, the position of the items should be resetted. 
             Also delete the note record from item.
*/


trigger RelationsAfterBeforeDelete on Relations__c (Before Delete,After Delete) {
    
   if(Trigger.isAfter){
        List<Relations__c> tobeUpdatedRelations = new List<Relations__c>();
        List<ID> tobeDeletedNotes = new List<ID>();
        set<Id> relId = new set<Id>();
        for (Relations__c r: Trigger.old){
            
            if(r.Type__c == 'Item') {
                relId.add(r.Parent_ID__c);
            }  
            
            if(r.Child_Object_Name__c == 'Note'){
            
                tobeDeletedNotes.add(r.Child_ID__c);
            }
        }
        
        map<Id,Integer> mapSize = new map<Id,Integer>();
        for(Relations__c  r : [select id,Position__c, Child_Object_Name__c, Child_ID__c, Parent_ID__c from Relations__c where Parent_ID__c In: relId and Type__c = 'Item' Order By Position__c ASC]) {
            
            if(mapSize.get(r.Parent_ID__c) == null){
                mapSize.put(r.Parent_ID__c, 0);
            }
            else {
                mapSize.put(r.Parent_ID__c, mapSize.get(r.Parent_ID__c)+ 1);
            }
            r.Position__c = mapSize.get(r.Parent_ID__c)+ 1;
            
            System.debug(r.Position__c );
            tobeUpdatedRelations.add(r); 
            
            
            
        }
        if(tobeUpdatedRelations.size() > 0) {
            update tobeUpdatedRelations;
        }
        
        if(tobeDeletedNotes.size() > 0) {
            delete [select id from Note where Id In: tobeDeletedNotes];
        }
    }
    
    
}