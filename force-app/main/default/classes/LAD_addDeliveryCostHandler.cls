/**
 * @description       : 
 * @author            : Prajjawal Tiwari
 * @group             : 
 * @last modified on  : 10-24-2024
 * @last modified by  : Prajjawal Tiwari
**/
public with sharing class LAD_addDeliveryCostHandler {
    
    @AuraEnabled
    public static boolean returnInternalPortalViability(String userId) {
        String role = [SELECT contact.lad_role__c FROM User WHERE Id = :userId].contact.lad_role__c;
        String eligibleRoles = 'Wholesale Manager,Hub Manager,Hub Team User,Account Manager';
        
        return eligibleRoles.contains(role);
    }
    
    @AuraEnabled
    public static void addCost(String userId, String accountId, Decimal deliveryCost) {
        String accId = '';
        
        if (accountId == '' || accountId == null) {            
            accId = LAD_ReturnAssociatedLocationDetails.getAccId(userId);
        } else {
            accId = accountId;        
        }
        
        List<WebCart> fetchCartDetails = [
            SELECT Id, CurrencyIsoCode 
            FROM WebCart 
            WHERE AccountId = :accId 
            AND (Status = 'Active' OR Status = 'Checkout') 
            AND OwnerId = :userId
        ];
        
        List<CartItem> cartItemList = [
            SELECT Id, TotalPriceAfterAllAdjustments  
            FROM CartItem 
            WHERE CartId = :fetchCartDetails[0].Id 
            AND Name = 'Delivery Cost'
        ];
        
        List<Coupon> couponData = [
            SELECT Id, Name, PromotionId 
            FROM Coupon 
            WHERE Promotion.Name = 'Delivery Cost Update'
        ];      
        
        if (cartItemList.size() != 0) {
            delete cartItemList;
        }
        
        ConnectApi.CartItemInput cartInput = new ConnectApi.CartItemInput(); 
        cartInput.productId = [SELECT Id FROM Product2 WHERE Name = 'Delivery Cost' LIMIT 1].Id; // ProductId                     
        cartInput.quantity = String.valueOf(1);
        cartInput.type = ConnectApi.CartItemType.PRODUCT;   
        
        String cartItemId = '';
        
        if (!Test.isRunningTest()) {
            ConnectApi.CartItem connectApiCartItem = ConnectApi.CommerceCart.addItemToCart(
                [SELECT Id, Name FROM WebStore WHERE Name = 'Laddaw'].Id,
                accountId,
                fetchCartDetails[0].Id,
                cartInput
            );
            cartItemId = connectApiCartItem.cartItemId;
        }
        
        OrderDeliveryMethod orderDelMethod = [SELECT Id FROM OrderDeliveryMethod WHERE Name = 'Laddaw Shipping'];
        
        List<CartItem> updateCartItems = [
            SELECT Id, CartDeliveryGroupId  
            FROM CartItem 
            WHERE Id = :cartItemId
        ];
        
        CartDeliveryGroup cartItemDelGrp = new CartDeliveryGroup();
        cartItemDelGrp.Name = 'Laddaw Shipping';
        cartItemDelGrp.DeliveryMethodId = orderDelMethod.Id;
        cartItemDelGrp.CartId = fetchCartDetails[0].Id;
        
        insert cartItemDelGrp;
        decimal unitprice=[select id ,unitprice from pricebookentry where pricebook2.name='Delivery cost' and product2.name='Delivery Cost'].unitprice;
        Decimal discount=-unitprice+deliveryCost;
        if (!Test.isRunningTest()) { 
            CartItemPriceAdjustment priceAdjustment = new CartItemPriceAdjustment(
                Name = 'Delivery Cost Update',
                CartItemId = cartItemId,
                TotalAmount = discount,
                CurrencyIsoCode = 'GBP',
                AdjustmentSource = 'Promotion',
                AdjustmentValue = discount,
                AdjustmentType = 'AdjustmentAmount',
                PriceAdjustmentCauseId = couponData[0].PromotionId,
                AdjustmentBasisReferenceId = couponData[0].Id,
                AdjustmentAmountScope = 'Total',
                CartId = fetchCartDetails[0].Id,
                AdjustmentTargetType = 'Item'
            );
            if(discount!=0){
                insert priceAdjustment;

            }
            
            CartItem cartItem = new CartItem();
            cartItem.Id = cartItemId;
            cartItem.CartDeliveryGroupId = cartItemDelGrp.Id;
            cartItem.LAD_UnitPriceAdjustment__c = discount;
            cartItem.TotalAdjustmentAmount = discount;
            cartItem.TotalPriceAfterAllAdjustments = deliveryCost;
            cartItem.TotalPromoAdjustmentAmount = discount;
            cartItem.UnitAdjustmentAmount = discount;
            
            update cartItem;
        }
    }
  
    @AuraEnabled
    public static String returnDeliveryCost(String userId, String accountId) {
        String accId = '';
        
        if (accountId == '' || accountId == null) {            
            accId = LAD_ReturnAssociatedLocationDetails.getAccId(userId);
        } else {
            accId = accountId;        
        }
        
        List<WebCart> fetchCartDetails = [
            SELECT Id 
            FROM WebCart 
            WHERE AccountId = :accId 
            AND (Status = 'Active' OR Status = 'Checkout') 
            AND OwnerId = :userId
        ];
        
        if (fetchCartDetails.size() == 0) {
            return null;
        } else {
            List<CartItem> cartItemDelGrp = [
                SELECT Id, TotalPriceAfterAllAdjustments, CurrencyIsoCode   
                FROM CartItem 
                WHERE CartId = :fetchCartDetails[0].Id 
                AND Name = 'Delivery Cost'
            ];
            
            if (cartItemDelGrp.size() == 0) {
                pricebookentry i= [select id ,unitprice,CurrencyIsoCode from pricebookentry where pricebook2.name='Delivery cost' and product2.name='Delivery Cost' limit 1];
                return LAD_CheckoutPageController.returnSymbol(i.CurrencyIsoCode)+''+i.UnitPrice;
            } else {
                return ' ' + LAD_CheckoutPageController.returnSymbol(cartItemDelGrp[0].CurrencyIsoCode) + '' + cartItemDelGrp[0].TotalPriceAfterAllAdjustments;
            }
        }
    }
        @AuraEnabled
    public static String returnDeliveryCostCheckout(String userId, String accountId) {
        String accId = '';
        
        if (accountId == '' || accountId == null) {            
            accId = LAD_ReturnAssociatedLocationDetails.getAccId(userId);
        } else {
            accId = accountId;        
        }
        
        List<WebCart> fetchCartDetails = [
            SELECT Id 
            FROM WebCart 
            WHERE AccountId = :accId 
            AND (Status = 'Active' OR Status = 'Checkout') 
            AND OwnerId = :userId
        ];
        
        if (fetchCartDetails.size() == 0) {
            return null;
        } else {
            List<CartItem> cartItemDelGrp = [
                SELECT Id, TotalPriceAfterAllAdjustments, CurrencyIsoCode   
                FROM CartItem 
                WHERE CartId = :fetchCartDetails[0].Id 
                AND Name = 'Delivery Cost'
            ];
            
            if (cartItemDelGrp.size() == 0) {
            	return null;   
            } else {
                return ' ' + LAD_CheckoutPageController.returnSymbol(cartItemDelGrp[0].CurrencyIsoCode) + '' + cartItemDelGrp[0].TotalPriceAfterAllAdjustments;
            }
        }
    }
}