/*
    Created by: Phaniraj
    Modifiedby:
    Style: Metro & Force.com
    Description:
     The social record for Decision keeps track total count and avg count of Errots, Results, Likes, Dislikes, moods, ratings. 
     So when any collaborator is deleted in parent, then the values should be rolled up in social record.
    */
trigger SocialInputAfterBeforeDelete on Social_Input__c (before Delete,After Delete) {
   System.debug('---------------------SIN DELETE-----------------');
    //integer.valueOf('cccc');
    if(trigger.isbefore){
    String[] toaddress = new String[]{};
    toaddress.add('shebin@kvpcorp.com');
    
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    mail.setToAddresses(toaddress);
    String sinids= '';
    for(Social_Input__c  Social_Input: trigger.old){
    sinids= sinids+'  '+Social_Input.id;
    }
    mail.setsubject('Social Input Deleted'  );
    mail.setHtmlBody(' Details '+ UserInfo.getUserId()+' '+System.now()+ '  ' + sinids);
   // Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    
    }
    set<Id> SIds = new set<Id>(); 
    
    //To remove the share settings for the user when user is deleted from parent object
    map<Id, set<Id>> DecisionUserMap  = new map<Id, set<Id>>();
    map<Id, set<Id>> planUserMap  = new map<Id, set<Id>>();
    
    
    // initialize follow (entiti subscription) object 
    List<EntitySubscription> followEntitySubscriptionToBeDeleted = new List<EntitySubscription> ();
    Map<Id,set<Id>> parentObjectUserMap = new Map<Id,set<Id>>();
    
    
    for(Social_Input__c s : trigger.old){
        if(Trigger.isAfter) {
            if(s.Decision__c != null) {
                  SIds.add(s.Decision__c);
                  set<Id> userId = DecisionUserMap.get(s.Decision__c);
                  if(userId == null) {
                      userId = new set<Id>();
                      DecisionUserMap.put(s.Decision__c, userId);
                  }
                  if(s.User__c != null) {
                      userId.add(s.User__c);
                      
                      set<Id> toBedeletedUserId = parentObjectUserMap.get(s.Decision__c);
                      if(toBedeletedUserId == null) {
                            toBedeletedUserId = new set<Id>();
                            parentObjectUserMap.put(s.Decision__c,toBedeletedUserId);
                      }
                      toBedeletedUserId.add(s.User__c);
                      
                  }
                  else {
                      userId.add(s.GroupId__c);
                  }
            }
            if(s.Plan__c != null) {
                
                
                SIds.add(s.Plan__c);
                set<Id> userId = planUserMap.get(s.Plan__c);
                if(userId == null) {
                    userId = new set<Id>();
                    planUserMap.put(s.Plan__c, userId);
                }
                if(s.User__c != null) {
                      userId.add(s.User__c);
                      
                      set<Id> toBedeletedUserId = parentObjectUserMap.get(s.Plan__c);
                      if(toBedeletedUserId == null) {
                            toBedeletedUserId = new set<Id>();
                            parentObjectUserMap.put(s.Plan__c,toBedeletedUserId);
                      }
                      toBedeletedUserId.add(s.User__c);
                      
                }
                else {
                    userId.add(s.GroupId__c);
                }
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
        for(AggregateResult q :[select Count(Like__c),Count(Dislike__c),Count(Mood__c),Sum(Mood__c), Count(Effort__c), Sum(Effort__c), Count(Result__c), Sum(Result__c),Count(Rating__c),Sum(Rating__c),Decision__c from Social_Input__c where Decision__c IN :SIds group by Decision__c]){
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
            rec.Average_Mood__c = TotalMoodMap != null && SumMoodMap != null && rec.Related_To_ID__c != null && TotalMoodMap.get(rec.Related_To_ID__c) != null && SumMoodMap.get(rec.Related_To_ID__c) != null ? TotalMoodMap.get(rec.Related_To_ID__c) / SumMoodMap.get(rec.Related_To_ID__c) : 0;
            rec.Total_Effort__c = TotalEffortMap != null && rec.Related_To_ID__c != null ? TotalEffortMap.get(rec.Related_To_ID__c) : 0;
            rec.Effort_count__c = SumEffortMap != null && rec.Related_To_ID__c != null ? SumEffortMap.get(rec.Related_To_ID__c) : 0;
            rec.Total_Result__c = TotalResultMap != null && rec.Related_To_ID__c != null ? TotalResultMap.get(rec.Related_To_ID__c) : 0;
            rec.Result_Count__c = SumResultMap != null && rec.Related_To_ID__c != null ? SumResultMap.get(rec.Related_To_ID__c) : 0;
            rec.Total_Rating__c = TotalRatingsMap != null && rec.Related_To_ID__c != null ? TotalRatingsMap.get(rec.Related_To_ID__c) : 0;
            rec.Rating_Count__c = SumRatingsMap != null && rec.Related_To_ID__c != null ? SumRatingsMap.get(rec.Related_To_ID__c) : 0;
        } 
        update socialRecords;
    }        
    
    map<Id, Id> planUserIdMap = new map<Id, Id>();
    for(Plan__c plan : [select id, ownerId from Plan__c where id IN : planUserMap.keyset() and isDeleted = false]) {
        planUserIdMap.put(plan.Id, plan.ownerId);
    }
    
    // To be detelted social input 
    List<Plan__Share> tobeDeletedPlanShare = new List<Plan__Share>();
    if(planUserMap.size() > 0){
        for(Plan__Share planShare : [select id, UserORGroupId, parentId from Plan__Share where  parentId In: planUserIdMap.keyset()] ) {
            set<Id> userGoupId = planUserMap.get(planShare.parentId);
            if(userGoupId.contains(planShare.UserORGroupId)) {
                if(planUserIdMap.get(planShare.parentId) != planShare.UserORGroupId)  {
                    tobeDeletedPlanShare.add(planShare);
                }
            }
        }
    }
    
    // 
    map<Id, Id> decisionUserIdMap = new map<Id, Id>();
    for(Decision__c decision : [select id, ownerId from Decision__c where id IN : DecisionUserMap.keyset() and isDeleted = false]) {
        decisionUserIdMap.put(decision.Id, decision.ownerId);
    }
    System.debug('------------------------------>'+decisionUserIdMap);
    // To be detelted social input 
    List<Decision__Share> tobeDeletedDecisionShare = new List<Decision__Share>();
    for(Decision__Share decisionShare : [select id, UserORGroupId, parentId from Decision__Share where  parentId In: decisionUserIdMap.keyset()] ) {
        set<Id> userGoupId = DecisionUserMap.get(decisionShare.parentId);
        if(userGoupId.contains(decisionShare.UserORGroupId)) {
            if(decisionUserIdMap.get(decisionShare.parentId) != decisionShare.UserORGroupId)  {
                tobeDeletedDecisionShare.add(decisionShare);
            }
        }
    }
    
    for(EntitySubscription es: [select id, parentId, subscriberid from EntitySubscription where ParentId In: parentObjectUserMap.keyset()]) {
        set<Id> toBeDeletedUser = parentObjectUserMap.get(es.parentId);
        
        if(toBeDeletedUser.contains(es.subscriberid)) {
            followEntitySubscriptionToBeDeleted.add(es);
        }
    }
    
    if(followEntitySubscriptionToBeDeleted.size() > 0) {
        delete followEntitySubscriptionToBeDeleted;
    }
    
    
    if(tobeDeletedPlanShare.size() > 0) {
        System.debug('---------tobeDeletedPlanShare.size()---------------'+tobeDeletedPlanShare.size());
        delete tobeDeletedPlanShare;
    }
    
    if(tobeDeletedDecisionShare.size() > 0){
        delete tobeDeletedDecisionShare;
    }
    
}