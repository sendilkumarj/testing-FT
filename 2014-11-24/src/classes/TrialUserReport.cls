public with sharing class TrialUserReport {
    public List<wrappReport> listWrapperReport{get;set;}
    public List<Social_Input__c > listOfSocial{get;set;}
    public List<Task> listTask{get;set;}
    
   public List<wrappReport> getContacts() {
            listWrapperReport = new List<wrappReport>();
            for(Social_Input__c c: [Select s.User__c, s.Plan__c, s.Name_of_the_User__c, s.Id, s.Decision__c, s.CreatedDate From Social_Input__c s where CreatedDate = LAST_MONTH AND User__c = :Userinfo.getUserId()   ]) {
                  listWrapperReport.add(new wrappReport(c));

            }
        return listWrapperReport ;

    }


   

    public class wrappReport{
        public string decisionName{get;set;}
        public string planName{get;set;}
        public string activaityname{get;set;}
        public string activityName{get;set;}
        public Social_Input__c decision{get;set;}
        
        public  wrappReport(Social_Input__c d){
            decision  = d;
        }
    }
}