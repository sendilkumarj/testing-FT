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
@isTest(seeAllData = true)
private class TestHomaPageMobile {

      static testmethod void testHomePageMobile()
      { 
      	 User u = [SELECT Id,isActive FROM User WHERE Profile.Name = 'System Administrator' and isActive = true limit 1];
        
         System.runAs(u){
          
      	 HomePageMobile hm = new HomePageMobile();
      	 HomePageMobile.homePageData('All') ;
      	 HomePageMobile.homePageData('24hours') ;
      	 HomePageMobile.homePageData('48hours') ;
         HomePageMobile.homePageData('7days') ;
         HomePageMobile.homePageData('1month') ;
         
         HomePageMobile.genralInfo = null;         
      	 HomePageMobile.listApprovals('All') ;
      	 HomePageMobile.listApprovals('24hours') ;
      	 HomePageMobile.listApprovals('48hours') ;
      	 HomePageMobile.listApprovals('7days') ;
      	 HomePageMobile.listApprovals('1month') ;
      	 
      	 Decision__c dec = new Decision__c();
         dec.Title__c     = 'test';
         dec.Problem_Idea_Advice__c = 'test'; 
         insert dec;
         dec.Phase__c ='Share'; 
         update dec;
         dec.Phase__c ='Propose' ;
         dec.Nearest_Due_Date__c  = DateTime.now();
         update dec;      
            
         CheckforRecrussion.isRecrussion =  false;  
          
         Social_input__c sin  =  [Select User__c, id,Decision__c from Social_input__c where decision__c =: dec.Id];
         update sin;
         
         HomePageMobile.ApprovalsListData ald = new HomePageMobile.ApprovalsListData();
         //ProcessInstanceWorkitem piw = [Select p.ProcessInstance.Status, p.ProcessInstance.TargetObjectId, p.ProcessInstanceId, p.Id, p.CreatedDate, p.CreatedBy.Name, p.CreatedById, p.Actor.Name, p.ActorId From ProcessInstanceWorkitem p limit 1]; 
		 //HomePageMobile.approvedReject(dec.id,piw.id,'Approve',''); 
		   
    }
  }
  
  static testmethod void testHomePageMobile1()
      { 
      	 
      	 HomePageMobile hm = new HomePageMobile();
      	 HomePageMobile.homePageData('All') ;
      	 HomePageMobile.homePageData('24hours') ;
      	 HomePageMobile.homePageData('48hours') ;
         HomePageMobile.homePageData('7days') ;
         HomePageMobile.homePageData('1month') ;
         
         HomePageMobile.genralInfo = null;         
      	 HomePageMobile.listApprovals('All') ;
      	 HomePageMobile.listApprovals('24hours') ;
      	 HomePageMobile.listApprovals('48hours') ;
      	 HomePageMobile.listApprovals('7days') ;
      	 HomePageMobile.listApprovals('1month') ;
      	 
      	 Decision__c dec = new Decision__c();
         dec.Title__c     = 'test';
         dec.Problem_Idea_Advice__c = 'test'; 
         insert dec;
         
         ProcessInstanceWorkitem piw = [Select p.ProcessInstance.Status, p.ProcessInstance.TargetObjectId, p.ProcessInstanceId, p.Id, p.CreatedDate, p.CreatedBy.Name, p.CreatedById, p.Actor.Name, p.ActorId From ProcessInstanceWorkitem p limit 1]; 
		 HomePageMobile.approvedReject(dec.id,piw.id,'Approve',''); 
		   
    
  }
  
  static testmethod void testHomePageMobile3()
      { 
          
      	 HomePageMobile hm = new HomePageMobile();
      	 HomePageMobile.homePageData('All') ;
      	 HomePageMobile.homePageData('24hours') ;
      	 HomePageMobile.homePageData('48hours') ;
         HomePageMobile.homePageData('7days') ;
         HomePageMobile.homePageData('1month') ;
         
         HomePageMobile.genralInfo = null;         
      	 HomePageMobile.listApprovals('All') ;
      	 HomePageMobile.listApprovals('24hours') ;
      	 HomePageMobile.listApprovals('48hours') ;
      	 HomePageMobile.listApprovals('7days') ;
      	 HomePageMobile.listApprovals('1month') ;
      	 
      	 Decision__c dec = new Decision__c();
         dec.Title__c     = 'test';
         dec.Problem_Idea_Advice__c = 'test'; 
         insert dec;
         
         Social_input__c sin  =  [Select User__c, id,Decision__c from Social_input__c where decision__c =: dec.Id];
         update sin;
         
         Task task = new Task();
	     task.WhatId = dec.Id;
	     task.Subject = 'Task on decision';
	     task.ActivityDate = Date.today().addDays(1);
	     task.Status = 'Inprogress';
	     task.Description = 'Test';
	     insert task;
         
         HomePageMobile.updatedApproval(sin.Id);
         HomePageMobile.listTasks('All');
         HomePageMobile.viewTask(task.Id,'Child');
         HomePageMobile.updateTask('',task.Id,'Not Started','test');
         HomePageMobile.decisionWrapper dw = new HomePageMobile.decisionWrapper();
         ProcessInstanceWorkitem piw = [Select p.ProcessInstance.Status, p.ProcessInstance.TargetObjectId, p.ProcessInstanceId, p.Id, p.CreatedDate, p.CreatedBy.Name, p.CreatedById, p.Actor.Name, p.ActorId From ProcessInstanceWorkitem p limit 1]; 
		 HomePageMobile.decisionViewMobileData(dec.Id,piw.Id);
		   
  }
  
