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
@isTest(SeeAllData=true)
private class TestPlanView {  

    static testMethod void planStandardObject() {
        // TO DO: implement unit test
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
        User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = 'testuser@test123456789.com';
        u.CompanyName = 'test.com';
        u.Title = 'Test User';
        u.Username = 'testuser1@test123456789.com';
        u.Alias = 'testuser';
        u.CommunityNickname = 'Test User';
        u.TimeZoneSidKey = 'America/Mexico_City';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = pf.Id;
        u.LanguageLocaleKey = 'en_US';
        
        insert u;
        
        System.runAs(u){
          
          Plan__c plan = new Plan__c();
          plan.Name = 'Test Plan record';
          insert plan;
          Relations__c relation = new Relations__c();
          relation.Child_Id__c = plan.Id;
          relation.Child_Record_Name__c = plan.Name;
          relation.Child_Object_Name__c = 'Decision';
          relation.Parent_Id__c = plan.Id;
          relation.Parent_Record_Name__c = plan.Name;
          relation.Parent_Object_Name__c = 'Plan';
          relation.Position__c = 1;
          relation.Type__c = 'Relation';
          insert relation;
          
          ApexPages.currentPage().getParameters().put('ID',plan.Id);
          ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(plan);
          
          PlanView PlanV = new PlanView(sc);
          
          Planview.getPlanRelation(plan.Id);
          PlanView.relationMap = new map<Id,Relations__c>();
          PlanView.relationMap.put(relation.Id,relation);
          try{ PlanView.moveDown(Plan.Id,relation.Id);}catch(exception e){}
          PlanView.planItemOrderChange(relation.Id,'0',relation.Id,'0');
          //PlanView.saveItemModifiedData(plan.Id,'2013,01,01,01,01,01');
          //PlanView.DeleteItem(Plan.Id,relationItem1.Id);
        }
    }
    
    static testMethod void planStandardObject1() {
        // TO DO: implement unit test
          
          Plan__c plan = new Plan__c();
          plan.Name = 'Test Plan record';
          insert plan;
          
          Task task = new Task();
          task.WhatId = plan.Id;
          task.Subject = 'Task on decision';
          task.ActivityDate = Date.today();
          task.Status = 'Inprogress';
          insert task;
          
          ApexPages.currentPage().getParameters().put('ID',plan.Id);
          ApexPages.currentPage().getParameters().put('taskId',task.Id);
          ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(plan);
          
          PlanView PlanV = new PlanView(sc);
          
          planV.createNewTaskForPlanAsRelation();
          planV.toBeUpdatedTask();
          planV.updatedTask();
    }
    
    static testMethod void planStandardOperation() {
        // TO DO: implement unit test
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
        User u = new User();
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
        
        insert u;
        
        System.runAs(u){
          
          Plan__c plan = new Plan__c();
          plan.Name = 'Test Plan record';
          insert plan;
          
          Task task = new Task();
          task.WhatId = plan.Id;
          task.Subject = 'Task on decision';
          task.ActivityDate = Date.today();
          task.Status = 'Inprogress';
          insert task; 
          
          Relations__c relationItem12 = new Relations__c();
          relationItem12.Child_Id__c = task.Id;
          relationItem12.Child_Record_Name__c = task.Subject;
          relationItem12.Child_Object_Name__c = 'Task';
          relationItem12.Parent_Id__c = plan.Id;
          relationItem12.Parent_Record_Name__c = plan.Name;
          relationItem12.Parent_Object_Name__c = 'Plan';
          relationItem12.Type__c = 'Item';
          insert relationItem12;
          
          Relations__c relationItem1 = new Relations__c();
          relationItem1.Child_Id__c = task.Id;
          relationItem1.Child_Record_Name__c = task.Subject;
          relationItem1.Child_Object_Name__c = 'Task';
          relationItem1.Parent_Id__c = plan.Id;
          relationItem1.Parent_Record_Name__c = plan.Name;
          relationItem1.Parent_Object_Name__c = 'Plan';
          relationItem1.Type__c = 'Item';
          insert relationItem1;
                    
          ApexPages.currentPage().getParameters().put('ID',plan.Id);
          ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(plan);
          
          PlanView PlanV = new PlanView(sc);
          PlanView.moveUp(Plan.Id,relationItem1.Id);
          //
        }
    }
    
    static testMethod void planStandardTaskEventOperation() {
        // TO DO: implement unit test
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
        User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = 'testuser@test123456789.com';
        u.CompanyName = 'test.com';
        u.Title = 'Test User';
        u.Username = 'testuser3@test123456789.com';
        u.Alias = 'testuser';
        u.CommunityNickname = 'Test User';
        u.TimeZoneSidKey = 'America/Mexico_City';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = pf.Id;
        u.LanguageLocaleKey = 'en_US';
        
        insert u;
        
        System.runAs(u){
          
          Plan__c plan = new Plan__c();
          plan.Name = 'Test Plan record';
          insert plan;
          
          Social_Input__c si = new Social_Input__c();
          si.Plan__c = plan.Id;
          si.Responsible__c = true;
          si.User__c = u.Id;
          insert si;
          
          Attachment att = new Attachment();
          String attchmentBody = 'test class coverage';
          att.Body = Blob.valueOf(attchmentBody);
          att.Name = 'Attached data on decision ';
          att.parentId = Plan.Id;
          insert att;
          
          Note note = new Note();
          note.Title = 'decision note';
          note.Body = 'Test class ';
          note.ParentId = Plan.Id;
          insert note;

        
          Task task = new Task();
          task.WhatId = plan.Id;
          task.Subject = 'Task on decision';
          task.ActivityDate = Date.today();
          task.Status = 'Inprogress';
          insert task; 
          
          Task taskCompleted = new Task();
          taskCompleted.WhatId = plan.Id;
          taskCompleted.Subject = 'Completed Task on decision';
          taskCompleted.ActivityDate = Date.today();
          taskCompleted.Status = 'Completed';
          insert taskCompleted;         
          
          
          Event event = new Event();
          event.WhatId = plan.Id;
          event.Subject = 'Event on decision ';
          event.ActivityDate = Date.today();
          event.ActivityDateTime = Datetime.now();
          event.DurationInMinutes = 50;
          insert event;
          
          Event event1 = new Event();
          event1.WhatId = plan.Id;
          event1.Subject = 'Event on decision ';
          event1.ActivityDate = Date.today().addDays(-2);
          event1.ActivityDateTime = Datetime.now();
          event1.DurationInMinutes = 50;
          insert event1;
                    
          ApexPages.currentPage().getParameters().put('ID',plan.Id);
          ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(plan);
          
          PlanView PlanV = new PlanView(sc);
          PlanView.deleteNotesAttachments(plan.Id,att.Id,'Attachment');
          PlanView.viewTaskEventTab(plan.Id, '');
          PlanView.viewHistory(plan.Id);
          PlanView.getNoteInfo(note.Id);
          
          //PlanView.tabSectionClicked(si.Id,'activities-tab');
          //PlanView.addNoteItems(plan.Id,'hello','how are you');
        }
    }
    
    // Test class to cover the code when activities batch updated.
    static testMethod void planActivitiesUpdate() {
        
        Plan__c plan = new Plan__c();
        plan.Name = 'Test Plan record';
        insert plan;
            
        Task task = new Task();
        task.WhatId = plan.Id;
        task.Subject = 'Task on decision';
        task.ActivityDate = Date.today();
        task.Status = 'Completed';
        insert task; 
        
        Event event = new Event();
        event.WhatId = plan.Id;
        event.Subject = 'Event on decision ';
        event.ActivityDate = Date.today().addDays(-2);
        event.ActivityDateTime = Datetime.now();
        event.DurationInMinutes = 50;
        insert event;
        
        ApexPages.currentPage().getParameters().put('ID',plan.Id);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(plan);
        
        String modifiedCode = '{"data":{"models":[{"url":"/00TN00000032BIzMAM?retURL=a06N0000000xNl1IAE","subjectClassLink":"","subjectClass":"hide-subject","subject":"Test1","statusImage":"resource/1372409819000/Images/common/icon-notStarted-16x16.png","status":"Not Started","roleAcceptanceStatus":"Approved/Accepted","recordNumber":1,"priority":"Normal","ownerId":"'+userinfo.getuserId()+'","isTaskImage":"resource/1372409819000/Images/common/icon-checked-16x16.png","isTask":"Task","isEditable":true,"isDeletable":true,"id":"'+task.Id+'","editImage":"resource/1372409819000/Images/common/icon-edit-16x16.png","duedate":"2013-08-25T18:30:00.000Z","deleteImage":"resource/1372409819000/Images/common/icon-delete-16x16.png","delayTaskClass":"","createdByName":"Kiran Kumar","createdByImage":"https://c.cs6.content.force.com/profilephoto/005/T","commentsImage":"resource/1372409819000/Images/common/icon-null-16x16.png","comments":null,"actionClassNameEdit":"","actionClassNameDelete":""},{"url":"/00UN0000001ShtpMAC?retURL=a06N0000000xNl1IAE","subjectClassLink":"","subjectClass":"hide-subject","subject":"Test2","statusImage":"resource/1372409819000/Images/common/icon-null-16x16.png","status":"","roleAcceptanceStatus":null,"recordNumber":2,"priority":"","ownerId":"'+userinfo.getuserId()+'","isTaskImage":"resource/1372409819000/Images/common/icon-unchecked-16x16.png","isTask":"Event","isEditable":true,"isDeletable":true,"id":"'+event.Id+'","editImage":"resource/1372409819000/Images/common/icon-edit-16x16.png","duedate":"2013-08-25T18:30:00.000Z","deleteImage":"resource/1372409819000/Images/common/icon-delete-16x16.png","delayTaskClass":null,"createdByName":"Kiran Kumar","createdByImage":"https://c.cs6.content.force.com/profilephoto/005/T","commentsImage":"resource/1372409819000/Images/common/icon-null-16x16.png","comments":"","actionClassNameEdit":"","actionClassNameDelete":""}]}}';
        PlanView.updateActivitesTab(modifiedCode,'test*',plan.Id);
        PlanView.viewTaskEventTabWithSearch(plan.Id,task.Id,'test*');
        PlanView.viewTaskEventTabWithSearch(plan.Id,event.Id,'test*');
    }
    
    static testMethod void planDelPeopleOperation() {
        // TO DO: implement unit test
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
        User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = 'testuser@test123456789.com';
        u.CompanyName = 'test.com';
        u.Title = 'Test User';
        u.Username = 'testuser4@test123456789.com';
        u.Alias = 'testuser';
        u.CommunityNickname = 'Test User';
        u.TimeZoneSidKey = 'America/Mexico_City';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = pf.Id;
        u.LanguageLocaleKey = 'en_US';
        
        insert u;
        
        User u1 = new User();
        u1.FirstName = 'Test';
        u1.LastName = 'User';
        u1.Email = 'testuser1@test123456789.com';
        u1.CompanyName = 'test.com';
        u1.Title = 'Test User';
        u1.Username = 'testuser5@test123456789.com';
        u1.Alias = 'testuser';
        u1.CommunityNickname = 'Test User1';
        u1.TimeZoneSidKey = 'America/Mexico_City';
        u1.LocaleSidKey = 'en_US';
        u1.EmailEncodingKey = 'ISO-8859-1';
        u1.ProfileId = pf.Id;
        u1.LanguageLocaleKey = 'en_US';
        
        insert u1;
        
        System.runAs(u){
          
          Plan__c plan = new Plan__c();
          plan.Name = 'Test Plan record';
          insert plan;
          
          Decision__c decision = new Decision__c();
          decision.Title__c = 'Decision test class';
          decision.Decision_Taken__c = 'Test decision';
          decision.Problem_Idea_Advice__c = 'decision problem stateent ';
          decision.Due_Date__c = Datetime.now();
          decision.Phase__c = 'Close';
          decision.Priority__c = 'High';
          decision.Private__c = true;
          insert decision;
          
          Social_Input__c si = new Social_Input__c();
          si.Plan__c = plan.Id;
          si.Responsible__c = true;
          si.User__c = u1.Id;
          insert si;
          
          ApexPages.currentPage().getParameters().put('ID',plan.Id);
          ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(plan);
          
          PlanView PlanV = new PlanView(sc);
          Plan.Name = 'Test Plan Updated';
          update plan;
          planV.savePlan();
          
          //PlanView.addNoteItems(plan.Id,'hello','how are you');
          PlanView.viewPeopleTab(plan.Id,si.ID);
        }
    }
    
