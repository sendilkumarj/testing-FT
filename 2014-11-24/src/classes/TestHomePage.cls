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
private class TestHomePage {

    static testMethod void testHome() {
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
        User u = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' and isActive = true limit 1];
        
        User u1 = new User();
        u1.FirstName = 'Test';
        u1.LastName = 'User';
        u1.Email = 'testuser123@test123456789.com';
        u1.CompanyName = 'test.com';
        u1.Title = 'Test User';
        u1.Username = 'testuser123@test123456789.com';
        u1.Alias = 'testuser';
        u1.CommunityNickname = 'Test User123';
        u1.TimeZoneSidKey = 'America/Mexico_City';
        u1.LocaleSidKey = 'en_US';
        u1.EmailEncodingKey = 'ISO-8859-1';
        u1.ProfileId = pf.Id;
        u1.LanguageLocaleKey = 'en_US';
        
        insert u1;
        
        System.runAs(u){
            Decision__c decision = new Decision__c();
            Decision.Title__c = 'Test record';
            Decision.Priority__c = 'Normal';
            Decision.Problem_Idea_Advice__c = 'Problem';
            Decision.Phase__c = 'Share';
            insert Decision;
            
            Task t = new Task();
            t.Subject = 'new task';
            t.OwnerId = u1.Id;
            t.whatId = Decision.Id;
            t.Status = 'In Progress';
            t.activityDate = System.today();
            insert t;
            
            Task t1 = new Task();
            t1.Subject = 'new1 task';
            t1.OwnerId = u1.Id;
            t1.activityDate = System.today();
            t1.Status = 'In Progress';
            insert t1;
           
            system.debug('------createdby----->'+u1.Id);
            system.debug('------OwnerId----->'+t1.OwnerId);
            
           
            
            Social_Input__c socialInput = new Social_Input__c();
            socialInput.Decision__c = Decision.Id;
            socialInput.Responsible__c = true;
            socialInput.User__c = u1.Id;
            socialInput.Backup_for_Accountable__c = true;
            socialInput.Accountable__c = true;
            socialInput.Final_Approval_Status__c = 'Approved';
            insert socialInput;
            
            HomePage home = new HomePage();
            HomePage.updateMyTask(t.id,'Task change','Normal','In Progress', '10,12,2013');
            HomeChart homechart = new homeChart();
            HomePage.ApprovalWrapper aw = new HomePage.ApprovalWrapper();
            HomePage.UrgentApprovalWrapper uaw = new HomePage.UrgentApprovalWrapper();
            HomePage.urgentDecisionWrapper udw = new HomePage.urgentDecisionWrapper();
            HomePage.urgentTaskWrapper utw = new HomePage.urgentTaskWrapper();
            HomePage.myCollegueTaskWrapper mctw = new HomePage.myCollegueTaskWrapper();
            HomePage.Datum dt = new HomePage.Datum();
            HomePage.approvedReject1(Decision.Id,'','Rejected','Test','items');
            HomePage.RootObject ro = new HomePage.RootObject();
            HomePage.IssuesDatum is = new Homepage.IssuesDatum();
            HomePage.IssuesRootObject iro = new Homepage.IssuesRootObject();
            HomePage.data d = new HomePage.data();
            HomePage.dataWrap dw = new HomePage.dataWrap();
            Homepage.saveModifiedDataWithSearchTimeFrame('{"data":{"models":[{"title":"BBBDDDDCCCEEEE","status":"Not Started","relatedToId":null,"relatedTo":"","priority":"Normal","Id":"'+t.Id+'","DueDate":"2013-10-02T18:30:00.000Z","CreatedById":"005900000011dERAAY","CreatedBy":"Shirin Devangavi"}]}}','All','');
            Homepage.updateIssuesDataWithSearchTimeFrame('{"data":{"models":[{"type":"Quality","status":"Raised","relatedToObject":"New Decision for Approvals Tab on urgent","relatedToId":"a06N0000000xwh1IAA","priority":"High","ownerId":"005900000011dERAAY"}]}}','','');
            Homepage.myDecisions('Accountable');
            
            //List<ProcessInstanceWorkitem> proInstance = [Select p.ProcessInstance.Status, p.ProcessInstance.TargetObjectId, p.ProcessInstanceId, p.Id, p.CreatedDate, p.CreatedBy.Name, p.CreatedById, p.Actor.Name, p.ActorId From ProcessInstanceWorkitem p order by createddate desc limit 1];
            //if(!proInstance.isEmpty()){
                //Homepage.approvedRejectWithSearchTimeFrame(Decision.Id,proInstance[0].Id,'Approve','Test','items','24hours','Test');
            //}
        }
    }
    
