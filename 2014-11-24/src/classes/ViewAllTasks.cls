/* 
   ********************************************************************** 
    Created by: Neha
    Last Modified by: Neha
    Style: Force.com & Metro
    Description:           
    **********************************************************************  
*/

public with sharing class ViewAllTasks{
    
    // user locale date fromat as string 
    //public static String dateFormat {get;set;}
    
    // user locale datetime fromat as string 
    //public static String dateTimeFormat {get;set;}
    
    /*JSON string initialization */
    
    //For task list views
    public String taskWrapperJSON {get;set;} 

    // Defining Constructor
    public ViewAllTasks(){
        viewTasksList();
    }
    
    public string viewTasksList(){
    
        /* // initialize General information class to get user locale date format and image static resouce url //
        GeneralInformation genralInfo  = new GeneralInformation();
        
        // assign user locale date format as string 
        dateTimeFormat = genralInfo.MapValuesDateTime();
        
        // assign user locale date format as string 
        dateFormat = genralInfo.MapValuesDateFormate();
    
        //Querying task and event list
        List<Task> taskList = Database.query('select id,Subject,ActivityDate,Status,Priority,OwnerId,Owner.Name,CreatedById,CreatedBy.Name from Task where OwnerId =: UserInfo.getUserId()');
        
        //Initialize task event list
        List<Task> taskList1 = new List<Task>();
        
        //For task
        for(Task tasks : taskList ){
           
                Task t = new Task();
               // t.id= tasks.id;
                t.subject = tasks.Subject;
              //  t.dueDate = tasks.ActivityDate;
                t.status = tasks.Status;
                
                t.priority = tasks.Priority;
              //  t.assignedTo = tasks.Owner.Name;
              //  t.assignedToImage = genralInfo.useImage.get(task.OwnerId);
                taskList.add(t);
        }
       
        //serialize task and event records list
        taskWrapperJSON = JSON.serialize(taskList);
        return taskWrapperJSON;*/
        TaskWrapper t = new TaskWrapper();
        return null;
    }
    
    // Wrapper class section
    
    //Wrapper class for Task 
    public class TaskWrapper {
      public String id {get;set;}
      public String subject {get;set;}
      public String dueDate {get;set;}
      public String status {get;set;}
      public String priority {get;set;}
      public String assignedTo {get;set;}
      public String assignedToImage {get;set;}
    } 
    


}