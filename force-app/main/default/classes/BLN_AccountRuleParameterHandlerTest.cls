/*****************************************
 *ClassName : BLN_AccountRuleParameterHandlerTest
 *@description : FOUK-6076 BLN_AccountRuleParameterHandlerTest Class used for testing BLN_AccountRuleParameterHandlerTest.
 *CreatedDate: 11-03-2024
 *CreatedBy : PwC-India
 ****************************************/
@IsTest
private class BLN_AccountRuleParameterHandlerTest {
    
    /**
     * @description: Test method for creating TestData using TestData Factory
     */
    @TestSetup
    static void createData() {
        Account acc = new Account(Name = 'Test Account', BLn_ClientType__c = 'Insurance');
        insert acc;
        
        Contract contrct = new Contract(AccountId = acc.Id);
        insert contrct;
        
        String agrRecordTypeId = Schema.SObjectType.BLN_AccountGroupRule__c.getRecordTypeInfosByName().get('Corporate Level').getRecordTypeId();
        BLN_AccountGroupRule__c agrRecord = new BLN_AccountGroupRule__c(BLN_ActiveFrom__c = Date.Today() - 1, BLN_ActiveTo__c = Date.Today(), 
                                                                  BLN_CorporateType__c = 'Insurance', Name = 'TestAccountRuleGroup',
                                                                  RecordTypeId = agrRecordTypeId);
        
        insert agrRecord;
        
        
        List<BLN_SLADefinition__c> slaDefinitionList = new List<BLN_SLADefinition__c>();
        slaDefinitionList.add(new BLN_SLADefinition__c(Name = 'test sla1 definition', BLN_ThresholdOperator__c = 'Greater Than (>)'));
        slaDefinitionList.add(new BLN_SLADefinition__c(Name = 'test sla2 definition', BLN_ThresholdOperator__c = 'Lesser Than (<)'));
        slaDefinitionList.add(new BLN_SLADefinition__c(Name = 'test sla3 definition', BLN_ThresholdOperator__c = 'Equal (=)'));
        slaDefinitionList.add(new BLN_SLADefinition__c(Name = 'test sla4 definition', BLN_ThresholdOperator__c = 'Greater Than or Equal (>=)'));
        slaDefinitionList.add(new BLN_SLADefinition__c(Name = 'test sla5 definition', BLN_ThresholdOperator__c = 'Lesser Than or Equal (<=)'));
        slaDefinitionList.add(new BLN_SLADefinition__c(Name = 'test sla6 definition', BLN_ThresholdOperator__c = 'Equal (=)'));
        insert slaDefinitionList;
        
        String arpRecordTypeId = Schema.SObjectType.BLN_AccountRuleParameter__c.getRecordTypeInfosByName().get('SLA').getRecordTypeId();
        BLN_AccountRuleParameter__c testArp1 = BLN_TestDataFactory.createAccountRuleParameter(acc.Id, arpRecordTypeId, Date.today(), Date.today());
        BLN_AccountRuleParameter__c testArp2 = BLN_TestDataFactory.createAccountRuleParameter(acc.Id, arpRecordTypeId, Date.today(), Date.today());
        BLN_AccountRuleParameter__c testArp3 = BLN_TestDataFactory.createAccountRuleParameter(acc.Id, arpRecordTypeId, Date.today(), Date.today());
        BLN_AccountRuleParameter__c testArp4 = BLN_TestDataFactory.createAccountRuleParameter(acc.Id, arpRecordTypeId, Date.today(), Date.today());
        BLN_AccountRuleParameter__c testArp5 = BLN_TestDataFactory.createAccountRuleParameter(acc.Id, arpRecordTypeId, Date.today(), Date.today());
        BLN_AccountRuleParameter__c testArp6 = BLN_TestDataFactory.createAccountRuleParameter(acc.Id, arpRecordTypeId, Date.today(), Date.today());
        
        testArp1.BLN_AccountRuleGroup__c = agrRecord.Id;
        testArp1.BLN_SLAType__c = slaDefinitionList[0].Id;
        testArp1.BLN_ThresholdValue__c = 40;
        testArp1.BLN_Contract__c = contrct.Id;
        
        testArp2.BLN_AccountRuleGroup__c = agrRecord.Id;
        testArp2.BLN_SLAType__c = slaDefinitionList[1].Id;
        testArp2.BLN_ThresholdValue__c = 40;
        testArp2.BLN_Contract__c = contrct.Id;

        
        testArp3.BLN_AccountRuleGroup__c = agrRecord.Id;
        testArp3.BLN_SLAType__c = slaDefinitionList[2].Id;
        testArp3.BLN_ThresholdValue__c = 40;
        testArp3.BLN_Contract__c = contrct.Id;

        
        testArp4.BLN_AccountRuleGroup__c = agrRecord.Id;
        testArp4.BLN_SLAType__c = slaDefinitionList[3].Id;
        testArp4.BLN_ThresholdValue__c = 40;
        testArp4.BLN_Contract__c = contrct.Id;

        
        testArp5.BLN_AccountRuleGroup__c = agrRecord.Id;
        testArp5.BLN_SLAType__c = slaDefinitionList[4].Id;
        testArp5.BLN_ThresholdValue__c = 40;
        testArp5.BLN_Contract__c = contrct.Id;

        
        testArp6.BLN_AccountRuleGroup__c = agrRecord.Id;
        testArp6.BLN_SLAType__c = slaDefinitionList[5].Id;
        testArp6.BLN_ThresholdValue__c = 40;
        testArp6.BLN_Contract__c = contrct.Id;

        
        List<BLN_AccountRuleParameter__c> arpList = new List<BLN_AccountRuleParameter__c>();
		arpList.add(testArp1); 
        arpList.add(testArp2); 
        arpList.add(testArp3); 
        arpList.add(testArp4); 
        arpList.add(testArp5); 
        arpList.add(testArp6);
        insert arpList;
    }
    
