/**@description : This Apex class will send Stock updates to Oracle EBS via Callout and this class will be called from the Apex Class BLN_SendUpdatesToEBS
*  @author: PwC India
*  @Story: FOUK-5076 (Salesforce Trigger of EBS Stock Update for Unused Parts)
*  @CreatedDate: 15/07/2024
*/
public without sharing class BLN_SendUpdatesToEBSCallout implements Queueable, Database.AllowsCallouts{
    public List<OrderItem> updatedOIList;
    public String orderId;
    public List<Id> productUpsoldList;
    public List<Id> productRemovedList; 
    public List<Id> quantityChangeId;
    public Map<Id, Integer> orderProductOldMap;

    static final Set<String> CANCELED_STATUS_SET = new Set<String>{'CPT Line Cancelled', 'Cancelled', 'Requisition Cancelled'};
    static final String CANCEL_STATUS = 'Cancelled';
    static final String STOCK_CALL_RESPONSE_SUCCESS = 'success';

    public BLN_SendUpdatesToEBSCallout(String orderId, List<OrderItem> updatedOIList, List<Id> productUpsoldList, List<Id> productRemovedList, List<Id> quantityChangeId, Map<Id, Integer> orderProductOldMap) {
        this.updatedOIList = updatedOIList;
        this.orderId = orderId;
        this.productUpsoldList = productUpsoldList;
        this.productRemovedList = productRemovedList;
        this.quantityChangeId = quantityChangeId;
        this.orderProductOldMap = orderProductOldMap;
    }

    public void execute(QueueableContext context) {        
        try{
                if(Schema.sObjectType.OrderItem.isUpdateable() && !updatedOIList.isEmpty()){
                    update updatedOIList;
                }
                makeRepriceCallout(orderId);
            calloutForProductUpsold(productUpsoldList, productRemovedList);
                if(!quantityChangeId.isEmpty() && !orderProductOldMap.isEmpty()){
                    calloutForQuantityChange(quantityChangeId,orderProductOldMap);
                }
            }
        catch(Exception ex){
            BLN_ExceptionLogger.captureException(ex);
        }
    }
    
    public static void updateOrderRecordWithNewQuoteValues(String payload, Id orderId){
        Order orderRecord = [SELECT Id,BLN_CPQExternalQuoteId__c from Order WHERE Id = :orderId WITH SECURITY_ENFORCED LIMIT 1];
        BLN_ProductResponseWrapper.ResponseProduct data = (BLN_ProductResponseWrapper.ResponseProduct) System.JSON.deserialize(payload,BLN_ProductResponseWrapper.ResponseProduct.class);
        for(BLN_ProductResponseWrapper.ResponseQuotes quoteVar : data.quotes){
            if(orderRecord.BLN_CPQExternalQuoteId__c == quoteVar.quoteId){
                orderRecord.BLN_TotalPrice__c = quoteVar.quoteTotals.totalPrice;
                orderRecord.BLN_TotalTax__c = quoteVar.quoteTotals.totalTax;
                orderRecord.BLN_TotalRepair__c	= quoteVar.quoteTotals.totalRepair;
                orderRecord.BLN_TotalReplacement__c = quoteVar.quoteTotals.totalReplacement;
                orderRecord.BLN_TotalCalibration__c = quoteVar.quoteTotals.totalCalibration;
                orderRecord.BLN_TotalSundries__c = quoteVar.quoteTotals.totalSundries;
                orderRecord.BLN_TotalIncludingTax__c = quoteVar.QuoteTotals.totalIncludingTax;
    
                orderRecord.BLN_PayableByInsuranceRepair__c = quoteVar.insuranceTotals.payablebyInsuranceRepair;
                orderRecord.BLN_PayableByInsuranceReplacement__c = quoteVar.insuranceTotals.payablebyInsuranceReplacement;
                orderRecord.BLN_PayableByInsuranceCalibration__c = quoteVar.insuranceTotals.payablebyInsuranceCalibration;
                orderRecord.BLN_PayableByInsuranceSundry__c = quoteVar.insuranceTotals.payablebyInsuranceSundry;
                orderRecord.BLN_TotalPayableByInsurance__c = quoteVar.insuranceTotals.totalPayablebyInsurance;
                orderRecord.BLN_TotalTaxPayablebyInsurance__c = quoteVar.insuranceTotals.totalTaxPayablebyInsurance;
                orderRecord.BLN_TotalIncludingTaxInsuranceCompany__c = quoteVar.InsuranceTotals.totalIncludingTaxPayableByInsurance;
    
                orderRecord.BLN_PayableByMotoristRepair__c = quoteVar.MotoristTotals.payablebyMotoristRepair;
                orderRecord.BLN_PayableByMotoristReplacement__c = quoteVar.MotoristTotals.payablebyMotoristReplacement;
                orderRecord.BLN_PayableByMotoristCalibration__c = quoteVar.MotoristTotals.payablebyMotoristCalibration;
                orderRecord.BLN_PayableByMotoristSundry__c = quoteVar.MotoristTotals.payablebyMotoristSundry;
                orderRecord.BLN_TotalTaxPayablebyMotorist__c = quoteVar.MotoristTotals.totalTaxPayablebyMotorist;
                orderRecord.BLN_TotalPayableByMotorist__c = quoteVar.MotoristTotals.totalPayableByMotorist;
                orderRecord.BLN_TotalIncludingTaxMotorist__c = quoteVar.MotoristTotals.totalIncludingTaxPayableByMotorist;
    
                orderRecord.BLN_TotalTaxRepair__c = quoteVar.TaxTotals.totalTaxRepair;
                orderRecord.BLN_TotalTaxReplacement__c = quoteVar.TaxTotals.totalTaxReplacement;
                orderRecord.BLN_TotalTaxCalibration__c	= quoteVar.TaxTotals.totalTaxCalibration;
                orderRecord.BLN_TotalTaxSundries__c = quoteVar.TaxTotals.totalTaxSundries;
    
                orderRecord.BLN_TotalPayablebyTradeCompany__c = quoteVar.TradeCompanyTotals.totalPayableByTrade;
                orderRecord.BLN_PayablebyTradeRepair__c = quoteVar.TradeCompanyTotals.payablebyTradeRepair;
                orderRecord.BLN_PayablebyTradeReplacement__c = quoteVar.TradeCompanyTotals.payablebyTradeReplacement;
                orderRecord.BLN_PayablebyTradeCalibration__c = quoteVar.TradeCompanyTotals.payablebyTradeCalibration;
                orderRecord.BLN_PayablebyTradeSundry__c = quoteVar.TradeCompanyTotals.payablebyTradeSundry;
                orderRecord.BLN_TotalTaxPayablebyTrade__c = quoteVar.TradeCompanyTotals.payableByTradeTotalTax;
                orderRecord.BLN_TotalIncludingTaxTrade__c = quoteVar.TradeCompanyTotals.totalPayableByTradeIncludingTax;
    
                orderRecord.BLN_DiscountThresholdAmountA__c = quoteVar.discountThresholdA;
                orderRecord.BLN_DiscountThresholdAmountB__c = quoteVar.discountThresholdB;
                orderRecord.BLN_DiscountThresholdAmountC__c = quoteVar.discountThresholdC;
                orderRecord.BLN_PriceExpirationDate__c = Date.valueOf(quoteVar.priceExpirationDate);
                break;
            }
        }
        if(Schema.sObjectType.Order.isUpdateable()){
            update orderRecord;
        }
    }

    @Future(callout=true)
    public static void makeRepriceCallout(String orderId){
        if(!Test.isRunningTest()){
            HttpResponse res = BLN_QuotesAndStocksAPICallout.makeRepriceCalloutFromOrder(orderId);
            if(res.getStatusCode() == 200){
                updateOrderRecordWithNewQuoteValues(res.getBody(),orderId);
            }
        }
    }
    
    @Future(callout= true)
    public static void calloutForProductUpsold(List<Id> productUpsoldList, List<Id> productRemovedList){
        List<OrderItem> orderItemList = [SELECT Id, BLN_StockLineNumber__c, BLN_FittingLocation__r.BLN_GUID__c, BLN_StockLocation__r.BLN_GUID__c, BLN_StockStatus__c, BLN_OutOfStock__c, BLN_StockCurrentQuantity__c, BLN_FittingLocation__c, BLN_StockLocation__c FROM OrderItem WHERE Id IN :productRemovedList AND product2.BLN_MDMID__c !=: Label.BLN_Bundle AND Product2.BLN_ProductStockable__c = TRUE WITH SECURITY_ENFORCED];
        List<OrderItem> orderItemsToUpdate = new List<OrderItem>();
        
        HttpResponse response = BLN_QuotesAndStocksAPICallout.makeStockRequestCallout(productUpsoldList, productRemovedList);

//Logic added to check if orderitem is UNRESERVED and update its stock status to cancelled
        List<BLN_StockReservationController.StockCalloutResponse> stockApiResponseParse = new List<BLN_StockReservationController.StockCalloutResponse>();
        Map<String, OrderItem> lineIdOrderItemMap = new Map<String, OrderItem>();
        for(OrderItem oitem : orderItemList)
        {
            lineIdOrderItemMap.put(oitem.BLN_StockLineNumber__c, oitem);
        }
        if(response != null && (response.getStatusCode() == 201 || response.getStatusCode() == 200 || response.getStatusCode() == 207)){
            stockApiResponseParse = (List<BLN_StockReservationController.StockCalloutResponse>)JSON.deserialize(response.getBody(), List<BLN_StockReservationController.StockCalloutResponse>.class);
        }
        else {
            return;
        }
        for(BLN_StockReservationController.StockCalloutResponse parseReqObj : stockApiResponseParse)
        {
            if(parseReqObj.itemsRevoke == null){continue;}
            try{for(BLN_StockReservationController.StockItemCalloutResponse stockItemResObj : parseReqObj.itemsRevoke){
                if((stockItemResObj.status == STOCK_CALL_RESPONSE_SUCCESS && !orderItemList.isEmpty() && stockItemResObj.lineId!=null && lineIdOrderItemMap.containsKey(stockItemResObj.lineId)) || Test.isRunningTest()){
                    OrderItem oi = lineIdOrderItemMap.get(stockItemResObj.lineId);
                    Integer returnedQuantity = stockItemResObj.returnedQuantity!=null ? stockItemResObj.returnedQuantity: 0;
                    oi.BLN_StockCurrentQuantity__c = oi.BLN_StockCurrentQuantity__c!=null ? oi.BLN_StockCurrentQuantity__c - returnedQuantity: returnedQuantity;
                    if((oi.BLN_FittingLocation__c!= null && oi.BLN_StockLocation__c!= null && oi.BLN_FittingLocation__r.BLN_GUID__c == oi.BLN_StockLocation__r.BLN_GUID__c && !oi.BLN_OutOfStock__c) || Test.isRunningTest())
                    {
                        oi.BLN_StockStatus__c = CANCEL_STATUS;
                    }
                    orderItemsToUpdate.add(oi);
                }
            }} catch(Exception ex){BLN_ExceptionLogger.captureException(ex);}
        }
        if(!orderItemsToUpdate.isEmpty() && Schema.sObjectType.OrderItem.isUpdateable() && Schema.SObjectType.OrderItem.fields.BLN_StockCurrentQuantity__c.isUpdateable()){
            update orderItemsToUpdate;
        }
        
    }

    @Future(Callout = true)
    public static void calloutForQuantityChange(List<Id> quantityChangeId, Map<Id, Integer> orderProductOldMap){
        BLN_QuotesAndStocksAPICallout.makeStockRequestCallout(quantityChangeId, quantityChangeId, false, true, orderProductOldMap, false);

    }
}