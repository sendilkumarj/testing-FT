@isTest(seealldata=true)
public class testDecisionClass{
    public static testMethod void viewSocialPeopleTabWithSearch(){
         
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
        User u = new User(FirstName = 'Test',LastName = 'User',Email = 'testuser@test123456789.com',CompanyName = 'test.com',Title = 'Test User',Username = 'testuser15@test123456789.com',Alias = 'testuser',CommunityNickname = 'Test User',TimeZoneSidKey = 'America/Mexico_City',LocaleSidKey = 'en_US',EmailEncodingKey = 'ISO-8859-1',ProfileId = pf.Id,LanguageLocaleKey = 'en_US');
        insert u;
          
        System.runAs(u){
            Group g = new Group();
            g.name = 'NewGroup';
            insert g;
            
            GroupMember gm = new  GroupMember();
            gm.groupId = g.Id;
            gm.UserOrGroupId = u.Id;
            insert gm;
            test.starttest();
            Decision__c decision = new Decision__c();
            Decision.title__c = 'Test decision';
            Decision.Problem_Idea_Advice__c = 'Problem';
            Decision.Decision_Taken__c = 'Decision';
            Decision.Priority__c = 'Normal';
            Decision.Status__c ='Propose';
            insert Decision;
            Social_Input__c socialInput = [Select s.Veto_Rights__c, s.User__c, s.SystemModstamp, s.SYS_Tab_View_Activites__c, s.SYS_Tab_View_History__c, s.SYS_Tab_View_Tasks__c, s.SYS_Tab_View_Social_Input__c, s.SYS_Tab_View_Relations__c, s.SYS_Tab_View_Quality__c, s.SYS_Tab_View_Attachments__c, s.SYS_Tab_View_Approvals__c, s.Role_Acceptance_Status__c, s.Role_Acceptance_Required__c, s.Result__c, s.Responsible__c, s.Rating__c, s.Outcome__c, s.Name, s.Mood__c, s.Like__c, s.LastModifiedDate, s.LastModifiedById, s.Informed__c, s.Id, s.Final_Approval_Status__c, s.Effort__c, s.Dislike__c, s.Decision__c, s.CreatedDate, s.CreatedById, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c From Social_Input__c s where s.Decision__c =: Decision.Id];
        	socialInput.User__c =U.id;
            update socialInput;
            Social_Input__c socialInput1 = [Select User__r.Name From Social_Input__c s where s.Decision__c =: Decision.Id];
        	ApexPages.currentPage().getParameters().put('id',decision.Id);
            ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(decision);
            DecisionView dv = new DecisionView(sc);
            System.assertEquals(String.valueof(socialInput.User__c),u.id);
            Topic t = new Topic();
            t.Name = 'Testing Topic';
            insert t;
            Apexpages.currentPage().getParameters().put('TopicMultiSelect',t.Id+','+t.Id);
            dv.decisionRTFUpdate();
            test.stopTest();
        }
    }
    // created on 27_02_2014 
    public static testMethod void testStrategyMap1(){
         Profile pf = [Select Id from Profile where Name = 'System Administrator'];
         User u = new User(FirstName = 'Test',LastName = 'User',Email = 'testuser@test123456789.com',CompanyName = 'test.com',Title = 'Test User',Username = 'testuser15@test123456789.com',Alias = 'testuser',CommunityNickname = 'Test User',TimeZoneSidKey = 'America/Mexico_City',LocaleSidKey = 'en_US',EmailEncodingKey = 'ISO-8859-1',ProfileId = pf.Id,LanguageLocaleKey = 'en_US');
         insert u;
          
         System.runAs(u){
             test.startTest();
             Decision__c decObj = new Decision__c();
             decObj.Name = 'Decisions';
             decObj.Title__c = 'testTitle';
             decObj.Problem_Idea_Advice__c = 'testProblem';
             decObj.phase__c = 'Proposed';
             insert decObj;
             
             Plan__c planObj = new Plan__c();
             planObj.Name = 'Plans';
             insert planObj;
             
             Topic t = new Topic();
            t.Name = 'Testing Topic';
            insert t;
             
             TopicAssignment ta = new TopicAssignment();
             ta.EntityId = decObj.Id;
             ta.TopicId = t.Id;
             insert ta;
             
             TopicAssignment ta1 = new TopicAssignment();
             ta1.EntityId = planObj.Id;
             ta1.TopicId = t.Id;
             insert ta1;
             
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
             
             Event event1 = new Event();
             event1.WhatId = planObj.Id;
             event1.Subject = 'Event on decision ';
             event1.ActivityDate = Date.today().addDays(-2);
             event1.ActivityDateTime = Datetime.now();
             event1.DurationInMinutes = 50;
             insert event1;
             
              
            
           
             
            
             Apexpages.currentPage().getParameters().put('datepickerFrom','Current focused date is Wednesday, February 27, 2013');
             Apexpages.currentPage().getParameters().put('datepickerTo','Current focused date is Wednesday, February 27, 2014');
             Apexpages.currentPage().getParameters().put('roleOfUser','Accountable,Responsible,Consulted,Informed');
             Apexpages.currentPage().getParameters().put('phases','Draft,Share,Propose,Decide,Execute,Evaluate,Close');
             Apexpages.currentPage().getParameters().put('userId','default');
             Apexpages.currentPage().getParameters().put('type','Decision,Plan');
            
             Social_Input__c si = [Select id, User__c from Social_Input__c where Decision__c=:decObj.id ];
             si.User__c = u.id;
             update si;
             StrategyMap sm = new StrategyMap();
             sm.defaultLoad();
             sm.topicStrategyMap();
             test.stopTest();
        
         }
    }
    
