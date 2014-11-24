@IsTest
public class Test_Sf1_AddEdit {
    public static testMethod void testSf1_AddEdit(){
        Decision__c decision = new Decision__c(title__c = 'Test decision',Problem_Idea_Advice__c = 'Problem',Decision_Taken__c = 'Decision',Priority__c = 'Normal');
            insert decision;
         Profile pf = [Select Id from Profile where Name = 'System Administrator'];         
            User u1 = new User(FirstName = 'Test',LastName = 'User1',Email = 'testuser@test123456789.com',CompanyName = 'test.com',Title = 'Test User',Username = 'testuser15@1.com',Alias = 'testu1',CommunityNickname = 'TestUser1',TimeZoneSidKey = 'America/Mexico_City',LocaleSidKey = 'en_US',EmailEncodingKey = 'ISO-8859-1',ProfileId = pf.Id,LanguageLocaleKey = 'en_US');
            insert u1;
             
            User u2 = new User(FirstName = 'Test',LastName = 'User2',Email = 'testuser@test123456789.com',CompanyName = 'test.com',Title = 'Test User',Username = 'testuser15@2.com',Alias = 'testu2',CommunityNickname = 'TestUser2',TimeZoneSidKey = 'America/Mexico_City',LocaleSidKey = 'en_US',EmailEncodingKey = 'ISO-8859-1',ProfileId = pf.Id,LanguageLocaleKey = 'en_US');
            insert u2;
        ApexPages.StandardController sc = new ApexPages.StandardController(decision);
        System.runAs(u1){
            SF1_AddEditPeople sf = new SF1_AddEditPeople(sc);
            sf.listOfCollaborator();
            string uid = u1.Id+','+u2.Id;
            SF1_AddEditPeople.addCollaborator(uid, string.valueOf(decision.Id));
           // sf.addCollaborator1();
        }
    }

}