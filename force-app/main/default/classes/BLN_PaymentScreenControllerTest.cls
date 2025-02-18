/*****************************************
ClassName : BLN_PaymentScreenControllerTest
Description : FOUK-4838 This test class is used to cover testcoverage for BLN_PaymentScreenController.
CreatedDate: 22-12-2023
CreatedBy : PwC-India
****************************************/
/*  *@description: This method is used to test BLN_PaymentScreenController getUserPermissionSet class.
    *return : void
*/
@IsTest
public class BLN_PaymentScreenControllerTest {

/*
    @IsTest
        public static void paymentScreenControllerTest() {
            Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'Service Agent']?.Id;
            String role = '';
            role= [Select Id FROM UserRole where developerName = 'BLN_UK'].Id;
        	User cERUser = new User(
            ProfileId = adminProfileId,
            UserroleId =role,
            FirstName = 'PS',
            LastName = 'Test User',
            UserName = System.now().getTime() + '@test.demo',
            Alias = 'pstes',
            Email = 'test@sample.demo',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'nl_NL',
            TimeZoneSidKey = UserInfo.getTimeZone().getID(),
            UserPermissionsSupportUser = true);
        	String retValue;
        try{
        	insert cERUser;
        }
        catch(Exception e){
            BLN_ExceptionLogger.captureException(e);
        }
                
        try{
        Database.insert(new PermissionSetAssignment (PermissionSetId = [Select id from PermissionSet where Name='BLN_CER']?.id , AssigneeId=CerUser.id));
        }
        catch(Exception e){
            BLN_ExceptionLogger.captureException(e);
        }
        
        //true value check
        Test.startTest();
        System.runAs(cERUser){
        retValue = BLN_PaymentScreenController.getUserPermissionSet();
            Assert.isTrue(retValue == 'true','test check');
        Test.stopTest();
        }
    }
*/


    
@TestSetup
static void testSetupData(){
   User u =   BLN_TestDataFactory.createCERUser('Test User6982',True);
    u.LastName = 'Test User6982';
    update u;
   PermissionSet permSet = [SELECT Id FROM PermissionSet WHERE Label = 'CER' LIMIT 1];
        PermissionSetAssignment permSetAssign = new PermissionSetAssignment(
            PermissionSetId = permSet.Id,
            AssigneeId = u.Id
        );

        try {
            insert permSetAssign;
        } catch (Exception e) {
            BLN_ExceptionLogger.captureException(e);
        }
    }
    
    @isTest
    public static void paymentScreenControllerTest() {

        String retValue;
       // Retrieve the test data created in @testSetup
       User cERUser1 = [SELECT Id,LastName FROM User WHERE LastName = 'Test User6982' Limit 1];
       
             //true value check
                Test.startTest();
                System.runAs(cERUser1){
                retValue = BLN_PaymentScreenController.getUserPermissionSet();
            System.assertEquals('true', retValue, 'Returned value should be true as CER is assigned');   
                 }
                Test.stopTest();
}
}