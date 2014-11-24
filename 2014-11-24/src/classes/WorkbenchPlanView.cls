/*
 Created by:Phaniraj
 Last Modified by: Phaniraj
 Style: Force.com & Metro
 Description: This class is written to invoke plan details when a plan is selected from Plan
 list in the plan workbench.
*/

public with sharing class WorkbenchPlanView{
    
    // Kendo People tab edit permission
    public String peopleEditPermission {get;set;}
    public static String allItemJson {get; private set;}
    
    //public static String allItemJsonNotRemote {get; private set;}
    
    // user locale date fromat as string 
    public static String dateFormat {get;set;}
    
    // user locale datetime fromat as string 
    public static String dateTimeFormat {get;set;}
    
    // string converted Id of the selected plan
    public static String selectedPlanId{get;set;}
    
    // instance of the plan object
    public Plan__c planDetail{get;set;}
    
    // instance of social input object
    public Social_Input__c socialInput{get;set;}
    
    //collections to hold the dynamic data of the plan
    public static set<Id> recordChildId; 
    public static set<Id> decisionSet{get;set;} 
    public static string canThisUserAddItems{get;set;}
    public static map<Id, Id> recordOwnerMap;
    public static map<Id, String> recordOwnerNameMap;
    public static map<Id,String> recordPopupField1Map;
    public static map<Id,String> recordPopupField2Map;
    public static map<Id,String> recordPopupField3Map;
    public static map<Id,String> recordPopupField1NameMap;
    public static map<Id,String> recordPopupField2NameMap; 
    public static map<Id,String> recordPopupField3NameMap;
    public static string totalHoursMints{get;private set;}
    public static map<Id,Relations__c> relationMap{get;set;}
    public string canUserEditThisPlan{get;set;}
    
     //Declare this variable for checking record level permission
    public static Boolean chkRecPermission{get;set;}
    // Declare this variable for UserRecordAccess  
    public List<UserRecordAccess> listUserRecordAccess{get;set;}
    
    // Declaring constructor
    public WorkbenchPlanView(){
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=8');
        // initialize General information class to get user locale date format and images from static resouces url //
        GeneralInformation genralInfo  = new GeneralInformation();
          
        // assign user locale date format as string 
        dateFormat = genralInfo.MapValuesDateFormate();
        
        // assign user locale datetime format as string 
        dateTimeFormat = genralInfo.MapValuesDateTime();
        listUserRecordAccess = new List<UserRecordAccess>();
        
        canThisUserAddItems = '';
        canUserEditThisPlan = 'false';
        peopleEditPermission = 'false';
    }
    
    // invoke plan data of the selected plan
    public pageReference planData(){
        selectedPlanId = ApexPages.currentPage().getParameters().get('planid');
        canUserEditThisPlan = 'false';
        peopleEditPermission = 'false';
        // Profile p = [select Name from Profile where id =: UserInfo.getProfileId()];
          // Query for current login user max record permission
        listUserRecordAccess = [SELECT RecordId, HasReadAccess, HasEditAccess, HasDeleteAccess,MaxAccessLevel FROM UserRecordAccess WHERE UserId=:UserInfo.getUserId() AND RecordId =:selectedPlanId limit 1];
              if(listUserRecordAccess.size() > 0 && listUserRecordAccess[0].MaxAccessLevel=='All'){
                    chkRecPermission=true;
              }
        planDetail = [Select ID,Add_C_I_Members__c , Name, All_Day_Event__c, Assigned_To__c, Assigned_To__r.Name, Description__c, End_Time__c, Location__c, Private__c, Show_Time_As__c, Start_Time__c from Plan__c where ID=: selectedPlanId ];
        if([Select id From Social_Input__c s where s.Plan__c =: planDetail.Id AND s.User__c =: userInfo.getUserId() limit 1 ].size() > 0) {
            socialInput = [Select s.Veto_Rights__c, s.User__c, s.SystemModstamp,s.SYS_Tab_View_Activites__c, s.SYS_Tab_View_History__c, s.SYS_Tab_View_Tasks__c, s.SYS_Tab_View_Social_Input__c, s.SYS_Tab_View_Relations__c, s.SYS_Tab_View_Quality__c, s.SYS_Tab_View_Attachments__c, s.SYS_Tab_View_Approvals__c, s.Role_Acceptance_Status__c, s.Role_Acceptance_Required__c, s.Result__c, s.Responsible__c, s.Rating__c, s.Outcome__c, s.Name, s.Mood__c, s.Like__c, s.LastModifiedDate, s.LastModifiedById, s.Informed__c, s.Id, s.Final_Approval_Status__c, s.Effort__c, s.Dislike__c, s.Plan__c, s.CreatedDate, s.CreatedById, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c, s.Accountable__c From Social_Input__c s where s.Plan__c =: planDetail.Id AND s.User__c =: userInfo.getUserId() limit 1 ];  
            if( socialInput.Accountable__c || socialInput.Responsible__c){
                canUserEditThisPlan = 'true';
                peopleEditPermission = 'true';
            }else{
                canUserEditThisPlan = 'false';
            }
        }
        if(chkRecPermission==true  ){
            canUserEditThisPlan = 'true';
            peopleEditPermission = 'true';  
        }
        //itemViewNotRemote(planDetail.Id);
        return null;
    }
    
    public pageReference planDataToSave(String planIdToSave){
        //selectedPlanId = ApexPages.currentPage().getParameters().get('planid');
        //if(selectedPlanId != null){
            planDetail = [Select ID,Add_C_I_Members__c , Name, All_Day_Event__c, Assigned_To__c, Assigned_To__r.Name, Description__c, End_Time__c, Location__c, Private__c, Show_Time_As__c, Start_Time__c from Plan__c where ID=: planIdToSave ];
            if([Select id From Social_Input__c s where s.Plan__c =: planDetail.Id AND s.User__c =: userInfo.getUserId() limit 1 ].size() == 1) {
                socialInput = [Select s.Veto_Rights__c, s.User__c, s.SystemModstamp,s.SYS_Tab_View_Activites__c, s.SYS_Tab_View_History__c, s.SYS_Tab_View_Tasks__c, s.SYS_Tab_View_Social_Input__c, s.SYS_Tab_View_Relations__c, s.SYS_Tab_View_Quality__c, s.SYS_Tab_View_Attachments__c, s.SYS_Tab_View_Approvals__c, s.Role_Acceptance_Status__c, s.Role_Acceptance_Required__c, s.Result__c, s.Responsible__c, s.Rating__c, s.Outcome__c, s.Name, s.Mood__c, s.Like__c, s.LastModifiedDate, s.LastModifiedById, s.Informed__c, s.Id, s.Final_Approval_Status__c, s.Effort__c, s.Dislike__c, s.Plan__c, s.CreatedDate, s.CreatedById, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c, s.Accountable__c From Social_Input__c s where s.Plan__c =: planDetail.Id AND s.User__c =: userInfo.getUserId() limit 1 ];  
            }
        //}
        // itemView1(String.valueOf(selectedPlanId));
        return null;
    }
    
    // update plan
    public void savePlan(){
        selectedPlanId = ApexPages.currentPage().getParameters().get('planid');
        if(Schema.sObjectType.Plan__c.fields.All_Day_Event__c.isUpdateable() && Schema.sObjectType.Plan__c.fields.Assigned_To__c.isUpdateable() && Schema.sObjectType.Plan__c.fields.Description__c.isUpdateable() && Schema.sObjectType.Plan__c.fields.End_Time__c.isUpdateable()  && Schema.sObjectType.Plan__c.fields.Location__c.isUpdateable()  && Schema.sObjectType.Plan__c.fields.Show_Time_As__c.isUpdateable()  && Schema.sObjectType.Plan__c.fields.Start_Time__c.isUpdateable() ){ 
            update planDetail;
        }
        planDataToSave(selectedPlanId);
    }
    
     // dummy call
    public void dummyCall() {
        selectedPlanId = ApexPages.currentPage().getParameters().get('planid');
        planDetail = [Select ID,Add_C_I_Members__c , Name, All_Day_Event__c, Assigned_To__c, Assigned_To__r.Name, Description__c, End_Time__c, Location__c, Private__c, Show_Time_As__c, Start_Time__c from Plan__c where ID=: planDetail.Id ];
            
    }
    
    public PageReference deletePlan(){
        pageReference page = new pageReference('/apex/Workbench');
        if(Plan__c.SObjectType.getDescribe().isDeletable()) {
           delete planDetail;
        }
        return  page;
    }
    
    // remote action method invoked to Items of the Plan
    @RemoteAction
    public static string itemView(String planId){
        Plan__c plan = [select id from Plan__c where id=:planId];
        planId = string.valueOf(plan.Id);
        GeneralInformation generalInfo = new GeneralInformation();
        List<Relations__c> reltionshipList;
        reltionshipList = getPlanRelation(planId);
        recordChildId = new Set<Id>();
        decisionSet = new Set<Id>();
        
        // get the role of the user for the selected Plan 
        Social_Input__c loggedInSocialPeople = new Social_Input__c();
        if([select id  from Social_Input__c where User__c =: userInfo.getUserId() AND Plan__c =: planId].size() > 0 ) {
            loggedInSocialPeople = [Select s.Veto_Rights__c, s.User__c, s.Responsible__c, s.Informed__c, s.Id, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c, s.Accountable__c From Social_Input__c s where User__c =: userInfo.getUserId() AND s.Plan__c =: planId limit 1 ];
        }
        // get the profile of the user for the selected Plan 
        // Profile profile =[Select p.Name From Profile p where Name =: 'System Administrator' limit 1];
         // Query for current login user max record permission
        UserRecordAccess usrRecordAccess = [SELECT RecordId, HasReadAccess, HasEditAccess, HasDeleteAccess,MaxAccessLevel FROM UserRecordAccess WHERE UserId=:UserInfo.getUserId() AND RecordId =:planId limit 1];
        //get all item data
        for(Relations__c r:reltionshipList ){
             recordChildId.add(r.Child_Id__c);
             if(r.Child_Object_Name__c == 'Decision'){
                 decisionSet.add(r.Child_Id__c);
             }
        } 
        
        map<Id,Decision__c> decisionMap = new map<Id,Decision__c>();
        map<Id,Social__c> socialMap = new map<Id,Social__c>();
        map<Id,List<Social_Input__c>> raciVetoMap = new map<Id,List<Social_Input__c>>(); 
        // approval list mapping 
        map<Id,List<Social_Input__c>> pendingRaciListMap = new map<Id,List<Social_Input__c>>();
        map<Id,List<Social_Input__c>> appRaciListMap = new map<Id,List<Social_Input__c>>();
        map<Id,List<Social_Input__c>> rejRaciListMap = new map<Id,List<Social_Input__c>>();
        //map<Id,List<Issues__c>> issueMap = new map<Id,List<Issues__c>>();
        if(decisionSet.size() > 0){
            //decisions
            for(Decision__c dec: [select id,phase__c,status__c, Estimated_Investment__c, Estimated_Direct_Cost__c, Estimated_Revenue__c, Estimated_Net_Present_Value__c, Estimated_People_Involved__c, Estimated_Full_time_Equivalent_FTE__c from Decision__c where Id In: recordChildId]) {
                decisionMap.put(dec.Id, dec);
            }
            
            //social
            for(Social__c soc: [select id, Avg_Mood__c,Related_To_ID__c from Social__c where Related_To_ID__c In: recordChildId]) {
                socialMap.put(soc.Related_To_ID__c, soc);
            }
            
            // Issues
            /*for(Issues__c iss: [select id, Related_To_ID__c from Issues__c where Related_To_ID__c In: recordChildId AND Status__c = 'Raised']) {
                List<Issues__c> issueList = issueMap.get(iss.Related_To_ID__c);
                if(issueList == null) {
                    issueList = new List<Issues__c>();
                    issueMap.put(iss.Related_To_ID__c, issueList);
                }
                issueList.add(iss);
            }*/
            
            List<Social_Input__c> raciList = [select id,Stance_Approval_Status__c,Final_Approval_Status__c,Decision__c,Veto_Rights__c,Responsible__c,Informed__c, Consulted__c, Backup_for_Accountable__c, Accountable__c  from Social_Input__c where Decision__c In: recordChildId];
            
            // get approval status of the raci members
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
        
         List<AllPlanJsonWrapper> allPlanJsonWrapperList = new List<AllPlanJsonWrapper >();
         //itemPlanWrapperMap = new map<Id,Relationship__c>();
         // generate json string of the Items for view 1234
         for(Relations__c r: reltionshipList) {
            AllPlanJsonWrapper apWrap = new AllPlanJsonWrapper();
            
            apWrap.Id = r.Id;
            apWrap.Name= r.Child_Record_Name__c;
            apWrap.Minutes = r.Minutes__c != null ? r.Minutes__c : '0' ;   //,Plan_Days_Duration__c
            apWrap.Hours = r.Hours__c != null ? r.Hours__c : '0' ;
            apWrap.Days = r.Days__c != null ? r.Days__c : '0' ;
            apWrap.Owner = recordOwnerNameMap.get(r.Child_Id__c) != null ? recordOwnerNameMap.get(r.Child_Id__c) : '';
            apWrap.popupField1 = recordPopupField1Map.get(r.Child_Id__c) != null ? recordPopupField1Map.get(r.Child_Id__c) : '';
            apWrap.popupField2 = recordPopupField2Map.get(r.Child_Id__c) != null ? recordPopupField2Map.get(r.Child_Id__c) : '';
            apWrap.popupField3 = recordPopupField3Map.get(r.Child_Id__c) != null ? recordPopupField3Map.get(r.Child_Id__c) : '';
            apWrap.popupFieldName1 = recordPopupField1NameMap.get(r.Child_Id__c) != null ? recordPopupField1NameMap.get(r.Child_Id__c) : 'Insufficient Privileges';
            apWrap.popupFieldName2 = recordPopupField2NameMap.get(r.Child_Id__c) != null ? recordPopupField2NameMap.get(r.Child_Id__c) : ''; 
            apWrap.popupFieldName3 = recordPopupField3NameMap.get(r.Child_Id__c) != null ? recordPopupField3NameMap.get(r.Child_Id__c) : ''; 
            apWrap.description = r.Description__c == null ? '' : r.Description__c;
            apWrap.Position = String.valueOf(r.Position__c);
            apWrap.Type = r.Child_Object_Name__c;
            apWrap.typeClass =  r.Child_Object_Name__c == 'Note'? 'plan-item-bold':'plan-item-normal' ;
            apWrap.itemRecordId = r.Child_Id__c;
            apWrap.isDeletable= false;
            apWrap.ismoveDown = false; 
            apWrap.ismoveUp = false; 
            if(loggedInSocialPeople.Accountable__c || loggedInSocialPeople.Backup_for_Accountable__c || loggedInSocialPeople.Responsible__c || usrRecordAccess.MaxAccessLevel=='All') {
                apWrap.isDeletable= true;
                apWrap.ismoveDown = true; 
                apWrap.ismoveUp = true;
            }
            apWrap.moveUp = apWrap.ismoveUp == true ? generalInfo.imageUrlMap.get('moveUp') : generalInfo.imageUrlMap.get('moveUpDisabled');
            apWrap.moveDown = apWrap.ismoveDown == true ? generalInfo.imageUrlMap.get('moveDown') : generalInfo.imageUrlMap.get('moveDownDisabled');
            apWrap.delItem = generalInfo.deleteImage.get(apWrap.isDeletable);
            apWrap.itemRecordId = r.Child_Id__c;
            apWrap.approve = appRaciListMap.get(Id.valueOf(r.Child_Id__c)) != null ? String.valueOf(appRaciListMap.get(Id.valueOf(r.Child_Id__c)).size()) : '0';
            apWrap.nostance = pendingRaciListMap.get(Id.valueOf(r.Child_Id__c)) != null ? String.valueOf(pendingRaciListMap.get(Id.valueOf(r.Child_Id__c)).size()) : '0';
            apWrap.disapprove = rejRaciListMap.get(Id.valueOf(r.Child_Id__c)) != null ? String.valueOf(rejRaciListMap.get(Id.valueOf(r.Child_Id__c)).size()) : '0';
            //apWrap.issue = issueMap.get(Id.valueOf(r.Child_Id__c)) != null ? String.valueOf(issueMap.get(Id.valueOf(r.Child_Id__c)).size()) : '' ;
            //apWrap.IssueImg= issueMap.get(Id.valueOf(r.Child_Id__c)) != null ? generalInfo.imageUrlMap.get('planFlagRed') : generalInfo.imageUrlMap.get('null');
            
           
            Decision__c dec = new Decision__c();
            if(decisionMap.get(Id.valueOf(r.Child_Id__c)) != null )
                dec = decisionMap.get(Id.valueOf(r.Child_Id__c));  
            if(dec.Id != null){
                String veto = 'approved';
                Integer vetNum = 0;
                Social__c soc = socialMap.get(Id.valueOf(r.Child_Id__c)); 
                List<Social_Input__c> raciList1 = new List<Social_Input__c>();
                raciList1 = raciVetoMap.get(Id.valueOf(r.Child_Id__c));
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
                apWrap.phase = dec.Phase__c != null ? dec.Phase__c : '';
                apWrap.status = dec.Status__c != null ? dec.status__c : '';
                
                /* *************** view4 *********** */
                apWrap.Investment = dec.Estimated_Investment__c != null ? String.valueOf(dec.Estimated_Investment__c) : '0';
                apWrap.DirectCost = dec.Estimated_Direct_Cost__c != null ? String.valueOf(dec.Estimated_Direct_Cost__c) : '0';
                apWrap.Revenue = dec.Estimated_Revenue__c != null ? String.valueOf(dec.Estimated_Revenue__c) : '0';
                apWrap.NetPresentValue = dec.Estimated_Net_Present_Value__c != null ? String.valueOf(dec.Estimated_Net_Present_Value__c) : '0';
                apWrap.PeopleInvolved = dec.Estimated_People_Involved__c != null ? String.valueOf(dec.Estimated_People_Involved__c) : '0';
                apWrap.FTE = dec.Estimated_Full_time_Equivalent_FTE__c != null ? String.valueOf(dec.Estimated_Full_time_Equivalent_FTE__c) : '0';
                
                /* *************** view3 *********** */
                apWrap.veto = String.valueOf(vetNum) != null ? String.valueOf(vetNum) : '' ;
                apWrap.moodClass = 'moodClass' + ( String.valueOf(soc.Avg_Mood__c) != null ? String.valueOf(math.round(soc.Avg_Mood__c)) : '');
                apWrap.mood = String.valueOf(soc.Avg_Mood__c) != null ? String.valueOf(math.round(soc.Avg_Mood__c)) : '';
                apWrap.MoodImg = generalInfo.imageUrlMap.get(string.valueOf(math.round(Double.valueOf(apWrap.mood)))) != null ? generalInfo.imageUrlMap.get(string.valueOf(math.round(Double.valueOf(apWrap.mood)))) : generalInfo.imageUrlMap.get('moodNoInput') ;                 
                /* *************** view2 *********** */
                apWrap.predictionResult = generalInfo.imageUrlMap.get(veto) != null ? generalInfo.imageUrlMap.get(veto) : generalInfo.imageUrlMap.get('null');  // to be replaced with image
                
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
                apWrap.predictionResult = generalInfo.imageUrlMap.get('null');
                apWrap.MoodImg = generalInfo.imageUrlMap.get('null') ;                 
            }
            
            
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
         
         // calculate the duration of hours of plan
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
         allItemJson = '';
         allItemJson = JSON.serialize(allPlanJsonWrapperList); 
         return allItemJson ;           
    } 
    
    // remote action method to delete item
    @RemoteAction
    public static String DeleteItem(String currId,String id){
        Relations__c relToBeDeleted = [select id from Relations__c where Id=:id];
        if(Relations__c.SObjectType.getDescribe().isDeletable()) {    
            delete relToBeDeleted ;
        }
        allItemJson = itemView(currId);
        
        return allItemJson;
    }
    
    // remote action method to move the item up
    @RemoteAction
    Public static String moveUp(String currId,string ids){
        System.debug('---->'+ids);
        Id positionRecId = Id.valueOf(ids);
        Plan__c p = [select Id from Plan__c where Id=:currId];
        List<Relations__c> listOfRelationship = getPlanRelation(p.id);
        Relations__c toBeUpdateRelationship = relationMap.get(positionRecId);
        System.debug('---->Current Position'+toBeUpdateRelationship.Position__c);
        List<Relations__c> toBeUpdatedRelationshipList = new List<Relations__c>();
        
        if(toBeUpdateRelationship.Position__c != 1 && toBeUpdateRelationship.Position__c != null) {
            for(Relations__c  r: listOfRelationship) {
                
                if(r.Position__c == toBeUpdateRelationship.Position__c - 1 ) {
                    r.Position__c = toBeUpdateRelationship.Position__c;
                    
                    toBeUpdateRelationship.Position__c= toBeUpdateRelationship.Position__c - 1;
                    toBeUpdatedRelationshipList.add(toBeUpdateRelationship);
                    toBeUpdatedRelationshipList.add(r);
                    System.debug('hello'+r.Position__c);
                    break;
                }
            }
        }
        if(toBeUpdatedRelationshipList.size() > 0) {
            //FLS check
            //Boolean updateRelList = fls.relationshipFLS('Update');
            if(Schema.SObjectType.Relations__c.fields.Position__c.isupdateable()) {
                 update toBeUpdatedRelationshipList;    
            }
        }
        allItemJson = itemView(p.id);
        
        return allItemJson;
        
    }
    
    // remote action method to move the item down
    @RemoteAction
    Public static String moveDown(String currId,string ids){
        System.debug('---->'+ids);
        Id positionRecId = Id.valueOf(ids);
        Plan__c p = [select Id from Plan__c where Id=:currId];
        List<Relations__c> listOfRelationship = getPlanRelation(p.id);
        Relations__c toBeUpdateRelationship = relationMap.get(positionRecId);
        System.debug('---->Current Position'+toBeUpdateRelationship.Position__c);
        List<Relations__c> toBeUpdatedRelationshipList = new List<Relations__c>();
        
        if(toBeUpdateRelationship.Position__c < listOfRelationship.size() && toBeUpdateRelationship.Position__c != null) {
            for(Relations__c  r: listOfRelationship) {
                
                if(r.Position__c == toBeUpdateRelationship.Position__c + 1 ) {
                    r.Position__c = toBeUpdateRelationship.Position__c;
                    
                    toBeUpdateRelationship.Position__c= toBeUpdateRelationship.Position__c + 1;
                    toBeUpdatedRelationshipList.add(toBeUpdateRelationship);
                    toBeUpdatedRelationshipList.add(r);
                    System.debug('hello'+r.Position__c);
                    break;
                }
            }
        }
        if(toBeUpdatedRelationshipList.size() > 0) {
            //FLS check
            //Boolean updateRelList = fls.relationshipFLS('Update');
            if(Schema.SObjectType.Relations__c.fields.Position__c.isupdateable()) {
                 update toBeUpdatedRelationshipList;    
            }
        }
        allItemJson = itemView(p.id);
        
        return allItemJson;
        
    }
    
    // remote action method to save the changes in the modifications done in item view 1
    @RemoteAction
    public static string saveItemModifiedData(String currId,string modifiedData){
        Plan__c p = [Select Id from Plan__c where Id =: currId];
       
        
        String allPlanItemJson = modifiedData;
        System.debug('--------json,,,,,,,,,,>'+allPlanItemJson);
     
        
        //System.debug((PlanView) System.JSON.deserialize(modifiedData, PlanView.class));
        //WorkbenchPlanView  pv = (WorkbenchPlanView) System.JSON.deserialize(modifiedData, WorkbenchPlanView.class);
        
        WorkbenchPlanView  pv = (WorkbenchPlanView) System.JSON.deserialize(modifiedData, WorkbenchPlanView.class);
        
       // System.debug(pv.Data);
        List<AllPlanJsonWrapper> allPlanView = pv.Data.models;
        
        
        
        /*******************************************************************/
        List<Relations__c> plnList =  getPlanRelation(p.Id);
        List<Relations__c> tobeUpdatedPlanItem = new List<Relations__c>();
        System.debug('-------------allPlanView------------'+allPlanView);
        for(AllPlanJsonWrapper d : allPlanView) {
            Relations__c r = relationMap.get(d.Id);
            
            r.Description__c = d.Description;
         //   r.ItemPosition__c = Decimal.valueOf(d.Position);
             system.debug('------------------->Duration'+d.Minutes);
            r.Minutes__c = d.Minutes;
            r.Hours__c = d.Hours;
            r.Days__c =  d.Days;  
            
            tobeUpdatedPlanItem.add(r);
        }
        System.debug('--->'+tobeUpdatedPlanItem);
        if(tobeUpdatedPlanItem.size () > 0) {
           //Boolean updatePlanRel = fls.relationshipFLS('Update');
            if(Schema.SObjectType.Relations__c.fields.days__c.isupdateable() && Schema.SObjectType.Relations__c.fields.Hours__c.isupdateable() && Schema.SObjectType.Relations__c.fields.Description__c.isupdateable() && Schema.SObjectType.Relations__c.fields.Minutes__c.isupdateable()) {
                 update tobeUpdatedPlanItem;    
            }
            //List<Relationship__c> plnList =  getPlanRelation(p.Id);
        }
        allItemJson = itemView(p.id);
        
        return allItemJson;
    } 
    
    //remote method to recalculate the duration of the plan after any modifications in Items
    @RemoteAction
    public static string calTotalMins(String currId){
        Plan__c p = [Select Id from Plan__c where Id =: currId];
        List<Relations__c> reltionshipList;
        reltionshipList = getPlanRelation(p.Id);
        Double totalMins = 0;
        Double totalHrs = 0;
        Double totalDays = 0;
        for(Relations__c r:reltionshipList){
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
        
         return totalHoursMints;
    }
    
    // remote method to add a item from Item list in the workbench
    @RemoteAction
    public static string addItemToPlan(string itemId,string itemName, string itemType, string planId){
        //Profile userPro = [select Name from Profile where id =: UserInfo.getProfileId()];
         // Query for current login user max record permission
        UserRecordAccess usrRecordAccess = [SELECT RecordId, HasReadAccess, HasEditAccess, HasDeleteAccess,MaxAccessLevel FROM UserRecordAccess WHERE UserId=:UserInfo.getUserId() AND RecordId =:planId limit 1];
        Social_Input__c si = new Social_Input__c();
        if([Select id From Social_Input__c s where s.Plan__c =: planId AND s.User__c =: userInfo.getUserId() limit 1 ].size() > 0) {
            si = [Select s.Veto_Rights__c, s.User__c, s.SystemModstamp,s.SYS_Tab_View_Activites__c, s.SYS_Tab_View_History__c, s.SYS_Tab_View_Tasks__c, s.SYS_Tab_View_Social_Input__c, s.SYS_Tab_View_Relations__c, s.SYS_Tab_View_Quality__c, s.SYS_Tab_View_Attachments__c, s.SYS_Tab_View_Approvals__c, s.Role_Acceptance_Status__c, s.Role_Acceptance_Required__c, s.Result__c, s.Responsible__c, s.Rating__c, s.Outcome__c, s.Name, s.Mood__c, s.Like__c, s.LastModifiedDate, s.LastModifiedById, s.Informed__c, s.Id, s.Final_Approval_Status__c, s.Effort__c, s.Dislike__c, s.Plan__c, s.CreatedDate, s.CreatedById, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c, s.Accountable__c From Social_Input__c s where s.Plan__c =: planId AND s.User__c =: userInfo.getUserId() limit 1 ];  
            if( si.Accountable__c || si.Responsible__c){
                canThisUserAddItems = 'true';
            }else{
                canThisUserAddItems = 'false';
            }
        }
        if(usrRecordAccess.MaxAccessLevel == 'All'){
            canThisUserAddItems = 'true';
        }
        if(canThisUserAddItems == 'true'){
            Plan__c p = [select Name from Plan__c where Id=:planId];
            Relations__c r = new Relations__c(child_Id__c = itemId,child_record_name__c = itemName,child_Object_Name__c = itemType,Type__c = 'Item',parent_Id__c = planId,parent_record_name__c = p.name,parent_Object_Name__c = 'Plan');
             if(Schema.SObjectType.Relations__c.fields.Parent_Record_Name__c.isCreateable() && Schema.SObjectType.Relations__c.fields.Parent_Id__c.isCreateable() && Schema.SObjectType.Relations__c.fields.Parent_Object_Name__c.isCreateable() && Schema.SObjectType.Relations__c.fields.Child_Id__c.isCreateable() && Schema.SObjectType.Relations__c.fields.Child_Object_Name__c.isCreateable() && Schema.SObjectType.Relations__c.fields.Child_Record_Name__c.isCreateable() && Schema.SObjectType.Relations__c.fields.Description__c.isCreateable() && Schema.SObjectType.Relations__c.fields.Parent_Relation__c.isCreateable() && Schema.SObjectType.Relations__c.fields.Child_Relation__c.isCreateable() && Schema.SObjectType.Relations__c.fields.Strength__c.isCreateable() && Schema.SObjectType.Relations__c.fields.Notes__c.isCreateable() && Schema.SObjectType.Relations__c.fields.Type__c.isCreateable() ){ 
                insert r;
            }
            allItemJson = itemView(planId); 
            return allItemJson ;
        }else{
            return 'no permission'; 
        }
    }
    
     // get all relation for plan 
    public static List<Relations__c> getPlanRelation(String PlanId) {
        System.debug('----------------------------->'+planId);
        relationMap = new map<Id,Relations__c>();
        if(planId != '' && planId != null) {
            List<Relations__c> relation = [select id,Minutes__c,Hours__c,Days__c,Description__c,Parent_Record_Name__c, Parent_Id__c, Parent_Object_Name__c, Child_Object_Name__c, Child_Record_Name__c, Child_Id__c, Position__c  from Relations__c  where Parent_Id__c =: planId AND Type__c = 'Item'  order by Position__c ASC limit 50000];
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
    public static void ownerDetail(Set<Id> recordIdList) {
        recordOwnerMap = new map<Id, Id>();
        recordOwnerNameMap = new map<Id, String>();
        recordPopupField1Map = new map<Id,String>();
        recordPopupField2Map = new map<Id,String>();
        recordPopupField3Map = new map<Id,String>();
        recordPopupField1NameMap = new map<Id,String>();
        recordPopupField2NameMap = new map<Id,String>(); 
        recordPopupField3NameMap = new map<Id,String>(); 
        
        for(Decision__c d: [select id, OwnerId, Owner.Name,Problem_Idea_Advice__c,Decision_Taken__c,Priority__c from Decision__c where Id In: recordIdList]) {
            recordOwnerMap.put(d.Id, d.OwnerId);
            recordOwnerNameMap.put(d.Id, d.Owner.Name);
            if(d.Problem_Idea_Advice__c != null)
            recordPopupField1Map.put(d.Id, d.Problem_Idea_Advice__c.replaceAll('\n',' '));
            //recordPopupField1NameMap.put(d.Id, 'Problem / Idea / Advice');
            recordPopupField1NameMap.put(d.Id, 'Description');
            if(d.Decision_Taken__c!= null)
            recordPopupField2Map.put(d.Id, d.Decision_Taken__c.replaceAll('\n',' '));
            recordPopupField2NameMap.put(d.Id, 'Decision');
            recordPopupField3Map.put(d.Id, '');
            recordPopupField3NameMap.put(d.Id,'');
        }
        
        for(Task  t: [select id, OwnerId, Owner.Name, Priority, Status, Type from Task where Id In: recordIdList]) {
            recordOwnerMap.put(t.Id, t.OwnerId);
            recordOwnerNameMap.put(t.Id, t.Owner.Name);
            recordPopupField1Map.put(t.Id, t.Priority);
            recordPopupField1NameMap.put(t.Id, 'Priority');
            recordPopupField2Map.put(t.Id, t.Status);
            recordPopupField2NameMap.put(t.Id, 'Status'); 
            recordPopupField3Map.put(t.Id,'');
            recordPopupField3NameMap.put(t.Id,''); 
        }
        
        for(Account a: [select id, OwnerId, Owner.Name,Name,Phone,Description from Account where Id In: recordIdList]) {
            recordOwnerMap.put(a.Id, a.OwnerId);
            recordOwnerNameMap.put(a.Id, a.Owner.Name);
            recordPopupField1Map.put(a.Id, a.Name);
            recordPopupField1NameMap.put(a.Id, 'Name');
            recordPopupField2Map.put(a.Id, a.Description);
            recordPopupField2NameMap.put(a.Id, 'Description');
            recordPopupField3Map.put(a.Id, '');
            recordPopupField3NameMap.put(a.Id, '');
        }
        
        for(Contact a: [select id, OwnerId, Owner.Name,LastName,FirstName,Title,MobilePhone,Description from Contact where Id In: recordIdList]) {
            recordOwnerMap.put(a.Id, a.OwnerId);
            recordOwnerNameMap.put(a.Id, a.Owner.Name);
            recordPopupField1Map.put(a.Id, a.FirstName+' '+a.LastName);
            recordPopupField1NameMap.put(a.Id, 'Name');
            recordPopupField2Map.put(a.Id, a.MobilePhone);
            recordPopupField2NameMap.put(a.Id, 'Title' );
            recordPopupField3Map.put(a.Id,a.MobilePhone);
            recordPopupField3NameMap.put(a.Id, 'Mobile');
        }
        
        /*for(Issues__c a: [select id, OwnerId, Owner.Name,Priority__c,Status__c,Type__c from Issues__c where Id In: recordIdList]) {
            recordOwnerMap.put(a.Id, a.OwnerId);
            recordOwnerNameMap.put(a.Id, a.Owner.Name);
            recordPopupField1Map.put(a.Id, a.Priority__c);
            recordPopupField1NameMap.put(a.Id, 'Priority');
            recordPopupField2Map.put(a.Id, a.Status__c);
            recordPopupField2NameMap.put(a.Id, 'Status');
            recordPopupField3Map.put(a.Id,'');
            recordPopupField3NameMap.put(a.Id, '');
        }*/
        
        for(Plan__c a: [select id, OwnerId, Owner.Name,Start_Time__c,End_Time__c,Location__c  from Plan__c where Id In: recordIdList]) {
            recordOwnerMap.put(a.Id, a.OwnerId);
            recordOwnerNameMap.put(a.Id, a.Owner.Name);
            recordPopupField1Map.put(a.Id, String.valueOf(a.Start_Time__c));
            recordPopupField1NameMap.put(a.Id, 'Start Date');
            recordPopupField2Map.put(a.Id, String.valueOf(a.End_Time__c));
            recordPopupField2NameMap.put(a.Id, 'End Date');
            recordPopupField3Map.put(a.Id,'');
            recordPopupField3NameMap.put(a.Id, '');
        }
        
        for(Note a: [select id, OwnerId, Owner.Name, body from Note where Id In: recordIdList]) {
            recordOwnerMap.put(a.Id, a.OwnerId);
            recordOwnerNameMap.put(a.Id, a.Owner.Name);
            recordPopupField1Map.put(a.Id, a.body);
            recordPopupField1NameMap.put(a.Id, 'Body');
            recordPopupField2Map.put(a.Id, '');
            recordPopupField2NameMap.put(a.Id, '');
            recordPopupField3Map.put(a.Id, '');
            recordPopupField3NameMap.put(a.Id, '');
        }
        
    }
    
    // remote method to add note in Item list
    @RemoteAction
    public static string addNoteItems(String currId,string subject,string body){
        Plan__c p = [select id, Name from plan__c where Id=:currId];
        
        Note n = new Note();
        n.body = body;
        n.Title = subject;
        n.parentId = p.Id;
        if(Schema.sObjectType.Note.fields.Title.isCreateable() && Schema.sObjectType.Note.fields.Body.isCreateable() && Schema.sObjectType.Note.fields.parentId.isCreateable()){
            insert n;
        }
        
        Relations__c r = new Relations__c();
        r.child_Id__c = n.Id;
        r.Child_Record_Name__c = subject;
        r.Child_Object_Name__c = 'Note';
        r.Parent_Id__c = p.Id;
        r.parent_Record_Name__c = p.Name;
        r.parent_Object_Name__c = 'Plan';
        r.type__c = 'Item';
        if(Schema.sObjectType.Relations__c.fields.child_Id__c.isCreateable() && Schema.sObjectType.Relations__c.fields.child_Record_Name__c.isCreateable()  && Schema.sObjectType.Relations__c.fields.child_Object_Name__c.isCreateable() && Schema.sObjectType.Relations__c.fields.parent_Object_Name__c.isCreateable() && Schema.sObjectType.Relations__c.fields.parent_Record_Name__c.isCreateable() && Schema.sObjectType.Relations__c.fields.Parent_Id__c.isCreateable() && Schema.sObjectType.Relations__c.fields.Type__c.isCreateable()){
            insert r;
        }
        
        allItemJson = itemView(p.id);
        
        return allItemJson;
    }
    
    public void chatterFeedMethod(){
    
    }
    
    public Data data;
    
    public class Data {
        public List<AllPlanJsonWrapper> models;
    }
    
     // Create Wrapper class for allPlanJson 
     
    public class Datum
    {
        public string Type { get; set; }
        public string Status { get; set; }
        public string recordId { get; set; }
        public string Position { get; set; }
        public string Phases { get; set; }
        public string Owner { get; set; }
        public string Name { get; set; }
        public string Id { get; set; }
        public string Minutes { get; set; }
        public string Hours { get; set; }
        public string Days { get; set; }
        public string Description { get; set; }
        public string OwnerId { get; set; }
    }

    public class RootObject
    {
        public List<Datum> data { get; set; }
    }
     
     // Create Wrapper class for allPlanJson 
    public class AllPlanJsonWrapper {
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
        public String typeClass {get;set;}   
        public String itemRecordId {get;set;}
        public Boolean ismoveUp {get;set;}
        public String moveUp{get;set;}
        public Boolean ismoveDown {get;set;}
        public String moveDown{get;set;}
        public Boolean isDeletable {get;set;}
        public String delItem{get;set;}
        public String Investment {get;set;}
        public String DirectCost {get;set;}
        public String Revenue{get;set;}
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
        public String moodClass {get;set;}
        
        
    }
       
    
}