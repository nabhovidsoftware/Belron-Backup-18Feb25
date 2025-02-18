/*****************************************
ClassName : BLN_CallBranchControllerTest
Description : FOUK-7149 Test Class for BLN_CallBranchTest lwc.
CreatedDate: 16-03-2024
CreatedBy : Siddhant Pandya
****************************************/
@isTest
public class BLN_CallBranchControllerTest {
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
        
        System.runAs(u) {
            system.assertNotEquals(p, Null, 'Profile Should be available');
        }
    }
    @isTest
    static void testGetPhone() {
        
        User TechUser = [select id from user where isActive=true limit 1];
        
        // Create test data using BLN_TestDataFactory
        Account testAccount = BLN_TestDataFactory.createTestAccount();
        insert testAccount;
        ServiceResource ServiceR = BLN_TestDataFactory.createServiceResource('TechSR', true);
        ServiceR.RelatedRecordId = TechUser.id;
        ServiceR.ResourceType ='T';
        ServiceR.IsActive = true;
        update ServiceR;
        ServiceTerritory ServiceT = BLN_TestDataFactory.createServiceTerritories('stName', true);
        ServiceT.BLN_PhoneNumber__c = '0987654321';
        update ServiceT;
        
        OperatingHours operatingHours = new OperatingHours();
        operatingHours.Name = 'Operating Hours Test';
        operatingHours.TimeZone = 'Europe/London';
        insert operatingHours;  
        
        ServiceTerritoryMember serviceTerritoryMembers = new ServiceTerritoryMember();
        serviceTerritoryMembers.OperatingHoursId = operatingHours.id;
        
        serviceTerritoryMembers.ServiceResourceId = ServiceR.id;
        serviceTerritoryMembers.ServiceTerritoryId = ServiceT.id ;
        serviceTerritoryMembers.TerritoryType = 'P';
        serviceTerritoryMembers.EffectiveStartDate = system.now() -3;
        insert serviceTerritoryMembers;
        
        
        system.runAS(TechUser){
            String phone = BLN_CallBranchController.getBranchPhone((String)TechUser.Id);
            System.assertEquals(ServiceT.BLN_PhoneNumber__c == phone, true, false);
        }}
}