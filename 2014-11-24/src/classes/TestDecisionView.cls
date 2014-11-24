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
@isTest(seealldata = true)
private class TestDecisionView {

    static testMethod void decisionStandardObject() {
        // TO DO: implement unit test
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
        /*User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = 'testuser@test123456789.com';
        u.CompanyName = 'test.com';
        u.Title = 'Test User';
        u.Username = 'testuser12@test123456789.com';
        u.Alias = 'testuser';
        u.CommunityNickname = 'Test User';
        u.TimeZoneSidKey = 'America/Mexico_City';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = pf.Id;
        u.LanguageLocaleKey = 'en_US';
        
        //insert u; */
        
        User u = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' and isActive = true limit 1];
        
        System.runAs(u){
            
            Decision__c decision = new Decision__c();
            decision.Title__c = 'Decision test class';
            decision.Decision_Taken__c = 'Test decision';
            decision.Problem_Idea_Advice__c = 'decision problem stateent ';
            decision.Due_Date__c = Datetime.now();
            decision.Phase__c = 'Draft';
            decision.Priority__c = 'High';
            decision.Private__c = true;
            insert decision;
            
            
            Social_Input__c socialInput = new Social_Input__c();
            socialInput.Decision__c = decision.Id;
            socialInput.Responsible__c = true;
            socialInput.User__c = UserInfo.getUserId();
            insert socialInput;
                        
            ApexPages.currentPage().getParameters().put('ID',decision.Id);
            ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(decision);
            
            DecisionView decisionsV = new DecisionView(sc);
            DecisionView.socialCommand(String.ValueOf(socialInput.Id), 'Mood', '3');
            DecisionView.socialCommand(String.ValueOf(socialInput.Id), 'Rating', '3');
            
            
            
        }
    }
    
    static testMethod void decisionStandardObjectAction() {
        // TO DO: implement unit test
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
        /*User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = 'testuser@test123456789.com';
        u.CompanyName = 'test.com';
        u.Title = 'Test User';
        u.Username = 'testuser12@test123456789.com';
        u.Alias = 'testuser';
        u.CommunityNickname = 'Test User';
        u.TimeZoneSidKey = 'America/Mexico_City';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = pf.Id;
        u.LanguageLocaleKey = 'en_US';
        
        //insert u; */
        
        User u = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' and isActive = true limit 1];
        
        System.runAs(u){
            
            Decision__c decision = new Decision__c();
            decision.Title__c = 'Decision test class';
            decision.Decision_Taken__c = 'Test decision';
            decision.Problem_Idea_Advice__c = 'decision problem stateent ';
            decision.Due_Date__c = Datetime.now();
            decision.Phase__c = 'Draft';
            decision.Priority__c = 'High';
            decision.Private__c = true;
            insert decision;
            

            /*Attachment att = new Attachment();
            String attchmentBody = 'test class coverage';
            att.Body = Blob.valueOf(attchmentBody);
            att.Name = 'Attached data on decision ';
            att.parentId = decision.Id;
            insert att;
            
            Note note = new Note();
            note.Title = 'decision note';
            note.Body = 'Test class ';
            note.ParentId = decision.Id;
            insert note;*/

            
            Task task = new Task();
            task.WhatId = decision.Id;
            task.Subject = 'Task on decision';
            task.ActivityDate = Date.today();
            task.Status = 'Completed';
            insert task; 
            
            /*Task taskCompleted = new Task();
            taskCompleted.WhatId = decision.Id;
            taskCompleted.Subject = 'Completed Task on decision';
            taskCompleted.ActivityDate = Date.today();
            taskCompleted.Status = 'Completed';
            insert taskCompleted;*/           
            
            
            Event event = new Event();
            event.WhatId = decision.Id;
            event.Subject = 'Event on decision ';
            event.ActivityDate = Date.today().addDays(-2);
            event.ActivityDateTime = Datetime.now();
            event.DurationInMinutes = 50;
            insert event;
            
            
                
            ApexPages.currentPage().getParameters().put('ID',decision.Id);
            ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(decision);
            
            String result;
            DecisionView.viewHistory(String.Valueof(decision.Id));
            //DecisionView.deleteNotesAttachments(String.Valueof(decision.Id),String.Valueof(att.Id),'Attachment');
            //DecisionView.deleteNotesAttachments(String.Valueof(decision.Id),String.Valueof(note.Id),'Note');
            DecisionView.activitiesTab(String.Valueof(decision.Id),'');
            DecisionView.activitiesTab(String.Valueof(decision.Id),String.Valueof(task.Id));
            DecisionView.activitiesTab(String.Valueof(decision.Id),String.Valueof(event.Id));
            DecisionView.saveMatrixDataTab(String.Valueof(decision.Id),'test');
            delete decision;
        }
    }
    
    // Test class to cover the code when activities batch updated.
    static testMethod void decisionActivitiesUpdate() {
        
        Decision__c decision = new Decision__c();
        decision.Title__c = 'Decision test class';
        decision.Decision_Taken__c = 'Test decision';
        decision.Problem_Idea_Advice__c = 'decision problem stateent ';
        decision.Due_Date__c = Datetime.now();
        decision.Phase__c = 'Draft';
        decision.Priority__c = 'High';
        decision.Private__c = true;
        insert decision;
            
        Task task = new Task();
        task.WhatId = decision.Id;
        task.Subject = 'Task on decision';
        task.ActivityDate = Date.today();
        task.Status = 'Completed';
        insert task; 
        
        Account a = new Account();
        a.Name = 'test';
        insert a;
        
        Event event = new Event();
        event.WhatId = decision.Id;
        event.Subject = 'Event on decision ';
        event.ActivityDate = Date.today().addDays(-2);
        event.StartDateTime = Datetime.now();
        event.DurationInMinutes = 50;
        insert event;
        
        ApexPages.currentPage().getParameters().put('ID',decision.Id);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(decision);
        
        String modifiedCode = '{"data":{"models":[{"url":"/00TN00000032BIzMAM?retURL=a06N0000000xNl1IAE","subjectClassLink":"","subjectClass":"hide-subject","subject":"Test1","statusImage":"resource/1372409819000/Images/common/icon-notStarted-16x16.png","status":"Not Started","roleAcceptanceStatus":"Approved/Accepted","recordNumber":1,"priority":"Normal","ownerId":"'+userinfo.getuserId()+'","isTaskImage":"resource/1372409819000/Images/common/icon-checked-16x16.png","duedateSort":"2013-08-25T18:30:00.000Z","isTask":"Task","isEditable":true,"isDeletable":true,"id":"'+task.Id+'","editImage":"resource/1372409819000/Images/common/icon-edit-16x16.png","duedate":"2013-08-25T18:30:00.000Z","deleteImage":"resource/1372409819000/Images/common/icon-delete-16x16.png","delayTaskClass":"","createdByName":"Kiran Kumar","createdByImage":"https://c.cs6.content.force.com/profilephoto/005/T","commentsImage":"resource/1372409819000/Images/common/icon-null-16x16.png","comments":null,"actionClassNameEdit":"","actionClassNameDelete":""},{"url":"/00UN0000001ShtpMAC?retURL=a06N0000000xNl1IAE","subjectClassLink":"","subjectClass":"hide-subject","subject":"Test2","statusImage":"resource/1372409819000/Images/common/icon-null-16x16.png","status":"","roleAcceptanceStatus":null,"recordNumber":2,"priority":"","ownerId":"'+userinfo.getuserId()+'","isTaskImage":"resource/1372409819000/Images/common/icon-unchecked-16x16.png","isTask":"Event","isEditable":true,"isDeletable":true,"id":"'+event.Id+'","duedateSort":"2013-08-25T18:30:00.000Z","editImage":"resource/1372409819000/Images/common/icon-edit-16x16.png","duedate":"2013-08-25T18:30:00.000Z","deleteImage":"resource/1372409819000/Images/common/icon-delete-16x16.png","delayTaskClass":null,"createdByName":"Kiran Kumar","createdByImage":"https://c.cs6.content.force.com/profilephoto/005/T","commentsImage":"resource/1372409819000/Images/common/icon-null-16x16.png","comments":"","actionClassNameEdit":"","actionClassNameDelete":""}]}}';
        DecisionView.updateActivitesTab(modifiedCode,'test*',decision.Id);
        DecisionView.activitiesTabWithSearch(decision.Id,task.Id,'test*');
        DecisionView.activitiesTabWithSearch(decision.Id,event.Id,'test*');
        DecisionView.decisionCopy(decision.Id,true,true,true,true,true,true,'Child',true);
    }
    
     static testMethod void decisionActivitiesUpdate1() {
        
        Decision__c decision = new Decision__c();
        decision.Title__c = 'Decision test class';
        decision.Decision_Taken__c = 'Test decision';
        decision.Problem_Idea_Advice__c = 'decision problem stateent ';
        decision.Due_Date__c = Datetime.now();
        decision.Phase__c = 'Draft';
        decision.Priority__c = 'High';
        decision.Private__c = true;
        insert decision;
            
        Task task = new Task();
        task.WhatId = decision.Id;
        task.Subject = 'Task on decision';
        task.ActivityDate = Date.today();
        task.Status = 'Completed';
        insert task; 
        
        Account a = new Account();
        a.Name = 'test';
        insert a;
        
        Event event = new Event();
        event.WhatId = decision.Id;
        event.Subject = 'Event on decision ';
        event.ActivityDate = Date.today().addDays(-2);
        event.StartDateTime = Datetime.now(); 
        event.DurationInMinutes = 50;
        insert event;
        
        DecisionQuickCreate.decisionCopy('Account',a.Id,decision.Id,true,true,true,true,true,true,'Child',true);
    }
    
