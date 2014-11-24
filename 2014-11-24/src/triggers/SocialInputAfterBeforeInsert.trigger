/*
Created by: Piyush Parmar
Modified by : Piyush Parmar
Description:
1) When new Social input  is create add sharing rule on parent object, follow the parent records and execute approval process 
2) Delete SIN post when social input record is created [Future method].
*/

trigger SocialInputAfterBeforeInsert on Social_Input__c (  before insert,after insert) {
  
    // initialize decision object 
    List<Decision__Share> decisionShareToBeInsertList = new List<Decision__Share>();
    
    // initialize follow (entiti subscription) object 
    List<EntitySubscription> followEntitySubscriptionToBeInsertList= new List<EntitySubscription> ();
    
    // initialize decision id set 
    set<Id> decisionId = new set<Id>();
     
     // role acceptance approval rules
    List<Approval.ProcessSubmitRequest>  roleAcceptanceApprovalList = new List<Approval.ProcessSubmitRequest>();
    
    
    // initialize plan id set
    set<Id> planId = new set<Id>();
    
    // initialize plan object 
    List<Plan__Share> planShareToBeInsertList = new List<Plan__Share>();
    
    
    // initialize user set for count how many records followed ?
    set<Id> userIdToBeFollwed = new set<Id>();
    map<Id,Integer> userFollwedmap = new map<Id,Integer>();
    
    map<id,Boolean> userActivity = new map<Id,Boolean>();
    // initializ e to be apply action on records
    // create set of recoords and mapping etc..
    
    //declare variables for Feed Comment
     Map<Id,Id> SocialfeedIdMap = new Map<Id,Id>();
     Set<Id>  userIdSet = new Set<Id>();
     Set<Id>  decisionIdForCommentSet = new Set<Id>();
     Set<Id> socialInputpostIdSet = new Set<Id>();
     Map<id,String > postTextMap = new Map<id,String>() ;
            
        for(Social_Input__c socialInput : Trigger.New) {
            if(Trigger.isAfter) {
                if(socialInput.Decision__c != null) {
                    decisionId.add(socialInput.Decision__c);
                }
                if(socialInput.Plan__c != null) {
                    planId.add(socialInput.Plan__c);
                }
                
                // initialize user set for count how many records followed ?
                userIdToBeFollwed.add(socialInput.User__c);
               
            }
            if(Trigger.isBefore) {
                if(!socialInput.Role_Acceptance_Required__c) {
                    socialInput.Role_Acceptance_Status__c ='Approved/Accepted';
                }
            }
        }
        
        // User activity map
        for(User u: [Select id,IsActive from User where id != null]){
            userActivity.put(u.id,u.IsActive);  
        }
        
        map<Id, Decision__c> decisionIdMap;
        
        if(decisionId.size() > 0){
           decisionIdMap = new map<Id, Decision__c>([select id,FeedItem_Id__c,Problem_Idea_Advice__c ,Phase__c,SYS_From_Quick_Decision__c,Approved_when_Created__c, ownerId,owner.Name, Status__c,FeedItem_Id_Propose__c,FeedItem_Id_Execute__c,FeedItem_Id_Evaluate__c  from Decision__c where Id In: decisionId]); 
        }
        
        // mapping to check user is aleady share with decision or not
        map<Id, set<Id>> decisionUserGrpMap = new map<Id, set<Id>>();
        
        List<Decision__Share> decisionShareList = new List<Decision__Share>();
        
        if(decisionId.size() > 0) {
            decisionShareList = [select id, UserOrGroupId, ParentId from Decision__Share where ParentId In: decisionId ];
        }
        System.debug('------decisionShareList-------->'+decisionShareList);
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
        
        if(decisionId.size() > 0) {
            entitySubscriptionList = [select id, parentId, subscriberid from EntitySubscription where ParentId In: decisionId];
        } 
        
        for(EntitySubscription es : entitySubscriptionList) {
            set<Id> usrGrpId = followDecisionUserGrpMap.get(es.ParentId);
            if(usrGrpId == null) {
                usrGrpId = new set<Id>();
                followDecisionUserGrpMap.put(es.ParentId,usrGrpId );
            }
            usrGrpId.add(es.subscriberid);
        }
        
        
        // mapping to check user is aleady share with plan or not
        map<Id, set<Id>> planUserGrpMap = new map<Id, set<Id>>();
        
        List<Plan__Share> planShareList = new List<Plan__Share>();
        
        if(planId.size() > 0) {
            planShareList = [select id, UserOrGroupId, ParentId from Plan__Share where ParentId In: planId ];
        }
        
        for(Plan__Share ps : planShareList) {
            set<Id> usrGrpId = planUserGrpMap.get(ps.ParentId);
            if(usrGrpId == null) {
                usrGrpId = new set<Id>();
                planUserGrpMap.put(ps.ParentId,usrGrpId );
            }
            usrGrpId.add(ps.UserOrGroupId);
        }
        
        // mapping to check user is aleady follow  the decision or not
        map<Id, set<Id>> followPlanUserGrpMap = new map<Id, set<Id>>();
        
        List<EntitySubscription> entitySubscriptionPlanList = new List<EntitySubscription>();
        
        if(planId.size() > 0) {
            entitySubscriptionPlanList = [select id, parentId, subscriberid from EntitySubscription where ParentId In: planId];
        } 
        
        for(EntitySubscription es : entitySubscriptionPlanList) {
            set<Id> usrGrpId = followPlanUserGrpMap.get(es.ParentId);
            if(usrGrpId == null) {
                usrGrpId = new set<Id>();
                followPlanUserGrpMap.put(es.ParentId,usrGrpId );
            }
            usrGrpId.add(es.subscriberid);
        }
        
        
        //  **** Create map for user and user follwed map **** 
        if(userIdToBeFollwed.size() > 0) {
            for(AggregateResult aggregateResult:  [select count(id), subscriberid from EntitySubscription where subscriberid In: userIdToBeFollwed  group by subscriberid]) {
                userFollwedmap.put((Id)aggregateResult.get('subscriberid'), (Integer)aggregateResult.get('expr0') );
            }
        }
        //
        
        set<Id> setSocialInputIds = new set<Id>();
        
        // apply all action on records
        for(Social_Input__c socialInput : Trigger.New) {
            
            if(Trigger.isAfter) {
            
                
                setSocialInputIds.add(socialInput.Id); // Collecting all the social input Id to pass it in a future method to delete SIN feeds
                if(socialInput.Decision__c != null) {
                    
                    Decision__c decision = new Decision__c();
                    decision = decisionIdMap.get(socialInput.Decision__c);
                    // This for chatter feed comment for different phase
                    if((decision.Phase__c == 'Propose' || decision.Phase__c == 'Decide' || decision.Phase__c == 'Share'|| decision.Phase__c == 'Execute' || decision.Phase__c == 'Evaluate' ) && (decision.FeedItem_Id__c != Null) )
                    {
                         String unitPost;
                         String postText;
                         Id decisionIdFormap = decision.Id;
                         if(socialInput.Is_Group__c != true ){
                             socialInputpostIdSet.add(socialInput.Id);
                         }
                         if(decision.Phase__c == 'Share' ){
                             SocialfeedIdMap.put(socialInput.Id,decision.FeedItem_Id__c);
                         }
                         else if(decision.Phase__c == 'Propose' ){
                             SocialfeedIdMap.put(socialInput.Id,decision.FeedItem_Id_Propose__c);
                         }
                         else if(decision.Phase__c == 'Execute' ){
                            id feedItemId =decision.FeedItem_Id_Execute__c;
                            if(decision.FeedItem_Id_Execute__c==null || decision.FeedItem_Id_Execute__c.trim()==''){
                                
                                Id userId=decision.ownerid;
                                String postTextCreate='The decision is good to go, let’s Execute!'+'\n';
                                id feedItemExecuteId =DecisionView.mentionTextPostPropose( userId, postTextCreate, decision.Id);
                                feedItemId = feedItemExecuteId;
                            }
                            
                             SocialfeedIdMap.put(socialInput.Id,feedItemId);
                         }
                         else if(decision.Phase__c == 'Evaluate' ){
                            id feedItemId =decision.FeedItem_Id_Evaluate__c;
                            if(decision.FeedItem_Id_Evaluate__c==null || decision.FeedItem_Id_Evaluate__c .trim()==''){
                                
                                Id userId=decision.ownerid;
                                String postTextCreate='How would you Evaluate the Outcome of this decision?'+'\n'+'Share your opinion and rate the overall result and effort!'+'\n'+'\n'+'(tip: it’s done from the Command Center)'+'\n';
                                id feedItemEvaluateId =DecisionView.mentionTextPostPropose( userId, postTextCreate, decision.Id);
                                feedItemId = feedItemEvaluateId;
                            }
                             SocialfeedIdMap.put(socialInput.Id,feedItemId);
                         }
                        // feedIdSet.add(decision.FeedItem_Id__c);
                         userIdSet.add(decisionIdMap.get(socialInput.Decision__c).ownerid);
                         decisionIdForCommentSet.add(decision.Id);
                         
                         
                         
                        String usrName = decisionIdMap.get(socialInput.Decision__c).owner.Name ;
                
                        if(decisionIdMap.get(socialInput.Decision__c).Problem_Idea_Advice__c.length() > 3500){
                             unitPost = decisionIdMap.get(socialInput.Decision__c).Problem_Idea_Advice__c.substring(0,3500);
                             unitPost += '... Readmore in Fingertip';
                        }else{
                             unitPost = decisionIdMap.get(socialInput.Decision__c).Problem_Idea_Advice__c;
                        }
                        
                        // postText='This decision has been shared with you.'+'\n'+'\n'+usrName+' '+'needs now your active collaboration';
                        postText ='';
                        if(decision.Phase__c == 'Share'){
                            // postText='You have been added to the Decision.'+'\n'+'\n'+usrName+' '+'needs your active collaboration';
                            postText='I added you to the Decision, Let’s collaborate!'+'\n'; 
                        }
                        else if(decision.Phase__c == 'Propose'){
                             postText='I need your Stance for this decision!'+'\n'+'Read the proposal and give your stance.'+'\n'+'\n'+'(hint: it’s done in the command center)';
                        }
                        // added on 1-5-2014
                        else if(decision.Phase__c == 'Execute'){
                             postText='We need you for the Execution. Come on let’s do this!'+'\n';
                        }else if(decision.Phase__c == 'Evaluate' ){
                            postText ='How would you Evaluate the Outcome of this decision?'+'\n'+'Share your opinion and rate the overall result and effort!'+'\n'+'\n'+'(tip: it’s done from the Command Center)'+'\n';

                        }
                        //System.debug('mentionTextPost'+postText+'userId'+userId+'userId'+userId);
                        postTextMap.put(decisionIdFormap,postText);  
                     

                      
                    }
                    
                    if(decision.Phase__c != 'Draft' && decision.Phase__c != 'Close' ) {
                        
                        // This is to share the Decision record. with the user 
                        // get all user maped id 
                        set<Id> alreadySharedUserId = new set<Id>();
                        alreadySharedUserId = decisionUserGrpMap.get(socialInput.Decision__c);
                        System.debug('----------alreadySharedUserId---------->'+alreadySharedUserId);
                        System.debug('----------socialInput.User__c---------->'+socialInput.User__c);
                        if(socialInput.User__c != null && userActivity.get(socialInput.User__c) == true) {
                            if(!alreadySharedUserId.contains(socialInput.User__c)) {
                                
                                Decision__Share decisionShare = new Decision__Share();
                                decisionShare.ParentId = socialInput.Decision__c; 
                                decisionShare.UserOrGroupId = socialInput.User__c;
                                if(socialInput.Responsible__c == true  || socialInput.Backup_for_Accountable__c || socialInput.Veto_Rights__c) {
                                    decisionShare.AccessLevel = 'Edit';
                                }
                                else {
                                    decisionShare.AccessLevel = 'Read';
                                }
                                decisionShareToBeInsertList.add(decisionShare);
                                System.debug('----------decisionShareToBeInsertList---------->'+decisionShareToBeInsertList);
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
                        if(socialInput.User__c != null && userActivity.get(socialInput.User__c) == true) {
                            if(followDecisionUserGrpMap.get(socialInput.Decision__c) != null) {
                                set<Id> alreadyFollowedUserId = followDecisionUserGrpMap.get(socialInput.Decision__c);
                            
                                if(alreadyFollowedUserId.size() > 0) {
                                    if(!alreadyFollowedUserId.contains(socialInput.User__c)) {
                                        
                                      //  if(userFollwedmap.get(socialInput.User__c) < 6) {
                                            EntitySubscription follow = new EntitySubscription ();
                                            follow.parentId = socialInput.Decision__c;
                                            follow.subscriberid = socialInput.User__c;
                                            followEntitySubscriptionToBeInsertList.add(follow);
                                    //    }
                                    }
                                } 
                            }// EO map null condition
                            else {
                                //if(userFollwedmap.get(socialInput.User__c) < 6) {
                                    EntitySubscription follow = new EntitySubscription ();
                                    follow.parentId = socialInput.Decision__c;
                                    follow.subscriberid = socialInput.User__c;
                                    followEntitySubscriptionToBeInsertList.add(follow);
                                //}
                            }
                        }
                        
                        
                    } // EOIF decision phase check condition 
                    
                    System.debug('+++++++++++++++++++++++++++'+socialInput.Role_Acceptance_Required__c);
                    // When collab is added on Propose phase (Final decision approval should be sent) on share phase (Role acceptance approval should be sent) 
                    System.debug('-----decision.Approved_when_Created__c-------------'+decision.Approved_when_Created__c);
                    if(socialInput.User__c != null && userActivity.get(socialInput.User__c) == true) {
                        if((decision.Phase__c == 'Share' && socialInput.Role_Acceptance_Required__c )||  (decision.Phase__c == 'Propose'  && ( socialInput.Accountable__c || socialInput.Responsible__c || socialInput.Consulted__c || (socialInput.Informed__c && socialInput.Backup_for_Accountable__c))) || (decision.Status__c =='Approved' && decision.Approved_when_Created__c && decision.SYS_From_Quick_Decision__c  && decision.Phase__c !='Execute' && decision.Phase__c !='Evaluate' && !socialInput.Accountable__c && (socialInput.Responsible__c || socialInput.Consulted__c))) {
                            // role/ deicsion
                            System.debug('+++++++++++++++++++++++++++'+socialInput.Role_Acceptance_Required__c);
                            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                            req.setComments('Awaiting response.');
                            req.setObjectId(socialInput.id);
                            roleAcceptanceApprovalList.add(req);
                        
                        }
                    }
                    
                    
                } // EOIF decision null 
                
                if(socialInput.Plan__c != null) {
                    
                    // This is to share the plan record. with the user 
                    // get all user maped id 
                    set<Id> alreadySharedUserId = new set<Id>();
                    alreadySharedUserId = planUserGrpMap.get(socialInput.Plan__c);
                    
                    if(socialInput.User__c != null && userActivity.get(socialInput.User__c) == true) {
                        if(!alreadySharedUserId.contains(socialInput.User__c)) {
                            
                            Plan__Share planShare = new Plan__Share();
                            planShare.ParentId = socialInput.Plan__c;
                            planShare.UserOrGroupId = socialInput.User__c;
                            if(socialInput.Responsible__c == true  || socialInput.Backup_for_Accountable__c || socialInput.Veto_Rights__c) {
                                planShare.AccessLevel = 'Edit';
                            }
                            else {
                                planShare.AccessLevel = 'Read';
                            }
                            planShareToBeInsertList.add(planShare);
                            
                        }
                    }
                    else {
                        if(socialInput.Is_Group__c && socialInput.GroupId__c != null) {
                            Plan__Share planShare = new Plan__Share();
                            planShare.ParentId = socialInput.Plan__c;
                            planShare.UserOrGroupId = socialInput.GroupId__c;
                            planShare.AccessLevel = 'Read';
                            planShareToBeInsertList.add(planShare);
                        }
                    }
                    
                    
                    if(socialInput.User__c != null && userActivity.get(socialInput.User__c) == true) {
                        if(followPlanUserGrpMap.get(socialInput.Plan__c) != null) {
                            set<Id> alreadyFollowedUserId = followPlanUserGrpMap.get(socialInput.Plan__c);
                        
                            if(alreadyFollowedUserId.size() > 0) {
                                if(!alreadyFollowedUserId.contains(socialInput.User__c)) {
                                    
                                    EntitySubscription follow = new EntitySubscription ();
                                    follow.parentId = socialInput.Plan__c;
                                    follow.subscriberid = socialInput.User__c;
                                    followEntitySubscriptionToBeInsertList.add(follow);
                                
                                }
                            } 
                        }// EO map null condition
                        else {
                            EntitySubscription follow = new EntitySubscription ();
                            follow.parentId = socialInput.Plan__c;
                            follow.subscriberid = socialInput.User__c;
                            followEntitySubscriptionToBeInsertList.add(follow);
                        } // EO follow records condition
                    }
                }
            } // EOIF after trigger 
            
        } //  EOF  trigger new 
        
      	if(Trigger.isAfter){
      		RankingDatabaseDefination rdd = new RankingDatabaseDefination();
      		set<Id> resUserIds = new set<Id>();
      		set<Id> conUserIds = new set<Id>();
      		set<Id> infUserIds = new set<Id>();
      		for(Social_Input__c socialInput : Trigger.New) {
      			if(socialInput.Responsible__c){	
      				resUserIds.add(socialInput.User__c);
      			}
      			if(socialInput.Consulted__c){
      				conUserIds.add(socialInput.User__c);
      			}
      			if(socialInput.Informed__c && !socialInput.Is_Group__c){
      				infUserIds.add(socialInput.User__c);
      			}
      		}
      		if(!resUserIds.isEmpty()){	
      			RankingDatabaseDefination.addedAsRole(resUserIds,'responsible','');
      		} 
      		if(!conUserIds.isEmpty()){
      			RankingDatabaseDefination.addedAsRole(conUserIds,'consulted','');
      		}
      		if(!infUserIds.isEmpty()){
      			RankingDatabaseDefination.addedAsRole(infUserIds,'informed','');
      		}
      	}
      	
        // insert decision share records 
        if(decisionShareToBeInsertList.size() > 0) {
        	System.debug('-------decisionShareToBeInsertList-------->'+decisionShareToBeInsertList);
            insert decisionShareToBeInsertList;
        }
        
        // insert decision share records 
        if(planShareToBeInsertList.size() > 0) {
            insert planShareToBeInsertList;
        }
        
        // insert entity subscription records
        if(followEntitySubscriptionToBeInsertList.size() > 0) {
            insert followEntitySubscriptionToBeInsertList;
        }
        
        // role/ deicsion acceptance approval rules
        if(roleAcceptanceApprovalList.size() > 0) {
            List<Approval.ProcessResult> roleAcceptanceProcessResultList = Approval.process(roleAcceptanceApprovalList);
            
            for(Approval.ProcessResult r: roleAcceptanceProcessResultList) {
                System.assert(r.isSuccess());
            }
        }
        if(!setSocialInputIds.isEmpty()){
            // Future method to delete SIN feeds on chatter post
            FutureMethodController.deleteSINChatterFeeds(setSocialInputIds);
        }
   
   //**********************************************************************
        //call this method for chatter feed comment when collaborator will add *
        //**********************************************************************
         
         if(SocialfeedIdMap.size() > 0 && userIdSet.size() > 0 && postTextMap.size() > 0 && decisionIdForCommentSet.size() > 0 && socialInputpostIdSet.size() > 0){
           System.debug('XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');
            ChatterFeedCommentOrPost.mentionTextPostForComment(SocialfeedIdMap, userIdSet, postTextMap, decisionIdForCommentSet,socialInputpostIdSet,false);
         }
                    
}