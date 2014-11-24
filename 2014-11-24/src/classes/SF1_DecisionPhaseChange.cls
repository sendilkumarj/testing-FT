/*************************************************
* Created By : Tanay Das Barman
* Description : This class using in Sf1 for Decision Phase Move
***************************************************/

global with sharing class SF1_DecisionPhaseChange {
     
    //Decision to hold decision data
    Public  static Decision__c decision {get;set;}
    // Boolean to render decisionStatementArea in VF
    Public  static  boolean renderPanel{get;set;}
    //Boolean to render approvalArea in VF if stance is pending
    Public  static  boolean renderDecisionApprovalPanel{get;set;}
    //Boolean to render approvalArea in VF if stance is pending
    Public  static  boolean renderStanceApprovalPanel{get;set;}
    //String to hold approval comments
    Public  static  String decisionComment{get;set;}
    //String to hold approval action Approve/Reject
    Public  static  String approvalAction{get;set;}
    //String to hold currentphase of the decision.
    Public  static  String decisionCurentPhase{get;set;}
    //Boolean to ask user for decision aproval.
    public  static  Boolean advanceDecision {get;set;}
    //Boolean to render close reason and comment at close phase
    public  static  Boolean renderCloseArea{get;set;}
    //Boolean to indicate succwesfull update.
    public  static  Boolean updateSuccess{get;set;}
    //Boolean to check for user access
    public  static  Boolean userAccess{get;set;}
    //Boolean to check for vetoRejection
    public  static  boolean vetoRejection{get;set;}
    
    Public  static  String decisionSpritePosition{get;set;}
     Public  static  String decisionTaken{get;set;}
     
     public SF1_DecisionPhaseChange(ApexPages.StandardController controller) {
     decision  = (Decision__c )controller.getRecord();
     renderPanel = false;
     //Query decision data
     decision = [Select id ,ownerId,Title__c,Status__c,Reason_for_Close__c , Phase__c ,Decision_Taken__c,Problem_Idea_Advice__c,  Decision__c from Decision__c where id =: decision.id];
     
     // adjust phase next possible one.
     adjustPhase();
     //Disable all penels
     renderStanceApprovalPanel = false;
     renderDecisionApprovalPanel = false;
     renderCloseArea   = false;
     vetoRejection    = false;
     userAccess = false;
     //Enable decision content panel at propose phase
     if(decision != null && decision.phase__c == 'Propose' && decision.Decision_Taken__c == null )
     {  
       renderPanel = true;
     }  
     Social_Input__c loggedInSocialPeople = new  Social_Input__c();
     if([Select id,Stance_Approval_Status__c,Final_Approval_status__c, Veto_Rights__c, Accountable__c,Backup_for_Accountable__c  from Social_Input__c where User__c =: Userinfo.getUserId() and Decision__c = : decision.id ].size() > 0){
        loggedInSocialPeople = [Select id,Stance_Approval_Status__c,Final_Approval_status__c, Veto_Rights__c, Accountable__c,Backup_for_Accountable__c  from Social_Input__c where User__c =: Userinfo.getUserId() and Decision__c = : decision.id ];
     }
      if(loggedInSocialPeople != null){
        userAccess  = loggedInSocialPeople.Accountable__c|| loggedInSocialPeople.Backup_for_Accountable__c;
      } 
      //Enable approval area if any approval pending
      system.debug('decisiondecisiondecision'+decision);
      if(decision != null && decision.phase__c == 'Decide' || decision.phase__c == 'Execute' || decision.phase__c == 'Evaluate' || decision.Phase__c == 'Close')
      {  
               if( [Select count() From ProcessInstanceWorkitem p where   p.ActorId =: Userinfo.getUserId() AND p.ProcessInstance.TargetObjectId =: loggedInSocialPeople.Id] > 0 )   
               {   if( loggedInSocialPeople.Stance_Approval_status__c == 'Pending Approval' ){
                   renderStanceApprovalPanel = true;
                    } else if( loggedInSocialPeople.Final_Approval_status__c   == 'Pending Approval' ){
                        renderDecisionApprovalPanel = true;
                        }
               }
               
        }
        //Enable close are if next phase  is close
        if( decision != null && decision.phase__c == 'Close'  )
        {
               renderCloseArea = true;
        }
        if( loggedInSocialPeople != null && loggedInSocialPeople.Veto_Rights__c == true ){
            vetoRejection = true;
        }
        
        
        
    }
    public  static  void adjustPhase(){
    
         decisionCurentPhase = [Select  Phase__c,status__c  from Decision__c where id =: decision.id].Phase__c  ;
         if(decision.phase__c == 'Draft'){
            decision.phase__c = 'Share'; 
            //sprite image position 
            decisionSpritePosition = '0';
         }
         else
         if(decision.phase__c == 'Share'){
            decision.phase__c = 'Propose'; 
              //sprite image position 
            decisionSpritePosition = '-40';
         }
         else
         if(decision.phase__c == 'Propose'){
            decision.phase__c = 'Decide';   
             //sprite image position 
            decisionSpritePosition = '-80';    
         }
         else
         if(decision.phase__c == 'Decide'  ){
            if( decision.status__c  == 'Approved'){            
                decision.phase__c = 'Execute';
                 //sprite image position 
                decisionSpritePosition = '-160';
            }
            else{
             decision.phase__c = 'Evaluate';   
                decisionSpritePosition= '-120';
             }  
         }
         else
         if(decision.phase__c == 'Execute'){
            decision.phase__c = 'Evaluate';   
             //sprite image position 
            decisionSpritePosition = '-200';       
         }
         else
         if(decision.phase__c == 'Evaluate'){
             if( decision.status__c  == 'Approved'){
                decision.phase__c = 'Close';    
                 //sprite image position 
                decisionSpritePosition = '-240';  
            }else{
                decision.phase__c = 'Close';    
                 //sprite image position 
                decisionSpritePosition = '-280';
            }
               
         }
         else
         if(decision.phase__c == 'Close'){
            decision.phase__c = 'Share';
             //sprite image position 
            decisionSpritePosition = '-320';         
         } 
    }
    
   @RemoteAction  
   global static void DecisionPhaseAdvance(String decisionId,String phase,string userComment,String reaonForClose){
    try{
     //Reste all flags to false;
     system.debug('reaonForClosereaonForClose '+reaonForClose);
     renderPanel  = false;
     advanceDecision  = false;
    // renderStanceApprovalPanel = false;
     renderDecisionApprovalPanel = false;
     renderCloseArea  = false;
     updateSuccess    = false;
     vetoRejection    = false;
     decision = [Select id ,ownerId,Title__c,Status__c,Reason_for_Close__c , Phase__c ,Decision_Taken__c,Problem_Idea_Advice__c,  Decision__c from Decision__c where id =: decisionid];
     //If the method is called by action support from drop down then enable close area and then return
    
     decision.phase__c = phase;
     if(decision != null && decision.phase__c == 'Propose' && userComment != null && userComment != '' ){
            decision.Decision_Taken__c = userComment;
            decision.Status__c = 'Undecided';
     }
     if(decision != null && decision.phase__c == 'Close'  )
     {        decision.Status__c = 'Closed';    
              decision.Comments__c = userComment;
              decision.Reason_for_close__c = reaonForClose;
              
               renderCloseArea = true;    
              // return;
     }
     //If clcked on move decision button at propose phase and stance is already approved then show decision approval area  and then return
     if(decision != null && decision.phase__c == 'Decide'  )
     {  
                       decision.Reason_for_close__c = 'Cancelled';
                       decision.Status__c = 'Approved';
                       Social_Input__c loggedInSocialPeople = [Select id,Stance_Approval_Status__c,Final_Approval_status__c,  Accountable__c,Backup_for_Accountable__c  from Social_Input__c where User__c =: Userinfo.getUserId() and Decision__c = : decision.id ];
                       if( [Select count() From ProcessInstanceWorkitem p where   p.ActorId =: Userinfo.getUserId() AND p.ProcessInstance.TargetObjectId =: loggedInSocialPeople.Id] > 0 )   
                       {    
                           if( loggedInSocialPeople.Final_Approval_status__c   == 'Pending Approval' )
                           renderDecisionApprovalPanel = true;
                           //return;
                       }
                       
      }
     //If decision is at share or propose status has to be Undecided
     if(decision != null && decision.phase__c == 'Share' ||  decision.phase__c == 'Propose'   )
     decision.Status__c = 'Undecided';
     if(decision != null && decision.phase__c == 'Share'    )
     decision.Comments__c= '';
     if(decision != null && phase == 'Execute'    )
     {   decision.Comments__c= '';
         decision.Status__c = 'Approved' ;
         decision.Reason_for_close__c = 'Executed';
     }
     if(decision.phase__c == 'Evaluate') {
            decision.Reason_for_close__c = 'Evaluated';
            if( decision.Status__c == 'Approved' )
            decision.Status__c = 'Executed' ;
     }
     
     if(FLS.decisionUpdateable()) {
            Update  decision;
            updateSuccess = true;
            //Create a chatter post when decision is shared
            if( FLS.FeedItemCreatable() && decision.phase__c == 'Share') 
            {
                Id userId=decision.ownerid;
                String unitPost;
                User usr = [Select id,name from User where id=:decision.ownerid Limit 1];
                
                if(decision.Problem_Idea_Advice__c != null && decision.Problem_Idea_Advice__c.length() > 3500){
                     unitPost = decision.Problem_Idea_Advice__c.substring(0,3500);
                     unitPost += '... Readmore in Fingertip';
                }else{
                        if(decision.Problem_Idea_Advice__c == null){
                            unitPost = '';
                        }else{
                            unitPost = decision.Problem_Idea_Advice__c;
                        }
                        
                }
                
                String postText='I just shared this decision with you. Let’s get good insights and collaboration going!'+'\n'+'\n'+'Here is the description:'+'\n'+'\n'+'"'+unitPost+'"'+'\n';
                //System.debug('mentionTextPost'+postText+'userId'+userId+'userId'+userId);
                Decisionview.mentionTextPost( userId, postText, decision.Id);
            } 
            //Create a chatter post when decision is proposed with then keep title as decision id for qurying later
            if(decision != null && FLS.FeedItemCreatable() && decision.phase__c == 'Propose') 
            {
                /*FeedItem post = new FeedItem();
                post.ParentId =  decision.Id;  
                post.Body =      'The decision has been proposed'  ;
                post.type = 'TextPost';                   
                post.Title = decision.id;  
                post.createdbyid = decision.ownerid;
                insert post;*/
                
                Decision__c decisionQry  =[select id,Problem_Idea_Advice__c,Decision_Taken__c,ownerid from Decision__c where id =:decision.id Limit 1];
                Id userId=decision.ownerid;
                User usr = [Select id,name from User where id=:decisionQry.ownerid Limit 1];
                String postText='Here is the proposed Decision, read it and give your Stance.'+'\n'+'\n'+'Decision:'+'\n'+'"'+decision.Decision_Taken__c+'"'+'\n'+'\n'+'(hint: it’s done in the command center)';
                DecisionView.mentionTextPostPropose( usr.id, postText, decision.id );
                   
            } 
            if(decision != null && FLS.FeedItemCreatable() && decision.phase__c  == 'Execute') 
            {
                Decision__c decisionQry  =[select id,Problem_Idea_Advice__c,Decision_Taken__c from Decision__c where id =:decision.id  Limit 1];
                Id userId=decision.ownerid;
                User usr = [Select id,name from User where id=:decision.ownerid Limit 1];
                String postText='The decision is good to go, let’s Execute!'+'\n';
                DecisionView.mentionTextPostPropose( usr.id, postText, decision.id );
            }   
            adjustPhase();  
            if(decision != null && decision.phase__c == 'Propose' && decision.Decision_Taken__c == null )
            {  
               renderPanel = true;
            }
           
            Social_Input__c loggedInSocialPeople = [Select id,Stance_Approval_Status__c,Final_Approval_status__c,  Accountable__c,Backup_for_Accountable__c  from Social_Input__c where User__c =: Userinfo.getUserId() and Decision__c = : decision.id ];
            if(decision != null && decision.phase__c == 'Decide'  )
            {  
                       if( [Select count() From ProcessInstanceWorkitem p where   p.ActorId =: Userinfo.getUserId() AND p.ProcessInstance.TargetObjectId =: loggedInSocialPeople.Id] > 0 )   
                       {   if( loggedInSocialPeople.Stance_Approval_status__c == 'Pending Approval' )
                           renderStanceApprovalPanel = true;
                           else
                           if( loggedInSocialPeople.Final_Approval_status__c   == 'Pending Approval' )
                           renderDecisionApprovalPanel = true;
                       }
                       
              }
        } 
    }
    
    catch(exception e){
          System.debug(e);
       }
   }
   
   @RemoteAction 
    global  static  void approvedReject(String decisionId, String approvalStatus, string UsrComment){
           advanceDecision  = false;
           //renderStanceApprovalPanel = false;
           renderDecisionApprovalPanel = false;
           vetoRejection   = false;
           approvalAction = approvalStatus;
           Social_Input__c loggedInSocialPeople = [Select id,Veto_Rights__c, Stance_Approval_status__c,Final_Approval_status__c from Social_Input__c where User__c =: Userinfo.getUserId() and Decision__c = :decisionId ];
           decision = [Select id ,ownerId,Title__c,Status__c,Reason_for_Close__c , Phase__c ,Decision_Taken__c,Problem_Idea_Advice__c,  Decision__c from Decision__c where id =: decisionid];
           
            if( [Select count() From ProcessInstanceWorkitem p where   p.ActorId =: Userinfo.getUserId() AND p.ProcessInstance.TargetObjectId =: loggedInSocialPeople.Id] > 0 )   
            {               
               if( approvalAction == 'Reject' && (  loggedInSocialPeople.Stance_Approval_status__c   == 'Pending Approval' ) && (  loggedInSocialPeople.Veto_Rights__c == true ) ){
                 vetoRejection = true;
                // return;
               }
               
               
               if( loggedInSocialPeople.Stance_Approval_status__c   == 'Pending Approval' ){
                   advanceDecision = true; 
                   approveorReject(loggedInSocialPeople.Id,UsrComment,decisionId,approvalStatus);
                   if( [Select count() From ProcessInstanceWorkitem p where   p.ActorId =: Userinfo.getUserId() AND p.ProcessInstance.TargetObjectId =: loggedInSocialPeople.Id] == 0 )   
                   advanceDecision = false;
               }
               else{
                    approveorReject(loggedInSocialPeople.Id ,UsrComment,decisionId,approvalStatus);
                    decision.Status__c = approvalAction == 'Approve'? 'Approved':'Rejected';
                    //DecisionPhaseAdvance(decisionId,'Decide');
               }
               
            }
    }
    
    public  static  void approveorReject(Id loggedInSocialPeopleId,string UsrComment,string decisionId,String action){
            decisionComment = UsrComment;
            String comment = UsrComment;
            Social_Input__c logedInsocialInput = [Select  s.Role__c , s.Role_Acceptance_Status__c , s.Accountable__c, s.Backup_for_Accountable__c, s.Responsible__c,s.Consulted__c,s.Informed__c,s.Veto_Rights__c,s.Stance_Approval_Status__c,s.Final_Approval_Status__c   From Social_Input__c s where s.Decision__c =: decisionId and s.User__c =: userInfo.getUserId() ];
            Approval.ProcessWorkItemRequest processWorkItemRequest = new Approval.ProcessWorkItemRequest();
            ProcessInstanceWorkitem processInstanceWorkitem = [Select p.ProcessInstance.Status, p.ProcessInstance.TargetObjectId, p.ProcessInstanceId, p.Id, p.CreatedDate, p.CreatedBy.Name, p.CreatedById, p.Actor.Name, p.ActorId From ProcessInstanceWorkitem p where   p.ActorId =: Userinfo.getUserId() AND p.ProcessInstance.TargetObjectId =: loggedInSocialPeopleId];    
            
            //processWorkItemRequest = processInstanceWorkitem;        
            processWorkItemRequest.setWorkitemId(processInstanceWorkitem.id);
              
            processWorkItemRequest.setComments(decisionComment);
           
            processWorkItemRequest.setAction(approvalAction); 
            Approval.ProcessResult pr = Approval.process(processWorkItemRequest);
            decisionComment = '';
            
             decision = [select id,FeedItem_Id_Propose__c, Name, Phase__c, Status__c ,ownerid from Decision__c where Id =:decisionId];
            
            Social_Input__c socialInput = [Select s.Veto_Rights__c, s.User__c,s.Stance_Approval_Status__c, s.SystemModstamp, s.SYS_Tab_View_Activites__c, s.SYS_Tab_View_History__c, s.SYS_Tab_View_Tasks__c, s.SYS_Tab_View_Social_Input__c, s.SYS_Tab_View_Relations__c, s.SYS_Tab_View_Quality__c, s.SYS_Tab_View_Attachments__c, s.SYS_Tab_View_Approvals__c, s.Role_Acceptance_Status__c, s.Role_Acceptance_Required__c, s.Result__c, s.Responsible__c, s.Rating__c, s.Outcome__c, s.Name, s.Mood__c, s.Like__c, s.LastModifiedDate, s.LastModifiedById, s.Informed__c, s.Id, s.Final_Approval_Status__c, s.Effort__c, s.Dislike__c, s.Decision__c, s.CreatedDate, s.CreatedById, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c, s.Accountable__c From Social_Input__c s where s.Id =: processInstanceWorkitem.ProcessInstance.TargetObjectId ];
            //If the current user approves stance or final decison a chatter post is created.
            String roleString  =  '';
            String proposeChatterPostId = '';
            // Checks for logged in users role status
            if( logedInsocialInput.Role_Acceptance_Status__c == 'Approved/Accepted'  ){
                 proposeChatterPostId  =  decision.FeedItem_Id_Propose__c; 
                //if no propose chatter post exist then create new one and make comment.
                if( decision.FeedItem_Id_Propose__c  == '' || decision.FeedItem_Id_Propose__c  == null ){
                    system.debug('-------------- Approved while creating' );
                    Decision__c decisionQry  =[select id,Problem_Idea_Advice__c,Decision_Taken__c,ownerid from Decision__c where id =:decisionId Limit 1];
                    Id userId=decision.ownerid;
                    //System.debug('-----decision-------------decision.Decision_Taken__c'+decision.Decision_Taken__c+decisionId+'--'+decision.ownerid);
                    User usr = [Select id,name from User where id=:decisionQry.ownerid Limit 1];
                    //String postText='The following decision has been proposed:'+'\n'+'\n'+'"'+decisionQry.Decision_Taken__c+'"'+'\n'+'\n'+usr.name+' '+'needs your personal stance.';
                    String postText='Here is the proposed Decision, read it and give your Stance.'+'\n'+'\n'+'Decision:'+'\n'+'"'+decisionQry.Decision_Taken__c+'"'+'\n'+'\n'+'(hint: it’s done in the command center)';
                    DecisionView.mentionTextPostPropose( usr.id, postText, decisionId);
                        
                    /*FeedItem post = new FeedItem();
                    post.ParentId =  decision.Id;  
                    post.Body =      'The decision has been proposed'  ;
                    post.type = 'TextPost';                   
                    post.Title = decision.id;  
                    post.createdbyid = decision.ownerid;
                    if( FLS.FeedItemCreatable()) 
                    insert post;*/ 
                    //proposeChatterPostId  =  post.id;
                    Decision__c decisionQryUpdated  =[select id,FeedItem_Id_Propose__c from Decision__c where id =:decisionId Limit 1];
                    proposeChatterPostId  =  decisionQryUpdated.FeedItem_Id_Propose__c; 
                }
                // Creates a feed comment
                FeedComment chatterComment = new FeedComment();
                chatterComment.feedItemId =  proposeChatterPostId;  
                comment = comment.length() > 1000 ? comment.substring(0,890) + '...':comment;
                // Role string to diplay each role separated with ',' and  'and'
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
                //Display chatter comment to show loggedin user has Approved/Rejected OR Supported/Opposed  the deciison with his role and comments provided in stance
                chatterComment.CommentBody = 'Has ' +  ( ( logedInsocialInput.Stance_Approval_Status__c == 'Pending Approval' ) ?   ( action == 'Approve' ? 'supported the decision' : 'opposed the decision' ) :  ( logedInsocialInput.Final_Approval_Status__c == 'Pending Approval' ?  ( action == 'Approve' ? 'approved the decision': 'rejected the decision' ) : '' ) ) + ' as '+  roleString +   (    (  comment != null &&( comment.trim().length() != 0 ) ) ?'\nwith Comment:\n \"' +comment +'\".' : '.' );
                if( FLS.FeedItemCreatable())    
                insert chatterComment;  
            }
            //if current user rejected stance create a chatter post for decision rejection
            if( logedInsocialInput.Role_Acceptance_Status__c == 'Approved/Accepted' && socialInput.Stance_Approval_Status__c == 'Rejected' && socialInput.Veto_Rights__c && action == 'Reject' ) 
            {
                         // Creates a feed comment 
                        FeedComment chatterComment = new FeedComment();
                        chatterComment.feedItemId =  proposeChatterPostId;  
                        comment = comment.length() > 1000 ? comment.substring(0,890) + '...':comment;
                        // Display chatter comment to show loggedin use has Rejected the decision with  his role and comments provided in stance
                        chatterComment.CommentBody =    'Has rejected the Decision'   + ' as '+  roleString +   (    (  comment != null &&( comment.trim().length() != 0 ) ) ?'\nwith Comment:\n \"' +comment +'\".' : '.' );
                        if( FLS.FeedItemCreatable())    
                        insert chatterComment;    
             }
    }
    
    @RemoteAction 
     global  static  void approveorRejectVeto(String decisionId, String approvalStatus,string UsrComment)    {
            string action = approvalStatus;
            vetoRejection   = false;
            decisionComment = UsrComment;
            approvalAction = approvalStatus;
            String comment = UsrComment;
           // Social_Input__c loggedInSocialPeople = [Select id,Veto_Rights__c, Stance_Approval_status__c,Final_Approval_status__c from Social_Input__c where User__c =: Userinfo.getUserId() and Decision__c = : decisionId ];
            Social_Input__c logedInsocialInput = [Select id, s.Role__c , s.Role_Acceptance_Status__c , s.Accountable__c, s.Backup_for_Accountable__c, s.Responsible__c,s.Consulted__c,s.Informed__c,s.Veto_Rights__c,s.Stance_Approval_Status__c,s.Final_Approval_Status__c   From Social_Input__c s where s.Decision__c =: decisionId and s.User__c =: userInfo.getUserId() ];
            Approval.ProcessWorkItemRequest processWorkItemRequest = new Approval.ProcessWorkItemRequest();
            ProcessInstanceWorkitem processInstanceWorkitem = [Select p.ProcessInstance.Status, p.ProcessInstance.TargetObjectId, p.ProcessInstanceId, p.Id, p.CreatedDate, p.CreatedBy.Name, p.CreatedById, p.Actor.Name, p.ActorId From ProcessInstanceWorkitem p where   p.ActorId =: Userinfo.getUserId() AND p.ProcessInstance.TargetObjectId =: logedInsocialInput.Id];    
            
            //processWorkItemRequest = processInstanceWorkitem;        
            processWorkItemRequest.setWorkitemId(processInstanceWorkitem.id);
              
            processWorkItemRequest.setComments(decisionComment);
           
            processWorkItemRequest.setAction(approvalAction); 
            Approval.ProcessResult pr = Approval.process(processWorkItemRequest);
            decisionComment = '';
           // adjustPhase();
           
           decision = [select id,FeedItem_Id_Propose__c, Name, Phase__c, Status__c ,ownerid from Decision__c where Id =:decisionId];
            
           Social_Input__c socialInput = [Select s.Veto_Rights__c, s.User__c,s.Stance_Approval_Status__c, s.SystemModstamp, s.SYS_Tab_View_Activites__c, s.SYS_Tab_View_History__c, s.SYS_Tab_View_Tasks__c, s.SYS_Tab_View_Social_Input__c, s.SYS_Tab_View_Relations__c, s.SYS_Tab_View_Quality__c, s.SYS_Tab_View_Attachments__c, s.SYS_Tab_View_Approvals__c, s.Role_Acceptance_Status__c, s.Role_Acceptance_Required__c, s.Result__c, s.Responsible__c, s.Rating__c, s.Outcome__c, s.Name, s.Mood__c, s.Like__c, s.LastModifiedDate, s.LastModifiedById, s.Informed__c, s.Id, s.Final_Approval_Status__c, s.Effort__c, s.Dislike__c, s.Decision__c, s.CreatedDate, s.CreatedById, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c, s.Accountable__c From Social_Input__c s where s.Id =: processInstanceWorkitem.ProcessInstance.TargetObjectId ];
           
            String roleString  =  '';
            String proposeChatterPostId = '';
            // Checks for logged in users role status
            if( logedInsocialInput.Role_Acceptance_Status__c == 'Approved/Accepted'  ){
                 proposeChatterPostId  =  decision.FeedItem_Id_Propose__c; 
                //if no propose chatter post exist then create new one and make comment.
                if( decision.FeedItem_Id_Propose__c  == '' || decision.FeedItem_Id_Propose__c  == null ){
                    system.debug('-------------- Approved while creating' );
                    Decision__c decisionQry  =[select id,Problem_Idea_Advice__c,Decision_Taken__c,ownerid from Decision__c where id =:decisionId Limit 1];
                    Id userId=decision.ownerid;
                    //System.debug('-----decision-------------decision.Decision_Taken__c'+decision.Decision_Taken__c+decisionId+'--'+decision.ownerid);
                    User usr = [Select id,name from User where id=:decisionQry.ownerid Limit 1];
                    //String postText='The following decision has been proposed:'+'\n'+'\n'+'"'+decisionQry.Decision_Taken__c+'"'+'\n'+'\n'+usr.name+' '+'needs your personal stance.';
                    String postText='Here is the proposed Decision, read it and give your Stance.'+'\n'+'\n'+'Decision:'+'\n'+'"'+decisionQry.Decision_Taken__c+'"'+'\n'+'\n'+'(hint: it’s done in the command center)';
                    DecisionView.mentionTextPostPropose( usr.id, postText, decisionId);
                   
                    Decision__c decisionQryUpdated  =[select id,FeedItem_Id_Propose__c from Decision__c where id =:decisionId Limit 1];
                    proposeChatterPostId  =  decisionQryUpdated.FeedItem_Id_Propose__c; 
                }
                 
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
                  
            }
            //if current user rejected stance create a chatter post for decision rejection
            if( logedInsocialInput.Role_Acceptance_Status__c == 'Approved/Accepted' && socialInput.Stance_Approval_Status__c == 'Rejected' && socialInput.Veto_Rights__c && action == 'Reject' ) 
            {
                         // Creates a feed comment 
                        FeedComment chatterComment = new FeedComment();
                        chatterComment.feedItemId =  proposeChatterPostId;  
                        comment = comment.length() > 1000 ? comment.substring(0,890) + '...':comment;
                        // Display chatter comment to show loggedin use has Rejected the decision with  his role and comments provided in stance
                        chatterComment.CommentBody =    'Has rejected the Decision'   + ' as '+  roleString +   (    (  comment != null &&( comment.trim().length() != 0 ) ) ?'\nwith Comment:\n \"' +comment +'\".' : '.' );
                        if( FLS.FeedItemCreatable())    
                        insert chatterComment;    
             }
    }
}