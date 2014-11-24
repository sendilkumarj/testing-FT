public with sharing class TopicAdminController{

     public String dateFormat { get; set; }
     public static list<TopicWrapp> topicWrapperLsit{get;set;}
     public static string  topicJsonString{get;set;}
     public static string  topicCollectorJsonString{get;set;}
     public static string  topicOrganiserJsonString{get;set;}
     public static GeneralInformation genralInfo;
     //variable to hold user locale for kendo culture
     public static string  userLocaleSidKey{get;set;}
     static{
            //set user locale here
            userLocaleSidKey  = UserInfo.getLocale().replace('_','-');
     }
     public TopicAdminController()
     {
        
       if(genralInfo == null ) {
            genralInfo  = new GeneralInformation();
       }
       dateFormat  = genralInfo.MapValuesDateFormate();
       // Getting default data which are selected previous in the admin tool.   
       List<Topics__c>  TopicsCustomSettingList  = [Select id ,TopicJson__c from  Topics__c order by RecordNumber__c asc];
       topicCollectorJsonString = '';
       for(Topics__c t : TopicsCustomSettingList)
       topicCollectorJsonString  = topicCollectorJsonString  + (t.TopicJson__c==null?'':t.TopicJson__c);
       List<Topic_Selected_Data__c>  TopicsSelectedCustomSettingList  = [Select id ,Topic_Json__c from  Topic_Selected_Data__c order by RecordNumber__c asc];
       topicOrganiserJsonString = '';
       for(Topic_Selected_Data__c t : TopicsSelectedCustomSettingList)
       topicOrganiserJsonString  = topicOrganiserJsonString  + (t.Topic_Json__c==null?'':t.Topic_Json__c);
       if( topicCollectorJsonString == '')
       topicCollectorJsonString = '[]';
       if( topicOrganiserJsonString == '')
       topicOrganiserJsonString = '[]';       
     }
     // Wrapper class variables to build search table
     public class topicWrapp
     {
        public Boolean isSelected{get;set;}
        public string  name{get;set;}
        public String  description{get;set;}
        public Integer talkingabout{get;set;}
        public String  createddate{get;set;}
      }
      @Remoteaction
     public static string searchTopic(String searchString){
        
        // Search table functionalty to fetch it from custom settings from Topics and Topics selected object and creating json data.
        // Search text to replace * with %
        if(searchString != ''){
            if(searchString.contains('*')){
                String SearchtextList=searchString.replaceAll('\\*','\\%');
                searchString = SearchtextList;
            }
        }
        
        GeneralInformation genInfo = new GeneralInformation();
        String  dateTimeFormat = genInfo.MapValuesDateTime();
        
        List<Topics__c>  TopicsCustomSettingList  = [Select id ,TopicJson__c from  Topics__c order by RecordNumber__c asc];
        String topicJson = '';
        for(Topics__c t : TopicsCustomSettingList)
            topicJson  = topicJson  + (t.TopicJson__c==null?'':t.TopicJson__c);
        List<Topics> topicsList = new List<Topics>();
        if(topicJson.length()>0)
            topicsList =  (List<Topics>)Json.deserialize(topicJson  ,List<Topics>.class);
        
        set<String> setTopics = new set<String>();
        for(Topics t : topicsList){
            setTopics.add(t.text);
        }
        
        List<Topic_Selected_Data__c>  TopicsSelectedCustomSettingList  = [Select id ,Topic_Json__c from  Topic_Selected_Data__c order by RecordNumber__c asc];
            
        String jsonData = '';
        for(Topic_Selected_Data__c tsd : TopicsSelectedCustomSettingList){
            jsonData = jsonData+''+tsd.Topic_Json__c;
        }
        System.debug('----jsonData------>'+jsonData);
        
        // Deserializing the json data and wrapping to a class.
        List<TopicRow> jsonTopicRows = new List<TopicRow>();
        if(jsonData != ''){
            jsonTopicRows = (List<TopicRow>)JSON.deserialize(jsonData,List<TopicRow>.class);
        }
        set<String> setTopicNames = new set<String>();
        for(TopicRow tr : jsonTopicRows){
            if(tr.items != null){
                for(Topics t : tr.items){
                    setTopics.add(t.text);
                }
            }
        }
        
        topicWrapperLsit = new list<TopicWrapp>();
        // query on topics which are not selected in admin table before and adding it to search list.
        List<Topic> topicList = new List<Topic>();
        
        if(searchString != ''){	
        	topicList = [Select CreatedById,CreatedDate,Description,Id,Name,SystemModstamp,TalkingAbout from Topic where Name like : '%'+searchString+'%' and Name Not IN : setTopics];
        } else {
        	topicList = [Select CreatedById,CreatedDate,Description,Id,Name,SystemModstamp,TalkingAbout from Topic where Name Not IN : setTopics];
        }
        for(Topic t:  topicList ){
          topicWrapp tw   = new topicWrapp();
          tw.isSelected   = false;
          tw.name         = t.name;
          tw.description  = t.description;
          tw.talkingabout = t.talkingabout;
          tw.createddate  = String.valueOf(t.createddate.format(dateTimeFormat)); 
          
          
          topicWrapperLsit.add( tw );
        }
        topicJsonString = Json.serialize( topicWrapperLsit );
        return ( topicJsonString  );
     }
     @Remoteaction
     public static string addAndSave(String jsonData){
      List<Topics__c>  TopicsCustomSettingList  = [Select id ,TopicJson__c from  Topics__c order by RecordNumber__c asc];
      String topicJson = '';
      for(Topics__c t : TopicsCustomSettingList)
      topicJson  = topicJson  + (t.TopicJson__c==null?'':t.TopicJson__c);
     // Integer.valueOf(topicJson);
      List<Topics> topicsList = new List<Topics>();
      if(topicJson.length()>0)
      topicsList =  (List<Topics>)Json.deserialize(topicJson  ,List<Topics>.class);

      // Add and save funcitonalty after selecting the topics from search table.
      List<TopicWrapp> topicWrappList =  (List<TopicWrapp>)Json.deserialize(jsonData,List<TopicWrapp>.class);
      for( TopicWrapp tw :  topicWrappList)
      if(tw.isSelected == true)
      {
        Topics t = new Topics();
        t.text   = tw.name;
        topicsList.add( t);
      }
     
      String topicAddedJson = Json.serialize( topicsList );
      double  d= topicAddedJson.length();
      d= d/255;
      //integer.valueOf( Math.ceil(d)+'v');
      // Creating multipule records on based on the length of the json string created.
      for(Integer i=0;i<Math.ceil(d);i++)
      {    
        if( ((i+1)*255) <= topicAddedJson.length() )
        TopicsCustomSettingList[i].TopicJson__c  =  topicAddedJson.substring(i*255,((i+1)*255  )) ;
        else{
        
            if( TopicsCustomSettingList.size() >= Math.ceil(d) )
            TopicsCustomSettingList[i].TopicJson__c  =  topicAddedJson.substring(i*255,topicAddedJson.length()) ;
            else{
              Topics__c tnew = new Topics__c();
              tnew.TopicJson__c =  topicAddedJson.substring(i*255,  topicAddedJson.length() ) ;
              tnew.name = string.valueOf(i);
              tnew.RecordNumber__c  =  i;
              TopicsCustomSettingList.add(tnew);
            }  
        }
      }    
      System.debug('--------FLS.topicsCreateable()------->'+FLS.topicsCreateable());
      System.debug('--------FLS.topicsUpdateable()------->'+FLS.topicsUpdateable());
      //if(FLS.topicsCreateable() && FLS.topicsUpdateable()){
            upsert TopicsCustomSettingList;
      //}
       TopicsCustomSettingList  = [Select id ,TopicJson__c from  Topics__c order by RecordNumber__c asc];
       topicCollectorJsonString = '';
       for(Topics__c t : TopicsCustomSettingList)
       topicCollectorJsonString  = topicCollectorJsonString  + (t.TopicJson__c==null?'':t.TopicJson__c);
       return topicCollectorJsonString  ;
     }
     // Classes used to bind json data.
     class Topics {
        public string text{get;set;}
    }
    class TopicRow {
        public String text{get;set;}
        public  List<Topics> items{get;set;}
    }
     
     @Remoteaction
     public static string dragAndDrop(String jsonData,String jsonData1){
      List<Topic_Selected_Data__c>  TopicsSelectedCustomSettingList  = [Select id ,Topic_Json__c from  Topic_Selected_Data__c order by RecordNumber__c asc];
      System.debug('-------FLS.topicSelectedDataDeletable()-------->'+FLS.topicSelectedDataDeletable());
      //if(FLS.topicSelectedDataDeletable()){
        delete TopicsSelectedCustomSettingList;
      //}
      TopicsSelectedCustomSettingList.clear();
      
     
      
      Decimal d= jsonData.length();
      d= d/255;
      
      System.debug('-------jsonData.length()-------->'+jsonData.length());
      System.debug('-------d-------->'+d);
      System.debug('-------Math.ceil(d)-------->'+Math.ceil(d));
      //integer.valueOf( Math.ceil(d)+'v');
      // Creating multipule records on based on the length of the json string created.
      for(Integer i=0;i<Math.ceil(d);i++)
      {    
        if( ((i+1)*255) <= jsonData.length() )
        {
              Topic_Selected_Data__c tnew = new Topic_Selected_Data__c();
              tnew.Topic_Json__c = jsonData.substring(i*255,((i+1)*255  )) ;
              tnew.name = string.valueOf(i);
              tnew.RecordNumber__c  =  i;
              TopicsSelectedCustomSettingList.add(tnew);
              System.debug('-------TopicsSelectedCustomSettingList-------->'+TopicsSelectedCustomSettingList);
        }      
        else{ 
              Topic_Selected_Data__c tnew = new Topic_Selected_Data__c();
              tnew.Topic_Json__c =  jsonData.substring(i*255,  jsonData.length() ) ;
              tnew.name = string.valueOf(i);
              tnew.RecordNumber__c  =  i;
              TopicsSelectedCustomSettingList.add(tnew);
              System.debug('-------TopicsSelectedCustomSettingList-------->'+TopicsSelectedCustomSettingList);
         }
      }
      System.debug('--------FLS.topicSelectedDataCreateable()------->'+FLS.topicSelectedDataCreateable());
      System.debug('--------FLS.topicSelectedDataUpdateable()------->'+FLS.topicSelectedDataUpdateable());
      //if(FLS.topicSelectedDataCreateable() && FLS.topicSelectedDataUpdateable()){     
        upsert TopicsSelectedCustomSettingList;
      //}
      
      List<Topics__c > TopicsCustomSettingList  = [Select id ,TopicJson__c from  Topics__c order by RecordNumber__c asc];
      System.debug('-------FLS.topicsDeletable()-------->'+FLS.topicsDeletable());
      //if(FLS.topicsDeletable()){  
        delete TopicsCustomSettingList;
      //}
      TopicsCustomSettingList.clear();
      
      d= jsonData1.length();
      d= d/255;
      //integer.valueOf( Math.ceil(d)+'v');
      // Creating multipule records on based on the length of the json string created.
      for(Integer i=0;i<Math.ceil(d);i++)
      {    
        if( ((i+1)*255) <= jsonData1.length() )
        {
        
        
              Topics__c tnew = new Topics__c();
              tnew.TopicJson__c = jsonData1.substring(i*255,((i+1)*255  )) ;
              tnew.name = string.valueOf(i);
              tnew.RecordNumber__c  =  i;
              TopicsCustomSettingList.add(tnew);
              
        }      
        else{ 
              Topics__c tnew = new Topics__c();
              tnew.TopicJson__c =  jsonData1.substring(i*255,  jsonData1.length() ) ;
              tnew.name = string.valueOf(i);
              tnew.RecordNumber__c  =  i;
              TopicsCustomSettingList.add(tnew);
         }
      }    
      System.debug('--------FLS.topicsCreateable()------->'+FLS.topicsCreateable());
      System.debug('--------FLS.topicsUpdateable()------->'+FLS.topicsUpdateable());
      //if(FLS.topicsCreateable() && FLS.topicsUpdateable()){
            upsert TopicsCustomSettingList;
      //}
      
      
      
       return '';
     }
     
     @Remoteaction
     public static string addTopic(String topicName , String topicDescription){
        // Creating topic records from add topic popup.
        List<Topic> lstTopic = [select id from Topic where Name = : topicName];
        String result;
        if(lstTopic.size() > 0){
            result = 'failed';
        } else {
          Topic  t = new Topic();
          t.Name = topicName;
          t.Description = topicDescription;
          if(FLS.topicCreateable()){    
            insert t;
          }
          result = 'success';
        }
        return result;
     }
      
     
}