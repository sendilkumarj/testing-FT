public class DecisionTabHelper {

	public static map<id,FeedItem> feedItemRecords {get;set;}
	
	public DecisionTabHelper(){
			
		
	}
	
	public static void groupFeeditemRecords(set<id> decisionRecordsId,Map<id,List<FeedItem>>  decisionfeedItems){
		feedItemRecords= new map<id,FeedItem>();
		feedItemRecords =new map<id,FeedItem>([SELECT ID,CommentCount,LikeCount,InsertedById , ParentId FROM FeedItem where ParentId in:decisionRecordsId ]);
		//Map<id,List<FeedItem>>  decisionfeedItems= new Map<id,List<FeedItem>>();
        for(id feedKeys : feedItemRecords.keySet()){
            List<FeedItem> lDecisionFeed = decisionfeedItems.get(feedItemRecords.get(feedKeys).ParentId);
            if(lDecisionFeed==null){
                lDecisionFeed = new  List<FeedItem>();
                decisionfeedItems.put(feedItemRecords.get(feedKeys).ParentId,lDecisionFeed);
            }
            lDecisionFeed.add(feedItemRecords.get(feedKeys));
        }
		
	}
	
}