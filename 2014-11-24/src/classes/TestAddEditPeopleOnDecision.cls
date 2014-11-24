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
public class TestAddEditPeopleOnDecision{
    public static testMethod Void testListToStringConvert(){
        test.startTest();
            Decision__c decisionRec = new Decision__c(title__c = 'Test decision',Problem_Idea_Advice__c = 'Problem',Decision_Taken__c = 'Decision',Priority__c = 'Normal',Status__c ='Propose');
            insert decisionRec;
            Social_Input__c si = [Select id,Is_Group__c from Social_Input__c where Decision__c =:decisionRec.id ];
            si.Is_Group__c = true;
        	Update si;
            ApexPages.currentPage().getParameters().put('id',decisionRec.id);		
            ApexPages.currentPage().getParameters().put('objType','Decision');	
            AddEditPeopleOnDecision addEditPeople = new AddEditPeopleOnDecision();
            //listToStringConvert
        test.stopTest();
   }
}