    static testMethod void decisionSocialAction() {
        // TO DO: implement unit test
        /*User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = 'testuser@test123456789.com';
        u.CompanyName = 'test.com'; 
        u.Title = 'Test User';
        u.Username = 'testuser12@test123456789.com';
        u.Alias = 'testuser';
        u.CommunityNickname = 'Test User';
        u.TimeZoneSidKey = 'America/Mexico_City';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = pf.Id;
        u.LanguageLocaleKey = 'en_US';
        
        //insert u; */
        
        User u = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' and isActive = true limit 1];
        
        System.runAs(u){
            
            Decision__c decision = new Decision__c();
            decision.Title__c = 'Decision test class';
            decision.Decision_Taken__c = 'Test decision';
            decision.Problem_Idea_Advice__c = 'decision problem stateent ';
            decision.Due_Date__c = Datetime.now();
            decision.Phase__c = 'Close';
            decision.Priority__c = 'High';
            decision.Private__c = true;
            insert decision;
            
            ApexPages.currentPage().getParameters().put('ID',decision.Id);
            ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(decision);
            
            Social_Input__c socialInput = new Social_Input__c();
            socialInput.Decision__c = decision.Id;
            socialInput.Responsible__c = true;
            socialInput.User__c = UserInfo.getUserId();
            socialInput.Backup_for_Accountable__c = true;
            socialInput.Accountable__c = false;
            insert socialInput;
            
            socialInput.Final_Approval_Status__c = 'Approved';          
            update socialInput;
            
            DecisionView.socialCommand(String.ValueOf(socialInput.Id), 'Like', '1');
            DecisionView.socialCommand(String.ValueOf(socialInput.Id), 'Dislike', '1');
            
            //DecisionView.socialCommand(String.ValueOf(socialInput.Id), 'Result', '1');
            //DecisionView.socialCommand(String.ValueOf(socialInput.Id), 'Effort', '1');
            
            DecisionView.kendoScatter(String.ValueOf(decision.Id));
            
            Outcome outCome = new Outcome();
            
                        
        }
    }
    
    static testMethod void decisionSocialAction1() {
        // TO DO: implement unit test
            
            Decision__c decision = new Decision__c();
            decision.Title__c = 'Decision test class';
            decision.Decision_Taken__c = 'Test decision';
            decision.Problem_Idea_Advice__c = 'decision problem stateent ';
            decision.Due_Date__c = Datetime.now();
            decision.Phase__c = 'Close';
            decision.Priority__c = 'High';
            decision.Private__c = true;
            insert decision;
            
            ApexPages.currentPage().getParameters().put('ID',decision.Id);
            ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(decision);
            
            Social_Input__c socialInput = new Social_Input__c();
            socialInput.Decision__c = decision.Id;
            socialInput.Responsible__c = true;
            socialInput.User__c = UserInfo.getUserId();
            socialInput.Backup_for_Accountable__c = true;
            socialInput.Accountable__c = false;
            insert socialInput;
            
            socialInput.Final_Approval_Status__c = 'Approved';          
            update socialInput;
            
            //DecisionView.socialCommand(String.ValueOf(socialInput.Id), 'Like', '1');
            //DecisionView.socialCommand(String.ValueOf(socialInput.Id), 'Dislike', '1');
            
            DecisionView.socialCommand(String.ValueOf(socialInput.Id), 'Result', '1');
            DecisionView.socialCommand(String.ValueOf(socialInput.Id), 'Effort', '1');
            
            DecisionView.kendoScatter(String.ValueOf(decision.Id));
            
            Outcome outCome = new Outcome();
            
                        
    }
    
    static testMethod void decisionCustomObjectAction() {
        // TO DO: implement unit test
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
            
            Decision__c decisionTag = new Decision__c();
            decisionTag.Title__c = 'Decision test class';
            decisionTag.Decision_Taken__c = 'Test decision';
            decisionTag.Problem_Idea_Advice__c = 'decision problem stateent ';
            decisionTag.Due_Date__c = Datetime.now();
            decisionTag.Phase__c = 'Draft';
            decisionTag.Priority__c = 'High';
            decisionTag.Private__c = true;
            insert decisionTag;
            
            
           

            
            
            
            ApexPages.currentPage().getParameters().put('ID',decision.Id);
            ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(decision);
            
            
          
            DecisionView.insertTag(String.ValueOf(decision.Id),'#ft, #fingerTip');
            DecisionView.insertTag(String.ValueOf(decision.Id),'#ftTest');
            DecisionView.insertTag(String.ValueOf(decision.Id),'#ft');
            DecisionView.insertTag(String.ValueOf(decisionTag.Id),'#KVP');
    }
    
    static testMethod void decisionClone() {
        // TO DO: implement unit test
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
        
            
            /*Decision__c decisionTag = new Decision__c();
            decisionTag.Title__c = 'Decision test class';
            decisionTag.Decision_Taken__c = 'Test decision';
            decisionTag.Problem_Idea_Advice__c = 'decision problem stateent ';
            decisionTag.Due_Date__c = Datetime.now();
            decisionTag.Phase__c = 'Draft';
            decisionTag.Priority__c = 'High';
            decisionTag.Private__c = true;
            decisionTag.Plain_Tag__c = '';
            insert decisionTag;*/
            
            
            Social_Input__c socialInput = new Social_Input__c();
            socialInput.Decision__c = decision.Id;
            socialInput.Responsible__c = true;
            socialInput.User__c = UserInfo.getUserId();
            insert socialInput;
            
            Task taskCompleted = new Task();
            taskCompleted.WhatId = decision.Id;
            taskCompleted.Subject = 'Completed Task on decision';
            taskCompleted.ActivityDate = Date.today();
            taskCompleted.Status = 'Completed';
            insert taskCompleted;           
            
            
            Relations__c relation = new Relations__c();
            //relation.Child_Id__c = decisionTag.Id;
            //relation.Child_Record_Name__c = decisionTag.Title__c;
            relation.Child_Object_Name__c = 'Decision';
            relation.Parent_Id__c = decision.Id;
            relation.Parent_Record_Name__c = decision.Title__c;
            relation.Parent_Object_Name__c = 'Decision';
            relation.Type__c = 'Relation';
            insert relation;
        
            /*Relations__c relationTag = new Relations__c();
            relationTag.Child_Id__c = decision.Id;
            relationTag.Child_Record_Name__c = decision.Title__c;
            relationTag.Child_Object_Name__c = 'Decision';
            relationTag.Parent_Id__c = decisionTag.Id;
            relationTag.Parent_Record_Name__c = decisionTag.Title__c;
            relationTag.Parent_Object_Name__c = 'Decision';
            relationTag.Type__c = 'Relation';
            insert relationTag;*/
            
            
            DecisionView.decisionClone(String.valueOf(decision.Id),true, true, true, true, true,'Test ');
            DecisionView.decisionClone1(String.valueOf(decision.Id),true, true, true, true, true, true,'Test ');
            
            
            decision.Title__c = 'Decision title changed';
            update decision;
                
    }
    
    static testMethod void decisionClone1() {
        // TO DO: implement unit test
            
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
        
            
            Decision__c decisionTag = new Decision__c();
            decisionTag.Title__c = 'Decision test class';
            decisionTag.Decision_Taken__c = 'Test decision';
            decisionTag.Problem_Idea_Advice__c = 'decision problem stateent ';
            decisionTag.Due_Date__c = Datetime.now();
            decisionTag.Phase__c = 'Draft';
            decisionTag.Priority__c = 'High';
            decisionTag.Private__c = true;
            decisionTag.Plain_Tag__c = '';
            insert decisionTag;
            
            
            /*Social_Input__c socialInput = new Social_Input__c();
            socialInput.Decision__c = decision.Id;
            socialInput.Responsible__c = true;
            socialInput.User__c = usr.Id;
            insert socialInput;
            
            Task taskCompleted = new Task();
            taskCompleted.WhatId = decision.Id;
            taskCompleted.Subject = 'Completed Task on decision';
            taskCompleted.ActivityDate = Date.today();
            taskCompleted.Status = 'Completed';
            insert taskCompleted;  */         
            
            
            Relations__c relation = new Relations__c();
            relation.Child_Id__c = decisionTag.Id;
            relation.Child_Record_Name__c = decisionTag.Title__c;
            relation.Child_Object_Name__c = 'Decision';
            relation.Parent_Id__c = decision.Id;
            relation.Parent_Record_Name__c = decision.Title__c;
            relation.Parent_Object_Name__c = 'Decision';
            relation.Type__c = 'Relation';
            insert relation;
        
            Relations__c relationTag = new Relations__c();
            relationTag.Child_Id__c = decision.Id;
            relationTag.Child_Record_Name__c = decision.Title__c;
            relationTag.Child_Object_Name__c = 'Decision';
            relationTag.Parent_Id__c = decisionTag.Id;
            relationTag.Parent_Record_Name__c = decisionTag.Title__c;
            relationTag.Parent_Object_Name__c = 'Decision';
            relationTag.Type__c = 'Relation';
            insert relationTag;
            
            
            DecisionView.decisionClone(String.valueOf(decision.Id),true, true, true, true, true,'Test ');
            DecisionView.decisionClone1(String.valueOf(decision.Id),true, true, true, true, true, true,'Test ');
            
            
            decision.Title__c = 'Decision title changed';
            update decision;
                
    }
    
