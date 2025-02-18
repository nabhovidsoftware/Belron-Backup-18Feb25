@isTest
public class LAD_FetchVehicleType_Test {

    @isTest
    public static void testFetchByChars(){
        BLN_VehicleType__c vT = BLN_TestDataFactory.getVehicleType('VAUXHALL', 'ASTRA SRI CDTI S/S');
        insert vT;
        
        List<LAD_FetchVehicleType.VehicleWrapper> veh = LAD_FetchVehicleType.fetchByChars();
        system.assertequals('VAUXHALL', veh[0].make,'Vehicle Details not found');
    }
}