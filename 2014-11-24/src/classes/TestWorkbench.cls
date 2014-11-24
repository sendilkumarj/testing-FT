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
@isTest
private class TestWorkbench {

    static testMethod void testWorkbenchDecisionView() {
        // TO DO: implement unit test
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
        User u = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' and isActive = true limit 1];
        
        System.runAs(u){
          
          Decision__c decision = new Decision__c();
          Decision.Problem_Idea_Advice__c = 'Problem';
          Decision.Title__c = 'Test Decision Record';
          Decision.Priority__c = 'Normal';
          Decision.Phase__c = 'Draft';
          Decision.Status__c = 'Undecided';
          insert decision;
          
      
          
          date todayDate = Date.today();
          Task task = new Task();
          task.WhatId = Decision.Id;
          task.Subject = 'Task on decision';
          task.ActivityDate = todayDate.addDays(-14);
          task.Status = 'Inprogress';
          insert task; 
          
          ApexPages.currentPage().getParameters().put('timeFrame','1 Week');
          ApexPages.currentPage().getParameters().put('owner',u.id);
          ApexPages.currentPage().getParameters().put('phases','');
          ApexPages.currentPage().getParameters().put('status','');
          
          WorkbenchDecisionView wrk = new WorkbenchDecisionView();
          
          ApexPages.currentPage().getParameters().put('timeFrame','2 Weeks');
          ApexPages.currentPage().getParameters().put('owner',u.id);
          ApexPages.currentPage().getParameters().put('phases','Draft');
          ApexPages.currentPage().getParameters().put('status','All');
          
          WorkbenchDecisionView wrk1 = new WorkbenchDecisionView();
          
          ApexPages.currentPage().getParameters().put('timeFrame','3 Week');
          ApexPages.currentPage().getParameters().put('owner',u.id);
          ApexPages.currentPage().getParameters().put('phases','All');
          ApexPages.currentPage().getParameters().put('status','Undecided');
          
          WorkbenchDecisionView wrk2 = new WorkbenchDecisionView();
        }
    }
    
    static testMethod void testWorkbenchPlanList() {
        // TO DO: implement unit test
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
        /*User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = 'testuser@test123456789.com';
        u.CompanyName = 'test.com';
        u.Title = 'Test User';
        u.Username = 'testuser2@test123456789.com';
        u.Alias = 'testuser';
        u.CommunityNickname = 'Test User';
        u.TimeZoneSidKey = 'America/Mexico_City';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = pf.Id;
        u.LanguageLocaleKey = 'en_US';
        
        insert u;*/
        
        //System.runAs(u){
            
          WorkbenchHomePage wrkHome = new WorkbenchHomePage();
          
          Plan__c plan = new Plan__c();
          plan.Name = 'Test plan record';
          insert plan;
          
          WorkbenchPlanList wrkPlanList = new WorkbenchPlanList();
          
          ApexPages.currentPage().getParameters().put('searchText','Test*');
          
          wrkPlanList.searchPlan();
          
          ApexPages.currentPage().getParameters().put('searchText','');
          
          wrkPlanList.searchPlan();
          wrkHome.displayType();
        //}
    }
    
    static testMethod void testWorkbenchPlanItemList() {
        // TO DO: implement unit test
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
        User u = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' and isActive = true limit 1];
        
        System.runAs(u){
            
          Plan__c plan = new Plan__c();
          plan.Name = 'Test plan record';
          insert plan;
          
          Decision__c decision = new Decision__c();
          decision.Problem_Idea_Advice__c = 'Problem';
          decision.Priority__c = 'Normal';
          decision.Title__c = 'Test record of Decision';
          insert decision;
          
          Account a = new Account();
          a.name = 'test Record for account';
          insert a ;
          
          Contact c  = new Contact();
          c.LastName = 'Test';
          insert c;
          
          date todayDate = Date.today();
          Task task = new Task();
          task.WhatId = Decision.Id;
          task.Subject = 'Test Task on decision';
          task.ActivityDate = todayDate.addDays(-14);
          task.Status = 'Inprogress';
          insert task; 
          
          WorkbenchPlanItemList wrkPlanItem = new WorkbenchPlanItemList();
          
          ApexPages.currentPage().getParameters().put('searchItemText','Test*');
          
          wrkPlanItem.searchItemPlan();
          
          ApexPages.currentPage().getParameters().put('searchItemText','');
          
          wrkPlanItem.searchItemPlan();
          
        }
    }
    
