/*****************************************
*ClassName : BLN_AppConstants
@description : FOUK-602 This class is for the Json Parsing .
*CreatedDate: 27-11-2023
*CreatedBy : PwC-India
****************************************/
public class BLN_WrapperStore {
    /*****************************************
*ClassName  : CreditSafeResponse
*@description This is the inner wrapper class for CreditSafeResponse.
****************************************/    
    public class CreditSafeResponse{
        public String statusCompanyReportProcessing;
    }   
 /*****************************************
*Method  : parseErrorResponse
*@description Deserialize the CreditSafeResponse JSON response
*@param json
*@return parseCreditSafeResponse
****************************************/    
    public static CreditSafeResponse parseCreditSafeResponse(String json){
        return (CreditSafeResponse) System.JSON.deserialize(json, CreditSafeResponse.class);
    }
    
    /*****************************************
    *ClassName  : InitiativeWrapper
    *@description This is the inner wrapper class for CreditSafeResponse.
    ****************************************/    
    public class InitiativeWrapper {
        @AuraEnabled public String recId;
        @AuraEnabled public String content;
        @AuraEnabled public String className;
        @AuraEnabled public String title;
        @AuraEnabled public String startDate;
        @AuraEnabled public String endDate;
        
        public InitiativeWrapper(String recId, String name, String startDate, String endDate, String className) {
           //System.debug(recId+'--PARAM 41--'+name+'---'+startDate+'----'+endDate+'---'+className);
            this.recId = recId;
            this.title = name;
            this.content = name;
            this.startDate = startDate;
            this.endDate = endDate;
            this.className = className;
        }
    }
}