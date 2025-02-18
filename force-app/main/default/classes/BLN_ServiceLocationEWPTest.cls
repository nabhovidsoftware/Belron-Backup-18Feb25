/**@description : This is the Apex Test class for the Apex Classes BLN_ServiceLocationEWPDataController.
*  @author: PwC India
*  @CreatedDate: 12/06/2024
*/
@isTest
private class BLN_ServiceLocationEWPTest {


    /**
* @description Sets up test data for the test methods
*/
    @TestSetup
    static void setupTestData() {
         WorkType repairWT = BLN_TestDataFactory.createWorkType(System.Label.BLN_RepairWT, 4 , true ,  true);
        WorkType replacementWT = BLN_TestDataFactory.createWorkType(System.Label.BLN_ReplacementWT, 4 , true ,  true);
        OperatingHours operatingHours = BLN_TestDataFactory.createOperatingHours('All Day Slot', true);
        
          ServiceTerritory st = BLN_TestDataFactory.createServiceTerritory('Bedford' , operatingHours.Id , true);
             st.BLN_GUID__c = 'Test_GUID';
            st.BLN_CostCenter__c = 'Test_CostCenter';
            st.BLN_Type__c = 'Branch';
           // st.BLN_Type__c = 'Mobile';
            st.IsActive = true;
            st.BLN_ConsiderforR1__c = false;
            st.BLN_Specials__c = true;
            st.Latitude = 52.125290000000000;
            st.Longitude = -0.422290000000000;
        
        
          update st;
        //System.debug('Inserted Service Territory: ' + st);
        String coordinates = '-89.02172505348693,47.81952924639332,0 -84.18774067848693,48.01097620848099,0 -84.89086567848693,46.22441984873406,0 -88.34057270973693,45.91190522847453,0 -88.90087544411193,47.53103006689299,0 -89.30736958473693,47.77524856801052,0 -89.02172505348693,47.81952924639332,0';
        FSL__Polygon__c myPolygon = new FSL__Polygon__c(

                Name = 'Central SSS1'

                ,FSL__Color__c = '#5679C0'

                ,FSL__KML__c =  '<?xml version="1.0" encoding="UTF-8"?> '+

                '<kml xmlns="http://www.opengis.net/kml/2.2">'+

                '<Style id="CentralSSSStyle">'+

                '<LineStyle>'+

                '<width>1</width>'+

                '</LineStyle>'+

                '<PolyStyle>'+

                '<color>80C07956</color>'+

                '</PolyStyle>'+

                '</Style>'+

                '<Placemark>'+

                '<name>CentralSSS</name>'+

                '<styleUrl>#CentralSSSStyle</styleUrl>'+

                '<Polygon>'+

                '<outerBoundaryIs>'+

                '<LinearRing>\n'+

                '<coordinates>-89.02172505348693,47.81952924639332,0\n'+

                '-84.18774067848693,48.01097620848099,0\n'+

                '-84.89086567848693,46.22441984873406,0\n'+

                '-88.34057270973693,45.91190522847453,0\n'+

                '-88.90087544411193,47.53103006689299,0\n'+

                '-89.30736958473693,47.77524856801052,0\n'+

                '-89.02172505348693,47.81952924639332,0\n'+

                '</coordinates>\n'+

                '</LinearRing>'+

                '</outerBoundaryIs>'+

                '</Polygon>'+

                '</Placemark>'+

                '</kml>'

                ,FSL__Ma_La__c = 48.01097620848099
                ,FSL__Ma_Lo__c = -84.18774067848693
                ,FSL__Mi_La__c = 45.91190522847453
                ,FSL__Mi_Lo__c = -89.3073695847369
                ,FSL__Service_Territory__c = st.id
        );
        
 
         BLN_Vehicle__c vehicles = BLN_TestDataFactory.getVehicle();
        vehicles.BLN_SpecialVehicle__c = true;
        Account testAcc = BLN_TestDataFactory.createTestAccount();
        testAcc.FirstName = 'Test';
        testAcc.LastName = 'Cont act';
        testAcc.PersonEmail = 'test123@gmail.com';
        insert testAcc;
        
        Contact testContact = BLN_TestDataFactory.getContact('Test');
        testContact.FirstName = 'Test';
        testContact.LastName = 'Contact';
        testContact.Email = 'test123@gmail.com';
        insert testContact;
        
        
        Case cse = BLN_TestDataFactory.getCase('Job Request', 'New');
        cse.Type = 'Job Request';
        cse.Status = 'New';
        cse.ContactId = testContact.Id;
        cse.BLN_ServiceGeolocation__latitude__s=46.22441984873406;
        cse.BLN_ServiceGeolocation__longitude__s=-89.02172505348693;
        cse.AccountId = testAcc.Id ;
        cse.Priority = 'Medium';
        cse.BLN_MotoristTaxStatus__c = 'Yes';
        cse.BLN_TotalMotoristLiability__c = 6000 ;
        cse.BLN_Vehicle__c = vehicles.id;
        insert cse;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        // Assert
        System.assertNotEquals(repairWT, null, 'The WorkType object should not be null.');
        System.assertNotEquals(replacementWT, null, 'The WorkType object should not be null.');
        System.assertNotEquals(coordinates, '', 'The coordinates string should not be empty.');
        System.assertEquals('Central SSS1', myPolygon.Name, 'The Name should be Central SSS1.');
    }

