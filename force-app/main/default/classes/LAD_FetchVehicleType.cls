/** @description :  LAD_FetchVehicleType
*/
public with sharing class LAD_FetchVehicleType {
    //fetchByChars method
    @AuraEnabled
    public static List<VehicleWrapper> fetchByChars(){
        try {
            List<BLN_VehicleType__c> vehTypes = [SELECT Id, Name, BLN_BodyType__c, BLN_Make__c, BLN_Model__c, BLN_Year__c, BLN_MVRIS__c FROM BLN_VehicleType__c WITH SECURITY_ENFORCED];
            List<VehicleWrapper> wrapperList = new List<VehicleWrapper>(); 
            for(BLN_VehicleType__c veh : vehTypes){
                VehicleWrapper wrap = new VehicleWrapper();
                wrap.mvris = veh.BLN_MVRIS__c;
                wrap.make = veh.BLN_Make__c;
                wrap.model = veh.BLN_Model__c;
                wrap.body = veh.BLN_BodyType__c;
                wrap.year = veh.BLN_Year__c;

                wrapperList.add(wrap);
            }

            return wrapperList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

     //Wrapper Class for Vehicle Type
     public class VehicleWrapper{
         //mvris
        @auraenabled public String mvris {get;set;}
         //make
        @auraenabled public String make {get;set;}
         //model
        @auraenabled public String model {get;set;}
         //body
        @auraenabled public String body {get;set;}
         //year
        @auraenabled public Double year {get;set;}
    }
}