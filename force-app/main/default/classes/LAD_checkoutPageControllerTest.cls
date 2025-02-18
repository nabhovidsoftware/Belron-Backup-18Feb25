@isTest
public class LAD_checkoutPageControllerTest {
    
    @isTest
    static void testFetchTimeLimitForCollection(){
        Test.startTest();
        Map<String, Integer> returnNum = LAD_checkoutPageController.fetchPreferredTimeLimits();
        Test.stopTest();
        System.assertNotEquals(null, returnNum);
    }
    @isTest
    static void testGetCartId() {
        // Create test user
       	User sampleUser=LAD_TestDataFactory.createAdminUser();
         Test.startTest();
        id accId=null;
         System.runAs(sampleUser) {
        Account testaccount =LAD_TestDataFactory.createAccount();
             accId=testaccount.id;
        WebStore testWebStore=LAD_TestDataFactory.createWebStore();
        WebCart sampleWebCart=LAD_TestDataFactory.createWebCart(testWebStore.id,testaccount.id,sampleUser.id);
        WebCart testCart = [Select Id FROM WebCart WHERE OwnerId = :sampleUser.Id AND Status = 'Active' LIMIT 1];
            
        

         }
        Id cartId = LAD_checkoutPageController.getCartId(sampleUser.Id,accId).cartId;
        
             Test.stopTest();

        // Verify the result
        System.assertNotEquals(null, cartId, 'CartId should not be null');
    }

    @isTest
    static void testGetCartItems() {
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
        testCart.OwnerId = testUser.Id;
        update testCart;
        CartDeliveryGroup testGroup = new CartDeliveryGroup(Name = 'TestGroup', CartId = testCart.id);
        insert testGroup;
        
        LAD_MDC_Preference__c pref=new LAD_MDC_Preference__c();
        pref.LAD_Account__c=testAccount.id;
        pref.LAD_Associated_Location__c=testAssociatedLocation.id;
        pref.LAD_Product__c=testProduct.id;
        pref.LAD_Delivery_Date__c='2024-10-10';
        pref.LAD_User__c=testUser.id;
        insert pref;
        CartItem createcartitem=LAD_TestDatafactory.createCartitem(testCart.id,testGroup.id,testProduct.id);
        pref.LAD_Cartitem__c=createcartitem.id;
        update pref;
        LAD_checkoutPageController.getCartItems(createcartitem.id);
                LAD_checkoutPageController.getProdLocAddresses(testCart.id);
        LAD_checkoutPageController.updatePoDetails(createcartitem.id,'Ponumber');
        
        ContactPointAddress add=new ContactPointAddress();
        add.Parentid=testAccount.id;
        add.AddressType='Shipping';
        add.name='test';
        insert add;
        
        Orderdeliverymethod method=new Orderdeliverymethod();
        method.name='Laddaw Delivery';
        method.CurrencyIsoCode='GBP';
        method.IsActive=true;
        insert method;
        
        
        Promotion promo=new Promotion();
        promo.name='test';
        promo.DisplayName='test';
        promo.LAD_Discount_Value__c=10;
        promo.LAD_Discount_Type__c='Amount';
        promo.LAD_Collection_Discount__c=true;
        insert promo;
        LAD_Assigned_Address__c assignedadd=new LAD_Assigned_Address__c();
		assignedadd.LAD_Account__c=testAccount.id;
        assignedadd.LAD_Address__c=add.id;
        assignedadd.LAD_Assigned_MDC__c=testAssociatedLocation.id;
        assignedadd.LAD_Is_default__c=true;
       insert assignedadd;
        
        
        
        
        List<Map<string,object>> lst=new List<Map<string,object>>();
        Map<string,object> testobj=new Map<string,object>();
        string addid=assignedadd.id;
        testobj.put('cartId',testCart.id);
       	testobj.put('location','test');
		testobj.put('method','Laddaw Delivery');
		testobj.put('address',assignedadd.id);
        testobj.put('cartitemid',createcartitem.id);
        testobj.put('deliverydate','2024-10-10');
        testobj.put('poNumber','test');
        testobj.put('cartPoNumber','cartPoNumber');
         testobj.put('preferredDate','2024-10-10');
        testobj.put('invokeCollectionDiscount',true);

        lst.add(testobj);
        LAD_checkoutPageController.createDelGrp(testCart.id,lst,'','');
        List<Map<string,object>> lst1=new List<Map<string,object>>();

        testobj.put('method','Laddaw Collection');
        testobj.put('preferredDate','2024-10-10');
        testobj.put('invokeCollectionDiscount',true);

        method.name='Laddaw Collection';

        update method;
        lst1.add(testobj);
        LAD_checkoutPageController.returnPrefilledData(testCart.id);
        LAD_checkoutPageController.createDelGrp(testCart.id,lst1,'','');

			List<Map<string,string>> lstmap=new List<Map<string,string>>();
		Map<string,string> a=new Map<string,string>();
		a.put('CartItemId',createcartitem.id);
        a.put('UserId',testUser.id);
        lstmap.add(a);
  
        // Test.setMock(HttpCalloutMock.class, new LAD_ReturnAssociatedLocationDetailsMock());
		Test.startTest();
        LAD_checkoutPageController.getPreferenceData(lstmap);
        LAD_checkoutPageController.getCartItems(testcart.id);
		// LAD_checkoutPageController.getProductAvailability(testUser.id,testCart.id,'01','Bardon',10);
        Test.stopTest();

        }


    
    