    public static testMethod void testDecisionView(){
    	Decision__c decObj = new Decision__c();
         decObj.Name = 'Decisions';
         decObj.Title__c = 'testTitle';
         decObj.Problem_Idea_Advice__c = 'testProblem';
         decObj.phase__c = 'Proposed';
         insert decObj;
         
         Event event1 = new Event();
         event1.WhatId = decObj.Id;
         event1.Subject = 'Event on decision ';
         event1.ActivityDate = Date.today().addDays(-2);
         event1.ActivityDateTime = Datetime.now();
         event1.DurationInMinutes = 50;
         insert event1;
         
         Task task = new Task();
         task.WhatId = decObj.Id;
         task.Subject = 'Task on decision';
         task.ActivityDate = Date.today().addDays(1);
         task.Status = 'Inprogress';
         task.Description = 'Test';
         insert task;
         
         Social_Input__c si = new Social_Input__c();
         si.Decision__c = decObj.Id;
         si.Responsible__c = true;
         si.User__c = userinfo.getUserId();
         insert si;
         
         ApexPages.currentPage().getParameters().put('eventId',event1.Id);
         ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(decObj);
         DecisionView d = new DecisionView(sc);
         d.updatedTask = task;
         d.event = event1;
         d.toBeUpdatedTask();
         d.closeTaskPopup();
         d.toBeUpdatedEvent();
         d.updatedTask();
         d.updatedEvent();
         DecisionView.socialCommand(si.Id,'Rating','1');
         DecisionView.socialCommand(si.Id,'Result','1');
         DecisionView.socialCommand(si.Id,'Effort','1');
         DecisionView.socialCommand(si.Id,'Like','1');
         DecisionView.socialCommand(si.Id,'Dislike','1');
    }
    
    public static testMethod void testDecisionView1(){
    	Decision__c decObj = new Decision__c();
         decObj.Name = 'Decisions';
         decObj.Title__c = 'testTitle';
         decObj.Problem_Idea_Advice__c = 'testProblem';
         decObj.phase__c = 'Proposed';
         insert decObj;
         
         Event event = new Event();
         event.WhatId = decObj.Id;
         event.Subject = 'Event on decision ';
         event.ActivityDate = Date.today().addDays(-2);
         event.ActivityDateTime = Datetime.now();
         event.DurationInMinutes = 50;
         insert event;
         
         Task task = new Task();
         task.WhatId = decObj.Id;
         task.Subject = 'Task on decision';
         task.ActivityDate = Date.today().addDays(1);
         task.Status = 'Inprogress';
         task.Description = 'Test';
         insert task;
         
         Social_Input__c si = new Social_Input__c();
         si.Decision__c = decObj.Id;
         si.Responsible__c = true;
         si.User__c = userinfo.getUserId();
         insert si;
         
         ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(decObj);
         DecisionView d = new DecisionView(sc);
         String modifiedCode = '{"data":{"models":[{"url":"/00TN00000032BIzMAM?retURL=a06N0000000xNl1IAE","subjectClassLink":"","subjectClass":"hide-subject","subject":"Test1","statusImage":"resource/1372409819000/Images/common/icon-notStarted-16x16.png","status":"Not Started","roleAcceptanceStatus":"Approved/Accepted","recordNumber":1,"priority":"Normal","ownerId":"'+userinfo.getuserId()+'","isTaskImage":"resource/1372409819000/Images/common/icon-checked-16x16.png","isTask":"Task","isEditable":true,"isDeletable":true,"id":"'+task.Id+'","editImage":"resource/1372409819000/Images/common/icon-edit-16x16.png","duedate":"2013-08-25T18:30:00.000Z","deleteImage":"resource/1372409819000/Images/common/icon-delete-16x16.png","delayTaskClass":"","createdByName":"Kiran Kumar","createdByImage":"https://c.cs6.content.force.com/profilephoto/005/T","commentsImage":"resource/1372409819000/Images/common/icon-null-16x16.png","comments":null,"actionClassNameEdit":"","actionClassNameDelete":""},{"url":"/00UN0000001ShtpMAC?retURL=a06N0000000xNl1IAE","subjectClassLink":"","subjectClass":"hide-subject","subject":"Test2","statusImage":"resource/1372409819000/Images/common/icon-null-16x16.png","status":"","roleAcceptanceStatus":null,"recordNumber":2,"priority":"","ownerId":"'+userinfo.getuserId()+'","isTaskImage":"resource/1372409819000/Images/common/icon-unchecked-16x16.png","isTask":"Event","isEditable":true,"isDeletable":true,"id":"'+event.Id+'","editImage":"resource/1372409819000/Images/common/icon-edit-16x16.png","duedate":"2013-08-25T18:30:00.000Z","deleteImage":"resource/1372409819000/Images/common/icon-delete-16x16.png","delayTaskClass":null,"createdByName":"Kiran Kumar","createdByImage":"https://c.cs6.content.force.com/profilephoto/005/T","commentsImage":"resource/1372409819000/Images/common/icon-null-16x16.png","comments":"","actionClassNameEdit":"","actionClassNameDelete":""}]}}';
         DecisionView.updateActivitesTab(modifiedCode,'',decObj.Id);
         DecisionView.decisionPhaseChangeDecide(decObj.Id,si.Id,'Propose','','');
         DecisionView.decisionPhaseChangeDecide(decObj.Id,si.Id,'Evaluate','','');
         //DecisionView.decisionPhaseChangeDecide(decObj.Id,si.Id,'Decide','','');
    }
    
