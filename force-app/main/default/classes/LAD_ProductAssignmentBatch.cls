/** @description :  This batch apex class is used to assign products to an entitlement policy.
*  @author:         (binayak.debnath@pwc.com (IN))
*  @Story:          FOUK-7121
*/
public without sharing class LAD_ProductAssignmentBatch implements Database.Batchable<sObject> {
    
    private Id entitlementPolicyId;
    private List<ProductCategoryProduct> categoryProductsToAdd;
    // Product Assignment Batch method
    public LAD_ProductAssignmentBatch(Id entitlementPolicyId, List<ProductCategoryProduct> categoryProductsToAdd) {
        this.entitlementPolicyId = entitlementPolicyId;
        this.categoryProductsToAdd = categoryProductsToAdd;
    }
    // start method to return categoryProductsToAdd
    public List<ProductCategoryProduct> start(Database.BatchableContext bc) {
       // String query = 'SELECT ProductId, ProductCategoryId FROM ProductCategoryProduct WHERE ProductId IN :categoryProductsToAdd AND ProductCategoryId = :categoryId';
        return categoryProductsToAdd;
    }
    //execute method
    public void execute(Database.BatchableContext bc, List<ProductCategoryProduct> scope) {
        List<CommerceEntitlementProduct> itemsToAdd = new List<CommerceEntitlementProduct>();
        for (ProductCategoryProduct categoryProduct : scope) {
            CommerceEntitlementProduct newItem = new CommerceEntitlementProduct();
            newItem.PolicyId = entitlementPolicyId;
            newItem.ProductId = categoryProduct.ProductId;
            itemsToAdd.add(newItem);
        }
        if(!itemsToAdd.isEmpty()){
            insert itemsToAdd;
        }
    }

    public void finish(Database.BatchableContext bc) {
        // Optional: Add any post-processing logic here
        //Eg: Add success message for executed records.
    }
    
}