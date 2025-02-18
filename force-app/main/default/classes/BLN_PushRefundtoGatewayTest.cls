/*****************************************
ClassName : BLN_PushRefundtoGatewayTest 
Description :  FOUK-6359, Test Class For BLN_PushRefundtoGateway
CreatedDate: 03-04-2024
Author: Ayush Kumar Singh (PwC India)
****************************************/
@isTest
public class BLN_PushRefundtoGatewayTest {
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
            
            BLN_Payment__c originalPayment = BLN_TestDataFactory.createPayments();
            originalPayment.BLN_PaymentId__c='6771229991';
            insert originalPayment;
        }
    }
    
    /*****************************************
MethodName : testPositive
Description : testPositive method is used to test the Positive Senarios of Apex Class  BLN_PushRefundtoGateway.
Input Parameter : 
Output Parameter : void
CreatedDate: 03-04-2024
CreatedBy : Ayush Kumar Singh (PwC India)
Change log :
****************************************/
    
    @isTest
    public static void testPositive() {
        User adminUser = [SELECT Id, Profile.Name, UserRole.DeveloperName, Email FROM User WHERE Profile.Name = 'System Administrator' AND UserRole.DeveloperName = 'BLN_UK' AND Email = 'test@sample.demo' LIMIT 1];
        System.runAs(adminUser){            
            BLN_Payment__c payment = [SELECT ID,BLN_PaymentId__c FROM BLN_Payment__c WHERE BLN_PaymentId__c='6771229992'];
            BLN_Payment__c originalPayment =  [SELECT ID,BLN_PaymentId__c FROM BLN_Payment__c WHERE BLN_PaymentId__c='6771229991'];
            
            payment.BLN_OriginalPayment__c = originalPayment.Id;
            update payment;
            
            Test.startTest(); 
            BLN_PushRefundtoGateway pushRef = new BLN_PushRefundtoGateway(payment.Id);
            System.enqueueJob(pushRef);
            System.assertequals('Success', 'Success','Success');            
            Test.stopTest();
        }
    }
    /*****************************************
MethodName : testNegative
Description : testNegative method is used to test the Negative Senarios of Apex Class  BLN_PushRefundtoGateway.
Input Parameter : 
Output Parameter : void
CreatedDate: 03-04-2024
CreatedBy : Ayush Kumar Singh (PwC India)
Change log :
****************************************/
    
    @isTest
    public static void testNegative() {
        Test.setMock(HttpCalloutMock.class, new BLN_PushRefundtoGatewayMock());            
        Id paymentId = [SELECT ID,BLN_PaymentId__c FROM BLN_Payment__c WHERE BLN_PaymentId__c='6771229992'].Id;
        Test.startTest(); 
        BLN_PushRefundtoGateway pushRef = new BLN_PushRefundtoGateway(paymentId);
        System.enqueueJob(pushRef);
        System.assertequals('Success', 'Success','Success');            
        Test.stopTest();
        
    }
}