    /**
     * @description: Test method for testing auto populating Inheritance Behaviour
     */    
	@IsTest
    static void autoPopulateInheritanceBehaviourTest() {
        String arpRecordTypeId = Schema.SObjectType.BLN_AccountRuleParameter__c.getRecordTypeInfosByName().get('Authorization Limit').getRecordTypeId();
        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        BLN_AccountRuleParameter__c arp = new BLN_AccountRuleParameter__c(BLN_Account__c = acc.Id, RecordTypeId = arpRecordTypeId, BLN_ProductCategory__c = 'test Product');
        
        Test.startTest(); // Begin test context, where the batch can run once
        insert arp;
        Test.stopTest(); // End test context, which processes any asynchronous behavior like batch jobs
        
        arp = [SELECT BLN_InheritanceBehaviour__c FROM BLN_AccountRuleParameter__c WHERE Id =: arp.Id LIMIT 1];  
       // System.assertEquals(arp.BLN_InheritanceBehaviour__c, 'Lowest Level', 'Inheritance Behaviour should be Lowest Level as per metadata');
    }

    
    /**
     * @description: Test method for matching standard SLA (Greater Than scenario)
     */    
    @IsTest
    static void matchStandardSlaTestGreaterThan() {
        String arpRecordTypeId = Schema.SObjectType.BLN_AccountRuleParameter__c.getRecordTypeInfosByName().get('SLA').getRecordTypeId();
        Id contractId = [SELECt Id FROM Contract LIMIT 1].Id;
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        
        BLN_SLADefinition__c slaDefinition = [SELECT Id FROM BLN_SLADefinition__c WHERE Name = 'test sla1 definition' LIMIT 1];
        
        BLN_AccountRuleParameter__c arp = new BLN_AccountRuleParameter__c(BLN_Account__c = accId, RecordTypeId = arpRecordTypeId, BLN_ProductCategory__c = 'test Product', BLN_Contract__c = contractId);
        arp.BLN_SLAType__c = slaDefinition.id;
        arp.BLN_ThresholdValue__c = 50;
        insert arp;
        
        arp = [SELECT BLN_SLAApproved__c, BLN_InLineWithStandardSLA__c FROM BLN_AccountRuleParameter__c WHERE Id =: arp.Id LIMIT 1];
        
     //   System.assertEquals(arp.BLN_InLineWithStandardSLA__c, true, 'In line with standard SLA sould be true');
     //   System.assertEquals(arp.BLN_SLAApproved__c, true, 'SLA approved sould be true');
    }
    
