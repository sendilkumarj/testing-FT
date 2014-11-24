Public class DecisionPhaseChange{
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
    
    public DecisionPhaseChange(ApexPages.StandardController controller) {
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
     //Enable decision content panel at propose phase
     if( decision.phase__c == 'Propose' && decision.Decision_Taken__c == null )
     {  
       renderPanel = true;
     }    
      Social_Input__c loggedInSocialPeople = [Select id,Stance_Approval_Status__c,Final_Approval_status__c,  Accountable__c,Backup_for_Accountable__c  from Social_Input__c where User__c =: Userinfo.getUserId() and Decision__c = : decision.id ];
      userAccess  = loggedInSocialPeople.Accountable__c|| loggedInSocialPeople.Backup_for_Accountable__c;
      //Enable approval area if any approval pending
      if( decision.phase__c == 'Decide' || decision.phase__c == 'Execute'  )
      {  
               if( [Select count() From ProcessInstanceWorkitem p where   p.ActorId =: Userinfo.getUserId() AND p.ProcessInstance.TargetObjectId =: loggedInSocialPeople.Id] > 0 )   
               {   if( loggedInSocialPeople.Stance_Approval_status__c == 'Pending Approval' )
                   renderStanceApprovalPanel = true;
                   else
                   if( loggedInSocialPeople.Final_Approval_status__c   == 'Pending Approval' )
                   renderDecisionApprovalPanel = true;
               }
               
        }
        //Enable close are if next phase  is close
        if( decision.phase__c == 'Close'  )
        {
               renderCloseArea = true;
        }
    }
   //This not used now
   Public  static  void decisionPhaseMoveBack(){
     
     renderPanel  = false;
     advanceDecision  = false;
     renderStanceApprovalPanel = false;
     renderDecisionApprovalPanel = false;
     vetoRejection    = false;
     renderCloseArea   = false;
     if( decision.phase__c == 'Decide'  )
     { 
        decision.phase__c = 'Propose';
     }
     updateSuccess = true;

   }
   //This method is called separatly at close phase as the the caller button in save in closearea
   Public  static  void decisionPhaseClose(){
     renderPanel  = false;
     advanceDecision  = false;
     renderStanceApprovalPanel = false;
     renderDecisionApprovalPanel = false;
     vetoRejection    = false;
     renderCloseArea   = false;
     decision.Status__c = 'Closed';
     update decision;
     decisionComment  = '';
     updateSuccess = true;
     adjustPhase();
   }
   //This method advances the decision
   
   @RemoteAction  
   Public static void DecisionPhaseAdvance(){
    
     //Reste all flags to false;
     renderPanel  = false;
     advanceDecision  = false;
     renderStanceApprovalPanel = false;
     renderDecisionApprovalPanel = false;
     renderCloseArea  = false;
     updateSuccess    = false;
     vetoRejection    = false;
     //If the method is called by action support from drop down then enable close area and then return
     if( decision.phase__c == 'Close'  )
     {
               renderCloseArea = true;
               return;
     }
     //If clcked on move decision button at propose phase and stance is already approved then show decision approval area  and then return
     if( decision.phase__c == 'Decide'  )
     {  
                       
                       Social_Input__c loggedInSocialPeople = [Select id,Stance_Approval_Status__c,Final_Approval_status__c,  Accountable__c,Backup_for_Accountable__c  from Social_Input__c where User__c =: Userinfo.getUserId() and Decision__c = : decision.id ];
                       if( [Select count() From ProcessInstanceWorkitem p where   p.ActorId =: Userinfo.getUserId() AND p.ProcessInstance.TargetObjectId =: loggedInSocialPeople.Id] > 0 )   
                       {    
                           if( loggedInSocialPeople.Final_Approval_status__c   == 'Pending Approval' )
                           renderDecisionApprovalPanel = true;
                           return;
                       }
                       
      }
      //If decision is at share or propose status has to be Undecided
     if( decision.phase__c == 'Share' ||  decision.phase__c == 'Propose'   )
     decision.Status__c = 'Undecided';
     if( decision.phase__c == 'Share'    )
     decision.Comments__c= '';
     if( decision.phase__c == 'Execute' && decisionCurentPhase   == 'Close'    )
     decision.Comments__c= '';
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
            if( FLS.FeedItemCreatable() && decision.phase__c == 'Propose') 
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
            if( FLS.FeedItemCreatable() && decision.phase__c  == 'Execute') 
            {
                Decision__c decisionQry  =[select id,Problem_Idea_Advice__c,Decision_Taken__c from Decision__c where id =:decision.id  Limit 1];
                Id userId=decision.ownerid;
                User usr = [Select id,name from User where id=:decision.ownerid Limit 1];
                String postText='The decision is good to go, let’s Execute!'+'\n';
                DecisionView.mentionTextPostPropose( usr.id, postText, decision.id );
            }   
            adjustPhase();  
            if( decision.phase__c == 'Propose' && decision.Decision_Taken__c == null )
            {  
               renderPanel = true;
            }
           
            Social_Input__c loggedInSocialPeople = [Select id,Stance_Approval_Status__c,Final_Approval_status__c,  Accountable__c,Backup_for_Accountable__c  from Social_Input__c where User__c =: Userinfo.getUserId() and Decision__c = : decision.id ];
            if( decision.phase__c == 'Decide'  )
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
   public  static  void approvedReject()
   {       advanceDecision  = false;
           renderStanceApprovalPanel = false;
           renderDecisionApprovalPanel = false;
           vetoRejection   = false;
           Social_Input__c loggedInSocialPeople = [Select id,Veto_Rights__c, Stance_Approval_status__c,Final_Approval_status__c from Social_Input__c where User__c =: Userinfo.getUserId() and Decision__c = : decision.id ];
           
            if( [Select count() From ProcessInstanceWorkitem p where   p.ActorId =: Userinfo.getUserId() AND p.ProcessInstance.TargetObjectId =: loggedInSocialPeople.Id] > 0 )   
            {               
               if( approvalAction == 'Reject' && (  loggedInSocialPeople.Stance_Approval_status__c   == 'Pending Approval' ) && (  loggedInSocialPeople.Veto_Rights__c == true ) ){
                 vetoRejection = true;
                 return;
               }
               
               
               if( loggedInSocialPeople.Stance_Approval_status__c   == 'Pending Approval' ){
                   advanceDecision = true; 
                   approveorReject(loggedInSocialPeople.Id );
                   if( [Select count() From ProcessInstanceWorkitem p where   p.ActorId =: Userinfo.getUserId() AND p.ProcessInstance.TargetObjectId =: loggedInSocialPeople.Id] == 0 )   
                   advanceDecision = false;
               }
               else{
                    approveorReject(loggedInSocialPeople.Id );
                    decision.Status__c = approvalAction == 'Approve'? 'Approved':'Rejected';
                    DecisionPhaseAdvance();
               }
               
            }
           
           
            
     
    }
    public  static  void approveorReject(Id loggedInSocialPeopleId )
    {
            Approval.ProcessWorkItemRequest processWorkItemRequest = new Approval.ProcessWorkItemRequest();
            ProcessInstanceWorkitem processInstanceWorkitem = [Select p.ProcessInstance.Status, p.ProcessInstance.TargetObjectId, p.ProcessInstanceId, p.Id, p.CreatedDate, p.CreatedBy.Name, p.CreatedById, p.Actor.Name, p.ActorId From ProcessInstanceWorkitem p where   p.ActorId =: Userinfo.getUserId() AND p.ProcessInstance.TargetObjectId =: loggedInSocialPeopleId];    
            
            //processWorkItemRequest = processInstanceWorkitem;        
            processWorkItemRequest.setWorkitemId(processInstanceWorkitem.id);
              
            processWorkItemRequest.setComments(decisionComment);
           
            processWorkItemRequest.setAction(approvalAction); 
            Approval.ProcessResult pr = Approval.process(processWorkItemRequest);
            decisionComment = '';
    }
    
     public  static  void approveorRejectVeto()
    {
            
            
            vetoRejection   = false;
            Social_Input__c loggedInSocialPeople = [Select id,Veto_Rights__c, Stance_Approval_status__c,Final_Approval_status__c from Social_Input__c where User__c =: Userinfo.getUserId() and Decision__c = : decision.id ];
            Approval.ProcessWorkItemRequest processWorkItemRequest = new Approval.ProcessWorkItemRequest();
            ProcessInstanceWorkitem processInstanceWorkitem = [Select p.ProcessInstance.Status, p.ProcessInstance.TargetObjectId, p.ProcessInstanceId, p.Id, p.CreatedDate, p.CreatedBy.Name, p.CreatedById, p.Actor.Name, p.ActorId From ProcessInstanceWorkitem p where   p.ActorId =: Userinfo.getUserId() AND p.ProcessInstance.TargetObjectId =: loggedInSocialPeople.Id];    
            
            //processWorkItemRequest = processInstanceWorkitem;        
            processWorkItemRequest.setWorkitemId(processInstanceWorkitem.id);
              
            processWorkItemRequest.setComments(decisionComment);
           
            processWorkItemRequest.setAction(approvalAction); 
            Approval.ProcessResult pr = Approval.process(processWorkItemRequest);
            decisionComment = '';
            adjustPhase();
    }
    
    public  static  Pagereference backToDecision(){
      return new Pagereference('/'+decision.id);
    }
    public  static  void adjustPhase(){
    
         decisionCurentPhase = [Select  Phase__c,status__c  from Decision__c where id =: decision.id].Phase__c  ;
         if(decision.phase__c == 'Draft'){
            decision.phase__c = 'Share';        
         }
         else
         if(decision.phase__c == 'Share'){
            decision.phase__c = 'Propose';      
         }
         else
         if(decision.phase__c == 'Propose'){
            decision.phase__c = 'Decide';       
         }
         else
         if(decision.phase__c == 'Decide'  ){
            if( decision.status__c  == 'Approved')            
            decision.phase__c = 'Execute';
            else
            decision.phase__c = 'Close';     
         }
         else
         if(decision.phase__c == 'Execute'){
            decision.phase__c = 'Evaluate';         
         }
         else
         if(decision.phase__c == 'Evaluate'){
            decision.phase__c = 'Close';        
         }
         else
         if(decision.phase__c == 'Close'){
            decision.phase__c = 'Share';        
         } 
    }
}