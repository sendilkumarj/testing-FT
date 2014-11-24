/*
 Created by:Phaniraj
 Last Modified by: Phaniraj
 Style: Force.com & Metro
 Description: This class is written to add relations to a parent record - Plan or decision
*/

public with sharing class AddRelations {
     
    public String message{get;set;}
    public boolean addFromSrchTable{get;set;}
    public boolean addFromMainTable{get;set;}
    public List<Relations__c> srchRelationship{get;set;}
    public Set<Relations__c> srchRelationshipSet{get;set;}
    public List<Relations__c> addItemsRelationship{get;set;}
    public Id recId{get;set;}
    public String recType{get;set;}
    public List<Relations__c> existingRecords{get;set;}
    public List<Relations__c> existingChildRecords{get;set;}
    public List<ID> chkExist{get;set;}
    public List<ID> itemList{get;set;}
    public String relType {get;set;}
    public Plan__c planRec{get;set;}
    public Decision__c decisionRec{get;set;}
    public Id currentRecordId{get;set;}
    public String currentRecordName{get;set;}
    public set<Id> relIds ;
    
    //variable to hold all user accessible object
    public List<SelectOption> userAccessibleobjects {get;set;}
    
    // set to hold all Crm objects that has to be shown under add plan items
    public set<String>  crmObjectsSet ; 
    
    // set to hold all FT  objects that has to be shown under add plan items
    public set<String>  ftObjectsSet ;
    
    // map to hold all object name to label
    public Map<String,String>  objectNameLabelMap  {get;set;}
    
    public AddRelations(){
        try{
            Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=8');
            srchRelationship = new List<Relations__c> ();
            srchRelationshipSet = new Set<Relations__c> ();
            addItemsRelationship = new List<Relations__c> ();
            relIds = new set<Id>();
            chkExist = new List<ID>();
            itemList = new List<ID>();
            recType = ApexPages.CurrentPage().getParameters().get('recType');
            recId = ApexPages.CurrentPage().getParameters().get('id');
            String crmObj = ApexPages.currentPage().getParameters().get('crmObj');
            // get plan details if relations are being added from plan
            if(recType == 'Plan'){
                planRec = [select Id,Name from Plan__c where id=:recId ];
                currentRecordId = planRec.id;
                currentRecordName = planRec.Name;
            }
            // get plan details if relations are being added from decision
            else if(recType == 'Decision'){
                decisionRec = [select Id,Name,title__c from Decision__c where id=:recId ]  ;  
                currentRecordId = decisionRec.id;
                currentRecordName = decisionRec.title__c;
            } else if(crmObj == 'true'){
            	currentRecordId = recId;
            }
            relType = ApexPages.CurrentPage().getParameters().get('relType');
            //if Items are added for a Plan, then get only child records 
            if(relType == 'Item'){
                existingRecords = [select Child_Id__c,Child_Record_Name__c,Child_Object_Name__c,Description__c,Parent_Relation__c,Strength__c,Notes__c from Relations__c where Parent_Id__c=:recId and Type__c = 'Item'];
            }
            // get both parent and child records of the relations 
            else{
                existingRecords = [select  Child_Id__c,Child_Record_Name__c,Parent_Record_Name__c,Parent_Object_Name__c,Child_Object_Name__c,Description__c,Parent_Relation__c,Strength__c,Notes__c from Relations__c where Parent_Id__c=:recId and Type__c = 'Relation'];
                existingChildRecords = [Select Child_Relation__c,Parent_Id__c,Parent_Object_Name__c,Description__c,Parent_Record_Name__c,Strength__c,Notes__c from Relations__c where Type__c = 'Relation' and Child_Id__c =: recId];
            }
            if(crmObj == 'true'){
            	// Checking for adding relations from CRM objects
            	existingRecords.clear();
            	existingRecords = [select  Child_Id__c,Child_Record_Name__c,Parent_Record_Name__c,Parent_Object_Name__c,Child_Object_Name__c,Description__c,Parent_Relation__c,Strength__c,Notes__c from Relations__c where (Parent_Id__c=:recId or Child_Id__c =: recId) and Type__c = 'Relation'];
            }
            System.debug('-----existingRecords--------->'+existingRecords);
            System.debug('-----existingChildRecords--------->'+existingChildRecords);
            
            //list to hold all useraccesable objects
            userAccessibleobjects = new List<SelectOption>();
             
            //Map to hold objects name and labels
            objectNameLabelMap = new Map<String,String>(); 
            
            //Initialize the crmObjectsSet to make userAccessibleobjects hold only specified values
            crmObjectsSet = new set<String>{'Account','Asset','Case','Campaign','Contact','Contract','Idea','Lead','Opportunity','Order','Price Book','Product','Quote','Quote Line Item','Solution','User','Task'};
           
            //Initialize the ftObjectsSet to make userAccessibleobjects hold only specified values
            ftObjectsSet  = new Set<String>{ 'Decision','Plan' };
            
        
             //get schema describe to get all object
             List<Schema.SObjectType> globaldescribe = Schema.getGlobalDescribe().Values();     
             
             List<SelectOption> userAccessibleobjectsUnSorted =  new List<SelectOption>();
             
             for(Schema.SObjectType f : globaldescribe)
             {   //for each object if it is viewable by user then add to userAccessibleobjects
                 if( f.getDescribe().isAccessible() && crmObjectsSet.contains(f.getDescribe().getLabel()) ){
                    userAccessibleobjectsUnSorted.add(new SelectOption(f.getDescribe().getName(),f.getDescribe().getLabel()));
                    objectNameLabelMap.put(f.getDescribe().getName(),f.getDescribe().getLabel());
                 }
                 else{
                     if( f.getDescribe().isAccessible() && ftObjectsSet.contains(f.getDescribe().getLabel()) ){
                        userAccessibleobjects.add(new SelectOption(f.getDescribe().getName(),f.getDescribe().getLabel()));
                        objectNameLabelMap.put(f.getDescribe().getName(),f.getDescribe().getLabel());
                     }
                 }
             }
             
             userAccessibleobjectsUnSorted.sort();
             userAccessibleobjects.sort();
             userAccessibleobjects.addAll( userAccessibleobjectsUnSorted );
            
            /*if(existingRecords.size() > 0){
                for(Relations__c exists:existingRecords){
                    String exstingId = exists.Child_Id__c;
                    chkExist.add(exstingId);
                }
            }
            if(existingChildRecords.size() > 0){
                for(Relations__c existsChild : existingChildRecords){
                    String exstingId = existsChild.Parent_Id__c;
                    chkExist.add(exstingId);
                }
            }*/
            
        }catch(Exception e){}
    }
    
    // search for items to be added as relations
    public pageReference searchItems(){
        String objectChosen = ApexPages.currentPage().getParameters().get('chooseObject');
        String searchText = ApexPages.currentPage().getParameters().get('searchText');
        String crmObj = ApexPages.currentPage().getParameters().get('crmObj');
        srchRelationship.clear();
        srchRelationshipSet.clear();
        message = '';
        
        List<Relations__c> lstExistingRelations = new List<Relations__c>();
        if(crmObj == 'true'){
        	lstExistingRelations = [select Id,Child_ID__c,Parent_ID__c from Relations__c where (Child_ID__c =: recId or Parent_ID__c =: recId) limit 999];
        } else {
        	lstExistingRelations = [select Id,Child_ID__c,Parent_ID__c from Relations__c where (Child_ID__c =: recId or Parent_ID__c =: recId) and Type__c = 'Item' limit 999];
        }
        //relIds = new set<id>();
        relIds.add(recId);
        relIds.add(UserInfo.getUserId());
        for(Relations__c rel : lstExistingRelations){
            relIds.add(rel.Child_ID__c);
            relIds.add(rel.Parent_ID__c);  
        }
        if(searchText != ''){
            if(searchText.contains('*')){
                String SearchtextList=searchText.replaceAll('\\*','\\%');
                searchText = SearchtextList;
            }
        }
        
          
       
        if( objectChosen != 'Contract' && objectChosen != 'QuoteLineItem' && objectChosen != 'Idea' &&   objectChosen != 'Solution' &&   objectChosen != 'Case' && !objectChosen.contains('Decision__c') && objectChosen != 'Task'){
            List<sObject> records = Database.query('Select Id, Name From ' + String.escapeSingleQuotes(objectChosen) + ' Where Name like ' + '\'%'+String.escapeSingleQuotes(searchText)+'%\'' + ' limit 999 ');
            for(SObject record : records){
                if(!relIds.contains((String) record.get('Id'))){    
                    Relations__c r = new Relations__c();
                    r.select__c = false;
                    r.Child_Record_Name__c = (String) record.get('Name');
                    r.Child_ID__c = (String) record.get('Id');
                    r.Child_Object_Name__c = objectNameLabelMap.get(objectChosen);  
                    srchRelationshipSet.add(r);  
                }
            }           
        }
        if(objectChosen.contains('Decision__c')){
        	List<Decision__c> lstDecision = [select id,Name,Title__c from Decision__c where Title__c like : '%'+searchText+'%' limit 999];
        	for(Decision__c dec : lstDecision){
        		if(!relIds.contains(dec.Id)){    
            		Relations__c r = new Relations__c();
                    r.select__c = false;
                    r.Child_Record_Name__c = dec.Title__c;
                    r.Child_ID__c = dec.Id;
                    r.Child_Object_Name__c = 'Decision';  
                    srchRelationshipSet.add(r);  
        		}
        	}
        }
    	// task
        if(objectChosen == 'Task'){
            List<Task> task = new List<Task>();
            if(searchText != ''){
                task = [Select id, Subject from Task where Subject like: '%'+searchText+'%' limit 500];
            } else {
                task = [Select id, Subject from Task limit 500];
            }
            for(Task t: task){
                if(!relIds.contains(t.Id)){
                    Relations__c r = new Relations__c();
                    r.select__c = false;
                    r.Child_Record_Name__c = t.Subject;
                    r.Child_ID__c = String.valueOf(t.id);
                    r.Child_Object_Name__c = 'Task';
                    srchRelationshipSet.add(r);
                }
            }
        }
        if(objectChosen == 'QuoteLineItem'  ){ 
            List<sObject> records = Database.query('Select Id, LineNumber  From ' + 'QuoteLineItem' + ' Where LineNumber like ' + '\'%'+String.escapeSingleQuotes(searchText)+'%\'' + ' limit 999 ');
            for(SObject record : records){
                     
                    if(!relIds.contains((String) record.get('Id'))){    
                        Relations__c r = new Relations__c();
                        r.select__c = false;
                        r.Child_Record_Name__c = (String) record.get('LineNumber');
                        r.Child_ID__c = (String) record.get('Id');
                        r.Child_Object_Name__c = objectNameLabelMap.get(objectChosen);
                        srchRelationshipSet.add(r);  
                    }
            }           
        }
        // For Idea section
        if(objectChosen == 'Idea'  ){
            List<sObject> records = Database.query('Select Id, Title  From ' + 'Idea' + ' Where Title like ' + '\'%'+String.escapeSingleQuotes(searchText)+'%\'' + ' limit 999 ');
            for(SObject record : records){
                    if(!relIds.contains((String) record.get('Id'))){    
                        Relations__c r = new Relations__c();
                        r.select__c = false;
                        r.Child_Record_Name__c = (String) record.get('Title');
                        r.Child_ID__c = (String) record.get('Id');
                        r.Child_Object_Name__c = objectNameLabelMap.get(objectChosen);
                        srchRelationshipSet.add(r);
                    }
            }           
        }   
        if(objectChosen == 'Solution'  ){
            List<sObject> records = Database.query('Select Id, SolutionName  From ' + 'Solution' + ' Where SolutionName like ' + '\'%'+String.escapeSingleQuotes(searchText)+'%\'' + ' limit 999 ');
            for(SObject record : records){
                    if(!relIds.contains((String) record.get('Id'))){    
                        Relations__c r = new Relations__c();
                        r.select__c = false;
                        r.Child_Record_Name__c = (String) record.get('SolutionName');
                        r.Child_ID__c = (String) record.get('Id');
                        r.Child_Object_Name__c = objectNameLabelMap.get(objectChosen);
                        srchRelationshipSet.add(r);
                    }
            }           
        }
         if(objectChosen == 'Case'){
            List<sObject> records = Database.query('Select Id, CaseNumber, Subject  From ' + 'Case' + ' Where CaseNumber like ' + '\'%'+String.escapeSingleQuotes(searchText)+'%\'' +  ' or Subject like ' + '\'%'+searchText+'%\''  + ' limit 999 ');
            for(SObject record : records){
                if(!relIds.contains((String) record.get('Id'))){    
                    Relations__c r = new Relations__c();
                    r.select__c = false;
                    if( (String) record.get('Subject') == null)
                        r.Child_Record_Name__c = 'No Subject';
                    else
                        r.Child_Record_Name__c = (String) record.get('Subject');
                    r.Child_ID__c = (String) record.get('Id');
                    r.Child_Object_Name__c = objectNameLabelMap.get(objectChosen);
                    srchRelationshipSet.add(r);
                }
            }            
        } 
        if(objectChosen == 'Contract'  ){
            List<sObject> records = Database.query('Select Id, Name, ContractNumber  From ' + 'Contract' + ' Where ContractNumber like ' + '\'%'+String.escapeSingleQuotes(searchText)+'%\'' +  ' or Name like ' + '\'%'+searchText+'%\''  + ' limit 999 ');
            for(SObject record : records){
                    if(!relIds.contains((String) record.get('Id'))){    
                        Relations__c r = new Relations__c();
                        r.select__c = false;
                        if( (String) record.get('Name') == null)
                            r.Child_Record_Name__c = 'No Name';
                        else
                            r.Child_Record_Name__c = (String) record.get('Name');
                        r.Child_ID__c = (String) record.get('Id');
                        r.Child_Object_Name__c = objectNameLabelMap.get(objectChosen);
                        srchRelationshipSet.add(r);
                    }
            }            
        } 
        for(Relations__c newRel:srchRelationshipSet){
            srchRelationship.add(newRel);
        }
       
        if(srchRelationship.size() == 0){
            message = 'No Records to Display';
        }
        
        return null;
    }
    
    public pageReference addAndClose(){
    	addFromSrch();
    	save_and_close();
        PageReference pageRef;
        if(String.valueOf(recId).startswith('005')){
    		pageRef = new PageReference('/'+recId+'?noredirect=1');
    	} else {
    		pageRef = new PageReference('/'+recId);
    	}
        return pageRef;
    }
    
    // items to be added from search table
    public pageReference addFromSrch(){
        for(Relations__c searchR : srchRelationship){
            if(searchR.select__c == true){
            	System.debug('------searchR------->'+searchR);
               addItemsRelationship.add(searchR);
               relIds.add(searchR.Child_Id__c);
            }
        }
        srchRelationship.clear();
        //searchText = '';
        return null;
    }
    
    public pageReference saveEdit(){
        return null;
    }
    
    public pageReference cancel(){
        PageReference pageRef;
        if(recType == 'Plan' && relType != 'Item'){ 
            pageRef = new PageReference('/apex/PlanView?id='+recId+'&sfdc.override=1&addRelations=true');
        }
        if(recType == 'Plan' && relType == 'Item'){ 
            pageRef = new PageReference('/apex/PlanView?id='+recId+'&sfdc.override=1&addRelations=false');
        }
        if(recType == 'Decision'){
            pageRef = new PageReference('/apex/DecisionView?id='+recId+'&sfdc.override=1&addRelations=true');
        }
        String crmObj = ApexPages.currentPage().getParameters().get('crmObj');
        if(crmObj == 'true'){
        	if(String.valueOf(recId).startswith('005')){
        		pageRef = new PageReference('/'+recId+'?noredirect=1');
        	} else {
        		pageRef = new PageReference('/'+recId);
        	}
        }
        return pageRef;
    }
    
    
    // save all new relations and redirect to parent record
    public pageReference save_and_close(){
        List<Relations__c> newItems = new List<Relations__c>();
        String crmObj = ApexPages.currentPage().getParameters().get('crmObj');
        String recName = ApexPages.currentPage().getParameters().get('recName');
        String objType = ApexPages.currentPage().getParameters().get('objType');
        for(Relations__c a:addItemsRelationship){
            if(a.select__c == true){
            	if(crmObj == 'true'){
            		Relations__c r = new Relations__c();
                    r.select__c = false;
                    r.Child_Record_Name__c = recName;
                    r.Child_ID__c = recId;
                    r.Child_Object_Name__c = objType; 
                    r.type__c = 'Relation';
                    r.parent_Id__c = a.Child_ID__c;
                    r.parent_record_Name__c = a.Child_Record_Name__c;
                    r.parent_object_Name__c = a.Child_Object_Name__c;
                    r.From_Relation__c = 'Parent';
                    r.To_Relation__c = 'Child';
                    r.Strength__c = a.Strength__c;
                    r.Notes__c = a.Notes__c;
                    if(a.Description__c != null && a.Description__c.length() > 254) {
	                    a.Description__c = a.Description__c.substring(0,254);
	                }
	                r.Description__c = a.Description__c;
                    newItems.add(r);
            	} else {
	                Relations__c newR = new Relations__c();
	                newR.Child_Record_Name__c = a.Child_Record_Name__c;
	                newR.Child_ID__c = a.Child_ID__c;
	                newR.Child_Object_Name__c = a.Child_Object_Name__c;
	                if(a.Description__c != null && a.Description__c.length() > 254) {
	                    a.Description__c = a.Description__c.substring(0,254);
	                }
	                newR.Description__c = a.Description__c;
	                newR.Parent_Id__c = currentRecordId; 
	                newR.Parent_Record_Name__c = currentRecordName;
	                newR.Parent_Object_Name__c = recType;
	                newR.Parent_Relation__c = a.Parent_Relation__c;
	                newR.Strength__c = a.Strength__c;
	                newR.Notes__c = a.Notes__c;
	                newR.Type__c = relType;
	                newItems.add(newR);
            	}
            }    
        }
        //FLS check
        if(Schema.SObjectType.Relations__c.fields.Parent_Record_Name__c.isCreateable() && Schema.SObjectType.Relations__c.fields.Parent_Id__c.isCreateable() && Schema.SObjectType.Relations__c.fields.Parent_Object_Name__c.isCreateable() && Schema.SObjectType.Relations__c.fields.Child_Id__c.isCreateable() && Schema.SObjectType.Relations__c.fields.Child_Object_Name__c.isCreateable() && Schema.SObjectType.Relations__c.fields.Child_Record_Name__c.isCreateable() && Schema.SObjectType.Relations__c.fields.Description__c.isCreateable() && Schema.SObjectType.Relations__c.fields.Parent_Relation__c.isCreateable() && Schema.SObjectType.Relations__c.fields.Strength__c.isCreateable() && Schema.SObjectType.Relations__c.fields.Notes__c.isCreateable() && Schema.SObjectType.Relations__c.fields.Type__c.isCreateable() ){ 
             insert newItems;
        }
        PageReference pageRef;
        if(recType == 'Plan' && relType != 'Item'){ 
            pageRef = new PageReference('/apex/PlanView?id='+recId+'&sfdc.override=1&addRelations=true');
        }
        if(recType == 'Plan' && relType == 'Item'){ 
            pageRef = new PageReference('/apex/PlanView?id='+recId+'&sfdc.override=1&addRelations=false');
        }
        if(recType == 'Decision'){
            pageRef = new PageReference('/apex/DecisionView?id='+recId+'&sfdc.override=1&addRelations=true');
        }
        if(crmObj == 'true'){
        	if(String.valueOf(recId).startswith('005')){
        		pageRef = new PageReference('/'+recId+'?noredirect=1');
        	} else {
        		pageRef = new PageReference('/'+recId);
        	}
        }
        return pageRef;
    }
}