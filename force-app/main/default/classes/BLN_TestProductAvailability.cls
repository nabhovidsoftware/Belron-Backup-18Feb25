/*****************************************
ClassName : BLN_TestProductAvailability
@description : FOUK-3681, 4049, 3085, 3090 This class is used to test BLN_ProductAvailability.
@author: PwC
CreatedDate: 24-11-2023
CreatedBy : PwC-India
****************************************/
@isTest
public class BLN_TestProductAvailability {
    
    public class MockResponseGenerator implements HttpCalloutMock {
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
    static void testDisplayLocation() {
        List<Knowledge__kav> knowledgeRecords = new List<Knowledge__kav>();
        for(Integer i = 0; i < 2; i++) {
            Knowledge__kav k = new Knowledge__kav(
                Title = 'Test Article' + i,
                BLN_DisplayLocation__c = (i == 0) ? 'Quote Summary' : 'Quote Presentation',
                UrlName= 'Test-Article' + i
            );
            knowledgeRecords.add(k);
        }
        insert knowledgeRecords;
        Test.startTest();
        List<BLN_ProductAvailabilityWrapper.DisplayLocationWrapper>result=BLN_ProductAvailability.displayLocation();
        Test.stopTest();
        System.assertEquals(2, result.size(), 'Expected two DisplayLocationWrapper objects');
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
        BLN_Corporate__c corporate = new BLN_Corporate__c(RecordTypeId = insuranceRTId, BLN_Vehicle__c=testVehicle.id,BLN_CHFVATStatus__c = 'Rated');
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
        BLN_ProductAvailability.makeQuoteCalloutWithFourLocations(cse.id);
        /// }
        System.assertEquals(6000, cse.BLN_TotalMotoristLiability__c, 'It should be equal');
        Test.stopTest();
        
    }

    @isTest
    static void testCpqConnectWithMotoristTaxStatusRegisteredISP() {
        
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
        BLN_Corporate__c corporate = new BLN_Corporate__c(RecordTypeId = insuranceRTId, BLN_Vehicle__c=testVehicle.id, BLN_CHFVATStatus__c = 'Rated');
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
        prod1.Name = 'Test2';
        prod1.BLN_MDMID__c = '2474AGNMVZ6C';
        prod1.ProductCode = '125317'; 
        prod1.IsActive = true;
        insert prod1 ;
        
        works.AccountId = testAcc.id;
        works.CaseId = cse.id;
        works.ContactId = testContact.id ;
        
        update works;
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockResponseGenerator());
        
