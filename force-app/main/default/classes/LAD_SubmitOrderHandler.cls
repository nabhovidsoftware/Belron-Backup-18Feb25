/** @description :  This apex class is used to handle Submit Order Functionality.
*   @Story :        
*   @author:        (binayak.debnath@pwc.com (IN))
*   @CreatedDate:   13-06-2024
*/
public with sharing class LAD_SubmitOrderHandler {

     /**@MethodName :   checkAccountViability
    * @description :    This method checks if the account is on hold or has exceeded buyer limits.
    * @param:           string userId
    * @return:          AccountWrapper
    */
    @auraenabled
    public static AccountWrapper checkAccountViability(string userId,string accountId){
        try {
             AccountWrapper successWrapper = new AccountWrapper();
            if(accountId==null || accountId==''){
                 User runUserAccountDetails = [SELECT Contact.Account.BLN_CreditHold__c, Contact.Account.LAD_Buyer_Credit_Exceeded__c FROM User WHERE Id = :userId];

                successWrapper.onHold = runUserAccountDetails.Contact.Account.BLN_CreditHold__c == 'Y' ? true : false;
                successWrapper.limitExceeded = runUserAccountDetails.Contact.Account.LAD_Buyer_Credit_Exceeded__c;
                successWrapper.status = 'Success';
            }else{
                Account accountDetails=[select BLN_CreditHold__c,LAD_Buyer_Credit_Exceeded__c from account where id=:accountId];
                 successWrapper.onHold = accountDetails.BLN_CreditHold__c == 'Y' ? true : false;
                successWrapper.limitExceeded = accountDetails.LAD_Buyer_Credit_Exceeded__c;
                successWrapper.status = 'Success';
            }
           

            return successWrapper;

        } catch (Exception e) {
             // Handling the exceptions and log an error message
             BLN_ExceptionLogger.captureException(e);
             AccountWrapper failedWrapper = new  AccountWrapper();
             failedWrapper.status = 'Error';
             failedWrapper.message = e.getMessage();
             return failedWrapper;
        }
    }
     /**@MethodName :   processOrderAndOrderSummaries
    * @description :    This method creates Order and related records as per Cart records and returns order number.
    * @param:           string cartId
    * @return:          OrderSummaryWrapper
    */
    @auraenabled
    public static OrderSummaryWrapper processOrderAndOrderSummaries(string cartId, String comment){
       
        try {
            WebCart activeCart;
            Id accountId;
            Id standardPriceBook;
            Order newOrder = new Order();
            List<Id> productIdList = new List<Id>();
            String currencyCode;
            Map<id,id> productIdPricebookEntryIdMap = new Map<id,id>(); 
            Map<id,id> productIdOrderItemIdMap = new Map<id,id>();
            Map<String, Id> orderDelGrpNameIdMap = new Map<String, Id>();
            Map<Id, Boolean> cartItemList = new Map<Id,Boolean>();  //FOUK-9948:for updation of non Returnable flag
            Map<Id, Boolean> priceAdjustmentAppliedBoolean = new Map<Id,Boolean>();  //FOUK-9948:checkbox at Cart item level indicating that a Price Adjustment has occurred for this Product in the Cart

            List<OrderDeliveryGroup> orderDelGrpList = new List<OrderDeliveryGroup>();
            List<OrderItem> orderItemList = new List<OrderItem>();
            List<OrderItemTaxLineItem> orderItemTaxList = new List<OrderItemTaxLineItem>();
            activeCart = [  SELECT  Id, 
                                    Name, 
                                    AccountId,
                                    Status,
                                    WebStoreId,
                                    PoNumber,
                                    LAD_Created_by_Upload__c,
                                    LAD_Special_Order_Cart__c ,
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
                                            LAD_PO_Number__c,
                                            LAD_Non_Returnable__c, //FOUK-9948
                                     		LAD_Is_Price_Adjustment_Applied__c
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
            newOrder.SalesStoreId = activeCart.WebStoreId;
            newOrder.AccountId = accountId;
            newOrder.Status = 'Draft';
            newOrder.PoNumber = activeCart.PoNumber;
            newOrder.LAD_Created_by_Upload__c = activeCart.LAD_Created_by_Upload__c;
            currencyCode = activeCart.CartItems[0].CurrencyIsoCode;

            //Create a List of Products to fetch Price Book and Price Book Entries for each product 
            for(CartItem item: activeCart.CartItems){
                productIdList.add(item.Product2Id);       
            }

            for(PricebookEntry entry : [SELECT Id, Name, Product2Id, pricebook2Id, CurrencyIsoCode FROM PricebookEntry where pricebook2.isStandard = true AND Product2Id IN :productIdList AND CurrencyIsoCode = :currencyCode]){
                productIdPricebookEntryIdMap.put(entry.Product2Id, entry.Id);
                standardPriceBook = entry.pricebook2Id;
            }

            //To create a map of product id and the non returnable field from cart items
            for(CartItem item: activeCart.CartItems){
                cartItemList.put(item.Product2Id, item.LAD_Non_Returnable__c);
                priceAdjustmentAppliedBoolean.put(item.Product2Id, item.LAD_Is_Price_Adjustment_Applied__c);
            }

            //Insert Order
            newOrder.Pricebook2Id = standardPriceBook;
            newOrder.EffectiveDate = Date.today();
            newOrder.Description = comment;
           //pt
            newOrder.type='Accepted';
            System.debug(newOrder.description);
            insert newOrder;

            //Create Order Delivery Groups for every Cart Delivery Group
            for(CartItem item: activeCart.CartItems){
                if(!orderDelGrpNameIdMap.containsKey(item.CartDeliveryGroup.Name)){
                    orderDelGrpNameIdMap.put(item.CartDeliveryGroup.Name, null);
                    OrderDeliveryGroup ordDelGrp = new OrderDeliveryGroup();
                    ordDelGrp.LAD_Name__c = item.CartDeliveryGroup.name;
                    ordDelGrp.DeliverToStreet = item.CartDeliveryGroup.DeliverToStreet;
                    ordDelGrp.DeliverToCity = item.CartDeliveryGroup.DeliverToCity;
                    ordDelGrp.DeliverToState = item.CartDeliveryGroup.DeliverToState;
                    ordDelGrp.DeliverToPostalCode = item.CartDeliveryGroup.DeliverToPostalCode;
                    ordDelGrp.DeliverToCountry = item.CartDeliveryGroup.DeliverToCountry;
                    ordDelGrp.DeliverToName = UserInfo.getName();
                    ordDelGrp.OrderId = newOrder.id;
                    ordDelGrp.OrderDeliveryMethodId = item.CartDeliveryGroup.DeliveryMethodId;
                    ordDelGrp.DesiredDeliveryDate = item.CartDeliveryGroup.DesiredDeliveryDate?.Date();
                    ordDelGrp.LAD_Date_Selected_By_Customer__c = item.CartDeliveryGroup.LAD_Date_Selected_By_Customer__c; //FOUK-9758 & FOUK-9759
                    ordDelGrp.LAD_Deliver_to_Location__c = item.CartDeliveryGroup.LAD_Deliver_to_Location__c; //FOUK-10272

                    orderDelGrpList.add(ordDelGrp);
                }               
            }

            //Insert all Order Delivery Groups and make a set of Ids to make a orderDelGrpNameIdMap of name to id. 
            //assign the delivery groups when creating Order Products using the orderDelGrpNameIdMap
            Database.SaveResult[] orderDelGrpResultList = Database.insert(orderDelGrpList, true);
            Set<Id> ordDelGrpIdSet = new Set<Id>();
            for(Database.SaveResult sr : orderDelGrpResultList){
                ordDelGrpIdSet.add(sr.getId());
            }

            for(OrderDeliveryGroup ord : [SELECT LAD_Name__c FROM OrderDeliveryGroup WHERE Id IN :ordDelGrpIdSet]){
                orderDelGrpNameIdMap.put(ord.LAD_Name__c, ord.id);
            }
            
            //Creating all Order Products from Cart Items and using orderDelGrpNameIdMap to assign delivery groups
            for(CartItem item: activeCart.CartItems){
                OrderItem newItem = new OrderItem();
                newItem.Quantity = item.Quantity;
                newItem.UnitPrice = item.UnitAdjustedPrice;
                newItem.Product2Id = item.Product2Id;
                newItem.orderId = newOrder.id;
                newItem.PriceBookEntryId = productIdPricebookEntryIdMap.get(item.Product2Id);
                newItem.OrderDeliveryGroupId = orderDelGrpNameIdMap.get(item.CartDeliveryGroup.name);
                newItem.TotalLineAmount = item.TotalLineNetAmount;
                newItem.LAD_PO_Number__c = item.LAD_PO_Number__c;
                newItem.Type = 'Order Product';
                orderItemList.add(newItem);                
            }

            //Insert all Order Products and create a set of Ids to create productIdOrderItemIdMap from Product Id to Order Product Id.
            //Use the mapn later to assign Order Products to Order Tax Line Items based on ProductId.
            Database.SaveResult[] orderItemResultList = Database.insert(orderItemList, true);
            Set<Id> orderItemIdSet = new Set<Id>();
            for(Database.SaveResult sr : orderItemResultList){
                orderItemIdSet.add(sr.getId());
            }

            for(OrderItem ord : [SELECT Product2Id FROM OrderItem WHERE Id IN :orderItemIdSet]){
                productIdOrderItemIdMap.put(ord.Product2Id, ord.id);
            }

            //Creating all Order tax Line Items from Cart Taxes and using productIdOrderItemIdMap to assign Order Products
            if(activeCart.CartItemTaxes.size() > 0){
                for(CartTax cartTax : activeCart.CartItemTaxes){
                    OrderItemTaxLineItem orderProductTax = new OrderItemTaxLineItem();
                    orderProductTax.name = cartTax.name;
                    orderProductTax.Amount = cartTax.Amount;
                    orderProductTax.OrderItemId = productIdOrderItemIdMap.get(cartTax.CartItem.Product2Id);
                    orderProductTax.TaxeffectiveDate = cartTax.TaxCalculationDate;
                    orderProductTax.Type = cartTax.TaxType;
                    orderItemTaxList.add(orderProductTax);
                }

                Database.SaveResult[] orderItemTaxResultList = Database.insert(orderItemTaxList, true);
            }
 
            newOrder.Status = 'Activated';
            newOrder.OrderedDate = Datetime.now();
            update newOrder;

            ConnectApi.OrderSummaryInputRepresentation osir = new ConnectApi.OrderSummaryInputRepresentation();
            osir.orderId=newOrder.id; 
          //    osir.orderLifeCycleType='Unmanaged';
            ConnectApi.OrderSummaryOutputRepresentation osor = ConnectApi.OrderSummaryCreation.createOrderSummary(osir);
            activeCart.status = System.Label.LAD_LocationCheckPDP_CartStatus_Closed;
            update activeCart;
            if(activeCart.LAD_Special_Order_Cart__c){
                integer countOfExistingSpecialOrder=[select count() from ordersummary where LAD_Special_Order__c=true];
                integer length= 6-string.valueof(countOfExistingSpecialOrder).length();
                string prefix='SO-';
                
                for(integer i=0;i<length;i++){
                    prefix=prefix+string.valueof(0);
                }
                string specialOrderNumber=prefix+string.valueof(countOfExistingSpecialOrder+1);
                system.debug(specialOrderNumber);
                OrderSummary orderSumm=new OrderSummary();
                orderSumm.id=osor.orderSummaryId;
                orderSumm.LAD_Special_Order__c=true;
                orderSumm.LAD_Special_Order_Number__c=specialOrderNumber;
                update orderSumm;
                
            }
          
            //To put the value of the non returnable flag in cart item on order product summary non returnable flag
            List<OrderItemSummary> prodList = [SELECT Id, Product2Id, LAD_Non_Returnable_Flag__c FROM OrderItemSummary WHERE OrderSummary.OriginalOrderId =:newOrder.Id];
            for(OrderItemSummary i: prodList){
                i.LAD_Non_Returnable_Flag__c = cartItemList.get(i.Product2Id);
                i.LAD_Is_Price_Adjustment_Applied__c=priceAdjustmentAppliedBoolean.get(i.Product2Id);
            }
            update prodList;

            OrderSummaryWrapper successOrder = new OrderSummaryWrapper();
            successOrder.status = 'Success';
            successOrder.message = System.Label.LAD_SubmitOrderButton_OrderSuccessMessage;
            successOrder.orderNumber = [SELECT OrderNumber FROM OrderSummary WHERE Id = :osor.orderSummaryId].OrderNumber;
            system.debug(successOrder);
            return successOrder;
            
        } catch (Exception e) {
            // Handling the exceptions and log an error message
            BLN_ExceptionLogger.captureException(e);
            OrderSummaryWrapper failedOrder = new OrderSummaryWrapper();
            failedOrder.status = 'Error';
            failedOrder.message = e.getMessage();
            return failedOrder;
        }
       
    }
    
    public class OrderSummaryWrapper{
        //status
        @auraenabled public String status {get; set;}
        //orderNumber
        @auraenabled public String orderNumber {get; set;}
        //message
        @auraenabled public String message {get; set;}

    }

    public class AccountWrapper{
        //onHold
        @auraenabled public boolean onHold {get; set;}
        //limitExceeded
        @auraenabled public boolean limitExceeded {get; set;}
        //status
        @auraenabled public String status {get; set;}
        //message
        @auraenabled public String message {get; set;}
    }
}