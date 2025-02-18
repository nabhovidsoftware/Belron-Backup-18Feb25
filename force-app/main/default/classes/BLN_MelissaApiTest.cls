/**
* @ClassName : BLN_MelissaApiTest
* @description : FOUK-684 This Test class is used in Melissa API Class.
* @CreatedDate: 26-10-2023
* @CreatedBy : PwC-India
*/
@isTest
public class BLN_MelissaApiTest {

     /**
* @description : Sets up common test data for the test methods.
*/
    @testSetup
    static void setupTestData() {
        User testUser = BLN_TestDataFactory.createAdminUser('Test');
        insert testUser;
    }
    
/* @description : This method is used to test Melissa API class in Postive*/
   @isTest
    public static void testPositive() {

        // Retrieve the test user created by @testSetup
        User testUser = [SELECT Id FROM User WHERE LastName = 'Test' LIMIT 1];

        // Create a JSON address string for testing
        string address1 = '[{"key":"homeTown","value":"Sadar"},{"key":"homeStreet","value":"Erfan Villa, Sector 19, Indira Nagar"},{"key":"homeCounty","value":"Uttar Pradesh"},{"key":"homeCountry","value":"India"},{"key":"homePostCode","value":"226016"},{"key":"homeLongitude","value":""},{"key":"homeLatitude","value":""},{"key":"changedOtherPostCode","value":"false"},{"key":"changedHomePostCode","value":"true"}]';
        string address2 = '[{"key":"homeTown","value":"Sadar"},{"key":"homeStreet","value":"Erfan Villa, Sector 19, Indira Nagar"},{"key":"homeCounty","value":"Uttar Pradesh"},{"key":"homeCountry","value":"India"},{"key":"homePostCode","value":"226016"},{"key":"homeLongitude","value":""},{"key":"homeLatitude","value":""},{"key":"changedOtherPostCode","value":"true"},{"key":"changedHomePostCode","value":"false"}]';
        string address3 = '[{"key":"homeTown","value":"Sadar"},{"key":"homeStreet","value":"Erfan Villa, Sector 19, Indira Nagar"},{"key":"homeCounty","value":"Uttar Pradesh"},{"key":"homeCountry","value":"India"},{"key":"homePostCode","value":"226016"},{"key":"homeLongitude","value":"23.30"},{"key":"homeLatitude","value":"45.30"},{"key":"changedOtherPostCode","value":"true"},{"key":"changedHomePostCode","value":"false"}]';

        // Create a test Account using a test data factory
        Account accounts = BLN_TestDataFactory.createAccount('Test', 'PersonAccount', '5757557');
         insert accounts;
        // Start the test context
        test.startTest(); 
        System.runAs(testUser){
        // Set up a mock HTTP callout to simulate external API calls
        Test.setMock(HttpCalloutMock.class, new BLN_MelissaApiMock()); 
        // Call the BLN_MelissaApiAddressService class to test it
        list<object> objList = BLN_MelissaApiAddressService.searchAddress('test');
     
        Case cse = BLN_TestDataFactory.createCase(true);
        // Call the BLN_MelissaApiAddressService to update the address
        BLN_MelissaApiAddressService.updateAddress(address1, accounts.Id, cse.Id, true,'Cash');
        BLN_MelissaApiAddressService.updateAddress(address2, accounts.Id, cse.Id, true,'Cash');
        BLN_MelissaApiAddressService.updateAddress(address3, accounts.Id, cse.Id, true,'Cash');

        // Assert expected results
        System.assertNotEquals(5, objList.size(), 'Actual and Required Size Same');
        System.assertEquals('Test', accounts.FirstName, 'Actual and Required Size Same');
        // Stop the test context
        }
        test.stopTest();
    }

/*@description : This method is used to test Melissa API class in Negative*/
   @isTest
    public static void testNegative() {
          // Retrieve the test user created by @testSetup
        User testUser = [SELECT Id FROM User WHERE LastName = 'Test' LIMIT 1];
          // Create a test Account using a test data factory
        Account accounts = BLN_TestDataFactory.createAccount('Test1', 'PersonAccount', '5753457');
        insert accounts;
        // Start the test context
        test.startTest(); 
        System.runAs(testUser){
        string address1 = '[{"key":"otherTown","value":"Sadar"},{"key":"otherStreet","value":"Erfan Villa, Sector 19, Indira Nagar"},{"key":"otherCounty","value":"Uttar Pradesh"},{"key":"otherCountry","value":"India"},{"key":"otherPostCode","value":"226016"},{"key":"otherLongitude","value":""},{"key":"otherLatitude","value":""},{"key":"changedOtherPostCode","value":"true"},{"key":"changedHomePostCode","value":"false"}]';
        string address2 = '[{"key":"otherTown","value":"Sadar"},{"key":"otherStreet","value":"Erfan Villa, Sector 19, Indira Nagar"},{"key":"otherCounty","value":"Uttar Pradesh"},{"key":"otherCountry","value":"India"},{"key":"otherPostCode","value":"226016"},{"key":"otherLongitude","value":""},{"key":"otherLatitude","value":""},{"key":"changedOtherPostCode","value":"false"},{"key":"changedHomePostCode","value":"true"}]';
        string address3 = '[{"key":"otherTown","value":"Sadar"},{"key":"otherStreet","value":"Erfan Villa, Sector 19, Indira Nagar"},{"key":"otherCounty","value":"Uttar Pradesh"},{"key":"otherCountry","value":"India"},{"key":"otherPostCode","value":"226016"},{"key":"otherLongitude","value":"24.50"},{"key":"otherLatitude","value":"35.50"},{"key":"changedOtherPostCode","value":"false"},{"key":"changedHomePostCode","value":"true"}]';
		
		
		
		
      
        // Call the BLN_MelissaApiAddressService to update the address
        BLN_MelissaApiAddressService.updateAddress(address1, accounts.Id, null, false, 'Insurance');
        BLN_MelissaApiAddressService.updateAddress(address2, accounts.Id, null, false, 'Insurance');
        BLN_MelissaApiAddressService.updateAddress(address3, accounts.Id, null, false, 'Insurance');
            BLN_MelissaApiAddressService.updateAddress(address3, accounts.Id, null, true, 'Insurance');
        // Call the BLN_MelissaApiAddressService with a different input to test negative case
        list<object> objList2 = BLN_MelissaApiAddressService.searchAddress('Test me');
        
        // Assert that no results are returned for the negative test case
        System.assertEquals(0, objList2.size(), 'Output Should Match With Required Output');   
        // Stop the test context
        }
        test.stopTest();
    }

/*@description : This method is used to test Melissa API class in Negative*/
    @isTest
    public static void testNegative2(){
        test.starttest();
        string address1 = '[{"key":"otherTown","value":"Sadar"},{"key":"otherStreet","value":"Erfan Villa, Sector 19, Indira Nagar"},{"key":"otherCounty","value":"Uttar Pradesh"},{"key":"otherCountry","value":"India"},{"key":"otherPostCode","value":"226016"},{"key":"otherLongitude","value":""},{"key":"otherLatitude","value":""},{"key":"changedOtherPostCode","value":"true"},{"key":"changedHomePostCode","value":"false"}]';

        BLN_MelissaApiAddressService.updateAddress(address1, 'accounts.Id');
         list<object> objList2 = BLN_MelissaApiAddressService.searchAddress('test me');
        
        // Assert that no results are returned for the negative test case
        System.assertEquals(0, objList2.size(), 'Output Should Match With Required Output');   
        test.stoptest();

    }
}