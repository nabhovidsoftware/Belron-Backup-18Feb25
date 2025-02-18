@isTest
global with sharing class BLN_InvoiceCalloutMock implements HttpCalloutMock{
    
    @testSetup static void setup() {
        Case c = new Case();
        c.Status='New';
        c.Type = 'Job Request';
        c.BLN_SubType__c = 'Job Request';
        insert c;
        system.assertNotEquals(c, null);
    }

    global HTTPResponse respond(HTTPRequest request) {       
        HttpResponse response = new HttpResponse();
        Case c = [SELECT Id FROM Case WHERE BLN_SubType__c =: 'Job Request' limit 1];
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"timestamp":"2024-07-19T10:06:07.479Z","sourceSystem":"Salesforce","initialisedSystem":"Salesforce","eventType":"Create","entityName":"BULK_JOB","entityID":"'+c.Id+'","data":{"current":{"caseId":"'+c.Id+'"}}}');
        response.setStatusCode(200);
        return response; 
    }
}