/* 
    ********************************************************************** 
    Created by: Kiran Kumar
    Last Modified by: Kiran Kumar
    Style: Force.com & Metro
    Description: a) This controller performs functionality to insert feedcomment unser task feedItem.
    		     b) This controller is created to put all future methods.
    ********************************************************************** 
 */
public without sharing class FutureMethodController {
	
	// Future method for inserting task comments under feeditmes.
	@future
	public static void insertFeedComments(set<Id> taskIds,map<Id,String> mapComments, String dmlType){
		// Creating a list of feed items
		//List<FeedItem> lstFeedItems = [select id,ParentId,Type from FeedItem where ParentId IN : taskIds and Type = 'CreateRecordEvent']; // Fetching all the "created this task" feeditems for task which are inserted or updated.
		List<TaskFeed> lstFeedItems = [Select t.Type, t.SystemModstamp, t.ParentId, t.IsDeleted, t.Id, t.CreatedDate, t.CreatedById From TaskFeed t where t.ParentId IN : taskIds and t.Type = 'CreateRecordEvent']; // Fetching all the "created this task" feeditems for task which are inserted or updated.
		// Creating a list of feed comments
		List<FeedComment> lstFeedComments = new List<FeedComment>();
		for(Id t : taskIds){
			for(TaskFeed fi : lstFeedItems){
				if(fi.ParentId == t){ // Comparing task id and feeditem parentId, allowing only those ids whose feeditem parentid is same with taskid which are inserted or updated.
					if(mapComments.get(t) != null){
						FeedComment fc = new FeedComment();
						if(dmlType == 'Insert'){
							if(mapComments.get(t).length() > 1000){ // If the comment is more then 1000 chars, taking up only first 997 chars and appending with ...
								fc.CommentBody = 'Added Task comment: \n"' + mapComments.get(t).substring(0,970) + '..."';
							} else {
								fc.CommentBody = 'Added Task comment: \n"' + mapComments.get(t) + '"';
							}
						}
						if(dmlType == 'Update'){
							if(mapComments.get(t).length() > 1000){ // If the comment is more then 1000 chars, taking up only first 997 chars and appending with ...
								fc.CommentBody = 'Changed Task comment to: \n"' + mapComments.get(t).substring(0,968) + '..."';
							} else {
								fc.CommentBody = 'Changed Task comment to: \n"' + mapComments.get(t) + '"';
							}
						}
						fc.FeedItemId = fi.Id;
						lstFeedComments.add(fc); // Adding to the list for inserting feedcomments
					}
				}
			}
		}
		if(!lstFeedComments.isEmpty()){
			if(FLS.feedCommentCreatable()){
				insert lstFeedComments; // inserting feedcomment
			}
		}
	}
	
	// Future method for inserting task comments under feeditmes which has task comments as null.
	@future
	public static void insertNullFeedComment(set<Id> taskIds){
		// Creating a list of feed items
		//List<FeedItem> lstFeedItems = [select id,ParentId from FeedItem where ParentId IN : taskIds and Type = 'CreateRecordEvent']; // Fetching all the "created this task" feeditems for task which task comment updated as null.
		List<TaskFeed> lstFeedItems = [Select t.Type, t.SystemModstamp, t.ParentId, t.IsDeleted, t.Id, t.CreatedDate, t.CreatedById From TaskFeed t where t.ParentId IN : taskIds and t.Type = 'CreateRecordEvent']; // Fetching all the "created this task" feeditems for task which are inserted or updated.
		// Creating a list of feed comments
		List<FeedComment> lstFeedComments = new List<FeedComment>();
		for(Id t : taskIds){
			for(TaskFeed fi : lstFeedItems){
				if(fi.ParentId == t){ // Comparing task id and feeditem parentId, allowing only those ids whose feeditem parentid is same with taskid which are updated.
					FeedComment fc = new FeedComment();
					fc.CommentBody = 'Task comment field content deleted.';
					fc.FeedItemId = fi.Id;
					lstFeedComments.add(fc); // Adding to the list for inserting feedcomments
				}
			}
		}
		if(!lstFeedComments.isEmpty()){
			if(FLS.feedCommentCreatable()){
				insert lstFeedComments; // inserting feedcomment
			}
		}
	}
	
	// Future method to delete SIN post for all social input records.
	@future
	public static void deleteSINChatterFeeds(set<Id> setSocialInputIds){
		List<FeedItem> lstFeedItems = [select id,ParentId from FeedItem where ParentId IN : setSocialInputIds and Type = 'CreateRecordEvent']; // Querying all the social input feed records.
		if(!lstFeedItems.isEmpty() && FLS.FeedItemDeletable()){
			delete lstFeedItems;
		}
	}
	
	// Future method to to add chatter comment when task is closed.
	// (R19-1-US-13) Chatter post on decision & plan when a task is closed
	@future
	public static void closeChatterComment(set<Id> taskIds,map<Id,String> mapStatus){
		List<TaskFeed> lstFeedItems = [Select t.Type, t.SystemModstamp, t.ParentId, t.IsDeleted, t.Id, t.CreatedDate, t.CreatedById From TaskFeed t where t.ParentId IN : taskIds and t.Type = 'CreateRecordEvent']; // Fetching all the "created this task" feeditems for task which are inserted or updated.
		// Creating a list of feed comments
		List<FeedComment> lstFeedComments = new List<FeedComment>();
		for(Id t : taskIds){
			for(TaskFeed tf : lstFeedItems){
				if(t == tf.ParentId){
					// Display the feed comment when the task is closed.
					FeedComment fc = new FeedComment();
					if(mapStatus.get(t) != null){
						fc.CommentBody = 'Closed the task with status "'+ mapStatus.get(t) + '"';
					} else {
						fc.CommentBody = 'Closed the task with status "Completed"';
					}
					fc.FeedItemId = tf.Id;
					lstFeedComments.add(fc);
				}
			}
		}
		if(!lstFeedComments.isEmpty() && FLS.feedCommentCreatable()){
			insert lstFeedComments; // inserting feedcomment
		}
	}
	
	//Writtern by kiran
	public static void decisionPlanRecordsUpdate(set<Id> decisionIds, set<Id> planIds){
		
		if(!decisionIds.isEmpty()){
	        List<Decision__c> lstDecision = [select id,Update_Manager__c from Decision__c where Id IN : decisionIds];
	        for(Decision__c d : lstDecision){
	        	d.Update_Manager__c = d.Update_Manager__c == null ? 0 : d.Update_Manager__c + 1;
	        }
	        if(!lstDecision.isEmpty() && FLS.decisionUpdateable()){
	        	update lstDecision;
	        }
    	}
        if(!planIds.isEmpty()){	
        	List<Plan__c> lstPlan = [select id,Update_Manager__c from Plan__c where Id IN : planIds];
        	for(Plan__c p : lstPlan){
        		p.Update_Manager__c = p.Update_Manager__c == null ? 0 : p.Update_Manager__c + 1;
        	} 
        	if(!lstPlan.isEmpty() && FLS.planUpdateable()){
        		update lstPlan;
        	}
        }
	}
	
	public static List<FeedComment> returnFeedComment(set<Id> setIds){
		List<FeedComment> lstFeedComment = [select CreatedById,FeedItemId,Id,ParentId,RelatedRecordId from FeedComment where FeedItemId IN : setIds];
		return lstFeedComment;
	}
	
	// For Chatter Feed ID update in Decision
	
	public static void feedIdUpdateOnDecision(String decisionId,String feedID){
		Decision__c decision = new Decision__c(id = decisionId,FeedItem_Id__c = feedID ); 
    	update decision;
	}
	
	
	public static void ProposefeedIdUpdateOnDecision(String decisionId,String feedID){
		 Decision__c decision = new Decision__c(id = decisionId,FeedItem_Id_Propose__c  = feedID ); 
         update decision;
	}
}