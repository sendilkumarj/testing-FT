/*
    Created by: Phaniraj
    Modifiedby: Piyush
    Style: Metro & Force.com
    Description:
    The social record for Decision keeps track total count and avg count of Errots, Results, Likes, Dislikes,moods,ratings. 
    So when there is any kind of update done by the user in decision, then the values should be rolled up in social record.
    */
    
trigger SocialInputAfterBeforeUpdate on Social_Input__c (Before Update, After Update) {
    
    //declare variables for Feed Comment
     Map<Id,Id> SocialfeedIdMap = new Map<Id,Id>();
     Set<Id>  userIdSet = new Set<Id>();
     Set<Id>  decisionIdForCommentSet = new Set<Id>();
     Set<Id> socialInputpostIdSet = new Set<Id>();
     Map<id,String > postTextMap = new Map<id,String>() ;
    
    RankingDatabaseDefination rdd = new RankingDatabaseDefination();
    set<Id> resUserIds = new set<Id>();
    set<Id> resUserRemovedIds = new set<Id>();
  	set<Id> conUserIds = new set<Id>();
  	set<Id> conUserRemovedIds = new set<Id>();
  	set<Id> infUserIds = new set<Id>();
  	set<Id> infUserRemovedIds = new set<Id>();
 // integer.valueOf(CheckforRecrussion.isRTFUpdate);
  if( CheckforRecrussion.isRecrussion == false  ) 
  { 
         if( Trigger.isAfter) {
           CheckforRecrussion.isRecrussion =  true;
        }  
        
        
        set<Id> SIds = new set<Id>(); 
       
        // initialize decision object for account swap 
        set<Id> socialInputOwnerSwapId = new set<Id>();
        
        // initialize decision object for account swap   ************* //
        
        set<Id> decisionOwnerSwapId = new set<Id>();
        List<Decision__c> tobeUpdatedDecisionOwnerList = new List<Decision__c>();
        List<Decision__Share> toBeUpdatedDecisionShareList = new List<Decision__Share>();
        List<Decision__Share> toBeInsertedDecisionShareList = new List<Decision__Share>();
        
        // initialize plan object for account swap     ************* ///
        List<Plan__c> tobeUpdatedPlanOwnerList = new List<Plan__c>();
        set<Id> planOwnerSwapId = new set<Id>();
        List<Plan__Share> toBeUpdatedPlanShareList = new List<Plan__Share>();
        List<Plan__Share> toBeInsertedPlanShareList = new List<Plan__Share>();
        
        List<Social_Input__c> tobeUpdateSocialInput = new List<Social_Input__c>();
        
        // to be updated socialInput role acceptance for accountable after role swapping
        //Set<Id> tobeUpdateSocialInputForAccAfterRoleSwapping = new set<Id>();
        
        // Approval process execution
        List<Decision__c> tobeUpdatedDecisionApprovalList = new List<Decision__c>(); 
        set<Id> tobeApprovedSocialInputId = new set<Id>();
        set<Id> tobeUpdatedDecisionApprovalId = new set<Id>();
        
        List<Approval.ProcessSubmitRequest>  roleAcceptanceApprovalList = new List<Approval.ProcessSubmitRequest>();
        
        set<Id> toBeupdatedDecisionOwnerId = new set<Id>(); 
        set<Id> toBeupdatedPlanOwnerId = new set<Id>(); 
        
        map<id,Boolean> userActivity = new map<Id,Boolean>();
        
        // initialize socialInputIdTobeRecallAproval
        // approval has been recalled
        set<Id> socialInputIdTobeRecallAproval = new set<Id>(); 
        
        for(Social_Input__c socialInput : trigger.new){
            if(Trigger.isBefore) {
                if(!socialInput.Role_Acceptance_Required__c) {
                    socialInput.Role_Acceptance_Status__c ='Approved/Accepted';
                }
            }
            if(trigger.isAfter){
                Social_Input__c socialinputOld = System.Trigger.oldMap.get(socialInput.Id);
                if(socialInput.Decision__c != null && ((socialInput.Like__c != socialinputOld.Like__c) || (socialInput.Dislike__c != socialinputOld.Dislike__c) || (socialInput.Mood__c != socialinputOld.Mood__c) || (socialInput.Effort__c != socialinputOld.Effort__c) || (socialInput.Result__c != socialinputOld.Result__c) || (socialInput.Rating__c != socialinputOld.Rating__c))){
                    SIds.add(socialInput.Decision__c);
                }
                
                // Account is changed thn change the owner of the parent records (Decision/plan)
                //if((socialInput.Accountable__c != socialinputOld.Accountable__c) || (socialInput.Responsible__c != socialinputOld.Responsible__c) || (socialInput.Consulted__c != socialinputOld.Consulted__c) || (socialInput.Informed__c != socialinputOld.Informed__c) || (socialInput.Veto_Rights__c != socialinputOld.Veto_Rights__c)|| (socialInput.Backup_for_Accountable__c != socialinputOld.Backup_for_Accountable__c)) {
                if(socialInput.Decision__c != null) {
                    decisionOwnerSwapId.add(socialInput.Decision__c);
                }
                if(socialInput.Plan__c != null) {
                    planOwnerSwapId.add(socialInput.Plan__c);
                }
             //   }
                
                // Social input approval process
                if(  (  ( socialInput.Final_Approval_Status__c == 'Approved' || socialInput.Final_Approval_Status__c == 'Rejected') || ( socialInput.Veto_Rights__c &&  socialInput.Stance_Approval_Status__c == 'Rejected' ) )&& (  (   socialInput.Veto_Rights__c && ( ( socialinputOld.Stance_Approval_Status__c != socialInput.Stance_Approval_Status__c ) || ( socialinputOld.Final_Approval_Status__c != socialInput.Final_Approval_Status__c ) ) ) || (  !socialInput.Veto_Rights__c && ( socialinputOld.Final_Approval_Status__c != socialInput.Final_Approval_Status__c ) )  ) ) {
                    System.debug('---------------------final approval process----------------------');
                   
                    tobeApprovedSocialInputId.add(socialInput.Id);
                    tobeUpdatedDecisionApprovalId.add(socialInput.Decision__c);
                }
            
            }
        }
    
        map<Id,Double> TotalLikesMap = new map <Id,Double>();
        map<Id,Double> TotalDisLikesMap = new map <Id,Double>(); 
        
        map<Id,Double> TotalMoodMap = new map <Id,Double>();
        map<Id,Double> SumMoodMap = new map <Id,Double>();
        
        map<Id,Double> TotalEffortMap = new map <Id,Double>();
        map<Id,Double> SumEffortMap = new map <Id,Double>();
        
        map<Id,Double> TotalResultMap = new map <Id,Double>(); 
        map<Id,Double> SumResultMap = new map <Id,Double>();
        
        map<Id,Double> TotalRatingsMap = new map <Id,Double>();
        map<Id,Double> SumRatingsMap = new map <Id,Double>();
        
        If(SIds.size()>0)  {
            for(AggregateResult q :[select sum(Like__c),sum(Dislike__c),Count(Mood__c),Sum(Mood__c), Count(Effort__c), Sum(Effort__c), Count(Result__c), Sum(Result__c),Count(Rating__c),Sum(Rating__c),Decision__c from Social_Input__c where Decision__c IN :SIds group by Decision__c]){
                System.debug('--------------->total counts'+(Double)q.get('expr0')+'------------->'+(Double)q.get('expr1'));
                TotalLikesMap.put((Id)q.get('Decision__c'),(Double)q.get('expr0'));
                TotalDisLikesMap.put((Id)q.get('Decision__c'),(Double)q.get('expr1'));
                TotalMoodMap.put((Id)q.get('Decision__c'),(Double)q.get('expr3'));
                SumMoodMap.put((Id)q.get('Decision__c'),(Double)q.get('expr2'));
                TotalEffortMap.put((Id)q.get('Decision__c'),(Double)q.get('expr5'));
                SumEffortMap.put((Id)q.get('Decision__c'),(Double)q.get('expr4'));
                TotalResultMap.put((Id)q.get('Decision__c'),(Double)q.get('expr7'));
                SumResultMap.put((Id)q.get('Decision__c'),(Double)q.get('expr6'));
                TotalRatingsMap.put((Id)q.get('Decision__c'),(Double)q.get('expr9'));
                SumRatingsMap.put((Id)q.get('Decision__c'),(Double)q.get('expr8'));
            }    
        }
        
        If(SIds.size()>0)  {    
            List<Social__c> socialRecords = [select id,Related_To_ID__c,Effort_Count__c,Mood_Count__c,Rating_Count__c,Result_Count__c,Total_Effort__c,Total_Likes__c,Total_Mood__c, Total_Rating__c,Total_Result__c from Social__c where Related_To_ID__c IN :SIds];
            for(Social__c rec:socialRecords){
                rec.Total_Likes__c = TotalLikesMap.get(rec.Related_To_ID__c);
                rec.Total_Dislikes__c = TotalDisLikesMap.get(rec.Related_To_ID__c);
                rec.Total_Mood__c = TotalMoodMap.get(rec.Related_To_ID__c);
                rec.Mood_count__c = SumMoodMap.get(rec.Related_To_ID__c);
                 //Added to track avrage value
                rec.Average_Mood__c =  rec.Related_To_ID__c != null && TotalMoodMap != null && SumMoodMap != null && TotalMoodMap.get(rec.Related_To_ID__c) != null && SumMoodMap.get(rec.Related_To_ID__c) != null ? Decimal.valueOf(TotalMoodMap.get(rec.Related_To_ID__c) / SumMoodMap.get(rec.Related_To_ID__c)).setScale(2) : 0.00;
                rec.Total_Effort__c = TotalEffortMap.get(rec.Related_To_ID__c);
                rec.Effort_count__c = SumEffortMap.get(rec.Related_To_ID__c);
                rec.Total_Result__c = TotalResultMap.get(rec.Related_To_ID__c);
                rec.Result_Count__c = SumResultMap.get(rec.Related_To_ID__c);
                rec.Total_Rating__c = TotalRatingsMap.get(rec.Related_To_ID__c);
                rec.Rating_Count__c = SumRatingsMap.get(rec.Related_To_ID__c);
            } 
            update socialRecords;
        }        
        
        // User activity map
        for(User u: [Select id,IsActive from User where id != null]){
            userActivity.put(u.id,u.IsActive);  
        }
        
        // **** Decision Shaare map **** ///
        // mapping to check user is aleady share with decision or not
        map<Id, List<Decision__Share>> decisionSharedMap = new map<Id, List<Decision__Share>>();
        
        // Create sharing map for decision
        map<Id, Decision__c> decisionIdMap;
        if(decisionOwnerSwapId.size() > 0) {
        
            decisionIdMap = new map<id,Decision__c>([select id,FeedItem_Id__c,FeedItem_Id_Evaluate__c ,Problem_Idea_Advice__c ,Phase__c,SYS_From_Quick_Decision__c,Approved_when_Created__c, ownerId,owner.Name, Status__c,FeedItem_Id_Propose__c,FeedItem_Id_Execute__c  from Decision__c where Id In: decisionOwnerSwapId]);
        }
        
         
        // **** Plan Shaare map **** ///
        // mapping to check user is aleady share with plan or not
        
        // Create sharing map for plan
        map<Id, Plan__c> planIdMap;
        if(planOwnerSwapId.size() > 0) {
            
            planIdMap = new map<id,Plan__c>([select id, OwnerId from Plan__c where Id In: planOwnerSwapId]);
            
        }
        
        // ********** Do action *********** //
        
        for(Social_Input__c socialInput : trigger.new){
            if(trigger.isAfter){    
                Social_Input__c socialinputOld = System.Trigger.oldMap.get(socialInput.Id);
            
                if(socialInput.Decision__c != null) {
                    Decision__c decision = decisionIdMap.get(socialInput.Decision__c);
                    // sharing rules apply if phase is not close or draft 
                    if(decision.Phase__c != 'Draft' && decision.Phase__c != 'Close' ) {
                         if(socialInput.User__c != null && userActivity.get(socialInput.User__c) == true ) {
                            
                             if((socialInput.Accountable__c != socialinputOld.Accountable__c) || (socialInput.Responsible__c != socialinputOld.Responsible__c) || (socialInput.Consulted__c != socialinputOld.Consulted__c) || (socialInput.Informed__c != socialinputOld.Informed__c) || (socialInput.Veto_Rights__c != socialinputOld.Veto_Rights__c)|| (socialInput.Backup_for_Accountable__c != socialinputOld.Backup_for_Accountable__c)) {
                                    Decision__Share decisionShare = new Decision__Share();
                                    decisionShare.ParentId = socialInput.Decision__c;
                                    decisionShare.UserOrGroupId = socialInput.User__c;
                                    if(socialInput.Responsible__c == true  || socialInput.Backup_for_Accountable__c || socialInput.Veto_Rights__c) {
                                      decisionShare.AccessLevel = 'Edit';
                                    }
                                    else {
                                        decisionShare.AccessLevel = 'Read';
                                    }
                                    
                                    toBeInsertedDecisionShareList.add(decisionShare);
                                    
                                    // change owner of decision objet
                                    if(socialInput.Accountable__c && socialinputOld.Accountable__c != socialInput.Accountable__c) {
                                        decision.OwnerId = socialInput.User__c;
                                        tobeUpdatedDecisionOwnerList.add(decision);
                                        toBeupdatedDecisionOwnerId.add(decision.Id);
                                    }
                             }
                             
                             //for veto chatter post 
                             /* also can use for role swapping */
                                 String unitPost;
                                 String postText;
                                 Id decisionIdFormap = decision.Id;
                                 if(socialInput.Is_Group__c != true && (socialInput.Veto_Rights__c == true && socialinputOld.Veto_Rights__c == false)){
                                     socialInputpostIdSet.add(socialInput.Id);
                                 }
                                 if(decision.Phase__c == 'Share' ){
                                     SocialfeedIdMap.put(socialInput.Id,decision.FeedItem_Id__c == '--'? null:decision.FeedItem_Id__c );
                                 }
                                 else if(decision.Phase__c == 'Propose' ){
                                     SocialfeedIdMap.put(socialInput.Id,decision.FeedItem_Id_Propose__c == '--'? null:decision.FeedItem_Id_Propose__c );
                                 }
                                 else if(decision.Phase__c == 'Execute' ){
                                     SocialfeedIdMap.put(socialInput.Id,decision.FeedItem_Id_Execute__c == '--'? null:decision.FeedItem_Id_Execute__c );
                                 }
                                 else if(decision.Phase__c == 'Evaluate' ){
                                     SocialfeedIdMap.put(socialInput.Id,decision.FeedItem_Id_Evaluate__c  == '--'? null:decision.FeedItem_Id_Evaluate__c  );
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
                                    //postText='I gave you'; 
                                }
                                else if(decision.Phase__c == 'Propose'){
                                     //postText='I need your Stance for this decision!'+'\n'+'Read the proposal and give your stance.'+'\n'+'\n'+'(hint: it’s done in the command center)';
                                }
                                else if(decision.Phase__c == 'Execute'){
                                    // postText='We need you for the Execution. Come on let’s do this!'+'\n';
                                }else if(decision.Phase__c == 'Evaluate' ){
                                    //postText='We have Executed the Decisoin and it is time to Evaluate its Outcome.'+'\n'+'Rate the overall Result and Effort put into the decision.'+'\n'+'\n'+'It would be great that you would share your key learning and take away from this decision. Put it as a comment!'+'\n'+'\n'+'(hint: it’s done in the command center)'+'\n';
                                }
                                //System.debug('mentionTextPost'+postText+'userId'+userId+'userId'+userId);
                                postTextMap.put(decisionIdFormap,postText);
                             
                             
                             
                         }
                        
                    } // EOF decision phases condition
                    
                    // Fire Mystance/Decision approval if any of the role has not been changed
                    if( ( ( socialinputOld.Consulted__c  == socialInput.Consulted__c  ) && ( socialinputOld.Responsible__c == socialInput.Responsible__c  ) && ( socialinputOld.informed__c == socialInput.informed__c ) && ( socialinputOld.Backup_for_Accountable__c == socialInput.Backup_for_Accountable__c ) && ( socialinputOld.Veto_Rights__c == socialInput.Veto_Rights__c  ) )  && decision.Phase__c == 'Propose' )
                    {  
                        if(socialInput.User__c != null &&  userActivity.get(socialInput.User__c) == true  ) {
                           
                            //Approval process for my stance when user accepts there role and when decision moves to propose phase an approval process will be sent to all the collaboraters.
                           if(decision.Phase__c == 'Propose' && socialInput.Role_Acceptance_Status__c == 'Approved/Accepted' && ( socialInput.Stance_Approval_Status__c == null || socialInput.Stance_Approval_Status__c == '' ) && ( socialInput.Final_Approval_Status__c  == null || socialInput.Final_Approval_Status__c == '' ) && ( ( socialInput.Accountable__c || socialInput.Responsible__c || socialInput.Consulted__c || socialInput.Backup_for_Accountable__c ) ||  ( socialInput.Informed__c && socialInput.Backup_for_Accountable__c ) ) ){ 
                                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                                req.setComments('Awaiting Response.');
                                req.setObjectId(socialInput.id);
                                roleAcceptanceApprovalList.add(req);
                           }
                           // Approval process for decision to be sent only for A, B, V after giving there my stance status in propose phase.
                           if( (socialInput.Accountable__c || socialInput.Backup_for_Accountable__c || socialInput.Veto_Rights__c ) && socialInput.Role_Acceptance_Status__c == 'Approved/Accepted' && ( socialInput.Stance_Approval_Status__c == 'Approved' || socialInput.Stance_Approval_Status__c == 'Rejected') && ( socialInput.Final_Approval_Status__c == null || socialInput.Final_Approval_Status__c == '' ) && decision.Phase__c == 'Propose' ) {
                                
                                // Send decision approval if not Veto or Veto and accepted Mystance
                                if(  ( !socialInput.Veto_Rights__c ) ||   ( ( socialInput.Accountable__c || socialInput.Backup_for_Accountable__c ) && (  socialInput.Stance_Approval_Status__c == 'Approved') ) ){
                                    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                                    req.setComments('Awaiting Response.');
                                    req.setObjectId(socialInput.id);
                                    roleAcceptanceApprovalList.add(req);
                                    
                                }                               
                           
                            }
                        }     
                      
                    }  
                    //if((decision.Phase__c == 'Share' && socialInput.Role_Acceptance_Required__c )||  (decision.Phase__c == 'Propose'  && ( socialInput.Accountable__c || socialInput.Responsible__c || socialInput.Consulted__c || (socialInput.Informed__c && socialInput.Backup_for_Accountable__c))) || (decision.Status__c =='Approved' && decision.Approved_when_Created__c && decision.SYS_From_Quick_Decision__c  && decision.Phase__c !='Execute' && decision.Phase__c !='Evaluate' && !socialInput.Accountable__c && (socialInput.Responsible__c || socialInput.Consulted__c))) {
                    if( decision.Phase__c == 'Share' && socialInput.Role_Acceptance_Required__c && socialinputOld.Role_Acceptance_Required__c == false ){
                        // role/ deicsion
                        if(socialInput.User__c != null &&  userActivity.get(socialInput.User__c) == true  ) {    
                            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                            req.setComments('Awaiting response.');
                            req.setObjectId(socialInput.id);
                            roleAcceptanceApprovalList.add(req);
                        }
                    }
                    
                    

                    // Fire Mystance/Decision approval if any of the role has  been changed
                    if( ( ( socialinputOld.Consulted__c  != socialInput.Consulted__c  ) || ( socialinputOld.Responsible__c != socialInput.Responsible__c  ) || ( socialinputOld.informed__c != socialInput.informed__c ) || ( socialinputOld.Backup_for_Accountable__c != socialInput.Backup_for_Accountable__c ) || ( socialinputOld.Veto_Rights__c != socialInput.Veto_Rights__c  ) )  && decision.Phase__c == 'Propose' )
                    {   
                        //if final approval is pending and backup/veto permission is removed then recall decision approval
                        if(  socialinput.Final_Approval_Status__c == 'Pending Approval'  )
                        {
                            
                            if( ( socialinputOld.Backup_for_Accountable__c  &&  !socialinput.Backup_for_Accountable__c   ) )
                            {                        
                             socialInputIdTobeRecallAproval.add(socialInput.Id);
                            }
                            
                        }
                        //if stance approval is pending and responsible and consulted and backup permission is removed then recall stance approval

                        if(  socialinput.Stance_Approval_Status__c == 'Pending Approval'  )
                        { 
                           
                             
                            if( !socialInput.Accountable__c && !socialInput.Responsible__c && !socialInput.Consulted__c &&  !socialInput.Backup_for_Accountable__c )
                            {
                             socialInputIdTobeRecallAproval.add(socialInput.Id);
                            } 
                        
                        }
                        //if role approval is done and stance approval is not done and made as consulted/responsible/backup fire mystance approval

                        if(  ( socialinput.Role_Acceptance_Status__c  == 'Approved/Accepted' ) &&  ( socialinput.Stance_Approval_Status__c  == '' || socialinput.Stance_Approval_Status__c  == null  )   )
                        { 
                           
                            if( ( (   socialInput.Consulted__c  ) || (   socialInput.Responsible__c  ) ||   (   socialInput.Backup_for_Accountable__c ) || (  socialInput.Veto_Rights__c  ) )  && decision.Phase__c == 'Propose' )
                            {
                                if(socialInput.User__c != null &&  userActivity.get(socialInput.User__c) == true  ) {
                                    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                                    req.setComments('Awaiting Response.');
                                    req.setObjectId(socialInput.id);
                                    roleAcceptanceApprovalList.add(req);
                                }
                            } 
                        
                        }
                        //if stance approval is done and final approval is not done and  backup/veto fire decision approval

                        if( ( socialinput.Stance_Approval_Status__c == 'Approved' ||  socialinput.Stance_Approval_Status__c == 'Rejected' ) &&  ( socialinput.Final_Approval_Status__c  == '' || socialinput.Final_Approval_Status__c  == null  )  )
                        { 
                        
                            if(   ( !socialinputOld.Backup_for_Accountable__c   &&   socialinput.Backup_for_Accountable__c )  &&  (  ( !socialInput.Veto_Rights__c ) || ( socialInput.Veto_Rights__c && ( socialinput.Stance_Approval_Status__c == 'Approved' ) ) )  ) 
                            {
                                if(socialInput.User__c != null &&  userActivity.get(socialInput.User__c) == true  ) {
                                    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                                    req.setComments('Awaiting Response.');
                                    req.setObjectId(socialInput.id);
                                    roleAcceptanceApprovalList.add(req);
                                }
                            } 
                        }
                       
                    }
                    
                    
                } 
                
                 
                // EOF decision object
                
                if(socialInput.Plan__c != null) {
                    if(socialInput.User__c != null && userActivity.get(socialInput.User__c) == true) {
                      if((socialInput.Accountable__c != socialinputOld.Accountable__c) || (socialInput.Responsible__c != socialinputOld.Responsible__c) || (socialInput.Consulted__c != socialinputOld.Consulted__c) || (socialInput.Informed__c != socialinputOld.Informed__c) || (socialInput.Veto_Rights__c != socialinputOld.Veto_Rights__c)|| (socialInput.Backup_for_Accountable__c != socialinputOld.Backup_for_Accountable__c)) {
                          Plan__c plan = planIdMap.get(socialInput.Plan__c);
                          Plan__Share planShare = new Plan__Share();
                          planShare.ParentId = socialInput.Plan__c;
                          planShare.UserOrGroupId = socialInput.User__c;
                          
                          if(socialInput.Responsible__c || socialInput.Backup_for_Accountable__c || socialInput.Veto_Rights__c) {
                              planShare.AccessLevel = 'Edit';
                          }
                          else {
                              planShare.AccessLevel = 'Read';
                          }
                          
                          toBeInsertedPlanShareList.add(planShare);
                          
                          // change owner of plan objet 
                          if(socialInput.Accountable__c && plan.OwnerId != socialInput.User__c  ) {
                              plan.OwnerId = socialInput.User__c;
                              tobeUpdatedPlanOwnerList.add(plan);
                              toBeupdatedPlanOwnerId.add(plan.Id);                   
                          }
                        
                      }
                    
                    }
                } // EOF plan object
                    
            } // EOF is after trigger 
            if((socialInput.Rating__c != null && socialInput.Mood__c != null && (socialInput.Like__c == 1.0 || socialInput.Dislike__c == 1.0) && Trigger.oldMap.get(socialInput.Id).Like__c == null && Trigger.oldMap.get(socialInput.Id).Dislike__c == null) || (Trigger.oldMap.get(socialInput.Id).Rating__c == null && socialInput.Rating__c != null && socialInput.Mood__c != null && socialInput.Dislike__c != null && socialInput.Like__c != null) || (socialInput.Rating__c != null && socialInput.Mood__c != null && Trigger.oldMap.get(socialInput.Id).Mood__c == null && socialInput.Dislike__c != null && socialInput.Like__c != null) ){
            	if(!CheckforRecrussion.isRdd){	
            		rdd.calculatePoints('Set all socials', '');
            		CheckforRecrussion.isRdd = true;
            	}
            }
            if(socialInput.Rating__c != null && socialInput.Mood__c != null && socialInput.Like__c != null && socialInput.Dislike__c != null && (socialInput.Rating__c != Trigger.oldMap.get(socialInput.Id).Rating__c || Trigger.oldMap.get(socialInput.Id).Mood__c != socialInput.Mood__c || Trigger.oldMap.get(socialInput.Id).Dislike__c != socialInput.Dislike__c || socialInput.Like__c != Trigger.oldMap.get(socialInput.Id).Like__c)){
            	if(!CheckforRecrussion.isRdd){	
            		rdd.calculatePoints('Change socials', '');
            		CheckforRecrussion.isRdd = true;
            	}
            }
            System.debug('-------socialInput.Rating__c--------->'+socialInput.Rating__c);
            System.debug('-------socialInput.Effort__c--------->'+socialInput.Effort__c);
            if((socialInput.Result__c != null && Trigger.oldMap.get(socialInput.Id).Effort__c == null && socialInput.Effort__c != null) || (socialInput.Effort__c != null && Trigger.oldMap.get(socialInput.Id).Result__c == null && socialInput.Result__c != null)){
            	if(!CheckforRecrussion.isRdd){
            		System.debug('-------Done--------->');
            		rdd.calculatePoints('Provide your evaluation to a decision', '');
            		CheckforRecrussion.isRdd = true;
            	}
            }
            if(socialInput.Responsible__c != Trigger.oldMap.get(socialInput.Id).Responsible__c && socialInput.Responsible__c == true && Trigger.oldMap.get(socialInput.Id).Responsible__c == false){
            	resUserIds.add(socialInput.User__c);
            }
            if(socialInput.Responsible__c != Trigger.oldMap.get(socialInput.Id).Responsible__c && socialInput.Responsible__c == false && Trigger.oldMap.get(socialInput.Id).Responsible__c == true){
            	resUserRemovedIds.add(socialInput.User__c);
            }
            if(socialInput.Consulted__c != Trigger.oldMap.get(socialInput.Id).Consulted__c && socialInput.Consulted__c == true && Trigger.oldMap.get(socialInput.Id).Consulted__c == false){
            	conUserIds.add(socialInput.User__c);
            }
            if(socialInput.Consulted__c != Trigger.oldMap.get(socialInput.Id).Consulted__c && socialInput.Consulted__c == false && Trigger.oldMap.get(socialInput.Id).Consulted__c == true){
            	conUserRemovedIds.add(socialInput.User__c);
            }
            if(socialInput.Informed__c != Trigger.oldMap.get(socialInput.Id).Informed__c && socialInput.Informed__c == true && Trigger.oldMap.get(socialInput.Id).Informed__c == false){
            	infUserIds.add(socialInput.User__c);
            }
            if(socialInput.Informed__c != Trigger.oldMap.get(socialInput.Id).Informed__c && socialInput.Informed__c == false && Trigger.oldMap.get(socialInput.Id).Informed__c == true){
            	infUserRemovedIds.add(socialInput.User__c);
            }
        } // EOF social input 
        
        
        // Approval process execution
           System.debug( tobeApprovedSocialInputId.size() );
        if(tobeApprovedSocialInputId.size() > 0 ) {
         
            System.debug(tobeUpdatedDecisionApprovalId);
            String decisionId;
            map<Id, Social_Input__c > socialInputToBeRecalledMap = new map<Id, Social_Input__c >([select  Backup_for_Accountable__c, Decision__c,Stance_Approval_Status__c , Final_Approval_Status__c from Social_Input__c where Decision__c =: tobeUpdatedDecisionApprovalId AND ( Backup_for_Accountable__c =: true OR Accountable__c =: true ) limit 2 ]);
            map<Id, Decision__c> decisionIdAprovalMap = new map<Id, Decision__c>([select id, OwnerId, Phase__c, Status__c, Reason_for_Close__c  from Decision__c where Id In: tobeUpdatedDecisionApprovalId]);
            for(Social_Input__c socialInput : [select Accountable__c,Responsible__c ,User__c,User__r.isActive, Veto_Rights__c, Backup_for_Accountable__c, Decision__c, Final_Approval_Status__c from Social_Input__c where id In: tobeApprovedSocialInputId]) {
                Decision__c decision = decisionIdAprovalMap.get(socialInput.Decision__c);
               
                decisionId = String.valueOf(decision.id);
                if(socialInput.User__c != null && socialInput.User__r.isActive) {
                   
                    if(socialInput.Accountable__c || socialInput.Backup_for_Accountable__c || socialInput.Veto_Rights__c) {
                        
                        if( ( socialInputToBeRecalledMap.get(socialInput.id) != null ) && (  socialInput.Veto_Rights__c == false )  )
                        {   
                            if( socialInputToBeRecalledMap.size() == 2 )
                            {
                                socialInputToBeRecalledMap.remove(socialInput.id);
                                for( Social_Input__c  socialInputToBeRecalled : socialInputToBeRecalledMap.values()){
                                    if(  socialInputToBeRecalled .Final_Approval_Status__c  == 'Pending Approval' )
                                         socialInputIdTobeRecallAproval.add( socialInputToBeRecalled.Id  );
                                }
                            }
                        }
                        if( (  socialInput.Veto_Rights__c == true ) ) 
                        { 
                           for( Social_Input__c  socialInputToBeRecalled : socialInputToBeRecalledMap.values()){
                                if(  socialInputToBeRecalled .Final_Approval_Status__c  == 'Pending Approval' )
                                     socialInputIdTobeRecallAproval.add( socialInputToBeRecalled.Id  );
                           }
                        
                        }
                        if(socialInput.Final_Approval_Status__c == 'Approved') {
    
                            if( socialInput.Accountable__c || (socialInput.Backup_for_Accountable__c)) {
                                if(decision.Status__c != 'Rejected') {
                                    decision.Status__c = 'Approved';
                                }
                                decision.Reason_for_close__c = 'Cancelled';
                                if(decision.Phase__c  == 'Propose') {
                                    decision.Phase__c = 'Decide';
                                }
                            }
                        }   
                        else {                          
    
                            if(socialInput.Accountable__c  || socialInput.Veto_Rights__c   ) {
                                if(decision.Phase__c == 'Propose') {
                                    decision.Phase__c = 'Decide';
                                }
                                decision.Status__c = 'Rejected';
                                decision.Reason_for_close__c = 'Rejected';
                            }
                            else  {
                                decision.Reason_for_close__c = 'Cancelled';
                                if(decision.Phase__c == 'Propose') {
                                    decision.Phase__c = 'Decide';
                                    decision.Status__c = 'Rejected';
                                }
                            }
                            
                        }
                    }
                }
                tobeUpdatedDecisionApprovalList.add(decision);
            
            } 
            
            // update decision approval phase
            if(tobeUpdatedDecisionApprovalList.size() > 0) {
                update tobeUpdatedDecisionApprovalList;
            }
            
        }
        
        
        // update  decision owner records 
        if(tobeUpdatedDecisionOwnerList.size() > 0) {
            update tobeUpdatedDecisionOwnerList;
        }
        List<Decision__Share> toBeUpsertedDecisionShareList = new List<Decision__Share>();
        
        map<Id, set<Id>> userDecisionMap = new map<Id, set<Id>>(); 
        for(Decision__Share ds: [select id, UserOrGroupId, ParentId from Decision__Share where ParentId In: decisionOwnerSwapId ]) {
            set<Id> useSet = userDecisionMap.get(ds.ParentId);
            if(useSet == null ) {
                useSet = new set<Id>();
                userDecisionMap.put(ds.ParentId, useSet);
            }
            useSet.add(ds.UserOrGroupId);
        }
        System.debug('-----userDecisionMap---------->'+userDecisionMap);
        map<Id,Decision__c> decisionUsrMap = new map<Id,Decision__c>([select Id, OwnerId from Decision__c where Id =: decisionOwnerSwapId]);
        
         
      for(Decision__Share ds: toBeInsertedDecisionShareList) {
          if(!toBeupdatedDecisionOwnerId.contains(ds.ParentId)) {
              if(userDecisionMap.get(ds.ParentId) != null && decisionUsrMap.get(ds.ParentId).OwnerId !=ds.UserOrGroupId ) {
                  if(!userDecisionMap.get(ds.ParentId).contains(ds.UserOrGroupId) ) {
                        toBeUpsertedDecisionShareList.add(ds);
                    }
                    toBeUpsertedDecisionShareList.add(ds);
                }
            }
      }
      
      for(Social_Input__c socialInput : [select Decision__c,User__r.isActive,User__c,Is_Group__c,GroupId__c,Responsible__c,Backup_for_Accountable__c, Veto_Rights__c, Informed__c,Consulted__c  from Social_Input__c where  Decision__c In: toBeupdatedDecisionOwnerId and Accountable__c = false]) {
          Decision__Share decisionShare = new Decision__Share();
          decisionShare.ParentId = socialInput.Decision__c;
          
          if(socialInput.User__c != null && socialInput.User__r.isActive) {
            decisionShare.UserOrGroupId = socialInput.User__c;
              if(socialInput.Responsible__c || socialInput.Backup_for_Accountable__c || socialInput.Veto_Rights__c) {
                decisionShare.AccessLevel = 'Edit';
              }
              else {
                  decisionShare.AccessLevel = 'Read';
              }
              toBeUpsertedDecisionShareList.add(decisionShare);
          }
          else {
            if(socialInput.Is_Group__c && socialInput.GroupId__c != null) {
                decisionShare.UserOrGroupId = socialInput.GroupId__c;
                decisionShare.AccessLevel = 'Read';
                toBeUpsertedDecisionShareList.add(decisionShare);
            }
          }
      }
       
      System.debug('=================toBeInsertedDecisionShareList==========='+toBeInsertedDecisionShareList);
        if(toBeUpsertedDecisionShareList.size() > 0) {
            System.debug('=================decisionSharedMap==========='+toBeUpsertedDecisionShareList);
            upsert toBeUpsertedDecisionShareList;
        }
        
        
        
        
        // update  plan owner records 
        if(tobeUpdatedPlanOwnerList.size() > 0) {
            update tobeUpdatedPlanOwnerList;
        }
        
        /*
        map<Id, set<Id>> userPlanMap = new map<Id, set<Id>>(); 
        for(Plan__Share ps: [select id, UserOrGroupId, ParentId from Plan__Share where ParentId In: planOwnerSwapId ]) {
            set<Id> useSet = userPlanMap.get(ps.ParentId);
            if(useSet == null ) {
                useSet = new set<Id>();
                userPlanMap.put(ps.ParentId, useSet);
            }
            useSet.add(ps.UserOrGroupId);
        }
        
        List<Plan__Share> toBeUpsertedPlanShareList = new List<Plan__Share>();
        for(Plan__Share ps: toBeInsertedPlanShareList) {
            if(userPlanMap.get(ps.ParentId) != null) {
                if(!userPlanMap.get(ps.ParentId).contains(ps.UserOrGroupId) ) {
                    toBeUpsertedPlanShareList.add(ps);
                }
            }
            else {
                toBeUpsertedPlanShareList.add(ps);
            }
        }
        
        if(toBeUpsertedPlanShareList.size() > 0) {
            upsert toBeUpsertedPlanShareList;
        }
        
        */
        // ____________________ //
        
            
        List<Plan__Share> toBeUpsertedPlanShareList = new List<Plan__Share>();
        
        map<Id, set<Id>> userPlanMap = new map<Id, set<Id>>(); 
        for(Plan__Share ps: [select id, UserOrGroupId, ParentId from Plan__Share where ParentId In: planOwnerSwapId ]) {
            set<Id> useSet = userPlanMap.get(ps.ParentId);
            if(useSet == null ) {
                useSet = new set<Id>();
                userPlanMap.put(ps.ParentId, useSet);
            }
            useSet.add(ps.UserOrGroupId);
        }
        
        map<Id,Plan__c> planUsrMap = new map<Id,Plan__c>([select Id, OwnerId from Plan__c where Id =: planOwnerSwapId]);
        
        
          for(Plan__Share ps: toBeInsertedPlanShareList) {
              if(!toBeupdatedPlanOwnerId.contains(ps.ParentId)) {
                  if(userPlanMap.get(ps.ParentId) != null && planUsrMap.get(ps.ParentId).OwnerId != ps.UserOrGroupId ) {
                      if(!userPlanMap.get(ps.ParentId).contains(ps.UserOrGroupId) ) {
                            toBeUpsertedPlanShareList.add(ps);
                        }
                        toBeUpsertedPlanShareList.add(ps);
                    }
                }
          }
      
          for(Social_Input__c socialInput : [select Plan__c,User__r.isActive,User__c,Is_Group__c,GroupId__c,Responsible__c,Backup_for_Accountable__c, Veto_Rights__c, Informed__c,Consulted__c  from Social_Input__c where  Plan__c In: toBeupdatedPlanOwnerId and Accountable__c = false]) {
              Plan__Share planShare = new Plan__Share();
              planShare.ParentId = socialInput.Plan__c;
              
              if(socialInput.User__c != null && socialInput.User__r.isActive) {
                planShare.UserOrGroupId = socialInput.User__c;
                  if(socialInput.Responsible__c || socialInput.Backup_for_Accountable__c || socialInput.Veto_Rights__c) {
                    planShare.AccessLevel = 'Edit';
                  }
                  else {
                      planShare.AccessLevel = 'Read';
                  }
              }
              else {
                if(socialInput.Is_Group__c && socialInput.GroupId__c != null) {
                  planShare.UserOrGroupId = socialInput.GroupId__c;
                    planShare.AccessLevel = 'Read';
                }
              }
              toBeUpsertedPlanShareList.add(planShare);
          }
          
        //if(tobeUpdateSocialInputForAccAfterRoleSwapping.size() > 0) { 
            //FutureMethodController.changeRoleAcceptanceStatus(tobeUpdateSocialInputForAccAfterRoleSwapping);
        //}
       
         if(roleAcceptanceApprovalList.size() > 0) {
            List<Approval.ProcessResult> roleAcceptanceProcessResultList = Approval.process(roleAcceptanceApprovalList);
            
            for(Approval.ProcessResult r: roleAcceptanceProcessResultList) {
                System.assert(r.isSuccess());
            }
        }
        
        
        
        if(socialInputIdTobeRecallAproval.size() > 0) { 
            map<Id, Social_Input__c > socialInputMap = new map<Id, Social_Input__c >([select Stance_Approval_Status__c, Final_Approval_Status__c from Social_Input__c where ID IN : socialInputIdTobeRecallAproval   ]);
            for(ProcessInstanceWorkitem p: [select Id,ProcessInstance.TargetObjectId from ProcessInstanceWorkitem where  ProcessInstance.TargetObjectId in: socialInputIdTobeRecallAproval]) {
                Approval.ProcessWorkItemRequest pwr = new Approval.ProcessWorkItemRequest();
                pwr.setWorkitemId(p.id);
                System.debug( socialInputMap );
                System.debug(p.ProcessInstance.TargetObjectId);
                System.debug( socialInputMap.get( p.ProcessInstance.TargetObjectId  ).Final_Approval_Status__c );
                System.debug( socialInputMap.get( p.ProcessInstance.TargetObjectId  ).Stance_Approval_Status__c );
                if( ( socialInputMap.get( p.ProcessInstance.TargetObjectId  )).Final_Approval_Status__c == 'Pending Approval' )
                pwr.setComments('This decision approval has been recalled');
                if( ( socialInputMap.get( p.ProcessInstance.TargetObjectId  )).Stance_Approval_Status__c == 'Pending Approval' ) 
                pwr.setComments('This stance approval has been recalled');
                pwr.setAction('Removed');  
                Approval.ProcessResult pr = Approval.process(pwr);     
                
                
            }
            
        }
        
        if(toBeUpsertedPlanShareList.size() > 0) {
            System.debug('------ toBeUpsertedPlanShareList --------->' + toBeUpsertedPlanShareList);
            upsert toBeUpsertedPlanShareList;
        }
    } 
    
    if(!infUserRemovedIds.isEmpty()){
  		if(!CheckforRecrussion.isInfRemove){	
  			RankingDatabaseDefination.addedAsRole(infUserRemovedIds,'informed','Remove');
  			CheckforRecrussion.isInfRemove = true;
  		}
  	}
    if(!resUserIds.isEmpty()){	
  		if(!CheckforRecrussion.isRes){	
  			RankingDatabaseDefination.addedAsRole(resUserIds,'responsible','');
  			CheckforRecrussion.isRes = true;
  		}
  	} 
  	if(!conUserIds.isEmpty()){
  		if(!CheckforRecrussion.isCon){	
  			RankingDatabaseDefination.addedAsRole(conUserIds,'consulted','');
  			CheckforRecrussion.isCon = true;
  		}
  	}
  	if(!infUserIds.isEmpty()){
  		if(!CheckforRecrussion.isInf){	
  			RankingDatabaseDefination.addedAsRole(infUserIds,'informed','');
  			CheckforRecrussion.isInf = true;
  		}
  	}
  	if(!resUserRemovedIds.isEmpty()){	
  		if(!CheckforRecrussion.isResRemove){
  			RankingDatabaseDefination.addedAsRole(resUserRemovedIds,'responsible','Remove');
  			CheckforRecrussion.isResRemove = true;
  		}
  	} 
  	if(!conUserRemovedIds.isEmpty()){
  		if(!CheckforRecrussion.isConRemove){	
  			RankingDatabaseDefination.addedAsRole(conUserRemovedIds,'consulted','Remove');
  			CheckforRecrussion.isConRemove = true;
  		}
  	}
    
     //**********************************************************************
        //call this method for chatter feed comment when collaborator will add *
        //**********************************************************************
         
         if(SocialfeedIdMap.size() > 0 && userIdSet.size() > 0 && postTextMap.size() > 0 && decisionIdForCommentSet.size() > 0 && socialInputpostIdSet.size() > 0){
           System.debug('XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');
            ChatterFeedCommentOrPost.mentionTextPostForComment(SocialfeedIdMap, userIdSet, postTextMap, decisionIdForCommentSet,socialInputpostIdSet,Trigger.isUpdate);
         }   
}