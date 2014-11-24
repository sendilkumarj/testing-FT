/* 
    ********************************************************************** 
    Created by: Kiran Kumar
    Last Modified by: Kiran Kumar
    Style: Force.com & Metro
    Description: a) This is primarily to fetch relations records for the record which is viewed.
                 b) This uses getter and setter method to fetch the realtions records.
    ********************************************************************** 
 */
public with sharing class RelatedList {
    
    public String objectType;
    public String rId;
    public List<Relationship> lstRealtionship {get; set;}
    public String jsonRelation {get;set;}
    
    // Here getter and setter methods are used because when we call component onload in the constructor data which is passed from the page is getting null so we used getter setter methods.
    public String getobjTypeLabel(){
        return objectType;
    }
    public void setobjTypeLabel(String objType){
        objectType = objType;
    }
    public String getrecordId(){
        return rId;
    }
    public void setrecordId(Id recId){
        rId = recId;
        // Called this method in a setter method because this method is executed after constructer is executed.
        listRelationRecords();
    }
    
    // Empty
    public RelatedList(){

    }
    
    //variable to send user locale 
    public static string  userLocaleSidKey{get;set;}
    static{
            //set user locale here
            userLocaleSidKey  = UserInfo.getLocale().replace('_','-');
    } 
    
    public void listRelationRecords(){ 
        // Method to fetch all the relations records for the record which is viewed.
        List<Relations__c> lstRelations = new List<Relations__c>();
        lstRealtionship = new List<Relationship>();
        GeneralInformation genralInfo  = new GeneralInformation();
        
        lstRelations = [select Parent_Relation__c,Parent_ID__c,Child_ID__c,Child_Relation__c,From_Relation__c,To_Relation__c,Child_Object_Name__c,Parent_Object_Name__c,Child_Record_Name__c,Parent_Record_Name__c,Strength__c,Notes__c from Relations__c where (Parent_ID__c =: rId or Child_ID__c = : rId) and Type__c = 'Relation' order by LastModifiedDate desc limit 1000];
        
        set<Id> setRecIds = new set<Id>();
        for(Relations__c r : lstRelations){
        	setRecIds.add(r.Parent_ID__c);
        	setRecIds.add(r.Child_ID__c);
        }
        map<Id,Decision__c> mapDecision = new map<Id,Decision__c>([select id,Phase__c,Progress__c,Problem_Idea_Advice__c,Decision_Taken__c from Decision__c where Id IN : setRecIds]);
        map<Id,String> mapProgress = new map<Id,String>();
        map<Id,Plan__c> mapPlan = new map<Id,Plan__c>([select id,Start_Time__c,End_Time__c from Plan__c where Id IN : setRecIds]);
        for(Relations__c r : lstRelations){
            Relationship rel = new Relationship();
            if(objectType == 'User'){   
                rel.recordId = r.Parent_ID__c == rId ? r.Child_ID__c : r.Child_ID__c == rId ? r.Parent_ID__c : '';
                rel.recordId = rel.recordId+'?noredirect=1'; 
            } else {
                rel.recordId = r.Parent_ID__c == rId ? r.Child_ID__c : r.Child_ID__c == rId ? r.Parent_ID__c : '';
            }
            rel.recordName = r.Parent_ID__c == rId ? r.Child_Record_Name__c : r.Child_ID__c == rId ? r.Parent_Record_Name__c : '';
            rel.objectIcon = r.Parent_Object_Name__c == 'Decision' ? genralInfo.imageUrlMap.get('decisionicon16') : r.Parent_Object_Name__c == 'Plan' ? genralInfo.imageUrlMap.get('planicon16') : r.Child_Object_Name__c == 'Decision' ? genralInfo.imageUrlMap.get('decisionicon16') : r.Child_Object_Name__c == 'Plan' ? genralInfo.imageUrlMap.get('planicon16') : '';
            rel.relation =  r.Parent_ID__c == rId ? r.From_Relation__c : r.Child_ID__c == rId ? r.To_Relation__c : '';
            rel.strength = r.Strength__c == null ? '' : r.Strength__c;
            rel.notes = r.Notes__c == null  ? '' : r.Notes__c ;
            rel.phase = mapDecision != null && r.Parent_ID__c != null && mapDecision.get(Id.valueOf(r.Parent_ID__c)) != null ? mapDecision.get(Id.valueOf(r.Parent_ID__c)).Phase__c : mapDecision != null && r.Child_ID__c != null && mapDecision.get(Id.valueOf(r.Child_ID__c)) != null ? mapDecision.get(Id.valueOf(r.Child_ID__c)).Phase__c : '';
            rel.objectName = r.Parent_ID__c == rId ? r.Child_Object_Name__c : r.Child_ID__c == rId ? r.Parent_Object_Name__c : '';
            // Below values are used to display call out values.
            if(rel.objectName == 'Decision'){
            	rel.popupField1 = mapDecision != null && r.Parent_ID__c != null && mapDecision.get(Id.valueOf(r.Parent_ID__c)) != null && mapDecision.get(Id.valueOf(r.Parent_ID__c)).Problem_Idea_Advice__c != null ? mapDecision.get(Id.valueOf(r.Parent_ID__c)).Problem_Idea_Advice__c : mapDecision != null && r.Child_ID__c != null && mapDecision.get(Id.valueOf(r.Child_ID__c)) != null && mapDecision.get(Id.valueOf(r.Child_ID__c)).Problem_Idea_Advice__c != null ? mapDecision.get(Id.valueOf(r.Child_ID__c)).Problem_Idea_Advice__c : '';
            	rel.popupFieldName1 = 'Description' ;
            	rel.popupField2 = mapDecision != null && r.Parent_ID__c != null && mapDecision.get(Id.valueOf(r.Parent_ID__c)) != null && mapDecision.get(Id.valueOf(r.Parent_ID__c)).Decision_Taken__c != null ? mapDecision.get(Id.valueOf(r.Parent_ID__c)).Decision_Taken__c : mapDecision != null && r.Child_ID__c != null && mapDecision.get(Id.valueOf(r.Child_ID__c)) != null && mapDecision.get(Id.valueOf(r.Child_ID__c)).Decision_Taken__c != null ? mapDecision.get(Id.valueOf(r.Child_ID__c)).Decision_Taken__c : '';
            	rel.popupFieldName2 = 'Decision';
            	// Progress indicator varaiable to display the progress indicator icon on related items.
            	String progressIndicator = mapDecision != null && r.Parent_ID__c != null && mapDecision.get(Id.valueOf(r.Parent_ID__c)) != null && mapDecision.get(Id.valueOf(r.Parent_ID__c)).Progress__c != null ? mapDecision.get(Id.valueOf(r.Parent_ID__c)).Progress__c : mapDecision != null && r.Child_ID__c != null && mapDecision.get(Id.valueOf(r.Child_ID__c)) != null && mapDecision.get(Id.valueOf(r.Child_ID__c)).Progress__c != null ? mapDecision.get(Id.valueOf(r.Child_ID__c)).Progress__c : '';
            	rel.progressValue = mapDecision != null && r.Parent_ID__c != null && mapDecision.get(Id.valueOf(r.Parent_ID__c)) != null && mapDecision.get(Id.valueOf(r.Parent_ID__c)).Progress__c != null ? mapDecision.get(Id.valueOf(r.Parent_ID__c)).Progress__c : mapDecision != null && r.Child_ID__c != null && mapDecision.get(Id.valueOf(r.Child_ID__c)) != null && mapDecision.get(Id.valueOf(r.Child_ID__c)).Progress__c != null ? mapDecision.get(Id.valueOf(r.Child_ID__c)).Progress__c : '';
            } else if(rel.objectName == 'Plan'){
            	rel.popupField1 = mapPlan != null && r.Parent_ID__c != null && mapPlan.get(Id.valueOf(r.Parent_ID__c)) != null && mapPlan.get(Id.valueOf(r.Parent_ID__c)).Start_Time__c != null ? ''+mapPlan.get(Id.valueOf(r.Parent_ID__c)).Start_Time__c : mapPlan != null && r.Child_ID__c != null && mapPlan.get(Id.valueOf(r.Child_ID__c)) != null && mapPlan.get(Id.valueOf(r.Child_ID__c)).Start_Time__c != null ? ''+mapPlan.get(Id.valueOf(r.Child_ID__c)).Start_Time__c : '';
            	rel.popupFieldName1 = 'Start Time';
            	rel.popupField2 = mapPlan != null && r.Parent_ID__c != null && mapPlan.get(Id.valueOf(r.Parent_ID__c)) != null && mapPlan.get(Id.valueOf(r.Parent_ID__c)).End_Time__c != null ? ''+mapPlan.get(Id.valueOf(r.Parent_ID__c)).End_Time__c : mapPlan != null && r.Child_ID__c != null && mapPlan.get(Id.valueOf(r.Child_ID__c)) != null && mapPlan.get(Id.valueOf(r.Child_ID__c)).End_Time__c != null ? ''+mapPlan.get(Id.valueOf(r.Child_ID__c)).End_Time__c : '';
            	rel.popupFieldName2 = 'End Time';
            }
            lstRealtionship.add(rel); 
        }
        jsonRelation = JSON.serialize(lstRealtionship);
    }
     
    public class Relationship{
    	public String objectIcon{get;set;}
    	public String relation{get;set;}  
    	public String strength{get;set;}
    	public String phase{get;set;}
    	public String notes{get;set;}
        public String recordId{get;set;}
        public String recordName{get;set;}
        public String objectName{get;set;}
        public String popupField1{get;set;}
        public String popupField2{get;set;}
        public String popupFieldName1{get;set;}
        public String popupFieldName2{get;set;}
        public String progressValue {get;set;}
    }
}