/*
Created By : Tanay Das Barman.
Description : SF1 Mobile Card Decision View
*/

public with sharing class SF1_Decision_Approval {
	//Initialize this varibale to store decision Record of relete SI record.
	 public Decision__c decisionDetails{get;set;}
	 //Initialize this varibale to store Timing Record.
	 public Timing__c timingRecord {get;set;}
	
	public SF1_Decision_Approval(ApexPages.StandardController controller) {
		//query social input for cuurent record.
		Social_Input__c si = [select id,Decision__c from Social_Input__c where Id = : controller.getId()];
		
        decisionDetails = [select id,Problem_Idea_Advice__c,Decision_Taken__c,Title__c from Decision__c where Id = : si.Decision__c];
        timingRecord  =[Select id,Actual_End_Date__c,End_Date_Time__c from Timing__c  where Related_To_ID__c =:decisionDetails.id and Stage__c='Propose'];
	}
}