public with sharing class BLN_CreditAndRebillController {

    @AuraEnabled
    public static void createOrderAndOrderItemsAfterRebill(String mainJson,String existingOrderItemData,String quoteId,String locationId){

        List<BLN_ProductAvailabilityWrapper.LineItemIdentifier> existingOrderItems = new List<BLN_ProductAvailabilityWrapper.LineItemIdentifier>();
        existingOrderItems = (List<BLN_ProductAvailabilityWrapper.LineItemIdentifier>) JSON.deserialize(existingOrderItemData,List<BLN_ProductAvailabilityWrapper.LineItemIdentifier>.class);
        Order ord = [SELECT Id,BLN_CPQExternalQuoteId__c,BLN_Case__c,BLN_Case__r.AccountId,Status FROM Order WHERE BLN_CPQExternalQuoteId__c = :quoteId WITH SECURITY_ENFORCED ORDER BY createdDate DESC LIMIT 1 ];
        
        Case caseRecord = [SELECT Id,AccountId,CurrencyIsoCode FROM Case WHERE Id = :ord.BLN_Case__c WITH SECURITY_ENFORCED]; 
        
        BLN_ProductResponseWrapper.ResponseProduct mainData = (BLN_ProductResponseWrapper.ResponseProduct) JSON.deserialize(mainJson,BLN_ProductResponseWrapper.ResponseProduct.class);
        Map<Order,List<OrderItem>> orderVsOrderItemListMap = new Map<Order,List<OrderItem>>();
        // List<BLN_ProductAvailabilityWrapper.ProductSelectionWrapper> selectedProdsData = (List<BLN_ProductAvailabilityWrapper.ProductSelectionWrapper>) JSON.deserialize(selectedProducts, List<BLN_ProductAvailabilityWrapper.ProductSelectionWrapper>.class);
		// List<BLN_ProductAvailabilityWrapper.ProductSelectionWrapper> selectedAddonProdsData = (List<BLN_ProductAvailabilityWrapper.ProductSelectionWrapper>) JSON.deserialize(selectedAddonProducts, List<BLN_ProductAvailabilityWrapper.ProductSelectionWrapper>.class);        
        Map<OrderItem,String> orderItemWithPartNumberMap = new Map<OrderItem,String>();

        for(BLN_ProductResponseWrapper.ResponseQuotes quoteVar : mainData.quotes){
            if(quoteVar.locationId == locationId){
                
                // Response property value mapping to Order & OrderItem fields to be done in BLN_QuoteBookingHandler.getOrderDataMappingFromQuoteResponse()
                Map<Order,List<OrderItem>> quoteVarOrderVsOrderItem = BLN_QuoteBookingHandler.getOrderDataMappingFromQuoteResponse(quoteVar);
                
                Map<Integer,OrderItem> lineItemIdVsOrderItemMap = new Map<Integer,OrderItem>();
                Order orderRecord = new List<Order>(quoteVarOrderVsOrderItem.keySet())[0];
                for(OrderItem ordrItm : quoteVarOrderVsOrderItem.get(orderRecord)){
                    lineItemIdVsOrderItemMap.put(Integer.valueOf(ordrItm.BLN_DocumentNumber__c),ordrItm);
                }
                
                // Lookup and non-consistent/dynamic field mapping on Order to be done here
                orderRecord.BLN_Case__c	= caseRecord.Id;
                orderRecord.BLN_ServiceTerritory__r  = new ServiceTerritory(BLN_GUID__c = quoteVar.locationId);
                orderRecord.AccountId = caseRecord.AccountId;
                orderRecord.EffectiveDate = System.today();
                orderRecord.Status = System.label.BLN_Accepted;
                
                List<OrderItem> orderItemList = new List<OrderItem>();
                for(BLN_ProductResponseWrapper.ResponseLineItems lineItem : quoteVar.lineItems){
                    // Lookup and non-consistent/dynamic field mapping on OrderItems to be done here
                    OrderItem ordrItm = lineItemIdVsOrderItemMap.get(lineItem.lineItemId);
                    
                    for(BLN_ProductAvailabilityWrapper.LineItemIdentifier oi : existingOrderItems){
                        if(oi.partNumber == (lineItem.partNumber == null ? '' : lineItem.partNumber) && oi.bomId == (lineItem.parentBOMId == null ? '' : lineItem.parentBOMId) && oi.bundleName == (lineItem.bundleName == null ? '' : lineItem.bundleName)){
                            ordrItm.BLN_ServiceAppointment__c = oi.serviceAppointment;
                            ordrItm.BLN_FittingLocation__c = oi.fittingLocation;
                            ordrItm.BLN_StockLocation__c = oi.stockLocation;
                        }
                    }
                    orderItemWithPartNumberMap.put(ordrItm,lineItem.partNumber);
                    orderItemList.add(ordrItm);
                }
                orderVsOrderItemListMap.put(orderRecord,orderItemList);
            }
        }

        Map<String,Product2> productIdVsMDMIdMap = new Map<String,Product2>();
        List<Product2> relatedProductList = new List<Product2>();
        relatedProductList = [SELECT Id, Name, BLN_MDMID__c FROM Product2 WHERE IsActive = true AND BLN_MDMID__c IN :orderItemWithPartNumberMap.values() WITH SECURITY_ENFORCED LIMIT 10000];
        for(Product2 prod : relatedProductList) {
            productIdVsMDMIdMap.put(prod.BLN_MDMID__c,prod);  
        }

        Map<String,PricebookEntry> productMdmIdVsPriceBookEntryMap = new Map<String,PricebookEntry>();
        List<PricebookEntry> relatedPriceEntryList = new List<PricebookEntry>();        
        relatedPriceEntryList = [SELECT Id, Pricebook2Id, Product2.BLN_MDMID__c,CurrencyIsoCode,UnitPrice,IsActive FROM PricebookEntry WHERE IsActive = true AND Pricebook2.IsActive = true AND Pricebook2.IsStandard = true AND CurrencyIsoCode = :caseRecord.CurrencyIsoCode AND Product2.BLN_MDMID__c IN :orderItemWithPartNumberMap.values() WITH SECURITY_ENFORCED LIMIT 10000];
        for(PricebookEntry pricebookEntryRecord : relatedPriceEntryList) {
            productMdmIdVsPriceBookEntryMap.put(pricebookEntryRecord.Product2.BLN_MDMID__c,pricebookEntryRecord);
        }

        List<OrderItem> orderItemsWithPricebookData = new List<OrderItem>();

        List<Order> orderList = new List<Order>();
        if(!orderVsOrderItemListMap.isEmpty()) {
            for(Order order1 : orderVsOrderItemListMap.keySet()){            
                for(OrderItem orderItem1 : orderVsOrderItemListMap.get(order1)) {
                    OrderItem clonedOrderItem = orderItem1.clone(false,true,true,true);
                    if(productMdmIdVsPriceBookEntryMap.containsKey(orderItemWithPartNumberMap.get(orderItem1))){
                        clonedOrderItem.PricebookEntryId = productMdmIdVsPriceBookEntryMap.get(orderItemWithPartNumberMap.get(orderItem1))?.Id;
                        clonedOrderItem.ListPrice = productMdmIdVsPriceBookEntryMap.get(orderItemWithPartNumberMap.get(orderItem1))?.UnitPrice;
                        order1.Pricebook2Id = productMdmIdVsPriceBookEntryMap.get(orderItemWithPartNumberMap.get(orderItem1))?.Pricebook2Id;
                        clonedOrderItem.Product2 = productIdVsMDMIdMap.get(orderItemWithPartNumberMap.get(orderItem1));
                        orderItemWithPartNumberMap.put(clonedOrderItem,orderItemWithPartNumberMap.get(orderItem1));
                        orderItemsWithPricebookData.add(clonedOrderItem);
                    }                  
                    orderItemWithPartNumberMap.remove(orderItem1);
                }
                orderList.add(order1);
            }
        }
        
        if(Schema.sObjectType.Order.isCreateable()){
            insert orderList;
        }
        if(Schema.sObjectType.OrderItem.isCreateable()){
            insert orderItemsWithPricebookData;
        }
        
       
        //Database.SaveResult[] orderSaveResult = Database.insert(orderList,true); 
       // Database.SaveResult[] orderItemSaveResult = Database.insert(orderItemsWithPricebookData,true); 

        ord.Status = System.label.BLN_Inactive;
        if(Schema.sObjectType.Order.isUpdateable()){
            Update ord;
        }
        caseRecord.BLN_TotalAccountLiability__c = orderList[0].BLN_TotalIncludingTaxTrade__c;
        caseRecord.BLN_TotalMotoristLiability__c =  orderList[0].BLN_TotalIncludingTaxMotorist__c;
        caseRecord.BLN_TotalInsuranceLiability__c = orderList[0].BLN_TotalIncludingTaxInsuranceCompany__c;
        if(Schema.sObjectType.Case.isUpdateable()){
            Update caseRecord;
        }
    }

    @AuraEnabled
    public static String makeQuoteCalloutWithSpecificOrderLocation(String cpqExternalId){
        Order ord = [SELECT Id,BLN_Case__c,BLN_ServiceTerritory__r.BLN_GUID__c,BLN_ServiceTerritory__r.BLN_OrgCodeLocation__c,BLN_ServiceTerritory__r.BLN_CostCenter__c,BLN_ServiceTerritory__r.BLN_Type__c,BLN_CPQExternalQuoteId__c FROM Order WHERE BLN_CPQExternalQuoteId__c = :cpqExternalId WITH SECURITY_ENFORCED LIMIT 1];
        Case motoCase = BLN_QuoteBookingHandler.getCaseForQuoteCallout(ord.BLN_Case__c);//BLN_ProductAvailability.getCaseForQuoteCallout(ord.BLN_Case__c);

        BLN_ProductAvailabilityWrapper.LocationWrapper locWrapper = new BLN_ProductAvailabilityWrapper.LocationWrapper();
        //Schema.Location loc = [SELECT Id, BLN_OrgCodeLocation__c, BLN_GUID__c FROM Location WHERE BLN_GUID__c = :ord.BLN_ServiceTerritory__r.BLN_GUID__c WITH SECURITY_ENFORCED];
        locWrapper.costCenterId = ord.BLN_ServiceTerritory__r.BLN_OrgCodeLocation__c != null ? ord.BLN_ServiceTerritory__r.BLN_OrgCodeLocation__c : ''; //ord.BLN_ServiceTerritory__r.BLN_CostCenter__c;
        locWrapper.locationId = ord.BLN_ServiceTerritory__r.BLN_GUID__c;
        locWrapper.mobileLocationIndicator = ord.BLN_ServiceTerritory__r.BLN_Type__c == 'Mobile' ? true : false;
        locWrapper.countryCode = 'GB';

        String payload  = BLN_QuoteBookingHandler.makeQuoteCallout(motoCase,new List<BLN_ProductAvailabilityWrapper.LocationWrapper>{locWrapper});

        return payload;
    }
}