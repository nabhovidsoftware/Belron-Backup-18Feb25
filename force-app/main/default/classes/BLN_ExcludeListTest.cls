/*
* @description : This is Test Class to cover BLN_ExcludeList class
* @author:Pruthvisinh Pujara (PWC IN)
* @CreatedDate: 03.01.2024
* @Story: FOUK-3954
* @Last ModifiedBy: Subhamita Dutta
*/
@isTest
private class BLN_ExcludeListTest {
	@TestSetup 
    static void setup() {
      
        OperatingHours opertatingHr = BLN_TestDataFactory.createOperatingHour('Test op',true); 
        ServiceTerritory serviceTerritory = BLN_TestDataFactory.createServiceTerritory('Test Territory',opertatingHr.Id,'United Kingdom',false);
        serviceTerritory.BLN_AnyDurationAssist__c = true;
        insert serviceTerritory;

        Product2 prod = BLN_TestDataFactory.createTestProduct();
        prod.BLN_BelronFittingTime__c = 15;
        prod.BLN_ProductCategory__c = '11';
        INSERT prod;
    }
/*  *@description: This method is used to check the user profile
        *@return : void
    */

    @isTest
    static void createUserTest() {
        UserRole ur = new UserRole(Name = 'Technicians');
        insert ur;
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];

        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName, UserRoleId = ur.Id);
        
        System.runAs(u) {
            system.assertNotEquals(p, Null, 'Profile Should be available');
        }
    }
    @isTest
    static void createUserTest2() {
        UserRole ur = new UserRole(Name = 'Technicians');
        insert ur; 

        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';	
        List<Profile> pList = [SELECT Id FROM Profile WHERE Name='Standard User'];
        Profile p;
        if(pList!=null && !pList.isEmpty())
        {
            p=pList.get(0);
        }

        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName=uniqueUserName, UserRoleId = ur.Id);

        System.runAs(u) {
            system.assertNotEquals(p, Null, 'Profile Should be available');
        }
    
    }

    
    @isTest
    static void excludeListTest() {
        OperatingHours opertatingHr = BLN_TestDataFactory.createOperatingHour('Test op',true); 
        ServiceTerritory serviceTerritory = BLN_TestDataFactory.createServiceTerritory('Test Territory1',opertatingHr.Id,'United Kingdom',false);
        serviceTerritory.BLN_AnyDurationAssist__c = true;
        insert serviceTerritory;

        Product2 prod = BLN_TestDataFactory.createTestProduct();
        prod.BLN_BelronFittingTime__c = 15;
        prod.BLN_ProductCategory__c = '11';
        INSERT prod;

        WorkType replacementWT = BLN_TestDataFactory.createWorkType('Replacement', 4 , true ,  true);

        test.startTest();
        BLN_ExcludeList.excludeList();
        BLN_ExcludeList.saveExcludeList(serviceTerritory.Id, new List<String>{'Repair'}, new List<String>{''}, new List<String>{''});
        test.stopTest();
        System.assertEquals('Replacement', replacementWT.Name,'WorkType Name is correct');
    }

/*  *@description: This method is used to test excludeList and saveExcludeList method for BLN_ExcludeList class.
        *@return : void
    */
    @IsTest
    static void excludeListTest2() {
        List<ServiceTerritory> serviceTerritoryList=[SELECT Id from ServiceTerritory where Name = 'Test Territory' AND Country='United Kingdom'];
        ServiceTerritory serviceTerInstance;

        if (serviceTerritoryList!=null && !serviceTerritoryList.isEmpty()) {
            serviceTerInstance=serviceTerritoryList.get(0);
        }

        WorkType replacementWT = BLN_TestDataFactory.createWorkType('Replacement', 4 , true ,  true);

        test.startTest();
        BLN_ExcludeList.excludeList();
        BLN_ExcludeList.saveExcludeList(serviceTerInstance.Id, new List<String>{'Repair'}, new List<String>{''}, new List<String>{''});
        test.stopTest();
        System.assertEquals('Replacement', replacementWT.Name,'WorkType Name is correct');
    }

    @isTest
    static void excludeListForProductTest() {
        OperatingHours opertatingHr = BLN_TestDataFactory.createOperatingHour('Test op',true); 
        ServiceTerritory serviceTerritory = BLN_TestDataFactory.createServiceTerritory('Test Territory1',opertatingHr.Id,'United Kingdom',false);
        serviceTerritory.BLN_AnyDurationAssist__c = true;
        insert serviceTerritory;

        Product2 prod = BLN_TestDataFactory.createTestProduct();
        prod.BLN_BelronFittingTime__c = 15;
        prod.BLN_ProductCategory__c = '11';
        INSERT prod;

        WorkType replacementWT = BLN_TestDataFactory.createWorkType('Replacement', 4 , true ,  true);

        test.startTest();
        BLN_ExcludeList.excludeList();
        List<String> testList=new List<String>();
        testList.add('Test');
        BLN_ExcludeList.excludeListForProduct('%Test%',testList  , true);
        BLN_ExcludeList.excludeListForProduct('%Test%',testList  , false);
        BLN_ExcludeList.saveExcludeList(serviceTerritory.Id, new List<String>{'Repair'}, new List<String>{''}, new List<String>{''});
        test.stopTest();
        System.assertEquals('Replacement', replacementWT.Name,'WorkType Name is correct');
    }
}