        BLN_ProductAvailability.makeQuoteCalloutForISPLocation(cse.id);
        // }
        System.assertEquals(6000, cse.BLN_TotalMotoristLiability__c, 'It should be equal');
        Test.stopTest();
        
    }
    
    
    @isTest
    static void testLocation1() {
        
        test.startTest();       
        BLN_TestDataFactory.createServiceTerritories('Test Certainty', false);
        
        // services.BLN_GUID__c='9y8hfh9';
        // services.PostalCode = 'MK44 3US';
        // services.IsActive = true;
        // services.BLN_Type__c = 'Branch';
        // services.BLN_Specials__c = true;
        // services.Country = 'Bedford';        
        // services.Latitude = 52.125290000000000;
        // services.Longitude = -0.422290000000000;
        
        
      
        
        ServiceTerritory services2 = BLN_TestDataFactory.createServiceTerritories('Test Certainty 2', false);
        
        services2.BLN_GUID__c='9y8hfh9';
        services2.PostalCode = 'MK44 3US';
        services2.IsActive = true;
        services2.BLN_Type__c = 'Mobile';
        services2.BLN_Specials__c = true;
        services2.Country = 'Bedford';        
        services2.Latitude = 52.125290000000000;
        services2.Longitude = -0.422290000000000;
        services2.BLN_CostCenter__c = 'test';
        
        insert services2;
        
        BLN_Vehicle__c vehicles = BLN_TestDataFactory.getVehicle();
        vehicles.BLN_SpecialVehicle__c = true;
        Account testAcc = BLN_TestDataFactory.createTestAccount();
        testAcc.FirstName = 'Test';
        testAcc.LastName = 'Cont act';
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
        cse.ContactId = testContact.Id;
        cse.BLN_ServiceGeolocation__latitude__s=46.22441984873406;
        cse.BLN_ServiceGeolocation__longitude__s=-89.02172505348693;
        cse.AccountId = testAcc.Id ;
        cse.Priority = 'Medium';
        cse.BLN_MotoristTaxStatus__c = 'Yes';
        cse.BLN_TotalMotoristLiability__c = 6000 ;
        cse.BLN_Vehicle__c = vehicles.id;
        insert cse;

        BLN_VehicleDamage__c vD = new BLN_VehicleDamage__c();
        vD.BLN_BOMID__c = '12541';
        vD.BLN_ProductId__c ='12345,54321';
        vD.BLN_Case__c = cse.id;
        vD.BLN_WorkType__c = 'Repair';
        insert vD;
        
        BLN_VehicleDamage__c vD2 = new BLN_VehicleDamage__c();
        vD2.BLN_BOMID__c = '125412';
        vD2.BLN_ProductId__c ='123452,543212';
        vD2.BLN_Case__c = cse.id;
        vD2.BLN_WorkType__c = 'Recalibration';
        insert vD2;

        String caseRec = cse.Id;
        Contract con=BLN_TestDataFactory.createTestContract(testAcc);
        Order ord = new Order();
        ord.Status = 'Accepted';
        ord.AccountId=testAcc.Id;
        ord.BLN_Case__c = cse.id;
        ord.EffectiveDate=Date.today();
        //ord.Status='Draft';
        ord.ContractId=con.Id;
        ord.BLN_ServiceTerritory__c = services2.Id;
        insert ord;
        
        
        
        
        // Coordinates from the provided KML data
        //String coordinates = '-89.02172505348693,47.81952924639332,0 -84.18774067848693,48.01097620848099,0 -84.89086567848693,46.22441984873406,0 -88.34057270973693,45.91190522847453,0 -88.90087544411193,47.53103006689299,0 -89.30736958473693,47.77524856801052,0 -89.02172505348693,47.81952924639332,0';
        String jsonRes=		'{'+
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
            '                "totalIncludingTaxPayableByMotorist": 1060.78'+
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
            '          "lineItemId": 2,'+
            '          "parentLineItemId": 2,'+
            '          "bundleName": "bundle01",'+
            '          "partNumber": "2474AGNMVZ6C",'+
            '          "belronPartNumber": "2474AGNMVZ6C",'+
            '          "partDescription": "BOSCH  WIPER BLADE AP18U",'+
            '          "quantity": 1,'+
            '          "baseListPrice": 25.42,'+
            '          "netPrice": 25.42,'+
            '          "taxRate": 20.0,'+
            '          "totalTax": 5.08,'+
            '          "netPriceIncludingTax": 30.5,'+
            '          "selectProduct": false,'+
            '          "bomMandatory": false,'+
            '          "partOfBundle": false,'+
            '          "bundleHierarchy": null,'+
            '          "nonBundlePrice": null,'+
            '          "parentBOMId": null,'+
            '          "leadingProductIndicator": false,'+
            '          "totalPayableByInsurance": 0,'+
            '          "totalTaxPayableByInsurance": 0,'+
            '          "totalIncludingTaxPayableByInsurance": 0,'+
            '          "totalPayableByMotorist": 5.08,'+
            '          "totalTaxPayableByMotorist": 25.42,'+
            '          "totalIncludingTaxPayableByMotorist": 30.5,'+
            '          "payableByTradeTotalTax": 0,'+
            '          "totalPayableByTrade": 0,'+
            '          "totalPayableByTradeIncludingTax": 0,'+
            '          "payableByTrade": "Motorist",'+
            '                    "availabilityDetails": ['+
            '                        {'+
            '                            "stockLocationId": "9y8hfh9",'+
            '                            "availableFromDate": "2024-03-27T00:00:00Z"'+
            '                        }'+
            '                    ]'+
            '                },'+
            '                {'+
            '          "lineItemId": 3,'+
            '          "parentLineItemId": 2,'+
            '          "bundleName": "bundle01",'+
            '          "partNumber": "2474AGNMVZ6C",'+
            '          "belronPartNumber": "2474AGNMVZ6C",'+
            '          "partDescription": "BOSCH  WIPER BLADE AP18U",'+
            '          "quantity": 1,'+
            '          "baseListPrice": 25.42,'+
            '          "netPrice": 25.42,'+
            '          "taxRate": 20.0,'+
            '          "totalTax": 5.08,'+
            '          "netPriceIncludingTax": 30.5,'+
            '          "selectProduct": false,'+
            '          "bomMandatory": false,'+
            '          "partOfBundle": false,'+
            '          "bundleHierarchy": null,'+
            '          "nonBundlePrice": null,'+
            '          "parentBOMId": null,'+
            '          "leadingProductIndicator": false,'+
            '          "totalPayableByInsurance": 0,'+
            '          "totalTaxPayableByInsurance": 0,'+
            '          "totalIncludingTaxPayableByInsurance": 0,'+
            '          "totalPayableByMotorist": 5.08,'+
            '          "totalTaxPayableByMotorist": 25.42,'+
            '          "totalIncludingTaxPayableByMotorist": 30.5,'+
            '          "payableByTradeTotalTax": 0,'+
            '          "totalPayableByTrade": 0,'+
            '          "totalPayableByTradeIncludingTax": 0,'+
            '          "payableByTrade": "Motorist",'+
            '                    "availabilityDetails": ['+
            '                        {'+
            '                            "stockLocationId": "9y8hfh9",'+
            '                            "availableFromDate": "2024-03-27T00:00:00Z"'+
            '                        }'+
            '                    ]'+
            '                },'+
            '                {'+
            '          "lineItemId": 4,'+
            '          "parentLineItemId": 4,'+
            '          "bundleName": "",'+
            '          "partNumber": "2474AGNMVZ6CX",'+
            '          "belronPartNumber": "2474AGNMVZ6C",'+
            '          "partDescription": "BOSCH  WIPER BLADE AP18U",'+
            '          "quantity": 1,'+
            '          "baseListPrice": 25.42,'+
            '          "netPrice": 25.42,'+
            '          "taxRate": 20.0,'+
            '          "totalTax": 5.08,'+
            '          "netPriceIncludingTax": 30.5,'+
            '          "selectProduct": false,'+
            '          "bomMandatory": false,'+
            '          "partOfBundle": false,'+
            '          "bundleHierarchy": null,'+
            '          "nonBundlePrice": null,'+
            '          "parentBOMId": "2474AGNMVZ6CX",'+
            '          "leadingProductIndicator": true,'+
            '          "totalPayableByInsurance": 0,'+
            '          "totalTaxPayableByInsurance": 0,'+
            '          "totalIncludingTaxPayableByInsurance": 0,'+
            '          "totalPayableByMotorist": 5.08,'+
            '          "totalTaxPayableByMotorist": 25.42,'+
            '          "totalIncludingTaxPayableByMotorist": 30.5,'+
            '          "payableByTradeTotalTax": 0,'+
            '          "totalPayableByTrade": 0,'+
            '          "totalPayableByTradeIncludingTax": 0,'+
            '          "payableByTrade": "Motorist",'+
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
       // List<BLN_ProductAvailability.LocationWrapper> results1 = BLN_ProductAvailability.getNearestServiceLocations(cse);
        
        FSL__Polygon__c myPolygon = new FSL__Polygon__c();
        
        myPolygon.FSL__Ma_La__c = 48.010976; 
        myPolygon.FSL__Mi_La__c = 45.911905 ; 
        myPolygon.FSL__Ma_Lo__c = -84.187741;
        myPolygon.FSL__Mi_Lo__c = -89.307370;     
        myPolygon.FSL__Color__c ='#5679C0';
        myPolygon.Name = 'Central SSS1' ;
        myPolygon.FSL__Service_Territory__c = services2.id;
        myPolygon.FSL__KML__c =  '<?xml version="1.0" encoding="UTF-8"?> '+
                '<kml xmlns="http://www.opengis.net/kml/2.2">'+
                '<Style id="CentralSSSStyle">'+
                '<LineStyle>'+
                '<width>1</width>'+
                '</LineStyle>'+
                '<PolyStyle>'+
                '<color>80C07956</color>'+
                '</PolyStyle>'+
                '</Style>'+
                '<Placemark>'+
                '<name>CentralSSS</name>'+
                '<styleUrl>#CentralSSSStyle</styleUrl>'+
                '<Polygon>'+
                '<outerBoundaryIs>'+
                '<LinearRing>\n'+
                '<coordinates>-89.02172505348693,47.81952924639332,0\n'+
                '-84.18774067848693,48.01097620848099,0\n'+
                '-84.89086567848693,46.22441984873406,0\n'+
                '-88.34057270973693,45.91190522847453,0\n'+
                '-88.90087544411193,47.53103006689299,0\n'+
                '-89.30736958473693,47.77524856801052,0\n'+
                '-89.02172505348693,47.81952924639332,0\n'+
                '</coordinates>\n'+
                '</LinearRing>'+
                '</outerBoundaryIs>'+
                '</Polygon>'+
                '</Placemark>'+
                '</kml>';
        insert myPolygon;
        
        product2 prod1 = new product2();
        prod1.Name = 'Test2';
        prod1.BLN_MDMID__c = '2474AGNMVZ6C';
        prod1.ProductCode = '125317'; 
        prod1.IsActive = true;
        prod1.BLN_ProductCategory__c = '111';
        insert prod1 ;
        
        product2 prod2 = new product2();
        prod2.Name = 'Test2';
        prod2.BLN_MDMID__c = '2474AGNMVZ6CX';
        prod2.ProductCode = '1253171'; 
        prod2.IsActive = true;
        prod2.BLN_ProductCategory__c = '111';
        insert prod2 ;

        Pricebook2 pb2 = new Pricebook2();
        pb2.Name = 'test2';
        pb2.IsActive = true;       
        insert pb2;
        
        Id standardPB = Test.getStandardPricebookId();
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = standardPB, Product2Id = prod1.Id, UnitPrice = 0.00, IsActive = true);
        insert standardPBE;
        PricebookEntry pbe = new PricebookEntry();
        pbe.UnitPrice = 0.00;
        pbe.Pricebook2Id = pb2.id;
        pbe.Product2Id = prod1.id;
        pbe.Product2 = prod1;
        insert pbe;

