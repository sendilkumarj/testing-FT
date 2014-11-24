public with sharing class FLS {
    
    
    // ******** DECISION **********************//
    
    public static Boolean decisionCreateable() {
        
        String [] decisionFields = new String [] {'Valid_Until__c', 'Valid_From__c', 'Title__c', 'Tag__c', 'Status__c', 'SYS_From_Quick_Decision__c', 'Reason_for_Close__c', 'Problem_Idea_Advice__c', 'Private__c', 'Priority__c', 'Point_of_No_Return__c', 'Plain_Tag__c', 'Phase__c', 'Parent_Decision__c', 'OwnerId', 'Name', 'Estimated_People_Involved__c', 'Estimated_Net_Present_Value__c', 'Estimated_Investment__c', 'Estimated_Full_time_Equivalent_FTE__c', 'Estimated_Direct_Cost__c', 'Due_Date__c', 'Decision_Taken__c', 'Decision_Type__c', 'Decision_Making_Style__c', 'Decision_Approach__c', 'Comments__c', 'Category__c', 'Approved_when_Created__c', 'Add_C_I_Members__c', 'Actual_People_Involved__c', 'Actual_Net_Present_Value__c', 'Actual_Investment__c', 'Actual_Full_time_Equivalent_FTE__c', 'Actual_Direct_Cost__c','Estimated_People_Involved_Desc__c', 'Estimated_Net_Present_Value_Desc__c', 'Estimated_Investment_Desc__c', 'Estimated_Full_time_Equivalent_Desc__c', 'Estimated_Direct_Cost_Desc__c', 'Actual_People_Involved_Desc__c', 'Actual_Net_Present_Value_Desc__c', 'Actual_Investment_Desc__c', 'Actual_Full_time_Equivalent_Desc__c', 'Actual_Direct_Cost_Desc__c','Identifier__c','Estimated_Revenue__c', 'Estimated_Revenue_Desc__c', 'Actual_Revenue__c', 'Actual_Revenue_Desc__c'};  
        Map<String,Schema.SObjectField> m = Schema.SObjectType.Decision__c.fields.getMap();
        for (String fieldToCheck : decisionFields) {
            if (!m.get(fieldToCheck).getDescribe().isCreateable()) {
                return false;
            }
        }
        return true;
    }
    
    public static Boolean decisionUpdateable() {
        
        String [] decisionFields = new String [] {'Valid_Until__c', 'Valid_From__c', 'Title__c', 'Tag__c', 'Status__c', 'SYS_From_Quick_Decision__c', 'Reason_for_Close__c', 'Problem_Idea_Advice__c', 'Private__c', 'Priority__c', 'Point_of_No_Return__c', 'Plain_Tag__c', 'Phase__c', 'Parent_Decision__c', 'OwnerId', 'Name', 'Estimated_People_Involved__c', 'Estimated_Net_Present_Value__c', 'Estimated_Investment__c', 'Estimated_Full_time_Equivalent_FTE__c', 'Estimated_Direct_Cost__c', 'Due_Date__c', 'Decision_Taken__c', 'Decision_Type__c', 'Decision_Making_Style__c', 'Decision_Approach__c', 'Comments__c', 'Category__c', 'Approved_when_Created__c', 'Add_C_I_Members__c', 'Actual_People_Involved__c', 'Actual_Net_Present_Value__c', 'Actual_Investment__c', 'Actual_Full_time_Equivalent_FTE__c', 'Actual_Direct_Cost__c','Estimated_People_Involved_Desc__c', 'Estimated_Net_Present_Value_Desc__c', 'Estimated_Investment_Desc__c', 'Estimated_Full_time_Equivalent_Desc__c', 'Estimated_Direct_Cost_Desc__c', 'Actual_People_Involved_Desc__c', 'Actual_Net_Present_Value_Desc__c', 'Actual_Investment_Desc__c', 'Actual_Full_time_Equivalent_Desc__c', 'Actual_Direct_Cost_Desc__c','Identifier__c','Estimated_Revenue__c', 'Estimated_Revenue_Desc__c', 'Actual_Revenue__c', 'Actual_Revenue_Desc__c'};  
        Map<String,Schema.SObjectField> m = Schema.SObjectType.Decision__c.fields.getMap();
        for (String fieldToCheck : decisionFields) {
            if (!m.get(fieldToCheck).getDescribe().isUpdateable()) {
                return false;
            }
        }
        return true;
    }
    
    public static Boolean decisionDeletable() {
        if (!Decision__c.sObjectType.getDescribe().isDeletable()){
            return false;
        }
        return true;
    }
    
    
    // ******** SOCIAL INPUT **********************//
    
    
    public static Boolean socialInputCreateable() {
        
        String [] socialInputFields = new String [] {'Veto_Rights__c', 'User__c', 'Select_People__c', 'SYS_Tab_View_Tasks__c', 'SYS_Tab_View_Social_Input__c', 'SYS_Tab_View_Relations__c', 'SYS_Tab_View_Quality__c', 'SYS_Tab_View_History__c', 'SYS_Tab_View_Attachments__c', 'SYS_Tab_View_Approvals__c', 'SYS_Tab_View_Activites__c', 'Role_Acceptance_Status__c', 'Role_Acceptance_Required__c', 'Result__c', 'Responsible__c', 'Rating__c', 'Plan__c', 'OwnerId', 'Outcome__c', 'Name_of_the_User__c', 'Mood__c', 'Like__c', 'Informed__c', 'Final_Approval_Status__c', 'Effort__c', 'Dislike__c', 'Description__c', 'Decision__c', 'Consulted__c', 'Backup_for_Accountable__c', 'Approved_for__c', 'Accountable__c'};  
        Map<String,Schema.SObjectField> m = Schema.SObjectType.Social_Input__c.fields.getMap();
        for (String fieldToCheck : socialInputFields) {
            if (!m.get(fieldToCheck).getDescribe().isCreateable()) {
                return false;
            }
        }
        return true;
    }
    
    public static Boolean socialInputUpdateable() {
        
        String [] socialInputFields = new String [] {'Veto_Rights__c', 'User__c', 'Select_People__c', 'SYS_Tab_View_Tasks__c', 'SYS_Tab_View_Social_Input__c', 'SYS_Tab_View_Relations__c', 'SYS_Tab_View_Quality__c', 'SYS_Tab_View_History__c', 'SYS_Tab_View_Attachments__c', 'SYS_Tab_View_Approvals__c', 'SYS_Tab_View_Activites__c', 'Role_Acceptance_Status__c', 'Role_Acceptance_Required__c', 'Result__c', 'Responsible__c', 'Rating__c', 'Plan__c', 'OwnerId', 'Outcome__c', 'Name_of_the_User__c', 'Mood__c', 'Like__c', 'Informed__c', 'Final_Approval_Status__c', 'Effort__c', 'Dislike__c', 'Description__c', 'Decision__c', 'Consulted__c', 'Backup_for_Accountable__c', 'Approved_for__c', 'Accountable__c'};  
        Map<String,Schema.SObjectField> m = Schema.SObjectType.Social_Input__c.fields.getMap();
        for (String fieldToCheck : socialInputFields) {
            if (!m.get(fieldToCheck).getDescribe().isUpdateable()) {
                return false;
            }
        }
        return true;
    }
    
    public static Boolean socialInputDeletable() {
        if (!Social_Input__c.sObjectType.getDescribe().isDeletable()){
            return false;
        }
        return true;
    }
    
    
    // ******** TAG **********************//
    public  static Boolean tagCreateable() {
        
        String [] tagFields = new String [] {'Name'};  
        Map<String,Schema.SObjectField> m = Schema.SObjectType.Tag__c.fields.getMap();
        for (String fieldToCheck : tagFields) {
            if (!m.get(fieldToCheck).getDescribe().isCreateable()) {
                return false;
            }
        }
        return true;
    }
    
    public  static Boolean tagUpdateable() {
        
        String [] tagFields = new String [] {'Name'};  
        Map<String,Schema.SObjectField> m = Schema.SObjectType.Tag__c.fields.getMap();
        for (String fieldToCheck : tagFields) {
            if (!m.get(fieldToCheck).getDescribe().isUpdateable()) {
                return false;
            }
        }
        return true;
    }
    
    public static Boolean tagDelete() {
        if (!Tag__c.sObjectType.getDescribe().isDeletable()){
            return false;
        }
        return true;
    }
    
    // ******** TAG JUNCTION**********************//
    public  static Boolean tagJunctionCreateable() {
        
        String [] tagJunctionFields = new String [] {'Related_To_ID__c', 'Related_To_Name__c', 'Related_To_Object__c', 'Tag_Name__c'};  
        Map<String,Schema.SObjectField> m = Schema.SObjectType.Tag_Junction__c.fields.getMap();
        for (String fieldToCheck : tagJunctionFields) {
            if (!m.get(fieldToCheck).getDescribe().isCreateable()) {
                return false;
            }
        }
        return true;
    }
    
    public  static Boolean tagJunctionUpdateable() {
        
        String [] tagJunctionFields = new String [] {'Related_To_ID__c', 'Related_To_Name__c', 'Related_To_Object__c', 'Tag_Name__c'};  
        Map<String,Schema.SObjectField> m = Schema.SObjectType.Tag_Junction__c.fields.getMap();
        for (String fieldToCheck : tagJunctionFields) {
            if (!m.get(fieldToCheck).getDescribe().isUpdateable()) {
                return false;
            }
        }
        return true;
    }
    
    public static Boolean tagJunctionDeletable() {
        if (!Tag_Junction__c.sObjectType.getDescribe().isDeletable()){
            return false;
        }
        return true;
    }
    
    // ******** TIMING **********************//

    public  static Boolean timingCreateable() {
        
        String [] timingFields = new String [] {'Start_Date_Time__c', 'Stage__c', 'Stage_No__c', 'Related_To_Object__c', 'Related_To_Name__c', 'Related_To_ID__c', 'OwnerId', 'Object_Name__c', 'End_Date_Time__c', 'Elapsed_Time__c', 'Difference__c', 'Comments__c', 'Actual_Start_Date__c', 'Actual_End_Date__c'};  
        Map<String,Schema.SObjectField> m = Schema.SObjectType.Timing__c.fields.getMap();
        for (String fieldToCheck : timingFields) {
            if (!m.get(fieldToCheck).getDescribe().isCreateable()) {
                return false;
            }
        }
        return true;
    }
    
    public  static Boolean timingUpdateable() {
        
        String [] timingFields = new String [] {'Start_Date_Time__c', 'Stage__c', 'Stage_No__c', 'Related_To_Object__c', 'Related_To_Name__c', 'Related_To_ID__c', 'OwnerId', 'Object_Name__c', 'End_Date_Time__c', 'Elapsed_Time__c', 'Difference__c', 'Comments__c', 'Actual_Start_Date__c', 'Actual_End_Date__c'};  
        Map<String,Schema.SObjectField> m = Schema.SObjectType.Timing__c.fields.getMap();
        for (String fieldToCheck : timingFields) {
            if (!m.get(fieldToCheck).getDescribe().isUpdateable()) {
                return false;
            }
        }
        return true;
    }
    
    public static Boolean timingDelete() {
        if (!Timing__c.sObjectType.getDescribe().isDeletable()){
            return false;
        }
        return true;
    }
    
    
    // ******** ISSUES **********************//

    public  static Boolean issuesCreateable() {
    	
        return null;
       
    }
    
    public  static Boolean issuesUpdateable() {
        
       return null;
    }
    
    public static Boolean issuesDeletable() {
       return null;
    }
    
    
    // *************************************** Relation ************** //////////
    
    public  static Boolean relationCreateable() {
        
        String [] relationFields = new String [] {'Type__c', 'Strength__c', 'Select__c', 'Position__c', 'Parent_Relation__c', 'Parent_Record_Name__c', 'Parent_Object_Name__c', 'Parent_ID__c', 'OwnerId', 'Notes__c', 'Minutes__c', 'Hours__c', 'Description__c', 'Days__c', 'Child_Relation__c', 'Child_Record_Name__c', 'Child_Object_Name__c', 'Child_ID__c', 'From_Relation__c','To_Relation__c'};  
        Map<String,Schema.SObjectField> m = Schema.SObjectType.Relations__c.fields.getMap();
        for (String fieldToCheck : relationFields) {
            if (!m.get(fieldToCheck).getDescribe().isCreateable()) {
                return false;
            }
        }
        return true;
    }
    
    public  static Boolean relationUpdateable() {
        
        String [] relationFields = new String [] {'Type__c', 'Strength__c', 'Select__c', 'Position__c', 'Parent_Relation__c', 'Parent_Record_Name__c', 'Parent_Object_Name__c', 'Parent_ID__c', 'OwnerId', 'Notes__c', 'Minutes__c', 'Hours__c', 'Description__c', 'Days__c', 'Child_Relation__c', 'Child_Record_Name__c', 'Child_Object_Name__c', 'Child_ID__c','From_Relation__c','To_Relation__c'};  
        Map<String,Schema.SObjectField> m = Schema.SObjectType.Relations__c.fields.getMap();
        for (String fieldToCheck : relationFields) {
            if (!m.get(fieldToCheck).getDescribe().isUpdateable()) {
                return false;
            }
        }
        return true;
    }
    
    
    public static Boolean relationDeletable() {
        if (!Relations__c.sObjectType.getDescribe().isDeletable()){
            return false;
        }
        return true;
    }
    
    
    
    // ********************* Task **************************//
    
    public static Boolean taskDeletable() {
        if (!Task.sObjectType.getDescribe().isDeletable()){
            return false;
        }
        return true;
    }
    public  static Boolean taskCreateable() {
        
        String [] taskFields = new String [] {'WhoId', 'WhatId', 'Subject', 'Status', 'Priority', 'OwnerId', 'Description','ActivityDate'};  
        Map<String,Schema.SObjectField> m = Schema.SObjectType.Task.fields.getMap();
        for (String fieldToCheck : taskFields) {
            if (!m.get(fieldToCheck).getDescribe().isCreateable()) {
                return false;
            }
        }
        return true;
    }
    
    public  static Boolean taskUpdateable() {
        
        String [] taskFields = new String [] {'WhoId', 'WhatId', 'Subject', 'Status', 'Priority', 'OwnerId', 'Description','ActivityDate'};  
        Map<String,Schema.SObjectField> m = Schema.SObjectType.Task.fields.getMap();
        for (String fieldToCheck : taskFields) {
            if (!m.get(fieldToCheck).getDescribe().isUpdateable()) {
                return false;
            }
        }
        return true;
    }
    
    // ********************* Event **************************//
    
    public static Boolean eventDeletable() {
        if (!Event.sObjectType.getDescribe().isDeletable()){
            return false;
        }
        return true;
    }
    
    public  static Boolean eventUpdateable() {
       
        String [] eventFields = new String [] {'WhoId', 'WhatId', 'Subject', 'StartDateTime', 'ShowAs', 'OwnerId', 'Location', 'Description', 'ActivityDateTime', 'ActivityDate'};  
        Map<String,Schema.SObjectField> m = Schema.SObjectType.Event.fields.getMap();
        for (String fieldToCheck : eventFields) {
            if (!m.get(fieldToCheck).getDescribe().isUpdateable()) {
                return false;
            }
        }
        return true;
    }
    
    // ******************* Attachment *************************//
    
    public static Boolean attachmentDeletable() {
        if (Attachment.sObjectType.getDescribe().isDeletable()){
            return true;
        }
        return false;
    }
    
    public static Boolean attachmentCreateable() {
    
        String [] attachmentFields = new String [] {'Body','Name','ParentId','OwnerId', 'IsPrivate'};  
        Map<String,Schema.SObjectField> m = Schema.SObjectType.Attachment.fields.getMap();
        for (String fieldToCheck : attachmentFields) {
            if (!m.get(fieldToCheck).getDescribe().isCreateable()) {
                return false;
            }
        }
        return true;
    }
    
    
    public static Boolean attachmentUpdateable() {
    
        String [] attachmentFields = new String [] {'Body','Name','OwnerId'};  
        Map<String,Schema.SObjectField> m = Schema.SObjectType.Attachment.fields.getMap();
        for (String fieldToCheck : attachmentFields) {
            if (!m.get(fieldToCheck).getDescribe().isUpdateable()) {
                return false;
            }
        }
        return true;
    }
    // ******************* Note *************************//
    
    public static Boolean noteDeletable() {
        if (!Note.sObjectType.getDescribe().isDeletable()){
            return false;
        }
        return true;
    }
    
    public static Boolean noteCreateable() {
    
        String [] noteFields = new String [] {'Body','Title','ParentId','OwnerId','IsPrivate'};  
        Map<String,Schema.SObjectField> m = Schema.SObjectType.Note.fields.getMap();
        for (String fieldToCheck : noteFields) {
            if (!m.get(fieldToCheck).getDescribe().isCreateable()) {
                return false;
            }
        }
        return true;
    }
    
     public static Boolean noteUpdatable() {
    
        String [] noteFields = new String [] {'Body','Title','OwnerId','IsPrivate'};  
        Map<String,Schema.SObjectField> m = Schema.SObjectType.Note.fields.getMap();
        for (String fieldToCheck : noteFields) {
            if (!m.get(fieldToCheck).getDescribe().isUpdateable()) {
                return false;
            }
        }
        return true;
    }
   // ******** PLAN **********************//
  
    public static Boolean planCreateable() {
    
        String [] planFields = new String [] {'Add_C_I_Members__c', 'All_Day_Event__c', 'Assigned_To__c', 'Description__c', 'End_Time__c', 'Location__c', 'Private__c', 'Show_Time_As__c','Start_Time__c'};  
        Map<String,Schema.SObjectField> m = Schema.SObjectType.Plan__c.fields.getMap();
        for (String fieldToCheck : planFields) {
            if (!m.get(fieldToCheck).getDescribe().isCreateable()) {
                return false;
            }
        }
        return true;
    }
  
    public static Boolean planUpdateable() {
    
        String [] planFields = new String [] {'Add_C_I_Members__c', 'All_Day_Event__c', 'Assigned_To__c', 'Description__c', 'End_Time__c', 'Location__c', 'Private__c', 'Show_Time_As__c','Start_Time__c'};  
        Map<String,Schema.SObjectField> m = Schema.SObjectType.Plan__c.fields.getMap();
        for (String fieldToCheck : planFields) {
            if (!m.get(fieldToCheck).getDescribe().isUpdateable()) {
                return false;
            }
        }
        return true;
    }
  
    public static Boolean planDeletable() {
        if (!Plan__c.sObjectType.getDescribe().isDeletable()){
         return false;
        }
        return true;
    }
    
    public static Boolean topicAssignmentCreateable() {
    
        String [] topicAssignmentFields = new String [] {'EntityId', 'TopicId'};  
        Map<String,Schema.SObjectField> m = Schema.SObjectType.TopicAssignment.fields.getMap();
        for (String fieldToCheck : topicAssignmentFields) {
            if (!m.get(fieldToCheck).getDescribe().isCreateable()) {
                return false;
            }
        }
        return true;
    }
    
    public static Boolean topicAssignmentDeletable() {
        if (!TopicAssignment.sObjectType.getDescribe().isDeletable()){
         return false;
        }
        return true;
    }
    
    public static Boolean topicCreateable() {
    
        String [] topicsFields = new String [] {'Name', 'Description'};  
        Map<String,Schema.SObjectField> m = Schema.SObjectType.Topic.fields.getMap();
        for(String fieldToCheck : topicsFields) {
            if (!m.get(fieldToCheck).getDescribe().isCreateable()) {
                return false;
            }
        }
        return true;
    }
    
    public static Boolean topicsDeletable() {
        if (!Topics__c.sObjectType.getDescribe().isDeletable()){
         return false;
        }
        return true;
    }
    
    public static Boolean topicSelectedDataDeletable() {
        if (!Topic_Selected_Data__c.sObjectType.getDescribe().isDeletable()){
         return false;
        }
        return true;
    }
    
    public static Boolean topicsCreateable() {
    
        String [] topicsFields = new String [] {'RecordNumber__c', 'TopicJson__c','Name'};  
        Map<String,Schema.SObjectField> m = Schema.SObjectType.Topics__c.fields.getMap();
        for(String fieldToCheck : topicsFields) {
            if (!m.get(fieldToCheck).getDescribe().isCreateable()) {
                return false;
            }
        }
        return true;
    }
    
    public static Boolean topicsUpdateable() {
    
        String [] topicsFields = new String [] {'RecordNumber__c', 'TopicJson__c','Name'};   
        Map<String,Schema.SObjectField> m = Schema.SObjectType.Topics__c.fields.getMap();
        for (String fieldToCheck : topicsFields) {
            if (!m.get(fieldToCheck).getDescribe().isUpdateable()) {
                return false;
            }
        }
        return true;
    }
    
    public static Boolean topicSelectedDataCreateable() {
    
        String [] topicsFields = new String [] {'RecordNumber__c', 'Topic_Json__c','Name'};  
        Map<String,Schema.SObjectField> m = Schema.SObjectType.Topic_Selected_Data__c.fields.getMap();
        for(String fieldToCheck : topicsFields) {
            if (!m.get(fieldToCheck).getDescribe().isCreateable()) {
                return false;
            }
        }
        return true;
    }
    
    public static Boolean topicSelectedDataUpdateable() {
    
        String [] topicsFields = new String [] {'RecordNumber__c', 'Topic_Json__c','Name'};   
        Map<String,Schema.SObjectField> m = Schema.SObjectType.Topic_Selected_Data__c.fields.getMap();
        for (String fieldToCheck : topicsFields) {
            if (!m.get(fieldToCheck).getDescribe().isUpdateable()) {
                return false;
            }
        }
        return true;
    }
    
    public static Boolean feedCommentCreatable(){
        String [] feedCommentFields = new String [] {'CommentBody','FeedItemId'};
        Map<String,Schema.SObjectField> f = Schema.SObjectType.FeedComment.fields.getMap();
        for(String fieldToCheck : feedCommentFields){
            if(!f.get(fieldToCheck).getDescribe().isCreateable()){
                return false;
            }
        }
        return true;
    }
     public static Boolean FeedItemCreatable(){
        String [] feedCommentFields = new String [] {'Body','Type','Title'};
        Map<String,Schema.SObjectField> f = Schema.SObjectType.FeedItem.fields.getMap();
        for(String fieldToCheck : feedCommentFields){
            if(!f.get(fieldToCheck).getDescribe().isCreateable()){
                return false;
            }
        }
        return true;
    }
    
    public static Boolean FeedItemDeletable() {
        if (!FeedItem.sObjectType.getDescribe().isDeletable()){
         return false;
        }
        return true;
    }
}