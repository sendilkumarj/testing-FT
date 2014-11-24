public with sharing class LookupPopupController {
    public String query {get; set;}
    //public List<Decision__c> decisionLst {get; set;}
    //public List<Plan__c> planLst {get; set;}
    public List<sObjectWrapper> lstsObjectWrap {get; set;}
   
    
    public LookupPopupController(){
        String searchObj = Apexpages.currentPage().getParameters().get('searchObj');
        
        if(Apexpages.currentPage().getParameters().get('searchText') != ''){
            query = Apexpages.currentPage().getParameters().get('searchText');
        } else {
            query = '';
        }
        System.debug('------searchObj---->'+searchObj);
        lstsObjectWrap = new List<sObjectWrapper>();
        if(searchObj == 'Decisions'){
            //List<List<Decision__c>> searchResults = [FIND :query IN ALL FIELDS RETURNING Decision__c (id, Name)];
            //decisionLst = searchResults[0];
            List<Decision__c> searchResults = [select id,Name from Decision__c where Name like : '%'+query+'%'];
            for(Decision__c d : searchResults){
                sObjectWrapper s = new sObjectWrapper();
                s.recId = d.Id;
                s.recName = d.Name;
                lstsObjectWrap.add(s);
            }
        } else if(searchObj == 'Plans'){
            //List<List<Plan__c>> searchResults = [FIND :query IN ALL FIELDS RETURNING Plan__c (id, Name)];
            List<Plan__c> searchResults = [select id,Name from Plan__c where Name like : '%'+query+'%' ];
            for(Plan__c p : searchResults){
                sObjectWrapper s = new sObjectWrapper();
                s.recId = p.Id;
                s.recName = p.Name;
                lstsObjectWrap.add(s);
            }
        } else if(searchObj == 'Accounts'){
            List<Account> searchResults = [select id,Name from Account where Name like : '%'+query+'%' ];
            for(Account a : searchResults){
                sObjectWrapper s = new sObjectWrapper();
                s.recId = a.Id;
                s.recName = a.Name;
                lstsObjectWrap.add(s);
            }
        } else if(searchObj == 'Contacts'){
            List<Contact> searchResults = [select id,Name from Contact where Name like : '%'+query+'%' ];
            for(Contact c : searchResults){
                sObjectWrapper s = new sObjectWrapper();
                s.recId = c.Id;
                s.recName = c.Name;
                lstsObjectWrap.add(s);
            }
        }
    }
    
    public PageReference runQuery()
    {
        String searchObj = Apexpages.currentPage().getParameters().get('searchObj');
        
        System.debug('------searchObj---->'+searchObj);
        lstsObjectWrap = new List<sObjectWrapper>();
        if(searchObj == 'Decisions'){
            //List<List<Decision__c>> searchResults = [FIND :query IN ALL FIELDS RETURNING Decision__c (id, Name)];
            //decisionLst = searchResults[0];
            List<Decision__c> searchResults = [select id,Name from Decision__c where Name like : '%'+query+'%' ];
            for(Decision__c d : searchResults){
                sObjectWrapper s = new sObjectWrapper();
                s.recId = d.Id;
                s.recName = d.Name;
                lstsObjectWrap.add(s);
            }
        } else if(searchObj == 'Plans'){
            //List<List<Plan__c>> searchResults = [FIND :query IN ALL FIELDS RETURNING Plan__c (id, Name)];
            List<Plan__c> searchResults = [select id,Name from Plan__c where Name like : '%'+query+'%' ];
            for(Plan__c p : searchResults){
                sObjectWrapper s = new sObjectWrapper();
                s.recId = p.Id;
                s.recName = p.Name;
                lstsObjectWrap.add(s);
            }
        } else if(searchObj == 'Accounts'){
            List<Account> searchResults = [select id,Name from Account where Name like : '%'+query+'%' ];
            for(Account a : searchResults){
                sObjectWrapper s = new sObjectWrapper();
                s.recId = a.Id;
                s.recName = a.Name;
                lstsObjectWrap.add(s);
            }
        } else if(searchObj == 'Contacts'){
            List<Contact> searchResults = [select id,Name from Contact where Name like : '%'+query+'%' ];
            for(Contact c : searchResults){
                sObjectWrapper s = new sObjectWrapper();
                s.recId = c.Id;
                s.recName = c.Name;
                lstsObjectWrap.add(s);
            }
        }
        return null;
    }
    
    public class sObjectWrapper {
        public Id recId {get; set;}
        public String recName {get; set;}
    }
}