    static testMethod void planItemOperation() {
        // TO DO: implement unit test
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
        User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = 'testuser@test123456789.com';
        u.CompanyName = 'test.com';
        u.Title = 'Test User';
        u.Username = 'testuser6@test123456789.com';
        u.Alias = 'testuser';
        u.CommunityNickname = 'Test User';
        u.TimeZoneSidKey = 'America/Mexico_City';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = pf.Id;
        u.LanguageLocaleKey = 'en_US';
        
        insert u;
        
        User u1 = new User();
        u1.FirstName = 'Test';
        u1.LastName = 'User';
        u1.Email = 'testuser1@test123456789.com';
        u1.CompanyName = 'test.com';
        u1.Title = 'Test User';
        u1.Username = 'testuser7@test123456789.com';
        u1.Alias = 'testuser';
        u1.CommunityNickname = 'Test User1';
        u1.TimeZoneSidKey = 'America/Mexico_City';
        u1.LocaleSidKey = 'en_US';
        u1.EmailEncodingKey = 'ISO-8859-1';
        u1.ProfileId = pf.Id;
        u1.LanguageLocaleKey = 'en_US';
        
        insert u1;
        
        System.runAs(u){
          
          Plan__c plan = new Plan__c();
          plan.Name = 'Test Plan record';
          insert plan;
          
          Social_Input__c si = new Social_Input__c();
          si.Plan__c = plan.Id;
          si.Responsible__c = true;
          si.User__c = u1.Id;
          insert si;
          
          Decision__c decision = new Decision__c();
          decision.Title__c = 'test Decision';
          decision.Problem_Idea_Advice__c = 'problem statement';
          decision.Priority__c = 'Normal';
          insert decision;
          
         
          
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
          
          si.Mood__c = 1;
          update si;
          
          ApexPages.currentPage().getParameters().put('ID',plan.Id);
          ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(plan);
          
          PlanView PlanV = new PlanView(sc);
          
          
          
        }
    }
    
    static testMethod void planPlanPDFGenerate() {
        // TO DO: implement unit test
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
        User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = 'testuser@test123456789.com';
        u.CompanyName = 'test.com';
        u.Title = 'Test User';
        u.Username = 'testuser6@test123456789.com';
        u.Alias = 'testuser';
        u.CommunityNickname = 'Test User';
        u.TimeZoneSidKey = 'America/Mexico_City';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = pf.Id;
        u.LanguageLocaleKey = 'en_US';
        
        insert u;
        
        System.runAs(u){
          
          Plan__c plan = new Plan__c();
          plan.Name = 'Test Plan record';
          insert plan;
          
          Social_Input__c si = new Social_Input__c();
          si.Plan__c = plan.Id;
          si.Responsible__c = true;
          si.User__c = u.Id;
          si.Final_Approval_Status__c = 'Approved';
          si.Veto_Rights__c = true;
          insert si;
          
          Decision__c decision = new Decision__c();
          decision.Title__c = 'test Decision';
          decision.Problem_Idea_Advice__c = 'problem statement';
          decision.Priority__c = 'Normal';
          insert decision; 
          
         
          
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
          
          Task taskCompleted = new Task();
          taskCompleted.WhatId = plan.Id;
          taskCompleted.Subject = 'Completed Task on decision';
          taskCompleted.ActivityDate = Date.today().addDays(-1);
          taskCompleted.Status = 'Completed';
          insert taskCompleted;          
          
          Event event1 = new Event();
          event1.WhatId = plan.Id;
          event1.Subject = 'Event on decision ';
          event1.ActivityDate = Date.today().addDays(-2);
          event1.ActivityDateTime = Datetime.now();
          event1.DurationInMinutes = 50;
          insert event1;
          
          Note note = new Note();
          note.Title = 'decision note';
          note.Body = 'Test class ';
          note.ParentId = Plan.Id;
          insert note;
          
          si.Mood__c = 1;
          update si;
          
          ApexPages.currentPage().getParameters().put('ID',plan.Id);
          ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(plan);
          
          set<Id> recordIdList = new set<Id>();
          recordIdList.add(note.Id); 
          
          PlanPDFGenerate planPDF = new PlanPDFGenerate(sc);
          planPDF.itemView(plan.Id);
        }
    }
    
    static testMethod void planPlanPDFGenerate1() {
        // TO DO: implement unit test
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
        User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = 'testuser@test123456789.com';
        u.CompanyName = 'test.com';
        u.Title = 'Test User';
        u.Username = 'testuser6@test123456789.com';
        u.Alias = 'testuser';
        u.CommunityNickname = 'Test User';
        u.TimeZoneSidKey = 'America/Mexico_City';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = pf.Id;
        u.LanguageLocaleKey = 'en_US';
        
        insert u;
        
        System.runAs(u){
          
          Plan__c plan = new Plan__c();
          plan.Name = 'Test Plan record';
          insert plan;
          
          Social_Input__c si = new Social_Input__c();
          si.Plan__c = plan.Id;
          si.Responsible__c = true;
          si.User__c = u.Id;
          si.Final_Approval_Status__c = 'Approved';
          si.Veto_Rights__c = true;
          insert si;
          
          Decision__c decision = new Decision__c();
          decision.Title__c = 'test Decision';
          decision.Problem_Idea_Advice__c = 'problem statement';
          decision.Priority__c = 'Normal';
          insert decision; 
          
        
          
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
          
          Task taskCompleted = new Task();
          taskCompleted.WhatId = plan.Id;
          taskCompleted.Subject = 'Completed Task on decision';
          taskCompleted.ActivityDate = Date.today().addDays(-1);
          taskCompleted.Status = 'Completed';
          insert taskCompleted;          
          
          Event event1 = new Event();
          event1.WhatId = plan.Id;
          event1.Subject = 'Event on decision ';
          event1.ActivityDate = Date.today().addDays(-2);
          event1.ActivityDateTime = Datetime.now();
          event1.DurationInMinutes = 50;
          insert event1;
          
          Note note = new Note();
          note.Title = 'decision note';
          note.Body = 'Test class ';
          note.ParentId = Plan.Id;
          insert note;
          
          ApexPages.currentPage().getParameters().put('ID',plan.Id);
          ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(plan);
          
          set<Id> recordIdList = new set<Id>();
          recordIdList.add(note.Id); 
          
          PlanPDFGenerate planPDF = new PlanPDFGenerate(sc);
          planPDF.defaultMethods();
        }
    }
    
    static testMethod void planPlanPDFGenerate2() {
        // TO DO: implement unit test
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
        User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = 'testuser@test123456789.com';
        u.CompanyName = 'test.com';
        u.Title = 'Test User';
        u.Username = 'testuser6@test123456789.com';
        u.Alias = 'testuser';
        u.CommunityNickname = 'Test User';
        u.TimeZoneSidKey = 'America/Mexico_City';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = pf.Id;
        u.LanguageLocaleKey = 'en_US';
        
        insert u;
        
        System.runAs(u){
          
          Plan__c plan = new Plan__c();
          plan.Name = 'Test Plan record';
          insert plan;
          
          Social_Input__c si = new Social_Input__c();
          si.Plan__c = plan.Id;
          si.Responsible__c = true;
          si.User__c = u.Id;
          si.Final_Approval_Status__c = 'Approved';
          si.Veto_Rights__c = true;
          insert si;
          
          Decision__c decision = new Decision__c();
          decision.Title__c = 'test Decision';
          decision.Problem_Idea_Advice__c = 'problem statement';
          decision.Priority__c = 'Normal';
          insert decision; 
                 
          
          Event event1 = new Event();
          event1.WhatId = plan.Id;
          event1.Subject = 'Event on decision ';
          event1.ActivityDate = Date.today().addDays(-2);
          event1.ActivityDateTime = Datetime.now();
          event1.DurationInMinutes = 50;
          insert event1;
          
          Note note = new Note();
          note.Title = 'decision note';
          note.Body = 'Test class ';
          note.ParentId = Plan.Id;
          insert note;
          
          si.Mood__c = 1;
          update si;
          
          ApexPages.currentPage().getParameters().put('ID',plan.Id);
          ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(plan);
          
          set<Id> recordIdList = new set<Id>();
          recordIdList.add(decision.Id);
          recordIdList.add(note.Id); 
          
          PlanPDFGenerate planPDF = new PlanPDFGenerate(sc);
          planPDF.ownerDetail(recordIdList);
        }
    }
    
    static testMethod void planStandardNoteOperation() {
        // TO DO: implement unit test
          
          Plan__c plan = new Plan__c();
          plan.Name = 'Test Plan record';
          insert plan;
          
          ApexPages.currentPage().getParameters().put('ID',plan.Id);
          ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(plan);
          
          PlanView PlanV = new PlanView(sc);
          
          
          PlanView.addNoteItems(plan.Id,'hello','how are you');
          
    }
    
    static testMethod void planStandardTabClickOperation1() {
        // TO DO: implement unit test
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
        User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = 'testuser@test123456789.com';
        u.CompanyName = 'test.com';
        u.Title = 'Test User';
        u.Username = 'testuser9@test123456789.com';
        u.Alias = 'testuser';
        u.CommunityNickname = 'Test User';
        u.TimeZoneSidKey = 'America/Mexico_City';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = pf.Id;
        u.LanguageLocaleKey = 'en_US';
        
        insert u;
        
        System.runAs(u){
          
          Plan__c plan = new Plan__c();
          plan.Name = 'Test Plan record';
          insert plan;
          
          Social_Input__c si = new Social_Input__c();
          si.Plan__c = plan.Id;
          si.Responsible__c = true;
          si.User__c = u.Id;
          insert si;
          
          ApexPages.currentPage().getParameters().put('ID',plan.Id);
          ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(plan);
          
          PlanView PlanV = new PlanView(sc);
          PlanView.tabSectionClicked(si.Id,'people-tab');
          PlanView.tabSectionClicked(si.Id,'task-tab');
          //
          //
        }
    }
    
    static testMethod void planStandardTabClickOperation2() {
        // TO DO: implement unit test
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
        User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = 'testuser@test123456789.com';
        u.CompanyName = 'test.com';
        u.Title = 'Test User';
        u.Username = 'testuser10@test123456789.com';
        u.Alias = 'testuser';
        u.CommunityNickname = 'Test User';
        u.TimeZoneSidKey = 'America/Mexico_City';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = pf.Id;
        u.LanguageLocaleKey = 'en_US';
        
        insert u;
        
        System.runAs(u){
          
          Plan__c plan = new Plan__c();
          plan.Name = 'Test Plan record';
          insert plan;
          
          Social_Input__c si = new Social_Input__c();
          si.Plan__c = plan.Id;
          si.Responsible__c = true;
          si.User__c = u.Id;
          insert si;
          
          ApexPages.currentPage().getParameters().put('ID',plan.Id);
          ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(plan);
          
          PlanView PlanV = new PlanView(sc);
          //
          PlanView.tabSectionClicked(si.Id,'attachment-tab');
          PlanView.tabSectionClicked(si.Id,'history-tab');
          PlanView.tabSectionClicked(si.Id,'quality-tab');
          
        }
    }
    
