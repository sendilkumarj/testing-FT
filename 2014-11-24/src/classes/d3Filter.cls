public with sharing class d3Filter {
	public List<Decision__c> searchDecision{get;set;}
	public String autoCompleteData{get;set;}
	public d3Filter(){
		
		 String decisiomName = Apexpages.currentPage().getParameters().get('decisionName');
	     String role = Apexpages.currentPage().getParameters().get('role');
	     String phase = Apexpages.currentPage().getParameters().get('phase');
	     String status = Apexpages.currentPage().getParameters().get('status');
	     autoCompleteData = runSearch(decisiomName);
	}
	
	@remoteaction
	public static  string runSearch(string decisionName) {  
	    //searchDecision = [Select  d.Name, d.Id, (Select id From People__r where Role__c =:role) From Decision__c d where d.Status__c = :status or d.Phase__c = :phase order by d.LastModifiedDate DESC Limit 1 ];
	    List<Social_Input__c> socialInputList  = [Select id,Decision__r.Title__c,Decision__r.name, Decision__r.id  from social_input__c where  Decision__c != null and  Decision__r.Title__c Like : '%' + decisionName +'%' and ( Accountable__c = true or Responsible__c = true or consulted__c = true or  informed__c  = true ) order by Decision__r.lastmodifieddate  ];
	    List<decisionWrapp> decisionWrappList = new  List<decisionWrapp>();
	    for( Social_Input__c socialInput : socialInputList)
	    {
	    	decisionWrapp dw = new decisionWrapp();
	    	dw.decisionId = socialInput.decision__r.id;
	    	dw.recordName = socialInput.decision__r.Title__c;
	    	decisionWrappList.add(dw);
	    
	    }
	    return JSON.serialize(decisionWrappList);
	}  
	
	public class decisionWrapp{
		
		public string decisionId{get;set;}
		public string recordName{get;set;}
	}  
}