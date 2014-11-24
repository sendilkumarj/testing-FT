@isTest
public class TestGenerlHistory {
    static testMethod void TestGenerlHistory1() {
        Decision__c decisionRec = new Decision__c(title__c = 'Test decision',Problem_Idea_Advice__c = 'Problem',Decision_Taken__c = 'Decision',Priority__c = 'Normal',Status__c ='Propose');
            insert decisionRec;
        GenerlHistoryComponent ghc = new GenerlHistoryComponent();
        ghc.MapValuesDateTime();
    	ghc.MapValuesDateFormate();
    }
}