    static testMethod void testHome5() {
        Decision__c decision = new Decision__c();
        Decision.Title__c = 'Test record';
        Decision.Priority__c = 'Normal';
        Decision.Problem_Idea_Advice__c = 'Problem';
        //Decision.Phase__c = 'Share';
        Decision.Phase__c = 'Propose';
        Decision.FeedItem_Id__c ='123';
        insert Decision;
        List<ProcessInstanceWorkitem> proInstance = [Select p.ProcessInstance.Status, p.ProcessInstance.TargetObjectId, p.ProcessInstanceId, p.Id, p.CreatedDate, p.CreatedBy.Name, p.CreatedById, p.Actor.Name, p.ActorId From ProcessInstanceWorkitem p order by createddate desc limit 1];
        if(!proInstance.isEmpty()){
            Homepage.approvedRejectWithSearchTimeFrame(Decision.Id,proInstance[0].Id,'Approve','Test','items','24hours','Test');
        }
    }
    
    static testMethod void testHome3() {
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];
        User u = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' and isActive = true limit 1];
        
        User u1 = new User();
        u1.FirstName = 'Test';
        u1.LastName = 'User';
        u1.Email = 'testuser123@test123456789.com';
        u1.CompanyName = 'test.com';
        u1.Title = 'Test User';
        u1.Username = 'testuser123@test123456789.com';
        u1.Alias = 'testuser';
        u1.CommunityNickname = 'Test User123';
        u1.TimeZoneSidKey = 'America/Mexico_City';
        u1.LocaleSidKey = 'en_US';
        u1.EmailEncodingKey = 'ISO-8859-1';
        u1.ProfileId = pf.Id;
        u1.LanguageLocaleKey = 'en_US';
        
        insert u1;
        