     @IsTest(SeeAllData=true)
    static void testGetConnectedapiData() {
        Test.startTest();
        // Call getConnectedapiData method
        String apiData = LAD_checkoutPageController.getConnectedapiData();
        Test.stopTest();

        // Verify the result
        System.assertNotEquals(null, apiData, 'API Data should not be null');
    }
    
     @isTest
    static void testMethod1() {
        LAD_checkoutPageController.returnSymbol('GPB');
    }
    
    
    @isTest
    static void testGetCartItems2() {
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
        testCart.OwnerId = testUser.Id;
        update testCart;
        CartDeliveryGroup testGroup = new CartDeliveryGroup(Name = 'TestGroup', CartId = testCart.id);
        insert testGroup;
        
        LAD_MDC_Preference__c pref=new LAD_MDC_Preference__c();
        pref.LAD_Account__c=testAccount.id;
        pref.LAD_Associated_Location__c=testAssociatedLocation.id;
        pref.LAD_Product__c=testProduct.id;
        pref.LAD_Delivery_Date__c='2024-10-10';
        pref.LAD_User__c=testUser.id;
        insert pref;
        CartItem createcartitem=LAD_TestDatafactory.createCartitem(testCart.id,testGroup.id,testProduct.id);
        pref.LAD_Cartitem__c=createcartitem.id;
        update pref;
        LAD_checkoutPageController.getCartItems(createcartitem.id);
                LAD_checkoutPageController.getProdLocAddresses(testCart.id);
        LAD_checkoutPageController.updatePoDetails(createcartitem.id,'Ponumber');
        
        ContactPointAddress add=new ContactPointAddress();
        add.Parentid=testAccount.id;
        add.AddressType='Shipping';
        add.name='test';
        insert add;
        
        Orderdeliverymethod method=new Orderdeliverymethod();
        method.name='Laddaw Delivery';
        method.CurrencyIsoCode='GBP';
        method.IsActive=true;
        insert method;
        
        
        Promotion promo=new Promotion();
        promo.name='test';
        promo.DisplayName='test';
        promo.LAD_Discount_Value__c=10;
        promo.LAD_Discount_Type__c='Percentage';
        promo.LAD_Collection_Discount__c=true;
        insert promo;
        LAD_Assigned_Address__c assignedadd=new LAD_Assigned_Address__c();
		assignedadd.LAD_Account__c=testAccount.id;
        assignedadd.LAD_Address__c=add.id;
        assignedadd.LAD_Assigned_MDC__c=testAssociatedLocation.id;
        assignedadd.LAD_Is_default__c=true;
       insert assignedadd;
        
        
        
        
        List<Map<string,object>> lst=new List<Map<string,object>>();
        Map<string,object> testobj=new Map<string,object>();
        string addid=assignedadd.id;
        testobj.put('cartId',testCart.id);
       	testobj.put('location','test');
		testobj.put('method','Laddaw Delivery');
		testobj.put('address',assignedadd.id);
        testobj.put('cartitemid',createcartitem.id);
        testobj.put('deliverydate','2024-10-10');
        testobj.put('poNumber','test');
        testobj.put('cartPoNumber','cartPoNumber');
         testobj.put('preferredDate','2024-10-10');
        testobj.put('invokeCollectionDiscount',true);

        lst.add(testobj);
        LAD_checkoutPageController.createDelGrp(testCart.id,lst,'','');
        List<Map<string,object>> lst1=new List<Map<string,object>>();

        testobj.put('method','Laddaw Collection');
        testobj.put('preferredDate','2024-10-10');
        testobj.put('invokeCollectionDiscount',true);

        method.name='Laddaw Collection';

        update method;
        lst1.add(testobj);
        LAD_checkoutPageController.returnPrefilledData(testCart.id);
        LAD_checkoutPageController.createDelGrp(testCart.id,lst1,'','');

			List<Map<string,string>> lstmap=new List<Map<string,string>>();
		Map<string,string> a=new Map<string,string>();
		a.put('CartItemId',createcartitem.id);
        a.put('UserId',testUser.id);
        lstmap.add(a);
        
      
      
         Test.startTest();
          string credit = LAD_checkoutPageController.creditlimit(testAccount.Id,testUser.Id);
        string currency1 = LAD_checkoutPageController.currencyfetch(testAccount.Id,testUser.Id);
        Id accid = LAD_checkoutPageController.getAccId(testUser.Id);
        
        LAD_checkoutPageController.getPreferenceData(lstmap);
        LAD_checkoutPageController.getCartItems(testcart.id);
        LAD_checkoutPageController.updateSpecialOrderflagOnCart(testUser.id,testAccount.id);
        LAD_checkoutPageController.checkIfCartExists(testUser.id,testAccount.id);
        // Test.setMock(HttpCalloutMock.class, new LAD_ReturnAssociatedLocationDetailsMock());
		
		// LAD_checkoutPageController.getProductAvailability(testUser.id,testCart.id,'01','Bardon',10);
         Test.stopTest();
        
	
   
		delete createcartitem;
        }
    
    //credit limit 
   /* @isTest
    static void testmethod2()
    {
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
        
        
        
        
        
        Test.startTest();
		string credit = LAD_checkoutPageController.creditlimit(testAccount.Id,testUser.Id);
        string currency1 = LAD_checkoutPageController.currencyfetch(testAccount.Id,testUser.Id);
        Test.stopTest();
        
        
    }*/

      
   



}