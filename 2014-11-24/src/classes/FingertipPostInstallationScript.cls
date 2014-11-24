global class FingertipPostInstallationScript implements InstallHandler {
	global void onInstall(InstallContext context) {
		List<Topic_Selected_Data__c> lstTopicSelected = [Select id ,Topic_Json__c from  Topic_Selected_Data__c];
		if(lstTopicSelected.isEmpty()){
			Topic_Selected_Data__c tnew = new Topic_Selected_Data__c();
          	tnew.Topic_Json__c = '[]';
          	tnew.name = '0';
          	tnew.RecordNumber__c = 0;
          	insert tnew;
		}
	}
}