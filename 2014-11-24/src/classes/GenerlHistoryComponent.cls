/*
Created : Piyush Parmar
Modified by : Piyush Parmar
Description: This controller contains hostory list of all object 
*/


public with sharing class GenerlHistoryComponent {
    // External variables
    public SObject myObject {get; set;}
    public Integer recordLimit {get; set;}
    public static String objectLabel {get;}
    
    // Internal Variables
    public objectHistoryLine[] objectHistory; 

    public static final Map<String, Schema.SObjectType> mySObjectTypeMap = Schema.getGlobalDescribe();
    public static Map<String, Schema.SObjectField> myObjectFieldMap;
    public static List<Schema.PicklistEntry> historyFieldPicklistValues;
    
   
    public Id myObjectId {get;set;} // piyush
    
    public List<objectHistoryLine> getObjectHistory(Id myObjectId1, SObject myObject1){
        
        myObject = myObject1;
        myObjectId = myObjectId1; // piyush
        
        System.debug('--->'+myObjectId);
        Schema.DescribeSObjectResult objectDescription = myObject.getSObjectType().getDescribe();

        myObjectFieldMap = objectDescription.fields.getMap();
        objectLabel = String.valueOf(objectDescription.getLabel());
        
        //Get the name of thew history table
        String objectHistoryTableName = objectDescription.getName();
        //if we have a custom object we need to drop the 'c' off the end before adding 'History' to get the history tables name
        if (objectDescription.isCustom()){
            objectHistoryTableName = objectHistoryTableName.substring(0, objectHistoryTableName.length()-1);
        }
        objectHistoryTableName = objectHistoryTableName + 'History';
        
        Schema.DescribeFieldResult objectHistoryFieldField = mySObjectTypeMap.get(objectHistoryTableName).getDescribe().fields.getMap().get('Field').getDescribe();
        historyFieldPicklistValues = objectHistoryFieldField.getPickListValues();
                    
        list<objectHistoryLine> objectHistory = new list<objectHistoryLine>();
        
        String prevDate = '';
        DateTime prevDate1 = null;
        
        if (recordLimit== null){
            recordLimit = 100;
        }
        
        list<sObject> historyList = Database.query( 'SELECT CreatedDate,'+
                                                    'CreatedById,'+
                                                    'Field,'+
                                                    'NewValue,'+
                                                    'OldValue ' +
                                                    'FROM ' + objectHistoryTableName + ' ' +
                                                    'WHERE ParentId =\'' + myObjectId + '\' ' +
                                                    'ORDER BY CreatedDate DESC '+
                                                    'LIMIT ' + String.valueOf(recordLimit));
        System.debug('****historyList'+historyList.size());
        
        for(Integer i = 0; i < historyList.size(); i++){
            sObject historyLine = historyList.get(i);
            if ((historyLine.get('newValue') == null && historyLine.get('oldValue') == null) 
                    || (historyLine.get('newValue') != null && !(string.valueOf(historyLine.get('newValue')).startsWith('005') || string.valueOf(historyLine.get('newValue')).startsWith('00G')))
                    || (historyLine.get('oldValue') != null && !(string.valueOf(historyLine.get('oldValue')).startsWith('005') || string.valueOf(historyLine.get('oldValue')).startsWith('00G')))){
                objectHistoryLine tempHistory = new objectHistoryLine();
                // Set the Date and who performed the action
                if (DateTime.valueOfGmt(String.valueOf(historyLine.get('CreatedDate'))) != prevDate1){
                    tempHistory.theDate = DateTime.valueOfGmt(String.valueOf(historyLine.get('CreatedDate')));
                    tempHistory.userId = String.valueOf(historyLine.get('CreatedById'));
                    tempHistory.who = String.valueOf(historyLine.get('CreatedById'));
                }
                else{
                    tempHistory.theDate = null;
                    tempHistory.who = '';
                    tempHistory.userId = String.valueOf(historyLine.get('CreatedById'));
                }
                prevDate1 = DateTime.valueOfGmt(String.valueOf(historyLine.get('CreatedDate')));
                
                // Get the field label
                String fieldLabel = GenerlHistoryComponent.returnFieldLabel(String.valueOf(historyLine.get('Field')));
                
                // Set the Action value
                   if (String.valueOf(historyLine.get('Field')) == 'created') {    // on Creation
                       tempHistory.action = 'Created.';
                  }
                  else if (historyLine.get('oldValue') != null && historyLine.get('newValue') == null){ // when deleting a value from a field
                      // Format the Date and if there's an error, catch it and re
                      try {
                         tempHistory.action = 'Deleted ' + Date.valueOf(historyLine.get('oldValue')).format() + ' in <b>' + fieldLabel + '</b>.';
                    } catch (Exception e){
                         tempHistory.action = 'Deleted ' + String.valueOf(historyLine.get('oldValue')) + ' in <b>' + fieldLabel + '</b>.';
                    }
                  }
                  else{  // all other scenarios
                      String fromText = '';
                    if (historyLine.get('oldValue') != null) {
                         try {
                              fromText = ' from ' + Date.valueOf(historyLine.get('oldValue')).format();
                         } catch (Exception e) {
                              fromText = ' from ' + String.valueOf(historyLine.get('oldValue'));
                         }
                    }
                    
                    String toText = '';
                    if (historyLine.get('oldValue') != null) {
                        try {
                             toText = Date.valueOf(historyLine.get('newValue')).format();
                        } catch (Exception e) {
                             toText = String.valueOf(historyLine.get('newValue'));
                        }
                    }
                    if (toText != ''){
                        tempHistory.action = 'Changed <b>' + fieldLabel + '</b>' + fromText + ' to <b>' + toText + '</b>.';
                    }
                    else {
                        tempHistory.action = 'Changed <b>' + fieldLabel;
                    }
                   }
                   
                   // Add to the list
                   objectHistory.add(tempHistory);
            }
         }
         System.debug('****historyList'+objectHistory.size());
         List<Id> userIdList = new List<Id>();
         for (objectHistoryLine myHistory : objectHistory){
             userIdList.add(myHistory.userId);
         }
         Map<Id, User> userIdMap = new Map<ID, User>([SELECT Name FROM User WHERE Id IN : userIdList]);
         
         for (objectHistoryLine myHistory : objectHistory){
             if (userIdMap.containsKey(myHistory.userId) & (myHistory.who != '') ){
                 myHistory.who = userIdMap.get(myHistory.who).Name;
             }
         }
         
         return objectHistory;
    }    
    
    // Function to return Field Label of a object field given a Field API name
    public Static String returnFieldLabel(String fieldName){

        if (GenerlHistoryComponent.myObjectFieldMap.containsKey(fieldName)){
            return GenerlHistoryComponent.myObjectFieldMap.get(fieldName).getDescribe().getLabel();
        }
        else {
            for(Schema.PicklistEntry pickList : historyFieldPicklistValues){
                if (pickList.getValue() == fieldName){
                    if (pickList.getLabel() != null){
                        return pickList.getLabel();
                    }
                    else {
                        return pickList.getValue();
                    }
                }
            }
        }
        return '';
    }
    
    // Inner Class to store the detail of the object history lines    
    public class objectHistoryLine {

        public DateTime theDate {get; set;}
        public String who {get; set;}
        public Id userId {get; set;} 
        public String action {get; set;}
    }
    
    // Method only used for code coverage.
    
    public String MapValuesDateTime() {
        Map<String, String> locale_map = new Map<String, String>(); //holds the locale to timedate formats
        locale_map.put('ar', 'dd/MM/yyyy hh:mm a');
        locale_map.put('ar_AE', 'dd/MM/yyyy hh:mm a');
        locale_map.put('ar_BH', 'dd/MM/yyyy hh:mm a');
        locale_map.put('ar_JO', 'dd/MM/yyyy hh:mm a');
        locale_map.put('ar_KW', 'dd/MM/yyyy hh:mm a');
        locale_map.put('ar_LB', 'dd/MM/yyyy hh:mm a');
        locale_map.put('ar_SA', 'dd/MM/yyyy hh:mm a');
        locale_map.put('bg_BG', 'yyyy-M-d H:mm');
        locale_map.put('ca', 'dd/MM/yyyy HH:mm');
        locale_map.put('ca_ES', 'dd/MM/yyyy HH:mm');
        locale_map.put('ca_ES_EURO', 'dd/MM/yyyy HH:mm');
        locale_map.put('cs', 'd.M.yyyy H:mm');
        locale_map.put('cs_CZ', 'd.M.yyyy H:mm');
        locale_map.put('da', 'dd-MM-yyyy HH:mm');
        locale_map.put('da_DK', 'dd-MM-yyyy HH:mm');
        locale_map.put('de', 'dd.MM.yyyy HH:mm');
        locale_map.put('de_AT', 'dd.MM.yyyy HH:mm');
        locale_map.put('de_AT_EURO', 'dd.MM.yyyy HH:mm');
        locale_map.put('de_CH', 'dd.MM.yyyy HH:mm');
        locale_map.put('de_DE', 'dd.MM.yyyy HH:mm');
        locale_map.put('de_DE_EURO', 'dd.MM.yyyy HH:mm');
        locale_map.put('de_LU', 'dd.MM.yyyy HH:mm');
        locale_map.put('de_LU_EURO', 'dd.MM.yyyy HH:mm');
        locale_map.put('el_GR', 'd/M/yyyy h:mm a');
        locale_map.put('en_AU', 'd/MM/yyyy HH:mm');
        locale_map.put('en_B', 'M/d/yyyy h:mm a');
        locale_map.put('en_BM', 'M/d/yyyy h:mm a');
        locale_map.put('en_CA', 'dd/MM/yyyy h:mm a');
        locale_map.put('en_GB', 'dd/MM/yyyy HH:mm');
        locale_map.put('en_GH', 'M/d/yyyy h:mm a');
        locale_map.put('en_ID', 'M/d/yyyy h:mm a');
        locale_map.put('en_IE', 'dd/MM/yyyy HH:mm');
        locale_map.put('en_IE_EURO', 'dd/MM/yyyy HH:mm');
        locale_map.put('en_NZ', 'd/MM/yyyy HH:mm');
        locale_map.put('en_SG', 'M/d/yyyy h:mm a');
        locale_map.put('en_US', 'M/d/yyyy h:mm a');
        locale_map.put('en_ZA', 'yyyy/MM/dd hh:mm a');
        locale_map.put('es', 'd/MM/yyyy H:mm');
        locale_map.put('es_AR', 'dd/MM/yyyy HH:mm');
        locale_map.put('es_BO', 'dd-MM-yyyy hh:mm a');
        locale_map.put('es_CL', 'dd-MM-yyyy hh:mm a');
        locale_map.put('es_CO', 'd/MM/yyyy hh:mm a');
        locale_map.put('es_CR', 'dd/MM/yyyy hh:mm a');
        locale_map.put('es_EC', 'dd/MM/yyyy hh:mm a');
        locale_map.put('es_ES', 'd/MM/yyyy H:mm');
        locale_map.put('es_ES_EURO', 'd/MM/yyyy H:mm');
        locale_map.put('es_GT', 'd/MM/yyyy hh:mm a');
        locale_map.put('es_HN', 'MM-dd-yyyy hh:mm a');
        locale_map.put('es_MX', 'd/MM/yyyy hh:mm a');
        locale_map.put('es_PE', 'dd/MM/yyyy hh:mm a');
        locale_map.put('es_PR', 'MM-dd-yyyy hh:mm a');
        locale_map.put('es_PY', 'dd/MM/yyyy hh:mm a');
        locale_map.put('es_SV', 'MM-dd-yyyy hh:mm a');
        locale_map.put('es_UY', 'dd/MM/yyyy hh:mm a');
        locale_map.put('es_VE', 'dd/MM/yyyy hh:mm a');
        locale_map.put('et_EE', 'd.MM.yyyy H:mm');
        locale_map.put('fi', 'd.M.yyyy H:mm');
        locale_map.put('fi_FI', 'd.M.yyyy H:mm');
        locale_map.put('fi_FI_EURO', 'd.M.yyyy H:mm');
        locale_map.put('fr', 'dd/MM/yyyy HH:mm');
        locale_map.put('fr_BE', 'd/MM/yyyy H:mm');
        locale_map.put('fr_CA', 'yyyy-MM-dd HH:mm');
        locale_map.put('fr_CH', 'dd.MM.yyyy HH:mm');
        locale_map.put('fr_FR', 'dd/MM/yyyy HH:mm');
        locale_map.put('fr_FR_EURO', 'dd/MM/yyyy HH:mm');
        locale_map.put('fr_LU', 'dd/MM/yyyy HH:mm');
        locale_map.put('fr_MC', 'dd/MM/yyyy HH:mm');
        locale_map.put('hr_HR', 'yyyy.MM.dd HH:mm');
        locale_map.put('hu', 'yyyy.MM.dd. H:mm');
        locale_map.put('hy_AM', 'M/d/yyyy h:mm a');
        locale_map.put('is_IS', 'd.M.yyyy HH:mm');
        locale_map.put('it', 'dd/MM/yyyy H.mm');
        locale_map.put('it_CH', 'dd.MM.yyyy HH:mm');
        locale_map.put('it_IT', 'dd/MM/yyyy H.mm');
        locale_map.put('iw', 'HH:mm dd/MM/yyyy');
        locale_map.put('iw_IL', 'HH:mm dd/MM/yyyy');
        locale_map.put('ja', 'yyyy/MM/dd H:mm');
        locale_map.put('ja_JP', 'yyyy/MM/dd H:mm');
        locale_map.put('kk_KZ', 'M/d/yyyy h:mm a');
        locale_map.put('km_KH', 'M/d/yyyy h:mm a');
        locale_map.put('ko', 'yyyy. M. d a h:mm');
        locale_map.put('ko_KR', 'yyyy. M. d a h:mm');
        locale_map.put('lt_LT', 'yyyy.M.d HH.mm');
        locale_map.put('lv_LV', 'yyyy.d.M HH:mm');
        locale_map.put('ms_MY', 'dd/MM/yyyy h:mm a');
        locale_map.put('nl', 'd-M-yyyy H:mm');
        locale_map.put('nl_BE', 'd/MM/yyyy H:mm');
        locale_map.put('nl_NL', 'd-M-yyyy H:mm');
        locale_map.put('nl_SR', 'd-M-yyyy H:mm');
        locale_map.put('no', 'dd.MM.yyyy HH:mm');
        locale_map.put('no_NO', 'dd.MM.yyyy HH:mm');
        locale_map.put('pl', 'yyyy-MM-dd HH:mm');
        locale_map.put('pt', 'dd-MM-yyyy H:mm');
        locale_map.put('pt_AO', 'dd-MM-yyyy H:mm');
        locale_map.put('pt_BR', 'dd/MM/yyyy HH:mm');
        locale_map.put('pt_PT', 'dd-MM-yyyy H:mm');
        locale_map.put('ro_RO', 'dd.MM.yyyy HH:mm');
        locale_map.put('ru', 'dd.MM.yyyy H:mm');
        locale_map.put('sk_SK', 'd.M.yyyy H:mm');
        locale_map.put('sl_SI', 'd.M.y H:mm');
        locale_map.put('sv', 'yyyy-MM-dd HH:mm');
        locale_map.put('sv_SE', 'yyyy-MM-dd HH:mm');
        locale_map.put('th', 'M/d/yyyy h:mm a');
        locale_map.put('th_TH', 'd/M/yyyy, H:mm ?.');
        locale_map.put('tr', 'dd.MM.yyyy HH:mm');
        locale_map.put('ur_PK', 'M/d/yyyy h:mm a');
        locale_map.put('vi_VN', 'HH:mm dd/MM/yyyy');
        locale_map.put('zh', 'yyyy-M-d ah:mm');
        locale_map.put('zh_CN', 'yyyy-M-d ah:mm');
        locale_map.put('zh_HK', 'yyyy-M-d ah:mm');
        locale_map.put('zh_TW', 'yyyy/M/d a h:mm');
        //locale_map.put('en_IN', 'dd/mm/yyyy h:mm a'); // manualy put
        locale_map.put('en_IN', 'd/M/yyyy h:mm a'); // manually added for locale India
        
        String user_locale = UserInfo.getLocale();
        
        // If locale is not match with current mapping
        if(locale_map.get(user_locale) == null) {
            user_locale = 'en_US';
        }
        
        
        
        return locale_map.get(user_locale); //return the map
    }
    
    public String MapValuesDateFormate() {
        Map<String, String> locale_map = new Map<String, String>(); //holds the locale to timedate formats
        locale_map.put('ar', 'dd/MM/yyyy');
        locale_map.put('ar_AE', 'dd/MM/yyyy');
        locale_map.put('ar_BH', 'dd/MM/yyyy');
        locale_map.put('ar_JO', 'dd/MM/yyyy');
        locale_map.put('ar_KW', 'dd/MM/yyyy');
        locale_map.put('ar_LB', 'dd/MM/yyyy');
        locale_map.put('ar_SA', 'dd/MM/yyyy');
        locale_map.put('bg_BG', 'yyyy-M-d');
        locale_map.put('ca', 'dd/MM/yyyy');
        locale_map.put('ca_ES', 'dd/MM/yyyy');
        locale_map.put('ca_ES_EURO', 'dd/MM/yyyy');
        locale_map.put('cs', 'd.M.yyyy');
        locale_map.put('cs_CZ', 'd.M.yyyy');
        locale_map.put('da', 'dd-MM-yyyy');
        locale_map.put('da_DK', 'dd-MM-yyyy');
        locale_map.put('de', 'dd.MM.yyyy');
        locale_map.put('de_AT', 'dd.MM.yyyy');
        locale_map.put('de_AT_EURO', 'dd.MM.yyyy');
        locale_map.put('de_CH', 'dd.MM.yyyy');
        locale_map.put('de_DE', 'dd.MM.yyyy');
        locale_map.put('de_DE_EURO', 'dd.MM.yyyy');
        locale_map.put('de_LU', 'dd.MM.yyyy');
        locale_map.put('de_LU_EURO', 'dd.MM.yyyy');
        locale_map.put('el_GR', 'd/M/yyyy');
        locale_map.put('en_AU', 'd/MM/yyyy');
        locale_map.put('en_B', 'M/d/yyyy');
        locale_map.put('en_BM', 'M/d/yyyy');
        locale_map.put('en_CA', 'dd/MM/yyyy');
        locale_map.put('en_GB', 'dd/MM/yyyy');
        locale_map.put('en_GH', 'M/d/yyyy');
        locale_map.put('en_ID', 'M/d/yyyy');
        locale_map.put('en_IE', 'dd/MM/yyyy');
        locale_map.put('en_IE_EURO', 'dd/MM/yyyy');
        locale_map.put('en_NZ', 'd/MM/yyyy');
        locale_map.put('en_SG', 'M/d/yyyy');
        locale_map.put('en_US', 'M/d/yyyy');
        locale_map.put('en_ZA', 'yyyy/MM/dd');
        locale_map.put('es', 'd/MM/yyyy');
        locale_map.put('es_AR', 'dd/MM/yyyy');
        locale_map.put('es_BO', 'dd-MM-yyyy');
        locale_map.put('es_CL', 'dd-MM-yyyy');
        locale_map.put('es_CO', 'd/MM/yyyy');
        locale_map.put('es_CR', 'dd/MM/yyyy');
        locale_map.put('es_EC', 'dd/MM/yyyy');
        locale_map.put('es_ES', 'd/MM/yyyy');
        locale_map.put('es_ES_EURO', 'd/MM/yyyy');
        locale_map.put('es_GT', 'd/MM/yyyy');
        locale_map.put('es_HN', 'MM-dd-yyyy');
        locale_map.put('es_MX', 'd/MM/yyyy');
        locale_map.put('es_PE', 'dd/MM/yyyy');
        locale_map.put('es_PR', 'MM-dd-yyyy');
        locale_map.put('es_PY', 'dd/MM/yyyy');
        locale_map.put('es_SV', 'MM-dd-yyyy');
        locale_map.put('es_UY', 'dd/MM/yyyy');
        locale_map.put('es_VE', 'dd/MM/yyyy');
        locale_map.put('et_EE', 'd.MM.yyyy');
        locale_map.put('fi', 'd.M.yyyy');
        locale_map.put('fi_FI', 'd.M.yyyy');
        locale_map.put('fi_FI_EURO', 'd.M.yyyy');
        locale_map.put('fr', 'dd/MM/yyyy');
        locale_map.put('fr_BE', 'd/MM/yyyy');
        locale_map.put('fr_CA', 'yyyy-MM-dd');
        locale_map.put('fr_CH', 'dd.MM.yyyy');
        locale_map.put('fr_FR', 'dd/MM/yyyy');
        locale_map.put('fr_FR_EURO', 'dd/MM/yyyy');
        locale_map.put('fr_LU', 'dd/MM/yyyy');
        locale_map.put('fr_MC', 'dd/MM/yyyy');
        locale_map.put('hr_HR', 'yyyy.MM.dd');
        locale_map.put('hu', 'yyyy.MM.dd');
        locale_map.put('hy_AM', 'M/d/yyyy');
        locale_map.put('is_IS', 'd.M.yyyy');
        locale_map.put('it', 'dd/MM/yyyy');
        locale_map.put('it_CH', 'dd.MM.yyyy');
        locale_map.put('it_IT', 'dd/MM/yyyy');
        locale_map.put('iw', 'dd/MM/yyyy');
        locale_map.put('iw_IL', 'dd/MM/yyyy');
        locale_map.put('ja', 'yyyy/MM/dd');
        locale_map.put('ja_JP', 'yyyy/MM/dd');
        locale_map.put('kk_KZ', 'M/d/yyyy');
        locale_map.put('km_KH', 'M/d/yyyy');
        locale_map.put('ko', 'yyyy. M. d');
        locale_map.put('ko_KR', 'yyyy. M. d');
        locale_map.put('lt_LT', 'yyyy.M.d');
        locale_map.put('lv_LV', 'yyyy.d.M');
        locale_map.put('ms_MY', 'dd/MM/yyyy');
        locale_map.put('nl', 'd-M-yyyy');
        locale_map.put('nl_BE', 'd/MM/yyyy');
        locale_map.put('nl_NL', 'd-M-yyyy');
        locale_map.put('nl_SR', 'd-M-yyyy');
        locale_map.put('no', 'dd.MM.yyyy');
        locale_map.put('no_NO', 'dd.MM.yyyy');
        locale_map.put('pl', 'yyyy-MM-dd');
        locale_map.put('pt', 'dd-MM-yyyy');
        locale_map.put('pt_AO', 'dd-MM-yyyy');
        locale_map.put('pt_BR', 'dd/MM/yyyy');
        locale_map.put('pt_PT', 'dd-MM-yyyy');
        locale_map.put('ro_RO', 'dd.MM.yyyy');
        locale_map.put('ru', 'dd.MM.yyyy');
        locale_map.put('sk_SK', 'd.M.yyyy');
        locale_map.put('sl_SI', 'd.M.y');
        locale_map.put('sv', 'yyyy-MM-dd');
        locale_map.put('sv_SE', 'yyyy-MM-dd');
        locale_map.put('th', 'M/d/yyyy');
        locale_map.put('th_TH', 'd/M/yyyy');
        locale_map.put('tr', 'dd.MM.yyyy');
        locale_map.put('ur_PK', 'M/d/yyyy');
        locale_map.put('vi_VN', 'dd/MM/yyyy');
        locale_map.put('zh', 'yyyy-M-d');
        locale_map.put('zh_CN', 'yyyy-M-d');
        locale_map.put('zh_HK', 'yyyy-M-d');
        locale_map.put('zh_TW', 'yyyy/M/d');
        //locale_map.put('en_IN', 'dd/mm/yyyy h:mm a'); // manualy put
        locale_map.put('en_IN', 'd/M/yyyy'); // manually added for locale India
        
        String user_locale = UserInfo.getLocale();
        
       // If locale is not match with current mapping
        if(locale_map.get(user_locale) == null) {
            user_locale = 'en_US';
        }
        
        String customdate = locale_map.get(user_locale);
        return customdate;
    }
}