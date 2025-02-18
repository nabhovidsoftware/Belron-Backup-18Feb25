/** @description : Test class for BLN_APICalloutPublisherTriggerHandler.
*   @Story : FOUK-867
*   @author: Shubhangi Patil (PwC)
*   @CreatedDate: 27/11/2023
*/
@isTest
private class BLN_SCUtilityTest {
    private Static Id accountRecordId=schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
    
    /*  *@description:This method is used to test BLN_SCUtility's generateCorrelationID method.
*return : void
*/
    @TestSetup
    public static void setupTestData () {
        Account testAccount = BLN_TestDataFactory.createAccountforAPI();
        insert testAccount;

        BLN_Payment__c paymentList = BLN_TestDataFactory.createPayments();
        paymentList.BLN_Status__c='valid';
        paymentList.BLN_PmtBatch__c='MV0000100524';
        insert paymentList;

    }
    @isTest
    static void testGenerateCorrelationID() {
        
       /* Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'Service Agent']?.Id;
        String role = '';
        role= [Select Id FROM UserRole where developerName = 'BLN_UK'].Id;
        User adminUser = new User(
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
        insert adminUser;*/
        User adminUser = BLN_TestDataFactory.createAdminUser('lastName');
        
        System.runAs(adminUser){
            Test.startTest();
            String correlationID = BLN_SCUtility.generateCorrelationID();
            System.assert(correlationID.contains('-'), ' ID  contain dashes');
            String secondCorrelationID = BLN_SCUtility.generateCorrelationID();
            BLN_SCUtility.generateRandomAlphabetString();
            System.assertNotEquals(correlationID, secondCorrelationID, ' IDs should be unique');
            Test.stopTest();
        }
        
    }
    
    /*  *@description:This method is used to test BLN_SCUtility's getMotoristDataforMDMSync method.
*return : void
*/
    @isTest
    static void testGetMotoristDataforMDMSync() {
        Account testAccount = [Select Id from Account LIMIT 1];
        Test.startTest();
        Account resultAccount = BLN_SCUtility.getMotoristDataforMDMSync(testAccount.Id);
        Test.stopTest();
        System.assertNotEquals(null, resultAccount,'resultaccount can not be null');
    }
    
    /*  *@description:This method is used to test BLN_SCUtility's getMotoristDataforMDMSync method nagative scenario.
*return : void
*/
    @isTest
    static void testMotoristData() {
        //Account testAccount = [Select Id from Account LIMIT 1];
        Test.startTest();
        Account resultAccount = BLN_SCUtility.getMotoristDataforMDMSync(null);
        Test.stopTest();
        System.assertEquals(null, resultAccount,'resultaccount is null');
        Exception ex;
        System.assertEquals(resultAccount,Null,'resultaccount is null');
        System.assertEquals(ex,Null,'ex is null');
        
    }
    
/*  *@description:This method is used to test BLN_SCUtility's paymentFieldsPopulation method.
*return : void
*/    
    @isTest
     static void testPaymentFieldsPopulation() {
        BLN_Payment__c paymentList = [Select Id FROM BLN_Payment__c LIMIT 1];
        List<BLN_Payment__c> updatedPayments = [SELECT Id,createddate,BLN_Case__c,BLN_First6DigitsofCard__c,BLN_Last4DigitsOfCard__c,LastModifiedDate,BLN_PmtGatewayProvider__c,BLN_PaymentMethod__c,BLN_Status__c, BLN_CR__c, BLN_TxnId__c,BLN_PaymentId__c, BLN_PaymentStatus__c,BLN_PaymentType__c,BLN_RctMethod__c, BLN_OriginalPayment__r.BLN_PmtGatewayProvider__c FROM BLN_Payment__c WHERE Id=: paymentList.id];
        BLN_SCUtility.paymentFieldsPopulation(updatedPayments);
        System.assertNotEquals(null, updatedPayments[0].BLN_CR__c, 'BLN_CR__c should not be null');
        System.assertNotEquals(null, updatedPayments[0].BLN_TxnId__c, 'BLN_TxnId__c should not be null');
        
    }  
    