    static testMethod void planDelItem() {
        // TO DO: implement unit test
          
          Plan__c plan = new Plan__c();
          plan.Name = 'Test Plan record';
          insert plan;
          
          Plan__c plan1 = new Plan__c();
          plan1.Name = 'Test Plan record';
          insert plan1;
          
          Relations__c relationItem2 = new Relations__c();
          relationItem2.Child_Id__c = Plan1.Id;
          relationItem2.Child_Record_Name__c = Plan1.Name;
          relationItem2.Child_Object_Name__c = 'Plan';
          relationItem2.Parent_Id__c = plan.Id;
          relationItem2.Days__c = '23';
          relationItem2.Minutes__c = '23';
          relationItem2.Hours__c = '23';
          relationItem2.Parent_Record_Name__c = plan.Name;
          relationItem2.Parent_Object_Name__c = 'Plan';
          relationItem2.Type__c = 'Item';
          insert relationItem2;
          
          ApexPages.currentPage().getParameters().put('ID',plan.Id);
          ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(plan);
          
          PlanView PlanV = new PlanView(sc);
          //
          PlanView.DeleteItem(Plan.Id,relationItem2.Id);
          //PlanView.calTotalMins(Plan.Id);
    }
    
    static testMethod void planDelItem1() {
        // TO DO: implement unit test
          
          Plan__c plan = new Plan__c();
          plan.Name = 'Test Plan record';
          insert plan;
          
          Plan__c plan1 = new Plan__c();
          plan1.Name = 'Test Plan record';
          insert plan1;
          
          Relations__c relationItem2 = new Relations__c();
          relationItem2.Child_Id__c = Plan1.Id;
          relationItem2.Child_Record_Name__c = Plan1.Name;
          relationItem2.Child_Object_Name__c = 'Plan';
          relationItem2.Parent_Id__c = plan.Id;
          relationItem2.Days__c = '23';
          relationItem2.Minutes__c = '23';
          relationItem2.Hours__c = '23';
          relationItem2.Parent_Record_Name__c = plan.Name;
          relationItem2.Parent_Object_Name__c = 'Plan';
          relationItem2.Type__c = 'Item';
          insert relationItem2;
          
          ApexPages.currentPage().getParameters().put('ID',plan.Id);
          ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(plan);
          
          PlanView PlanV = new PlanView(sc);
          //
          //PlanView.DeleteItem(Plan.Id,relationItem2.Id);
          PlanView.calTotalMins(Plan.Id);
    }
    
    static testMethod void planCloneOperation() {
        // TO DO: implement unit test
          
          Plan__c plan = new Plan__c();
          plan.Name = 'Test Plan record';
          insert plan;
          
          Social_Input__c si = new Social_Input__c();
          si.Plan__c = plan.Id;
          si.Responsible__c = true;
          si.User__c = Userinfo.getuserId();
          insert si;
          
          Task task = new Task();
          task.WhatId = plan.Id;
          task.Subject = 'Task on decision';
          task.ActivityDate = Date.today();
          task.Status = 'Inprogress';
          insert task; 
          
          Relations__c relationItem1 = new Relations__c();
          relationItem1.Child_Id__c = Plan.Id;
          relationItem1.Child_Record_Name__c = Plan.Name;
          relationItem1.Child_Object_Name__c = 'Plan';
          relationItem1.Parent_Id__c = plan.Id;
          relationItem1.Days__c = '23';
          relationItem1.Minutes__c = '23';
          relationItem1.Hours__c = '23';
          relationItem1.Parent_Record_Name__c = plan.Name;
          relationItem1.Parent_Object_Name__c = 'Plan';
          relationItem1.Type__c = 'Item';
          insert relationItem1;
          
          ApexPages.currentPage().getParameters().put('ID',plan.Id);
          ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(plan);
          
          PlanView PlanV = new PlanView(sc);
          Apexpages.currentPage().getParameters().put('items','true');
          Apexpages.currentPage().getParameters().put('people','true');
          Apexpages.currentPage().getParameters().put('task','true');
          
          planV.planClone();
          
    }
    
    static testMethod void planCloneOperation1() {
        // TO DO: implement unit test
          Plan__c plan = new Plan__c();
          plan.Name = 'Test Plan record';
          insert plan;
          
          Social_Input__c si = new Social_Input__c();
          si.Plan__c = plan.Id;
          si.Responsible__c = true;
          si.User__c = UserInfo.getUserId();
          insert si;
          
          Task task = new Task();
          task.WhatId = plan.Id;
          task.Subject = 'Task on decision';
          task.ActivityDate = Date.today();
          task.Status = 'Inprogress';
          insert task; 
          
          Relations__c relationItem1 = new Relations__c();
          relationItem1.Child_Id__c = Plan.Id;
          relationItem1.Child_Record_Name__c = Plan.Name;
          relationItem1.Child_Object_Name__c = 'Note';
          relationItem1.Parent_Id__c = plan.Id;
          relationItem1.Days__c = '23';
          relationItem1.Minutes__c = '23';
          relationItem1.Hours__c = '23';
          relationItem1.Parent_Record_Name__c = plan.Name;
          relationItem1.Parent_Object_Name__c = 'Plan';
          relationItem1.Type__c = 'Item';
          insert relationItem1;
          
          ApexPages.currentPage().getParameters().put('ID',plan.Id);
          ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(plan);
          
          PlanView PlanV = new PlanView(sc);
          Apexpages.currentPage().getParameters().put('items','true');
          Apexpages.currentPage().getParameters().put('people','true');
          Apexpages.currentPage().getParameters().put('task','true');
          
          planV.planClone();
          
    }
    
    static testMethod void planCloneOperation2() {
        // TO DO: implement unit test
          
          Plan__c plan = new Plan__c();
          plan.Name = 'Test Plan record';
          insert plan;
          
          Relations__c relationItem2 = new Relations__c();
          relationItem2.Child_Id__c = Plan.Id;
          relationItem2.Child_Record_Name__c = Plan.Name;
          relationItem2.Child_Object_Name__c = 'Plan';
          relationItem2.Parent_Id__c = plan.Id;
          relationItem2.Days__c = '23';
          relationItem2.Minutes__c = '23';
          relationItem2.Hours__c = '23';
          relationItem2.Parent_Record_Name__c = plan.Name;
          relationItem2.Parent_Object_Name__c = 'Plan';
          relationItem2.Type__c = 'Relation';
          insert relationItem2;
          
          Task task = new Task();
          task.WhatId = plan.Id;
          task.Subject = 'Task on decision';
          task.ActivityDate = Date.today();
          task.Status = 'Inprogress';
          insert task; 
          
          Relations__c relationItem22 = new Relations__c();
          relationItem22.Parent_Id__c = task.Id;
          relationItem22.Parent_Record_Name__c = task.Subject;
          relationItem22.Parent_Object_Name__c = 'Task';
          relationItem22.Child_Id__c = plan.Id;
          relationItem22.Days__c = '23';
          relationItem22.Minutes__c = '23';
          relationItem22.Hours__c = '23';
          relationItem22.Child_Record_Name__c = plan.Name;
          relationItem22.Child_Object_Name__c = 'Plan';
          relationItem22.Type__c = 'Relation';
          insert relationItem22;
          
          Attachment att = new Attachment();
          String attchmentBody = 'test class coverage';
          att.Body = Blob.valueOf(attchmentBody);
          att.Name = 'Attached data on decision ';
          att.parentId = Plan.Id;
          insert att;
          
          ApexPages.currentPage().getParameters().put('ID',plan.Id);
          ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(plan);
          
          PlanView PlanV = new PlanView(sc);
          Apexpages.currentPage().getParameters().put('resetDate','true');
          Apexpages.currentPage().getParameters().put('attach','true');
          Apexpages.currentPage().getParameters().put('relateClone','true');
          Apexpages.currentPage().getParameters().put('relationValue','new relation');
          Apexpages.currentPage().getParameters().put('relations','true');
          //planV.planClone();
          planV.planPDF();
    }
    
    static testMethod void planCloneOperation3() {
        // TO DO: implement unit test
          
          Plan__c plan = new Plan__c();
          plan.Name = 'Test Plan record';
          insert plan;
          
          Relations__c relationItem2 = new Relations__c();
          relationItem2.Child_Id__c = Plan.Id;
          relationItem2.Child_Record_Name__c = Plan.Name;
          relationItem2.Child_Object_Name__c = 'Plan';
          relationItem2.Parent_Id__c = plan.Id;
          relationItem2.Days__c = '23';
          relationItem2.Minutes__c = '23';
          relationItem2.Hours__c = '23';
          relationItem2.Parent_Record_Name__c = plan.Name;
          relationItem2.Parent_Object_Name__c = 'Plan';
          relationItem2.Type__c = 'Relation';
          insert relationItem2;
          
          Task task = new Task();
          task.WhatId = plan.Id;
          task.Subject = 'Task on decision';
          task.ActivityDate = Date.today();
          task.Status = 'Inprogress';
          insert task; 
          
          Attachment att = new Attachment();
          String attchmentBody = 'test class coverage';
          att.Body = Blob.valueOf(attchmentBody);
          att.Name = 'Attached data on decision ';
          att.parentId = Plan.Id;
          insert att;
          
          ApexPages.currentPage().getParameters().put('ID',plan.Id);
          ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(plan);
          
          PlanView PlanV = new PlanView(sc);
          Apexpages.currentPage().getParameters().put('resetDate','true');
          Apexpages.currentPage().getParameters().put('attach','true');
          Apexpages.currentPage().getParameters().put('relateClone','true');
          Apexpages.currentPage().getParameters().put('relationValue','new relation');
          Apexpages.currentPage().getParameters().put('relations','true');
          planV.planClone();
          //planV.planPDF();
    }
    
    static testMethod void viewAlltasksTest(){
        
        Plan__c plan = new Plan__c();
        plan.Name = 'Test Plan record';
        insert plan;
        
        Task task = new Task();
        task.WhatId = plan.Id;
        task.Subject = 'Task on decision';
        task.ActivityDate = Date.today();
        task.Status = 'Inprogress';
        task.OwnerId = Userinfo.getUserId();
        insert task; 
        
        //ViewAllTasks vat = new ViewAllTasks();
    }
    
