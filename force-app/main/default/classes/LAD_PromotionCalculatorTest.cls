@IsTest
public class LAD_PromotionCalculatorTest {
 @IsTest
    public static void testStaticMethodReturnValidReponse() {
          	User sampleUser=LAD_TestDataFactory.createAdminUser();
        Id cartId=null;
         System.runAs(sampleUser) {
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
        
        LAD_MDC_Preference__c pref=new LAD_MDC_Preference__c();
        pref.LAD_Account__c=testAccount.id;
        pref.LAD_Associated_Location__c=testAssociatedLocation.id;
        pref.LAD_Product__c=testProduct.id;
        pref.LAD_Delivery_Date__c='2024-10-10';
        pref.LAD_User__c=testUser.id;
        insert pref;
        CartItem createcartitem=LAD_TestDatafactory.createCartitem(testCart.id,testGroup.id,testProduct.id);
		        createcartitem.LAD_UnitPriceAdjustment__c=100;
             update createcartitem;
        cartId=testCart.id;
         cartitempriceadjustment cipr=new cartitempriceadjustment();
         cipr.AdjustmentAmountScope='Total';
        cipr.AdjustmentSource='Promotion';
             cipr.AdjustmentTargetType='Item';
             cipr.AdjustmentType='OverrideAmount';
             cipr.AdjustmentValue=100;
             cipr.CartId=testCart.id;
             cipr.CartItemId=createcartitem.id;
             cipr.TotalAmount=100;
             cipr.name='check';
             insert cipr;

         }
        
       
        CartExtension.Cart cart = CartExtension.CartTestUtil.getCart(cartId);

        Test.startTest();
        LAD_PromotionCalculator calculator =  new LAD_PromotionCalculator();
        calculator.istest=true;
        calculator.calculate(new CartExtension.CartCalculateCalculatorRequest(cart, CartExtension.OptionalBuyerActionDetails.empty()));
        Test.stopTest();


    }
}