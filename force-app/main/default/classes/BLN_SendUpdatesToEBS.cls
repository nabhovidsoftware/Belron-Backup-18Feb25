/**@description : This Apex class will send Stock updates to Oracle EBS via Callout and this class will be called from the Flow BLN_ArrivalNotificationtoCustomer
*  @author: PwC India
*  @Story: FOUK-5076 (Salesforce Trigger of EBS Stock Update for Unused Parts)
*  @CreatedDate: 08/05/2024
*/
public without sharing class BLN_SendUpdatesToEBS {
@InvocableMethod(label='Send Updates To EBS' description='This Class will send updates to EBS')
    public static void sendUpdatesToEBS(List<InputVariables> inputVariables){
        try{
            ServiceAppointment inputSA = inputVariables.get(0).sA;
            List<ServiceAppointment> sAList = [SELECT Id, ServiceTerritoryId, Status, WorkTypeId, ParentRecordId, BLN_Case__c FROM ServiceAppointment WHERE Id =: inputSA.Id WITH SECURITY_ENFORCED LIMIT 1] ;
            ServiceAppointment sA = sAList[0];
            Set<Id> productIds = new Set<Id>();
            Map<String, Decimal> mapOfproductIdAndPrQuantity = new Map<String, Decimal>();
           // List<OrderItem> updatedOliList = new List<OrderItem>();        
            //Map<Id, Decimal> mapOfSurplusPIdAndQuantity = new Map<Id, Decimal>();
            List<ProductRequired> prList = new List<ProductRequired>();
           // List<ProductConsumed> pcList = new List<ProductConsumed>();
            List<OrderItem> opList = new List<OrderItem>();
            List<OrderItem> updatedOIList = new List<OrderItem>();
            List<Id> productUpsoldList = new List<Id>();
            List<Id> productRemovedList = new List<Id>();
            Map<Id, Integer> orderProductOldMap = new Map<Id, Integer>();
            List<Id> quantityChangeId = new List<Id>();
            String orderId = '';
            prList = [SELECT Id, ParentRecordId, Product2Id, BLN_IsConsumed__c, QuantityRequired, BLN_QuantityUsedByTech__c FROM ProductRequired WHERE ParentRecordId=:sA.ParentRecordId WITH SECURITY_ENFORCED] ;
            if(!prList.isEmpty()){
                for(ProductRequired pr:prList){
                    if(pr.Product2Id!=null){
                        productIds.add(pr.Product2Id);
                        mapOfproductIdAndPrQuantity.put(pr.Product2Id, pr.BLN_QuantityUsedByTech__c);
                    }
                }
            }
            /*if(!productIds.isEmpty()){
                pcList = [SELECT Id, WorkOrderLineItemId, Product2Id, QuantityConsumed FROM ProductConsumed WHERE WorkOrderLineItemId=:sA.ParentRecordId AND Product2Id IN:productIds WITH SECURITY_ENFORCED] ;
            }
            if(!pcList.isEmpty()){
                for(ProductConsumed pc:pcList){
                    if(pc.Product2Id!=null && pc.QuantityConsumed!=null && mapOfproductIdAndPrQuantity.containsKey(pc.Product2Id) && pc.QuantityConsumed < mapOfproductIdAndPrQuantity.get(pc.Product2Id)){
                                    mapOfSurplusPIdAndQuantity.put(pc.Product2Id, pc.QuantityConsumed);
                                }
                            }
            }*/
                opList = [SELECT Id, OrderId, Order.BLN_CPQExternalQuoteId__c, Order.BLN_Discount__c, BLN_IsProductSelected__c, Product2Id, 
                          Product2.BLN_MDMID__c, BLN_ServiceAppointment__c, Quantity, BLN_StockLineNumber__c, BLN_FittingLocation__c, 
                         BLN_StockLocation__r.BLN_OrgCodeLocation__c, BLN_ProductChangeType__c 
                          FROM OrderItem 
                          WHERE BLN_ServiceAppointment__c=:sA.Id AND Order.Status =: System.Label.BLN_Accepted AND BLN_ProductChangeType__c!=NULL AND Product2.BLN_ProductStockable__c = TRUE WITH SECURITY_ENFORCED]; 
            if(!opList.isEmpty()){
                orderId = opList[0].OrderId;
                for(OrderItem oi:opList){
                    if(oi.BLN_ProductChangeType__c == System.Label.BLN_ProductUpsold && oi.BLN_IsProductSelected__c == true){
                        productUpsoldList.add(oi.Id);
                    }
                    else if(oi.BLN_ProductChangeType__c == System.Label.BLN_ProductRemoved  && oi.BLN_IsProductSelected__c == false){
                        productRemovedList.add(oi.Id);
                    }
                    else if(oi.BLN_ProductChangeType__c == System.Label.BLN_QuantityChanged  && oi.BLN_IsProductSelected__c == true){
                        quantityChangeId.add(oi.Id);
                        orderProductOldMap.put(oi.Id, Integer.valueOf(oi.Quantity));

                        // prepare OLI List for DML
                        OrderItem updatedOI = new OrderItem();
                        updatedOI.Id = oi.Id;
                        updatedOI.BLN_UnConsumedQuantity__c = oi.Quantity - mapOfproductIdAndPrQuantity.get(oi.Product2Id);
                        updatedOI.Quantity = mapOfproductIdAndPrQuantity.get(oi.Product2Id);
                        updatedOIList.add(updatedOI);
                    }
                    }
            }
            if(!String.isBlank(orderId)){
                System.enqueueJob(new BLN_SendUpdatesToEBSCallout(orderId, updatedOIList, productUpsoldList, productRemovedList, quantityChangeId, orderProductOldMap));
            }
        }catch(Exception ex){
            BLN_ExceptionLogger.captureException(ex);
        }
    }

    public class InputVariables{
        @InvocableVariable
        public ServiceAppointment sA;   
    }
}