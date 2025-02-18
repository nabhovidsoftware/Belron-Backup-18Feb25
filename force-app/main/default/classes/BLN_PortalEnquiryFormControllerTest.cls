/*****************************************
*ClassName : BLN_PortalEnquiryFormControllerTest
*@description : FOUK- This is test class of Bln_PortalEnquiryFormController
*CreatedDate: 29-04-2024
*CreatedBy : PwC-India
****************************************/
@isTest
public class BLN_PortalEnquiryFormControllerTest {
    
    /*MethodName : createCaseRecordTest
*@description : This method is used for to test createCaseRecord Method
*@return void
*@param 
*Output Parameter : 
*CreatedDate: 29-04-2024
*CreatedBy : Pwc-India
*Change log :
****************************************/    
    @isTest
    static void createCaseRecordTest() {
        
        // Create test Case record
        Case testCase = new Case();
        testCase.Subject = 'Test Case';
        testCase.Description = 'Test Description';
        
        
      /*  //fetch b2b community profile
        Profile profile = [SELECT ID FROM Profile WHERE Name ='Belron B2B Portal Customer Community User' LIMIT 1];
        
        User testPortalUser = new User (Alias ='Stadt',
                                        Email = 'testsit@testorg.com',
                                        FirstName = 'Testing',
                                        LastName = 'TestUserLastName',
                                        Username = 'testsit@testorg.com',
                                        CommunityNickname = 'test1user@example.com',
                                        EmailEncodingKey = 'UTF-8',
                                        LanguageLocaleKey = 'en_US',
                                        LocaleSidKey = 'en_US',
                                        TimeZoneSidKey = 'America/Los_Angeles',
                                        IsActive = true,                     
                                        ProfileId = profile.id, ContactId=testContact.Id,UserRoleId = UserInfo.getUserRoleId());
       
        insert testPortalUser;
*/


        // Generate dummy base64 data and filename for testing
        String base64Data = EncodingUtil.base64Encode(Blob.valueOf('Test Data'));
        String fileName = 'Test_File.txt';
         Map<String,String> caseRecordMap = new Map<String,string>();

        // Call the method under test
       
            Test.startTest();
            caseRecordMap = BLN_PortalEnquiryFormController.createCaseRecord(testCase, base64Data , fileName);
            Test.stopTest();
            
            Case caseRecord = [Select id from case where id = : caseRecordMap.get('Id') limit 1];
            // Assert that the case was inserted
            System.assertEquals(caseRecord.Id,caseRecordMap.get('Id'), 'case is inserted');
            System.assertNotEquals(null,caseRecordMap, 'case is not  inserted');
        
    }
   /*MethodName : testIsVRNRegistered
*@description : This method is used for to test IsVRNRegistered Method
*@return void
*@param 
*Output Parameter : 
*CreatedDate: 29-04-2024
*CreatedBy : Pwc-India
*Change log :
****************************************/      
     @isTest
    static void testIsVRNRegistered() {
        // Test scenario when vehicle is registered
        BLN_Vehicle__c testVehicle = new BLN_Vehicle__c(BLN_VehicleRegNumber__c = 'TestVRN');
        insert testVehicle;

        String vehicleId = BLN_PortalEnquiryFormController.isVRNRegistered('TestVRN');
        System.assertEquals(testVehicle.Id, vehicleId, 'vehicleId matched');

        // Test scenario when vehicle is not registered
        String nonExistentVehicleId = BLN_ComplaintRaisecontroller.isVRNRegistered('vrnNotExist');
        System.assertEquals(null, nonExistentVehicleId, 'vehicleId not matched');
    }


}