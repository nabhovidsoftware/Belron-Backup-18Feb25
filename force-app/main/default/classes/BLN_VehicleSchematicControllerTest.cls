/*****************************************
ClassName : BLN_VehicleSchematicControllerTest
Description : FOUK-580,FOUK-1181 This test class is used to cover testcoverage for BLN_VehicleSchematicController.
CreatedDate: 28-08-2023
CreatedBy : PwC-India
****************************************/

@IsTest
public class BLN_VehicleSchematicControllerTest {

    /*@description : This method is used to test BLN_VehicleSchematicController's fetchMetaListLwc method*/
    @IsTest
    static void testFetchMetaListLwc(){
        Test.StartTest();
        List<BLN_VehicleSchematicController.WrapMapData> result = BLN_VehicleSchematicController.fetchMetaListLwc();
        Test.StopTest();
        System.assertEquals(True,result.size()>0,'result size is greater than zero');

    }
}