  	static testMethod void myUnitTestLookupPopupController() {
        // TO DO: implement unit test
        
        List<User> lstUser = [Select u.Profile.Name, u.ProfileId, u.IsActive, u.Id From User u where isActive = true AND Profile.Name = 'System Administrator'];
        system.runAs(lstUser[0]){
        
        Account accObj = new Account();
	    accObj.Name = 'Accounts';
	    insert accObj;
	    
	    Contact conObj = new Contact();
	   // conObj.Name = 'Contacts';
	    conObj.AccountId = accObj.Id;
	    conObj.LastName = 'testName';
	    insert conObj;
	    
        Decision__c decObj = new Decision__c();
        decObj.Name = 'Decisions';
	    decObj.Title__c = 'testTitle';
	    decObj.Problem_Idea_Advice__c = 'testProblem'; 
	    insert decObj;
	    
	    Plan__c planObj = new Plan__c();
	    planObj.Name = 'Plans';
	    insert planObj;
	    
	    Apexpages.currentPage().getParameters().put('searchText','');
        Apexpages.currentPage().getParameters().put('searchObj','Decisions');
        LookupPopupController lookUpObject = new LookupPopupController();
        lookUpObject.query = 'Decisions';
        lookUpObject.runQuery();
        
        Apexpages.currentPage().getParameters().put('searchObj','Plans');
        LookupPopupController lookUpObject1 = new LookupPopupController();
        lookUpObject1.query = 'Plans';
        lookUpObject1.runQuery();
        
        Apexpages.currentPage().getParameters().put('searchObj','Accounts');
        LookupPopupController lookUpObject2 = new LookupPopupController();
        lookUpObject2.query = 'Accounts';
        lookUpObject2.runQuery();
        
        Apexpages.currentPage().getParameters().put('searchObj','All');
        lookUpObject2.query = 'All';
        lookUpObject2.runQuery();
        
        Apexpages.currentPage().getParameters().put('searchObj','Contacts');
        LookupPopupController lookUpObject3 = new LookupPopupController();
        lookUpObject3.query = 'Contacts';
        lookUpObject3.runQuery();
        
    }
  }
  
  static testmethod void testKanbanBoardAndCards(){
  	
  	 Decision__c decObj = new Decision__c();
     decObj.Name = 'Decisions';
     decObj.Title__c = 'testTitle';
     decObj.Problem_Idea_Advice__c = 'testProblem'; 
     insert decObj;
  	 
  	 Task task = new Task();
     task.WhatId = decObj.Id;
     task.Subject = 'Task on decision';
     task.ActivityDate = Date.today().addDays(1);
     task.Status = 'Inprogress';
     task.Description = 'Test';
     insert task;
  	 
  	 KanbanBoardAndCards kbc = new KanbanBoardAndCards();
  	 Apexpages.currentPage().getParameters().put('assignedId','AssignedTo');
  	 Apexpages.currentPage().getParameters().put('dueDateSelected','48hours');
  	 Apexpages.currentPage().getParameters().put('userSelected','Default');
  	 Apexpages.currentPage().getParameters().put('recRelatedWhatId',decObj.Id);
  	 Apexpages.currentPage().getParameters().put('taskSelectedId',task.Id);
  	 ApexPages.currentPage().getParameters().put('recordAccess','true');
  	 ApexPages.currentPage().getParameters().put('sendingNotification','true');
  	 kbc.searchFilter();
  	 kbc.createNewTask();
  	 KanbanBoardAndCards.updateTask(task.Id,'Inprogress');
  	 Apexpages.currentPage().getParameters().put('lookUpRecId',decObj.Id);
  	 kbc.taskDetails();
  	 kbc.updateTaskDetails();
  }
  
  static testmethod void testStrategyMap(){
  	
  	 Decision__c decObj = new Decision__c();
     decObj.Name = 'Decisions';
     decObj.Title__c = 'testTitle';
     decObj.Problem_Idea_Advice__c = 'testProblem';
     decObj.phase__c = 'Close';
     insert decObj;
  	 
  	 Topic t = new Topic();
  	 t.Name = 'New Topic1';
  	 insert t;
  	 
  	 TopicAssignment ta = new TopicAssignment();
  	 ta.EntityId = decObj.Id;
  	 ta.TopicId = t.Id;
  	 insert ta;
  	 
  	 Task task = new Task();
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
  	 
  	 Apexpages.currentPage().getParameters().put('datepickerFrom','13.2.2013');
     Apexpages.currentPage().getParameters().put('datepickerTo','13.2.2014');
     Apexpages.currentPage().getParameters().put('roleOfUser','Accountable,Responsible,Consulted,Informed');
     Apexpages.currentPage().getParameters().put('phases','Draft,Share,Propose,Decide,Execute,Evaluate,Close');
     Apexpages.currentPage().getParameters().put('userId','default');
     Apexpages.currentPage().getParameters().put('type','Decision,Plan');
  	 
  	 StrategyMap sm = new StrategyMap();
  	 sm.defaultLoad();
  	 sm.topicStrategyMap();
   }
   
