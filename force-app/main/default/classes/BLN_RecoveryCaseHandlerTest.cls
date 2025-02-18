/*****************************************
ClassName : BLN_RecoveryCaseHandlerTest
Description : FOUK-6164 This test class is used to cover testcoverage for BLN_RecoveryCaseHandler.
CreatedDate: 12-03-2024
CreatedBy : PwC-India
****************************************/


@isTest
private class BLN_RecoveryCaseHandlerTest {
    /*Description : Creating a records using testDataFactory for case*/
    @isTest
    static void testCalculateRecoveryCasePriority() {
        Case casedata=BLN_TestDataFactory.createCaseForRecovery('Price (Cash Opportunities)','Customer Checking Finances',FALSE);
        casedata.BLN_Corporate__c = null;
        insert casedata;
        
        /*Description : Creating a records using testDataFactory for Vehicle Damage*/
        BLN_VehicleDamage__c vehicledamage=BLN_TestDataFactory.createVehcileDamagerForRecovery();
        vehicledamage.BLN_Case__c =	casedata.Id;
        insert vehicledamage;
        
        // Call the method 
        Test.startTest();
        List<Case> caseList = [SELECT Id, BLN_ServiceType__c, BLN_Corporate__c, BLN_SecondaryReason__c, BLN_Escalated__c FROM Case WHERE Id = :casedata.Id ];
        BLN_RecoveryCaseHandler.calculateRecoveryCasePriority(caseList);
        Test.stopTest();
        
        // Verify the priority calculation
        Case updatedCase = [SELECT Id, Priority FROM Case WHERE Id = :casedata.Id];
        System.assertEquals('High', updatedCase.Priority, 'Priority should be set to High');
        
    }  
    
    @isTest
    static void testCalculateRecoveryCasePriorityMedium() {
        Case casedataformedium=BLN_TestDataFactory.createCaseForRecovery('Price (Cash Opportunities)','Customer Checking Finances',FALSE);
        casedataformedium.BLN_Escalated__c = FALSE;
        insert casedataformedium;

        BLN_Vehicle__c veh = BLN_TestDataFactory.getVehicle();
        veh.BLN_VIN__c='';
        insert veh;
        
        BLN_Corporate__c corporate=BLN_TestDataFactory.createcorporate();
        corporate.BLN_Vehicle__c=veh.Id;
        insert corporate;
        
        Case casedataformedium1=BLN_TestDataFactory.createCaseForRecovery('Price (Cash Opportunities)','Customer Checking Finances',FALSE);
        casedataformedium1.BLN_Corporate__c = corporate.id;
        insert casedataformedium1;
        
        /*Description : Creating a records using testDataFactory for Vehicle Damage*/
        BLN_VehicleDamage__c vehicledamage=BLN_TestDataFactory.createVehcileDamagerForRecovery();
        vehicledamage.BLN_Case__c =	casedataformedium1.Id;
        insert vehicledamage;
        
        // Call the method
        Test.startTest();
        List<Case> caseList = [SELECT Id, BLN_ServiceType__c, BLN_Corporate__c, BLN_SecondaryReason__c, BLN_Escalated__c FROM Case WHERE Id = :casedataformedium.Id OR Id = :casedataformedium1.Id ];
        BLN_RecoveryCaseHandler.calculateRecoveryCasePriority(caseList);
        Test.stopTest();
        
        // Verify the priority calculation
        Case updatedCase = [SELECT Id, Priority FROM Case WHERE Id = :casedataformedium.Id];
        System.assertEquals('Medium', updatedCase.Priority, 'Priority should be set to High');
        
        
    }

    @isTest
    static void testCalculateRecoveryCasePriorityCriticalEscalated() {
        Case casedata=BLN_TestDataFactory.createCaseForRecovery('Price (Cash Opportunities)','Customer Checking Finances',TRUE);
        casedata.BLN_Corporate__c = null;
        insert casedata;
        
        /*Description : Creating a records using testDataFactory for Vehicle Damage*/
        BLN_VehicleDamage__c vehicledamage=BLN_TestDataFactory.createVehcileDamagerForRecovery();
        vehicledamage.BLN_Case__c =	casedata.Id;
        insert vehicledamage;
        
        // Call the method 
        Test.startTest();
        List<Case> caseList = [SELECT Id, BLN_ServiceType__c, BLN_Corporate__c, BLN_SecondaryReason__c, BLN_Escalated__c FROM Case WHERE Id = :casedata.Id ];
        BLN_RecoveryCaseHandler.calculateRecoveryCasePriority(caseList);
        Test.stopTest();
        
        // Verify the priority calculation
        Case updatedCase = [SELECT Id, Priority FROM Case WHERE Id = :casedata.Id];
        System.assertEquals('Critical', updatedCase.Priority, 'Priority should be set to Critical');
    }  
}