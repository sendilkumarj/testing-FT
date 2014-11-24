global class SocialInputDeleteScheduler implements Schedulable{
    global void execute(SchedulableContext SC) {
        List<FeedItem> feedsToBeDeleted = [SELECT Id,parentId,Type FROM FeedItem WHERE parentId in (SELECT Id FROM Social_Input__c)];
        if(feedsToBeDeleted.size() > 0)
            delete feedsToBeDeleted ;
    } 
}