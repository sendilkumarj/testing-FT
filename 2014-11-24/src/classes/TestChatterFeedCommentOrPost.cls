@IsTest(SeeAllData=true)
public class TestChatterFeedCommentOrPost{
     public static testMethod void testFeedCommnetOrPost1(){
            test.startTest();
            Decision__c decision = new Decision__c(title__c = 'Test decision',Problem_Idea_Advice__c = 'Problem',Decision_Taken__c = 'Decision',Priority__c = 'Normal');
            insert decision;
            
            Decision__c UpdatedDec1 = [Select id, phase__c from Decision__c where id=:decision.id];
            System.assertEquals(UpdatedDec1.phase__c, 'Draft');
          
            Profile pf = [Select Id from Profile where Name = 'System Administrator'];         
            User u1 = new User(FirstName = 'Test',LastName = 'User1',Email = 'testuser@test123456789.com',CompanyName = 'test.com',Title = 'Test User',Username = 'testuser15@1.com',Alias = 'testu1',CommunityNickname = 'TestUser1',TimeZoneSidKey = 'America/Mexico_City',LocaleSidKey = 'en_US',EmailEncodingKey = 'ISO-8859-1',ProfileId = pf.Id,LanguageLocaleKey = 'en_US');
            insert u1;
             
            User u2 = new User(FirstName = 'Test',LastName = 'User2',Email = 'testuser@test123456789.com',CompanyName = 'test.com',Title = 'Test User',Username = 'testuser15@2.com',Alias = 'testu2',CommunityNickname = 'TestUser2',TimeZoneSidKey = 'America/Mexico_City',LocaleSidKey = 'en_US',EmailEncodingKey = 'ISO-8859-1',ProfileId = pf.Id,LanguageLocaleKey = 'en_US');
            insert u2;
        
            
            System.runAs(u1){
                Social_Input__c sIAcc = new Social_Input__c(User__c=u1.id,Decision__c=decision.id,Accountable__c=true);
                insert sIAcc;
                DecisionView.decisionPhaseChange(String.valueof(decision.id),String.Valueof(sIAcc.id),'Share','','') ;
                Social_Input__c sICon = new Social_Input__c(User__c=u2.id,Decision__c=decision.id,Consulted__c=true);
                insert sICon;
                Social_Input__c sIRes = new Social_Input__c(User__c=u2.id,Decision__c=decision.id,Responsible__c=true);
                insert sIRes;
                Social_Input__c sIBackUp = new Social_Input__c(User__c=u2.id,Decision__c=decision.id,Backup_for_Accountable__c=true,Responsible__c=true,Consulted__c=true);
                insert sIBackUp;
                Social_Input__c sIBackUpNotCon = new Social_Input__c(User__c=u2.id,Decision__c=decision.id,Backup_for_Accountable__c=true,Responsible__c=true,Consulted__c=false);
                insert sIBackUpNotCon;
             }
    }   
     
    public static testMethod void testFeedCommnetOrPost1Dup(){
        test.startTest();
        Decision__c decision = new Decision__c(title__c = 'Test decision',Problem_Idea_Advice__c = 'Problem',Decision_Taken__c = 'Decision',Priority__c = 'Normal');
        insert decision;
        
        Decision__c UpdatedDec1 = [Select id, phase__c from Decision__c where id=:decision.id];
        System.assertEquals(UpdatedDec1.phase__c, 'Draft');
        
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];         
        User u1 = new User(FirstName = 'Test',LastName = 'User1',Email = 'testuser@test123456789.com',CompanyName = 'test.com',Title = 'Test User',Username = 'testuser15@1.com',Alias = 'testu1',CommunityNickname = 'TestUser1',TimeZoneSidKey = 'America/Mexico_City',LocaleSidKey = 'en_US',EmailEncodingKey = 'ISO-8859-1',ProfileId = pf.Id,LanguageLocaleKey = 'en_US');
        insert u1;
        
