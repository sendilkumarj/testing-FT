/*
Created : Piyush Parmar
Modified by : Piyush Parmar
Description: This trigger is used to apply sharing rules, trigger approval processes(Role,Stance and Decision), Follow and unfollow people and recall approval process.
             The objective of the trigger is, when a decision record is updated,
             1) The sharing rules should be applied for the people who are part of the decision on share phase. 
             2) The approval process should get triggered (Role,Stance and Decision).
             3) People should follow the decision when shared.
             4) Unfollow the people when decision is closed.
             5) Recall the approval process taht are pending when the decision is closed.
             6) A chatter post when the decison is closed.
*/

trigger DecisionAfterBeforeUpdate on Decision__c (after update, before update) {
        
    // initialize deicision map with id
    map<Id,Decision__c> decisionIdMap = new map<Id,Decision__c>();
    
    // initialize deicision oldmap with id
    map<Id,Decision__c> decisionOldIdMap = new map<Id,Decision__c>();
    
    // initialize decision object 
    List<Decision__Share> decisionShareToBeInsertList = new List<Decision__Share>();
    
    // initialize follow (entiti subscription) object 
    List<EntitySubscription> followEntitySubscriptionToBeInsertList= new List<EntitySubscription> ();
    
     // initialize decision id set 
    set<Id> decisionIdTobeShare = new set<Id>();
    
     // initialize decision id set 
    set<Id> decisionIdTobeDecide = new set<Id>();
    
    // initialize decision id set 
    set<Id> decisionIdToBeClose = new set<Id>();
    
    // initialize decision id set 
    set<Id> decisionIdToBeExecute = new set<Id>();
    
    // initialize decision id set 
    set<Id> decisionIdToBeCloseShare = new set<Id>();
    
    // TO BE POSTED CHATTER ON DECISION CLOSE
    List<FeedItem> toBePostedOnDecision = new List<FeedItem>();
    
    // initialize decisionid se for update tab structure of hitory  
    set<Id> decisionIdPhasesUpdate = new set<Id>();
    
    
    // initialize decisionid se for update relation object 
    map<Id,Decision__c> decisioMapTileUpdated = new map<Id,Decision__c>();
     
    // role acceptance approval rules
    List<Approval.ProcessSubmitRequest>  roleAcceptanceApprovalList = new List<Approval.ProcessSubmitRequest>();
    
    // initialize socialInputIdTobeRecallAproval
    // approval has been recalled
    set<Id> socialInputIdTobeRecallAproval = new set<Id>();
    
    // Variables used for transfer ownership.
    // Set the id for the decision owner.
    set<Id> decisionOwnerSwap = new set<Id>();
    // Create a map for the decision current owner.
    map<id,id> decisionCurrentOwnerId = new map<id,id>();
    // Create a map for the decision old owner.
    map<id,id> decisionIdOldOwnerMap = new map<id,id>(); 
    
    List<Social_Input__c> tobeUpdateSocialInput = new List<Social_Input__c>();
    RankingDatabaseDefination rdd = new RankingDatabaseDefination();
    set<Id> setIds = new set<Id>();
    for(Decision__c decision : Trigger.new) {
        if(decision.Update_Manager__c == Trigger.oldMap.get(decision.Id).Update_Manager__c){
            if(Trigger.isBefore){
                
                decision.SYS_Accountable__c = decision.OwnerId;
                
                if(decision.Private__c == true){
                    decision.Name = '...';
                }
                else {
                    decision.Name = decision.Title__c;
                    if(decision.name.length() > 79) {
                        decision.Name = decision.Name.substring(0,79);
                    }
                }
                if(decision.Approved_when_Created__c){
                    decision.Approved_when_Created__c = false;  
                }
                
                if(decision.Status__c == 'Approved'){
                    decision.test__c = true;
                } else if(decision.Status__c == 'Rejected'){
                    decision.test__c = false;
                }
                //Decision__c oldDecision = Trigger.oldMap.get(decision.ID);
               
            }
            if(Trigger.isAfter) {
                Decision__c  oldDecision = System.Trigger.oldMap.get(decision.Id);
                
                decisionOldIdMap.put(oldDecision.Id, oldDecision);
                decisionIdMap.put(decision.Id, decision);
              
                //decisionIdTobeShare.add(decision.Id);
                if((decision.Phase__c == 'Propose' || decision.Phase__c=='Decide') && (oldDecision.Phase__c == 'Decide' || oldDecision.Phase__c == 'Propose') &&  oldDecision.OwnerId != decision.OwnerId){
                    decisionIdTobeShare.add(decision.Id);
                }
                // Decisin "Share"
                if(decision.Phase__c=='Share' && decision.Phase__c != oldDecision.Phase__c){
                    decisionIdTobeShare.add(decision.Id);
                }
                
                if(decision.Phase__c=='Propose' && decision.Phase__c != oldDecision.Phase__c){
                    decisionIdTobeDecide.add(decision.Id);
                } 
                
                if(decision.Phase__c=='Propose' && oldDecision.Phase__c == 'Propose'){
                    decisionIdTobeDecide.add(decision.Id);
                }
                
                // When the decision is closed a chatter post is generated for the decision.
                // Check the decision phase.
                if(decision.Phase__c=='Close' && decision.Phase__c != oldDecision.Phase__c) {
                    decisionIdToBeClose.add(decision.Id);
                     
                    // Create a post.
                    FeedItem post = new FeedItem();
                    post.ParentId = decision.id;
                    // Condition check if comments field is not empty.
                    if(decision.Comments__c != null){
                        post.Body = 'closed the decision with "' + decision.Reason_for_Close__c +'" as the reason and the following comment: "'+ decision.Comments__c + '"';
                    }
                    // Condition check if comments field is empty.
                    else{
                        post.Body = 'closed the decision with "'+ decision.Reason_for_Close__c +'" as the reason.';                }
                    toBePostedOnDecision.add(post);
                }
               
                // add all follow user on decision - when decision get re-Execute
                if(decision.Phase__c=='Execute' && oldDecision.Phase__c == 'Close') {
                    decisionIdToBeExecute.add(decision.Id);
                }
                
                // update tab structure of hitory 
                // update timing data of decision
                if(decision.Phase__c != oldDecision.Phase__c) {
                    decisionIdPhasesUpdate.add(decision.Id);
                }
                
                // update relations records if title or name will change
                if(decision.Title__c != oldDecision.Title__c){
                    decisioMapTileUpdated.put(decision.Id,decision);
                }
                
                // For Transfer ownership
                // Condition to check when owner id is changed.
                if(decision.OwnerId != oldDecision.OwnerId){
                    decisionIdOldOwnerMap.put(decision.Id,oldDecision.OwnerId); 
                    decisionCurrentOwnerId.put(decision.Id,decision.OwnerId);   
                    decisionOwnerSwap.add(decision.Id); 
                }
                if(trigger.oldmap.get(decision.id).Decision_Type__c != decision.Decision_Type__c){
                	rdd.updateCalculation('Create a decision', decision.Decision_Type__c, trigger.oldmap.get(decision.id).Decision_Type__c);
                }
                if(decision.Phase__c == 'Close'){
                	if(!CheckforRecrussion.isRdd){		
                		rdd.calculatePoints('Close a Decision', '');
                		//CheckforRecrussion.isRdd = true;
                	}
                }
                if(decision.Phase__c != Trigger.oldMap.get(decision.Id).Phase__c){
                	if(!CheckforRecrussion.isRdd){			
                		rdd.calculatePoints('Advance a decision as Accountable', '');
                		CheckforRecrussion.isRdd = true;
                	}
                }
                if(decision.Status__c != Trigger.oldMap.get(decision.Id).Status__c && (decision.Status__c == 'Approved' || decision.Status__c == 'Rejected')){
                	setIds.add(decision.Id);
                }
            }
        }
    }
    
    if(!setIds.isEmpty()){
    	RankingDatabaseDefination.stanceNotGiven(setIds);
    }
    
    // Transfer ownership
    if(decisionOwnerSwap.size() > 0){
        // Call transferOwnershipForDecision method from TransferOwnership controller.
        TransferOwnership.transferOwnershipForDecision(decisionOwnerSwap,decisionIdOldOwnerMap,decisionCurrentOwnerId);
    }
    
    // share decision with user 
    // trigger acceptance request to the user of decision
    if(decisionIdTobeShare.size() > 0) {
        
        // mapping to check user is aleady share with decision or not
        map<Id, set<Id>> decisionUserGrpMap = new map<Id, set<Id>>();
        
        List<Decision__Share> decisionShareList = new List<Decision__Share>();
        decisionShareList = [select id, UserOrGroupId, ParentId from Decision__Share where ParentId In: decisionIdTobeShare ];
        
        for(Decision__Share ds : decisionShareList) {
            set<Id> usrGrpId = decisionUserGrpMap.get(ds.ParentId);
            if(usrGrpId == null) {
                usrGrpId = new set<Id>();
                decisionUserGrpMap.put(ds.ParentId,usrGrpId );
            }
            usrGrpId.add(ds.UserOrGroupId);
        }
        
        // mapping to check user is aleady follow  the decision or not
        map<Id, set<Id>> followDecisionUserGrpMap = new map<Id, set<Id>>();
        
        List<EntitySubscription> entitySubscriptionList = new List<EntitySubscription>();
        entitySubscriptionList = [select id, parentId, subscriberid from EntitySubscription where ParentId In: decisionIdTobeShare];
        
        for(EntitySubscription es : entitySubscriptionList) {
            set<Id> usrGrpId = followDecisionUserGrpMap.get(es.ParentId);
            if(usrGrpId == null) {
                usrGrpId = new set<Id>();
                followDecisionUserGrpMap.put(es.ParentId,usrGrpId );
            }
            usrGrpId.add(es.subscriberid);
        }
        //
        
        
            
        // sharing rule and follow generate
        for(Social_Input__c socialInput : [Select s.Id,s.User__r.isActive,s.Is_Group__c, s.GroupId__c, s.Role_Acceptance_Required__c, s.Role_Acceptance_Status__c,s.Responsible__c, s.Veto_Rights__c, s.Informed__c,s.User__c, s.Decision__c,s.Decision__r.Phase__c, s.Consulted__c, s.Backup_for_Accountable__c, s.Accountable__c From Social_Input__c s where s.Decision__c In: decisionIdTobeShare]) {
        
            Decision__c decisionOld = decisionOldIdMap.get(socialInput.Decision__c);
            
            if(decisionOld.Phase__c == 'Draft' && socialInput.Role_Acceptance_Required__c) {
                
                if(socialInput.User__c != null && socialInput.User__r.isActive == true) {
                    if(socialInput.Responsible__c || socialInput.Consulted__c || socialInput.Informed__c ) {
                        // role acceptance request to the user of decision
                        //if(socialInput.Role_Acceptance_Status__c !='Pending Approval' && socialInput.Role_Acceptance_Status__c !='Approved/Accepted') {
                            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                            req.setComments('Awaiting response.');
                            req.setObjectId(socialInput.id);
                            roleAcceptanceApprovalList.add(req);
                        //}
                    }
                 }
            }
            
            // Close to share 
            if(decisionOld.Phase__c != 'Draft' && (socialInput.Decision__r.Phase__c !='Decide' && decisionOld.Phase__c == 'Decide')) {
                 if(socialInput.Role_Acceptance_Status__c != 'Pending Approval'){
                    socialInputIdTobeRecallAproval.add(socialInput.Id);
                    socialInput.Final_Approval_Status__c = '';
                    socialInput.Stance_Approval_Status__c = '';
                    tobeUpdateSocialInput.add(socialInput);
                }
            }
            
            if(decisionOld.Phase__c == 'Propose' || decisionOld.Phase__c == 'Execute' || decisionOld.Phase__c == 'Evaluate' || decisionOld.Phase__c == 'Close' ) {
                  
                 if(socialInput.Role_Acceptance_Status__c != 'Pending Approval'){
                    socialInputIdTobeRecallAproval.add(socialInput.Id);
                    socialInput.Final_Approval_Status__c = '';
                    socialInput.Stance_Approval_Status__c = '';
                    tobeUpdateSocialInput.add(socialInput);
                }
            }
            // Integer.valueOf(socialInput.Decision__r.Phase__c + decisionOld.Phase__c +  socialInput.Role_Acceptance_Status__c +  socialInput.Role_Acceptance_Required__c); 
            if(socialInput.Decision__r.Phase__c == 'Share' && decisionOld.Phase__c == 'Close' && socialInput.Role_Acceptance_Status__c == 'Pending Approval' && socialInput.Role_Acceptance_Required__c ){
                System.debug( 'APPROVE2');
              // Integer.valueOf(socialInput.Decision__r.Phase__c ); 
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Awaiting response.');
                req.setObjectId(socialInput.id);
                roleAcceptanceApprovalList.add(req);    
            }
            
            // This is to share the Decision record. with the user 
            // get all user maped id 
            set<Id> alreadySharedUserId = new set<Id>();
            alreadySharedUserId = decisionUserGrpMap.get(socialInput.Decision__c);
            if(socialInput.User__c != null && socialInput.User__r.isActive == true) {
                if(!alreadySharedUserId.contains(socialInput.User__c)) {
                    
                    Decision__Share decisionShare = new Decision__Share();
                    decisionShare.ParentId = socialInput .Decision__c;
                    decisionShare.UserOrGroupId = socialInput .User__c;
                    if(socialInput.Responsible__c || socialInput.Backup_for_Accountable__c || socialInput.Veto_Rights__c) {
                        decisionShare.AccessLevel = 'Edit';
                    }
                    else {
                        decisionShare.AccessLevel = 'Read';
                    }
                    decisionShareToBeInsertList.add(decisionShare);
                    
                }
            }
            else {
                if(socialInput.Is_Group__c && socialInput.GroupId__c != null) {
                    Decision__Share decisionShare = new Decision__Share();
                    decisionShare.ParentId = socialInput.Decision__c;
                    decisionShare.UserOrGroupId = socialInput.GroupId__c;
                    decisionShare.AccessLevel = 'Read';
                    decisionShareToBeInsertList.add(decisionShare);
                }
            }
            // This is to follow the Decision record. with the user 
            // get all user maped id 
            // follow the decision is decision is on draft and closed
            if(socialInput.User__c != null && socialInput.User__r.isActive == true) {
                if(followDecisionUserGrpMap.get(socialInput.Decision__c) != null) {
                    set<Id> alreadyFollowedUserId = followDecisionUserGrpMap.get(socialInput.Decision__c);
                
                    if(alreadyFollowedUserId.size() > 0) {
                        if(!alreadyFollowedUserId.contains(socialInput.User__c)) {
                            
                            EntitySubscription follow = new EntitySubscription ();
                            follow.parentId = socialInput .Decision__c;
                            follow.subscriberid = socialInput .User__c;
                            followEntitySubscriptionToBeInsertList.add(follow);
                        
                        }
                    } 
                }// EO map null condition
                else {
                    EntitySubscription follow = new EntitySubscription ();
                    follow.parentId = socialInput.Decision__c;
                    follow.subscriberid = socialInput.User__c;
                    followEntitySubscriptionToBeInsertList.add(follow);
                }
            }
        } // EOF social input 
        
        if(tobeUpdateSocialInput.size() > 0) {
            update tobeUpdateSocialInput;
        }
        
         // approval has been recalled
        if(socialInputIdTobeRecallAproval.size() > 0) {
            
            for(ProcessInstanceWorkitem p: [select Id,ProcessInstance.TargetObjectId from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId in: socialInputIdTobeRecallAproval]) {
                System.debug( 'APPROVE3');
                Approval.ProcessWorkItemRequest pwr = new Approval.ProcessWorkItemRequest();
                pwr.setWorkitemId(p.id);
                pwr.setComments('This decision approval has been recalled');
                pwr.setAction('Removed'); 
                Approval.ProcessResult pr = Approval.process(pwr);
            }
            
        } // EO if condition for approval recall
         
    } // EO share condition
    
    
    // decision phase become "Propose" do  action
    /*if(decisionIdTobeDecide.size() > 0) {
        for(Social_Input__c socialInput : [Select s.Id,s.User__r.isActive,s.Role_Acceptance_Status__c,s.Responsible__c,Final_Approval_Status__c, s.Veto_Rights__c, s.Informed__c,s.User__c, s.Decision__c,s.Decision__r.Phase__c, s.Consulted__c, s.Backup_for_Accountable__c, s.Accountable__c From Social_Input__c s where s.Decision__c In: decisionIdTobeDecide]) {
            if(socialInput.User__c != null && socialInput.User__r.isActive == true) {
                if(socialInput.Accountable__c || socialInput.Responsible__c || socialInput.Consulted__c || (socialInput.Informed__c && socialInput.Backup_for_Accountable__c)) {
                    // decision acceptance request to the user of decision
                    if(socialInput.Role_Acceptance_Status__c !='Pending Approval' && socialInput.Role_Acceptance_Status__c !='Not Accepted' && (socialInput.Final_Approval_Status__c !='Pending Approval' && socialInput.Decision__r.Phase__c == 'Propose') ) {
                        System.debug( 'APPROVE4');
                        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                        req.setComments('Awaiting Response.');
                        req.setObjectId(socialInput.id);
                        roleAcceptanceApprovalList.add(req);
                    }
                }
            }
        }
    }*/
    
    /*
    if(decisionIdTobeDecide.size() > 0) {
        for(Social_Input__c socialInput : [Select s.Id,s.User__r.isActive,s.Stance_Approval_Status__c,s.Role_Acceptance_Status__c,s.Responsible__c,Final_Approval_Status__c, s.Veto_Rights__c, s.Informed__c,s.User__c, s.Decision__c,s.Decision__r.Phase__c, s.Consulted__c, s.Backup_for_Accountable__c, s.Accountable__c From Social_Input__c s where s.Decision__c In: decisionIdTobeDecide]) {
            if(socialInput.User__c != null && socialInput.User__r.isActive == true) {
                //Approval process for my stance when user accepts there role and when decision moves to propose phase an approval process will be sent to all the collaboraters.
               if(socialInput.Decision__r.Phase__c == 'Propose' && socialInput.Role_Acceptance_Status__c == 'Approved/Accepted' && socialInput.Stance_Approval_Status__c == null && !socialInput.Informed__c){ 
                    System.debug('--------Stance Approval------------>');
                    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                    req.setComments('Awaiting Response.');
                    req.setObjectId(socialInput.id);
                    roleAcceptanceApprovalList.add(req);
               }
               // Approval process for decision to be sent only for A, B, V after giving there my stance status in propose phase.
               if((socialInput.Accountable__c || socialInput.Backup_for_Accountable__c || socialInput.Veto_Rights__c) && socialInput.Role_Acceptance_Status__c == 'Approved/Accepted' && (socialInput.Stance_Approval_Status__c == 'Approved' || socialInput.Stance_Approval_Status__c == 'Rejected') && (socialInput.Final_Approval_Status__c == null && socialInput.Decision__r.Phase__c == 'Propose')) {
                    System.debug('--------Decision Approval------------>');
                    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                    req.setComments('Awaiting Response.');
                    req.setObjectId(socialInput.id);
                    roleAcceptanceApprovalList.add(req);
                }
            }
        }
    }   */
    
    // decision phase become "Execute" 
    //share decision with user 
    if(decisionIdToBeExecute.size() > 0) {
        
        // mapping to check user is aleady follow  the decision or not
        map<Id, set<Id>> followDecisionUserGrpMap = new map<Id, set<Id>>();
        
        List<EntitySubscription> entitySubscriptionList = new List<EntitySubscription>();
        entitySubscriptionList = [select id, parentId, subscriberid from EntitySubscription where ParentId In: decisionIdToBeExecute];
        
        for(EntitySubscription es : entitySubscriptionList) {
            set<Id> usrGrpId = followDecisionUserGrpMap.get(es.ParentId);
            if(usrGrpId == null) {
                usrGrpId = new set<Id>();
                followDecisionUserGrpMap.put(es.ParentId,usrGrpId );
            }
            usrGrpId.add(es.subscriberid);
        }
        //
        
        for(Social_Input__c socialInput : [Select s.Informed__c,User__r.isActive,s.User__c, s.Decision__c, s.Consulted__c, s.Backup_for_Accountable__c, s.Accountable__c From Social_Input__c s where s.Decision__c In: decisionIdToBeExecute]) {
            // This is to follow the Decision record. with the user 
            // get all user maped id 
            // follow the decision is decision is on draft and closed
            if(socialInput.User__c != null && socialInput.User__r.isActive == true) {
                if(followDecisionUserGrpMap.get(socialInput.Decision__c) != null) {
                    set<Id> alreadyFollowedUserId = followDecisionUserGrpMap.get(socialInput.Decision__c);
                
                    if(alreadyFollowedUserId.size() > 0) {
                        if(!alreadyFollowedUserId.contains(socialInput.User__c)) {
                            
                            EntitySubscription follow = new EntitySubscription ();
                            follow.parentId = socialInput .Decision__c;
                            follow.subscriberid = socialInput .User__c;
                            followEntitySubscriptionToBeInsertList.add(follow);
                        
                        }
                    } 
                }// EO map null condition
                else {
                    EntitySubscription follow = new EntitySubscription ();
                    follow.parentId = socialInput.Decision__c;
                    follow.subscriberid = socialInput.User__c;
                    followEntitySubscriptionToBeInsertList.add(follow);
                }
            }
        } // EOF social input 
        
    }
    
    // update tab structure of hitory 
    if(decisionIdPhasesUpdate.size() > 0) {
        
        // initialize Social Input for update tab structure of hitory 
        List<Social_Input__c> toBeUpdatedSocialInputForHistory = new List<Social_Input__c>();
        
        for(Social_Input__c socialInput : [Select s.SYS_Tab_View_History__c From Social_Input__c s where s.Decision__c In: decisionIdPhasesUpdate]) {
            socialInput.SYS_Tab_View_History__c = true;
            toBeUpdatedSocialInputForHistory.add(socialInput);
        }
        
        // initialize timing records list for track timing
        List<Timing__c> tobeUpdatedTimingList = new List<Timing__c>();
        
        // initialize map of decision id v/s timing data
        map<Id, List<Timing__c>> decisionIdtimingListMap = new map<Id, List<Timing__c>>();
        
        for(Timing__c timing : [Select t.Start_Date_Time__c, t.Stage__c, t.Related_To_ID__c, t.End_Date_Time__c, t.Elapsed_Time__c, t.Difference__c, t.Actual_Start_Date__c, t.Actual_End_Date__c From Timing__c t where t.Related_To_ID__c In: decisionIdPhasesUpdate]) {
            
            List<Timing__c> timingList = decisionIdtimingListMap.get(timing.Related_To_ID__c);
            if(timingList == null ) {
                timingList = new List<Timing__c>();
                decisionIdtimingListMap.put(timing.Related_To_ID__c, timingList);
            }
            timingList.add(timing);
        }
        
        List<Id> decisionIdList = new List<Id>(decisionIdPhasesUpdate);
        //.addAll(decisionIdPhasesUpdate);
        
        
        for(Id dId :decisionIdList ) {
            
            
            // update timing records on decision phase chanages
            
            Decision__c deicisionOld = decisionOldIdMap.get(dId);
            Decision__c deicision = decisionIdMap.get(dId);
            
            map<String, Timing__c> phasestimingMap = new map<String, Timing__c>();
            for(Timing__c timing : decisionIdtimingListMap.get(dId)) {
                phasestimingMap.put(timing.Stage__c, timing);
            }
            
            Timing__c draft = phasestimingMap.get('Draft');
            Timing__c share = phasestimingMap.get('Share');
            Timing__c decide = phasestimingMap.get('Propose');
            Timing__c approve = phasestimingMap.get('Decide');
            Timing__c execute = phasestimingMap.get('Execute');
            Timing__c evaluate = phasestimingMap.get('Evaluate');
            Timing__c close = phasestimingMap.get('Close');
            
            if(deicision.Phase__c == 'Share') {
                draft.Actual_End_Date__c = DateTime.now();
                share.Actual_Start_Date__c = DateTime.now();
                draft.Elapsed_Time__c = GeneralInformation.displayDifferencesforTimimg(draft.Actual_End_Date__c, draft.Actual_Start_Date__c);
                string accumulatedTime = GeneralInformation.displayDifferencesforTimimg(draft.Actual_End_Date__c, draft.Actual_Start_Date__c) ;
                draft.Difference__c= accumulatedTime;
            }
            
            if(deicision.Phase__c == 'Propose') {
                share.Actual_End_Date__c = DateTime.now();
                decide.Actual_Start_Date__c = DateTime.now();
                share.Elapsed_Time__c = GeneralInformation.displayDifferencesforTimimg(share.Actual_End_Date__c, share.Actual_Start_Date__c);
                //Accumulated time calculation 
                 string accumulatedTime = GeneralInformation.displayDifferencesforTimimg(share.Actual_End_Date__c, draft.Actual_Start_Date__c) ;
                 share.Difference__c= accumulatedTime;
 
            }
            
            if(deicision.Phase__c  == 'Decide') {
                decide.Actual_End_Date__c = DateTime.now();
                approve.Actual_Start_Date__c = DateTime.now();
                decide.Elapsed_Time__c = GeneralInformation.displayDifferencesforTimimg(decide.Actual_End_Date__c, decide.Actual_Start_Date__c);
                string accumulatedTime = GeneralInformation.displayDifferencesforTimimg(decide.Actual_End_Date__c, draft.Actual_Start_Date__c) ;
                decide.Difference__c= accumulatedTime;           
            }
            
            if(deicision.Phase__c == 'Execute') {
                approve.Actual_End_Date__c = DateTime.now();
                execute.Actual_Start_Date__c = DateTime.now();
                approve.Elapsed_Time__c = GeneralInformation.displayDifferencesforTimimg(approve.Actual_End_Date__c, approve.Actual_Start_Date__c);
                string accumulatedTime = GeneralInformation.displayDifferencesforTimimg(approve.Actual_End_Date__c, draft.Actual_Start_Date__c) ;
                approve.Difference__c= accumulatedTime;           
            
            }
            
            if(deicision.Phase__c == 'Evaluate') {
                
                
                if(deicisionOld.Phase__c == 'Execute'){
	                execute.Actual_End_Date__c = DateTime.now();
	                execute.Elapsed_Time__c = GeneralInformation.displayDifferencesforTimimg(execute.Actual_End_Date__c, execute.Actual_Start_Date__c);
	                string accumulatedTime = GeneralInformation.displayDifferencesforTimimg(execute.Actual_End_Date__c, draft.Actual_Start_Date__c) ;           
	                execute.Difference__c= accumulatedTime;  
	                evaluate.Actual_Start_Date__c = DateTime.now();
                }
                
                 if(deicisionOld.Phase__c == 'Decide'){
	                approve.Actual_End_Date__c = DateTime.now();
	                approve.Elapsed_Time__c = GeneralInformation.displayDifferencesforTimimg(approve.Actual_End_Date__c, approve.Actual_Start_Date__c);
	                string accumulatedTime = GeneralInformation.displayDifferencesforTimimg(approve.Actual_End_Date__c, draft.Actual_Start_Date__c) ;           
	                approve.Difference__c= accumulatedTime;  
	                evaluate.Actual_Start_Date__c = DateTime.now();
                }
                
             }
                         
            
            
            if(deicision.Phase__c == 'Close') {
                if(deicisionOld.Phase__c == 'Share'){
                    share.Actual_End_Date__c = DateTime.now();
                    string accumulatedTime = GeneralInformation.displayDifferencesforTimimg(share.Actual_End_Date__c, draft.Actual_Start_Date__c) ;
                    share.Difference__c= accumulatedTime;               
                    share.Elapsed_Time__c  = GeneralInformation.displayDifferencesforTimimg(share.Actual_End_Date__c, share.Actual_Start_Date__c);                 
                }
                if(deicisionOld.Phase__c == 'Propose'){
                    decide.Actual_End_Date__c = DateTime.now();
                    string accumulatedTime = GeneralInformation.displayDifferencesforTimimg(decide.Actual_End_Date__c, draft.Actual_Start_Date__c) ;
                    decide.Difference__c= accumulatedTime;  
                    decide.Elapsed_Time__c  = GeneralInformation.displayDifferencesforTimimg(decide.Actual_End_Date__c, decide.Actual_Start_Date__c);                 
                }
                if(deicisionOld.Phase__c == 'Decide'){
                    approve.Actual_End_Date__c = DateTime.now();
                    string accumulatedTime = GeneralInformation.displayDifferencesforTimimg(approve.Actual_End_Date__c, draft.Actual_Start_Date__c) ;
                    approve.Difference__c= accumulatedTime;                  
                    approve.Elapsed_Time__c  = GeneralInformation.displayDifferencesforTimimg(approve.Actual_End_Date__c, approve.Actual_Start_Date__c);                 
                }
                if(deicisionOld.Phase__c == 'Execute'){
                    execute.Actual_End_Date__c = DateTime.now();
                    string accumulatedTime = GeneralInformation.displayDifferencesforTimimg(execute.Actual_End_Date__c, draft.Actual_Start_Date__c) ;           
                    execute.Difference__c= accumulatedTime;
                    execute.Elapsed_Time__c  = GeneralInformation.displayDifferencesforTimimg(execute.Actual_End_Date__c, execute.Actual_Start_Date__c);                 
                }
                if(deicisionOld.Phase__c == 'Evaluate'){
                    evaluate.Actual_End_Date__c = DateTime.now();
                    evaluate.Elapsed_Time__c  = GeneralInformation.displayDifferencesforTimimg(evaluate.Actual_End_Date__c, evaluate.Actual_Start_Date__c); 
                }
                close.Actual_Start_Date__c = DateTime.now();
                close.Actual_End_Date__c = DateTime.now();
                close.Elapsed_Time__c  = GeneralInformation.displayDifferencesforTimimg(close.Actual_End_Date__c, close.Actual_Start_Date__c); 
               close.Difference__c  = GeneralInformation.displayDifferencesforTimimg(close.Actual_End_Date__c, draft.Actual_Start_Date__c); 

                if(evaluate.Elapsed_Time__c != 'N/A'){
                    evaluate.Elapsed_Time__c  = GeneralInformation.displayDifferencesforTimimg(evaluate.Actual_End_Date__c, evaluate.Actual_Start_Date__c); 
                    string accumulatedTime = GeneralInformation.displayDifferencesforTimimg(close.Actual_Start_Date__c, draft.Actual_Start_Date__c) ;            
                    evaluate.Difference__c= accumulatedTime; 
                }   
            }
                
            if(deicision.Phase__c == 'Share' && deicisionOld.Phase__c != 'Draft') {
                
                share.Actual_Start_Date__c = DateTime.now();
                share.Actual_End_Date__c = null;
                share.End_Date_Time__c = null;
                share.Elapsed_Time__c = 'N/A';
                share.Difference__c      = 'N/A';
               
                decide.Actual_Start_Date__c = null;
                decide.Actual_End_Date__c = null;
                decide.Start_Date_Time__c = null;
                decide.End_Date_Time__c = null;
                decide.Elapsed_Time__c = 'N/A';
                decide.Difference__c      = 'N/A';
                
                approve.Actual_Start_Date__c = null;
                approve.Actual_End_Date__c = null;
                approve.Start_Date_Time__c = null;
                approve.End_Date_Time__c = null;
                approve.Elapsed_Time__c = 'N/A';
                approve.Difference__c      = 'N/A';
                
                
                execute.Actual_Start_Date__c = null;
                execute.Actual_End_Date__c = null;
                execute.Start_Date_Time__c = null;
                execute.End_Date_Time__c = null;
                execute.Elapsed_Time__c = 'N/A';
                execute.Difference__c      = 'N/A';
               
                evaluate.Actual_Start_Date__c = null;
                evaluate.Actual_End_Date__c = null;
                evaluate.Start_Date_Time__c = null;
                evaluate.End_Date_Time__c = null;
                evaluate.Elapsed_Time__c = 'N/A';
                evaluate.Difference__c      = 'N/A';
                
                close.Actual_End_Date__c = null;
                close.Actual_Start_Date__c = null;
                close.Start_Date_Time__c = null;
                close.End_Date_Time__c = null;
                close.Elapsed_Time__c = 'N/A';
                close.Difference__c      = 'N/A';
                
            } 
            if( deicision.Phase__c == 'Execute' && deicisionOld.Phase__c != 'Decide') {
                execute.Actual_Start_Date__c = DateTime.now();
                execute.Actual_End_Date__c = null;
                execute.End_Date_Time__c = null;
                execute.Elapsed_Time__c = 'N/A';
                execute.Difference__c = 'N/A';
               
                evaluate.Actual_Start_Date__c = null;
                evaluate.Actual_End_Date__c = null;
                evaluate.Start_Date_Time__c = null;
                evaluate.End_Date_Time__c = null;
                evaluate.Elapsed_Time__c = 'N/A';
                evaluate.Difference__c = 'N/A';                
               
                close.Actual_End_Date__c = null;
                close.Actual_Start_Date__c = null;
                close.Start_Date_Time__c = null;
                close.End_Date_Time__c = null;
                close.Elapsed_Time__c = 'N/A';
                close.Difference__c = 'N/A';                           
            }
            
            tobeUpdatedTimingList.add(draft);
            tobeUpdatedTimingList.add(share);
            tobeUpdatedTimingList.add(decide);
            tobeUpdatedTimingList.add(approve);
            tobeUpdatedTimingList.add(execute);
            tobeUpdatedTimingList.add(evaluate);
            tobeUpdatedTimingList.add(close);
        }
        
        if(tobeUpdatedTimingList.size() > 0) {
            update tobeUpdatedTimingList;
        }
        
        // Update Social Input  
        if(toBeUpdatedSocialInputForHistory.size() > 0) {
            update toBeUpdatedSocialInputForHistory;
        }
        
    }
    
    
    // update relation records
    if(!decisioMapTileUpdated.isEmpty()) {
        
        List<Relations__c> toBeUpdateRelations = new List<Relations__c>();
        for(Relations__c r : [Select r.OwnerId, r.id, r.Parent_Record_Name__c, r.Parent_ID__c,r.Child_Record_Name__c, r.Child_ID__c From Relations__c r where  r.Parent_ID__c =: decisioMapTileUpdated.keyset() or  r.Child_ID__c =: decisioMapTileUpdated.keyset() ]){
            if(decisioMapTileUpdated.containsKey(r.Parent_ID__c)) {
                r.Parent_Record_Name__c = decisioMapTileUpdated.get(r.Parent_ID__c).Title__c;
            }
            else {
                r.Child_Record_Name__c = decisioMapTileUpdated.get(r.Child_ID__c).Title__c;
            }
            toBeUpdateRelations.add(r);
        }
        
        // update relation records
        if(toBeUpdateRelations.size() > 0) {
            update toBeUpdateRelations;
        }
    }
    
    
    
    // unfollow decision with user when phase become close
    // remove all approval process (recall approval process)
    if(decisionIdToBeClose.size() > 0) {
        
        
        
        map<Id,Social_Input__c> socialInputMap = new map<Id,Social_Input__c>([select id, Role_Acceptance_Status__c from Social_Input__c where Decision__c In:decisionIdToBeClose ]);
        
                
        if(socialInputMap.size() > 0 ) {
            for(ProcessInstanceWorkitem p: [select Id,ProcessInstance.TargetObjectId from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId in: socialInputMap.keySet()]) {
                System.debug( 'APPROVE5');

                Approval.ProcessWorkItemRequest pwr = new Approval.ProcessWorkItemRequest();
                pwr.setWorkitemId(p.id);
                pwr.setComments('This decision approval has been recalled');
                pwr.setAction('Removed'); 
                Approval.ProcessResult pr = Approval.process(pwr);
            }
        }
        
        // unfollow the decision 
        delete [select id from EntitySubscription where parentId In: decisionIdToBeClose]; 
    }
    
    
    // insert decision share records 
    if(decisionShareToBeInsertList.size() > 0) {
        insert decisionShareToBeInsertList;
    }
    
    
    // insert entity subscription records
    if(followEntitySubscriptionToBeInsertList.size() > 0) {
        insert followEntitySubscriptionToBeInsertList;
    }
    
    // insert chatter feed
    if(toBePostedOnDecision.size() > 0) {
        insert toBePostedOnDecision;
    }
    
    
    // role acceptance approval rules
    //Integer.valueOf(roleAcceptanceApprovalList);
    List<Approval.ProcessResult> roleAcceptanceProcessResultList = Approval.process(roleAcceptanceApprovalList);
    
    for(Approval.ProcessResult r: roleAcceptanceProcessResultList) {
        System.assert(r.isSuccess());
    }
     
}