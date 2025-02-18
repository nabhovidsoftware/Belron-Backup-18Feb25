/**@description : This Apex class has Parameter setup.
*  @author: PwC India
*  @Story: FOUK-5167
*  @CreatedDate: 24/06/2024
*/
public class BLN_MDMConfiguration {

/**
*@description:This is class used to set parameter which is required for callout.
*@return 
*/
    	public class MDMParameters
        {
            public string streamName{get;set;}
            public string sourceObject{get;set;}
            public object fieldsToSync{get;set;}
            public string fieldsToSyncDataType{get;set;}
            public string accountId{get;set;}// 5167
            public string eventType{get;set;}
            public string accountName{get;set;}
            public string mdmAccountId{get;set;}
        }

    /**
*@description:This is class used to set filter criteria.
*@return 
*/
    	public class Metadata_Retreiver_Param
        {
            public Map<string,string> filterCriteria{get;set;}
            public string metadataName{get;set;}
        }

    /**
*@description:This is class used to set parameter.
*@return 
*/
        public class ResponseWrapper
        {
            public object response{get;set;}
            public Integer statusCode{get;set;}
            public string message{get;set;}
        }



}