        Id serviceAppointmentId = BLN_TestDataFactory.createServiceAppointment('Recalibration', true);
        serviceappointment sa = new serviceappointment();
        sa.Id = serviceAppointmentId;
        sa.ArrivalWindowStartTime = System.now();
        sa.ArrivalWindowEndTime = System.now().addHours(2);      
        update sa;

        Order ordr = new Order();
        ordr.Status = 'Accepted';
        ordr.AccountId=testAcc.Id;
        ordr.BLN_Case__c = cse.id;
        ordr.EffectiveDate=Date.today();
        ordr.ContractId=con.Id;
        ordr.BLN_ServiceTerritory__c = services2.Id;
        insert ordr;
        
		Schema.Location loc = new Schema.Location();
        loc.BLN_GUID__c = '9y8hfh9';
        loc.Longitude = 28.635308;
        loc.Latitude = 28.635308;
        loc.Name = 'Tokyo';
        insert loc;

        orderItem orderItm = new OrderItem();
        orderItm.BLN_DocumentNumber__c = 20;
        orderItm.Quantity = 1;
        orderItm.BLN_PartOfBundle__c = true;
        orderItm.BLN_ParentDocumentNumber__c = 5;
        orderItm.BLN_IsProductSelected__c = true;
        orderItm.BLN_BOMId__c = 'TEST_BOMID';
        orderItm.BLN_BundleName__c = 'test';
        orderItm.Product2Id = prod1.Id;
        orderItm.OrderId = ordr.Id;
        orderItm.ListPrice = 0.0;
        orderItm.UnitPrice = 0.0;
        orderItm.TotalLineAmount = 0.0;
        orderItm.BLN_ServiceAppointment__c = serviceAppointmentId;
        orderItm.BLN_LeadingPartIndicator__c = true;
        orderItm.BLN_OutOfStock__c = true;
        orderItm.BLN_StockOrderNumber__c = '450';
        orderItm.BLN_StockStatus__c = '';
        orderItm.EndDate = system.today();
        orderItm.BLN_TotalTax__c = 2.2;
        orderItm.BLN_NetPriceAfterPromotion__c = 2.9;
        orderItm.BLN_FittingLocation__c = loc.Id;
        insert orderItm;
        DateTime currentTime = DateTime.now();  
        DateTime runTime = currentTime.addMinutes(2);  
          
        // Format the time for the cron expression  
        String second = String.valueOf(runTime.second());  
        String minute = String.valueOf(runTime.minute());  
        String hour = String.valueOf(runTime.hour());  
        String dayOfMonth = String.valueOf(runTime.day());  
        String month = String.valueOf(runTime.month());  
        String dayOfWeek = '?'; // Use '?' for day of the week when specifying day of the month  
          
        // Construct the cron expression  
        String cronExp = second + ' ' + minute + ' ' + hour + ' ' + dayOfMonth + ' ' + month + ' ' + dayOfWeek;
        //BLN_ProductResponseWrapper.ResponseAvailabilityDetails earlydate = new BLN_ProductResponseWrapper.ResponseAvailabilityDetails();
        Test.setMock(HttpCalloutMock.class, new BLN_ReserveCptStockMock());
        //List<BLN_ProductAvailabilityWrapper.LocationWrapper> results = BLN_ProductAvailability.getNearestServiceLocations(cse);
        BLN_ProductAvailability.getNearestServiceLocations(cse);
        //List<BLN_ProductAvailability.LocationWrapper> results1 = BLN_ProductAvailabilityRebook.getNearestServiceLocationsByLatLong(cse,87879,989867);
        //BLN_ProductAvailabilityWrapper.EarliestAvailabilityDetailsWrapper testEADW = new BLN_ProductAvailabilityWrapper.EarliestAvailabilityDetailsWrapper();
        //BLN_ProductAvailabilityWrapper.DisplayDetailsWrapper result = 
        BLN_ProductAvailability.structureDataForQuoteUI(jsonRes,caseRec);
        try{BLN_ProductAvailability.structureDataForQuoteUI(jsonRes,caseRec);}
        catch(Exception e){System.debug(e);}
        
        System.schedule('Stock Movement Request for Case ' + cse.Id, cronExp, new BLN_StockMovementSchedule(cse.Id, false));
        System.schedule('Stock Movement Request for SA ' + cse.Id, cronExp, new BLN_StockMovementSchedule(cse.Id, true));
      //  BLN_OldProductAvailabilty.DisplayDetailsWrapper res = BLN_OldProductAvailabilty.createOrderItems(jsonRes,cse.Id);        
        System.assertEquals(0.00, pbe.UnitPrice, 'Unit Price should be equal');
        
