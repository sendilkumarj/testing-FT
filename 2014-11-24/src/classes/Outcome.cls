/*
 Created by:Neha
 Last Modified by: Neha
 Style: Force.com & Metro
 Description:
*/
public with sharing class Outcome{
    
    //JSON string initialization for outcomes
    public static String outcomeJSON {get;private set;}
    
    //Defining constructor
    public Outcome(){
       //call outcome method
        viewOutcomeGraph();  
    }
    
    // Create outcome JSON string
    public static string viewOutcomeGraph(){
    
        List<Decision__c> decision = [Select ID,Name,Title__c,Phase__c,LastModifiedDate,CreatedDate,Due_Date__c from Decision__c where Phase__c = 'Evaluate' OR  Phase__c = 'Close' limit 50000];
        
        // Set id for decision.
        set<ID> decisionID= new set<ID>();
        // To fetch the id's of decision record.
        for(Decision__c d: decision) {
            decisionID.add(d.ID);
        }
        
        // Initialize outcome class that is declared under wrapper section area.
        List<OutcomeWrapper> socialList = new List<OutcomeWrapper>(); 
        for(Social__c social : [Select Id, Related_To_Name__c, Avg_Effort__c, Avg_Result__c, Related_To_ID__c From Social__c where Related_To_ID__c In: decisionID]){
           if(social.Avg_Effort__c > 0 && social.Avg_Result__c > 0) {
               OutcomeWrapper oc = new OutcomeWrapper();
               oc.decision = String.escapeSingleQuotes(social.Related_To_Name__c);
               oc.xAxis = String.valueof(social.Avg_Effort__c.intValue());
               oc.yAxis = String.valueof(social.Avg_Result__c.intValue());
               socialList.add(oc);
           }
        }   
        
        //serialize social record list 
        outcomeJSON = JSON.serialize(socialList);
        return outcomeJSON;  
    }
    
    /* Wrapper class section */
    public class OutComewrapper {
        public String decision;
        public String xAxis;
        public String yAxis;
    }
}