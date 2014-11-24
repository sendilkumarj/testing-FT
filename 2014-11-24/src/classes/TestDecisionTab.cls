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
private class TestDecisionTab {

    static testMethod void unitTestDecisionTab () {
        // TO DO: implement unit test
        
        // insert Decision Record :
        test.startTest();
        Decision__c decision = new Decision__c();
        decision.Title__c = 'test Decision';
        decision.Problem_Idea_Advice__c = 'problem statement';
        decision.Priority__c = 'Normal';
        insert decision;
         
        Profile pfSysAdm = [Select Id from Profile where Name = 'System Administrator'];
        Profile pfStdUser = [Select Id from Profile where Name = 'System Administrator'];
        User u1 = new User(FirstName = 'Test',LastName = 'User',Email = 'testuser1@test123456789.com',CompanyName = 'test.com',Title = 'Test User',Username = 'testuser1@test123456789.com',Alias = 'testuser',CommunityNickname = 'TUser1',TimeZoneSidKey = 'America/Mexico_City',LocaleSidKey = 'en_US',EmailEncodingKey = 'ISO-8859-1',ProfileId = pfSysAdm.Id,LanguageLocaleKey = 'en_US');
        insert u1;
        
        User u2 = new User(FirstName = 'Test',LastName = 'User',Email = 'testuser2@test123456789.com',CompanyName = 'test.com',Title = 'Test User',Username = 'testuser2@test123456789.com',Alias = 'testuser',CommunityNickname = 'TUser2',TimeZoneSidKey = 'America/Mexico_City',LocaleSidKey = 'en_US',EmailEncodingKey = 'ISO-8859-1',ProfileId = pfStdUser.Id,LanguageLocaleKey = 'en_US');
        insert u2;
        
        List<Task> listTaskRec = new List<Task>();
        for(integer i=0;i<200;i++){
            Task taskRec = new Task(Ownerid=u1.id,Subject='test Task'+i,whatid=decision.id);
            listTaskRec.add(taskRec);
        }
        insert listTaskRec;
        List<Task> listTaskRecToUpdate = new List<Task>();
        for(integer i=0;i<listTaskRec.size();i++){
            Task taskRec = listTaskRec.get(i);
            taskRec.Subject='test Task'+i;
            listTaskRecToUpdate.add(taskRec);
        }
        update listTaskRecToUpdate;
        // add social input record
        Social_Input__c socialInputRecord1 = new Social_Input__c(User__c=u1.id,Description__c=decision.id,Stance_Approval_Status__c='Approved');
        insert socialInputRecord1;
        Social_Input__c socialInputRecord2 = new Social_Input__c(User__c=u2.id,Description__c=decision.id);
        insert socialInputRecord2;
        // add decisionFeed
        FeedItem decisionFeed = new FeedItem (Body='Hello',ParentId=decision.id);
        insert decisionFeed;
        
        FeedItem taskFeed = new FeedItem (Body='Hello',ParentId=listTaskRecToUpdate.get(0).id);
        insert taskFeed;        
        DecisionTab decisionTabObject = new DecisionTab();
        
        
        test.stopTest();
    }
    
    // to update the decision the decision call the remove function .
    static testMethod void unitTestDecisionTabUpdate () {
        
        test.startTest();
        Decision__c decision = new Decision__c();
        decision.Title__c = 'test Decision';
        decision.Problem_Idea_Advice__c = 'problem statement';
        decision.Priority__c = 'Normal';
        insert decision;
        String decisionId = String.valueOf(decision.id);
        String editedJsonString ='[{"title":"XX - Test Highlight 1.1222","thanksBadgesForMe":"","thanksBadges":"0","status":"Approved","stanceColour":"emptyDuedateTask","stance":"1/2","readsOfDecision":"","phase":"Close","nextDueDate":"","name":"XX - Test Highlight 1.122","myStance":"Supported","myRole":"Accountable","lastActivityDate":"8/4/2014 12:54 PM","isEditable":true,"id":"'+decisionId+'","icon":"/resource/1396683622000/Images/newDecisionLifeCycle/LifeCycle-profilePic-130x130.jpg","dType":"","chatterPosts":14,"chatterPostLikesForME":0,"chatterPostLikes":0,"activityColour":"emptyDuedateTask","activitiesTask":"0/0","accountable":"Manju S"}]'; 
        
        //DecisionTab decisionTabObject = new DecisionTab();        
        DecisionTab.updateDecisions(editedJsonString,'Closed');
        DecisionTab.updateDecisions(editedJsonString,'');
        test.stopTest();
    }   
    
