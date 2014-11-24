public with sharing class UpdateNearestDueDate {

	public UpdateNearestDueDate(){
		
	}
	
	public static void updateAllDeicisons(string decisionIdFromDecision){
		
		Set<Id> decisionId = new Set<Id>();
		
		List<Decision__c> decisionsToBeUpdated = new List<Decision__c>();
		 
		if(decisionIdFromDecision == null){
		
			decisionsToBeUpdated = [select id, Phase__c from Decision__c where Phase__c != 'Close' ]; 
			System.debug('-decisionsToBeUpdated one------------------');
			for(Decision__c d: decisionsToBeUpdated){
				decisionId.add(d.Id);		
			}
		}else{
			decisionsToBeUpdated = [select id, Phase__c from Decision__c where Phase__c != 'Close' and id=: decisionIdFromDecision ]; 
			System.debug('-decisionsToBeUpdated two------------------');
			for(Decision__c d: decisionsToBeUpdated){
				decisionId.add(d.Id);		
			}
		}
		
		// initialize map of decision id v/s timing data
        map<Id, List<Timing__c>> decisionIdtimingListMap = new map<Id, List<Timing__c>>();
        
        for(Timing__c timing : [Select t.Start_Date_Time__c, t.Stage__c, t.Related_To_ID__c, t.End_Date_Time__c, t.Elapsed_Time__c, t.Difference__c, t.Actual_Start_Date__c, t.Actual_End_Date__c From Timing__c t where t.Related_To_ID__c IN: decisionId]) {
            
            List<Timing__c> timingList = decisionIdtimingListMap.get(timing.Related_To_ID__c);
            if(timingList == null ) {
                timingList = new List<Timing__c>();
                decisionIdtimingListMap.put(timing.Related_To_ID__c, timingList);
            }
            timingList.add(timing);
        }
        
        map<String, Timing__c> phasestimingMap = new map<String, Timing__c>();
        
        for(Id decision: decisionId){
	        for(Timing__c timing : decisionIdtimingListMap.get(decision)) {
	            phasestimingMap.put(timing.Stage__c, timing);
	        }
        }
        List<Decision__c> toBeUpdated = new List<Decision__c>();
        
        
        
        for(Decision__c decision: decisionsToBeUpdated){
        
	        DateTime toBeUpdatedNearestDueDate;
	        if(decision.Phase__c == 'Draft') {
	        	System.debug('----------hello today------------');
	        	//calculate nearest due date
	        	Timing__c draft = phasestimingMap.get('Draft');
	            Timing__c share = phasestimingMap.get('Share');
	        	Timing__c decide = phasestimingMap.get('Propose');
	        	Timing__c approve = phasestimingMap.get('Decide');
	        	Timing__c execute = phasestimingMap.get('Execute');
	        	Timing__c evaluate = phasestimingMap.get('Evaluate');
	        	Timing__c close = phasestimingMap.get('Close');
	        	
	        	if(close.End_Date_Time__c != null)
	        		toBeUpdatedNearestDueDate = close.End_Date_Time__c;
	    		if(close.Start_Date_Time__c != null)
	        		toBeUpdatedNearestDueDate = close.Start_Date_Time__c;
	    		if(evaluate.End_Date_Time__c != null)
	        		toBeUpdatedNearestDueDate = evaluate.End_Date_Time__c;
	    		if(evaluate.Start_Date_Time__c != null)
	        		toBeUpdatedNearestDueDate = evaluate.Start_Date_Time__c;
	    		if(execute.End_Date_Time__c != null)
	        		toBeUpdatedNearestDueDate = execute.End_Date_Time__c;
	    		if(execute.Start_Date_Time__c != null)
	        		toBeUpdatedNearestDueDate = execute.Start_Date_Time__c;
	    		if(approve.End_Date_Time__c != null)
	        		toBeUpdatedNearestDueDate = approve.End_Date_Time__c;
	    		if(approve.Start_Date_Time__c != null)
	        		toBeUpdatedNearestDueDate = approve.Start_Date_Time__c;
	    		if(decide.End_Date_Time__c != null)
	        		toBeUpdatedNearestDueDate = decide.End_Date_Time__c;
	    		if(decide.Start_Date_Time__c != null)
	        		toBeUpdatedNearestDueDate = decide.Start_Date_Time__c;
	    		if(share.End_Date_Time__c != null)
	        		toBeUpdatedNearestDueDate = share.End_Date_Time__c;
        		if(share.Start_Date_Time__c != null)
        			toBeUpdatedNearestDueDate = share.Start_Date_Time__c;
    			if(draft.End_Date_Time__c != null)
        			toBeUpdatedNearestDueDate = draft.End_Date_Time__c;
	    		
	    		if(close.End_Date_Time__c == null && close.Start_Date_Time__c == null && evaluate.End_Date_Time__c == null && evaluate.Start_Date_Time__c == null && execute.End_Date_Time__c == null && execute.Start_Date_Time__c == null && approve.End_Date_Time__c == null && approve.Start_Date_Time__c == null && decide.End_Date_Time__c == null && decide.Start_Date_Time__c == null && share.End_Date_Time__c == null && share.Start_Date_Time__c == null && draft.End_Date_Time__c == null)
        		toBeUpdatedNearestDueDate = null;
	    		
	    		// update nearest due date
	    		//if(toBeUpdatedNearestDueDate != null){
		    		decision.Nearest_Due_Date__c = toBeUpdatedNearestDueDate;
		    		toBeUpdated.add(decision);
	        	//}
	        }
	        else if(decision.Phase__c == 'Share') {
	        	//calculate nearest due date
	            Timing__c share = phasestimingMap.get('Share');
	        	Timing__c decide = phasestimingMap.get('Propose');
	        	Timing__c approve = phasestimingMap.get('Decide');
	        	Timing__c execute = phasestimingMap.get('Execute');
	        	Timing__c evaluate = phasestimingMap.get('Evaluate');
	        	Timing__c close = phasestimingMap.get('Close');
	        	
	        	if(close.End_Date_Time__c != null)
	        		toBeUpdatedNearestDueDate = close.End_Date_Time__c;
	    		if(close.Start_Date_Time__c != null)
	        		toBeUpdatedNearestDueDate = close.Start_Date_Time__c;
	    		if(evaluate.End_Date_Time__c != null)
	        		toBeUpdatedNearestDueDate = evaluate.End_Date_Time__c;
	    		if(evaluate.Start_Date_Time__c != null)
	        		toBeUpdatedNearestDueDate = evaluate.Start_Date_Time__c;
	    		if(execute.End_Date_Time__c != null)
	        		toBeUpdatedNearestDueDate = execute.End_Date_Time__c;
	    		if(execute.Start_Date_Time__c != null)
	        		toBeUpdatedNearestDueDate = execute.Start_Date_Time__c;
	    		if(approve.End_Date_Time__c != null)
	        		toBeUpdatedNearestDueDate = approve.End_Date_Time__c;
	    		if(approve.Start_Date_Time__c != null)
	        		toBeUpdatedNearestDueDate = approve.Start_Date_Time__c;
	    		if(decide.End_Date_Time__c != null)
	        		toBeUpdatedNearestDueDate = decide.End_Date_Time__c;
	    		if(decide.Start_Date_Time__c != null)
	        		toBeUpdatedNearestDueDate = decide.Start_Date_Time__c;
	    		if(share.End_Date_Time__c != null)
	        		toBeUpdatedNearestDueDate = share.End_Date_Time__c;
	    		
	    		System.debug('-------toBeUpdatedNearestDueDate-------'+toBeUpdatedNearestDueDate);
	    		
	    		if(close.End_Date_Time__c == null && close.Start_Date_Time__c == null && evaluate.End_Date_Time__c == null && evaluate.Start_Date_Time__c == null && execute.End_Date_Time__c == null && execute.Start_Date_Time__c == null && approve.End_Date_Time__c == null && approve.Start_Date_Time__c == null && decide.End_Date_Time__c == null && decide.Start_Date_Time__c == null && share.End_Date_Time__c == null)
        			toBeUpdatedNearestDueDate = null;
	    		
	    		// update nearest due date
	    		//if(toBeUpdatedNearestDueDate != null){
		    		decision.Nearest_Due_Date__c = toBeUpdatedNearestDueDate;
		    		toBeUpdated.add(decision);
	        	//}
	        }
	        else if(decision.Phase__c == 'Propose') {
	            //calculate nearest due date
	            Timing__c decide = phasestimingMap.get('Propose');
	        	Timing__c approve = phasestimingMap.get('Decide');
	        	Timing__c execute = phasestimingMap.get('Execute');
	        	Timing__c evaluate = phasestimingMap.get('Evaluate');
	        	Timing__c close = phasestimingMap.get('Close');
	        	
	        	if(close.End_Date_Time__c != null)
	        		toBeUpdatedNearestDueDate = close.End_Date_Time__c;
	    		if(close.Start_Date_Time__c != null)
	        		toBeUpdatedNearestDueDate = close.Start_Date_Time__c;
	    		if(evaluate.End_Date_Time__c != null)
	        		toBeUpdatedNearestDueDate = evaluate.End_Date_Time__c;
	    		if(evaluate.Start_Date_Time__c != null)
	        		toBeUpdatedNearestDueDate = evaluate.Start_Date_Time__c;
	    		if(execute.End_Date_Time__c != null)
	        		toBeUpdatedNearestDueDate = execute.End_Date_Time__c;
	    		if(execute.Start_Date_Time__c != null)
	        		toBeUpdatedNearestDueDate = execute.Start_Date_Time__c;
	    		if(approve.End_Date_Time__c != null)
	        		toBeUpdatedNearestDueDate = approve.End_Date_Time__c;
	    		if(approve.Start_Date_Time__c != null)
	        		toBeUpdatedNearestDueDate = approve.Start_Date_Time__c;
	    		if(decide.End_Date_Time__c != null)
	        		toBeUpdatedNearestDueDate = decide.End_Date_Time__c;
	    		
	    		System.debug('------toBeUpdatedNearestDueDate------------'+toBeUpdatedNearestDueDate);
	    		
	    		if(close.End_Date_Time__c == null && close.Start_Date_Time__c == null && evaluate.End_Date_Time__c == null && evaluate.Start_Date_Time__c == null && execute.End_Date_Time__c == null && execute.Start_Date_Time__c == null && approve.End_Date_Time__c == null && approve.Start_Date_Time__c == null && decide.End_Date_Time__c == null)
        			toBeUpdatedNearestDueDate = null;
	    		
	    		// update nearest due date
	    		// update nearest due date
	    		//if(toBeUpdatedNearestDueDate != null){
		    		decision.Nearest_Due_Date__c = toBeUpdatedNearestDueDate;
		    		toBeUpdated.add(decision);
	        	//}
	        }
	        else if(decision.Phase__c == 'Decide') {
	            
	            
	            // calculate nearest due date
	            
	        	Timing__c approve = phasestimingMap.get('Decide');
	        	Timing__c execute = phasestimingMap.get('Execute');
	        	Timing__c evaluate = phasestimingMap.get('Evaluate');
	        	Timing__c close = phasestimingMap.get('Close');
	        	
	        	if(close.End_Date_Time__c != null)
	        		toBeUpdatedNearestDueDate = close.End_Date_Time__c;
	    		if(close.Start_Date_Time__c != null)
	        		toBeUpdatedNearestDueDate = close.Start_Date_Time__c;
	    		if(evaluate.End_Date_Time__c != null)
	        		toBeUpdatedNearestDueDate = evaluate.End_Date_Time__c;
	    		if(evaluate.Start_Date_Time__c != null)
	        		toBeUpdatedNearestDueDate = evaluate.Start_Date_Time__c;
	    		if(execute.End_Date_Time__c != null)
	        		toBeUpdatedNearestDueDate = execute.End_Date_Time__c;
	    		if(execute.Start_Date_Time__c != null)
	        		toBeUpdatedNearestDueDate = execute.Start_Date_Time__c;
	    		if(approve.End_Date_Time__c != null)
	        		toBeUpdatedNearestDueDate = approve.End_Date_Time__c;
	    		
	    		if(close.End_Date_Time__c == null && close.Start_Date_Time__c == null && evaluate.End_Date_Time__c == null && evaluate.Start_Date_Time__c == null && execute.End_Date_Time__c == null && execute.Start_Date_Time__c == null && approve.End_Date_Time__c == null)
        			toBeUpdatedNearestDueDate = null;
	    		
	    		// update nearest due date
	    		//if(toBeUpdatedNearestDueDate != null){
		    		decision.Nearest_Due_Date__c = toBeUpdatedNearestDueDate;
		    		toBeUpdated.add(decision);
	        	//}
	        }
	        else if(decision.Phase__c == 'Execute') {
	            
	            
	            //calculate nearest due date
	            Timing__c execute = phasestimingMap.get('Execute');
	        	Timing__c evaluate = phasestimingMap.get('Evaluate');
	        	Timing__c close = phasestimingMap.get('Close');
	        	
	        	if(close.End_Date_Time__c != null)
	        		toBeUpdatedNearestDueDate = close.End_Date_Time__c;
	    		if(close.Start_Date_Time__c != null)
	        		toBeUpdatedNearestDueDate = close.Start_Date_Time__c;
	    		if(evaluate.End_Date_Time__c != null)
	        		toBeUpdatedNearestDueDate = evaluate.End_Date_Time__c;
	    		if(evaluate.Start_Date_Time__c != null)
	        		toBeUpdatedNearestDueDate = evaluate.Start_Date_Time__c;
	    		if(execute.End_Date_Time__c != null)
	        		toBeUpdatedNearestDueDate = execute.End_Date_Time__c;
	    		
	    		if(close.End_Date_Time__c == null && close.Start_Date_Time__c == null && evaluate.End_Date_Time__c == null && evaluate.Start_Date_Time__c == null && execute.End_Date_Time__c == null)
        			toBeUpdatedNearestDueDate = null;
	    		
	    		System.debug('------toBeUpdatedNearestDueDate------------'+toBeUpdatedNearestDueDate);
	    		
	    		// update nearest due date
	    		//if(toBeUpdatedNearestDueDate != null){
		    		decision.Nearest_Due_Date__c = toBeUpdatedNearestDueDate;
		    		toBeUpdated.add(decision);
	        	//}
	        }
	        else if(decision.Phase__c == 'Evaluate') {
	            
	            
	            //calculate nearest due date
	            Timing__c evaluate = phasestimingMap.get('Evaluate');
	        	Timing__c close = phasestimingMap.get('Close');
	        	
	        	if(close.End_Date_Time__c != null)
	        		toBeUpdatedNearestDueDate = close.End_Date_Time__c;
	    		if(close.Start_Date_Time__c != null)
	        		toBeUpdatedNearestDueDate = close.Start_Date_Time__c;
	    		if(evaluate.End_Date_Time__c != null)
	        		toBeUpdatedNearestDueDate = evaluate.End_Date_Time__c;
	    		
	    		if(close.End_Date_Time__c == null && close.Start_Date_Time__c == null && evaluate.End_Date_Time__c == null)
        			toBeUpdatedNearestDueDate = null;
	    		
	    		// update nearest due date
	    		//if(toBeUpdatedNearestDueDate != null){
		    		decision.Nearest_Due_Date__c = toBeUpdatedNearestDueDate;
		    		toBeUpdated.add(decision);
	        	//}
	        }
	        
	        else if(decision.Phase__c == 'Close') {
	            toBeUpdatedNearestDueDate = null;
	    		decision.Nearest_Due_Date__c = toBeUpdatedNearestDueDate;
		    	toBeUpdated.add(decision);
	        }
        }
        
        if(toBeUpdated.size() > 0){
        	if(FLS.decisionUpdateable()) {
        		update toBeUpdated;
        	}
        }
	}
	
	

}