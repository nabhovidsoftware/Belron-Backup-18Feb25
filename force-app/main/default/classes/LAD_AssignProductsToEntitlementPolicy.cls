/** @description :  This apex class is used to find out products which are part of a category,
*                  but not of an entitlement policy. Such products are passed off to a batch for 
*                  assignment
*  @author:         (binayak.debnath@pwc.com (IN))
*  @story:          FOUK-7121
*/
public with sharing class LAD_AssignProductsToEntitlementPolicy {
    
    // Wrapper Class handling input from Flow to Apex Class
    public class FlowInputWrapper{
        @InvocableVariable public Id entitlementPolicyId;
        @InvocableVariable public Id categoryId;
    }
    
    // Wrapper Class handling output from Apex Class to Flow
    public class FlowOutputWrapper{
        @InvocableVariable public String message;
    }
    
    /* Invokable Method handling the calling of apex method for assignment functionality and 
two way conversion of parameters and data */
    @InvocableMethod
    public static List<FlowOutputWrapper> invokeLocalMethod(List<FlowInputWrapper> idLists){
        List<FlowOutputWrapper> outPut = new List<FlowOutputWrapper>();
        for(FlowInputWrapper input : idLists){
            outPut.add(assignProducts(input));
        }
        return outPut;
    }
    
    // Apex Method handling the functionality to determine products to be assigned
    public static FlowOutputWrapper assignProducts(FlowInputWrapper idList) {
        
        Id entitlementPolicyId = idList.entitlementPolicyId;
        Id categoryId = idList.categoryId;
        FLowOutputWrapper outPut = new FlowOutputWrapper();
        
        try{
            // Fetch related category product junction records for the given category
            List<ProductCategoryProduct> categoryProducts = [SELECT Id, ProductId, ProductCategoryId FROM ProductCategoryProduct WHERE ProductCategoryId = :categoryId];
            if(categoryProducts.size() == 0){
                outPut.message = System.Label.LAD_NoProductsAvailable;
                return outPut;
            }
            // Fetch related product Ids for the given entitlement policy
            Set<Id> entitlementPolicyProductIds = new Set<Id>();
            for (CommerceEntitlementProduct item : [SELECT ProductId, PolicyId FROM CommerceEntitlementProduct WHERE PolicyId = :entitlementPolicyId]) {
                entitlementPolicyProductIds.add(item.ProductId);
            }
            
            // Identify product Ids from the category that are not part of the entitlement policy
            List<ProductCategoryProduct> categoryProductsToAdd = new List<ProductCategoryProduct>();
            for (ProductCategoryProduct categoryProduct : categoryProducts) {
                if (!entitlementPolicyProductIds.contains(categoryProduct.ProductId)) {
                    categoryProductsToAdd.add(categoryProduct);
                }
            }
            
            // Assign product Ids to the entitlement policy
            if (!categoryProductsToAdd.isEmpty()) {
                // Call the batch class to assign products
                LAD_ProductAssignmentBatch batch = new LAD_ProductAssignmentBatch(entitlementPolicyId, categoryProductsToAdd);
                Database.executeBatch(batch);
                outPut.message = System.Label.LAD_ProductAssignmentStartedSuccess + ' ' +String.valueOf(categoryProductsToAdd.size())+' '+System.Label.LAD_ProductAssignmentStartedSuccess2;
                return outPut;
            }
            else{
                outPut.message = System.Label.LAD_NoProductsToAssign;
                return outPut;
            }
        }
        catch(Exception ex){
            outPut.message = ex.getMessage();
            return outPut;
            
        } 
        
    }
}