/*****************************************
ClassName : BLN_ProductIdentifierUtility
Description : Validation : This utility class is used for product identifiy ie. Charge, windscreen etc.
CreatedDate: 28-06-2024
CreatedBy : PwC-India
****************************************/
public with sharing class BLN_ProductIdentifierUtility { 

    public static List<BLN_ProductAvailabilityWrapper.ProductIdentifierWrapper> getProductIndentify(String primeProduct) {
        List<BLN_ProductAvailabilityWrapper.ProductIdentifierWrapper> prodIdentWrapper = new List<BLN_ProductAvailabilityWrapper.ProductIdentifierWrapper>();
        List<String> productTypesSplits = new List<String>();
        if(primeProduct.contains(',')) { 
            productTypesSplits = primeProduct.split(',');
        } else {
            productTypesSplits.add(primeProduct);
        } 
        if(productTypesSplits.size() > 0) {
            for(BLN_ProductIdentifier__mdt prodIdnMtd: [SELECT BLN_CategoryCode__c, BLN_MatchingCriteria__c, BLN_Type__c FROM BLN_ProductIdentifier__mdt WHERE BLN_Type__c IN: productTypesSplits WITH SECURITY_ENFORCED ]) {  
                BLN_ProductAvailabilityWrapper.ProductIdentifierWrapper prodIdentInstance = new BLN_ProductAvailabilityWrapper.ProductIdentifierWrapper();
                prodIdentInstance.categoryCode = prodIdnMtd.BLN_CategoryCode__c;
                prodIdentInstance.type = prodIdnMtd.BLN_Type__c != null ? prodIdnMtd.BLN_Type__c.toUpperCase() : null ;
                prodIdentWrapper.add(prodIdentInstance);
            }
        }
        return prodIdentWrapper;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<BLN_ProductAvailabilityWrapper.RepairProductValidater> getRepairProduct() {
        List<BLN_ProductAvailabilityWrapper.RepairProductValidater> repairProductVals = new List<BLN_ProductAvailabilityWrapper.RepairProductValidater>();
        for(BLN_ProductIdentifier__mdt prodIdnMtd: [SELECT BLN_ProductCode__c, BLN_MatchingCriteria__c, BLN_BranchOnlyOrMobileOnly__c, BLN_Type__c FROM BLN_ProductIdentifier__mdt WHERE BLN_BranchOnlyOrMobileOnly__c != null WITH SECURITY_ENFORCED]) {  
            BLN_ProductAvailabilityWrapper.RepairProductValidater prodIdentInstance = new BLN_ProductAvailabilityWrapper.RepairProductValidater();
            prodIdentInstance.productCode = prodIdnMtd.BLN_ProductCode__c;
            prodIdentInstance.branchOnlyMobileOnly = prodIdnMtd.BLN_BranchOnlyOrMobileOnly__c != null ? prodIdnMtd.BLN_BranchOnlyOrMobileOnly__c : '';
            repairProductVals.add(prodIdentInstance);
        }
        return repairProductVals;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> getAppointmentExcludedProductCodes(){ 
        List<String> prodCodesToExculde = new List<String>();
    	List<BLN_ProductIdentifier__mdt> mDataRecords = new List<BLN_ProductIdentifier__mdt>();
        
        mDataRecords = [SELECT BLN_ProductCode__c,BLN_Type__c FROM BLN_ProductIdentifier__mdt WHERE BLN_Type__c = 'EXCLUDE FOR APPOINTMENT' WITH SECURITY_ENFORCED];	
        for(BLN_ProductIdentifier__mdt rec : mDataRecords){
            prodCodesToExculde.add(rec.BLN_ProductCode__c);
        }
        
        return prodCodesToExculde;
    }
    

}