    static testMethod void decisionTabUpdate() {
        // TO DO: implement unit test
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
        
        /*User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = 'testuser@test123456789.com';
        u.CompanyName = 'test.com';
        u.Title = 'Test User';
        u.Username = 'testuser12@test123456789.com';
        u.Alias = 'testuser';
        u.CommunityNickname = 'Test User';
        u.TimeZoneSidKey = 'America/Mexico_City';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = pf.Id;
        u.LanguageLocaleKey = 'en_US';
        
        //insert u; */
        
        User usr = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' and isActive = true limit 1];
        
        /*User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = 'testuser@test123456789.com';
        u.CompanyName = 'test.com';
        u.Title = 'Test User';
        u.Username = 'testuser10@test123456789.com';
        u.Alias = 'testuser';
        u.CommunityNickname = 'ft user';
        u.TimeZoneSidKey = 'America/Mexico_City';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = pf.Id;
        u.LanguageLocaleKey = 'en_US';
        
        insert u;*/
        
        System.runAs(usr){
            
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
            
            Social_Input__c socialInput = new Social_Input__c();
            socialInput.Decision__c = decision.Id;
            socialInput.Responsible__c = true;
            socialInput.User__c = usr.Id;
            insert socialInput;
            
            DecisionView.tabSectionClicked(String.valueOf(socialInput.Id), 'people-tab');
            DecisionView.tabSectionClicked(String.valueOf(socialInput.Id), 'task-tab');
            /*DecisionView.tabSectionClicked(String.valueOf(socialInput.Id), 'activities-tab');
            DecisionView.tabSectionClicked(String.valueOf(socialInput.Id), 'relation-tab');
            DecisionView.tabSectionClicked(String.valueOf(socialInput.Id), 'attachment-tab');
            DecisionView.tabSectionClicked(String.valueOf(socialInput.Id), 'history-tab');
            DecisionView.tabSectionClicked(String.valueOf(socialInput.Id), 'quality-tab'); */
            
            Timing__c timing = [Select t.Id, t.Actual_End_Date__c, t.Actual_Start_Date__c, t.Start_Date_Time__c, t.Stage__c, t.Related_To_ID__c, t.End_Date_Time__c, t.Elapsed_Time__c, t.Difference__c, t.Comments__c From Timing__c t where t.Related_To_ID__c = : decision.Id and t.Stage__c = 'Decide' limit 1];
            
            DecisionView.upateTimingTab(String.valueOf(timing.Id), '2013,01,01,01,01,01' ,'2013,02,01,01,01,01', 'update timing ');
            DecisionView.upateTimingTab(String.valueOf(timing.Id), null, null, 'update timing ');   
            
            
        }
    }
    
    static testMethod void decisionTabUpdate1(){
        
        // TO DO: implement unit test
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
        
        /*User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = 'testuser@test123456789.com';
        u.CompanyName = 'test.com';
        u.Title = 'Test User';
        u.Username = 'testuser12@test123456789.com';
        u.Alias = 'testuser';
        u.CommunityNickname = 'Test User';
        u.TimeZoneSidKey = 'America/Mexico_City';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = pf.Id;
        u.LanguageLocaleKey = 'en_US';
        
        //insert u; */
        
        User usr = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' and isActive = true limit 1];
        
        System.runAs(usr){
            
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
            
            Social_Input__c socialInput = new Social_Input__c();
            socialInput.Decision__c = decision.Id;
            socialInput.Responsible__c = true;
            socialInput.User__c = usr.Id;
            insert socialInput;
            
            //DecisionView.tabSectionClicked(String.valueOf(socialInput.Id), 'people-tab');
            //DecisionView.tabSectionClicked(String.valueOf(socialInput.Id), 'task-tab');
            DecisionView.tabSectionClicked(String.valueOf(socialInput.Id), 'activities-tab');
            DecisionView.tabSectionClicked(String.valueOf(socialInput.Id), 'relation-tab');
            DecisionView.tabSectionClicked(String.valueOf(socialInput.Id), 'attachment-tab');
            DecisionView.tabSectionClicked(String.valueOf(socialInput.Id), 'history-tab');
            DecisionView.tabSectionClicked(String.valueOf(socialInput.Id), 'quality-tab');
            
            //Timing__c timing = [Select t.Id, t.Actual_End_Date__c, t.Actual_Start_Date__c, t.Start_Date_Time__c, t.Stage__c, t.Related_To_ID__c, t.End_Date_Time__c, t.Elapsed_Time__c, t.Difference__c, t.Comments__c From Timing__c t where t.Related_To_ID__c = : decision.Id and t.Stage__c = 'Decide' limit 1];
            
            //DecisionView.upateTimingTab(String.valueOf(timing.Id), '2013,01,01,01,01,01' ,'2013,02,01,01,01,01', 'update timing ');
            //DecisionView.upateTimingTab(String.valueOf(timing.Id), null, null, 'update timing ');   
            
            
        }
    
    }
    
