/*ClassName :   BLN_MDMCalloutSetup
Description :	BLN_MDMCalloutSetup having test class BLN_MDMCalloutSetupTest
Story       :   
CreatedDate :   25/06/2024
CreatedBy   :   Sachin
**********************************************************************************/
@isTest 
private class BLN_MDMCalloutSetupTest {
   
    /*@Description : This method is used to test metaParameters*/
    @isTest
    static void testMdMFieldMapping() {
        Test.startTest();
        //Create instance of the main class
        BLN_MDMCalloutSetup objMDMCalloutSetup = new BLN_MDMCalloutSetup();
        try{
            objMDMCalloutSetup.getMDMFieldMapping('Test Object');
        }
        catch(Exception ex){
            Assert.isInstanceOfType(ex, IllegalArgumentException.class, 'Exception is of IllegalArgumentException type');
            Assert.areEqual('Metadata configurations cannot be null', ex.getMessage(), 'Exception message');
        }
        Test.stopTest();
    }
    
// test method to verify metadata mapping
    @isTest 
    static void testGetJsonBodyByMDMMapping(){
        
        Map<String, Object> mpfield = new Map<String, Object>{'BLN_FieldAPIName__c' => 'Sales'};
        List<sObject> fldMapConfig = new List<sObject>{new BLN_MDMFieldMapping__mdt(BLN_FieldAPIName__c='BLN_FieldAPIName__c',BLN_MDMFieldLabel__c='Sales')};
        
        Test.startTest();        
        BLN_MDMCalloutSetup mdmCalloutSetup = new BLN_MDMCalloutSetup();
        String result = mdmCalloutSetup.getJsonBodyByMDMMapping(mpfield,fldMapConfig);
        Test.stopTest();
        
        Assert.isNotNull(result, 'Result should not be Null');
    }
    
// test method to verify exception
    @isTest 
    static void testGetJsonBodyByMapWithEmptyMap(){
        Map<String, Object> mpfield = new Map<String, Object>();
        
        Test.startTest();        
        BLN_MDMCalloutSetup mdmCalloutSetup = new BLN_MDMCalloutSetup();
        String result = mdmCalloutSetup.getJsonBodyByMap(mpfield);
        Test.stopTest();
        
        Assert.isNotNull(result, 'Result should not be Null');       
    }

// test method to verify Json
    @isTest 
    static void testGetJsonBodyByMapWithValidMap(){
        Map<String, Object> mpfield = new Map<String, Object>{'BLN_FieldAPIName__c' => 'Sales'};
        
        Test.startTest();        
        BLN_MDMCalloutSetup mdmCalloutSetup = new BLN_MDMCalloutSetup();
        String result = mdmCalloutSetup.getJsonBodyByMap(mpfield);
        Test.stopTest();
        
        Assert.isNotNull(result, 'Result should not be Null');
    }
}