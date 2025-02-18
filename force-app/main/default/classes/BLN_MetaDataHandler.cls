/**@description : This Apex class used to fieldset and metadata filter criteria.
*  @author: PwC India
*  @Story: FOUK-5167
*  @CreatedDate: 24/06/2024
*/
public virtual without sharing class BLN_MetaDataHandler {
  
    /**
    *@description:This method is used to fieldset.
    *@return Set<String>
    */
        public virtual Set<String> getFielsetFields(string sobjectName, string fieldSetName) {
            Set<String> mdmSyncFields=new Set<String>();
            if(string.isBlank(sobjectName) || string.isBlank(fieldSetName)){
                return mdmSyncFields;
            }
            
            Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe(); 
            Schema.SObjectType sObjectTypeObj = globalDescribeMap.get(sobjectName);
            Schema.DescribeSObjectResult describeSObjectResultObj = sObjectTypeObj.getDescribe();
            Schema.FieldSet fieldSetObj = describeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
            List<Schema.FieldSetMember> lstfields=fieldSetObj.getFields();
    
    
            for(Schema.FieldSetMember fieldMemeber : lstfields){
                mdmSyncFields.add(fieldMemeber.getFieldPath());
            }
            
            if(mdmSyncFields.size()==0){
                throw new IllegalArgumentException('FieldSet fields are missing.');
            }
           
            return mdmSyncFields;
        }
    
        /**
    *@description:This method is used to get metadata and filtercriteria.
    *@return list<sobject>
    */
        public virtual list<sobject> retrieveMetaData(BLN_MDMConfiguration.Metadata_Retreiver_Param parameters ) {
            // Start building the SOQL query
            String query = 'SELECT ' + String.join(getFieldNames(parameters.metadataName), ',') +
                           ' FROM ' + parameters.metadataName;
            
            // Add filters to the query if they exist
            Map<string,string> filtercriteria=parameters.filterCriteria;
            if (filtercriteria.size()>0) {
                List<String> criteriaList = new List<String>();
                for (String fieldName : filtercriteria.keySet()) {
                    criteriaList.add(fieldName + ' = \'' + String.escapeSingleQuotes(filtercriteria.get(fieldName)) + '\'');
                }
                String criteria = String.join(criteriaList, ' AND ');
                query += ' WHERE ' + criteria;
            }
            // Execute the dynamic query
            List<SObject> records = System.Database.query(query);
            return records;
        }
        
        /**
    *@description:This method is used to get fields from metadata.
    *@return List<String>
    */
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
        /**
    *@description:This method is used to get changed fields values and api names.
    *@return Map<string,Map<string,string>>
    */
        public virtual Map<string,Map<string,string>> getFieldsChanged(List<sobject> lstOldRecord,list<sobject> lstNewRecord,Set<String> fieldsToProcess, Map<String,String> streamObject) {
            String streamName = streamObject.get('streamName');
            String objectName = streamObject.get('objectName');
            Integer recordCount=lstNewRecord.size();
            List<BLN_AccountRuleParameter__c> arpList = new List<BLN_AccountRuleParameter__c>();

            if(objectName == 'BLN_AccountGroupRule__c'){
                arpList = [select BLN_Account__c, BLN_Account__r.Name,BLN_Account__r.BLN_MDMAccountID__c, BLN_AccountRuleGroup__c from BLN_AccountRuleParameter__c where BLN_Account__c!=null and BLN_AccountRuleGroup__c in :  (List<BLN_AccountGroupRule__c>)lstNewRecord WITH SECURITY_ENFORCED];
            }
            else if(objectName == 'BLN_SLADefinition__c'){
                arpList = [select BLN_Account__c,BLN_SLAType__c, BLN_Account__r.Name,BLN_Account__r.BLN_MDMAccountID__c from BLN_AccountRuleParameter__c where BLN_Account__c!=null and BLN_SLAType__c in :  (List<BLN_SLADefinition__c>)lstNewRecord WITH SECURITY_ENFORCED];

            }

            Set<Id>accountIds = new Set<Id>();
            Map<string,BLN_AccountRuleParameter__c> arpMap = new Map<string,BLN_AccountRuleParameter__c>();
            for(BLN_AccountRuleParameter__c arp : arpList){
                if(objectName == 'BLN_AccountGroupRule__c'){arpMap.put(arp.BLN_AccountRuleGroup__c,arp);}
                else if(objectName == 'BLN_SLADefinition__c'){arpMap.put(arp.BLN_SLAType__c,arp);}
            }

            for(SObject sobj :lstNewRecord){
                Id accountId = null;
                if(objectName == 'Contact'){
                    Contact con = (Contact)sobj;
                    accountId = con.AccountId;
                }
                else if(objectName == 'BLN_AccountRuleParameter__c'){
                    BLN_AccountRuleParameter__c arp = (BLN_AccountRuleParameter__c)sobj;accountId = arp.BLN_Account__c;}
                else if(objectName == 'BLN_PDSCode__c'){
                    BLN_PDSCode__c pds = (BLN_PDSCode__c)sobj;accountId = pds.BLN_Account__c;
                }
                else if(objectName == 'BLN_AccountAlternativeName__c'){
                    BLN_AccountAlternativeName__c alt = (BLN_AccountAlternativeName__c)sobj;accountId = alt.BLN_Account__c;
                }

                if(accountId!=null){
                    accountIds.add(accountId);
                }
                
            }
            
            List<Account> accountList = [select Id,Name,BLN_MDMAccountID__c from account where Id in :accountIds WITH SECURITY_ENFORCED];
            Map<Id,Account> accountMap = new Map<Id,Account>(accountList);
    
            string recordIdApiName='Id';
            Map<string,Map<string,string>> mpFieldChanged=new Map<string,Map<string,string>>();
            if(lstOldRecord != null){
            for(Integer recNumber=0;recNumber<recordCount;recNumber++)
            {
                    sobject newRecord= lstNewRecord.get(recNumber);
                    Map<String, Object> newRecFieldMap = newRecord.getPopulatedFieldsAsMap(); 
                   /* Boolean isLegacySystemAccount = (Boolean)newRecFieldMap?.get('BLN_IsLegacySystemAccount__c');
                    if(isLegacySystemAccount){
                        continue;
                    }*/

                    set<string> changedFields = new set<String> ();
                    Map<string,string> fieldsChanged=new Map<string,string>();
                    string activeRecordId = null;
                    sobject oldRecord= lstOldRecord[recNumber];
                
                Map<String, Object> oldRecFieldMap = oldRecord.getPopulatedFieldsAsMap();
                activeRecordId=(string)oldRecFieldMap.get(recordIdApiName);
                
                // code block added to contain all api names in map
                Map<String, Object> allRecFieldMap = new Map<String, Object>();
                allRecFieldMap.putAll(newRecFieldMap);
                allRecFieldMap.putAll(oldRecFieldMap);
                
                for (string field : allRecFieldMap.keySet()) {
                    if(!fieldsToProcess.contains(field)){
                        continue;
                    }
                    
                    Object oldValue = oldRecFieldMap?.get(field);
                    Object newValue = newRecFieldMap?.get(field);
                    if (hasFieldChanged(oldValue, newValue)) {
                        fieldsChanged.put(String.valueof(field),String.valueof(newValue));                                         
                    }
                    else{
                        if(streamName==System.label.BLN_ServiceStream){
                            fieldsChanged.put(String.valueof(field),String.valueof(newValue));
                        }
                        }
                    }

                    if(fieldsChanged.size()>0 && streamName== System.label.BLN_SalesStream && objectName == 'Account'){
                        fieldsChanged.put('Name',String.valueof(newRecFieldMap.get('Name')));fieldsChanged.put('BLN_MDMAccountID__c',String.valueof(newRecFieldMap.get('BLN_MDMAccountID__c')));
                    }
                    if( fieldsChanged.size()>0 && streamName== System.label.BLN_SalesStream && objectName == 'Contact' && accountMap.containsKey(String.valueof(newRecFieldMap.get('AccountId')))){
                        fieldsChanged.put('Name',accountMap.get(String.valueof(newRecFieldMap.get('AccountId'))).Name); fieldsChanged.put('BLN_MDMAccountID__c',accountMap.get(String.valueof(newRecFieldMap.get('AccountId'))).BLN_MDMAccountID__c); fieldsChanged.put('accountId',String.valueof(newRecFieldMap.get('AccountId')));
                    }
                    if( fieldsChanged.size()>0 && streamName== System.label.BLN_SalesStream && (objectName == 'BLN_AccountRuleParameter__c' || objectName == 'BLN_PDSCode__c' || objectName == 'BLN_AccountAlternativeName__c') && accountMap.containsKey(String.valueof(newRecFieldMap.get('BLN_Account__c'))) ){
                        fieldsChanged.put('Name',accountMap.get(String.valueof(newRecFieldMap.get('BLN_Account__c'))).Name); fieldsChanged.put('BLN_MDMAccountID__c',accountMap.get(String.valueof(newRecFieldMap.get('BLN_Account__c'))).BLN_MDMAccountID__c); fieldsChanged.put('accountId',String.valueof(newRecFieldMap.get('BLN_Account__c')));
                    }
                    if( fieldsChanged.size()>0 && streamName== System.label.BLN_SalesStream && (objectName == 'BLN_AccountGroupRule__c'  || objectName == 'BLN_SLADefinition__c')  && arpMap.containsKey(String.valueof(newRecFieldMap.get('Id')))){
                        fieldsChanged.put('Name',arpMap.get(String.valueof(newRecFieldMap.get('Id'))).BLN_Account__r.Name); fieldsChanged.put('BLN_MDMAccountID__c',arpMap.get(String.valueof(newRecFieldMap.get('Id'))).BLN_Account__r.BLN_MDMAccountID__c); fieldsChanged.put('accountId',arpMap.get(String.valueof(newRecFieldMap.get('Id'))).BLN_Account__c);
                    }
                    if(fieldsChanged.size()>0){
                        mpFieldChanged.put(activeRecordId, fieldsChanged);
                    }
            }
        }else{
                for (Integer recNumber = 0; recNumber < recordCount; recNumber++) {
                                SObject newRecord = lstNewRecord.get(recNumber);
                    Map<String, Object> newRecFieldMap = newRecord.getPopulatedFieldsAsMap();
                    /* Boolean isLegacySystemAccount = (Boolean)newRecFieldMap?.get('BLN_IsLegacySystemAccount__c');
                     if(isLegacySystemAccount){
                         continue;
                     }*/
                              
                    String activeRecordId = (String) newRecord.get(recordIdApiName);
                                Map<String, String> fieldsChanged = new Map<String, String>();
                    
                                for (String field : newRecFieldMap.keySet()) {
                                    if (fieldsToProcess.contains(field)) {
                                        Object newValue = newRecFieldMap.get(field);
                                        fieldsChanged.put(field, String.valueOf(newValue));
                                    }
                                }
                    
                                if (!fieldsChanged.isEmpty()) {
                                    if(streamName== System.label.BLN_SalesStream && objectName == 'Contact' && accountMap.containsKey(String.valueof(newRecFieldMap.get('AccountId')))){
                            fieldsChanged.put('Name',accountMap.get(String.valueof(newRecFieldMap.get('AccountId'))).Name); fieldsChanged.put('BLN_MDMAccountID__c',accountMap.get(String.valueof(newRecFieldMap.get('AccountId'))).BLN_MDMAccountID__c); fieldsChanged.put('accountId',String.valueof(newRecFieldMap.get('AccountId')));
                        }
                        if(streamName== System.label.BLN_SalesStream  && (objectName == 'BLN_AccountRuleParameter__c' || objectName == 'BLN_PDSCode__c' || objectName == 'BLN_AccountAlternativeName__c') && accountMap.containsKey(String.valueof(newRecFieldMap.get('BLN_Account__c')))){
                            fieldsChanged.put('Name',accountMap.get(String.valueof(newRecFieldMap.get('BLN_Account__c'))).Name); fieldsChanged.put('BLN_MDMAccountID__c',accountMap.get(String.valueof(newRecFieldMap.get('BLN_Account__c'))).BLN_MDMAccountID__c); fieldsChanged.put('accountId',String.valueof(newRecFieldMap.get('BLN_Account__c')));
                                    }
                                    else{
                                        mpFieldChanged.put(activeRecordId, fieldsChanged);
                                    }
                                    mpFieldChanged.put(activeRecordId, fieldsChanged);
                                }
                            }
    
            }
        
            return mpFieldChanged;
        }
    
    /**
    *@description:This method is used to pass boolean, if field values has changed.
    *@return Boolean
    */
        private Boolean hasFieldChanged(Object oldValue, Object newValue) {
            if (oldValue == null && newValue == null) {
                return false;
            }
            if (oldValue != newValue) {
                return true;
            }
            return false;
        }
    }