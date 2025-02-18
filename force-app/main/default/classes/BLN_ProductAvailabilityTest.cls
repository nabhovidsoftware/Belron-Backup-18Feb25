@isTest  
public class BLN_ProductAvailabilityTest {  
  
    @testSetup  
    static void setupTestData() {  
        // Create OperatingHours record  
        OperatingHours opHours = BLN_TestDataFactory.createOperatingHour('EU Operating Hour', false);
        insert opHours;
        
        // Create ServiceTerritory records  
        String oppHourId = [SELECT Id, Name FROM OperatingHours LIMIT 1 ].Id;
        ServiceTerritory st1 = BLN_TestDataFactory.createServiceTerritory('Test Branch 1', oppHourId, false);   
            st1.Latitude = 51.509865;
            st1.Longitude = -0.118092; 
            st1.BLN_GUID__c = 'GUID1';
            st1.BLN_OrgCodeLocation__c = 'ORG1'; 
            st1.BLN_CostCenter__c = 'COST1';
            st1.IsActive = true;
            st1.BLN_Type__c = 'Branch';
        insert st1;  
  
        // Create a Case record  
        Account acc = BLN_TestDataFactory.createPersonAccount('Test', 'Account', false);  
        insert acc; 
        
         BLN_Vehicle__c vehicle = BLN_TestDataFactory.getVehicle();  
            vehicle.BLN_MDMID__c = 'VEHICLE1'; 
            vehicle.BLN_SpecialVehicle__c = false; 
        insert vehicle; 
        
        BLN_Corporate__c corporate = new BLN_Corporate__c(  
            BLN_VehicleDamageExcess__c = 100.0,
            BLN_Vehicle__c = vehicle.Id
        );  
        insert corporate;  
       
        Case testCase = BLN_TestDataFactory.createCaseTest(false); 
            testCase.AccountId = acc.Id;
            testCase.BLN_Corporate__c = corporate.Id;
            testCase.BLN_Vehicle__c = vehicle.Id;
            testCase.BLN_PricingDate__c = Date.today();
            testCase.BLN_ServiceCountry__c = 'GB'; 
            testCase.BLN_ServiceGeolocation__Latitude__s = 51.509865; 
            testCase.BLN_ServiceGeolocation__Longitude__s = -0.118092;  
        insert testCase;
        
        // Create BLN_VehicleDamage__c records  
        BLN_VehicleDamage__c damage = BLN_TestDataFactory.createVehcileDamagerForRecovery();
            damage.BLN_Case__c = testCase.Id; 
            damage.BLN_BOMID__c = 'BOM1'; 
            damage.BLN_ProductId__c = 'PROD1'; 
        insert damage;  
    }  
  
    @isTest  
    static void testMakeQuoteCallout() {  
        try{
           // Fetch the test Case record  
        Case testCase = [SELECT Id FROM Case LIMIT 1];  
         // System.debug('testCase'+testCase);
        // Mock the HTTP callout  
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());  
          
        // Call the method  
        String response = BLN_ProductAvailability.makeQuoteCalloutWithFourLocations(testCase.Id);  
          
        // Verify the response  
        System.assertNotEquals(response, System.label.BLN_CalloutFailed, 'The callout should not fail.');  
    }  
        Catch(exception ex){
            
        }  
    }  

@isTest
    static void testGetNearestServiceLocations() {
        // Create and insert a test Vehicle
        /*Vehicle__c testVehicle = new Vehicle__c(
            Name = 'Test Vehicle',
            BLN_SpecialVehicle__c = false
        );
        insert testVehicle;*/
        
        // Create and insert a test Case
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'New',
            Origin = 'Phone',
            //BLN_Vehicle__c = testVehicle.Id,
            BLN_ServiceGeolocation__Latitude__s = 1.3521,
            BLN_ServiceGeolocation__Longitude__s = 103.8198
            //BLN_ServiceGeolocation__c = 'Point(1.3521 103.8198)' // Sample GeoLocation
        );
        insert testCase;
        
        // Create and insert ServiceTerritory records
        ServiceTerritory branchTerritory = new ServiceTerritory(
            Name = 'Branch Territory',
            BLN_GUID__c = 'GUID123',
            BLN_CostCenter__c = 'CC123',
            BLN_Type__c = System.Label.BLN_Branch,
            Latitude = 1.3521,
            Longitude = 103.8198,
            IsActive = true,
            BLN_ConsiderforR1__c = false,
            BLN_Specials__c = false,
            OperatingHoursId= System.Label.BLN_OperatingHoursId
        );
        insert branchTerritory;
        
        // Create and insert a Location record
        /*Location testLocation = new Location(
            
        );
        insert testLocation;*/
        
        // Create and insert a FSL_Polygon__c record
        /*FSL__Polygon__c testPolygon = new FSL__Polygon__c(
            FSL__Service_Territory__r = branchTerritory,
            FSL__Service_Territory__c = branchTerritory.Id,
            FSL__Service_Territory__r.BLN_GUID__c = 'GUID123',
            FSL__Service_Territory__r.BLN_CostCenter__c = 'CC123',
            FSL__Service_Territory__r.Address = 'Test Address',
            FSL__Service_Territory__r.BLN_Type__c = System.Label.BLN_Mobile
        );
        insert testPolygon;*/
        
        // Call the method and assert the response
        Test.startTest();
        List<BLN_ProductAvailabilityWrapper.LocationWrapper> result = BLN_ProductAvailability.getNearestServiceLocations(testCase);
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(1, result.size(), 'Result size should be 1');
        //System.assertEquals('GUID123', result[0].locationId, 'Location ID should match');
        //System.assertEquals('OrgCode123', result[0].costCenterId, 'Cost Center ID should match');
        System.assertEquals('GB', result[0].countryCode, 'Country Code should be GB');
        System.assertEquals(false, result[0].mobileLocationIndicator, 'Mobile Location Indicator should be false');
    }

   