    static testMethod void planNew() {
        // TO DO: implement unit test
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
        User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = 'testuser@test123456789.com';
        u.CompanyName = 'test.com';
        u.Title = 'Test User';
        u.Username = 'testuser15@test123456789.com';
        u.Alias = 'testuser';
        u.CommunityNickname = 'Test User';
        u.TimeZoneSidKey = 'America/Mexico_City';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = pf.Id;
        u.LanguageLocaleKey = 'en_US';
        
        insert u;
        
        
        
        System.runAs(u){
          Plan__c plan = new Plan__c();
          plan.Name = 'test records';
          insert plan;
          
          Decision__c decision = new Decision__c();
          Decision.title__c = 'Test decision';
          Decision.Problem_Idea_Advice__c = 'Problem';
          Decision.Decision_Taken__c = 'Decision';
          Decision.Priority__c = 'Normal';
          insert Decision;
          
          Note note = new Note();
          note.Title = 'decision note';
          note.Body = 'Test class ';
          note.ParentId = Plan.Id;
          insert note;
          
          Group g = new Group();
          g.name = 'NewGroup';
          insert g;
          
          GroupMember gm = new  GroupMember();
          gm.groupId = g.Id;
          gm.UserOrGroupId = u.Id;
          insert gm;
          
          ApexPages.currentPage().getParameters().put('ID',plan.Id);
          ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(plan);
          ApexPages.currentPage().getParameters().put('retURL','test');
          PlanNew PlanN = new PlanNew(sc);
          planN.Save();
          PlanN.customCancel();
          //planN.cancel();
          //ApexPages.currentPage().getParameters().put('decisionId',Decision.Id);
          
          //PlanView planV = new PlanView(sc);
          //planV.createNewTaskForDecision();
          //PlanView.editNote(plan.Id,note.Id,'test','test title');
          //PlanView.retrieveGroupMember(g.Id);
          //planV.saveIssues();
          //PlanView.checkRoleOnDecision(Decision.Id);
          //planView.Datum dat = new PlanView.Datum();
          //PlanView.RootObject ro = new PlanView.RootObject();
          //planV.itemViewDetails();
        }
    }
    
    static testMethod void planNew2() {
        // TO DO: implement unit test
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
        User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = 'testuser@test123456789.com';
        u.CompanyName = 'test.com';
        u.Title = 'Test User';
        u.Username = 'testuser15@test123456789.com';
        u.Alias = 'testuser';
        u.CommunityNickname = 'Test User';
        u.TimeZoneSidKey = 'America/Mexico_City';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = pf.Id;
        u.LanguageLocaleKey = 'en_US';
        
        insert u;
        
        
        
        System.runAs(u){
          Plan__c plan = new Plan__c();
          plan.Name = 'test records';
          insert plan;
          
          Decision__c decision = new Decision__c();
          Decision.title__c = 'Test decision';
          Decision.Problem_Idea_Advice__c = 'Problem';
          Decision.Decision_Taken__c = 'Decision';
          Decision.Priority__c = 'Normal';
          insert Decision;
          
          Note note = new Note();
          note.Title = 'decision note';
          note.Body = 'Test class ';
          note.ParentId = Plan.Id;
          insert note;
          
          Group g = new Group();
          g.name = 'NewGroup';
          insert g;
          
          GroupMember gm = new  GroupMember();
          gm.groupId = g.Id;
          gm.UserOrGroupId = u.Id;
          insert gm;
          
          ApexPages.currentPage().getParameters().put('ID',plan.Id);
          ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(plan);
          
          //PlanNew PlanN = new PlanNew(sc);
          //planN.Save();
          //planN.cancel();
          ApexPages.currentPage().getParameters().put('decisionId',Decision.Id);
          
          PlanView planV = new PlanView(sc);
          //planV.createNewTaskForDecision();
          //PlanView.editNote(plan.Id,note.Id,'test','test title');
          PlanView.retrieveGroupMember(g.Id);
          planV.saveIssues();
          //PlanView.checkRoleOnDecision(Decision.Id);
          //planView.Datum dat = new PlanView.Datum();
          //PlanView.RootObject ro = new PlanView.RootObject();
          //planV.itemViewDetails();
        }
    }
    
    static testMethod void planNew3() {
        // TO DO: implement unit test
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
        User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = 'testuser@test123456789.com';
        u.CompanyName = 'test.com';
        u.Title = 'Test User';
        u.Username = 'testuser15@test123456789.com';
        u.Alias = 'testuser';
        u.CommunityNickname = 'Test User';
        u.TimeZoneSidKey = 'America/Mexico_City';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = pf.Id;
        u.LanguageLocaleKey = 'en_US';
        
        insert u;
        
        
        
        System.runAs(u){
          Plan__c plan = new Plan__c();
          plan.Name = 'test records';
          insert plan;
          
          
          Note note = new Note();
          note.Title = 'decision note';
          note.Body = 'Test class ';
          note.ParentId = Plan.Id;
          insert note;
          
          Group g = new Group();
          g.name = 'NewGroup';
          insert g;
          
          GroupMember gm = new  GroupMember();
          gm.groupId = g.Id;
          gm.UserOrGroupId = u.Id;
          insert gm;
          
          ApexPages.currentPage().getParameters().put('ID',plan.Id);
          ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(plan);
          
          //PlanNew PlanN = new PlanNew(sc);
          //planN.Save();
          //planN.cancel();
          //ApexPages.currentPage().getParameters().put('decisionId',Decision.Id);
          
          PlanView planV = new PlanView(sc);
          //planV.createNewTaskForDecision();
          PlanView.editNote(plan.Id,note.Id,'test','test title');
          //PlanView.retrieveGroupMember(g.Id);
          //planV.saveIssues();
          //PlanView.checkRoleOnDecision(Decision.Id);
          //planView.Datum dat = new PlanView.Datum();
          //PlanView.RootObject ro = new PlanView.RootObject();
          //planV.itemViewDetails();
        }
    }
    
    static testMethod void planNew1() {
        // TO DO: implement unit test
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
        User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = 'testuser@test123456789.com';
        u.CompanyName = 'test.com';
        u.Title = 'Test User';
        u.Username = 'testuser15@test123456789.com';
        u.Alias = 'testuser';
        u.CommunityNickname = 'Test User';
        u.TimeZoneSidKey = 'America/Mexico_City';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = pf.Id;
        u.LanguageLocaleKey = 'en_US';
        
        insert u;
        
        
        
        System.runAs(u){
          PLan__c plan = new Plan__c();
          plan.Name = 'test records';
          insert plan;
          
          Note note = new Note();
          note.Title = 'decision note';
          note.Body = 'Test class ';
          note.ParentId = Plan.Id;
          insert note;
          
          Group g = new Group();
          g.name = 'NewGroup';
          insert g;
          
          GroupMember gm = new  GroupMember();
          gm.groupId = g.Id;
          gm.UserOrGroupId = u.Id;
          insert gm;
          
          Relations__c rel1 = new Relations__c();
          rel1.Child_Id__c = plan.Id;
          rel1.Child_Record_Name__c = plan.Name;
          rel1.Child_Object_Name__c = 'Decision';
          rel1.Parent_Id__c = Plan.Id;
          rel1.Parent_Record_Name__c = Plan.name;
          rel1.Parent_Object_Name__c = 'Plan';
          rel1.Type__c = 'Item';
          insert rel1;
          
          ApexPages.currentPage().getParameters().put('ID',plan.Id);
          ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(plan);
          
          PlanNew PlanN = new PlanNew(sc);
          planN.Save();
          //planN.cancel();
          ApexPages.currentPage().getParameters().put('decisionId',plan.Id);
          
          PlanView planV = new PlanView(sc);
          //PlanView.checkRoleOnDecision(plan.Id);
          planView.Datum dat = new PlanView.Datum();
          PlanView.RootObject ro = new PlanView.RootObject();
          planview.TaskEventHistory teh = new PlanView.TaskEventHistory();
          planview.getPlanRelation(plan.Id);
          //planV.itemViewDetails();
        }
    }
    
    static testMethod void planNew11() {
        // TO DO: implement unit test
        
        PLan__c plan = new Plan__c();
          plan.Name = 'test records';
          insert plan;
        
          Decision__c decision = new Decision__c();
            Decision.Title__c = 'Test record';
            Decision.Priority__c = 'Normal';
            Decision.Problem_Idea_Advice__c = 'Problem';
            Decision.Phase__c = 'Share';
            insert Decision;
            
          ApexPages.currentPage().getParameters().put('ID',plan.Id);
          ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(plan);
          
          ApexPages.currentPage().getParameters().put('decisionId',Decision.Id);
          
          PlanView planV = new PlanView(sc);
          PlanView.checkRoleOnDecision(Decision.Id);
          planV.createNewTaskForDecision();
          //planV.itemViewDetails();
    }
    
    static testMethod void planNew12() {
        // TO DO: implement unit test
        
        PLan__c plan = new Plan__c();
          plan.Name = 'test records';
          insert plan;
        
          ApexPages.currentPage().getParameters().put('ID',plan.Id);
          ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(plan);
          
          PlanView planV = new PlanView(sc);
          //PlanView.checkRoleOnDecision(Decision.Id);
          //planV.createNewTaskForDecision();
          planV.itemViewDetails();
    }
    
    static testMethod void deleteNote() {
        // TO DO: implement unit test
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
        User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = 'testuser@test123456789.com';
        u.CompanyName = 'test.com';
        u.Title = 'Test User';
        u.Username = 'testuser15@test123456789.com';
        u.Alias = 'testuser';
        u.CommunityNickname = 'Test User';
        u.TimeZoneSidKey = 'America/Mexico_City';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = pf.Id;
        u.LanguageLocaleKey = 'en_US';
        
        insert u;
        
        
        
        System.runAs(u){
          PLan__c plan = new Plan__c();
          plan.Name = 'test records';
          insert plan;
          
                   
          Note note = new Note();
          note.Title = 'decision note';
          note.Body = 'Test class ';
          note.ParentId = Plan.Id;
          insert note;
          
          Delete note;
        }   
    }
    
    static testMethod void AddPeople() {
        // TO DO: implement unit test
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
        User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = 'testuser@test123456789.com';
        u.CompanyName = 'test.com';
        u.Title = 'Test User';
        u.Username = 'testuser15@test123456789.com';
        u.Alias = 'testuser';
        u.CommunityNickname = 'Test User';
        u.TimeZoneSidKey = 'America/Mexico_City';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = pf.Id;
        u.LanguageLocaleKey = 'en_US';
        
        insert u;  
        
        
              
          Plan__c plan =  new Plan__c();
          plan.name = 'Test record for add edit people';
          insert plan;
          
          Decision__c decision = new Decision__c();
          Decision.title__c = 'Test decision';
          Decision.Problem_Idea_Advice__c = 'Problem';
          Decision.Decision_Taken__c = 'Decision';
          Decision.Priority__c = 'Normal';
          insert Decision;
          
          Group g;
          GroupMember gm;
          system.runas(u){
          g = new Group();
          g.name = 'NewGroup';
          insert g;
          
          gm = new  GroupMember();
          gm.groupId = g.Id;
          gm.UserOrGroupId = UserInfo.getUserId();
          insert gm;
          }
          Social_Input__c si = new Social_Input__c();
          si.Plan__c = plan.Id;
          si.Responsible__c = true;
          si.User__c = UserInfo.getUserId();
          si.Is_Group__c = true;  
          insert si;
          
          ApexPages.currentPage().getParameters().put('objType','plan');
          ApexPages.currentPage().getParameters().put('searchText','');
          ApexPages.currentPage().getParameters().put('Id',plan.id);
          
          AddEditPeople add = new AddEditPeople();
          add.searchUsers();
          
          ApexPages.currentPage().getParameters().put('objType','decision');
          ApexPages.currentPage().getParameters().put('searchText','');
          ApexPages.currentPage().getParameters().put('Id',decision.id);
          ApexPages.currentPage().getParameters().put('userType','User');
          ApexPages.currentPage().getParameters().put('searchText','Test*');
          ApexPages.currentPage().getParameters().put('selectedUsers',UserInfo.getUserId()+','+UserInfo.getUserId());
          
          AddEditPeople adds = new AddEditPeople();
          adds.searchUsers();
          //adds.listToBeDeletedId.add(UserInfo.getUserId());
          try {	
          	adds.addingUserBasedOnType();
          } catch (exception e){
          	
          }
          //adds.userSearched[0].selectUser = true;
          List<Id> userIds = new List<Id>();
          userIds.add(UserInfo.getUserId());
          try {	
          	Pagereference pr = adds.addedUser(userIds,'User','informedReqd','responsibleReqd','consultedReqd');
          } catch (exception e){
          	
          }
          userIds.clear();
          userIds.add(g.Id);
          try {		
          	Pagereference pr1 = adds.addedUser(userIds,'Group','informedReqd','responsibleReqd','consultedReqd');
          } catch (exception e){
          	
          }
    }
    
