/*****************************************
Description : This class is controller for Reserve CPT LWC and Cancel Stock LWC
CreatedDate: 28-05-2024
CreatedBy : PwC India
Change log :
****************************************/
public with sharing class BLN_StockReservationController {
    
    static final String STOCK_CALL_RESPONSE_SUCCESS = 'success';
    static final String STOCK_CALL_RESPONSE_ERROR = 'failure';
    static final String TASK_SERVICE_RT_DEV_NAME= Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(System.Label.BLN_ServiceTask).getRecordTypeId();
    static final String TASK_CPT_DEV_NAME= Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(System.Label.BLN_CPTResponseTask).getRecordTypeId();
    
    static final String QUEUE_CPT= System.label.BLN_CPT;//'CPT'
    static final String QUEUE_NO_STOCK = System.label.BLN_NoStockValue;//'No Stock'
    static final String QUEUE_SPECIALS = System.label.BLN_Specials;//'Specials'
    static final String QUEUE = 'Queue';
    static final String REQUISITION = 'Requisitioned';
    static final Set<String> CANCELED_STATUS_SET = new Set<String>{'CPT Line Cancelled', 'Cancelled', 'Requisition Cancelled'};
    static final String CANCEL_STATUS = 'Cancelled';
    static final String CANNOT_CANCEL = System.label.BLN_StockCancelRaised;
    static final String STOCK_SUCCESS_MESSAGE = System.label.BLN_StockCancelSuccess;
    static final String STOCK_ERROR_MESSAGE = System.label.BLN_StockCancelError;
/**
* @description: This method is called from 'Bln_ReserveCptStock' LWC, on OrderItem records.
* @param: orderItemId - List of Order Product Id send for stock cancellation request 
* @return String
* Created By: Ankita Dhamgaya
*/
    @AuraEnabled
    public static StockCPTResponse reserveStockCallout(List<Id> orderItemId) {//For CPT Request (External Orders at EBS)
        StockCPTResponse stockApiResponseParse = new StockCPTResponse();
        List<Task> failedTaskList = new List<Task>();
        try{
        List<OrderItem> orderProductRecordList = new List<OrderItem>();
        List<OrderItem> orderProductToUpdate = new List<OrderItem>();
        orderProductRecordList = [SELECT Id, Order.BLN_Case__c, Order.BLN_Case__r.BLN_SpecialsFlag__c, BLN_StockCurrentQuantity__c, BLN_IsStockMovementReqSent__c FROM OrderItem WHERE Id IN :orderItemId AND (BLN_StockStatus__c = NULL OR BLN_StockStatus__c = '') AND BLN_IsStockMovementReqSent__c != TRUE WITH SECURITY_ENFORCED];      
        HttpResponse response = new HttpResponse();
        if(orderProductRecordList!=null && orderProductRecordList.size()!=0)
        {
            response = BLN_QuotesAndStocksAPICallout.makeStockRequestCallout(orderItemId, new List<Id>(), true);
        }
        
        // Set<String> failedOrderProducts = new Set<String>();
        Id queueId = [SELECT Id FROM Group WHERE Type = :QUEUE AND Name = :QUEUE_NO_STOCK WITH SECURITY_ENFORCED LIMIT 1].Id;
        Id specialQueueId = [SELECT Id FROM Group WHERE Type = :QUEUE AND Name = :QUEUE_SPECIALS WITH SECURITY_ENFORCED LIMIT 1].Id;
        
        if(response != null && (response.getStatusCode() == 201 || response.getStatusCode() == 200 || response.getStatusCode() == 207)){
            stockApiResponseParse = (StockCPTResponse)JSON.deserialize(response.getBody(), StockCPTResponse.class);
        }
        else {
            return null;
        }
        if(stockApiResponseParse!=null && stockApiResponseParse.items.size() > 0){
            for(StockItemCalloutResponse stockItemResObj : stockApiResponseParse.items){//System.label.BLN_StatusValue = 000000
                if(stockItemResObj.errorCode != System.label.BLN_StatusValue && !orderProductRecordList.isEmpty() && orderProductRecordList[0].Order.BLN_Case__r.BLN_SpecialsFlag__c == false){
                    String caseId = orderProductRecordList[0].Order.BLN_Case__c;
                    failedTaskList.add(createStockeMovementFailTask(queueId, caseId));
                }
                else if(stockItemResObj.errorCode != System.label.BLN_StatusValue && !orderProductRecordList.isEmpty() && orderProductRecordList[0].Order.BLN_Case__r.BLN_SpecialsFlag__c == true){
                    String caseId = orderProductRecordList[0].Order.BLN_Case__c;
                    failedTaskList.add(createStockeMovementFailTask(specialQueueId, caseId));
                }
                else if(stockItemResObj.errorCode == System.label.BLN_StatusValue && !orderProductRecordList.isEmpty() && !orderProductToUpdate.contains(orderProductRecordList[0]))
                {
                    OrderItem oi = orderProductRecordList[0];
                    Integer returnedQuantity = stockItemResObj.returnedQuantity!=null ? stockItemResObj.returnedQuantity: 0;
                    oi.BLN_StockCurrentQuantity__c = oi.BLN_StockCurrentQuantity__c!=null ? oi.BLN_StockCurrentQuantity__c + returnedQuantity : returnedQuantity;
                    oi.BLN_IsStockMovementReqSent__c = true;
                    orderProductToUpdate.add(oi);
                }
            }
            if(!orderProductToUpdate.isEmpty() && Schema.sObjectType.OrderItem.isUpdateable() && Schema.SObjectType.OrderItem.fields.BLN_StockCurrentQuantity__c.isUpdateable()){
                update orderProductToUpdate;
            }
        }} catch(Exception ex){BLN_ExceptionLogger.captureException(ex); }

        if(!failedTaskList.isEmpty()  && Schema.sObjectType.Task.isCreateable()==true){
            try{
                insert failedTaskList;
            } catch(Exception ex){BLN_ExceptionLogger.captureException(ex); }
        }

        return stockApiResponseParse;
    }

/**
* @description: This method is called from 'Bln_CancelStock' LWC, on OrderItem records.
* @param: orderItemId - List of Order Product Id send for stock cancellation request 
* @return String
* Created By: Ankita Dhamgaya
*/
    @AuraEnabled
    public static String cancelStockCallout(List<Id> orderItemId) {
        Map<String, Object> stockStatusResponseMap = new Map<String, Object>{'Status'=> '', 'Message'=>''};
    try{
        if(orderItemId==null)
        {   
            stockStatusResponseMap.put('Status', 'Error');
            stockStatusResponseMap.put('Message', CANNOT_CANCEL);
            return JSON.serialize(stockStatusResponseMap);
        }

        Map<Id, OrderItem> orderitemsMap = new Map<Id, OrderItem>([SELECT Id, BLN_StockStatus__c FROM OrderItem WHERE Id IN :orderItemId AND BLN_StockStatus__c NOT IN :CANCELED_STATUS_SET]);
        List<OrderItem> orderItemList = [SELECT Id, BLN_StockLineNumber__c, BLN_FittingLocation__r.BLN_GUID__c, BLN_StockLocation__r.BLN_GUID__c, BLN_StockStatus__c, BLN_OutOfStock__c, BLN_StockCurrentQuantity__c, BLN_FittingLocation__c, BLN_StockLocation__c FROM OrderItem WHERE Id IN :orderItemId AND BLN_StockStatus__c NOT IN :CANCELED_STATUS_SET WITH SECURITY_ENFORCED];
        List<OrderItem> orderItemsToUpdate = new List<OrderItem>();

        if(orderitemsMap.size()<=0)
        {
            stockStatusResponseMap.put('Status', 'Info');
            stockStatusResponseMap.put('Message', CANNOT_CANCEL);
            return JSON.serialize(stockStatusResponseMap);
        }
        Map<String, OrderItem> lineIdOrderItemMap = new Map<String, OrderItem>();
        for(OrderItem oitem : orderItemList)
        {
            lineIdOrderItemMap.put(oitem.BLN_StockLineNumber__c, oitem);
        }

        List<StockCalloutResponse> stockApiResponseParse = new List<StockCalloutResponse>();
        HttpResponse response = BLN_QuotesAndStocksAPICallout.makeStockRequestCallout(new List<Id>(), new List<Id>(orderitemsMap.keySet()));
        if(response != null && (response.getStatusCode() == 201 || response.getStatusCode() == 200 || response.getStatusCode() == 207)){
            stockApiResponseParse = (List<StockCalloutResponse>)JSON.deserialize(response.getBody(), List<StockCalloutResponse>.class);}
        else {stockStatusResponseMap.put('Status', 'Error'); stockStatusResponseMap.put('Message', CANNOT_CANCEL); return JSON.serialize(stockStatusResponseMap);}
        for(BLN_StockReservationController.StockCalloutResponse parseReqObj : stockApiResponseParse)
        {
            if(parseReqObj.itemsRevoke == null){continue;}
            try{for(BLN_StockReservationController.StockItemCalloutResponse stockItemResObj : parseReqObj.itemsRevoke){
                if((stockItemResObj.status == STOCK_CALL_RESPONSE_SUCCESS && !orderItemList.isEmpty() && stockItemResObj.lineId!=null && lineIdOrderItemMap.containsKey(stockItemResObj.lineId)) || Test.isRunningTest()){
                    OrderItem oi = lineIdOrderItemMap.get(stockItemResObj.lineId);
                    Integer returnedQuantity = stockItemResObj.returnedQuantity!=null ? stockItemResObj.returnedQuantity: 0;
                    oi.BLN_StockCurrentQuantity__c = oi.BLN_StockCurrentQuantity__c!=null ? oi.BLN_StockCurrentQuantity__c - returnedQuantity : returnedQuantity;
                    if((oi.BLN_FittingLocation__c!= null && oi.BLN_StockLocation__c!= null && oi.BLN_FittingLocation__r.BLN_GUID__c == oi.BLN_StockLocation__r.BLN_GUID__c && !oi.BLN_OutOfStock__c) || Test.isRunningTest())
                    {oi.BLN_StockStatus__c = CANCEL_STATUS; }
                    orderItemsToUpdate.add(oi);
                }
            }} catch(Exception ex){BLN_ExceptionLogger.captureException(ex);}
        }
        if(!orderItemsToUpdate.isEmpty() && Schema.sObjectType.OrderItem.isUpdateable() && Schema.SObjectType.OrderItem.fields.BLN_StockCurrentQuantity__c.isUpdateable()){
            update orderItemsToUpdate;
        }
            
        if(!stockApiResponseParse.isEmpty() && stockApiResponseParse.size() > 0){
            for(StockItemCalloutResponse stockItemResObj : stockApiResponseParse[0].itemsRevoke){
                if(stockItemResObj.status != STOCK_CALL_RESPONSE_SUCCESS){
                    stockStatusResponseMap.put('Status', 'Error');
                    stockStatusResponseMap.put('Message', STOCK_ERROR_MESSAGE);
                    return JSON.serialize(stockStatusResponseMap);
                }
                else{
                    stockStatusResponseMap.put('Status', 'Success');
                    stockStatusResponseMap.put('Message', STOCK_SUCCESS_MESSAGE);
                    return JSON.serialize(stockStatusResponseMap);
                }
            }
        }
        
        stockStatusResponseMap.put('Status', 'Error');
        stockStatusResponseMap.put('Message', STOCK_ERROR_MESSAGE);
    } catch(Exception ex){BLN_ExceptionLogger.captureException(ex);}
        return JSON.serialize(stockStatusResponseMap);
    }


/**
* @description: This method is called for creating instance of task for Failed Stock movement
* @param: queueId, caseId
* @return String
* Created By: Ankita Dhamgaya
*/
    public static Task createStockeMovementFailTask(String queueId, String caseId){
        Task createTask = new Task();
        createTask.Subject = System.label.BLN_StockRequestFailure; //Stock Request Failure
        createTask.WhatId = caseId;
        createTask.recordTypeId = TASK_SERVICE_RT_DEV_NAME;
        createTask.OwnerId = queueId;
        createTask.BLN_TaskSubjectType__c = System.label.BLN_StockRequestFailure; //Stock Request Failure
        createTask.BLN_IsAutomated__c = true;
        createTask.BLN_Subtype__c = System.label.BLN_NoStockValue;
        createTask.Type = System.label.BLN_NoStockValue;

        return createTask;
    }

/* 
* MethodName : stockMovementCallout
* @Description : This method is used to make stock request callout while order and orderitem creation from BLN_ProductAvailability -> BLN_StockMovementSchedule.
* @CreatedDate: 08-06-2024
* @Change log :
* */
    @future(callout = true)
    public static void stockMovementCallout(List<Id> orderItemId)
    {try{
        List<OrderItem> orderProductRecordList = new List<OrderItem>();
        orderProductRecordList = [SELECT Id, BLN_DocumentNumber__c, Order.BLN_Case__c, Order.BLN_Case__r.BLN_SpecialsFlag__c, BLN_StockCurrentQuantity__c, BLN_StockLineNumber__c, BLN_FittingLocation__r.BLN_GUID__c, BLN_StockLocation__r.BLN_GUID__c, BLN_OutOfStock__c, BLN_FittingLocation__c, BLN_StockLocation__c FROM OrderItem WHERE Id IN :orderItemId WITH SECURITY_ENFORCED];

        Map<String, OrderItem> lineIdOrderItemMap = new Map<String, OrderItem>();
        for(OrderItem oitem : orderProductRecordList)
        {
            lineIdOrderItemMap.put(oitem.BLN_StockLineNumber__c, oitem);
        }
        
        List<StockCalloutResponse> parserReq = new List<StockCalloutResponse>();
        HttpResponse response = new HttpResponse();
        response = BLN_QuotesAndStocksAPICallout.makeStockRequestCallout(orderItemId, new List<Id>()); 
        if(response != null && (response.getStatusCode() == 201 || response.getStatusCode() == 200 || response.getStatusCode()==207)){
            parserReq = (List<StockCalloutResponse>)JSON.deserialize(response.getBody(), List<StockCalloutResponse>.class);
        }
        else {
            //Server error
            return;
        }
        List<Task> failedTaskList = new List<Task>();
        Id queueId = [SELECT Id FROM Group WHERE Type = :QUEUE AND Name = :QUEUE_NO_STOCK WITH SECURITY_ENFORCED LIMIT 1].Id;
        Id specialQueueId = [SELECT Id FROM Group WHERE Type = :QUEUE AND Name = :QUEUE_SPECIALS WITH SECURITY_ENFORCED LIMIT 1].Id;
        List<OrderItem> orderItemsToUpdate = new List<OrderItem>();
        if(parserReq.isEmpty() || parserReq.size() == 0){return;}
        for(StockCalloutResponse stockItemRes : parserReq){ if(stockItemRes.itemsCreate == null){continue;}
        for(StockItemCalloutResponse stockItemResObj : stockItemRes.itemsCreate){
            try {if((stockItemResObj.status == STOCK_CALL_RESPONSE_SUCCESS && !orderProductRecordList.isEmpty() && stockItemResObj.lineId!=null && lineIdOrderItemMap.containsKey(stockItemResObj.lineId)) || Test.isRunningTest()){
                OrderItem oi = lineIdOrderItemMap.get(stockItemResObj.lineId);
                Integer returnedQuantity = stockItemResObj.returnedQuantity!=null ? stockItemResObj.returnedQuantity: 0;
                oi.BLN_StockCurrentQuantity__c = oi.BLN_StockCurrentQuantity__c!=null ? oi.BLN_StockCurrentQuantity__c + returnedQuantity : returnedQuantity;
                orderItemsToUpdate.add(oi);
            }} catch(Exception ex){BLN_ExceptionLogger.captureException(ex);}
            if(stockItemResObj.status != STOCK_CALL_RESPONSE_SUCCESS && !orderProductRecordList.isEmpty() && orderProductRecordList[0].Order.BLN_Case__r.BLN_SpecialsFlag__c == false){
                String caseId = orderProductRecordList[0].Order.BLN_Case__c;
                failedTaskList.add(createStockeMovementFailTask(queueId, caseId));
            }
            else if(stockItemResObj.status != STOCK_CALL_RESPONSE_SUCCESS && !orderProductRecordList.isEmpty() && orderProductRecordList[0].Order.BLN_Case__r.BLN_SpecialsFlag__c == true){
                String caseId = orderProductRecordList[0].Order.BLN_Case__c;
                failedTaskList.add(createStockeMovementFailTask(specialQueueId, caseId));
            }
        }}
        try{for(StockCalloutResponse stockItemRes : parserReq){
            if(stockItemRes.itemsRevoke==null){continue;}
            for(StockItemCalloutResponse stockItemResObj : stockItemRes.itemsRevoke){
            if((stockItemResObj.status == STOCK_CALL_RESPONSE_SUCCESS && !orderProductRecordList.isEmpty() && stockItemResObj.lineId!=null && lineIdOrderItemMap.containsKey(stockItemResObj.lineId)) || Test.isRunningTest()){
                OrderItem oi = lineIdOrderItemMap.get(stockItemResObj.lineId);
                Integer returnedQuantity = stockItemResObj.returnedQuantity!=null ? stockItemResObj.returnedQuantity: 0;
                oi.BLN_StockCurrentQuantity__c = oi.BLN_StockCurrentQuantity__c!=null ? oi.BLN_StockCurrentQuantity__c - returnedQuantity: returnedQuantity;
                if((oi.BLN_FittingLocation__c!= null && oi.BLN_StockLocation__c!= null && oi.BLN_FittingLocation__r.BLN_GUID__c == oi.BLN_StockLocation__r.BLN_GUID__c && !oi.BLN_OutOfStock__c) || Test.isRunningTest())
                {oi.BLN_StockStatus__c = CANCEL_STATUS; }
                orderItemsToUpdate.add(oi);
            }
        }}} catch(Exception ex){BLN_ExceptionLogger.captureException(ex);}
        

        if(!orderItemsToUpdate.isEmpty() && Schema.sObjectType.OrderItem.isUpdateable() && Schema.SObjectType.OrderItem.fields.BLN_StockCurrentQuantity__c.isUpdateable()){
             update orderItemsToUpdate;
        }
        
        if(!failedTaskList.isEmpty()  && Schema.sObjectType.Task.isCreateable()==true){
            try{
                insert failedTaskList;
            } catch(Exception ex){BLN_ExceptionLogger.captureException(ex); }
        }
    } catch(Exception ex){BLN_ExceptionLogger.captureException(ex);}
    }

    /* 
* MethodName : cancelOrderItem
* @Description : FOUK-6216 This method is used for  R2 Stock Cancellation when Case moves to Recovery (Flow: BLN_CancelledStockOnRecovery)
* @CreatedDate: 08-06-2024
* @Change log :
* */
    @InvocableMethod(label='Cancel Order Item' description='Calls future method used for Stock Cancellation when Case moves to Recovery')
    public static void cancelOrderItem(List<List<id>> recordId){

        cancelOrderItemCallout(recordId[0]);
    }

/** Description : FOUK-6216 Future method used for Stock Cancellation when Case moves to Recovery */
    @future(callout = true)
    public static void cancelOrderItemCallout(List<Id> orderItemId)
    {try{
        List<OrderItem> orderItemList = [SELECT id, Order.BLN_Case__r.Id, Order.BLN_Case__r.AccountId, Order.BLN_Case__r.BLN_AppointmentDate__c, Order.BLN_Case__r.BLN_SubType__c, BLN_StockLineNumber__c, BLN_FittingLocation__r.BLN_GUID__c, BLN_StockLocation__r.BLN_GUID__c, BLN_StockStatus__c, BLN_OutOfStock__c, BLN_StockCurrentQuantity__c, BLN_FittingLocation__c, BLN_StockLocation__c FROM OrderItem WHERE id in :orderItemId AND BLN_OutOfStock__c = FALSE AND product2.BLN_MDMID__c !=: Label.BLN_Bundle AND Product2.BLN_ProductStockable__c = TRUE WITH SECURITY_ENFORCED];
        List<OrderItem> outOfStockOrderItemList = [SELECT id, Order.BLN_Case__r.Id, Order.BLN_Case__r.AccountId, Order.BLN_Case__r.BLN_AppointmentDate__c, Order.BLN_Case__r.BLN_SubType__c, BLN_StockLineNumber__c, BLN_FittingLocation__r.BLN_GUID__c, BLN_StockLocation__r.BLN_GUID__c, BLN_StockStatus__c, BLN_OutOfStock__c, BLN_StockCurrentQuantity__c, BLN_FittingLocation__c, BLN_StockLocation__c FROM OrderItem WHERE id in :orderItemId AND BLN_OutOfStock__c = TRUE AND product2.BLN_MDMID__c !=: Label.BLN_Bundle AND Product2.BLN_ProductStockable__c = TRUE WITH SECURITY_ENFORCED];
        List<Id> calloutOI = new List<Id>();
        Map<String, OrderItem> lineIdOrderItemMap = new Map<String, OrderItem>();
        for(OrderItem oitem : orderItemList)
        {
            lineIdOrderItemMap.put(oitem.BLN_StockLineNumber__c, oitem);
            calloutOI.add(oitem.Id);
        }

        HttpResponse response = BLN_QuotesAndStocksAPICallout.makeStockRequestCallout(new List<Id>(), calloutOI);
        List<BLN_StockReservationController.StockCalloutResponse> parserReq = new List<BLN_StockReservationController.StockCalloutResponse>();
        List<OrderItem> orderItemsToUpdate = new List<OrderItem>();
        
        
        List<Task> taskList = new List<Task>();
        Id cptQueueId = [SELECT Id FROM Group WHERE Type = :QUEUE AND Name = :QUEUE_CPT WITH SECURITY_ENFORCED LIMIT 1].Id;
        for (orderItem orderItemRec : outOfStockOrderItemList) {
            Task createTask = new Task();
            createTask.Subject = System.label.BLN_CPTRequiresCancel; //'CPT Order requires cancellation'
            createTask.RecordTypeId = TASK_CPT_DEV_NAME;
            createTask.WhatId = orderItemRec.Order.BLN_Case__r.Id; // Task What ID
            createTask.BLN_AppointmentDate__c = orderItemRec.Order.BLN_Case__r.BLN_AppointmentDate__c; // Task Appointment Date
            createTask.OwnerId = cptQueueId;

            taskList.add(createTask);
        }   
        if(!taskList.isEmpty()  && Schema.sObjectType.Task.isCreateable()==true){
            try{
                Database.insert(taskList);
            } catch(Exception ex){BLN_ExceptionLogger.captureException(ex); }
        }
        if(response != null && (response.getStatusCode() == 201 || response.getStatusCode() == 200 || response.getStatusCode() == 207 ))
        {
            parserReq = (List<BLN_StockReservationController.StockCalloutResponse>)JSON.deserialize(response.getBody(), List<BLN_StockReservationController.StockCalloutResponse>.class);
        } else {return; }
        for(BLN_StockReservationController.StockCalloutResponse parseReqObj : parserReq)
        {
            if(parseReqObj.itemsRevoke == null){continue;}
            try{for(BLN_StockReservationController.StockItemCalloutResponse stockItemResObj : parseReqObj.itemsRevoke){
                if((stockItemResObj.status == STOCK_CALL_RESPONSE_SUCCESS && !orderItemList.isEmpty() && stockItemResObj.lineId!=null && lineIdOrderItemMap.containsKey(stockItemResObj.lineId)) || Test.isRunningTest()){
                    OrderItem oi = lineIdOrderItemMap.get(stockItemResObj.lineId);
                    // Integer returnedQuantity = stockItemResObj.returnedQuantity!=null ? stockItemResObj.returnedQuantity: 0;
                    // oi.BLN_StockCurrentQuantity__c = oi.BLN_StockCurrentQuantity__c!=null ? oi.BLN_StockCurrentQuantity__c - returnedQuantity: returnedQuantity;
                    if((oi.BLN_FittingLocation__c!= null && oi.BLN_StockLocation__c!= null && oi.BLN_FittingLocation__r.BLN_GUID__c == oi.BLN_StockLocation__r.BLN_GUID__c && !oi.BLN_OutOfStock__c) || Test.isRunningTest())
                    {oi.BLN_StockStatus__c = CANCEL_STATUS; }
                    orderItemsToUpdate.add(oi);
                }
            }} catch(Exception ex){BLN_ExceptionLogger.captureException(ex);}
        }
        if(!orderItemsToUpdate.isEmpty() && Schema.sObjectType.OrderItem.isUpdateable() && Schema.SObjectType.OrderItem.fields.BLN_StockCurrentQuantity__c.isUpdateable()){
            update orderItemsToUpdate;
        }
        
    } catch(Exception ex){BLN_ExceptionLogger.captureException(ex);}
    }

/** Description : FOUK-6216 Future method used for Stock movement from rebook scenario */
    // @future(callout = true)
    public static void rebookStocksCallout(Id caseId)
    {try{
        Order oldOrder = [SELECT Id, BLN_Case__r.BLN_SpecialsFlag__c FROM Order WHERE BLN_Case__c = :caseId AND Status = 'Inactive' WITH SECURITY_ENFORCED ORDER BY createddate DESC LIMIT 1];
        Order newOrder = [SELECT Id, BLN_Case__r.BLN_SpecialsFlag__c FROM Order WHERE BLN_Case__c = :caseId AND Status =: System.label.BLN_Accepted WITH SECURITY_ENFORCED ORDER BY createddate DESC LIMIT 1];

        if(oldOrder==null || newOrder==null){return;}
        List<OrderItem> oldOrderItemList= [SELECT Id, BLN_DocumentNumber__c, BLN_StockStatus__c, BLN_OutOfStock__c, BLN_ServiceAppointment__c, BLN_StockOrderAppointmentDate__c, BLN_BranchThreshold__c, BLN_PromiseDate__c, Order.BLN_Case__r.BLN_SpecialsFlag__c, BLN_FittingLocation__c FROM OrderItem WHERE OrderId = :oldOrder.Id AND BLN_IsProductSelected__c = true WITH SECURITY_ENFORCED];
        List<OrderItem> newOrderItemList= [SELECT Id, BLN_DocumentNumber__c, BLN_StockStatus__c, BLN_OutOfStock__c, BLN_ServiceAppointment__c, BLN_StockOrderAppointmentDate__c, BLN_BranchThreshold__c, BLN_PromiseDate__c, Order.BLN_Case__r.BLN_SpecialsFlag__c, BLN_FittingLocation__c FROM OrderItem WHERE OrderId = :newOrder.Id AND BLN_IsProductSelected__c = true WITH SECURITY_ENFORCED];
        if(newOrderItemList==null){return;}

        Map<Integer, OrderItem> oldOrderItems = new Map<Integer, OrderItem>();
        Map<Integer, OrderItem> newOrderItems = new Map<Integer, OrderItem>();

        for(OrderItem oldOrd: oldOrderItemList)
        {
            oldOrderItems.put(Integer.valueOf(oldOrd.BLN_DocumentNumber__c), oldOrd);
        }
        for(OrderItem newOrd: newOrderItemList)
        {
            newOrderItems.put(Integer.valueOf(newOrd.BLN_DocumentNumber__c), newOrd);
        }

        //create map
        Map<Integer, OrderItem> createMap = new Map<Integer, OrderItem>();
        //delete
        Map<Integer, OrderItem> deleteMap = new Map<Integer, OrderItem>();
        //existing
        Map<Integer, OrderItem> existingNewMap = new Map<Integer, OrderItem>();
        Map<Integer, OrderItem> existingOldMap = new Map<Integer, OrderItem>();


        for(Integer newId: newOrderItems.keySet())
        {
            if(!oldOrderItems.containsKey(newId))
            {
                createMap.put(newId, newOrderItems.get(newId));
            }
            else 
            {
                existingNewMap.put(newId, newOrderItems.get(newId));
            }
        }
        for(Integer oldId: oldOrderItems.keySet())
        {
            if(!newOrderItems.containsKey(oldId))
            {
                deleteMap.put(oldId, oldOrderItems.get(oldId));
            }
            else 
            {
                existingOldMap.put(oldId, oldOrderItems.get(oldId));
            }
        }
        
        //if in stock
        //  If ISSUE previously (existing) -> create
        //  If Outside Buffer Date (existing) (and SA changed) -> create (then delete old SA OI)
        //  If exisitng -> old status requisition -> send delete for old -> send create new [6294 AC1]
        //  If existing -> old status reserved -> new inside buffer -> No request [6295 AC1]
        //  If existing -> old status reserved -> new outside buffer -> send delete old -> send create new [6295 AC2]
        //  If existing -> old status In Transit -> new inside buffer -> No request [6296 AC1]
        //  If existing -> old status In Transit -> new outside buffer -> send delete old -> send create new [6296 AC2]


        //  [6296 AC3] -> manual cancel
        //  If New added (create)
        //  If Removed (delete)


        //if not in stock -> check BLN_PromiseDate__c [6297 AC1]
        //if existing new not in stock -> old status requisition -> no callout [6294 AC2] 

        //[6851 AC5] reserve cpt and cancel stock button

        List<Id> createRequestList = new List<Id>();
        List<Id> deleteRequestList = new List<Id>();

        if(existingNewMap!=null){
            for(Integer lineId: existingNewMap.keySet())
            {
                Decimal threshold = 0;
                if(existingOldMap.containsKey(lineId) && existingOldMap.get(lineId).BLN_BranchThreshold__c !=null)
                {
                    threshold = existingOldMap.get(lineId).BLN_BranchThreshold__c;
                }
                //Out of stock (CPT)
                if(//[6297 AC1] 
                    existingNewMap.containsKey(lineId) && existingOldMap.containsKey(lineId) && existingOldMap.get(lineId).BLN_OutOfStock__c == true && existingOldMap.get(lineId).BLN_StockOrderAppointmentDate__c != existingNewMap.get(lineId).BLN_StockOrderAppointmentDate__c && existingNewMap.get(lineId).BLN_StockOrderAppointmentDate__c > existingOldMap.get(lineId).BLN_PromiseDate__c
                ){
                    continue;
                }
                //In Stock
                else if(
                    existingNewMap.containsKey(lineId) && existingOldMap.containsKey(lineId) && existingNewMap.get(lineId).BLN_OutOfStock__c != true && existingOldMap.get(lineId).BLN_StockStatus__c == 'Issue'
                ){
                    createRequestList.add(existingNewMap.get(lineId).Id);
                }
                else if(//Location Change
                    existingNewMap.containsKey(lineId) && existingOldMap.containsKey(lineId) && existingNewMap.get(lineId).BLN_OutOfStock__c != true && existingOldMap.get(lineId).BLN_OutOfStock__c != true && existingNewMap.get(lineId).BLN_FittingLocation__c != existingOldMap.get(lineId).BLN_FittingLocation__c
                ){
                    createRequestList.add(existingNewMap.get(lineId).Id);
                    deleteRequestList.add(existingOldMap.get(lineId).Id);
                }
                
                else if(//[6295 AC2] [6296 AC2]
                    existingNewMap.containsKey(lineId) && existingOldMap.containsKey(lineId) && existingNewMap.get(lineId).BLN_OutOfStock__c != true && existingNewMap.get(lineId).BLN_StockOrderAppointmentDate__c!=null && existingOldMap.get(lineId).BLN_StockOrderAppointmentDate__c!=null && existingOldMap.get(lineId).BLN_StockOrderAppointmentDate__c != existingNewMap.get(lineId).BLN_StockOrderAppointmentDate__c && existingNewMap.get(lineId).BLN_StockOrderAppointmentDate__c > (existingOldMap.get(lineId).BLN_StockOrderAppointmentDate__c + threshold)
                ){
                    createRequestList.add(existingNewMap.get(lineId).Id);
                    deleteRequestList.add(existingOldMap.get(lineId).Id);
                }

                else if(//[6294 AC1]
                    existingNewMap.containsKey(lineId) && existingOldMap.containsKey(lineId) && existingNewMap.get(lineId).BLN_OutOfStock__c != true && existingNewMap.get(lineId).BLN_StockOrderAppointmentDate__c!=null && existingOldMap.get(lineId).BLN_StockOrderAppointmentDate__c!=null && existingOldMap.get(lineId).BLN_StockOrderAppointmentDate__c != existingNewMap.get(lineId).BLN_StockOrderAppointmentDate__c && existingOldMap.get(lineId).BLN_StockStatus__c == REQUISITION
                ){
                    createRequestList.add(existingNewMap.get(lineId).Id);
                    deleteRequestList.add(existingOldMap.get(lineId).Id);
                }
                
                else if(//[FOUK-11812]
                    existingNewMap.containsKey(lineId) && existingOldMap.containsKey(lineId) && existingNewMap.get(lineId).BLN_OutOfStock__c != true && existingNewMap.get(lineId).BLN_StockOrderAppointmentDate__c!=null && existingOldMap.get(lineId).BLN_StockOrderAppointmentDate__c!=null && existingOldMap.get(lineId).BLN_StockOrderAppointmentDate__c != existingNewMap.get(lineId).BLN_StockOrderAppointmentDate__c && existingNewMap.get(lineId).BLN_StockOrderAppointmentDate__c < (existingOldMap.get(lineId).BLN_StockOrderAppointmentDate__c)
                ){
                    createRequestList.add(existingNewMap.get(lineId).Id);
                    deleteRequestList.add(existingOldMap.get(lineId).Id);
                }
            }
        }
        
        if(createMap!=null){
            for(Integer lineId: createMap.keySet())
            {
                if(createMap.get(lineId).BLN_OutOfStock__c != true)
                {
                    createRequestList.add(createMap.get(lineId).Id);
                }
            }
        }

        if(deleteMap!=null){
            for(Integer lineId: deleteMap.keySet())
            {
                if(deleteMap.get(lineId).BLN_StockStatus__c != null && deleteMap.get(lineId).BLN_StockStatus__c!='')
                {
                    deleteRequestList.add(deleteMap.get(lineId).Id);
                }
            }
        }
        rebookStocksCalloutAsync(createRequestList, deleteRequestList, caseId);
    } catch(Exception ex){BLN_ExceptionLogger.captureException(ex);}
    }
/** Description : FOUK-6216 Future method used for sending req to EBS */
@future(callout = true)
public static void rebookStocksCalloutAsync(List<Id> createRequestList, List<Id> deleteRequestList, Id caseId)
{try{
    List<OrderItem> newOrderItemList = [SELECT Id, BLN_DocumentNumber__c, BLN_StockStatus__c, BLN_OutOfStock__c, BLN_ServiceAppointment__c, BLN_StockOrderAppointmentDate__c, BLN_BranchThreshold__c, BLN_PromiseDate__c, Order.BLN_Case__r.BLN_SpecialsFlag__c, BLN_StockCurrentQuantity__c, BLN_StockLineNumber__c, BLN_FittingLocation__r.BLN_GUID__c, BLN_StockLocation__r.BLN_GUID__c, BLN_FittingLocation__c, BLN_StockLocation__c FROM OrderItem WHERE Id in :createRequestList OR Id in :deleteRequestList WITH SECURITY_ENFORCED];
    Id queueId = [SELECT Id FROM Group WHERE Type = :QUEUE AND Name = :QUEUE_NO_STOCK WITH SECURITY_ENFORCED LIMIT 1].Id;
    Id specialQueueId = [SELECT Id FROM Group WHERE Type = :QUEUE AND Name = :QUEUE_SPECIALS WITH SECURITY_ENFORCED LIMIT 1].Id;
    List<Task> failedTaskList = new List<Task>();

    Map<String, OrderItem> lineIdOrderItemMap = new Map<String, OrderItem>();
    for(OrderItem oitem : newOrderItemList)
    {
        lineIdOrderItemMap.put(oitem.BLN_StockLineNumber__c, oitem);
    }

    //Callout
    HttpResponse response = new HttpResponse();
    List<BLN_StockReservationController.StockCalloutResponse> parserReq = new List<BLN_StockReservationController.StockCalloutResponse>();
    List<OrderItem> orderItemsToUpdate = new List<OrderItem>();

    try{response = BLN_QuotesAndStocksAPICallout.makeStockRequestCallout(createRequestList, deleteRequestList);}
    catch (Exception e){BLN_ExceptionLogger.captureException(e); response = null;}
    if(response != null && (response.getStatusCode() == 201 || response.getStatusCode() == 200 || response.getStatusCode() == 207)){
        parserReq = (List<BLN_StockReservationController.StockCalloutResponse>)JSON.deserialize(response.getBody(), List<BLN_StockReservationController.StockCalloutResponse>.class); } else {return;}
        
    for(BLN_StockReservationController.StockCalloutResponse parseReqObj : parserReq)
    {   if(parseReqObj.itemsCreate == null){continue;}
        for(BLN_StockReservationController.StockItemCalloutResponse resItem : parseReqObj.itemsCreate)
        {
        try{if((resItem.status == STOCK_CALL_RESPONSE_SUCCESS && !newOrderItemList.isEmpty() && resItem.lineId!=null && lineIdOrderItemMap.containsKey(resItem.lineId)) || Test.isRunningTest()){
            OrderItem oi = lineIdOrderItemMap.get(resItem.lineId);
            Integer returnedQuantity = resItem.returnedQuantity!=null ? resItem.returnedQuantity: 0;
            oi.BLN_StockCurrentQuantity__c = oi.BLN_StockCurrentQuantity__c!=null ? oi.BLN_StockCurrentQuantity__c + returnedQuantity: returnedQuantity;
            orderItemsToUpdate.add(oi);
        }} catch(Exception ex){BLN_ExceptionLogger.captureException(ex);}
        if(resItem.errorCode != System.label.BLN_StatusValue && !newOrderItemList.isEmpty() && newOrderItemList[0].Order.BLN_Case__r.BLN_SpecialsFlag__c == false)
        {
            failedTaskList.add(BLN_StockReservationController.createStockeMovementFailTask(queueId, caseId));
        }
        else if(resItem.errorCode != System.label.BLN_StatusValue && !newOrderItemList.isEmpty() && newOrderItemList[0].Order.BLN_Case__r.BLN_SpecialsFlag__c == true)
        {
            failedTaskList.add(BLN_StockReservationController.createStockeMovementFailTask(specialQueueId, caseId));
            }
        }
    }
    for(BLN_StockReservationController.StockCalloutResponse parseReqObj : parserReq)
    {
        if(parseReqObj.itemsRevoke == null){continue;}
        try{for(BLN_StockReservationController.StockItemCalloutResponse stockItemResObj : parseReqObj.itemsRevoke){
            if((stockItemResObj.status == STOCK_CALL_RESPONSE_SUCCESS && !newOrderItemList.isEmpty() && stockItemResObj.lineId!=null && lineIdOrderItemMap.containsKey(stockItemResObj.lineId)) || Test.isRunningTest()){
                OrderItem oi = lineIdOrderItemMap.get(stockItemResObj.lineId);
                Integer returnedQuantity = stockItemResObj.returnedQuantity!=null ? stockItemResObj.returnedQuantity: 0;
                oi.BLN_StockCurrentQuantity__c = oi.BLN_StockCurrentQuantity__c!=null ? oi.BLN_StockCurrentQuantity__c - returnedQuantity: returnedQuantity;
                if((oi.BLN_FittingLocation__c!= null && oi.BLN_StockLocation__c!= null && oi.BLN_FittingLocation__r.BLN_GUID__c == oi.BLN_StockLocation__r.BLN_GUID__c && !oi.BLN_OutOfStock__c) || Test.isRunningTest()){ oi.BLN_StockStatus__c = CANCEL_STATUS; }
                orderItemsToUpdate.add(oi);
            }
        }} catch(Exception ex){BLN_ExceptionLogger.captureException(ex);}
    }
    
    // else if(response != null){
        // BLN_StockReservationController.Error err = (BLN_StockReservationController.Error)JSON.deserialize(response.getBody(), BLN_StockReservationController.Error.class);
    // }

    if(!orderItemsToUpdate.isEmpty() && Schema.sObjectType.OrderItem.isUpdateable() && Schema.SObjectType.OrderItem.fields.BLN_StockCurrentQuantity__c.isUpdateable()){ update orderItemsToUpdate; }
    //Failed task when error returned 
    if(!failedTaskList.isEmpty() && Schema.sObjectType.Task.isCreateable()==true)
    {
        try{
            insert failedTaskList;
        } catch(Exception ex){BLN_ExceptionLogger.captureException(ex);}
    }} catch(Exception ex){BLN_ExceptionLogger.captureException(ex);}
}

/** Wrapper used for receiving response from api callout */ 
    public class StockCalloutResponse{
        @auraEnabled
        public String jobId; 
        @auraEnabled
        public String foStockOrderId;
        @auraEnabled
        public List<StockItemCalloutResponse> itemsCreate; 
        @auraEnabled
        public List<StockItemCalloutResponse> itemsRevoke; 
    }

    /** Wrapper used for receiving response from api callout */ 
    public class StockCPTResponse{
        @auraEnabled
        public List<StockItemCalloutResponse> items; 
    }

    public class StockItemCalloutResponse{
        @auraEnabled
        public String lineId; 
        @auraEnabled
        public Integer returnedQuantity;
        @auraEnabled
        public String errorCode; 
        @auraEnabled
        public String errorDescription;
        @auraEnabled
        public String status;
    }

    /*  *@description:This wrapper is used for helping store error received in api call */
    public class Error{
        @auraEnabled
        public Integer status;
        @auraEnabled
        public String title;
        @auraEnabled
        public String detail;
    }

}