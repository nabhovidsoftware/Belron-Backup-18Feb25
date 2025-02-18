/** @description : This class is used as controller of BLN_SelectServiceType LWC
*   @Story : FOUK-8373
*   @author: Siddhant Pandya (PwC)
*   @CreatedDate: 21/05/2024
*/
public with sharing class BLN_SelectServiceTypeController {
/**
*@description : This method is called from 'BLN_SelectServiceType' LWC, for checking vehicle values if filled or not.
*@return void
*/
    @AuraEnabled
    public static boolean checkVehicleValues(Id vehicleId) {
        String query = 'Select id, BLN_MakeOfVehicle__c, BLN_ModelOfVehicle__c, BLN_Year__c, BLN_BodyType__c from BLN_Vehicle__c where id = \''+vehicleId+'\'';
        BLN_Vehicle__c vehicle = Database.query(query);

        if(vehicle !=null && (vehicle.BLN_MakeOfVehicle__c == null || vehicle.BLN_ModelOfVehicle__c == null || vehicle.BLN_Year__c == null || vehicle.BLN_BodyType__c == null || vehicle.BLN_MakeOfVehicle__c == '' || vehicle.BLN_ModelOfVehicle__c == '' || vehicle.BLN_BodyType__c == ''))
        {
            return false;
        }

        return true;
    }
}