@istest
public class testFuture{

   static testMethod void testFutureMethodController (){
    Task t = new Task(subject='test',ownerId=userinfo.getuserId());
    insert t;
    Set<id> TaskId = new set<id>();
    Map<id,string> taskComment = new Map<id,string>();
    taskComment.put(t.id,'1234');
    Test.starttest();
    FutureMethodController.insertFeedComments(taskid,taskComment,'Insert');
    FutureMethodController.insertFeedComments(taskid,taskComment,'Update');
    test.stopTest();
    
   }


}