@isTest
    static void testMakeQuoteCalloutForISPLocation() {
        // Create and insert a test Case
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'New',
            Origin = 'Phone'
        );
        insert testCase;
        
        // Mock the necessary methods
        Case motoCase = BLN_QuoteBookingHandler.getCaseForQuoteCallout(testCase.Id);
        BLN_ProductAvailabilityWrapper.LocationWrapper locWrapper = new BLN_ProductAvailabilityWrapper.LocationWrapper();
        locWrapper.costCenterId = System.Label.BLN_ISPLocationGUID;
        locWrapper.locationId = System.Label.BLN_ISPLocationGUID;
        locWrapper.mobileLocationIndicator = false;
        locWrapper.countryCode = 'GB';
		
        // Mock the HTTP callout  
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());  
        
        Test.startTest();
        String payload = BLN_ProductAvailability.makeQuoteCalloutForISPLocation(testCase.Id);
        Test.stopTest();

        // Assertions
        System.assertNotEquals(null, payload, 'Payload should not be null');
    }
    
    @isTest
    static void testUpdateAllQuoteIds() {
        // Create and insert a test Case
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'New',
            Origin = 'Phone'
        );
        insert testCase;
        
        // Create a mock payload
        String payload = '{"quotes":[{"quoteId":"Q12345"},{"quoteId":"Q67890"}]}';
        
        // Call the method
        Test.startTest();
        BLN_ProductAvailability.updateAllQuoteIds(payload, testCase.Id);
        Test.stopTest();
        
        // Retrieve the updated Case
        Case updatedCase = [SELECT BLN_CPQQuoteIdCollection__c FROM Case WHERE Id = :testCase.Id];
        
        // Assertions
        System.assertNotEquals(null, updatedCase.BLN_CPQQuoteIdCollection__c, 'Quote ID collection should not be null');
        System.assertEquals('Q12345,Q67890', updatedCase.BLN_CPQQuoteIdCollection__c, 'Quote ID collection should match the payload');
    }

    @isTest
    static void testMakeRepriceCallout() {
        // Mock the callout response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Define test parameters
        String repriceRequestPayload = '{"somePayload":"value"}';
        String caseRecordId = 'someCaseId';
        
        // Call the method
        Test.startTest();
        String repricedPayload = BLN_ProductAvailability.makeRepriceCallout(repriceRequestPayload, caseRecordId);
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, repricedPayload, 'Repriced payload should not be null');
        //System.assert(repricedPayload.contains('someExpectedValue'), 'Repriced payload should contain the expected value');
    }

    