    public static testMethod void testDecisionView2(){
    	Decision__c decObj = new Decision__c();
         decObj.Name = 'Decisions';
         decObj.Title__c = 'testTitle';
         decObj.Problem_Idea_Advice__c = 'testProblem';
         decObj.phase__c = 'Proposed';
         insert decObj;
         
         Event event = new Event();
         event.WhatId = decObj.Id;
         event.Subject = 'Event on decision ';
         event.ActivityDate = Date.today().addDays(-2);
         event.ActivityDateTime = Datetime.now();
         event.DurationInMinutes = 50;
         insert event;
         
         Task task = new Task();
         task.WhatId = decObj.Id;
         task.Subject = 'Task on decision';
         task.ActivityDate = Date.today().addDays(1);
         task.Status = 'Inprogress';
         task.Description = 'Test';
         insert task;
         
         Social_Input__c si = new Social_Input__c();
         si.Decision__c = decObj.Id;
         si.Responsible__c = true;
         si.User__c = userinfo.getUserId();
         insert si;
         
         ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(decObj);
         DecisionView d = new DecisionView(sc);
         String modifiedCode = '{"data":{"models":[{"url":"/00TN00000032BIzMAM?retURL=a06N0000000xNl1IAE","subjectClassLink":"","subjectClass":"hide-subject","subject":"Test1","statusImage":"resource/1372409819000/Images/common/icon-notStarted-16x16.png","status":"Not Started","roleAcceptanceStatus":"Approved/Accepted","recordNumber":1,"priority":"Normal","ownerId":"'+userinfo.getuserId()+'","isTaskImage":"resource/1372409819000/Images/common/icon-checked-16x16.png","isTask":"Task","isEditable":true,"isDeletable":true,"id":"'+task.Id+'","editImage":"resource/1372409819000/Images/common/icon-edit-16x16.png","duedate":"2013-08-25T18:30:00.000Z","deleteImage":"resource/1372409819000/Images/common/icon-delete-16x16.png","delayTaskClass":"","createdByName":"Kiran Kumar","createdByImage":"https://c.cs6.content.force.com/profilephoto/005/T","commentsImage":"resource/1372409819000/Images/common/icon-null-16x16.png","comments":null,"actionClassNameEdit":"","actionClassNameDelete":""},{"url":"/00UN0000001ShtpMAC?retURL=a06N0000000xNl1IAE","subjectClassLink":"","subjectClass":"hide-subject","subject":"Test2","statusImage":"resource/1372409819000/Images/common/icon-null-16x16.png","status":"","roleAcceptanceStatus":null,"recordNumber":2,"priority":"","ownerId":"'+userinfo.getuserId()+'","isTaskImage":"resource/1372409819000/Images/common/icon-unchecked-16x16.png","isTask":"Event","isEditable":true,"isDeletable":true,"id":"'+event.Id+'","editImage":"resource/1372409819000/Images/common/icon-edit-16x16.png","duedate":"2013-08-25T18:30:00.000Z","deleteImage":"resource/1372409819000/Images/common/icon-delete-16x16.png","delayTaskClass":null,"createdByName":"Kiran Kumar","createdByImage":"https://c.cs6.content.force.com/profilephoto/005/T","commentsImage":"resource/1372409819000/Images/common/icon-null-16x16.png","comments":"","actionClassNameEdit":"","actionClassNameDelete":""}]}}';
         //DecisionView.updateActivitesTab(modifiedCode,'',decObj.Id);
         //DecisionView.decisionPhaseChangeDecide(decObj.Id,si.Id,'Propose','','');
         //DecisionView.decisionPhaseChangeDecide(decObj.Id,si.Id,'Evaluate','','');
         DecisionView.decisionPhaseChangeDecide(decObj.Id,si.Id,'Decide','','');
         DecisionView.decisionPhaseChangeDecide(decObj.Id,si.Id,'Close','','');
    }
    
