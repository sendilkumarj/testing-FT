public with sharing class HomePageMobile {
    Public string homeJson{get;set;}
    public static GeneralInformation genralInfo;
    Public static Decision__c decision{get;set;}
    Public static Map<String,String> decisionAttachmentids{get;set;}
    Public static string approvalListJson{get;set;}
    public static string  userLocaleSidKey{get;set;}
    static{
            //set user locale here
            userLocaleSidKey  = UserInfo.getLocale().replace('_','-');
    }
    Public HomePageMobile()
    {
       homeJson =   homePageData('All')  ; 
        approvalListJson = '[{priority:\'High\', subject:\'MARKETING: Do we need a new Responsive website?\', duedate:\'17.10.2013 18:00\', deadline:\'5 Days\', role:\'R, A\', reqby:\'Walter Canchalo\', type:\'Support / Oppose\'}]';
    }
    @RemoteAction
    Public static string homePageData(String timeSelected)
    {       
            if(genralInfo == null ) {
                genralInfo  = new GeneralInformation();
            }
            String dateTimeFormat = genralInfo.MapValuesDateTime();
            DateTime todaysDatetime = DateTime.now();
            // These conditions are based on user slected dropdown  
            if(timeSelected == '24hours'){
                todaysDatetime = todaysDatetime.addDays(1); 
            } else if(timeSelected == '48hours'){
                todaysDatetime = todaysDatetime.addDays(2);
            } else if(timeSelected == '' || timeSelected == '7days'){
                todaysDatetime = todaysDatetime.addDays(7);
            } else if(timeSelected == '1month'){
                todaysDatetime = todaysDatetime.addMonths(1);
            } else if(timeSelected == 'All'){
                todaysDatetime = todaysDatetime.addYears(10); 
            }
            
           Date  todaysDate = date.newinstance(todaysDatetime.year(), todaysDatetime.month(), todaysDatetime.day());
          
           System.debug(todaysDatetime);
           System.debug(todaysDate);
           List<Social_Input__c> myUrgentDecisionList = new List<Social_Input__c>();
           List<Task> urgentTaskList = new List<Task>();
          
           Map<Id,Social_Input__c> socialInputMap = new map<Id,Social_Input__c>();
           if(timeSelected == 'All'){
                // This query is used when user selects "All" from the drop down, which will query all the records even when due date is null
                myUrgentDecisionList = [select id  from Social_Input__c where User__c =: UserInfo.getUserId() and (Accountable__c = true or Backup_for_Accountable__c = true) and Decision__r.phase__c != 'Close'  order by Decision__r.Nearest_Due_Date__c DESC NULLS LAST limit 25];
            } else {
                myUrgentDecisionList = [select id  from Social_Input__c where User__c =: UserInfo.getUserId() and (Accountable__c = true or Backup_for_Accountable__c = true) and Decision__r.Nearest_Due_Date__c != null and Decision__r.Nearest_Due_Date__c <=: todaysDatetime and Decision__r.phase__c != 'Close'   order by Decision__r.Nearest_Due_Date__c DESC limit 25 ]; 
            } 
            
            if(timeSelected == 'All'){ 
                 System.debug('A');
                // This query is used when user selects "All" from the drop down, which will query all the records even when due date is null
                urgentTaskList = [Select t.Id  From Task t where t.Owner.id =: UserInfo.getUserId()  and t.IsClosed = false  order by t.ActivityDate DESC NULLS LAST limit 25];
            } else {
                 System.debug('B');
                urgentTaskList = [Select t.Id  From Task t where t.ActivityDate <=: todaysDate and t.Owner.id =: UserInfo.getUserId()   and t.IsClosed = false  order by t.ActivityDate DESC,  id limit 25];
            }  
             
            if(timeSelected == 'All'){ 
                // This query is used when user selects "All" from the drop down, which will query all the records even when due date is null
                socialInputMap = new map<Id,Social_Input__c> ([Select  id From Social_Input__c s where Role_Acceptance_Status__c =:'Approved/Accepted' and  s.User__c =: userInfo.getUserId() and s.Decision__c != null order by s.Decision__r.Due_Date__c,s.Decision__r.LastModifiedDate DESC NULLS LAST ]);
            } else {
                socialInputMap = new map<Id,Social_Input__c> ([Select  id From Social_Input__c s where Role_Acceptance_Status__c =:'Approved/Accepted' and  s.User__c =: userInfo.getUserId() and s.Decision__c != null and s.Decision__r.Nearest_Due_Date__c !=null and s.Decision__r.Nearest_Due_Date__c <=: todaysDatetime order by s.Decision__r.Due_Date__c DESC ]);
            }
            List<ProcessInstanceWorkitem> ProcessInstanceWorkitemList = [Select p.ProcessInstance.Status, p.ProcessInstance.TargetObjectId, p.ProcessInstanceId, p.Id, p.CreatedDate, p.CreatedBy.Name, p.CreatedById, p.Actor.Name, p.ActorId From ProcessInstanceWorkitem p where  p.ActorId =: Userinfo.getUserId() AND p.ProcessInstance.TargetObjectId IN: socialInputMap.keyset() order by p.CreatedDate desc limit 25];
            Integer countApproval  =  [Select  count() From ProcessInstanceWorkitem p where  p.ActorId =: Userinfo.getUserId() AND p.ProcessInstance.TargetObjectId IN: socialInputMap.keyset() ];
            
            
            HomeData  data          = new HomeData();
            data.numberOfDecisions  = myUrgentDecisionList.size();
            data.numberOfApprovals  =  countApproval > 25 ? '25 +': String.valueOf(ProcessInstanceWorkitemList.size()); 
            data.numberOfTasks      = urgentTaskList.size();
            return JSON.serialize(data);
    }
    
    public class HomeData
    {
         Public integer numberOfTasks{get;set;}
         Public string numberOfApprovals{get;set;}
         Public integer numberOfDecisions{get;set;}
    }
    
    public class ApprovalsListData implements Comparable
    {    Public String id{get;set;}
         Public String subject{get;set;}
         Public integer deadline{get;set;}
         Public String priority{get;set;}
         Public String title{get;set;}
         Public String decisionImage{get;set;}
         Public String duedate{get;set;}
         Public String requestedPhoto{get;set;}
         Public String nameOfRequeste{get;set;}
         Public String typeOfApproval{get;set;}
         Public String approvalStatus{get;set;}
         Public String decisionId{get;set;}
         Public String socialInputId{get;set;}
         Public String role{get;set;}
         Public String progressIndicator{get;set;}
         Public String status{get;set;}
         Public String myStance{get;set;}
         public Integer compareTo(Object compareTo)    
         {
                 ApprovalsListData appdata = (ApprovalsListData) compareTo; 
                 if (   this.deadline  ==   appdata.deadline   )
                  return 0;
                 if (  this.deadline   >   appdata.deadline  )
                  return 1;  
                  return -1; 
         }        
          
    } 
    
     @RemoteAction
    Public static string listApprovals(String timeSelected)
    {       Map<Id,Social_Input__c> socialInputMap = new map<Id,Social_Input__c>(); 
            decisionAttachmentids = new map<String,String>();            
            Set<string> decsionIds = new Set<string>();
            if(genralInfo == null ) {
                genralInfo  = new GeneralInformation();
            }
            System.debug('-----------------------------------'); 
                String dateTimeFormat = genralInfo.MapValuesDateTime();
                
            DateTime todaysDatetime = DateTime.now();
            // These conditions are based on user slected dropdown  
            if(timeSelected == '24hours'){
                todaysDatetime = todaysDatetime.addDays(1); 
            } else if(timeSelected == '48hours'){
                todaysDatetime = todaysDatetime.addDays(2);
            } else if(timeSelected == '' || timeSelected == '7days'){
                todaysDatetime = todaysDatetime.addDays(7);
            } else if(timeSelected == '1month'){
                todaysDatetime = todaysDatetime.addMonths(1);
            } else if(timeSelected == 'All'){
                todaysDatetime = todaysDatetime.addYears(10); 
            }  
            
            Date  todaysDate = date.newinstance(todaysDatetime.year(), todaysDatetime.month(), todaysDatetime.day());
            List<Social_Input__c> myUrgentDecisionList = new List<Social_Input__c>();
           
            if(timeSelected == 'All'){
                // This query is used when user selects "All" from the drop down, which will query all the records even when due date is null
                socialInputMap = new map<Id,Social_Input__c> ([Select Decision__r.Status__c,Decision__r.Progress__c,s.Role__c,s.Decision__r.Due_Date__c,s.Decision__r.Title__c,s.Final_Approval_Status__c , s.Decision__c , s.User__r.Name, s.Stance_Approval_Status__c, s.User__c, s.Role_Acceptance_Status__c  From Social_Input__c s where Role_Acceptance_Status__c =:'Approved/Accepted' and  s.User__c =: userInfo.getUserId() and s.Decision__c != null order by s.Decision__r.Due_Date__c,s.Decision__r.LastModifiedDate DESC NULLS LAST]);
            } 
            else if( timeSelected == 'overdue'){ 
                socialInputMap = new map<Id,Social_Input__c> ([Select Decision__r.Progress__c,s.Role__c,s.Decision__r.Due_Date__c,s.Decision__r.Title__c,s.Final_Approval_Status__c, s.Decision__c , s.User__r.Name, s.Stance_Approval_Status__c, s.User__c, s.Role_Acceptance_Status__c  From Social_Input__c s where Role_Acceptance_Status__c =:'Approved/Accepted' and s.User__c =: userInfo.getUserId() and s.Decision__c != null and s.Decision__r.Due_Date__c !=null and s.Decision__r.Due_Date__c<: Date.today() order by s.Decision__r.Due_Date__c DESC NULLS LAST]);
                List<ProcessInstanceWorkitem>  piwList = [Select  p.ProcessInstance.Status, p.ProcessInstance.TargetObjectId, p.ProcessInstanceId, p.Id, p.CreatedDate, p.CreatedBy.Name, p.CreatedById, p.Actor.Name, p.ActorId From ProcessInstanceWorkitem p where  p.ActorId =: Userinfo.getUserId() AND p.ProcessInstance.TargetObjectId IN: socialInputMap.keyset() order by p.CreatedDate desc ];
                if(piwList.size() < 10 ){
                Integer queryLimit = ( 20 - piwList.size()   );
                socialInputMap = new map<Id,Social_Input__c> ([Select Decision__r.Status__c,Decision__r.Progress__c,s.Role__c,s.Decision__r.Due_Date__c,s.Decision__r.Title__c,s.Final_Approval_Status__c, s.Decision__c , s.User__r.Name, s.Stance_Approval_Status__c, s.User__c, s.Role_Acceptance_Status__c  From Social_Input__c s where Role_Acceptance_Status__c =:'Approved/Accepted' and s.User__c =: userInfo.getUserId() and s.Decision__c != null and s.Decision__r.Due_Date__c!=null and s.Decision__r.Due_Date__c <=: todaysDatetime.addMonths(1) order by s.Decision__r.Due_Date__c DESC limit : queryLimit ]);
                
             } 
            }
            else {
                socialInputMap = new map<Id,Social_Input__c> ([Select Decision__r.Progress__c,s.Role__c,s.Decision__r.Due_Date__c,s.Decision__r.Title__c,s.Final_Approval_Status__c, s.Decision__c , s.User__r.Name, s.Stance_Approval_Status__c, s.User__c, s.Role_Acceptance_Status__c  From Social_Input__c s where Role_Acceptance_Status__c =:'Approved/Accepted' and  s.User__c =: userInfo.getUserId() and s.Decision__c != null and s.Decision__r.Due_Date__c !=null and s.Decision__r.Due_Date__c >=: Date.today() and s.Decision__r.Due_Date__c<=: todaysDatetime order by s.Decision__r.Due_Date__c DESC]);
                List<ProcessInstanceWorkitem>  piwList = [Select  p.ProcessInstance.Status, p.ProcessInstance.TargetObjectId, p.ProcessInstanceId, p.Id, p.CreatedDate, p.CreatedBy.Name, p.CreatedById, p.Actor.Name, p.ActorId From ProcessInstanceWorkitem p where  p.ActorId =: Userinfo.getUserId() AND p.ProcessInstance.TargetObjectId IN: socialInputMap.keyset() order by p.CreatedDate desc ];
                if(piwList.size() < 10 ){
                Integer queryLimit = ( 20 - piwList.size()   );
                socialInputMap = new map<Id,Social_Input__c> ([Select Decision__r.Status__c,Decision__r.Progress__c,s.Role__c,s.Decision__r.Due_Date__c,s.Decision__r.Title__c,s.Final_Approval_Status__c, s.Decision__c , s.User__r.Name, s.Stance_Approval_Status__c, s.User__c, s.Role_Acceptance_Status__c  From Social_Input__c s where  Role_Acceptance_Status__c =:'Approved/Accepted' and  s.User__c =: userInfo.getUserId() and s.Decision__c != null and s.Decision__r.Due_Date__c !=null  and s.Decision__r.Due_Date__c>=: Date.today() and s.Decision__r.Due_Date__c<=: todaysDatetime.addMonths(1) order by s.Decision__r.Due_Date__c DESC limit : queryLimit ]);
               
                } 
                
            }
            
            ///integer.valueOf('a'+ timeSelected);
            for(Social_Input__c socialInput :socialInputMap.values() ){
              decsionIds.add( socialInput.Decision__c  ); 
            }
            Map<id,Decision__c> DecisionMap = new Map<id,Decision__c>([Select id,Status__c,Progress__c ,Title__c,Priority__c,owner.name from Decision__c where id in: decsionIds]);
            Map<id,Decision__c> socialToDecisionMap = new Map<id,Decision__c>();
            for(social_Input__C  sc: socialInputMap.values())
            {
                socialToDecisionMap.put(Sc.id, DecisionMap.get( sc.Decision__c));
            }
            System.debug(decsionIds);
            // List<Attachment> attachments = [select id ,Name from Attachment WHERE ParentID in : decsionIds  AND Name in : decsionIds];
            //for(Attachment image : attachments ){
            //    decisionAttachmentids.put(image.Name,image.id );
            //}  
           
            System.debug('-----'+decisionAttachmentids);
            List<ApprovalsListData> approvalWrapperList = new List<ApprovalsListData>();
            for(ProcessInstanceWorkitem piw : [Select  p.ProcessInstance.Status, p.ProcessInstance.TargetObjectId, p.ProcessInstanceId, p.Id, p.CreatedDate, p.CreatedBy.Name, p.CreatedById, p.Actor.Name, p.ActorId From ProcessInstanceWorkitem p where  p.ActorId =: Userinfo.getUserId() AND p.ProcessInstance.TargetObjectId IN: socialInputMap.keyset() order by p.CreatedDate DESC NULLS LAST ]) {
               Social_Input__c loggedInSocialPeople = socialInputMap.get(piw.ProcessInstance.TargetObjectId);
               if(loggedInSocialPeople.Final_Approval_Status__c != null || loggedInSocialPeople.Stance_Approval_Status__c != null){
                    ApprovalsListData aw = new ApprovalsListData();
                    aw.id                = piw.Id;
                    aw.title             = loggedInSocialPeople.Decision__r.Title__c;
                    aw.duedate           = loggedInSocialPeople.Decision__r.Due_Date__c != null ? String.valueOf(loggedInSocialPeople.Decision__r.Due_Date__c.format(dateTimeFormat)):''; //.format(dateTimeFormat);
                  //  aw.decisionImage     = decisionAttachmentids.get( loggedInSocialPeople.Decision__c) != null ? '/servlet/servlet.FileDownload?file='+decisionAttachmentids.get( loggedInSocialPeople.Decision__c) : '';
                    aw.requestedPhoto    = loggedInSocialPeople.User__c != null ? genralInfo.useImage.get(loggedInSocialPeople.User__c) : '/'+ genralInfo.imageUrlMap.get('group');
                    aw.typeOfApproval    = loggedInSocialPeople.Role_Acceptance_Status__c == 'Pending Approval' ?  'Role' : (  loggedInSocialPeople.Stance_Approval_Status__c == 'Pending Approval' ? 'Stance': ( loggedInSocialPeople.Final_Approval_Status__c == 'Pending Approval' ) ? 'Decision': 'NONE' );
                    aw.approvalStatus    = piw.ProcessInstance.Status;
                    aw.decisionId        = loggedInSocialPeople.Decision__c;
                    aw.socialInputId     = loggedInSocialPeople.id;
                    aw.nameOfRequeste    = socialToDecisionMap.get(String.valueOf(piw.ProcessInstance.TargetObjectId)).owner.name;
                    aw.priority          =  socialToDecisionMap.get(String.valueOf(piw.ProcessInstance.TargetObjectId)).Priority__c; 
                    aw.subject           =  socialToDecisionMap.get(String.valueOf(piw.ProcessInstance.TargetObjectId)).Title__c;  
                    if( loggedInSocialPeople.Decision__r.Due_Date__c  != null )
                    aw.deadline          =   Date.today().daysbetween( date.newinstance(loggedInSocialPeople.Decision__r.Due_Date__c.year(), loggedInSocialPeople.Decision__r.Due_Date__c.month(), loggedInSocialPeople.Decision__r.Due_Date__c.day()) )   ;
                    
                    aw.role              = loggedInSocialPeople.Role__c.replaceAll('Accountable','A').replaceAll('Responsible','R').replaceAll('Consulted','C').replaceAll('Informed','I').replaceAll(' ',''); 
                    aw.progressIndicator = loggedInSocialPeople.Decision__r.Progress__c;
                    aw.status   = loggedInSocialPeople.Decision__r.Status__c;
                    aw.myStance =  loggedInSocialPeople.Stance_Approval_Status__c;
                    approvalWrapperList.add(aw);     
                }       
            }
            return JSON.serialize(approvalWrapperList);  
    } 
    
    
      // decision Approva /reject
    @RemoteAction
    public static  String approvedReject(String decisionId, String processInstanceitemId, String action, String comment ) {
            String newComment = comment;
            Social_Input__c logedInsocialInput = [Select  s.Role__c , s.Role_Acceptance_Status__c , s.Accountable__c, s.Backup_for_Accountable__c, s.Responsible__c,s.Consulted__c,s.Informed__c,s.Veto_Rights__c,s.Stance_Approval_Status__c,s.Final_Approval_Status__c   From Social_Input__c s where s.Decision__c =: decisionId and s.User__c =: userInfo.getUserId() limit 1];
            Approval.ProcessWorkItemRequest processWorkItemRequest = new Approval.ProcessWorkItemRequest();
            ProcessInstanceWorkitem processInstanceWorkitem = [Select p.ProcessInstance.Status, p.ProcessInstance.TargetObjectId, p.ProcessInstanceId, p.Id, p.CreatedDate, p.CreatedBy.Name, p.CreatedById, p.Actor.Name, p.ActorId From ProcessInstanceWorkitem p where  p.id=: processInstanceitemId];    
            
            //processWorkItemRequest = processInstanceWorkitem;        
            processWorkItemRequest.setWorkitemId(processInstanceWorkitem.id);
            System.debug('-----Checking comments in approval------------------'+newComment+'-----------------------'+comment);
             
            processWorkItemRequest.setComments(comment);
           
            processWorkItemRequest.setAction(action); 
            Approval.ProcessResult pr = Approval.process(processWorkItemRequest);
            
            
           
            decision = [select id, Name, Phase__c, Status__c ,ownerid from Decision__c where Id =: decisionId];
            
            Social_Input__c socialInput = [Select s.Veto_Rights__c, s.User__c,s.Stance_Approval_Status__c, s.SystemModstamp, s.SYS_Tab_View_Activites__c, s.SYS_Tab_View_History__c, s.SYS_Tab_View_Tasks__c, s.SYS_Tab_View_Social_Input__c, s.SYS_Tab_View_Relations__c, s.SYS_Tab_View_Quality__c, s.SYS_Tab_View_Attachments__c, s.SYS_Tab_View_Approvals__c, s.Role_Acceptance_Status__c, s.Role_Acceptance_Required__c, s.Result__c, s.Responsible__c, s.Rating__c, s.Outcome__c, s.Name, s.Mood__c, s.Like__c, s.LastModifiedDate, s.LastModifiedById, s.Informed__c, s.Id, s.Final_Approval_Status__c, s.Effort__c, s.Dislike__c, s.Decision__c, s.CreatedDate, s.CreatedById, s.Consulted__c, s.Backup_for_Accountable__c, s.Approved_for__c, s.Accountable__c From Social_Input__c s where s.Id =: processInstanceWorkitem.ProcessInstance.TargetObjectId ];
            //If the current user approves stance or final decison a chatter post is created.
            String roleString  =  '';
            String proposeChatterPostId = '';
            // Checks for logged in users role status
            if( logedInsocialInput.Role_Acceptance_Status__c == 'Approved/Accepted'  ){
            	  Decision__c decisionQryUpdated  =[select id,FeedItem_Id_Propose__c from Decision__c where id =:decision.Id Limit 1];
                  proposeChatterPostId  =  decisionQryUpdated.FeedItem_Id_Propose__c; 
               /* List<Decision__Feed> feedList = [ Select id,title from Decision__Feed where parentId=:decision.Id order by createddate desc ];
                for( Decision__Feed feed:feedList)
                {
                    if( feed.title ==  String.valueOf(decision.id ) )
                    {
                        proposeChatterPostId = feed.id;
                        break;
                    }
                } 
                //if no propose chatter post exist then create new one and make comment.
                if( proposeChatterPostId == ''){
                
                    /*FeedItem post = new FeedItem();
                    post.ParentId =  decision.Id;  
                    post.Body =      'The decision has been proposed'  ;
                    post.type = 'TextPost';                   
                    post.Title = decision.id;  
                    post.createdbyid = decision.ownerid;
                    if( FLS.FeedItemCreatable()) 
                    insert post; 
                    proposeChatterPostId  =  post.id;
                    
                    Decision__c decisionQry  =[select id,Problem_Idea_Advice__c,Decision_Taken__c,ownerid from Decision__c where id =:decision.id Limit 1];
                    Id userId=decision.ownerid;
                    User usr = [Select id,name from User where id=:decisionQry.ownerid Limit 1];
                    //String postText='The following decision has been proposed:'+'\n'+'\n'+'"'+decisionQry.Decision_Taken__c+'"'+'\n'+'\n'+usr.name+' '+'needs your personal stance.';
                    String postText='Here is the proposed Decision, read it and give your Stance.'+'\n'+'\n'+'Decision:'+'\n'+'"'+decisionQry.Decision_Taken__c+'"'+'\n'+'\n'+'(hint: it’s done in the command center)';
                    DecisionView.mentionTextPost( usr.id, postText, decision.id);
                    Decision__c decisionQryUpdated  =[select id,FeedItem_Id__c from Decision__c where id =:decisionId Limit 1];
                    proposeChatterPostId  =  decisionQryUpdated.FeedItem_Id__c; 
                }*/
                // Creates a feed comment
                if(proposeChatterPostId != null){
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
            }
            //if current user rejected stance create a chatter post for decision rejection
            if( logedInsocialInput.Role_Acceptance_Status__c == 'Approved/Accepted' && socialInput.Stance_Approval_Status__c == 'Rejected' && socialInput.Veto_Rights__c && action == 'Reject' ) 
            {
                        
                       Decision__c decisionQryUpdated  =[select id,FeedItem_Id_Propose__c from Decision__c where id =:decision.Id Limit 1];
                  	   proposeChatterPostId  =  decisionQryUpdated.FeedItem_Id_Propose__c; 
                       /* List<Decision__Feed> feedList = [ Select id,title from Decision__Feed where parentId=:decision.Id order by createddate desc ];
                        for( Decision__Feed feed:feedList)
                        {
                            if( feed.title ==  String.valueOf(decision.id ) )
                            {
                                proposeChatterPostId = feed.id;
                                break;
                            }
                        }*/
                        // Creates a feed comment 
                        if(proposeChatterPostId != null){
	                        FeedComment chatterComment = new FeedComment();
	                        chatterComment.feedItemId =  proposeChatterPostId;  
	                        comment = comment.length() > 1000 ? comment.substring(0,890) + '...':comment;
	                        // Display chatter comment to show loggedin use has Rejected the decision with  his role and comments provided in stance
	                        chatterComment.CommentBody =    'Has rejected the Decision'   + ' as '+  roleString +   (    (  comment != null &&( comment.trim().length() != 0 ) ) ?'\nwith Comment:\n \"' +comment +'\".' : '.' );
	                        if( FLS.FeedItemCreatable())    
	                        insert chatterComment;   
                        }    
             }
            
                  
            
         
            return listApprovals('All');
       }  
               
       Public static string updatedApproval(String socialInputId)
       {         
               
               Social_Input__c loggedInSocialPeople = [Select Decision__r.Progress__c,s.Decision__r.owner.name, s.Decision__r.Due_Date__c,s.Decision__r.Title__c,s.Final_Approval_Status__c , s.Decision__c , s.User__r.Name, s.Stance_Approval_Status__c, s.User__c, s.Role_Acceptance_Status__c  From Social_Input__c s where   id =: socialInputId ] ;
               if(genralInfo == null ) {
                  genralInfo  = new GeneralInformation();
               }
               String dateTimeFormat = genralInfo.MapValuesDateTime();
               ApprovalsListData aw = new ApprovalsListData();           
               for(ProcessInstanceWorkitem piw : [Select p.ProcessInstance.Status, p.ProcessInstance.TargetObjectId, p.ProcessInstanceId, p.Id, p.CreatedDate, p.CreatedBy.Name, p.CreatedById, p.Actor.Name, p.ActorId From ProcessInstanceWorkitem p where  p.ActorId =: Userinfo.getUserId() AND p.ProcessInstance.TargetObjectId =: loggedInSocialPeople.id order by p.CreatedDate desc limit 100]) {
               if(loggedInSocialPeople.Final_Approval_Status__c != null || loggedInSocialPeople.Stance_Approval_Status__c != null){
                   
                    aw.id                = piw.Id;
                    aw.title             = loggedInSocialPeople.Decision__r.Title__c;
                    aw.duedate           = loggedInSocialPeople.Decision__r.Due_Date__c != null ? String.valueOf(loggedInSocialPeople.Decision__r.Due_Date__c.format(dateTimeFormat)):''; //.format(dateTimeFormat);
                   //    aw.decisionImage     = decisionAttachmentids.get( loggedInSocialPeople.Decision__c) != null ? '/servlet/servlet.FileDownload?file='+decisionAttachmentids.get( loggedInSocialPeople.Decision__c) : '';
                    aw.requestedPhoto    = loggedInSocialPeople.User__c != null ? genralInfo.useImage.get(loggedInSocialPeople.User__c) : '/'+ genralInfo.imageUrlMap.get('group');
                    aw.typeOfApproval    = loggedInSocialPeople.Role_Acceptance_Status__c == 'Pending Approval' ?  'Role' : (  loggedInSocialPeople.Stance_Approval_Status__c == 'Pending Approval' ? 'Stance': ( loggedInSocialPeople.Final_Approval_Status__c == 'Pending Approval' ) ? 'Decision': 'NONE' );
                    aw.approvalStatus    = piw.ProcessInstance.Status;
                    aw.decisionId        = loggedInSocialPeople.Decision__c;
                    aw.socialInputId     = loggedInSocialPeople.id;
                    aw.nameOfRequeste    = loggedInSocialPeople.Decision__r.owner.name;
                   aw.progressIndicator = loggedInSocialPeople.Decision__r.Progress__c;
                }       
            }
            return  JSON.serialize(aw);  
      } 
      
      
      public static string listOfDecisionJSON{get;set;}
      
       @RemoteAction
    Public static string listDecisions(String timeSelected){
           Map<Id,Social_Input__c> socialInputMap = new map<Id,Social_Input__c>(); 
            decisionAttachmentids = new map<String,String>();            
            if(genralInfo == null ) {
                genralInfo  = new GeneralInformation();
            }
            System.debug('-----------------------------------'); 
                String dateTimeFormat = genralInfo.MapValuesDateTime();
                
            DateTime todaysDatetime = DateTime.now();
            // These conditions are based on user slected dropdown  
            if(timeSelected == '24hours'){
                todaysDatetime = todaysDatetime.addDays(1); 
            } else if(timeSelected == '48hours'){
                todaysDatetime = todaysDatetime.addDays(2);
            } else if(timeSelected == '' || timeSelected == '7days'){
                todaysDatetime = todaysDatetime.addDays(7);
            } else if(timeSelected == '1month'){
                todaysDatetime = todaysDatetime.addMonths(1);
            } else if(timeSelected == 'All'){
                todaysDatetime = todaysDatetime.addYears(10); 
            }
            
            Date  todaysDate = date.newinstance(todaysDatetime.year(), todaysDatetime.month(), todaysDatetime.day());
           
            if(timeSelected == 'All'){
                // This query is used when user selects "All" from the drop down, which will query all the records even when due date is null
                socialInputMap = new map<Id,Social_Input__c> ([Select  Decision__r.Progress__c,Decision__r.Priority__c,Decision__r.Status__c,Decision__r.OwnerId ,Decision__r.LastModifiedDate,Decision__r.Nearest_Due_Date__c,Decision__r.Phase__c,Decision__r.Decision_Taken__c ,s.Role__c,Decision__r.Problem_Idea_Advice__c,s.Decision__r.Due_Date__c,s.Decision__r.Title__c,s.Final_Approval_Status__c , s.Decision__c , s.User__r.Name, s.Stance_Approval_Status__c, s.User__c, s.Role_Acceptance_Status__c  From Social_Input__c s where  s.User__c =: userInfo.getUserId() and (Accountable__c = true or Backup_for_Accountable__c = true or Responsible__c = true) and s.Decision__c != null order by s.Decision__r.lastModifiedDate DESC NULLS LAST limit 25 ]);
            }  
            else if( timeSelected == 'overdue'){ 
                socialInputMap = new map<Id,Social_Input__c> ([Select Decision__r.Progress__c,Decision__r.Priority__c,Decision__r.Status__c,Decision__r.OwnerId ,Decision__r.LastModifiedDate,Decision__r.Nearest_Due_Date__c,Decision__r.Phase__c,Decision__r.Decision_Taken__c ,s.Role__c,Decision__r.Problem_Idea_Advice__c,s.Decision__r.Due_Date__c,s.Decision__r.Title__c,s.Final_Approval_Status__c, s.Decision__c , s.User__r.Name, s.Stance_Approval_Status__c, s.User__c, s.Role_Acceptance_Status__c  From Social_Input__c s where  s.User__c =: userInfo.getUserId() and (Accountable__c = true or Backup_for_Accountable__c = true or Responsible__c = true) and s.Decision__c != null and s.Decision__r.Due_Date__c !=null and s.Decision__r.Due_Date__c<: Date.today() order by s.Decision__r.Due_Date__c DESC NULLS LAST limit 25]);
            }
            else {
                socialInputMap = new map<Id,Social_Input__c> ([Select Decision__r.Progress__c,Decision__r.Priority__c,Decision__r.Status__c,Decision__r.OwnerId ,Decision__r.LastModifiedDate,Decision__r.Nearest_Due_Date__c,Decision__r.Phase__c,Decision__r.Decision_Taken__c ,s.Role__c,Decision__r.Problem_Idea_Advice__c,s.Decision__r.Due_Date__c,s.Decision__r.Title__c,s.Final_Approval_Status__c, s.Decision__c , s.User__r.Name, s.Stance_Approval_Status__c, s.User__c, s.Role_Acceptance_Status__c  From Social_Input__c s where  s.User__c =: userInfo.getUserId() and (Accountable__c = true or Backup_for_Accountable__c = true or Responsible__c = true) and s.Decision__c != null and s.Decision__r.Due_Date__c !=null and s.Decision__r.Due_Date__c >=: Date.today() and s.Decision__r.Due_Date__c<=: todaysDatetime order by s.Decision__r.Due_Date__c DESC NULLS LAST limit 25]);
            }
            
            
           List<DecisionCardWrapper> decisionWrapperList = new List<DecisionCardWrapper>();
            for(Social_Input__c s: socialInputMap.values()){
                if(s.Decision__c != null && s.Decision__r.Title__c != null){
                    DecisionCardWrapper  u = new DecisionCardWrapper(); 
                    u.Id = s.Id;
                    u.decisionId = s.Decision__c;
                    System.debug('----s.Decision__c------'+s.Decision__c);
                    u.decisionTitle = s.Decision__r.Title__c;
                    u.problemStatement = s.Decision__r.Problem_Idea_Advice__c;
                    u.decisionTaken = s.Decision__r.Decision_Taken__c != null ? s.Decision__r.Decision_Taken__c : '';
                    u.phase = s.Decision__r.Phase__c;
                    u.phaseImg = genralInfo.imageUrlMap.get(s.Decision__r.Phase__c);
                    u.dueDate =  s.Decision__r.Nearest_Due_Date__c == null ? '' : String.valueOf(s.Decision__r.Nearest_Due_Date__c.format(dateTimeFormat)); //.format(dateTimeFormat);
                    u.role = s.Role__c.replaceAll('Accountable','A').replaceAll('Responsible','R').replaceAll('Consulted','C').replaceAll('Informed','I').replaceAll(' ',''); 
                    u.ownerId = s.Decision__r.OwnerId;
                    System.debug('------s.Decision__r.OwnerId-------'+s.Decision__r.OwnerId);
                    u.ownerName = genralInfo != null && genralInfo.useNameMap != null && s.Decision__r.OwnerId != null && genralInfo.useNameMap.get(s.Decision__r.OwnerId) != null ? genralInfo.useNameMap.get(s.Decision__r.OwnerId).Name : '';
                    System.debug('------u.ownerName-------'+u.ownerName);
                   // start added on 22-4-2014
                    u.dueDateSort =  s.Decision__r.Nearest_Due_Date__c != null ? s.Decision__r.Nearest_Due_Date__c: null; //.format(dateTimeFormat); 
                    //end added on 22-4-2014
                    u.lastModified = s.Decision__r.LastModifiedDate;
                    
                    if( s.Decision__r.Due_Date__c  != null )
                     u.deadline = Date.today().daysbetween( date.newinstance(s.Decision__r.Due_Date__c.year(), s.Decision__r.Due_Date__c.month(), s.Decision__r.Due_Date__c.day()) )   ;
                    u.status = s.Decision__r.Status__c;
                    u.priority = s.Decision__r.Priority__c;
                    u.myStance     =  s.Stance_Approval_Status__c;
                    u.decisionProgress = s.Decision__r.Progress__c;
                    u.typeOfApproval    = s.Role_Acceptance_Status__c == 'Pending Approval' ?  'Role' : (  s.Stance_Approval_Status__c == 'Pending Approval' ? 'Stance': ( s.Final_Approval_Status__c == 'Pending Approval' ) ? 'Decision': 'NONE' );
                    u.progressIndicator = s.Decision__r.Progress__c;
                    u.lastModified = s.Decision__r.LastModifiedDate;
                    decisionWrapperList.add(u);
                }
            } 
            
             listOfDecisionJSON = JSON.serialize(decisionWrapperList); 
            
            return listOfDecisionJSON;
    }
    
    
    
    
       @RemoteAction
    Public static string detailsDecisions(String decisionId){
           Map<Id,Social_Input__c> socialInputMap = new map<Id,Social_Input__c>(); 
            decisionAttachmentids = new map<String,String>();            
          if(genralInfo == null ) {
                genralInfo  = new GeneralInformation();
            }
            System.debug('-----------------------------------'); 
                String dateTimeFormat = genralInfo.MapValuesDateTime();
            
           
                // This query is used when user selects "decisionId" from the drop down, which will query all the records even when due date is null
                socialInputMap = new map<Id,Social_Input__c> ([Select Decision__r.Progress__c,Decision__r.Priority__c,Decision__r.Status__c,Decision__r.OwnerId ,Decision__r.LastModifiedDate,Decision__r.Nearest_Due_Date__c,Decision__r.Phase__c,Decision__r.Decision_Taken__c ,s.Role__c,Decision__r.Problem_Idea_Advice__c,s.Decision__r.Due_Date__c,s.Decision__r.Title__c,s.Final_Approval_Status__c , s.Decision__c , s.User__r.Name, s.Stance_Approval_Status__c, s.User__c, s.Role_Acceptance_Status__c  From Social_Input__c s where  Decision__c = :decisionId AND s.User__c =: userInfo.getUserId() Limit 1]);
                 Social_Input__c loggedInSocialPeople =[select id from Social_Input__c where  Decision__c = :decisionId AND user__c =: Userinfo.getUserId()  Limit 1];
                // for fetch ProcessInstanceWorkitem id of  every loggedin user 
                ProcessInstanceWorkitem piw = new ProcessInstanceWorkitem();
                
                if([Select  p.ProcessInstance.Status, p.ProcessInstance.TargetObjectId, p.ProcessInstanceId, p.Id, p.CreatedDate, p.CreatedBy.Name, p.CreatedById, p.Actor.Name, p.ActorId From ProcessInstanceWorkitem p where  p.ActorId =: Userinfo.getUserId() AND p.ProcessInstance.TargetObjectId =: loggedInSocialPeople.Id Limit 1 ].size() > 0){
                    piw = [Select  p.ProcessInstance.Status, p.ProcessInstance.TargetObjectId, p.ProcessInstanceId, p.Id, p.CreatedDate, p.CreatedBy.Name, p.CreatedById, p.Actor.Name, p.ActorId From ProcessInstanceWorkitem p where  p.ActorId =: Userinfo.getUserId() AND p.ProcessInstance.TargetObjectId =: loggedInSocialPeople.Id Limit 1 ];
                }
           List<DecisionCardWrapper> decisionWrapperList = new List<DecisionCardWrapper>();
            for(Social_Input__c s: socialInputMap.values()){
                if(s.Decision__c != null && s.Decision__r.Title__c != null){
                    DecisionCardWrapper  u = new DecisionCardWrapper(); 
                    if(piw.id != null){
                        u.processInstanceWorkitem = piw.id;
                    }
                    u.Id = s.Id;
                    u.decisionId = s.Decision__c;
                    System.debug('----s.Decision__c------'+s.Decision__c);
                    u.decisionTitle = s.Decision__r.Title__c;
                    u.problemStatement = s.Decision__r.Problem_Idea_Advice__c;
                    u.decisionTaken = s.Decision__r.Decision_Taken__c != null ? s.Decision__r.Decision_Taken__c : '';
                    u.phase = s.Decision__r.Phase__c;
                    u.phaseImg = genralInfo.imageUrlMap.get(s.Decision__r.Phase__c);
                    u.dueDate =  s.Decision__r.Nearest_Due_Date__c == null ? '' : String.valueOf(s.Decision__r.Nearest_Due_Date__c.format(dateTimeFormat)); //.format(dateTimeFormat);
                    u.role = s.Role__c.replaceAll('Accountable','A').replaceAll('Responsible','R').replaceAll('Consulted','C').replaceAll('Informed','I').replaceAll(' ',''); 
                    u.ownerId = s.Decision__r.OwnerId;
                    System.debug('------s.Decision__r.OwnerId-------'+s.Decision__r.OwnerId);
                    u.ownerName = genralInfo != null && genralInfo.useNameMap != null && s.Decision__r.OwnerId != null && genralInfo.useNameMap.get(s.Decision__r.OwnerId) != null ? genralInfo.useNameMap.get(s.Decision__r.OwnerId).Name : '';
                    System.debug('------u.ownerName-------'+u.ownerName);
                   // start added on 22-4-2014
                    u.dueDateSort =  s.Decision__r.Nearest_Due_Date__c != null ? s.Decision__r.Nearest_Due_Date__c: null; //.format(dateTimeFormat); 
                    //end added on 22-4-2014
                    u.lastModified = s.Decision__r.LastModifiedDate;
                    
                    if( s.Decision__r.Due_Date__c  != null )
                     u.deadline = Date.today().daysbetween( date.newinstance(s.Decision__r.Due_Date__c.year(), s.Decision__r.Due_Date__c.month(), s.Decision__r.Due_Date__c.day()) )   ;
                    u.status = s.Decision__r.Status__c;
                    u.priority = s.Decision__r.Priority__c;
                    u.myStance     =  s.Stance_Approval_Status__c;
                    u.decisionProgress = s.Decision__r.Progress__c;
                    u.typeOfApproval    = s.Role_Acceptance_Status__c == 'Pending Approval' ?  'Role' : (  s.Stance_Approval_Status__c == 'Pending Approval' ? 'Stance': ( s.Final_Approval_Status__c == 'Pending Approval' ) ? 'Decision': 'NONE' );
                    u.progressIndicator = s.Decision__r.Progress__c;
                    decisionWrapperList.add(u);
                }
            } 
            
             listOfDecisionJSON = JSON.serialize(decisionWrapperList); 
            
            return listOfDecisionJSON;
    }
      
    
    
    
      
    @RemoteAction
    Public static string listTasks(String timeSelected)
    {
            List<Task> taskList  = new List<Task>();
            List<Task> allTaskList  = new List<Task>(); 
            Date  todaysDate = Date.today();
            if(genralInfo == null ) {
                  genralInfo  = new GeneralInformation();
            }
            if(timeSelected == '24hours'){
                todaysDate = todaysDate.addDays(1); 
            } else if(timeSelected == '48hours'){
                todaysDate = todaysDate.addDays(2);
            } else if(timeSelected == '' || timeSelected == '7days'){
                todaysDate = todaysDate.addDays(7);
            } else if(timeSelected == '1month'){
                todaysDate = todaysDate.addMonths(1);
            } else if(timeSelected == 'All'){
                todaysDate = todaysDate.addYears(10); 
            }
            
             String accountPrefix   =  Schema.Account.getSObjectType().getDescribe().getKeyPrefix();
             String contactPrefix   =  Schema.Contact.getSObjectType().getDescribe().getKeyPrefix();
             String decisionPrefix  =  Schema.Decision__c.getSObjectType().getDescribe().getKeyPrefix(); 
             String planPrefix      =  Schema.Plan__c.getSObjectType().getDescribe().getKeyPrefix();
            
            String dateTimeFormat = genralInfo.MapValuesDateTime();
            if(timeSelected == 'All'){ 
                // This query is used when user selects "All" from the drop down, which will query all the records even when due date is null
                taskList = [Select t.subject,t.Description,t.Id,t.ActivityDate,t.Status,t.WhatId,t.Priority,t.createdby.name  From Task t where t.Owner.id =: UserInfo.getUserId()   and t.IsClosed = false  order by t.ActivityDate  DESC NULLS LAST limit 10000];
            } else 
            if(timeSelected == 'overdue'){ 
                // This query is used when user selects  options other than All from the drop down, which will query all the records even when due date is null
                taskList = [Select t.subject,t.Description,t.Id,t.ActivityDate,t.Status,t.WhatId,t.Priority,t.createdby.name   From Task t where     t.ActivityDate <: Date.today() and t.Owner.id =: UserInfo.getUserId()   and t.IsClosed = false  order by t.ActivityDate DESC,  id limit 10000];
            }
            else { 
                // This query is used when user selects  options other than All from the drop down, which will query all the records even when due date is null
                taskList = [Select  t.subject,t.Description,t.Id,t.ActivityDate,t.Status,t.WhatId,t.Priority,t.createdby.name   From Task t where  t.ActivityDate <=: todaysDate   and t.Owner.id =: UserInfo.getUserId()   and t.IsClosed = false  order by t.ActivityDate DESC,  id limit 10000];
            }
            Set<id> accountWhatIds   = new Set<id>();
            Set<id> contactWhatIds   = new Set<id>();
            Set<id> decisionWhatIds  = new Set<id>();
            Set<id> planWhatIds      = new Set<id>();
            Set<id> otherWhatIds     = new Set<id>();
            
            for(Task tsk:taskList){
                 if( tsk.whatid != null ){
                      String idValue =  String.valueOF( tsk.whatid );
                     if( idValue.startsWith(accountPrefix)  )
                     accountWhatIds.add(tsk.whatid);
                     else
                     if( idValue.startsWith(contactPrefix)  )
                     contactWhatIds.add(tsk.whatid);
                     else
                     if( idValue.startsWith(decisionPrefix)  )
                     decisionWhatIds.add(tsk.whatid);
                     else
                     if( idValue.startsWith(planPrefix)  )
                     planWhatIds.add(tsk.whatid);
                     else
                     otherWhatIds.add(tsk.whatid);
                 }
                
            }
            
            allTaskList = [ Select  t.subject,t.Description,t.Id,t.ActivityDate,t.Status,t.WhatId,t.What.Name,t.Priority,t.createdby.name   From Task t where  t.whatId in:   accountWhatIds];
            allTaskList.addAll([ Select  t.subject,t.Description,t.Id,t.ActivityDate,t.Status,t.WhatId,t.What.Name,t.Priority,t.createdby.name   From Task t where  t.whatId in: contactWhatIds]);
            allTaskList.addAll([ Select  t.subject,t.Description,t.Id,t.ActivityDate,t.Status,t.WhatId,t.What.Title,t.Priority,t.createdby.name   From Task t where  t.whatId in: decisionWhatIds]);
            allTaskList.addAll([ Select  t.subject,t.Description,t.Id,t.ActivityDate,t.Status,t.WhatId,t.What.Title,t.Priority,t.createdby.name   From Task t where  t.whatId in: planWhatIds]);
            allTaskList.addAll([ Select  t.subject,t.Description,t.Id,t.ActivityDate,t.Status,t.WhatId, t.Priority,t.createdby.name   From Task t where  t.whatId in: otherWhatIds]);
           
            Map<id,Decision__c> decisionMap  = new Map<id,Decision__c>( [Select id,Title__c   from Decision__c where id in : decisionWhatIds ]);
            Map<id,Plan__c>     planMap      = new Map<id,Plan__c>([Select id,Name   from Plan__c where id in : planWhatIds ]);
           
           
            String objectNames   =  'Decision__cPlan__cAccountContact';
            List<taskWrapper> taskWrapperList =  new List<taskWrapper>();
            for( Task tsk : allTaskList  ) {
                taskWrapper tw = new taskWrapper();
                tw.taskId        =   tsk.id;
                tw.comments      =   tsk.description == null ? '' : tsk.description;  
                tw.subject       =   tsk.subject;
                tw.status        =   tsk.Status;
                tw.createdByName =   tsk.createdby.name ;
                tw.duedate       =   tsk.ActivityDate != null ? string.valueOf(tsk.ActivityDate) : ''; 
                if( tsk.ActivityDate != null )
                tw.deadline      =   String.valueOf(  ( date.today().daysBetween(tsk.ActivityDate) ) );
                else
                tw.deadline      =   '';
                tw.priority      =   tsk.Priority;
                tw.createdbyname =   tsk.createdby.name;
                String taskWhatId =  String.valueOf( tsk.whatId); 
                tw.relatedTo      = '';       
                
                 if( taskWhatId.startsWith(accountPrefix) ||  taskWhatId.startsWith(contactPrefix) )
                 {
                     tw.relatedTo = tw.relatedTo != null ? tsk.what.name : '';
                 }
                 if(  taskWhatId.startsWith(decisionPrefix) )
                 {
                     tw.relatedTo = decisionMap.get( tsk.whatid ).Title__c != null ? decisionMap.get( tsk.whatid ).Title__c :'' ;
                 }
                 if(  taskWhatId.startsWith(planPrefix) )
                 {  
                     tw.relatedTo = planMap.get( tsk.whatid ).Name != null ? planMap.get( tsk.whatid ).Name :'' ; 
                 }
                 System.debug('============'+tsk);
                 taskWrapperList.add(tw);
            }
            
            return JSON.serialize(taskWrapperList);  
    }  
    @RemoteAction 
    public static string viewTask(String taskId,String relatedTo ){ 
        
                Task viewTask = [ Select  t.subject,t.Description,t.Id,t.ActivityDate,t.Status,t.WhatId,t.What.Name,t.Priority,t.createdby.name   From Task t where id =: taskId];
                List<taskWrapper> taskWrapperList =  new List<taskWrapper>();
                
                taskWrapper tw = new taskWrapper();
                tw.taskId         =   viewTask.id;              
                tw.comments       =    viewTask.description == null ? '' :viewTask.description ;  
                tw.subject        =   viewTask.subject;
                tw.status         =   viewTask.Status;
                tw.createdByName  =   viewTask.createdby.name ;
                tw.duedate        =   viewTask.ActivityDate != null ? string.valueOf(viewTask.ActivityDate) : ''; 
                if( viewTask.ActivityDate != null )
                tw.deadline       =   String.valueOf(  ( date.today().daysBetween(viewTask.ActivityDate) ) );
                else 
                tw.deadline       =   '';
                tw.priority       =   viewTask.Priority;
                tw.createdbyname  =   viewTask.createdby.name;
                tw.relatedTo      =   relatedTo;
                taskWrapperList.add(tw);
                 
                 return JSON.serialize(taskWrapperList);  
        
    }
    
    
    
    @RemoteAction 
    public static string updateTask(String pageId,String taskId,String status,String comment ){
        Task updateTask  = [Select id , description,status from task where id =: taskId ];
        if(pageId != 'drawer-tasks' )
        updateTask.description = comment;
        else
        updateTask.status      = status;
        try
        {
          if(FLS.taskUpdateable()){ 
            update updateTask;
          }
          return 'SUCCESS';
        }
        catch(Exception e)
        {
          return 'FAIL'; 
        }
        
        
    }
   
  
    @RemoteAction
    public static string decisionViewMobileData(String decisionId,String processInstanceId ) {
        if(genralInfo == null ) {
                genralInfo  = new GeneralInformation();
        }
        String dateTimeFormat = genralInfo.MapValuesDateTime();
        decision              = [Select id,Progress__c,Title__c,Priority__c,Decision_Taken__c,Problem_Idea_Advice__c,status__c,due_date__c from decision__c where id =: decisionId ];
        Social_Input__c loggedInSocialPeople  = [Select id,Role__c,Mood__c,User__r.Name,Final_Approval_Status__c,Role_Acceptance_Status__c ,Stance_Approval_Status__c ,Decision__r.OwnerId from Social_Input__c  where User__c =: UserInfo.getUserId() and Decision__c =: decisionId ];
        Social_Input__c findAccountable = [Select id,Role__c,Mood__c,User__c from Social_Input__c  where Accountable__c = true and Decision__c =: decisionId limit 1 ];
        List<Attachment> attachments = [select id,body from Attachment WHERE ParentID =: decisionId  AND Name=:decisionId limit 1];
        ProcessInstanceWorkitem  piwList = new ProcessInstanceWorkitem();
        if([Select p.ProcessInstance.Status, p.ProcessInstance.TargetObjectId, p.ProcessInstanceId, p.Id, p.CreatedDate, p.CreatedBy.Name, p.CreatedById, p.Actor.Name, p.ActorId From ProcessInstanceWorkitem p where  p.ActorId =: Userinfo.getUserId() AND p.ProcessInstance.TargetObjectId =: loggedInSocialPeople.Id Limit 1].size() >0){	
        	piwList = [Select p.ProcessInstance.Status, p.ProcessInstance.TargetObjectId, p.ProcessInstanceId, p.Id, p.CreatedDate, p.CreatedBy.Name, p.CreatedById, p.Actor.Name, p.ActorId From ProcessInstanceWorkitem p where  p.ActorId =: Userinfo.getUserId() AND p.ProcessInstance.TargetObjectId =: loggedInSocialPeople.Id Limit 1];
        }
        decisionWrapper dw    =  new decisionWrapper();
        dw.typeOfapproval     =  loggedInSocialPeople.Role_Acceptance_Status__c == 'Pending Approval' ?  'Role' : (  loggedInSocialPeople.Stance_Approval_Status__c == 'Pending Approval' ? 'Stance': ( loggedInSocialPeople.Final_Approval_Status__c == 'Pending Approval' ) ? 'Decision': 'NONE' );
        dw.decisionId         =  decision.id; 
        dw.duedate            =  decision.Due_Date__c  != null ? String.valueOf( decision.Due_Date__c.format(dateTimeFormat)) :''; 
        dw.subject            =  decision.Title__c;
        if(decision.Due_Date__c != null )
        dw.duedate            =  decision.Due_Date__c  != null ? String.valueOf( decision.Due_Date__c.format(dateTimeFormat)) :''; 
        else 
        dw.duedate            =   '';
        if(decision.Due_Date__c != null ) 
        dw.deadline           =   String.valueOf( Date.today().daysbetween( date.newinstance(decision.Due_Date__c.year(), decision.Due_Date__c.month(), decision.Due_Date__c.day()) ) ) ;
        else
        dw.deadline           =   ''; 
        dw.role               = loggedInSocialPeople.Role__c.replaceAll('Accountable','A').replaceAll('Responsible','R').replaceAll('Consulted','C').replaceAll('Informed','I').replaceAll(' ',''); 
        dw.approvalComment    = '   ';
        if( decision.Problem_Idea_Advice__c != null )
        dw.problemStatement   =  decision.Problem_Idea_Advice__c.replaceAll('<[^>]+>',' ');
        else
        dw.problemStatement   = '';
        if( decision.Decision_Taken__c != null )   
        dw.decisionStatement  =  decision.Decision_Taken__c.replaceAll('<[^>]+>',' ');
        else
        dw.decisionStatement  = '';
        
        dw.status             =  decision.Status__c;
        dw.priority           =  decision.Priority__c;
        dw.requestedBy        =  piwList.CreatedBy.Name;
        dw.socialInputId      =  loggedInSocialPeople.id; 
        dw.processId          =  processInstanceId;   //piwList.size() > 0 ? String.valueOf( piwList[0].id ) : 'NONE';
        dw.moodvalue          =  loggedInSocialPeople.Mood__c;
        dw.imageURLonDecision =  attachments.size() > 0 ? '/servlet/servlet.FileDownload?file='+attachments[0].id : '';
        dw.myStance           =  loggedInSocialPeople.Stance_Approval_Status__c;
        dw.ownerName          =  genralInfo != null && genralInfo.useNameMap != null && findAccountable.User__c != null && genralInfo.useNameMap.get(findAccountable.User__c) != null ? genralInfo.useNameMap.get(findAccountable.User__c).Name : '';
        dw.progressIndicator = Decision.Progress__c;
        List<decisionWrapper> dwList = new  List<decisionWrapper>();
        dwList.add(dw);
        return  JSON.serialize(dwList);       
    } 
    
    
    
    // pulse in command center 
     @RemoteAction
    public static void updatePulse(String pulseStatus, String decisionId){
        Decision__c decision1 = new Decision__c();
         decision1.Id = decisionId;
         decision1.Progress__c = pulseStatus;
        if(FLS.decisionUpdateable()){
            update decision1;
        }
     
    }
    
    
    
    
    
      public class taskWrapper{
        public string  priority{get;set;}
        public string  status{get;set;}
        public string  subject{get;set;}
        public string  duedate{get;set;}
        public string deadline{get;set;}
        public string  createdbyname{get;set;}
        public string  relatedTo{get;set;}
        public string  comments{get;set;}
        public string  taskId{get;set;}
    }  
      public class decisionWrapper{  
            public string decisionId{get;set;}
            public string subject{get;set;}         
            public string problemStatement{get;set;}
            public string decisionStatement{get;set;}  
            public string approvalComment{get;set;}  
            public string role{get;set;}  
            public string status{get;set;}
            public string priority{get;set;}
            public string duedate{get;set;}         
            public string deadline{get;set;}
            public string requestedBy{get;set;}
            public string socialInputId{get;set;}
            public string processId{get;set;}
            public decimal moodValue{get;set;}
            public string typeOfapproval{get;set;}
            public string imageURLonDecision{get;set;}
            public string myStance{get;set;}
            public string ownerName{get;set;} 
            public string progressIndicator{get;set;}
    }     
    
    
    
      // Decision List  wrapper class
       public class DecisionCardWrapper{
        public string Id{get;set;}
        public string decisionId{get;set;}
        public string decisionTitle{get;set;}
        public string problemStatement{get;set;}
        public string decisionTaken{get;set;}
        public string phaseImg{get;set;}
        public string phase{get;set;}
        public string dueDate{get;set;}
        public string role{get;set;}
        public string ownerId{get;set;}
        public string ownerName{get;set;} 
        public string status{get;set;}
        public string priority{get;set;}
        // start added on 22-4-2014
        public datetime dueDateSort{get;set;}
        public datetime lastModified{get;set;}
        // end added on 22-4-2014
        public string myStance{get;set;}
        public integer deadline{get;set;}
        public string decisionProgress{get;set;}
        public string typeOfApproval{get;set;}
        public string processInstanceWorkitem{get;set;}
        public string progressIndicator{get;set;}
    }
}