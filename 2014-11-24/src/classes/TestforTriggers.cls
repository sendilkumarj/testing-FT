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
@isTest (seeAllData=true)
private class TestforTriggers {

    static testMethod void testTriggers() {
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
        User u = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' and isActive = true limit 1];
        
        
        System.runAs(u){
            Account a = new Account();
            a.name = 'test account';
            insert a;
            
            Contact c = new Contact();
            c.FirstName = 'first';
            c.LastName = 'Test';
            insert c;
            
            
            Plan__c plan = new Plan__c();
            plan.name = 'test plan';
            insert plan;
            
            Task task = new Task();
            task.WhatId = plan.Id;
            task.Subject = 'Task on decision';
            task.ActivityDate = Date.today();
            task.Status = 'Inprogress';
            task.Description = 'Test';
            insert task; 
            
            FeedItem tf = new FeedItem();
            tf.ParentId = task.Id;
            tf.Type = 'CreateRecordEvent';
            insert tf;
            
            Note note = new Note();
            note.Title = 'new note';
            note.parentId = plan.id;
            insert note;
            
            Relations__c relationItem = new Relations__c();
            relationItem.Child_Id__c = a.Id;
            relationItem.Child_Record_Name__c = a.Name;
            relationItem.Child_Object_Name__c = 'Account';
            relationItem.Parent_Id__c = plan.Id;
            relationItem.Parent_Record_Name__c = plan.Name;
            relationItem.Parent_Object_Name__c = 'Plan';
            relationItem.Type__c = 'Item';
            insert relationItem; 
            
            
            Relations__c rel1 = new Relations__c();
            rel1.Child_Id__c = c.Id;
            rel1.Child_Record_Name__c = c.LastName;
            rel1.Child_Object_Name__c = 'Contact';
            rel1.Parent_Id__c = plan.Id;
            rel1.Parent_Record_Name__c = plan.Name;
            rel1.Parent_Object_Name__c = 'Plan';
            rel1.Type__c = 'Item';
            insert rel1; 
            
            Relations__c rel2 = new Relations__c();
            rel2.Child_Id__c = note.Id;
            rel2.Child_Record_Name__c = note.Title;
            rel2.Child_Object_Name__c = 'Note';
            rel2.Parent_Id__c = plan.Id;
            rel2.Parent_Record_Name__c = plan.Name;
            rel2.Parent_Object_Name__c = 'Plan';
            rel2.Type__c = 'Item';
            insert rel2; 
            
            Relations__c rel3 = new Relations__c();
            rel3.Child_Id__c = task.Id;
            rel3.Child_Record_Name__c = task.Subject;
            rel3.Child_Object_Name__c = 'Task';
            rel3.Parent_Id__c = plan.Id;
            rel3.Parent_Record_Name__c = plan.Name;
            rel3.Parent_Object_Name__c = 'Plan';
            rel3.Type__c = 'Item';
            insert rel3; 
            
            task.Status = 'N/A';
            task.Description = 'Test123';
            update task; 
            
            a.Name = 'testing account';
            update a;
            
            c.FirstName = 'hello123';
            c.LastName = 'Testing';
            update c;
            
            note.title = 'changing note title';
            update note;
            
            task.Subject = 'Task on decisions';
            update task;
            
            List<Account> accList = new List<Account>();
            accList.add(a);
            
            delete accList;
            
            List<Contact> conList = new List<Contact>();
            conList.add(c);
            
            delete conList;
            
            
            
            List<Plan__c> planList = new List<Plan__c>();
            planList.add(plan);
            
            delete planList;
        }
    }
    
