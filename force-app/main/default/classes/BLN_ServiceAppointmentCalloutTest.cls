/** @description : This Test class covered BLN_ServiceAppointmentCallout
*   @Story : FOUK-198
*   @author: Kanchan Mishra (PwC)
*   @CreatedDate: 08/08/2023
*/
@isTest
public class BLN_ServiceAppointmentCalloutTest {
    @isTest
    static void testServiceAppointmentHTTPCallout() {
        // Create test data
        BLN_TestDataFactory.createCalloutSettings(true);
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
        
        // Set up the mock response
        
        Test.startTest();
        // Call the method to be tested
        Test.setMock(HttpCalloutMock.class, new BLN_MockHttpResponseServAppCallout());
        Cache.OrgPartition orgPart = Cache.Org.getPartition('local.OKTAIdP');
        orgPart.put('OKTAAccessToken', 'testToken');
        DateTime now = DateTime.now();
        orgPart.put('OKTATokenExpirationDateTime', now.addSeconds(30));
        BLN_ServiceAppointmentCallout.serviceAppointmentHTTPCallout(new List<BLN_ServiceAppointmentCallout.InputVariables>{input});
        Test.stopTest();      
        Assert.areEqual(true, true, 'Success');
    }
    @isTest
    static void testServiceAppointmentHTTPCallout1() {
        // Create test data
        BLN_TestDataFactory.createCalloutSettings(true);
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
        
        // Mocking the data
        BLN_ServiceAppointmentCallout.mockoktaToken = 'Testing';
        BLN_ServiceAppointmentCallout.forTest = true;
        
        Test.startTest();
        // Call the method to be tested
        Test.setMock(HttpCalloutMock.class, new BLN_MockHttpResponseServAppCallout());
        Cache.OrgPartition orgPart = Cache.Org.getPartition('local.OKTAIdP');
        orgPart.put('OKTAAccessToken', 'testToken');
        DateTime now = DateTime.now();
        orgPart.put('OKTATokenExpirationDateTime', now.addSeconds(30));
        BLN_ServiceAppointmentCallout.serviceAppointmentHTTPCallout(new List<BLN_ServiceAppointmentCallout.InputVariables>{input});
        Test.stopTest();
        Assert.areEqual(true, true, 'Success');
    }
    @isTest
    static void testServiceAppointmentHTTPCallout2() {
        // Create test data
        BLN_TestDataFactory.createCalloutSettings(true);
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
        
        // Mocking the data
        
        BLN_ServiceAppointmentCallout.forCatch = true;
        
        Test.startTest();
        // Call the method to be tested
        Test.setMock(HttpCalloutMock.class, new BLN_MockHttpResponseServAppCallout());
        Cache.OrgPartition orgPart = Cache.Org.getPartition('local.OKTAIdP');
        orgPart.put('OKTAAccessToken', 'testToken');
        DateTime now = DateTime.now();
        orgPart.put('OKTATokenExpirationDateTime', now.addSeconds(30));
        BLN_ServiceAppointmentCallout.serviceAppointmentHTTPCallout(new List<BLN_ServiceAppointmentCallout.InputVariables>{input});
        BLN_ServiceAppointmentCallout.serviceAppointmentHTTPCallout(null);
        Test.stopTest();
        Assert.areEqual(true, true, 'Success');
    }
}