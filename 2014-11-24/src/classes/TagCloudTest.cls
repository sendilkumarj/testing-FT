@isTest
private class TagCloudTest {

    static testMethod void tagCloudyTest() {
     
     	Test.startTest();
     
     	TagCloud t = new TagCloud();
     
     	Test.stopTest();
     	
     	// To check result 
     	System.assertEquals(t.hashTag.size(), 0);	
    }
}