    static testMethod void testSocialInputTriggerUpDate1() {
    	
    	Profile pf = [Select Id from Profile where Name = 'System Administrator'];
        User u1 = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' and isActive = true limit 1];
         User u = [SELECT Id FROM User WHERE Profile.Name = 'Fingertip User' and isactive =: true limit 1];
        
        
        System.runAs(u1){
    	
	    	 Decision__c decisionTag = new Decision__c();
	         decisionTag.Title__c = 'Decision test class';
	         decisionTag.Decision_Taken__c = 'Test decision';
	         decisionTag.Problem_Idea_Advice__c = 'decision problem stateent ';
	         decisionTag.Due_Date__c = Datetime.now();
	         decisionTag.Phase__c = 'Draft';
	         decisionTag.Priority__c = 'High';
	         decisionTag.Private__c = true;
	         insert decisionTag;
	         
	         decisionTag.Phase__c = 'Share';
	         update decisionTag;
     
      		Social_Input__c s = new Social_Input__c();
            s.Select_People__c = false;
            s.User__c = u.Id;
            s.Accountable__c = false;
            s.Backup_for_Accountable__c = false;
            s.Consulted__c = false;
            s.Informed__c = true;
            s.Responsible__c = false;
            s.Description__c = '';
            s.Veto_Rights__c = false;
            s.Role_Acceptance_Required__c = false;
            s.Role_Acceptance_Status__c = '';
            s.Decision__c = decisionTag.Id;
            
            /*Social_Input__c s1 = new Social_Input__c();
            s1.Select_People__c = false;
            s1.User__c = u1.Id;
            s1.Accountable__c = false;
            s1.Backup_for_Accountable__c = false;
            s1.Consulted__c = false;
            s1.Informed__c = false;
            s1.Responsible__c = true;
            s1.Description__c = '';
            s1.Veto_Rights__c = false;
            s1.Role_Acceptance_Required__c = false;
            s1.Role_Acceptance_Status__c = '';
            s1.Decision__c = decisionTag.Id;*/
            
            List<Social_Input__c> social_Insert = new List<Social_Input__c>();
            social_Insert.add(s);
            //social_Insert.add(s1);
            insert social_Insert;
            
            List<Social_Input__c> social_Update = new List<Social_Input__c>();
            Social_Input__c s11 = new Social_Input__c(id = s.id,Responsible__c=true,Informed__c=false);
            //Social_Input__c s12 = new Social_Input__c(id = s1.id,Responsible__c=false,Informed__c=true);
            social_Update.add(s11);
            //social_Update.add(s12);
            CheckforRecrussion.isRecrussion = false;
            update social_Update;
        }	
    }
    
    static testMethod void futureMethod(){
    	
    	Plan__c plan = new Plan__c();
        plan.name = 'test plan';
        insert plan;
    	
    	Task task = new Task();
        task.WhatId = plan.Id;
        task.Subject = 'Task on decision';
        task.ActivityDate = Date.today();
        task.Status = 'Inprogress';
        task.Description = 'Test';
        insert task; 
        
    	User u = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' and isActive = true limit 1];
    	System.runAs(u){
	    	FeedItem fi = new FeedItem();
	        fi.ParentId = task.Id;
	        fi.Type = 'CreateRecordEvent';
	        insert fi;
	        
	        task.Description = null;
	        update task;
    	}
    	
    	Relations__c searchR = new Relations__c();
    	searchR.Parent_Id__c = u.Id;
        searchR.Parent_Record_Name__c = 'Testing';
        searchR.Parent_Object_Name__c = 'User';
        searchR.To_Relation__c = 'Parent';
    	insert searchR;
    	
    	RelatedList rl = new RelatedList();
    	rl.getobjTypeLabel();
    	rl.getrecordId();
    	rl.setobjTypeLabel('User');
    	rl.setrecordId(u.Id);
    }
    
    // Social_input record SocialAfterBeforeInsert
    static testMethod void SocialInsertUpdate(){
    	test.startTest();
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
       		Decision__c decObj = new Decision__c();
            decObj.Name = 'Decisions';
            decObj.Title__c = 'testTitle';
            decObj.Problem_Idea_Advice__c = 'testProblem';
            decObj.phase__c = 'Draft';
        	//decObj.FeedItem_Id__c = fItem.id;
        	insert decObj;
            decObj.Phase__c='Share';
        	update decObj;
            
        	DecisionView.mentionTextPost(Userinfo.getUserId(),decObj.Problem_Idea_Advice__c, decObj.Id);
			//system.assertEquals(decObj.FeedItem_Id__c,'a');
          
                Social_Input__c si1 =new Social_Input__c();
                si1.Decision__c= decObj.Id;
                si1.Responsible__c = true;
                si1.User__c = Userinfo.getUserId();
                insert si1;
        test.stopTest();
          
    }
}