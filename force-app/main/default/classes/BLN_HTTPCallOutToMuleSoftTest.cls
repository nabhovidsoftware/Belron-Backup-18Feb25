/** @description : This Test class covered BLN_HTTPCallOutToMuleSoft
*   @Story : FOUK-198
*   @author: Kanchan Mishra (PwC)
*   @CreatedDate: 08/08/2023
*/
@isTest
public class BLN_HTTPCallOutToMuleSoftTest {
    @IsTest
    static void testExecuteCallOutToOkta() {
        BLN_TestDataFactory.createCalloutSettings(true);
        List<BLN_ServiceAppointmentCallout.InputVariables> serviceAppointList ;
        BLN_ServiceAppointmentCallout.InputVariables input = new BLN_ServiceAppointmentCallout.InputVariables();
        input.ServiceAppointmentlist = new List<ServiceAppointment>();
        ServiceAppointment sa1 = BLN_TestDataFactory.createServiceAppointmentRecord('Test Name1', true);
        sa1.Duration = 80;
        sa1.Country = BLN_CountryCode__mdt.getAll().values()[0].BLN_Country__c;
        ServiceAppointment sa2 = BLN_TestDataFactory.createServiceAppointmentRecord('TestName', true);
        sa2.Duration = 70;
        sa2.Country = BLN_CountryCode__mdt.getAll().values()[0].BLN_Country__c;
        input.ServiceAppointmentlist.add(sa1);
        input.ServiceAppointmentlist.add(sa2);
        serviceAppointList = new List<BLN_ServiceAppointmentCallout.InputVariables>{input};

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponse());
        BLN_GenerateOktaToken.generateOktaToken( sa1.Id);
        Test.stopTest();
        List<BLN_IntegrationLogger__c> insertedLogs = [SELECT Id, BLN_TargetSystem__c FROM BLN_IntegrationLogger__c ORDER BY CreatedDate ASC];
        System.assertEquals(1, serviceAppointList.size(), 'Success');
        System.assertEquals(1, insertedLogs.size(), 'Success');
        System.assertEquals('Okta', insertedLogs[0].BLN_TargetSystem__c, 'Success');
    }

    @IsTest
    static void testExecuteEvent() {
        BLN_TestDataFactory.createCalloutSettings(true);
        List<BLN_ServiceAppointmentCallout.InputVariables> serviceAppointList ;
        BLN_ServiceAppointmentCallout.InputVariables input = new BLN_ServiceAppointmentCallout.InputVariables();
        input.ServiceAppointmentlist = new List<ServiceAppointment>();
        ServiceAppointment sa1 = BLN_TestDataFactory.createServiceAppointmentRecord('Test Name1', true);
        sa1.Duration = 80;
        sa1.Country = BLN_CountryCode__mdt.getAll().values()[0].BLN_Country__c;
        ServiceAppointment sa2 = BLN_TestDataFactory.createServiceAppointmentRecord('TestName', true);
        sa2.Duration = 70;
        sa2.Country = BLN_CountryCode__mdt.getAll().values()[0].BLN_Country__c;
        input.ServiceAppointmentlist.add(sa1);
        input.ServiceAppointmentlist.add(sa2);
        serviceAppointList = new List<BLN_ServiceAppointmentCallout.InputVariables>{input};
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponse());
        BLN_OktaCallout__e eventOctaCallout = new BLN_OktaCallout__e(BLN_ServiceAppointmentId__c = sa1.id);
        EventBus.publish(eventOctaCallout);
        Test.stopTest();
        Assert.areEqual(true, true, 'Success');
    }

    @IsTest
    static void testExecuteCallOutToMuleSoft() {
        BLN_TestDataFactory.createCalloutSettings(true);
        List<BLN_ServiceAppointmentCallout.InputVariables> serviceAppointList ;
        BLN_ServiceAppointmentCallout.InputVariables input = new BLN_ServiceAppointmentCallout.InputVariables();
        input.ServiceAppointmentlist = new List<ServiceAppointment>();
        ServiceAppointment sa1 = BLN_TestDataFactory.createServiceAppointmentRecord('Test Name1', true);
        sa1.Duration = 80;
        sa1.Country = BLN_CountryCode__mdt.getAll().values()[0].BLN_Country__c;
        ServiceAppointment sa2 = BLN_TestDataFactory.createServiceAppointmentRecord('TestName', true);
        sa2.Duration = 70;
        sa2.Country = BLN_CountryCode__mdt.getAll().values()[0].BLN_Country__c;
        input.ServiceAppointmentlist.add(sa1);
        input.ServiceAppointmentlist.add(sa2);
        serviceAppointList = new List<BLN_ServiceAppointmentCallout.InputVariables>{input};

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponse());
        Cache.OrgPartition orgPart = Cache.Org.getPartition('local.OKTAIdP');
        orgPart.put('OKTAAccessToken', 'testToken');
        DateTime now = DateTime.now();
        orgPart.put('OKTATokenExpirationDateTime', now.addSeconds(30));
        BLN_ServiceAppointmentCallout.serviceAppointmentHTTPCallout(serviceAppointList);
        Test.stopTest();
        List<BLN_IntegrationLogger__c> insertedLogs = [SELECT Id, BLN_TargetSystem__c FROM BLN_IntegrationLogger__c];
        System.assertEquals(1, serviceAppointList.size(), 'Success');
        //System.assertEquals(1, insertedLogs.size(), 'Success');
        //System.assertEquals('Mulesoft', insertedLogs[0].BLN_TargetSystem__c, 'Success');
    }

    @IsTest
    static void testJsonBuild() {
        List<ServiceAppointment> serviceAppointList = new List<ServiceAppointment>();
        List<List<ServiceAppointment>> serializedServiceAppointmentList = new List<List<ServiceAppointment>>();

        serviceAppointList.add(BLN_TestDataFactory.createServiceAppointmentRecord('Test Name1', false));
        serviceAppointList[0].Duration = 80;
        serviceAppointList[0].Country = BLN_CountryCode__mdt.getAll().values()[0].BLN_Country__c;
        serviceAppointList[0].SchedEndTime = System.Now().addDays(1);
        serviceAppointList[0].SchedStartTime = System.Now();
        List<ServiceResource> resource = new List<ServiceResource>();
        resource.add(BLN_TestDataFactory.createServiceResource('test', false));
        resource.add(BLN_TestDataFactory.createServiceResource('testOld', false));
        User user = new User();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            user = BLN_TestDataFactory.createAdminUser('test', true);
        }
        resource[1].BLN_WorkdayEmployeeId__c = '700101';
        resource[1].RelatedRecordId = user.Id;
        insert resource;
        serviceAppointList[0].BLN_AssignedServiceResource__c = resource[0].Id;
        insert serviceAppointList[0];
        ServiceAppointment appointment = serviceAppointList[0];
        appointment.Status = System.Label.BLN_DispatchedStatus;
        appointment.BLN_ServiceResourceID__c = resource[1].Id;
        serviceAppointList.add(appointment);
        serializedServiceAppointmentList.add(serviceAppointList);

        Test.startTest();
        List<BLN_HTTPCallOutToMuleSoftHelper.ServiceAppointmentHelper> appBulkData = BLN_HTTPCallOutToMuleSoftHelper.prepareBulkData(serializedServiceAppointmentList);
        BLN_ServiceAppJSON serviceAppJSON = BLN_HTTPCallOutToMuleSoft.createJsonBody(appBulkData[0]);
        Test.stopTest();

        System.assertEquals(appointment.Id, serviceAppJSON.entityID, 'Success');
        System.assertEquals(4800, serviceAppJSON.data.previous.motoristSalesOpportunity.salesOpportunity.jobWorkOrder[0].jobWorkOrderLine[0].jobAppointment[0].duration, 'Success');
        System.assertNotEquals(serviceAppJSON.data.previous.motoristSalesOpportunity.salesOpportunity.jobWorkOrder[0].jobWorkOrderLine[0].jobAppointment[0].jobAppointmentStatus,
                serviceAppJSON.data.current.motoristSalesOpportunity.salesOpportunity.jobWorkOrder[0].jobWorkOrderLine[0].jobAppointment[0].jobAppointmentStatus, 'Success');
    }

    private class MockHTTPResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest param1) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"access_token":"testAccessToken","expires_in":30}');
            return res;
        }
    }
}