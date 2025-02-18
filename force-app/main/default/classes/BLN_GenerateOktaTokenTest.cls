/** @description : Test Class for BLN_GenerateOktaToken
*  @author: mluniewski002
* @CreatedDate: 18.01.2024
*/

@IsTest
private class BLN_GenerateOktaTokenTest {

    //Test Setup 
    @TestSetup
    static void makeData(){

        //Create lists to store data
        List<ServiceAppointment> serviceAppointList = new List<ServiceAppointment>();
        List<List<ServiceAppointment>> serializedServiceAppointmentList = new List<List<ServiceAppointment>>();

        serviceAppointList.add(BLN_TestDataFactory.createServiceAppointmentRecord('Test Name1', true));
        serviceAppointList[0].Duration = 80;
        ServiceAppointment appointment = serviceAppointList[0];
        serviceAppointList.add(appointment);
        serializedServiceAppointmentList.add(serviceAppointList);

        
    }

    /** @description : Test Method for BLN_GenerateOktaToken
*/
    @IsTest
    static void testGenerationOfOktaToken() {
        List<ServiceAppointment> serviceAppointList = new List<ServiceAppointment>();
        List<List<ServiceAppointment>> serializedServiceAppointmentList = new List<List<ServiceAppointment>>();

        serviceAppointList.add(BLN_TestDataFactory.createServiceAppointmentRecord('Test Name3', true));
        serviceAppointList[0].Duration = 80;
        ServiceAppointment appointment = serviceAppointList[0];
        serviceAppointList.add(appointment);
        serializedServiceAppointmentList.add(serviceAppointList);

        Test.startTest();
        List<BLN_HTTPCallOutToMuleSoftHelper.ServiceAppointmentHelper> appBulkData = BLN_HTTPCallOutToMuleSoftHelper.prepareBulkData(serializedServiceAppointmentList);
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponse());
        BLN_GenerateOktaToken.generateOktaToken( serviceAppointList[0].Id);
        Test.stopTest();
        List<BLN_IntegrationLogger__c> integrationLogger = [SELECT Id, BLN_ResponseBody__c FROM BLN_IntegrationLogger__c ORDER BY CreatedDate ASC];
        Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped((integrationLogger[0].BLN_ResponseBody__c));
        String oktaToken = (String)results.get('access_token');
        System.assertNotEquals(null, integrationLogger, 'Success');
        System.assertEquals('testAccessToken', oktaToken, 'Success');
    }

    private class MockHTTPResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest param1) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"access_token":"testAccessToken","expires_in":30}');
            return res;
        }
    }

    /** @description : Test Method for BLN_GenerateOktaToken
*/
    @IsTest
    static void testGenerationOfOktaToken2() {

        //Create lists to store data
        List<ServiceAppointment> serviceAppointList = new List<ServiceAppointment>();
        List<List<ServiceAppointment>> serializedServiceAppointmentList = new List<List<ServiceAppointment>>();

        serviceAppointList.add(BLN_TestDataFactory.createServiceAppointmentRecord('Test Name4', true));
        serviceAppointList[0].Duration = 80;
        ServiceAppointment appointment = serviceAppointList[0];
        serviceAppointList.add(appointment);
        serializedServiceAppointmentList.add(serviceAppointList);

        Test.startTest();
        List<BLN_HTTPCallOutToMuleSoftHelper.ServiceAppointmentHelper> appBulkData = BLN_HTTPCallOutToMuleSoftHelper.prepareBulkData(serializedServiceAppointmentList);
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponse());
        BLN_GenerateOktaToken.generateOktaToken( serviceAppointList[0].Id);
        Test.stopTest();

        List<BLN_IntegrationLogger__c> integrationLogger = [SELECT Id, BLN_ResponseBody__c FROM BLN_IntegrationLogger__c ORDER BY CreatedDate ASC];
        Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped((integrationLogger[0].BLN_ResponseBody__c));
        String oktaToken = (String)results.get('access_token');

        //Assert
        System.assertNotEquals(null, integrationLogger,'Assert is not null');
        System.assertEquals('testAccessToken', oktaToken,'testAccessToken');
    }
}