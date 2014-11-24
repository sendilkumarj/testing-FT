@istest
public class TestTempAddEditPeople{
     public static testMethod void testAddEditPeople1(){
         test.startTest();
            Decision__c decisionRec = new Decision__c(title__c = 'Test decision',Problem_Idea_Advice__c = 'Problem',Decision_Taken__c = 'Decision',Priority__c = 'Normal',Status__c ='Propose');
            insert decisionRec;
            Social_Input__c si = [Select id,Is_Group__c from Social_Input__c where Decision__c =:decisionRec.id ];
            si.Is_Group__c = true;
        	Update si;
         	Profile pf = [Select Id from Profile where Name = 'System Administrator'];    
            User u1 = new User(FirstName = 'Test',LastName = 'User2',Email = 'testuser@test123456789.com',CompanyName = 'test.com',Title = 'Test User',Username = 'testuser15@2.com',Alias = 'testu2',CommunityNickname = 'TestUser2',TimeZoneSidKey = 'America/Mexico_City',LocaleSidKey = 'en_US',EmailEncodingKey = 'ISO-8859-1',ProfileId = pf.Id,LanguageLocaleKey = 'en_US');
            insert u1;
          System.runAs(u1){
            ApexPages.currentPage().getParameters().put('id',decisionRec.id);		
            ApexPages.currentPage().getParameters().put('objType','Decision');
         	 ApexPages.currentPage().getParameters().put('searchText','Test');
            ApexPages.currentPage().getParameters().put('searchType','User');
           ApexPages.currentPage().getParameters().put('selectedUsers',u1.id);		
            ApexPages.currentPage().getParameters().put('userType','User');
         	ApexPages.currentPage().getParameters().put('addingAsResponsible','responsibleReqd');

           AddEditPeople aep =new AddEditPeople();

       		aep.searchUsers();
            try {	
            	aep.addingUserBasedOnType();
            } catch (exception e){
            	
            }
            ApexPages.currentPage().getParameters().put('selectedUserswrap',u1.id);		
            ApexPages.currentPage().getParameters().put('userTypewrap','User');
         	ApexPages.currentPage().getParameters().put('addingAsResponsible','responsibleReqd');
			try { 	
			 	aep.addinWrapeerUserBasedOnType();
         	} catch (exception e){
            	
            }
         test.stopTest();
          }
    }
    public static testMethod void testAddEditPeople2(){
         test.startTest();
            Decision__c decisionRec = new Decision__c(title__c = 'Test decision',Problem_Idea_Advice__c = 'Problem',Decision_Taken__c = 'Decision',Priority__c = 'Normal',Status__c ='Propose');
            insert decisionRec;
            Social_Input__c si = [Select id,Is_Group__c from Social_Input__c where Decision__c =:decisionRec.id ];
            si.Is_Group__c = true;
        	Update si;
         	Profile pf = [Select Id from Profile where Name = 'System Administrator'];    
            User u1 = new User(FirstName = 'Test',LastName = 'User2',Email = 'testuser@test123456789.com',CompanyName = 'test.com',Title = 'Test User',Username = 'testuser15@2.com',Alias = 'testu2',CommunityNickname = 'TestUser2',TimeZoneSidKey = 'America/Mexico_City',LocaleSidKey = 'en_US',EmailEncodingKey = 'ISO-8859-1',ProfileId = pf.Id,LanguageLocaleKey = 'en_US');
            insert u1;
          System.runAs(u1){
              Group g = new Group();
          g.name = 'NewGroup';
          insert g;
          
          GroupMember gm = new  GroupMember();
          gm.groupId = g.Id;
          gm.UserOrGroupId = u1.Id;
          insert gm;
              
            ApexPages.currentPage().getParameters().put('id',decisionRec.id);		
            ApexPages.currentPage().getParameters().put('objType','Decision');
         	 ApexPages.currentPage().getParameters().put('searchText','NewGroup');
            ApexPages.currentPage().getParameters().put('searchType','Group');
           ApexPages.currentPage().getParameters().put('selectedUsers',g.id);		
            ApexPages.currentPage().getParameters().put('userType','Group');
         	ApexPages.currentPage().getParameters().put('addingAsResponsible','responsibleReqd');

           AddEditPeople aep =new AddEditPeople();
              
          
             ApexPages.currentPage().getParameters().put('selectedUserswrap',g.id);		
             ApexPages.currentPage().getParameters().put('userTypewrap','Group');
             ApexPages.currentPage().getParameters().put('addingAsResponsiblewrap','responsibleReqd');
           aep.searchUsers();
              
              try{
              aep.addingUserBasedOnType();
              aep.addinWrapeerUserBasedOnType();
              }catch(exception e){}  
              
              aep.dummyRender();
              aep.savePeople();
              aep.saveCurrentPeople();
              AddEditPeople.retrieveGroupMember(g.id);
              aep.cancel();
              
             test.stopTest();
              
          }
        
    }
    public static testMethod void testAddEditPeople3(){
         test.startTest();
            Decision__c decisionRec = new Decision__c(title__c = 'Test decision',Problem_Idea_Advice__c = 'Problem',Decision_Taken__c = 'Decision',Priority__c = 'Normal',Status__c ='Propose');
            insert decisionRec;
            Social_Input__c si = [Select id,Is_Group__c from Social_Input__c where Decision__c =:decisionRec.id ];
            si.Is_Group__c = true;
        	Update si;
         	Profile pf = [Select Id from Profile where Name = 'System Administrator'];    
            User u1 = new User(FirstName = 'Test',LastName = 'User2',Email = 'testuser@test123456789.com',CompanyName = 'test.com',Title = 'Test User',Username = 'testuser15@2.com',Alias = 'testu2',CommunityNickname = 'TestUser2',TimeZoneSidKey = 'America/Mexico_City',LocaleSidKey = 'en_US',EmailEncodingKey = 'ISO-8859-1',ProfileId = pf.Id,LanguageLocaleKey = 'en_US');
            insert u1;
          System.runAs(u1){
              Group g = new Group();
          g.name = 'NewGroup';
          insert g;
          
          GroupMember gm = new  GroupMember();
          gm.groupId = g.Id;
          gm.UserOrGroupId = u1.Id;
          insert gm;
              
            ApexPages.currentPage().getParameters().put('id',decisionRec.id);		
            ApexPages.currentPage().getParameters().put('objType','Decision');
         	 ApexPages.currentPage().getParameters().put('searchText','NewGroup');
            ApexPages.currentPage().getParameters().put('searchType','Group');
           ApexPages.currentPage().getParameters().put('selectedUsers',g.id);		
            ApexPages.currentPage().getParameters().put('userType','Group');
         	ApexPages.currentPage().getParameters().put('addingAsResponsible','responsibleReqd');

           AddEditPeople aep =new AddEditPeople();
              
          
             ApexPages.currentPage().getParameters().put('selectedUserswrap',g.id);		
             ApexPages.currentPage().getParameters().put('userTypewrap','Group');
             ApexPages.currentPage().getParameters().put('addingAsResponsiblewrap','responsibleReqd');
           
                aep.deleteThisSocialInput();
              aep.deletePeople();
             test.stopTest();
          }
        
    }
    
