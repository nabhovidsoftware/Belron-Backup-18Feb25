/** @description :  This apex class is used to validation errors on Cart Page
*   @Story :        
*   @author:        (prajjawal.tiwari@pwc.com (IN))
*   @CreatedDate:   19-06-2024
*/


global class LAD_CartAdapter extends CartExtension.CartCalculate {

    
    /**
     * @description All classes extending CartExtension.CartCalculate must have a default constructor defined
     */
    global LAD_CartAdapter() {}

    /**
     * @description Constructor used by unit tests only. See <<CartCalculateSampleUnitTest>>.
     * @param apexExecutor Executor which executes various calculators. Can be used to stub calculation results or delegate calculations to actual Calculator. See <<CartCalculateExecutorMock>>.
     */
    global LAD_CartAdapter(final CartExtension.CartCalculateExecutorMock apexExecutor) {
        // Must call super constructor in order for provided Executor to be used for calculations
		//super(apexExecutor);
    }

    // Each orchestrator must override this calculate method.
    global virtual override void calculate(CartExtension.CartCalculateOrchestratorRequest request) {
        CartExtension.Cart cart = request.getCart();
		
        dismissAllexistingErrors(request);
        
        boolean isPriceAdjustmentApplied=checkIfPriceAdjustmentIsApplied(request);
        
        boolean isDeliveryCostUpdated=checkIfDeliveryCostIsModified(request);
        
        
        // Use BuyerActions to decide which calculators to invoke
        CartExtension.BuyerActions buyerActions = request.getBuyerActions();
        boolean isCouponAppliedInCheckout = isCouponAppliedInCheckout(buyerActions, cart);
        boolean runPricing = buyerActions.isRecalculationRequested() || buyerActions.isCheckoutStarted() || buyerActions.isCartItemChanged();
        boolean runPromotions = buyerActions.isRecalculationRequested() || buyerActions.isCheckoutStarted() || buyerActions.isCouponChanged() || buyerActions.isCartItemChanged();
        boolean runInventory = isRecalculationRequestedInCheckout(buyerActions, cart) || buyerActions.isCheckoutStarted() ;
        boolean runShipping = isRecalculationRequestedInCheckout(buyerActions, cart) || buyerActions.isDeliveryGroupChanged() || isCouponAppliedInCheckout ;
        boolean runPostShipping = isRecalculationRequestedInCheckout(buyerActions, cart) || buyerActions.isDeliveryGroupChanged() || buyerActions.isDeliveryMethodSelected() || isCouponAppliedInCheckout ;
        boolean runTaxes = isRecalculationRequestedInCheckout(buyerActions, cart) || buyerActions.isDeliveryGroupChanged() || buyerActions.isDeliveryMethodSelected() || isCouponAppliedInCheckout ;

        // OptionalBuyerActionDetails can be used to optimize the various calculators that are invoked
        CartExtension.CartCalculateCalculatorRequest calculatorRequest = new CartExtension.CartCalculateCalculatorRequest(cart, request.getOptionalBuyerActionDetails());

        if (runPricing) {
            

            if (isPriceAdjustmentApplied || isDeliveryCostUpdated) {
                return;
            }else{
                prices(calculatorRequest);
            }
        }

        if (runPromotions) {
            promotions(calculatorRequest);

            
        }

     
    }

    // This function evaluates whether there are errors in the CVO of a specific calculator type.
    private Boolean hasErrorLevelCartValidationOutput(CartExtension.CartValidationOutputList cartValidationOutputs,
                                                      CartExtension.CartValidationOutputTypeEnum cartValidationOutputType) {
        Iterator<CartExtension.CartValidationOutput> iterator = cartValidationOutputs.iterator();

        while (iterator.hasNext()) {
            CartExtension.CartValidationOutput cvo = iterator.next();

            Boolean cvoContainsCalculatorError = cvo.getType() == cartValidationOutputType
                    && cvo.getLevel() == CartExtension.CartValidationOutputLevelEnum.ERROR;

            if (cvoContainsCalculatorError) {
                return true;
            }
        }

        return false;
    }

    private Boolean isCouponAppliedInCheckout(CartExtension.BuyerActions buyerActions, CartExtension.Cart cart) {
        return cart.getStatus() == CartExtension.CartStatusEnum.CHECKOUT && buyerActions.isCouponChanged();
    }

    private Boolean isRecalculationRequestedInCheckout(CartExtension.BuyerActions buyerActions, CartExtension.Cart cart) {
      //  return buyerActions.isRecalculationRequested() && CartExtension.CartStatusEnum.CHECKOUT == cart.getStatus();
      return true;
    }
    
    /**
     * @description Checks for Price Adjustment and blocks quantity change when price adjustment is applies
     */
    private Boolean checkIfPriceAdjustmentIsApplied(CartExtension.CartCalculateOrchestratorRequest request) {
        system.debug('METHOD ENTRY');
        Boolean isPriceAdjustmentApplied = false;
        
        // Iterate through the cart items
        Iterator<CartExtension.CartItem> cartItemIterator = request.getCart().getCartItems().iterator();
        
        while (cartItemIterator.hasNext()) {
            CartExtension.CartItem cartItem = cartItemIterator.next();
            
            // Iterate through the price adjustments of the current cart item
            Iterator<CartExtension.CartItemPriceAdjustment> priceAdjustmentIterator = cartItem.getCartItemPriceAdjustments().iterator();
            
            Integer priceAdjustmentCount = 0;
            
            while (priceAdjustmentIterator.hasNext()) {
                CartExtension.CartItemPriceAdjustment priceAdjustment = priceAdjustmentIterator.next();
                priceAdjustmentCount++;
            }
            
       
            // Check if there are price adjustments and quantity mismatch
            if (priceAdjustmentCount != 0 && ((Decimal)cartItem.getQuantity() != (Decimal)cartItem.getCustomField('LAD_Existing_Quantity_Counter__c'))) {
                
                // Create validation output for the pricing issue
                CartExtension.CartValidationOutput validationOutput = new CartExtension.CartValidationOutput(
                    CartExtension.CartValidationOutputTypeEnum.Promotions,
                    CartExtension.CartValidationOutputLevelEnum.INFO,
                    cartItem
                );
                validationOutput.setMessage('You cannot change the quantity of this item.');
                
                // Add validation output to the cart's validation list
                request.getCart().getCartValidationOutputs().add(validationOutput);
                request.getCart().getCartValidationOutputs().add(validationOutput);
                
                // Mark that a price adjustment has been applied
                isPriceAdjustmentApplied = true;
                
                // Restore the original quantity of the cart item
                Decimal existingQuantity = (Decimal)cartItem.getCustomField('LAD_Existing_Quantity_Counter__c');
                cartItem.setQuantity(existingQuantity);
                
            } else {
                // Update the custom field with the current quantity
                cartItem.setCustomField('LAD_Existing_Quantity_Counter__c', cartItem.getQuantity());
            }
        }
    	system.debug('isPriceAdjustmentApplied>>'+isPriceAdjustmentApplied);
        return isPriceAdjustmentApplied;
        
    }

	 /**
     * @description Checks for Price Adjustment and blocks quantity change when price adjustment is applies
     */
    private Boolean checkIfDeliveryCostIsModified(CartExtension.CartCalculateOrchestratorRequest request) {  
        system.debug('METHOD ENTRY');  
        Boolean isDeliveryCostUpdated = false;  
      
        // Iterate through the cart items  
        Iterator<CartExtension.CartItem> cartItemIterator = request.getCart().getCartItems().iterator();  
      
        while (cartItemIterator.hasNext()) {  
            CartExtension.CartItem cartItem = cartItemIterator.next();  
      
            // Check if there are price adjustments and quantity mismatch  
            if (cartItem.getSKU().equals('PSER00405A') &&  
                (cartItem.getQuantity() > 1 ||  
                (!FeatureManagement.checkPermission('LAD_Laddaw_Internal_Portal') &&  
                cartItem.getQuantity() != cartItem.getCustomField('LAD_Existing_Quantity_Counter__c')))) {  
                  
                // Create validation output for the pricing issue  
                CartExtension.CartValidationOutput validationOutput = new CartExtension.CartValidationOutput(  
                    CartExtension.CartValidationOutputTypeEnum.Promotions,  
                    CartExtension.CartValidationOutputLevelEnum.INFO,  
                    cartItem  
                );  
                validationOutput.setMessage('You can not modify the quantity of Delivery Cost');  
                  
                // Add validation output to the cart's validation list  
                request.getCart().getCartValidationOutputs().add(validationOutput);  
                  
                // Mark that a price adjustment has been applied  
                isDeliveryCostUpdated = true;  
                  
                // Restore the original quantity of the cart item  
                Decimal existingQuantity = (Decimal) cartItem.getCustomField('LAD_Existing_Quantity_Counter__c');  
                cartItem.setQuantity(existingQuantity);  
                  
            } else {  
                // Update the custom field with the current quantity  
                cartItem.setCustomField('LAD_Existing_Quantity_Counter__c', cartItem.getQuantity());  
            }  
        }  
        system.debug('isDeliveryCostUpdated>>' + isDeliveryCostUpdated);  
        return isDeliveryCostUpdated;  
    }  
    
    
    private void dismissAllexistingErrors(CartExtension.CartCalculateOrchestratorRequest request) {
        
		CartExtension.CartValidationOutputList cartValidationOutputCollection = request.getCart().getCartValidationOutputs();
 		Iterator<CartExtension.CartValidationOutput> iterator = cartValidationOutputCollection.iterator();
        while(iterator.hasnext()){
              CartExtension.CartValidationOutput cv = iterator.next();
            	cv.setDismissed(true);

        }

    }
    
    
    private void checkIfDeliveryCostIsRemoved(CartExtension.CartCalculateOrchestratorRequest request) {
        system.debug('METHOD ENTRY');  
        Boolean isDeliveryCostItemInCart = false;  
        boolean isDeliveryAppliedBefore=(boolean)request.getCart().getCustomField('LAD_Delivery_Cost_Applied__c');
        boolean isInternalPortalUser=FeatureManagement.checkPermission('LAD_Laddaw_Internal_Portal');
        Iterator<CartExtension.CartItem> cartItemIterator = request.getCart().getCartItems().iterator();  
		Iterator<CartExtension.CartDeliveryGroup> getCartDeliveryGroups = request.getCart().getCartDeliveryGroups().iterator();  
		CartExtension.CartDeliveryGroup deliveryCostDelGrp=null; 
        while (cartItemIterator.hasNext()) {  
            CartExtension.CartItem cartItem = cartItemIterator.next();  
            if(cartItem.getSKU().equals('PSER00405A')){
                isDeliveryCostItemInCart=true;
            }
        }
        
         while (getCartDeliveryGroups.hasNext()) {  
            CartExtension.CartDeliveryGroup cartDelgrp = getCartDeliveryGroups.next();  
            if(cartDelgrp.getName().equals('Laddaw Shipping')){
                deliveryCostDelGrp=cartDelgrp;
            }
        }
        
        
        if(!isInternalPortalUser && isDeliveryAppliedBefore && !isDeliveryCostItemInCart){
            CartExtension.CartItem ci=new CartExtension.CartItem(
            															CartExtension.SalesItemTypeEnum.PRODUCT,
                														deliveryCostDelGrp,
                														'Delivery Cost'
            													);
            
            ci.setProduct2Id('01t9K000009CqNRQA0');
            ci.setquantity(1);
			request.getCart().getCartItems().add(ci);

        }
        
        
        
    }


            
}