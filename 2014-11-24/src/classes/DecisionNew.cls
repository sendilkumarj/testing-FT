/* 
    ********************************************************************** 
    Created by: Neha
    Last Modified by: Neha
    Style: Force.com & Metro
    Description: This controller is written to save the decision record into the database on creation.
                 Also replaced the salesforce RTF fields to kendo RTF.
    ********************************************************************** 
*/
 
public with sharing class DecisionNew{
    
    // Initialize decision
    public Decision__c decision {get;set;}
    
    public DecisionNew(ApexPages.StandardController controller){
        // Create a new instance of decision
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=8');
        decision = new  Decision__c();
       /* this.decision = getDecision();*/
    }
    
    /* public List<Schema.FieldSetMember> getFields() {
        return SObjectType.Decision__c.FieldSets.Customer_Specific.getFields();
    }
    
    public Decision__c getDecision() {
        String query = 'SELECT ';
        for(Schema.FieldSetMember f : this.getFields()) {
            query += f.getFieldPath() + ', ';
        }
        query += 'Name, Title__c,Problem_Statement__c,Decision__c,Priority__c,Identifier__c,Private__c, Decision_Approach__c,Decision_Making_Style__c,Decision_Type__c,Due_Date__c,Category__c,Estimated_Direct_Cost__c,Estimated_Full_time_Equivalent_FTE__c,Estimated_Investment__c,Estimated_Net_Present_Value__c,Estimated_People_Involved__c,Estimated_Revenue__c  FROM Decision__c LIMIT 1';
        return Database.query(query);
    }*/
    
    // Save decision
    public PageReference saveDecision(){
        
        pageReference decisionViewPage;
        //String kendoRtfProblemstatement = Apexpages.currentPage().getParameters().get('ProblemStatementValue');
        //String kendoRtfDecision = Apexpages.currentPage().getParameters().get('DecisionValue');
        //kendoRtfProblemstatement  = removeHTML(kendoRtfProblemstatement);
        //kendoRtfDecision = removeHTML(kendoRtfDecision);
        
        //decision.Problem_Statement__c = kendoRtfProblemstatement; 
        //decision.Decision__c = kendoRtfDecision;
        
        // Inserting decision record
        if(FLS.decisionCreateable()) {
            insert decision;
            if(ApexPages.currentPage().getParameters().get('parentId') != null) {
                Decision__c parentDecision = [select id, Title__c from Decision__c where id=: ApexPages.currentPage().getParameters().get('parentId')];
                Relations__c rel = new Relations__c();
                rel.Child_ID__c = decision.Id;
                rel.Child_Object_Name__c = 'Decision';
                rel.Child_Record_Name__c = decision.Title__c;
                rel.Child_Relation__c = 'Child';
                rel.Parent_ID__c = parentDecision.Id;
                rel.Parent_Record_Name__c = parentDecision.Title__c;
                rel.Parent_Object_Name__c = 'Decision';
                
                if(FLS.relationCreateable()) {
                    insert rel;
                }
                decisionViewPage = new pageReference('/apex/decisionView?addRelations=true&id='+parentDecision.Id);
            }
            else {
                decisionViewPage = new pageReference('/apex/decisionView?id='+decision.Id);
            }
        }
        return decisionViewPage;
    }
    
    // Remove 
    private String removeHTML(String htmlString) { 
        /*String noHTMLString = '';
        if(htmlString != null) {
            noHTMLString = htmlString.replaceAll('&amp;', '&'); 
            noHTMLString = noHTMLString.replaceAll('&quot', '\"');
            noHTMLString = noHTMLString.replaceAll('&#039;', '\'');
            noHTMLString = noHTMLString.replaceAll('&lt;', '<');
            noHTMLString = noHTMLString.replaceAll('&gt;', '>');
        }
        return noHTMLString;*/
        return null;
    }
    
    public Pagereference customCancel(){
        Id parentId = Apexpages.currentPage().getParameters().get('parentId');
        if(parentId != null){
            Pagereference pr = new Pagereference('/apex/DecisionView?id='+parentId+'&sfdc.override=1#0');
            return pr;
        } else {
            String x; 
            Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
            for(String sObj : Schema.getGlobalDescribe().keySet()){
                Schema.DescribeSObjectResult r =  gd.get(sObj).getDescribe();
                String tempName = r.getName();
                String tempPrefix = r.getKeyPrefix();
                System.debug('Processing Object['+tempName + '] with Prefix ['+ tempPrefix+']');
                if(tempName.equals('fingertip_a__Decision__c') || tempName.equals('Decision__c')) {
                    x= tempPrefix;
                }
             }
            Pagereference pr = new Pagereference('/'+x+'/o');
            return pr;
        }
    }
}