global with sharing class SF1_AddEditPeople {
    public  Id decisionId{get;set;}
    public List<Social_Input__c> existingSocialInputList{get;set;}
    public set<Id> exsistingUserId{get;set;}
    public List<User> newCollaboratorList{get;set;}
    public Boolean chkConsultanInformed{get;set;}
    public string userIdString{get;set;}
    public Boolean chkDecisionStatus{get;set;}
    public SF1_AddEditPeople(ApexPages.StandardController controller){
        exsistingUserId = new set<Id>();
        newCollaboratorList = new List<User>();
        chkConsultanInformed = false;
        this.decisionId = controller.getId();
        listOfCollaborator();
    }
    public void listOfCollaborator(){ 
       // User usrChk = [Select id from User where Id = :UserInfo.getUserId() Limit 1];
        Social_Input__c  socialInput = new Social_Input__c();
        Decision__c decision = new Decision__c();
        if([select id ,Status__c,Phase__c from Decision__c where id = :decisionId ].size() > 0){
            decision =[select id ,Status__c,Phase__c from Decision__c where id = :decisionId];
            
        }
        if(decision.phase__c == 'Close'){
            chkDecisionStatus = true;
        }
        if([Select s.Veto_Rights__c, s.User__c, s.Responsible__c, s.Informed__c, s.Id,Decision__r.Add_C_I_Members__c, s.Group_Name__c, s.GroupId__c, s.Consulted__c, s.Backup_for_Accountable__c, s.Accountable__c,Decision__c From Social_Input__c s where User__c = :UserInfo.getUserId() and Decision__c =:decisionId Limit 1].size() > 0){
            socialInput = [Select s.Veto_Rights__c, s.User__c, s.Responsible__c, Decision__r.Add_C_I_Members__c, s.Informed__c, s.Id, s.Group_Name__c, s.GroupId__c, s.Consulted__c, s.Backup_for_Accountable__c, s.Accountable__c,Decision__c From Social_Input__c s where User__c = : UserInfo.getUserId() and Decision__c =:decisionId Limit 1];
        }
            if(  ( socialInput.Accountable__c == false && socialInput.Responsible__c == false  &&  socialInput.Backup_for_Accountable__c == false && socialInput.Decision__r.Add_C_I_Members__c == false ) ){
                chkConsultanInformed = true;
            }
            for(Social_Input__c si:[select Id,User__r.isActive,GroupId__c,Role__c,Is_Group__c, Group_Name__c,User__c from Social_Input__c where Decision__c =: decisionId]){
                exsistingUserId.add(si.User__c);
            }
        if(exsistingUserId.size() > 0){     
            for(User usr:[select id, Name, firstname, Department from User where Id not In: exsistingUserId and isActive=true  Order By firstName limit 100]){
                newCollaboratorList.add(usr);
            }
        }else{
            newCollaboratorList = [select id, Name, firstname, Department from User where isActive=true  Order By firstName limit 100];
        }   
    }
    @RemoteAction 
    global static void addCollaborator(string userIdString ,string decisionId){
        system.debug('decisionIddecisionIddecisionId'+decisionId);
        List<Social_Input__c> newUsersToBeSaved = new List<Social_Input__c>();
        //Need to split the string of comma seperated ids into a List
        List<Id> userIDs = userIdString.split(',');
        for(Id uId:userIDs){
                Social_Input__c s = new Social_Input__c();
                    s.Select_People__c = false;
                    s.User__c = uId;
                    s.Accountable__c = false;
                    s.Backup_for_Accountable__c = false;
                    s.Responsible__c = true;
                    s.Description__c = '';
                    s.Veto_Rights__c = false;
                    s.Role_Acceptance_Required__c = false;
                    s.Role_Acceptance_Status__c = '';
                    s.Decision__c = decisionId;
                    newUsersToBeSaved.add(s);
        }
        
        insert newUsersToBeSaved;
    }
     public  void addCollaborator1(){
    /*    system.debug('decisionIddecisionIddecisionId'+decisionId);
        List<Social_Input__c> newUsersToBeSaved = new List<Social_Input__c>();
        //Need to split the string of comma seperated ids into a List
        List<Id> userIDs = userIdString.split(',');
        for(Id uId:userIDs){
                Social_Input__c s = new Social_Input__c();
                    s.Select_People__c = false;
                    s.User__c = uId;
                    s.Accountable__c = false;
                    s.Backup_for_Accountable__c = false;
                    s.Responsible__c = true;
                    s.Description__c = '';
                    s.Veto_Rights__c = false;
                    s.Role_Acceptance_Required__c = false;
                    s.Role_Acceptance_Status__c = '';
                    s.Decision__c = decisionId;
                    newUsersToBeSaved.add(s);
        }
        
        insert newUsersToBeSaved;
        */
    }
}