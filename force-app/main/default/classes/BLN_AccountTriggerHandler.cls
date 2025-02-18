/**@description : This Apex class used to handle the after insert and after update operation.
*  @author: PwC India
*  @Story: FOUK-5167
*  @CreatedDate: 24/06/2024
*/
public with sharing class BLN_AccountTriggerHandler extends BLN_MetaDataHandler implements BLN_TriggerInterface{

    public Boolean isPersonAccount = false;
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
        // system.debug('stopExecution-->'+stopExecution);
        return stopExecution;
    }

/**
*@description:This method is used in interface so declare in class..
*@return void
*/
    public void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
        stopExecution = false;
       
    }

/**
*@description:This method is used in interface so declare in class..
*@return void
*/
public void beforeInsert(List<SObject> newList) {
    // if(!stopExecution){
    //     List<Account> accList =(List<Account>)newList;
    //    // setPersonIndividualId(accList); 
    //     //stopExecution = true;
    // }
    stopExecution = false;
}


/**
*@description:Once Account inserted method will pass below parameters for next execution.
*@return void
*/
    public void afterInsert(List<SObject> newList, Map<Id, SObject> newMap) {
        try{
        List<Account> isLegacyAccList = new List<Account>(); //FOUK-12889
        isLegacyAccList = getisLegacyFalseAcc((List<Account>) newList); //FOUK-12889
  if(!isLegacyAccList.isEmpty()){
        if (!stopExecution && isAccountPerson(isLegacyAccList) ) {//FOUK-12889
            this.operationType = System.TriggerOperation.AFTER_INSERT;
            this.newMap = new Map<Id, SObject>(isLegacyAccList);
            this.streamName = System.label.BLN_ServiceStream;
            this.objectName = determineObjectName(isLegacyAccList, null); //FOUK-12889 // Get object name dynamically based on IsPersonAccount
            stopExecution = true;
            this.accIds = getAccountIdsFromTrigger(isLegacyAccList); //FOUK-12889
            validateRequest(true,'Create'); // Pass true for insert operation
        }
        else if (!stopExecution && isSalesAccount(isLegacyAccList)){//FOUK-12889
            this.operationType = System.TriggerOperation.AFTER_INSERT;
            this.newMap = new Map<Id, SObject>(isLegacyAccList);
            this.streamName = System.label.BLN_SalesStream;
            this.objectName = determineObjectName(isLegacyAccList, null); //FOUK-12889 // Get object name dynamically based on IsPersonAccount
            stopExecution = true;
            this.accIds = getAccountIdsFromTrigger(isLegacyAccList); //FOUK-12889
            validateRequest(true,'Create'); // Pass true for insert operation
        }
    }
}
catch (Exception ex) {BLN_ExceptionLogger.captureException(ex);}
    }

/**
*@description:Once Account updated  method will pass below parameters for next execution.
*@return void
*/
    public void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) { //FOUK-12889
       try{
        List<Account> isLegacyAccList = new List<Account>(); //FOUK-12889
        Map<Id,Account> mapAcc = new Map<Id,Account>();
        isLegacyAccList = getisLegacyFalseAcc((List<Account>) newList); //FOUK-12889
        mapAcc = getisLegacyFalseAccMap((Map<Id,Account>) oldMap,isLegacyAccList);
        if(!isLegacyAccList.isEmpty()){
        if (!stopExecution && isAccountPerson(isLegacyAccList)) { //FOUK-12889
            this.operationType = System.TriggerOperation.AFTER_UPDATE; this.oldMap = mapAcc; this.streamName = System.label.BLN_ServiceStream; this.newMap = new Map<Id, SObject>(isLegacyAccList); //FOUK-12889
            this.objectName = determineObjectName(isLegacyAccList, mapAcc);  //FOUK-12889 // Get object name dynamically based on IsPersonAccount
            stopExecution = true; this.accIds = getAccountIdsFromTrigger(isLegacyAccList); validateRequest(false,'Update'); // Pass false for update operation
        }
        else if(!stopExecution && isSalesAccount(isLegacyAccList)){ //FOUK-12889
            this.operationType = System.TriggerOperation.AFTER_UPDATE; this.oldMap = mapAcc;this.streamName = System.label.BLN_SalesStream; this.newMap = new Map<Id, SObject>(isLegacyAccList); //FOUK-12889
            this.objectName = determineObjectName(isLegacyAccList, mapAcc); //FOUK-12889// Get object name dynamically based on IsPersonAccount
           stopExecution = true;this.accIds = getAccountIdsFromTrigger(isLegacyAccList);validateRequest(false,'Update'); // Pass false for update operation
        }
    }
} 
catch (Exception ex) {BLN_ExceptionLogger.captureException(ex);}
}


public void beforeDelete(List<SObject> oldList, Map<Id, SObject> oldMap) {
    stopExecution = false;
}

public void afterDelete(List<SObject> oldList, Map<Id, SObject> oldMap) {stopExecution = false;}


public void afterUnDelete(List<SObject> newList, Map<Id, SObject> newMap) {stopExecution = false;}


