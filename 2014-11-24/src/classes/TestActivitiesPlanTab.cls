/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestActivitiesPlanTab {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        
        Plan__c p = new Plan__c();
        p.Name = 'Testing';
        insert p;
        
        PlanTab pt = new PlanTab();
        PlanTab.updatePlans('[{"thanksBadges":0,"subject":"testing text overflow5","planStartDate":"2014-01-02 14:23","planEndDate":"2014-01-15 14:23","lastActivityDate":"2014-03-05 13:13","isEditable":true,"id":"/'+p.Id+'","description":"testing text overflow in the location","decisions":0,"chatterPosts":11,"chatterPostLikes":0,"assignToId":"00590000001gHR0AAM","assignTo":"Sendil Kumar J","activityColour":"delayTask","activitiesTask":"1/3"}]');
        
        Task task = new Task();
        task.WhatId = p.Id;
        task.Subject = 'Task on decision';
        task.ActivityDate = Date.today();
        task.Status = 'Completed';
        insert task; 
        
        WorkbenchHomePage whp = new WorkbenchHomePage();
        ActivityTab at = new ActivityTab(whp);
        ActivityTab.updateActivities('[{"url":"/00TO0000007OsVgMAK?retURL=null","title":null,"subjectClassLink":null,"subject":"Stand alone4","status":"Not Started","relatedToName":"","relatedToId":"","recordAccess":true,"priority":"Normal","ownerId":"005900000011OupAAE","lastActivityDate":"2014-01-10 13:17","isTask":"Task","isEditable":false,"isDeletable":false,"id":"'+task.Id+'","icon":"resource/1396683622000/Images/common/icon-activity-16x16.png","duedate":"2014-1-10","deleteImage":"resource/1396683622000/Images/common/icon-deleteDisabled-16x16.png","delayTaskClass":"delayTask","createdByName":"Rahul Baliga","comments":"","assignedByName":"Neha Patel","assignedBy":"005900000011AggAAE","actionClassNameDelete":"grid-action-disabled"}]');
    }
}