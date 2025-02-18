public virtual class BLN_MDM_CalloutSetup extends BLN_MetaData_Handler {
    
    class MDM_FieldMap_MetaDataConfig
    {
        public final string Mapping_MetadataName='BLN_MDMFieldMapping__mdt';
        public final string fld_ObjName_Api='BLN_ObjectName__c';
        public final string fld_SF_ApiName='BLN_FieldAPIName__c';
        public final string fld_MDM_Name='BLN_MDMFieldLabel__c';
    }
    
    MDM_FieldMap_MetaDataConfig MDMFieldMap{get;set;}
    {
        MDMFieldMap=new MDM_FieldMap_MetaDataConfig();
    }
    
    String namedCredentials{get;set;}
    Map<string,Map<string,string>> CallOutFields { get; set; }
    String streamName{get;set;}
    
    public virtual void GetConfigurationByStream(BLN_MDM_Configuration.MDMParameters parameters)
    {
        //this.CallOutFields=callOutFields;
        //this.StreamName=streamName;
    }
    
    
    public list<sobject> GetMDMFieldMapping(string objectName){
        BLN_MDM_Configuration.Metadata_Retreiver_Param meta_parameters=null;
        Map<string,string> mpFilterCriteria=new Map<string,string>();
        meta_parameters=new BLN_MDM_Configuration.Metadata_Retreiver_Param();
        meta_parameters.Metadata_Name=MDMFieldMap.Mapping_MetadataName;
        mpFilterCriteria.put(MDMFieldMap.fld_ObjName_Api,objectName);
        meta_parameters.FilterCriteria=mpFilterCriteria;
        
        if(meta_parameters==null)
        {
            throw new IllegalArgumentException('Metadata configurations cannot be null');
        }
        return retrieveMetaData(meta_parameters);
    }
    
    public string GetJsonBodyByMDMMapping (Map<String, object> mpfield,list<sobject> fldMapConfig){
        string jsonBody='';
        Map<String, object> mpJsonMapping=new Map<String, object>();
        for(sobject sobj :fldMapConfig){
            string sfApiName=(string)sobj.get(MDMFieldMap.fld_SF_ApiName);
            if(mpfield.containskey(sfApiName)){
                string mdmLabel=(string)sobj.get(MDMFieldMap.fld_MDM_Name);
                string sfValue=(string)mpfield.get(sfApiName);
                mpJsonMapping.put(mdmLabel,sfValue);
            }
        }
        if(mpJsonMapping.size()>0){
            jsonBody=JSON.serialize(mpJsonMapping);
        }
        return jsonBody;
    }
    
    public string GetJsonBodyByMap (Map<String, object> mpfield){
        string jsonBody='';
        if(mpfield.size()>0){
            jsonBody=JSON.serialize(mpfield);
        }
        return jsonBody;
    }
}