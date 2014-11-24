trigger AttachmentAfterBeforeUpdate on Attachment (after update, before update) {
    if(Trigger.isAfter){        
        set<String> objectList = new set<String>();
        String x; 
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        for(String sObj : Schema.getGlobalDescribe().keySet()){
            Schema.DescribeSObjectResult r =  gd.get(sObj).getDescribe();
            String tempName = r.getName();
            String tempPrefix = r.getKeyPrefix();
            System.debug('Processing Object['+tempName + '] with Prefix ['+ tempPrefix+']');
            if(tempName.equals('fingertip_a__Decision__c') || tempName.equals('Decision__c') || tempName.equals('fingertip_a__Plan__c') || tempName.equals('Plan__c')) {
                System.debug(tempPrefix);
                objectList.add(tempPrefix);
                x= tempPrefix;
            }
         }
         System.debug(x);
         set<Id> toBeDeletedAttId = new set<Id>();
         set<String> toBeDeletedAttName = new  set<String>();
         for(Attachment a: Trigger.new) {
            String objetId = (String.valueOf(a.parentId)).substring(0, 3);
           	
           	if(objectList.contains(objetId) && a.Name == 'ToBeDeletedCustomAttachment') {
            	toBeDeletedAttId.add(a.Id);
            }
         }
         
         List<Attachment> toBeDeleteAttchment = [select id from Attachment where Id In: toBeDeletedAttId ];
         
         if(toBeDeleteAttchment.size() > 0 ) {
            delete toBeDeleteAttchment;
         }
         List<FeedItem> toBePostedOnChatter = new List<FeedItem>();
         for(Attachment a : Trigger.new) {
         	String objetId = (String.valueOf(a.parentId)).substring(0, 3);
			if(objectList.contains(objetId) && string.valueof(a.ParentId) == a.Name) {
	            FeedItem post = new FeedItem();
	            post.ParentId = a.ParentId;
	            //post.ContentData = a.Body;
	            //post.ContentFileName = a.Name;
	            post.Title = a.Name;
	            post.Body = 'A file '+ a.Name + ' has been updated by '+ Userinfo.getName();
	            post.LinkUrl = '/servlet/servlet.FileDownload?file='+a.Id;
	            toBePostedOnChatter.add(post);
			}
         }
         if(toBePostedOnChatter.size() > 0) {
            insert toBePostedOnChatter;
         }
    }
    
    
}