    static testMethod void AddPeople3() {
        // TO DO: implement unit test
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
        User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = 'testuser@test123456789.com';
        u.CompanyName = 'test.com';
        u.Title = 'Test User';
        u.Username = 'testuser15@test123456789.com';
        u.Alias = 'testuser';
        u.CommunityNickname = 'Test User';
        u.TimeZoneSidKey = 'America/Mexico_City';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = pf.Id;
        u.LanguageLocaleKey = 'en_US';
        
        insert u;  
        
        
              
          Plan__c plan =  new Plan__c();
          plan.name = 'Test record for add edit people';
          insert plan;
          
          Decision__c decision = new Decision__c();
          Decision.title__c = 'Test decision';
          Decision.Problem_Idea_Advice__c = 'Problem';
          Decision.Decision_Taken__c = 'Decision';
          Decision.Priority__c = 'Normal';
          insert Decision;
          
          Group g;
          GroupMember gm;
          system.runas(u){
          g = new Group();
          g.name = 'NewGroup';
          insert g;
          
          gm = new  GroupMember();
          gm.groupId = g.Id;
          gm.UserOrGroupId = UserInfo.getUserId();
          insert gm;
          }
          Social_Input__c si = new Social_Input__c();
          si.Plan__c = plan.Id;
          si.Responsible__c = true;
          si.User__c = UserInfo.getUserId();
          si.Is_Group__c = true;  
          insert si;
          
          ApexPages.currentPage().getParameters().put('objType','plan');
          ApexPages.currentPage().getParameters().put('searchText','');
          ApexPages.currentPage().getParameters().put('Id',plan.id);
          
          ApexPages.currentPage().getParameters().put('objType','decision');
          ApexPages.currentPage().getParameters().put('searchText','');
          ApexPages.currentPage().getParameters().put('Id',decision.id);
          ApexPages.currentPage().getParameters().put('userType','User');
          ApexPages.currentPage().getParameters().put('searchText','Test*');
          ApexPages.currentPage().getParameters().put('selectedUsers',UserInfo.getUserId()+','+UserInfo.getUserId());
          
          List<Id> userIds = new List<Id>();
          userIds.clear();
          userIds.add(UserInfo.getUserId());
          userIds.add(g.Id);
          
          ApexPages.currentPage().getParameters().put('searchType','Group');
          ApexPages.currentPage().getParameters().put('searchText','New*');
          ApexPages.currentPage().getParameters().put('existType','Exist');
          ApexPages.currentPage().getParameters().put('userType','User');
          ApexPages.currentPage().getParameters().put('socialInputId',UserInfo.getUserId());
          AddEditPeople adds1 = new AddEditPeople();
          adds1.searchUsers();
          adds1.deletePeople();
          adds1.saveCurrentPeople();
          //adds1.addedUser(userIds,'Group','informedReqd','consultedReqd','responsibleReqd');
          //adds1.userSearched[0].selectUser = true;
          //adds1.addedUser();
          
          //AddEditPeople.retrieveGroupMember(g.Id);
          
          adds1.Cancel();
          adds1.savePeople();
          
    }
    
    static testMethod void AddPeople1() {
        // TO DO: implement unit test
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
        User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = 'testuser@test123456789.com';
        u.CompanyName = 'test.com';
        u.Title = 'Test User';
        u.Username = 'testuser15@test123456789.com';
        u.Alias = 'testuser';
        u.CommunityNickname = 'Test User';
        u.TimeZoneSidKey = 'America/Mexico_City';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = pf.Id;
        u.LanguageLocaleKey = 'en_US';
        
        insert u;  
        
        
              
          Plan__c plan =  new Plan__c();
          plan.name = 'Test record for add edit people';
          insert plan;
          
          Decision__c decision = new Decision__c();
          Decision.title__c = 'Test decision';
          Decision.Problem_Idea_Advice__c = 'Problem';
          Decision.Decision_Taken__c = 'Decision';
          Decision.Priority__c = 'Normal';
          insert Decision;
          
          Group g;
          GroupMember gm;
          system.runas(u){
          g = new Group();
          g.name = 'NewGroup';
          insert g;
          
          gm = new  GroupMember();
          gm.groupId = g.Id;
          gm.UserOrGroupId = UserInfo.getUserId();
          insert gm;
          }
          Social_Input__c si = new Social_Input__c();
          si.Plan__c = plan.Id;
          si.Responsible__c = true;
          si.User__c = UserInfo.getUserId();
          si.Is_Group__c = true;  
          insert si;
          
          ApexPages.currentPage().getParameters().put('objType','plan');
          ApexPages.currentPage().getParameters().put('searchText','');
          ApexPages.currentPage().getParameters().put('Id',plan.id);
          
          ApexPages.currentPage().getParameters().put('objType','decision');
          ApexPages.currentPage().getParameters().put('searchText','');
          ApexPages.currentPage().getParameters().put('Id',decision.id);
          ApexPages.currentPage().getParameters().put('searchType','User');
          ApexPages.currentPage().getParameters().put('searchText','Test*');
          ApexPages.currentPage().getParameters().put('selectedUsers',UserInfo.getUserId()+','+UserInfo.getUserId());
          
          //adds.userSearched[0].selectUser = true;
          List<Id> userIds = new List<Id>();
          userIds.clear();
          userIds.add(g.Id);
          
          ApexPages.currentPage().getParameters().put('userTypewrap','Group');
          ApexPages.currentPage().getParameters().put('searchText','New*');
          ApexPages.currentPage().getParameters().put('existType','Exist');
          ApexPages.currentPage().getParameters().put('userTypewrap','User');
          ApexPages.currentPage().getParameters().put('addingAsResponsiblewrap','responsibleReqd');
          ApexPages.currentPage().getParameters().put('socialInputId',UserInfo.getUserId());
          ApexPages.currentPage().getParameters().put('selectedUserswrap',UserInfo.getUserId()+','+UserInfo.getUserId());
          AddEditPeople adds1 = new AddEditPeople();
          try {	
          	adds1.addedUser(userIds,'Group','informedReqd','consultedReqd','responsibleReqd');
          } catch (exception e){
          	
          }
          try {	
          	adds1.addinWrapeerUserBasedOnType();
          } catch (exception e){
          	
          }
          try {	
          	AddEditPeople.retrieveGroupMember(g.Id);
          } catch (exception e){
          	
          }
          //adds1.userSearched[0].selectUser = true;
          //adds1.addedUser();
    }
    
    static testMethod void AddPeople2() {
        // TO DO: implement unit test
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
        User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = 'testuser@test123456789.com';
        u.CompanyName = 'test.com';
        u.Title = 'Test User';
        u.Username = 'testuser15@test123456789.com';
        u.Alias = 'testuser';
        u.CommunityNickname = 'Test User';
        u.TimeZoneSidKey = 'America/Mexico_City';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = pf.Id;
        u.LanguageLocaleKey = 'en_US';
        
        insert u;  
        
        
              
          Plan__c plan =  new Plan__c();
          plan.name = 'Test record for add edit people';
          insert plan;
          
          Decision__c decision = new Decision__c();
          Decision.title__c = 'Test decision';
          Decision.Problem_Idea_Advice__c = 'Problem';
          Decision.Decision_Taken__c = 'Decision';
          Decision.Priority__c = 'Normal';
          insert Decision;
          
          Group g;
          GroupMember gm;
	          g = new Group();
	          g.name = 'NewGroup';
	          
	          gm = new  GroupMember();
          system.runas(u){
	          insert g;
	          gm.groupId = g.Id;
	          gm.UserOrGroupId = UserInfo.getUserId();
	          insert gm;
          }
          Social_Input__c si = new Social_Input__c();
          si.Plan__c = plan.Id;
          si.Responsible__c = true;
          si.User__c = UserInfo.getUserId();
          si.Is_Group__c = true;  
          insert si;
          
          ApexPages.currentPage().getParameters().put('objType','plan');
          ApexPages.currentPage().getParameters().put('searchText','');
          ApexPages.currentPage().getParameters().put('Id',plan.id);
          
          ApexPages.currentPage().getParameters().put('objType','decision');
          ApexPages.currentPage().getParameters().put('searchText','');
          ApexPages.currentPage().getParameters().put('Id',decision.id);
          ApexPages.currentPage().getParameters().put('searchType','User');
          ApexPages.currentPage().getParameters().put('searchText','Test*');
          ApexPages.currentPage().getParameters().put('selectedUsers',UserInfo.getUserId()+','+UserInfo.getUserId()+','+g.Id+','+gm.Id);
          
          //adds.userSearched[0].selectUser = true;
          List<Id> userIds = new List<Id>();
          userIds.clear();
          userIds.add(g.Id);
          
          ApexPages.currentPage().getParameters().put('userTypewrap','Group');
          //ApexPages.currentPage().getParameters().put('userTypewrap','User');
          ApexPages.currentPage().getParameters().put('addingAsInformedwrap','informedReqd');
          ApexPages.currentPage().getParameters().put('addingAsResponsiblewrap','test');
          ApexPages.currentPage().getParameters().put('addingAsConsultedwrap','test');
          ApexPages.currentPage().getParameters().put('socialInputId',UserInfo.getUserId());
          ApexPages.currentPage().getParameters().put('selectedUserswrap',UserInfo.getUserId()+','+UserInfo.getUserId()+','+UserInfo.getUserId()+','+g.Id+','+gm.Id);
          AddEditPeople adds1 = new AddEditPeople();
          try {	
          	adds1.addinWrapeerUserBasedOnType();
          } catch (exception e){
          	
          }
          try {
          	adds1.addedUser(userIds,'Group','informedReqd','consultedReqd','responsibleReqd');
          } catch (exception e){
          	
          }
          set<Id> userIds1 = new set<Id>();
          userIds1.add(userInfo.getUserId());
          adds1.addUsersfromGroupToDelete(userIds1,userIds1);
          //adds1.userSearched[0].selectUser = true;
          List<Id> userIdList = new List<Id>();
          userIdList.add(UserInfo.getUserId());
          try {	
          	adds1.addedUser(userIdList,'User','informedReqd','responsibleReqd','consultedReqd');
	          
          } catch (exception e){
          	
          }
          adds1.deleteThisSocialInput();
	      adds1.dummyRender();
          //AddEditPeople.retrieveGroupMember(g.Id);
          
    }
    
