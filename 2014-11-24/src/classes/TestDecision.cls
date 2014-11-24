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
private class TestDecision {

    static testMethod void DecisionNew() {
        
            Decision__c decision = new Decision__c();
            decision.Title__c = 'Decision test class';
            decision.Decision_Taken__c = 'Test decision';
            decision.Problem_Idea_Advice__c = 'decision problem stateent ';
            decision.Due_Date__c = Datetime.now();
            decision.Phase__c = 'Draft';
            decision.Priority__c = 'High';
            decision.Private__c = true;
            
            
            Decision__c decisionParent = new Decision__c();
            decisionParent.Title__c = 'Decision test class';
            decisionParent.Decision_Taken__c = 'Test decision';
            decisionParent.Problem_Idea_Advice__c = 'decision problem stateent ';
            decisionParent.Due_Date__c = Datetime.now();
            decisionParent.Phase__c = 'Draft';
            decisionParent.Priority__c = 'High';
            decisionParent.Private__c = true;
            insert decisionParent;
            
            ApexPages.StandardController st = new ApexPages.StandardController(decision);
            ApexPages.currentPage().getParameters().put('ProblemStatementValue','piyush quot; parmar');
            ApexPages.currentPage().getParameters().put('ProblemStatementValue','&lt; piyush &#039 parmar &gt;');
            
            
           // DecisionNew  decisionNew = new DecisionNew(st); 
           // DecisionNew.decision = decision;
            //decisionNew.saveDecision();
            DecisionNew  decisionParentNew1 = new DecisionNew(st); 
            decisionParentNew1.customCancel();
            
            ApexPages.currentPage().getParameters().put('parentId',String.valueOf(decisionParent.Id));
            
            DecisionNew  decisionParentNew = new DecisionNew(st); 
            decisionParentNew.decision = decision;
            decisionParentNew.saveDecision();           
            decisionParentNew.customCancel();
            
            AddEditPeopleOnPlan app = new AddEditPeopleOnPlan();
            app.searchUsers();
            app.addingUserBasedOnType();
            app.deletePeople();
            app.cancel();
            app.savePeople();
            app.saveCurrentPeople();
            List<Id> lstIds = new List<Id>();
            List<String> lstString = new List<String>();
            app.listToStringConvert(lstString);
            AddEditPeopleOnPlan.retrieveGroupMember('Testing');
            AddEditPeopleOnPlan.userWrapperClass uw = new AddEditPeopleOnPlan.userWrapperClass();
            AddEditPeopleOnPlan.SocialInputWrapper uw1 = new AddEditPeopleOnPlan.SocialInputWrapper();
            AddEditPeopleOnPlan.UserGroupMemberList uw2 = new AddEditPeopleOnPlan.UserGroupMemberList();
            app.addedUser(lstIds,'','','','');
    }
    
    static testMethod void  QuickCreateDecision() {
   
        //Mandatory  Feilds
       
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
 
        User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = 'testuser@test123456789.com';
        u.CompanyName = 'test.com';
        u.Title = 'Test User';
        u.Username = 'testuser543@test123456789.com';
        u.Alias = 'testuser';
        u.CommunityNickname = 'Test User';
        u.TimeZoneSidKey = 'America/Mexico_City';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = pf.Id;
        u.LanguageLocaleKey = 'en_US';
        insert u;
        
        Plan__c p = new Plan__c();
        p.Name = 'Test Plan';
        insert p;
        
        /*Social_Input__c si = new Social_Input__c();
        si.Plan__c = p.Id;
        si.Responsible__c = true;
        si.User__c = u.Id;
        insert si;*/
        
        Group grp = new Group();
        grp.Name = 'Test Group';
        insert grp;
        
        
        system.runAs(u){
            
            GroupMember gm = new  GroupMember();
            gm.groupId = grp.Id;
            gm.UserOrGroupId = u.Id;
            insert gm;
            
            Decision__c  decision =new Decision__c();
            decision.Title__c = 'Decision test class';
            decision.Decision_Taken__c = 'Test decision';
            decision.Problem_Idea_Advice__c = 'decision problem stateent ';
            decision.Due_Date__c = Datetime.now();
            decision.Phase__c = 'Draft';
            decision.Priority__c = 'High';
            decision.SYS_From_Quick_Decision__c = true;
            
            ApexPages.currentPage().getParameters().put('fromPlanId',p.Id);
            Apexpages.currentPage().getParameters().put('Accoutable',u.Id+','+u.Id);
            Apexpages.currentPage().getParameters().put('Informed',u.Id+','+u.Id);
            Apexpages.currentPage().getParameters().put('Responsible',u.Id+','+u.Id);
            Apexpages.currentPage().getParameters().put('Consulted',u.Id+','+u.Id);
           
            
            
            
            
            ApexPages.StandardController sc = new ApexPages.StandardController(decision);
            DecisionQuickCreate qc= new DecisionQuickCreate(sc);
            
            /*List<Social_Input__c> lstSocialInput = new List<Social_Input__c>();
            lstSocialInput.add(si);*/
            
            
           
            qc.decision = decision;
            
            qc.setState(u.Id);
            qc.saveUserIdAcc();
            qc.saveUserIdRes();
            
            qc.setState(u.Id);
            qc.saveUserIdRes();
            qc.setState(u.Id);
            qc.saveUserIdRes();
            
            
            qc.setState(u.Id);
            qc.saveUserIdCon();
            
            qc.setState(u.Id);
            qc.saveUserIdCon();
            qc.setState(u.Id);
            
            qc.setState(u.Id);
            qc.saveUserIdInfo();
            qc.setState(u.Id);
            qc.saveUserIdInfo();
            try{	
            	qc.saveDecision();
            } catch (exception e){
            	
            }
             Apexpages.currentPage().getParameters().put('addAsRealtion', 'true'); 
            Apexpages.currentPage().getParameters().put('objectChosen', 'Decision__c');
            Apexpages.currentPage().getParameters().put('recId', qc.decision.id );
            
            qc.setState(u.Id);
            qc.saveUserIdInfo();
            
            qc.setState(u.Id);
            qc.saveUserIdInfo();
            qc.setState(u.Id);
            qc.saveUserIdInfo();
            
            
            qc.saveUserIdRes();
            qc.saveUserIdAcc();
            qc.saveUserIdCon();
            qc.saveUserIdInfo();
            
            
            qc.delUserIdRes();
            qc.delUserIdAcc();
            qc.delUserIdCon();
            qc.delUserIdInfo();
            qc.cancelDecision();
            qc.getState();
            //qc.saveUserIdListRes();
            //qc.socialInputData(u.Id,lstSocialInput,'Responsible');
            qc.setStateList(p.Id+','+p.Id);
            List<String> str = qc.getStateList();
            DecisionQuickCreate.addGroupMember(grp.Id);
            
        }     
    }
    
