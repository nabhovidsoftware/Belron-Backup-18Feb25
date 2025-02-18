/** 
 * @description : Test class for BLN_MDM_TriggerHandlerTest.
 * @Story : FOUK-
 * @author: PWC-India
 * @CreatedDate: 
 */
@isTest
public class BLN_MDM_TriggerHandlerTest {
    /** 
     * MethodName : insertAccountTest
     * @description: This method tests the insertion and update of an Account record.
     * Input Parameter : None
     * Output Parameter : void
     * CreatedBy : Pwc-India
     * Change log : 
     */
    @isTest
    static void insertAccountTest() {
        // Start the test context.
        Test.startTest();
        
        Account testAccount = BLN_TestDataFactory.createSalesAccount('TestMockB2BAccount1','Agriculture','Underwriter',1,'Insurance','GB123456779', 'AA161811','San Francisco', 'testStreet','12345' ,'GB','Blue Anchor' ,'Minehead',
                                                                     '7890' , 'United Kingdom','BLN_CustomerB2BAccount');        
        insert testAccount;        

        testAccount.Name = 'TestMockB2BAccount12';
        update testAccount;
        
        // Stop the test context.
        Test.stopTest();
    }
}