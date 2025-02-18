/** @description :  Test Class for LAD_AssignProductsToEntitlementPolicy and LAD_ProductAssignmentBatch
*  @author:         (binayak.debnath@pwc.com (IN))
*  @story:          FOUK-7121
*/
@isTest
public class LAD_AssignProdToEntitlementPolicyTest {
    
    @istest
    static void assignProductsTest(){
        ProductCatalog catalog1 = new ProductCatalog(Name = 'Catalog1');
        ProductCategory category1 = new ProductCategory(Name = 'Category1');
        Product2 prod1 = new Product2(Name = 'Prod1', isActive =true);
        insert catalog1;
        category1.CatalogId = catalog1.id;
        insert category1;
        insert prod1;
        
        ProductCategoryProduct catProd1 = new ProductCategoryProduct(ProductCategoryId = category1.id, ProductId = prod1.id);
        insert catProd1;
        
        CommerceEntitlementPolicy policy1 = new CommerceEntitlementPolicy(Name = 'Policy1', isActive = true);
        insert policy1;
        CommerceEntitlementProduct policyProduct1 = new CommerceEntitlementProduct(PolicyId = policy1.id, ProductId = prod1.id);
        insert policyProduct1;
        
        List<LAD_AssignProductsToEntitlementPolicy.FlowInputWrapper> inputList = new List<LAD_AssignProductsToEntitlementPolicy.FlowInputWrapper>();
        LAD_AssignProductsToEntitlementPolicy.FlowInputWrapper input = new LAD_AssignProductsToEntitlementPolicy.FlowInputWrapper();
        input.entitlementPolicyId = policy1.id;
        input.categoryId = category1.Id;
        inputList.add(input);
        
        Test.startTest();
        List<LAD_AssignProductsToEntitlementPolicy.FlowOutputWrapper> outputList1 = LAD_AssignProductsToEntitlementPolicy.invokeLocalMethod(inputList);
        delete policyProduct1;
        List<LAD_AssignProductsToEntitlementPolicy.FlowOutputWrapper> outputList2 = LAD_AssignProductsToEntitlementPolicy.invokeLocalMethod(inputList);
        Test.stopTest();
        Assert.areEqual(System.Label.LAD_NoProductsToAssign, outputList1[0].message);
        Assert.areEqual(System.Label.LAD_ProductAssignmentStartedSuccess + ' 1'+' '+System.Label.LAD_ProductAssignmentStartedSuccess2, outputList2[0].message);    
    }
}