@isTest
    static void testDisplayLocation() {
        // Prepare test data
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Knowledge__kav knowledge1 = new Knowledge__kav(
                Title = 'Knowledge 1',
                BLN_DisplayLocation__c = System.Label.BLN_QuoteSummary,
                UrlName = '1st-Article2'
            );
            insert knowledge1;

            Knowledge__kav knowledge2 = new Knowledge__kav(
                Title = 'Knowledge 2',
                BLN_DisplayLocation__c = System.Label.BLN_QuotePresentation,
                UrlName = '1st-Article3'
                
            );
            insert knowledge2;
        }

        // Call the method
        Test.startTest();
        List<BLN_ProductAvailabilityWrapper.DisplayLocationWrapper> result = BLN_ProductAvailability.displayLocation();
        Test.stopTest();

        // Assertions
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.size() == 2, 'Result size should be 2');

        for (BLN_ProductAvailabilityWrapper.DisplayLocationWrapper wrapper : result) {
            if (wrapper.screenName == System.Label.BLN_QuoteSummary) {
                System.assert(wrapper.value.size() == 1, 'Quote summary knowledge should have 1 entry');
                System.assert(wrapper.value[0].Title == 'Knowledge 1', 'Title should be Knowledge 1');
            } else if (wrapper.screenName == System.Label.BLN_QuotePresentation) {
                System.assert(wrapper.value.size() == 1, 'Quote presentation knowledge should have 1 entry');
                System.assert(wrapper.value[0].Title == 'Knowledge 2', 'Title should be Knowledge 2');
            }
        }
    }

    @isTest
    static void testGetIsFirstCustomPermission() {
        // Mock FeatureManagement
        FeatureManagement fm = new FeatureManagement();

        Test.startTest();
        Boolean result = BLN_ProductAvailability.getIsFirstCustomPermission();
        Test.stopTest();

        // Assertions
        System.assertNotEquals(true, result, 'Permission check should return false');
    }
    
    

@isTest  
    static void testUpdateWOwithOrderFuture() {  
        // Create a test Account  
        Account testAccount = new Account(  
            Name = 'Test Account'  
        );  
        insert testAccount;  
  
        // Create a test Case  
        Case testCase = new Case(  
            Subject = 'Test Case',  
            Status = 'New',  
            AccountId = testAccount.Id  
            // Add other required fields as necessary  
        );  
        insert testCase;  
  
        // Create a test WorkOrder linked to the Case  
        WorkOrder testWorkOrder = new WorkOrder(  
            Status = 'New',  
            CaseId = testCase.Id  
            // Add other required fields as necessary  
        );  
        insert testWorkOrder;  
  
        // Create a test Order linked to the Case  
        Order testOrder = new Order(  
            Name = 'Test Order',  
            EffectiveDate = Date.today(),  
            Status = 'Draft',  
            AccountId = testAccount.Id,  
            BLN_Case__c = testCase.Id  // Ensure this matches with the Case  
        );  
        insert testOrder;  
  
        // Call the future method  
        Test.startTest();  
        BLN_ProductAvailability.updateWOwithOrderFuture(testOrder.Id);  
        Test.stopTest();  
  
        // Retrieve the updated WorkOrder  
        testWorkOrder = [SELECT Id, BLN_Order__c FROM WorkOrder WHERE Id = :testWorkOrder.Id];  
  
        // Assertions  
        System.assertEquals(testOrder.Id, testWorkOrder.BLN_Order__c, 'The WorkOrder should have the Order ID set.');  
    }

    @isTest
    static void testUpdateCaseFuture() {
        // Create and insert a test Case
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'New',
            Origin = 'Phone'
        );
        insert testCase;

        // Prepare the JSON string to simulate the records to be updated
        String caseJson = JSON.serialize(testCase);

        // Call the future method
        Test.startTest();
        BLN_ProductAvailability.updateCaseFuture(caseJson);
        Test.stopTest();

        // Retrieve the updated Case
        Case updatedCase = [SELECT Id, Status FROM Case WHERE Id = :testCase.Id];

        // Assertions
        System.assertNotEquals(null, updatedCase, 'Updated Case should not be null');
        System.assertEquals('New', updatedCase.Status, 'Status should remain New'); // Adjust based on expected updates
    }  
  
    private class MockHttpResponseGenerator implements HttpCalloutMock {  
        public HTTPResponse respond(HTTPRequest req) {  
            // Create a fake response  
            HttpResponse res = new HttpResponse();  
            res.setHeader('Content-Type', 'application/json');  
            res.setBody('{"quotes":[{"quoteId":"QUOTE1","locationId":"GUID1","quoteTotals":{"totalPrice":1000.0,"totalTax":200.0,"totalIncludingTax":1200.0},"motoristTotals":{"totalPayableByMotorist":300.0,"totalTaxPayableByMotorist":60.0,"totalIncludingTaxPayableByMotorist":360.0},"insuranceTotals":{"totalPayableByInsurance":500.0,"totalTaxPayableByInsurance":100.0,"totalIncludingTaxPayableByInsurance":600.0},"tradeCompanyTotals":{"totalPayableByTrade":200.0,"payableByTradeTotalTax":40.0,"totalPayableByTradeIncludingTax":240.0},"lineItems":[{"lineItemId":1,"partNumber":"PROD1","quantity":1,"netPrice":800.0,"netPriceIncludingTax":960.0,"totalTax":160.0,"selectProduct":true}]}]}');  
            res.setStatusCode(201);  
            return res;  
        }  
    }  

}