    /*
    *@description: This method is used to test GetNearestServiceLocations method.
    *return : void
    */
    @isTest
    static void testGetNearestServiceLocations() {
        // Set up mock REST request
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/nearest-locations';
        request.httpMethod = 'GET';
        request.addParameter('latitude', '40.7128');
        request.addParameter('longitude', '-74.0060');
        request.addParameter('specialVehicle', 'false');

        RestContext.request = request;
        RestResponse response = new RestResponse();
        RestContext.response = response;
        // Call the method to test
        Test.startTest();
        BLN_ServiceLocationEWPDataController.getNearestServiceLocationsByCoords(); 
        Test.stopTest();
        
        System.assertEquals('/services/apexrest/nearest-locations', request.requestURI,'request');
    }
    
    /*
    *@description: This method is used to test GetNearestServiceLocationsWithSpecial method.
    *return : void
    
    @isTest
    static void testGetNearestServiceLocationsWithSpecial() {
        // Mock REST request with parameters
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/nearest-locations';
        request.httpMethod = 'GET';
        request.addParameter('latitude', '37.7749'); // San Francisco Latitude
        request.addParameter('longitude', '-122.4194'); // San Francisco Longitude
        request.addParameter('specialVehicle', 'true');
        RestContext.request = request;
        RestResponse response = new RestResponse();
        RestContext.response = response;
        ServiceTerritory services = BLN_TestDataFactory.createServiceTerritories('Test Certainty', true);
        services.BLN_Type__c=  'Mobile'; 
        services.BLN_GUID__c='abcd';
        update services;

        // Call the method under test
        Test.startTest();
        BLN_ServiceLocationEWPDataController.getNearestServiceLocationsByCoords();
        
        Test.stopTest();

        // Assertion
        System.assertEquals('abcd', services.BLN_GUID__c, 'GUID is abcd');
        
    }*/

    /*
    *@description: This method is used to test GetNearestServiceLocationsNegative method.
    *return : void
    */
    @isTest
    static void testGetNearestServiceLocationsNegative() {
    test.starttest();
        // Mock REST request with parameters
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/nearest-locations';
        request.httpMethod = 'GET';
        request.addParameter('latitude', ''); // San Francisco Latitude
        request.addParameter('longitude', ''); // San Francisco Longitude
        request.addParameter('specialVehicle', '');
        RestContext.request = request;
        RestResponse response = new RestResponse();
        RestContext.response = response;
      BLN_ServiceLocationEWPDataController.getNearestServiceLocationsByCoords(); 
        test.stoptest();
        // Assertion
        System.assertEquals('GET', request.httpMethod, 'Expected GET');
    }
}