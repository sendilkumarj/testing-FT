Public class XSSPOCController{

  Public string  jsonString{get;set;}
  Public string  untrustedData{get;set;}
  public  XSSPOCController()
  {
      List<Account> accountList = [Select id, name,Description,owner.name from Account limit 10];
      
      List<accountWrapper> accountWrapperList = new List<accountWrapper>();
      for( Account a: accountList )
      {
        accountWrapper aw = new accountWrapper();
        aw.id =       a.id;
        aw.description =    a.Description;
        aw.name     = a.name;
       // aw.ownername= a.owner.name;
        accountWrapperList .add(aw);
        
      }
      jsonString =  Json.serialize( accountWrapperList );
      jsonString  = jsonString.escapeHtml4();
      untrustedData = '[{ "text": "Black", "value": "1" },{ "text": "Orange", "value": "2" },{ "text": "Grey", "value": "3" },{ "text": "<script>alert(2)</script>", "value": "<script>alert(3)</script>"},{ "text": "<img src=\'\' onerror=\'alert(1)\'/>", "value": "<img src=\'\'  onerror=\'alert(1)\'/>"} ]';
  }
  
  public class accountWrapper
  {
     String id{get;set;}
     String description{get;set;}
     String ownername{get;set;}
     String name{get;set;}
  }
}