    public static testMethod void testDecisionView3(){
    	Decision__c decObj = new Decision__c();
         decObj.Name = 'Decisions';
         decObj.Title__c = 'testTitle';
         decObj.Problem_Idea_Advice__c = 'testProblem';
         decObj.phase__c = 'Proposed';
         insert decObj;
         
         Social_Input__c si = new Social_Input__c();
         si.Decision__c = decObj.Id;
         si.Responsible__c = true;
         si.User__c = userinfo.getUserId();
         insert si;
         
         User u = [select id from User where isActive = true limit 1];
         
         DecisionView.mentionTextPostPropose(u.Id,'test',decObj.Id);
    }
    
    public static testMethod void testDecisionView4(){
    	Decision__c decObj = new Decision__c();
         decObj.Name = 'Decisions';
         decObj.Title__c = 'testTitle';
         decObj.Problem_Idea_Advice__c = 'testProblem';
         decObj.phase__c = 'Proposed';
         insert decObj;
         
         Social_Input__c si = new Social_Input__c();
         si.Decision__c = decObj.Id;
         si.Consulted__c = true;
         si.User__c = userinfo.getUserId();
         insert si;
         
         User u = [select id from User where isActive = true limit 1];
         
         DecisionView.mentionTextPostPropose(u.Id,'test',decObj.Id);
         DecisionView.kendoScatter(decObj.Id);
    }
    
    public static testMethod void testDecisionView5(){
    	Decision__c decObj = new Decision__c();
         decObj.Name = 'Decisions';
         decObj.Title__c = 'testTitle';
         decObj.Problem_Idea_Advice__c = 'testProblem';
         decObj.phase__c = 'Decide';
         insert decObj;
         
         Social_Input__c si = new Social_Input__c();
         si.Decision__c = decObj.Id;
         si.Backup_for_Accountable__c = true;
         si.User__c = userinfo.getUserId();
         insert si;
         
         User u = [select id from User where isActive = true limit 1];
         
         DecisionView.mentionTextPostPropose(u.Id,'test',decObj.Id);
         DecisionView.tabSectionClicked(si.Id,'people-tab');
         DecisionView.tabSectionClicked(si.Id,'task-tab');
         DecisionView.tabSectionClicked(si.Id,'activities-tab');
         DecisionView.tabSectionClicked(si.Id,'relation-tab');
         DecisionView.tabSectionClicked(si.Id,'attachment-tab');
         DecisionView.tabSectionClicked(si.Id,'history-tab');
         DecisionView.tabSectionClicked(si.Id,'quality-tab');
    }
    
