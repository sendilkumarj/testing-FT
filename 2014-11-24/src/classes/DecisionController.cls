public with sharing class DecisionController {
    
    public Decision__c decision {get; set;}
    public Decimal pendingTaskCount{get;set;}
    public DecisionController(apexpages.standardcontroller con) {
        //decision = new Decision__c();
        pendingTaskCount = 5;
        //decision = [select id,Decision_Type__c,Decision_Approach__c,Category__c,Decision_Making_Style__c,Priority__c,Problem_Idea_Advice__c,Decision_Taken__c,Title__c  from Decision__c where Id = : con.getId()];
    }
    
    public Pagereference customSave(){
        update decision;
        
        /*FeedItem post = new FeedItem();
        post.ParentId = decision.Id;
        post.Body = 'created a case';
        post.type = 'LinkPost'; 
        post.LinkUrl = '/' + decision.id;
        post.Title = decision.Title__c;
        insert post;*/
         
        return null;
    }
}