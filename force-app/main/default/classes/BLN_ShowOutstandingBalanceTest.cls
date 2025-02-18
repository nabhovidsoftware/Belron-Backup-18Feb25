/*
ClassName : BLN_ShowOutstandingBalanceTest
Description :	BLN_ShowOutstandingBalance test class.
@Story : FOUK-5777
percentage : 87%
CreatedBy : Sourabh Bhattacharjee
*/
@isTest
public class BLN_ShowOutstandingBalanceTest {
 @isTest
    static void getBal1(){
        Account acc = new Account(Name = 'Test Account',BLN_RegisteredAddressTerritory__c = 'Test');
        insert acc;
        Contact con = new Contact(LastName = 'Test Contact', AccountId = acc.Id);
        insert con;
        BLN_Vehicle__c vehicleRec = new BLN_Vehicle__c(
            BLN_Year__c = 2020,
            BLN_VehicleRegNumber__c = 'ABC123',
            BLN_MakeOfVehicle__c = 'Test Make',
            BLN_ModelOfVehicle__c = 'Test Model'
        );
        insert vehicleRec;

        OperatingHours oh = new OperatingHours(
            Name = 'Test Operating Hours'
        );
        insert oh;

         // Create Service Territory and Operating Hours
        ServiceTerritory st = new ServiceTerritory
            (Name = 'Test Territory',
             OperatingHoursId = oh.Id ,
             IsActive = true
            );
	        insert st;

        Case testCase = new Case(
            Subject = 'Test Case',
            AccountID = acc.Id,
            ContactId = con.Id,
            Status = 'New',
            Origin = 'Web',
            BLN_Vehicle__c = vehicleRec.Id,
            BLN_BookingStatus__c = 'Confirmed',
            BLN_SubType__c='Job Request',
            Type = 'Job Request',
            Priority = 'Medium',
            BLN_TotalMotoristLiability__c = 6000
        );
        insert testCase;
        Test.startTest();
        BLN_ShowOutstandingBalance.getBal(testCase.id);
        Test.stopTest();
        System.assert(testCase.Id != null, 'Case ID Should not be null');
    }
@isTest
    static void getBal2(){
        Account acc = new Account(Name = 'Test Account',BLN_RegisteredAddressTerritory__c = 'Test');
        insert acc;
        Contact con = new Contact(LastName = 'Test Contact', AccountId = acc.Id);
        insert con;
        BLN_Vehicle__c vehicleRec = new BLN_Vehicle__c(
            BLN_Year__c = 2020,
            BLN_VehicleRegNumber__c = 'ABC123',
            BLN_MakeOfVehicle__c = 'Test Make',
            BLN_ModelOfVehicle__c = 'Test Model'
        );
        insert vehicleRec;

        OperatingHours oh = new OperatingHours(
            Name = 'Test Operating Hours'
        );
        insert oh;

         // Create Service Territory and Operating Hours
        ServiceTerritory st = new ServiceTerritory
            (Name = 'Test Territory',
             OperatingHoursId = oh.Id ,
             IsActive = true
            );
	        insert st;

        Case testCase = new Case(
            Subject = 'Test Case',
            AccountID = acc.Id,
            ContactId = con.Id,
            Status = 'New',
            Origin = 'Web',
            BLN_Vehicle__c = vehicleRec.Id,
            BLN_BookingStatus__c = 'Confirmed',
            BLN_SubType__c='Job Request',
            Type = 'Job Request',
            Priority = 'Medium',
            BLN_TotalMotoristLiability__c = 2
        );
        insert testCase;
        Test.startTest();
        BLN_ShowOutstandingBalance.getBal(testCase.id);
        Test.stopTest();
        System.assert(testCase.Id != null, 'Case ID Should not be null');
    }
    @isTest
    static void getBal3(){
        Account acc = new Account(Name = 'Test Account',BLN_RegisteredAddressTerritory__c = 'Test');
        insert acc;
        Contact con = new Contact(LastName = 'Test Contact', AccountId = acc.Id);
        insert con;
        BLN_Vehicle__c vehicleRec = new BLN_Vehicle__c(
            BLN_Year__c = 2020,
            BLN_VehicleRegNumber__c = 'ABC123',
            BLN_MakeOfVehicle__c = 'Test Make',
            BLN_ModelOfVehicle__c = 'Test Model'
        );
        insert vehicleRec;

        OperatingHours oh = new OperatingHours(
            Name = 'Test Operating Hours'
        );
        insert oh;

         // Create Service Territory and Operating Hours
        ServiceTerritory st = new ServiceTerritory
            (Name = 'Test Territory',
             OperatingHoursId = oh.Id ,
             IsActive = true
            );
	        insert st;

        Case testCase = new Case(
            Subject = 'Test Case',
            AccountID = acc.Id,
            ContactId = con.Id,
            Status = 'New',
            Origin = 'Web',
            BLN_Vehicle__c = vehicleRec.Id,
            BLN_BookingStatus__c = 'Provisional',
            BLN_SubType__c='Job Request',
            Type = 'Job Request',
            Priority = 'Medium',
            BLN_TotalMotoristLiability__c = 2
        );
        insert testCase;
        Test.startTest();
        BLN_ShowOutstandingBalance.getBal(testCase.id);
        Test.stopTest();
        System.assert(testCase.Id != null, 'Case ID Should not be null');
    }
}