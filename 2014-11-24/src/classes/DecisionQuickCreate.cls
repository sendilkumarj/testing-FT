/* 
   ********************************************************************** 
    Created by: Neha
    Last Modified by: Neha
    Style: Force.com & Metro
    Description: The objective of this controller is to save the decision and add people to the decision very quickly.
    To add people an auto complete plugin is used. This will an pop up and will be accesible through custom links.           
   **********************************************************************  
*/
 
public with sharing class DecisionQuickCreate{
    
     // Initialize decision
    public Decision__c decision{get;set;}
    
    // Initialize list for Responsible,Accountable,Consulted,Informed
    private set<Id> responsibleData;
    private  set<Id> accountableData;
    private set<Id> consultedData;
    private set<Id> informedData;
    
    // Initialize approve immediately checkbox
    public  Boolean quickApproveChckbox{get;set;}
    
    //JSON string initialization section
    
    // JSON string for existing users
    public String userDataJSON {get;set;} 
    
    // JSON string for existing users and public gruop
    public String userGruopDataJSON {get;set;} 
    
    
    // JSON string for default user 
    public String defaultUserJSON {get;set;}
    
    
    // 
    public String loggedInUserId {get;set;}
    
    
     //variable to send user locale 
    public static string  userLocaleSidKey{get;set;}
    static{
            //set user locale here
            userLocaleSidKey  = UserInfo.getLocale().replace('_','-');
    } 
    
    public List<User> userList {get; set;}
     
    // Defining constructor
    public DecisionQuickCreate(ApexPages.StandardController controller){
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=8');
        // Create a new instance of decision
        decision = new  Decision__c();
        // Create a new instance for responsible, accountable,consulted,informed
        responsibleData= new set<Id>();
        accountableData= new set<Id>();
        consultedData= new set<Id>();
        informedData= new set<Id>();
        userList = [select id, Name, SmallPhotoUrl  from User where isactive = true and Id != : userInfo.getUserId()];
        viewPeople(); 
    }
    
    // Save decision with people
    public PageReference saveDecision(){
        string dec =decision.Title__c;
        System.debug('hhhhhhhhhhhhhhhhhhhhhhhhhhhh'+dec);
        // Declaring variable for redirection
        pageReference decisionViewPage;
        
        // Declaring variable to save data from text are to RTF field.
        String privateCheckbox = Apexpages.currentPage().getParameters().get('privateCheckbox'); 
        String approvalCheckBox = Apexpages.currentPage().getParameters().get('approvalCheckBox');
        String proposeCheckBox = Apexpages.currentPage().getParameters().get('proposeCheckBox');
        
        String textAreaProblemstatement = Apexpages.currentPage().getParameters().get('ProblemStatementValue');
        String textAreaDecision = Apexpages.currentPage().getParameters().get('DecisionValue');
        String textAreatitle = Apexpages.currentPage().getParameters().get('titleValue');
        String accoutableString = Apexpages.currentPage().getParameters().get('Accoutable');
        String decisionDuedate = Apexpages.currentPage().getParameters().get('dueDate');
        
        List<Id> accoutableList = accoutableString.split(',');
        accountableData.addAll(accoutableList);
        
        String responsibleString = Apexpages.currentPage().getParameters().get('Responsible');
        System.debug('--------responsibleString------------'+responsibleString);
        if(responsibleString != null && responsibleString != ''){
            List<Id> responsibleList = responsibleString.split(',');
            responsibleData.addAll(responsibleList);
        }
        
        String consultedString = Apexpages.currentPage().getParameters().get('Consulted');
        System.debug('--------consultedString------------'+consultedString);
        if(consultedString != null && consultedString != ''){
            List<Id> consultedList = consultedString.split(',');
            consultedData.addAll(consultedList);
        }
        
        String informedString = Apexpages.currentPage().getParameters().get('Informed');
        System.debug('--------informedString------------'+informedString);
        if(informedString != null && informedString != ''){
            List<Id> informedList = informedString.split(',');
            informedData.addAll(informedList);
        }
       
        // Checks for approve immediately checkbox is checked or not. 
         if(privateCheckbox == 'true'){
            decision.Private__c = true;
         }
         
         if(proposeCheckBox == 'true'){
            decision.Phase__c = 'Propose';
            decision.Status__c = 'Undecided';
            decision.Propose_Immediately__c = true;
         }
         
         if(approvalCheckBox == 'true'){
            decision.SYS_From_Quick_Decision__c = true;
         
         }
           
        if(decision.SYS_From_Quick_Decision__c){
            decision.Phase__c = 'Decide';
            decision.Status__c = 'Approved';
        }
        
       
        // Inserting decision record
        if(FLS.decisionCreateable()) {
            List<Id> ids = new List<Id>();
            ids.addAll(accountableData);
            //system.debug('decisionDuedatedecisionDuedatedecisionDuedate'+decisionDuedate);
            if( decisionDuedate.length() > 0){
                decision.Due_Date__c = DateTime.valueOf(decisionDuedate);
            }
            decision.Priority__c = Apexpages.currentPage().getParameters().get('priorityVal');
            decision.Problem_Idea_Advice__c = textAreaProblemstatement; 
            decision.Decision_Taken__c = textAreaDecision;
            decision.Title__c = textAreatitle;
            System.debug('------------decision.Title__c---------------->'+approvalCheckBox);
            System.debug('------------decision.Problem_Idea_Advice__c---------------->'+ textAreaProblemstatement);
            decision.Approved_when_Created__c = true;
            //decision.OwnerId = ids[0];
            insert decision;
            
            string chkFromPlan = ApexPages.currentPage().getParameters().get('fromPlanId');
            string addAsRealtion = ApexPages.currentPage().getParameters().get('addAsRealtion');
            string objectChosen = ApexPages.currentPage().getParameters().get('objType');
            string recId = ApexPages.currentPage().getParameters().get('recId');
            //Map to hold objects name and labels
            Map<String,String> objectNameLabelMap = new Map<String,String>(); 
            List<Schema.SObjectType> globaldescribe = Schema.getGlobalDescribe().Values();     
            List<SelectOption> userAccessibleobjectsUnSorted =  new List<SelectOption>();
            //Initialize the crmObjectsSet to make userAccessibleobjects hold only specified values
            set<String> crmObjectsSet = new set<String>{'Account','Asset','Case','Campaign','Contact','Contract','Idea','Lead','Opportunity','Order','Price Book','Product','Quote','Quote Line Item','Solution','User' };
            for(Schema.SObjectType f : globaldescribe) {   //for each object if it is viewable by user then add to userAccessibleobjects
                if( f.getDescribe().isAccessible() && crmObjectsSet.contains(f.getDescribe().getLabel()) ){
                    userAccessibleobjectsUnSorted.add(new SelectOption(f.getDescribe().getName(),f.getDescribe().getLabel()));
                    objectNameLabelMap.put(f.getDescribe().getName(),f.getDescribe().getLabel());
                }
            }
            if(addAsRealtion == 'true' || recId != null){
                // Relation record is create when a new Decision is created from standard object.
                DecisionQuickCreate.addAsRelation(objectChosen,recId,decision.Id,decision.Title__c);
                decisionViewPage = new pageReference('/apex/DecisionView?id='+decision.Id);
            } else if(chkFromPlan != null){
                Plan__c p = [select id,name from Plan__c where Id =:chkFromPlan];
                Relations__c r = new Relations__c();
                r.parent_Id__c = p.Id;
                r.parent_record_Name__c = p.name;
                r.parent_object_Name__c = 'Plan';
                r.child_Id__c = decision.Id;
                r.child_record_Name__c = decision.Title__c;
                r.child_object_Name__c = 'Decision';
                r.type__c = 'Item';
                if(Schema.SObjectType.Relations__c.fields.Parent_Record_Name__c.isCreateable() && Schema.SObjectType.Relations__c.fields.Parent_Id__c.isCreateable() && Schema.SObjectType.Relations__c.fields.Parent_Object_Name__c.isCreateable() && Schema.SObjectType.Relations__c.fields.Child_Id__c.isCreateable() && Schema.SObjectType.Relations__c.fields.Child_Object_Name__c.isCreateable() && Schema.SObjectType.Relations__c.fields.Child_Record_Name__c.isCreateable() && Schema.SObjectType.Relations__c.fields.Description__c.isCreateable() && Schema.SObjectType.Relations__c.fields.From_Relation__c.isCreateable() && Schema.SObjectType.Relations__c.fields.Strength__c.isCreateable() && Schema.SObjectType.Relations__c.fields.Notes__c.isCreateable() && Schema.SObjectType.Relations__c.fields.Type__c.isCreateable() && Schema.SObjectType.Relations__c.fields.To_Relation__c.isCreateable()){    
                    insert r;
                }
                decisionViewPage = new pageReference('/'+chkFromPlan);
            }else if(ApexPages.currentPage().getParameters().get('parentId') != null){
                 Decision__c parentDecision = [select id, Title__c from Decision__c where id=: ApexPages.currentPage().getParameters().get('parentId')];
                    Relations__c rel = new Relations__c();
                    rel.Child_ID__c = decision.Id;
                    rel.Child_Object_Name__c = 'Decision';
                    rel.Child_Record_Name__c = decision.Title__c;
                    rel.Child_Relation__c = 'Child';
                    rel.Parent_ID__c = parentDecision.Id;
                    rel.Parent_Record_Name__c = parentDecision.Title__c;
                    rel.Parent_Object_Name__c = 'Decision';
                if(FLS.relationCreateable()) {
                    insert rel;
                }
                decisionViewPage = new pageReference('/apex/decisionView?addRelations=true&id='+parentDecision.Id);
                
                
            } else if(ApexPages.currentPage().getParameters().get('fromDecisionTab') == 'true'){
                decisionViewPage = new pageReference('/apex/DecisionTab');
            } else{
                decisionViewPage = new pageReference('/apex/DecisionView?id='+decision.Id);
            }
           
            
            List<Social_Input__c> socialInputList = new List<Social_Input__c>();
            set<Id> selectedAccountable = new set<Id>(); 
            set<Id> selectedResponsible = new set<Id>(); 
            set<Id> selectedConsultant = new set<Id>(); 
            
            // Insert selected user as accountable
            for(Id a: accountableData) {
                    Social_Input__c si = new Social_Input__c();
                    si.Accountable__c = true;
                    si.Responsible__c = false;
                    si.Consulted__c = false;
                    si.Informed__c = false;
                    si.Decision__c = decision.ID;
                    si.Role_Acceptance_Required__c = false;
                    si.Role_Acceptance_Status__c = 'Approved/Accepted';
                    if(decision.Phase__c == 'Decide'){
                        si.Final_Approval_Status__c = 'Approved';
                        si.Stance_Approval_Status__c = 'Approved';
                        si.Approved_for__c = decision.Decision_Taken__c;
                    }
                    si.User__c = a;
                    socialInputList.add(si);
                    //si.OwnerId = ids[0];
                    selectedAccountable.add(a);
                    System.debug('--------------------------->' + selectedAccountable);
            } 
            
            System.debug('--------------------------->>' + responsibleData);
            System.debug('--------------------------->>' + consultedData);
            
            map<Id, Id> userGroupMap = new map<Id, Id>();
            for(GroupMember groupMember : [Select g.UserOrGroupId, g.Id, g.GroupId From GroupMember g where g.GroupId In: informedData]) {
                userGroupMap.put(groupMember.UserOrGroupId, groupMember.GroupId);
            }
            
            
            List<User> userList = [select id, Name,profileId, SmallPhotoUrl  from User where isactive = true];
            List<ObjectPermissions> objPermissins = [SELECT Id,PermissionsModifyAllRecords,ParentId FROM ObjectPermissions WHERE SobjectType = 'Decision__c'];
            set<Id> setPermissionsetIds = new set<Id>();
            for(ObjectPermissions op : objPermissins ){
                setPermissionsetIds.add(op.ParentId);
            }
            List<PermissionSet> permissionset = [SELECT Id,ProfileId FROM PermissionSet where Id IN : setPermissionsetIds];
            List<PermissionSetAssignment> perSetAssigned = [SELECT AssigneeId,Id,PermissionSetId,SystemModstamp FROM PermissionSetAssignment where PermissionSetId IN : setPermissionsetIds];
            
            // Insert selected user as responsible
            for(Id a: responsibleData) {
                System.debug('--------------------------->' + a);
          //      if(a != '' || a != ' ') {
                
                    if(selectedAccountable.contains(a)) {
                        List<Social_Input__c> socialInputList1 = socialInputData(a,socialInputList,'Responsible');
                        socialInputList.clear();
                        socialInputList.addAll(socialInputList1);
                        System.debug('socialInputList------->'+socialInputList);
                    }
                    else {
                        for(User u : userList){
                            for(PermissionSet ps : permissionset){
                                if(u.Id == a && u.ProfileId == ps.ProfileId){
                                    Social_Input__c si = new Social_Input__c();
                                    si.Responsible__c = true;
                                    si.Decision__c = decision.ID;
                                    si.User__c = a;
                                    si.Role_Acceptance_Required__c = false;
                                    si.Role_Acceptance_Status__c = 'Approved/Accepted';
                                    if(userGroupMap.get(a) != null) {
                                        si.GroupId__c = userGroupMap.get(a);
                                    }
                                    socialInputList.add(si);
                                    selectedResponsible.add(a);
                                    si.OwnerId = ids[0];
                                }
                            }
                            for(PermissionSetAssignment psa : perSetAssigned){
                                if(u.Id == psa.AssigneeId && !selectedResponsible.contains(u.Id) && u.Id == a){
                                    Social_Input__c si = new Social_Input__c();
                                    si.Responsible__c = true;
                                    si.Decision__c = decision.ID;
                                    si.User__c = a;
                                    si.Role_Acceptance_Required__c = false;
                                    si.Role_Acceptance_Status__c = 'Approved/Accepted';
                                    if(userGroupMap.get(a) != null) {
                                        si.GroupId__c = userGroupMap.get(a);
                                    }
                                    socialInputList.add(si);
                                    selectedResponsible.add(a);
                                    si.OwnerId = ids[0];
                                }
                            }
                        }
                    }
            //    }
            }
           System.debug('-----consultedData------->'+consultedData);
            // Insert selected user as consulted
            for(Id a: consultedData) {
               // if(a != '' || a != ' ') {
                    if(selectedAccountable.contains(a)) {
                        List<Social_Input__c> socialInputList1= socialInputData(a,socialInputList,'Consulted');
                        socialInputList.clear();
                        socialInputList.addAll(socialInputList1);
                    }
                    else if(selectedResponsible.contains(a)) {
                        List<Social_Input__c> socialInputList1 = socialInputData(a,socialInputList,'Consulted');
                        socialInputList.clear();
                        socialInputList.addAll(socialInputList1);
                    }
                    else {
                        for(User u : userList){
                            for(PermissionSet ps : permissionset){
                                if(u.Id == a && u.ProfileId == ps.ProfileId){
                                    Social_Input__c si = new Social_Input__c();
                                    si.Consulted__c = true;
                                    si.Decision__c = decision.Id;
                                    si.User__c = a;
                                    si.Role_Acceptance_Required__c = false;
                                    si.Role_Acceptance_Status__c = 'Approved/Accepted';
                                    if(userGroupMap.get(a) != null) {
                                        si.GroupId__c = userGroupMap.get(a);
                                    }
                                    socialInputList.add(si);
                                    si.OwnerId = ids[0];
                                    selectedConsultant.add(a);
                                }
                            }
                            for(PermissionSetAssignment psa : perSetAssigned){
                                if(u.Id == psa.AssigneeId && !selectedConsultant.contains(u.Id) && u.Id == a){
                                    Social_Input__c si = new Social_Input__c();
                                    si.Consulted__c = true;
                                    si.Decision__c = decision.ID;
                                    si.User__c = a;
                                    si.Role_Acceptance_Required__c = false;
                                    si.Role_Acceptance_Status__c = 'Approved/Accepted';
                                    if(userGroupMap.get(a) != null) {
                                        si.GroupId__c = userGroupMap.get(a);
                                    }
                                    socialInputList.add(si);
                                    selectedConsultant.add(a);
                                    si.OwnerId = ids[0];
                                }
                            }
                        }
                    } 
                //}
            }
           
            // Insert selected user as informed
            set<Id> setIdsInformed = new set<Id>();
            for(Id a: informedData) {
                if(selectedAccountable.contains(a)) {
                    List<Social_Input__c> socialInputList1 = socialInputData(a,socialInputList,'Informed');
                    socialInputList.clear();
                    socialInputList.addAll(socialInputList1);
                }
                else if(selectedResponsible.contains(a)) {
                    List<Social_Input__c> socialInputList1 = socialInputData(a,socialInputList,'Informed');
                    socialInputList.clear();
                    socialInputList.addAll(socialInputList1);
                }
                else if(selectedConsultant.contains(a)) {
                    List<Social_Input__c> socialInputList1 = socialInputData(a,socialInputList,'Informed');
                    socialInputList.clear();
                    socialInputList.addAll(socialInputList1);
                }
                else {
                    for(User u : userList){
                        for(PermissionSet ps : permissionset){
                            if(u.Id == a && u.ProfileId == ps.ProfileId){
                                Social_Input__c si = new Social_Input__c();
                                si.Informed__c = true;
                                si.Decision__c = decision.ID;
                                if(STring.Valueof(a).startsWith('005')) {
                                    si.User__c = a;
                                    si.Role_Acceptance_Required__c = false;
                                    si.Role_Acceptance_Status__c = 'Approved/Accepted';
                                }
                                else {
                                    si.GroupId__c = a;
                                    si.Is_Group__c = true;
                                }
                                si.OwnerId = ids[0];
                                setIdsInformed.add(a);
                                socialInputList.add(si);
                            }
                        }
                        for(PermissionSetAssignment psa : perSetAssigned){
                            if(u.Id == psa.AssigneeId && !setIdsInformed.contains(u.Id) && u.Id == a){
                                Social_Input__c si = new Social_Input__c();
                                si.Informed__c = true;
                                si.Decision__c = decision.ID;
                                if(STring.Valueof(a).startsWith('005')) {
                                    si.User__c = a;
                                    si.Role_Acceptance_Required__c = false;
                                    si.Role_Acceptance_Status__c = 'Approved/Accepted';
                                }
                                else {
                                    si.GroupId__c = a;
                                    si.Is_Group__c = true;
                                }
                                si.OwnerId = ids[0];
                                setIdsInformed.add(a);
                                socialInputList.add(si);
                            }
                        }
                    }
                    if(!String.Valueof(a).startsWith('005')){
                        Social_Input__c si = new Social_Input__c();
                        si.Informed__c = true;
                        si.Decision__c = decision.ID;
                        if(STring.Valueof(a).startsWith('005')) {
                            si.User__c = a;
                            si.Role_Acceptance_Required__c = false;
                            si.Role_Acceptance_Status__c = 'Approved/Accepted';
                        }
                        else {
                            si.GroupId__c = a;
                            si.Is_Group__c = true;
                        }
                        si.OwnerId = ids[0];
                        socialInputList.add(si);
                    }
                }          
            }
            
            if(!decision.SYS_From_Quick_Decision__c){
                //socialInputList.remove(0);
            }
            //
            // Insert people/raci list
            System.debug('socialInputList------->'+socialInputList);
            if(socialInputList.size() > 0 ) {
                
                
                if(FLS.socialInputCreateable()) {
                     insert socialInputList;
                }
                
                Decision__c d  = new Decision__c (id = decision.Id, OwnerId= ids[0]);
                update d;
                
                Social_Input__c logedInsocialInput = [Select  s.Role__c , s.Role_Acceptance_Status__c , s.Accountable__c, s.Backup_for_Accountable__c, s.Responsible__c,s.Consulted__c,s.Informed__c,s.Veto_Rights__c,s.Stance_Approval_Status__c,s.Final_Approval_Status__c   From Social_Input__c s where s.Decision__c =: decision.Id and s.User__c =: d.ownerid ];
                if(  decision.SYS_From_Quick_Decision__c  ){
                	Decision__c decisionQry  = [select id,Problem_Idea_Advice__c,Decision_Taken__c,ownerid from Decision__c where id =:decision.Id Limit 1];
                	Id userId = decisionQry.ownerid;
                    Id decisionId = decisionQry.Id;
                    String unitPost;
                    
                    if(decisionQry != null && decisionQry.Problem_Idea_Advice__c != null && decisionQry.Problem_Idea_Advice__c.length() > 3500){
                         unitPost = decision.Problem_Idea_Advice__c.substring(0,3500);
                         unitPost += '... Readmore in Fingertip';
                    }else{
                         unitPost = decisionQry.Problem_Idea_Advice__c;
                    }
                    
                	
                	String postText='I just shared this decision with you. Let’s get good insights and collaboration going!'+'\n'+'\n'+'Here is the description:'+'\n'+'\n'+'"'+unitPost+'"'+'\n';
                    //System.debug('mentionTextPost'+postText+'userId'+userId+'userId'+userId);
                    DecisionView.mentionTextPost( d.OwnerId, postText, decisionId);  
                    
                    postText='Here is the proposed Decision, read it and give your Stance.'+'\n'+'\n'+'Decision:'+'\n'+'"'+decision.Decision_Taken__c+'"'+'\n'+'\n'+'(hint: it’s done in the command center)';
            		Decisionview.mentionTextPostPropose(d.OwnerId,postText,decision.Id);
                	
                	Decision__c decisionProposeId  = [select FeedItem_Id_Propose__c from Decision__c where id =:decision.Id Limit 1];
                	
                	FeedComment fc = new FeedComment();
                	String roleString = '';             
                    roleString  =  roleString + ( logedInsocialInput.Accountable__c ? ' Accountable,':'' );
                    roleString  =  roleString + ( logedInsocialInput.Responsible__c ? ' Responsible,':'' );
                    roleString  =  roleString + ( logedInsocialInput.Consulted__c ? ' Consulted,':'' );
                    roleString  =  roleString + ( logedInsocialInput.Informed__c ? ' Informed,':'' );
                    roleString  =  roleString + ( logedInsocialInput.Backup_for_Accountable__c ? ' Backup,':'' );
                    roleString  =  roleString + ( logedInsocialInput.Veto_Rights__c ? ' Veto,':'' );
                    roleString  =  roleString.reverse(); 
                    roleString  =  roleString.replaceFirst(',','');
                    roleString  =  roleString.replaceFirst(',',' dna ');
                    roleString  =  roleString.reverse();
					fc.CommentBody = 'Has approved the decision as ' + roleString +'.';
					fc.CreatedById = d.OwnerId;
					fc.FeedItemId = Id.valueOf(decisionProposeId.FeedItem_Id_Propose__c);
                	if( FLS.feedCommentCreatable()){ 
                    	insert fc;
                	}
                } else if(decision.Propose_Immediately__c == true){
                	//Decision__c decisionQry  = [select id,ownerid from Decision__c where id =:d.Id Limit 1];
                	//System.debug('-------decisionQry------>'+decisionQry);
                	Id userId = decision.ownerid;
                    Id decisionId = decision.Id;
                    String unitPost;
                    
                    if(decision != null && decision.Problem_Idea_Advice__c != null && decision.Problem_Idea_Advice__c.length() > 3500){
                         unitPost = decision.Problem_Idea_Advice__c.substring(0,3500);
                         unitPost += '... Readmore in Fingertip';
                    }else{
                         unitPost = decision.Problem_Idea_Advice__c;
                    }
                	String postText='I just shared this decision with you. Let’s get good insights and collaboration going!'+'\n'+'\n'+'Here is the description:'+'\n'+'\n'+'"'+unitPost+'"'+'\n';
                    //System.debug('mentionTextPost'+postText+'userId'+userId+'userId'+userId);
                    DecisionView.mentionTextPost( userId, postText, decisionId);
                	
                	postText='Here is the proposed Decision, read it and give your Stance.'+'\n'+'\n'+'Decision:'+'\n'+'"'+decision.Decision_Taken__c+'"'+'\n'+'\n'+'(hint: it’s done in the command center)';
            		Decisionview.mentionTextPostPropose(userId,postText,decision.Id);
                }
                
                
                System.debug('**************'+[select id, accesslevel, UserOrGroupId, ParentId from Decision__Share where ParentId =: decision.ID ]);
                List<Social_Input__c> toBeUpdatedSocialInput = [Select Responsible__c,Accountable__c,Consulted__c,Informed__c from Social_Input__c where Decision__c =: decision.ID ];
                if(toBeUpdatedSocialInput .size() > 0) {
                    
                    if(FLS.socialInputUpdateable()) {
                       // update toBeUpdatedSocialInput;
                    }
                }
                 
                                      
            }
            
            
             // Create a chatter post if decision is approved while creating
       
        }   
        decisionViewPage.setRedirect(true);
        return decisionViewPage;
    }
    
    public static void addAsRelation(String objectChosen,String recId,Id decisionId,String decisionTitle){
        //Map to hold objects name and labels
        Map<String,String> objectNameLabelMap = new Map<String,String>(); 
        List<Schema.SObjectType> globaldescribe = Schema.getGlobalDescribe().Values();     
        List<SelectOption> userAccessibleobjectsUnSorted =  new List<SelectOption>();
        //Initialize the crmObjectsSet to make userAccessibleobjects hold only specified values
        set<String> crmObjectsSet = new set<String>{'Account','Asset','Case','Campaign','Contact','Contract','Idea','Lead','Opportunity','Order','Price Book','Product','Quote','Quote Line Item','Solution','User' };
        for(Schema.SObjectType f : globaldescribe) {   //for each object if it is viewable by user then add to userAccessibleobjects
            if( f.getDescribe().isAccessible() && crmObjectsSet.contains(f.getDescribe().getLabel()) ){
                userAccessibleobjectsUnSorted.add(new SelectOption(f.getDescribe().getName(),f.getDescribe().getLabel()));
                objectNameLabelMap.put(f.getDescribe().getName(),f.getDescribe().getLabel());
            }
        }
        List<Relations__c> srchRelationshipSet = new List<Relations__c>();
        if(objectChosen != 'Contract' && objectChosen != 'QuoteLineItem' && objectChosen != 'Idea' &&   objectChosen != 'Solution' && objectChosen != 'Case'){
            List<sObject> records = Database.query('Select Id, Name From ' + String.escapeSingleQuotes(objectChosen) + ' Where Id = : recId limit 1');
            for(SObject record : records){
                Relations__c r = new Relations__c();
                r.select__c = false;
                r.Child_Record_Name__c = (String) record.get('Name');
                r.Child_ID__c = (String) record.get('Id');
                r.Child_Object_Name__c = objectNameLabelMap.get(objectChosen); 
                r.type__c = 'Relation';
                r.parent_Id__c = decisionId;
                r.parent_record_Name__c = decisionTitle;
                r.parent_object_Name__c = 'Decision';
                r.From_Relation__c = 'Parent';
                r.To_Relation__c = 'Child';
                srchRelationshipSet.add(r);  
            }
        }
        if(objectChosen == 'QuoteLineItem'  ){ 
            List<sObject> records = Database.query('Select Id, LineNumber  From ' + 'QuoteLineItem' + ' Where Id = : recId limit 1 ');
            for(SObject record : records){
                Relations__c r = new Relations__c();
                r.select__c = false;
                r.Child_Record_Name__c = (String) record.get('LineNumber');
                r.Child_ID__c = (String) record.get('Id');
                r.Child_Object_Name__c = objectNameLabelMap.get(objectChosen);
                r.type__c = 'Relation';
                r.parent_Id__c = decisionId;
                r.parent_record_Name__c = decisionTitle;
                r.parent_object_Name__c = 'Decision';
                r.From_Relation__c = 'Parent';
                r.To_Relation__c = 'Child';
                srchRelationshipSet.add(r);  
            }           
        }
        if(objectChosen == 'Solution'  ){
            List<sObject> records = Database.query('Select Id, SolutionName  From ' + 'Solution' + ' Where Id = : recId limit 1 ');
            for(SObject record : records){
                Relations__c r = new Relations__c();
                r.select__c = false;
                r.Child_Record_Name__c = (String) record.get('SolutionName');
                r.Child_ID__c = (String) record.get('Id');
                r.Child_Object_Name__c = objectNameLabelMap.get(objectChosen);
                r.type__c = 'Relation';
                r.parent_Id__c = decisionId;
                r.parent_record_Name__c = decisionTitle;
                r.parent_object_Name__c = 'Decision';
                r.From_Relation__c = 'Parent';
                r.To_Relation__c = 'Child';
                srchRelationshipSet.add(r);
            }           
        }
        if(objectChosen == 'Case'  ){
            List<sObject> records = Database.query('Select Id, CaseNumber, Subject  From ' + 'Case' + ' Where Id = : recId limit 1 ');
            for(SObject record : records){
                Relations__c r = new Relations__c();
                r.select__c = false;
                if( (String) record.get('Subject') == null)
                    r.Child_Record_Name__c = 'No Subject';
                else
                    r.Child_Record_Name__c = (String) record.get('Subject');
                r.Child_ID__c = (String) record.get('Id');
                r.Child_Object_Name__c = objectNameLabelMap.get(objectChosen);
                r.type__c = 'Relation';
                r.parent_Id__c = decisionId;
                r.parent_record_Name__c = decisionTitle;
                r.parent_object_Name__c = 'Decision';
                r.From_Relation__c = 'Parent';
                r.To_Relation__c = 'Child';
                srchRelationshipSet.add(r);
            }            
        }
        if(objectChosen == 'Contract'  ){
            List<sObject> records = Database.query('Select Id, Name, ContractNumber  From ' + 'Contract' + ' Where Id = : recId limit 1 ');
            for(SObject record : records){
                Relations__c r = new Relations__c();
                r.select__c = false;
                if( (String) record.get('Name') == null)
                    r.Child_Record_Name__c = 'No Name';
                else
                    r.Child_Record_Name__c = (String) record.get('Name');
                r.Child_ID__c = (String) record.get('Id');
                r.Child_Object_Name__c = objectNameLabelMap.get(objectChosen);
                r.type__c = 'Relation';
                r.parent_Id__c = decisionId;
                r.parent_record_Name__c = decisionTitle;
                r.parent_object_Name__c = 'Decision';
                r.From_Relation__c = 'Parent';
                r.To_Relation__c = 'Child';
                srchRelationshipSet.add(r);
            }            
        } 
        if(!srchRelationshipSet.isEmpty()){
            if(Schema.SObjectType.Relations__c.fields.Parent_Record_Name__c.isCreateable() && Schema.SObjectType.Relations__c.fields.Parent_Id__c.isCreateable() && Schema.SObjectType.Relations__c.fields.Parent_Object_Name__c.isCreateable() && Schema.SObjectType.Relations__c.fields.Child_Id__c.isCreateable() && Schema.SObjectType.Relations__c.fields.Child_Object_Name__c.isCreateable() && Schema.SObjectType.Relations__c.fields.Child_Record_Name__c.isCreateable() && Schema.SObjectType.Relations__c.fields.Description__c.isCreateable() && Schema.SObjectType.Relations__c.fields.From_Relation__c.isCreateable() && Schema.SObjectType.Relations__c.fields.Strength__c.isCreateable() && Schema.SObjectType.Relations__c.fields.Notes__c.isCreateable() && Schema.SObjectType.Relations__c.fields.Type__c.isCreateable() && Schema.SObjectType.Relations__c.fields.To_Relation__c.isCreateable()){    
                insert srchRelationshipSet;
                System.debug('-------srchRelationshipSet----->'+srchRelationshipSet);
            }
        }
        
    }
    /*************************************Add as a relation***********************************/
     @RemoteAction
    public static String decisionCopy(String objectChosen,String addAsRelationId,String decisionId, Boolean people, Boolean reasetDate, Boolean tasks, Boolean relationships, Boolean isRelatedTo, Boolean assignToMe, String relation, Boolean attachments) {
        // Query decision
        Decision__c decision = [Select  d.Valid_Until__c, d.Valid_From__c, d.Title__c, d.Tag__c, d.SystemModstamp, d.Status__c, d.SYS_From_Quick_Decision__c, d.Reason_for_Close__c, d.Problem_Idea_Advice__c, d.Private__c, d.Priority__c, d.Point_of_No_Return__c, d.Phase__c, d.Parent_Decision__c, d.OwnerId, d.Name, d.LastModifiedDate, d.LastModifiedById, d.LastActivityDate, d.IsDeleted, d.Id, d.Estimated_People_Involved__c, d.Estimated_Net_Present_Value__c, d.Estimated_Investment__c, d.Estimated_Full_time_Equivalent_FTE__c, d.Estimated_Direct_Cost__c, d.Due_Date__c, d.Decision_Taken__c, d.Decision_Type__c, d.Decision_Making_Style__c, d.Decision_Approach__c, d.Category__c, d.CreatedDate, d.CreatedById, d.Comments__c, d.Approved_when_Created__c, d.Add_C_I_Members__c, d.Actual_People_Involved__c, d.Actual_Net_Present_Value__c, d.Actual_Investment__c, d.Actual_Full_time_Equivalent_FTE__c, d.Actual_Direct_Cost__c, d.Accountable__c,d.Estimated_People_Involved_Desc__c, d.Estimated_Net_Present_Value_Desc__c, d.Estimated_Investment_Desc__c, d.Estimated_Full_time_Equivalent_Desc__c, d.Estimated_Direct_Cost_Desc__c, d.Actual_People_Involved_Desc__c, d.Actual_Net_Present_Value_Desc__c, d.Actual_Investment_Desc__c, d.Actual_Full_time_Equivalent_Desc__c, d.Actual_Direct_Cost_Desc__c,d.Estimated_Revenue__c, d.Estimated_Revenue_Desc__c, d.Actual_Revenue__c, d.Actual_Revenue_Desc__c From Decision__c d where d.Id =: decisionId];
        
        // Clone decision 
        Decision__c cloneDecision = decision.clone(false);
        cloneDecision.Phase__c= 'Draft';
        cloneDecision.Status__c = 'Undecided';
        cloneDecision.Title__c = 'Copy - '+ cloneDecision.Title__c;
        if(cloneDecision.Title__c.length() > 129) {
            cloneDecision.Title__c = cloneDecision.Title__c.substring(0,129);
        }
        // Resets important dates when cloning decision.
        if(reasetDate) {
            cloneDecision.Due_Date__c = null;
            cloneDecision.Valid_Until__c = null;
            cloneDecision.Valid_From__c = null; 
            cloneDecision.Point_of_No_Return__c = null; 
        }
        cloneDecision.OwnerId = userInfo.getUserId();
        
        // inserts copy of the decision.
        if(FLS.decisionCreateable()) {
            insert cloneDecision;
        }
        
        // Clone people.
        // Creates a list to add people.
        List<Social_Input__c> toBeCloneSocialInput = new List<Social_Input__c>();
        
        // Clone collabrator list for QCD.
        if(cloneDecision.Approved_when_Created__c) {
            Social_Input__c socialInput = new Social_Input__c();
            socialInput.Accountable__c = true;
            socialInput.User__c = cloneDecision.OwnerId;
            socialInput.Decision__c = cloneDecision.Id;
            toBeCloneSocialInput.add(socialInput);
        }
        // Clone collaborator list for decision.
        if(people){
            for(Social_Input__c si : [Select s.Is_Group__c,s.User__r.isActive,s.Stance_Approval_Status__c, s.Role_Acceptance_Required__c, s.GroupId__c, s.Veto_Rights__c, s.User__c,s.Description__c,  s.Responsible__c, s.Informed__c, s.Consulted__c, s.Backup_for_Accountable__c, s.Accountable__c From Social_Input__c s where s.Decision__c =: decisionId]) {
                if((si.User__r.isActive == True && si.User__c != null) || si.User__c == null){
                    if(si.User__c != userInfo.getUserId()) {
                    
                        Social_Input__c socialInput = new Social_Input__c();
                        socialInput.Responsible__c = si.Responsible__c;
                        if(si.Accountable__c) {
                            si.Accountable__c = false;
                            socialInput.Responsible__c = true;
                        }
                        socialInput.Informed__c = si.Informed__c;
                        socialInput.Consulted__c = si.Consulted__c;
                        socialInput.Backup_for_Accountable__c = si.Backup_for_Accountable__c;
                        socialInput.Veto_Rights__c = si.Veto_Rights__c;
                        socialInput.User__c = si.User__c;
                        socialInput.GroupId__c = si.GroupId__c;
                        socialInput.Is_Group__c = si.Is_Group__c;
                        socialInput.Decision__c = cloneDecision.Id;
                        socialInput.Description__c = si.Description__c;
                        socialInput.Role_Acceptance_Required__c = si.Role_Acceptance_Required__c;
                        toBeCloneSocialInput.add(socialInput);
                    }
                }
            }
        }
        
        // Clone relations.
        // Creates a list to add relations.
        List<Relations__c> toBeCloneRelations = new List<Relations__c>();
        
        // Clone relations list
        if(relationships) {
            for(Relations__c r : [Select r.Type__c, r.Strength__c, r.From_Relation__c, r.Parent_Record_Name__c, r.Parent_Object_Name__c, r.Parent_ID__c, r.Notes__c, r.To_Relation__c, r.Child_Record_Name__c, r.Child_Object_Name__c, r.Child_ID__c From Relations__c r where r.Type__c =: 'Relation' and ( r.Parent_ID__c =: decisionId or  r.Child_ID__c =: decisionId )]){
                Relations__c rel = new Relations__c();
                if(r.Parent_ID__c == decisionId) {
                    rel.Parent_ID__c = cloneDecision.Id;
                    rel.Parent_Record_Name__c = cloneDecision.Title__c;
                    rel.Parent_Object_Name__c = 'Decision';
                    rel.Child_ID__c = r.Child_ID__c;
                    rel.Child_Record_Name__c = r.Child_Record_Name__c;
                    rel.Child_Object_Name__c = r.Child_Object_Name__c;
                }
                else {
                    rel.Parent_ID__c = r.Parent_ID__c;
                    rel.Parent_Record_Name__c = r.Parent_Record_Name__c;
                    rel.Parent_Object_Name__c = r.Parent_Object_Name__c;
                    rel.Child_ID__c = cloneDecision.Id;
                    rel.Child_Record_Name__c = cloneDecision.Title__c;
                    rel.Child_Object_Name__c = 'Decision';
                }
                rel.From_Relation__c = r.From_Relation__c;
                rel.To_Relation__c = r.To_Relation__c;
                rel.Strength__c = r.Strength__c;
                rel.Notes__c = r.Notes__c;
                toBeCloneRelations.add(rel);
            }
        }
        // Creates a relation record of decision from where it is cloned.
        if(isRelatedTo) {
            Relations__c rel = new Relations__c();
            rel.Parent_ID__c = decision.Id;
            rel.Parent_Record_Name__c = decision.Title__c;
            rel.Parent_Object_Name__c = 'Decision';
            rel.Child_ID__c = cloneDecision.Id;
            rel.Child_Record_Name__c = cloneDecision.Title__c;
            rel.Child_Object_Name__c = 'Decision';
            rel.To_Relation__c = relation;
              // -- Start added on 26_02_2014 to add the reciprocal relation when clone is done. 
            //IF "To Relation" is child then "From Relation" will be Parent,IF "To Relation" is Parent then "From Relation" will be Child, IF "To Relation" is Sibling then "From Relation" will be Sibling
            //IF "To Relation" is blank then "From Relation" will blank
            rel.From_Relation__c  = rel.To_Relation__c  == 'Parent' ? 'Child' : rel.To_Relation__c  == 'Child' ? 'Parent' : rel.To_Relation__c ==  'Sibling' ? 'Sibling' : '' ;
            //-- end added on 26_02_2014 to add the reciprocal relation when clone is done.
            toBeCloneRelations.add(rel);
        }
        
        // Clone tasks.
        // Creates a list to add tasks.
        List<Task> toBeInsertedTask = new List<Task>();
        
        // Clone task list
        if(tasks) {
            for(Task task: [select Id,WhatId,OwnerId, Owner.Name ,ActivityDate,Status,Priority,Subject,Description from Task where whatId=:decisionId order by subject desc] ){
                Task cloneTask = task.clone(false);
                cloneTask.WhatId = cloneDecision.Id;
                cloneTask.Status = 'Not Started';
                if(assignToMe){
                    cloneTask.OwnerId = userInfo.getUserId();
                }
                if(reasetDate) {
                    cloneTask.ActivityDate = null;
                }
                toBeInsertedTask.add(cloneTask);
            }
        }
        
        // Clone attachments
        // Creates a list to add attachments.
        List<Attachment>  toBeCloneAttachments = new List<Attachment>();
        //list of clone Feed Attachment 
        List<Attachment> toBeCloneFeedAttachment = new List<Attachment>();
        Set<ID> contentVersionRecordId = new Set<ID>();
        // To check whether the copy attachments is checked or not.
        if(attachments){
            // Clone attachment list  
            // query for RelatedRecordId in chatter feed 
             for(Decision__Feed feedItm:[SELECT ContentFileName,ParentId,RelatedRecordId FROM Decision__Feed where ParentId= :decisionId ]){
                if(feedItm.RelatedRecordId != null){
                    contentVersionRecordId.add(feedItm.RelatedRecordId);
                    System.debug('clonefeedItemclonefeedItemclonefeedItem'+contentVersionRecordId);
                }
            }
            // query for chatter feed Attactment in ContentVersion 
            For(ContentVersion contnVersion: [SELECT Id,Title,PathOnClient, ContentDocumentId,VersionData FROM ContentVersion WHERE ID In : contentVersionRecordId]  ){
                
                Attachment cloneAttachment = new Attachment() ;
                cloneAttachment.ParentId = cloneDecision.Id;
                cloneAttachment.Name = contnVersion.PathOnClient;
                cloneAttachment.Body = contnVersion.VersionData;
                toBeCloneFeedAttachment.add(cloneAttachment);

            }
                     
            for(Attachment attachment : [select id, Name, Body from Attachment where ParentId =: decisionId]){
                    if(attachment.Name == decisionId ){
                        continue;
                    }
                    Attachment cloneAttachment = attachment.clone(false);
                    cloneAttachment.ParentId = cloneDecision.Id;
                    cloneAttachment.Name = attachment.Name;
                    cloneAttachment.Body = attachment.Body;
                    toBeCloneAttachments.add(cloneAttachment);
                }
            
            
        }
        
        // inserts attachment lists.
        if(toBeCloneAttachments.size() > 0  ) {
           if(FLS.attachmentCreateable()) {
                insert toBeCloneAttachments;
           }
        }
        
        //insert Feed Attachment list
        if(toBeCloneFeedAttachment.size() > 0 ){
            if(FLS.attachmentCreateable()) {
                insert toBeCloneFeedAttachment;
           }
        
        }
        
        // inserts social input lists.
        if(toBeCloneSocialInput.size() > 0) {
            if(FLS.socialInputCreateable()) {
                insert toBeCloneSocialInput;
            }
        }
        
       // inserts relations lists.
        if(toBeCloneRelations.size() > 0) {
            if(FLS.relationCreateable()) {
                insert toBeCloneRelations;
            }
        }
        
       // inserts tasks lists.
        if(toBeInsertedTask.size() > 0) {
            if(FLS.taskCreateable()){
                insert toBeInsertedTask;
            }
        }
        // add relation from std objcect 
        if(addAsRelationId.length() > 1){
                system.debug('addAsRelationIdaddAsRelationIdaddAsRelationId'+addAsRelationId.length());
                // Relation record is create when a new Decision is created from standard object.
                DecisionQuickCreate.addAsRelation(objectChosen,addAsRelationId,cloneDecision.Id,cloneDecision.Title__c);
             pageReference   decisionViewPage = new pageReference('/apex/DecisionView?id='+cloneDecision.Id);
                decisionViewPage.setRedirect(true);
            }
        // returns the id of the decision to be cloned.
        return cloneDecision.Id;    
    }
    
    // Save RACI 
    private String selectedId= '';
    
    private List<Id> selectedIdList;
    
    public void saveUserIdListRes(){
        System.debug('selectedIdList-------->'+selectedIdList);
        
        responsibleData.addAll(selectedIdList);
    }
    
    public void saveUserIdListCon(){
       
    }
     
    public void saveUserIdRes(){
        
    }
    
    public void saveUserIdAcc(){
        
    }
    
    public void saveUserIdCon(){
        
    }
    
    public void saveUserIdInfo(){
        
    }
    
    // Delete RACI
    public void delUserIdRes(){
       
    }
   
    public void delUserIdAcc(){
       
    }
    
    public void delUserIdCon(){
       
    }
    
    public void delUserIdInfo(){
       
    }
    
    public string viewPeople(){
        
        //
        GeneralInformation genralInfo  = new GeneralInformation();
        // Get all permission set user 
        //List<PermissionSet> PermissionSetList = [Select id from PermissionSet where id in (SELECT  ParentId FROM ObjectPermissions) ];
        
        //List<profile> profileList = [Select id from profile where id in ( select ProfileId from PermissionSet where id in : PermissionSetList   ) ];
      
      
        // List of user who are active
        List<User> userList = [select id, Name,profileId, SmallPhotoUrl  from User where isactive = true];
        List<ObjectPermissions> objPermissins = [SELECT Id,PermissionsModifyAllRecords,ParentId FROM ObjectPermissions WHERE SobjectType = 'Decision__c'];
        set<Id> setPermissionsetIds = new set<Id>();
        for(ObjectPermissions op : objPermissins ){
            setPermissionsetIds.add(op.ParentId);
        }
        List<PermissionSet> permissionset = [SELECT Id,ProfileId FROM PermissionSet where Id IN : setPermissionsetIds];
        List<PermissionSetAssignment> perSetAssigned = [SELECT AssigneeId,Id,PermissionSetId,SystemModstamp FROM PermissionSetAssignment where PermissionSetId IN : setPermissionsetIds];
        // Initialize existing user list
        List<UserData> userDataJSONList = new List<UserData>();
        
        // Initialize existing user list
        List<UserData> userGruopDataJSONList = new List<UserData>();
        
        
        // Initialize default user list
        List<UserData> defaultUserJSONList = new List<UserData>();
        
        // Mapping fields for default user (That is accountable)
        loggedInUserId = userinfo.getuserId();
        
        UserData defaultUser = new UserData();
        defaultUser.id = userinfo.getuserId();
        defaultUser.name =  String.escapeSingleQuotes(Userinfo.getName());
        defaultUserJSONList.add(defaultUser);
       
        Integer i=0;
        set<Id> setUserIds = new set<Id>();
        for(User u: userList){
            for(PermissionSet ps : permissionset){
                if(u.ProfileId == ps.ProfileId){
                    UserData existingUser = new UserData();
                    existingUser.id = String.valueof(u.Id);
                    existingUser.name =  String.escapeSingleQuotes(u.Name);
                    existingUser.url = u.SmallPhotoUrl;
                    userDataJSONList.add(existingUser);
                    setUserIds.add(u.Id);
                    userGruopDataJSONList.add(existingUser);
                }
            }
            for(PermissionSetAssignment psa : perSetAssigned){
                if(u.Id == psa.AssigneeId && !setUserIds.contains(u.Id)){
                    UserData existingUser = new UserData();
                    existingUser.id = String.valueof(u.Id);
                    existingUser.name =  String.escapeSingleQuotes(u.Name);
                    existingUser.url = u.SmallPhotoUrl;
                    userDataJSONList.add(existingUser);
                    setUserIds.add(u.Id);
                    userGruopDataJSONList.add(existingUser);
                }
            }
        } 
        
        //generate map for Group with Group members
        map<Id,List<String>> groupMembermap = new map<Id,List<String>>();
        for(GroupMember gruopMember : [Select g.UserOrGroupId, g.Id, g.GroupId From GroupMember g limit 10000]) {
            List<String> groupMemberLIst = groupMembermap.get(gruopMember.GroupId);
            if(groupMemberLIst == null) {
                groupMemberLIst = new List<String>();
                groupMembermap.put(gruopMember.GroupId, groupMemberLIst);
            }
           // groupMemberLIst.add(gruopMember.UserOrGroupId);
        }
        
        for(Group g : [Select g.Name, g.Id From Group g]) {
            if(g.Name != null && g.Name != '' && groupMembermap.get(g.Id) != null) {
                UserData existingGruop = new UserData();
                existingGruop.id = String.valueof(g.Id);
                existingGruop.name =  String.escapeSingleQuotes(g.Name);
                existingGruop.url = '/'+ genralInfo.imageUrlMap.get('group');
                userGruopDataJSONList.add(existingGruop);
            }   
        }
        System.debug('--------userGruopDataJSONList---------->'+userGruopDataJSONList);
        // serialize defaultUser and existingUser list
        userGruopDataJSON = JSON.serialize(userGruopDataJSONList);
        
        // serialize defaultUser and existingUser list
        defaultUserJSON = JSON.serialize(defaultUserJSONList);
       
        userDataJSON = JSON.serialize(userDataJSONList);
        
        return userDataJSON;
        
    }
    
    // List of people
    public List<Social_Input__c> socialInputData(Id userId, List<Social_Input__c> socialInputList, String role) {
        System.debug('userId'+userId);
        System.debug('socialInputList'+socialInputList);
        
        System.debug('socialInputList'+role);
        List<Social_Input__c> newSocialInputList = new List<Social_Input__c>();
        for(Social_Input__c si: socialInputList){
            String nameOfUser = si.User__c ;
            if(si.User__c  == userId) {
                if(role == 'Responsible' ) {
                    si.Responsible__c = true;
                }
                else if(role == 'Consulted'){
                    si.Consulted__c = true;
                }
                else if(role == 'Informed'){
                    si.Informed__c = true;
                }
            }
            newSocialInputList.add(si);
            System.debug('socialInputList'+si);            
        }
        return newSocialInputList;
    }
     
    // Cancel Decision
    public pagereference cancelDecision(){
        //Variable to fetch the plan URL paramaters.
        string chkFromPlan = ApexPages.currentPage().getParameters().get('fromPlanId');
        //Variable to fetch the decision URL paramaters.
        string chkFromDecision = ApexPages.currentPage().getParameters().get('retURL');
        // To get the keyprefix of decision object dynamically.
        set<String> objectList = new set<String>();
        String x;
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        for(String sObj : Schema.getGlobalDescribe().keySet()){
            Schema.DescribeSObjectResult r =  gd.get(sObj).getDescribe();
            String tempName = r.getName();
            String tempPrefix = r.getKeyPrefix();
            if(tempName.equals('fingertip_a__Decision__c') || tempName.equals('Decision__c')) {
                System.debug(tempPrefix);
                objectList.add(tempPrefix);
                x = tempPrefix;
            }
        }
        pageReference homePage;
        
        string addAsRealtion = ApexPages.currentPage().getParameters().get('addAsRealtion');
        string recId = ApexPages.currentPage().getParameters().get('recId');
        if(addAsRealtion == 'true'){
            homePage = new pageReference('/'+recId);
        } else if(chkFromPlan != null){
            // Condition to check if the URL is from plan 
            homePage = new pageReference('/'+chkFromPlan);
        } else if(chkFromDecision != null){   // Condition to check if the URL is from decision
            homePage = new pageReference('/'+x+'/o');
        } else if(ApexPages.currentPage().getParameters().get('parentId') != null){
            string parentId =ApexPages.currentPage().getParameters().get('parentId');
             homePage = new Pagereference('/apex/DecisionView?id='+parentId+'&sfdc.override=1#0');
            //return homePage;
        } else if(ApexPages.currentPage().getParameters().get('fromDecisionTab') == 'true'){
                homePage = new pageReference('/apex/DecisionTab');
        } else {
            homePage = new pageReference('/apex/HomePage');
        }
        homePage.setRedirect(true);
        return homePage;
    }
    
    public void setState(String n) {
       
    }
            
    public String getState() {
        return null;
    }
    
    public void setStateList(String n) {
        
    }
            
    public List<String> getStateList() {
        return null;
    }
    
    
    
    @RemoteAction
    public static String addGroupMember(String gruopId) {
        Map<id,Boolean> userActivity = new map<Id,Boolean>(); 
        GeneralInformation generalInfo = new GeneralInformation();
        for(User u: [Select id,IsActive from User where id != null]){
            userActivity.put(u.id,u.IsActive);  
        }
        List<User> userList = [select id, Name,profileId, SmallPhotoUrl  from User where isactive = true];
        
        List<ObjectPermissions> objPermissins = [SELECT Id,PermissionsModifyAllRecords,ParentId FROM ObjectPermissions WHERE SobjectType = 'Decision__c'];
        set<Id> setPermissionsetIds = new set<Id>();
        for(ObjectPermissions op : objPermissins ){
            setPermissionsetIds.add(op.ParentId);
        }
        List<PermissionSet> permissionset = [SELECT Id,ProfileId FROM PermissionSet where Id IN : setPermissionsetIds];
        List<PermissionSetAssignment> perSetAssigned = [SELECT AssigneeId,Id,PermissionSetId,SystemModstamp FROM PermissionSetAssignment where PermissionSetId IN : setPermissionsetIds];
        set<Id> setIds = new set<Id>();
        List<UserData> gruopMemberList = new List<UserData>();
        for(GroupMember g :[Select g.UserOrGroupId, g.GroupId From GroupMember g where g.GroupId  =:gruopId]) {
            for(User u: userList){
                for(PermissionSet ps : permissionset){
                    if(u.ProfileId == ps.ProfileId && g.UserOrGroupId == u.Id){
                        if(userActivity.get(g.UserOrGroupId) != null && userActivity.get(g.UserOrGroupId) == true && !setIds.contains(u.Id)){
                            UserData groupUser = new UserData();
                            groupUser.id = g.UserOrGroupId;
                            groupUser.name = generalInfo.useNameMap.get(g.UserOrGroupId).Name;
                            gruopMemberList.add(groupUser);
                            setIds.add(u.Id);
                        }
                    }
                }
                for(PermissionSetAssignment psa : perSetAssigned){
                    if(u.Id == psa.AssigneeId && g.UserOrGroupId == u.Id){
                        if(userActivity.get(g.UserOrGroupId) != null && userActivity.get(g.UserOrGroupId) == true && !setIds.contains(u.Id)){
                            UserData groupUser = new UserData();
                            groupUser.id = g.UserOrGroupId;
                            groupUser.name = generalInfo.useNameMap.get(g.UserOrGroupId).Name;
                            gruopMemberList.add(groupUser);
                            setIds.add(u.Id);
                        }
                    }
                }
            }
            if(!String.Valueof(g.UserOrGroupId).startsWith('005')){
                if(userActivity.get(g.UserOrGroupId) != null && userActivity.get(g.UserOrGroupId) == true){
                    UserData groupUser = new UserData();
                    groupUser.id = g.UserOrGroupId;
                    groupUser.name = generalInfo.useNameMap.get(g.UserOrGroupId).Name;
                    gruopMemberList.add(groupUser);
                }
            }
        }
        
        return JSON.serialize(gruopMemberList);
    }
    
    
    
    /***************This section for clone Decsion List & Search*******************************/
     public static string cloneDecisionJSON{get;set;} 
    
    @RemoteAction
    public  static string cloneDecisionWithSearch(String searchText ){
            GeneralInformation genralInfo  = new GeneralInformation();
            string dateTimeFormat = genralInfo.MapValuesDateTime();
            
            if(searchText != ''){
                if(searchText.contains('*')){
                    String SearchtextList=searchText.replaceAll('\\*','\\%');
                    searchText = SearchtextList;
                }
            }
            
            List<Social_Input__c> myCloneDecisionList = new List<Social_Input__c>();
            
            if(searchText != ''){
                searchText = searchText+'%';
                myCloneDecisionList = [select id, Decision__c,Decision__r.LastModifiedDate, Decision__r.Title__c,Decision__r.Problem_Idea_Advice__c,Decision__r.Decision_Taken__c, Decision__r.OwnerId, Decision__r.Phase__c,Role__c,Decision__r.Nearest_Due_Date__c from Social_Input__c where User__c =: UserInfo.getUserId() and (Accountable__c = true or Backup_for_Accountable__c = true or Responsible__c = true)   and Decision__r.phase__c != 'Close' and Decision__r.Title__c like : '%'+searchText+'%' order by Decision__r.LastModifiedDate DESC limit 1000]; 
            }else {
                myCloneDecisionList = [select id, Decision__c,Decision__r.LastModifiedDate, Decision__r.Title__c,Decision__r.Problem_Idea_Advice__c,Decision__r.Decision_Taken__c, Decision__r.OwnerId, Decision__r.Phase__c,Role__c,Decision__r.Nearest_Due_Date__c from Social_Input__c where User__c =: UserInfo.getUserId() and (Accountable__c = true or Backup_for_Accountable__c = true or Responsible__c = true)   and Decision__r.phase__c != 'Close' order by Decision__r.LastModifiedDate DESC limit 1000];
            } 
            
            List<CloneDecisionWrapper> cloneDecisionWrapperList = new List<CloneDecisionWrapper>();
            for(Social_Input__c s: myCloneDecisionList){
                if(s.Decision__c != null && s.Decision__r.Title__c != null){
                    CloneDecisionWrapper  u = new CloneDecisionWrapper(); 
                    u.Id = s.Id;
                    u.decisionId = s.Decision__c;
                    System.debug('----s.Decision__c------'+s.Decision__c);
                    u.decisionTitle = s.Decision__r.Title__c;
                    u.problemStatement = s.Decision__r.Problem_Idea_Advice__c;
                    u.decisionTaken = s.Decision__r.Decision_Taken__c != null ? s.Decision__r.Decision_Taken__c : '';
                    u.phase = s.Decision__r.Phase__c;
                    u.phaseImg = genralInfo.imageUrlMap.get(s.Decision__r.Phase__c);
                    u.dueDate =  s.Decision__r.Nearest_Due_Date__c == null ? '' : String.valueOf(s.Decision__r.Nearest_Due_Date__c.format(dateTimeFormat)); //.format(dateTimeFormat);
                    u.myRole = s.Role__c.replaceAll(' ',', ');
                    u.ownerId = s.Decision__r.OwnerId;
                    System.debug('------s.Decision__r.OwnerId-------'+s.Decision__r.OwnerId);
                    u.ownerName = genralInfo != null && genralInfo.useNameMap != null && s.Decision__r.OwnerId != null && genralInfo.useNameMap.get(s.Decision__r.OwnerId) != null ? genralInfo.useNameMap.get(s.Decision__r.OwnerId).Name : '';
                    System.debug('------u.ownerName-------'+u.ownerName);
                    u.fieldTitle1 = 'Problem Statement';
                    u.fieldTitle2 = 'Decision';
                    // start added on 22-4-2014
                    u.dueDateSort =  s.Decision__r.Nearest_Due_Date__c != null ? s.Decision__r.Nearest_Due_Date__c: null; //.format(dateTimeFormat); 
                    //end added on 22-4-2014
                    u.lastModified = s.Decision__r.LastModifiedDate;
                    cloneDecisionWrapperList.add(u);
                }
            }
            
            // serialize records list
            cloneDecisionJSON = JSON.serialize(cloneDecisionWrapperList);
            
            return cloneDecisionJSON;
            
    }
    
    public static string componetChkJSON{get;set;} 
     
    @RemoteAction
    public  static string checkDecisionComponent (String decisionId ){
        boolean attchk = false;
        boolean tskchk = false;
        boolean relchk = false;
         
        if([select id from attachment where parentId=:decisionId ].size()>0){
            attchk = true;
        }
        if([select id from Task where whatId = :decisionId ].size()>0){
            tskchk = true;
        }
        if([Select  r.id From Relations__c r where ( r.Parent_ID__c =: decisionId or  r.Child_ID__c =: decisionId ) ].size()>0){
            relchk = true;
        }
        cloneComponentWrapper obj = new cloneComponentWrapper();
            obj.chkAttachment = attchk;
            obj.chkTask = tskchk;
            obj.chkRelation = relchk;
            
            componetChkJSON = JSON.serialize(obj);
        return componetChkJSON;
    }
    
    
    
     /***************End of This section for clone Decsion List & Search*******************************/
    
    //Wrapper class section
    public class UserData{
        public String id {get;set;}
        public String name{get;set;}
        public String url {get;set;}
    }
    
      //clone Decision wrapper class
       public class CloneDecisionWrapper{
        public string Id{get;set;}
        public string decisionId{get;set;}
        public string decisionTitle{get;set;}
        public string problemStatement{get;set;}
        public string decisionTaken{get;set;}
        public string phaseImg{get;set;}
        public string phase{get;set;}
        public string dueDate{get;set;}
        public string myRole{get;set;}
        public string ownerId{get;set;}
        public string ownerName{get;set;} 
        public string fieldTitle1{get;set;}
        public string fieldTitle2{get;set;}
        // start added on 22-4-2014
        public datetime dueDateSort{get;set;}
        public datetime lastModified{get;set;}
        // end added on 22-4-2014
    }
    
    // wrapper class for chechk attachment,relation,task
    
    public class cloneComponentWrapper{
        public boolean chkAttachment{get;set;}
        public boolean chkRelation{get;set;}
        public boolean chkTask{get;set;}
    
    }
    
}