  /*  // to update the decision the decision
    static testMethod void unitTestDecisionTabMultipleDecision () {
        
         // TO DO: implement unit test
        
        // insert Decision Record :
        test.startTest();
        List<Decision__c> lstdecision = new List<Decision__c>();
        for(integer i=0;i<1000;i++){
            Decision__c decision = new Decision__c();
            decision.Title__c = 'test Decision'+i;
            decision.Problem_Idea_Advice__c = 'problem statement';
            decision.Priority__c = 'Normal';
            lstdecision.add(decision);
        }
        insert lstdecision;
        
        list<Attachment> lstAttachment = new LIST<Attachment>();
        for(integer i=0;i<lstdecision.size();i++){
            Attachment lAttach = new Attachment();
            lAttach.Body= EncodingUtil.base64Decode('hello');
            lAttach.ParentId = lstdecision.get(i).id;
            lstAttachment.add(lAttach);            
        }
        insert lstAttachment;
        
        Profile pfSysAdm = [Select Id from Profile where Name = 'System Administrator'];
        Profile pfStdUser = [Select Id from Profile where Name = 'System Administrator'];
        User u1 = new User(FirstName = 'Test',LastName = 'User',Email = 'testuser1@test123456789.com',CompanyName = 'test.com',Title = 'Test User',Username = 'testuser1@test123456789.com',Alias = 'testuser',CommunityNickname = 'TUser1',TimeZoneSidKey = 'America/Mexico_City',LocaleSidKey = 'en_US',EmailEncodingKey = 'ISO-8859-1',ProfileId = pfSysAdm.Id,LanguageLocaleKey = 'en_US');
        insert u1;
        
        User u2 = new User(FirstName = 'Test',LastName = 'User',Email = 'testuser2@test123456789.com',CompanyName = 'test.com',Title = 'Test User',Username = 'testuser2@test123456789.com',Alias = 'testuser',CommunityNickname = 'TUser2',TimeZoneSidKey = 'America/Mexico_City',LocaleSidKey = 'en_US',EmailEncodingKey = 'ISO-8859-1',ProfileId = pfStdUser.Id,LanguageLocaleKey = 'en_US');
        insert u2;
        test.stopTest();
    }   */
    
     static testMethod void unitTestDecisionApproved () {
        // TO DO: implement unit test
        
        // insert Decision Record :
        test.startTest();
        Decision__c decision = new Decision__c();
        decision.Title__c = 'test Decision';
        decision.Problem_Idea_Advice__c = 'problem statement';
        decision.Priority__c = 'Normal';
        insert decision;
         
        Profile pfSysAdm = [Select Id from Profile where Name = 'System Administrator'];
        Profile pfStdUser = [Select Id from Profile where Name = 'System Administrator'];
        
            List<Task> listTaskRec = new List<Task>();
            for(integer i=0;i<200;i++){
                Task taskRec = new Task(Ownerid=UserInfo.getUserId(),Subject='test Task'+i,whatid=decision.id);
                listTaskRec.add(taskRec);
            }
            insert listTaskRec;
            
            // add social input record
            Social_Input__c socialInputRecord1 = new Social_Input__c(User__c=UserInfo.getUserId(),Description__c=decision.id,Responsible__c =true,Stance_Approval_Status__c='Approved');
            insert socialInputRecord1;
            Social_Input__c socialInputRecord2 = new Social_Input__c(User__c=UserInfo.getUserId(),Description__c=decision.id,Responsible__c =true);
            insert socialInputRecord2;
             system.debug('socialInputRecord2--->'+socialInputRecord2);
            List<Social_Input__c>  lstSocialRec = [Select id,Name from Social_Input__c where Decision__c=: decision.id];
            // System.assertEquals(lstSocialRec.size(), 10);
            // add decisionFeed
            FeedItem decisionFeed = new FeedItem (Body='Hello',ParentId=decision.id);
            insert decisionFeed;
            DecisionTab decisionTabObject = new DecisionTab();
        
              
        test.stopTest();
    }
    
    static testMethod void unitTestSocialTabUpdate () {
        // TO DO: implement unit test
        
        // insert Decision Record :
        test.startTest();
        Decision__c decision = new Decision__c();
        decision.Title__c = 'test Decision';
        decision.Problem_Idea_Advice__c = 'problem statement';
        decision.Priority__c = 'Normal';
        insert decision;
        String decisionId = String.valueOf(decision.id);
        String editedJsonString ='[{"unlikes":1,"title":"XX - Test Highlight 1.12223","socialRecord":{"attributes":{"type":"Social__c","url":"/services/data/v30.0/sobjects/Social__c/a0AO0000009K2jSMAS"},"Related_To_ID__c":"a06O000000JUlNpIAL","Avg_Mood__c":4,"Total_Likes__c":1,"Avg_Effort__c":4,"Total_Dislikes__c":1,"Avg_Result__c":3,"Total_Issues__c":0,"LastModifiedDate":"2014-02-14T09:42:44.000+0000","Id":"a0AO0000009K2jSMAS","Avg_Rating__c":3},"relevanceStars":null,"relevanceStarPosition":"0 -108px no-repeat","relevanceClass":null,"relevance":3,"outcome":"Medium","name":"XX - Test Highlight 1.1222","myRole":"Accountable","myMoodClass":"moodClass4","myMood":"4","moodImg":null,"moodClass":"moodClass4","likes":1,"lastActivityDate":"8/4/2014 12:57 PM","isEditable":true,"id":"'+decisionId+'","icon":"/resource/1396683622000/Images/newDecisionLifeCycle/LifeCycle-profilePic-130x130.jpg","effort":"High","averageMood":"4","accountable":"Manju S"}]';  
        
        //DecisionTab decisionTabObject = new DecisionTab();        
        DecisionTab.updateDecisionsSocial(editedJsonString,'Closed');
        test.stopTest();
    }
    
