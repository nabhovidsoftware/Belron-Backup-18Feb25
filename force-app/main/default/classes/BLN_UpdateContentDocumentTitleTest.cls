/*****************************************
ClassName : BLN_UpdateContentDocumentTitleTest
Description : FOUK-1537 Test Class for BLN_UpdateContentDocumentTitleHandler
CreatedDate: 19-03-2024
CreatedBy : Siddhant Pandya
****************************************/
@isTest
public class BLN_UpdateContentDocumentTitleTest {
    @TestSetup
    static void createUserTest() {
        UserRole ur = new UserRole(Name = 'Technicians');
        insert ur;
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';	
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',IsActive = true,
                          UserName=uniqueUserName, UserRoleId = ur.Id);
        // Assert that the User was created with the expected values
        System.assertEquals('standt', u.Alias);
    }
    @isTest
    static void testGetPhone() {
        
        User techUser = [select Id from user where isActive=true limit 1];
        
        // Create test data using BLN_TestDataFactory
        //Id userid = techUser.Id;
        WorkType workType = BLN_TestDataFactory.createWorkType('Replacement', 1.0, true, true);
        WorkOrder workOrder = BLN_TestDataFactory.createWorkOrder(false);
        workOrder.status = 'completed';
        insert workOrder;
        
        WorkOrderLineItem wOLI = new WorkOrderLineItem();
        wOLI.WorkTypeId = worktype.Id;
        wOLI.WorkOrderId = workOrder.id;
        wOLI.status = 'Completed';
        wOLI.BLN_IsStockCheckInCompleted__c = false;
        insert wOLI;  
        
        ServiceAppointment serviceAppointments = new ServiceAppointment();
        serviceAppointments.ParentRecordId = wOLI.id;
        
        serviceAppointments.Status = 'Failed After Arrive';
        serviceAppointments.SchedStartTime = system.now();
        serviceAppointments.SchedEndTime = system.now()+5;
        serviceAppointments.BLN_WorkOrderNumber__c = workOrder.id;
        serviceAppointments.BLN_RemedyJobId__c = '3333333';
        serviceAppointments.BLN_RemedyTaskId__c = '5454545';
        serviceAppointments.WorkTypeId = workType.id;
        insert serviceAppointments;
        
        ContentVersion version = new ContentVersion(
            Title='File Name',
            PathOnClient='sample.jpg',
            VersionData=EncodingUtil.base64Decode('AA=='),
            Origin='H',
            FirstPublishLocationId = serviceAppointments.id
        );
        
        system.runAS(techUser){
            insert version;
        }
        
        // Assert that the ContentVersion was created successfully
        ContentVersion insertedVersion = [SELECT Id, Title, FirstPublishLocationId FROM ContentVersion WHERE Id = :version.Id];
        System.assertNotEquals('File Name', insertedVersion.Title, 'ContentVersion title should match');
        System.assertEquals(serviceAppointments.Id, insertedVersion.FirstPublishLocationId, 'ContentVersion should be associated with the correct ServiceAppointment');
    }
}