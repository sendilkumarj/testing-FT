@istest 
public class testKanbanBoardAndCards {

   static testMethod void planStandardObject(){
       KanbanBoardAndCards kbn = new KanbanBoardAndCards();
       kbn.viewAllTasks(); 
       PageReference pageRef = Page.ActivityTab;
       Test.setCurrentPage(pageRef);
      
       ApexPages.currentPage().getParameters().put('assignedId',  userinfo.getUserId());
       ApexPages.currentPage().getParameters().put('dueDateSelected', '');
       ApexPages.currentPage().getParameters().put('userSelected', 'Default');
       ApexPages.currentPage().getParameters().put('dateField', 'DUE_DATE');
       kbn.searchFilter();
       ApexPages.currentPage().getParameters().put('assignedId',  userinfo.getUserId());
       ApexPages.currentPage().getParameters().put('dueDateSelected', '');
       ApexPages.currentPage().getParameters().put('userSelected', 'Default');
       ApexPages.currentPage().getParameters().put('dateField', 'CREATED_DATE');
       kbn.searchFilter();
       ApexPages.currentPage().getParameters().put('assignedId',  userinfo.getUserId());
       ApexPages.currentPage().getParameters().put('dueDateSelected', '');
       ApexPages.currentPage().getParameters().put('userSelected', 'Default');
       ApexPages.currentPage().getParameters().put('dateField', 'LAST_UPDATE');
       kbn.searchFilter();
       ApexPages.currentPage().getParameters().put('assignedId',  userinfo.getUserId());
       ApexPages.currentPage().getParameters().put('dueDateSelected', '');
       ApexPages.currentPage().getParameters().put('userSelected', 'Default');
       ApexPages.currentPage().getParameters().put('dateField', 'Not_DUE_DATE');
       kbn.searchFilter();
       ApexPages.currentPage().getParameters().put('assignedId',  userinfo.getUserId());
       ApexPages.currentPage().getParameters().put('dueDateSelected', '');
       ApexPages.currentPage().getParameters().put('userSelected', 'Default');
       ApexPages.currentPage().getParameters().put('dateField', 'Not_CREATED_DATE');
       kbn.searchFilter();
       ApexPages.currentPage().getParameters().put('assignedId',  userinfo.getUserId());
       ApexPages.currentPage().getParameters().put('dueDateSelected', '');
       ApexPages.currentPage().getParameters().put('userSelected', 'Default');
       ApexPages.currentPage().getParameters().put('dateField', 'Not_LAST_UPDATE');
       kbn.searchFilter();
       
   
   
   }


}