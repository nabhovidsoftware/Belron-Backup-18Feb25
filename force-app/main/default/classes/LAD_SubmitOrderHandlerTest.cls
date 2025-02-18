/** @description :  Test Class for LAD_SubmitOrderHandler
*   @Story :        
*   @author:        (binayak.debnath@pwc.com (IN))
*   @CreatedDate:   13-06-2024
*/
@isTest
private class LAD_SubmitOrderHandlerTest {
    
    // Test data setup
    @testSetup static void setup() {
        Account testaccount =new Account(Name = 'ABC Corp');
        insert testaccount;
        BuyerAccount buyerAccount = new BuyerAccount();
        buyerAccount.BuyerId = testaccount.Id;
        buyerAccount.Name = 'Test Buyer Account (BA-AJ)';
        buyerAccount.IsActive = true;
        insert buyerAccount;
        
        BuyerGroup bg=new BuyerGroup();
        bg.name='Test';
        bg.Role='AccountBased';
        insert bg;
        BuyerGroupMember bgm=new BuyerGroupMember();
        bgm.BuyerId =testaccount.id;
        bgm.BuyerGroupId=bg.id;
        insert bgm;
        
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
        loc.BLN_GUID__c = 'L19_UK';
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
        
        WebStoreBuyerGroup wsbg=new WebStoreBuyerGroup();
        wsbg.WebStoreId=testStore.id;
        wsbg.BuyerGroupid=bg.id;
        insert wsbg;

        //CART RELATED DATA
        WebCart testCart = new WebCart (Name = 'TestCart', WebStoreId = testStore.id, AccountId = testAccount.id);
        insert testCart;
        testCart.OwnerId = testUser.Id;
        update testCart;
        
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
                                         CartId = testCart.id
                                         );
        insert testItem;
        CartTax tax = new CartTax(  Amount = 50.0,
                                  CartItemId = testItem.id,
                                  Name = 'Sample',
                                  TaxCalculationDate = Date.today(),
                                  TaxRate = 0.5,
                                  TaxType = 'Actual');
        insert tax;
    }

    @isTest
    static void checkAccountViabilityTest_Exception() {
        
        Test.startTest();
        LAD_SubmitOrderHandler.AccountWrapper acc = LAD_SubmitOrderHandler.checkAccountViability('Test',null);
                LAD_SubmitOrderHandler.AccountWrapper acc1 = LAD_SubmitOrderHandler.checkAccountViability('Test',[select id from account limit 1].id);

        Test.stopTest();
        System.assertNotEquals(null, acc);
    }

    @isTest
    static void checkAccountViabilityTest() {
        Id userId = [SELECT Id FROM User WHERE FirstName = 'Test-First'].Id;
        Test.startTest();
        LAD_SubmitOrderHandler.AccountWrapper acc = LAD_SubmitOrderHandler.checkAccountViability(userId,null);
        Test.stopTest();
        System.assertEquals(false, acc.onHold, 'Expected not on hold');
    }
    
    @isTest
    static void processOrderAndOrderSummariesTest() {
        WebCart testCart = [SELECT Id, (SELECT Name, 
                                            Amount,
                                            TaxRate,
                                            TaxType,
                                            TaxCalculationDate,
                                            CartItem.Product2Id 
                                    FROM CartItemTaxes) FROM WebCart WHERE Name = 'TestCart' AND Account.Name = 'ABC Corp' LIMIT 1];
        system.debug('cart>>>'+ testCart+ 'cart taxes>>'+testCart.CartItemTaxes);
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true
        );
        update standardPricebook;
        Product2 testProduct = [SELECT Id FROM Product2 WHERE Name = 'Test Product'];
        PriceBookEntry testEntry = new PriceBookEntry(product2id = testProduct.id, pricebook2id = pricebookId, UnitPrice = 0);
        insert testEntry;
        Test.startTest();
        LAD_SubmitOrderHandler.orderSummaryWrapper returnWrapper = LAD_SubmitOrderHandler.processOrderAndOrderSummaries(testCart.id, 'Test');
        Test.stopTest();
        System.assertNotEquals(null, returnWrapper, 'Expected a return');
    }
}