 /*  *@description:This method is used to test BLN_SCUtility's paymentReceiptMethodPopulation method.
*return : void
*/    
    @isTest
    static void testpaymentReceiptMethodPopulation() {
        BLN_Payment__c paymentList = [Select Id FROM BLN_Payment__c LIMIT 2];
        
        List<BLN_Payment__c> updatedPayments = [SELECT Id,createddate,BLN_Case__c,LastModifiedDate,BLN_Status__c,BLN_PaymentId__c,BLN_RctMethod__c,BLN_CardType__c,BLN_PaymentType__c,BLN_Last4DigitsOfCard__c,BLN_First6DigitsofCard__c, BLN_PaymentStatus__c FROM BLN_Payment__c WHERE Id=: paymentList.id];
        BLN_SCUtility.paymentReceiptMethodPopulation(updatedPayments);
        
        System.assertEquals('valid', updatedPayments[0].BLN_Status__c, 'status is valid');
        System.assertEquals('On-line International Maestro', updatedPayments[0].BLN_CardType__c, 'Card type should be updated to EcommsCard for ecommerce payments');  
        
    }
    
    
/*  *@description:This method is used to test BLN_SCUtility's paymentReceiptMethodPopulation method.
*return : void
*/    
    @isTest
    static void testpaymentReceiptIdMethodPopulation() {
        BLN_Payment__c paymentList = [Select Id FROM BLN_Payment__c LIMIT 1];
        
        List<BLN_Payment__c> updatedPayments = [SELECT Id,createddate,BLN_Case__c,LastModifiedDate,BLN_Status__c,BLN_RctMethod__c,BLN_CardType__c,BLN_Last4DigitsOfCard__c,BLN_First6DigitsofCard__c, BLN_PaymentStatus__c,BLN_PaymentType__c,BLN_RctMethodId__c FROM BLN_Payment__c WHERE Id=: paymentList.id];
        BLN_SCUtility.paymentReceiptIdMethodPopulation(updatedPayments);
        System.assertEquals('ONLINE PAYMENT', updatedPayments[0].BLN_PaymentType__c, 'payment type should not be null');
        
    }
        @isTest
    static void testpaymentBatchDetermination() {
        BLN_Payment__c paymentList = [Select Id FROM BLN_Payment__c LIMIT 1];
        //string pmtbatch = '';
        //pmtbatch = 'SW0000'
        // Get the current date
        Date currentDate = Date.today();
        // Convert to DateTime for formatting
        DateTime currentDateTime = DateTime.newInstance(currentDate.year(), currentDate.month(), currentDate.day());
        // Format the date as a string in ddMMyy format
        String formattedDate = currentDateTime.format('ddMMyy');
        // Concatenate with "SW0000"
        String result = 'SW0000' + formattedDate;


        List<BLN_Payment__c> updatedPayments = [SELECT Id,createddate,BLN_Case__c,LastModifiedDate,BLN_Status__c,BLN_PmtBatch__c, BLN_PaymentId__c,BLN_RctMethod__c,BLN_CardType__c,BLN_PaymentType__c,BLN_Last4DigitsOfCard__c,BLN_First6DigitsofCard__c, BLN_PaymentStatus__c FROM BLN_Payment__c WHERE Id=: paymentList.id];
        BLN_SCUtility.paymentBatchDetermination(updatedPayments);
        BLN_SCUtility.paymentTokenIdConcatinate(updatedPayments);
        
        //System.assertEquals('MV0000100524', updatedPayments[0].BLN_PmtBatch__c, 'Payment batch should be updated with the correct prefix');
         System.assertEquals(result, updatedPayments[0].BLN_PmtBatch__c, 'Payment batch should be updated with the correct prefix');
    }
   
   
}