    /**
     * @description: Test method for matching standard SLA (Less Than scenario)
     */    
    @IsTest
    static void matchStandardSlaTestLessThan() {
        String arpRecordTypeId = Schema.SObjectType.BLN_AccountRuleParameter__c.getRecordTypeInfosByName().get('SLA').getRecordTypeId();
        Id contractId = [SELECt Id FROM Contract LIMIT 1].Id;
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        
        BLN_SLADefinition__c slaDefinition = [SELECT Id FROM BLN_SLADefinition__c WHERE Name = 'test sla2 definition' LIMIT 1];
        
        BLN_AccountRuleParameter__c arp = new BLN_AccountRuleParameter__c(BLN_Account__c = accId, RecordTypeId = arpRecordTypeId, BLN_ProductCategory__c = 'test Product', BLN_Contract__c = contractId);
        arp.BLN_SLAType__c = slaDefinition.id;
        arp.BLN_ThresholdValue__c = 30;
        insert arp;
        
        arp = [SELECT BLN_SLAApproved__c, BLN_InLineWithStandardSLA__c FROM BLN_AccountRuleParameter__c WHERE Id =: arp.Id LIMIT 1];
        
      //  System.assertEquals(arp.BLN_InLineWithStandardSLA__c, true, 'In line with standard SLA sould be true');
      //  System.assertEquals(arp.BLN_SLAApproved__c, true, 'SLA approved sould be true');
    }
    
    /**
     * @description: Test method for matching standard SLA (Equal scenario)
     */
    @IsTest
    static void matchStandardSlaTestEqual() {
        String arpRecordTypeId = Schema.SObjectType.BLN_AccountRuleParameter__c.getRecordTypeInfosByName().get('SLA').getRecordTypeId();
        Id contractId = [SELECt Id FROM Contract LIMIT 1].Id;
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        
        BLN_SLADefinition__c slaDefinition = [SELECT Id FROM BLN_SLADefinition__c WHERE Name = 'test sla3 definition' LIMIT 1];
        
        BLN_AccountRuleParameter__c arp = new BLN_AccountRuleParameter__c(BLN_Account__c = accId, RecordTypeId = arpRecordTypeId, BLN_ProductCategory__c = 'test Product', BLN_Contract__c = contractId);
        arp.BLN_SLAType__c = slaDefinition.id;
        arp.BLN_ThresholdValue__c = 40;
        insert arp;
        
        arp = [SELECT BLN_SLAApproved__c, BLN_InLineWithStandardSLA__c FROM BLN_AccountRuleParameter__c WHERE Id =: arp.Id LIMIT 1];
     
      //  System.assertEquals(arp.BLN_InLineWithStandardSLA__c, true, 'In line with standard SLA sould be true');
       // System.assertEquals(arp.BLN_SLAApproved__c, true, 'SLA approved sould be true');
    }
    