     public static testMethod void testAddEditPeople4(){
         test.startTest();
            Decision__c decisionRec = new Decision__c(title__c = 'Test decision',Problem_Idea_Advice__c = 'Problem',Decision_Taken__c = 'Decision',Priority__c = 'Normal',Status__c ='Propose');
            insert decisionRec;
            Social_Input__c si = [Select id,Is_Group__c from Social_Input__c where Decision__c =:decisionRec.id ];
            si.Is_Group__c = true;
        	Update si;
         	Profile pf = [Select Id from Profile where Name = 'System Administrator'];    
            User u1 = new User(FirstName = 'Test',LastName = 'User2',Email = 'testuser@test123456789.com',CompanyName = 'test.com',Title = 'Test User',Username = 'testuser15@2.com',Alias = 'testu2',CommunityNickname = 'TestUser2',TimeZoneSidKey = 'America/Mexico_City',LocaleSidKey = 'en_US',EmailEncodingKey = 'ISO-8859-1',ProfileId = pf.Id,LanguageLocaleKey = 'en_US');
            insert u1;
          System.runAs(u1){
              Group g = new Group();
          g.name = 'NewGroup';
          insert g;
          
          GroupMember gm = new  GroupMember();
          gm.groupId = g.Id;
          gm.UserOrGroupId = u1.Id;
          insert gm;
              
            ApexPages.currentPage().getParameters().put('id',decisionRec.id);		
            ApexPages.currentPage().getParameters().put('objType','Decision');
         	 ApexPages.currentPage().getParameters().put('searchText','NewGroup');
            ApexPages.currentPage().getParameters().put('searchType','Group');
           ApexPages.currentPage().getParameters().put('selectedUsers',g.id);		
            ApexPages.currentPage().getParameters().put('userType','Group');
         	ApexPages.currentPage().getParameters().put('addingAsInformed','informedReqdasgrp');

           AddEditPeople aep =new AddEditPeople();
              
          
             ApexPages.currentPage().getParameters().put('selectedUserswrap',g.id);		
             ApexPages.currentPage().getParameters().put('userTypewrap','Group');
             ApexPages.currentPage().getParameters().put('addingAsInformedwrap','informedReqdasgrp');
           aep.searchUsers();
               aep.addingUserBasedOnType();
             try { 
              aep.addinWrapeerUserBasedOnType();
             } catch (exception e){
            	
            }
              aep.dummyRender();
              aep.savePeople();
              aep.saveCurrentPeople();
              AddEditPeople.retrieveGroupMember(g.id);
              aep.cancel();
              
             test.stopTest();
              
          }
        
    }

