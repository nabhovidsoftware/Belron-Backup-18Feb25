/** @description :  This apex class is used to handle return order functionality.
*   @Story :        FOUK-9948; FOUK-9903; FOUK-9893; FOUK-9259; FOUK-9256; FOUK-10184; FOUK-9897; FOUK-10185
*   @author:        (ashwin.r.raja@pwc.com (IN), manoj.varma.ummadisingu@pwc.com)
*   @CreatedDate:   30-09-2024
*/

public with sharing class LAD_ReturnOrderHandler {

    /**@MethodName :    getUserInfo
    * @description :    This method is to get the user info of the running user.
    * @param:           -- 
    * @return:          Map<String,String>
    * @author:			(ashwin.r.raja@pwc.com (IN))
    */

    @AuraEnabled
    public static Map<String,String> getUserInfo(Id userId, Id accountId){
        Map<String,String> result = new Map<String,String>();
        User u = [SELECT Id, FirstName, LastName, Phone, Email, Contact.LAD_Role__c FROM User WHERE Id=:userId];
        Account acc = [SELECT Id, Name FROM Account WHERE Id=:accountId];
        result.put('FirstName',u.FirstName);
        result.put('LastName',u.LastName);
        result.put('Email',u.Email);
        result.put('Phone',u.Phone);
        result.put('accountName',acc.Name);
        result.put('role',u.Contact.LAD_Role__c);
        return result;
    }

    /**@MethodName :    getOrderItems
    * @description :    This method is used to get the order and order item
                        details when return items button is clicked on portal
    * @param:           -- 
    * @return:          ReturnOrderWrapper
    * @author:			(ashwin.r.raja@pwc.com (IN))
    */
    @AuraEnabled
    public static ReturnOrderWrapper getOrderItems(Id orderId){
        List<ReturnOrderItemWrapper> result = new List<ReturnOrderItemWrapper>();
        ReturnOrderWrapper returnOrder = new ReturnOrderWrapper();
        Map<String, List<LAD_Assigned_Address__c>> addresses = new Map<String, List<LAD_Assigned_Address__c>>();
        List<LAD_Assigned_Address__c> laddawCollectAddresses = new List<LAD_Assigned_Address__c>();
        List<OrderItemSummary> orderItems = [SELECT Id, Product2.Name, OrderSummary.Status, LAD_ReturnableQuantity__c,
                                                        Product2Id, Quantity, OriginalOrderItemId, 
                                                        LAD_Is_Invoiced__c, LAD_Invoice__c, LAD_Invoice_Date__c,
                                                        OriginalOrderItem.OrderDeliveryGroupId, 
                                                        OriginalOrderItem.OrderDeliveryGroup.LAD_Deliver_to_Location__c,
                                                        OriginalOrderItem.OrderDeliveryGroup.LAD_Deliver_to_Location__r.VisitorAddressId, 
                                                        OrderSummary.OriginalOrder.AccountId, LAD_Non_Returnable_Flag__c 
                                                FROM OrderItemSummary 
                                                WHERE OrderSummaryId =:orderId];   
        Id accId = orderItems[0].OrderSummary.OriginalOrder.AccountId;

        for(OrderItemSummary o: orderItems){
            if(o.LAD_Is_Invoiced__c==true && o.LAD_Invoice__c!=null && o.LAD_ReturnableQuantity__c!=0 && o.LAD_Non_Returnable_Flag__c==false){    
                returnOrder.nonReturnable = false;
                break;
            }
            else{
                returnOrder.nonReturnable = true;
            }
        }

        if(returnOrder.nonReturnable==false){
           
            List<AssociatedLocation> address = [SELECT Id, LocationId, Location.VisitorAddressId, Type,
                                                        Location.VisitorAddress.street,Location.VisitorAddress.city, 
                                                        Location.VisitorAddress.state, Location.VisitorAddress.PostalCode, 
                                                        Location.VisitorAddress.Country, 
                                                        (SELECT Id, LAD_Address__c, LAD_Address__r.street,LAD_Address__r.city,
                                                                LAD_Address__r.state,LAD_Address__r.PostalCode,LAD_Address__r.Country 
                                                            FROM Assigned_Address__r)
                                                    FROM AssociatedLocation 
                                                    WHERE ParentRecordId=:accId] ;

            for(AssociatedLocation add: address){
                addresses.put(add.LocationId,add.Assigned_Address__r);
            }

            for(AssociatedLocation laddawCollect: address){
                if(laddawCollect.Type=='Ship To'){
                    laddawCollectAddresses = laddawCollect.Assigned_Address__r;
                }
            }
            
            Map<String, String> x = new Map<String,String>();

            for(LAD_Assigned_Address__c a : laddawCollectAddresses){
                String adr = a.LAD_Address__r.street+','+ a.LAD_Address__r.city +','+ 
                                     a.LAD_Address__r.state +','+ a.LAD_Address__r.PostalCode+','+
                                     a.LAD_Address__r.Country;

                String adrid = a.LAD_Address__c;
                x.put(adrid, adr);
            }
            returnOrder.laddawCollectAddress = x;

            for(OrderItemSummary o: orderItems){
                ReturnOrderItemWrapper temp = new ReturnOrderItemWrapper();
                List<LAD_Assigned_Address__c> tempDropOff = new List<LAD_Assigned_Address__c>();
                temp.Id = o.Id;
                temp.productName = o.Product2.Name;
                temp.productId = o.Product2Id;
                temp.quantity = o.Quantity;
                temp.quantityReturnable = o.LAD_ReturnableQuantity__c==null?o.Quantity:o.LAD_ReturnableQuantity__c;
                temp.quantityReturned = temp.quantityReturnable;
                temp.nonReturnable = o.LAD_Non_Returnable_Flag__c==true ? o.LAD_Non_Returnable_Flag__c : (o.LAD_Is_Invoiced__c==true && o.LAD_Invoice__c!=null) ? false : true;
                if(o.LAD_ReturnableQuantity__c==0){
                    temp.nonReturnable = true;
                }
                temp.invoiceDate = o.LAD_Invoice_Date__c;
                tempDropOff = addresses.get(o.OriginalOrderItem.OrderDeliveryGroup.LAD_Deliver_to_Location__c);
                Map<String, String> y = new Map<String,String>();
                if(tempDropOff!=null){
                    for(LAD_Assigned_Address__c a:tempDropOff){
                        String adr = a.LAD_Address__r.street+','+ a.LAD_Address__r.city +','+ 
                                     a.LAD_Address__r.state +','+ a.LAD_Address__r.PostalCode+','+
                                     a.LAD_Address__r.Country;

                        String adrid = a.LAD_Address__c;
                        y.put(adrid, adr);
                    }
                }
                temp.returnAddressList = y;
                result.add(temp);
            }
            returnOrder.returnOrderItems = result;
            return returnOrder;
        }
        else{
            return returnOrder;
        }
    }
    
    /**@MethodName :    checkReturnPeriod
    * @description :    This method is used to check whether the return date entered 
                        is beyond the return period described in the custom metadata 
                        LAD_Return_Period__mdt
    * @param:           -- 
    * @return:          List<dateValidateWrapper>
    * @author:			(ashwin.r.raja@pwc.com (IN))
    */

    @AuraEnabled
    public static List<dateValidateWrapper> checkReturnPeriod(List<dateValidateWrapper> dateList, Id orderId){
        try{
            Map<String, LAD_Return_Period__mdt> returnPeriod = LAD_Return_Period__mdt.getAll();
            for(dateValidateWrapper i:dateList){
                Decimal period = returnPeriod.get(i.returnReason).LAD_Return_Period__c;
                Decimal diff = i.invoiceDate.date().daysBetween(i.returnDate.date());
                if((i.returnDate>i.invoiceDate) && (i.returnDate.date()>system.today())){
                    if(period==0 || period == null){
                        i.validDate = 0;
                    }
                    else if(diff>period){
                        i.validDate = 1;
                    }
                    else{
                        i.validDate = 0;
                    }
                }
                else{
                    i.validDate = 2;
                }
            }
            return dateList;
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**@MethodName :    createReturnCase
    * @description :    This method is used to create case based on return reason
    * @param:           -- 
    * @return:          void
    * @author:			(ashwin.r.raja@pwc.com (IN))
    */

    @AuraEnabled
     public static void createReturnCase(Id accountId, List<ReturnOrderItemWrapper> caseDetails) {
        Map<String,String> caseMap = new Map<String,String>{
            'UK11'=>'DMR',
            'UK12'=>'Laddaw Warranty'
        };
        Account acc = [SELECT Id, Name FROM Account WHERE Id = :accountId LIMIT 1];
        RecordType caseRecord = [SELECT id FROM RecordType WHERE DeveloperName = 'LAD_Laddaw_Case'];
        List<Case> newCase = new List<Case>();
        Group hubTeamQueue = [SELECT Id FROM Group WHERE Name = 'Hub Team Queue' AND Type = 'Queue' LIMIT 1];
        if (acc != null) {
            for(ReturnOrderItemWrapper i:caseDetails){
                Case temp = new Case();
                temp.Subject = 'Return Case for ' + acc.Name;
                temp.RecordTypeId = caseRecord.Id;
                temp.Type = 'Return';
                temp.AccountId = acc.Id;
                temp.BLN_SubType__c = caseMap.get(i.returnReason);
                temp.OwnerId = hubTeamQueue.Id; 
                newCase.add(temp);
            }
            insert newCase;
            System.debug('Return Case created successfully for ' + acc.Name);

        } else {
            System.debug('Account with Id ' + accountId + ' not found.');
        }
    }


     /**@MethodName :   createReturnOrder
    * @description :    This method is used to create return order based on user inputs
    * @param:           -- 
    * @return:          void
    * @author:			(ashwin.r.raja@pwc.com (IN))
    */

    @AuraEnabled
    public static void createReturnOrder(ReturnOrderWrapper order){
            LAD_Return__c returnOrder = new LAD_Return__c();
            List<String> dropOffIds = new List<String>();
            List<String> collectionIds = new List<String>();
            Map<String, Address> dropOff = new Map<String, Address>();
            Map<String, Address> collection = new Map<String, Address>();
            List<ReturnOrderItemWrapper> dropOffItems = new List<ReturnOrderItemWrapper>();
            List<ReturnOrderItemWrapper> collectionItems = new List<ReturnOrderItemWrapper>();
            List<LAD_Return_Item__c> returnItems = new List<LAD_Return_Item__c>();
            List<Id> oisId = new List<Id>();
            
            //Id orderId = [SELECT Id, OriginalOrderId FROM OrderSummary WHERE Id=:order.orderId].OriginalOrderId;
            returnOrder.LAD_Account__c = order.accountId;
            //returnOrder.LAD_Original_Order__c = orderId;
            returnOrder.LAD_Original_Order_Summary__c = order.orderId;
            returnOrder.OwnerId = order.userId;
            insert returnOrder;
            
            for(ReturnOrderItemWrapper item: order.returnOrderItems){
                oisId.add(item.Id);
                if(item.returnMethod == 'Laddaw Collect'){
                    collectionItems.add(item);
                    collectionIds.add(item.returnAddress);
                }
                else{
                    dropOffItems.add(item);
                    dropOffIds.add(item.returnAddress);
                }
            }
            
            List<OrderItemSummary> ois = [SELECT Id, LAD_ReturnableQuantity__c FROM OrderItemSummary
                                          WHERE Id in :oisId];
            Map<Id,Decimal> oisMap = new Map<Id, Decimal>();
            for(OrderItemSummary i:ois){
                oisMap.put(i.Id, 0);
            }

            List<ContactPointAddress> dropOffAddress = [SELECT Id, Address FROM ContactPointAddress WHERE Id in :dropOffIds];
            List<ContactPointAddress> collectionAddress = [SELECT Id, Address FROM ContactPointAddress WHERE Id in :collectionIds];
            
            for(ContactPointAddress addr: dropOffAddress){
                dropOff.put(addr.Id, addr.Address);
            }

            for(ContactPointAddress addr: collectionAddress){
                collection.put(addr.Id, addr.Address);
            }

            for(ReturnOrderItemWrapper item: collectionItems){
                    LAD_Return_Item__c returnItem = new LAD_Return_Item__c();
                    oisMap.put(item.Id, item.quantityReturnable - item.quantityReturned);
                    returnItem.LAD_Original_Order_Summary_Product__c = item.Id;
                    returnItem.LAD_Product_Name__c = item.productId;
                    returnItem.LAD_Quantity_returned__c = item.quantityReturned;
                    returnItem.LAD_Quantity_ordered__c = item.quantity;
                    returnItem.LAD_Return_Date_and_Time__c = item.returnDate;
                    returnItem.LAD_Return_Method__c	= item.returnMethod;
                    returnItem.LAD_Return_Reason__c = item.returnReason;
                    returnItem.LAD_Return_Order__c = returnOrder.Id;
                    returnItem.LAD_Additional_Comments__c = item.returnComment;
                    if(item.returnOverrideReason!=null){
                        returnItem.LAD_ReturnOverrideReason__c = item.returnOverrideReason;
                    } 
                    // returnItem.LAD_Return_address__street__s = collection.get(item.returnAddress).street;
                    // returnItem.LAD_Return_address__city__s = collection.get(item.returnAddress).city;
                    //returnItem.LAD_Return_address__statecode__s = address[2];
                    //returnItem.LAD_Return_address__PostalCode__s = collection.get(item.returnAddress).PostalCode;
                    //returnItem.LAD_Return_address__CountryCode__s = collection.get(item.returnAddress).Country;
                    returnItem.LAD_ReturnAddress__c = collection.get(item.returnAddress).street+', '+collection.get(item.returnAddress).city+', '
                                                      +collection.get(item.returnAddress).PostalCode+', '+collection.get(item.returnAddress).Country;
                    returnItems.add(returnItem);
                }
            
            for(ReturnOrderItemWrapper item: dropOffItems){
                    LAD_Return_Item__c returnItem = new LAD_Return_Item__c();
                    oisMap.put(item.Id, item.quantity - item.quantityReturned);
                    returnItem.LAD_Original_Order_Summary_Product__c = item.Id;
                    returnItem.LAD_Product_Name__c = item.productId;
                    returnItem.LAD_Quantity_returned__c = item.quantityReturned;
                    returnItem.LAD_Quantity_ordered__c = item.quantity;
                    returnItem.LAD_Return_Date_and_Time__c = item.returnDate;
                    returnItem.LAD_Return_Method__c	= item.returnMethod;
                    returnItem.LAD_Return_Reason__c = item.returnReason;
                    returnItem.LAD_Additional_Comments__c = item.returnComment;
                    returnItem.LAD_Return_Order__c = returnOrder.Id; 
                    if(item.returnOverrideReason!=null){
                        returnItem.LAD_ReturnOverrideReason__c = item.returnOverrideReason;
                    } 
                    //returnItem.LAD_Return_address__street__s = dropOff.get(item.returnAddress).street;
                    //returnItem.LAD_Return_address__city__s = dropOff.get(item.returnAddress).city;
                    //returnItem.LAD_Return_address__statecode__s = address[2];
                    //returnItem.LAD_Return_address__PostalCode__s = dropOff.get(item.returnAddress).PostalCode;
                    //returnItem.LAD_Return_address__CountryCode__s = dropOff.get(item.returnAddress).Country;
                    returnItem.LAD_ReturnAddress__c = dropOff.get(item.returnAddress).street+', '+dropOff.get(item.returnAddress).city+', '
                                                      +dropOff.get(item.returnAddress).PostalCode+', '+dropOff.get(item.returnAddress).Country;
                    returnItems.add(returnItem);
                }
            insert returnItems;
            for(OrderItemSummary i:ois){
                i.LAD_ReturnableQuantity__c = oisMap.get(i.Id);
            }
            update ois;
    }


     /**@MethodName :    getReturnOrders
    * @description :    This method is to get Return orders for portal based on account/Original Order.
    * @param:           -- 
    * @return:          List<LAD_Return__c>
    * @author:			(manoj.varma.ummadisingu@pwc.com (IN))
    */
    @AuraEnabled(cacheable=true)
    public static List<ReturnOrdersWrapper> getReturnOrders(Id effectiveAccountId) {
        // Query to fetch return orders along with related Account and Order information
        
        List<LAD_Return__c> returnOrders = [
            SELECT Id, Name, LAD_Account__c, LAD_Account__r.Name, LAD_Original_Order_Summary__c,CreatedDate
            FROM LAD_Return__c WHERE LAD_Account__c =: effectiveAccountId ORDER BY CreatedDate DESC 
        ];
        
        List<ReturnOrdersWrapper> returnOrdersWrappers = new List<ReturnOrdersWrapper>();
        
        // Create wrapper for each record to simplify data handling
        for (LAD_Return__c ro : returnOrders) {
            returnOrdersWrappers.add(new ReturnOrdersWrapper(
                ro.Id, ro.Name, ro.LAD_Account__r != null ? ro.LAD_Account__r.Name : null, ro.LAD_Original_Order_Summary__c
            ));
        }
        
        return returnOrdersWrappers;
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String,String> returnDetail(Id recordId){
        try {
            LAD_Return__c r = [SELECT Id, Name, LAD_Account__r.Name, Owner.Name, CurrencyIsoCode, LAD_Status__c, 
                               LAD_Original_Order_Summary__r.OrderNumber, CreatedBy.Name 
                        FROM LAD_Return__c 
                        WHERE Id=:recordId];
            Map<String, String> result = new Map<String, String>();
            result.put('Name',r.Name);
            result.put('accountName',r.LAD_Account__r.Name);
            result.put('owner', r.Owner.Name);
            result.put('currency', r.CurrencyIsoCode);
            result.put('status',r.LAD_Status__c);
            result.put('orderSummary',r.LAD_Original_Order_Summary__r.OrderNumber);
            result.put('createdBy', r.createdby.name);
            return result;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<ReturnItemWrapper> getItemsByReturnOrder(Id returnOrderId) {
       List<LAD_Return_Item__c> returnItems =[SELECT Id, Name,LAD_Sales_Code__c, LAD_Quantity_ordered__c,LAD_Quantity_returned__c, LAD_Product_Name__r.Name 
            FROM LAD_Return_Item__c
            WHERE LAD_Return_Order__c = :returnOrderId
        ];
         // Use the wrapper to structure the data
        List<ReturnItemWrapper> returnItemWrappers = new List<ReturnItemWrapper>();
        for (LAD_Return_Item__c rI : returnItems) {
            returnItemWrappers.add(new ReturnItemWrapper(rI));
        }
        return returnItemWrappers;
    }
    
    // Wrapper class to structure the data
    public class ReturnOrdersWrapper {
        @AuraEnabled public String Id { get; set; }
        @AuraEnabled public String Name { get; set; }
        @AuraEnabled public String AccountName { get; set; }
        @AuraEnabled public String OriginalOrderNumber { get; set; }
        
        public ReturnOrdersWrapper(String id, String name, String accountName, String originalOrderNumber) {
            this.Id = id;
            this.Name = name;
            this.AccountName = accountName;
            this.OriginalOrderNumber = originalOrderNumber;
        }
    }
     // Wrapper class for return items
    public class ReturnItemWrapper {
        @AuraEnabled public String returnItemId;
        @AuraEnabled public String returnItemName;
        @AuraEnabled public Integer quantityordered;
        @AuraEnabled public Integer quantityreturned;
        @AuraEnabled public String productName;
        @AuraEnabled public String salescode;
        
        // Constructor to initialize the values
        public ReturnItemWrapper(LAD_Return_Item__c returnItem) {
            this.returnItemId = returnItem.Id;
            this.returnItemName = returnItem.Name;
            this.quantityordered = returnItem.LAD_Quantity_ordered__c != null ? returnItem.LAD_Quantity_ordered__c.intValue() : 0;
            this.quantityreturned = returnItem.LAD_Quantity_returned__c != null ? returnItem.LAD_Quantity_returned__c.intValue() : 0;
            this.productName = returnItem.LAD_Product_Name__c != null ? returnItem.LAD_Product_Name__r.Name : '';
            this.salescode = returnItem.LAD_Sales_Code__c != null ? returnItem.LAD_Sales_Code__c : '';
        }
    }

    public class ReturnOrderWrapper{
        @AuraEnabled public Boolean nonReturnable {get; set;}
        @AuraEnabled public String orderId {get; set;}
        @AuraEnabled public String userId {get; set;}
        @AuraEnabled public String accountId {get; set;}
        @AuraEnabled public Map<String, String> laddawCollectAddress {get; set;}
        @AuraEnabled public List<ReturnOrderItemWrapper> returnOrderItems {get; set;}
    }

    public class dateValidateWrapper{
        @Auraenabled public string returnReason {get; set;}
        @Auraenabled public Datetime returnDate {get; set;}
        @Auraenabled public string key {get; set;}
        @Auraenabled public Integer validDate {get; set;}
        @Auraenabled public Datetime invoiceDate {get; set;}
    }

    public class ReturnOrderItemWrapper{
        @AuraEnabled public String Id{get; set;}
        @AuraEnabled public String productName {get; set;}
        @AuraEnabled public String productId {get; set;}
        @AuraEnabled public String salesCode {get; set;}
        @AuraEnabled public String returnReason {get; set;}
        @AuraEnabled public Datetime returnDate {get; set;}
        @Auraenabled public Datetime invoiceDate {get; set;}
        @AuraEnabled public Decimal quantity {get; set;}
        @AuraEnabled public Decimal quantityReturnable {get; set;}
        @AuraEnabled public Decimal quantityReturned {get; set;}
        @AuraEnabled public String returnMethod {get; set;}
        @AuraEnabled public Boolean nonReturnable {get; set;}
        @AuraEnabled public string returnOverrideReason {get; set;}
        @AuraEnabled public string returnComment {get; set;}
        @AuraEnabled public Map<String, String> returnAddressList {get; set;}
        @AuraEnabled public Map<String, String> dropOffAddress {get; set;}
        @AuraEnabled public String returnAddress {get; set;}
    }

}