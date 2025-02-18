/** @description : BLN_DecodeWorldPayMobileResponseTest Class used for testing BLN_DecodeWorldPayMobileResponse.
*  	@autor: Gaurav Giradkar
* 	@Story: FOUK-1609
*	@Created Date: 22/07/2024
*/
@isTest
public with sharing class BLN_DecodeWorldPayMobileResponseTest {
    
    @isTest
    public static void decodeWorldPayResponseTest(){
        String urlToDecode = System.label.BLN_PaymentResponseURL;
        WorkOrderLineItem woli = BLN_TestDataFactory.createWOLI();
        Test.startTest();
        Boolean returnResponse = BLN_DecodeWorldPayMobileResponse.decodeWorldPayResponse(urlToDecode, woli.Id);
        Test.stopTest();
        System.assertEquals(true, returnResponse,'return should be true');
    }
}