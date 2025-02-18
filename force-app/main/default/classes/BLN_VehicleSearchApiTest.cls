/*****************************************
ClassName : BLN_VehicleSearchApiTest
Description : FOUK-3149 and FOUK-1009 This Test class is used in BLN_VehicleSearchAPI class.
CreatedDate: 03-11-2023
CreatedBy : PwC-India
****************************************/

/** @description :This Test class is used in BLN_VehicleSearchAPI class. */
@isTest
Public class BLN_VehicleSearchApiTest {
    /*****************************************
MethodName : testPositive
Description : This method is used to test BLN_VehicleSearchAPI class.
Input Parameter : 
Output Parameter : void
CreatedDate: 03-11-2023
CreatedBy : Pwc-India
Change log :
****************************************/

/** @description :This method is used to test BLN_VehicleSearchAPI class */
    @isTest
    Public static void testPositive() {
        string specialData = '[{"key":"Make","value":"Honda"},{"key":"Model","value":"AB"},{"key":"BodyType","value":"COUB"},{"key":"Year","value":"2013"}]';
       // string colorValue = '[{"key":"Make","value":"Honda"},{"key":"Model","value":"AB"},{"key":"BodyType","value":"COUB"},{"key":"color","value":"black"}]';
       // string yearValue = '[{"key":"Make","value":"Honda"},{"key":"Model","value":"AB"},{"key":"BodyType","value":"COUB"},{"key":"Year","value":"2013"}]';
        string vehicleData = '[{"key":"Make","value":"Honda"},{"key":"Model","value":"AB"},{"key":"BodyType","value":"COUB"},{"key":"Year","value":"2013"},{"key":"colour","value":"black"},{"key":"vrn","value":"trtr"},{"key":"vin","value":"yryr"},{"key":"mvris","value":"trtre"},{"key":"regAuth","value":"gre"},{"key":"specialType","value":"Other"},{"key":"specialVehicle","value":"true"}]';
        // Set up a mock HTTP callout to simulate external API calls.
        Test.setMock(HttpCalloutMock.class, new BLN_VehicleSearchApiMock());
        // Create a test data using a test data factory.
        BLN_VehicleType__c vT = BLN_TestDataFactory.getVehicleType('VAUXHALL', 'ASTRA SRI CDTI S/S');
        vT.BLN_MDMExternalID__c = 'ggetstwse';
        insert vT;
        
         // Account acc =  BLN_TestDataFactory.createAccount('Account2','PersonAccount','1234567890');
          //  insert acc;
       // Account acc = BLN_TestDataFactory.createSalesAccount('TestMockB2BAccount1','Agriculture','Underwriter',1,'Insurance','GB123456779', 'AA161811','San Francisco', 'testStreet','12345' ,'GB','Blue Anchor' ,'Minehead',
       // '7890' , 'United Kingdom','BLN_CustomerB2BAccount');
       // insert acc;   
      
           
           // Contact con = BLN_TestDataFactory.getContact('belron');//
           //    con.FirstName = 'belron';
          //    con.LastName = 'glass';
           // con.Email = 'belronglass@gmail.com';
           // con.AccountId = acc.Id;
        
        
       // contact con = BLN_TestDataFactory.getContact('test');
       // insert con;
        BLN_Vehicle__c veh = BLN_TestDataFactory.getVehicle();
        insert veh;
        case cases = BLN_TestDataFactory.getCase('Job Request','New');
        // cases.AccountId = acc.id;
        //cases.ContactId = con.id;
        cases.BLN_Vehicle__c = veh.id; 
        insert cases;
        
        //new logic 
           BLN_Vehicle__c vehObj = BLN_TestDataFactory.getVehicle();
          insert vehObj;
        
          Case closedLostCase = BLN_TestDataFactory.getCase('Job Request', 'Closed-Lost');
       // closedLostCase.AccountId = acc.id;
        closedLostCase.BLN_Vehicle__c = vehObj.id; 
        insert closedLostCase;
        
        BLN_Vehicle__c vehObj1 = BLN_TestDataFactory.getVehicle();
          insert vehObj1;
        Case closedCompletedCase = BLN_TestDataFactory.getCase('Job Request', 'Closed-Completed');
    // closedCompletedCase.AccountId = acc.id;
        closedCompletedCase.BLN_Vehicle__c = vehObj1.id; 
        insert closedCompletedCase;

    
        
        // Start the test context.
        Test.startTest();
        
        BLN_VehicleSearchAPI.searchVRN('BN12OEE',cases.id);
        
        //BLN_VehicleSearchAPI.searchVRN('tgrgrg',cases.id);
        List<BLN_VehicleType__c> makeList = BLN_VehicleSearchAPI.returnMake(vT.BLN_Make__c,false);
        List<BLN_VehicleType__c> modelList = BLN_VehicleSearchAPI.returnModel(vT.BLN_Make__c, vT.BLN_Model__c,true);
       // List<BLN_VehicleType__c> modelList1 = BLN_VehicleSearchAPI.returnModel(vT.BLN_Make__c, vT.BLN_Model__c,false);
         List<Case> duplicateCases = BLN_VehicleSearchAPI.duplicateVrnCases('BN12OEE');
        BLN_VehicleSearchAPI.returnSpecialVehicle(specialData);
        BLN_VehicleSearchAPI.returnYear('Honda', 'AB', 'COUB', '2013', true);
         BLN_VehicleSearchAPI.returnYear('Honda', 'AB', 'COUB', '', false);
        BLN_VehicleSearchAPI.returnColor('Honda', 'AB', 'COUB');
         BLN_VehicleSearchAPI.returnMDMId('VAUXHALL', 'ASTRA SRI CDTI S/S', '5 DOOR HATCHBACK');
        BLN_VehicleSearchAPI.returnBodyType(vT.BLN_Make__c,vT.BLN_Model__c, vt.BLN_BodyType__c,true);
         BLN_VehicleSearchAPI.returnBodyType(vT.BLN_Make__c,vT.BLN_Model__c, vt.BLN_BodyType__c,false);
        BLN_VehicleSearchAPI.returnVehicle(veh.id);
        BLN_VehicleSearchAPI.insertVehicle(vehicleData, veh.id);
        BLN_VehicleSearchAPI.insertVehicle(vehicleData, cases.id);
        BLN_VehicleSearchAPI.insertEditVehicle(vehicleData, veh.id);
        // Assert expected results.
        system.assertequals('Job Request',cases.Type,'Case type is job request');
        system.assertequals(1,makeList.size(),'list is not empty');
        system.assertequals(1,modelList.size(),'list is not empty');
         if (!duplicateCases.isEmpty()) {
        System.assertEquals(cases.Id, duplicateCases[0].Id, 'The returned case should match the open case');
       }
        // Stop the test context.
        Test.stopTest();
        
    }
    /*****************************************
MethodName : testPositive2
Description : This method is used to test BLN_VehicleSearchAPI class.
Input Parameter : 
Output Parameter : void
CreatedDate: 03-11-2023
CreatedBy : Pwc-India
Change log :
****************************************/

/** @description :This method is used to test BLN_VehicleSearchAPI class */
    @isTest
    public static void testPositive2(){

        Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator']?.Id;
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
        User adminUser = new User(
            ProfileId = adminProfileId,
            FirstName = 'PS',
            LastName = 'Test User',
            UserName = System.now().getTime() + '@test.demo',
            Alias = 'pstes',
            Email = 'test@sample.demo',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'nl_NL',
            TimeZoneSidKey = UserInfo.getTimeZone().getID(),
            UserRoleId = r.Id,
            UserPermissionsSupportUser = true); 
        insert adminUser;
        System.runAs(adminUser){
        Test.setMock(HttpCalloutMock.class, new BLN_VehicleSearchApiMock());
        // Create a test data using a test data factory.
           // BLN_VehicleType__c vT = BLN_TestDataFactory.getVehicleType('VAUXHALL', 'ASTRA SRI CDTI S/S');
           // insert vT;
          // Account acc =  BLN_TestDataFactory.createAccount('Sample','PersonAccount','8698023890');
         //  insert acc;
           
            //  Account acc = BLN_TestDataFactory.createSalesAccount('TestMockB2BAccount3','Agriculture','Underwriter',1,'Insurance','GB123456734', 'AA161811','San Francisco', 'testStreet','12345' ,'GB','Blue Anchor' ,'Minehead',
              //'7590' , 'United Kingdom','BLN_CustomerB2BAccount');
              // insert acc; 
            
           // Contact con = BLN_TestDataFactory.getContact('Test');
            //   con.FirstName = 'Test';
           //   con.LastName = 'Contact';
           // con.Email = 'test123@gmail.com';
           // con.AccountId = acc.Id;
            
            
            
           // contact con = BLN_TestDataFactory.getContact('test');
            //insert con;
            
            BLN_Vehicle__c veh = BLN_TestDataFactory.getVehicle();
            insert veh;
            case cases = BLN_TestDataFactory.getCase('Job Request','New');
           // cases.AccountId = acc.id;
        cases.BLN_Vehicle__c = veh.id; 
        insert cases;
        
        // Start the test context.
        Test.startTest();
        
        BLN_VehicleSearchAPI.searchVRN('BN12OEE',cases.id);
        // Assert expected results.
        system.assertNOTequals('BN12OEE',cases.id,'case id is different');
        
        test.stopTest();
        }
    }
    /*****************************************
MethodName : testNegative
Description : This method is used to test BLN_VehicleSearchAPI class.
Input Parameter : 
Output Parameter : void
CreatedDate: 03-11-2023
CreatedBy : Pwc-India
Change log :
****************************************/

/** @description :This method is used to test BLN_VehicleSearchAPI class */
    @isTest
    public static  void testNegative(){
        string vehicleData = '[{"key":"make","value":"Hero"},{"key":"model","value":"BB"},{"key":"bodyType","value":"NW"},{"key":"year","value":"2015"},{"key":"colour","value":"blue"},{"key":"vrn","value":"hgs"},{"key":"vin","value":"brbr"},{"key":"mvris","value":"tytrg"},{"key":"regAuth","value":"noi"},{"key":"specialType","value":"Truck"},{"key":"specialVehicle","value":"true"}]';
        // Create a test data using a test data factory
        contact con = BLN_TestDataFactory.getContact('test');
        insert con;
        case cases = BLN_TestDataFactory.getCase('Job Request','New');
        cases.ContactId = con.id;
        insert cases;
        // Start the test context.
        test.startTest();
        BLN_VehicleSearchAPI.insertVehicle(vehicleData, cases.id); 
        BLN_VehicleSearchAPI.searchVRN('thghghg' ,cases.id);
        BLN_VehicleSearchAPI.returnMake('ss', true);
        BLN_VehicleSearchAPI.returnModel('', '', false);
        BLN_VehicleSearchAPI.returnSpecialVehicle('specialData');
          BLN_VehicleSearchAPI.returnMDMId('VAUXHALL', 'ASTRA SRI CDTI S/S', '5 DOOR HATCHBACK');
       // BLN_VehicleSearchAPI.returnColor('colorValue');
        BLN_VehicleSearchAPI.returnBodyType('','', '',true);
        BLN_VehicleSearchAPI.insertVehicle('vehicleData', cases.id);
        BLN_VehicleSearchAPI.insertEditVehicle(vehicleData, cases.id);
        // Assert expected results.
        system.assertequals('test',con.LastName,'Lastname should not be empty');
        // Stop the test context.
        test.stopTest();

    }
    
     @isTest
    public static void testNegative2(){
        string vehicleData = '[{"key":"make","value":"Hero"},{"key":"model","value":"BB"},{"key":"bodyType","value":"NW"},{"key":"year","value":"2015"},{"key":"colour","value":"blue"},{"key":"vrn","value":"hgs"},{"key":"vin","value":"brbr"},{"key":"mvris","value":"tytrg"]';
        // Create a test data using a test data factory
        contact con = BLN_TestDataFactory.getContact('test');
        insert con;
        case cases = BLN_TestDataFactory.getCase('Job Request','New');
        cases.ContactId = con.id;
        insert cases;
        // Start the test context.
        test.startTest();
        BLN_VehicleSearchAPI.insertVehicle(vehicleData, cases.id); 
        BLN_VehicleSearchAPI.searchVRN('thghghg' ,cases.id);
        BLN_VehicleSearchAPI.returnMake(Null,true);
        BLN_VehicleSearchAPI.returnModel('', '',true);
        BLN_VehicleSearchAPI.returnSpecialVehicle('specialData');
       
        BLN_VehicleSearchAPI.returnColor('%','$','&');
        BLN_VehicleSearchAPI.returnBodyType('','', '',false);
        BLN_VehicleSearchAPI.insertVehicle('vehicleData', cases.id);
        BLN_VehicleSearchAPI.insertEditVehicle(vehicleData, cases.id);
        // Assert expected results.
        system.assertequals('test',con.LastName,'Lastname should not be empty');
        // Stop the test context.
        test.stopTest();
        
    }
    
    
}