public with sharing class LAD_returnProductAvailabilityDetails {
    @AuraEnabled
    public static List<OrderItemSummary> orderproductDetails(string orderSummaryId){
        
            return [select id,LAD_Date_Selected_By_Customer__c,LAD_Product_Availability_Date__c,Product2.name from orderItemSummary where orderSummaryId=:orderSummaryId  ];
     
    }

}