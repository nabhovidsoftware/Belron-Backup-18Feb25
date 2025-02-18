/*****************************************
ClassName : BLN_InitiateAutomPaymentTest 
Description :  FOUK-7125, Test Class For BLN_InitiateAutomPayment
CreatedDate: 04-04-2024
Author: Ayush Kumar Singh (PwC India)
****************************************/
@isTest
public class BLN_InitiateAutomPaymentTest {
 /*****************************************
MethodName : setup
Description : setup method of the test class
Input Parameter : 
Output Parameter : void
CreatedDate: 03-04-2024
CreatedBy : Ayush Kumar Singh (PwC India)
Change log :
****************************************/
@TestSetup
static void setup() {
    Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator']?.Id;
    String role = [SELECT Id FROM UserRole WHERE developerName = 'BLN_UK'].Id;
    User adminUser = new User(
        UserroleId =role,
        ProfileId = adminProfileId,
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
    insert adminUser;
    
    System.runAs(adminUser){
        BLN_Payment__c payment = BLN_TestDataFactory.createPayments();
        payment.BLN_PaymentId__c='6771229992';
        insert payment;
    }
}

/*****************************************
MethodName : testPositive
Description : testPositive method is used to test the Positive Senarios of Apex Class  BLN_InitiateAutomPayment.
Input Parameter : 
Output Parameter : void
CreatedDate: 03-04-2024
CreatedBy : Ayush Kumar Singh (PwC India)
Change log :
****************************************/

@isTest
public static void testPositive() {
    Test.setMock(HttpCalloutMock.class, new BLN_InitiateAutomPaymentMock());            
    Id paymentId = [SELECT ID,BLN_PaymentId__c FROM BLN_Payment__c WHERE BLN_PaymentId__c='6771229992'].Id;
    Test.startTest(); 
    BLN_InitiateAutomPayment pushRef = new BLN_InitiateAutomPayment(paymentId);
    System.enqueueJob(pushRef);
    System.assertequals('Success', 'Success','Success');            
    Test.stopTest();
}
}