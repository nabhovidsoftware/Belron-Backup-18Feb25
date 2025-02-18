/*****************************************
ClassName : BLN_CheckBvtTaskCreationUtilityTest
@description : Test class for BLN_CheckBvtTaskCreationUtility class.
@author: PwC
CreatedDate: 26-11-2024
CreatedBy : PwC-India
****************************************/
@isTest
public class BLN_CheckBvtTaskCreationUtilityTest {
    @isTest
    public static void testcheckBvtTaskCreation(){
        //Make JSON for methods.
        String jsonRes =		'{'+
        '    "status": "success",'+
        '    "quotes": ['+
        '        {'+
        '            "quoteId": "39239816",'+
        '            "locationId": "9y8hfh9",'+
        '            "quoteTotals": {'+
        '                "totalPrice": 0,'+
        '                "totalTax": 176.8,'+
        '                "totalRepair": 0,'+
        '                "totalReplacement": 629.51,'+
        '                "totalCalibration": 0,'+
        '                "totalSundries": 0,'+
        '                "totalIncludingTax": 1060.78'+
        '            },'+
        '            "insuranceTotals": {'+
        '                "payableByInsuranceRepair": 0,'+
        '                "payableByInsuranceReplacement": 0,'+
        '                "payableByInsuranceCalibration": 0,'+
        '                "payableByInsuranceSundry": 0,'+
        '                "totalPayableByInsurance": 0,'+
        '                "totalTaxPayableByInsurance": 0,'+
        '                "totalIncludingTaxPayableByInsurance": 0'+
        '            },'+
        '            "motoristTotals": {'+
        '                "payableByMotoristRepair": 0,'+
        '                "payableByMotoristReplacement": 629.51,'+
        '                "payableByMotoristCalibration": 0,'+
        '                "payableByMotoristSundry": 0,'+
        '                "totalTaxPayableByMotorist": 1060.78,'+
        '                "totalPayableByMotorist": 883.98,'+
        '                "totalInludingTaxPayableByMotorist": 1060.78'+
        '            },'+
        '            "taxTotals": {'+
        '                "totalTaxRepair": 0,'+
        '                "totalTaxReplacement": 0,'+
        '                "totalTaxCalibration": 0,'+
        '                "totalTaxSundries": 0'+
        '            },'+
        '            "tradeCompanyTotals": {'+
        '                "payableByTradeRepair": 0,'+
        '                "totalPayableByTrade": 0,'+
        '                "totalPayableByTradeIncludingTax": 0,'+
        '                "payableByTradeSundry": 0,'+
        '                "payableByTradeReplacement": 0,'+
        '                "payableByTradeCalibration": 0,'+
        '                "payableByTradeTotalTax": 0'+
        '            },'+
        '            "discountThresholdA": 848.62,'+
        '            "discountThresholdB": 689.51,'+
        '            "discountThresholdC": 618.79,'+
        '            "priceExpirationDate": "2024-05-27T00:00:00Z",'+
        '            "lineItems": ['+
        '                {'+
        '                    "lineItemId": 2,'+
        '                    "parentLineItemId": 2,'+
        '                    "bundleName": null,'+
        '                    "partNumber": "2474AGNMVZ6C",'+
        '                    "belronPartNumber": "2474AGNMVZ6C",'+
        '                    "partDescription": "MINI MINI 2CA 2016 ^WINDSCREEN  DROP DOWN BAND / ENCAPSULATION BOTTOM / FITTING SENSOR / GLASS COLOR - GREEN / SILKPRINT 4/4 / VERTICAL VIN",'+
        '                    "quantity": 1,'+
        '                    "baseListPrice": 629.51,'+
        '                    "netPrice": 629.51,'+
        '                    "taxRate": 20,'+
        '                    "totalTax": 125.9,'+
        '                    "netPriceIncludingTax": 755.41,'+
        '                    "selectProduct": true,'+
        '                    "optional": "mandatory",'+
        '                    "partOfBundle": true,'+
        '                    "bundleHierarchy": null,'+
        '                    "nonBundlePrice": null,'+
        '                    "availabilityDetails": ['+
        '                        {'+
        '                            "stockLocationId": "9y8hfh9",'+
        '                            "availableFromDate": "2024-03-27T00:00:00Z"'+
        '                        }'+
        '                    ]'+
        '                }'+
        '            ]'+
        '        }'+
        '    ]'+
        '}';

        String insuranceRTId = Schema.getGlobalDescribe().get('BLN_Corporate__c').getDescribe().getRecordTypeInfosByName().get('Insurance').getRecordTypeId();
        String corporateRTId = Schema.getGlobalDescribe().get('BLN_Corporate__c').getDescribe().getRecordTypeInfosByName().get('Corporate/Fleet').getRecordTypeId();
        String splitBillRTId = Schema.getGlobalDescribe().get('BLN_Corporate__c').getDescribe().getRecordTypeInfosByName().get('Split Bill').getRecordTypeId();

        // BLN_Corporate__c corporate1 = new BLN_Corporate__c(RecordTypeId = insuranceRTId, BLN_Vehicle__c=testVehicle.id,BLN_CHFVATStatus__c = 'Rated');
        // corporate1.BLN_InsuranceSite__c = 
        // BLN_Corporate__c corporate2 = new BLN_Corporate__c(RecordTypeId = corporateRTId, BLN_Vehicle__c=testVehicle.id,BLN_CHFVATStatus__c = 'Rated');
        // BLN_Corporate__c corporate3 = new BLN_Corporate__c(RecordTypeId = splitBillRTId, BLN_Vehicle__c=testVehicle.id,BLN_CHFVATStatus__c = 'Rated');
        // List<BLN_Corporate__c> corpList = new List<BLN_Corporate__c>();
        // corpList.add(corporate1);
        // corpList.add(corporate2);
        // corpList.add(corporate3);
        // insert corpList;

        Account accRec= new Account();
        accRec.name = 'test';
        accRec.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BLN_CustomerB2BAccount').getRecordTypeId();        
        insert accRec;

        Account accRec2= new Account();
        accRec2.name = 'test 2';
        accRec2.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BLN_CustomerB2BAccount').getRecordTypeId();        
        insert accRec2;

        // BLN_Vehicle__c vehicles = BLN_TestDataFactory.getVehicle();
        BLN_Vehicle__c vehicles = BLN_TestDataFactory.getVehicle();
        insert vehicles;

        BLN_Corporate__c corporate1=BLN_TestDataFactory.createcorporate();
        corporate1.BLN_CorporateSite__c = accRec.Id;
        corporate1.BLN_InsuranceSite__c = accRec2.id;
        corporate1.BLN_Vehicle__c = vehicles.id;
        corporate1.RecordTypeId = splitBillRTId;
        // insert corporate1;

        BLN_Corporate__c corporate2 = BLN_TestDataFactory.createcorporate();
        corporate2.BLN_CorporateSite__c = accRec.Id;
        corporate2.BLN_InsuranceSite__c = accRec2.id;
        corporate2.BLN_Vehicle__c = vehicles.id;
        corporate2.RecordTypeId = corporateRTId;
        // insert corporate2;

        BLN_Corporate__c corporate3 = BLN_TestDataFactory.createcorporate();
        corporate3.BLN_CorporateSite__c = accRec.Id;
        corporate3.BLN_InsuranceSite__c = accRec2.id;
        corporate3.BLN_Vehicle__c = vehicles.id;
        corporate3.RecordTypeId = insuranceRTId;
        // insert corporate3;

        List<BLN_Corporate__c> corpList = new List<BLN_Corporate__c>();
        corpList.add(corporate1);
        corpList.add(corporate2);
        corpList.add(corporate3);
        insert corpList;

        Account testAcc = BLN_TestDataFactory.createTestAccount();
        testAcc.FirstName = 'Test';
        testAcc.LastName = 'Cont act';
        testAcc.PersonEmail = 'test123@gmail.com';
        insert testAcc;

        Case cse = BLN_TestDataFactory.getCase('Job Request', 'New');
        cse.Type = 'Job Request';
        cse.Status = 'New';
        // cse.ContactId = testContact.Id;
        cse.BLN_ServiceGeolocation__latitude__s=46.22441984873406;
        cse.BLN_ServiceGeolocation__longitude__s=-89.02172505348693;
        cse.AccountId = testAcc.Id ;
        cse.Priority = 'Medium';
        cse.BLN_MotoristTaxStatus__c = 'Yes';
        cse.BLN_TotalMotoristLiability__c = 6000 ;
        cse.BLN_Vehicle__c = vehicles.id;
        cse.BLN_Corporate__c = corporate3.Id;
        insert cse;

        product2 prod1 = new product2();
        prod1.Name = 'Test1';
        prod1.BLN_MDMID__c = '2474AGNMVZ6C';
        prod1.ProductCode = '12345'; 
        prod1.IsActive = true;
        prod1.BLN_BondedNonBonded__c = true;
        insert prod1;

        //ARP creation
        List<BLN_AccountRuleParameter__c> arpList = new List<BLN_AccountRuleParameter__c>();
        BLN_AccountRuleParameter__c acpTest1 = new BLN_AccountRuleParameter__c(
            BLN_Account__c = accRec.Id,
            BLN_InsurerAccount__c = accRec.Id,
            BLN_ReplacementExcess__c = 123,
            BLN_VAT__c = 'Motorist',
            BLN_Excess__c = 'Motorist',
            BLN_PolicyNumbers__c = '123',
            BLN_PolicyLimit__c = 123,
            BLN_RepairExcess__c = 123,
            BLN_Remainder__c = 'Motorist',
            BLN_ActiveFrom__c = Date.today(),
            BLN_ActiveTo__c = Date.today().addDays(10),
            BLN_OEAuthorization__c = System.label.BLN_OEAuthorizationReq,
            RecordTypeId = Schema.SObjectType.BLN_AccountRuleParameter__c.getRecordTypeInfosByDeveloperName().get('BLN_OEAuthorization').getRecordTypeId()
        );
        // insert acpTest;

        BLN_AccountRuleParameter__c acpTest2 = new BLN_AccountRuleParameter__c(
            BLN_Account__c = accRec.Id,
            BLN_InsurerAccount__c = accRec.Id,
            BLN_ReplacementExcess__c = 123,
            BLN_VAT__c = 'Motorist',
            BLN_Excess__c = 'Motorist',
            BLN_PolicyNumbers__c = '123',
            BLN_PolicyLimit__c = 123,
            BLN_RepairExcess__c = 123,
            BLN_Remainder__c = 'Motorist',
            BLN_ActiveFrom__c = Date.today(),
            BLN_ActiveTo__c = Date.today().addDays(10),
            BLN_AuthorizationLimit__c = 0,
            RecordTypeId = Schema.SObjectType.BLN_AccountRuleParameter__c.getRecordTypeInfosByDeveloperName().get('BLN_AuthorizationLimit').getRecordTypeId()
        );

        BLN_AccountRuleParameter__c acpTest3 = new BLN_AccountRuleParameter__c(
            BLN_Account__c = accRec.Id,
            BLN_InsurerAccount__c = accRec.Id,
            BLN_ReplacementExcess__c = 123,
            BLN_VAT__c = 'Motorist',
            BLN_Excess__c = 'Motorist',
            BLN_PolicyNumbers__c = '123',
            BLN_PolicyLimit__c = 123,
            BLN_RepairExcess__c = 123,
            BLN_Remainder__c = 'Motorist',
            BLN_ActiveFrom__c = Date.today(),
            BLN_ActiveTo__c = Date.today().addDays(10),
            BLN_Product__c = prod1.Id,
            RecordTypeId = Schema.SObjectType.BLN_AccountRuleParameter__c.getRecordTypeInfosByDeveloperName().get('BLN_ProductAllowance').getRecordTypeId()
        );

        // insert acpTest;
        arpList.add(acpTest1);
        arpList.add(acpTest2);
        arpList.add(acpTest3);
        insert arpList;

        Test.startTest();
        Boolean result1 = BLN_CheckBvtTaskCreationUtility.checkBvtTaskCreation(jsonRes, cse.Id);

        cse.BLN_Corporate__c = corporate2.Id;
        update cse;
        Boolean result2 = BLN_CheckBvtTaskCreationUtility.checkBvtTaskCreation(jsonRes, cse.Id);

        cse.BLN_Corporate__c = corporate1.Id;
        update cse;
        Boolean result3 = BLN_CheckBvtTaskCreationUtility.checkBvtTaskCreation(jsonRes, cse.Id);

        BLN_CheckBvtTaskCreationUtility.setAccountId(corporate1);

        BLN_CheckBvtTaskCreationUtility.setAccountId(corporate2);

        BLN_CheckBvtTaskCreationUtility.setAccountId(corporate3);

        Test.stopTest();

        system.assertEquals(true, result1, 'Value should be true');
        system.assertEquals(true, result2, 'Value should be true');
        system.assertEquals(true, result3, 'Value should be true');
    }

