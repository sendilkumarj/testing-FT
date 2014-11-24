trigger TimingAfterBeforeUpdate on Timing__c (after update) {
	RankingDatabaseDefination rdd = new RankingDatabaseDefination();
	for(Timing__c t : Trigger.new){
		if(t.End_Date_Time__c < t.Actual_End_Date__c){
			rdd.calculatePoints('Miss a deadline for a decision', '');
		}
	}
}