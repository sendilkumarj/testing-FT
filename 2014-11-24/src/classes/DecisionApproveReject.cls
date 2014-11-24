Public class DecisionApproveReject{
   Public String decisionComment{get;set;} 
   Public String approvalAction{get;set;}   
   Public String pageURL{get;set;}   
   Public Decision__c decision {get;set;}
   Public Social_Input__c sin{get;set;}
   Public boolean approvedRejected{get;set;}
   Public boolean alreadyApproved{get;set;}
   
   public DecisionApproveReject(ApexPages.StandardController controller) {
         approvedRejected  = false;
         alreadyApproved   = false;
         sin = (Social_Input__c )controller.getRecord();
         sin =  [Select id , Decision__c, Stance_Approval_status__c, Final_Approval_status__c from Social_Input__c where id =: sin.id];
         decision = [Select id ,Title__c,Reason_for_Close__c , Phase__c ,Decision_Taken__c,Problem_Idea_Advice__c,  Decision__c from Decision__c where id =: sin.decision__c];
         if( [Select count() From ProcessInstanceWorkitem p where   p.ActorId =: Userinfo.getUserId() AND p.ProcessInstance.TargetObjectId =: sin.Id] > 0 )
         alreadyApproved = true;
     }
   public void approvedReject()
   {       
            approvedRejected   = true;
            Approval.ProcessWorkItemRequest processWorkItemRequest = new Approval.ProcessWorkItemRequest();
            ProcessInstanceWorkitem processInstanceWorkitem = [Select p.ProcessInstance.Status, p.ProcessInstance.TargetObjectId, p.ProcessInstanceId, p.Id, p.CreatedDate, p.CreatedBy.Name, p.CreatedById, p.Actor.Name, p.ActorId From ProcessInstanceWorkitem p where   p.ActorId =: Userinfo.getUserId() AND p.ProcessInstance.TargetObjectId =: sin.Id];    
            
            //processWorkItemRequest = processInstanceWorkitem;        
            processWorkItemRequest.setWorkitemId(processInstanceWorkitem.id);
              
            processWorkItemRequest.setComments(decisionComment);
           
            processWorkItemRequest.setAction(approvalAction); 
            Approval.ProcessResult pr = Approval.process(processWorkItemRequest);
            approvedRejected = true;
      
    }
    
}