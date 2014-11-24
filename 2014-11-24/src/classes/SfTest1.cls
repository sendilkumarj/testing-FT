public class SfTest1{
    public Id recId {get;set;} 
    
    public Decision__c decisionDetails{get;set;}
    
    // hold the timing record for the associated decision record.
    public Timing__c timingRecord {get;set;}
    
    
    public SfTest1(ApexPages.StandardController controller) {
        //recId = ApexPages.currentPage().getParameters().get('id');
        //decisionDetails = new List<Decision__c>();
           // viewDecision();
        //decisionDetails = [Select d.Problem_Idea_Advice__c, d.Id, d.Decision_Taken__c, (Select Id From People__r where id = :controller.getId()) From Decision__c d];   
        System.debug('----------Hi---------->'+controller.getId());
        Social_Input__c si = [select id,Decision__c from Social_Input__c where Id = : controller.getId()];
        decisionDetails = [select id,Problem_Idea_Advice__c,Decision_Taken__c,Title__c from Decision__c where Id = : si.Decision__c];
        // get the TimingRecord for the selected decision where stage is "Proposed" . added on 03_03_2014 start
        timingRecord  =[Select id,Actual_End_Date__c,End_Date_Time__c from Timing__c  where Related_To_ID__c =:decisionDetails.id and Stage__c='Propose'];
        // end 03_03_2014
        
    }
    
    

}