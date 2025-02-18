@isTest
public class BLN_ProductIdentifierUtilityTest {
@isTest
    static void getProductIndentifyTest(){           
        Set<String> productCodes = new Set<String>();
        String data = [SELECT BLN_CategoryCode__c, BLN_MatchingCriteria__c, BLN_Type__c FROM BLN_ProductIdentifier__mdt LIMIT 1].BLN_CategoryCode__c;
      
        productCodes.add(data);
        Test.startTest();
        BLN_ProductIdentifierUtility.getProductIndentify(System.Label.BLN_PRIME);
       
        Test.stopTest(); 
        System.assertNotEquals(data, null,'test');
    }
@isTest
    static void getAppointmentExcludedProductCodesTest(){
        Test.startTest();
        BLN_ProductIdentifierUtility.getAppointmentExcludedProductCodes();
       BLN_ProductIdentifierUtility.getRepairProduct();
        Test.stopTest(); 
        
    }
}