    /*static testMethod void AddPeopleForPlan() {
        // TO DO: implement unit test
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
        
        User u = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' and isActive = true limit 1];
        
        User u1 = new User();
        u1.FirstName = 'Tested';
        u1.LastName = 'User';
        u1.Email = 'testuser123@test123456789.com';
        u1.CompanyName = 'test.com';
        u1.Title = 'Test User';
        u1.Username = 'testuser17@test123456789.com';
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
        u11.Username = 'testuser18@test123456789.com';
        u11.Alias = 'testuser';
        u11.CommunityNickname = 'Test User2';
        u11.TimeZoneSidKey = 'America/Mexico_City';
        u11.LocaleSidKey = 'en_US';
        u11.EmailEncodingKey = 'ISO-8859-1';
        u11.ProfileId = pf.Id;
        u11.LanguageLocaleKey = 'en_US';
        
        insert u11;
        
        System.runAs(u1){
          
          Plan__c plan =  new Plan__c();
          plan.name = 'Test record for add edit people';
          insert plan;
          
          Decision__c decision = new Decision__c();
          Decision.title__c = 'Test decision';
          Decision.Problem_Idea_Advice__c = 'Problem';
          Decision.Decision_Taken__c = 'Decision';
          Decision.Priority__c = 'Normal';
          insert Decision;
          
          Group g = new Group();
          g.name = 'NewGroup';
          insert g;
          
          GroupMember gm = new  GroupMember();
          gm.groupId = g.Id;
          gm.UserOrGroupId = u11.Id;
          insert gm;
          
          Social_Input__c si = new Social_Input__c();
          si.Plan__c = plan.Id;
          si.Responsible__c = true;
          si.User__c = u11.Id;
          si.Is_Group__c = true;
          insert si;
          
          ApexPages.currentPage().getParameters().put('objType','plan');
          ApexPages.currentPage().getParameters().put('searchText','');
          ApexPages.currentPage().getParameters().put('Id',plan.id);
          
          AddEditPeopleOnPlan add = new AddEditPeopleOnPlan();
          add.searchUsers();
          
          ApexPages.currentPage().getParameters().put('objType','decision');
          ApexPages.currentPage().getParameters().put('searchText','');
          ApexPages.currentPage().getParameters().put('Id',decision.id);
          ApexPages.currentPage().getParameters().put('searchType','User');
          ApexPages.currentPage().getParameters().put('searchText','Test*');
          ApexPages.currentPage().getParameters().put('selectedUsers',u1.Id+','+u1.Id);
          
          AddEditPeopleOnPlan adds = new AddEditPeopleOnPlan();
          adds.searchUsers();
          adds.addingUserBasedOnType();
          //adds.userSearched[0].selectUser = true;
          List<Id> userIds = new List<Id>();
          userIds.add(u11.Id);
          Pagereference pr = adds.addedUser(userIds,'User','informedReqd','responsibleReqd','consultedReqd');
          userIds.clear();
          userIds.add(g.Id);
          Pagereference pr1 = adds.addedUser(userIds,'Group','informedReqd','responsibleReqd','consultedReqd');
          
          ApexPages.currentPage().getParameters().put('searchType','Group');
          ApexPages.currentPage().getParameters().put('searchText','New*');
          ApexPages.currentPage().getParameters().put('existType','Exist');
          ApexPages.currentPage().getParameters().put('userType','User');
          ApexPages.currentPage().getParameters().put('socialInputId',u11.Id);
          AddEditPeopleOnPlan adds1 = new AddEditPeopleOnPlan();
          adds1.searchUsers();
          adds1.deletePeople();
          adds1.saveCurrentPeople();
          adds1.addedUser(userIds,'Group','informedReqd','consultedReqd','responsibleReqd');
          //adds1.userSearched[0].selectUser = true;
          //adds1.addedUser();
          
          AddEditPeopleOnPlan.retrieveGroupMember(g.Id);
          
          adds.Cancel();
          add.savePeople();
          
        }
    }
    */
    static testMethod void FLSMethods(){
        FLS f = new FLS();
        Boolean b = FLS.decisionDeletable();
        FLS.socialInputDeletable();
        FLS.tagUpdateable();
        FLS.tagDelete();
        FLS.tagJunctionUpdateable();
        FLS.tagJunctionDeletable();
        FLS.timingCreateable();
        FLS.timingDelete();
        FLS.issuesUpdateable();
        FLS.issuesDeletable();
        FLS.relationDeletable();
        FLS.taskDeletable();
        FLS.taskUpdateable();
        FLS.eventDeletable();
        FLS.attachmentDeletable();
        FLS.noteDeletable();
        FLS.planDeletable();
        
        GenerlHistoryComponent ghc = new GenerlHistoryComponent();
        ghc.MapValuesDateTime();
        ghc.MapValuesDateFormate();
    }
    
    
    
    static testMethod void AddRelations() {
        
    }
    
    static testMethod void EditRelations() {
        // TO DO: implement unit test
        
          
          Plan__c plan =  new Plan__c();
          plan.name = 'Test record for add edit people';
          insert plan;
          
          Decision__c decision = new Decision__c();
          Decision.title__c = 'Test decision';
          Decision.Problem_Idea_Advice__c = 'Problem';
          Decision.Decision_Taken__c = 'Decision';
          Decision.Priority__c = 'Normal';
          insert Decision;
          
          
          
          Relations__c rel1 = new Relations__c();
          rel1.Child_Id__c = Decision.Id;
          rel1.Child_Record_Name__c = Decision.Title__c;
          rel1.Child_Object_Name__c = 'Decision';
          rel1.Parent_Id__c = Plan.Id;
          rel1.Parent_Record_Name__c = Plan.name;
          rel1.Parent_Object_Name__c = 'Plan';
          insert rel1;
          
          
          
          ApexPages.currentPage().getParameters().put('relId',rel1.Id);
          ApexPages.currentPage().getParameters().put('Id',plan.id);//type
          ApexPages.currentPage().getParameters().put('relPlan','True');
          ApexPages.currentPage().getParameters().put('type','1');
          EditRelationship add = new EditRelationship();
          
          ApexPages.currentPage().getParameters().put('relId',rel1.Id);
          ApexPages.currentPage().getParameters().put('Id',Decision.id);//type
          ApexPages.currentPage().getParameters().put('relPlan','false');
          ApexPages.currentPage().getParameters().put('type','2');
          EditRelationship adds = new EditRelationship();
          
          rel1.Notes__c = 'Note';
          update rel1;
          adds.relaType = '1';
          adds.Save();
          add.cancel();
          
    }
    
    static testMethod void nearestDuedateTest() {
        Decision__c decision = new Decision__c();
        Decision.title__c = 'Test decision';
        Decision.Problem_Idea_Advice__c = 'Problem';
        Decision.Decision_Taken__c = 'Decision';
        Decision.Priority__c = 'Normal';
        decision.Phase__c = 'Share';
        insert Decision;
        
        String DecisionId = string.valueOf(Decision.id);
        
        List<Timing__c> timingList = new List<Timing__c>();
        for(Timing__c time1 :[Select t.Start_Date_Time__c, t.Stage__c, t.Related_To_ID__c, t.End_Date_Time__c, t.Elapsed_Time__c, t.Difference__c, t.Actual_Start_Date__c, t.Actual_End_Date__c From Timing__c t where t.Related_To_ID__c =: DecisionId]){
            if(time1.Stage__c == 'Close'){
                time1.End_Date_Time__c = System.now();
                time1.Start_Date_Time__c = System.now();
            }
            if(time1.Stage__c == 'Evaluate'){
                time1.End_Date_Time__c = System.now();
                time1.Start_Date_Time__c = System.now();
            }
            if(time1.Stage__c == 'Execute'){
                time1.End_Date_Time__c = System.now();
                time1.Start_Date_Time__c = System.now();
            }
            if(time1.Stage__c == 'Decide'){
                time1.End_Date_Time__c = System.now();
                time1.Start_Date_Time__c = System.now();
            }
            if(time1.Stage__c == 'Propose'){
                time1.End_Date_Time__c = System.now();
                time1.Start_Date_Time__c = System.now();
            }
            if(time1.Stage__c == 'Share'){
                time1.End_Date_Time__c = System.now();
                time1.Start_Date_Time__c = System.now();
            }
            timingList.add(time1);      
        }
        
        if(timingList.size() > 0){
            update timingList;  
        }
        
        UpdateNearestDueDate und = new UpdateNearestDueDate();
        UpdateNearestDueDate.updateAllDeicisons(null);
        
        Decision__c decision1 = new Decision__c();
        Decision1.title__c = 'Test decision';
        Decision1.Problem_Idea_Advice__c = 'Problem';
        Decision1.Decision_Taken__c = 'Decision';
        Decision1.Priority__c = 'Normal';
        decision1.Phase__c = 'Decide';
        insert Decision1;
        
        String DecisionId1 = string.valueOf(Decision1.id);
        
        List<Timing__c> timingList1 = new List<Timing__c>();
        for(Timing__c time1 :[Select t.Start_Date_Time__c, t.Stage__c, t.Related_To_ID__c, t.End_Date_Time__c, t.Elapsed_Time__c, t.Difference__c, t.Actual_Start_Date__c, t.Actual_End_Date__c From Timing__c t where t.Related_To_ID__c =: DecisionId1]){
            if(time1.Stage__c == 'Close'){
                time1.End_Date_Time__c = System.now();
                time1.Start_Date_Time__c = System.now();
            }
            if(time1.Stage__c == 'Evaluate'){
                time1.End_Date_Time__c = System.now();
                time1.Start_Date_Time__c = System.now();
            }
            if(time1.Stage__c == 'Execute'){
                time1.End_Date_Time__c = System.now();
                time1.Start_Date_Time__c = System.now();
            }
            if(time1.Stage__c == 'Decide'){
                time1.End_Date_Time__c = System.now();
                time1.Start_Date_Time__c = System.now();
            }
            timingList1.add(time1);     
        }
        
        if(timingList1.size() > 0){
            update timingList1; 
        }
        
        UpdateNearestDueDate.updateAllDeicisons(Decision1.Id);
        
        Decision__c decision2 = new Decision__c();
        Decision2.title__c = 'Test decision';
        decision2.Problem_Idea_Advice__c = 'Problem';
        decision2.Decision_Taken__c = 'Decision';
        decision2.Priority__c = 'Normal';
        decision2.Phase__c = 'Execute';
        insert decision2;
        
        String DecisionId2 = string.valueOf(Decision2.id);
        
        List<Timing__c> timingList2 = new List<Timing__c>();
        for(Timing__c time1 :[Select t.Start_Date_Time__c, t.Stage__c, t.Related_To_ID__c, t.End_Date_Time__c, t.Elapsed_Time__c, t.Difference__c, t.Actual_Start_Date__c, t.Actual_End_Date__c From Timing__c t where t.Related_To_ID__c =: DecisionId2]){
            if(time1.Stage__c == 'Close'){
                time1.End_Date_Time__c = System.now();
                time1.Start_Date_Time__c = System.now();
            }
            if(time1.Stage__c == 'Evaluate'){
                time1.End_Date_Time__c = System.now();
                time1.Start_Date_Time__c = System.now();
            }
            if(time1.Stage__c == 'Execute'){
                time1.End_Date_Time__c = System.now();
                time1.Start_Date_Time__c = System.now();
            }
            
            timingList2.add(time1);     
        }
        
        if(timingList2.size() > 0){
            update timingList2; 
        }
        
        UpdateNearestDueDate.updateAllDeicisons(decision2.Id);
        
        Decision__c decision3 = new Decision__c();
        decision3.title__c = 'Test decision';
        decision3.Problem_Idea_Advice__c = 'Problem';
        decision3.Decision_Taken__c = 'Decision';
        decision3.Priority__c = 'Normal';
        decision3.Phase__c = 'Evaluate';
        insert decision3;
        
        String DecisionId3 = string.valueOf(Decision3.id);
        
        List<Timing__c> timingList65 = new List<Timing__c>();
        for(Timing__c time1 :[Select t.Start_Date_Time__c, t.Stage__c, t.Related_To_ID__c, t.End_Date_Time__c, t.Elapsed_Time__c, t.Difference__c, t.Actual_Start_Date__c, t.Actual_End_Date__c From Timing__c t where t.Related_To_ID__c =: DecisionId3]){
            if(time1.Stage__c == 'Close'){
                time1.End_Date_Time__c = System.now();
                time1.Start_Date_Time__c = System.now();
            }
            if(time1.Stage__c == 'Evaluate'){
                time1.End_Date_Time__c = System.now();
                time1.Start_Date_Time__c = System.now();
            }
            
            
            timingList65.add(time1);        
        }
        
        if(timingList65.size() > 0){
            update timingList65;    
        }
        
        UpdateNearestDueDate.updateAllDeicisons(decision3.Id);
    }
    