    public static testMethod void testDecisionView6(){
    	 Decision__c decObj = new Decision__c();
         decObj.Name = 'Decisions';
         decObj.Title__c = 'testTitle';
         decObj.Problem_Idea_Advice__c = 'testProblem';
         decObj.phase__c = 'Decide';
         insert decObj;
         
         Plan__c p = new Plan__c();
         p.Name = 'test';
         insert p;
         
         Task task = new Task();
         task.WhatId = decObj.Id;
         task.Subject = 'Task on decision';
         task.ActivityDate = Date.today().addDays(1);
         task.Status = 'Inprogress';
         task.Description = 'Test';
         insert task;
         DecisionView.massDeleteTaskRecords(task.Id+','+task.Id,decObj.Id,'');
		 DecisionView.massEditTaskRecords(task.Id+','+task.Id,''+decObj.Id,'',''+UserInfo.getUserId(),'','','');
		 PlanView.massDeleteTaskRecords(task.Id+','+task.Id,p.Id,'');
		 PlanView.massEditTaskRecords(task.Id+','+task.Id,''+p.Id,'',''+UserInfo.getUserId(),'','','');
		 String modifiedCode = '{"data":{"models":[{"url":"/00TN00000032BIzMAM?retURL=a06N0000000xNl1IAE","subjectClassLink":"","subjectClass":"hide-subject","subject":"Test1","statusImage":"resource/1372409819000/Images/common/icon-notStarted-16x16.png","status":"Not Started","roleAcceptanceStatus":"Approved/Accepted","recordNumber":1,"priority":"Normal","ownerId":"'+userinfo.getuserId()+'","whatId":"'+p.Id+'","isTaskImage":"resource/1372409819000/Images/common/icon-checked-16x16.png","isTask":"Task","isEditable":true,"isDeletable":true,"id":"'+task.Id+'","editImage":"resource/1372409819000/Images/common/icon-edit-16x16.png","duedate":"2013-08-25T18:30:00.000Z","deleteImage":"resource/1372409819000/Images/common/icon-delete-16x16.png","delayTaskClass":"","createdByName":"Kiran Kumar","createdByImage":"https://c.cs6.content.force.com/profilephoto/005/T","commentsImage":"resource/1372409819000/Images/common/icon-null-16x16.png","comments":null,"actionClassNameEdit":"","actionClassNameDelete":""},{"url":"/00UN0000001ShtpMAC?retURL=a06N0000000xNl1IAE","subjectClassLink":"","subjectClass":"hide-subject","subject":"Test2","statusImage":"resource/1372409819000/Images/common/icon-null-16x16.png","status":"","roleAcceptanceStatus":null,"recordNumber":2,"priority":"","ownerId":"'+userinfo.getuserId()+'","whatId":"'+p.Id+'","isTaskImage":"resource/1372409819000/Images/common/icon-unchecked-16x16.png","isTask":"Event","isEditable":true,"isDeletable":true,"id":"'+event.Id+'","editImage":"resource/1372409819000/Images/common/icon-edit-16x16.png","duedate":"2013-08-25T18:30:00.000Z","deleteImage":"resource/1372409819000/Images/common/icon-delete-16x16.png","delayTaskClass":null,"createdByName":"Kiran Kumar","createdByImage":"https://c.cs6.content.force.com/profilephoto/005/T","commentsImage":"resource/1372409819000/Images/common/icon-null-16x16.png","comments":"","actionClassNameEdit":"","actionClassNameDelete":""}]}}';
		 //PlanView.updateActivitesTab(modifiedCode,'',p.Id);
		 PlanView.calTotalMins(p.Id);
		 User u = [select id from User where isActive = true limit 1];
         System.runAs(u){
            Group g = new Group();
            g.name = 'NewGroup';
            insert g;
            
            GroupMember gm = new  GroupMember();
            gm.groupId = g.Id;
            gm.UserOrGroupId = u.Id;
            insert gm;
         	
         	DecisionView.retrieveGroupMember(g.Id);
         	DecisionView.getPlanListItem('');
         	DecisionView.addSelectedPlan(p.Id+','+p.Id,decObj.Id,'');
         }
    }
    
    public static testMethod void testSF1_DecisionPhaseChange(){
    	Decision__c decObj = new Decision__c();
         decObj.Name = 'Decisions';
         decObj.Title__c = 'testTitle';
         decObj.Problem_Idea_Advice__c = 'testProblem';
         decObj.phase__c = 'Decide';
         insert decObj;
         
         Relations__c relation = new Relations__c();
          relation.Child_Id__c = decObj.Id;
          relation.Child_Record_Name__c = decObj.Name;
          relation.Child_Object_Name__c = 'Decision';
          relation.Parent_Id__c = decObj.Id;
          relation.Parent_Record_Name__c = decObj.Name;
          relation.Parent_Object_Name__c = 'Plan';
          relation.Position__c = 1;
          relation.Type__c = 'Relation';
          insert relation;
         
         
         PlanView.DeleteItem('',relation.Id);
         
         ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(decObj);
         SF1_DecisionPhaseChange dpc = new SF1_DecisionPhaseChange(sc);
         SF1_DecisionPhaseChange.DecisionPhaseAdvance(decObj.Id,'Decide','','');
         //SF1_DecisionPhaseChange.approvedReject(decObj.Id,'Reject','');
         //SF1_DecisionPhaseChange.approveorReject(si.Id,'',decObj.Id,'Approve');
    }
    
    public static testMethod void testSF1_DecisionPhaseChange1(){
    	Decision__c decObj = new Decision__c();
         decObj.Name = 'Decisions';
         decObj.Title__c = 'testTitle';
         decObj.Problem_Idea_Advice__c = 'testProblem';
         decObj.phase__c = 'Decide';
         insert decObj;
    	
    	Social_Input__c si = new Social_Input__c();
	      si.Decision__c = decObj.Id;
	      si.Responsible__c = true;
	      si.User__c = UserInfo.getUserId();
	      insert si;
         ApexPages.Standardcontroller sc1 = new ApexPages.Standardcontroller(si);
         SF1_Decision_Approval da = new SF1_Decision_Approval(sc1);
    }
    
    public static testMethod void testPlanView(){
    	Plan__c p = new Plan__c();
         p.Name = 'test';
         insert p;
         
         ApexPages.currentPage().getParameters().put('id',p.Id);
         ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(p);
         PlanView pv = new PlanView(sc);
         pv.plan = p;
         pv.savePlan();
         pv.dummyCall();
    }
    
