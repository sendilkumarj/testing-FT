/*
 Created by:Phaniraj
 Last Modified by: Phaniraj
 Style: Force.com & Metro
 Description: This class is written to invoke all items in the item list in workbench
*/
public with sharing class WorkbenchPlanItemList{
    public static string planListItemJson{get;set;}
    // user locale date fromat as string 
    public static String dateFormat {get;set;}
    
    // user locale datetime fromat as string 
    public static String dateTimeFormat {get;set;}
    
   // public static string selectItem{get;set;}
    
    GeneralInformation genralInfo;
    
    String searchItemText ;
        
    public WorkbenchPlanItemList(){
        // initialize General information class to get user locale date format and images from static resouces url //
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=8');
        genralInfo  = new GeneralInformation();
          
        // assign user locale date format as string 
        dateFormat = genralInfo.MapValuesDateFormate();
        
        // assign user locale datetime format as string 
        dateTimeFormat = genralInfo.MapValuesDateTime();
        
        //selectItem = genralInfo.imageUrlMap.get('itemSelect');
        
        generatePlanItemListJson();
    }
    
    // method to generate all items in the item list
    public void generatePlanItemListJson(){
        List<planItemListJsonClass> workbenchPlanItemList = new List<planItemListJsonClass>();
        // decision items
        for(Decision__c p : [select id,Name, Title__c, LastModifiedDate, Owner.Name from Decision__c limit 50000 ]) {
          
          planItemListJsonClass wpl = new planItemListJsonClass();
          wpl.id = p.id;
          wpl.name = p.Title__c == null ? '' : String.escapeSingleQuotes(p.Title__c);
          wpl.lastModifiedDate = String.valueOf(p.LastModifiedDate.format('M/d/yyyy h:mm a'));
          wpl.Type = 'Decision';
          wpl.selectItem = genralInfo.imageUrlMap.get('itemSelect');
          workbenchPlanItemList.add(wpl);
          
        }
        // account items
        for(Account p : [select id, Name, LastModifiedDate, Owner.Name from Account limit 50000 ]) {
          
          planItemListJsonClass wpl = new planItemListJsonClass();
          wpl.id = p.id;
          wpl.name = p.Name == null ? '' : String.escapeSingleQuotes(p.Name);
          wpl.lastModifiedDate = String.valueOf(p.LastModifiedDate.format('M/d/yyyy h:mm a'));
          wpl.Type = 'Account';
          wpl.selectItem = genralInfo.imageUrlMap.get('itemSelect');
          workbenchPlanItemList.add(wpl);
          
        }
        // contact items
        for(Contact p : [select id, Name, LastModifiedDate, Owner.Name from Contact limit 50000 ]) {
          
          planItemListJsonClass wpl = new planItemListJsonClass();
          wpl.id = p.id;
          wpl.name = p.Name == null ? '' : String.escapeSingleQuotes(p.Name);
          wpl.lastModifiedDate = String.valueOf(p.LastModifiedDate.format('M/d/yyyy h:mm a'));
          wpl.Type = 'Contact';
          wpl.selectItem = genralInfo.imageUrlMap.get('itemSelect');
          workbenchPlanItemList.add(wpl);
          
        }
        // task items
        for(Task t : [Select t.Subject ,t.LastModifiedDate, t.OwnerId, t.Id From Task t limit 50000]) {
          
          planItemListJsonClass wpl = new planItemListJsonClass();
          wpl.id = t.id;
          wpl.name = t.Subject == null ? '' : String.escapeSingleQuotes(t.Subject); 
          wpl.lastModifiedDate = String.valueOf(t.LastModifiedDate.format('M/d/yyyy h:mm a'));
          wpl.Type = 'Task';
          wpl.selectItem = genralInfo.imageUrlMap.get('itemSelect');
          workbenchPlanItemList.add(wpl);
          
        }
        
        planListItemJson = JSON.serialize(workbenchPlanItemList);
        
        //return planListItemJson;
    }
    
    // method to search an item based on the text entered by the user
    public void searchItemPlan(){
        searchItemText =  ApexPages.currentPage().getParameters().get('searchItemText');
        System.debug('------------srch text--->'+searchItemText);
        if(searchItemText != '' && searchItemText != null){
            if(searchItemText.contains('*')){
                searchItemText=searchItemText.replaceAll('\\*','\\%');
                
            }
            searchItemText= '%'+searchItemText+'%';
            List<planItemListJsonClass> workbenchPlanItemList = new List<planItemListJsonClass>();
            // decision items
            for(Decision__c p : [select id,Name, Title__c, LastModifiedDate, Owner.Name from Decision__c where (Name like: searchItemText or Title__c like: searchItemText ) limit 50000 ]) {
          
              planItemListJsonClass wpl = new planItemListJsonClass();
              wpl.id = p.id;
              wpl.name = p.Title__c;
              wpl.lastModifiedDate = String.valueOf(p.LastModifiedDate.format('M/d/yyyy h:mm a'));
              wpl.Type = 'Decision';
              wpl.selectItem = genralInfo.imageUrlMap.get('itemSelect');
              workbenchPlanItemList.add(wpl);
              
            }
            // account items
            for(Account p : [select id, Name, LastModifiedDate, Owner.Name from Account where Name like: searchItemText limit 50000 ]) {
              
              planItemListJsonClass wpl = new planItemListJsonClass();
              wpl.id = p.id;
              wpl.name = p.Name;
              wpl.lastModifiedDate = String.valueOf(p.LastModifiedDate.format('M/d/yyyy h:mm a'));
              wpl.Type = 'Account';
              wpl.selectItem = genralInfo.imageUrlMap.get('itemSelect');
              workbenchPlanItemList.add(wpl);
              
            }
            // contact items
            for(Contact p : [select id, Name, LastModifiedDate, Owner.Name from Contact where Name like: searchItemText limit 50000 ]) {
              
              planItemListJsonClass wpl = new planItemListJsonClass();
              wpl.id = p.id;
              wpl.name = p.Name;
              wpl.lastModifiedDate = String.valueOf(p.LastModifiedDate.format('M/d/yyyy h:mm a'));
              wpl.Type = 'Contact';
              wpl.selectItem = genralInfo.imageUrlMap.get('itemSelect');
              workbenchPlanItemList.add(wpl);
              
            }
            // task items
            for(Task t : [Select t.Subject ,t.LastModifiedDate, t.OwnerId, t.Id From Task t  where t.Subject like: searchItemText limit 50000]) {
              
              planItemListJsonClass wpl = new planItemListJsonClass();
              wpl.id = t.id;
              wpl.name = String.escapeSingleQuotes(t.Subject); 
              wpl.lastModifiedDate = String.valueOf(t.LastModifiedDate.format('M/d/yyyy h:mm a'));
              wpl.Type = 'Task';
              wpl.selectItem = genralInfo.imageUrlMap.get('itemSelect');
              workbenchPlanItemList.add(wpl);
              
            }
            
            planListItemJson= JSON.serialize(workbenchPlanItemList);
            
        }else{
            generatePlanItemListJson();
            
        }
    }
    
    public class planItemListJsonClass{
        public string id{get;set;}
        public String name{get;set;}
        public string lastModifiedDate{get;set;}
        public string Type{get;set;}
        public string selectItem{get;set;}
    }
}