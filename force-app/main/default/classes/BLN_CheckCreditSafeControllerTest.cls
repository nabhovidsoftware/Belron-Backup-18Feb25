/** @description : Test class for BLN_CheckCreditSafeController.
*   @Story : FOUK-602
*   @author:PWC-India
*   @CreatedDate: 06/12/2023 
*/
@isTest
public class BLN_CheckCreditSafeControllerTest {
    /*****************************************
*MethodName : testMakeCallOutSuccess
*@description This method is used to test CallOutSuccess.
*Input Parameter : 
*Output Parameter : void
*CreatedDate: 07-12-2023
*CreatedBy : Pwc-India
*Change log :
****************************************/
    @isTest
    static void testMakeCallOutSuccess() {
        
        // Set up a mock HTTP callout to simulate external API calls.
        Test.setMock(HttpCalloutMock.class, new BLN_CheckCreditSafeMock());
        
        List<String>testAccountIds = new List<String>();
        Account testAccount = BLN_TestDataFactory.createSalesAccount('TestMockB2BAccount1','Agriculture','Underwriter',1,'Insurance','GB123456779', 'AA161811','San Francisco', 'testStreet','12345' ,'GB','Blue Anchor' ,'Minehead',
                                                                     '7890' , 'United Kingdom','BLN_CustomerB2BAccount');
        insert testAccount;
        testAccountIds.add(testAccount.Id);
        User testSalesPerson = BLN_TestDataFactory.createSalesTestUser('salesuser' + DateTime.now().getTime() + '@testorg.com', 'Belron Integration Profile', 'salesus', 'salesuser@testorg.com', 'Testing',
                                                                       'en_US', 'en_US', 'Europe/London', 'UTF-8');
        
        String creditSafeStatus = '';                                                              
        // Start the test context.
        test.startTest();
        creditSafeStatus = BLN_CheckCreditSafeController.checkCreditSafe(testAccountIds)[0];
        // Stop the test context.
        
        test.stopTest();
        
        //System.runAs(testSalesPerson){ 
            System.assertEquals('OK' , creditSafeStatus , 'creditSafeStatus should have OK value');
            System.assertNotEquals(creditSafeStatus ,'', 'creditSafeStatus should not  have Null  value');
       // }
    }
}