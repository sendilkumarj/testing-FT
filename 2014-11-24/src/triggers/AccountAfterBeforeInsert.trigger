trigger AccountAfterBeforeInsert on Account (After Insert) {

    for(Account a:Trigger.new){
        
        
        String s = a.Name;  
    }
}