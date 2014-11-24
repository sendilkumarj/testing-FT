@isTest
public class TestDecisionSharingRecalculation {
	
	static testMethod void testApexSharing(){
       // Instantiate the class implementing the Database.Batchable interface.     
        
        Decision__c decision = new Decision__c();
    	decision.Title__c = 'Decision test class';
    	decision.Decision_Taken__c = 'Test decision';
    	decision.Problem_Idea_Advice__c = 'decision problem stateent';
    	decision.Due_Date__c = Datetime.now();
    	decision.Phase__c = 'Draft';
    	decision.Priority__c = 'High';
    	decision.Private__c = true;
    	insert decision;
        
        Social_Input__c social_1 = new Social_Input__c(User__c = Userinfo.getUserId(),Decision__c = decision.id, Backup_for_Accountable__c = true);
        
        insert social_1;
        
        Test.startTest();
        
        DecisionSharingRecalculation recalc = new DecisionSharingRecalculation();
        // Invoke the Batch class.
        String jobId = Database.executeBatch(recalc,200);
        
        Test.stopTest();
    }
    
    static testMethod void testApexSharing1(){
       // Instantiate the class implementing the Database.Batchable interface.     
        
        Plan__c plan = new Plan__c();
        plan.name = 'test plan';
        insert plan;
        
        Social_Input__c social_1 = new Social_Input__c(User__c = Userinfo.getUserId(),Plan__c = plan.id, responsible__c = true);
        
        insert social_1;
        
        Test.startTest();
        
        PlanSharingRecalculation recalc = new PlanSharingRecalculation();
        // Invoke the Batch class.
        String jobId = Database.executeBatch(recalc,200);
        
        Test.stopTest();
    }
}