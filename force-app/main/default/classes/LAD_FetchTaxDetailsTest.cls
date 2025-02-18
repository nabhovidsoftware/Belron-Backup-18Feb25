/**
* @description       : Test Class for LAD_FetchTaxDetails
* @author            : Prajjawal Tiwari
* @group             : B2B Commerce - Belron
* @last modified on  : 06-11-2024
* @last modified by  : Prajjawal Tiwari
**/

@isTest
private class LAD_FetchTaxDetailsTest {

    @TestSetup
    static void makeData(){
        Account testAccount = new Account(Name = 'ABC Corp'); // add more fields based on your org validation 
        insert testAccount;
        Contact testContact = New Contact(LastName = 'Test', AccountID = testAccount.id);
        insert testContact;
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User' LIMIT 1];
        user testUser = New User(UserName = 'test_' + math.random() + '@test.com',
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
        
        
        AssociatedLocation testAssociatedLocation = new AssociatedLocation(LocationId = loc.id,
                                                                           LAD_Location_Type__c = 'Primary',
                                                                           ParentRecordId = testAccount.Id);
        insert testAssociatedLocation;
        
        Product2 testProduct = new Product2(Name = 'Test Product');
        insert testProduct;
        
        WebStore testStore = new WebStore(Name = 'test Store',
                                          OptionsAutoFacetingEnabled = true,
                                          OptionsCartToOrderAutoCustomFieldMapping = true,	
                                          OptionsCommerceEinsteinActivitiesTracked = true,	                                             
                                          OptionsCommerceEinsteinDeployed = true,	
                                          OptionsGuestBrowsingEnabled = true,	                                             
                                          OptionsSkipAdditionalEntitlementCheckForSearch = true);
        insert testStore;
        WebCart testCart = new WebCart (Name = 'TestCart', WebStoreId = testStore.id, AccountId = testAccount.id);
        insert testCart;
        
        OrderDeliveryMethod testDelMethod = new OrderDeliveryMethod(name = 'TestMethod', isActive = true);
        insert testDelMethod;
        
        CartDeliveryGroup testGroup = new CartDeliveryGroup(Name = 'TestGroup', CartId = testCart.id, DeliveryMethodId = testDelMethod.Id);
        insert testGroup;
        
        String deliveryDate = Date.today().addDays(7).format();
        LAD_MDC_Preference__c mdcPreference = new LAD_MDC_Preference__c();
        mdcPreference.LAD_Account__c = testAccount.Id;
        mdcPreference.LAD_Delivery_Date__c = deliveryDate;
        mdcPreference.LAD_Associated_Location__c = testAssociatedLocation.Id;
        
        
        mdcPreference.LAD_Product__c = testProduct.id;
        
        
        mdcPreference.LAD_User__c = testUser.id;
        
        insert mdcPreference;
        CartItem testItem = new CartItem(Name = 'TestItem', 
                                         Product2id = testProduct.id,
                                         Quantity = 10,
                                         CartDeliveryGroupId = testGroup.id, 
                                         CartId = testCart.id,
                                        TotalPriceAfterAllAdjustments=100);
        insert testItem;
         Set<Id> idSet = new Set<Id>();
        idSet.add(testItem.id);
        Test.setMock(HttpCalloutMock.class, new LAD_FetchTaxDetailsMock());
        Test.startTest();
        LAD_FetchTaxDetails.getTaxInfo(idSet);
                  
		List<CartTax> exitingTax=[select id from carttax];
        system.assertequals(0,exitingTax.size());
        Test.stopTest();


    }

    @isTest
    static void getTaxInfoTest() {
        Id itemId = [SELECT Id FROM CartItem WHERE Name = 'TestItem' LIMIT 1].Id;
        List<LAD_FetchTaxDetails.LineItem> wrapperList=new List<LAD_FetchTaxDetails.LineItem>();
                LAD_FetchTaxDetails.LineItem wrapperitem=new  LAD_FetchTaxDetails.LineItem();
				wrapperitem.totaltax=10;
        wrapperList.add(wrapperitem);
       LAD_FetchTaxDetails.LineItemWrapper wrapper=new  LAD_FetchTaxDetails.LineItemWrapper();
       wrapper.lineItems=wrapperList;
    }
    
    
    @isTest
    static void returnBearerTokensTest(){
         Test.setMock(HttpCalloutMock.class, new LAD_FetchTaxDetailsMockOcta());
        Test.startTest();
        LAD_FetchTaxDetails.returnBearerTokens();
                  

        Test.stopTest();
    }
}