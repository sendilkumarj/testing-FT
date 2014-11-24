/*
 Created by:Phaniraj
 Last Modified by: Phaniraj
 Style: Force.com & Metro
 Description: This class is written to create a Plan list in the workbench
*/

public with sharing class WorkbenchPlanList{
    public static string planlListJson{get;set;}
    // user locale date fromat as string 
    public static String dateFormat {get;set;}
    
    // user locale datetime fromat as string 
    public static String dateTimeFormat {get;set;}
    
    GeneralInformation genralInfo;
        
    public WorkbenchPlanList(){
    	Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=8');
        // initialize General information class to get user locale date format and images from static resouces url //
        genralInfo  = new GeneralInformation();
          
        // assign user locale date format as string 
        dateFormat = genralInfo.MapValuesDateFormate();
        
        // assign user locale datetime format as string 
        dateTimeFormat = genralInfo.MapValuesDateTime();
        
        generatePlanListJson();
    }
    
    // method to generate Plan list in workbench
    public void generatePlanListJson(){
        
        
        List<Plan__c> planList = [select Id,Name, LastModifiedDate, Owner.Name from Plan__c where Id != null order by LastModifiedDate Desc Limit 50000];
        List<planListJsonClass> planJsonList = new List<planListJsonClass>();
        for(plan__c p : planList){
            planListJsonClass jsonNew = new planListJsonClass();
            jsonNew.id = p.Id;
            jsonNew.Name = p.Name;
            jsonNew.lastModifiedDate = String.valueOf(p.LastModifiedDate.format('M/d/yyyy h:mm a'));
            jsonNew.owner = p.owner.name;
            jsonNew.selectIcon = genralInfo.imageUrlMap.get('selectPlan');
            planJsonList.add(jsonNew);
        }
        system.debug('-----------srch text---coming------>');
        planlListJson = JSON.serialize(planJsonList);
        
    }
    
    // method to search a plan in plan list in workbench
    public void searchPlan(){
        String searchText =  ApexPages.currentPage().getParameters().get('searchText');
        System.debug('------------srch text--->'+searchText);
        if(searchText != ''){
            
            if(searchText.contains('*')){
                searchText=searchText.replaceAll('\\*','\\%');
            }
            searchText = '%'+searchText+'%';
            
            
            List<Plan__c> planList = [select Id,Name, LastModifiedDate, Owner.Name from Plan__c where Name like: searchText order by LastModifiedDate Desc Limit 50000];
            List<planListJsonClass> planJsonList = new List<planListJsonClass>();
            for(plan__c p : planList){
                planListJsonClass jsonNew = new planListJsonClass();
                jsonNew.id = p.Id;
                jsonNew.Name = p.Name;
                jsonNew.lastModifiedDate = String.valueOf(p.LastModifiedDate.format('M/d/yyyy h:mm a'));
                jsonNew.owner = p.owner.name;
                jsonNew.selectIcon = genralInfo.imageUrlMap.get('selectPlan');
                planJsonList.add(jsonNew);
            }
            
            planlListJson = JSON.serialize(planJsonList);
            
        }else{
            generatePlanListJson();
        }
    }
    
    public class planListJsonClass{
        public string id{get;set;}
        public String name{get;set;}
        public string lastModifiedDate{get;set;}
        public string owner{get;set;}
        public string selectIcon{get;set;}
    }
}