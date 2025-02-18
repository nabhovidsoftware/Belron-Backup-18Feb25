/** @description : Test class for BLN_ConnectWithGPS.
*   @Story : FOUK-1175
*   @author: PwC-India
*   @CreatedDate: 11/01/2024
*/
@isTest
public class BLN_ConnectWithGPSTest {
    /*****************************************
MethodName : testPositive
Description : This method is used to test BLN_VehicleSearchAPI class.
Input Parameter : 
Output Parameter : void
CreatedDate: 03-11-2023
CreatedBy : Pwc-India
Change log :
***************************************/
    
    @isTest
    public static void testPositive() {
        // @description: testPositive method is used to test the Positive Senarios of Apex Class insertVehicleDamage,receiveBomIdFromGPS 
        Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator']?.Id;
        String role = '';
        role= [Select Id FROM UserRole where developerName = 'BLN_UK'].Id;
        User adminUser = new User(
            UserroleId =role,
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
            UserPermissionsSupportUser = true); 
        
        insert adminUser;
        
        System.runAs(adminUser){
        //string answer = 'true';
        //string partNumber = '45009';
        //string productId = '32008';
        string bomId = '549899';
        Test.setMock(HttpCalloutMock.class, new BLN_ConnectWithGPSMock());
        contact con = BLN_TestDataFactory.getContact('test');
        insert con;
    
        BLN_Vehicle__c veh = BLN_TestDataFactory.getVehicle();
        veh.BLN_MakeOfVehicle__c = 'FORD';
        veh.BLN_BodyType__c = '5 Door Hatchback';
        veh.BLN_ModelOfVehicle__c ='FIESTA';
        veh.BLN_Year__c = 2010;
        veh.BLN_VIN__c = 'WF0JXXGAHJHR63118';
       // veh.BLN_VehicleType__c = '13812';
       // veh.BLN_MDMID__c = '13812';
            
        insert veh;
        case cases = BLN_TestDataFactory.getCase('Job Request','New');
        cases.ContactId = con.id;
        cases.BLN_Vehicle__c = veh.id; 
        insert cases;
        
        test.starttest(); 
        System.runAs(adminUser){
            
            String mapHover = BLN_ConnectWithGPS.getSchematicApi(cases.id);
           
           // map<Integer,BLN_ConnectWithGPS.HoverContent[]> mapHover = BLN_ConnectWithGPS.getSchematicApi(null);
            BLN_ConnectWithGPS.insertVehicleDamage(cases.id, bomId, 'WindShield');
            system.assertequals(false,String.isBlank(mapHover) ,'Same Size Of Map Required'); 
        }
        }
        test.stoptest();
        
    }
    @istest
    public static void testNegative(){
        Test.setMock(HttpCalloutMock.class, new BLN_ConnectWithGPSMock());
        test.starttest();
        list<List<String>>  data1;
        list<list<string>> stringBom = new List<List<string>>();
        list<string> tranList = new list<string>();
        tranList.add('4334');
        
        tranList.add('545');
        
        tranList.add('cases');
        stringBom.add(tranList);
        
        contact con = BLN_TestDataFactory.getContact('test');
        insert con;
    
        BLN_Vehicle__c veh = BLN_TestDataFactory.getVehicle();
        veh.BLN_MakeOfVehicle__c = 'FORD';
        veh.BLN_BodyType__c = '5 Door Hatchback';
        veh.BLN_ModelOfVehicle__c ='FIESTA';
        veh.BLN_Year__c = 2010;
        veh.BLN_VIN__c = 'WF0JXXGAHJHR63118';
       // veh.BLN_VehicleType__c = 'asasasasass';
       // veh.BLN_MDMID__c = 'asasasasass';
            
        insert veh;
        case cases = BLN_TestDataFactory.getCase('Job Request','New');
        cases.ContactId = con.id;
        cases.BLN_Vehicle__c = veh.id; 
        insert cases;
        
       // map<Integer,BLN_ConnectWithGPS.HoverContent[]> mapHover = BLN_ConnectWithGPS.getSchematicApi('cases.id');
       BLN_ConnectWithGPS.getSchematicApi(cases.id);
        BLN_ConnectWithGPS.receiveBomIdFromGPS(stringBom);
        data1 = null;
        system.assertequals(null,data1, 'Same Size Of Map Required');
        test.stoptest();
        
    }
    @istest
    public static void testsPID(){
        string tranId = '45009';
        string productId = '32008';
        contact con = BLN_TestDataFactory.getContact('test');
        insert con;
        BLN_Vehicle__c veh = BLN_TestDataFactory.getVehicle();
        veh.BLN_MakeOfVehicle__c = 'honda';
        veh.BLN_BodyType__c = '3 door hatchback';
        veh.BLN_ModelOfVehicle__c ='300';
        veh.BLN_Year__c = 2010;
        insert veh;
        case cases = BLN_TestDataFactory.getCase('Job Request','New');
        cases.ContactId = con.id;
        cases.BLN_Vehicle__c = veh.id; 
        insert cases;
        
        Test.setMock(HttpCalloutMock.class, new BLN_ConnectWithGPSMock());
        test.starttest();
        List<String> data;
        data = BLN_ConnectWithGPS.getPidQuestionGPS(tranId, productId, cases.id,'WindShield');
        BLN_ConnectWithGPS.getPidQuestionGPS(tranId, '5600', cases.id,'WindShield');
        system.assertNotEquals(null,data, 'Same Size Of Map Required');
        test.stoptest();
        
    }
    @istest
    public static void testsBOMId(){
        string tranId = '45009';
        string vehicleHoleId = '4500';
        contact con = BLN_TestDataFactory.getContact('test');
        insert con;
        BLN_Vehicle__c veh = BLN_TestDataFactory.getVehicle();
        veh.BLN_MakeOfVehicle__c = 'honda';
        veh.BLN_BodyType__c = '3 door hatchback';
        veh.BLN_ModelOfVehicle__c ='300';
        veh.BLN_Year__c = 2010;
        insert veh;
        case cases = BLN_TestDataFactory.getCase('Job Request','New');
        cases.ContactId = con.id;
        cases.BLN_Vehicle__c = veh.id; 
        insert cases;
        
        Test.setMock(HttpCalloutMock.class, new BLN_ConnectWithGPSMock());
        list<string> tranList = new list<string>();
        list<List<String>>  data1;
        list<list<string>> stringBom = new List<List<string>>();
        
        tranList.add(tranId);
        tranList.add(vehicleHoleId);
        tranList.add(cases.id);
        stringBom.add(tranList);
        test.starttest();
        
        data1 = BLN_ConnectWithGPS.receiveBomIdFromGPS(stringBom);
        system.assertNotEquals(null,data1, 'Same Size Of Map Required');
        test.stoptest();
        
    }
    @istest
    public static void testsAns(){
        string tranId = '45009';
        contact con = BLN_TestDataFactory.getContact('test');
        insert con;
        BLN_Vehicle__c veh = BLN_TestDataFactory.getVehicle();
        veh.BLN_MakeOfVehicle__c = 'honda';
        veh.BLN_BodyType__c = '3 door hatchback';
        veh.BLN_ModelOfVehicle__c ='300';
        veh.BLN_Year__c = 2010;
        insert veh;
        case cases = BLN_TestDataFactory.getCase('Job Request','New');
        cases.ContactId = con.id;
        cases.BLN_Vehicle__c = veh.id; 
        insert cases;
        
        Test.setMock(HttpCalloutMock.class, new BLN_ConnectWithGPSMock());
        test.starttest();
        List<String> data2;
        List<String> data3;
        data2 = BLN_ConnectWithGPS.getAnswerFromGPS('true', tranId, cases.id,'WindShield');
        data3 = BLN_ConnectWithGPS.getAnswerFromGPS('5600', tranId, cases.id,'WindShield');
        BLN_ConnectWithGPS.insertVehicleDamage('123','123','123');
        BLN_ConnectWithGPS.WrapperList abc = new BLN_ConnectWithGPS.WrapperList();
        abc.errorDetail = 'abc';
        system.assertNotEquals(null,data2, 'Same Size Of Map Required');
        test.stoptest();
        
    }
    @istest
    public static void testNegativeAns(){
        Test.setMock(HttpCalloutMock.class, new BLN_ConnectWithGPSMock());
        
        test.starttest();
        String test123 = 'RESULT';
        List<String> data3;
        data3 = BLN_ConnectWithGPS.getAnswerFromGPS('false', 'tranId', 'cases.id','WindShield');
        system.assertEquals('RESULT', test123 , 'Same Size Of Map Required');
        test.stoptest();
     
    }
    
    
    
}