        User u2 = new User(FirstName = 'Test',LastName = 'User2',Email = 'testuser@test123456789.com',CompanyName = 'test.com',Title = 'Test User',Username = 'testuser15@2.com',Alias = 'testu2',CommunityNickname = 'TestUser2',TimeZoneSidKey = 'America/Mexico_City',LocaleSidKey = 'en_US',EmailEncodingKey = 'ISO-8859-1',ProfileId = pf.Id,LanguageLocaleKey = 'en_US');
        insert u2;
        
        
        System.runAs(u1){
            Social_Input__c sIAcc = new Social_Input__c(User__c=u1.id,Decision__c=decision.id,Accountable__c=true);
            insert sIAcc;
            DecisionView.decisionPhaseChange(String.valueof(decision.id),String.Valueof(sIAcc.id),'Share','','') ;
            Social_Input__c sIResponsible_Consulted = new Social_Input__c(User__c=u2.id,Decision__c=decision.id,Backup_for_Accountable__c=true,Informed__c=true,Responsible__c = false,Consulted__c = false);  
            insert sIResponsible_Consulted; 
            Social_Input__c sINonRes= new Social_Input__c(User__c=u2.id,Decision__c=decision.id,Backup_for_Accountable__c=true,Informed__c=true,Responsible__c = false,Consulted__c = true);  
            insert sINonRes;
            Social_Input__c sINonAccNonBack= new Social_Input__c(User__c=u2.id,Decision__c=decision.id,Accountable__c =false,Backup_for_Accountable__c=false,Informed__c=true,Responsible__c = true,Consulted__c = true);  
            insert sINonAccNonBack;
        }
    }  
    public static testMethod void testFeedCommnetOrPostDelete(){
        test.startTest();
        Decision__c decision = new Decision__c(title__c = 'Test decision',Problem_Idea_Advice__c = 'Problem',Decision_Taken__c = 'Decision',Priority__c = 'Normal');
        insert decision;
        
        Decision__c UpdatedDec1 = [Select id, phase__c from Decision__c where id=:decision.id];
        System.assertEquals(UpdatedDec1.phase__c, 'Draft');
        
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];         
        User u1 = new User(FirstName = 'Test',LastName = 'User1',Email = 'testuser@test123456789.com',CompanyName = 'test.com',Title = 'Test User',Username = 'testuser15@1.com',Alias = 'testu1',CommunityNickname = 'TestUser1',TimeZoneSidKey = 'America/Mexico_City',LocaleSidKey = 'en_US',EmailEncodingKey = 'ISO-8859-1',ProfileId = pf.Id,LanguageLocaleKey = 'en_US');
        insert u1;
        
        User u2 = new User(FirstName = 'Test',LastName = 'User2',Email = 'testuser@test123456789.com',CompanyName = 'test.com',Title = 'Test User',Username = 'testuser15@2.com',Alias = 'testu2',CommunityNickname = 'TestUser2',TimeZoneSidKey = 'America/Mexico_City',LocaleSidKey = 'en_US',EmailEncodingKey = 'ISO-8859-1',ProfileId = pf.Id,LanguageLocaleKey = 'en_US');
        insert u2;
        
        
        System.runAs(u1){
            Social_Input__c sIAcc = new Social_Input__c(User__c=u1.id,Decision__c=decision.id,Accountable__c=true);
            insert sIAcc;
            DecisionView.decisionPhaseChange(String.valueof(decision.id),String.Valueof(sIAcc.id),'Share','','') ;
            Social_Input__c sIResponsible_Consulted = new Social_Input__c(User__c=u2.id,Decision__c=decision.id,Backup_for_Accountable__c=true,Informed__c=true,Responsible__c = false,Consulted__c = false);  
            insert sIResponsible_Consulted; 
            FeedItem Fd = [Select id,parentid from FeedItem where parentid=:decision.id order by CreatedDate limit 1];
            delete Fd;
            
            Social_Input__c sINonRes= new Social_Input__c(User__c=u2.id,Decision__c=decision.id,Backup_for_Accountable__c=true,Informed__c=true,Responsible__c = false,Consulted__c = true);  
            insert sINonRes;
            
            
        }
    }
    public static testMethod void testFeedPostDeletePropose(){
        
        Decision__c decision = new Decision__c(title__c = 'Test decision',Problem_Idea_Advice__c = 'Problem',Decision_Taken__c = 'Decision',Priority__c = 'Normal',Phase__c ='Share');
        insert decision;
         
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];         
        User u1 = new User(FirstName = 'Test',LastName = 'User1',Email = 'testuser@test123456789.com',CompanyName = 'test.com',Title = 'Test User',Username = 'testuser15@1.com',Alias = 'testu1',CommunityNickname = 'TestUser1',TimeZoneSidKey = 'America/Mexico_City',LocaleSidKey = 'en_US',EmailEncodingKey = 'ISO-8859-1',ProfileId = pf.Id,LanguageLocaleKey = 'en_US');
        insert u1;
        
        User u2 = new User(FirstName = 'Test',LastName = 'User2',Email = 'testuser@test123456789.com',CompanyName = 'test.com',Title = 'Test User',Username = 'testuser15@2.com',Alias = 'testu2',CommunityNickname = 'TestUser2',TimeZoneSidKey = 'America/Mexico_City',LocaleSidKey = 'en_US',EmailEncodingKey = 'ISO-8859-1',ProfileId = pf.Id,LanguageLocaleKey = 'en_US');
        insert u2;
       
        System.runAs(u1){
           /* Social_Input__c sIAcc = new Social_Input__c(User__c=u1.id,Decision__c=decision.id,Accountable__c=true);
       		insert sIAcc;
            DecisionView.decisionPhaseChange(String.valueof(decision.id),String.Valueof(sIAcc.id),'Share','','') ;
            DecisionView.decisionPhaseChange(String.valueof(decision.id),String.Valueof(sIAcc.id),'Propose','','') ;
            test.startTest();
            Social_Input__c sIResponsible_Consulted = new Social_Input__c(User__c=u2.id,Decision__c=decision.id,Backup_for_Accountable__c=true,Informed__c=true,Responsible__c = false,Consulted__c = false);  
            insert sIResponsible_Consulted; 
            FeedItem Fd = [Select id,parentid from FeedItem where parentid=:decision.id order by CreatedDate desc limit 1];
            delete Fd;
            Social_Input__c sINonAccNonBack= new Social_Input__c(User__c=u2.id,Decision__c=decision.id,Accountable__c =false,Backup_for_Accountable__c=false,Informed__c=true,Responsible__c = true,Consulted__c = true);  
            insert sINonAccNonBack;
            test.stopTest();*/
        }
    }
    public static testMethod void testFeedPostDeleteExecute(){
        
        Decision__c decision = new Decision__c(title__c = 'Test decision',Problem_Idea_Advice__c = 'Problem',Decision_Taken__c = 'Decision',Priority__c = 'Normal',Phase__c ='Share');
        insert decision;
         
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];         
        User u1 = new User(FirstName = 'Test',LastName = 'User1',Email = 'testuser@test123456789.com',CompanyName = 'test.com',Title = 'Test User',Username = 'testuser15@1.com',Alias = 'testu1',CommunityNickname = 'TestUser1',TimeZoneSidKey = 'America/Mexico_City',LocaleSidKey = 'en_US',EmailEncodingKey = 'ISO-8859-1',ProfileId = pf.Id,LanguageLocaleKey = 'en_US');
        insert u1;
        
        User u2 = new User(FirstName = 'Test',LastName = 'User2',Email = 'testuser@test123456789.com',CompanyName = 'test.com',Title = 'Test User',Username = 'testuser15@2.com',Alias = 'testu2',CommunityNickname = 'TestUser2',TimeZoneSidKey = 'America/Mexico_City',LocaleSidKey = 'en_US',EmailEncodingKey = 'ISO-8859-1',ProfileId = pf.Id,LanguageLocaleKey = 'en_US');
        insert u2;
       
        System.runAs(u1){
            Social_Input__c sIAcc = new Social_Input__c(User__c=u1.id,Decision__c=decision.id,Accountable__c=true);
       		insert sIAcc;
            DecisionView.decisionPhaseChange(String.valueof(decision.id),String.Valueof(sIAcc.id),'Share','','') ;
            //DecisionView.decisionPhaseChange(String.valueof(decision.id),String.Valueof(sIAcc.id),'Propose','','') ;
            DecisionView.decisionPhaseChange(String.valueof(decision.id),String.Valueof(sIAcc.id),'Execute','','') ;
            
            Social_Input__c sIResponsible_Consulted = new Social_Input__c(User__c=u1.id,Decision__c=decision.id,Backup_for_Accountable__c=true,Informed__c=true,Responsible__c = false,Consulted__c = false);  
            
            insert sIResponsible_Consulted; 
            FeedItem Fd = [Select id,parentid from FeedItem where parentid=:decision.id order by CreatedDate desc limit 1];
            delete Fd;
            test.startTest();
            Social_Input__c sINonAccNonBack= new Social_Input__c(User__c=u1.id,Decision__c=decision.id,Accountable__c =false,Backup_for_Accountable__c=false,Informed__c=true,Responsible__c = true,Consulted__c = true);  
            insert sINonAccNonBack;
            test.stopTest();
        }
    }
}