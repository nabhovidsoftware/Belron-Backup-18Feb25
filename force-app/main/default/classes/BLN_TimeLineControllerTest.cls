@IsTest
private class BLN_TimeLineControllerTest {
    @TestSetup
    static void createData() {
        Account acc = new Account(Name = 'Account 1');
        insert acc;
        
    	BLN_AccountPlan__c acPlan = new BLN_AccountPlan__c(BLN_AccountName__c = acc.Id);
        insert acPlan;
        
        List<BLN_Initiative__c> initiativeList = new List<BLN_Initiative__c>();
        initiativeList.add(new BLN_Initiative__c(Name = 'Int 1', BLN_Status__c = 'In Progress', BLN_EndDate__c = System.today() + 1, BLN_StartDate__c = System.today(), BLN_AccountPlanName__c = acPlan.Id, BLN_ClientPriority__c = 'High'));
        initiativeList.add(new BLN_Initiative__c(Name = 'Int 2', BLN_Status__c = 'Completed', BLN_EndDate__c = System.today() + 1, BLN_StartDate__c = System.today(), BLN_AccountPlanName__c = acPlan.Id, BLN_ClientPriority__c = 'High'));
        initiativeList.add(new BLN_Initiative__c(Name = 'Int 3', BLN_Status__c = 'In Progress', BLN_EndDate__c = System.today() - 1, BLN_StartDate__c = System.today() - 2, BLN_AccountPlanName__c = acPlan.Id, BLN_ClientPriority__c = 'High'));
        initiativeList.add(new BLN_Initiative__c(Name = 'Int 4', BLN_Status__c = 'Planned', BLN_EndDate__c = System.today() - 1, BLN_StartDate__c = System.today() - 2, BLN_AccountPlanName__c = acPlan.Id, BLN_ClientPriority__c = 'High'));
        insert initiativeList;
    }
    
	@IsTest
    static void getInitiativesTest() {
        BLN_AccountPlan__c acPlan = [SELECT Id FROM BLN_AccountPlan__c LIMIT 1];
        
        Test.startTest();
        	List<BLN_WrapperStore.InitiativeWrapper> intWrapList = BLN_TimeLineController.getInitiatives(acPlan.Id);
        Test.stopTest();
        
        System.assertEquals(intWrapList.size(), 4, 'Wrapper should have 4 records');
    }
}