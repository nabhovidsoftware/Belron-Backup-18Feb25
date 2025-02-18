/*****************************************
*ClassName : BLN_InsuranceDetailFormControllerTest
*@description : FOUK-6986 This is to test BLN_InsuranceDetailFormController .
*CreatedDate: 12-04-2024
*CreatedBy : PwC-India
****************************************/
@isTest
public class BLN_InsuranceDetailFormControllerTest {
     /*MethodName : testCreateTask
*@description : This method is used to test createTask 
*@return void
*@param 
*Output Parameter : 
*CreatedDate: 12-04-2024
*CreatedBy : Pwc-India
*Change log :
****************************************/
    @isTest
    static void testCreateTask() {
        // Create a test case record
        Case testCase = new Case(
            Subject = 'Test Case',
            Description = 'Test Description'
        );
        insert testCase;
        
        // Generate dummy base64 data and filename for testing
        String base64Data = EncodingUtil.base64Encode(Blob.valueOf('Test Data'));
        String fileName = 'Test_File.txt';
        
        test.startTest();
        Boolean insuranceFlag = BLN_InsuranceDetailFormController.createTask(testCase.Id, 'Test Description', base64Data, fileName);
        test.stopTest();

        // Assert that the insuranceFlag is true
        System.assertEquals(true, insuranceFlag, 'Insurance flag should be true if task is successfully created');
        System.assertNotEquals(false, insuranceFlag, 'Insurance flag should be false if task not successfully created');

        
    }
}