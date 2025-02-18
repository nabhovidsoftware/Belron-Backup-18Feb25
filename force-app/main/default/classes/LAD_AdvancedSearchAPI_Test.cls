/** @description :  Test Class for LAD_AdvancedSearcgAPI.
*   @Story :        FOUK-7858; FOUK-7857; FOUK-7851; FOUK-8516; FOUK-8515; FOUK-7845; FOUK-7859; FOUK-7862
*   @author:        (binayak.debnath@pwc.com (IN))
*   @CreatedDate:   22-05-2024
*/
@isTest
public class LAD_AdvancedSearchAPI_Test {
    @testSetup static void setup() {
        Account testAccount = new Account(Name = 'ABC Corp'); // add more fields based on your org validation 
        insert testAccount;
        Contact testContact = New Contact(LastName = 'Test', AccountID = testAccount.id);
        insert testContact;
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User' LIMIT 1];
        user testUser = New User(   UserName = 'test_' + math.random() + '@test.com',
                                    FirstName = 'Test-First',
                                    LastName = 'Test-Last',
                                    Alias = 'test',
                                    email = 'test' + math.random() + '@test.com',
                                    CommunityNickName = string.valueOf(math.random()).substring(0,6),
                                    ProfileID = p.id,
                                    ContactId = testContact.Id,
                                    TimeZoneSidKey = 'America/New_York', 
                                    LocaleSidKey = 'en_US', 
                                    EmailEncodingKey = 'UTF-8', 
                                    LanguageLocaleKey = 'en_US');
        insert testUser; 

    }

    @isTest
    public static void testInsertSearchRecord(){
        User testUser = [SELECT Id FROM User WHERE FirstName = 'Test-First' LIMIT 1];
        String accountId = [SELECT Id FROM Account WHERE Name = 'ABC Corp' LIMIT 1].Id;
        Map<String, Object> paramMap = new Map<String, Object>();
        paramMap.put('userId', testUser.Id);
        paramMap.put('accountId', accountId);
        paramMap.put('recordType','LAD_Vehicle_Characteristics_Search');
        paramMap.put('isInternal', false);
        List<Map<String,Object>> paramList = new List<Map<String,Object>>{paramMap};

        Test.startTest();
        String result = LAD_AdvancedSearchAPI.insertSearchRecord(paramList);
        Test.stopTest();

        System.assertEquals('Success', result, 'Records created');
    }

    @isTest
    public static void testVRNEligibility(){
		String accountId = [SELECT Id FROM Account WHERE Name = 'ABC Corp' LIMIT 1].Id;
        Test.startTest();
        LAD_AdvancedSearchAPI.AccountWrapper returnValue = LAD_AdvancedSearchAPI.VRNSearchEligibility(accountId);
        Test.stopTest();
        System.assertEquals(false, returnValue.disableVRN, 'not false');
    }

    @isTest
    public static void testUpdateVrnUsage(){
		String accountId = [SELECT Id FROM Account WHERE Name = 'ABC Corp' LIMIT 1].Id;
        Test.startTest();
        Integer newValue = LAD_AdvancedSearchAPI.updateVrnUsage(accountId);
        Test.stopTest();
        System.assertEquals(1, newValue, 'Value not 1');
    }
    
    @isTest
    public static void testDVLA(){
        Test.setMock(HttpCalloutMock.class, new BLN_VehicleSearchApiMock());
        BLN_VehicleType__c vT = BLN_TestDataFactory.getVehicleType('VAUXHALL', 'ASTRA SRI CDTI S/S');
        insert vT;
        Test.startTest();
        List<Map<String,String>> list1 = LAD_AdvancedSearchAPI.callDVLA('BN12OEE');
        system.assertequals('VAUXHALL',list1[0].get('Make'), 'Details not fetched');
        List<Map<String,String>> list2 = LAD_AdvancedSearchAPI.callDVLA('thghghg');
        system.assertequals(true,list2[0].containsKey('Error'),'No Error found');
        Test.stopTest();
    }
    
    @isTest
    public static void testGPSschematics(){
        Test.setMock(HttpCalloutMock.class, new BLN_ConnectWithGPSMock());
        
        Test.startTest();
        String mapHover = LAD_AdvancedSearchAPI.callGPSSchematics('FORD','FIESTA','5 Door Hatchback', '2010', 'WF0JXXGAHJHR63118');
        system.assertequals(false, String.isBlank(mapHover), 'Same Size Of Map Required');
        Test.stopTest();
    }
    
    @isTest
    public static void testGPSbomId(){
        string tranId = '45009';
        string vehicleHoleId = '4500';
        Test.setMock(HttpCalloutMock.class, new BLN_ConnectWithGPSMock());
        list<string> tranList = new list<string>();
        list<List<String>>  data1;
        list<list<string>> stringBom = new List<List<string>>();
        
        tranList.add(tranId);
        tranList.add(vehicleHoleId);
        stringBom.add(tranList);
        test.starttest();
        
        data1 = LAD_AdvancedSearchAPI.callGPSbomId(stringBom);
        system.assertNotEquals(null,data1, 'Same Size Of Map Required');
        test.stoptest();
    }
    
    @istest
    public static void testGPSanswer(){
        string tranId = '45009';
        
        Test.setMock(HttpCalloutMock.class, new BLN_ConnectWithGPSMock());
        test.starttest();
        List<String> data2;
        data2 = LAD_AdvancedSearchAPI.callGPSanswer('true', tranId);
        system.assertNotEquals(null,data2, 'Same Size Of Map Required');
        test.stoptest();
        
    }
    
    @istest
    public static void testCallGPSanswerResult(){
        Test.setMock(HttpCalloutMock.class, new BLN_ConnectWithGPSMock());
        test.starttest();
        List<String> data3;
        data3 = LAD_AdvancedSearchAPI.callGPSanswer('false', 'tranId');
        system.assertEquals('RESULT', data3[0] , 'Same Size Of Map Required');
        test.stoptest();
        
    }
}