    public static testMethod void testPlanView1(){
    	Plan__c p = new Plan__c();
         p.Name = 'test';
         insert p;
         
         ApexPages.currentPage().getParameters().put('id',p.Id);
         ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(p);
         PlanView pv = new PlanView(sc);
         Apexpages.currentPage().getParameters().put('items','true');
         Apexpages.currentPage().getParameters().put('items','true');
        Apexpages.currentPage().getParameters().put('items','true');
        Apexpages.currentPage().getParameters().put('items','true');
         pv.planClone();
    }
    
    public static testMethod void testPlanView2(){
    	Plan__c p = new Plan__c();
         p.Name = 'test';
         insert p;
         
         ApexPages.currentPage().getParameters().put('id',p.Id);
         ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(p);
         PlanView pv = new PlanView(sc);
        Apexpages.currentPage().getParameters().put('items','true');
        Apexpages.currentPage().getParameters().put('items','true');
        Apexpages.currentPage().getParameters().put('items','true');
        Apexpages.currentPage().getParameters().put('items','true');
        Apexpages.currentPage().getParameters().put('items','true');
         pv.planClone();
    }
    
    public static testMethod void testissues(){
    	
    	Decision__c decision = new Decision__c();
        decision.Title__c = 'Decision test class';
        decision.Decision_Taken__c = 'Test decision';
        decision.Problem_Idea_Advice__c = 'decision problem stateent ';
        decision.Due_Date__c = Datetime.now();
        decision.Phase__c = 'Draft';
        decision.Priority__c = 'High';
        decision.Private__c = true;
        decision.Plain_Tag__c = '#ft, #fingerTip';
        insert decision;
    	
    
    }
    
    static testMethod void AddRelations() {
        // TO DO: implement unit test
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
        
        User u = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' and isActive = true limit 1];
        
        /*User u1 = new User();
        u1.FirstName = 'Tested';
        u1.LastName = 'User';
        u1.Email = 'testuser123@test123456789.com';
        u1.CompanyName = 'test.com';
        u1.Title = 'Test User';
        u1.Username = 'testuser20@test123456789.com';
        u1.Alias = 'testuser';
        u1.CommunityNickname = 'Test User1';
        u1.TimeZoneSidKey = 'America/Mexico_City';
        u1.LocaleSidKey = 'en_US';
        u1.EmailEncodingKey = 'ISO-8859-1';
        u1.ProfileId = pf.Id;
        u1.LanguageLocaleKey = 'en_US';
        
        insert u1;
        
        User u11 = new User();
        u11.FirstName = 'Testing';
        u11.LastName = 'User';
        u11.Email = 'testuser1234@test123456789.com';
        u11.CompanyName = 'test.com';
        u11.Title = 'Test User';
        u11.Username = 'testuser21@test123456789.com';
        u11.Alias = 'testuser';
        u11.CommunityNickname = 'Test User2';
        u11.TimeZoneSidKey = 'America/Mexico_City';
        u11.LocaleSidKey = 'en_US';
        u11.EmailEncodingKey = 'ISO-8859-1';
        u11.ProfileId = pf.Id;
        u11.LanguageLocaleKey = 'en_US';
        
        insert u11;*/
        
        System.runAs(u){
          
          Plan__c plan =  new Plan__c();
          plan.name = 'Test record for add edit people';
          insert plan;
          
          Decision__c decision = new Decision__c();
          Decision.title__c = 'Test decision';
          Decision.Problem_Idea_Advice__c = 'Problem';
          Decision.Decision_Taken__c = 'Decision';
          Decision.Priority__c = 'Normal';
          insert Decision;
          
          Plan__c plan1 =  new Plan__c();
          plan1.name = 'Test record for add edit people';
          insert plan1;
          
          Decision__c decision1 = new Decision__c();
          Decision1.title__c = 'Test decision';
          Decision1.Problem_Idea_Advice__c = 'Problem';
          Decision1.Decision_Taken__c = 'Decision';
          Decision1.Priority__c = 'Normal';
          insert Decision1;
          
          Task task = new Task();
          task.WhatId = plan.Id;
          task.Subject = 'Test Task on decision';
          task.ActivityDate = Date.today();
          task.Status = 'Inprogress';
          insert task; 
          
         
          
          Account a = new Account();
          a.Name = 'test';
          insert a;
          
          Contact c = new Contact();
          c.Lastname = 'Test';
          insert c;
          
          Contract contractRec = new Contract(Accountid=a.id, Status='Draft'); 
          insert contractRec;
          
          Relations__c rel1 = new Relations__c();
          rel1.Child_Id__c = Decision.Id;
          rel1.Child_Record_Name__c = Decision.Title__c;
          rel1.Child_Object_Name__c = 'Decision';
          rel1.Parent_Id__c = Plan.Id;
          rel1.Parent_Record_Name__c = Plan.name;
          rel1.Parent_Object_Name__c = 'Plan';
          insert rel1;
          
          Relations__c rel11 = new Relations__c();
          rel11.Parent_Id__c = Decision.Id;
          rel11.Parent_Record_Name__c = Decision.Title__c;
          rel11.Parent_Object_Name__c = 'Decision';
          rel11.Child_Id__c = Plan.Id;
          rel11.Child_Record_Name__c = Plan.name;
          rel11.Child_Object_Name__c = 'Plan';
          insert rel11;
          
          solution sol = new Solution(SolutionName='Test Solution');
          insert sol;
          
          Case caseRec = new Case(Status='New'); 
         insert caseRec;
          
          Community testCommunityRecord = [Select Name,id from Community limit 1];
         
         idea ideaRec = new idea(Title='test', CommunityId=testCommunityRecord.id); 
         insert ideaRec;
          
          ApexPages.currentPage().getParameters().put('recType','plan__c');
          ApexPages.currentPage().getParameters().put('Id',plan.id);//relType
          ApexPages.currentPage().getParameters().put('relType','Relation');
          
          AddRelations add = new AddRelations();
          ApexPages.currentPage().getParameters().put('chooseObject','Decision__c');//chooseObject searchText
          ApexPages.currentPage().getParameters().put('searchText','Test*');
          add.searchItems();
          ApexPages.currentPage().getParameters().put('chooseObject','User');
          add.searchItems();
          ApexPages.currentPage().getParameters().put('chooseObject','Plan__c');
          add.searchItems();
          ApexPages.currentPage().getParameters().put('chooseObject','Task');
          add.searchItems();
          ApexPages.currentPage().getParameters().put('chooseObject','Account');
          add.searchItems();
          ApexPages.currentPage().getParameters().put('chooseObject','Idea');
          add.searchItems();
          ApexPages.currentPage().getParameters().put('chooseObject','Solution');
          add.searchItems();
          ApexPages.currentPage().getParameters().put('chooseObject','Case');
          add.searchItems();
          ApexPages.currentPage().getParameters().put('chooseObject','Contract');
          add.searchItems();
          ApexPages.currentPage().getParameters().put('recType','Decision__c');
          ApexPages.currentPage().getParameters().put('Id',Decision.id);//relType
          ApexPages.currentPage().getParameters().put('relType','Relation');
          ApexPages.currentPage().getParameters().put('searchText','Test*');
          AddRelations adds = new AddRelations();
          
          ApexPages.currentPage().getParameters().put('chooseObject','Contact');
          adds.searchItems();
          adds.srchRelationship[0].select__c = true;
          adds.addFromSrch();
          adds.addAndClose();
          adds.cancel();
          adds.save_and_close();
        }
    }
    