   static testmethod void testTopicAdmin(){
   		
   		Topic t = new Topic();
   		t.Name = 'Another Topic1';
   		insert t;
   		
   		TopicAdminController tac = new TopicAdminController();
   		TopicAdminController.searchTopic('Another Topic1');
   		TopicAdminController.dragAndDrop('[{"text":"Row 1","name":"level1","index":0,"items":[{"text":"Another Topic","index":0},{"text":"Daily Scrum","index":1}],"expanded":true}]','[{"text":"Topic5","index":0},{"text":"Testing 123","index":1}]');
   		// commneted on 28_02_2014 method wasremoved in controller
        //TopicAdminController.dragAndSave('[{"text":"Row 1","name":"level1","index":0,"items":[{"text":"Another Topic","index":0},{"text":"Daily Scrum","index":1}],"expanded":true}]','[{"text":"Topic5","index":0},{"text":"Testing 123","index":1}]');
   		TopicAdminController.dragAndDrop('[{"text":"Row 8","name":"level1","index":1},{"text":"Row 9","name":"level1","index":2},{"text":"Row 10","name":"level1","index":3},{"text":"Row11","name":"level1","index":4},{"text":"Row 7","name":"level1","index":5},{"text":"Row 8","name":"level1","index":6},{"text":"Row 9","name":"level1","index":7}]','[{"text":"New Topic Created"},{"text":"Testing"},{"text":"Testing topic"},{"text":"Testing 123"},{"text":"Topic1"},{"text":"Topic2"},{"text":"Topic4"},{"text":"1234"},{"text":"123443"},{"text":"A1"},{"text":"Another Topic"},{"text":"Daily"},{"text":"DailyScrum"},{"text":"New Topic"},{"text":"Old Topic"},{"text":"Old Topic1"},{"text":"Topic 54321"}]');
   		// commented on 28_02_2014 method wasremoved in controller
        //TopicAdminController.dragAndSave('[{"text":"Row 8","name":"level1","index":1},{"text":"Row 9","name":"level1","index":2},{"text":"Row 10","name":"level1","index":3},{"text":"Row11","name":"level1","index":4},{"text":"Row 7","name":"level1","index":5},{"text":"Row 8","name":"level1","index":6},{"text":"Row 9","name":"level1","index":7}]','[{"text":"New Topic Created"},{"text":"Testing"},{"text":"Testing topic"},{"text":"Testing 123"},{"text":"Topic1"},{"text":"Topic2"},{"text":"Topic4"},{"text":"1234"},{"text":"123443"},{"text":"A1"},{"text":"Another Topic"},{"text":"Daily"},{"text":"DailyScrum"},{"text":"New Topic"},{"text":"Old Topic"},{"text":"Old Topic1"},{"text":"Topic 54321"}]');
   		TopicAdminController.addTopic('Another Topic2','testing');
   		TopicAdminController.addAndSave('[{"text":"Topic5","index":0},{"text":"Testing 123","index":1}]');
   }
    
    // created on 27_02_2014 
    public static testMethod void testStrategyMap1(){
             test.startTest();
             Decision__c decObj = new Decision__c();
             decObj.Name = 'Decisions';
             decObj.Title__c = 'testTitle';
             decObj.Problem_Idea_Advice__c = 'testProblem';
             decObj.phase__c = 'Proposed';
             insert decObj;
             
             Topic t = new Topic();
             t.Name = 'New Topic Created';
             insert t;
             //Topic t = [Select id from Topic where Name = 'New Topic Created'];
             
             TopicAssignment ta = new TopicAssignment();
             ta.EntityId = decObj.Id;
             ta.TopicId = t.Id;
             insert ta;
             
             Apexpages.currentPage().getParameters().put('datepickerFrom','Current focused date is Wednesday, February 27, 2013');
             Apexpages.currentPage().getParameters().put('datepickerTo','Current focused date is Wednesday, February 27, 2014');
             Apexpages.currentPage().getParameters().put('roleOfUser','Accountable,Responsible,Consulted,Informed');
             Apexpages.currentPage().getParameters().put('phases','Draft,Share,Propose,Decide,Execute,Evaluate,Close');
             Apexpages.currentPage().getParameters().put('userId','default');
             Apexpages.currentPage().getParameters().put('type','Decision,Plan');
            
             Social_Input__c si = [Select id, User__c from Social_Input__c where Decision__c=:decObj.id ];
             si.User__c = UserInfo.getUserId();
             update si;
             StrategyMap sm = new StrategyMap();
             sm.defaultLoad();
             //System.assertEquals(String.valueof(decObj.id),'a');
             sm.topicStrategyMap();
             test.stopTest();
        
    }
    
}