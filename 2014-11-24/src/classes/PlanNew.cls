/*
 Created by:Phaniraj
 Last Modified by: Phaniraj
 Style: Force.com & Metro
 Description: This class is written to create a new plan record. The redirection will be tracked if the plan is created from the plan tab or from the workbench.
*/
public with sharing class PlanNew{
    
    public Plan__c planNew{get;set;}
    public string workbenchVal{get;set;}
    public PlanNew(ApexPages.StandardController stdController){
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=8');
        planNew = new Plan__c();
        workbenchVal = ApexPages.currentPage().getParameters().get('workbench');
    }
    
    // save the plan and redirect to specific tab.
    public pageReference save(){
    	System.debug('-------planNew-------->'+planNew.Start_Time__c);
    	System.debug('-------planNew-------->'+planNew.End_Time__c);
        insert planNew;
        pageReference page;
        if(workbenchVal == null){
            page = new pageReference('/'+planNew.Id);    
        }else{
            page = new pageReference('/apex/WorkbenchHomePage?gotoplan=yes');    
        }
        page.setRedirect(true);
        return page;
    }
    
    public Pagereference customCancel(){
        String returnURL = ApexPages.currentPage().getParameters().get('retURL');
        pageReference page;
        System.debug('------------returnURL--------->'+returnURL);
        if(returnURL != null && returnURL != ''){
            set<String> objectList = new set<String>();
            String x;
            Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
            for(String sObj : Schema.getGlobalDescribe().keySet()){
                Schema.DescribeSObjectResult r =  gd.get(sObj).getDescribe();
                String tempName = r.getName();
                String tempPrefix = r.getKeyPrefix();
                if(tempName.equals('fingertip_a__Plan__c') || tempName.equals('Plan__c')) {
                    System.debug(tempPrefix);
                    objectList.add(tempPrefix);
                    x = tempPrefix;
                }
            }
            page = new pageReference('/'+x+'/o');    
        } else {
            page = new pageReference('/apex/HomePage');
        }
        page.setRedirect(true);
        return page;
    }
}