/*
Created by: Phaniraj
Modifiedby:
Style: Metro & Force.com
Description: This trigger is used to track whether the record inserted is item or a relation record. Also used to maintain the position of the items when inserted and to bold and unbold the number of records within the plan.
             The objective of trigger is when an record is inserted to a relation object,
             1) Identify whether it is an item or a relation record.
             2) Manage positions for the items record.
             3) If a new record is added to the note object and the user has not visited the tab since the addition of the new record then the number on tab will be bold indicating the user to view the tab, else this number is unbold.  
*/

trigger RelationsAfterBeforeInsert on Relations__c (Before Insert, After Insert) {

    if(Trigger.isBefore){
    
        set<Id> relId = new set<Id>();
        map<Id,List<Relations__c>> relMap = new map<Id,List<Relations__c>>();
        for (Relations__c rela : Trigger.new){
            
            if(rela.Type__c == 'Item') {
                relId.add(rela.Parent_ID__c);
            }
            
        }
        
        for(Relations__c  r : [select id, Parent_ID__c from Relations__c where Parent_ID__c In: relId and Type__c = 'Item' ]) {
            
            List<Relations__c> rList = relMap.get(r.Parent_ID__c);
            if(rList == null) {
                rList = new List<Relations__c>();
                relMap.put(r.Parent_ID__c,rList);
            }
            rList.add(r);
        }
        
        map<Id, Integer> mapSize = new map<Id, Integer>();
        
        for (Relations__c rela : Trigger.new){
            
            if(rela.Type__c == 'Item') {
            
                if(relMap.get(rela.Parent_ID__c) != null) {
                    if(mapSize.get(rela.Parent_ID__c) == null) {
                        mapSize.put(rela.Parent_ID__c,relMap.get(rela.Parent_ID__c).size());
                    }
                    else {
                        Integer cntSize = mapSize.get(rela.Parent_ID__c);
                        mapSize.put(rela.Parent_ID__c,cntSize+1 );
                    }
                    rela.Position__c = mapSize.get(rela.Parent_ID__c)+1;
                }
                else {
                    if(mapSize.get(rela.Parent_ID__c) == null) {
                        mapSize.put(rela.Parent_ID__c,0);
                    }
                    else {
                        Integer cntSize = mapSize.get(rela.Parent_ID__c);
                        mapSize.put(rela.Parent_ID__c,cntSize+1 );
                    }
                    rela.Position__c = mapSize.get(rela.Parent_ID__c)+1;
                }
            }
        }
    }
    
    if(Trigger.isAfter){
        set<Id> socialInputId = new set<Id>();
        for(Relations__c r:Trigger.new){
            socialInputId.add(r.Parent_ID__c);   
        }
        if(socialInputId.size() > 0){
            List<Social_Input__c> socialRec = [select Id,SYS_Tab_View_Relations__c from Social_Input__c where Decision__c IN: socialInputId];
            for(Social_Input__c s:socialRec){
                s.SYS_Tab_View_Relations__c = true;
            }
            update socialRec;
        }
    }

}