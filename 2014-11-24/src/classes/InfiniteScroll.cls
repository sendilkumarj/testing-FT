global with sharing class InfiniteScroll {
	
	static final Integer pageSize = 1;
	static final String soql = 'Select id,Name,Title__c,Priority__c,Decision_Taken__c,Problem_Idea_Advice__c,status__c,due_date__c from decision__c';
	
    static ApexPages.StandardSetController getSObjectFeed() {
    	return new ApexPages.StandardSetController(Database.query(soql));     
    }
    
    public static InfiniteScrollResponse getInfiniteScrollResponse(Integer currentPageNumber, Boolean isGetMore) { 
    	ApexPages.StandardSetController feed = getSObjectFeed();    	     	
        feed.setPageSize(pageSize);
        feed.setPageNumber(currentPageNumber);               
        if (!isGetMore) {
        	InfiniteScrollResponse r = new InfiniteScrollResponse((List<SObject>)feed.getRecords());
	        r.hasMore = feed.getHasNext();
	        r.pageNumber = feed.getPageNumber();
	        return r;
        } else {
        	if (feed.getHasNext()) {
		    	feed.next();
		        InfiniteScrollResponse r = new InfiniteScrollResponse((List<SObject>)feed.getRecords());
		        r.hasMore = feed.getHasNext();
		        r.pageNumber = feed.getPageNumber();
		        return r;
        	} else {
	    		InfiniteScrollResponse r = new InfiniteScrollResponse(null);
		        r.hasMore = false;
		        r.pageNumber = feed.getPageNumber();
		        return r;
        	}
    	}        
    }

    public static InfiniteScrollResponse getInfiniteScrollResponseOffset(Integer offset, Integer reclimit) {
        return new InfiniteScrollResponse(Database.query(soql + ' limit ' + reclimit.format() + ' offset ' + offset.format()));
    }
	    
   
}