    static testMethod void decisionpdf() {
        // TO DO: implement unit test
            
            Decision__c decision = new Decision__c();
            decision.Title__c = 'Decision test class';
            decision.Decision_Taken__c = 'Test decision';
            decision.Problem_Idea_Advice__c = 'decision problem stateent ';
            decision.Due_Date__c = Datetime.now();
            decision.Phase__c = 'Draft';
            decision.Priority__c = 'High';
            decision.Private__c = true;
            insert decision;
            

            Attachment att = new Attachment();
            String attchmentBody = 'test class coverage';
            att.Body = Blob.valueOf(attchmentBody);
            att.Name = 'Attached data on decision ';
            att.parentId = decision.Id;
            insert att;
            
            Note note = new Note();
            note.Title = 'decision note';
            note.Body = 'Test class ';
            note.ParentId = decision.Id;
            insert note;

            
            Task task = new Task();
            task.WhatId = decision.Id;
            task.Subject = 'Task on decision';
            task.ActivityDate = Date.today();
            task.Status = 'In progress';
            insert task; 
            
            Task taskCompleted = new Task();
            taskCompleted.WhatId = decision.Id;
            taskCompleted.Subject = 'Completed Task on decision';
            taskCompleted.ActivityDate = Date.today();
            taskCompleted.Status = 'Completed';
            insert taskCompleted;           
            
            
            Event event = new Event();
            event.WhatId = decision.Id;
            event.Subject = 'Event on decision ';
            event.ActivityDate = Date.today().addDays(-2);
            event.ActivityDateTime = Datetime.now();
            event.DurationInMinutes = 50;
            insert event;
            
            
            ApexPages.currentPage().getParameters().put('ID',decision.Id);
            ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(decision);
            
            DecisionPDFGenerate decisionPdf = new DecisionPDFGenerate(sc);
            
    }
    
    static testMethod void testTaskCoverage() {
    	
    	Decision__c decision = new Decision__c();
        decision.Title__c = 'Decision test class';
        decision.Decision_Taken__c = 'Test decision';
        decision.Problem_Idea_Advice__c = 'decision problem stateent ';
        decision.Due_Date__c = Datetime.now();
        decision.Phase__c = 'Draft';
        decision.Priority__c = 'High';
        decision.Private__c = true;
        insert decision;
    	
    	Task taskCompleted = new Task();
        taskCompleted.WhatId = decision.Id;
        taskCompleted.Subject = 'Completed Task on decision';
        taskCompleted.ActivityDate = Date.today();
        taskCompleted.Status = 'Completed';
        insert taskCompleted;
        
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(decision);
        DecisionView dv = new DecisionView(sc);
        dv.newTaskToDecision = taskCompleted;
        dv.decision = decision;
        dv.intialiseDecisionTask();
        dv.createNewTaskForDecision();
    }
    
    static testMethod void testContribution(){
    	
    	Decision__c decision = new Decision__c();
        decision.Title__c = 'Decision test class';
        decision.Decision_Taken__c = 'Test decision';
        decision.Problem_Idea_Advice__c = 'decision problem stateent ';
        decision.Due_Date__c = Datetime.now();
        decision.Phase__c = 'Draft';
        decision.Priority__c = 'High';
        decision.Private__c = true;
        insert decision;
        
        Social_Input__c si = new Social_Input__c();
        si.Decision__c = decision.Id;
        si.Backup_for_Accountable__c = true;
        si.User__c = userInfo.getUserId();
        insert si;
        
        FeedItem post = new FeedItem();
        post.ParentId = decision.Id;
        post.Body = Userinfo.getName()  + ' closed the task:';
        post.title = 'Test';
        post.LinkUrl = '/'+ decision.id;
        insert post;
        
        DecisionView.contributionTab(decision.Id);
    }
}