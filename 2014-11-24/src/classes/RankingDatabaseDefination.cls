public with sharing class RankingDatabaseDefination {
	
	User u;
	public RankingDatabaseDefination(){
		u = [select id,Total_Score__c from User where Id = : UserInfo.getUserId()];
	}
	
	public void calculatePoints(String action,String val){
		
		//Integer.valueOf('X');
		
		Decimal valPoints = 0.00;
		if(u.Total_Score__c == null){
			u.Total_Score__c = 0.0;
		}
		System.debug('------val------>'+val);
		if(action == 'Create a decision'){
			Points_Definition__c cd = Points_Definition__c.getValues('Create a decision');
			Decimal cdPoints = cd.Points__c;
			if(val == 'None' || val == null){
				Points_Definition__c cdMicro = Points_Definition__c.getValues('Create a decision None');
				valPoints = cdMicro.Points__c;
			} else {
				Points_Definition__c cdMicro = Points_Definition__c.getValues('Create a decision '+val);
				valPoints = cdMicro.Points__c;
			}
			u.Total_Score__c = u.Total_Score__c + cdPoints * valPoints;
		} else if(action == 'Set all socials'){
			Points_Definition__c pd = Points_Definition__c.getValues('Set all socials');
			valPoints = pd.Points__c;
			u.Total_Score__c = u.Total_Score__c + valPoints;
		} else if(action == 'Create a task for self'){
			Points_Definition__c pd = Points_Definition__c.getValues('Create a task for self');
			valPoints = pd.Points__c;
			u.Total_Score__c = u.Total_Score__c + valPoints;
		} else if(action == 'Change socials'){
			Points_Definition__c pd = Points_Definition__c.getValues('Change socials');
			valPoints = pd.Points__c;
			u.Total_Score__c = u.Total_Score__c + valPoints;
		} else if(action == 'Create a task for other'){
			Points_Definition__c pd = Points_Definition__c.getValues('Create a task for other');
			valPoints = pd.Points__c;
			u.Total_Score__c = u.Total_Score__c + valPoints;
		} else if(action == 'Task assigned to self'){
			Points_Definition__c pd = Points_Definition__c.getValues('Task assigned to self');
			valPoints = pd.Points__c;
			u.Total_Score__c = u.Total_Score__c + valPoints;
		} else if(action == 'Provide your evaluation to a decision'){
			Points_Definition__c pd = Points_Definition__c.getValues('Provide your evaluation to a decision');
			valPoints = pd.Points__c;
			u.Total_Score__c = u.Total_Score__c + valPoints;
		} else if(action == 'Advance a decision as Accountable'){
			Points_Definition__c pd = Points_Definition__c.getValues('Advance a decision as Accountable');
			valPoints = pd.Points__c;
			u.Total_Score__c = u.Total_Score__c + valPoints;
		} else if(action == 'Close a Decision'){
			Points_Definition__c pd = Points_Definition__c.getValues('Close a Decision');
			valPoints = pd.Points__c;
			u.Total_Score__c = u.Total_Score__c + valPoints;
		} else if(action == 'Miss a deadline for a decision'){
			Points_Definition__c pd = Points_Definition__c.getValues('Miss a deadline for a decision');
			valPoints = pd.Points__c;
			u.Total_Score__c = u.Total_Score__c - valPoints;
		} else if(action == 'Miss a deadline for a task low'){
			Points_Definition__c pd = Points_Definition__c.getValues('Miss a deadline for a task low');
			valPoints = pd.Points__c;
			u.Total_Score__c = u.Total_Score__c - valPoints;
		} else if(action == 'Miss a deadline for a task high'){
			Points_Definition__c pd = Points_Definition__c.getValues('Miss a deadline for a task high');
			valPoints = pd.Points__c;
			u.Total_Score__c = u.Total_Score__c - valPoints;
		} else if(action == 'Stance not given before decide phase'){
			Points_Definition__c pd = Points_Definition__c.getValues('Stance not given before decide phase');
			valPoints = pd.Points__c;
			u.Total_Score__c = u.Total_Score__c - valPoints;
		} else if(action == 'Do not provide your evaluation'){
			Points_Definition__c pd = Points_Definition__c.getValues('Do not provide your evaluation');
			valPoints = pd.Points__c;
			u.Total_Score__c = u.Total_Score__c - valPoints;
		}
		update u;
	}
	
	public void updateCalculation(String action, String currentVal, String previousValue){
		if(action == 'Create a decision'){
			Decimal previousPoints = 0.0;
			Decimal currentPoints = 0.0;
			Points_Definition__c cd = Points_Definition__c.getValues('Create a decision');
			Decimal cdPoints = cd.Points__c;
			if(previousValue == 'None' || previousValue == null){
				Points_Definition__c cdMicro = Points_Definition__c.getValues('Create a decision None');
				previousPoints = cdMicro.Points__c;
			} else {
				Points_Definition__c cdMicro = Points_Definition__c.getValues('Create a decision '+previousValue);
				previousPoints = cdMicro.Points__c;
			}
			if(currentVal == 'None' || currentVal == null){
				Points_Definition__c cdMicro = Points_Definition__c.getValues('Create a decision None');
				currentPoints = cdMicro.Points__c;
			} else {
				Points_Definition__c cdMicro = Points_Definition__c.getValues('Create a decision '+currentVal);
				currentPoints = cdMicro.Points__c;
			}
			if(u.Total_Score__c == null){
				u.Total_Score__c = 0.0;
			}
			u.Total_Score__c = u.Total_Score__c + cdPoints * (currentPoints - previousPoints);
		}
		update u;
	}
	
	public static void addedAsRole(set<Id> setIds,String addedAs, String remove){
		List<User> lstUsers = [select Id,Total_Score__c from User where Id In : setIds];
		for(User u : lstUsers){
			Points_Definition__c cdMicro = Points_Definition__c.getValues('Being added as a '+addedAs);
			if(u.Total_Score__c == null){
				u.Total_Score__c = 0.0;
			}
			if(remove == 'Remove'){	
				u.Total_Score__c = u.Total_Score__c - cdMicro.Points__c;
			} else {
				u.Total_Score__c = u.Total_Score__c + cdMicro.Points__c;
			}
		}
		if(!lstUsers.isEmpty()){	
			update lstUsers;
		}
	}
	
	public static void missingTaskDeadline(set<Id> setOwnerIds,String taskPriority){
		List<User> lstUsers = [select Id,Total_Score__c from User where Id In : setOwnerIds];
		for(User u : lstUsers){
			Points_Definition__c cdMicro = Points_Definition__c.getValues('Miss a deadline for a task '+taskPriority);
			if(u.Total_Score__c == null){
				u.Total_Score__c = 0.0;
			}
			u.Total_Score__c = u.Total_Score__c - cdMicro.Points__c;
		}
		if(!lstUsers.isEmpty()){	
			update lstUsers;
		}
	}
	
	public static void stanceNotGiven(set<Id> setIds){
		List<Social_Input__c> lstSocialInput = [select Id,Decision__c,Stance_Approval_Status__c,User__c from Social_Input__c where Decision__c IN : setIds and Stance_Approval_Status__c = 'Pending Approval'];
		set<Id> userIds = new set<Id>();
		for(Social_Input__c si : lstSocialInput){
			userIds.add(si.User__c);
		}
		List<User> lstUsers = [select Id,Total_Score__c from User where Id In : userIds];
		for(User u : lstUsers){
			Points_Definition__c cdMicro = Points_Definition__c.getValues('Stance not given before decide phase');
			if(u.Total_Score__c == null){
				u.Total_Score__c = 0.0;
			}
			u.Total_Score__c = u.Total_Score__c - cdMicro.Points__c;
		}
		if(!lstUsers.isEmpty()){	
			update lstUsers;
		}
	}
}