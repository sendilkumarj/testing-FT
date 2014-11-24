/*
Created by: Phaniraj
Modifiedby:
Style: Metro & Force.com
Description:
The trigger is written to update the decoration image, insert chatter post on chatter when an attachment is added. 
The objective of the trigger is: 
1) When uploading an image to decorate a Decision, we would require to delete older image if any image is existing. As we don't have the permission to write the FLS for the Attachment, we are writing this trigger. This trigger deletes any image that is already uploaded to decorate the decision.
2) Inserts a chatter feed on chatter when an attachment is attached.
After a Attachment is inserted we need to bold the numbers in attachment Tab. so the system checkbox is set to true.(NA)
*/

trigger AttachmentAfterBeforeInsert on Attachment (after insert, before insert) {

    set<String> objectList = new set<String>();
    String x; 
    Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
    for(String sObj : Schema.getGlobalDescribe().keySet()){
        Schema.DescribeSObjectResult r =  gd.get(sObj).getDescribe();
        String tempName = r.getName();
        String tempPrefix = r.getKeyPrefix();
        if(tempName.equals('fingertip_a__Decision__c') || tempName.equals('Decision__c') || tempName.equals('fingertip_a__Plan__c') || tempName.equals('Plan__c')) {
            System.debug(tempPrefix);
            objectList.add(tempPrefix);
            x = tempPrefix;
        }
     }
     
    if(Trigger.isBefore){        
         set<Id> toBeDeletedAttId = new set<Id>();
         set<String> toBeDeletedAttName = new  set<String>();
         for(Attachment a: Trigger.new) {
            String objetId = (String.valueOf(a.parentId)).substring(0, 3);
            System.debug(objetId);
            if(objectList.contains(objetId) && a.Name.contains(objetId)) {
                toBeDeletedAttId.add(a.parentId);
                toBeDeletedAttName.add(String.valueof(a.parentId));
            }
         }
         
         List<Attachment> toBeDeleteAttchment = [select id from Attachment where Name In: toBeDeletedAttName AND parentId In: toBeDeletedAttId ];
         
         if(toBeDeleteAttchment.size() > 0 ) {
            delete toBeDeleteAttchment;
         }
    }
    
    if(Trigger.isAfter){
        Set<Id> parentIds = new set<Id>();
        for(Attachment a: Trigger.new) {
            parentIds.add(a.parentId);
        }            
        
        if(parentIds.size() > 0){
            List<Social_Input__c> socialRec = [select Id, SYS_Tab_View_Attachments__c from Social_Input__c where Decision__c IN: parentIds];
            for(Social_Input__c s:socialRec){
                s.SYS_Tab_View_Attachments__c = true;
            }
            update socialRec;
        }
        List<FeedItem> toBePostedOnChatter = new List<FeedItem>();
        for(Attachment a : Trigger.new) {
            System.debug('------a.parentId------->'+a.parentId);
            String objetId = (String.valueOf(a.parentId)).substring(0, 3);
            if(objectList.contains(objetId) && string.valueOf(a.ParentId) != a.Name) {
                FeedItem post = new FeedItem();
                post.ParentId = a.ParentId;
                //post.ContentData = a.Body;
                //post.ContentFileName = a.Name;
                post.Title = a.Name;
                post.Body = 'A file '+ a.Name + ' has been attached by '+ Userinfo.getName();
                System.debug('------a.Id------->'+a.Id);
                post.LinkUrl = '/servlet/servlet.FileDownload?file='+a.Id;
                toBePostedOnChatter.add(post);
            }
        }
        if(toBePostedOnChatter.size() > 0) {
            insert toBePostedOnChatter;
        }
    }            
}