    static testMethod void testWorkbenchPlanView() {
        // TO DO: implement unit test
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
        User u = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' and isActive = true limit 1];
        
        System.runAs(u){
            
          Plan__c plan = new Plan__c();
          plan.Name = 'Test plan record';
          insert plan;
          
          Decision__c decision = new Decision__c();
          decision.Problem_Idea_Advice__c = 'Problem';
          decision.Priority__c = 'Normal';
          decision.Title__c = 'Test record of Decision';
          insert decision;
          
          ApexPages.currentPage().getParameters().put('planid',plan.id);
          WorkbenchPlanView wrkPlanV = new WorkbenchPlanView();
          plan.Name = 'testing plan record';
          update plan;
          wrkPlanV.planDataToSave(plan.Id);
          wrkPlanV.savePlan();
          
          
        
          
          Account a = new Account();
          a.Name = 'Test account';
          insert a ;
          
          Contact c = new Contact();
          c.LastName = 'Test';
          insert c;
          
          /*date todayDate = Date.today();
          Task task = new Task();
          task.WhatId = Decision.Id;
          task.Subject = 'Test Task on decision';
          task.ActivityDate = todayDate.addDays(-14);
          task.Status = 'Inprogress';
          insert task; */
          
          Plan__c planB = new Plan__c();
          planB.Name = 'testing plan b';
          insert planB;
          
          Note note = new Note();
          note.parentId = planB.id;
          note.Title = 'note';
          insert note;
          
          Relations__c relationItem1 = new Relations__c();
          relationItem1.Child_Id__c = Decision.Id;
          relationItem1.Child_Record_Name__c = Decision.Title__c;
          relationItem1.Child_Object_Name__c = 'Decision';
          relationItem1.Parent_Id__c = plan.Id;
          relationItem1.Days__c = '23';
          relationItem1.Minutes__c = '23';
          relationItem1.Hours__c = '23';
          relationItem1.Parent_Record_Name__c = plan.Name;
          relationItem1.Parent_Object_Name__c = 'Plan';
          relationItem1.Type__c = 'Item';
          insert relationItem1;
          
          /*Relations__c relationItem2 = new Relations__c();
          relationItem2.Child_Id__c = task.Id;
          relationItem2.Child_Record_Name__c = task.Subject;
          relationItem2.Child_Object_Name__c = 'Task';
          relationItem2.Parent_Id__c = plan.Id;
          relationItem2.Days__c = '23';
          relationItem2.Minutes__c = '23';
          relationItem2.Hours__c = '23';
          relationItem2.Parent_Record_Name__c = plan.Name;
          relationItem2.Parent_Object_Name__c = 'Plan';
          relationItem2.Type__c = 'Item';
          insert relationItem2; */
          
          Relations__c relationItem3 = new Relations__c();
          relationItem3.Child_Id__c = a.Id;
          relationItem3.Child_Record_Name__c = a.name;
          relationItem3.Child_Object_Name__c = 'Account';
          relationItem3.Parent_Id__c = plan.Id;
          relationItem3.Days__c = '23';
          relationItem3.Minutes__c = '23';
          relationItem3.Hours__c = '23';
          relationItem3.Parent_Record_Name__c = plan.Name;
          relationItem3.Parent_Object_Name__c = 'Plan';
          relationItem3.Type__c = 'Item';
          insert relationItem3;
          
          Relations__c relationItem4 = new Relations__c();
          relationItem4.Child_Id__c = c.Id;
          relationItem4.Child_Record_Name__c = c.name;
          relationItem4.Child_Object_Name__c = 'Contact';
          relationItem4.Parent_Id__c = plan.Id;
          relationItem4.Days__c = '23';
          relationItem4.Minutes__c = '23';
          relationItem4.Hours__c = '23';
          relationItem4.Parent_Record_Name__c = plan.Name;
          relationItem4.Parent_Object_Name__c = 'Plan';
          relationItem4.Type__c = 'Item';
          insert relationItem4;
          
          Relations__c relationItem5 = new Relations__c();
          relationItem5.Child_Id__c = note.Id;
          relationItem5.Child_Record_Name__c = note.title;
          relationItem5.Child_Object_Name__c = 'Note';
          relationItem5.Parent_Id__c = plan.Id;
          relationItem5.Days__c = '23';
          relationItem5.Minutes__c = '23';
          relationItem5.Hours__c = '23';
          relationItem5.Parent_Record_Name__c = plan.Name;
          relationItem5.Parent_Object_Name__c = 'Plan';
          relationItem5.Type__c = 'Item';
          insert relationItem5;
          
          Relations__c relationItem6 = new Relations__c();
          relationItem6.Child_Id__c = planb.Id;
          relationItem6.Child_Record_Name__c = planb.name;
          relationItem6.Child_Object_Name__c = 'Plan';
          relationItem6.Parent_Id__c = plan.Id;
          relationItem6.Days__c = '23';
          relationItem6.Minutes__c = '23';
          relationItem6.Hours__c = '23';
          relationItem6.Parent_Record_Name__c = plan.Name;
          relationItem6.Parent_Object_Name__c = 'Plan';
          relationItem6.Type__c = 'Item';
          insert relationItem6;
          
          Relations__c relationItem7 = new Relations__c();
          relationItem7.Child_Object_Name__c = 'Issue';
          relationItem7.Parent_Id__c = plan.Id;
          relationItem7.Days__c = '23';
          relationItem7.Minutes__c = '23';
          relationItem7.Hours__c = '23';
          relationItem7.Parent_Record_Name__c = plan.Name;
          relationItem7.Parent_Object_Name__c = 'Plan';
          relationItem7.Type__c = 'Item';
          insert relationItem7;
          
          
          
          WorkbenchPlanView.itemView(plan.Id);
          
        }
    }
    
