@isTest
public class BLN_QuoteBookingHandlerTest {
    private class MockResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
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
                '                    "optional": "mandatory",'+
                '                    "partOfBundle": false,'+
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
            //String contentType = 'application/x-www-form-urlencoded';
            if(req.getEndpoint() == 'callout:BLN_OktaAuthToken'){
                HttpResponse response = new HttpResponse();
                response.setBody('{"token_type":"Bearer","expires_in":3600,"access_token":"MockAccessToken123","scope":"read"}');
                response.setStatusCode(200);
                return response;      
            }else {
                HttpResponse response = new HttpResponse();
                response.setBody(jsonRes);
                response.setStatusCode(200);
                return response; 
            }
        }
    }
    @isTest
    public static void createOrderAndOrderItemForISPTest(){
        
        Account testAcc = BLN_TestDataFactory.createTestAccount();
        testAcc.FirstName = 'Test';
        testAcc.LastName = 'Contact';
        testAcc.PersonEmail = 'test123@gmail.com';
        insert testAcc;
        
        Contact testContact = BLN_TestDataFactory.getContact('Test');
        testContact.FirstName = 'Test';
        testContact.LastName = 'Contact';
        testContact.Email = 'test123@gmail.com';
        insert testContact;
        
        Case cse = BLN_TestDataFactory.getCase('Job Request', 'New');
        cse.Type = 'Job Request';
        cse.Status = 'New';
        cse.BLN_ServiceGeolocation__latitude__s=48.010976;
        cse.BLN_ServiceGeolocation__longitude__s=-84.187741;
        cse.AccountId = testAcc.Id ;
        cse.Priority = 'Medium';
        cse.BLN_MotoristTaxStatus__c = 'Yes';
        cse.BLN_TotalMotoristLiability__c = 6000 ; 
        insert cse;
        cse.AccountId = testAcc.Id;
        cse.BLN_PricingDate__c = System.today();
        update cse;
        
        Schema.Location loc = new Schema.Location();
        loc.BLN_GUID__c = '542';
        loc.Longitude = 28.635308;
        loc.Latitude = 28.635308;
        loc.Name = 'Tokyo';
        insert loc;

        ServiceTerritory services = BLN_TestDataFactory.createServiceTerritories('Test Certainty', false);
        services.BLN_Type__c=  'Branch';
       	services.BLN_GUID__c= '542';
        insert services;
        
        workType types = BLN_TestDataFactory.createWorkType('test certainty', true);
        WorkOrder works = BLN_TestDataFactory.createWorkOrder2(types.id, services.id, true); 
        product2 prod1 = new product2();
        prod1.Name = 'Test1';
        prod1.BLN_MDMID__c = '2437AXRC';
        prod1.ProductCode = '12345'; 
        prod1.IsActive = true;
        insert prod1 ;
        PricebookEntry pbe1 = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = prod1.Id,
            UnitPrice = 1020,
            IsActive = true
        );
        insert pbe1;
        product2 prod2 = new product2();
        prod2.Name = 'Test2';
        prod2.BLN_MDMID__c = '2474AGNMVZ6C';
        prod2.ProductCode = '125317'; 
        prod2.IsActive = true;
        insert prod2 ;
        
        PricebookEntry pbe2 = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = prod2.Id,
            UnitPrice = 1020,
            IsActive = true
        );
		Insert pbe2;
        
        works.AccountId = testAcc.id;
        works.CaseId = cse.id;
        works.ContactId = testContact.id ;
        
        update works;
        
        String currentPayloadJson ='{'+
            '  "status": "success",'+
            '  "quotes": ['+
            '    {'+
            '      "quoteId": "38318988",'+
            '      "locationId": "542",'+
            '      "quoteTotals": {'+
            '        "totalPrice": 1531.97,'+
            '        "totalTax": 306.4,'+
            '        "totalRepair": 0.0,'+
            '        "totalReplacement": 1439.99,'+
            '        "totalCalibration": 0.0,'+
            '        "totalSundries": 0.0,'+
            '        "totalIncludingTax": 1838.37'+
            '      },'+
            '      "insuranceTotals": {'+
            '        "payableByInsuranceRepair": 0.0,'+
            '        "payableByInsuranceReplacement": 0.0,'+
            '        "payableByInsuranceCalibration": 0.0,'+
            '        "payableByInsuranceSundry": 0.0,'+
            '        "totalPayableByInsurance": 0.0,'+
            '        "totalTaxPayableByInsurance": 0.0,'+
            '        "totalIncludingTaxPayableByInsurance": 0.0'+
            '      },'+
            '      "motoristTotals": {'+
            '        "payableByMotoristRepair": 0.0,'+
            '        "payableByMotoristReplacement": 1439.99,'+
            '        "payableByMotoristCalibration": 0.0,'+
            '        "payableByMotoristSundry": 0.0,'+
            '        "totalTaxPayableByMotorist": 306.4,'+
            '        "totalPayableByMotorist": 1531.97,'+
            '        "totalInludingTaxPayableByMotorist": 1838.37'+
            '      },'+
            '      "taxTotals": {'+
            '        "totalTaxRepair": 0.0,'+
            '        "totalTaxReplacement": 0.0,'+
            '        "totalTaxCalibration": 0.0,'+
            '        "totalTaxSundries": 0.0'+
            '      },'+
            '      "tradeCompanyTotals": {'+
            '        "payableByTradeRepair": 0.0,'+
            '        "totalPayableByTrade": 0.0,'+
            '        "totalPayableByTradeIncludingTax": 0.0,'+
            '        "payableByTradeSundry": 0.0,'+
            '        "payableByTradeReplacement": 0.0,'+
            '        "payableByTradeCalibration": 0.0,'+
            '        "payableByTradeTotalTax": 0.0'+
            '      },'+
            '      "discountThresholdA": 1470.7,'+
            '      "discountThresholdB": 1194.94,'+
            '      "discountThresholdC": 1076.38,'+
            '      "priceExpirationDate": "2024-07-22T00:00:00Z",'+
            '      "lineItems": ['+
            '        {'+
            '          "lineItemId": 2,'+
            '          "parentLineItemId": 2,'+
            '          "bundleName": null,'+
            '          "partNumber": "2437AXRC",'+
            '          "belronPartNumber": null,'+
            '          "partDescription": "BMW 3-SERIES 2C/2CA 1998-ON WINDSCREEN-SUNDRY",'+
            '          "quantity": 1,'+
            '          "baseListPrice": 80.0,'+
            '          "netPrice": 80.0,'+
            '          "taxRate": 20.0,'+
            '          "totalTax": 16.0,'+
            '          "netPriceIncludingTax": 96.0,'+
            '          "optional": "mandatory",'+
            '          "partOfBundle": false,'+
            '          "bundleHierarchy": null,'+
            '          "nonBundlePrice": null,'+
            '          "availabilityDetails": [],'+
            '          "parentBOMId": null,'+
            '          "leadingProductIndicator": false,'+
            '          "totalPayableByInsurance": 0,'+
            '          "totalTaxPayableByInsurance": 0,'+
            '          "totalIncludingTaxPayableByInsurance": 0,'+
            '          "totalPayableByMotorist": 16.0,'+
            '          "totalTaxPayableByMotorist": 80.0,'+
            '          "totalIncludingTaxPayableByMotorist": 96.0,'+
            '          "payableByTradeTotalTax": 0,'+
            '          "totalPayableByTrade": 0,'+
            '          "totalPayableByTradeIncludingTax": 0,'+
            '          "payableByTrade": "Motorist"'+
            '        }'+
            '     '+
            '      '+
            '    '+
            '      '+
            '      ]'+
            '    }'+
            '  ]'+
            '}';
        
        Test.startTest();  
        Boolean retValue = BLN_QuoteBookingHandler.createOrderAndOrderItemsForISP(currentPayloadJson,cse.id);
        Test.stopTest();
        System.assertEquals(retValue,true, 'Success');
    }
    
    @isTest
    static void testCpqConnectWithMotoristTaxStatusRegistered() {
        
        ServiceTerritory services = BLN_TestDataFactory.createServiceTerritories('Test Certainty', true);
        services.BLN_Type__c=  'Mobile';
        services.BLN_GUID__c='542';
        update services;
        
        workType types = BLN_TestDataFactory.createWorkType('test certainty', true);
        WorkOrder works = BLN_TestDataFactory.createWorkOrder2(types.id, services.id, true); 
        //BLN_Vehicle__c vehicles = BLN_TestDataFactory.getVehicle();  
        Account testAcc = BLN_TestDataFactory.createTestAccount();
        testAcc.FirstName = 'Test';
        testAcc.LastName = 'Contact';
        testAcc.PersonEmail = 'test123@gmail.com';
        insert testAcc;
        
        Contact testContact = BLN_TestDataFactory.getContact('Test');
        testContact.FirstName = 'Test';
        testContact.LastName = 'Contact';
        testContact.Email = 'test123@gmail.com';
        insert testContact;
        
        String insuranceRTId = Schema.getGlobalDescribe().get('BLN_Corporate__c').getDescribe().getRecordTypeInfosByName().get('Insurance').getRecordTypeId();
        BLN_Vehicle__c testVehicle = new BLN_Vehicle__c(BLN_VehicleRegNumber__c = 'TestVRN');
        insert testVehicle;
        BLN_Corporate__c corporate = new BLN_Corporate__c(RecordTypeId = insuranceRTId, BLN_Vehicle__c=testVehicle.id,BLN_CHFVATStatus__c = 'Rated',BLN_OEAuthorized__c = 'Y');
        insert corporate;

        Case cse = BLN_TestDataFactory.getCase('Job Request', 'New');
        cse.BLN_Corporate__c = corporate.Id;
        cse.Type = 'Job Request';
        cse.Status = 'New'; 
        cse.ContactId = testContact.Id;
        cse.BLN_ServiceGeolocation__latitude__s=48.010976;
        cse.BLN_ServiceGeolocation__longitude__s=-84.187741;//-89.02172505348693;
        cse.AccountId = testAcc.Id ;
        cse.Priority = 'Medium';
        cse.BLN_MotoristTaxStatus__c = 'Yes';
        cse.BLN_TotalMotoristLiability__c = 6000 ;
        insert cse;
        BLN_VehicleDamage__c vD = new BLN_VehicleDamage__c();
        vD.BLN_BOMID__c = '12541';
        vD.BLN_ProductId__c = '12345';
        vD.BLN_Case__c = cse.id;
        insert vD;
        
        product2 prod1 = new product2();
        prod1.Name = 'Test1';
        prod1.BLN_MDMID__c = '2474AGNMVZ6C1';
        prod1.ProductCode = '12345'; 
        prod1.IsActive = true;
        insert prod1 ;

        
        product2 prod2 = new product2();
        prod2.Name = 'Test2';
        prod2.BLN_MDMID__c = '2474AGNMVZ6C';
        prod2.ProductCode = '125317'; 
        prod2.IsActive = true;
        insert prod2 ;
        
        works.AccountId = testAcc.id;
        works.CaseId = cse.id;
        works.ContactId = testContact.id ;
        
        update works;
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockResponseGenerator());  
        Case motoCase = BLN_QuoteBookingHandler.getCaseForQuoteCallout(cse.Id);
        List<BLN_ProductAvailabilityWrapper.LocationWrapper> nearestLocations = BLN_ProductAvailability.getNearestServiceLocations(motoCase);                  
        BLN_QuoteBookingHandler.makeQuoteCallout(motoCase,nearestLocations);
        //BLN_ProductAvailability.makeQuoteCalloutWithFourLocations(cse.id);
        
        /// }
        System.assertEquals(6000, cse.BLN_TotalMotoristLiability__c, 'It should be equal');
        Test.stopTest();
        
    }
}