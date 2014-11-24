/* 
    ********************************************************************** 
    Created by: Tanay Das Barman
    Style: Force.com & Metro
    Description: a) This is for the Chatter Feed Comment Post, when collaborator is added at any Phanse.
                 
    ********************************************************************** 
 */
public with sharing class ChatterFeedCommentOrPost {
  
  
  
  // Call this method froms SocialinPutAfterBeforeInsert Trigger.
  public static void mentionTextPostForComment(Map<Id,Id> socialfeedIdMap,Set<Id> userId, Map<Id,String> decisionIdpostTextMap,Set<Id> decisionId, Set<Id> socialInputIdSet,Boolean isUpdate) {
    
    //********************************************************//
    //SocialfeedIdMap this map contains socialInputId & feed Id
    // DecisionIdpostTextMap this map contains decision Id & problem,Idea & Advice
    
    // query from Social_Input__c where Id=SocialInputIdSet               
     Map<Id,Social_Input__c>  socialInputMap = new Map<Id,Social_Input__c>([Select Id,Veto_Rights__c,s.Decision__c,s.Decision__r.Phase__c,s.Decision__r.ownerid, s.Decision__r.Decision_Taken__c,s.Decision__r.Problem_Idea_Advice__c, s.Informed__c,s.Responsible__c,s.Accountable__c,s.Consulted__c,s.Role_Acceptance_Status__c,s.Is_Group__c,s.User__c, s.Backup_for_Accountable__c,s.Role__c From Social_Input__c s where Id In:socialInputIdSet  ]);
    
      //Initialize Chatter Connect Api locaally.
           ConnectApi.CommentInput input = new ConnectApi.CommentInput();
           
           //Initialize chatter MessageBodyInput to pass @mention tag
           ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
           
           //Initialize chatter TextSegmentInput to pass problem,Idea & Advice of decision.
           
       ConnectApi.TextSegmentInput textSegment;
       
      // Initialize this list to combine @mention tag & problem,Idea & Advice of decision text.
      
         messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
         
         //Initialize this variable to assign dicision Id from socialInputMap map.
         
         string decisionIdPost ;
         
         //Initialize this variable to assign problem,Idea & Advice of decision value from decisionIdpostTextMap
         
           String postText;
            //Initialize this variable to assign Chaater Feed Id from socialfeedIdMap
           Id eachFeedId ;
           
           //Initialize this variable to execute one time inside the loop.
           Boolean oneTimeExecution= true;
           Boolean vetoOoneTimeExecution= true;
           Boolean chkvetoOrNot = false;
           Boolean oneinform = false;
           
           
           set<id> feedItemIds = new set<id>();
           feedItemIds.addAll(socialfeedIdMap.values());
           Map<id,FeedItem> existingFeedItem = new Map<id,FeedItem>([select id, parentId from FeedItem where id in :feedItemIds]);
           feedItemIds.removeAll(existingFeedItem.keySet());
           /*set<id> DecisionIds = new set<id>();
           for(id socialInputid :socialfeedIdMap.keyset()){
             if(feedItemIds.contains(socialfeedIdMap.get(socialInputid))){
               DecisionIds.add(socialInputMap.get(socialInputid).Decision__c);
             }
            }*/
           
           set<Id> setSocialInptIds = new set<Id>();
           set<Id> setSocialInptIds1 = new set<Id>();
           set<Id> setSocialInptIds2 = new set<Id>();
           
           setSocialInptIds = socialInputMap.keyset();
           List<Id> lstSocialInptIds = new List<Id>();
           lstSocialInptIds.addAll(setSocialInptIds);
           
           if(socialInputMap != null && socialInputMap.keyset().size() > 25){
                for(Integer i = 0 ; i < 24 ; i++){
                    setSocialInptIds1.add(lstSocialInptIds[i]);
                }
                for(Integer j = 24; j < setSocialInptIds.size() ; j++){
                    setSocialInptIds2.add(lstSocialInptIds[j]);
                }
           } else {
               setSocialInptIds1.addAll(socialInputMap.keyset());
           }
           String postCommentText = '';
           for (Id si : setSocialInptIds1) {
               decisionIdPost = socialInputMap.get(si).Decision__c;
               String decisionPhase = socialInputMap.get(si).Decision__r.Phase__c;
               postText = decisionIdpostTextMap.get(decisionIdPost);
               eachFeedId =socialfeedIdMap.get(si);
                
                if(feedItemIds!= null && feedItemIds.contains(eachFeedId)){
                  if(decisionPhase=='Execute'){
                      Id decisionOwnerId=socialInputMap.get(si).Decision__r.ownerid;
                                String postTextCreate='The decision is good to go, let’s Execute!'+'\n';
                                postCommentText = postTextCreate;
                                id feedItemExecuteId =DecisionView.mentionTextPostPropose( decisionOwnerId, postTextCreate, decisionIdPost);
                                eachFeedId = feedItemExecuteId;
                                feedItemIds.remove(eachFeedId);
                  } else if(decisionPhase=='Evaluate'){
                      Id decisionOwnerId=socialInputMap.get(si).Decision__r.ownerid;
                                String postTextCreate='We have Executed the Decision and it is time to Evaluate its Outcome.'+'\n'+'Rate the overall Result and Effort put into the decision.'+'\n'+'\n'+'It would be great that you would share your key learning and take away from this decision. Put it as a comment!'+'\n'+'\n'+'(hint: it’s done in the command center)'+'\n';
                                postCommentText = postTextCreate;
                                id feedItemExecuteId =DecisionView.mentionTextPostPropose( decisionOwnerId, postTextCreate, decisionIdPost);
                                eachFeedId = feedItemExecuteId;
                                feedItemIds.remove(eachFeedId);
                  } 
                  else if(decisionPhase=='Propose'){
                      Id decisionOwnerId=socialInputMap.get(si).Decision__r.ownerid;
                                String postTextCreate='Here is the proposed Decision, read it and give your Stance.'+'\n'+'\n'+'Decision:'+'\n'+'"'+socialInputMap.get(si).Decision__r.Decision_Taken__c+'"'+'\n'+'\n'+'(hint: it’s done in the command center)';
                                postCommentText = postTextCreate;
                                id feedItemExecuteId =DecisionView.mentionTextPostPropose( decisionOwnerId, postTextCreate, decisionIdPost);
                                eachFeedId = feedItemExecuteId;
                                feedItemIds.remove(eachFeedId);
                  }   
                  else if(decisionPhase=='Share'){
                      Id decisionOwnerId=socialInputMap.get(si).Decision__r.ownerid;
                                String postTextCreate='I just shared this decision with you. Let’s get good insights and collaboration going!'+'\n'+'\n'+'Here is the description:'+'\n'+'\n'+'"'+socialInputMap.get(si).Decision__r.Problem_Idea_Advice__c+'"'+'\n';
                                postCommentText = postTextCreate;
                                id feedItemExecuteId =DecisionView.mentionTextPostPropose(decisionOwnerId, postTextCreate, decisionIdPost);
                                eachFeedId = feedItemExecuteId;
                                feedItemIds.remove(eachFeedId);
                  }     
                }
                
                  if(oneTimeExecution){
                    textSegment = new ConnectApi.TextSegmentInput();
                    textSegment.text = '\n'+postText+'\n';
                     messageInput.messageSegments.add(textSegment);
                     oneTimeExecution=false;
                  }
                 if(userId.contains(socialInputMap.get(si).User__c)){
                      continue;
                 }
                      //This is for Accountable Collaborator.
                 else if(((socialInputMap.get(si).Backup_for_Accountable__c== true &&  socialInputMap.get(si).Informed__c == true ) && ( socialInputMap.get(si).Responsible__c == false && socialInputMap.get(si).Consulted__c == false   ) ) && !socialInputMap.get(si).Is_Group__c &&  socialInputMap.get(si).Role_Acceptance_Status__c !='Not Accepted'){
                      messageInput.messageSegments.add(addMentionSegment(socialInputMap.get(si).User__c));
                      textSegment = new ConnectApi.TextSegmentInput();
                      textSegment.text ='   '+ '[Backup For Accountable],';
                      messageInput.messageSegments.add(textSegment);
                  }
                      //This is for Responsible Collaborator.
                 else if((socialInputMap.get(si).Role__c=='Responsible' || (socialInputMap.get(si).Responsible__c == true && socialInputMap.get(si).Accountable__c == false && socialInputMap.get(si).Consulted__c == false   ) )&& socialInputMap.get(si).Backup_for_Accountable__c== false && !socialInputMap.get(si).Is_Group__c   && socialInputMap.get(si).Role_Acceptance_Status__c !='Not Accepted'){
                      messageInput.messageSegments.add(addMentionSegment(socialInputMap.get(si).User__c));
                      textSegment = new ConnectApi.TextSegmentInput();
                      textSegment.text = '  '+'[Responsible],';
                      messageInput.messageSegments.add(textSegment);
                 } 
                 //This is for consulted Collaborator.
                 else if((socialInputMap.get(si).Role__c=='Consulted' || (socialInputMap.get(si).Consulted__c == true && socialInputMap.get(si).Accountable__c == false && socialInputMap.get(si).Responsible__c == false  )) && socialInputMap.get(si).Backup_for_Accountable__c== false && !socialInputMap.get(si).Is_Group__c  && socialInputMap.get(si).Role_Acceptance_Status__c !='Not Accepted'){
                      messageInput.messageSegments.add(addMentionSegment(socialInputMap.get(si).User__c));
                      textSegment = new ConnectApi.TextSegmentInput();
                      textSegment.text = '  '+'[Consulted],';
                      messageInput.messageSegments.add(textSegment);
                 } 
                 //This is for Bacup Accountable/Responsible/Consulted Collaborator.
                  if(socialInputMap.get(si).Backup_for_Accountable__c == true  && socialInputMap.get(si).Responsible__c == true && socialInputMap.get(si).Consulted__c == true && !socialInputMap.get(si).Is_Group__c &&  socialInputMap.get(si).Role_Acceptance_Status__c !='Not Accepted' ){
                      messageInput.messageSegments.add(addMentionSegment(socialInputMap.get(si).User__c));
                      textSegment = new ConnectApi.TextSegmentInput();
                      textSegment.text = '  '+'[Backup For Accountable][Responsible][Consulted],';
                      messageInput.messageSegments.add(textSegment);
                 }
                 //This is for Backup Accountable/Responsible Collaborator.
                  else if(socialInputMap.get(si).Backup_for_Accountable__c== true  && socialInputMap.get(si).Responsible__c == true && socialInputMap.get(si).Consulted__c != true && !socialInputMap.get(si).Is_Group__c &&   socialInputMap.get(si).Role_Acceptance_Status__c !='Not Accepted' ){
                      messageInput.messageSegments.add(addMentionSegment(socialInputMap.get(si).User__c));
                      textSegment = new ConnectApi.TextSegmentInput();
                      textSegment.text ='  '+'[Backup For Accountable][Responsible],';
                      messageInput.messageSegments.add(textSegment);
                 }
                 //This is for Backup Accountable/Consulted Collaborator.
                  else if(socialInputMap.get(si).Backup_for_Accountable__c == true && socialInputMap.get(si).Responsible__c != true && socialInputMap.get(si).Consulted__c == true && !socialInputMap.get(si).Is_Group__c &&   socialInputMap.get(si).Role_Acceptance_Status__c !='Not Accepted' ){
                      messageInput.messageSegments.add(addMentionSegment(socialInputMap.get(si).User__c));
                      textSegment = new ConnectApi.TextSegmentInput();
                      textSegment.text = '  '+'[Backup For Accountable][Consulted],';
                      messageInput.messageSegments.add(textSegment);
                 }
                 //This is for Responsible/Consulted Collaborator.
                  else if((socialInputMap.get(si).Accountable__c != true || socialInputMap.get(si).Backup_for_Accountable__c != true) && socialInputMap.get(si).Responsible__c == true && socialInputMap.get(si).Consulted__c == true && !socialInputMap.get(si).Is_Group__c &&   socialInputMap.get(si).Role_Acceptance_Status__c !='Not Accepted' ){
                      messageInput.messageSegments.add(addMentionSegment(socialInputMap.get(si).User__c));
                      textSegment = new ConnectApi.TextSegmentInput();
                      textSegment.text = '  '+'[Responsible][Consulted],';
                      messageInput.messageSegments.add(textSegment);
                 }
                 
                 else if(socialInputMap.get(si).Role__c=='Informed' && !socialInputMap.get(si).Is_Group__c ){
                     
                     if(socialInputMap.size() == 1 ){
                        oneinform = true;
                        
                     }
                     /* messageInput.messageSegments.add(addMentionSegment(si.User__c)); 
                      textSegment = new ConnectApi.TextSegmentInput();
                      textSegment.text = '[Informed],';
                      messageInput.messageSegments.add(textSegment);*/
                 } 
                 
              // add the text that was passed
              /* input.body = messageInput;       
            ConnectApi.Comment commentRep = ConnectApi.ChatterFeeds.postComment(null, eachFeedId, input, null);*/
              
           }
           if(!chkvetoOrNot && !isUpdate && !oneinform ){
              input.body = messageInput;       
              ConnectApi.Comment commentRep = ConnectApi.ChatterFeeds.postComment(null, eachFeedId, input, null);
           }
            
            if(!setSocialInptIds2.isEmpty()){
                List<Social_Input__c> lstSocialInputRecords = [Select s.Informed__c,s.Decision__r.OwnerId,s.Veto_Rights__c,s.Responsible__c,s.Accountable__c,s.Consulted__c,s.Role_Acceptance_Status__c,s.Is_Group__c,s.User__c, s.Backup_for_Accountable__c,s.Role__c From Social_Input__c s where Id In : setSocialInptIds2];
                if(!lstSocialInputRecords.isEmpty()){
                    if(decisionIdpostTextMap != null && lstSocialInputRecords[0].Decision__c != null){  
                        postCommentText = decisionIdpostTextMap.get(lstSocialInputRecords[0].Decision__c);
                    }
                    Decisionview.mentionTextPostForMoreUsers(lstSocialInputRecords,eachFeedId,null,postCommentText);
                }
            }
            
            //This is for veto  Collaborator. 
            
            //Initialize Chatter Connect Api locaally.
           ConnectApi.CommentInput inputforveto = new ConnectApi.CommentInput();
           
           //Initialize chatter MessageBodyInput to pass @mention tag
           ConnectApi.MessageBodyInput messageInputforveto = new ConnectApi.MessageBodyInput();
           
           //Initialize chatter TextSegmentInput to pass problem,Idea & Advice of decision.
           
       ConnectApi.TextSegmentInput textSegmentforveto;
       
      // Initialize this list to combine @mention tag & problem,Idea & Advice of decision text.
      
         messageInputforveto.messageSegments = new List<ConnectApi.MessageSegmentInput>();
         
         //Initialize this variable to assign dicision Id from socialInputMap map.
         
            
                   for (Id si:socialInputMap.keyset()) {
                    if(socialInputMap.get(si).Veto_Rights__c){
                        chkvetoOrNot = true;
                       decisionIdPost = socialInputMap.get(si).Decision__c;
                       String decisionPhase = socialInputMap.get(si).Decision__r.Phase__c;
                       postText = decisionIdpostTextMap.get(decisionIdPost);
                       eachFeedId =socialfeedIdMap.get(si);
                                            
                        if(vetoOoneTimeExecution){
                             textSegmentforveto = new ConnectApi.TextSegmentInput();
                             textSegmentforveto.text = '\n'+'I have given you Veto rights for this Decision. Please note that if you reject, the decision can’t go forward!'+'\n';
                             messageInputforveto.messageSegments.add(textSegmentforveto);
                             vetoOoneTimeExecution=false;
                        }
                     if(userId.contains(socialInputMap.get(si).User__c)){
                          continue;
                     }
                      //This is for Veto  Collaborator.
                     else if(socialInputMap.get(si).Veto_Rights__c == true && !socialInputMap.get(si).Is_Group__c && socialInputMap.get(si).Role_Acceptance_Status__c !='Not Accepted'){
                          messageInputforveto.messageSegments.add(addMentionSegment(socialInputMap.get(si).User__c));
                          textSegmentforveto = new ConnectApi.TextSegmentInput();
                          textSegmentforveto.text ='   '+ '[Veto],';
                          messageInputforveto.messageSegments.add(textSegmentforveto);
                      }
                    }
                 }
                 
                 inputforveto.body = messageInputforveto;  
                 if(chkvetoOrNot){     
                     ConnectApi.Comment commentRepforVeto = ConnectApi.ChatterFeeds.postComment(null, eachFeedId, inputforveto, null);
                 }   
  }
  
     //** Create and post a message to Chatter (Mention List)
     public static ConnectApi.MentionSegmentInput addMentionSegment(Id thisId) {
        ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
        mentionSegment.id = thisId;
        system.debug('mentionSegmentmentionSegment'+mentionSegment);
        return mentionSegment;
    }
  
}