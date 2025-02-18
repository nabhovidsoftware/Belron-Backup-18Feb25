/**@description : This is Stock Check-In Utility Class.
*  @author: Sapna Teltumade
*  @Story: FOUK-4139
*  @CreatedDate: 02/01/2024
*/
public with sharing class BLN_StockCheckInListUtility {
    
    public static list<WrapperList> stockCheckIn(){
        list<WrapperList> wlData = new list<WrapperList>();
        map<serviceAppointment,map<Id, productRequired>> masterMap = new map<serviceAppointment,map<Id,productRequired>>();
        ServiceResource serviceResource = [SELECT Id, RelatedRecordId,LocationId,Location.LocationType FROM ServiceResource where 
                                           relatedrecordId =: system.userInfo.getUserId() AND Location.LocationType =: Label.BLN_Van WITH SECURITY_ENFORCED limit 1 ];
        ID serviceResourceId = serviceResource.Id;
        map<Id,serviceAppointment> serviceAppointmentData = new map<Id,serviceAppointment>([SELECT AppointmentNumber, BLN_WorkOrderLineItem__c,BLN_WorkOrderLineItem__r.status,BLN_WorkOrderLineItem__r.BLN_IsStockCheckInCompleted__c,
                                                                                            BLN_WorkOrderNumber__c, serviceterritory.name, BLN_WorkOrderNumber__r.status,BLN_WorkOrderNumber__r.workordernumber, WorkTypeId,WorkType.bln_isMainJob__c,
                                                                                            worktype.name, BLN_AssignedServiceResource__c, Id FROM ServiceAppointment where WorkType.bln_isMainJob__c = true and worktype.name NOT IN ('System.label.BLN_Recalibration')
                                                                                            and BLN_WorkOrderLineItem__r.BLN_IsStockCheckInCompleted__c = false and ((BLN_WorkOrderLineItem__r.status =: System.label.BLN_Completed and BLN_WorkOrderNumber__r.status =: System.label.BLN_Completed)
                                                                                                                                                                     OR (BLN_WorkOrderLineItem__r.status =: System.label.BLN_Canceled and BLN_WorkOrderNumber__r.status =: System.label.BLN_Canceled)) and BLN_AssignedServiceResource__c =: serviceResourceId]);
        
        system.debug('Map size : '+serviceAppointmentData.size());
        set<Id> woliIds = new set<Id>();
        
        for(Id s : serviceAppointmentData.keySet()){
            System.debug('WOLI from class '+serviceAppointmentData.get(s).BLN_WorkOrderLineItem__c);
            woliIds.add(serviceAppointmentData.get(s).BLN_WorkOrderLineItem__c);            
        }
        
        map<Id,productRequired> productRequiredData = new map<Id,productRequired>([select id, parentrecordid, Product2Id, Product2.productCode, ProductName, BLN_ProductQuantityConsumedOrTransferred__c,QuantityRequired from productrequired where parentRecordId IN: woliIds]);
        system.debug('Product Required Data size : '+productRequiredData.size());
        
        /*  Currently No Need for Product Consumed
map<Id,productConsumed> productConsumedData = new map<Id,productConsumed>([SELECT Id, workOrderLineItemId, Product2Id, ProductName, QuantityConsumed, IsConsumed FROM ProductConsumed where workOrderLineItemId IN: woliIds]);
system.debug('Product Consumed Data size : '+productConsumedData.size()); */
        
        for(Id s : serviceAppointmentData.keySet()){
            map<Id, productRequired> innerProductRequiredMap = new map<Id, productRequired>();
            for(Id s1 : productRequiredData.keySet()){
                If(serviceAppointmentData.get(s).BLN_WorkOrderLineItem__c == productRequiredData.get(s1).parentRecordId){
                    innerProductRequiredMap.put(s1, productRequiredData.get(s1));
                }
            }
            If(!innerProductRequiredMap.isEmpty()){
                masterMap.put(serviceAppointmentData.get(s),innerProductRequiredMap);
                system.debug('MasterMap Data size : '+masterMap.size());
                system.debug('MasterMap Data : '+masterMap);
            }
        }
        
        for(serviceAppointment s : MasterMap.keySet()){
            list<unusedProductsOptions> productLists = new list<unusedProductsOptions>();
            
            for(productRequired pr : MasterMap.get(s).values()){
                system.debug('pr.QuantityRequired : '+pr.QuantityRequired);
                system.debug('pr.BLN_ProductQuantityConsumedOrTransferred__c '+pr.BLN_ProductQuantityConsumedOrTransferred__c);
                if(pr.QuantityRequired > pr.BLN_ProductQuantityConsumedOrTransferred__c){
                    
                    decimal unusedQuantity = pr.QuantityRequired - pr.BLN_ProductQuantityConsumedOrTransferred__c;
                    unusedProductsOptions products = new unusedProductsOptions();
                    String productVar = '';
                    system.debug('******* Start *******');
                    system.debug('Product Name : '+pr.ProductName);
                    productVar = pr.ProductName;
                    system.debug('Quantity : '+string.valueOf(integer.valueOf(pr.QuantityRequired)));
                    productVar = productVar + ' ' + string.valueOf(integer.valueOf(pr.QuantityRequired));
                    system.debug('WorkOrder : '+s.BLN_WorkOrderNumber__r.workOrderNumber);
                    productVar = productVar + ' WO-' + s.BLN_WorkOrderNumber__r.workOrderNumber;
                    system.debug('Product Code : '+pr.Product2.productCode);
                    productVar = productVar + ' ' + pr.Product2.productCode;
                    system.debug('Service Territory : '+s.serviceterritory.name);
                    productVar = productVar + ' ' + s.serviceterritory.name;
                    system.debug('Product String created is : '+productVar);
                    system.debug('******* End *******');
                    
                    products.label = productVar;
                    
                    ProductData p = new ProductData();
                    p.saName = string.valueOf(s.AppointmentNumber);
                    p.productName = pr.ProductName;
                    p.productId = pr.Product2Id;
                    p.productQuantity = string.valueOf(pr.QuantityRequired);
                    p.productCode= pr.Product2.productCode;
                    p.vanLocationId=serviceResource.LocationId;
                    p.productRequiredId=pr.Id;
                    p.unUsedProductQuantity = string.valueOf(unusedQuantity);
                    p.woliId = s.BLN_WorkOrderLineItem__c;
                    
                    products.value = JSON.serialize(p);                    
                    productLists.add(products);
                }
            }
            wrapperList data = new wrapperList();
            if(!productLists.isEmpty()){
                system.debug('appointmentnumber : '+s.AppointmentNumber);
                system.debug('unUsedProductLists : '+productLists);
                data.saName = string.valueOf(s.AppointmentNumber);
                data.unUsedProductLists = productLists;
                wlData.add(data);
                system.debug('WL Size '+wlData.size());
            } 
        }
        
        return wlData;
    }
    
    public static productTransfer createPT(BLN_StockCheckInListUtility.ProductData pdWrapper){
        
        productRequired pr = [select id, parentrecordid, Product2Id, Product2.productCode, ProductName, BLN_ProductQuantityConsumedOrTransferred__c,QuantityRequired from productrequired where Id =: pdWrapper.productRequiredId];        
        
        productTransfer pt = new productTransfer();
        pt.Product2Id = pdWrapper.productId;
        pt.QuantityReceived = decimal.valueOf(pdWrapper.unUsedProductQuantity);
        pt.QuantitySent = decimal.valueOf(pdWrapper.unUsedProductQuantity);
        pt.QuantityUnitOfMeasure = 'Each';
        pt.IsReceived = TRUE;
        pt.SourceLocationId = pdWrapper.vanLocationId;
        pt.DestinationLocationId = NULL;
        
        return pt; 
        
    }
    
  /* public static productItem updateProductItem(BLN_StockCheckInListUtility.ProductData pdWrapper, productTransfer productTransfer){
        productItem pi = [select id,quantityonhand,product2id from productItem where product2id =: productTransfer.Product2Id WITH SECURITY_ENFORCED];  
       	decimal quantityOnHandRemain = pi.QuantityOnHand - productTransfer.QuantitySent;
        system.debug('product item quantity on hand is before updating : '+quantityOnHandRemain);
        pi.QuantityOnHand -= productTransfer.QuantityReceived;
       	pi.QuantityOnHand = quantityOnHandRemain;
        system.debug('product item quantity on hand is after updating : '+pi.QuantityOnHand);
        system.debug('QuantityReceived : '+productTransfer.QuantityReceived);        
        return pi;
    } */
    
    
    public static productRequired updateProductRequired(BLN_StockCheckInListUtility.ProductData pdWrapper, productTransfer productTransfer){
        productRequired pr = [select id, Product2Id, BLN_ProductQuantityConsumedOrTransferred__c from productrequired where Id =: pdWrapper.productRequiredId];
        pr.BLN_ProductQuantityConsumedOrTransferred__c += productTransfer.quantityReceived;
        return pr;        
    }
    
    public static boolean checkAllPrCompleted(BLN_StockCheckInListUtility.ProductData pdWrapper){
        integer counter = 0;
        list<productRequired> prList = new list<productRequired>([select id, parentrecordid, BLN_ProductQuantityConsumedOrTransferred__c, QuantityRequired from productrequired where parentRecordId =: pdWrapper.woliId]);
        system.debug('prList size : '+prList.size());
        for(productRequired pr : prList){
            if(pr.BLN_ProductQuantityConsumedOrTransferred__c != pr.QuantityRequired){
                counter ++;
            } 
        }
        system.debug('counter : '+counter);
        if(counter == 0 && !prList.isEmpty()){
            return true;
        } 
        else {
            return false;
        }
    }
    
    public static workOrderLineItem updateWoli(BLN_StockCheckInListUtility.ProductData pdWrapper){
        workOrderLineItem woli = new workOrderLineItem();
        woli.Id = pdWrapper.woliId;
        woli.BLN_IsStockCheckInCompleted__c = TRUE;
        return woli;
    }
    
    public class WrapperList{
        public string saName;
        public list<UnusedProductsOptions> unUsedProductLists;
    } 
    
    public class UnusedProductsOptions{
        public string label;
        public string value;
    }
    
    public class ProductData{
        public string saName;
        public string saId;
        public string productName;
        public string productId;
        public string productQuantity;
        public string productCode;
        public string vanLocationId;
        public string unUsedProductQuantity;
        public string productRequiredId;
        public string woliId;
    }
    
    public class CreatePTWrapper{
        public string productRequiredId;
    }
}