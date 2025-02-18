/** @description :  This apex class is used to handle Associated Products functionality.
*   @Story :        FOUK-7848; FOUK-7866; FOUK-7867; FOUK-7868; FOUK-8518
*   @author:        (binayak.debnath@pwc.com (IN))
*   @CreatedDate:   26-06-2024
*/
public with sharing class LAD_AssociatedProductsHandler {

     /**@MethodName :   findAssociatedProductsHandler
    * @description :    This method is used when we need to find associated products based on the leading product OEM code. We find BOM records for the leading record
                        collect unique BOM Ids, which are then passed on to findAssociatedProductsbyBom for finding the actual products
    * @param:           String leadProductId, String userId, String networkId
    * @return:          List<AssociatedProductWrapper>
    */
    @auraenabled
    public static List<AssociatedProductWrapper> findAssociatedProductsHandler( String leadProductId, String userId, String networkId) {
        try {
             String leadOemCode = [SELECT LAD_Latest_OEM_Code__c FROM Product2 WHERE Id = :leadProductId AND isActive = true LIMIT 1].LAD_Latest_OEM_Code__c;
            //String leadOemCode = 'OEMCODE-PARENT';
            Set<String> bomIdSet = new Set<String>();
            //List<PRODUCT_BILL_OF_MATERIAL> parentBomList = parentBomMock();
            List<LAD_Product_Bill_Of_Material__c> parentBomList = [ SELECT  LAD_Bill_of_Material_Id__c,
                                                                            LAD_Product_Start_Date__c,
                                                                            LAD_Product_End_Date__c
                                                                    FROM LAD_Product_Bill_Of_Material__c 
                                                                    WHERE LAD_Product_Belron_Id__c = :leadOemCode AND LAD_Product_BOM_Leading_Product_Ind__c = 'TRUE'];
            List<AssociatedProductWrapper> returnWrapper = new List<AssociatedProductWrapper>();

            if(!parentBomList.isEmpty()){

                for(LAD_Product_Bill_Of_Material__c parent : parentBomList){
                    if(Date.today() >= Date.valueOf(parent.LAD_Product_Start_Date__c) && Date.today() <= Date.valueOf(parent.LAD_Product_End_Date__c)){
                        bomIdSet.add(parent.LAD_Bill_of_Material_Id__c);
                    }
                }
                
                if(!bomIdSet.isEmpty()){
                    List<String> bomIdList = new List<String>();
                    bomIdList.addAll(bomIdSet);
                    returnWrapper = findAssociatedProductsbyBom(bomIdList, userId, networkId);
                }
                
            }

            return returnWrapper;
        } catch (Exception e) {
            BLN_ExceptionLogger.captureException(e);
            return null;
        }
    }

     /**@MethodName :   findAssociatedProductsbyBom
    * @description :    This method receives unique BOM identifiers for the associated products either from LWC or from the findAssociatedProductsHandler method
                        to find associated products details along with their prices and other details. 
    * @param:           List<String> bomIdList, String userId, String networkId
    * @return:          List<AssociatedProductWrapper>
    */
    @auraenabled
    public static List<AssociatedProductWrapper> findAssociatedProductsbyBom(List<String> bomIdList, String userId, String networkId){
        try {
            //List<PRODUCT_BILL_OF_MATERIAL> childBomList = childBomMock();
            List<LAD_Product_Bill_Of_Material__c> childBomList = [  SELECT  LAD_Bill_of_Material_Id__c,
                                                                            LAD_Product_Belron_Id__c,
                                                                            LAD_Product_Bill_of_Material_Quantity__c,
                                                                            LAD_Product_BOM_Mandatory_Ind__c,
                                                                            LAD_Product_Start_Date__c,
                                                                            LAD_Product_End_Date__c
                                                                    FROM LAD_Product_Bill_Of_Material__c 
                                                                    WHERE LAD_Bill_of_Material_Id__c IN :bomIdList AND LAD_Product_BOM_Leading_Product_Ind__c = 'FALSE'];
            Map<String, LAD_Product_Bill_Of_Material__c> oemCodeToBomMap = new Map<String, LAD_Product_Bill_Of_Material__c>();
            Map<String, Product2> productIdToProductMap = new Map<String, Product2>();
            Map<String, QuantityRule> prodIdtoQtyRuleMap = new Map<String, QuantityRule>();
            List<AssociatedProductWrapper> returnWrapperList = new List<AssociatedProductWrapper>();

            String webStoreId;

            if(Test.isRunningTest() == false) {
                webStoreId = [SELECT Id, Name, NetworkId, WebStoreId FROM WebStoreNetwork WHERE NetworkId = :networkId LIMIT 1].WebStoreId;
            }
            else{
                webStoreId = networkId;
            }


            String accountId = [SELECT id, AccountId  FROM User WHERE id =:userid  LIMIT 1].AccountId;

            for(LAD_Product_Bill_Of_Material__c bom: childBomList){
                if(Date.today() >= Date.valueOf(bom.LAD_Product_Start_Date__c) && Date.today() <= Date.valueOf(bom.LAD_Product_End_Date__c)){
                    Boolean newBom = !oemCodeToBomMap.containsKey(bom.LAD_Product_Belron_Id__c);
                    Boolean newBomMoreQuantity = newBom == true ? false : bom.LAD_Product_Bill_of_Material_Quantity__c > oemCodeToBomMap.get(bom.LAD_Product_Belron_Id__c).LAD_Product_Bill_of_Material_Quantity__c;
                    if(newBom || newBomMoreQuantity){
                        oemCodeToBomMap.put(bom.LAD_Product_Belron_Id__c, bom);
                    }
                   
                }
            }

            for(Product2 prod : [   SELECT  Name, 
                                            StockKeepingUnit, 
                                            Description, 
                                            ProductCode, 
                                            LAD_Latest_OEM_Code__c, 
                                            CurrencyIsoCode 
                                    FROM Product2
                                    WHERE isActive = true AND LAD_Latest_OEM_Code__c IN :oemCodeToBomMap.keySet()]){        
                productIdToProductMap.put(prod.Id, prod);                        
            }

            for(ProductQuantityRule qtyRule : [   SELECT    ProductId,
                                                            PurchaseQuantityRule.Minimum, 
                                                            PurchaseQuantityRule.Maximum, 
                                                            PurchaseQuantityRule.Increment
                                                    FROM ProductQuantityRule
                                                    WHERE ProductId IN :productIdToProductMap.keySet()]){
                
                QuantityRule newRule = new QuantityRule();
                newRule.minimum = qtyRule.PurchaseQuantityRule.Minimum;
                newRule.maximum = qtyRule.PurchaseQuantityRule.Maximum;
                newRule.increment = qtyRule.PurchaseQuantityRule.Increment;

                prodIdtoQtyRuleMap.put(qtyRule.ProductId, newRule);
            }

            String urlPrefix = String.valueOf(Url.getOrgDomainUrl().toExternalForm());

            HttpRequest req = new HttpRequest();
            req.setMethod('GET');          
            req.setEndpoint( urlPrefix +  '/services/data/v58.0/commerce/webstores/'+ webStoreId +'/pricing/products?effectiveAccountId=' + accountId + '&productIds=' + String.valueOf(productIdToProductMap.keySet()).replaceAll('[{ }]',''));
            req.setHeader('Authorization','OAuth '+ UserInfo.getSessionId());
            req.setHeader('Accept','*/*');
            Http http = new Http();
            HTTPResponse res = http.send(req);

            Map<String, Object> responseBody = new Map<String, Object>();
            if(JSON.deserializeUntyped(String.valueOf(res.getBody())) instanceOf List<Object>){
                responseBody = (Map<String, Object>) ((List<Object>)JSON.deserializeUntyped(String.valueOf(res.getBody())))[0];
                CalloutException e = new CalloutException();
                e.setMessage((String) responseBody.get('message'));
                throw e;
            }
            else{
                responseBody = (Map<String, Object>) JSON.deserializeUntyped(String.valueOf(res.getBody()));
            }

            if(responseBody.containsKey('pricingLineItemResults')){
               List<Object> productPriceList = (List<Object>) responseBody.get('pricingLineItemResults');
               system.debug('PRICE LIST '+productPriceList);
               system.debug('PRODUCT MAP' + productIdToProductMap);
               for(Object obj : productPriceList){
                    Map<String, Object> prodMap = (Map<String,Object>) obj;
                    if((Boolean) prodMap.get('success')){
                        Product2 currentProduct = productIdToProductMap.get((String) prodMap.get('productId'));
                        LAD_Product_Bill_Of_Material__c currentBom = (oemCodeToBomMap.get(currentProduct.LAD_Latest_OEM_Code__c));
                        AssociatedProductWrapper newWrapper = new AssociatedProductWrapper();
                        newWrapper.id = (String) prodMap.get('productId');
                        newWrapper.name = currentProduct.Name;
                        newWrapper.isEssential = currentBom.LAD_Product_BOM_Mandatory_Ind__c == 'TRUE';
                        newWrapper.sku = currentProduct.StockKeepingUnit;
                        newWrapper.code = currentProduct.ProductCode;
                        newWrapper.isAvailable = false;
                        newWrapper.avlStatus =  '';
                        newWrapper.deliveryDate = '';
                        newWrapper.description = currentProduct.Description;
                        newWrapper.currencyIsoCode = currentProduct.CurrencyIsoCode;
                        newWrapper.unitPrice = (Boolean) prodMap.containsKey('lowestUnitPrice') ? (String) prodMap.get('lowestUnitPrice') : (String) prodMap.get('unitPrice');
                        newWrapper.quantitySuggested = (Integer) currentBom.LAD_Product_Bill_of_Material_Quantity__c;
                        newWrapper.purchaseQuantityRule = prodIdtoQtyRuleMap.containsKey(newWrapper.id) ?  prodIdtoQtyRuleMap.get(newWrapper.id) : null;

                        returnWrapperList.add(newWrapper);
                    }

               }
            }
            
            return returnWrapperList;
        } catch (Exception e) {
            BLN_ExceptionLogger.captureException(e);
            return null;
        }
        
    }


    /**@description :   Wrapper Class to structure data to be returned to LWC. 
   */
    public class  AssociatedProductWrapper{
        @auraenabled public String id {get; set;}
        @auraenabled public String name {get; set;}
        @auraenabled public Boolean isEssential {get; set;}
        @auraenabled public String sku {get; set;}
        @auraenabled public String code {get; set;}
        @auraenabled public Boolean isAvailable {get; set;}
        @auraenabled public String avlStatus {get; set;}
        @auraenabled public String deliveryDate {get; set;}
        @auraenabled public String description {get; set;}
        @auraenabled public String currencyIsoCode {get; set;}
        @auraenabled public String unitPrice {get; set;}
        @auraenabled public Integer quantitySuggested {get; set;}
        @auraenabled public QuantityRule purchaseQuantityRule {get; set;}       
    }

    public class QuantityRule{
        @auraenabled public Double minimum {get; set;}
        @auraenabled public Double maximum {get; set;}
        @auraenabled public Double increment {get; set;}
    }




    // MOCK DATA SET UP
    /* public class PRODUCT_BILL_OF_MATERIAL{
        String Bill_Of_Material_ID {get; set;}
        String Product_Belron_ID {get; set;}
        String Product_Bill_Of_Material_Leading_Product_Ind  {get; set;}
        Integer Product_Bill_Of_Material_Quantity  {get; set;}
        String Product_Bill_Of_Material_Mandatory_Ind  {get; set;}
        String Product_Start_Date  {get; set;}
        String Product_End_Date  {get; set;}
    }

    private static List<PRODUCT_BILL_OF_MATERIAL> parentBomMock(){
        List<PRODUCT_BILL_OF_MATERIAL> returnLeadBomList = new List<PRODUCT_BILL_OF_MATERIAL>();
        PRODUCT_BILL_OF_MATERIAL returnLeadBom = new PRODUCT_BILL_OF_MATERIAL();
        returnLeadBom.Bill_Of_Material_ID = 'BOM1';
        returnLeadBom.Product_Belron_ID = 'OEMCODE-PARENT';
        returnLeadBom.Product_Bill_Of_Material_Leading_Product_Ind = 'TRUE';
        returnLeadBom.Product_Bill_Of_Material_Quantity = 10;
        returnLeadBom.Product_Bill_Of_Material_Mandatory_Ind = 'TRUE';
        returnLeadBom.Product_Start_Date = '2024-06-01';
        returnLeadBom.Product_End_Date = '2024-07-30';

        returnLeadBomList.add(returnLeadBom);
        return returnLeadBomList;

    }

    private static List<PRODUCT_BILL_OF_MATERIAL> childBomMock(){
        List<PRODUCT_BILL_OF_MATERIAL> returnLeadBomList = new List<PRODUCT_BILL_OF_MATERIAL>();
        for(Integer i = 0; i<=1;i++){
            PRODUCT_BILL_OF_MATERIAL returnLeadBom = new PRODUCT_BILL_OF_MATERIAL();
            returnLeadBom.Bill_Of_Material_ID = 'BOM1';
            returnLeadBom.Product_Belron_ID = 'OEMCODE-CHILD' + i;
            returnLeadBom.Product_Bill_Of_Material_Leading_Product_Ind = 'FALSE';
            returnLeadBom.Product_Bill_Of_Material_Quantity =  i == 0 ? 10 : 5;
            returnLeadBom.Product_Bill_Of_Material_Mandatory_Ind = i == 0 ? 'TRUE' : 'FALSE';
            returnLeadBom.Product_Start_Date = '2024-06-01';
            returnLeadBom.Product_End_Date = '2024-07-30';

            returnLeadBomList.add(returnLeadBom);
        }
        
        return returnLeadBomList;

    } */
}