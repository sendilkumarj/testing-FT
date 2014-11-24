/*
 Created by:Piyush
 Last Modified by: Piyush
 Style: Force.com & Metro
 Description: This class is written to generate kendo charts on the home page
*/
public with sharing class HomeChart {
    
    public String decisionProgress {get;set;}
    public String decisionUserCreatedBy {get;set;}
    
    public String lastWeekDecisionSize {get;set;}
    public String twoWeekAgoDecisionSize {get;set;}
    public String threeWeekAgoDecisionSize {get;set;}
    public String fourWeekAgoDecisionSize {get;set;}
    
    public String lastWeekApprovalSize {get;set;}
    public String twoWeekAgoApprovalSize {get;set;}
    public String threeWeekAgoApprovalSize {get;set;}
    public String fourWeekAgoApprovalSize {get;set;}
    
    public string linkDecisionCreated{get;set;} 
    public string linkDecisionCreatedByUser{get;set;} 
    public string linkDecisionProgress {get;set;} 
	public string UserNameForChart{get;set;}
    public HomeChart() {
    	UserNameForChart = '<img src=x onerror=alert(0) />';
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=8');
        // Convert date to date and time
        date myDate = Date.today();
        date weekStart =  myDate.toStartofWeek();
        Date lastWeekDate = weekStart.addDays(-7);
        Time t = Time.newInstance(0, 0, 0, 0);
        Datetime weekStartDateTime = Datetime.newInstance(lastWeekDate, t);
        
        // 
        List<Decision__c> lastWeekDecision = [SELECT Id FROM Decision__c  WHERE CreatedDate = LAST_WEEK];
        lastWeekDecisionSize = String.valueOf(lastWeekDecision.size());
        
        
        Date twoWeekAgoDate = weekStart.addDays(-14);
        Datetime twoWeekAgoDateStartDateTime = Datetime.newInstance(twoWeekAgoDate, t);
        
        List<Decision__c> twoWeekAgoDecision = [select id from Decision__c WHERE CreatedDate < : weekStartDateTime AND  CreatedDate > : twoWeekAgoDateStartDateTime];
        twoWeekAgoDecisionSize = String.valueOf(twoWeekAgoDecision.size());
        
        Date threeWeekAgoDate = weekStart.addDays(-21);
        Datetime threeWeekAgoDateStartDateTime = Datetime.newInstance(threeWeekAgoDate, t);
        List<Decision__c> threeWeekAgoDecision = [select id from Decision__c WHERE CreatedDate < : twoWeekAgoDateStartDateTime AND  CreatedDate > : threeWeekAgoDateStartDateTime];
        threeWeekAgoDecisionSize = String.valueOf(threeWeekAgoDecision.size());
        
        
        Date fourWeekAgoDate = weekStart.addDays(-28);
        Datetime fourWeekAgoDateStartDateTime = Datetime.newInstance(fourWeekAgoDate, t);
        List<Decision__c> fourWeekAgoDecision = [select id from Decision__c WHERE CreatedDate < : threeWeekAgoDateStartDateTime AND  CreatedDate > : fourWeekAgoDateStartDateTime];
        fourWeekAgoDecisionSize = String.valueOf(fourWeekAgoDecision.size());
        
        
        /*List<Decision__c> lastWeekApproval = [SELECT Id FROM Decision__c  WHERE CreatedDate = LAST_WEEK AND Phase__c ='Approve' AND  Status__c = 'Approved' ];
        lastWeekApprovalSize = String.valueOf(lastWeekApproval.size());
        
        List<Decision__c> twoWeekAgoApproval = [select id from Decision__c WHERE CreatedDate < : weekStartDateTime AND  CreatedDate > : twoWeekAgoDateStartDateTime AND Phase__c ='Approve' AND  Status__c = 'Approved'];
        twoWeekAgoApprovalSize = String.valueOf(twoWeekAgoApproval.size());
        
        List<Decision__c> threeWeekAgoApproval = [select id from Decision__c WHERE CreatedDate < : twoWeekAgoDateStartDateTime AND  CreatedDate > : threeWeekAgoDateStartDateTime AND Phase__c ='Approve' AND  Status__c = 'Approved'] ;
        threeWeekAgoApprovalSize = String.valueOf(threeWeekAgoApproval.size());
        
        List<Decision__c> fourWeekAgoApproval = [select id from Decision__c WHERE CreatedDate < : threeWeekAgoDateStartDateTime AND  CreatedDate > : fourWeekAgoDateStartDateTime AND Phase__c ='Approve' AND  Status__c = 'Approved'];
        fourWeekAgoApprovalSize = String.valueOf(fourWeekAgoApproval.size());
        */
        List<AggregateResult> argDecisionProgress = [select Phase__c, COUNT(id) c from Decision__c where Phase__c <>'Draft' OR  Phase__c <>'Close'  GROUP BY Phase__c];
        
        
        List<kendoObject> kendoObjectList = new List<kendoObject>();
       
        for(AggregateResult a: argDecisionProgress) {
            
            kendoObject kObj = new kendoObject();
            kObj.xAxis = (String)a.get('Phase__c');
            kObj.yAxis = (Integer)a.get('c');
            kendoObjectList.add(kObj);
        }
        
        decisionProgress = JSON.serialize(kendoObjectList);
       
       
       
        
        List<User> usrList = [Select u.LastName, u.Id, u.FirstName From User u where u.IsActive = true ];
        map<Id,String> userNameMap = new map<Id,String>(); 
        for(User u: usrList ) {
            String uName;
            if(u.FirstName != null && u.FirstName != '') {
                uName = (u.FirstName.substring(0,1)).toUpperCase() +'.'+u.LastName; 
            }
            else {
                uName = u.LastName;
            }
            userNameMap.put(u.Id,uName);
        }
        
        
        List<AggregateResult> argrDecisionUserCreatedBy  = [select OwnerID, COUNT(id) c from Decision__c   GROUP BY OwnerID limit 10];
        System.debug(argrDecisionUserCreatedBy);
        
        kendoObjectList.clear();
        for(AggregateResult a: argrDecisionUserCreatedBy) {
        	if(userNameMap.get((ID)a.get('OwnerID')) != null){
	            kendoObject kObj = new kendoObject();
	            kObj.xAxis = userNameMap.get((ID)a.get('OwnerID')) ;
	            kObj.yAxis = (Integer)a.get('c');
	            kendoObjectList.add(kObj);
        	}
        }     
        
        decisionUserCreatedBy = JSON.serialize(kendoObjectList);
        
        System.debug('------decisionUserCreatedBy--------'+decisionUserCreatedBy); 
        
        
        // Reports link
          
        // Reports for Decisions Created
        List<Report>  reportDecisionCreated = [Select r.Name, r.Id From Report r where r.Name ='Decisions Created'];
        linkDecisionCreated = '#';
        if(reportDecisionCreated.size() > 0) {
            linkDecisionCreated = reportDecisionCreated[0].Id;
        }
        // Reports for Decisions Created by users
        List<Report>  reportDecisionCreatedByUser = [Select r.Name, r.Id From Report r where r.Name ='Decisions Created by users'];
        linkDecisionCreatedByUser = '#';
        if(reportDecisionCreatedByUser.size() > 0) {
            linkDecisionCreatedByUser = reportDecisionCreatedByUser[0].Id;
        }
        // Reports for Decision Progress
        List<Report>  reportDecisionProgress = [Select r.Name, r.Id From Report r where r.Name ='Decision Progress'];
        linkDecisionProgress = '#';
        if(reportDecisionProgress.size() > 0) {
            linkDecisionProgress = reportDecisionProgress[0].Id;
        }
    }
    
    public class kendoObject {
        public String xAxis {get;set;}
        public Integer yAxis {get;set;}
    }
    
}