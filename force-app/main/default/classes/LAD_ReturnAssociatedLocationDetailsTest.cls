/** @description :  Test Class for LAD_ReturnAssociatedLocationDetails and LAD_CartItemTriggerHandler
*   @Story :        FOUK-9051; FOUK-8454; FOUK-8231; FOUK-8232; FOUK-8230; FOUK-7684; FOUK-8367
*   @author:        (prajjawal.tiwari@pwc.com (IN)) (binayak.debnath@pwc.com (IN))
*   @CreatedDate:   22-05-2024
*/
@isTest
private class LAD_ReturnAssociatedLocationDetailsTest {
    // Test data setup
    @testSetup static void setup() {
        Account testAccount = new Account(Name = 'ABC Corp'); // add more fields based on your org validation 
        insert testAccount;
        Contact testContact = New Contact(LastName = 'Test', AccountID = testAccount.id);
        insert testContact;
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User' LIMIT 1];
        user testUser = New User(   UserName = 'test_' + math.random() + '@test.com',
                                    FirstName = 'Test-First',
                                    LastName = 'Test-Last',
                                    Alias = 'test',
                                    email = 'test' + math.random() + '@test.com',
                                    CommunityNickName = string.valueOf(math.random()).substring(0,6),
                                    ProfileID = p.id,
                                    ContactId = testContact.Id,
                                    TimeZoneSidKey = 'America/New_York', 
                                    LocaleSidKey = 'en_US', 
                                    EmailEncodingKey = 'UTF-8', 
                                    LanguageLocaleKey = 'en_US');
        insert testUser; 
        
        Schema.location loc= new Schema.location();
        loc.Name = 'test';
        loc.LocationType = 'WAREHOUSE';
        loc.BLN_GUID__c = 'L31_UK';
        insert loc;
        
        
        AssociatedLocation testAssociatedLocation = new AssociatedLocation( LocationId = loc.id,
                                                                            LAD_Location_Type__c = 'Primary',
                                                                            ParentRecordId = testAccount.Id);
        insert testAssociatedLocation;
        
        Product2 testProduct = new Product2(Name = 'Test Product');
        insert testProduct;
        
        WebStore testStore = new WebStore(	Name = 'test Store',
                                            OptionsAutoFacetingEnabled = true,
                                            OptionsCartToOrderAutoCustomFieldMapping = true,	
                                            OptionsCommerceEinsteinActivitiesTracked = true,	                                             
                                            OptionsCommerceEinsteinDeployed = true,	
                                            OptionsGuestBrowsingEnabled = true,	                                             
                                            OptionsSkipAdditionalEntitlementCheckForSearch = true);
        insert testStore;
        WebCart testCart = new WebCart (Name = 'TestCart', WebStoreId = testStore.id, AccountId = testAccount.id);
        insert testCart;
        CartDeliveryGroup testGroup = new CartDeliveryGroup(Name = 'TestGroup', CartId = testCart.id);
        insert testGroup;
        
    }
    
    /* @isTest
    static void testGetAccId() {    
        Contact testContact = [SELECT Id, AccountId FROM Contact WHERE Name = 'Test' LIMIT 1];
        // system.debug('Contact = ' + testContact.Id);
        User testUser = [SELECT Id FROM User WHERE FirstName = 'Test-First'];
        
        Test.startTest();
        Id accountId = LAD_ReturnAssociatedLocationDetails.getAccId(testUser.Id);
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, accountId, 'Expected an Account Id');
        System.assertEquals(testContact.AccountId, accountId, 'Account Id should match the Contact\'s Account Id');
        
    } */
    
    @isTest
    static void testReturnLocationDetails() { 
        Contact testContact = [SELECT Id, AccountId FROM Contact WHERE Name = 'Test' LIMIT 1];
        // system.debug('Contact = ' + testContact.Id);
        User testUser = [SELECT Id FROM User WHERE FirstName = 'Test-First'];
        Test.setMock(HttpCalloutMock.class, new LAD_ReturnAssociatedLocationDetailsMock());
        
        // Test method invocation
        Test.startTest();
        List<String> productList = new List<String>{'0000000000'};
            
        LAD_ReturnAssociatedLocationDetails.productDetailWrapper data=new LAD_ReturnAssociatedLocationDetails.productDetailWrapper();
        data.userId=testUser.id;
        data.productIdList=productList;
        data.location='';
        data.quantity=10;
        data.effectiveAccountId=null;

        List<LAD_ReturnAssociatedLocationDetails.HttpResponseWrapper>  result = LAD_ReturnAssociatedLocationDetails.getProductAvailability(data);
        Test.stopTest();
        // Assertions
        System.assertEquals(true, result.size() > 0, 'Expected Location Data');
    }
    
    
    //Tests both createMDCPreferenceRecord method and LAD_CartItemTriggerHandler
    @isTest
    static void testCreateMDCPreferenceRecord() {
        // Test data setup
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'ABC Corp' LIMIT 1];
        
        
        AssociatedLocation location = [SELECT Id FROM AssociatedLocation WHERE LAD_Location_Type__c = 'Primary'];
        
        Product2 testProduct = [SELECT Id FROM Product2 WHERE Name = 'Test Product'];
        User testUser = [SELECT Id FROM User WHERE FirstName = 'Test-First'];
        String deliveryDate = Date.today().addDays(7).format(); // Set delivery date 7 days from today
        
        // Test method invocation
        Test.startTest();
        
        List<String> prodList = new List<String>{testProduct.Id};
            
            
         LAD_ReturnAssociatedLocationDetails.createMDCPreferenceRecordInputWrapper mdcWrapper   =new  LAD_ReturnAssociatedLocationDetails.createMDCPreferenceRecordInputWrapper ();
        mdcWrapper.locationId=location.Id;
            mdcWrapper.productIdList=prodList;
            mdcWrapper.userId= testUser.Id;
            mdcWrapper.deliveryDate=deliveryDate;
            mdcWrapper.effectiveAccountId=null;
        LAD_ReturnAssociatedLocationDetails.createMDCPreferenceRecord(mdcWrapper);
        CartDeliveryGroup testGroup = [SELECT Id FROM CartDeliveryGroup WHERE Name = 'TestGroup' LIMIT 1];
        WebCart testCart = [SELECT Id FROM WebCart WHERE Name = 'TestCart' LIMIT 1];
        CartItem testItem = new CartItem(Name = 'TestItem', 
                                         Product2id = testProduct.id,
                                         CartDeliveryGroupId = testGroup.id, 
                                         CartId = testCart.id);
        insert testItem;
        LAD_ReturnAssociatedLocationDetails.createMDCPreferenceRecord(mdcWrapper);
        
        Test.stopTest();
        
        // Assertions
        List<LAD_MDC_Preference__c> preferenceRecords = [SELECT Id FROM LAD_MDC_Preference__c WHERE LAD_Product__c = :testProduct.id AND LAD_User__c = :testUser.id LIMIT 1];
        System.assertNotEquals(0, preferenceRecords.size(), 'Expected at least one preference record');        
    }
}