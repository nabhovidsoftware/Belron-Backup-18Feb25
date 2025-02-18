/*ClassName : BLN_IntegrationLoggerHandlerTest
Description : Test class for BLN_IntegrationLoggerHandler
@Story : FOUK-5189
CreatedDate: 27/02/2023
CreatedBy : PwC-India
****************************************/
@isTest
public class BLN_IntegrationLoggerHandlerTest {
    @isTest
    public static void testLogCalloutDetails() {
        Test.startTest();
        Assert.isTrue(BLN_IntegrationLoggerHandler.logCalloutDetails(new Account().Id,System.label.BLN_True,System.now(),System.now(),new HttpRequest(),new HttpResponse()).isSuccess(),System.label.BLN_True);
        Test.stopTest();
    }
    
    @IsTest
    public static void testLogCalloutDetailsRest() {
        Test.startTest();
        Assert.isTrue(BLN_IntegrationLoggerHandler.logCalloutDetailsRest(new Account().Id, System.Label.BLN_True, System.now(), System.now(), new RestRequest(), new RestResponse(), 'POST').isSuccess(), System.Label.BLN_True);
        Test.stopTest();
    }
}