    static testMethod void testWorkbenchPlanViewOperation() {
        // TO DO: implement unit test
          Plan__c plan = new Plan__c();
          plan.Name = 'Test plan record';
          insert plan;
          
          WorkbenchPlanView.addNoteItems(plan.id,'Title','Subject');
    }
    
    static testMethod void testWorkbenchPlanViewMoveUpOperation() {
        // TO DO: implement unit test
            
          Plan__c plan = new Plan__c();
          plan.Name = 'Test plan record';
          insert plan;
          
          Account a = new Account();
          a.Name = 'Test account';
          insert a ;
          
          Contact c = new Contact();
          c.LastName = 'Test';
          insert c;
          
          Relations__c relationItem3 = new Relations__c();
          relationItem3.Child_Id__c = a.Id;
          relationItem3.Child_Record_Name__c = a.name;
          relationItem3.Child_Object_Name__c = 'Account';
          relationItem3.Parent_Id__c = plan.Id;
          relationItem3.Days__c = '23';
          relationItem3.Minutes__c = '23';
          relationItem3.Hours__c = '23';
          relationItem3.Parent_Record_Name__c = plan.Name;
          relationItem3.Parent_Object_Name__c = 'Plan';
          relationItem3.Type__c = 'Item';
          insert relationItem3;
          
          Relations__c relationItem4 = new Relations__c();
          relationItem4.Child_Id__c = c.Id;
          relationItem4.Child_Record_Name__c = c.name;
          relationItem4.Child_Object_Name__c = 'Contact';
          relationItem4.Parent_Id__c = plan.Id;
          relationItem4.Days__c = '23';
          relationItem4.Minutes__c = '23';
          relationItem4.Hours__c = '23';
          relationItem4.Parent_Record_Name__c = plan.Name;
          relationItem4.Parent_Object_Name__c = 'Plan';
          relationItem4.Type__c = 'Item';
          insert relationItem4;
          
          WorkbenchPlanView.moveUp(Plan.id,relationItem4.Id);
    }
    
    
    
    static testMethod void testWorkbenchPlanViewDelItemOperation() {
        // TO DO: implement unit test
            
          Plan__c plan = new Plan__c();
          plan.Name = 'Test plan record';
          insert plan;
          
          Account a = new Account();
          a.Name = 'Test account';
          insert a ;
          
          Contact c = new Contact();
          c.LastName = 'Test';
          insert c;
          
          Relations__c relationItem3 = new Relations__c();
          relationItem3.Child_Id__c = a.Id;
          relationItem3.Child_Record_Name__c = a.name;
          relationItem3.Child_Object_Name__c = 'Account';
          relationItem3.Parent_Id__c = plan.Id;
          relationItem3.Days__c = '23';
          relationItem3.Minutes__c = '23';
          relationItem3.Hours__c = '23';
          relationItem3.Parent_Record_Name__c = plan.Name;
          relationItem3.Parent_Object_Name__c = 'Plan';
          relationItem3.Type__c = 'Item';
          insert relationItem3;
          
          
          
          WorkbenchPlanView.DeleteItem(Plan.id,relationItem3.Id);
    }
    