    static testMethod void unitTestFinancialTabUpdate () {
        // TO DO: implement unit test
        
        // insert Decision Record :
        test.startTest();
        Decision__c decision = new Decision__c();
        decision.Title__c = 'test Decision';
        decision.Problem_Idea_Advice__c = 'problem statement';
        decision.Priority__c = 'Normal';
        insert decision;
        String decisionId = String.valueOf(decision.id);
        String editedJsonString ='[{"title":"Add to Plan 333121231","revenuePercentColour":"emptyDuedateTask","revenuePercent":0,"revenueEstimate":0,"revenueActual":0,"peopleInvolvedPercentColour":"emptyDuedateTask","peopleInvolvedPercent":0,"peopleInvolvedinvestmentActual":0,"peopleInvolvedEstimate":0,"NPVPercentColour":"emptyDuedateTask","NPVPercent":0,"NPVEstimate":0,"NPVActual":0,"name":"Add to Plan 33312123","isEditableEstimate":true,"isEditableActual":false,"isEditable":true,"investmentPercentColour":"emptyDuedateTask","investmentPercent":0,"investmentEstimate":14,"investmentActual":0,"id":"'+decisionId+'","icon":"/resource/1396683622000/Images/newDecisionLifeCycle/LifeCycle-profilePic-130x130.jpg","FTEPercentColour":"emptyDuedateTask","FTEPercent":0,"FTEEstimate":0,"FTEActual":0,"directCostPercentColour":"emptyDuedateTask","directCostPercent":0,"directCostEstimate":5435,"directCostActual":0,"chkRecPermissionFinancial":false}]'; 
        
        //DecisionTab decisionTabObject = new DecisionTab();        
        DecisionTab.updateDecisionsFinancial(editedJsonString,'Closed');
        test.stopTest();
    }
    static testMethod void unitTestTabData () {
        // TO DO: implement unit test
        
        // insert Decision Record :
        test.startTest();
        Decision__c decision = new Decision__c();
        decision.Title__c = 'test Decision';
        decision.Problem_Idea_Advice__c = 'problem statement';
        decision.Priority__c = 'Normal';
        insert decision;
         
        Profile pfSysAdm = [Select Id from Profile where Name = 'System Administrator'];
        Profile pfStdUser = [Select Id from Profile where Name = 'System Administrator'];
        
        List<Task> listTaskRec = new List<Task>();
        for(integer i=0;i<200;i++){
            Task taskRec = new Task(Ownerid=UserInfo.getUserId(),Subject='test Task'+i,whatid=decision.id);
            listTaskRec.add(taskRec);
        }
        insert listTaskRec;
        List<Task> listTaskRecToUpdate = new List<Task>();
        for(integer i=0;i<listTaskRec.size();i++){
            Task taskRec = listTaskRec.get(i);
            taskRec.Subject='test Task'+i;
            listTaskRecToUpdate.add(taskRec);
        }
        update listTaskRecToUpdate;
        // add social input record
        Social_Input__c socialInputRecord1 = new Social_Input__c(User__c=UserInfo.getUserId(),Description__c=decision.id,Stance_Approval_Status__c='Approved');
        insert socialInputRecord1;
        Social_Input__c socialInputRecord2 = new Social_Input__c(User__c=UserInfo.getUserId(),Description__c=decision.id);
        insert socialInputRecord2;
        
        List<Social__c> SocialRecords = [Select id,Avg_Rating__c,Total_Rating__c from Social__c where Related_To_ID__c=:decision.id] ;
        
        for(integer i=0;i<SocialRecords.size();i++ ){
            if(i==0){
                SocialRecords.get(i).Total_Rating__c=2;
                SocialRecords.get(i).Rating_Count__c=1;
            }
        }
        update SocialRecords;
        // add decisionFeed
        FeedItem decisionFeed = new FeedItem (Body='Hello',ParentId=decision.id);
        insert decisionFeed;
        
        FeedItem taskFeed = new FeedItem (Body='Hello',ParentId=listTaskRecToUpdate.get(0).id);
        insert taskFeed;        
        //social Tab
        DecisionTab.buildSocialTabData('');
        // Financial Tab
        DecisionTab.buildFinancialTabData('');
        
        test.stopTest();
    }
}