    static testMethod void nearestDuedateTest1() {
        
        
        Decision__c decision1 = new Decision__c();
        Decision1.title__c = 'Test decision';
        Decision1.Problem_Idea_Advice__c = 'Problem';
        Decision1.Decision_Taken__c = 'Decision';
        Decision1.Priority__c = 'Normal';
        decision1.Phase__c = 'Draft';
        insert Decision1;
        
        String DecisionId4 = string.valueOf(Decision1.id);
        
        List<Timing__c> timingList = new List<Timing__c>();
        for(Timing__c time1 :[Select t.Start_Date_Time__c, t.Stage__c, t.Related_To_ID__c, t.End_Date_Time__c, t.Elapsed_Time__c, t.Difference__c, t.Actual_Start_Date__c, t.Actual_End_Date__c From Timing__c t where t.Related_To_ID__c =: DecisionId4]){
            if(time1.Stage__c == 'Close'){
                time1.End_Date_Time__c = System.now();
                time1.Start_Date_Time__c = System.now();
            }
            if(time1.Stage__c == 'Evaluate'){
                time1.End_Date_Time__c = System.now();
                time1.Start_Date_Time__c = System.now();
            }
            if(time1.Stage__c == 'Execute'){
                time1.End_Date_Time__c = System.now();
                time1.Start_Date_Time__c = System.now();
            }
            if(time1.Stage__c == 'Decide'){
                time1.End_Date_Time__c = System.now();
                time1.Start_Date_Time__c = System.now();
            }
            if(time1.Stage__c == 'Propose'){
                time1.End_Date_Time__c = System.now();
                time1.Start_Date_Time__c = System.now();
            }
            if(time1.Stage__c == 'Share'){
                time1.End_Date_Time__c = System.now();
                time1.Start_Date_Time__c = System.now();
            }
            if(time1.Stage__c == 'Draft'){
                time1.End_Date_Time__c = System.now();
                time1.Start_Date_Time__c = System.now();
            }
            timingList.add(time1);      
        }
        
        if(timingList.size() > 0){
            update timingList;  
        }
        
        UpdateNearestDueDate.updateAllDeicisons(Decision1.Id);
        
    }
    
    static testMethod void decisiondummyMethods() {
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
        Plan__c plan = new Plan__c();
        plan.Name = 'Test Plan record';
        insert plan;
        
        Decision__c decision3 = new Decision__c();
        decision3.title__c = 'Test';
        decision3.Problem_Idea_Advice__c = 'Problem';
        decision3.Decision_Taken__c = 'Decision';
        decision3.Priority__c = 'Normal';
        decision3.Phase__c = 'Evaluate';
        insert decision3;
        
     
      
      Contact c = new Contact();
      c.Lastname = 'Test';
      insert c;
      
      Account a = new Account();
      a.Name = 'test';
      insert a;
      
      Opportunity opp = new Opportunity();
      opp.Name ='Test OPP';
      opp.AccountId =a.id;
      opp.CloseDate = system.Today();
      opp.StageName = 'Prospecting';
      insert opp;  
      
      
      
      Pricebook2 pb = [select Id from Pricebook2 where IsStandard = true limit 1];
      Product2 p = new Product2(Name = 'Test Product', isActive = true);
      insert p;
       
      /*PriceBookEntry testPriceBookEntryRec = [SELECT Id FROM PricebookEntry limit 1];
      Quote quotesRec = new Quote(Name='QuoteTest',Opportunityid=opp.id,PriceBook2Id = pb.Id);
      insert quotesRec;
      QuoteLineItem qli = new QuoteLineItem(QuoteId = quotesRec.Id,PriceBookEntryId = testPriceBookEntryRec.Id, Quantity = 1, UnitPrice = 100);
      insert qli;*/
        
        ApexPages.currentPage().getParameters().put('id',plan.Id);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(Plan);
        PlanView dv = new PlanView(sc);
        dv.existingRelationsAddToSet();
        ApexPages.currentPage().getParameters().put('chooseObject','User');
        ApexPages.currentPage().getParameters().put('searchText','Test*');
        dv.searchItems();
        //ApexPages.currentPage().getParameters().put('chooseObject','Plan__c');
        //ApexPages.currentPage().getParameters().put('searchText','Test*');
        //dv.searchItems();
        ApexPages.currentPage().getParameters().put('chooseObject','Decision__c');
        ApexPages.currentPage().getParameters().put('searchText','Test*');
        dv.searchItems();
       //-------start commneted on 24_2_2014----
       // ApexPages.currentPage().getParameters().put('chooseObject','Task');
       // ApexPages.currentPage().getParameters().put('searchText','Test*');
       // dv.searchItems();
       //-------end commneted on 24_2_2014----
        /*ApexPages.currentPage().getParameters().put('chooseObject','Account');
        ApexPages.currentPage().getParameters().put('searchText','Test*');
        dv.searchItems();
        ApexPages.currentPage().getParameters().put('chooseObject','Contact');
        ApexPages.currentPage().getParameters().put('searchText','Test*');
        dv.searchItems();*/
        //-------start commneted on 24_2_2014----
        //ApexPages.currentPage().getParameters().put('chooseObject','Issue__c');
        //ApexPages.currentPage().getParameters().put('searchText','Test*');
        //dv.searchItems();
        //-------end commneted on 24_2_2014----
        ApexPages.currentPage().getParameters().put('chooseObject','QuoteLineItem');
        ApexPages.currentPage().getParameters().put('searchText','*');
        dv.searchItems();
        
    }
    
    static testMethod void decisiondummyMethods1() {
        Plan__c plan = new Plan__c();
        plan.Name = 'Test Plan record';
        insert plan;
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(Plan);
        PlanView dv = new PlanView(sc);
        dv.objectNameLabelMap = new Map<String,String>(); 
        
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
        
          Relations__c rel1 = new Relations__c();
          rel1.Child_Id__c = sol.Id;
          rel1.Child_Record_Name__c = sol.SolutionName;
          rel1.Child_Object_Name__c = 'Decision';
          rel1.Parent_Id__c = Plan.Id;
          rel1.Parent_Record_Name__c = a.name;
          rel1.Parent_Object_Name__c = 'Plan';
          rel1.Type__c = 'Item';
          insert rel1;  
        dv.srchRelationship =  new List<Relations__c> (); 
        dv.srchRelationshipSet =  new set<Relations__c> (); 
        dv.srchRelationship.add(rel1);
        dv.srchRelationshipSet.add(rel1);
        ApexPages.currentPage().getParameters().put('chooseObject','Solution');
        ApexPages.currentPage().getParameters().put('searchText','Test*');
        dv.searchItems();
        
        ApexPages.currentPage().getParameters().put('chooseObject','Case');
        ApexPages.currentPage().getParameters().put('searchText','*');
        dv.searchItems();
        
        ApexPages.currentPage().getParameters().put('chooseObject','Contract');
        ApexPages.currentPage().getParameters().put('searchText','*');
        dv.searchItems();
        
        ApexPages.currentPage().getParameters().put('chooseObject','Idea');
        ApexPages.currentPage().getParameters().put('searchText','Test*');
        dv.searchItems();
        dv.addFromSrch();
        dv.cancelRelation();
        Planview.AttachmentNote an = new PlanView.AttachmentNote();
    }
    
    // item View Details method to cover different if statements by changing the social input .
    static testMethod void itemViewDetailsCase1(){
          Profile pf = [Select Id from Profile where Name = 'System Administrator'];
          User u = new User(FirstName = 'Test',LastName = 'User',Email = 'testuser@test123456789.com',CompanyName = 'test.com',Title = 'Test User',Username = 'testuser15@test123456789.com',Alias = 'testuser',CommunityNickname = 'Test User',TimeZoneSidKey = 'America/Mexico_City',LocaleSidKey = 'en_US',EmailEncodingKey = 'ISO-8859-1',ProfileId = pf.Id,LanguageLocaleKey = 'en_US');
          insert u;
          
          System.runAs(u){
          Plan__c plan = new Plan__c();
          plan.Name = 'test records';
          insert plan;
          
          Relations__c rel1 = new Relations__c();
          rel1.Child_Id__c = plan.Id;
          rel1.Child_Record_Name__c = plan.Name;
          rel1.Child_Object_Name__c = 'Decision';
          rel1.Parent_Id__c = Plan.Id;
          rel1.Parent_Record_Name__c = Plan.name;
          rel1.Parent_Object_Name__c = 'Plan';
          rel1.Type__c = 'Item';
          insert rel1;
            
          //Social_Input__c raciListC1 = new Social_Input__c(Final_Approval_Status__c ='Pending Approval',Accountable__c=true,Decision__c=decision.id);
          Social_Input__c raciListC1 = new Social_Input__c(Stance_Approval_Status__c='Pending Approval',Final_Approval_Status__c ='Pending Approval',Accountable__c=true,Plan__c=plan.id);
          insert raciListC1;
         
          ApexPages.currentPage().getParameters().put('ID',plan.Id);
          ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(plan);
          
          
          PlanView planV = new PlanView(sc);
          planV.itemViewDetails();
          //PlanView.itemView1(plan.id);
          }
        
    }
    
    // item View Details method to cover different if statements by changing the social input .
    static testMethod void itemViewDetailsCase2(){
            // TO DO: implement unit test
            
           // TO DO: implement unit test
            Profile pf = [Select Id from Profile where Name = 'System Administrator'];
            User u = new User();
            u.FirstName = 'Test';
            u.LastName = 'User';
            u.Email = 'testuser@test123456789.com';
            u.CompanyName = 'test.com';
            u.Title = 'Test User';
            u.Username = 'testuser15@test123456789.com';
            u.Alias = 'testuser';
            u.CommunityNickname = 'Test User';
            u.TimeZoneSidKey = 'America/Mexico_City';
            u.LocaleSidKey = 'en_US';
            u.EmailEncodingKey = 'ISO-8859-1';
            u.ProfileId = pf.Id;
            u.LanguageLocaleKey = 'en_US';
            
            insert u;  
          Plan__c plan = new Plan__c();
          plan.Name = 'test records';
          insert plan;
          
          Note note = new Note();
          note.Title = 'decision note';
          note.Body = 'Test class ';
          note.ParentId = Plan.Id;
          insert note;
          
          Group g;
          GroupMember gm;
          system.runas(u){
              g = new Group();
              g.name = 'NewGroup';
              insert g;
              
              gm = new  GroupMember();
              gm.groupId = g.Id;
              gm.UserOrGroupId = UserInfo.getUserId();
              insert gm;
          }
          
          Relations__c rel1 = new Relations__c();
          rel1.Child_Id__c = plan.Id;
          rel1.Child_Record_Name__c = plan.Name;
          rel1.Child_Object_Name__c = 'Decision';
          rel1.Parent_Id__c = Plan.Id;
          rel1.Parent_Record_Name__c = Plan.name;
          rel1.Parent_Object_Name__c = 'Plan';
          rel1.Type__c = 'Item';
          insert rel1;
            
          //Social_Input__c raciListC2 = new Social_Input__c(Final_Approval_Status__c ='Approved',Accountable__c=true,Decision__c=decision.id);
          Social_Input__c raciListC2 = new Social_Input__c(Stance_Approval_Status__c='Approved',Final_Approval_Status__c ='Approved',Accountable__c=true,Plan__c=plan.id);
          insert raciListC2; 
          ApexPages.currentPage().getParameters().put('ID',plan.Id);
          ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(plan);
         
          PlanView planV = new PlanView(sc);
          planV.itemViewDetails();
          //PlanView.itemView1(plan.id);
        
    }
    
