public without sharing class BLN_ManageStockSourceController{
    @AuraEnabled
    public static BLN_ProductAvailabilityUtility.DisplayDetailsWrapper getAppoinmentAndProduct(String caseId){        
       return BLN_ProductAvailabilityUtility.rebookServiceAppointments(caseId);
    }

    @AuraEnabled
    public static Map<Id, OrderItem> getProductLineItem(String caseId){
        Map<Id, OrderItem> orderItemList = new Map<Id, OrderItem>([SELECT Id,BLN_PromiseDate__c, BLN_StockStatus__c, BLN_ServiceAppointment__c
                                                                   FROM OrderItem
                                                                   WHERE BLN_IsProductSelected__c = true AND order.BLN_Case__c = :caseId
                                                                   WITH SECURITY_ENFORCED]);
        return orderItemList;
    }

    @AuraEnabled
    public static List<Locationwrap> getLocation(List<String> stackLocationIdList){
        List<Locationwrap> locationwrapList = new List<Locationwrap>();
        for (Schema.Location serviceTer : [Select Id, Name, BLN_OrgCodeLocation__c
                                           From Location
                                           where BLN_OrgCodeLocation__c IN:stackLocationIdList
                                           WITH SECURITY_ENFORCED]){
            Locationwrap locWrap = new Locationwrap();
            locWrap.label = serviceTer.Name;
            locWrap.value = serviceTer.BLN_OrgCodeLocation__c;
            locationwrapList.add(locWrap);
        }
        return locationwrapList;
    }

    @AuraEnabled
    public static Map<String, OrderItem> getProduct(){
        List<OrderItem> prodList = [SELECT Id, BLN_ProductCode__c
                                    FROM OrderItem
                                    WITH SECURITY_ENFORCED];
        Map<String, OrderItem> productCodeWithProductMap = new Map<String, OrderItem>();
        for (OrderItem prod : prodList){           
            productCodeWithProductMap.put(prod.BLN_ProductCode__c, prod);
        }
        return productCodeWithProductMap;
    }

    @AuraEnabled
    public static void makeStockCallout(List<Id> orderItemItemList, String orderitemLocationMap, String productWithSA, String collectFlagMap){
        Map<String,String> mdmIdWithorgLocCodeMap = new Map<String,String>();
        Map<String,String> orderItemIdWIthSAIdMap = new Map<String,String>();
        // Set<Id> orderItemItemSet = new Set<Id>(orderItemItemList);
        Object obj = (Object) JSON.deserializeUntyped(productWithSA);
        Map<String, Object> orderitemIdWithSA = (Map<String, Object>)obj;

        Object locationObj = (Object) JSON.deserializeUntyped(orderitemLocationMap);
        Map<String, Object> orderitIdemLocationMap = (Map<String, Object>)locationObj;
        for (String mdmId : orderitIdemLocationMap.keySet()) {
            mdmIdWithorgLocCodeMap.put(mdmId, (String)orderitIdemLocationMap.get(mdmId));
        }
        for (String orderId : orderitemIdWithSA.keySet()) {
            orderItemIdWIthSAIdMap.put(orderId,(String)orderitemIdWithSA.get(orderId));
        }
        BLN_QuotesAndStocksAPICallout.makeStockRequestCalloutforStockCollect(orderItemItemList,orderItemItemList,mdmIdWithorgLocCodeMap,orderItemIdWIthSAIdMap,collectFlagMap);
        //BLN_QuotesAndStocksAPICallout.quoteStockMovementCallout(orderItemItemSet, orderitemLocationMap);
    }

    @AuraEnabled
    public static string getAppointmentId(Id appointmentId, String locationId){
        String appId =  BLN_ManageMDCStockCollectController.generateMDCStock(appointmentId, locationId);
        return appId;
    }
   
    public class Locationwrap{
        @AuraEnabled
        public  String label;
        @AuraEnabled
        public  String value;

    }

}