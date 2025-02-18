@IsTest
public with sharing class BLN_InvoiceCalloutControllerTest {
   
   @testSetup static void setup() {

        Case c = new Case();
        c.Status='New';
        c.Type = 'Job Request';
        c.BLN_SubType__c = 'Job Request';
        insert c;
        system.assertNotEquals(c, null);
    }

    static testMethod void testShowOutstandingBalance() {
        
        // Mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new BLN_InvoiceCalloutMock());
        Case c = [SELECT Id FROM Case WHERE BLN_SubType__c =: 'Job Request' limit 1];
        Test.startTest();
        BLN_InvoiceCalloutController.syncCloseCompletedCase(new List<String>{c.id+'~Create'});
        Test.stopTest();
    }  
}