    static testMethod void testWorkbenchPlanViewCalMinsOperation() {
        // TO DO: implement unit test
          Plan__c plan = new Plan__c();
          plan.Name = 'Test plan record';
          insert plan;
          
          Account a = new Account();
          a.Name = 'Test account';
          insert a ;
          
          Contact c = new Contact();
          c.LastName = 'Test';
          insert c;
          
          Relations__c relationItem3 = new Relations__c();
          relationItem3.Child_Id__c = a.Id;
          relationItem3.Child_Record_Name__c = a.name;
          relationItem3.Child_Object_Name__c = 'Account';
          relationItem3.Parent_Id__c = plan.Id;
          relationItem3.Days__c = '23';
          relationItem3.Minutes__c = '23';
          relationItem3.Hours__c = '23';
          relationItem3.Parent_Record_Name__c = plan.Name;
          relationItem3.Parent_Object_Name__c = 'Plan';
          relationItem3.Type__c = 'Item';
          insert relationItem3;
          
          Relations__c relationItem33 = new Relations__c();
          relationItem33.Child_Id__c = a.Id;
          relationItem33.Child_Record_Name__c = a.name;
          relationItem33.Child_Object_Name__c = 'Account';
          relationItem33.Parent_Id__c = plan.Id;
          relationItem33.Days__c = '40';
          relationItem33.Minutes__c = '40';
          relationItem33.Hours__c = '40';
          relationItem33.Parent_Record_Name__c = plan.Name;
          relationItem33.Parent_Object_Name__c = 'Plan';
          relationItem33.Type__c = 'Item';
          insert relationItem33;
          
          WorkbenchPlanView.calTotalMins(Plan.id);
    }
    
    static testMethod void testWorkbenchPlanViewMoveDownOperation() {
            
          Plan__c plan = new Plan__c();
          plan.Name = 'Test plan record';
          insert plan;
          
          Account a = new Account();
          a.Name = 'Test account';
          insert a ;
          
          Contact c = new Contact();
          c.LastName = 'Test';
          insert c;
          
          Relations__c relationItem3 = new Relations__c();
          relationItem3.Child_Id__c = a.Id;
          relationItem3.Child_Record_Name__c = a.name;
          relationItem3.Child_Object_Name__c = 'Account';
          relationItem3.Parent_Id__c = plan.Id;
          relationItem3.Days__c = '23';
          relationItem3.Minutes__c = '23';
          relationItem3.Hours__c = '23';
          relationItem3.Parent_Record_Name__c = plan.Name;
          relationItem3.Parent_Object_Name__c = 'Plan';
          relationItem3.Type__c = 'Item';
          insert relationItem3;
          
          Relations__c relationItem33 = new Relations__c();
          relationItem33.Child_Id__c = a.Id;
          relationItem33.Child_Record_Name__c = a.name;
          relationItem33.Child_Object_Name__c = 'Account';
          relationItem33.Parent_Id__c = plan.Id;
          relationItem33.Days__c = '40';
          relationItem33.Minutes__c = '40';
          relationItem33.Hours__c = '40';
          relationItem33.Parent_Record_Name__c = plan.Name;
          relationItem33.Parent_Object_Name__c = 'Plan';
          relationItem33.Type__c = 'Item';
          insert relationItem33;
          
          WorkbenchPlanView.moveDown(Plan.id,relationItem3.Id);
    }
    
    static testMethod void testWorkbenchPlanViewAddItemOperation() {
        // TO DO: implement unit test
        
      Plan__c plan = new Plan__c();
      plan.Name = 'Test plan record';
      insert plan;
      
      Account a = new Account();
      a.Name = 'Test account';
      insert a ;
      
      Contact c = new Contact();
      c.LastName = 'Test';
      insert c;
      
      
      WorkbenchPlanView.addItemToPlan(c.id,'Test','Contact',plan.id);
    }
}