/**
*@description:This method used to check account type and get the map of updated fields and values.
*@return void
*/
    void validateRequest(Boolean isOperationTypeInsert, String eventType) {

        try {
            if (String.isNotBlank(objectName)) {
                String fieldSetName = getConfigurations();
                if(objectName== 'PersonAccount'){
                    isPersonAccount=true;
                    objectName ='Account';
                }
                Set<String> fieldSet = getFielsetFields(objectName, fieldSetName);

                if (isOperationTypeInsert) {
                    mdmFields = getFieldsChanged(null, newMap.values(), fieldSet,new Map<String,String>{'objectName'=> objectName, 'streamName'=>streamName});
                } else {mdmFields = getFieldsChanged(oldMap.values(), newMap.values(), fieldSet,new Map<String,String>{'objectName'=> objectName, 'streamName'=>streamName});}
                if (mdmFields != null && !mdmFields.isEmpty()) {
                    prepareCallOutActions(eventType);
                }
            }
        }catch (Exception ex) {BLN_ExceptionLogger.captureException(ex);}
    }

/**
*@description:This method used to prepare data which is required for callout.
*@return void
*/
    void prepareCallOutActions(String eventType) {
        BLN_MDMConfiguration.MDMParameters param = new BLN_MDMConfiguration.MDMParameters();

        // if (isPersonAccount) {
        //     param.streamName = 'Service';} else {param.streamName = 'Sales';
        // }
        param.streamName =  streamName;
        param.fieldsToSync = mdmFields;
        param.sourceObject = objectName;
        param.eventType = eventType;
        // for (Id accId : accIds) {
        //     param.accountId = accId; 
        // }
        if(!Test.isrunningtest()){
            String processId = '';processId = Database.executeBatch(new BLN_QueueMDMGateWay(param),1);

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

/**
*@description:This method used to get Object Name.
*@return String
*/
    String determineObjectName(List<SObject> newRecords, Map<Id, SObject> oldMap) {
        if (Trigger.isInsert && newRecords != null && !newRecords.isEmpty()) {
            Account acc = (Account) newRecords[0];
            return acc.IsPersonAccount ? 'PersonAccount' : 'Account';} else if (Trigger.isUpdate && newRecords != null && !newRecords.isEmpty() && oldMap != null && !oldMap.isEmpty()) {Account acc = (Account) newRecords[0];return acc.IsPersonAccount ? 'PersonAccount' : 'Account';
        }
        return null;}
        
    Set<Id> getAccountIdsFromTrigger(List<SObject> records) {
        Set<Id> ids = new Set<Id>();

        for (SObject record : records) {
            if (record instanceof Account) {
                ids.add(record.Id);
            }
        }

        return ids;}

               /**
*@description:This method used to get Object Account with isLegacySystemAccount False.
*@return String
*/
    Public Static List<Account> getisLegacyFalseAcc(List<Account> records){
        List<Account> accList = new List<Account>();
        try{
        
        for (Account rec : records) {

               if(rec.BLN_IsLegacySystemAccount__c == false){
                   accList.add(rec);
             
           }
       }  
      }
       catch (Exception ex) {BLN_ExceptionLogger.captureException(ex);}
       return accList ; 
    }


       Public Static Map<Id, Account> getisLegacyFalseAccMap(Map<Id, Account> recMap, List<Account> records){
        Map<Id, Account> accMap = new Map<Id, Account>();
        try{
        
       
        for (Account rec : records) {

               if(rec.BLN_IsLegacySystemAccount__c == false && recMap.containsKey(rec.Id)){
                 accMap.put(rec.Id,recMap.get(rec.Id));
           }
       }  
    }
    catch (Exception ex) {BLN_ExceptionLogger.captureException(ex);}
    return accMap ; 
}    

       


    /**
*@description:This method used to check Account is Person Account or not.
*@return Boolean
*/
    Boolean isAccountPerson(List<SObject> records) {
        try{
        for (SObject record : records) {
            if (record instanceof Account) {
                Account acc = (Account) record;
                if (acc.IsPersonAccount) {
                    return true;
                }
            }
        }
    }catch (Exception ex) {BLN_ExceptionLogger.captureException(ex);}
        return false;
    }
    Boolean isSalesAccount(List<SObject> records) {
        try{
      Set<Id> salesRecordTypeIds = new Set<Id>();
       List<recordType> salesRecordTypes = [select Id from recordType where developerName = 'BLN_ReferralPartner' OR developerName = 'BLN_CustomerB2BAccount' OR developerName = 'BLN_Competitor' OR developerName = 'BLN_CustomerB2BAccount'  WITH SECURITY_ENFORCED];
       for(recordType rectype :salesRecordTypes){
        salesRecordTypeIds.add(rectype.Id);
       }
        for (SObject record : records) {
            if (record instanceof Account) {
                Account acc = (Account) record;
                if (salesRecordTypeIds.contains(acc.RecordTypeId)) {
                    return true;
                }
            }
        }
    }
     catch (Exception ex) {BLN_ExceptionLogger.captureException(ex);}
        return false;
    }


}