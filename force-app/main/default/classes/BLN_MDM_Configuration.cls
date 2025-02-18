public class BLN_MDM_Configuration {
    	
    	public class MDMParameters
        {
            Public string StreamName{get;set;}
            Public string SourceObject{get;set;}
            Public object FieldsToSync{get;set;}
            public string fieldsToSync_DataType{get;set;}
        }
    
    	public class Metadata_Retreiver_Param
        {
            Public Map<string,string> FilterCriteria{get;set;}
            Public string Metadata_Name{get;set;}
        }
    
        public class ResponseWrapper
        {
            Public object Response{get;set;}
            Public Integer StatusCode{get;set;}
            Public string Message{get;set;}
        }
}