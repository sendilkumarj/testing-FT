/*
 Created by:Kiran
 Last Modified by: Kiran
 Style: Force.com & Metro
 Description: This controleer is used for Plan PDF generate. 
 The objective of the controller is to query the database for Plan, relations, collaborators, task and activities.
*/

public with sharing class PlanPDFGenerate {
    
    public Plan__c plan {get; set;}
    public List<Relations__c> itemViewRelationList {get;set;}
    public List<Relations__c> relationList {get;set;}
    public List<Relations__c> relationList1 {get;set;}
    public List<Social_Input__c> peopleList {get; set;}
    public List<Task> taskList {get; set;}
    public List<Event> eventList {get; set;}
    public List<Attachment> attachmentList {get; set;}
    public List<Note> noteList {get; set;}
    public List<CommonHistory> commonHistoryList {get; set;}
    public  String dateTimeFormat {get;set;}
    public  map<Id, Id> recordOwnerMap;
    public  map<Id, String> recordOwnerNameMap;
    public  map<Id,String> recordPopupField1Map;
    public  map<Id,String> recordPopupField2Map;
    public  map<Id,String> recordPopupField3Map;
    public  map<Id,String> recordPopupField1NameMap;
    public  map<Id,String> recordPopupField2NameMap; 
    public  map<Id,String> recordPopupField3NameMap;
    public static string totalHoursMints{get;set;}
    public List<AllPlanJsonWrapper> allPlanJsonWrapperList {get; set;}
    public List<SocialInputWrapper> socialInputWrapperList {get; set;}
    public String currentDateTime {get; set;}    
    public List<FeedItemWrapper> feedsList {get; set;}
    GeneralInformation genralInfo;
    //Declare this variable for checking record level permission
    public static Boolean chkRecPermission{get;set;}
    // Declare this variable for UserRecordAccess  
    public List<UserRecordAccess> listUserRecordAccess{get;set;}
    
    public PlanPDFGenerate(ApexPages.StandardController controller){
        // initialize General information class to get user locale date format and images from static resouces url //
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=8');
        genralInfo  = new GeneralInformation();
        itemViewRelationList = new List<Relations__c>();
        taskList = new List<Task>();
        eventList = new List<Event>();
        listUserRecordAccess = new List<UserRecordAccess>();
        plan = [Select Start_Time__c, Show_Time_As__c, Private__c,Assigned_To__r.Name, Name, Location__c, Id, End_Time__c, Description__c, Assigned_To__c, All_Day_Event__c, Add_C_I_Members__c From Plan__c where Id = : ApexPages.currentPage().getParameters().get('id')];
        itemViewRelationList = [Select Type__c, Strength__c, Select__c,Parent_Object_Name__c ,Child_Relation__c,Parent_Relation__c ,Child_Record_Name__c,Parent_Record_Name__c,Child_Object_Name__c ,Owner.Name, Position__c, Parent_ID__c, Notes__c, Name, Minutes__c, Id, Hours__c, Description__c, Days__c, Child_ID__c From Relations__c where (Parent_ID__c = : plan.Id OR Child_ID__c = : plan.Id) and Type__c = 'Item'];
        
        relationList = [Select ID, Name,Child_ID__c,Child_Object_Name__c,Child_Record_Name__c,Child_Relation__c,Strength__c,Notes__c,Parent_ID__c,Parent_Object_Name__c,Parent_Record_Name__c,Parent_Relation__c from Relations__c where Type__c = 'Relation' AND Child_Id__c =: plan.Id];
        relationList1 = [Select ID, Name,Child_ID__c,Child_Object_Name__c,Child_Record_Name__c,Child_Relation__c,Strength__c,Notes__c,Parent_ID__c,Parent_Object_Name__c,Parent_Record_Name__c,Parent_Relation__c from Relations__c where Type__c = 'Relation' AND Parent_ID__c =:  plan.Id];
        
        // Fetching people for related plan
        peopleList = [select id,User__r.Name,Name,Role__c,GroupId__c,Description__c from Social_Input__c where Plan__c = : plan.Id];
        socialInputWrapperList = new List<SocialInputWrapper>();
        for(Social_Input__c si : peopleList){
            SocialInputWrapper siw = new SocialInputWrapper();
            siw.socInput = si;
            if(si.User__r.Name != null){
                siw.usrGrpName = si.User__r.Name;   
            } else {
                siw.usrGrpName = genralInfo.groupMap.get(si.GroupId__c).Name;
            }
            socialInputWrapperList.add(siw);
        } 
        /*
        // Fetching task and event for related plan
        taskList = [select id,WhatId,Subject,ActivityDate,Status,Priority,OwnerId,Owner.Name,CreatedById,CreatedBy.Name from Task where WhatId =: plan.Id];
        eventList = [select id,WhatId,Subject,ActivityDate,ActivityDateTime,OwnerId,Owner.Name,CreatedById,CreatedBy.Name from Event where WhatId =: plan.Id];
        
        // Fetching Note and Attachment for related attachment
        attachmentList = [Select ParentId, OwnerId, Owner.Name, Name, LastModifiedDate, Id, CreatedById From Attachment where parentId =: plan.Id];
        noteList = [Select ParentId, OwnerId, Title, owner.Name,Body, LastModifiedDate, Id, CreatedById From Note where parentId =: plan.Id];
        
        // Fetching History for related Plan
        historyView();
        
        
        // Fetching items for related tab
        itemView(plan.Id);
        viewChatter(plan.Id);*/
    }
    
    public void defaultMethods(){
        // Fetching task and event for related plan
        taskList = [select id,WhatId,Subject,ActivityDate,Status,Priority,OwnerId,Owner.Name,CreatedById,CreatedBy.Name from Task where WhatId =: plan.Id];
        eventList = [select id,WhatId,Subject,ActivityDate,ActivityDateTime,OwnerId,Owner.Name,CreatedById,CreatedBy.Name from Event where WhatId =: plan.Id];
        
        // Fetching Note and Attachment for related attachment
        attachmentList = [Select ParentId, OwnerId, Owner.Name, Name, LastModifiedDate, Id, CreatedById From Attachment where parentId =: plan.Id];
        noteList = [Select ParentId, OwnerId, Title, owner.Name,Body, LastModifiedDate, Id, CreatedById From Note where parentId =: plan.Id];
        
        // Fetching History for related Plan
        historyView();
        
        
        // Fetching items for related tab
        itemView(plan.Id);
        viewChatter(plan.Id);
    }
    
    public void historyView(){
        //GeneralInformation genralInfo  = new GeneralInformation();
        dateTimeFormat = genralInfo.MapValuesDateTime();
        System.debug('----dateTimeFormat----->'+dateTimeFormat);
        currentDateTime = System.now().format(dateTimeFormat);
        
        commonHistoryList = new List<CommonHistory>();
        for(Task tt: [select id,WhatId,OwnerId, Owner.Name ,ActivityDate,Status,Priority,Subject,Description from Task where whatId=:plan.Id and Status=:'completed' ] ){
             // for generating list of 'History Tab' (Task) 
            CommonHistory chTask = new CommonHistory();
            Time myTime1 = Time.newInstance(00, 00, 00, 00);
            if(tt.ActivityDate != null) {
                Date dt = tt.ActivityDate;
                DateTime dtTime = DateTime.newInstance(dt,myTime1);
                chTask.chDateTime = dtTime;
                chTask.duedate = dtTime.format(dateTimeFormat);
            }
            chTask.status = tt.Status != null ? tt.Status : '';
            chTask.assignedTo = tt.Owner.Name;
            chTask.assignedToId = genralInfo.useImage.get(tt.OwnerId);
            chTask.subject= tt.Subject;
            chTask.comments = tt.Description != null ? tt.Description : '';
            chTask.relatedTo = 'Task';
            commonHistoryList.add(chTask);
            //
        }
        
        for(Event ee: [select id,WhatId,OwnerId,Owner.Firstname,Owner.Lastname,ActivityDate,ActivityDateTime,Subject,Description from Event where whatId=:plan.Id and ActivityDate < Today ]){
             // for generating list of 'History Tab' (Event)
            CommonHistory chEvent = new CommonHistory();
            
            chEvent.chDateTime = ee.ActivityDateTime;
            chEvent.duedate = ee.ActivityDateTime.format(dateTimeFormat);
            chEvent.assignedTo = ee.Owner.Firstname + ee.Owner.Lastname;
            chEvent.assignedToId = genralInfo.useImage.get(ee.OwnerId);
            chEvent.comments = ee.Description != null ? ee.Description : '';
            chEvent.relatedTo = 'Event';
            commonHistoryList.add(chEvent);
            
        }
        
        // call history class to get history data
        GenerlHistoryComponent gh = new GenerlHistoryComponent();
        List<GenerlHistoryComponent.objectHistoryLine> obhLineList = new List<GenerlHistoryComponent.objectHistoryLine>();
        gh.myObject = Schema.getGlobalDescribe().get('Plan__c').newSObject();
        gh.myObjectId = plan.Id;
        obhLineList = gh.getObjectHistory(gh.myObjectId, gh.myObject);
        for(GenerlHistoryComponent.objectHistoryLine historyDecision : obhLineList){
            commonHistory ch=new commonHistory();
            ch.chDateTime  = historyDecision.theDate;
            if(historyDecision.theDate != null) {
                ch.duedate = historyDecision.theDate.format(dateTimeFormat);
            }
            ch.relatedTo = 'Field Change';
            ch.assignedTo =historyDecision.who;
            ch.assignedToId =  genralInfo.useImage.get(historyDecision.userId);
            ch.status = (historyDecision.action.replaceAll('<b>', '')).replaceAll('</b>','');
            ch.comments = '';
            commonHistoryList.add(ch);
        }
        
        // sorting by datetime
        map<DateTime, List<CommonHistory>> dateTimeCommonHistoryMap = new map<DateTime, List<CommonHistory>>();
        List<CommonHistory> commonHistoryListNew = commonHistoryList.clone();
        commonHistoryList.clear();
        for(CommonHistory c: commonHistoryListNew) {
            List<commonHistory> chMappedList =  dateTimeCommonHistoryMap.get(c.chDateTime);
            if(chMappedList == null) {
                chMappedList = new List<commonHistory>();
                dateTimeCommonHistoryMap.put(c.chDateTime,chMappedList);
            }
            chMappedList.add(c);
        }
        List<DateTime> dateTimeCHList = new List<DateTime>();
        system.debug('dateTimeCHSet-->'+dateTimeCommonHistoryMap.keySet());
        dateTimeCHList.addAll(dateTimeCommonHistoryMap.keySet());
        dateTimeCHList.sort();
        system.debug('dateTimeCHList-->'+dateTimeCHList);
        map<Integer, DateTime> stringSortMap = new map<Integer, DateTime>();
        Integer listSize = dateTimeCHList.size();
        for(DateTime s: dateTimeCHList) {
            listSize--;
            stringSortMap.put(listSize, s);
        }
        system.debug('stringSortMap-->'+stringSortMap);
        List<DateTime> newDateTimeSortedList = new List<DateTime>();
        for(Integer i=0; i< = dateTimeCHList.size() ; i++) {
             newDateTimeSortedList.add(stringSortMap.get(i));
        }
        system.debug('newDateTimeSortedList-->'+newDateTimeSortedList);
        for(DateTime d: newDateTimeSortedList) {
            if(dateTimeCommonHistoryMap.get(d) != null) {
                List<CommonHistory> ahList = new List<CommonHistory>();
                ahList = dateTimeCommonHistoryMap.get(d);
                System.debug('********>'+ahList);
                for(CommonHistory a : ahList) {
                    commonHistory ch=new commonHistory();
                    ch = a;
                    commonHistoryList.add(ch);
                }
            }
        }
    }
    
    public void itemView(Id currentPlanId){
        //GeneralInformation genralInfo  = new GeneralInformation();
        System.debug('------currentPlanId----->'+currentPlanId);
        String planId = string.valueOf(currentPlanId);
        List<Relations__c> reltionshipList;
        reltionshipList = getPlanRelation(planId);
        Set<Id> recordChildId = new Set<Id>();
        Set<Id> decisionSet = new Set<Id>();
         
        Social_Input__c loggedInSocialPeople = new Social_Input__c();
        if([select id  from Social_Input__c where User__c =: userInfo.getUserId() AND Plan__c =: planId].size() > 0 ) {
            loggedInSocialPeople = [Select s.Veto_Rights__c, s.User__c, s.Responsible__c, s.Informed__c, s.Id, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c, s.Accountable__c From Social_Input__c s where User__c =: userInfo.getUserId() AND s.Plan__c =: planId limit 1 ];
        }
        
        Profile profileOfUser =[Select p.Name,p.Id From Profile p where p.id =: UserInfo.getProfileId() ];
          // Query for current login user max record permission
        listUserRecordAccess = [SELECT RecordId, HasReadAccess, HasEditAccess, HasDeleteAccess,MaxAccessLevel FROM UserRecordAccess WHERE UserId=:UserInfo.getUserId() AND RecordId =:currentPlanId limit 1];
           		system.debug('============listUserRecordAccess==========='+listUserRecordAccess);
         	  if(listUserRecordAccess.size() > 0 && listUserRecordAccess[0].MaxAccessLevel=='All'){
           			chkRecPermission=true;
           			system.debug('============chkRecPermission==========='+chkRecPermission);
           		}
         for(Relations__c r:reltionshipList ){
             recordChildId.add(r.Child_Id__c);
             if(r.Child_Object_Name__c == 'Decision'){
                 decisionSet.add(r.Child_Id__c);
             }
         } 
         
        map<Id,Social_Input__c> myRoleInDecisionMap = new map<Id,Social_Input__c>();
        map<Id,Decision__c> decisionMap = new map<Id,Decision__c>();
        map<Id,Social__c> socialMap = new map<Id,Social__c>();
        map<Id,List<Social_Input__c>> raciVetoMap = new map<Id,List<Social_Input__c>>(); 
        // approval list mapping 
        map<Id,List<Social_Input__c>> pendingRaciListMap = new map<Id,List<Social_Input__c>>();
        map<Id,List<Social_Input__c>> appRaciListMap = new map<Id,List<Social_Input__c>>();
        map<Id,List<Social_Input__c>> rejRaciListMap = new map<Id,List<Social_Input__c>>();
        if(decisionSet.size() > 0){
            //decisions
            for(Decision__c dec: [select id,phase__c,status__c, Estimated_Investment__c, Estimated_Direct_Cost__c, Estimated_Revenue__c, Estimated_Net_Present_Value__c, Estimated_People_Involved__c, Estimated_Full_time_Equivalent_FTE__c from Decision__c where Id In: recordChildId]) {
                decisionMap.put(dec.Id, dec);
            }
            
            //social
            for(Social__c soc: [select id, Avg_Mood__c,Related_To_ID__c from Social__c where Related_To_ID__c In: recordChildId]) {
                socialMap.put(soc.Related_To_ID__c, soc);
            }
            
           
            
            List<Social_Input__c> raciList = [select id,Stance_Approval_Status__c,Final_Approval_Status__c,Decision__c,Veto_Rights__c,Responsible__c,Informed__c, Consulted__c, Backup_for_Accountable__c, Accountable__c  from Social_Input__c where Decision__c In: recordChildId];
            
            List<Social_Input__c> myRoleOnDecisionList = [select id,Final_Approval_Status__c,Decision__c,Veto_Rights__c,Responsible__c,Informed__c, Consulted__c, Backup_for_Accountable__c, Accountable__c  from Social_Input__c where Decision__c In: recordChildId and User__c =: userInfo.getUserId()];
            
            for(Social_Input__c s: myRoleOnDecisionList){
                if(myRoleInDecisionMap.get(s.Decision__c) == null)
                    myRoleInDecisionMap.put(s.Decision__c,s);   
            }
            
            for(Social_Input__c r: raciList){
                if(r.Stance_Approval_Status__c == 'Pending Approval'){
                    List<Social_Input__c> pendingRaciList =  pendingRaciListMap.get(r.Decision__c);
                    if(pendingRaciList == null) {
                     pendingRaciList = new List<Social_Input__c>();
                     pendingRaciListMap.put(r.Decision__c, pendingRaciList);
                    }
                    pendingRaciList.add(r);
                }
                if(r.Stance_Approval_Status__c == 'Approved'){
                    List<Social_Input__c> approveRaciList =  appRaciListMap.get(r.Decision__c);
                    if(approveRaciList == null) {
                     approveRaciList = new List<Social_Input__c>();
                     appRaciListMap.put(r.Decision__c, approveRaciList);
                    }
                    approveRaciList.add(r);
                }
                if(r.Stance_Approval_Status__c == 'Rejected'){
                    List<Social_Input__c> rejectRaciList =  rejRaciListMap.get(r.Decision__c);
                    if(rejectRaciList == null) {
                     rejectRaciList = new List<Social_Input__c>();
                     rejRaciListMap.put(r.Decision__c, rejectRaciList);
                    }
                    rejectRaciList.add(r);
                }
                
                raciList = raciVetoMap.get(r.Decision__c);
                if(raciList == null) {
                    raciList = new List<Social_Input__c>();
                    raciVetoMap.put(r.Decision__c,raciList);
                }
                raciList.add(r);
            }
         }
         
         ownerDetail(recordChildId);
         Double totalMins = 0;
         Double totalHrs = 0;
         Double totalDays = 0;
         Integer i = 0;
        
         allPlanJsonWrapperList = new List<AllPlanJsonWrapper >();
        
         //itemPlanWrapperMap = new map<Id,Relationship__c>();
        
         for(Relations__c r: reltionshipList) {
            AllPlanJsonWrapper apWrap = new AllPlanJsonWrapper();
            
            apwrap.rel = r;
            apWrap.Id = r.Id;
            apWrap.Name= r.Child_Record_Name__c;
            apWrap.Minutes = r.Minutes__c == null ? '0' : r.Minutes__c;   //,Plan_Days_Duration__c
            apWrap.Hours = r.Hours__c == null ? '0' : r.Hours__c;
            apWrap.Days = r.Days__c == null ? '0' : r.Days__c;
            apWrap.Owner = recordOwnerNameMap.get(r.Child_Id__c) != null ? recordOwnerNameMap.get(r.Child_Id__c) : '';
            
            apWrap.description = r.Description__c == null ? '' : r.Description__c;
            apWrap.Position = String.valueOf(r.Position__c);
            apWrap.Type = r.Child_Object_Name__c;
            apWrap.itemRecordId = r.Child_Id__c;
            apWrap.isDeletable= false;
            apWrap.isEditable = false;
            apWrap.ismoveDown = false; 
            apWrap.ismoveUp = false; 
            
            apWrap.actionClassName = 'grid-action-disabled';
            
            if(loggedInSocialPeople.Accountable__c || loggedInSocialPeople.Backup_for_Accountable__c || loggedInSocialPeople.Responsible__c || chkRecPermission==true) {
                apWrap.isDeletable= true;
                apWrap.isEditable = true;
                apWrap.ismoveDown = true; 
                apWrap.ismoveUp = true;
                apWrap.actionClassName = '';
            }
            apWrap.moveUp = apWrap.ismoveUp == true ? genralInfo.imageUrlMap.get('moveUp') : genralInfo.imageUrlMap.get('moveUpDisabled');
            apWrap.moveDown = apWrap.ismoveDown == true ? genralInfo.imageUrlMap.get('moveDown') : genralInfo.imageUrlMap.get('moveDownDisabled');
            apWrap.delItem = genralInfo.deleteImage.get(apWrap.isDeletable);
            apWrap.itemRecordId = r.Child_Id__c;
            apWrap.approve = appRaciListMap.get(Id.valueOf(r.Child_Id__c)) != null ? String.valueOf(appRaciListMap.get(Id.valueOf(r.Child_Id__c)).size()) : '0';
            apWrap.nostance = pendingRaciListMap.get(Id.valueOf(r.Child_Id__c)) != null ? String.valueOf(pendingRaciListMap.get(Id.valueOf(r.Child_Id__c)).size()) : '0';
            apWrap.disapprove = rejRaciListMap.get(Id.valueOf(r.Child_Id__c)) != null ? String.valueOf(rejRaciListMap.get(Id.valueOf(r.Child_Id__c)).size()) : '0';
            
            System.debug('---issueMap.get(Id.valueOf(r.Child_Id__c))---'+r.Child_Id__c);
            System.debug('---issueMap.get(Id.valueOf(r.Child_Id__c))---'+r.Id);
            //System.debug('---issueMap.get(Id.valueOf(r.Child_Id__c))---'+issueMap.get(Id.valueOf(r.Child_Id__c)));
            //System.debug('-apWrap.IssueImg---'+apWrap.IssueImg);
           
            Decision__c dec = new Decision__c();
            if(decisionMap.get(Id.valueOf(r.Child_Id__c)) != null )
                dec = decisionMap.get(Id.valueOf(r.Child_Id__c));  
            
            
            apWrap.decisionClass = 'grid-action-disabled';
            apWrap.actionClassNameDecision = 'grid-action-disabled';
            /************* new task **********************/
            if(apWrap.Type != 'Decision'){
                apWrap.newTaskFromDecision = genralInfo.imageUrlMap.get('null');
                apWrap.newTaskFromDecisionIconTitle = '';  
                //apWrap.actionClassName = 'grid-action-disabled';
            }else{
                
                //apWrap.actionClassName = '';
                //if(loggedInSocialPeople.Accountable__c || loggedInSocialPeople.Backup_for_Accountable__c || loggedInSocialPeople.Responsible__c || profileOfUser.Name == 'System Administrator') {
                    if(dec.Id == null){
                        apWrap.newTaskFromDecision = genralInfo.imageUrlMap.get('newTaskForDecisionDisabled');
                        apWrap.newTaskFromDecisionIconTitle = 'You are not part of the Decision, so you cannot create the task';
                        apWrap.canUserCreateTask = 'false';     
                    }else{
                        System.debug('-phaniraj coding---'+profileOfUser.Name);
                        if(myRoleInDecisionMap.get(Id.valueOf(r.Child_Id__c)) != null){
                            System.debug('-phaniraj coding---'+myRoleInDecisionMap.get(Id.valueOf(r.Child_Id__c)).Accountable__c+'-----'+myRoleInDecisionMap.get(Id.valueOf(r.Child_Id__c)).Responsible__c+'------'+myRoleInDecisionMap.get(Id.valueOf(r.Child_Id__c)).Backup_for_Accountable__c+'-------'+profileOfUser.Name);
                            if(myRoleInDecisionMap.get(Id.valueOf(r.Child_Id__c)).Accountable__c == false && myRoleInDecisionMap.get(Id.valueOf(r.Child_Id__c)).Responsible__c == false && myRoleInDecisionMap.get(Id.valueOf(r.Child_Id__c)).Backup_for_Accountable__c == false && chkRecPermission!=true){
                                apWrap.newTaskFromDecision = genralInfo.imageUrlMap.get('newTaskForDecisionDisabled');
                                apWrap.newTaskFromDecisionIconTitle = 'Your role on the decision doesnot permit to create tasks';   
                                apWrap.canUserCreateTask = 'false';
                            }else{
                                apWrap.decisionClass = 'new-item-decision';
                                apWrap.newTaskFromDecision = genralInfo.imageUrlMap.get('newTaskForDecision');
                                apWrap.newTaskFromDecisionIconTitle = 'Adds new task under this decision';  
                                apWrap.canUserCreateTask = 'true';  
                            }
                        }else{
                            apWrap.newTaskFromDecision = genralInfo.imageUrlMap.get('newTaskForDecisionDisabled');
                            apWrap.newTaskFromDecisionIconTitle = 'You are not part of the Decision, so you cannot create the task';    
                            apWrap.canUserCreateTask = 'false';
                        }
                    }
                /*}else{
                    apWrap.newTaskFromDecision = genralInfo.imageUrlMap.get('newTaskForDecisionDisabled');
                    apWrap.newTaskFromDecisionIconTitle = 'Consulted and Informed do not have permissions to add task';  
                    apWrap.canUserCreateTask = 'false'; 
                }*/
            }
            
            
            if(dec.Id != null){
                String veto = 'approved';
                Integer vetNum = 0;
                Social__c soc = socialMap.get(Id.valueOf(r.Child_Id__c)); 
                List<Social_Input__c> raciList1 = new List<Social_Input__c>();
                raciList1 = raciVetoMap.get(Id.valueOf(r.Child_Id__c));
                Boolean vetoPower = false;
                Boolean accoutableApproved = false;
                for(Social_Input__c si: raciList1) {
                   
                    
                    if(si.Veto_Rights__c) {
                        vetNum = vetNum + 1;
                        if(veto != 'rejected') {
                            
                            if(si.Stance_Approval_Status__c == 'Rejected'){
                                veto = 'rejected';
                            }
                            if((si.Stance_Approval_Status__c == 'Pending Approval' || si.Stance_Approval_Status__c == 'Approved') && veto != 'rejected' ){
                                veto = '';
                            }
                           
                        }
                        
                    }
                    
                    if((si.Accountable__c || si.Backup_for_Accountable__c)&& (si.Final_Approval_Status__c == 'Approved' || si.Final_Approval_Status__c == 'Rejected')  ) {
                        accoutableApproved = true;
                    }
                }
                
                if(veto == '' && accoutableApproved) {
                    veto = 'approved';
                }
                
            
                System.debug('----------------veto value--------'+veto);
                
                
                apWrap.actionClassNameDecision = '';
                       
                apWrap.phase = dec.Phase__c != null ? dec.Phase__c : '';
                apWrap.status = dec.Status__c != null ? dec.status__c : '';
                
                /* *************** view4 *********** */
                apWrap.Investment = dec.Estimated_Investment__c != null ? String.valueOf(dec.Estimated_Investment__c.round()) : '';
                apWrap.DirectCost = dec.Estimated_Direct_Cost__c != null ? String.valueOf(dec.Estimated_Direct_Cost__c.round()) : '';
                apWrap.Revenue = dec.Estimated_Revenue__c != null ? String.valueOf(dec.Estimated_Revenue__c.round()) : '';
                apWrap.NetPresentValue = dec.Estimated_Net_Present_Value__c != null ? String.valueOf(dec.Estimated_Net_Present_Value__c.round()) : '';
                apWrap.PeopleInvolved = dec.Estimated_People_Involved__c != null ? String.valueOf(Integer.valueOf(dec.Estimated_People_Involved__c.round())) : '';
                apWrap.FTE = dec.Estimated_Full_time_Equivalent_FTE__c != null ? String.valueOf(dec.Estimated_Full_time_Equivalent_FTE__c) : '';
                
                /* *************** view3 *********** */
                apWrap.veto = String.valueOf(vetNum) != null ? String.valueOf(vetNum) : '' ;
                apWrap.mood = String.valueOf(soc.Avg_Mood__c) != null ? String.valueOf(math.round(soc.Avg_Mood__c)) : '';
                apWrap.MoodImg = genralInfo.imageUrlMap.get(string.valueOf(math.round(Double.valueOf(apWrap.mood)))) != null ? genralInfo.imageUrlMap.get(string.valueOf(math.round(Double.valueOf(apWrap.mood)))) : genralInfo.imageUrlMap.get('moodNoInput') ;                 
                /* *************** view2 *********** */
                apWrap.predictionResult = genralInfo.imageUrlMap.get(veto) != null ? genralInfo.imageUrlMap.get(veto) : genralInfo.imageUrlMap.get('null');  // to be replaced with image
            }else{
                apWrap.phase = '';
                apWrap.status = '';
                
                /* *************** view4 *********** */
                apWrap.Investment = '';
                apWrap.DirectCost = '';
                apWrap.Revenue = '';
                apWrap.NetPresentValue = '';
                apWrap.PeopleInvolved = '';
                apWrap.FTE = '';
                
                /* *************** view3 *********** */
                apWrap.veto = '';
                apWrap.mood = '';
                
                /* *************** view2 *********** */
                apWrap.predictionResult = genralInfo.imageUrlMap.get('null');
                apWrap.MoodImg = genralInfo.imageUrlMap.get('null') ; 
            }
            
            System.debug('----------------apWrap.MoodImg--------'+apWrap.MoodImg);
            allPlanJsonWrapperList.add(apWrap);
            //itemPlanWrapperMap.put(r.Id, r);
            
            if(r.Minutes__c != null) {
                totalMins = totalMins + Double.valueOf(r.Minutes__c);
            }
            if(r.Hours__c != null){
                totalHrs = totalHrs + Double.valueOf(r.Hours__c);
            }
            if(r.Days__c != null){
                totalDays = totalDays + Double.valueOf(r.Days__c);
            }
         }
         
         // count Mints
        
         if(totalMins  > = 60) {
            Integer hr = (totalMins/60).intValue();
            Integer mins = (totalMins - (hr * 60)).intValue();
            totalMins = mins;
            totalHrs = totalHrs + hr;
            //totalHoursMints = String.valueOf(hr) + ' hr : ' + String.valueOf(mins )  + ' mins';
         }
         if(totalHrs > 23){
            Integer days = (totalHrs/24).intValue();
            Integer hrs = (totalHrs - (days * 24)).intValue();
            totalHrs = hrs;
            totalDays = totalDays + days;   
         }
         String days = '';
         if(totalDays.intValue() < 2){
             days = 'day';
         }else{
             days = 'days';
         }
         
         String hours= '';
         if(totalHrs.intValue() < 2){
             hours = 'hour';
         }else{
             hours = 'hours';
         }
         
         String mins = '';
         if(totalMins.intValue() < 2){
             mins= 'min';
         }else{
             mins= 'mins';
         }
        
         totalHoursMints = String.valueOf(totalDays.intValue())+' '+days+' '+String.valueOf(totalHrs.intValue())+' '+hours+' '+String.valueOf(totalMins.intValue())+' '+mins;
         System.debug('------currentPlanId----->'+currentPlanId);
    }
    
    // get all relation for plan 
    public List<Relations__c> getPlanRelation(String PlanId) {
        System.debug('----------------------------->'+planId);
        map<Id,Relations__c> relationMap = new map<Id,Relations__c>();
        if(planId != '' && planId != null) {
            List<Relations__c> relation = [select id,Minutes__c,Hours__c,Days__c,Owner.Name,Description__c,Parent_Record_Name__c, Parent_Id__c, Parent_Object_Name__c, Child_Object_Name__c, Child_Record_Name__c, Child_Id__c, Position__c  from Relations__c  where Parent_Id__c =: planId AND Type__c = 'Item'  order by Position__c asc limit 50000];
            for(relations__c r:relation){
                relationMap.put(r.Id,r);
            }
            return relation ;
        }
        else {
            return null;
        }
    }
    
    //Owner Details
    public void ownerDetail(Set<Id> recordIdList) {
        recordOwnerMap = new map<Id, Id>();
        recordOwnerNameMap = new map<Id, String>();
        
        
        for(Decision__c d: [select id, OwnerId, Owner.Name,Problem_Idea_Advice__c,Decision_Taken__c,Priority__c from Decision__c where Id In: recordIdList]) {
            recordOwnerMap.put(d.Id, d.OwnerId);
            recordOwnerNameMap.put(d.Id, d.Owner.Name);
            
        }
        
        for(Task  t: [select id, OwnerId, Owner.Name, Priority, Status, Type from Task where Id In: recordIdList]) {
            recordOwnerMap.put(t.Id, t.OwnerId);
            recordOwnerNameMap.put(t.Id, t.Owner.Name);
            
        }
        
        for(Account a: [select id, OwnerId, Owner.Name,Name,Phone,Description from Account where Id In: recordIdList]) {
            recordOwnerMap.put(a.Id, a.OwnerId);
            recordOwnerNameMap.put(a.Id, a.Owner.Name);
            
        }
        
        for(Contact a: [select id, OwnerId, Owner.Name,LastName,FirstName,Title,MobilePhone,Description from Contact where Id In: recordIdList]) {
            recordOwnerMap.put(a.Id, a.OwnerId);
            recordOwnerNameMap.put(a.Id, a.Owner.Name);
            
        }
    
        
        for(Plan__c a: [select id, OwnerId, Owner.Name,Start_Time__c,End_Time__c,Location__c  from Plan__c where Id In: recordIdList]) {
            recordOwnerMap.put(a.Id, a.OwnerId);
            recordOwnerNameMap.put(a.Id, a.Owner.Name);
            
        }
        
        for(Note a: [select id, OwnerId, Owner.Name, body from Note where Id In: recordIdList]) {
            recordOwnerMap.put(a.Id, a.OwnerId);
            recordOwnerNameMap.put(a.Id, a.Owner.Name);
            
        }
        
    }
    
     // View Chatter Feeds and comments
         public void viewChatter(String planRecordId) {
     
     
     Plan__Feed [] items = [SELECT CreatedBy.name,   Body, LikeCount,Title ,CreatedDate,   (SELECT CreatedBy.Name,CommentBody,createddate  FROM FeedComments order by createddate ) FROM Plan__Feed WHERE ParentId =:planRecordId order by createddate ];
    
    // Map to store values
     Map<id, List<FeedCommentWrapper>> commentsMap = new Map<id, List<FeedCommentWrapper>>();
    
     // map the keys to a empty list to avoid nulls later
     for (Plan__Feed item:items) {
        commentsMap.put(item.id, new List<FeedCommentWrapper>());
     }
    
    
     for (Plan__Feed item:items) {
        
        for (FeedComment comment : item.FeedComments) {
            FeedCommentWrapper CommentWrapper  = new FeedCommentWrapper();         
            CommentWrapper.body            = comment.CommentBody;
            CommentWrapper.createdDate     = comment.createddate.format(dateTimeFormat);
            CommentWrapper.createdBy       = comment.CreatedBy.name;   
            commentsMap.get(item.id).add(CommentWrapper);
        }
     }
     
     feedsList = new List<FeedItemWrapper>();
       for( Plan__Feed feed :items){
            FeedItemWrapper FeedItem = new FeedItemWrapper();
            FeedItem.title           = feed.Title;
            FeedItem.body            = feed.Body;
            FeedItem.createdDate     = feed.createddate.format(dateTimeFormat);
            FeedItem.createdBy       = feed.CreatedBy.name;        
            FeedItem.feedCommentList  = commentsMap.get(feed.id);
            feedsList.add(FeedItem);
       }  
     
    }
    //Wrapper class for history tab 
    public class CommonHistory {
        public DateTime chDateTime {get;set;} // only use for sorting 
        public String subject{get; set; }
        public String duedate {get; set;}
        public String status {get; set;}
        public String assignedTo {get;set;}
        public String assignedToId {get;set;}
        public String comments {get;set;}
        public String relatedTo {get;set;}
    }
    
    public class AllPlanJsonWrapper {
        public Relations__c rel {get; set;}
        public String Id {get;set;}
        public String Name {get;set;}
        public String Minutes{get;set;}
        public string Hours{ get; set; }
        public string Days{ get; set; }
        public String Owner {get;set;}
        public String status {get;set;}
        public String phase{get;set;}
        public String Position {get;set;}
        public String Type {get;set;}
        public String itemRecordId {get;set;}
        public Boolean ismoveUp {get;set;}
        public String moveUp{get;set;}
        public Boolean ismoveDown {get;set;}
        public String moveDown{get;set;}
        public Boolean isDeletable {get;set;}
        public Boolean isEditable {get;set;}
        public String delItem{get;set;}
        public String Investment {get;set;}
        public String DirectCost {get;set;}
        public String Revenue {get;set;}
        public String NetPresentValue {get;set;}
        public String PeopleInvolved{get;set;}
        public String FTE{get;set;} 
        public String veto{get;set;}
        public String approve{get;set;}
        public String nostance{get;set;}
        public String disapprove{get;set;}
        public String issue{get;set;}
        public String mood{get;set;}
        public String predictionResult{get;set;}
        public String description {get;set;}
        public String popupField1{get;set;}
        public String popupField2{get;set;}
        public String popupField3{get;set;}
        public String popupFieldName1{get;set;}
        public String popupFieldName2{get;set;}
        public String popupFieldName3{get;set;}
        public String IssueImg{get;set;}
        public String MoodImg{get;set;}
        public string newTaskFromDecision{get;set;}
        public string newTaskFromDecisionIconTitle{get;set;}
        public string canUserCreateTask{get;set;}
        public string decisionClass {get;set;}
        
        public String actionClassName {get;set;}
        public String actionClassNameDecision {get;set;}
        
        public AllPlanJsonWrapper(){
            rel = new Relations__c();
        }
    }
    
    public class SocialInputWrapper {
        public Social_Input__c socInput {get; set;}
        public String usrGrpName {get; set;}
    }
     public class FeedItemWrapper {
      
      public String  title{get;set;}
      public String  body{get;set;}
      public String  createdBy{get;set;}
      public Integer likeCount{get;set;}
      public Integer commentCount{get;set;}
      public String  createdDate{get;set;} 
      public List<FeedCommentWrapper> feedCommentList{get;set;} 
    }
    
     public class FeedCommentWrapper {
      
      public String  title{get;set;}
      public String  body{get;set;}
      public String  createdBy{get;set;}
      public Integer likeCount{get;set;}
      public Integer commentCount{get;set;}
      public String  createdDate{get;set;} 
      public List<FeedComment> feedCommentList{get;set;} 
    }
}