    static testMethod void decisionPhaseShareUpdate() {
        // TO DO: implement unit test
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
    
        /*User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = 'testuser@test123456789.com';
        u.CompanyName = 'test.com';
        u.Title = 'Test User';
        u.Username = 'testuser12@test123456789.com';
        u.Alias = 'testuser';
        u.CommunityNickname = 'Test User';
        u.TimeZoneSidKey = 'America/Mexico_City';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = pf.Id;
        u.LanguageLocaleKey = 'en_US';
        
        //insert u; */
        
        User u = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' and isActive = true limit 1];
        
        System.runAs(u){
            
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
            
            String DecisionId3 = string.valueOf(decision.id);
       
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
                timingList65.add(time1);  
           }
           
           if(timingList65.size() > 0){
            update timingList65; 
           }
            
            Social_Input__c socialInput = [Select s.Veto_Rights__c, s.User__c, s.SystemModstamp, s.SYS_Tab_View_Activites__c, s.SYS_Tab_View_History__c, s.SYS_Tab_View_Tasks__c, s.SYS_Tab_View_Social_Input__c, s.SYS_Tab_View_Relations__c, s.SYS_Tab_View_Quality__c, s.SYS_Tab_View_Attachments__c, s.SYS_Tab_View_Approvals__c, s.Role_Acceptance_Status__c, s.Role_Acceptance_Required__c, s.Result__c, s.Responsible__c, s.Rating__c, s.Outcome__c, s.Name, s.Mood__c, s.Like__c, s.LastModifiedDate, s.LastModifiedById, s.Informed__c, s.Id, s.Final_Approval_Status__c, s.Effort__c, s.Dislike__c, s.Decision__c, s.CreatedDate, s.CreatedById, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c From Social_Input__c s where s.Decision__c =: decision.Id];
            
            DecisionView.decisionPhaseChange(String.valueOf(decision.Id), String.valueOf(socialInput.Id), 'Share', 'Test class coverage', 'Test');
            //DecisionView.decisionPhaseChangeDecide(String.valueOf(decision.Id), String.valueOf(socialInput.Id), 'Share', 'Test class coverage', 'Test');
            DecisionView.decisionPhaseChange(String.valueOf(decision.Id), String.valueOf(socialInput.Id), 'Propose', 'Test class coverage', 'Test');
        }
    }
    
    static testMethod void decisionPhaseDecideUpdate() {
        // TO DO: implement unit test
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
    
        /*User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = 'testuser@test123456789.com';
        u.CompanyName = 'test.com';
        u.Title = 'Test User';
        u.Username = 'testuser12@test123456789.com';
        u.Alias = 'testuser';
        u.CommunityNickname = 'Test User';
        u.TimeZoneSidKey = 'America/Mexico_City';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = pf.Id;
        u.LanguageLocaleKey = 'en_US';
        
        //insert u; */
        
        User u = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' and isActive = true limit 1];
        
        System.runAs(u){
            
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
            
            String DecisionId3 = string.valueOf(decision.id);
       
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
                timingList65.add(time1);  
           }
           
           if(timingList65.size() > 0){
            update timingList65; 
           }
            
            Social_Input__c socialInput = [Select s.Veto_Rights__c, s.User__c, s.SystemModstamp, s.SYS_Tab_View_Activites__c, s.SYS_Tab_View_History__c, s.SYS_Tab_View_Tasks__c, s.SYS_Tab_View_Social_Input__c, s.SYS_Tab_View_Relations__c, s.SYS_Tab_View_Quality__c, s.SYS_Tab_View_Attachments__c, s.SYS_Tab_View_Approvals__c, s.Role_Acceptance_Status__c, s.Role_Acceptance_Required__c, s.Result__c, s.Responsible__c, s.Rating__c, s.Outcome__c, s.Name, s.Mood__c, s.Like__c, s.LastModifiedDate, s.LastModifiedById, s.Informed__c, s.Id, s.Final_Approval_Status__c, s.Effort__c, s.Dislike__c, s.Decision__c, s.CreatedDate, s.CreatedById, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c From Social_Input__c s where s.Decision__c =: decision.Id];
            
            DecisionView.decisionPhaseChange(String.valueOf(decision.Id), String.valueOf(socialInput.Id), 'Decide', 'Test class coverage', 'Test');
            //DecisionView.decisionPhaseChangeDecide(String.valueOf(decision.Id), String.valueOf(socialInput.Id), 'Share', 'Test class coverage', 'Test');
        }
    }
    
    static testMethod void decisionPhaseApproveUpdate() {
        // TO DO: implement unit test
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
        
            Social_Input__c socialInput = [Select s.Veto_Rights__c, s.User__c, s.SystemModstamp, s.SYS_Tab_View_Activites__c, s.SYS_Tab_View_History__c, s.SYS_Tab_View_Tasks__c, s.SYS_Tab_View_Social_Input__c, s.SYS_Tab_View_Relations__c, s.SYS_Tab_View_Quality__c, s.SYS_Tab_View_Attachments__c, s.SYS_Tab_View_Approvals__c, s.Role_Acceptance_Status__c, s.Role_Acceptance_Required__c, s.Result__c, s.Responsible__c, s.Rating__c, s.Outcome__c, s.Name, s.Mood__c, s.Like__c, s.LastModifiedDate, s.LastModifiedById, s.Informed__c, s.Id, s.Final_Approval_Status__c, s.Effort__c, s.Dislike__c, s.Decision__c, s.CreatedDate, s.CreatedById, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c From Social_Input__c s where s.Decision__c =: decision.Id];
            
            decision.Phase__c = 'Share';
            update decision;
            
            //decision.Phase__c = 'Propose';
            //update decision;
            
            //DecisionView.approvalFromPhasesArrow(String.valueOf(decision.Id), String.valueOf(socialInput.Id));
            
            //ProcessInstanceWorkitem processInstanceWorkitem = [Select p.ProcessInstance.Status, p.ProcessInstance.TargetObjectId, p.ProcessInstanceId, p.Id, p.CreatedDate, p.CreatedBy.Name, p.CreatedById, p.Actor.Name, p.ActorId From ProcessInstanceWorkitem p where p.ActorId=: u.Id and p.ProcessInstance.TargetObjectId =: socialInput.Id];
            //DecisionView.approvedReject(String.valueOf(decision.Id), String.valueOf(processInstanceWorkitem.Id), 'Reject', 'Reject approvals');
            //DecisionView.decisionPhaseChange(String.valueOf(decision.Id), String.valueOf(socialInput.Id), 'Close', 'Test class coverage', 'Test');
    }
    
    static testMethod void decisionMethods(){
        
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
        /*User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = 'testuser@test123456789.com';
        u.CompanyName = 'test.com';
        u.Title = 'Test User';
        u.Username = 'testuser12@test123456789.com';
        u.Alias = 'testuser';
        u.CommunityNickname = 'Test User';
        u.TimeZoneSidKey = 'America/Mexico_City';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = pf.Id;
        u.LanguageLocaleKey = 'en_US';
        
        //insert u; */
        
        User u = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' limit 1];
        
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
        
        Attachment att = new Attachment();
        String attchmentBody = 'test class coverage';
        att.Body = Blob.valueOf(attchmentBody);
        att.Name = 'Attached data on decision ';
        att.parentId = decision.Id;
        insert att;
        
        Group grp = new Group();
        grp.Name = 'Test Group';
        insert grp;
        
        Social_Input__c socialInput = new Social_Input__c();
        socialInput.Decision__c = decision.Id;
        socialInput.Responsible__c = true;
        socialInput.User__c = u.Id;
        insert socialInput;
        
        DecisionView.deleteNotesAttachments(decision.Id,att.Id,'Attachment');
        DecisionView.retrieveGroupMember(grp.Id); 
        DecisionView.approvalFromPhasesArrow(decision.Id, socialInput.Id);
        DecisionView.getPlanListItem('Test');
    }
    
    static testMethod void decisionMethods1(){
        
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
        
        Plan__c p = new Plan__c();
        p.Name = 'test';
        insert p;
        
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
        
        DecisionView.attachmentNoteView(decision.Id);
        DecisionView.addSelectedPlan(p.Id+','+p.Id,decision.Id,'Test');
        decisionView.UserGroupMemberList ugml = new decisionView.UserGroupMemberList(); 
    }
    
    static testMethod void decisionPhaseExecuteUpdate() {
        // TO DO: implement unit test
        //Profile pf = [Select Id from Profile where Name = 'System Administrator'];
    
        /*User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = 'testuser@test123456789.com';
        u.CompanyName = 'test.com';
        u.Title = 'Test User';
        u.Username = 'testuser12@test123456789.com';
        u.Alias = 'testuser';
        u.CommunityNickname = 'Test User';
        u.TimeZoneSidKey = 'America/Mexico_City';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = pf.Id;
        u.LanguageLocaleKey = 'en_US';
        
        //insert u; */
        
        //User u = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' limit 1];
        
        //System.runAs(u){
            
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
            
            Social_Input__c socialInput = [Select s.Veto_Rights__c, s.User__c, s.SystemModstamp, s.SYS_Tab_View_Activites__c, s.SYS_Tab_View_History__c, s.SYS_Tab_View_Tasks__c, s.SYS_Tab_View_Social_Input__c, s.SYS_Tab_View_Relations__c, s.SYS_Tab_View_Quality__c, s.SYS_Tab_View_Attachments__c, s.SYS_Tab_View_Approvals__c, s.Role_Acceptance_Status__c, s.Role_Acceptance_Required__c, s.Result__c, s.Responsible__c, s.Rating__c, s.Outcome__c, s.Name, s.Mood__c, s.Like__c, s.LastModifiedDate, s.LastModifiedById, s.Informed__c, s.Id, s.Final_Approval_Status__c, s.Effort__c, s.Dislike__c, s.Decision__c, s.CreatedDate, s.CreatedById, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c From Social_Input__c s where s.Decision__c =: decision.Id];
            
            decision.Phase__c = 'Share';
            update decision;
            
            //decision.Phase__c = 'Decide';
            //update decision;
            
            //decision.Phase__c = 'Approve';
            //update decision;
            
            String DecisionId3 = string.valueOf(decision.id);
       
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
                timingList65.add(time1);  
           }
           
           if(timingList65.size() > 0){
            update timingList65; 
           }            
            DecisionView.decisionPhaseChange(String.valueOf(decision.Id), String.valueOf(socialInput.Id), 'Execute', 'Test class coverage', 'Test');
            //DecisionView.decisionPhaseChangeDecide(String.valueOf(decision.Id), String.valueOf(socialInput.Id), 'Share', 'Test class coverage', 'Test');
        //}
    }
    
    static testMethod void decisionPhaseExecuteUpdate1() {
        // TO DO: implement unit test
        //Profile pf = [Select Id from Profile where Name = 'System Administrator'];
    
        /*User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = 'testuser@test123456789.com';
        u.CompanyName = 'test.com';
        u.Title = 'Test User';
        u.Username = 'testuser12@test123456789.com';
        u.Alias = 'testuser';
        u.CommunityNickname = 'Test User';
        u.TimeZoneSidKey = 'America/Mexico_City';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = pf.Id;
        u.LanguageLocaleKey = 'en_US';
        
        //insert u; */
        
        //User u = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' limit 1];
        
        //System.runAs(u){
            
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
            
            Social_Input__c socialInput = [Select s.Veto_Rights__c, s.User__c, s.SystemModstamp, s.SYS_Tab_View_Activites__c, s.SYS_Tab_View_History__c, s.SYS_Tab_View_Tasks__c, s.SYS_Tab_View_Social_Input__c, s.SYS_Tab_View_Relations__c, s.SYS_Tab_View_Quality__c, s.SYS_Tab_View_Attachments__c, s.SYS_Tab_View_Approvals__c, s.Role_Acceptance_Status__c, s.Role_Acceptance_Required__c, s.Result__c, s.Responsible__c, s.Rating__c, s.Outcome__c, s.Name, s.Mood__c, s.Like__c, s.LastModifiedDate, s.LastModifiedById, s.Informed__c, s.Id, s.Final_Approval_Status__c, s.Effort__c, s.Dislike__c, s.Decision__c, s.CreatedDate, s.CreatedById, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c From Social_Input__c s where s.Decision__c =: decision.Id];
            
            //decision.Phase__c = 'Share';
            //update decision;
            
            decision.Phase__c = 'Decide';
            update decision;
            
            decision.Phase__c = 'Approve';
            update decision;
            
                        
            DecisionView.decisionPhaseChange(String.valueOf(decision.Id), String.valueOf(socialInput.Id), 'Execute', 'Test class coverage', 'Test');
            DecisionView.AttachmentNote an = new DecisionView.AttachmentNote();
            
            //DecisionView.decisionPhaseChangeDecide(String.valueOf(decision.Id), String.valueOf(socialInput.Id), 'Share', 'Test class coverage', 'Test');
        //}
    }
    
    static testMethod void decisionPhaseEvaluateUpdate() {
        // TO DO: implement unit test
        //Profile pf = [Select Id from Profile where Name = 'System Administrator'];
    
        /*User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = 'testuser@test123456789.com';
        u.CompanyName = 'test.com';
        u.Title = 'Test User';
        u.Username = 'testuser12@test123456789.com';
        u.Alias = 'testuser';
        u.CommunityNickname = 'Test User';
        u.TimeZoneSidKey = 'America/Mexico_City';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = pf.Id;
        u.LanguageLocaleKey = 'en_US';
        
        //insert u; */
        
        //User u = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' limit 1];
        
        //System.runAs(u){
            
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
            
            Social_Input__c socialInput = [Select s.Veto_Rights__c, s.User__c, s.SystemModstamp, s.SYS_Tab_View_Activites__c, s.SYS_Tab_View_History__c, s.SYS_Tab_View_Tasks__c, s.SYS_Tab_View_Social_Input__c, s.SYS_Tab_View_Relations__c, s.SYS_Tab_View_Quality__c, s.SYS_Tab_View_Attachments__c, s.SYS_Tab_View_Approvals__c, s.Role_Acceptance_Status__c, s.Role_Acceptance_Required__c, s.Result__c, s.Responsible__c, s.Rating__c, s.Outcome__c, s.Name, s.Mood__c, s.Like__c, s.LastModifiedDate, s.LastModifiedById, s.Informed__c, s.Id, s.Final_Approval_Status__c, s.Effort__c, s.Dislike__c, s.Decision__c, s.CreatedDate, s.CreatedById, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c From Social_Input__c s where s.Decision__c =: decision.Id];
                        
            DecisionView.decisionPhaseChange(String.valueOf(decision.Id), String.valueOf(socialInput.Id), 'Evaluate', 'Test class coverage', 'Test');
            //DecisionView.decisionPhaseChangeDecide(String.valueOf(decision.Id), String.valueOf(socialInput.Id), 'Share', 'Test class coverage', 'Test');
        //}
    }
    
    static testMethod void decisionPhaseChangeDecide() {
        // TO DO: implement unit test
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
    
        /*User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = 'testuser@test123456789.com';
        u.CompanyName = 'test.com';
        u.Title = 'Test User';
        u.Username = 'testuser12@test123456789.com';
        u.Alias = 'testuser';
        u.CommunityNickname = 'Test User';
        u.TimeZoneSidKey = 'America/Mexico_City';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = pf.Id;
        u.LanguageLocaleKey = 'en_US';
        
        //insert u; */
        
        User u = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' and isActive = true limit 1];
        
        System.runAs(u){
            
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
            
            Social_Input__c socialInput = [Select s.Veto_Rights__c, s.User__c, s.SystemModstamp, s.SYS_Tab_View_Activites__c, s.SYS_Tab_View_History__c, s.SYS_Tab_View_Tasks__c, s.SYS_Tab_View_Social_Input__c, s.SYS_Tab_View_Relations__c, s.SYS_Tab_View_Quality__c, s.SYS_Tab_View_Attachments__c, s.SYS_Tab_View_Approvals__c, s.Role_Acceptance_Status__c, s.Role_Acceptance_Required__c, s.Result__c, s.Responsible__c, s.Rating__c, s.Outcome__c, s.Name, s.Mood__c, s.Like__c, s.LastModifiedDate, s.LastModifiedById, s.Informed__c, s.Id, s.Final_Approval_Status__c, s.Effort__c, s.Dislike__c, s.Decision__c, s.CreatedDate, s.CreatedById, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c From Social_Input__c s where s.Decision__c =: decision.Id];
                        
            DecisionView.decisionPhaseChangeDecide(String.valueOf(decision.Id), String.valueOf(socialInput.Id), 'Share', 'Test class coverage', 'Test');
        }
    }
    
    static testMethod void decisionPhaseCloseUpdate() {
        // TO DO: implement unit test
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
    
        /*User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = 'testuser@test123456789.com';
        u.CompanyName = 'test.com';
        u.Title = 'Test User';
        u.Username = 'testuser12@test123456789.com';
        u.Alias = 'testuser';
        u.CommunityNickname = 'Test User';
        u.TimeZoneSidKey = 'America/Mexico_City';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = pf.Id;
        u.LanguageLocaleKey = 'en_US';
        
        //insert u; */
        
        User u = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' and isActive = true limit 1];
        
        System.runAs(u){
            
            Decision__c decision = new Decision__c();
            decision.Title__c = 'Decision test class';
            decision.Decision_Taken__c = 'Test decision';
            decision.Problem_Idea_Advice__c = 'decision problem stateent ';
            decision.Due_Date__c = Datetime.now();
            decision.Phase__c = 'Draft';
            decision.Priority__c = 'High';
            decision.Plain_Tag__c = '#ft, #fingerTip';
            insert decision;
            
            
            Social_Input__c socialInput = [Select s.Veto_Rights__c, s.User__c, s.SystemModstamp, s.SYS_Tab_View_Activites__c, s.SYS_Tab_View_History__c, s.SYS_Tab_View_Tasks__c, s.SYS_Tab_View_Social_Input__c, s.SYS_Tab_View_Relations__c, s.SYS_Tab_View_Quality__c, s.SYS_Tab_View_Attachments__c, s.SYS_Tab_View_Approvals__c, s.Role_Acceptance_Status__c, s.Role_Acceptance_Required__c, s.Result__c, s.Responsible__c, s.Rating__c, s.Outcome__c, s.Name, s.Mood__c, s.Like__c, s.LastModifiedDate, s.LastModifiedById, s.Informed__c, s.Id, s.Final_Approval_Status__c, s.Effort__c, s.Dislike__c, s.Decision__c, s.CreatedDate, s.CreatedById, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c From Social_Input__c s where s.Decision__c =: decision.Id];
                        
            DecisionView.decisionPhaseChange(String.valueOf(decision.Id), String.valueOf(socialInput.Id), 'Close', 'Test class coverage', 'Test');
            decision.Phase__c = 'Close';
            update decision;
            
            
            //decision.Phase__c = 'Execute';
            //update decision;
            
            
            //decision.Phase__c = 'Share';
            //update decision;
            
        }
    }
    
    static testMethod void decisionPhaseCloseUpdate1() {
        // TO DO: implement unit test
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
    
        /*User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = 'testuser@test123456789.com';
        u.CompanyName = 'test.com';
        u.Title = 'Test User';
        u.Username = 'testuser12@test123456789.com';
        u.Alias = 'testuser';
        u.CommunityNickname = 'Test User';
        u.TimeZoneSidKey = 'America/Mexico_City';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = pf.Id;
        u.LanguageLocaleKey = 'en_US';
        
        //insert u; */
        
        User u = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' and isActive = true limit 1];
        
        System.runAs(u){
            
            Decision__c decision = new Decision__c();
            decision.Title__c = 'Decision test class';
            decision.Decision_Taken__c = 'Test decision';
            decision.Problem_Idea_Advice__c = 'decision problem stateent ';
            decision.Due_Date__c = Datetime.now();
            decision.Phase__c = 'Draft';
            decision.Priority__c = 'High';
            decision.Plain_Tag__c = '#ft, #fingerTip';
            insert decision;
            
            
            Social_Input__c socialInput = [Select s.Veto_Rights__c, s.User__c, s.SystemModstamp, s.SYS_Tab_View_Activites__c, s.SYS_Tab_View_History__c, s.SYS_Tab_View_Tasks__c, s.SYS_Tab_View_Social_Input__c, s.SYS_Tab_View_Relations__c, s.SYS_Tab_View_Quality__c, s.SYS_Tab_View_Attachments__c, s.SYS_Tab_View_Approvals__c, s.Role_Acceptance_Status__c, s.Role_Acceptance_Required__c, s.Result__c, s.Responsible__c, s.Rating__c, s.Outcome__c, s.Name, s.Mood__c, s.Like__c, s.LastModifiedDate, s.LastModifiedById, s.Informed__c, s.Id, s.Final_Approval_Status__c, s.Effort__c, s.Dislike__c, s.Decision__c, s.CreatedDate, s.CreatedById, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c From Social_Input__c s where s.Decision__c =: decision.Id];
                        
            DecisionView.decisionPhaseChange(String.valueOf(decision.Id), String.valueOf(socialInput.Id), 'Close', 'Test class coverage', 'Test');
            //decision.Phase__c = 'Close';
            //update decision;
            
            
            decision.Phase__c = 'Execute';
            update decision;
            
            
            //decision.Phase__c = 'Share';
            //update decision;
            
        }
    }
    
    static testMethod void decisionPhaseCloseUpdate2() {
        // TO DO: implement unit test
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
    
        /*User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = 'testuser@test123456789.com';
        u.CompanyName = 'test.com';
        u.Title = 'Test User';
        u.Username = 'testuser12@test123456789.com';
        u.Alias = 'testuser';
        u.CommunityNickname = 'Test User';
        u.TimeZoneSidKey = 'America/Mexico_City';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = pf.Id;
        u.LanguageLocaleKey = 'en_US';
        
        //insert u; */
        
        User u = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' and isActive = true limit 1];
        
        System.runAs(u){
            
            Decision__c decision = new Decision__c();
            decision.Title__c = 'Decision test class';
            decision.Decision_Taken__c = 'Test decision';
            decision.Problem_Idea_Advice__c = 'decision problem stateent ';
            decision.Due_Date__c = Datetime.now();
            decision.Phase__c = 'Draft';
            decision.Priority__c = 'High';
            decision.Plain_Tag__c = '#ft, #fingerTip';
            insert decision;
            
            
            Social_Input__c socialInput = [Select s.Veto_Rights__c, s.User__c, s.SystemModstamp, s.SYS_Tab_View_Activites__c, s.SYS_Tab_View_History__c, s.SYS_Tab_View_Tasks__c, s.SYS_Tab_View_Social_Input__c, s.SYS_Tab_View_Relations__c, s.SYS_Tab_View_Quality__c, s.SYS_Tab_View_Attachments__c, s.SYS_Tab_View_Approvals__c, s.Role_Acceptance_Status__c, s.Role_Acceptance_Required__c, s.Result__c, s.Responsible__c, s.Rating__c, s.Outcome__c, s.Name, s.Mood__c, s.Like__c, s.LastModifiedDate, s.LastModifiedById, s.Informed__c, s.Id, s.Final_Approval_Status__c, s.Effort__c, s.Dislike__c, s.Decision__c, s.CreatedDate, s.CreatedById, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c From Social_Input__c s where s.Decision__c =: decision.Id];
                        
            DecisionView.decisionPhaseChange(String.valueOf(decision.Id), String.valueOf(socialInput.Id), 'Close', 'Test class coverage', 'Test');
            //decision.Phase__c = 'Close';
            //update decision;
            
            
            //decision.Phase__c = 'Execute';
            //update decision;
            
            
            decision.Phase__c = 'Share';
            update decision;
            
        }
    }
    
    static testMethod void decisionUpdate() {
        // TO DO: implement unit test
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
    
        /*User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = 'testuser@test123456789.com';
        u.CompanyName = 'test.com';
        u.Title = 'Test User';
        u.Username = 'testuser12@test123456789.com';
        u.Alias = 'testuser';
        u.CommunityNickname = 'Test User';
        u.TimeZoneSidKey = 'America/Mexico_City';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = pf.Id;
        u.LanguageLocaleKey = 'en_US';
        
        //insert u; */
        
        User u = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' and isActive = true limit 1];
        
        System.runAs(u){
            
            Decision__c decision = new Decision__c();
            decision.Title__c = 'Decision test class';
            decision.Decision_Taken__c = 'Test decision';
            decision.Problem_Idea_Advice__c = 'decision problem stateent ';
            decision.Due_Date__c = Datetime.now();
            decision.Phase__c = 'Draft';
            decision.Priority__c = 'High';
            decision.Plain_Tag__c = '#ft, #fingerTip';
            insert decision;
            
            
         
            
            
            ApexPages.StandardController sc = new ApexPages.StandardController(decision);   
            
            ApexPages.currentPage().getParameters().put('ID',decision.id);  
            ApexPages.currentPage().getParameters().put('ProblemStatementValue','piyush quot; parmar');
            ApexPages.currentPage().getParameters().put('DecisionValue','&lt; piyush &#039 parmar &gt;');
            
            // --
			ApexPages.currentPage().getParameters().put('TopicMultiSelect','A,B,C');
            //-- 
            DecisionView  decisionView = new DecisionView(sc); 
            decisionView.decisionRTFUpdate();
            //decisionView.decisionRTFUpdateDecide();
            
        }
    }
    
    static testMethod void decisionUpdate1() {
        // TO DO: implement unit test
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
    
        /*User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = 'testuser@test123456789.com';
        u.CompanyName = 'test.com';
        u.Title = 'Test User';
        u.Username = 'testuser12@test123456789.com';
        u.Alias = 'testuser';
        u.CommunityNickname = 'Test User';
        u.TimeZoneSidKey = 'America/Mexico_City';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = pf.Id;
        u.LanguageLocaleKey = 'en_US';
        
        //insert u; */
        
        User u = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' and isActive = true limit 1];
        
        System.runAs(u){
            
            Decision__c decision = new Decision__c();
            decision.Title__c = 'Decision test class';
            decision.Decision_Taken__c = 'Test decision';
            decision.Problem_Idea_Advice__c = 'decision problem stateent ';
            decision.Due_Date__c = Datetime.now();
            decision.Phase__c = 'Draft';
            decision.Priority__c = 'High';
            decision.Plain_Tag__c = '#ft, #fingerTip';
            insert decision;
            
            
         
            
            
            ApexPages.StandardController sc = new ApexPages.StandardController(decision);   
            
            ApexPages.currentPage().getParameters().put('ID',decision.id);  
            ApexPages.currentPage().getParameters().put('ProblemStatementValue1','piyush quot; parmar');
            ApexPages.currentPage().getParameters().put('DecisionValue1','&lt; piyush &#039 parmar &gt;');
            
            // --
			ApexPages.currentPage().getParameters().put('TopicMultiSelect','A,B,C');
            //-- 
            DecisionView  decisionView = new DecisionView(sc); 
            decisionView.decision = decision;
            //decisionView.decisionRTFUpdate();
            decisionView.decisionRTFUpdateDecide();
            
        }
    }
    
    static testMethod void decisionCustomUpdate() {
        // TO DO: implement unit test
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
    
        /*User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = 'testuser@test123456789.com';
        u.CompanyName = 'test.com';
        u.Title = 'Test User';
        u.Username = 'testuser12@test123456789.com';
        u.Alias = 'testuser';
        u.CommunityNickname = 'Test User';
        u.TimeZoneSidKey = 'America/Mexico_City';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = pf.Id;
        u.LanguageLocaleKey = 'en_US';
        
        //insert u; */
        
        User u = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' and isActive = true limit 1];
        
        System.runAs(u){
            
            Decision__c decision = new Decision__c();
            decision.Title__c = 'Decision test class';
            decision.Decision_Taken__c = 'Test decision';
            decision.Problem_Idea_Advice__c = 'decision problem stateent ';
            decision.Due_Date__c = Datetime.now();
            decision.Phase__c = 'Draft';
            decision.Priority__c = 'High';
            decision.Plain_Tag__c = '#ft, #fingerTip';
            insert decision;
            
            
        
            
            
            ApexPages.StandardController sc = new ApexPages.StandardController(decision);   
            ApexPages.currentPage().getParameters().put('ID',decision.id);  
            
            DecisionView  decisionView = new DecisionView(sc); 
            
            decisionView.tagUpdate();
            
           decisionView.saveIssues();
            
            
        }
    }
    
    static testMethod void decisionImage() {
        // TO DO: implement unit test
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
    
        /*User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = 'testuser@test123456789.com';
        u.CompanyName = 'test.com';
        u.Title = 'Test User';
        u.Username = 'testuser12@test123456789.com';
        u.Alias = 'testuser';
        u.CommunityNickname = 'Test User';
        u.TimeZoneSidKey = 'America/Mexico_City';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = pf.Id;
        u.LanguageLocaleKey = 'en_US';
        
        //insert u; */
        
        User u = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' and isActive = true limit 1];
        
        System.runAs(u){
            
            Decision__c decision = new Decision__c();
            decision.Title__c = 'Decision test class';
            decision.Decision_Taken__c = 'Test decision';
            decision.Problem_Idea_Advice__c = 'decision problem stateent ';
            decision.Due_Date__c = Datetime.now();
            decision.Phase__c = 'Draft';
            decision.Priority__c = 'High';
            //decision.Plain_Tag__c = '#ft, #fingerTip';
            insert decision;
            
            Tag__c tag= new Tag__c(Name = '#fingerTip');
            insert tag;
            DecisionView.insertTag(String.valueOf(decision.Id), '#fingerTip,#ft');
            DecisionView.insertTag(String.valueOf(decision.Id), '#kvp,#piyush');
            
            
            ApexPages.StandardController sc = new ApexPages.StandardController(decision);   
            ApexPages.currentPage().getParameters().put('ID',decision.id);  
            
            DecisionView  decisionView1 = new DecisionView(sc); 
            
            
            String attchmentBody = 'test class coverage';
            decisionView1.fileBodyUpdate  = Blob.valueOf(attchmentBody);
            decisionView1.fileBody  = Blob.valueOf(attchmentBody);
            decisionView1.uploadDecisionImage();
            decisionView1.updateDecisionImage();
            decisionView1.deleteUploadImage();
            decisionView1.cancelUploadImage();
            decisionView1.decisionPDFGenerate();
            decisionView1.dummyCall();
        }
    }
    
    static testMethod void decisionDelete() {
        // TO DO: implement unit test
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
    
        /*User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = 'testuser@test123456789.com';
        u.CompanyName = 'test.com';
        u.Title = 'Test User';
        u.Username = 'testuser12@test123456789.com';
        u.Alias = 'testuser';
        u.CommunityNickname = 'Test User';
        u.TimeZoneSidKey = 'America/Mexico_City';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = pf.Id;
        u.LanguageLocaleKey = 'en_US';
        
        //insert u; */
        
        User u = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' and isActive = true limit 1];
        
        System.runAs(u){
            
            Decision__c decision = new Decision__c();
            decision.Title__c = 'Decision test class';
            decision.Decision_Taken__c = 'Test decision';
            decision.Problem_Idea_Advice__c = 'decision problem stateent ';
            decision.Due_Date__c = Datetime.now();
            decision.Phase__c = 'Draft';
            decision.Priority__c = 'High';
            //decision.Plain_Tag__c = '#ft, #fingerTip';
            insert decision;
            
            Delete decision;
           
        }
    }
    
    static testMethod void decisiondummyMethods() {
         test.starttest();
        Decision__c decisionTag = new Decision__c();
        decisionTag.Title__c = 'Decision test class';
        decisionTag.Decision_Taken__c = 'Test decision';
        decisionTag.Problem_Idea_Advice__c = 'decision problem stateent ';
        decisionTag.Due_Date__c = Datetime.now();
        decisionTag.Phase__c = 'Draft';
        decisionTag.Priority__c = 'High';
        decisionTag.Private__c = true;
        insert decisionTag;
        Social_Input__c socialInput = [Select s.Veto_Rights__c, s.User__c, s.SystemModstamp, s.SYS_Tab_View_Activites__c, s.SYS_Tab_View_History__c, s.SYS_Tab_View_Tasks__c, s.SYS_Tab_View_Social_Input__c, s.SYS_Tab_View_Relations__c, s.SYS_Tab_View_Quality__c, s.SYS_Tab_View_Attachments__c, s.SYS_Tab_View_Approvals__c, s.Role_Acceptance_Status__c, s.Role_Acceptance_Required__c, s.Result__c, s.Responsible__c, s.Rating__c, s.Outcome__c, s.Name, s.Mood__c, s.Like__c, s.LastModifiedDate, s.LastModifiedById, s.Informed__c, s.Id, s.Final_Approval_Status__c, s.Effort__c, s.Dislike__c, s.Decision__c, s.CreatedDate, s.CreatedById, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c From Social_Input__c s where s.Decision__c =: decisionTag.Id];
        Relations__c relation = new Relations__c();
        relation.Child_Record_Name__c = decisionTag.Title__c;
        relation.Child_Object_Name__c = 'Decision';
        relation.Parent_Id__c = decisionTag.Id;
      
        relation.Type__c = 'Relation';
        insert relation;
        
        ApexPages.currentPage().getParameters().put('id',decisionTag.Id);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(decisionTag);
        DecisionView dv = new DecisionView(sc);
        dv.srchRelationship = new List<Relations__c>();
        dv.srchRelationshipSet = new Set<Relations__c>();
        dv.existingRelationsAddToSet();
        ApexPages.currentPage().getParameters().put('chooseObject','User');
        ApexPages.currentPage().getParameters().put('searchText','Test*');
        dv.searchItems();
        ApexPages.currentPage().getParameters().put('chooseObject','Account');
        ApexPages.currentPage().getParameters().put('searchText','Test*');
        dv.searchItems();
        ApexPages.currentPage().getParameters().put('chooseObject','QuoteLineItem');
        ApexPages.currentPage().getParameters().put('searchText','Test*');
        dv.searchItems();
        ApexPages.currentPage().getParameters().put('chooseObject','Idea');
        ApexPages.currentPage().getParameters().put('searchText','Test*');
        dv.searchItems();
        ApexPages.currentPage().getParameters().put('chooseObject','Solution');
        ApexPages.currentPage().getParameters().put('searchText','Test*');
        dv.searchItems();
        ApexPages.currentPage().getParameters().put('chooseObject','Case');
        ApexPages.currentPage().getParameters().put('searchText','Test*');
        dv.searchItems();
        ApexPages.currentPage().getParameters().put('chooseObject','Contract');
        ApexPages.currentPage().getParameters().put('searchText','Test*');
        dv.searchItems();
        dv.cancelRelation();
        dv.addFromSrch();
       
        test.stoptest();
    }
    
    static testMethod void decisiondummyMethods2() {
        Decision__c decisionTag = new Decision__c();
        decisionTag.Title__c = 'Decision test class';
        decisionTag.Decision_Taken__c = 'Test decision';
        decisionTag.Problem_Idea_Advice__c = 'decision problem stateent ';
        decisionTag.Due_Date__c = Datetime.now();
        decisionTag.Phase__c = 'Draft';
        decisionTag.Priority__c = 'High';
        decisionTag.Private__c = true;
        insert decisionTag;
        Social_Input__c socialInput = [Select s.Veto_Rights__c, s.User__c, s.SystemModstamp, s.SYS_Tab_View_Activites__c, s.SYS_Tab_View_History__c, s.SYS_Tab_View_Tasks__c, s.SYS_Tab_View_Social_Input__c, s.SYS_Tab_View_Relations__c, s.SYS_Tab_View_Quality__c, s.SYS_Tab_View_Attachments__c, s.SYS_Tab_View_Approvals__c, s.Role_Acceptance_Status__c, s.Role_Acceptance_Required__c, s.Result__c, s.Responsible__c, s.Rating__c, s.Outcome__c, s.Name, s.Mood__c, s.Like__c, s.LastModifiedDate, s.LastModifiedById, s.Informed__c, s.Id, s.Final_Approval_Status__c, s.Effort__c, s.Dislike__c, s.Decision__c, s.CreatedDate, s.CreatedById, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c From Social_Input__c s where s.Decision__c =: decisionTag.Id];
        Relations__c relation = new Relations__c();
        relation.Child_Record_Name__c = decisionTag.Title__c;
        relation.Child_Object_Name__c = 'Decision';
        relation.Parent_Id__c = decisionTag.Id;
       
        relation.Type__c = 'Relation';
        insert relation;
        
        DecisionView.updateDecisionNearestDueDate(decisionTag.Id);
        DecisionView.ActivitiesTaskEvent ate = new DecisionView.ActivitiesTaskEvent();
        DecisionView.decisionPhaseChangewithRTF('problemStatemnt','decisionStatemnt',decisionTag.Id,socialInput.id,'Propose','','comments'   );
        //ProcessInstance p  = [Select id from processInstance limit 1];
        //DecisionView.approvedReject( decisionTag.Id, p.id,'Approve','Reject this decision');
        
        Task task = new Task();
        task.WhatId = decisionTag.Id;
        task.Subject = 'Task on decision';
        task.ActivityDate = Date.today();
        task.Status = 'Completed';
        insert task; 
        
        Event event = new Event();
        event.WhatId = decisionTag.Id;
        event.Subject = 'Task on decision';
        event.DurationInMinutes = 50;
        event.ActivityDateTime = System.now();
        insert event; 
        
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
        User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Email = 'testuser@test123456789.com';
        u.CompanyName = 'test.com';
        u.Title = 'Test User';
        u.Username = 'testuser12@test123456789.com';
        u.Alias = 'testuser';
        u.CommunityNickname = 'Test User';
        u.TimeZoneSidKey = 'America/Mexico_City';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = pf.Id;
        u.LanguageLocaleKey = 'en_US';
        insert u;
        
        ApexPages.currentPage().getParameters().put('taskId',task.Id);
        ApexPages.currentPage().getParameters().put('eventId',event.Id);
		
        ApexPages.currentPage().getParameters().put('id',decisionTag.Id);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(decisionTag);
        DecisionView dv = new DecisionView(sc);
        dv.toBeUpdatedTask();
        dv.toBeUpdatedEvent();
        dv.updatedTask();
        dv.updatedEvent();
        DecisionView.addMentionSegment(task.Id);
        DecisionView.mentionTextPost(u.Id,'test',decisionTag.Id);
        test.starttest();
        	socialInput.Responsible__c = true;
        	socialInput.Accountable__c = false;
        	socialInput.Consulted__c = false;
        	socialInput.Is_Group__c = false;
        	socialInput.Role_Acceptance_Status__c = 'Rejected';
        	update socialInput;
        	DecisionView.mentionTextPost(u.Id,'test',decisionTag.Id);
        	socialInput.Consulted__c = true;
        	socialInput.Responsible__c = false;
        	socialInput.Backup_for_Accountable__c = true;
        	socialInput.Accountable__c = false;
        	socialInput.Consulted__c = false;
        	socialInput.Is_Group__c = false;
        	socialInput.Role_Acceptance_Status__c = 'Rejected';
        	update socialInput;
        	DecisionView.mentionTextPost(u.Id,'test',decisionTag.Id);
        	socialInput.Responsible__c = true;
        	socialInput.Consulted__c = true;
        	socialInput.Accountable__c = true;
        	socialInput.Consulted__c = false;
        	socialInput.Is_Group__c = false;
        	socialInput.Role_Acceptance_Status__c = 'Rejected';
        	update socialInput;
        	DecisionView.mentionTextPost(u.Id,'test',decisionTag.Id);
        test.stoptest();
    }
    
    public static testMethod void testViewSocialPeopleTabWithSearch(){
        test.startTest();
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
        /*User u = new User(FirstName = 'Test',LastName = 'User',Email = 'testuser@test123456789.com',CompanyName = 'test.com',Title = 'Test User',Username = 'testuser15@test123456789.com',Alias = 'testuser',CommunityNickname = 'Test User',TimeZoneSidKey = 'America/Mexico_City',LocaleSidKey = 'en_US',EmailEncodingKey = 'ISO-8859-1',ProfileId = pf.Id,LanguageLocaleKey = 'en_US');
        insert u;*/
          User u = [select id from User where isActive = true limit 1];
        System.runAs(u){
            Group g = new Group();
            g.name = 'NewGroup';
            insert g;
            
            GroupMember gm = new  GroupMember();
            gm.groupId = g.Id;
            gm.UserOrGroupId = u.Id;
            insert gm;
            
            Decision__c decision = new Decision__c();
            Decision.title__c = 'Test decision';
            Decision.Problem_Idea_Advice__c = 'Problem';
            Decision.Decision_Taken__c = 'Decision';
            Decision.Priority__c = 'Normal';
            insert Decision;
            Social_Input__c socialInput = [Select s.Veto_Rights__c, s.User__c, s.SystemModstamp, s.SYS_Tab_View_Activites__c, s.SYS_Tab_View_History__c, s.SYS_Tab_View_Tasks__c, s.SYS_Tab_View_Social_Input__c, s.SYS_Tab_View_Relations__c, s.SYS_Tab_View_Quality__c, s.SYS_Tab_View_Attachments__c, s.SYS_Tab_View_Approvals__c, s.Role_Acceptance_Status__c, s.Role_Acceptance_Required__c, s.Result__c, s.Responsible__c, s.Rating__c, s.Outcome__c, s.Name, s.Mood__c, s.Like__c, s.LastModifiedDate, s.LastModifiedById, s.Informed__c, s.Id, s.Final_Approval_Status__c, s.Effort__c, s.Dislike__c, s.Decision__c, s.CreatedDate, s.CreatedById, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c From Social_Input__c s where s.Decision__c =: Decision.Id];
        	socialInput.Is_Group__c = true;
            socialInput.GroupId__c=g.id;
            socialInput.User__c =U.id;
            //
            update socialInput;
            
            Social_Input__c socialInput1 = [Select User__r.Name From Social_Input__c s where s.Decision__c =: Decision.Id];
        	
            ApexPages.currentPage().getParameters().put('id',decision.Id);
            ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(decision);
            DecisionView dv = new DecisionView(sc);
            System.assertEquals(String.valueof(socialInput.User__c),u.id);
            
            //System.assertEquals(socialInput1.User__r.Name,'Test' );
            DecisionView.viewSocialPeopleTabWithSearch(String.valueOf(decision.id),'','Test*');
            DecisionView.viewSocialPeopleTabWithSearch(String.valueOf(decision.id),'','Te');
            test.stopTest();
        }
        
    }
   // public static testMethod void testViewSocialPeopleTabWithSearch(){
        
   // }
   public static testMethod void testapprovedReject(){
            test.startTest();
       		Decision__c decision = new Decision__c();
            decision.title__c = 'Test decision';
            decision.Problem_Idea_Advice__c = 'Problem';
            decision.Decision_Taken__c = 'Decision';
            decision.Priority__c = 'Normal';
         	decision.Phase__c  ='Share';
         	decision.SYS_From_Quick_Decision__c=True;
            insert decision;
         
			decision.Phase__c  ='Propose';
         	update decision;
         
         	Social_Input__c sI = [Select id,Name from Social_Input__c where Decision__c=:decision.id];
         	sI.Stance_Approval_Status__c='Rejected';
       		sI.Veto_Rights__c = true;
       		Update sI;
         	ProcessInstance pI  = [Select id, TargetObjectId,TargetObject.Name from processInstance where TargetObjectId=:sI.id  ];
         	ProcessInstanceWorkitem piwi =[Select id from ProcessInstanceWorkitem where ProcessInstanceId=:pI.id ];
         	System.assertEquals(String.valueof(SI.Name), String.valueof(pi.TargetObject.Name));
       		System.assertEquals(pi.TargetObjectID, SI.Id);
         	System.assertEquals(pi.TargetObjectID, SI.Id);
         
          	ApexPages.currentPage().getParameters().put('id',decision.Id);
            ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(decision);
            DecisionView dv = new DecisionView(sc);
       		
       		DecisionView.approvedReject(decision.Id, piwi.id, 'Reject', 'comment');
       		test.stopTest();
        }
    
    // search all the recodes, add relation button
    public static testMethod void testsearchItems(){
    	test.starttest();
        Decision__c decisionTag = new Decision__c(Title__c= 'Decision test class',Decision_Taken__c = 'Test decision',Problem_Idea_Advice__c = 'decision problem stateent ',Due_Date__c = Datetime.now(),Phase__c = 'Draft',Priority__c = 'High',Private__c = true);
        insert decisionTag;
        
        Social_Input__c socialInput = [Select s.Veto_Rights__c, s.User__c, s.SystemModstamp, s.SYS_Tab_View_Activites__c, s.SYS_Tab_View_History__c, s.SYS_Tab_View_Tasks__c, s.SYS_Tab_View_Social_Input__c, s.SYS_Tab_View_Relations__c, s.SYS_Tab_View_Quality__c, s.SYS_Tab_View_Attachments__c, s.SYS_Tab_View_Approvals__c, s.Role_Acceptance_Status__c, s.Role_Acceptance_Required__c, s.Result__c, s.Responsible__c, s.Rating__c, s.Outcome__c, s.Name, s.Mood__c, s.Like__c, s.LastModifiedDate, s.LastModifiedById, s.Informed__c, s.Id, s.Final_Approval_Status__c, s.Effort__c, s.Dislike__c, s.Decision__c, s.CreatedDate, s.CreatedById, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c From Social_Input__c s where s.Decision__c =: decisionTag.Id];
        
       
        
        Account a = new Account();
        a.Name = 'test';
        insert a;
        
        Contact c = new Contact();
        c.Lastname = 'Test';
        insert c;
        
        Opportunity opp = new Opportunity();
        opp.Name ='Test OPP';
        opp.AccountId =a.id;
        opp.CloseDate = system.Today();
        opp.StageName = 'Prospecting';
        insert opp;  
        
        
        
        Pricebook2 pb = [select Id from Pricebook2 where IsStandard = true limit 1];
        //Pricebook2 pb = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true,IsStandard=true);
		//insert pb;

        Product2 p = new Product2(Name = 'Test Product', isActive = true);
        insert p;
        
        //PriceBookEntry testPriceBookEntryRec = [SELECT Id FROM PricebookEntry limit 1];
        PricebookEntry testPriceBookEntryRec = new PriceBookEntry(IsActive=true,UnitPrice = 2,Pricebook2Id= pb.id,Product2Id=p.id,UseStandardPrice = false);
		insert testPriceBookEntryRec;
		
        Quote quotesRec = new Quote(Name='QuoteTest',Opportunityid=opp.id,PriceBook2Id = pb.Id);
        insert quotesRec;
        
        QuoteLineItem qli = new QuoteLineItem(QuoteId = quotesRec.Id, PriceBookEntryId = testPriceBookEntryRec.Id, Quantity = 1, UnitPrice = 100);
        insert qli;
 
        solution sol = new Solution(SolutionName='Test Solution');
        insert sol;
        
        Case caseRec = new Case(Status='New'); 
        insert caseRec;
        
        Contract contractRec = new Contract(Accountid=a.id, Status='Draft'); 
        insert contractRec;
        
        Community testCommunityRecord = [Select Name,id from Community limit 1];
        
        idea ideaRec = new idea(Title='test', CommunityId=testCommunityRecord.id); 
        insert ideaRec;
        
        
        ApexPages.currentPage().getParameters().put('id',decisionTag.Id);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(decisionTag);
        DecisionView dv = new DecisionView(sc);
        dv.srchRelationship = new List<Relations__c>();
        dv.srchRelationshipSet = new Set<Relations__c>();
        dv.existingRelationsAddToSet();
        ApexPages.currentPage().getParameters().put('chooseObject','User');
        ApexPages.currentPage().getParameters().put('searchText','Test*');
        dv.searchItems();
        ApexPages.currentPage().getParameters().put('chooseObject','Account');
        ApexPages.currentPage().getParameters().put('searchText','Test*');
        dv.searchItems();
        ApexPages.currentPage().getParameters().put('chooseObject','QuoteLineItem');
        ApexPages.currentPage().getParameters().put('searchText','*');
        dv.searchItems();
        ApexPages.currentPage().getParameters().put('chooseObject','Idea');
        ApexPages.currentPage().getParameters().put('searchText','Test*');
        dv.searchItems();
        ApexPages.currentPage().getParameters().put('chooseObject','Solution');
        ApexPages.currentPage().getParameters().put('searchText','Test*');
        dv.searchItems();
        ApexPages.currentPage().getParameters().put('chooseObject','Case');
        ApexPages.currentPage().getParameters().put('searchText','*');
        dv.searchItems();
        ApexPages.currentPage().getParameters().put('chooseObject','Contract');
        ApexPages.currentPage().getParameters().put('searchText','*');
        dv.searchItems();
        ApexPages.currentPage().getParameters().put('chooseObject','Contact');
        ApexPages.currentPage().getParameters().put('searchText','Test*');
        dv.searchItems();
        
        ApexPages.currentPage().getParameters().put('chooseObject','Idea');
        ApexPages.currentPage().getParameters().put('searchText','Test*');
        dv.searchItems();
        dv.cancelRelation();
        dv.addFromSrch();
       
        test.stoptest();
    
        
    }
    // CommentFeedCommnetOrPost code coverage DV-84 PV-85
	public static testMethod void testFeedCommnetOrPost(){
    	    test.startTest();
       		Decision__c decision = new Decision__c(title__c = 'Test decision',Problem_Idea_Advice__c = 'Problem',Decision_Taken__c = 'Decision',Priority__c = 'Normal',Phase__c  ='Share',SYS_From_Quick_Decision__c=True);
            insert decision;
			Profile pf = [Select Id from Profile where Name = 'System Administrator'];         
            User u1 = new User(FirstName = 'Test',LastName = 'User1',Email = 'testuser@test123456789.com',CompanyName = 'test.com',Title = 'Test User',Username = 'testuser15@1.com',Alias = 'U1',CommunityNickname = 'U1',TimeZoneSidKey = 'America/Mexico_City',LocaleSidKey = 'en_US',EmailEncodingKey = 'ISO-8859-1',ProfileId = pf.Id,LanguageLocaleKey = 'en_US');
            insert u1;
        	
            User u2 = new User(FirstName = 'Test',LastName = 'User2',Email = 'testuser@test123456789.com',CompanyName = 'test.com',Title = 'Test User',Username = 'testuser15@2.com',Alias = 'U2',CommunityNickname = 'U2',TimeZoneSidKey = 'America/Mexico_City',LocaleSidKey = 'en_US',EmailEncodingKey = 'ISO-8859-1',ProfileId = pf.Id,LanguageLocaleKey = 'en_US');
            insert u2;
        
        	Social_Input__c sIRes = new Social_Input__c(User__c=u1.id,Decision__c=decision.id,Responsible__c=true);
        	insert sIRes;
        	Social_Input__c sICon = new Social_Input__c(User__c=u2.id,Decision__c=decision.id,Consulted__c=true);
         	insert sICon;
         	
        
    }
}