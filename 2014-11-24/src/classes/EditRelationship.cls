/*
 Created by:Phaniraj
 Last Modified by: Phaniraj
 Style: Force.com & Metro
 Description: This class is written update a relationship in plan or decision
*/
public with sharing class EditRelationship {
    public Id currentId{get;set;}
    public Id relationshipId {get;set;}
    public String decisionTitle {get;set;}
    public String relaType {get;set;}
    public String relaPlan{get;set;}
    public Relations__c relation{get;set;}
    
    // constructor to get the details about the relations to be edited.
    public editRelationship(){  
        try{
            Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=8');
            currentId = ApexPages.currentPage().getParameters().get('id');
            relationshipId = ApexPages.currentPage().getParameters().get('relId');
            relaType = ApexPages.currentPage().getParameters().get('type');
            relaPlan = ApexPages.currentPage().getParameters().get('relPlan');
            if(relaPlan == 'false'){
                if(Schema.sObjectType.Decision__c.fields.name.isAccessible()&& Schema.sObjectType.Decision__c.fields.Title__c.isAccessible()){
                    Decision__c deci = [select name,Title__c from Decision__c where id=:currentId];
                    decisionTitle = deci.Name;
                }
            }
            if(relaPlan == 'true'){
                Plan__c plan = [select name from Plan__c where id=:currentId];
                decisionTitle = plan.Name;
            }
            relation = [select From_Relation__c,To_Relation__c,Child_Object_Name__c,Parent_Object_Name__c,Child_Record_Name__c,Parent_Record_Name__c,Strength__c,Notes__c from Relations__c where id=:relationshipId]; 
        }catch(Exception e){}
    }
    
    // method to update relations
    public pageReference save(){
        if((Schema.sObjectType.Relations__c.fields.From_Relation__c.isUpdateable()) && (Schema.sObjectType.Relations__c.fields.To_Relation__c.isUpdateable()) &&(Schema.sObjectType.Relations__c.fields.Strength__c.isUpdateable()) &&(Schema.sObjectType.Relations__c.fields.Notes__c.isUpdateable())){
            // Querying to fetch the old data of the fields.
            Relations__c   relationOld = [select From_Relation__c,To_Relation__c  from Relations__c where id=:relationshipId]; 
            // Checks for if relation type is parent
            if( relaType == '1' )
            // Compares the value of From Relation field with old value
            if(  relationOld.From_Relation__c !=  relation.From_Relation__c ){
                 // Condition to check if the field value is sibling
                 if( relation.From_Relation__c == 'Sibling' || relation.From_Relation__c == null )
                    relation.To_Relation__c  = relation.From_Relation__c;
                 // Condition to check if the field value is not sibling
                 else if( relationOld.From_Relation__c  != 'Sibling' && relationOld.From_Relation__c  != null )
                    relation.To_Relation__c = relationOld.From_Relation__c; 
                 else 
                    relation.To_Relation__c = relation.From_Relation__c == 'Parent' ? 'Child' : 'Parent';
            }
            // Checks for if relation type is parent
            if( relaType == '2')
            // Compares the value of To Relation field with old value
            if( relationOld.To_Relation__c !=  relation.To_Relation__c ){
                // Condition to check if the field value is sibling
                if( relation.To_Relation__c == 'Sibling' || relation.To_Relation__c == null)
                    relation.From_Relation__c = relation.To_Relation__c; 
                // Condition to check if the field value is not sibling
                else if( relationOld.To_Relation__c  != 'Sibling' &&  relationOld.To_Relation__c  != null )
                    relation.From_Relation__c = relationOld.To_Relation__c; 
                else
                    relation.From_Relation__c = relation.To_Relation__c == 'Parent'?'Child':'Parent'; 
            }
            update relation;
        }
        
        PageReference pageRef;
        if(relaPlan == 'true'){ 
            pageRef = new PageReference('/apex/PlanView?id='+currentId+'&sfdc.override=1&addRelations=true');
        }
        if(relaPlan == 'false'){
            pageRef = new PageReference('/apex/DecisionView?id='+currentId+'&sfdc.override=1&addRelations=true');
        }
        return pageRef;
    }
    
    public  PageReference cancel() { 
        PageReference pageRef;
        if(relaPlan == 'true'){ 
            pageRef = new PageReference('/apex/PlanView?id='+currentId+'&sfdc.override=1&addRelations=true');
        }
        if(relaPlan == 'false'){
            pageRef = new PageReference('/apex/DecisionView?id='+currentId+'&sfdc.override=1&addRelations=true');
        }
        return pageRef;
    }
}