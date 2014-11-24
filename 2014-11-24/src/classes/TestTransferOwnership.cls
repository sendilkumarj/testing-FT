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

@istest
public class TestTransferOwnership{
	
    public static testMethod void testTransferOwnershipForPlan(){
        test.startTest();
            // plan rec  
            List<Plan__c> testPlanRecList = new List<Plan__c>();
        	Map<id,id> planOldOwners = new Map<id,id>();
        	Map<id,id> planNewOwners = new Map<id,id>();
        	Set<id> planIds = new Set<id>();
            for(integer i=0;i<200;i++){
                Plan__c lPlan = new Plan__c(Name='Test Plan Rec '+i );
                testPlanRecList.add(lPlan);
            }
        	// insert as "Test User1" user.
        	Profile pf = [Select Id from Profile where Name = 'System Administrator'];
        	User u = new User(FirstName = 'Test',LastName = 'User1',Email = 'testuser1@test123456789.com',CompanyName = 'test.com',Title = 'Test User1',Username = 'testuser1@test123456789.com',Alias = 'tuser1',CommunityNickname = 'TestUser1',TimeZoneSidKey = 'America/Mexico_City',LocaleSidKey = 'en_US',EmailEncodingKey = 'ISO-8859-1',ProfileId = pf.Id,LanguageLocaleKey = 'en_US');
        	insert u;
          	User u2 = new User(FirstName = 'Test',LastName = 'User2',Email = 'testuser2@test123456789.com',CompanyName = 'test.com',Title = 'Test User2',Username = 'testuser2@test123456789.com',Alias = 'tuser2',CommunityNickname = 'TestUser2',TimeZoneSidKey = 'America/Mexico_City',LocaleSidKey = 'en_US',EmailEncodingKey = 'ISO-8859-1',ProfileId = pf.Id,LanguageLocaleKey = 'en_US');
        	insert u2;
        	System.runAs(u){
        		insert testPlanRecList;
    		}
            
        	// get all the plan ids, old owner and change the owner.
            List<Plan__c> testPlanRecUpdate = new List<Plan__c>();
        	for(integer i=0;i<testPlanRecList.size();i++ ){
                	planIds.add(testPlanRecList.get(i).id);
                	planOldOwners.put(testPlanRecList.get(i).id,testPlanRecList.get(i).OwnerId);
                	planNewOwners.put(testPlanRecList.get(i).id,U2.id);
                	// test
                		testPlanRecList.get(i).OwnerId = U2.id;
                		testPlanRecUpdate.add(testPlanRecList.get(i));
                	// 
            }
        	update testPlanRecUpdate;
        	TransferOwnership.transferOwnershipForPlan(planIds, planOldOwners, planNewOwners);
        test.stopTest();
        
    }
    
    public static testMethod void testTransferOwnershipForDecision(){
        test.startTest();
        	List<Decision__c> testDecisionRecList = new List<Decision__c>();
        	Map<id,id> DecisionOldOwners = new Map<id,id>();
        	Map<id,id> DecisionNewOwners = new Map<id,id>();
        	Set<id> DecisionIds = new Set<id>();
            for(integer i=0;i<20;i++){
                Decision__c lDecision = new Decision__c(Title__c = 'Decision test class'+i ,Decision_Taken__c = 'Test decision',Problem_Idea_Advice__c = 'decision problem stateent ',Due_Date__c = Datetime.now(),Phase__c = 'Draft',Priority__c = 'High',Private__c = true);
                testDecisionRecList.add(lDecision);
            }
        	// insert as "Test User1" user.
        	insert testDecisionRecList;
            
        	// get all the plan ids, old owner and change the owner.
            List<Decision__c> testDecisionRecUpdate = new List<Decision__c>();
        	for(integer i=0;i<testDecisionRecList.size();i++ ){
                	DecisionIds.add(testDecisionRecList.get(i).id);
                	DecisionOldOwners.put(testDecisionRecList.get(i).id,testDecisionRecList.get(i).OwnerId);
                	DecisionNewOwners.put(testDecisionRecList.get(i).id,UserInfo.getUserId());
                	// test
                		testDecisionRecList.get(i).OwnerId = UserInfo.getUserId();
                		testDecisionRecUpdate.add(testDecisionRecList.get(i));
                	// 
            }
        	update testDecisionRecUpdate;
        	TransferOwnership.transferOwnershipForDecision(DecisionIds, DecisionOldOwners, DecisionNewOwners);
        test.stopTest();
        
    }

    
}