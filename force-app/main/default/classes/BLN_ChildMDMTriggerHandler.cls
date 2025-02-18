/**@description : This Apex class used to handle the after insert and after update operation.
*  @author: PwC India
*  @Story: FOUK-9523
*  @CreatedDate: 15/07/2024
*/
public with sharing class BLN_ChildMDMTriggerHandler extends BLN_MetaDataHandler implements BLN_TriggerInterface {
    public static Boolean handlerExecuted = false;
    public static Boolean stopExecution = false;
    public Map<String, Map<String, String>> mdmFields { get; set; }
    public String objectName { get; set; }
    public String eventType { get; set; }
    public Set<Id> accIds { get; set; } 
    System.TriggerOperation operationType { get; set; }
    public Map<Id, SObject> oldMap { get; set; }
    public Map<Id, SObject> newMap { get; set; }
    public String streamName { get; set; }

/**
*@description:This method is used to check trigger executed or not.
*@return boolean
*/
public Boolean stopDispatch(){
    return stopExecution;
}

/**
*@description:This method is used in interface so declare in class..
*@return void
*/
public void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {

    stopExecution = true;
   
}
    /**
*@description:This method is used in interface so declare in class..
*@return void
*/
public void beforeInsert(List<SObject> newList) {
    /** @description : FOUK-6076 fill Inheritance Behaviour from custom metadata **/
    BLN_AccountRuleParameterTriggerHandler.beforeInsert((List<BLN_AccountRuleParameter__c>)newList);
}
/**
*@description:Once Account inserted method will pass below parameters for next execution.
*@return void
*/
public void afterInsert(List<SObject> newList, Map<Id, SObject> newMap) {
   
        this.operationType = System.TriggerOperation.AFTER_INSERT;
        this.newMap = newMap;
        this.streamName = System.label.BLN_SalesStream;
        this.objectName = Trigger.new.getSObjectType().getDescribe().getName(); 
        // stopExecution = true;
        validateRequest(true,'Update'); // Pass true for insert operation
}

/**
*@description:Once Account updated  method will pass below parameters for next execution.
*@return void
*/
public void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
    this.operationType = System.TriggerOperation.AFTER_UPDATE;
    this.oldMap = oldMap;
    this.streamName = System.label.BLN_SalesStream;
    this.newMap = new Map<Id, SObject>(newList);
    this.objectName = Trigger.new.getSObjectType().getDescribe().getName(); 
    // stopExecution = true;
    validateRequest(false,'Update'); // Pass false for update operation
}

public void beforeDelete(List<SObject> oldList, Map<Id, SObject> oldMap) {
   stopExecution = true;
}

public void afterDelete(List<SObject> oldList, Map<Id, SObject> oldMap) {
    stopExecution = true;
}


public void afterUnDelete(List<SObject> newList, Map<Id, SObject> newMap) {
    stopExecution = true;
}


/**
*@description:This method used to check account type and get the map of updated fields and values.
*@return void
*/
void validateRequest(Boolean isOperationTypeInsert, String eventType) {
    try {
        if (String.isNotBlank(objectName)) {
            String fieldSetName = getConfigurations();
           
            Set<String> fieldSet = getFielsetFields(objectName, fieldSetName);

            if (isOperationTypeInsert) {
                mdmFields = getFieldsChanged(null, newMap.values(), fieldSet, new Map<String,String>{'objectName'=> objectName, 'streamName'=>streamName});} else { mdmFields = getFieldsChanged(oldMap.values(), newMap.values(), fieldSet,new Map<String,String>{'objectName'=> objectName, 'streamName'=>streamName});
            }
            if (mdmFields != null && !mdmFields.isEmpty()) {
               prepareCallOutActions(eventType);
            }
        }
    } catch (Exception ex) {
        BLN_ExceptionLogger.captureException(ex);
    }
}

/**
*@description:This method used to prepare data which is required for callout.
*@return void
*/
void prepareCallOutActions(String eventType) {
    BLN_MDMConfiguration.MDMParameters param = new BLN_MDMConfiguration.MDMParameters();
    param.streamName =  streamName;
    param.fieldsToSync = mdmFields;
    param.sourceObject = objectName;
    param.eventType = eventType;
if(!test.isRunningTest()){
        String processId = '';
        processId = Database.executeBatch(new BLN_QueueMDMGateWay(param), 1);
    }
    
}

/**
*@description:This method used to get metadata and fieldset name.
*@return void
*/
String getConfigurations() {
    BLN_MDMConfiguration.Metadata_Retreiver_Param metaParameters = getSobjectFieldSet(objectName);
    String fieldSetName = '';

    if (metaParameters == null) {throw new IllegalArgumentException('Parameters cannot be null or empty');}

    List<SObject> retrieveSettings = retrieveMetaData(metaParameters);

    if (retrieveSettings.isEmpty()) {throw new IllegalArgumentException('Metadata configuration is missing');
    }
    for (SObject metadata : retrieveSettings) {
        MDM_Configuration__mdt config = (MDM_Configuration__mdt) metadata;
        fieldSetName = config.FieldApiName__c;
        break; 
    }
    return fieldSetName;
}


/**
*@description:This method used to get metadata,filter criteria , object name and fieldset name.
*@return void
*/
BLN_MDMConfiguration.Metadata_Retreiver_Param getSobjectFieldSet(String objectName) {
    BLN_MDMConfiguration.Metadata_Retreiver_Param metaParameters = null;
    String metadataName = 'MDM_Configuration__mdt';
    String filterCriteria = 'Fieldset';

    Map<String, String> mpFilterCriteria = new Map<String, String>();
    metaParameters = new BLN_MDMConfiguration.Metadata_Retreiver_Param();
    metaParameters.metadataName = metadataName;
    mpFilterCriteria.put('FilterCriteria__c', filterCriteria);
    mpFilterCriteria.put('ObjectName__c', objectName);
    metaParameters.filterCriteria = mpFilterCriteria;

    return metaParameters;
}





}