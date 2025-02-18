/** @description :  This apex class is used to handle Amend Order and Reorder Functionality.
*   @Story :        FOUK-9073; FOUK-9872; FOUK-10281
*   @author:        (binayak.debnath@pwc.com (IN)) (prajjawal.tiwari@pwc.com (IN))
*   @CreatedDate:   12-07-2024
*/
public with sharing class LAD_AmendOrderHandler {


    //ORDER DETAILS SEGMENT
	@TestVisible private static boolean isTest = false;
	@TestVisible private static string orderIdfromtest = '';
	//@TestVisible private static string cartIdMock = '';

 /**@MethodName :    doesCartExist
    * @description :    This checks whether a cart exists corrosponding to account and user.
    * @param:           string userId,string effectiveAccountId
    * @return:          Boolean
    */
    @AuraEnabled
    public static Boolean doesCartExist(string userId,string effectiveAccountId){
       
            string loggedInAccountId=[select accountId from user where id=:userId].accountId;
            effectiveAccountId= effectiveAccountId != null && effectiveAccountId != '' ? effectiveAccountId : loggedInAccountId;
            List<webcart> cartList=[SELECT id FROM webcart WHERE accountId=:effectiveAccountId AND ownerId=:userId AND status IN ('Active', 'Checkout')];
            if(cartList.size()!=0){
                return true;
            }else{
                return false;
            }

     
    }
    
    /**@className :     OrderWrapper
    * @description :    Used to wrap order input parameters from LWC.
    */
    public class OrderWrapper{
        @auraenabled public string orderSummaryId {get; set;}
        @auraenabled public string userId {get; set;}
        @auraenabled public boolean isAmend {get; set;}
        @auraenabled public boolean isReorder {get; set;}
    }
    /**@MethodName :    amendOrderController
    * @description :    This method handles the entire functionality of creating a cart and related objects from an Order.
    * @param:           id orderSummaryId
    * @return:          void
    */
    @auraenabled
    public static void amendOrderController(OrderWrapper orderSummaryDetails){
        OrderSummary ordersummaryInstance=new ordersummary();
        system.debug(orderSummaryDetails.orderSummaryId);
        string orderId='';
        if(!isTest){
          OrderSummary i=[select id,OriginalOrderId,LAD_Special_Order__c,LAD_Special_Order_Number__c from ordersummary where id=:orderSummaryDetails.orderSummaryId];
            orderId=i.OriginalOrderId;
            ordersummaryInstance=i;

        }else{
            orderId=orderIdfromtest;
        }
        //Fetch order Details
        Order orderDetail=[SELECT 	id,
                                    name,
                                    accountId,
                                    SalesStoreId,
                                    POnumber,
                                    Description,
                                    (SELECT Id, 
                                            OrderDeliveryGroupId,
                                            OrderDeliveryGroup.LAD_Name__c,
                                            OrderDeliveryGroup.DeliverToStreet,
                                            OrderDeliveryGroup.DeliverToCity,
                                            OrderDeliveryGroup.DeliverToState,
                                            OrderDeliveryGroup.DeliverToPostalCode,
                                            OrderDeliveryGroup.DeliverToCountry,
                                            OrderDeliveryGroup.OrderDeliveryMethodId,
                                            OrderDeliveryGroup.DesiredDeliveryDate,
                                            OrderDeliveryGroup.LAD_Date_Selected_By_Customer__c, //FOUK-9758 & FOUK-9759
                                            OrderDeliveryGroup.LAD_Deliver_to_Location__c, //FOUK-10272
                                            Product2Id,
                                            Product2.Name, 
                                            TotalLineTaxAmount, 
                                            Quantity, 
                                            LAD_PO_Number__c
                                    FROM orderItems),
                                    (SELECT id,
                                            LAD_Name__c,
                                            DeliverToStreet,
                                            DeliverToCity,
                                            DeliverToState,
                                            DeliverToPostalCode,
                                            DeliverToCountry,
                                            DeliverToName,
                                            OrderDeliveryMethodId,
                                            DesiredDeliveryDate,
                                            LAD_Date_Selected_By_Customer__c,
                                            LAD_Deliver_to_Location__c
                                    FROM OrderDeliveryGroups),
                                    (SELECT AdjustmentValue,
                                            AdjustmentType,
                                            AdjustmentAmountScope,
                                            AdjustmentSource,
                                            AdjustmentBasisReferenceId,
                                            AdjustmentCauseId,
                                            TotalAmtWithTax,
                                            OrderAdjustmentGroupId,
                                            TotalTaxAmount,
                                            Description,
                                            RelatedAdjustmentLineItemId,
                                            OrderId,
                                            Amount,
                                            OrderItemId,
                                            OrderItem.product2id,
                                            Id,
                                            Name,
                                            CurrencyIsoCode 
                                    FROM OrderItemAdjustmentLineItems)
                                FROM order 
                                WHERE id=:orderId];


        handleCreateMDCAmenOrReorder(orderDetail, orderSummaryDetails.userId);

        if(orderSummaryDetails.isAmend){
            string cartId = createCart(orderDetail, orderSummaryDetails.isAmend,ordersummaryInstance);
            List<cartDeliveryGroup> cartDeliveryGroups = setCartDeliveryGroup(cartId,orderDetail); //will only happen in Amend
            List<cartItem> cartitemlist = createCartItems(cartId, orderDetail, cartDeliveryGroups, orderSummaryDetails.isAmend,orderSummaryDetails.isReorder);                            
            handlePriceAdjustment(orderDetail, cartitemlist, cartId);   //will only happen in Amend
        }
        else if(orderSummaryDetails.isReorder){
            string cartId = createCart(orderDetail, orderSummaryDetails.isAmend,ordersummaryInstance);
            List<cartItem> cartitemlist = createCartItems(cartId, orderDetail, null, orderSummaryDetails.isAmend,orderSummaryDetails.isReorder);                            
        }
        
    }


    /**@MethodName :    handleCreateMDCAmenOrReorder
    * @description :    This method handles the creation/updation of MDC records related to the Amend / Reorder functionality.
    * @param:           Order orderDetail, String userId
    * @return:          void
    */
    public static void handleCreateMDCAmenOrReorder(Order orderDetail, String userId){
        String accountId = orderDetail.AccountId;
        Map<String, String> ordDelGrpIdLocationIdMap = new Map<String, String>();
        Map<String, String> locationIdAssLocIdMap = new Map<String, String>();
        Map<String, Set<String>> ordDelGrpIdProductIdSetMap = new Map<String, Set<String>>();
       // List<LAD_ReturnAssociatedLocationDetails.createMDCPreferenceRecordInputWrapper> mdcList = new List<LAD_ReturnAssociatedLocationDetails.createMDCPreferenceRecordInputWrapper>();
        for(OrderDeliveryGroup ord : orderDetail.OrderDeliveryGroups){

            ordDelGrpIdLocationIdMap.put(ord.Id, ord.LAD_Deliver_to_Location__c);
            
            Set<String> productIdSet = new Set<String>();
            ordDelGrpIdProductIdSetMap.put(ord.Id, productIdSet);
        }

        for(AssociatedLocation assLoc : [SELECT Id, LocationId FROM AssociatedLocation WHERE LocationId IN :ordDelGrpIdLocationIdMap.values() AND ParentRecordId = :accountId]){
            locationIdAssLocIdMap.put(assLoc.LocationId, assLoc.Id);
        }

        for(OrderItem item : orderDetail.OrderItems){
            system.debug('Product ID' + item.Product2Id);
            Set<String> updateProducts = ordDelGrpIdProductIdSetMap.get(item.OrderDeliveryGroupId);
            updateProducts.add(item.Product2Id);
            ordDelGrpIdProductIdSetMap.put(item.OrderDeliveryGroupId, updateProducts);
            system.debug('Updated Product Id Set' + ordDelGrpIdProductIdSetMap.get(item.OrderDeliveryGroupId));
        }

        for(String ordId : ordDelGrpIdProductIdSetMap.keySet()){
            LAD_ReturnAssociatedLocationDetails.createMDCPreferenceRecordInputWrapper mdcWrapper = new LAD_ReturnAssociatedLocationDetails.createMDCPreferenceRecordInputWrapper();
            mdcWrapper.userId = userId;
            mdcWrapper.effectiveAccountId = accountId;
            mdcWrapper.locationId = locationIdAssLocIdMap.get(ordDelGrpIdLocationIdMap.get(ordId));
            mdcWrapper.productIdList = new List<String>(ordDelGrpIdProductIdSetMap.get(ordId));
            mdcWrapper.deliveryDate = '';
            system.debug(mdcWrapper);
            LAD_ReturnAssociatedLocationDetails.createMDCPreferenceRecord(mdcWrapper);
        }
        

    }
  
    /**@MethodName :    handlePriceAdjustment
    * @description :    This method handles Price Adjustment for the Cart items created from the Amended Order.
    * @param:           Order OrderDetail,List<cartItem> cartitemlist,string cartId
    * @return:          void
    */
    public static void handlePriceAdjustment(Order OrderDetail,List<cartItem> cartitemlist,string cartId){
        try{
            
        
        Map<string,cartItem> cartItemsMap=new  Map<string,cartItem>();
        system.debug('cartItemsMap>>>'+cartItemsMap);
        for(cartItem j:cartitemlist){
          
            cartItemsMap.put(j.product2id,j);
        }
        List<cartitem> updatecartitemList=new List<cartItem>();
        List<cartItemPriceadjustment> cartpriceadjustLst=new List<cartItemPriceadjustment>();
      
        		
              for(OrderItemAdjustmentLineItem i:OrderDetail.OrderItemAdjustmentLineItems){
                if( cartItemsMap.get(i.OrderItem.product2id).id!=null ){
                     cartpriceadjustLst.add(new cartItemPriceadjustment(AdjustmentAmountScope='Total',
                                                                   AdjustmentSource='System',
                                                                   AdjustmentTargetType='Item',
                                                                   AdjustmentType='OverrideAmount',
                                                                   AdjustmentValue=i.Amount,
                                                                   CartId=cartId,
                                                                   AdjustmentBasisReferenceId=i.AdjustmentBasisReferenceId,
                                                                   TotalAmount=i.Amount,
                                                                   PriceAdjustmentCauseId=i.AdjustmentCauseId,
                                                                   Name=i.Name,
                                                                   CurrencyIsoCode=i.CurrencyIsoCode,
                                                                   CartItemId=cartItemsMap.get(i.OrderItem.product2id).id
                                                                   ));
                	
                CartItem instance=cartItemsMap.get(i.OrderItem.product2id);
                instance.TotalAdjustmentAmount=i.Amount;
                instance.TotalPromoAdjustmentAmount=i.Amount;
                    instance.LAD_UnitPriceAdjustment__c=i.Amount/cartItemsMap.get(i.OrderItem.product2id).quantity;
                instance.TotalPriceAfterAllAdjustments=instance.totalprice+i.AdjustmentValue;
                    updatecartitemList.add(instance);
                }
                  
               
            	}
        update updatecartitemList;
        insert cartpriceadjustLst;
        }catch(Exception ex){
            BLN_ExceptionLogger.captureException(ex);
        }
    }
    
    public class cartItemWrapper{
          @auraenabled public String name {get; set;}
          @auraenabled public decimal amount {get; set;}

    }
  
    /**@MethodName :    createCart
    * @description :    This method creates Cart from Order .
    * @param:           Order orderDetail
    * @return:          string
    */
    public static string createCart(Order orderDetail, Boolean isAmend,OrderSummary ordersummaryData){
        
      
     
        // Creating Cart using accountId and webstoreid fetched above
        ConnectApi.CartInput cart = new ConnectApi.CartInput();
        cart.effectiveAccountId=orderDetail.accountId;
        system.debug(cart+'-'+orderDetail.SalesStoreId);
        ConnectApi.CartSummary cartSummary=connectApi.CommerceCart.createCart(orderDetail.SalesStoreId,cart);
        system.debug(164);
        
        
        // Updating the reference of order in Cart record.
        WebCart webCartInstance=new WebCart();
        webCartInstance.id=cartSummary.cartid;
        if(isAmend){
            webCartInstance.LAD_Order__c=orderDetail.id;
            webCartInstance.LAD_Special_Order_Number__c=ordersummaryData.LAD_Special_Order_Number__c;
            webCartInstance.LAD_Special_Order_Cart__c=ordersummaryData.LAD_Special_Order__c;
            webCartInstance.PoNumber=orderDetail.PoNumber;
            webCartInstance.LAD_Comment__c=orderDetail.Description;
        }
        
        update webCartInstance;
        return cartSummary.cartid;
        
    }
  
  
    /**@MethodName :    createCartItems
    * @description :    This method creates Cart Items from Order Products.
    * @param:           string cartid,Order orderDetail,List<cartDeliveryGroup> cartDeliveryGroups
    * @return:          List<CartItem>
    */
    public static List<CartItem> createCartItems(string cartid, Order orderDetail, List<cartDeliveryGroup> cartDeliveryGroups, Boolean isAmend,Boolean isReorder){
        Map<string,string> cartdeliverygrpname_product=new map<string,string>();
        if(isAmend){
            for(cartDeliveryGroup c:cartDeliveryGroups){
                cartdeliverygrpname_product.put(c.name,c.id);
            }
        }
        
        // Fetching orderitem details to create cartItems.
        Map<string,orderItemDetails> product_DeliveryGroup=new Map<string,orderItemDetails>();
        for(orderItem o:orderDetail.orderItems){
            if(! (isReorder && o.Product2.Name=='Delivery Cost' )){
               // creating cartItems using connectApi
            
            ConnectApi.CartItemInput cartInput = new ConnectApi.CartItemInput(); 
            cartInput.productId = o.product2id;//ProductId                     
            
            cartInput.quantity = string.valueof(o.quantity);
            
            cartInput.type = ConnectApi.CartItemType.PRODUCT;   
            if(!isTest){
                ConnectApi.CartItem ConnectApi_CartItem=ConnectApi.CommerceCart.addItemToCart(orderDetail.SalesStoreId,orderDetail.accountId,cartId, cartInput);

            }
            
            //Store Delivery Group Name and PO Numbers only if Amend
            if(isAmend){
                orderItemDetails oid = new orderItemDetails();	
                oid.orderDeliveryGroupName = o.OrderDeliveryGroup.LAD_name__c;
                oid.orderItemPoNumber = o.LAD_PO_Number__c;
            
                product_DeliveryGroup.put(o.product2id,oid);
            }
              
            }
           
        }

        List<CartItem> fetchCartItems=[select id,product2id,product2.name,TotalPrice,cartdeliverygroupid,LAD_UnitPriceAdjustment__c,quantity,LAD_Non_Returnable__c,LAD_Is_Price_Adjustment_Applied__c from cartItem where cartId=:cartid];
        Set<id> cartItemList=new Set<id>();
        for(cartitem i:fetchCartItems){
            cartItemList.add(i.id);
        }
        LAD_FetchTaxDetails.getTaxInfo(cartItemList);
        
        //Update Cart Item with Cart Delivery Group only if Amend
        if(isAmend){
            List<OrderItemSummary> ois = [SELECT Id, Product2Id, LAD_Non_Returnable_Flag__c,LAD_Is_Price_Adjustment_Applied__c FROM OrderItemSummary WHERE OrderSummary.OriginalOrderId =:orderDetail.Id];
            Map<String,Boolean> nonReturnableCheck = new Map<String,Boolean>();
             Map<String,Boolean> priceAdjustmentAppliedBoolean = new Map<String,Boolean>();
            for(OrderItemSummary o:ois){
                nonReturnableCheck.put(o.Product2Id,o.LAD_Non_Returnable_Flag__c);
                priceAdjustmentAppliedBoolean.put(o.Product2Id,o.LAD_Is_Price_Adjustment_Applied__c);

            }

            for(CartItem i:fetchCartItems){
                i.cartdeliverygroupid = cartdeliverygrpname_product.get(product_DeliveryGroup.get(i.product2id).orderDeliveryGroupName);
                i.LAD_PO_Number__c=product_DeliveryGroup.get(i.product2id).orderItemPoNumber;
                i.LAD_Non_Returnable__c = nonReturnableCheck.get(i.product2id);
                i.LAD_Is_Price_Adjustment_Applied__c= priceAdjustmentAppliedBoolean.get(i.product2id);
            }
            update fetchCartItems;
        }

        return fetchCartItems;
    }
    
    /**@MethodName :    setCartDeliveryGroup
    * @description :    This method creates Cart Delivery Groups from Order Delivery Groups.
    * @param:           string cartid,Order orderDetail
    * @return:          List<cartDeliveryGroup>
    */
    public static List<cartDeliveryGroup> setCartDeliveryGroup(string cartid,Order orderDetail){
            
        List<cartDeliveryGroup> cartDeliveryGrpList=new List<cartDeliveryGroup>();
        for(OrderDeliveryGroup i:orderDetail.OrderDeliveryGroups){
            
            cartDeliveryGrpList.add(new cartDeliveryGroup(
                name=i.LAD_Name__c,
                DeliverToStreet=i.DeliverToStreet,
                DeliverToCity=i.DeliverToCity,
                DeliverToState=i.DeliverToState,
                DeliverToPostalCode=i.DeliverToPostalCode,
                DeliverToCountry=i.DeliverToCountry,
                DeliveryMethodId=i.OrderDeliveryMethodId,
                DesiredDeliveryDate=i.DesiredDeliveryDate,
                LAD_Date_Selected_By_Customer__c = i.LAD_Date_Selected_By_Customer__c,
                CartId=cartid,
                LAD_Address_Key__c=i.LAD_Name__c=='Laddaw Shipping'?null:i.LAD_Name__c.split('-')[2]
            ));
            
        }
        insert cartDeliveryGrpList;

		return cartDeliveryGrpList;
            
        
    }
    
    public class orderItemDetails{
       @auraenabled  public string orderDeliveryGroupName {get;set;}
       @auraenabled  public string orderItemPoNumber {get;set;}

    }


    //CHECKOUT SEGMENT

    /**@MethodName :    orderAmendmentViability
    * @description :    This method checks if the Order is open to Amending.
    * @param:           Id orderId
    * @return:          Boolean
    */
    @AuraEnabled
    public static Boolean orderAmendmentViability(Id orderId){
        try {
            for(OrderItemSummary itemSummary : [SELECT LAD_Status__c  FROM OrderItemSummary WHERE OrderSummaryId = :orderId]){
                if(!system.label.LAD_AmendorderViableList.contains(itemSummary.LAD_Status__c) ){return false;}
            }
            return true;
        } catch (Exception e) {BLN_ExceptionLogger.captureException(e);return false;}
    }

    /**@MethodName :    orderAmendmentViabilityDetailsPage
    * @description :    This method checks if the Order is open to Amending on Order Details Page.
    * @param:           Id orderId
    * @return:          Boolean
    */
    @AuraEnabled
    public static Boolean orderAmendmentViabilityDetailsPage(string orderSummaryId){
          try {
        string contactId=[select contactId from user where id=:Userinfo.getUserId()].contactId;
        boolean isRole=false;
        List<String> possibleValues = new List<String>{
            'Wholesale Manager',
            'Hub Manager',
            'Hub Team User'
        };
        if(contactId!=null){
            Contact i=[select LAD_Role__c from contact where id=:contactId];
            if(possibleValues.contains(i.LAD_Role__c)){isRole=true;}
        }
        List<PermissionSetAssignment> lstcurrentUserPerSet =    [   SELECT Id, PermissionSet.Name,AssigneeId
                                                                FROM PermissionSetAssignment
                                                                WHERE AssigneeId = :Userinfo.getUserId() and (PermissionSet.Name ='Laddaw_Internal_Portal_User_Object_Access' or PermissionSetGroup.developername='Laddaw_Internal_Portal_User')];
		boolean isInternalUser=lstcurrentUserPerSet.size()>0?true:false;
		
        boolean isSpecialOrder=[select LAD_Special_Order__c from OrderSummary where id=:orderSummaryId].LAD_Special_Order__c;
        
      
            for(OrderItemSummary itemSummary : [SELECT LAD_Status__c  FROM OrderItemSummary WHERE OrderSummaryId = :orderSummaryId]){
                if(!system.label.LAD_AmendorderViableList.contains(itemSummary.LAD_Status__c)){return false;}
            }
              system.debug(isSpecialOrder+'-'+isRole);
            return isSpecialOrder==true?isInternalUser & isRole:true;
        } catch (Exception e) {
            // Handling the exceptions and log an error message
            BLN_ExceptionLogger.captureException(e);return false;
        }
    }
    
   
    /**@MethodName :    fetchExistingOrderDetails
    * @description :    This method fetches existing Order details from Cart.
    * @param:           Id cartId
    * @return:          List<OrderItem>
    */
    @AuraEnabled
    public static List<OrderItem> fetchExistingOrderDetails(Id cartId){
        try {
            //Fetch 
            Id orderId = [SELECT LAD_Order__c FROM WebCart WHERE Id = :cartId].LAD_Order__c;
            List<OrderItem> orderProducts = [SELECT Id, 
                                                    Product2Id,
                                                    Quantity,
                                                    OrderDeliveryGroupId,
                                                    OrderDeliveryGroup.LAD_Name__c,
                                                    OrderDeliveryGroup.DeliverToStreet,
                                                    OrderDeliveryGroup.DeliverToCity,
                                                    OrderDeliveryGroup.DeliverToState,
                                                    OrderDeliveryGroup.DeliverToPostalCode,
                                                    OrderDeliveryGroup.DeliverToCountry,
                                                    OrderDeliveryGroup.DesiredDeliveryDate,
                                                    OrderDeliveryGroup.OrderDeliveryMethodId,
                                                    OrderDeliveryGroup.OrderDeliveryMethod.Name
                                            FROM OrderItem
                                            WHERE OrderId = :orderId];
            
            return orderProducts;
        } catch (Exception e) {
            // Handling the exceptions and log an error message
            BLN_ExceptionLogger.captureException(e);return null;
        }
    }


    /**@MethodName :    processAmendOrder
    * @description :    This method updates the existing order from the details extracted from the cart.
    * @param:           string cartId, String comment
    * @return:          OrderSummaryWrapper
    */
    @AuraEnabled
    public static OrderSummaryWrapper processAmendOrder(string cartId, String comment){
        try {
            WebCart activeCart;
            Id accountId;
            Id standardPriceBook;
            String currencyCode;
           // Map<id,id> productIdPricebookEntryIdMap = new Map<id,id>(); 
            Map<Id, String> productIdCartDelGrpNameMap = new Map<Id, String>();
            Set<String> cartDelGrpNames = new Set<String>();

            activeCart = [  SELECT  Id, 
                                    Name, 
                                    AccountId,
                                    Status,
                                    WebStoreId,
                                    PoNumber,
                                    LAD_Created_by_Upload__c,
                                    LAD_Order__c,
                                    CreatedById,
                                    OwnerId,
                            		LAD_Special_Order_Cart__c,
                          			LAD_Special_Order_Number__c ,
                                    (SELECT Id, 
                                            Name, 
                                            CartId, 
                                            CartDeliveryGroupId,
                                            CartDeliveryGroup.Name,
                                            CartDeliveryGroup.DeliverToStreet,
                                            CartDeliveryGroup.DeliverToCity,
                                            CartDeliveryGroup.DeliverToState,
                                            CartDeliveryGroup.DeliverToPostalCode,
                                            CartDeliveryGroup.DeliverToCountry,
                                            CartDeliveryGroup.DeliveryMethodId,
                                            CartDeliveryGroup.DesiredDeliveryDate,
                                            CartDeliveryGroup.LAD_Date_Selected_By_Customer__c, //FOUK-9758 & FOUK-9759
                                            CartDeliveryGroup.LAD_Deliver_to_Location__c, //FOUK-10272
                                            Product2Id,
                                            Product2.Name, 
                                            UnitAdjustedPrice, 
                                            TotalLineTaxAmount, 
                                            Quantity, 
                                            TotalLineNetAmount, 
                                            TotalLineGrossAmount,
                                            CurrencyIsoCode,
                                            LAD_PO_Number__c
                                    FROM CartItems),
                                    (SELECT Name, 
                                            Amount,
                                            TaxRate,
                                            TaxType,
                                            TaxCalculationDate,
                                            CartItem.Product2Id 
                                    FROM CartItemTaxes)
                            FROM WebCart
                            WHERE Id = :cartId
                            LIMIT 1];
            accountId = activeCart.AccountId;
            Order existingOrder = [SELECT Status, EffectiveDate, Description FROM Order WHERE Id = :activeCart.LAD_Order__c];

            if(!Test.isRunningTest()){existingOrder.OwnerId = activeCart.OwnerId;update existingOrder;OrderSummary orderSum = [SELECT Id FROM OrderSummary WHERE OriginalOrderId = :existingOrder.Id];Database.delete(orderSum.Id);}
            // existingOrder.SalesStoreId = activeCart.WebStoreId;
            // existingOrder.AccountId = accountId;
            existingOrder.Status = 'Draft';
            existingOrder.LAD_Created_by_Upload__c = activeCart.LAD_Created_by_Upload__c;
            currencyCode = activeCart.CartItems[0].CurrencyIsoCode;

            for(CartItem item: activeCart.CartItems){
                
                productIdCartDelGrpNameMap.put(item.Product2Id, item.CartDeliveryGroup.Name);
                cartDelGrpNames.add(item.CartDeliveryGroup.Name);
            }

         /*    for(PricebookEntry entry : [SELECT Id, Name, Product2Id, pricebook2Id, CurrencyIsoCode FROM PricebookEntry where pricebook2.isStandard = true AND Product2Id IN :productIdList AND CurrencyIsoCode = :currencyCode]){
                productIdPricebookEntryIdMap.put(entry.Product2Id, entry.Id);
                standardPriceBook = entry.pricebook2Id;
            }
 */
            //Update Order
            // existingOrder.Pricebook2Id = standardPriceBook;
            existingOrder.PoNumber = activeCart.PoNumber;
            //existingOrder.EffectiveDate = Date.today();
            existingOrder.Description = comment;
            System.debug(existingOrder.description);
            update existingOrder;

            //Create List of OrderDeliveryGroups to be deleted and Map of the ones to be upserted
            Map<String, OrderDeliveryGroup> oldOrderDelGrpNameMap = new Map<String, OrderDeliveryGroup>();
            List<OrderDeliveryGroup> deleteOrderDelGrpList = new List<OrderDeliveryGroup>();
            
           for (OrderDeliveryGroup grp : [  SELECT  LAD_Name__c,
                                                    DeliverToStreet,
                                                    DeliverToCity,
                                                    DeliverToState,
                                                    DeliverToPostalCode,
                                                    DeliverToCountry,
                                                    DesiredDeliveryDate,
                                                    OrderDeliveryMethodId,
                                                    OrderDeliveryMethod.Name
                                            FROM OrderDeliveryGroup
                                            WHERE OrderId = :existingOrder.Id]){
                
                if(!cartDelGrpNames.contains(grp.LAD_Name__c)){
                    deleteOrderDelGrpList.add(grp);
                }
                else{ oldOrderDelGrpNameMap.put(grp.LAD_Name__c, grp);}
            }
                           
            //Create List of OrderItems to be deleted and Map of the ones to be upserted
            Map<Id, OrderItem> oldOrderProdIdItemMap = new Map<Id, OrderItem>();            
            List<OrderItem> deleteOrderItemList = new List<OrderItem>();
            for(OrderItem item : [  SELECT  Quantity,
                                            Product2Id,
                                            OrderDeliveryGroupId,
                                            LAD_PO_Number__c
                                    FROM OrderItem
                                    WHERE OrderId = :existingOrder.Id]){
                
                if(!productIdCartDelGrpNameMap.containsKey(item.Product2Id)){deleteOrderItemList.add(item);}
                else{
                    oldOrderProdIdItemMap.put(item.Product2Id, item);

                }
            }

            

            Map<String, OrderDeliveryGroup> upsertDelGrpNameRecordMap = new Map<String, OrderDeliveryGroup>();
            for(CartItem item : activeCart.CartItems){
                if(!upsertDelGrpNameRecordMap.containsKey(item.CartDeliveryGroup.Name)){
                    OrderDeliveryGroup ordDelGrp = new OrderDeliveryGroup();
                    if(oldOrderDelGrpNameMap.containsKey(item.CartDeliveryGroup.Name)){ordDelGrp.Id = oldOrderDelGrpNameMap.get(item.CartDeliveryGroup.Name).Id;}
                    else{ordDelGrp.OrderId = existingOrder.id; }
                    ordDelGrp.LAD_Name__c = item.CartDeliveryGroup.name;
                    ordDelGrp.DeliverToStreet = item.CartDeliveryGroup.DeliverToStreet;
                    ordDelGrp.DeliverToCity = item.CartDeliveryGroup.DeliverToCity;
                    ordDelGrp.DeliverToState = item.CartDeliveryGroup.DeliverToState;
                    ordDelGrp.DeliverToPostalCode = item.CartDeliveryGroup.DeliverToPostalCode;
                    ordDelGrp.DeliverToCountry = item.CartDeliveryGroup.DeliverToCountry;
                    ordDelGrp.DeliverToName = UserInfo.getName();
                    ordDelGrp.OrderDeliveryMethodId = item.CartDeliveryGroup.DeliveryMethodId;
                    ordDelGrp.DesiredDeliveryDate = item.CartDeliveryGroup.DesiredDeliveryDate?.Date();
                    ordDelGrp.LAD_Date_Selected_By_Customer__c = item.CartDeliveryGroup.LAD_Date_Selected_By_Customer__c; //FOUK-9758 & FOUK-9759
                    ordDelGrp.LAD_Deliver_to_Location__c = item.CartDeliveryGroup.LAD_Deliver_to_Location__c; //FOUK-10272

                    //Add to Map to upsert
                    upsertDelGrpNameRecordMap.put(item.CartDeliveryGroup.Name, ordDelGrp);
                }
            }

            Database.delete(deleteOrderDelGrpList, true);

            Database.UpsertResult[] upsertDelGrpResults = Database.upsert(upsertDelGrpNameRecordMap.values(), true);
            Set<Id> ordDelGrpIdSet = new Set<Id>();
            for(Database.UpsertResult sr : upsertDelGrpResults){
                ordDelGrpIdSet.add(sr.getId());
            }

            Map<String, Id> orderDelGrpNameIdMap = new Map<String, Id>();
            for(OrderDeliveryGroup ord : [SELECT LAD_Name__c FROM OrderDeliveryGroup WHERE Id IN :ordDelGrpIdSet]){
                orderDelGrpNameIdMap.put(ord.LAD_Name__c, ord.id);
            }


            //Creating all Order Products from Cart Items and using orderDelGrpNameIdMap to assign delivery groups
            List<OrderItem> orderItemList = new List<OrderItem>();
            for(CartItem item: activeCart.CartItems){
                OrderItem newItem = new OrderItem();
                if(oldOrderProdIdItemMap.containsKey(item.Product2Id)){
                    newItem.Id = oldOrderProdIdItemMap.get(item.Product2Id).Id;
                }
                else{newItem.orderId = existingOrder.id;newItem.Product2Id = item.Product2Id;}   
                newItem.Quantity = item.Quantity;
                newItem.UnitPrice = item.UnitAdjustedPrice;
                //newItem.PriceBookEntryId = productIdPricebookEntryIdMap.get(item.Product2Id);
                newItem.OrderDeliveryGroupId = orderDelGrpNameIdMap.get(item.CartDeliveryGroup.name);
                newItem.TotalLineAmount = item.TotalLineNetAmount;
                newItem.LAD_PO_Number__c = item.LAD_PO_Number__c;
                newItem.Type = 'Order Product';
                orderItemList.add(newItem);                
            }

            Database.delete(deleteOrderItemList, true);

            Database.UpsertResult[] orderItemResultList = Database.upsert(orderItemList, true);
            Set<Id> orderItemIdSet = new Set<Id>();
            for(Database.UpsertResult sr : orderItemResultList){
                orderItemIdSet.add(sr.getId());
            }

            Map<id,id> productIdOrderItemIdMap = new Map<id,id>();
            for(OrderItem ord : [SELECT Product2Id FROM OrderItem WHERE Id IN :orderItemIdSet]){
                productIdOrderItemIdMap.put(ord.Product2Id, ord.id);
            }


            //Delete all tax records
            Database.delete([SELECT Id FROM OrderItemTaxLineItem WHERE OrderItemId IN :orderItemIdSet], true);
                            
            List<OrderItemTaxLineItem> orderItemTaxList = new List<OrderItemTaxLineItem>();
            //Creating all Order tax Line Items from Cart Taxes and using productIdOrderItemIdMap to assign Order Products
            if(activeCart.CartItemTaxes.size() > 0){
                for(CartTax cartTax : activeCart.CartItemTaxes){
                    OrderItemTaxLineItem orderProductTax = new OrderItemTaxLineItem();
                    orderProductTax.name = cartTax.name;orderProductTax.Amount = cartTax.Amount; orderProductTax.OrderItemId = productIdOrderItemIdMap.get(cartTax.CartItem.Product2Id);orderProductTax.TaxeffectiveDate = cartTax.TaxCalculationDate;orderProductTax.Type = cartTax.TaxType;orderItemTaxList.add(orderProductTax);
                }

                Database.SaveResult[] orderItemTaxResultList = Database.insert(orderItemTaxList, true);
            }
 
            existingOrder.Status = 'Activated';
            //existingOrder.OrderedDate = Datetime.now();
            update existingOrder;

            ConnectApi.OrderSummaryInputRepresentation osir = new ConnectApi.OrderSummaryInputRepresentation();
            osir.orderId=existingOrder.id; 
            ConnectApi.OrderSummaryOutputRepresentation osor = ConnectApi.OrderSummaryCreation.createOrderSummary(osir);
            activeCart.status = System.Label.LAD_LocationCheckPDP_CartStatus_Closed;
            update activeCart;

            OrderSummaryWrapper successOrder = new OrderSummaryWrapper();
            successOrder.status = 'Success';
            successOrder.message = System.Label.LAD_SubmitOrderButton_OrderSuccessMessage;
            OrderSummary orderSummary = [SELECT Status, OrderNumber FROM OrderSummary WHERE Id = :osor.orderSummaryId];
            orderSummary.status = 'Amended';orderSummary.LAD_Special_Order__c=activeCart.LAD_Special_Order_Cart__c;orderSummary.LAD_Special_Order_Number__c=activecart.LAD_Special_Order_Number__c;
            
            update orderSummary;

            List<OrderItemSummary> itemSummaryList = new List<OrderItemSummary>();
            for(OrderItemSummary itemSummary : [SELECT LAD_Status__c  FROM OrderItemSummary WHERE OrderSummaryId = :orderSummary.Id]){
                itemSummary.LAD_Status__c  = 'Amended';
                itemSummaryList.add(itemSummary);
            }

            update itemSummaryList;
            
            successOrder.orderNumber = orderSummary.OrderNumber;
            system.debug(successOrder);
            return successOrder;

        } catch (Exception e) {
            // Handling the exceptions and log an error message
            BLN_ExceptionLogger.captureException(e);OrderSummaryWrapper failedOrder = new OrderSummaryWrapper(); failedOrder.status = 'Error';failedOrder.message = e.getMessage();return failedOrder;
        }
       
    }
    
    public class OrderSummaryWrapper{
        @auraenabled public String status {get; set;}
        @auraenabled public String orderNumber {get; set;}
        @auraenabled public String message {get; set;}

    }
    
}