    // item View Details method to cover different if statements by changing the social input .
    static testMethod void itemViewDetailsCase3(){
            // TO DO: implement unit test
            
           // TO DO: implement unit test
            Profile pf = [Select Id from Profile where Name = 'System Administrator'];
            User u = new User();
            u.FirstName = 'Test';
            u.LastName = 'User';
            u.Email = 'testuser@test123456789.com';
            u.CompanyName = 'test.com';
            u.Title = 'Test User';
            u.Username = 'testuser15@test123456789.com';
            u.Alias = 'testuser';
            u.CommunityNickname = 'Test User';
            u.TimeZoneSidKey = 'America/Mexico_City';
            u.LocaleSidKey = 'en_US';
            u.EmailEncodingKey = 'ISO-8859-1';
            u.ProfileId = pf.Id;
            u.LanguageLocaleKey = 'en_US';
            
            insert u; 
          Plan__c plan = new Plan__c();
          plan.Name = 'test records';
          insert plan;
          
          Note note = new Note();
          note.Title = 'decision note';
          note.Body = 'Test class ';
          note.ParentId = Plan.Id;
          insert note;
          
          Group g;
          GroupMember gm;
          system.runas(u){
          g = new Group();
          g.name = 'NewGroup';
          insert g;
          
          gm = new  GroupMember();
          gm.groupId = g.Id;
          gm.UserOrGroupId = UserInfo.getUserId();
          insert gm;
          }
          
          Relations__c rel1 = new Relations__c();
          rel1.Child_Id__c = plan.Id;
          rel1.Child_Record_Name__c = plan.Name;
          rel1.Child_Object_Name__c = 'Decision';
          rel1.Parent_Id__c = Plan.Id;
          rel1.Parent_Record_Name__c = Plan.name;
          rel1.Parent_Object_Name__c = 'Plan';
          rel1.Type__c = 'Item';
          insert rel1;
            
          // Social_Input__c raciListC2 = new Social_Input__c(Final_Approval_Status__c ='Rejected',Accountable__c=true,Decision__c=decision.id);
          Social_Input__c raciListC2 = new Social_Input__c(Stance_Approval_Status__c='Rejected',Final_Approval_Status__c ='Rejected',Accountable__c=true,Plan__c=plan.id);
          insert raciListC2; 
          ApexPages.currentPage().getParameters().put('ID',plan.Id);
          ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(plan);
         
          PlanView planV = new PlanView(sc);
          planV.itemViewDetails();
          //PlanView.itemView1(plan.id);
        
    }
     // item View Details method to cover different if statements by changing the social input .
    // Removed the permission for record, made the veto checkbox true. 
    static testMethod void itemViewDetailsCase4(){
            // TO DO: implement unit test
            
           // TO DO: implement unit test
            Profile pf = [Select Id from Profile where Name = 'System Administrator'];
            User u = new User();
            u.FirstName = 'Test';
            u.LastName = 'User';
            u.Email = 'testuser@test123456789.com';
            u.CompanyName = 'test.com';
            u.Title = 'Test User';
            u.Username = 'testuser15@test123456789.com';
            u.Alias = 'testuser';
            u.CommunityNickname = 'Test User';
            u.TimeZoneSidKey = 'America/Mexico_City';
            u.LocaleSidKey = 'en_US';
            u.EmailEncodingKey = 'ISO-8859-1';
            u.ProfileId = pf.Id;
            u.LanguageLocaleKey = 'en_US';
            
            insert u; 
          Plan__c plan = new Plan__c();
          plan.Name = 'test records';
          insert plan;
          
          Note note = new Note();
          note.Title = 'decision note';
          note.Body = 'Test class ';
          note.ParentId = Plan.Id;
          insert note;
          
          Group g;
          GroupMember gm;
          system.runas(u){
          g = new Group();
          g.name = 'NewGroup';
          insert g;
          
          gm = new  GroupMember();
          gm.groupId = g.Id;
          gm.UserOrGroupId = UserInfo.getUserId();
          insert gm;
          }
          
          Relations__c rel1 = new Relations__c();
          rel1.Child_Id__c = plan.Id;
          rel1.Child_Record_Name__c = plan.Name;
          rel1.Child_Object_Name__c = 'Decision';
          rel1.Parent_Id__c = Plan.Id;
          rel1.Parent_Record_Name__c = Plan.name;
          rel1.Parent_Object_Name__c = 'Plan';
          rel1.Type__c = 'Item';
          insert rel1;
            
          // Social_Input__c raciListC2 = new Social_Input__c(Final_Approval_Status__c ='Rejected',Accountable__c=true,Decision__c=decision.id,Veto_Rights__c=true);
          Social_Input__c raciListC2 = new Social_Input__c(Stance_Approval_Status__c='Rejected',Final_Approval_Status__c ='Rejected',Accountable__c=true,Plan__c=Plan.id);
          insert raciListC2; 
          ApexPages.currentPage().getParameters().put('ID',plan.Id);
          ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(plan);
         
          PlanView planV = new PlanView(sc);
          // Record permission is not there.
          PlanView.chkRecPermission =false;
          planV.itemViewDetails();
          //PlanView.itemView1(plan.id);
        
    }
    
     // item View Details method to cover different if statements by changing the social input .
    // Removed the permission for record, made the veto checkbox true and relation record is not Decision record. 
    // 
    static testMethod void itemViewDetailsCase5(){
            // TO DO: implement unit test
            
           // TO DO: implement unit test
            Profile pf = [Select Id from Profile where Name = 'System Administrator'];
            User u = new User();
            u.FirstName = 'Test';
            u.LastName = 'User';
            u.Email = 'testuser@test123456789.com';
            u.CompanyName = 'test.com';
            u.Title = 'Test User';
            u.Username = 'testuser15@test123456789.com';
            u.Alias = 'testuser';
            u.CommunityNickname = 'Test User';
            u.TimeZoneSidKey = 'America/Mexico_City';
            u.LocaleSidKey = 'en_US';
            u.EmailEncodingKey = 'ISO-8859-1';
            u.ProfileId = pf.Id;
            u.LanguageLocaleKey = 'en_US';
            
            insert u; 
          Plan__c plan = new Plan__c();
          plan.Name = 'test records';
          insert plan;
          
          Note note = new Note();
          note.Title = 'decision note';
          note.Body = 'Test class ';
          note.ParentId = Plan.Id;
          insert note;
          
            Group g;
          GroupMember gm;
          system.runas(u){
          g = new Group();
          g.name = 'NewGroup';
          insert g;
          
          gm = new  GroupMember();
          gm.groupId = g.Id;
          gm.UserOrGroupId = UserInfo.getUserId();
          insert gm;
          }
          
          Relations__c rel1 = new Relations__c();
          rel1.Child_Id__c = plan.Id;
          rel1.Child_Record_Name__c = plan.Name;
          rel1.Child_Object_Name__c = 'Decision1';
          rel1.Parent_Id__c = Plan.Id;
          rel1.Parent_Record_Name__c = Plan.name;
          rel1.Parent_Object_Name__c = 'Plan';
          rel1.Type__c = 'Item';
          rel1.Days__c = '4';
          rel1.Minutes__c='125';
          rel1.Hours__c='28';
          insert rel1;
            
          // Social_Input__c raciListC2 = new Social_Input__c(Final_Approval_Status__c ='Rejected',Accountable__c=true,Decision__c=decision.id,Veto_Rights__c=true);
          Social_Input__c raciListC2 = new Social_Input__c(Stance_Approval_Status__c='Rejected',Final_Approval_Status__c ='Rejected',Accountable__c=true,Plan__c=plan.id);
          insert raciListC2; 
          ApexPages.currentPage().getParameters().put('ID',plan.Id);
          ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(plan);
         
          PlanView planV = new PlanView(sc);
          // Record permission is not there.
          PlanView.chkRecPermission =false;
          planV.itemViewDetails();
          PlanView.itemView1(plan.id);
        
    }    
    
    //viewPeopleTabWithSearch
    // when search text is null;
    static testMethod void testViewPeopleTabWithSearch(){
            Plan__c plan = new Plan__c();
            plan.Name = 'test records';
            insert plan;
            
            ApexPages.currentPage().getParameters().put('ID',plan.Id);
            ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(plan);
             
            PlanView planV = new PlanView(sc);
    
            PlanView.viewPeopleTabWithSearch(plan.id, null,'Test');
    }
    // to cover itemitemView1 
    static testMethod void testitemView1(){
            // TO DO: implement unit test
          
          Profile pf = [Select Id from Profile where Name = 'System Administrator'];
          User u = new User(FirstName = 'Test',LastName = 'User',Email = 'testuser@test123456789.com',CompanyName = 'test.com',Title = 'Test User',Username = 'testuser15@test123456789.com',Alias = 'testuser',CommunityNickname = 'Test User',TimeZoneSidKey = 'America/Mexico_City',LocaleSidKey = 'en_US',EmailEncodingKey = 'ISO-8859-1',ProfileId = pf.Id,LanguageLocaleKey = 'en_US');
          insert u;
          
          System.runAs(u){
          Plan__c plan = new Plan__c();
          plan.Name = 'test records';
          insert plan;
          
          Note note = new Note();
          note.Title = 'decision note';
          note.Body = 'Test class ';
          note.ParentId = Plan.Id;
          insert note;
          
          Group g = new Group();
          g.name = 'NewGroup';
          insert g;
          
          GroupMember gm = new  GroupMember();
          gm.groupId = g.Id;
          gm.UserOrGroupId = u.Id;
          insert gm;
          
          Relations__c rel1 = new Relations__c();
          rel1.Child_Id__c = plan.Id;
          rel1.Child_Record_Name__c = Plan.name;
          rel1.Child_Object_Name__c = 'Decision';
          rel1.Parent_Id__c = Plan.Id;
          rel1.Parent_Record_Name__c = Plan.name;
          rel1.Parent_Object_Name__c = 'Plan';
          rel1.Type__c = 'Item';
          insert rel1;
            
          // Social_Input__c raciListC2 = new Social_Input__c(Final_Approval_Status__c ='Rejected',Accountable__c=true,Decision__c=decision.id);
          Social_Input__c raciListC2 = new Social_Input__c(Stance_Approval_Status__c='Rejected',Final_Approval_Status__c ='Rejected',Accountable__c=true,Plan__c=plan.id);
          insert raciListC2; 
          ApexPages.currentPage().getParameters().put('ID',plan.Id);
          ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(plan);
         
          PlanView planV = new PlanView(sc);
          //planV.itemViewDetails();
          PlanView.itemView1(plan.id);
        }
        
    }
    

         
}