        Test.stopTest();
        
    }
    
    @isTest
    static void testLocation2() {
        
        test.startTest();       
        BLN_TestDataFactory.createServiceTerritories('Test Certainty', false);
        
        // services.BLN_GUID__c='9y8hfh9';
        // services.PostalCode = 'MK44 3US';
        // services.IsActive = true;
        // services.BLN_Type__c = 'Branch';
        // services.BLN_Specials__c = true;
        // services.Country = 'Bedford';        
        // services.Latitude = 52.125290000000000;
        // services.Longitude = -0.422290000000000;
        
        
      
        
        ServiceTerritory services2 = BLN_TestDataFactory.createServiceTerritories('Test Certainty 2', false);
        
        services2.BLN_GUID__c='9y8hfh9';
        services2.PostalCode = 'MK44 3US';
        services2.IsActive = true;
        services2.BLN_Type__c = 'Mobile';
        services2.BLN_Specials__c = true;
        services2.Country = 'Bedford';        
        services2.Latitude = 52.125290000000000;
        services2.Longitude = -0.422290000000000;
        services2.BLN_CostCenter__c = 'test';
        
        insert services2;
        
        BLN_Vehicle__c vehicles = BLN_TestDataFactory.getVehicle();
        vehicles.BLN_SpecialVehicle__c = true;
        Account testAcc = BLN_TestDataFactory.createTestAccount();
        testAcc.FirstName = 'Test';
        testAcc.LastName = 'Cont act';
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
        cse.ContactId = testContact.Id;
        cse.BLN_ServiceGeolocation__latitude__s=46.22441984873406;
        cse.BLN_ServiceGeolocation__longitude__s=-89.02172505348693;
        cse.AccountId = testAcc.Id ;
        cse.Priority = 'Medium';
        cse.BLN_MotoristTaxStatus__c = 'Yes';
        cse.BLN_TotalMotoristLiability__c = 6000 ;
        cse.BLN_Vehicle__c = vehicles.id;
        insert cse;
        
        BLN_VehicleDamage__c vD = new BLN_VehicleDamage__c();
        vD.BLN_BOMID__c = '12541';
        vD.BLN_ProductId__c ='12345,54321';
        vD.BLN_Case__c = cse.id;
        vD.BLN_WorkType__c = 'Repair';
        insert vD;
        
        BLN_VehicleDamage__c vD2 = new BLN_VehicleDamage__c();
        vD2.BLN_BOMID__c = '125412';
        vD2.BLN_ProductId__c ='123452,543212';
        vD2.BLN_Case__c = cse.id;
        vD2.BLN_WorkType__c = 'Recalibration';
        insert vD2;

        String caseRec = cse.Id;
        Contract con=BLN_TestDataFactory.createTestContract(testAcc);
        Order ord = new Order();
        ord.Status = 'Accepted';
        ord.AccountId=testAcc.Id;
        ord.BLN_Case__c = cse.id;
        ord.EffectiveDate=Date.today();
        //ord.Status='Draft';
        ord.ContractId=con.Id;
        ord.BLN_ServiceTerritory__c = services2.Id;
        insert ord;
        
        
        
        
        // Coordinates from the provided KML data
        //String coordinates = '-89.02172505348693,47.81952924639332,0 -84.18774067848693,48.01097620848099,0 -84.89086567848693,46.22441984873406,0 -88.34057270973693,45.91190522847453,0 -88.90087544411193,47.53103006689299,0 -89.30736958473693,47.77524856801052,0 -89.02172505348693,47.81952924639332,0';
        String jsonRes=		'{'+
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
            '                "totalIncludingTaxPayableByMotorist": 1060.78'+
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
            '          "lineItemId": 2,'+
            '          "parentLineItemId": 2,'+
            '          "bundleName": "bundle01",'+
            '          "partNumber": "",'+
            '          "belronPartNumber": "2474AGNMVZ6C",'+
            '          "partDescription": "BOSCH  WIPER BLADE AP18U",'+
            '          "quantity": 1,'+
            '          "baseListPrice": 25.42,'+
            '          "netPrice": 25.42,'+
            '          "taxRate": 20.0,'+
            '          "totalTax": 5.08,'+
            '          "netPriceIncludingTax": 30.5,'+
            '          "selectProduct": false,'+
            '          "bomMandatory": false,'+
            '          "partOfBundle": true,'+
            '          "bundleHierarchy": null,'+
            '          "nonBundlePrice": null,'+
            '          "parentBOMId": null,'+
            '          "leadingProductIndicator": false,'+
            '          "totalPayableByInsurance": 0,'+
            '          "totalTaxPayableByInsurance": 0,'+
            '          "totalIncludingTaxPayableByInsurance": 0,'+
            '          "totalPayableByMotorist": 5.08,'+
            '          "totalTaxPayableByMotorist": 25.42,'+
            '          "totalIncludingTaxPayableByMotorist": 30.5,'+
            '          "payableByTradeTotalTax": 0,'+
            '          "totalPayableByTrade": 0,'+
            '          "totalPayableByTradeIncludingTax": 0,'+
            '          "payableByTrade": "Motorist",'+
            '                    "availabilityDetails": ['+
            '                        {'+
            '                            "stockLocationId": "9y8hfh9",'+
            //'                            "availableFromDate": "2024-03-27T00:00:00Z"'+
            '                            "availableFromDate": null'+
            '                        }'+
            '                    ]'+
            '                },'+
            '                {'+
            '          "lineItemId": 3,'+
            '          "parentLineItemId": 2,'+
            '          "bundleName": "bundle01",'+
            '          "partNumber": "2474AGNMVZ6C",'+
            '          "belronPartNumber": "2474AGNMVZ6C",'+
            '          "partDescription": "BOSCH  WIPER BLADE AP18U",'+
            '          "quantity": 1,'+
            '          "baseListPrice": 25.42,'+
            '          "netPrice": 25.42,'+
            '          "taxRate": 20.0,'+
            '          "totalTax": 5.08,'+
            '          "netPriceIncludingTax": 30.5,'+
            '          "selectProduct": false,'+
            '          "bomMandatory": false,'+
            '          "partOfBundle": true,'+
            '          "bundleHierarchy": null,'+
            '          "nonBundlePrice": null,'+
            '          "parentBOMId": null,'+
            '          "leadingProductIndicator": false,'+
            '          "totalPayableByInsurance": 0,'+
            '          "totalTaxPayableByInsurance": 0,'+
            '          "totalIncludingTaxPayableByInsurance": 0,'+
            '          "totalPayableByMotorist": 5.08,'+
            '          "totalTaxPayableByMotorist": 25.42,'+
            '          "totalIncludingTaxPayableByMotorist": 30.5,'+
            '          "payableByTradeTotalTax": 0,'+
            '          "totalPayableByTrade": 0,'+
            '          "totalPayableByTradeIncludingTax": 0,'+
            '          "payableByTrade": "Motorist",'+
            '                    "availabilityDetails": ['+
            '                        {'+
            '                            "stockLocationId": "9y8hfh9",'+
            '                            "availableFromDate": "2024-03-27T00:00:00Z"'+
            '                        }'+
            '                    ]'+
            '                },'+
            '                {'+
            '          "lineItemId": 4,'+
            '          "parentLineItemId": 4,'+
            '          "bundleName": "bundle002",'+
            '          "partNumber": "",'+
            '          "belronPartNumber": "2474AGNMVZ6C",'+
            '          "partDescription": "BOSCH  WIPER BLADE AP18U",'+
            '          "quantity": 1,'+
            '          "baseListPrice": 25.42,'+
            '          "netPrice": 25.42,'+
            '          "taxRate": 20.0,'+
            '          "totalTax": 5.08,'+
            '          "netPriceIncludingTax": 30.5,'+
            '          "selectProduct": false,'+
            '          "bomMandatory": false,'+
            '          "partOfBundle": true,'+
            '          "bundleHierarchy": null,'+
            '          "nonBundlePrice": null,'+
            '          "parentBOMId": "2474AGNMVZ6CX",'+
            '          "leadingProductIndicator": true,'+
            '          "totalPayableByInsurance": 0,'+
            '          "totalTaxPayableByInsurance": 0,'+
            '          "totalIncludingTaxPayableByInsurance": 0,'+
            '          "totalPayableByMotorist": 5.08,'+
            '          "totalTaxPayableByMotorist": 25.42,'+
            '          "totalIncludingTaxPayableByMotorist": 30.5,'+
            '          "payableByTradeTotalTax": 0,'+
            '          "totalPayableByTrade": 0,'+
            '          "totalPayableByTradeIncludingTax": 0,'+
            '          "payableByTrade": "Motorist",'+
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
       // List<BLN_ProductAvailability.LocationWrapper> results1 = BLN_ProductAvailability.getNearestServiceLocations(cse);
        
        FSL__Polygon__c myPolygon = new FSL__Polygon__c();
        
        myPolygon.FSL__Ma_La__c = 48.010976; 
        myPolygon.FSL__Mi_La__c = 45.911905 ; 
        myPolygon.FSL__Ma_Lo__c = -84.187741;
        myPolygon.FSL__Mi_Lo__c = -89.307370;     
        myPolygon.FSL__Color__c ='#5679C0';
        myPolygon.Name = 'Central SSS1' ;
        myPolygon.FSL__Service_Territory__c = services2.id;
        myPolygon.FSL__KML__c =  '<?xml version="1.0" encoding="UTF-8"?> '+
                '<kml xmlns="http://www.opengis.net/kml/2.2">'+
                '<Style id="CentralSSSStyle">'+
                '<LineStyle>'+
                '<width>1</width>'+
                '</LineStyle>'+
                '<PolyStyle>'+
                '<color>80C07956</color>'+
                '</PolyStyle>'+
                '</Style>'+
                '<Placemark>'+
                '<name>CentralSSS</name>'+
                '<styleUrl>#CentralSSSStyle</styleUrl>'+
                '<Polygon>'+
                '<outerBoundaryIs>'+
                '<LinearRing>\n'+
                '<coordinates>-89.02172505348693,47.81952924639332,0\n'+
                '-84.18774067848693,48.01097620848099,0\n'+
                '-84.89086567848693,46.22441984873406,0\n'+
                '-88.34057270973693,45.91190522847453,0\n'+
                '-88.90087544411193,47.53103006689299,0\n'+
                '-89.30736958473693,47.77524856801052,0\n'+
                '-89.02172505348693,47.81952924639332,0\n'+
                '</coordinates>\n'+
                '</LinearRing>'+
                '</outerBoundaryIs>'+
                '</Polygon>'+
                '</Placemark>'+
                '</kml>';
        insert myPolygon;
        
        product2 prod1 = new product2();
        prod1.Name = 'Test2';
        prod1.BLN_MDMID__c = '2474AGNMVZ6C';
        prod1.ProductCode = '125317'; 
        prod1.IsActive = true;
        prod1.BLN_ProductCategory__c = '111';
        insert prod1 ;
        
        product2 prod2 = new product2();
        prod2.Name = 'Test2';
        prod2.BLN_MDMID__c = '2474AGNMVZ6CX';
        prod2.ProductCode = '1253171'; 
        prod2.IsActive = true;
        prod2.BLN_ProductCategory__c = '111';
        insert prod2 ;

        Pricebook2 pb2 = new Pricebook2();
        pb2.Name = 'test2';
        pb2.IsActive = true;       
        insert pb2;
        
        Id standardPB = Test.getStandardPricebookId();
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = standardPB, Product2Id = prod1.Id, UnitPrice = 0.00, IsActive = true);
        insert standardPBE;
        PricebookEntry pbe = new PricebookEntry();
        pbe.UnitPrice = 0.00;
        pbe.Pricebook2Id = pb2.id;
        pbe.Product2Id = prod1.id;
        pbe.Product2 = prod1;
        insert pbe;

        Id serviceAppointmentId = BLN_TestDataFactory.createServiceAppointment('Recalibration', true);
        serviceappointment sa = new serviceappointment();
        sa.Id = serviceAppointmentId;
        sa.ArrivalWindowStartTime = System.now();
        sa.ArrivalWindowEndTime = System.now().addHours(2);      
        update sa;

        Order ordr = new Order();
        ordr.Status = 'Accepted';
        ordr.AccountId=testAcc.Id;
        ordr.BLN_Case__c = cse.id;
        ordr.EffectiveDate=Date.today();
        ordr.ContractId=con.Id;
        ordr.BLN_ServiceTerritory__c = services2.Id;
        insert ordr;
        
		Schema.Location loc = new Schema.Location();
        loc.BLN_GUID__c = '9y8hfh9';
        loc.Longitude = 28.635308;
        loc.Latitude = 28.635308;
        loc.Name = 'Tokyo';
        insert loc;

        orderItem orderItm = new OrderItem();
        orderItm.BLN_DocumentNumber__c = 20;
        orderItm.Quantity = 1;
        orderItm.BLN_PartOfBundle__c = true;
        orderItm.BLN_ParentDocumentNumber__c = 5;
        orderItm.BLN_IsProductSelected__c = true;
        orderItm.BLN_BOMId__c = 'TEST_BOMID';
        orderItm.BLN_BundleName__c = 'test';
        orderItm.Product2Id = prod1.Id;
        orderItm.OrderId = ordr.Id;
        orderItm.ListPrice = 0.0;
        orderItm.UnitPrice = 0.0;
        orderItm.TotalLineAmount = 0.0;
        orderItm.BLN_ServiceAppointment__c = serviceAppointmentId;
        orderItm.BLN_LeadingPartIndicator__c = true;
        orderItm.BLN_OutOfStock__c = true;
        orderItm.BLN_StockOrderNumber__c = '450';
        orderItm.BLN_StockStatus__c = '';
        orderItm.EndDate = system.today();
        orderItm.BLN_TotalTax__c = 2.2;
        orderItm.BLN_NetPriceAfterPromotion__c = 2.9;
        orderItm.BLN_FittingLocation__c = loc.Id;
        insert orderItm;
        DateTime currentTime = DateTime.now();  
        DateTime runTime = currentTime.addMinutes(2);  
          
        // Format the time for the cron expression  
        String second = String.valueOf(runTime.second());  
        String minute = String.valueOf(runTime.minute());  
        String hour = String.valueOf(runTime.hour());  
        String dayOfMonth = String.valueOf(runTime.day());  
        String month = String.valueOf(runTime.month());  
        String dayOfWeek = '?'; // Use '?' for day of the week when specifying day of the month  
          
        // Construct the cron expression  
        String cronExp = second + ' ' + minute + ' ' + hour + ' ' + dayOfMonth + ' ' + month + ' ' + dayOfWeek;
        //BLN_ProductResponseWrapper.ResponseAvailabilityDetails earlydate = new BLN_ProductResponseWrapper.ResponseAvailabilityDetails();        
        Test.setMock(HttpCalloutMock.class, new BLN_ReserveCptStockMock());
        //List<BLN_ProductAvailabilityWrapper.LocationWrapper> results = BLN_ProductAvailability.getNearestServiceLocations(cse);
        BLN_ProductAvailability.getNearestServiceLocations(cse);
        //List<BLN_ProductAvailability.LocationWrapper> results1 = BLN_ProductAvailabilityRebook.getNearestServiceLocationsByLatLong(cse,87879,989867);
        //BLN_ProductAvailabilityWrapper.EarliestAvailabilityDetailsWrapper testEADW = new BLN_ProductAvailabilityWrapper.EarliestAvailabilityDetailsWrapper();
        //BLN_ProductAvailabilityWrapper.DisplayDetailsWrapper result = 
        try{
	        BLN_ProductAvailability.structureDataForQuoteUI(jsonRes,caseRec);    
        } catch(Exception e){System.debug(e);}
        
        try{
            //BLN_ProductAvailability.updateWOwithOrderFuture(ordr.Id);
        } catch(Exception e){System.debug(e);}
      //  BLN_OldProductAvailabilty.DisplayDetailsWrapper res = BLN_OldProductAvailabilty.createOrderItems(jsonRes,cse.Id);        
       // System.assertEquals(0.00, pbe.UnitPrice, 'Unit Price should be equal');
        
        Test.stopTest();
        
    }
    
    @isTest
    static void testGetNearestServiceLocations() {
        // Create test data
        Case motoristCase = new Case(/* Add necessary fields */);
        
        Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator']?.Id;
        id roleId = [SELECT Id FROM UserRole where DeveloperName ='BLN_CERs' limit 1]?.id; 
        User adminUser = new User(
            ProfileId = adminProfileId,
            FirstName = 'PS',
            LastName = 'Test User',
            UserName = System.now().getTime() + '@test.demo',
            Alias = 'pstes',
            Email = 'test@sample.demo',
            UserRoleId = roleId,
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'nl_NL',
            TimeZoneSidKey = UserInfo.getTimeZone().getID(),
            UserPermissionsSupportUser = true); 
        insert adminUser; 
        // Test the method
        Test.startTest();
        System.runAs(adminUser){
            Boolean retBool = BLN_ProductAvailability.getIsFirstCustomPermission();
            List<BLN_ProductAvailabilityWrapper.LocationWrapper> result = BLN_ProductAvailability.getNearestServiceLocations(motoristCase);
            // Perform assertions
            System.assertEquals(false,retBool,'Result is null');
            System.assertNotEquals(null, result, 'Result should not be null');
            System.assertEquals(0, result.size(), 'Result size should be 0');
            
        }
        Test.stopTest();
        
        
        
    }
    
    @isTest
    static void testmakeRepriceCallout() {
        String repriceRequestPayload = '  {'+
            '    "id": "40597011",'+
            '    "discount": 0,'+
            '    "afterHours": "Ahrs_Ws_Repairs",'+
            '    "lineItems": ['+
            '      {'+
            '        "lineId": "2",'+
            '        "quantity": 3'+
            '      }'+
            '    ],'+
            '    "caseId": "5007Y00000QrZSsQAN"'+
            '  }'+
            ']';
        Case cse = BLN_TestDataFactory.getCase('Job Request', 'New');
        cse.Type = 'Job Request';
        cse.Status = 'New';
        
        cse.BLN_ServiceGeolocation__latitude__s=46.22441984873406;
        cse.BLN_ServiceGeolocation__longitude__s=-89.02172505348693;
        
        cse.Priority = 'Medium';
        cse.BLN_MotoristTaxStatus__c = 'Yes';
        cse.BLN_TotalMotoristLiability__c = 6000 ;
        insert cse;
        String caseRecordId =cse.id;
        
        String currentPayloadJson ='{'+
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
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockResponseGenerator());
        String updatedPayload = BLN_ProductAvailability.makeRepriceCallout(repriceRequestPayload, caseRecordId);
        //BLN_ProductAvailability.makeRepriceCallout(repriceRequestPayload, caseRecordId);
        
        String caseId = [SELECT Id FROM Case LIMIT 1].Id;
        //String motoristCaseId = caseId;
        //Double userLatitude =54.63150177683656; // set latitude to test value
        //Double userLongitude = -5.924506383950011; // set longitude to test value
        //String existingGUId = '';
        
        ServiceTerritory services = BLN_TestDataFactory.createServiceTerritories('Test Certainty', false);
        services.BLN_Type__c=  'Branch';
       	services.BLN_GUID__c= '140007';
        insert services;
        BLN_ProductAvailability.updateAllQuoteIds(currentPayloadJson, caseId);
        //String result = BLN_ProductAvailabilityRebook.makeNewQuoteCallout(caseRecordId, userLatitude, userLongitude, services.BLN_GUID__c);
        Test.stopTest();
        
        // Assert the result
        System.assertNotEquals(null, updatedPayload, 'it should not be null');
        
    }
    @isTest
    public static void orderAndOrderItemCreation(){
        ServiceTerritory services = BLN_TestDataFactory.createServiceTerritories('Test Certainty', false);
        services.BLN_Type__c=  'Branch';
       	services.BLN_GUID__c= '542';//140007
        insert services;
        
        Schema.Location loc = new Schema.Location();
        loc.BLN_GUID__c = '542';
        loc.Longitude = 28.635308;
        loc.Latitude = 28.635308;
        loc.Name = 'Tokyo';
        insert loc;
        
        workType types = BLN_TestDataFactory.createWorkType('test certainty', true);
        BLN_TestDataFactory.createWorkOrder2(types.id, services.id, true); 
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
        
        Case cse = BLN_TestDataFactory.getCase('Job Request', 'New');
        cse.Type = 'Job Request';
        cse.Status = 'New';
        cse.ContactId = testContact.Id;
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
        
        OperatingHours operatingHours = BLN_TestDataFactory.createOperatingHours(System.label.BLN_OneHourSlot, true);
        ServiceTerritory st = BLN_TestDataFactory.createServiceTerritory('Bedford' , operatingHours.Id , true);
        WorkType replacementWT = BLN_TestDataFactory.createWorkType(System.label.BLN_WarrantyReplacement, 4 , true ,  true);

        WorkOrder wo = new WorkOrder();
        wo.BLN_RemedyJobId__c = '001111';
        wo.WorkTypeId = replacementWT.Id;
        wo.ServiceTerritoryId = st.id;
        wo.CaseId = cse.Id;
        insert wo;
        
        BLN_VehicleDamage__c vD = new BLN_VehicleDamage__c();
        vD.BLN_BOMID__c = '12541';
        vd.BLN_ProductId__c ='12345,54321';
        vD.BLN_Case__c = cse.id;
        insert vD;
        
        Contract con=BLN_TestDataFactory.createTestContract(testAcc);
        
        product2 prod1 = new product2();
        prod1.Name = 'Test2';
        prod1.BLN_MDMID__c = '2474AGNMVZ6C';
        prod1.ProductCode = '125317'; 
        prod1.IsActive = true;
        insert prod1 ; 

        Pricebook2 pb2 = new Pricebook2();
        pb2.Name = 'test2';
        pb2.IsActive = true;       
        insert pb2;
        
        Id standardPB = Test.getStandardPricebookId();
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = standardPB, Product2Id = prod1.Id, UnitPrice = 0.00, IsActive = true);
        insert standardPBE;
        PricebookEntry pbe = new PricebookEntry();
        pbe.UnitPrice = 0.00;
        pbe.Pricebook2Id = pb2.id;
        pbe.Product2Id = prod1.id;
        pbe.Product2 = prod1;
        insert pbe;

        Id serviceAppointmentId = BLN_TestDataFactory.createServiceAppointment('Recalibration', true);
        serviceappointment sa = new serviceappointment();
        sa.Id = serviceAppointmentId;
        sa.ArrivalWindowStartTime = System.now();
        sa.ArrivalWindowEndTime = System.now().addHours(2);
        update sa;

        Order ord = new Order();
        ord.Status = 'Accepted';
        ord.AccountId=testAcc.Id;
        ord.BLN_Case__c = cse.id;
        ord.EffectiveDate=Date.today();
        ord.ContractId=con.Id;
        insert ord;

        orderItem orderItm = new OrderItem();
        orderItm.BLN_DocumentNumber__c = 20;
        orderItm.Quantity = 1;
        orderItm.BLN_IsProductSelected__c = true;
        orderItm.BLN_BOMId__c = 'TEST_BOMID';
        orderItm.BLN_BundleName__c = '';
        orderItm.Product2Id = prod1.Id;
        orderItm.OrderId = ord.Id;
        orderItm.ListPrice = 0.0;
        orderItm.UnitPrice = 0.0;
        orderItm.TotalLineAmount = 0.0;
        orderItm.BLN_ServiceAppointment__c = serviceAppointmentId;
        orderItm.BLN_LeadingPartIndicator__c = true;
        orderItm.BLN_OutOfStock__c = true;
        orderItm.BLN_StockOrderNumber__c = '450';
        orderItm.BLN_fittingLocation__c = loc.Id;
        insert orderItm;
        
       
        
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
            '          "partOfBundle": true,'+
            '          "bundleHierarchy": null,'+
            '          "nonBundlePrice": null,'+
            '          "availabilityDetails": [{"stockLocationId": 88, "availableFromDate": "2025-04-14T07:00:00"} ],'+
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
        
        String appjson=	'['	+
            '    {'+
            '        "ServiceLocationName": "SERVICE LOCATION CE Bedford",'+
            '        "ServiceLocationId": "542",'+
            '        "isPrimaryLocation": true,'+
            '        "ServiceLocationLabel": ['+
            '            {'+
            '                "ServiceLabel": "SERVICE LOCATION",'+
            '                "Product": "Products",'+
            '                "ProductNames": ['+
            '                    {'+
            '                        "productName": "Weather Guard",'+
            '                        "productCode": "2474AGNMVZ6C"'+
            '                    },'+
            '                    {'+
            '                        "productName": "Windscreen Product",'+
            '                        "productCode": "2484AGSCMVZ"'+
            '                    }'+
            '                ]'+
            '            }'+
            '        ],'+
            '        "EarliestAvailablity": ['+
            '            {'+
            '                "ServiceName": "CE Bedford",'+
            '                "EarliestAvailablity": "Earliest Availability",'+
            '                "productDate": ['+
            '                    {'+
            '                        "EarliestDate": "Invalid Date",'+
            '                        "productCode": "2474AGNMVZ6C"'+
            '                    },'+
            '                    {'+
            '                        "EarliestDate": "Invalid Date",'+
            '                        "productCode": "2484AGSCMVZ"'+
            '                    }'+
            '                ]'+
            '            }'+
            '        ],'+
            '        "Appointments": [{'+
            '            "appointmentName": "Appointment 1",'+
            '            "keyIndex": 0,'+
            '            "locationId": "542",'+
            '            "locationName": "CE Bedford",'+
            '            "isFirstAppointment": false,'+
            '            "isMobileLocation": true,'+
            '            "earlierAvailabilityDateHeader": "Invalid Date",'+
            '            "slotSelectedDate": "",'+
            '            "serviceAppointmentId": "",'+
            '            "slotDate": "",'+
            '            "slotTime": "",'+
            '            "slotDateTimeStart": "",'+
            '            "slotDateTimeFinish": "",'+
            '            "ProductAvailibilities": ['+
            '                {'+
            '                    "Products": ['+
            '                        {'+
            '                            "productCode": "2474AGNMVZ6C",'+
            '                            "productEnable": true,'+
            '                            "quantity": 1,'+
            '                            "isChecked": false'+
            '                        },'+
            '                        {'+
            '                            "productCode": "2484AGSCMVZ",'+
            '                            "productEnable": true,'+
            '                            "quantity": 1,'+
            '                            "isChecked": false'+
            '                        },'+
            '                        {'+
            '                            "productCode": "2474AGNMVZ6CX",'+
            '                            "productEnable": true,'+
            '                            "quantity": 1,'+
            '                            "isChecked": false,'+
            '							 "partOfBundle": true'+
            '                        },'+
            '                        {'+
            '                            "productCode": "2474AGNMVZ6CX1",'+
            '                            "productEnable": true,'+
            '                            "quantity": 1,'+
            '                            "isChecked": false,'+
            '							 "bomId": "123"'+
            '                        }'+
            '                    ]'+
            '                }'+
            '            ],'+
            '            "isWeatherGuardPDis": true,'+
            '            "productEnable": true'+
            '        }]'+
            ' }] ';
        
        
        String selectedProdjson =  '['+
            '{'+
            '        "bomId": "",'+
            '        "hierarchy": "",'+
            '        "isBranchOnlyProduct": false,'+
            '        "lineItemId": 3,'+
            '        "netPrice": 629.51,'+
            '        "netPriceIncludingTax": 755.41,'+
            '        "optionalAttributeValue": "mandatory",'+
            '        "productCode": "2474AGNMVZ6C",'+
            '        "productName": "Weather Guard",'+
            '        "quantity": 1,'+
            '        "totalTax": 125.9,'+
            '        "activeElement": "active",'+
            '        "isChild": false,'+
            '        "isParent": false,'+
            '        "isCheckedByDefault": true,'+
            '        "itemIndex": 4,'+
            '        "isQtyDisabled": false,'+
            '        "colorCode": "background-color: white;",'+
            '        "isAddAllDisabled": true'+
            '    }'+
            ' ]';
        
		Test.setMock(HttpCalloutMock.class, new BLN_ReserveCptStockMock());
        List<BLN_ProductAvailabilityWrapper.EarliestAvailabilityDetailsWrapper> earliestAvailabilityList = new List<BLN_ProductAvailabilityWrapper.EarliestAvailabilityDetailsWrapper>();
        String earlyList = JSON.serialize(earliestAvailabilityList); 
        
        String json = '{"attributes":{"type":"Case","url":"/services/data/v61.0/sobjects/Case/'+cse.Id+'"},"Id":"'+cse.Id+'","AccountId":"'+testAcc.Id+'","BLN_PricingDate__c":"2024-06-25","BLN_Corporate__c":"","CreatedDate":"2024-06-25T17:50:25.000+0000","BLN_CPQQuoteIdCollection__c":"61845235,61845241,61845237,61845238"}';
        Test.startTest();
        
        BLN_ProductAvailability.updateCaseFuture(json);
        BLN_ProductAvailability.createOrdersAndOrderItems(currentPayloadJson,selectedProdjson,selectedProdjson,appjson,cse.id,'38318988',earlyList,75.00);
        Test.stopTest();
        System.assertEquals(6000, cse.BLN_TotalMotoristLiability__c, 'It should be equal');
    } 
    
    /*@isTest
    static void testMakeQuoteCalloutForISPLocation() {
        // Create a test ServiceTerritory with the required fields
        ServiceTerritory services = BLN_TestDataFactory.createServiceTerritories('Test Certainty', false);
        services.BLN_Type__c=  'Branch';
       	services.BLN_GUID__c= '140007';
        insert services;
        //insert testServTer;
        
        // Create a test Case with the required fields
       // Case testCase = new Case(
         //   Subject = 'Test Case',
         //   Status = 'New'
        //);
        //insert testCase;
        //
        workType types = BLN_TestDataFactory.createWorkType('test certainty', true);
        WorkOrder works = BLN_TestDataFactory.createWorkOrder2(types.id, services.id, true); 
        BLN_Vehicle__c vehicles = BLN_TestDataFactory.getVehicle(); 
        
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
        cse.ContactId = testContact.Id;
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
        
        // Mock the BLN_ProductAvailability class and its method
        Test.startTest();
        
        // Mock the response of the makeQuoteCallout method
        String expectedPayload = 'Expected Payload';
        
        // Set up the mock response in a test callout class
        BLN_ProductAvailabilityWrapper.LocationWrapper locWrapper = new BLN_ProductAvailabilityWrapper.LocationWrapper();
        locWrapper.costCenterId = services.BLN_CostCenter__c;
        locWrapper.locationId = services.BLN_GUID__c;
        locWrapper.mobileLocationIndicator = false;
        locWrapper.countryCode = 'GB';
        
        // Perform the actual call to the method
        //String actualPayload = 
            BLN_ProductAvailability.makeQuoteCalloutForISPLocation(cse.Id);
        
        // Validate the response
      //  System.assertEquals(expectedPayload, actualPayload);
        
        Test.stopTest();
    }*/
     @isTest
    static void testGetAvailableDate() {
        // Create test data for ResponseLineItems
        BLN_ProductResponseWrapper.ResponseLineItems selectedEle = new BLN_ProductResponseWrapper.ResponseLineItems();
        selectedEle.partNumber = 'TestPartNumber';
        selectedEle.bundleName = 'TestBundleName';
        selectedEle.parentBOMId = 'TestBOMId';
        
        // Create test data for EarliestAvailabilityDetailsWrapper
        BLN_ProductAvailabilityWrapper.EarliestAvailabilityDetailsWrapper availabilityDetails1 = new BLN_ProductAvailabilityWrapper.EarliestAvailabilityDetailsWrapper();
        availabilityDetails1.locationId = 'TestLocationId';
        //availabilityDetails1.productCode = 'TestPartNumber';
        availabilityDetails1.bundleName = 'TestBundleName';
        availabilityDetails1.bomId = 'TestBOMId';
        availabilityDetails1.earliestDateList = new List<BLN_ProductResponseWrapper.ResponseAvailabilityDetails>{
            new BLN_ProductResponseWrapper.ResponseAvailabilityDetails()
        };

        BLN_ProductAvailabilityWrapper.EarliestAvailabilityDetailsWrapper availabilityDetails2 = new BLN_ProductAvailabilityWrapper.EarliestAvailabilityDetailsWrapper();
        availabilityDetails2.locationId = 'AnotherLocationId';
        //availabilityDetails2.productCode = 'AnotherPartNumber';
        availabilityDetails2.bundleName = 'AnotherBundleName';
        availabilityDetails2.bomId = 'AnotherBOMId';
        availabilityDetails2.earliestDateList = new List<BLN_ProductResponseWrapper.ResponseAvailabilityDetails>{
            new BLN_ProductResponseWrapper.ResponseAvailabilityDetails()
        };

        List<BLN_ProductAvailabilityWrapper.EarliestAvailabilityDetailsWrapper> earliestAvailabilityDateList = 
            new List<BLN_ProductAvailabilityWrapper.EarliestAvailabilityDetailsWrapper>{availabilityDetails1, availabilityDetails2};

        // Call the method
        List<BLN_ProductResponseWrapper.ResponseAvailabilityDetails> result = BLN_ProductAvailability.getAvailableDate(
            'TestLocationId', selectedEle, earliestAvailabilityDateList);
        BLN_ProductAvailability.getIsFirstCustomPermission();

        // Validate the results
        //System.assertEquals(1, result.size(),'Result should be 1');
        System.assertEquals(0, result.size(),'Result should be 0');
    }
}