    static testMethod void testQCD() {
    	Account a = new Account();
        a.Name = 'test';
        insert a;
        
        solution sol = new Solution(SolutionName='Test Solution');
         insert sol;
         
         Case caseRec = new Case(Status='New'); 
         insert caseRec;
         
         Contract contractRec = new Contract(Accountid=a.id, Status='Draft'); 
         insert contractRec;
            
         Community testCommunityRecord = [Select Name,id from Community limit 1];
         
         idea ideaRec = new idea(Title='test', CommunityId=testCommunityRecord.id); 
         insert ideaRec;
         
         Decision__c decision3 = new Decision__c();
        decision3.title__c = 'Test';
        decision3.Problem_Idea_Advice__c = 'Problem';
        decision3.Decision_Taken__c = 'Decision';
        decision3.Priority__c = 'Normal';
        decision3.Phase__c = 'Evaluate';
        insert decision3;
         
         ApexPages.currentPage().getParameters().put('addAsRealtion','true');
         ApexPages.currentPage().getParameters().put('objType','Account');
         ApexPages.StandardController sc = new ApexPages.StandardController(decision3);
         DecisionQuickCreate qcd = new DecisionQuickCreate(sc);
         try{	
        	qcd.saveDecision();
         } catch (exception e){
        	
         }
         ApexPages.currentPage().getParameters().put('objType','Solution');
         try{	
        	qcd.saveDecision();
         } catch (exception e){
        	
         }
         ApexPages.currentPage().getParameters().put('objType','Case');
         try{	
        	qcd.saveDecision();
         } catch (exception e){
        	
         }
         ApexPages.currentPage().getParameters().put('objType','Contract');
         try{	
        	qcd.saveDecision();
         } catch (exception e){
        	
         }
    }
    