    public static testMethod void testAddEditPeople5(){
    	
    	Profile pf = [Select Id from Profile where Name = 'System Administrator'];    
    	
    	Plan__c p = new Plan__c();
    	p.Name = 'new Plan';
    	insert p;
    	
      	User u1 = new User(FirstName = 'Test',LastName = 'User2',Email = 'testuser@test123456789.com',CompanyName = 'test.com',Title = 'Test User',Username = 'testuser15@2.com',Alias = 'testu2',CommunityNickname = 'TestUser2',TimeZoneSidKey = 'America/Mexico_City',LocaleSidKey = 'en_US',EmailEncodingKey = 'ISO-8859-1',ProfileId = pf.Id,LanguageLocaleKey = 'en_US');
        insert u1;
      	System.runAs(u1){
      		
      		Group g = new Group();
	      	g.name = 'NewGroup';
	      	insert g;
	      	
	      	Group g1 = new Group();
	      	g1.name = 'NewGroup';
	      	insert g1;
      		
	      	GroupMember gm = new  GroupMember();
	      	gm.groupId = g.Id;
	      	gm.UserOrGroupId = u1.Id;
	      	insert gm;
	    	
	    	GroupMember gm1 = new  GroupMember();
	      	gm1.groupId = g.Id;
	      	gm1.UserOrGroupId = g1.Id;
	      	insert gm1;
	    	
	    	List<GroupMember> lstGm = new List<GroupMember>();
	    	lstGm.add(gm);
	    	
	    	List<User> lstUser = new List<User>();
	    	
	    	lstUser.add(u1);
	    	
	    	ApexPages.currentPage().getParameters().put('objType','Plan');
	    	ApexPages.currentPage().getParameters().put('id',p.id);	
	    	AddEditPeople aep =new AddEditPeople();
	    	aep.extractGrpWithInGrp(g.Id,gm.Id,lstGm,lstUser);
      	}
    }
}