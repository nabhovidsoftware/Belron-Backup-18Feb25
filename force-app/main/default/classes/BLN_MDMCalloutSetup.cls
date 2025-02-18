/**@description : This Apex class used to get metadata and related fields and MDM mapping.
*  @author: PwC India
*  @Story: FOUK-5167
*  @CreatedDate: 24/06/2024
*/
public virtual class BLN_MDMCalloutSetup extends BLN_MetaDataHandler {
    
    class MDM_FieldMap_MetaDataConfig
    {
        public final string mappingMetadataName='BLN_MDMFieldMapping__mdt';
        public final string fldObjNameApi='BLN_ObjectName__c';
        public final string fldSFApiName='BLN_FieldAPIName__c';
        public final string fldMDMName='BLN_MDMFieldLabel__c';
    }
    
    MDM_FieldMap_MetaDataConfig mdmFieldMap{get;set;}
    {
        mdmFieldMap=new MDM_FieldMap_MetaDataConfig();
    }
    
    String namedCredentials{get;set;}
    String streamName{get;set;}

/**
*@description:This method is used to get MDM field mapping.
*@return List<object>
*/
    public list<sobject> getMDMFieldMapping(string objectName){
        BLN_MDMConfiguration.Metadata_Retreiver_Param metaParameters=null;
        Map<string,string> mpFilterCriteria=new Map<string,string>();
        metaParameters=new BLN_MDMConfiguration.Metadata_Retreiver_Param();
        metaParameters.metadataName=mdmFieldMap.mappingMetadataName;
        mpFilterCriteria.put(mdmFieldMap.fldObjNameApi,objectName);
        metaParameters.filterCriteria=mpFilterCriteria;
        if(metaParameters==null)
        {
            throw new IllegalArgumentException('Metadata configurations cannot be null');
        }
        return retrieveMetaData(metaParameters);
    }
    
/**
*@description:This method is used to get  Sf field value and MDM field Name for mapping.
*@return String
*/
    public string getJsonBodyByMDMMapping (Map<String, object> mpfield,list<sobject> fldMapConfig){
        string jsonBody='';

        Map<String, object> mpJsonMapping=new Map<String, object>();
        for(sobject sobj :fldMapConfig){
            string sfApiName=(string)sobj.get(mdmFieldMap.fldSFApiName);
            if(mpfield.containskey(sfApiName)){
                string mdmLabel=(string)sobj.get(mdmFieldMap.fldMDMName);
                string sfValue=(string)mpfield.get(sfApiName);
                mpJsonMapping.put(mdmLabel,sfValue);
            }
        }
        if(mpJsonMapping.size()>0){
            jsonBody=JSON.serialize(mpJsonMapping);
        }
        return jsonBody;
    }
    
/**
*@description:This method is used to serialize JSON.
*@return String
*/
    public string getJsonBodyByMap (Map<String, object> mpfield){
        string jsonBody='';
        if(mpfield.size()>0){
            jsonBody=JSON.serialize(mpfield);
        }
        return jsonBody;
    }
}