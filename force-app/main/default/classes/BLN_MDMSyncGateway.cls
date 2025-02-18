/**@description : This Apex class used to for sync between MDM and SF.
*  @author: PwC India
*  @Story: FOUK-5167
*  @CreatedDate: 24/06/2024
*/
public class BLN_MDMSyncGateway{
    
    //Declaration
    string recordIdApiName='Id';
    MDM_FieldChangeMonitor defaultvalue=MDM_FieldChangeMonitor.VALIDATE_ALL_FIELDS;
    public string sobjectName{get;set;} // sobjectName
    public list<sobject> oldValue{get;set;}
    public list<sobject> newValue{get;set;}
    public Set<String> mdmSyncFields{get;set;}
    public Map<string,set<string>> mpFieldChanged{get;set;}
    {
        mpFieldChanged =new Map<string,set<string>>();
    }

/**
*@description:This is method used to capture old and updated value of the SF fields.
*@return void
*/
    public void captureRecordFieldChanges(list<sobject> triggerOldValue,list<sobject> triggernNewValue,string sourceObjectName){
        BLN_MDMSync_Helper helper=null;
        if(triggerOldValue.size()==0 || triggernNewValue.size()==0 || String.isBlank(sobjectName)){
            Boolean triggerold;
        }else{
            helper=new BLN_MDMSync_Helper();
            
            oldValue=triggerOldValue;
            newValue=triggernNewValue;
            sobjectName=sourceObjectName;
            mdmSyncFields=helper.getMDMFieldList(sobjectName,'');
        }
    }

/**
*@description:This is method used to get MDM mapping fieldset.
*@return Set<String>
*/
    public static Set<String> getMDMFieldList(string sobjectName,String fieldSetName){
        Set<String> mdmSyncFields=new Set<String>();
        
        Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType sObjectTypeObj = globalDescribeMap.get(sobjectName);
        Schema.DescribeSObjectResult describeSObjectResultObj = sObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = describeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        List<Schema.FieldSetMember> lstfields=fieldSetObj.getFields();
        
        for(Schema.FieldSetMember fieldMemeber : lstfields){
            mdmSyncFields.add(fieldMemeber.getFieldPath());
        }
        return mdmSyncFields;
    }

/**
*@description:This is method used to validate the fields.
*@return void
*/
    public void validateFieldChanges(){
        
        Integer recordCount=newValue.size();
        for(Integer recNumber=0;recNumber<recordCount;recNumber++)
        {
            set<string> changedFields = new set<String> ();
            string activeRecordId=null;
            sobject oldRecord= oldValue.get(recNumber);
            sobject newRecord= newValue.get(recNumber);
            
            Map<String, Object> oldRecFieldMap = oldRecord.getPopulatedFieldsAsMap();
            Map<String, Object> newRecFieldMap = newRecord.getPopulatedFieldsAsMap();
            activeRecordId=(string)oldRecFieldMap.get(recordIdApiName);
            
            for (string field : oldRecFieldMap.keySet()) {
                
                //if field doesnt belongs to mapping list then skip it
                if(!mdmSyncFields.contains(field)){
                    continue;
                }
                
                Object oldValue = oldRecFieldMap.get(field);
                Object newValue = newRecFieldMap.get(field);
                
                if (hasFieldChanged(oldValue, newValue)) {
                    changedFields.add(field);
                }
            }
            
            if(changedFields.size()>0){
                mpFieldChanged.put(activeRecordId, changedFields);
            }
        }
    }


/**
*@description:This is method used to check field is updated or not.
*@return boolean
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
    
    public enum MDM_FieldChangeMonitor { 
        VALIDATE_ALL_FIELDS,
        VALIDATE_FIRST_CHANGE_FIELD
            }

    /**
*@description:This is method used to get MDM mapping fieldset.
*@return Set<String>
*/
    public class BLN_MDMSync_Helper{
        
        public Set<String> getMDMFieldList(string sobjectName,String fieldSetName){
            Set<String> mdmSyncFields=new Set<String>();
            
            Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe(); 
            Schema.SObjectType sObjectTypeObj = globalDescribeMap.get(sobjectName);
            Schema.DescribeSObjectResult describeSObjectResultObj = sObjectTypeObj.getDescribe();
            Schema.FieldSet fieldSetObj = describeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
            List<Schema.FieldSetMember> lstfields=fieldSetObj.getFields();
            
            for(Schema.FieldSetMember fieldMemeber : lstfields){
                mdmSyncFields.add(fieldMemeber.getFieldPath());
            }
            return mdmSyncFields;
        }
    }
}