        System.runAs(u){
            Decision__c decision = new Decision__c();
            Decision.Title__c = 'Test record';
            Decision.Priority__c = 'Normal';
            Decision.Problem_Idea_Advice__c = 'Problem';
            Decision.Phase__c = 'Share';
            insert Decision;
            
            Task t = new Task();
            t.Subject = 'new task';
            t.OwnerId = u1.Id;
            t.whatId = Decision.Id;
            t.Status = 'In Progress';
            t.activityDate = System.today();
            insert t;
            
            Task t1 = new Task();
            t1.Subject = 'new1 task';
            t1.OwnerId = u1.Id;
            t1.activityDate = System.today();
            t1.Status = 'In Progress';
            insert t1;
           
            system.debug('------createdby----->'+u1.Id);
            system.debug('------OwnerId----->'+t1.OwnerId);
            
        
            
            Social_Input__c socialInput = new Social_Input__c();
            socialInput.Decision__c = Decision.Id;
            socialInput.Responsible__c = true;
            socialInput.User__c = u1.Id;
            socialInput.Backup_for_Accountable__c = true;
            socialInput.Accountable__c = true;
            socialInput.Final_Approval_Status__c = 'Approved';
            insert socialInput;
            
            Homepage.DecisionHighlist();
            Homepage.DefineHomeCharts();
            Homepage.myTasksWrapper tw = new Homepage.myTasksWrapper();
        }
    }
    
    static testMethod void testHome1() {
        
            Decision__c decision = new Decision__c();
            Decision.Title__c = 'Test record';
            Decision.Priority__c = 'Normal';
            Decision.Problem_Idea_Advice__c = 'Problem';
            Decision.Phase__c = 'Share';
            Decision.Nearest_Due_Date__c = System.today();
            insert Decision;
            
            HomePage home = new HomePage();
            HomePage.UrgentApprovalTabWithSearchTimeFrame('Test*','48hours');
            HomePage.UrgentApprovalTabWithSearchTimeFrame('Test*','7days');
            HomePage.UrgentApprovalTabWithSearchTimeFrame('Test*','1month');
            HomePage.UrgentApprovalTabWithSearchTimeFrame('Test*','All');
            HomePage.assignedTaskDataWithSearchTimeFrame('Test*','48hours');
            HomePage.assignedTaskDataWithSearchTimeFrame('Test*','7days');
            HomePage.assignedTaskDataWithSearchTimeFrame('Test*','1month');
            HomePage.assignedTaskDataWithSearchTimeFrame('Test*','All');
            HomePage.UrgentTaskTabWithSearchTimeFrame('Test*','48hours');
            HomePage.UrgentTaskTabWithSearchTimeFrame('Test*','7days');
            HomePage.UrgentTaskTabWithSearchTimeFrame('Test*','1month');
            HomePage.UrgentTaskTabWithSearchTimeFrame('Test*','All');
            HomePage.UrgentDecisionTabWithSearchTimeFrame('Test*','48hours');
            HomePage.UrgentDecisionTabWithSearchTimeFrame('Test*','7days');
            HomePage.UrgentDecisionTabWithSearchTimeFrame('Test*','1month');
            HomePage.UrgentDecisionTabWithSearchTimeFrame('Test*','All');
    }
    
    static testMethod void testHome2() {
        
            Profile pf = [Select Id from Profile where Name = 'System Administrator'];
        
            Decision__c decision = new Decision__c();
            Decision.Title__c = 'Test record';
            Decision.Priority__c = 'Normal';
            Decision.Problem_Idea_Advice__c = 'Problem';
            Decision.Phase__c = 'Execute';
            Decision.Nearest_Due_Date__c = System.today();
            insert Decision;
            
          
            
            Social_Input__c socialInput = new Social_Input__c();
            socialInput.Decision__c = Decision.Id;
            socialInput.Accountable__c = true;
            socialInput.User__c = Userinfo.getUserId();
            socialInput.Backup_for_Accountable__c = true;
            socialInput.Accountable__c = true;
            socialInput.Final_Approval_Status__c = 'Approved';
            insert socialInput;
            
            Social_Input__c socialInput2 = new Social_Input__c();
            socialInput2.Decision__c = Decision.Id;
            socialInput2.Consulted__c = true;
            socialInput2.User__c = Userinfo.getUserId();
            socialInput2.Final_Approval_Status__c = 'Approved';
            insert socialInput2;
            
            User u1 = new User();
            u1.FirstName = 'Test';
            u1.LastName = 'User';
            u1.Email = 'testuser123@test123456789.com';
            u1.CompanyName = 'test.com';
            u1.Title = 'Test User';
            u1.Username = 'testuser123@test123456789.com';
            u1.Alias = 'testuser';
            u1.CommunityNickname = 'Test User123';
            u1.TimeZoneSidKey = 'America/Mexico_City';
            u1.LocaleSidKey = 'en_US';
            u1.EmailEncodingKey = 'ISO-8859-1';
            u1.ProfileId = pf.Id;
            u1.LanguageLocaleKey = 'en_US';
            insert u1;
            
            Social_Input__c socialInput1 = new Social_Input__c();
            socialInput1.Decision__c = Decision.Id;
            socialInput1.Accountable__c = true;
            socialInput1.User__c = u1.Id;
            socialInput1.Backup_for_Accountable__c = true;
            socialInput1.Accountable__c = true;
            socialInput1.Final_Approval_Status__c = 'Pending Approval';
            insert socialInput1;
            
            Task t1 = new Task();
            t1.Subject = 'new1 task';
            t1.OwnerId = Userinfo.getUserId();
            t1.activityDate = System.today();
            t1.Status = 'In Progress';
            insert t1;
            
            HomePage home = new HomePage();
            HomePage.pendingApprovalsWithSearchTimeFrame('Test*','48hours');
            HomePage.pendingApprovalsWithSearchTimeFrame('Test*','7days');
            HomePage.pendingApprovalsWithSearchTimeFrame('Test*','1month');
            HomePage.pendingApprovalsWithSearchTimeFrame('Test*','All');
            //HomePage.urgentIssuesTabWithSearchTimeFrame('Test*','48hours');
            //HomePage.urgentIssuesTabWithSearchTimeFrame('Test*','7days');
            //HomePage.urgentIssuesTabWithSearchTimeFrame('Test*','1month');
            //HomePage.urgentIssuesTabWithSearchTimeFrame('Test*','All');
    }
    
    static testMethod void testHome4() {
        HomePage.urgentIssuesTabWithSearchTimeFrame('Test*','48hours');
        HomePage.urgentIssuesTabWithSearchTimeFrame('Test*','7days');
        HomePage.urgentIssuesTabWithSearchTimeFrame('Test*','1month');
        HomePage.urgentIssuesTabWithSearchTimeFrame('Test*','All');
    }
    static testMethod void testHome6(){
        HomePage.UrgentTabsCount('' , '');
        HomePage.UrgentTabsCount('24hours' , '');
        HomePage.UrgentTabsCount('48hours' , '');
        HomePage.UrgentTabsCount('1month' , '');
        HomePage.UrgentTabsCount('All' , '');
        HomePage.UrgentTabsCount('' , '123');
        HomePage.UrgentTabsCount('24hours' , '123');
        HomePage.UrgentTabsCount('48hours' , '123');
        HomePage.UrgentTabsCount('1month' , '123');
        HomePage.UrgentTabsCount('All' , '123'); 
        
    }
    
    
   
     static testMethod void testHome8(){
    Long now = System.now().gettime();
    
        
        HomePage.viewImportantColumnCards(false,'ADPT',now ,32503660200000L ,now+604800000L );
        HomePage.viewImportantColumnCards(false,'ADPT',now ,0,0 );
    
    
    }
    static testMethod void testHome9(){
        HomePage.importantCount( 'ADPT');
        
    }
    
   static testMethod void testHome7(){
    Long now = System.now().gettime();
    
        HomePage.viewImportantColumnCards(false,'ADPT',now ,now,0);
         
    
    }
    static testMethod void testHome10(){
    Long now = System.now().gettime();
    
        HomePage.viewImportantColumnCards(false,'ADPT',now ,now+86400000L,0 );
        
    
    }
    static testMethod void testHome11(){
    Long now = System.now().gettime();
    
         HomePage.viewImportantColumnCards(false,'ADPT',now ,now+604800000L,now+ 86400000L );
        
    
    }
}