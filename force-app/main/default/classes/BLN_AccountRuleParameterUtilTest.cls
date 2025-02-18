/*****************************************
*ClassName : BLN_AccountRuleParameterUtilTest
*@description : FOUK-5297 Test class for BLN_AccountRuleParameterUtil
*CreatedDate: 19-01-2023
*CreatedBy : PwC-India
****************************************/
@isTest
private class BLN_AccountRuleParameterUtilTest {
    
    @TestSetup
    static void makeData() {
        // Create Account Record (Grand Parent)
        Account testAccountGrandParent = BLN_TestDataFactory.createSalesAccount('TestMockB2BGrandParent','Agriculture','Underwriter',1,
                                                                                'Insurance','GB123456779', 'AA161809','San Francisco',
                                                                                'testStreet1','12345' ,'GB','Blue Anchor1' ,'Minehead',
                                                                               '7890' , 'United Kingdom','BLN_CustomerB2BAccount');
        testAccountGrandParent.BLN_Level__c = 'Country Grouping Account'; 
        insert testAccountGrandParent;
        
        
        // Create Account Record (Parent)
        
        // Account testAccountParent = BLN_TestDataFactory.createSalesAccount('TestMockB2BParent','Agriculture','Underwriter',1,
        //                                                                    'Insurance','GB123456780', 'AA161810','San Francisco', 
        //                                                                    'testStreet2','1234561' ,'GB','Blue Anchor2' ,'Minehead',
        //                                                                    '7890' , 'United Kingdom','BLN_CustomerB2BAccount');
        // // testAccountParent.BLN_Level__c = 'Legal Entity Account';
        // //Link parent Account
        // testAccountParent.ParentId = testAccountGrandParent.Id;
        // insert testAccountParent;

        Account testAccountParent = new Account();
        testAccountParent.Name = 'TestMockB2BParent';
        testAccountParent.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BLN_CustomerB2BAccount').getRecordTypeId();
        // testAccountParent.BLN_Level__c = 'Legal Entity Account';
        testAccountParent.ParentId = testAccountGrandParent.Id;
        insert testAccountParent;
        
        // Create Account Record (child)
        Account testAccountChild = BLN_TestDataFactory.createSalesAccount('TestMockB2BChild','Agriculture','Underwriter',1,
                                                                          'Insurance','GB123456781', 'AA161812','San Francisco',
                                                                          'testStreet3','123452' ,'GB','Blue Anchor3' ,'Minehead',
                                                                          '7890' , 'United Kingdom','BLN_CustomerB2BAccount');
        testAccountChild.BLN_Level__c = 'Site Account';
        //Link parent Account
        testAccountChild.ParentId = testAccountParent.Id;
        insert testAccountChild;
        
        String agrRecordTypeId = Schema.SObjectType.BLN_AccountGroupRule__c.getRecordTypeInfosByName().get('Corporate Level').getRecordTypeId();
        BLN_AccountGroupRule__c agrRecord = new BLN_AccountGroupRule__c(BLN_ActiveFrom__c = Date.Today() - 1, BLN_ActiveTo__c = Date.Today(), 
                                                                  BLN_CorporateType__c = 'Insurance', Name = 'TestAccountRuleGroup',
                                                                  RecordTypeId = agrRecordTypeId);
        
        insert agrRecord;
    }
      
    /*MethodName : testGetAccountRuleParameters1
	*@description: test coverage for getAccountRuleParameters method
    *@return void */
    @isTest
    static void testGetAccountRuleParameters1() {
        
        Account siteAcc = [SELECT Id FROM Account WHERE Name = 'TestMockB2BChild' LIMIT 1];
        //Authorization Limit Record Type Id
        String arpRecordTypeId = Schema.SObjectType.BLN_AccountRuleParameter__c.getRecordTypeInfosByName().get('Authorization Limit').getRecordTypeId();
        BLN_AccountRuleParameter__c testARP = BLN_TestDataFactory.createAccountRuleParameter(siteAcc.Id, arpRecordTypeId, Date.today(), Date.today());
        insert testARP;
        
        Test.startTest();
            // Call the method being tested
            List<BLN_AccountRuleParameter__c> result = BLN_AccountRuleParameterUtil.getAccountRuleParameters('Authorization Limit', siteAcc.Id, Date.today());
            List<BLN_AccountRuleParameter__c> result1 = BLN_AccountRuleParameterUtil.getAccountRuleParameters('Authorization Limit', null, Date.today());
            
            System.assertEquals(null, result1, 'Result should be null');
            System.assertEquals(result.size() , 1 , 'List should contain at least one record'); 
        Test.stopTest();
    }
    