    @isTest
    public static void testcheckBvtTaskCreationSplitBill(){
        //Make JSON for methods.
        String jsonRes =		'{'+
        '    "status": "success",'+
        '    "quotes": ['+
        '        {'+
        '            "quoteId": "39239816",'+
        '            "locationId": "9y8hfh9",'+
        '            "quoteTotals": {'+
        '                "totalPrice": 0,'+
        '                "totalTax": 176.8,'+
        '                "totalRepair": 0,'+
        '                "totalReplacement": 629.51,'+
        '                "totalCalibration": 0,'+
        '                "totalSundries": 0,'+
        '                "totalIncludingTax": 1060.78'+
        '            },'+
        '            "insuranceTotals": {'+
        '                "payableByInsuranceRepair": 0,'+
        '                "payableByInsuranceReplacement": 0,'+
        '                "payableByInsuranceCalibration": 0,'+
        '                "payableByInsuranceSundry": 0,'+
        '                "totalPayableByInsurance": 0,'+
        '                "totalTaxPayableByInsurance": 0,'+
        '                "totalIncludingTaxPayableByInsurance": 10'+
        '            },'+
        '            "motoristTotals": {'+
        '                "payableByMotoristRepair": 0,'+
        '                "payableByMotoristReplacement": 629.51,'+
        '                "payableByMotoristCalibration": 0,'+
        '                "payableByMotoristSundry": 0,'+
        '                "totalTaxPayableByMotorist": 1060.78,'+
        '                "totalPayableByMotorist": 883.98,'+
        '                "totalInludingTaxPayableByMotorist": 1060.78'+
        '            },'+
        '            "taxTotals": {'+
        '                "totalTaxRepair": 0,'+
        '                "totalTaxReplacement": 0,'+
        '                "totalTaxCalibration": 0,'+
        '                "totalTaxSundries": 0'+
        '            },'+
        '            "tradeCompanyTotals": {'+
        '                "payableByTradeRepair": 0,'+
        '                "totalPayableByTrade": 0,'+
        '                "totalPayableByTradeIncludingTax": 10,'+
        '                "payableByTradeSundry": 0,'+
        '                "payableByTradeReplacement": 0,'+
        '                "payableByTradeCalibration": 0,'+
        '                "payableByTradeTotalTax": 0'+
        '            },'+
        '            "discountThresholdA": 848.62,'+
        '            "discountThresholdB": 689.51,'+
        '            "discountThresholdC": 618.79,'+
        '            "priceExpirationDate": "2024-05-27T00:00:00Z",'+
        '            "lineItems": ['+
        '                {'+
        '                    "lineItemId": 2,'+
        '                    "parentLineItemId": 2,'+
        '                    "bundleName": null,'+
        '                    "partNumber": "2474AGNMVZ6C",'+
        '                    "belronPartNumber": "2474AGNMVZ6C",'+
        '                    "partDescription": "MINI MINI 2CA 2016 ^WINDSCREEN  DROP DOWN BAND / ENCAPSULATION BOTTOM / FITTING SENSOR / GLASS COLOR - GREEN / SILKPRINT 4/4 / VERTICAL VIN",'+
        '                    "quantity": 1,'+
        '                    "baseListPrice": 629.51,'+
        '                    "netPrice": 629.51,'+
        '                    "taxRate": 20,'+
        '                    "totalTax": 125.9,'+
        '                    "netPriceIncludingTax": 755.41,'+
        '                    "selectProduct": true,'+
        '                    "optional": "mandatory",'+
        '                    "partOfBundle": true,'+
        '                    "bundleHierarchy": null,'+
        '                    "nonBundlePrice": null,'+
        '                    "totalIncludingTaxPayableByInsurance": 10,'+
        '                    "totalPayableByTradeIncludingTax": 10,'+
        '                    "availabilityDetails": ['+
        '                        {'+
        '                            "stockLocationId": "9y8hfh9",'+
        '                            "availableFromDate": "2024-03-27T00:00:00Z"'+
        '                        }'+
        '                    ]'+
        '                }'+
        '            ]'+
        '        }'+
        '    ]'+
        '}';

        String splitBillRTId = Schema.getGlobalDescribe().get('BLN_Corporate__c').getDescribe().getRecordTypeInfosByName().get('Split Bill').getRecordTypeId();

        Account accRec= new Account();
        accRec.name = 'test';
        accRec.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BLN_CustomerB2BAccount').getRecordTypeId();        
        insert accRec;

        Account accRec2= new Account();
        accRec2.name = 'test 2';
        accRec2.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BLN_CustomerB2BAccount').getRecordTypeId();        
        insert accRec2;

        // BLN_Vehicle__c vehicles = BLN_TestDataFactory.getVehicle();
        BLN_Vehicle__c vehicles = BLN_TestDataFactory.getVehicle();
        insert vehicles;

        BLN_Corporate__c corporate1=BLN_TestDataFactory.createcorporate();
        corporate1.BLN_CorporateSite__c = accRec2.Id;
        corporate1.BLN_InsuranceSite__c = accRec.id;
        corporate1.BLN_Vehicle__c = vehicles.id;
        corporate1.RecordTypeId = splitBillRTId;
        insert corporate1;

        //ARP creation
        List<BLN_AccountRuleParameter__c> arpList = new List<BLN_AccountRuleParameter__c>();
        BLN_AccountRuleParameter__c acpTest1 = new BLN_AccountRuleParameter__c(
            BLN_Account__c = accRec.Id,
            BLN_InsurerAccount__c = accRec.Id,
            BLN_ReplacementExcess__c = 123,
            BLN_VAT__c = 'Motorist',
            BLN_Excess__c = 'Motorist',
            BLN_PolicyNumbers__c = '123',
            BLN_PolicyLimit__c = 123,
            BLN_RepairExcess__c = 123,
            BLN_Remainder__c = 'Motorist',
            BLN_ActiveFrom__c = Date.today(),
            BLN_ActiveTo__c = Date.today().addDays(10),
            BLN_OEAuthorization__c = System.label.BLN_OEAuthorizationReq,
            RecordTypeId = Schema.SObjectType.BLN_AccountRuleParameter__c.getRecordTypeInfosByDeveloperName().get('BLN_OEAuthorization').getRecordTypeId()
        );
        // insert acpTest;

        BLN_AccountRuleParameter__c acpTest2 = new BLN_AccountRuleParameter__c(
            BLN_Account__c = accRec2.Id,
            BLN_InsurerAccount__c = accRec2.Id,
            BLN_ReplacementExcess__c = 123,
            BLN_VAT__c = 'Motorist',
            BLN_Excess__c = 'Motorist',
            BLN_PolicyNumbers__c = '123',
            BLN_PolicyLimit__c = 123,
            BLN_RepairExcess__c = 123,
            BLN_Remainder__c = 'Motorist',
            BLN_ActiveFrom__c = Date.today(),
            BLN_ActiveTo__c = Date.today().addDays(10),
            BLN_OEAuthorization__c = System.label.BLN_OEAuthorizationReq,
            RecordTypeId = Schema.SObjectType.BLN_AccountRuleParameter__c.getRecordTypeInfosByDeveloperName().get('BLN_OEAuthorization').getRecordTypeId()
        );

        BLN_AccountRuleParameter__c acpTest3 = new BLN_AccountRuleParameter__c(
            BLN_Account__c = accRec.Id,
            BLN_InsurerAccount__c = accRec.Id,
            BLN_ReplacementExcess__c = 123,
            BLN_VAT__c = 'Motorist',
            BLN_Excess__c = 'Motorist',
            BLN_PolicyNumbers__c = '123',
            BLN_PolicyLimit__c = 123,
            BLN_RepairExcess__c = 123,
            BLN_Remainder__c = 'Motorist',
            BLN_ActiveFrom__c = Date.today(),
            BLN_ActiveTo__c = Date.today().addDays(10),
            BLN_AuthorizationLimit__c = 0,
            RecordTypeId = Schema.SObjectType.BLN_AccountRuleParameter__c.getRecordTypeInfosByDeveloperName().get('BLN_AuthorizationLimit').getRecordTypeId()
        );

        BLN_AccountRuleParameter__c acpTest4 = new BLN_AccountRuleParameter__c(
            BLN_Account__c = accRec2.Id,
            BLN_InsurerAccount__c = accRec2.Id,
            BLN_ReplacementExcess__c = 123,
            BLN_VAT__c = 'Motorist',
            BLN_Excess__c = 'Motorist',
            BLN_PolicyNumbers__c = '123',
            BLN_PolicyLimit__c = 123,
            BLN_RepairExcess__c = 123,
            BLN_Remainder__c = 'Motorist',
            BLN_ActiveFrom__c = Date.today(),
            BLN_ActiveTo__c = Date.today().addDays(10),
            BLN_AuthorizationLimit__c = 0,
            RecordTypeId = Schema.SObjectType.BLN_AccountRuleParameter__c.getRecordTypeInfosByDeveloperName().get('BLN_AuthorizationLimit').getRecordTypeId()
        );

        //Add products for Product allowance ARP
        product2 prod1 = new product2();
        prod1.Name = 'Test1';
        prod1.BLN_MDMID__c = '2474AGNMVZ6C';
        prod1.ProductCode = '12345'; 
        prod1.IsActive = true;
        prod1.BLN_BondedNonBonded__c = true;
        insert prod1;

        BLN_AccountRuleParameter__c acpTest5 = new BLN_AccountRuleParameter__c(
            BLN_Account__c = accRec.Id,
            BLN_InsurerAccount__c = accRec.Id,
            BLN_ReplacementExcess__c = 123,
            BLN_VAT__c = 'Motorist',
            BLN_Excess__c = 'Motorist',
            BLN_PolicyNumbers__c = '123',
            BLN_PolicyLimit__c = 123,
            BLN_RepairExcess__c = 123,
            BLN_Remainder__c = 'Motorist',
            BLN_ActiveFrom__c = Date.today(),
            BLN_ActiveTo__c = Date.today().addDays(10),
            BLN_Product__c = prod1.Id,
            RecordTypeId = Schema.SObjectType.BLN_AccountRuleParameter__c.getRecordTypeInfosByDeveloperName().get('BLN_ProductAllowance').getRecordTypeId()
        );

        BLN_AccountRuleParameter__c acpTest6 = new BLN_AccountRuleParameter__c(
            BLN_Account__c = accRec2.Id,
            BLN_InsurerAccount__c = accRec2.Id,
            BLN_ReplacementExcess__c = 123,
            BLN_VAT__c = 'Motorist',
            BLN_Excess__c = 'Motorist',
            BLN_PolicyNumbers__c = '123',
            BLN_PolicyLimit__c = 123,
            BLN_RepairExcess__c = 123,
            BLN_Remainder__c = 'Motorist',
            BLN_ActiveFrom__c = Date.today(),
            BLN_ActiveTo__c = Date.today().addDays(10),
            BLN_Product__c = prod1.Id,
            RecordTypeId = Schema.SObjectType.BLN_AccountRuleParameter__c.getRecordTypeInfosByDeveloperName().get('BLN_ProductAllowance').getRecordTypeId()
        );

        arpList.add(acpTest1);
        arpList.add(acpTest2);
        arpList.add(acpTest3);
        arpList.add(acpTest4);
        arpList.add(acpTest5);
        arpList.add(acpTest6);
        insert arpList;

        Account testAcc = BLN_TestDataFactory.createTestAccount();
        testAcc.FirstName = 'Test';
        testAcc.LastName = 'Cont act';
        testAcc.PersonEmail = 'test123@gmail.com';
        insert testAcc;

        Case cse = BLN_TestDataFactory.getCase('Job Request', 'New');
        cse.Type = 'Job Request';
        cse.Status = 'New';
        // cse.ContactId = testContact.Id;
        cse.BLN_ServiceGeolocation__latitude__s=46.22441984873406;
        cse.BLN_ServiceGeolocation__longitude__s=-89.02172505348693;
        cse.AccountId = testAcc.Id ;
        cse.Priority = 'Medium';
        cse.BLN_MotoristTaxStatus__c = 'Yes';
        cse.BLN_TotalMotoristLiability__c = 6000 ;
        cse.BLN_Vehicle__c = vehicles.id;
        cse.BLN_Corporate__c = corporate1.Id;
        insert cse;

        Test.startTest();
        Boolean result1 = BLN_CheckBvtTaskCreationUtility.checkBvtTaskCreation(jsonRes, cse.Id);
        
        acpTest1.BLN_OEAuthorization__c = System.label.BLN_OEMotoristLiability;
        update acpTest1;
        Boolean result2 = BLN_CheckBvtTaskCreationUtility.checkBvtTaskCreation(jsonRes, cse.Id);
        Test.stopTest();

        system.assertEquals(true, result1, 'Value should be true');
        system.assertEquals(true, result2, 'Value should be true');
    }
}