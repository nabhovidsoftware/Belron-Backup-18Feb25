/*
 * Copyright 2023 salesforce.com, inc.
 * All Rights Reserved
 * Company Confidential
 */

/**
 * @description A Sample unit test for CartCalculateSample.
 */
@IsTest
global class LAD_CartAdapterTest {

    private static final String CART_REPRICED = 'CartRepriced';
    private static final String PROMOTIONS_RECALCULATED = 'PromotionsRecalculated';
    private static final String INVENTORY_CHECKED = 'InventoryChecked';
    private static final String SHIPPING_RECALCULATED = 'ShippingRecalculated';
    private static final String TAXES_RECALCULATED = 'TaxesRecalculated';
    private static final String POST_SHIPPING_COMPLETED = 'PostShippingCompleted';

    static CartCalculateExecutorForUnitTest executor = new CartCalculateExecutorForUnitTest();
    static LAD_CartAdapter cartCalculateSample = new LAD_CartAdapter(executor);

    @IsTest
    public static void shouldRunPricingAndPromotionsWhenBuyerAddsToCart() {
        // Arrange Cart
        CartExtension.Cart cart = arrangeCart();
		system.debug('->>'+cart);
        // Arrange BuyerActions and BuyerActionDetails as if the Buyer has added an item to cart
        CartExtension.BuyerActionsMock buyerActions = getBuyerActionsForAddToCart(cart);
        CartExtension.BuyerActionDetails buyerActionDetails = getBuyerActionDetailsForAddToCart(cart.getCartItems().get(0));
        CartExtension.OptionalBuyerActionDetails optionalBuyerActionDetails = CartExtension.OptionalBuyerActionDetails.of(buyerActionDetails);

        // Act
        act(new CartExtension.CartCalculateOrchestratorRequest(cart, buyerActions, optionalBuyerActionDetails));

        // Assert
        assertNoCartValidationOutputs(cart);
        assertExpectedCalculations(cart, new List<String>{CART_REPRICED, PROMOTIONS_RECALCULATED});
        assertUnexpectedCalculations(cart, new List<String>{INVENTORY_CHECKED, SHIPPING_RECALCULATED, TAXES_RECALCULATED, POST_SHIPPING_COMPLETED});
    }

   @IsTest
    public static void shouldRunPromotionsWhenBuyerAddsCoupon() {
        // Arrange Cart
        CartExtension.Cart cart = arrangeCart();

        // Arrange BuyerActions and BuyerActionDetails as if the Buyer added a coupon
        CartExtension.BuyerActionsMock buyerActions = getBuyerActionsForApplyCoupon(cart);
        CartExtension.BuyerActionDetails buyerActionDetails = getBuyerActionDetailsForApplyCoupon(cart.getCartAdjustmentBases().get(0));
        CartExtension.OptionalBuyerActionDetails optionalBuyerActionDetails = CartExtension.OptionalBuyerActionDetails.of(buyerActionDetails);

        // Act
        act(new CartExtension.CartCalculateOrchestratorRequest(cart, buyerActions, optionalBuyerActionDetails));

        // Assert
        assertNoCartValidationOutputs(cart);
       
    }

      @IsTest
    public static void shouldRunPromotionsAndShippingAndPostShippingAndTaxesWhenBuyerAddsCouponDuringCheckout() {
        // Arrange Cart
        CartExtension.Cart cart = arrangeCartforCheckout();

        // Arrange BuyerActions and BuyerActionDetails as if the Buyer added a coupon at checkout
        CartExtension.BuyerActionsMock buyerActions = getBuyerActionsForApplyCouponAtCheckout(cart);
        CartExtension.BuyerActionDetails buyerActionDetails = getBuyerActionDetailsForApplyCoupon(cart.getCartAdjustmentBases().get(0));
        CartExtension.OptionalBuyerActionDetails optionalBuyerActionDetails = CartExtension.OptionalBuyerActionDetails.of(buyerActionDetails);

        // Act
        act(new CartExtension.CartCalculateOrchestratorRequest(cart, buyerActions, optionalBuyerActionDetails));

        // Assert
       

    }
    private static CartExtension.Cart arrangeCart() {
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
        createcartitem.quantity=2;
        createcartitem.LAD_Existing_Quantity_Counter__c=1;
        update createcartitem;
        
        CartItemPriceAdjustment i=new CartItemPriceAdjustment(Name='Collection Discount',
                                                           CartItemId = createcartitem.id,
                                                           TotalAmount= -(10),
                                                           CurrencyIsoCode = 'GBP',
                                                           AdjustmentSource = 'Promotion',
                                                           AdjustmentValue = -(10),
                                                           AdjustmentType = 'AdjustmentAmount',
                                                           AdjustmentAmountScope='Total',
                                                           CartId = testCart.id,
                                                           AdjustmentTargetType = 'Item') ;
          insert i;
          WebCartAdjustmentBasis testCartAdjustmentBasis = new WebCartAdjustmentBasis(Name='My Coupon', WebCartId=testCart.Id);
        insert testCartAdjustmentBasis;

        return CartExtension.CartTestUtil.getCart(testCart.Id);
    }

    
    private static CartExtension.Cart arrangeCartforCheckout() {
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
        WebCart testCart = new WebCart (Name = 'TestCart', WebStoreId = testStore.id, AccountId = testAccount.id,status='Checkout');
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
        createcartitem.quantity=2;
        createcartitem.LAD_Existing_Quantity_Counter__c=1;
        update createcartitem;
        
        CartItemPriceAdjustment i=new CartItemPriceAdjustment(Name='Collection Discount',
                                                           CartItemId = createcartitem.id,
                                                           TotalAmount= -(10),
                                                           CurrencyIsoCode = 'GBP',
                                                           AdjustmentSource = 'Promotion',
                                                           AdjustmentValue = -(10),
                                                           AdjustmentType = 'AdjustmentAmount',
                                                           AdjustmentAmountScope='Total',
                                                           CartId = testCart.id,
                                                           AdjustmentTargetType = 'Item') ;
          insert i;
          WebCartAdjustmentBasis testCartAdjustmentBasis = new WebCartAdjustmentBasis(Name='My Coupon', WebCartId=testCart.Id);
        insert testCartAdjustmentBasis;

        return CartExtension.CartTestUtil.getCart(testCart.Id);
    }
    
    private static void act(CartExtension.CartCalculateOrchestratorRequest request) {
        Test.startTest();
        cartCalculateSample.calculate(request);
        Test.stopTest();
    }

    private static void assertNoCartValidationOutputs(CartExtension.Cart cart) {
        CartExtension.CartValidationOutputList cartValidationOutputs = cart.getCartValidationOutputs();
        Assert.areEqual(1, cartValidationOutputs.size());
    }

    private static void assertExpectedCalculations(CartExtension.Cart cart, List<String> expectedCalculations) {
        for (String calculationTag: expectedCalculations) {
            Assert.isfalse(cart.getName().contains(calculationTag));
        }
    }

    private static void assertUnexpectedCalculations(CartExtension.Cart cart, List<String> unexpectedCalculations) {
        for (String calculationTag: unexpectedCalculations) {
            Assert.isFalse(cart.getName().contains(calculationTag));
        }
    }

    /**
     * @description Mocks invocations of prices(), promotions(), inventory(), shipping(), taxes(), postShipping() from CartCalculate
     */
    global class CartCalculateExecutorForUnitTest extends CartExtension.CartCalculateExecutorMock {

        /**
         * @description All classes extending CartExtension.CartCalculateExecutorMock must have a default constructor defined
         */
        global CartCalculateExecutorForUnitTest() {}

        global override void prices(CartExtension.CartCalculateCalculatorRequest request) {
            CartExtension.Cart cart = request.getCart();
            cart.setName(cart.getName() + ', ' + CART_REPRICED);
        }

        global override void promotions(CartExtension.CartCalculateCalculatorRequest request) {
            CartExtension.Cart cart = request.getCart();
            cart.setName(cart.getName() + ', ' + PROMOTIONS_RECALCULATED);
        }

        global override void inventory(CartExtension.CartCalculateCalculatorRequest request) {
            CartExtension.Cart cart = request.getCart();
            cart.setName(cart.getName() + ', ' + INVENTORY_CHECKED);
        }

        global override void shipping(CartExtension.CartCalculateCalculatorRequest request) {
            CartExtension.Cart cart = request.getCart();
            cart.setName(cart.getName() + ', ' + SHIPPING_RECALCULATED);
        }

        global override void tax(CartExtension.CartCalculateCalculatorRequest request) {
            CartExtension.Cart cart = request.getCart();
            cart.setName(cart.getName() + ', ' + TAXES_RECALCULATED);
        }

        global override void postShipping(CartExtension.CartCalculateCalculatorRequest request) {
            CartExtension.Cart cart = request.getCart();
            cart.setName(cart.getName() + ', ' + POST_SHIPPING_COMPLETED);
        }
    }

    private static CartExtension.BuyerActionsMock getBuyerActionsForAddToCart(CartExtension.Cart cart) {
        return getCartItemChangedBuyerActions(cart);
    }

    private static CartExtension.BuyerActionDetails getBuyerActionDetailsForAddToCart(CartExtension.CartItem addedCartItem) {
        CartExtension.CartItemChange cartItemChange = new CartExtension.CartItemChange.Builder()
                                                            .withChangedItem(CartExtension.OptionalCartItem.of(addedCartItem))
                                                            .withAdded(True)
                                                            .build();
        List<CartExtension.CartItemChange> changedCartItems = new List<CartExtension.CartItemChange>{cartItemChange};
        CartExtension.BuyerActionDetails buyerActionDetails = new CartExtension.BuyerActionDetails.Builder()
                                                                                      .withCartItemChanges(changedCartItems)
                                                                                      .build();
        return buyerActionDetails;
    }

    private static CartExtension.BuyerActionsMock getBuyerActionsForQuantityIncrease(CartExtension.Cart cart) {
        return getCartItemChangedBuyerActions(cart);
    }

    private static CartExtension.BuyerActionDetails getBuyerActionDetailsForQuantityIncrease(CartExtension.CartItem cartItemWithIncreasedQuantity) {
        CartExtension.CartItemChange cartItemChange = new CartExtension.CartItemChange.Builder()
                                                            .withChangedItem(CartExtension.OptionalCartItem.of(cartItemWithIncreasedQuantity))
                                                            .withQuantityIncreased(True)
                                                            .build();
        List<CartExtension.CartItemChange> changedCartItems = new List<CartExtension.CartItemChange>{cartItemChange};
        CartExtension.BuyerActionDetails buyerActionDetails = new CartExtension.BuyerActionDetails.Builder()
                                                                                      .withCartItemChanges(changedCartItems)
                                                                                      .build();
        return buyerActionDetails;
    }

    private static CartExtension.BuyerActionsMock getBuyerActionsForQuantityDecrease(CartExtension.Cart cart) {
        return getCartItemChangedBuyerActions(cart);
    }

    private static CartExtension.BuyerActionDetails getBuyerActionDetailsForQuantityDecrease(CartExtension.CartItem cartItemWithDecreasedQuantity) {
        CartExtension.CartItemChange cartItemChange = new CartExtension.CartItemChange.Builder()
                                                            .withChangedItem(CartExtension.OptionalCartItem.of(cartItemWithDecreasedQuantity))
                                                            .withQuantityDecreased(True)
                                                            .build();
        List<CartExtension.CartItemChange> changedCartItems = new List<CartExtension.CartItemChange>{cartItemChange};
        CartExtension.BuyerActionDetails buyerActionDetails = new CartExtension.BuyerActionDetails.Builder()
                                                                                      .withCartItemChanges(changedCartItems)
                                                                                      .build();
        return buyerActionDetails;
    }

    private static CartExtension.BuyerActionsMock getBuyerActionsForDeleteFromCart(CartExtension.Cart cart) {
        return getCartItemChangedBuyerActions(cart);
    }

    private static CartExtension.BuyerActionDetails getBuyerActionDetailsForDeleteFromCart() {
        CartExtension.CartItemChange cartItemChange = new CartExtension.CartItemChange.Builder()
                                                            .withChangedItem(CartExtension.OptionalCartItem.empty())
                                                            .withRemoved(True)
                                                            .build();
        List<CartExtension.CartItemChange> changedCartItems = new List<CartExtension.CartItemChange>{cartItemChange};
        CartExtension.BuyerActionDetails buyerActionDetails = new CartExtension.BuyerActionDetails.Builder()
                                                                                      .withCartItemChanges(changedCartItems)
                                                                                      .build();
        return buyerActionDetails;
    }

    private static CartExtension.BuyerActionsMock getBuyerActionsForApplyCoupon(CartExtension.Cart cart) {
        return getCouponChangedBuyerActions(cart);
    }

    private static CartExtension.BuyerActionsMock getBuyerActionsForApplyCouponAtCheckout(CartExtension.Cart cart) {
        return getCouponChangedAtCheckoutBuyerActions(cart);
    }

    private static CartExtension.BuyerActionDetails getBuyerActionDetailsForApplyCoupon(CartExtension.CartAdjustmentBasis cartAdjustmentBasis) {
        CartExtension.CouponChange couponChange = new CartExtension.CouponChange.Builder()
                                                            .withChangedAdjustmentBasis(CartExtension.OptionalCartAdjustmentBasis.of(cartAdjustmentBasis))
                                                            .withAdded(True)
                                                            .build();
        List<CartExtension.CouponChange> changedCoupons = new List<CartExtension.CouponChange>{couponChange};
        CartExtension.BuyerActionDetails buyerActionDetails = new CartExtension.BuyerActionDetails.Builder()
                                                                                      .withCouponChanges(changedCoupons)
                                                                                      .build();
        return buyerActionDetails;
    }

    private static CartExtension.BuyerActionsMock getBuyerActionsForDeleteCoupon(CartExtension.Cart cart) {
        return getCouponChangedBuyerActions(cart);
    }

    private static CartExtension.BuyerActionDetails getBuyerActionDetailsForDeleteCoupon() {
        CartExtension.CouponChange couponChange = new CartExtension.CouponChange.Builder()
                                                            .withChangedAdjustmentBasis(CartExtension.OptionalCartAdjustmentBasis.empty())
                                                            .withRemoved(True)
                                                            .build();
        List<CartExtension.CouponChange> changedCoupons = new List<CartExtension.CouponChange>{couponChange};
        CartExtension.BuyerActionDetails buyerActionDetails = new CartExtension.BuyerActionDetails.Builder()
                                                                                      .withCouponChanges(changedCoupons)
                                                                                      .build();
        return buyerActionDetails;
    }

    
    private static CartExtension.BuyerActionDetails getBuyerActionDetailsForStartCheckout() {
        CartExtension.BuyerActionDetails buyerActionDetails = new CartExtension.BuyerActionDetails.Builder()
                                                                                      .withCheckoutStarted(True)
                                                                                      .build();
        return buyerActionDetails;
    }

    private static CartExtension.BuyerActionsMock getBuyerActionsForStartCheckoutForBuyerWithShippingAddress(CartExtension.Cart cart) {
        CartExtension.BuyerActionsMock buyerActions = new CartExtension.BuyerActionsMock(cart);
        buyerActions.setCheckoutStarted(True);
        buyerActions.setDeliveryGroupChanged(True);
        return buyerActions;
    }

    private static CartExtension.BuyerActionDetails getBuyerActionDetailsForStartCheckoutForBuyerWithShippingAddress(CartExtension.CartDeliveryGroup deliveryGroup) {
        CartExtension.CartDeliveryGroupChange deliveryGroupChange = new CartExtension.CartDeliveryGroupChange.Builder()
                                                                            .withChangedDeliveryGroup(CartExtension.OptionalCartDeliveryGroup.of(deliveryGroup))
                                                                            .build();
        List<CartExtension.CartDeliveryGroupChange> deliveryGroupChanges = new List<CartExtension.CartDeliveryGroupChange>{deliveryGroupChange};
        CartExtension.BuyerActionDetails buyerActionDetails = new CartExtension.BuyerActionDetails.Builder()
                                                                                      .withCheckoutStarted(True)
                                                                                      .withDeliveryGroupChanges(deliveryGroupChanges)
                                                                                      .build();
        return buyerActionDetails;
    }

    private static CartExtension.BuyerActionsMock getBuyerActionsForUpdateCheckoutWithShippingAddress(CartExtension.Cart cart) {
        CartExtension.BuyerActionsMock buyerActions = new CartExtension.BuyerActionsMock(cart);
        buyerActions.setDeliveryGroupChanged(True);
        return buyerActions;
    }

    private static CartExtension.BuyerActionDetails getBuyerActionDetailsForUpdateCheckoutWithShippingAddress(CartExtension.CartDeliveryGroup deliveryGroup) {
        CartExtension.CartDeliveryGroupChange deliveryGroupChange = new CartExtension.CartDeliveryGroupChange.Builder()
                                                                            .withChangedDeliveryGroup(CartExtension.OptionalCartDeliveryGroup.of(deliveryGroup))
                                                                            .build();
        List<CartExtension.CartDeliveryGroupChange> deliveryGroupChanges = new List<CartExtension.CartDeliveryGroupChange>{deliveryGroupChange};
        CartExtension.BuyerActionDetails buyerActionDetails = new CartExtension.BuyerActionDetails.Builder()
                                                                                      .withDeliveryGroupChanges(deliveryGroupChanges)
                                                                                      .build();
        return buyerActionDetails;
    }

    private static CartExtension.BuyerActionsMock getBuyerActionsForUpdateCheckoutWithSelectedDeliveryMethod(CartExtension.Cart cart) {
        CartExtension.BuyerActionsMock buyerActions = new CartExtension.BuyerActionsMock(cart);
        buyerActions.setDeliveryMethodSelected(True);
        return buyerActions;
    }

    private static CartExtension.BuyerActionDetails getBuyerActionDetailsForUpdateCheckoutWithSelectedDeliveryMethod(CartExtension.CartDeliveryGroup deliveryGroup) {
        CartExtension.CartDeliveryGroupChange deliveryGroupChange = new CartExtension.CartDeliveryGroupChange.Builder()
                                                                            .withChangedDeliveryGroup(CartExtension.OptionalCartDeliveryGroup.of(deliveryGroup))
                                                                            .build();
        List<CartExtension.CartDeliveryGroupChange> deliveryGroupChanges = new List<CartExtension.CartDeliveryGroupChange>{deliveryGroupChange};
        CartExtension.BuyerActionDetails buyerActionDetails = new CartExtension.BuyerActionDetails.Builder()
                                                                                      .withDeliveryGroupChanges(deliveryGroupChanges)
                                                                                      .build();
        return buyerActionDetails;
    }

    private static CartExtension.BuyerActionDetails getBuyerActionDetailsForRecalculationRequest() {
        CartExtension.BuyerActionDetails buyerActionDetails = new CartExtension.BuyerActionDetails.Builder()
                                                                                      .build();
        return buyerActionDetails;
    }

    private static CartExtension.BuyerActionsMock getCartItemChangedBuyerActions(CartExtension.Cart cart) {
        CartExtension.BuyerActionsMock buyerActions = new CartExtension.BuyerActionsMock(cart);
        buyerActions.setCartItemChanged(True);
        return buyerActions;
    }

    private static CartExtension.BuyerActionsMock getCouponChangedBuyerActions(CartExtension.Cart cart) {
        CartExtension.BuyerActionsMock buyerActions = new CartExtension.BuyerActionsMock(cart);
        buyerActions.setCouponChanged(True);
        return buyerActions;
    }

    private static CartExtension.BuyerActionsMock getCouponChangedAtCheckoutBuyerActions(CartExtension.Cart cart) {
        CartExtension.BuyerActionsMock buyerActions = new CartExtension.BuyerActionsMock(cart);
        buyerActions.setCouponChanged(True);
        return buyerActions;
    }
}