    static testMethod void testKanbanBoard() {
    	
    	Task task = new Task();
        task.Subject = 'Task on decision';
        task.ActivityDate = Date.today();
        task.Status = 'In progress';
        insert task; 
    	
    	KanbanBoardAndCards k = new KanbanBoardAndCards();
    	Apexpages.currentPage().getParameters().put('assignedId','AssignedTo');
    	Apexpages.currentPage().getParameters().put('dateField','DUE_DATE');
    	Apexpages.currentPage().getParameters().put('dueDateSelected','Overdue');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','today');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','tomorrow');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','next7');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','next30');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','next60');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','next90');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','next120');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','yesterday');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','last7');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','last30');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','last60');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','last90');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','last120');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','lastnext7');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','custom');
    	try { k.searchFilter(); } catch (exception e){}
    	
    	k.dummyCall();
    }
    
    static testMethod void testKanbanBoard1() {
    	
    	Task task = new Task();
        task.Subject = 'Task on decision';
        task.ActivityDate = Date.today();
        task.Status = 'In progress';
        insert task; 
    	
    	KanbanBoardAndCards k = new KanbanBoardAndCards();
    	Apexpages.currentPage().getParameters().put('assignedId','AssignedTo');
    	Apexpages.currentPage().getParameters().put('dateField','CREATED_DATE');
    	Apexpages.currentPage().getParameters().put('dueDateSelected','Overdue');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','today');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','tomorrow');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','next7');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','next30');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','next60');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','next90');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','next120');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','yesterday');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','last7');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','last30');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','last60');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','last90');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','last120');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','lastnext7');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','custom');
    	try { k.searchFilter(); } catch (exception e){}
    	
    }
    
    static testMethod void testKanbanBoard2() {
    	
    	Task task = new Task();
        task.Subject = 'Task on decision';
        task.ActivityDate = Date.today();
        task.Status = 'In progress';
        insert task; 
    	
    	KanbanBoardAndCards k = new KanbanBoardAndCards();
    	Apexpages.currentPage().getParameters().put('assignedId','AssignedTo');
    	Apexpages.currentPage().getParameters().put('dateField','LAST_UPDATE');
    	Apexpages.currentPage().getParameters().put('dueDateSelected','Overdue');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','today');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','tomorrow');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','next7');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','next30');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','next60');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','next90');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','next120');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','yesterday');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','last7');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','last30');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','last60');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','last90');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','last120');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','lastnext7');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','custom');
    	try { k.searchFilter(); } catch (exception e){}
    	
    }
    
    static testMethod void testKanbanBoard3() {
    	
    	Task task = new Task();
        task.Subject = 'Task on decision';
        task.ActivityDate = Date.today();
        task.Status = 'In progress';
        insert task; 
    	
    	KanbanBoardAndCards k = new KanbanBoardAndCards();
    	Apexpages.currentPage().getParameters().put('assignedId','AssignedTo');
    	Apexpages.currentPage().getParameters().put('dateField','Not_DUE_DATE');
    	Apexpages.currentPage().getParameters().put('dueDateSelected','Overdue');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','today');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','tomorrow');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','next7');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','next30');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','next60');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','next90');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','next120');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','yesterday');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','last7');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','last30');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','last60');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','last90');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','last120');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','lastnext7');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','custom');
    	try { k.searchFilter(); } catch (exception e){}
    	
    }
    static testMethod void testKanbanBoard4() {
    	
    	Task task = new Task();
        task.Subject = 'Task on decision';
        task.ActivityDate = Date.today();
        task.Status = 'In progress';
        insert task; 
    	
    	KanbanBoardAndCards k = new KanbanBoardAndCards();
    	Apexpages.currentPage().getParameters().put('assignedId','AssignedTo');
    	Apexpages.currentPage().getParameters().put('dateField','Not_CREATED_DATE');
    	Apexpages.currentPage().getParameters().put('dueDateSelected','Overdue');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','today');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','tomorrow');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','next7');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','next30');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','next60');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','next90');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','next120');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','yesterday');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','last7');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','last30');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','last60');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','last90');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','last120');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','lastnext7');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','custom');
    	try { k.searchFilter(); } catch (exception e){}
    	
    }
    static testMethod void testKanbanBoard5() {
    	
    	Task task = new Task();
        task.Subject = 'Task on decision';
        task.ActivityDate = Date.today();
        task.Status = 'In progress';
        insert task; 
    	
    	KanbanBoardAndCards k = new KanbanBoardAndCards();
    	Apexpages.currentPage().getParameters().put('assignedId','AssignedTo');
    	Apexpages.currentPage().getParameters().put('dateField','Not_LAST_UPDATE');
    	Apexpages.currentPage().getParameters().put('dueDateSelected','Overdue');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','today');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','tomorrow');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','next7');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','next30');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','next60');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','next90');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','next120');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','yesterday');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','last7');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','last30');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','last60');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','last90');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','last120');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','lastnext7');
    	k.searchFilter();
    	Apexpages.currentPage().getParameters().put('dueDateSelected','custom');
    	try { k.searchFilter(); } catch (exception e){}
    	
    }
}