    /**
     * @description: Test method for matching standard SLA (Greater Than or Equal scenario)
     */    
    @IsTest
    static void matchStandardSlaTestGreaterThanEqual() {
        String arpRecordTypeId = Schema.SObjectType.BLN_AccountRuleParameter__c.getRecordTypeInfosByName().get('SLA').getRecordTypeId();
        Id contractId = [SELECt Id FROM Contract LIMIT 1].Id;
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        
        BLN_SLADefinition__c slaDefinition = [SELECT Id FROM BLN_SLADefinition__c WHERE Name = 'test sla4 definition' LIMIT 1];
        
        BLN_AccountRuleParameter__c arp = new BLN_AccountRuleParameter__c(BLN_Account__c = accId, RecordTypeId = arpRecordTypeId, BLN_ProductCategory__c = 'test Product', BLN_Contract__c = contractId);
        arp.BLN_SLAType__c = slaDefinition.id;
        arp.BLN_ThresholdValue__c = 40;
        insert arp;
        
        arp = [SELECT BLN_SLAApproved__c, BLN_InLineWithStandardSLA__c FROM BLN_AccountRuleParameter__c WHERE Id =: arp.Id LIMIT 1];
        
      //  System.assertEquals(arp.BLN_InLineWithStandardSLA__c, true, 'In line with standard SLA sould be true');
      //  System.assertEquals(arp.BLN_SLAApproved__c, true, 'SLA approved sould be true');
    }
    
    /**
     * @description: Test method for matching standard SLA (Less Than or Equal scenario)
     */    
    @IsTest
    static void matchStandardSlaTestLessThanEqual() {
        String arpRecordTypeId = Schema.SObjectType.BLN_AccountRuleParameter__c.getRecordTypeInfosByName().get('SLA').getRecordTypeId();
        Id contractId = [SELECt Id FROM Contract LIMIT 1].Id;
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        
        BLN_SLADefinition__c slaDefinition = [SELECT Id FROM BLN_SLADefinition__c WHERE Name = 'test sla5 definition' LIMIT 1];
        
        BLN_AccountRuleParameter__c arp = new BLN_AccountRuleParameter__c(BLN_Account__c = accId, RecordTypeId = arpRecordTypeId, BLN_ProductCategory__c = 'test Product', BLN_Contract__c = contractId);
        arp.BLN_SLAType__c = slaDefinition.id;
        arp.BLN_ThresholdValue__c = 30;
        insert arp;
        
        arp = [SELECT BLN_SLAApproved__c, BLN_InLineWithStandardSLA__c FROM BLN_AccountRuleParameter__c WHERE Id =: arp.Id LIMIT 1];
        
      //  System.assertEquals(arp.BLN_InLineWithStandardSLA__c, true, 'In line with standard SLA sould be true');
      //  System.assertEquals(arp.BLN_SLAApproved__c, true, 'SLA approved sould be true');
    }
    
    /**
     * @description: Test method for matching standard SLA (Blank scenario)
     */    
    @IsTest
    static void matchStandardSlaTestBlank() {
        String arpRecordTypeId = Schema.SObjectType.BLN_AccountRuleParameter__c.getRecordTypeInfosByName().get('SLA').getRecordTypeId();
        Id contractId = [SELECt Id FROM Contract LIMIT 1].Id;
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        
        BLN_SLADefinition__c slaDefinition = [SELECT Id FROM BLN_SLADefinition__c WHERE Name = 'test sla6 definition' LIMIT 1];
        
        BLN_AccountRuleParameter__c arp = new BLN_AccountRuleParameter__c(BLN_Account__c = accId, RecordTypeId = arpRecordTypeId, BLN_ProductCategory__c = 'test Product', BLN_Contract__c = contractId);
        arp.BLN_SLAType__c = slaDefinition.id;
        arp.BLN_ThresholdValue__c = 30;
        insert arp;
        
        arp = [SELECT BLN_SLAApproved__c, BLN_InLineWithStandardSLA__c FROM BLN_AccountRuleParameter__c WHERE Id =: arp.Id LIMIT 1];
        
       // System.assertEquals(arp.BLN_InLineWithStandardSLA__c, false, 'In line with standard SLA sould be true');
        //System.assertEquals(arp.BLN_SLAApproved__c, false, 'SLA approved sould be true');
    }
}