/** @description : The Apex handler class for BLN_CaseTrigger
*   @Story : FOUK-5034
*   @author: Rahul Jain(PwC IN)
*    @CreatedDate: 14/06/2024
*/
public with sharing class BLN_CaseTriggerHandler implements BLN_TriggerInterface {
   public static Boolean stopExecution = false;
   static final String CASE_STATUS_ACCEPTED = 'Accepted';
   public Boolean stopDispatch() {
       return stopExecution;
   }
   public static void afterInsert(List<SObject> newList, Map<Id, SObject> newMap) {
       stopExecution = true;
   }
   public static void beforeInsert(List<SObject> newList) {
    stopExecution = true;
}

   public static void afterUpdate(List<SObject> newList, Map<Id, SObject> newMap) {
    stopExecution = false;
    List<Case> newCaseCastedList = (List<Case>) newList;
    Map<Id, Case> oldCaseCastedMap = (Map<Id, Case>) newMap;
    Set<Id> closedCaseIdSet = getClosedCaseIds(newCaseCastedList, oldCaseCastedMap);
    if (!closedCaseIdSet.isEmpty()) {
        makeStockCallout(closedCaseIdSet);
    }
    
}

@future (callout=true)
public static void makeStockCallout(Set<Id> closedCaseIdSet){
    BLN_QuotesAndStocksAPICallout.sendWorkOrderComplete(closedCaseIdSet);
}

   public static void beforeUpdate(List<sObject> newCaseList, Map<Id, sObject> oldCaseMap) {
       List<Case> newCaseCastedList = (List<Case>) newCaseList;
       Map<Id, Case> oldCaseCastedMap = (Map<Id, Case>) oldCaseMap;
       Set<Id> closedCaseIdSet = getClosedCaseIds(newCaseCastedList, oldCaseCastedMap);
       if (!closedCaseIdSet.isEmpty()) {
           List<Order> orderList = getOrdersByCaseIds(closedCaseIdSet);
           processOrders(orderList, newCaseCastedList);
       }
   }


   public void beforeDelete(List<SObject> oldList, Map<Id, SObject> oldMap) {
    stopExecution = true;
    }
    
    public void afterDelete(List<SObject> oldList, Map<Id, SObject> oldMap) {
        stopExecution = true;
    }
    
    
    public void afterUnDelete(List<SObject> newList, Map<Id, SObject> newMap) {
        stopExecution = true;
    }


    private static Set<Id> getClosedCaseIds(List<Case> newCaseList, Map<Id, Case> oldCaseMap) {
        Set<String> allowedRecordTypeIds = new Set<String>{'Enquiry', 'Feedback', 'Job Request'};
            Set<Id> closedCaseIdSet = new Set<Id>();
        for (Case newCase : newCaseList) {
            if (allowedRecordTypeIds.contains(newCase.Type) && newCase.Status != oldCaseMap.get(newCase.Id).Status
                && (newCase.Status == 'Closed' || newCase.Status == 'Closed-Completed' || newCase.Status == 'Closed-Lost')) {
                    closedCaseIdSet.add(newCase.Id);
                }
        }
        return closedCaseIdSet;
    }
   private static List<Order> getOrdersByCaseIds(Set<Id> closedCaseIdSet) {
       return [
           SELECT Id, BLN_Case__c,
                  (SELECT Id, Product2.BLN_ProductCategory__c, Product2.ProductCode, BLN_IsProductSelected__c,
                          Product2.LAD_Vehicle_Hole__c, Product2.BLN_ProductType__c, Product2.LAD_Vehicle_Type__c
                   FROM OrderItems WHERE BLN_IsProductSelected__c = true)
           FROM Order
           WHERE BLN_Case__c IN :closedCaseIdSet
             AND Status = :CASE_STATUS_ACCEPTED WITH SECURITY_ENFORCED
       ];
   }
   private static void processOrders(List<Order> orderList, List<Case> newCaseList) {
       Map<String, String> productRestrictionConfigMap = getProductRestrictionConfigMap();
       for (Order orderObj : orderList) {
           Map<String, Integer> combinationCountMap = new Map<String, Integer>();
           for (OrderItem orderProductObj : orderObj.OrderItems) {
               if (orderProductObj.Product2.BLN_ProductType__c != null && orderProductObj.Product2.LAD_Vehicle_Type__c != null) {
                   List<String> lstStrProductType = orderProductObj.Product2.BLN_ProductType__c.Split('-',2);
                   String strProductType = lstStrProductType[lstStrProductType.size()-1];
                   String vehicleMapKey = orderProductObj.Product2.LAD_Vehicle_Type__c + '~' + strProductType;
                   if (productRestrictionConfigMap.containsKey(vehicleMapKey) && productRestrictionConfigMap.get(vehicleMapKey) == 'Same Product') {
                       vehicleMapKey += '~' + orderProductObj.Product2.ProductCode;
                   }
                   if (combinationCountMap.containsKey(vehicleMapKey)) {
                       combinationCountMap.put(vehicleMapKey, combinationCountMap.get(vehicleMapKey) + 1);
                   } else {
                       combinationCountMap.put(vehicleMapKey, 1);
                   }
                   if (combinationCountMap.get(vehicleMapKey) > 1) {
                       addErrorToCases(newCaseList, orderObj.BLN_Case__c, System.label.BLN_CaseProductRestrictionMessage);
                   }
               }
           }
       }
   }
   private static Map<String, String> getProductRestrictionConfigMap() {
       Map<String, String> productRestrictionConfigMap = new Map<String, String>();
       List<BLN_ProductRestrictionRules__mdt> productRestrictionMappingList = [
           SELECT Id, BLN_Name__c, BLN_VehicleType__c, BLN_HoleType__c, BLN_RuleType__c
           FROM BLN_ProductRestrictionRules__mdt WITH SECURITY_ENFORCED
       ];
       for (BLN_ProductRestrictionRules__mdt productMappingObj : productRestrictionMappingList) {
           String configKey = productMappingObj.BLN_VehicleType__c + '~' + productMappingObj.BLN_HoleType__c;
           productRestrictionConfigMap.put(configKey, productMappingObj.BLN_RuleType__c);
       }
       return productRestrictionConfigMap;
   }
   private static void addErrorToCases(List<Case> newCaseList, Id caseId, String errorMessage) {
       for (Case newCase : newCaseList) {
           if (newCase.Id == caseId) {
               newCase.addError(errorMessage);
           }
       }
   }
}