@isTest
private class LAD_webCartTriggerTest {

    @TestSetup
    static void testData() {
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
    static void TestwebCartTrigger(){
        WebCart c = [SELECT Id, Status FROM WebCart WHERE Name = 'TestCart' LIMIT 1];
        c.status = 'PendingDelete';
        Test.startTest();
        update c;
        Test.stopTest();
        //List<WebCart> clist = new List<WebCart>();
        //clist.add(c);
    }
}