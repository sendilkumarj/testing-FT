/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@istest

public class TestStrategyMap{
	 // created on 27_02_2014 
    public static testMethod void testStrategyMap(){
         Topic_Selected_Data__c customSettingRec1 = new Topic_Selected_Data__c(Name ='0',RecordNumber__c=0,Topic_Json__c='[{"text": "Row 1","name": "level1","index": 0,"items": [{"text": "New Topic Test Class","index": 0 },{"text":"01234567890123456789012345678901234567890123456789","index": 1},' );
         insert customSettingRec1;
         Topic_Selected_Data__c customSettingRec2 = new Topic_Selected_Data__c(Name ='1',RecordNumber__c=1,Topic_Json__c='{"text": "0123456789012345678901234567890123456789","index": 2},{"text": "01234567890123456789","index": 3 },{"text": "1234","index": 4},{"text": "0123456789","index": 4}],"expanded": true }]' );
         insert customSettingRec2;
         test.startTest();
         Decision__c decObj = new Decision__c();
         decObj.Name = 'Decisions';
         decObj.Title__c = 'testTitle';
         decObj.Problem_Idea_Advice__c = 'testProblem';
         decObj.phase__c = 'Proposed';
         insert decObj;
         
         Topic t = new Topic (Name='New Topic Test Class');
         insert t;
         
         TopicAssignment ta = new TopicAssignment();
         ta.EntityId = decObj.Id;
         ta.TopicId = t.Id;
         insert ta;
         
         /*Task task = new Task();
         task.WhatId = decObj.Id;
         task.Subject = 'Task on decision';
         task.ActivityDate = Date.today().addDays(1);
         task.Status = 'Inprogress';
         task.Description = 'Test';
         insert task;
         
         Event event = new Event();
         event.WhatId = decObj.Id;
         event.Subject = 'Event on decision ';
         event.ActivityDate = Date.today().addDays(-2);
         event.ActivityDateTime = Datetime.now();
         event.DurationInMinutes = 50;
         insert event;
         
         Event event1 = new Event();
         event1.WhatId = planObj.Id;
         event1.Subject = 'Event on decision ';
         event1.ActivityDate = Date.today().addDays(-2);
         event1.ActivityDateTime = Datetime.now();
         event1.DurationInMinutes = 50;
         insert event1;
         
          */
         
        
         
        
         Apexpages.currentPage().getParameters().put('datepickerFrom','Current focused date is Wednesday, February 27, 2013');
         Apexpages.currentPage().getParameters().put('datepickerTo','Current focused date is Wednesday, February 27, 2014');
         Apexpages.currentPage().getParameters().put('roleOfUser','Accountable,Responsible,Consulted,Informed');
         Apexpages.currentPage().getParameters().put('phases','Draft,Share,Propose,Decide,Execute,Evaluate,Close');
         Apexpages.currentPage().getParameters().put('userId','default');
         Apexpages.currentPage().getParameters().put('type','Decision,Plan');
        
         Social_Input__c si = [Select id, User__c from Social_Input__c where Decision__c=:decObj.id ];
         si.User__c = Userinfo.getUserId();
         update si;
         StrategyMap sm = new StrategyMap();
         sm.defaultLoad();
         //System.assertEquals(String.valueof(t.id),'a');
         //System.assertEquals(String.valueof(ta.id),'a');
         sm.topicStrategyMap();
         test.stopTest();
    }
    
    public static testMethod void testTaskViewPopupController(){
    	
    	ApexPages.currentPage().getParameters().put('sendingNotification','true');
    	TaskViewPopupController tc = new TaskViewPopupController();
    	
    	Plan__c planObj = new Plan__c();
        planObj.Name = 'Plans';
        insert planObj;
    	
    	Task task = new Task();
	    task.WhatId = planObj.Id;
	    task.Subject = 'Task on decision';
	    task.ActivityDate = Date.today().addDays(1);
	    task.Status = 'Inprogress';
	    task.Description = 'Test';
	    insert task;
    	
    	tc.newSelectedTask = task;
    	tc.gettaskIdToEdit();
    	tc.settaskIdToEdit(task.Id);
    	tc.showTaskDetails();
    	tc.updateTaskDetails();
    }
}