public virtual class BLN_MetaData_Handler {
    
	public virtual Set<String> GetFielsetFields(string sobjectName, string fieldSetName) {
        Set<String> MDM_SyncFields=new Set<String>();
        if(string.isBlank(sobjectName) || string.isBlank(fieldSetName)){
            return MDM_SyncFields;
        }
        
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(sobjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        List<Schema.FieldSetMember> lstfields=fieldSetObj.getFields();

        for(Schema.FieldSetMember fieldMemeber : lstfields){
            MDM_SyncFields.add(fieldMemeber.getFieldPath());
        }
        
        if(MDM_SyncFields.size()==0){
            throw new IllegalArgumentException('FieldSet fields are missing.');
        }
        return MDM_SyncFields;
    }
    
    public virtual list<sobject> retrieveMetaData(BLN_MDM_Configuration.Metadata_Retreiver_Param parameters ) {
        // Start building the SOQL query
        String query = 'SELECT ' + String.join(getFieldNames(parameters.Metadata_Name), ',') +
                       ' FROM ' + parameters.Metadata_Name;
        
        // Add filters to the query if they exist
        Map<string,string> filtercriteria=parameters.FilterCriteria;
        if (filtercriteria.size()>0) {
            List<String> criteriaList = new List<String>();
            for (String fieldName : filtercriteria.keySet()) {
                criteriaList.add(fieldName + ' = \'' + String.escapeSingleQuotes(filtercriteria.get(fieldName)) + '\'');
            }
            String criteria = String.join(criteriaList, ' AND ');
            query += ' WHERE ' + criteria;
        }
        
        // Execute the dynamic query
        List<SObject> records = Database.query(query);
        return records;
    }
    
    List<String> getFieldNames(String metadataType) {
        // Retrieve the describe result for the metadata type
        DescribeSObjectResult describe = Schema.getGlobalDescribe().get(metadataType).getDescribe();
        
        // Get the fields from the describe result
        Map<String, Schema.SObjectField> fields = describe.fields.getMap();
        
        // Extract the field names
        List<String> fieldNames = new List<String>();
        for (String fieldName : fields.keySet()) {
            fieldNames.add(fieldName);
        }
        
        return fieldNames;
    }
    
    public virtual Map<string,Map<string,string>> GetFieldsChanged(List<sobject> lstOldRecord,list<sobject> lstNewRecord,Set<String> FieldsToProcess) {
        
        Integer recordCount=lstNewRecord.size();
        string recordId_ApiName='Id';
        Map<string,Map<string,string>> mpFieldChanged=new Map<string,Map<string,string>>();
        for(Integer recNumber=0;recNumber<recordCount;recNumber++)
        {
            set<string> changedFields = new set<String> ();
            Map<string,string> fieldsChanged=new Map<string,string>();
            string activeRecordId=null;
            sobject oldRecord= lstOldRecord.get(recNumber);
            sobject newRecord= lstNewRecord.get(recNumber);
            
            Map<String, Object> oldRecFieldMap = oldRecord.getPopulatedFieldsAsMap();
            Map<String, Object> newRecFieldMap = newRecord.getPopulatedFieldsAsMap();            
            activeRecordId=(string)oldRecFieldMap.get(recordId_ApiName);
            
            for (string field : oldRecFieldMap.keySet()) {
                
                //if field doesnt belongs to mapping list then skip it
                if(!FieldsToProcess.contains(field)){
                    continue;
                }
                
                Object oldValue = oldRecFieldMap.get(field);
                Object newValue = newRecFieldMap.get(field);
                
                if (HasFieldChanged(oldValue, newValue)) {
                    fieldsChanged.put(String.valueof(field),String.valueof(newValue));                                        
                }
            }
            
            if(fieldsChanged.size()>0){
                mpFieldChanged.put(activeRecordId, fieldsChanged);
            }
        }
        return mpFieldChanged;
    }
    
    private Boolean HasFieldChanged(Object oldValue, Object newValue) {
        if (oldValue == null && newValue == null) {
            return false;
        }
        if (oldValue != newValue) {
            return true;
        }
        return false;
    }
}