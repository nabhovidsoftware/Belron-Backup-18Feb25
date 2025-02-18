/** @description : Test class for BLN_SelectServiceTypeController apex class
*   @Story : FOUK-8373
*   @author: Siddhant Pandya (PwC)
*   @CreatedDate: 21/05/2024
*/
@isTest
public class BLN_SelectServiceTypeControllerTest {
/**
*@description : This method is used for testing BLN_SelectServiceTypeController.checkVehicleValues method
*@return void
*/
@isTest
    static void testCheckVehicleValues(){
        BLN_Vehicle__c vehicle1 = BLN_TestDataFactory.getVehicle();
        vehicle1.BLN_MakeOfVehicle__c = 'BMW';
        vehicle1.BLN_ModelOfVehicle__c = 'X2';
        vehicle1.BLN_Year__c = 2020;
        vehicle1.BLN_BodyType__c = 'Carbon';
        insert vehicle1;

        BLN_Vehicle__c vehicle2 = BLN_TestDataFactory.getVehicle();
        insert vehicle2;

        Test.startTest();
        Boolean value1 = BLN_SelectServiceTypeController.checkVehicleValues(vehicle1.Id);
        Boolean value2 = BLN_SelectServiceTypeController.checkVehicleValues(vehicle2.Id);
        Test.stopTest();
        
        System.assertEquals(true,value1 && !value2, 'Value1 should be true, Value2 should be false');
    }
}