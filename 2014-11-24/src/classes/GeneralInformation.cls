/*
Created : Piyush Parmar
Modified by : Piyush Parmar
Description: This controller contains local date/time information and static resource values
*/

public with sharing class GeneralInformation{
    
    // user profile image 
    public map<Id,String> useImage = new map<Id,String>();
    
    // user Object 
    public map<Id,User> useNameMap = new map<Id,User>();
    
    public static GeneralInformation generalInfo ;
    
    // gruop  Object 
    public map<Id,Group> groupMap;
    
    // group member map
    //public map<Id, List<string>> generalGroupMemberMap;
    
    // delete image 
    public map<Boolean, String> deleteImage = new map<Boolean, String>();
    //edit image
    public map<Boolean,String> editImage = new map<Boolean,String>();
    
    //Common image mapping to get dynamically 
    public map<String, String> imageUrlMap = new map<String, String>();
    
    
    public GeneralInformation() {
        for(User u : [select Id,isActive, Name,FirstName,LastName, SmallPhotoUrl, Department   from User]) {
            useImage.put(u.Id,u.SmallPhotoUrl);
            useNameMap.put(u.Id,u);
        }
        
        groupMap = new map<Id,Group>( [select id,  Name from Group where type='Regular']); //added type filter to prevent role  coming here by shebin
        
        
        StaticResource imagesResource = [ SELECT Name, NamespacePrefix, SystemModStamp FROM StaticResource WHERE Name = 'Images' ];
        String namespace = imagesResource.NamespacePrefix;
        
        String imagesResourceLink = 'resource/' + imagesResource.SystemModStamp.getTime() + '/' + (namespace != null && namespace != '' ? namespace + '__' : '') + 'Images';
        
        deleteImage.put(true,imagesResourceLink+'/common/icon-delete-16x16.png');
        deleteImage.put(false,imagesResourceLink+'/common/icon-deleteDisabled-16x16.png');
        
        editImage.put(true,imagesResourceLink+'/common/icon-edit-16x16.png');
        editImage.put(false,imagesResourceLink+'/common/icon-editDisabled-16x16.png');
        
        
        
        imageUrlMap.put('selectPlan',imagesResourceLink+'/common/icon_select_16x16.png');
        imageUrlMap.put('itemSelect',imagesResourceLink+'/common/icon-add-16x16.png');
        imageUrlMap.put('unlock',imagesResourceLink+'/kanbanImages/unlock-24x24.png');
        imageUrlMap.put('lock',imagesResourceLink+'/newDecisionLifeCycle/icon_lock-12x16.png');
        
        imageUrlMap.put('null',imagesResourceLink+'/common/icon-null-16x16.png');
        imageUrlMap.put('',imagesResourceLink+'/common/icon-null-16x16.png');
        imageUrlMap.put('activities',imagesResourceLink+'/common/icon-activities-24x24.png');
        imageUrlMap.put('addEditPeople',imagesResourceLink+'/common/icon-addEditPeople-32x32.png');
        imageUrlMap.put('addPeople',imagesResourceLink+'/common/icon-addPeople-24x24.png');
        imageUrlMap.put('approved',imagesResourceLink+'/common/icon-approved-16x16.png');
        imageUrlMap.put('attachments',imagesResourceLink+'/common/icon-attachments-24x24.png');
        imageUrlMap.put('chatter',imagesResourceLink+'/common/icon-chatter-24x24.png');
        imageUrlMap.put('checked',imagesResourceLink+'/common/icon-checked-16x16.png');
        imageUrlMap.put('collaborators',imagesResourceLink+'/common/icon-collaborators-24x24.png');
        imageUrlMap.put('delete',imagesResourceLink+'/common/icon-delete-16x16.png');
        imageUrlMap.put('deleteDisabled',imagesResourceLink+'/common/icon-deleteDisabled-16x16.png');
        imageUrlMap.put('edit',imagesResourceLink+'/common/icon-edit-16x16.png');
        imageUrlMap.put('editDisabled',imagesResourceLink+'/common/icon-editDisabled-16x16.png');
        imageUrlMap.put('editPeople',imagesResourceLink+'/common/icon-editPeople-24x24.png');
        imageUrlMap.put('general',imagesResourceLink+'/common/icon-general-24x24.png');
        imageUrlMap.put('help',imagesResourceLink+'/common/icon-help-16x16.png');
        imageUrlMap.put('history',imagesResourceLink+'/common/icon-history-24x24.png');
        imageUrlMap.put('info',imagesResourceLink+'/common/icon-info-16x16.png');
        imageUrlMap.put('items',imagesResourceLink+'/common/icon-items-24x24.png');
        imageUrlMap.put('group',imagesResourceLink+'/common/icon-publicGroups-24x24.png');
        imageUrlMap.put('moveDown',imagesResourceLink+'/common/icon-moveDown-16x16.png');
        imageUrlMap.put('moveDownDisabled',imagesResourceLink+'/common/icon-moveDownDisabled-16x16.png');
        imageUrlMap.put('moveUp',imagesResourceLink+'/common/icon-moveUp-16x16.png');
        imageUrlMap.put('moveUpDisabled',imagesResourceLink+'/common/icon-moveUpDisabled-16x16.png');
        imageUrlMap.put('pending',imagesResourceLink+'/common/icon-pending-16x16.png');
        imageUrlMap.put('quality',imagesResourceLink+'/common/icon-quality-24x24.png');
        imageUrlMap.put('recordAdd',imagesResourceLink+'/common/icon-recordAdd-24x24.png');
        imageUrlMap.put('recordEdit',imagesResourceLink+'/common/icon-recordEdit-24x24.png');
        imageUrlMap.put('recordSelected',imagesResourceLink+'/common/icon-recordSelected-24x24.png');
        imageUrlMap.put('rejected',imagesResourceLink+'/common/icon-rejected-16x16.png');
        imageUrlMap.put('relations',imagesResourceLink+'/common/icon-relations-24x24.png');
        imageUrlMap.put('relationship',imagesResourceLink+'/common/icon-relationship-32x32.png');
        imageUrlMap.put('tasks',imagesResourceLink+'/common/icon-tasks-24x24.png');
        imageUrlMap.put('timing',imagesResourceLink+'/common/icon-timing-24x24.png');
        imageUrlMap.put('unchecked',imagesResourceLink+'/common/icon-unchecked-16x16.png');
        imageUrlMap.put('warning',imagesResourceLink+'/common/icon-warning-24x24.png');
        imageUrlMap.put('planFlagRed',imagesResourceLink+'/common/icon-redFlag-16x16.png');
        imageUrlMap.put('moodAngry',imagesResourceLink+'/common/icon-moodAngry-16x16.png');
        imageUrlMap.put('moodSad',imagesResourceLink+'/common/icon-moodSad-16x16.png');
        imageUrlMap.put('moodNeutral',imagesResourceLink+'/common/icon-moodNeutral-16x16.png');
        imageUrlMap.put('moodNoInput',imagesResourceLink+'/common/icon-moodNoInput-16x16.png');
        imageUrlMap.put('moodSmile',imagesResourceLink+'/common/icon-moodSmile-16x16.png');
        imageUrlMap.put('moodHappy',imagesResourceLink+'/common/icon-moodHappy-16x16.png');
        imageUrlMap.put('chat',imagesResourceLink+'/common/icon-comments-16x16.png');
        imageUrlMap.put('dragDrop',imagesResourceLink+'/common/icon-drag-16x16.png');
        imageUrlMap.put('activity',imagesResourceLink+'/common/icon-activity-16x16.png');
        
        
        imageUrlMap.put('1',imagesResourceLink+'/common/icon-moodAngry-16x16.png');
        imageUrlMap.put('2',imagesResourceLink+'/common/icon-moodSad-16x16.png');
        imageUrlMap.put('3',imagesResourceLink+'/common/icon-moodNeutral-16x16.png');
        imageUrlMap.put('4',imagesResourceLink+'/common/icon-moodSmile-16x16.png');
        imageUrlMap.put('5',imagesResourceLink+'/common/icon-moodHappy-16x16.png');
        
        imageUrlMap.put('newModdImage',imagesResourceLink+'/kanbanImages/sprite-sheet-180x202.png');
        
        imageUrlMap.put('Draft',imagesResourceLink+'/home/icon-phase1-16x16.png');
        imageUrlMap.put('Share',imagesResourceLink+'/home/icon-phase2-16x16.png');
        imageUrlMap.put('Propose',imagesResourceLink+'/home/icon-phase3a-16x16.png');
        imageUrlMap.put('Decide',imagesResourceLink+'/home/icon-phase3b-16x16.png');
        imageUrlMap.put('Execute',imagesResourceLink+'/home/icon-phase4-16x16.png');
        imageUrlMap.put('Evaluate',imagesResourceLink+'/home/icon-phase5-16x16.png');
        imageUrlMap.put('Close',imagesResourceLink+'/home/icon-phase6-16x16.png');
        
        // images for status
        imageUrlMap.put('Not Started',imagesResourceLink+'/common/icon-notStarted-16x16.png');
        imageUrlMap.put('In Progress',imagesResourceLink+'/common/icon-inProgress-16x16.png');
        imageUrlMap.put('Completed',imagesResourceLink+'/common/icon-completed-16x16.png');
        imageUrlMap.put('Waiting on someone else',imagesResourceLink+'/common/icon-waitingOnSomeone-16x16.png');
        imageUrlMap.put('Deferred',imagesResourceLink+'/common/icon-deferred-16x16.png');
        
        //decision highlights
        imageUrlMap.put('likeUp',imagesResourceLink+'/home/icon-likeGreen-16x16.png');
        imageUrlMap.put('likeDown',imagesResourceLink+'/home/icon-dislikeRed-16x16.png');
        imageUrlMap.put('likeNeutral',imagesResourceLink+'/home/icon-neutralYellow-16x16.png');
        //imageUrlMap.put('approveImg',imagesResourceLink+'/home/image-approveReject-51x28.png');
        imageUrlMap.put('finalApprovalImg',imagesResourceLink+'/home/image-decisionApproval-51x28.png');
        imageUrlMap.put('personalApprovalImg',imagesResourceLink+'/home/image-personalStance-51x28.png');
        imageUrlMap.put('roleApprovalImg',imagesResourceLink+'/home/image-roleAccepatnce-51x28.png');
        
        //relevancy
        imageUrlMap.put('AllStars',imagesResourceLink+'/newDecisionLifeCycle/icon_stars_all-108x198.png');
        
        imageUrlMap.put('star','0 0px no-repeat' );
        imageUrlMap.put('star1','0 -36px no-repeat');
        imageUrlMap.put('star1.5','0 -54px no-repeat');
        imageUrlMap.put('star2','0 -72px no-repeat');
        imageUrlMap.put('star2.5','0 -90px no-repeat');
        imageUrlMap.put('star3','0 -108px no-repeat');
        imageUrlMap.put('star3.5','0 -126px no-repeat');
        imageUrlMap.put('star4','0 -144px no-repeat');
        imageUrlMap.put('star4.5','0 -162px no-repeat');
        imageUrlMap.put('star5','0 -180px no-repeat');
        
        imageUrlMap.put('star11',imagesResourceLink+'/common/image-stars1-84x16.png');
        imageUrlMap.put('star21',imagesResourceLink+'/common/image-stars2-84x16.png');
        imageUrlMap.put('star31',imagesResourceLink+'/common/image-stars3-84x16.png');
        imageUrlMap.put('star41',imagesResourceLink+'/common/image-stars4-84x16.png');
        imageUrlMap.put('star51',imagesResourceLink+'/common/image-stars5-84x16.png');
        imageUrlMap.put('star1.51',imagesResourceLink+'/common/image-stars15-84x16.png');
        imageUrlMap.put('star2.51',imagesResourceLink+'/common/image-stars25-84x16.png');
        imageUrlMap.put('star3.51',imagesResourceLink+'/common/image-stars35-84x16.png');
        imageUrlMap.put('star4.51',imagesResourceLink+'/common/image-stars45-84x16.png');
        
        // Decision and Plan icon 16 px
        imageUrlMap.put('decisionicon16',imagesResourceLink+'/common/decisionCardIcon-16x16.png');
        imageUrlMap.put('planicon16',imagesResourceLink+'/common/Fingertip_plan_icon_16x16.png');
        
        // new task for decisions from plan
        imageUrlMap.put('newTaskForDecision',imagesResourceLink+'/common/icon-newTask-16x16.png');
        imageUrlMap.put('newTaskForDecisionDisabled',imagesResourceLink+'/common/icon-newTaskDisabled-16x16.png');
        // for group image mapping 
        
        //start added on 23-3-2014
        imageUrlMap.put('lifeCycleProfilePic',imagesResourceLink+'/newDecisionLifeCycle/LifeCycle-profilePic-130x130.jpg');
        // end on 23-3-2014
    }
    
    //populate a map with locale values and corresponding datetime formats
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
        locale_map.put('eu_ES', 'yyyy-mm-d HH:mm'); // manually added for locale Basque (Spain)
        String user_locale = UserInfo.getLocale();
        
        // If locale is not match with current mapping
        if(locale_map.get(user_locale) == null) {
            user_locale = 'en_US';
        }
        
        
        return locale_map.get(user_locale); //return the map
    }
    
    public String MapValuesDate(String d, String m, String y) {
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
        locale_map.put('eu_ES', 'yyyy-mm-d');  // manually added for locale Basque (Spain)
        
        String user_locale = UserInfo.getLocale();
        
       // If locale is not match with current mapping
        if(locale_map.get(user_locale) == null) {
            user_locale = 'en_US';
        }
        
        String customdate = locale_map.get(user_locale);
        customdate = customdate.toLowerCase();
        customdate = customdate.ReplaceAll('dd','d');
        customdate = customdate.ReplaceAll('mm','m');
        customdate = customdate.ReplaceAll('yyyy','y');
        customdate = customdate.ReplaceAll('yy','y');
        
        customdate = customdate.ReplaceAll('d',d);
        customdate = customdate.ReplaceAll('m',m);
        customdate = customdate.ReplaceAll('y',y);
        System.debug('---custom--------------------->'+customDate);
        return customdate;
        
       
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
    
    public static Map<String, String> displayCountryLocale(){
        Map<String, String> country_locale_map = new Map<String, String>(); //holds the country to locale mapping
        /*country_locale_map.put('Afrikaans','af_ZA');
        country_locale_map.put('Afrikaans (South Africa)','af_ZA');
        country_locale_map.put('Albanian','sq_AL');
        country_locale_map.put('Albanian (Albania)','sq_AL');
        country_locale_map.put('Alsatian (France)','gsw_FR');
        country_locale_map.put('Amharic (Ethiopia)','am_ET');
        country_locale_map.put('Arabic‎','ar');
        country_locale_map.put('Arabic (Algeria)‎','ar_DZ');
        country_locale_map.put('Arabic (Bahrain)','ar_BH');
        country_locale_map.put('Arabic (Egypt)‎','ar_EG');
        country_locale_map.put('Arabic (Iraq)‎','ar_IQ');
        country_locale_map.put('Arabic (Jordan)','ar_JO');
        country_locale_map.put('Arabic (Kuwait)‎','ar_KW');
        country_locale_map.put('Arabic (Lebanon)','ar_LB');
        country_locale_map.put('Arabic (Libya)‎','ar_LY');
        country_locale_map.put('Arabic (Morocco)','ar_MA');
        country_locale_map.put('Arabic (Oman)','ar_OM');
        country_locale_map.put('Arabic (Qatar)‎','ar_QA');
        country_locale_map.put('Arabic (Saudi Arabia)','ar_SA');
        country_locale_map.put('Arabic (Syria)‎','ar_SY');
        country_locale_map.put('Arabic (Tunisia)‎','ar_TN');
        country_locale_map.put('Arabic (U.A.E.)‎','ar_AE');
        country_locale_map.put('Arabic (Yemen)','ar_YE');
        country_locale_map.put('Armenian (Armenia)','hy_AM');
        country_locale_map.put('Assamese (India)','as_IN');
        country_locale_map.put('Azeri','az');*/
        country_locale_map.put('az_Cyrl_AZ','Azeri (Cyrillic, Azerbaijan)');
        country_locale_map.put('az_Latn_AZ','Azeri (Latin, Azerbaijan)');
        country_locale_map.put('ba_RU','Bashkir (Russia)');
        country_locale_map.put('eu','Basque');
        country_locale_map.put('eu_ES','Basque (Basque)');
        country_locale_map.put('be','Belarusian');
        country_locale_map.put('be_BY','Belarusian (Belarus)');
        country_locale_map.put('bn_BD','Bengali (Bangladesh)');
        country_locale_map.put('bn_IN','Bengali (India)');
        country_locale_map.put('bs_Cyrl_BA','Bosnian (Cyrillic, Bosnia and Herzegovina)');
        country_locale_map.put('bs_Latn_BA','Bosnian (Latin, Bosnia and Herzegovina)');
        country_locale_map.put('br_FR','Breton (France)');
        country_locale_map.put('bg','Bulgarian');
        country_locale_map.put('bg_BG','Bulgarian (Bulgaria)');
        country_locale_map.put('ca','Catalan');
        country_locale_map.put('ca_ES','Catalan (Catalan)');
        country_locale_map.put('zh_HK','Chinese (Hong Kong S.A.R.)');
        country_locale_map.put('zh_MO','Chinese (Macao S.A.R.)');
        country_locale_map.put('zh_CN','Chinese (People Republic of China)');
        
        
        country_locale_map.put('es','Spanish');
        /*country_locale_map.put('Armenian','hy');
        country_locale_map.put('Armenian','hy');
        country_locale_map.put('Armenian','hy');
        country_locale_map.put('Armenian','hy');
        country_locale_map.put('Armenian','hy');
        country_locale_map.put('Armenian','hy');
        country_locale_map.put('Armenian','hy');
        country_locale_map.put('Armenian','hy');
        country_locale_map.put('Armenian','hy');
        country_locale_map.put('Armenian','hy');
        country_locale_map.put('Armenian','hy');
        country_locale_map.put('Armenian','hy');
        country_locale_map.put('Armenian','hy');*/
        
        return country_locale_map;
    }
    
    public static String displayDifferencesforTimimg(Datetime endDt,Datetime startdt){
        if(endDt !=null && startdt != null) {
        Long secondsBetween = endDt.getTime()  / 1000 - startdt.getTime()  / 1000;
        
        Double  numdays = Math.floor((secondsBetween/86400));
        
        Double numhours = Math.floor((math.mod(secondsBetween, 86400) ) / 3600);
        
        Double numminutes = Math.floor(math.mod(math.mod(secondsBetween, 86400),3600) / 60);
          
        Double numseconds =  math.mod(math.mod(math.mod(secondsBetween, 86400),3600),60);
          
        return String.valueOf(numdays.intValue())+ ' d : '+ String.valueOf(numhours.intValue()) + ' h : ' + String.valueOf(numminutes.intValue()) + ' m : ' + String.valueOf(numseconds.intValue()) + ' s ';
        
        }
        else {
            return '';
        }
    }
    
    public static string displayDifferencesforAccumualted(Datetime endDt,Datetime startdt){
        if(endDt !=null && startdt != null) {
        Long secondsBetween = endDt.getTime()  / 1000 - startdt.getTime()  / 1000;
        
        Double  numdays = Math.floor((secondsBetween/86400));
        
        Double numhours = Math.floor((math.mod(secondsBetween, 86400) ) / 3600);
        
        Double numminutes = Math.floor(math.mod(math.mod(secondsBetween, 86400),3600) / 60);
          
        Double numseconds =  math.mod(math.mod(math.mod(secondsBetween, 86400),3600),60);
          
        return String.valueOf(numdays.intValue())+ ' d : '+ String.valueOf(numhours.intValue()) + ' h : ' + String.valueOf(numminutes.intValue()) + ' m : ' + String.valueOf(numseconds.intValue()) + ' s ';
        
        }
        else {
            return '';
        }
    }
    
    
    // Convert list to string for group member name
    public static String listToStringConvert(List<String> grpMemberList) {
        
        
        if(generalInfo == null){
            generalInfo = new GeneralInformation();
        } 
        
        String UserName = '';
        Integer i = 0;
        for(String str : grpMemberList) {
            if(UserName == '') {
                UserName = generalInfo.useNameMap.get(str).Name;
            }
            else {
                if(i<4){
                    UserName = UserName + ',' + generalInfo.useNameMap.get(str).Name;
                    i++;
                }
            }
        }
        return  UserName;       
    }
}