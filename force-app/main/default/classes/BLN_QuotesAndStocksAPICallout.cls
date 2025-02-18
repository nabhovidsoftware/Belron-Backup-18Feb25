/*****************************************
ClassName : BLN_QuotesAndStocksAPICallout
Description :  This class has all Quotes and Stocks APIs which are calling out CPQ via Mulesoft
CreatedDate: 23-05-2024
Author: Ayush Kumar Singh (PwC India)
****************************************/
public without sharing class BLN_QuotesAndStocksAPICallout {
    
    static final String STOCK_CALL_ENDPOINT_SUFFIX = System.label.BLN_StockMovementEndpoint;
    static final String CREATE = 'CREATE';
    static final String REVOKE = 'REVOKE';
    static final String REQUISITION = 'REQUISITION';
    static final String CANCEL = 'CANCEL';
    static final String ISSUE = 'ISSUE';
    static final String RESERVE = 'RESERVE';
    static final String UNRESERVE = 'UNRESERVE';
    static final String STOCK_CALL_RESPONSE_SUCCESS = 'success';
    static final String CANCEL_STATUS = 'Cancelled';
    static final String CPT = System.label.BLN_CPT;
    /*****************************************
MethodName : makeQuoteCallout
Description : This method will do callout to Create Quote API
Input Parameter : String payload, String motoristCaseId
Output Parameter : HttpResponse
CreatedDate: 23-05-2024
CreatedBy : Ayush Kumar Singh (PwC India)
Change log :
****************************************/
    public static HttpResponse makeQuoteCallout(String payload, String motoristCaseId){
        BLN_APICalloutMapper__mdt calloutDetails = BLN_APICalloutMapper__mdt.getInstance(System.label.BLN_QuoteApi);
        Map<String,String> headerMap = new Map<String,String>();
        headerMap.put(System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[0],System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[1]+' '+BLN_HTTPCallOutAccessToken.getAccessToken()?.accessToken);
        for(String str : calloutDetails.BLN_Headers__c.split(System.label.BLN_Semicolon)){
            headerMap.put(str.split(System.label.BLN_Comma)[0],str.split(System.label.BLN_Comma)[1]);
        }
        return BLN_HttpCalloutUtility.makeCallout(calloutDetails.BLN_DestinationSystem__c,calloutDetails.BLN_NamedCredential__c + calloutDetails.BLN_CalloutURL__c, calloutDetails.BLN_Method__c, headerMap, motoristCaseId, payload,Integer.valueOf(calloutDetails.BLN_APITimeout__c));        
    }
    
    /*****************************************
MethodName : makeRepriceCallout
Description : This method will do callout to Price & Reprice Quotes API
Input Parameter : String repriceRequestPayload, String caseRecordId
Output Parameter : HttpResponse
CreatedDate: 23-05-2024
CreatedBy : Ayush Kumar Singh (PwC India)
Change log :
****************************************/
    public static HttpResponse makeRepriceCallout(String repriceRequestPayload, String caseRecordId){
        return BLN_QuoteBookingHandler.repriceQuoteCallout(repriceRequestPayload,caseRecordId);
    }

    /*****************************************
MethodName : makeRepriceCallout
Description : This method will do callout to Price & Reprice Quotes API
Input Parameter : List<String> orderItemIds
Output Parameter : HttpResponse
CreatedDate: 29-05-2024
CreatedBy : Ayush Kumar Singh (PwC India)
Change log :
****************************************/
public static HttpResponse makeRepriceCalloutFromOrder(String orderId){
    //Set<Id> setOfOrderItemIds = new Set<Id>();
    //setOfOrderItemIds = listOfRecIdStrToSetOfId(orderItemIds);
   // String repriceRequestPayload = '';
    String caseRecordId = '';
    List<RepricePayloadWrapper> repricePayloadList = new List<RepricePayloadWrapper>();
    List<RepriceLineItem> lineItems = new List<RepriceLineItem>();

    RepricePayloadWrapper repricePayload = new RepricePayloadWrapper();

    List<OrderItem> opList = [  SELECT Id, Product2Id, OrderId, Quantity, BLN_StockCurrentQuantity__c, BLN_IsProductSelected__c,
                                BLN_StockLineNumber__c, BLN_DocumentNumber__c, BLN_StockOrderNumber__c, BLN_FittingLocation__c,
                                BLN_StockLocation__c, Order.BLN_Case__c,
                                Order.BLN_Case__r.BLN_Corporate__r.BLN_CHFVATStatus__c,
                                Order.BLN_ServiceTerritory__c, Order.BLN_CPQExternalQuoteId__c,
                                Order.BLN_Discount__c, Order.BLN_ServiceTerritory__r.BLN_CostCenter__c,
                                Product2.BLN_MDMID__c, BLN_StockLocation__r.BLN_OrgCodeLocation__c , BLN_FittingLocation__r.BLN_OrgCodeLocation__c, BLN_FittingLocation__r.BLN_GUID__c, BLN_StockLocation__r.BLN_GUID__c, BLN_FittingLocation__r.BLN_PrimarySourceCollectId__c, BLN_ServiceAppointment__r.BLN_RebookedServiceAppointment__c, BLN_ServiceAppointment__r.BLN_RebookedServiceAppointment__r.AppointmentNumber, BLN_ServiceAppointment__r.AppointmentNumber
                                FROM OrderItem WHERE OrderId = :orderId WITH SECURITY_ENFORCED];


    if(!opList.isEmpty() && opList[0].OrderId!=null){
        repricePayload.id = opList[0].Order.BLN_CPQExternalQuoteId__c!=null ? opList[0].Order.BLN_CPQExternalQuoteId__c : '';
        repricePayload.discount = opList[0].Order.BLN_Discount__c!=null ? opList[0].Order.BLN_Discount__c : 0;            
        repricePayload.afterHours = ''; //afterHours to be decided
        
        if(opList[0].Order.BLN_Case__c!=null ){
            caseRecordId = opList[0].Order.BLN_Case__c!=null ? opList[0].Order.BLN_Case__c : '';
            repricePayload.caseId = caseRecordId;
            repricePayload.chfVATStatus = opList[0].Order.BLN_Case__r.BLN_Corporate__r.BLN_CHFVATStatus__c!=null ? opList[0].Order.BLN_Case__r.BLN_Corporate__r.BLN_CHFVATStatus__c : '';            
        }
        else if(opList[0].Order.BLN_Case__c!=null)
        {
            caseRecordId = opList[0].Order.BLN_Case__c!=null ? opList[0].Order.BLN_Case__c : '';
            repricePayload.caseId = caseRecordId;
            repricePayload.chfVATStatus = '';
        }
        else{
            repricePayload.caseId = '';
            repricePayload.chfVATStatus = '';
        }
        
        for(OrderItem oi:opList){            
            RepriceLineItem repriceItem = new RepriceLineItem();
            repriceItem.lineId = oi.BLN_DocumentNumber__c!=null ? String.valueOf(oi.BLN_DocumentNumber__c) : '';
            repriceItem.quantity = oi.Quantity!=null ? Integer.valueOf(oi.Quantity) : 0;
            repriceItem.selectProduct = oi.BLN_IsProductSelected__c;               
            lineItems.add(repriceItem);
            repricePayload.lineItems = lineItems;
        }
    }
    else {
        repricePayload.id = '';
        repricePayload.discount = 0;
        repricePayload.afterHours = '';
        repricePayload.caseId = '';
        repricePayload.chfVATStatus = '';
        repricePayload.lineItems = lineItems;
    }
    repricePayloadList.add(repricePayload); // final Payload for stock movement

    return makeRepriceCallout(JSON.serialize(repricePayloadList), caseRecordId);
       
}
    
    /*****************************************
MethodName : getQuoteCallout
Description : This method will do callout to Get Quotes API
Input Parameter : String cpqExtenalCode
Output Parameter : HttpResponse
CreatedDate: 23-05-2024
CreatedBy : Ayush Kumar Singh (PwC India)
Change log :
****************************************/
    public static HttpResponse getQuoteCallout(String cpqExtenalCode){
        // BLN_APICalloutMapper__mdt calloutDetails = BLN_APICalloutMapper__mdt.getInstance(System.label.BLN_GetQuoteAPI);
        // Map<String,String> headerMap = new Map<String,String>();
        // headerMap.put(System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[0],System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[1]+' '+BLN_HTTPCallOutAccessToken.getAccessToken()?.accessToken);
        // String hCode = EncodingUtil.convertToHex(Crypto.generateAesKey(128));
        // String correlID = hCode.substring(0,4)+'-'+hCode.substring(0,4)+'-'+hCode.substring(5,8)+'-'+hCode.substring(9,12)+'-'+hCode.substring(12,16)+'-'+hCode.substring(16,20);
        // headerMap.put(System.label.BLN_XCORRELATIONID,correlID);

        return BLN_QuoteBookingHandler.getQuoteCallout(cpqExtenalCode,'CPQ External Id : '+cpqExtenalCode);        
    }  
    
    /*****************************************
MethodName : quoteStockMovementCallout
Description : This method will do callout to Create/Update Quote Stock Movement API
Input Parameter : String cpqExtenalCode, String requestPayload
Output Parameter : HttpResponse
CreatedDate: 23-05-2024
CreatedBy : Ayush Kumar Singh (PwC India)
Change log :
****************************************/
    public static HttpResponse quoteStockMovementCallout(String cpqExtenalCode, String requestPayload){
        BLN_APICalloutMapper__mdt calloutDetails = BLN_APICalloutMapper__mdt.getInstance(System.label.BLN_QuoteStockMovement);
        String calloutURL = calloutDetails.BLN_CalloutURL__c;
        List<Object> parameters = new List<Object>{cpqExtenalCode};
        calloutURL = String.format(calloutURL, parameters);
        Map<String,String> headerMap = new Map<String,String>();
        headerMap.put(System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[0],System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[1]+' '+BLN_HTTPCallOutAccessToken.getAccessToken()?.accessToken);
        return BLN_HttpCalloutUtility.makeCallout(calloutDetails.BLN_DestinationSystem__c,calloutDetails.BLN_NamedCredential__c + calloutURL, calloutDetails.BLN_Method__c,headerMap,'CPQ External Id '+cpqExtenalCode, requestPayload,Integer.valueOf(calloutDetails.BLN_APITimeout__c));
    }

    /*****************************************
MethodName : quoteStockMovementCallout
Description : This method will do callout to Create/Update Quote Stock Movement API
Input Parameter : Set<Id> setOfOrderItemIds, String actionType
Output Parameter : HttpResponse
CreatedDate: 23-05-2024
CreatedBy : Ayush Kumar Singh (PwC India)
Change log :
****************************************/
public static HttpResponse quoteStockMovementCallout(Set<Id> setOfOrderItemIds, String orderitemLocationMapDes){
    //get the OrderProducts and make request for callout
    
    // List<List<StockAdjustPayloadWrapper>> payloadList = new List<List<StockAdjustPayloadWrapper>>();
    Map<String, String> orderitemLocationMap = (Map<String, String>) JSON.deserializeStrict(orderitemLocationMapDes, Map<String, String>.class); 
    String cpqQuoteId = '';
    List<OrderItem> opList = [SELECT Id, Product2Id, OrderId, Quantity, BLN_StockCurrentQuantity__c, BLN_IsProductSelected__c,BLN_ServiceAppointment__c,
    BLN_StockLineNumber__c, BLN_DocumentNumber__c, BLN_StockOrderNumber__c, BLN_FittingLocation__c,
    BLN_StockLocation__c, Order.BLN_Case__c,
    Order.BLN_ServiceTerritory__c, Order.BLN_CPQExternalQuoteId__c,
    Order.BLN_Discount__c, Order.BLN_ServiceTerritory__r.BLN_CostCenter__c, BLN_FittingLocation__r.BLN_OrgCodeLocation__c,
    Product2.BLN_MDMID__c, BLN_StockLocation__r.BLN_OrgCodeLocation__c, Product2.BLN_SKU__c, BLN_ServiceAppointment__r.ArrivalWindowStartTime, BLN_StockLocation__r.BLN_GUID__c, BLN_FittingLocation__r.BLN_GUID__c, BLN_FittingLocation__r.BLN_PrimarySourceCollectId__c, BLN_StockStatus__c, BLN_OutOfStock__c, BLN_ServiceAppointment__r.BLN_RebookedServiceAppointment__c, BLN_ServiceAppointment__r.BLN_RebookedServiceAppointment__r.AppointmentNumber, BLN_ServiceAppointment__r.AppointmentNumber
    FROM OrderItem WHERE Id IN:setOfOrderItemIds WITH SECURITY_ENFORCED];

    Map<String, Schema.Location> mapLoc = new Map<String, Schema.Location>();
    List<String> payloadJsonList = new List<String>();
    for(Schema.Location loc : [SELECT Id,Name, BLN_GUID__c, BLN_OrgCodeLocation__c FROM Location WHERE BLN_OrgCodeLocation__c IN :orderitemLocationMap.values() WITH SECURITY_ENFORCED]) {   
        mapLoc.put(loc.BLN_OrgCodeLocation__c, loc);
    }
    Map<String, OrderItem> lineIdOrderItemMap = new Map<String, OrderItem>();
    for(OrderItem oitem : opList)
    {
        lineIdOrderItemMap.put(oitem.BLN_StockLineNumber__c, oitem);
    }
    if(!opList.isEmpty()){
        StockAdjustPayloadWrapper stockAdjustpayload = new StockAdjustPayloadWrapper();
        if(opList[0].OrderId!=null && opList[0].Order.BLN_ServiceTerritory__c!=null){

            stockAdjustpayload.jobId = opList[0].Order.BLN_Case__c!=null ? opList[0].Order.BLN_Case__c.to15() : '';
            cpqQuoteId = opList[0].Order.BLN_CPQExternalQuoteId__c!=null ? opList[0].Order.BLN_CPQExternalQuoteId__c : '';
            // stockAdjustpayload.costCenterId = opList[0].Order.BLN_ServiceTerritory__r.BLN_CostCenter__c!=null ? opList[0].Order.BLN_ServiceTerritory__r.BLN_CostCenter__c : '';
            stockAdjustpayload.costCenterId = opList[0].BLN_FittingLocation__c!=null ? opList[0].BLN_FittingLocation__r.BLN_OrgCodeLocation__c : '';
        }
        else if(opList[0].OrderId!=null) 
        {
            stockAdjustpayload.jobId = opList[0].Order.BLN_Case__c!=null ? opList[0].Order.BLN_Case__c.to15() : '';
            cpqQuoteId = opList[0].Order.BLN_CPQExternalQuoteId__c!=null ? opList[0].Order.BLN_CPQExternalQuoteId__c : '';
            stockAdjustpayload.costCenterId = '';
        }
        else
        {
            stockAdjustpayload.jobId = '';
            stockAdjustpayload.costCenterId = '';
        }
        stockAdjustpayload.foStockOrderId = opList[0].BLN_StockOrderNumber__c!=null ? opList[0].BLN_StockOrderNumber__c : '';
        
        stockAdjustpayload.itemsCreate = new List<ItemsWrapper>(); // commenting as asked by Jon/Rahul S
        stockAdjustpayload.itemsRevoke = new List<ItemsWrapper>(); // commenting as asked by Jon/Rahul S

        //CANCEL REQUEST
        for(OrderItem oi:opList){
            List<StockAdjustPayloadWrapper> stockAdjustpayloadList = new List<StockAdjustPayloadWrapper>();
            StockAdjustPayloadWrapper stockAdjustpayload2 = new StockAdjustPayloadWrapper();
            stockAdjustpayload2 = stockAdjustpayload;
            ItemsWrapper item = new ItemsWrapper();
            List<ItemsWrapper> itemsCreate = new List<ItemsWrapper>();
            List<ItemsWrapper> itemsRevoke = new List<ItemsWrapper>();

            item = createOrderItemPayload(oi, CANCEL, false, false);
            
            itemsRevoke.add(item);
            stockAdjustpayload2.itemsRevoke = itemsRevoke;
            stockAdjustpayload2.itemsCreate = itemsCreate;
            
            stockAdjustpayloadList.add(stockAdjustpayload2); // final Payload for stock movement
            if(oi.BLN_StockStatus__c != CANCEL_STATUS){
                payloadJsonList.add(JSON.serializePretty(stockAdjustpayloadList, true));
            }
        }

        //CREATE REQUEST
        for(OrderItem oi:opList){
            List<StockAdjustPayloadWrapper> stockAdjustpayloadList = new List<StockAdjustPayloadWrapper>();
            StockAdjustPayloadWrapper stockAdjustpayload2 = new StockAdjustPayloadWrapper();
            stockAdjustpayload2 = stockAdjustpayload;
            ItemsWrapper item = new ItemsWrapper();
            List<ItemsWrapper> itemsCreate = new List<ItemsWrapper>();
            List<ItemsWrapper> itemsRevoke = new List<ItemsWrapper>();

            item = createOrderItemPayload(oi, REQUISITION, false, false);
            
            item.stockLocationOrganizationId = orderitemLocationMap.containsKey(oi.id) ? mapLoc.containsKey(orderitemLocationMap.get(oi.id)) ? mapLoc.get(orderitemLocationMap.get(oi.id)).BLN_OrgCodeLocation__c != null? mapLoc.get(orderitemLocationMap.get(oi.id)).BLN_OrgCodeLocation__c : '' : '' : '';
            String newLocGUID = orderitemLocationMap.containsKey(oi.id) ? mapLoc.containsKey(orderitemLocationMap.get(oi.id)) ? mapLoc.get(orderitemLocationMap.get(oi.id)).BLN_GUID__c != null? mapLoc.get(orderitemLocationMap.get(oi.id)).BLN_GUID__c : '' : '' : '';
            if( oi.BLN_FittingLocation__r.BLN_GUID__c == newLocGUID ){
                item.actionType = RESERVE;
            }
            else{
                item.actionType = REQUISITION;
            }
            
            itemsCreate.add(item);
            stockAdjustpayload2.itemsRevoke = itemsRevoke;
            stockAdjustpayload2.itemsCreate = itemsCreate;
            
            stockAdjustpayloadList.add(stockAdjustpayload2); // final Payload for stock movement
            payloadJsonList.add(JSON.serializePretty(stockAdjustpayloadList, true));
        }
    }
    if(payloadJsonList==null || payloadJsonList.size()==0){return null;}
    BLN_APICalloutMapper__mdt calloutDetails = BLN_APICalloutMapper__mdt.getInstance(System.label.BLN_StocksRequestApi);
    String endPoint = calloutDetails.BLN_NamedCredential__c + calloutDetails.BLN_CalloutURL__c+cpqQuoteId+STOCK_CALL_ENDPOINT_SUFFIX;
    Map<String,String> headerMap = new Map<String,String>();
        headerMap.put(System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[0],System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[1]+' '+BLN_HTTPCallOutAccessToken.getAccessToken()?.accessToken);
    for(String str : calloutDetails.BLN_Headers__c.split(System.label.BLN_Semicolon)){
        headerMap.put(str.split(System.label.BLN_Comma)[0],str.split(System.label.BLN_Comma)[1]);
    }

    List<OrderItem> orderItemsToUpdate = new List<OrderItem>();
    Map<String, HttpResponse> resList = new Map<String,HttpResponse>();
    List<Exception> ex = new List<Exception>();

    for(String eachPayload: payloadJsonList)
    {
        HttpResponse response = new HttpResponse();
        String payloadRequest = eachPayload;
        if(payloadRequest!=null && !String.isEmpty(payloadRequest) && !String.isBlank(payloadRequest))
        {
            List<BLN_StockReservationController.StockCalloutResponse> stockApiResponseParse = new List<BLN_StockReservationController.StockCalloutResponse>();
            response = BLN_HttpCalloutUtility.makeCallout(false, calloutDetails.BLN_DestinationSystem__c, endPoint, calloutDetails.BLN_Method__c, headerMap, null, payloadRequest,Integer.valueof(calloutDetails.BLN_APITimeout__c));
            resList.put(payloadRequest, response);
            try{stockApiResponseParse = (List<BLN_StockReservationController.StockCalloutResponse>)JSON.deserialize(response.getBody(), List<BLN_StockReservationController.StockCalloutResponse>.class);
            if(stockApiResponseParse[0].itemsRevoke != null){continue;}
            if(stockApiResponseParse[0].itemsCreate[0].status == STOCK_CALL_RESPONSE_SUCCESS)
            {
                OrderItem oi = lineIdOrderItemMap.get(stockApiResponseParse[0].itemsCreate[0].lineId);
                oi.BLN_StockLocation__c = mapLoc.get(oi.Id).Id;
                orderItemsToUpdate.add(oi);
            }}
            catch(Exception e){ex.add(e);}
        }
        
    }
    List<BLN_IntegrationLogger__c> loggerList = new List<BLN_IntegrationLogger__c>();
    for(String res: resList.keySet())
    {
        BLN_IntegrationLogger__c loggerRecord = new BLN_IntegrationLogger__c();
        String header = '';        
        //assignment of request details
        loggerRecord.BLN_RequestBody__c = res;
        loggerRecord.BLN_RequestEndPoint__c = endPoint;
        loggerRecord.BLN_RequestIssuedBy__c = UserInfo.getUserId();
        loggerRecord.BLN_RequestMethod__c = calloutDetails.BLN_Method__c;
        loggerRecord.BLN_RequestSent__c = System.now();
        loggerRecord.BLN_ResponseBody__c = resList.get(res).getBody().length() <= BLN_IntegrationLogger__c.BLN_ResponseBody__c.getDescribe().length ? resList.get(res).getBody() : resList.get(res).getBody().subString(0,BLN_IntegrationLogger__c.BLN_ResponseBody__c.getDescribe().length - 1);
        header = '';
        for(String keyVal : resList.get(res).getHeaderkeys()){header += keyVal+' '+resList.get(res).getHeader(keyVal)+'  ';}
        loggerRecord.BLN_ResponseHeaders__c = header;
        loggerRecord.BLN_ResponseStatusCode__c = String.valueOf(resList.get(res).getStatusCode());
        loggerRecord.BLN_ResponseStatus__c = resList.get(res).getStatus();
        loggerRecord.BLN_TargetSystem__c = calloutDetails.BLN_DestinationSystem__c;
        loggerList.add(loggerRecord);
    }
    if(orderItemsToUpdate!=null && Schema.sObjectType.OrderItem.isUpdateable())
    {
        update orderItemsToUpdate;
    }
    if(loggerList!=null && Schema.sObjectType.BLN_IntegrationLogger__c.isCreateable())
    {
        Database.insert(loggerList,false);
    }
    return null;
}

    /*****************************************
MethodName : quoteStockMovementCancelCallout
Description : This method will do callout to Create/Update Quote Stock Movement API for actionType CANCEL 
Input Parameter : Set<Id> setOfOrderItemIds
Output Parameter : Boolean
CreatedDate: 23-05-2024
CreatedBy : Ayush Kumar Singh (PwC India)
Change log :
****************************************/

@AuraEnabled
public static Boolean quoteStockMovementCancelCallout(List<String> setOfOrderItemIds){
    Set<Id> setOfOIIds = new Set<Id>();
    List<Id> listOfOrderItems = new List<Id>();
    if(setOfOrderItemIds!=null){
        for(String oId: setOfOrderItemIds)
        {
            listOfOrderItems.add(Id.valueOf(oId));
        }
    }

    setOfOIIds = listOfRecIdStrToSetOfId(setOfOrderItemIds);
    Boolean result = false;
    // HttpResponse res = quoteStockMovementCallout(setOfOIIds, System.Label.BLN_EBSActionType);
    HttpResponse res = makeStockRequestCallout(new List<Id>(), listOfOrderItems);
    result = ( res.getStatusCode()==200 ||res.getStatusCode()==201 ||res.getStatusCode()==207) ? true : false;
    return result;
} 

public static ItemsWrapper createOrderItemPayload(OrderItem orderProdObj, String actionType, Boolean isCPT, Boolean onSAUpdate){
    return createOrderItemPayload(orderProdObj, actionType, isCPT, onSAUpdate, null);
}
public static ItemsWrapper createOrderItemPayload(OrderItem orderProdObj, String actionType, Boolean isCPT, Boolean onSAUpdate, ServiceAppointment rebookSA){
    ItemsWrapper cItem = new ItemsWrapper();
    cItem.lineId = orderProdObj.BLN_StockLineNumber__c != null ? String.valueOf(orderProdObj.BLN_StockLineNumber__c) : '';
    if(onSAUpdate && actionType == CANCEL && rebookSA != null){
        cItem.lineId = rebookSA.AppointmentNumber + orderProdObj.BLN_DocumentNumber__c;
    } 
    else if(onSAUpdate && actionType == CANCEL)
    {
        cItem.lineId = orderProdObj.BLN_ServiceAppointment__r.AppointmentNumber + orderProdObj.BLN_DocumentNumber__c;
    }

    if(onSAUpdate && actionType == CANCEL){
        cItem.currentQuantity = orderProdObj.Quantity != null ? Integer.valueOf(orderProdObj.Quantity): 0;
        cItem.actionQuantity = 0;
        
    } 
    else if(onSAUpdate){
        cItem.currentQuantity = 0;
        cItem.actionQuantity = orderProdObj.Quantity != null ? Integer.valueOf(orderProdObj.Quantity): 0;
        
    } 
    else if(actionType == CANCEL){
        cItem.currentQuantity = orderProdObj.Quantity != null ? Integer.valueOf(orderProdObj.Quantity): 0;
        cItem.actionQuantity = 0;
    }
    else{
        // cItem.currentQuantity = orderProdObj.BLN_StockCurrentQuantity__c!=null ? Integer.valueOf(orderProdObj.BLN_StockCurrentQuantity__c) : 0;
        // cItem.actionQuantity = orderProdObj.Quantity != null ? Integer.valueOf(orderProdObj.Quantity) - cItem.currentQuantity : 0;
        cItem.currentQuantity = 0;
        cItem.actionQuantity = orderProdObj.Quantity != null ? Integer.valueOf(orderProdObj.Quantity) : 0;
    }
    
    cItem.itemId = orderProdObj.Product2.BLN_SKU__c != null ? orderProdObj.Product2.BLN_SKU__c : '';
    
    if(isCPT == true && actionType!=ISSUE)
    {
        cItem.stockLocationOrganizationId = CPT;
    }
    else if(isCPT == true && actionType==ISSUE){
        cItem.stockLocationOrganizationId = CPT;
        cItem.actionType = actionType; //'ISSUE'
    }
    else if(actionType==ISSUE)
    {
        cItem.stockLocationOrganizationId = orderProdObj.BLN_FittingLocation__r.BLN_OrgCodeLocation__c != null ? orderProdObj.BLN_FittingLocation__r.BLN_OrgCodeLocation__c : '';
        cItem.actionType = ISSUE; //'ISSUE'
    }
    else if(actionType == CANCEL)
    {
        cItem.stockLocationOrganizationId = orderProdObj.BLN_StockLocation__r.BLN_OrgCodeLocation__c != null ? orderProdObj.BLN_StockLocation__r.BLN_OrgCodeLocation__c : '';
        if(orderProdObj.BLN_FittingLocation__r.BLN_GUID__c == orderProdObj.BLN_StockLocation__r.BLN_GUID__c && !orderProdObj.BLN_OutOfStock__c)
        {
            cItem.actionType = UNRESERVE;
        }
        else
        {
            cItem.actionType = CANCEL;
        }
    }
    else {
        cItem.stockLocationOrganizationId = orderProdObj.BLN_StockLocation__r.BLN_OrgCodeLocation__c != null ? orderProdObj.BLN_StockLocation__r.BLN_OrgCodeLocation__c : '';
        if( orderProdObj.BLN_FittingLocation__r.BLN_GUID__c == orderProdObj.BLN_StockLocation__r.BLN_GUID__c ){
            cItem.actionType = RESERVE;
        }
        else{
            cItem.actionType = REQUISITION;
        }
    }
    if( orderProdObj.BLN_FittingLocation__r.BLN_GUID__c == orderProdObj.BLN_StockLocation__r.BLN_GUID__c ){
        cItem.collectionFlag = 'Y';
    }
    else{

        if( orderProdObj.BLN_FittingLocation__r.BLN_PrimarySourceCollectId__c != NULL && 
            orderProdObj.BLN_FittingLocation__r.BLN_PrimarySourceCollectId__c == orderProdObj.BLN_StockLocation__r.BLN_GUID__c){
            cItem.collectionFlag = 'Y';
        }else{
            cItem.collectionFlag = 'N';
        }
    }

    
    if(orderProdObj.BLN_ServiceAppointment__r.ArrivalWindowStartTime != null 
       || (onSAUpdate && actionType == CANCEL && rebookSA != null)){
        String reqByDateTime = '';
           if(onSAUpdate && actionType == CANCEL && rebookSA != null){
              reqByDateTime = rebookSA.ArrivalWindowStartTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSSSSZ');
         
           } else{
             reqByDateTime = orderProdObj.BLN_ServiceAppointment__r.ArrivalWindowStartTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSSSSZ');
         
           }
        String last2Chars = reqByDateTime.right(2);
        reqByDateTime = reqByDateTime.removeEnd(last2Chars);
        reqByDateTime = reqByDateTime + ':' + last2Chars;
        cItem.requiredByDateTime = reqByDateTime;//Required Field or else error in response
    }
    else {
        cItem.requiredByDateTime = '';//Required Field or else error in response
    }
    
    
    return cItem;
}

/*****************************************
MethodName : makeStockRequestCallout
Description : This method will do callout to Create Stock Request API
Input Parameter : String payload
Output Parameter : HttpResponse
CreatedDate: 24-05-2024
CreatedBy : Siddhant Pandya (PwC India)
Change log :
****************************************/
public static HttpResponse makeStockRequestCallout(List<Id> createOrderItemId, List<Id> revokeOrederItemId, Boolean isCPT, Boolean isQuantityChange, Map<Id, Integer> oldQuantityMap, Boolean isFromPortal){

    String cpqQuoteId = '';
    List<OrderItem> orderProductDataList = new List<OrderItem>();
   // String bundleProductName = Label.BLN_Bundle;
    orderProductDataList = [SELECT Id, OrderId, Order.BLN_Case__c, BLN_StockOrderNumber__c, 
                            BLN_StockLineNumber__c, Product2.BLN_MDMID__c, BLN_ServiceAppointment__r.ArrivalWindowStartTime, 
                            BLN_StockCurrentQuantity__c, Quantity, 
                            BLN_FittingLocation__c, BLN_StockLocation__c, BLN_ServiceAppointment__r.AppointmentNumber,  
                            Order.OrderNumber, BLN_DocumentNumber__c, BLN_ServiceAppointment__c, Order.BLN_CPQExternalQuoteId__c, 
                            Product2.BLN_SKU__c,  Product2.BLN_ProductStockable__c,  
                            BLN_FittingLocation__r.BLN_PrimarySourceCollectId__c, BLN_FittingLocation__r.BLN_CostCenterCode__c, 
                            BLN_FittingLocation__r.BLN_OrgCodeLocation__c, BLN_ServiceAppointment__r.BLN_RebookedServiceAppointment__r.AppointmentNumber, 
                            BLN_ServiceAppointment__r.BLN_RebookedServiceAppointment__r.ArrivalWindowStartTime,
                            BLN_StockLocation__r.BLN_OrgCodeLocation__c, BLN_StockLocation__r.BLN_GUID__c, 
                            BLN_FittingLocation__r.BLN_GUID__c, BLN_OutOfStock__c, BLN_ServiceAppointment__r.BLN_RebookedServiceAppointment__c, 
                            BLN_StocksPreviousAppointment__c, Order.BLN_Case__r.CaseNumber
                            FROM OrderItem 
                            WHERE (Id IN :createOrderItemId  OR Id IN :revokeOrederItemId) AND product2.BLN_MDMID__c !=: Label.BLN_Bundle AND Product2.BLN_ProductStockable__c = TRUE WITH SECURITY_ENFORCED];

    if(orderProductDataList.size()>0)
    {
        for(OrderItem oitem: orderProductDataList)
        {
            if(oitem.Order.BLN_CPQExternalQuoteId__c != null)
            {
                cpqQuoteId = oitem.Order.BLN_CPQExternalQuoteId__c;
                break;
            }
        }
    }
    List<String> oldAppNo = new List<String>();
    Map<String, ServiceAppointment> oldSaMap = new Map<String, ServiceAppointment>();
    if(isFromPortal)
    {
        for(OrderItem oitem: orderProductDataList){
            oldAppNo.add(oitem.BLN_StocksPreviousAppointment__c);
        }
        for(ServiceAppointment sa: [SELECT Id, AppointmentNumber, ArrivalWindowStartTime FROM ServiceAppointment WHERE AppointmentNumber IN :oldAppNo WITH SECURITY_ENFORCED]){
            oldSaMap.put(sa.AppointmentNumber, sa);
        }
    }
    Map<Id, Map<String, List<ItemsWrapper>>> saWithOrderProductMap = new Map<Id, Map<String, List<ItemsWrapper>>>();
    Map<Id, String> saWithStockOrderNo = new Map<Id, String>();
    Map<id, Id> saWithCase = new Map<Id, Id>();
    String fittingLocationId = '';
    
    for(OrderItem orderProdObj: orderProductDataList){
        Map<String, List<ItemsWrapper>> innerOrderProductMap = new Map<String, List<ItemsWrapper>>{CREATE => new List<ItemsWrapper>(), 
        REVOKE => new List<ItemsWrapper>()};
        Map<String, List<ItemsWrapper>> innerOProductMapSAupdate = new Map<String, List<ItemsWrapper>>{CREATE => new List<ItemsWrapper>(), 
        REVOKE => new List<ItemsWrapper>()};

        List<ItemsWrapper> createOrderProductList = new List<ItemsWrapper>();
        List<ItemsWrapper> revokeOrderProductList = new List<ItemsWrapper>(); 
        Id rebookedSAId;
        ServiceAppointment rebookedSA = new ServiceAppointment();
        if(isFromPortal)
        {
            rebookedSAId = oldSaMap.containsKey(orderProdObj.BLN_StocksPreviousAppointment__c)? oldSaMap.get(orderProdObj.BLN_StocksPreviousAppointment__c).Id: null;
            rebookedSA = oldSaMap.containsKey(orderProdObj.BLN_StocksPreviousAppointment__c)? oldSaMap.get(orderProdObj.BLN_StocksPreviousAppointment__c): null;
        }

        if(orderProdObj.BLN_FittingLocation__c != null && fittingLocationId == '')
        {
            fittingLocationId = orderProdObj.BLN_FittingLocation__r.BLN_OrgCodeLocation__c!=null? orderProdObj.BLN_FittingLocation__r.BLN_OrgCodeLocation__c:'';
        }
        if(saWithOrderProductMap.containsKey(orderProdObj.BLN_ServiceAppointment__c) && !isFromPortal){
            innerOrderProductMap = saWithOrderProductMap.get(orderProdObj.BLN_ServiceAppointment__c);
            createOrderProductList = innerOrderProductMap.get(CREATE);
            revokeOrderProductList = innerOrderProductMap.get(REVOKE);
        }        
        if(isFromPortal && saWithOrderProductMap.containsKey(orderProdObj.BLN_ServiceAppointment__c)){
            innerOrderProductMap = saWithOrderProductMap.get(orderProdObj.BLN_ServiceAppointment__c);
            createOrderProductList = innerOrderProductMap.get(CREATE);
            // revokeOrderProductList = innerOrderProductMap.get(REVOKE);
        }
        if(isFromPortal && rebookedSAId != null && saWithOrderProductMap.containsKey(rebookedSAId)){
            innerOProductMapSAupdate = saWithOrderProductMap.get(rebookedSAId);
            // createOrderProductList = innerOrderProductMap.get(CREATE);
            revokeOrderProductList = innerOProductMapSAupdate.get(REVOKE);
        }
        if(createOrderItemId.contains(orderProdObj.Id)){
            ItemsWrapper cItem = createOrderItemPayload(orderProdObj, REQUISITION, isCPT, isFromPortal);
            createOrderProductList.add(cItem);
            innerOrderProductMap.put(CREATE, createOrderProductList);
        } 
        if(revokeOrederItemId.contains(orderProdObj.Id) && !isCPT && !isFromPortal){
            ItemsWrapper cItem = createOrderItemPayload(orderProdObj, CANCEL, false, isFromPortal, rebookedSA);
            if(isQuantityChange)
            {
                cItem.currentQuantity = oldQuantityMap.containsKey(orderProdObj.Id)? oldQuantityMap.get(orderProdObj.Id): Integer.valueOf(orderProdObj.quantity);
                // cItem.actionQuantity = 2343;
            }
            revokeOrderProductList.add(cItem);
            innerOrderProductMap.put(REVOKE, revokeOrderProductList);
        }
        else if(revokeOrederItemId.contains(orderProdObj.Id) && isCPT && !isFromPortal){
            ItemsWrapper cItem = createOrderItemPayload(orderProdObj, ISSUE, isCPT, isFromPortal);
            revokeOrderProductList.add(cItem);
            innerOrderProductMap.put(REVOKE, revokeOrderProductList);
        }        
        //SA update changes
        if(revokeOrederItemId.contains(orderProdObj.Id) && !isCPT && isFromPortal){
            ItemsWrapper cItem = createOrderItemPayload(orderProdObj, CANCEL, false, isFromPortal, rebookedSA);
            if(isQuantityChange)
            {
                cItem.currentQuantity = oldQuantityMap.containsKey(orderProdObj.Id)? oldQuantityMap.get(orderProdObj.Id): Integer.valueOf(orderProdObj.quantity);
                // cItem.actionQuantity = 2343;
            }
            revokeOrderProductList.add(cItem);
            innerOProductMapSAupdate.put(REVOKE, revokeOrderProductList);
        }
        else if(revokeOrederItemId.contains(orderProdObj.Id) && isCPT && isFromPortal){
            ItemsWrapper cItem = createOrderItemPayload(orderProdObj, ISSUE, isCPT, isFromPortal);
            revokeOrderProductList.add(cItem);
            innerOProductMapSAupdate.put(REVOKE, revokeOrderProductList);
        }     
        
        saWithStockOrderNo.put(orderProdObj.BLN_ServiceAppointment__c, orderProdObj.BLN_StockOrderNumber__c);
        if(isFromPortal && rebookedSAId!=null)
        {
            String foID = orderProdObj.Order.BLN_Case__r.CaseNumber + System.label.BLN_FoStockOrderSeperator + (oldSaMap.get(orderProdObj.BLN_StocksPreviousAppointment__c).AppointmentNumber).right(6);
            //saWithStockOrderNo.put(rebookedSAId, oldSaMap.get(orderProdObj.BLN_StocksPreviousAppointment__c).AppointmentNumber);
            //Updated as per CR FOUK-11112
            saWithStockOrderNo.put(rebookedSAId, foID);
            saWithCase.put(rebookedSAId, orderProdObj.Order.BLN_Case__c);
        }
        if(revokeOrederItemId.contains(orderProdObj.Id) && isFromPortal) {
            saWithOrderProductMap.put(orderProdObj.BLN_ServiceAppointment__c, innerOrderProductMap);
            saWithOrderProductMap.put(rebookedSAId, innerOProductMapSAupdate);
        }
        //SA update changes end

        else {
            saWithOrderProductMap.put(orderProdObj.BLN_ServiceAppointment__c, innerOrderProductMap);
        }
        if(orderProdObj.Order.BLN_Case__c != null)
        {
            saWithCase.put(orderProdObj.BLN_ServiceAppointment__c, orderProdObj.Order.BLN_Case__c);
        }
    }

    Map<Id, ServiceAppointment> serviceAppointmentMap = new Map<Id, ServiceAppointment>([SELECT Id, AppointmentNumber, SchedStartTime, ServiceTerritory.BLN_CostCenter__c, BLN_Case__c
                                                        FROM ServiceAppointment 
                                                        WHERE Id In : saWithOrderProductMap.keySet()]);

    List<StockWrapper> payload = new List<StockWrapper>();

    if(serviceAppointmentMap != null){
        for(Id saRecordId : saWithOrderProductMap.keySet()){
            // String orderId = '';
            StockWrapper requestBd = new StockWrapper(); 
            List<ItemsWrapper> createOIList = saWithOrderProductMap.get(saRecordId).get(CREATE);
            List<ItemsWrapper> revokeOIList = saWithOrderProductMap.get(saRecordId).get(REVOKE);
                
            // if(!createOIList.isEmpty()){
            //     orderId = createOIList[0].lineId;
            // } else if(!revokeOIList.isEmpty()){
            //     orderId = revokeOIList[0].lineId;
            // }

            if(isCPT && !createOrderItemId.isEmpty()){
                // requestBd.caseId = serviceAppointmentMap.containsKey(saRecordId) ? serviceAppointmentMap.get(saRecordId).BLN_Case__c!=null ? String.valueOf(serviceAppointmentMap.get(saRecordId).BLN_Case__c) : '' : '';
                requestBd.caseId = saWithCase.containsKey(saRecordId) ? saWithCase.get(saRecordId)!=null ? String.valueOf(saWithCase.get(saRecordId).to15()) : '' : '';
            }
            else {
            // requestBd.jobId = serviceAppointmentMap.containsKey(saRecordId) ? serviceAppointmentMap.get(saRecordId).BLN_Case__c!=null ? String.valueOf(serviceAppointmentMap.get(saRecordId).BLN_Case__c) : '' : '';
            requestBd.jobId = saWithCase.containsKey(saRecordId) ? saWithCase.get(saRecordId)!=null ? String.valueOf(saWithCase.get(saRecordId).to15()) : '' : '';
            }

            requestBd.foStockOrderId = saWithStockOrderNo.containsKey(saRecordId) ?  saWithStockOrderNo.get(saRecordId): '';
            // requestBd.costCenterId = serviceAppointmentMap.containsKey(saRecordId) ? serviceAppointmentMap.get(saRecordId).ServiceTerritory.BLN_CostCenter__c != null ? serviceAppointmentMap.get(saRecordId).ServiceTerritory.BLN_CostCenter__c : '' : '' ;//Required Field or else error in response
            requestBd.costCenterId = fittingLocationId;//Required Field or else error in response
            if(isCPT && !createOrderItemId.isEmpty())
            {
                requestBd.items = createOIList;
            }
            else if(isCPT && !revokeOrederItemId.isEmpty())
            {
                requestBd.itemsClose = revokeOIList;
            }
            else {
                requestBd.itemsCreate = createOIList;
                requestBd.itemsRevoke = revokeOIList;
            }
            payload.add(requestBd);
        }

        BLN_APICalloutMapper__mdt calloutDetails = BLN_APICalloutMapper__mdt.getInstance(System.label.BLN_StocksRequestApi);
        if(isCPT && !createOrderItemId.isEmpty())
        {calloutDetails = BLN_APICalloutMapper__mdt.getInstance(System.label.BLN_StocksCPTApi);}
        else if(isCPT && !revokeOrederItemId.isEmpty())
        {calloutDetails = BLN_APICalloutMapper__mdt.getInstance(System.label.BLN_StocksCPTMovementApi);}

        Map<String,String> headerMap = new Map<String,String>();
        headerMap.put(System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[0],System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[1]+' '+BLN_HTTPCallOutAccessToken.getAccessToken()?.accessToken);
        for(String str : calloutDetails.BLN_Headers__c.split(System.label.BLN_Semicolon)){
            headerMap.put(str.split(System.label.BLN_Comma)[0],str.split(System.label.BLN_Comma)[1]);
        }
        if(payload==null || payload.size()==0){return null;}
        String endPoint = calloutDetails.BLN_NamedCredential__c + calloutDetails.BLN_CalloutURL__c+cpqQuoteId+STOCK_CALL_ENDPOINT_SUFFIX;
        String payloadRequest = JSON.serializePretty(payload, true);
        
        if(isCPT)
        {
            StockWrapper cptPayload = payload[0];
            endpoint = calloutDetails.BLN_NamedCredential__c + calloutDetails.BLN_CalloutURL__c;
            payloadRequest = JSON.serializePretty(cptPayload, true);
        }
        if(payloadRequest!=null && !String.isEmpty(payloadRequest) && !String.isBlank(payloadRequest))
        {
            return BLN_HttpCalloutUtility.makeCallout(calloutDetails.BLN_DestinationSystem__c, endPoint, calloutDetails.BLN_Method__c, headerMap, null, payloadRequest,Integer.valueof(calloutDetails.BLN_APITimeout__c));
        }
    }
    return null;
}

/** Method used for non CPT callouts */
public static HttpResponse makeStockRequestCallout(List<Id> createOrderItemId, List<Id> revokeOrederItemId){
    return makeStockRequestCallout(createOrderItemId, revokeOrederItemId, false);
}

public static HttpResponse makeStockRequestCallout(List<Id> createOrderItemId, List<Id> revokeOrederItemId, Boolean isCPT){
    return makeStockRequestCallout(createOrderItemId, revokeOrederItemId, isCPT, false, null, false);
}
@future(callout = true)
public static void makeStockRequestCalloutForSaUpdate(List<Id> createOrderItemId, List<Id> revokeOrederItemId, Boolean isCPT){
    makeStockRequestCallout(createOrderItemId, revokeOrederItemId, isCPT, false, null, true);
}
    
    public static HttpResponse makeStockRequestCalloutFromPortal(List<Id> createOrderItemId, List<Id> revokeOrederItemId, Boolean isCPT){
        return makeStockRequestCallout(createOrderItemId, revokeOrederItemId, isCPT, false, null, true);
    }

public static HttpResponse makeWorkOrderComplete(List<Id> orderItemList){
    Map<Id, List<ItemsWrapper>> orderWithServiceAppointment = new Map<Id, List<ItemsWrapper>>();
    String cpqQuoteId = '';
    String caseId = '';
    List<StockWrapper> payload = new List<StockWrapper>();    
    
    for(OrderItem orderItemObj : [SELECT Id, OrderId, BLN_ServiceAppointment__c, Order.BLN_Case__c, BLN_StockLineNumber__c,
                                    BLN_StockOrderNumber__c, BLN_FittingLocation__r.BLN_CostCenterCode__c, Product2.BLN_MDMID__c,
                                    BLN_ServiceAppointment__r.ArrivalWindowStartTime, BLN_StockCurrentQuantity__c, Quantity, 
                                    BLN_StockLocation__r.BLN_OrgCodeLocation__c,  BLN_FittingLocation__c, BLN_FittingLocation__r.BLN_OrgCodeLocation__c, BLN_StockLocation__c,
                                    BLN_ServiceAppointment__r.AppointmentNumber,  Order.OrderNumber, BLN_DocumentNumber__c, 
                                    Order.BLN_CPQExternalQuoteId__c, Order.BLN_Case__r.Status, Product2.BLN_SKU__c, BLN_FittingLocation__r.BLN_GUID__c, BLN_StockLocation__r.BLN_GUID__c, BLN_FittingLocation__r.BLN_PrimarySourceCollectId__c, BLN_OutOfStock__c FROM OrderItem 
                                    WHERE Id IN : orderItemList AND BLN_PartOfBundle__c = false AND product2.BLN_MDMID__c !=: Label.BLN_Bundle AND Product2.BLN_ProductStockable__c = TRUE WITH SECURITY_ENFORCED]){
        cpqQuoteId = orderItemObj.OrderId;
        caseId = orderItemObj.Order.BLN_Case__c.to15();
        List<ItemsWrapper> innerOrderItemList = new List <ItemsWrapper>();
        if(orderWithServiceAppointment.containsKey(orderItemObj.BLN_ServiceAppointment__c)){
            innerOrderItemList = orderWithServiceAppointment.get(orderItemObj.BLN_ServiceAppointment__c);
        }
        innerOrderItemList.add(createOrderItemPayload(orderItemObj, ISSUE, false, false));
        orderWithServiceAppointment.put(orderItemObj.BLN_ServiceAppointment__c, innerOrderItemList);
    }
    BLN_APICalloutMapper__mdt calloutDetails = BLN_APICalloutMapper__mdt.getInstance(System.label.BLN_StocksRequestApi);
        
    for(Id serviceAppId : orderWithServiceAppointment.keySet()){
        StockWrapper requestBd = new StockWrapper(); 
        requestBd.jobId = caseId;        
        requestBd.foStockOrderId = serviceAppId;
        requestBd.items = orderWithServiceAppointment.get(serviceAppId);
        requestBd.itemsClose = orderWithServiceAppointment.get(serviceAppId);
        
        Map<String,String> headerMap = new Map<String,String>();
        headerMap.put(Label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[0],System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[1]+' '+BLN_HTTPCallOutAccessToken.getAccessToken()?.accessToken);
        for(String str : calloutDetails.BLN_Headers__c.split(System.label.BLN_Semicolon)){
            headerMap.put(str.split(System.label.BLN_Comma)[0],str.split(System.label.BLN_Comma)[1]);
        }
        if(payload == null || payload.size() == 0){return null;}
        String endPoint = calloutDetails.BLN_NamedCredential__c + calloutDetails.BLN_CalloutURL__c + cpqQuoteId + STOCK_CALL_ENDPOINT_SUFFIX;
        String payloadRequest = JSON.serializePretty(requestBd, true);

        if(payloadRequest!= null && !String.isEmpty(payloadRequest) && !String.isBlank(payloadRequest))
        {
            HttpResponse responseObject = new HttpResponse();
            responseObject = BLN_HttpCalloutUtility.makeCallout(calloutDetails.BLN_DestinationSystem__c, endPoint, calloutDetails.BLN_Method__c, headerMap, null, payloadRequest,Integer.valueOf(calloutDetails.BLN_APITimeout__c));
        }
    }
    return null;
}

    /*****************************************
    MethodName : listOfRecIdStrToSetOfId
    Description : This method will return a Set<Id> converting it from a list of recordIds in String
    Input Parameter : List<String> listOfRecIdinStr
    Output Parameter : Set<Id>
    CreatedDate: 29-05-2024
    CreatedBy : Ayush Kumar Singh (PwC India)
    Change log :
    ****************************************/
    public static Set<Id> listOfRecIdStrToSetOfId(List<String> listOfRecIdinStr){
        Set<Id> setOfIds = new Set<Id>();
        if(!listOfRecIdinStr.isEmpty()){
            for(String str:listOfRecIdinStr){
                setOfIds.add(Id.valueOf(str));
            }
        }
        return setOfIds;
    }

    
    public static void sendWorkOrderComplete(Set<Id> closedCaseIdSet){
        Map<String,List<OrderItem>> saWithorderItemMap = new  Map<String,List<OrderItem>>();
        String cpqQuoteId = '';
        Map<String,String> saIdWithSaNumberMap = new  Map<String,String>();
        Boolean isClosedLost = false;
        String caseId = '';
        List<Id> revokeOrederItemIdList = new List<Id>();
        Order ord = [SELECT Id FROM Order WHERE BLN_Case__c IN: closedCaseIdSet WITH SECURITY_ENFORCED ORDER BY LastModifiedDate DESC LIMIT 1];
        List<OrderItem> orderItemList  = [SELECT Id, BLN_ServiceAppointment__c,BLN_StockLineNumber__c,Quantity,
                                        BLN_ServiceAppointment__r.ArrivalWindowStartTime,BLN_StockCurrentQuantity__c,BLN_UnConsumedQuantity__c	,
                                        BLN_FittingLocation__c, BLN_FittingLocation__r.BLN_OrgCodeLocation__c, BLN_StockLocation__c,BLN_ServiceAppointment__r.AppointmentNumber,
                                        BLN_StockLocation__r.BLN_OrgCodeLocation__c, Order.BLN_ServiceTerritory__r.BLN_CostCenter__c, BLN_FittingLocation__r.BLN_PrimarySourceCollectId__c, 
                                        Product2.BLN_SKU__c,Order.BLN_CPQExternalQuoteId__c, Order.BLN_Case__r.Status, BLN_FittingLocation__r.BLN_GUID__c,order.BLN_Case__c, BLN_StockLocation__r.BLN_GUID__c, BLN_OutOfStock__c, BLN_ServiceAppointment__r.BLN_RebookedServiceAppointment__c, BLN_ServiceAppointment__r.BLN_RebookedServiceAppointment__r.AppointmentNumber FROM OrderItem 
                                        WHERE BLN_IsProductSelected__c = true AND Product2.BLN_ProductStockable__c = TRUE AND OrderId = :ord.Id WITH SECURITY_ENFORCED];
         
        for(OrderItem orderItemRec : orderItemList){
            caseId = orderItemRec.Order.BLN_Case__c.to15();
            List<OrderItem> orderItemRecList = new List<OrderItem>();
            saIdWithSaNumberMap.put(orderItemRec.BLN_ServiceAppointment__c, orderItemRec.BLN_ServiceAppointment__r.AppointmentNumber);
            revokeOrederItemIdList.add(orderItemRec.Id);
            if (orderItemRec?.Order.BLN_CPQExternalQuoteId__c != null) {
                cpqQuoteId = orderItemRec.Order.BLN_CPQExternalQuoteId__c;
            }
            if(saWithorderItemMap.containsKey(orderItemRec.BLN_ServiceAppointment__c)){
                orderItemRecList = saWithorderItemMap.get(orderItemRec.BLN_ServiceAppointment__c);
            }
            orderItemRecList.add(orderItemRec);
            saWithorderItemMap.put(orderItemRec.BLN_ServiceAppointment__c, orderItemRecList);
        }

        for(String saId:saWithorderItemMap.keySet()){
            List<ItemsWrapper> orderItemPayLoadList = new List<ItemsWrapper>();
            StockWrapper stockWrapInst = new  StockWrapper();
            stockWrapInst.jobId = caseId;
            String orderCostCenterId = '';
            if(saIdWithSaNumberMap.containsKey(saId)){
                stockWrapInst.foStockOrderId = saIdWithSaNumberMap.get(saId);
            }
            for (OrderItem ordItem : saWithorderItemMap.get(saId)) {
                orderCostCenterId = ordItem.BLN_FittingLocation__c != null ? ordItem.BLN_FittingLocation__r.BLN_OrgCodeLocation__c : '';
                ItemsWrapper itemRep;
                if (ordItem.order.BLN_Case__r.status == 'Closed-Lost') {                    
                    itemRep =  createOrderItemPayload(ordItem, CANCEL, false, false);
                    isClosedLost = true;
                   
                }else {
                    itemRep =  createOrderItemPayload(ordItem, ISSUE, false, false);
                    isClosedLost = false;
                }
                if (ordItem.BLN_UnConsumedQuantity__c	 != null) {
                    itemRep.actionQuantity = Integer.ValueOf(ordItem?.Quantity - ordItem?.BLN_UnConsumedQuantity__c	 == null ? 0 : ordItem.BLN_UnConsumedQuantity__c	);
                }
                orderItemPayLoadList.add(itemRep);
                
            }
            stockWrapInst.costCenterId = orderCostCenterId;
            stockWrapInst.itemsClose = orderItemPayLoadList;
            if (isClosedLost == true) {
                BLN_QuotesAndStocksAPICallout.makeStockRequestCallout(new List<Id>(), revokeOrederItemIdList, false, false, null, true);
            }else {
                makeCalloutForCaseClose(JSON.serializePretty(stockWrapInst, true),cpqQuoteId);
            }   

        }

    }
    
    public static void makeCalloutForCaseClose(String payloadRequest,  String cpqQuoteId){
        BLN_APICalloutMapper__mdt calloutDetails = BLN_APICalloutMapper__mdt.getInstance(System.label.BLN_StocksCPTMovementApi);      
        Map<String,String> headerMap = new Map<String,String>();
        headerMap.put(System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[0],System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[1]+' '+BLN_HTTPCallOutAccessToken.getAccessToken()?.accessToken);
        for(String str : calloutDetails.BLN_Headers__c.split(System.label.BLN_Semicolon)){
            headerMap.put(str.split(System.label.BLN_Comma)[0],str.split(System.label.BLN_Comma)[1]);
        }

        String endPoint = calloutDetails.BLN_NamedCredential__c + calloutDetails.BLN_CalloutURL__c;
        if(payloadRequest!=null && !String.isEmpty(payloadRequest) && !String.isBlank(payloadRequest)){
            HttpResponse resp = new HttpResponse();
            resp = BLN_HttpCalloutUtility.makeCallout(calloutDetails.BLN_DestinationSystem__c, endPoint, calloutDetails.BLN_Method__c, headerMap, 'CPQ External Id : '+cpqQuoteId, payloadRequest,Integer.valueOf(calloutDetails.BLN_APITimeout__c));
        }
    }

    Public static string makeStockRequestCalloutforStockCollect(List<Id> createOrderItemList,List<Id>revokeOrederItemIdList,  Map<String, String> orderitemLocationMap,  Map<String, String> productWithSA, String manuallCollectFlagMap){
        String cpqQuoteId = '';
        Map<String, HttpResponse> resList = new Map<String,HttpResponse>();
        List<OrderItem> orderItemListtoUpdate = new List<OrderItem>();
        Map<String, String> flagMap = (Map<String, String>) JSON.deserializeStrict(manuallCollectFlagMap, Map<String, String>.class); 
        Map<String, Boolean> collectFlagMap = new Map <String, Boolean>();

        String caseId = '';
        List<OrderItem> orderItemList  = [SELECT Id, BLN_ServiceAppointment__c,BLN_StockLineNumber__c,Quantity,
                                        BLN_ServiceAppointment__r.ArrivalWindowStartTime,BLN_StockCurrentQuantity__c,BLN_UnConsumedQuantity__c	,BLN_ServiceAppointment__r.BLN_RebookedServiceAppointment__c,
                                        BLN_FittingLocation__c, BLN_FittingLocation__r.BLN_OrgCodeLocation__c, BLN_StockLocation__c,BLN_ServiceAppointment__r.AppointmentNumber,
                                        BLN_StockLocation__r.BLN_OrgCodeLocation__c, Order.BLN_ServiceTerritory__r.BLN_CostCenter__c, BLN_FittingLocation__r.BLN_PrimarySourceCollectId__c, 
                                        Product2.BLN_SKU__c,Product2.BLN_MDMID__c,BLN_StockOrderNumber__c,Order.BLN_CPQExternalQuoteId__c,BLN_DocumentNumber__c, Order.BLN_Case__r.Status, BLN_FittingLocation__r.BLN_GUID__c,order.BLN_Case__c, BLN_StockLocation__r.BLN_GUID__c, BLN_OutOfStock__c FROM OrderItem 
                                        WHERE order.Status = 'Accepted' AND BLN_IsProductSelected__c = true AND Product2.BLN_ProductStockable__c = TRUE AND (Id IN :createOrderItemList  OR Id IN :revokeOrederItemIdList) WITH SECURITY_ENFORCED];
        
        Map<String, Schema.Location> orgcodelocationIdWithLocMap = new Map<String, Schema.Location>();
        Map<String,String>saIDWithSANumberMap = new Map<String,String>();
        for(String oderItmId : flagMap.keySet()){
            collectFlagMap.put(oderItmId,Boolean.valueOf(flagMap.get(oderItmId)));
        }
        for (ServiceAppointment	 sa : [SELECT Id,AppointmentNumber FROM ServiceAppointment	 WHERE Id IN : productWithSA.values() WITH SECURITY_ENFORCED]) {
            saIDWithSANumberMap.put(sa.Id, sa.AppointmentNumber);
        }      

        for(Schema.Location loc : [SELECT Id,Name, BLN_GUID__c, BLN_OrgCodeLocation__c FROM Location WHERE BLN_OrgCodeLocation__c IN : orderitemLocationMap.values() WITH SECURITY_ENFORCED]) {   
            orgcodelocationIdWithLocMap.put(loc.BLN_OrgCodeLocation__c, loc);
        }

        
        for(OrderItem oitemRec: orderItemList){           
            if(oitemRec.Order.BLN_CPQExternalQuoteId__c != null){
                cpqQuoteId = oitemRec.Order.BLN_CPQExternalQuoteId__c;
                break;
            }
        }
        List<String> stockAdjustpayloadList = new List<String>();
        for(OrderItem oi:orderItemList){
            List<StockAdjustPayloadWrapper> stockInnerpayloadList = new List<StockAdjustPayloadWrapper>();
            StockAdjustPayloadWrapper stockWrap = new StockAdjustPayloadWrapper();
            stockWrap.jobId = oi.Order.BLN_Case__c;
            stockWrap.foStockOrderId = oi.BLN_StockOrderNumber__c;
            stockWrap.costCenterId = oi.BLN_FittingLocation__r.BLN_OrgCodeLocation__c;
            ItemsWrapper item = new ItemsWrapper();
            List<ItemsWrapper> itemsCreate = new List<ItemsWrapper>();
            List<ItemsWrapper> itemsRevoke = new List<ItemsWrapper>();          
            if(createOrderItemList.contains(oi.Id) && productWithSA.containsKey(oi.Product2.BLN_MDMID__c)){
               item = createOrderItemPayload(oi, REQUISITION, false, false); 
                
                String  newLocGUID = orderitemLocationMap.containsKey(oi.Id)?orderitemLocationMap.get(oi.Id):'';  
                item.stockLocationOrganizationId = newLocGUID;
                if(collectFlagMap.containsKey(oi.Id) && collectFlagMap.get(oi.Id) == true){
                    item.collectionFlag = 'Y';
                }
                OrderItem orItem = new OrderItem();
                
                orItem.Id = oi.Id;
                orItem.BLN_StockLocation__c = orgcodelocationIdWithLocMap.containsKey(newLocGUID)?orgcodelocationIdWithLocMap.get(newLocGUID).Id:'';
                orderItemListtoUpdate.add(orItem);
                if( oi.BLN_FittingLocation__r.BLN_OrgCodeLocation__c == newLocGUID ){
                    item.actionType = RESERVE;
                }
                else{
                    item.actionType = REQUISITION;
                }              
                itemsCreate.add(item);
            }
            if(revokeOrederItemIdList.contains(oi.Id)){
                item = createOrderItemPayload(oi, CANCEL, false, false);  
                itemsRevoke.add(item);
            }         
            stockWrap.itemsRevoke = itemsRevoke;
            stockWrap.itemsCreate = itemsCreate;            
            stockInnerpayloadList.add(stockWrap); // final Payload for stock movement
            stockAdjustpayloadList.add(JSON.serializePretty(stockInnerpayloadList));
        }

        if(stockAdjustpayloadList==null || stockAdjustpayloadList.size()==0){return null;}
        BLN_APICalloutMapper__mdt calloutDetails = BLN_APICalloutMapper__mdt.getInstance(System.label.BLN_StocksRequestApi);
        String endPoint = calloutDetails.BLN_NamedCredential__c + calloutDetails.BLN_CalloutURL__c+cpqQuoteId+STOCK_CALL_ENDPOINT_SUFFIX;
        Map<String,String> headerMap = new Map<String,String>();
            headerMap.put(System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[0],System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[1]+' '+BLN_HTTPCallOutAccessToken.getAccessToken()?.accessToken);
        for(String str : calloutDetails.BLN_Headers__c.split(System.label.BLN_Semicolon)){
            headerMap.put(str.split(System.label.BLN_Comma)[0],str.split(System.label.BLN_Comma)[1]);
        }

        for(String eachPayload: stockAdjustpayloadList)   {
            HttpResponse response = new HttpResponse();
            String payloadRequest = eachPayload;
            if(payloadRequest!=null && !String.isEmpty(payloadRequest) && !String.isBlank(payloadRequest)){
                response = BLN_HttpCalloutUtility.makeCallout(false, calloutDetails.BLN_DestinationSystem__c, endPoint, calloutDetails.BLN_Method__c, headerMap, null, payloadRequest,Integer.valueof(calloutDetails.BLN_APITimeout__c));
                resList.put(payloadRequest, response);
            }
        }
        List<BLN_IntegrationLogger__c> loggerList = new List<BLN_IntegrationLogger__c>();
        for(String res: resList.keySet()){
            BLN_IntegrationLogger__c loggerRecord = new BLN_IntegrationLogger__c();
            String header = '';        
            //assignment of request details
            loggerRecord.BLN_RequestBody__c = res;
            loggerRecord.BLN_RequestEndPoint__c = endPoint;
            loggerRecord.BLN_RequestIssuedBy__c = UserInfo.getUserId();
            loggerRecord.BLN_RequestMethod__c = calloutDetails.BLN_Method__c;
            loggerRecord.BLN_RequestSent__c = System.now();
            loggerRecord.BLN_ResponseBody__c = resList.get(res).getBody().length() <= BLN_IntegrationLogger__c.BLN_ResponseBody__c.getDescribe().length ? resList.get(res).getBody() : resList.get(res).getBody().subString(0,BLN_IntegrationLogger__c.BLN_ResponseBody__c.getDescribe().length - 1);
            header = '';
            for(String keyVal : resList.get(res).getHeaderkeys()){header += keyVal+' '+resList.get(res).getHeader(keyVal)+'  ';}
            loggerRecord.BLN_ResponseHeaders__c = header;
            loggerRecord.BLN_ResponseStatusCode__c = String.valueOf(resList.get(res).getStatusCode());
            loggerRecord.BLN_ResponseStatus__c = resList.get(res).getStatus();
            loggerRecord.BLN_TargetSystem__c = calloutDetails.BLN_DestinationSystem__c;
            loggerList.add(loggerRecord);
        }

        if(orderItemListtoUpdate!=null && Schema.sObjectType.OrderItem.isUpdateable()){
            update orderItemListtoUpdate;
        }
        if(loggerList!=null && Schema.sObjectType.BLN_IntegrationLogger__c.isCreateable()){
            Database.insert(loggerList,false);
        }
        return '';
                                        
    }


 
    public class StockAdjustPayloadWrapper{
		public String jobId{get;set;}
		public String foStockOrderId {get;set;}
		public String costCenterId {get;set;}
		public List<ItemsWrapper> itemsCreate{get;set;} // commenting as asked by Jon/Rahul S
		public List<ItemsWrapper> itemsRevoke{get;set;}
	}

    public class StockWrapper{
        public String caseId{get;set;}
        public String jobId{get;set;}
		public String foStockOrderId {get;set;}
		public String costCenterId {get;set;}
		public List<ItemsWrapper> itemsCreate{get;set;}
		public List<ItemsWrapper> itemsRevoke{get;set;}
        public List<ItemsWrapper> items{get;set;}
        public List<ItemsWrapper> itemsClose{get;set;}
    }

	public class ItemsWrapper {
		public String lineId{get;set;}
		public String itemId{get;set;}
		public String stockLocationOrganizationId{get;set;}
		public Integer currentQuantity{get;set;}
		public Integer actionQuantity{get;set;}
		public String requiredByDateTime{get;set;}
		public String collectionFlag{get;set;}
		public String actionType{get;set;}
	}

    public class RepricePayloadWrapper {
		public String id;
		public Decimal discount;
		public String afterHours;
		public List<RepriceLineItem> lineItems;
		public String caseId;
		public String chfVATStatus;
	}

	public class RepriceLineItem {
		public String lineId;
		public Integer quantity;
		public Boolean selectProduct;
	}


}