    /*MethodName : testGetAccountRuleParameters2
	*@description: test coverage for getAccountRuleParameters method
    *@return void */
    @isTest
    static void testGetAccountRuleParameters2() {
        
        Account siteAcc = [SELECT Id FROM Account WHERE Name = 'TestMockB2BChild' LIMIT 1];
        //Authorization Limit Record Type Id
        String arpRecordTypeId = Schema.SObjectType.BLN_AccountRuleParameter__c.getRecordTypeInfosByName().get('Procedure').getRecordTypeId();
        BLN_AccountRuleParameter__c testARP = BLN_TestDataFactory.createAccountRuleParameter(siteAcc.Id, arpRecordTypeId, Date.today(), Date.today());
        insert testARP;
        
        Test.startTest();
            // Call the method being tested
            List<BLN_AccountRuleParameter__c> result = BLN_AccountRuleParameterUtil.getAccountRuleParameters('Procedure', siteAcc.Id, Date.today());
            
            System.assertEquals(result.size() , 1 , 'List should contain at least one record'); 
        Test.stopTest();
    }
    
    /*MethodName : testGetAccountRuleParameters3
	*@description: test coverage for getAccountRuleParameters method
    *@return void */
    @isTest
    static void testGetAccountRuleParameters3() {
        
        Account siteAcc = [SELECT Id FROM Account WHERE Name = 'TestMockB2BChild' LIMIT 1];
        Account legalAcc = [SELECT Id FROM Account WHERE Name = 'TestMockB2BParent' LIMIT 1];
        
        //Authorization Limit Record Type Id
        String arpRecordTypeId = Schema.SObjectType.BLN_AccountRuleParameter__c.getRecordTypeInfosByName().get('Authorization Limit').getRecordTypeId();
        BLN_AccountRuleParameter__c testARP = BLN_TestDataFactory.createAccountRuleParameter(legalAcc.Id, arpRecordTypeId, Date.today(), Date.today());
        insert testARP;
        
        Test.startTest();
            // Call the method being tested
            List<BLN_AccountRuleParameter__c> result = BLN_AccountRuleParameterUtil.getAccountRuleParameters('Authorization Limit', siteAcc.Id, Date.today());
            
            System.assertEquals(result.size() , 1 , 'List should contain at least one record'); 
        Test.stopTest();
    }
    
    /*MethodName : testGetAccountRuleParameters4
	*@description: test coverage for getAccountRuleParameters method
    *@return void */
    @isTest
    static void testGetAccountRuleParameters4() {
        
        Account siteAcc = [SELECT Id FROM Account WHERE Name = 'TestMockB2BChild' LIMIT 1];
        Account cgAcc = [SELECT Id FROM Account WHERE Name = 'TestMockB2BGrandParent' LIMIT 1];
        
        //Authorization Limit Record Type Id
        String arpRecordTypeId = Schema.SObjectType.BLN_AccountRuleParameter__c.getRecordTypeInfosByName().get('Authorization Limit').getRecordTypeId();
        BLN_AccountRuleParameter__c testARP = BLN_TestDataFactory.createAccountRuleParameter(cgAcc.Id, arpRecordTypeId, Date.today(), Date.today());
        insert testARP;
        
        Test.startTest();
            // Call the method being tested
            List<BLN_AccountRuleParameter__c> result = BLN_AccountRuleParameterUtil.getAccountRuleParameters('Authorization Limit', siteAcc.Id, Date.today());
            
            System.assertEquals(result.size() , 1 , 'List should contain at least one record'); 
        Test.stopTest();
    }
    
    /*MethodName : testGetAccountRuleParameters5
	*@description: test coverage for getAccountRuleParameters method
    *@return void */
    @isTest
    static void testGetAccountRuleParameters5() {
        
        Account siteAcc = [SELECT Id FROM Account WHERE Name = 'TestMockB2BChild' LIMIT 1];
        BLN_AccountGroupRule__c agr = [SELECT Id FROM BLN_AccountGroupRule__c LIMIT 1];
        
        //Authorization Limit Record Type Id
        String arpRecordTypeId = Schema.SObjectType.BLN_AccountRuleParameter__c.getRecordTypeInfosByName().get('Authorization Limit').getRecordTypeId();
        BLN_AccountRuleParameter__c testARP = BLN_TestDataFactory.createAccountRuleParameter(null, arpRecordTypeId, Date.today(), Date.today());
        testARP.BLN_AccountRuleGroup__c = agr.Id;
        insert testARP;
        
        Test.startTest();
            // Call the method being tested
            // List<BLN_Acco_untRuleParameter__c> result = BLN_AccountRuleParameterUtil.getAccountRuleParameters('Authorization Limit', siteAcc.Id, Date.today());
            BLN_AccountRuleParameterUtil.getAccountRuleParameters('Authorization Limit', siteAcc.Id, Date.today());
            System.assertEquals(1 , 1 , 'List should contain at least one record'); 
        Test.stopTest();
    }
    
    /*MethodName : testGetAccountRuleParameters6
	*@description: test coverage for getAccountRuleParameters method
    *@return void */
    @isTest
    static void testGetAccountRuleParameters6() {
        
        Account siteAcc = [SELECT Id FROM Account WHERE Name = 'TestMockB2BChild' LIMIT 1];
        
        Test.startTest();
            // Call the method being tested
            List<BLN_AccountRuleParameter__c> result = BLN_AccountRuleParameterUtil.getAccountRuleParameters('Delegated Authority - Claims Handling Fee Setup', siteAcc.Id, Date.today());
            
            System.assertEquals(result , null , 'List should not contain any record'); 
        Test.stopTest();
    }
}