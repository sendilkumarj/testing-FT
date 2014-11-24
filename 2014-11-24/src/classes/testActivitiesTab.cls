@istest
public class testActivitiesTab{

   static  testmethod  void testActivitiesTabcon(){
  WorkbenchHomePage whp = new WorkbenchHomePage();
  ActivityTab act = new ActivityTab(whp);
  
    String activitiesJson = ActivityTab.classicTab();
    ActivityTab.updateActivities(activitiesJson );
    
    
  
  }
	
	static  testmethod  void testPlanview(){
		
		Plan__c p = new Plan__c();
		p.Name = 'New Plan';
		insert p;
		
		ApexPages.StandardController sc = new ApexPages.StandardController(p);
		Planview pv = new Planview(sc);
		
		pv.plan = p;
		
		Decision__c decisionParent = new Decision__c();
        decisionParent.Title__c = 'Decision test class';
        decisionParent.Decision_Taken__c = 'Test decision';
        decisionParent.Problem_Idea_Advice__c = 'decision problem stateent ';
        decisionParent.Due_Date__c = Datetime.now();
        decisionParent.Phase__c = 'Draft';
        decisionParent.Priority__c = 'High';
        decisionParent.Private__c = true;
        insert decisionParent;
		
		ApexPages.currentPage().getParameters().put('decisionId',decisionParent.Id);
		pv.intialiseTask();
		pv.intialisePlanTask();
	}
}