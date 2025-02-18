/**@description : This Apex class used to break the records into batches and enqueue the job.
*  @author: PwC India
*  @Story: FOUK-5167
*  @CreatedDate: 24/06/2024
*/
public class BLN_QueueMDMGateWay extends BLN_MDMCalloutSetup implements  Database.Batchable<String>  {

    string fieldsJson{get;set;}
    BLN_MDMConfiguration.MDMParameters mdmParameter{get;set;}
    
    /**
    *@description:This is a constructor.
    *@return 
    */
    public BLN_QueueMDMGateWay(BLN_MDMConfiguration.MDMParameters parameters){
        this.mdmParameter=parameters;
    }
    
public List<String>  start(Database.BatchableContext bc){
    
    Map<String, Map<String, String>> fieldsToSyncMap = (Map<String, Map<String, String>>) mdmParameter.fieldsToSync;
    return new List<String>(fieldsToSyncMap.keySet());
} 

    /**
    *@description:This method is used to break the records into batches to avoid limit exception.
    *@return void
    */
public void execute(Database.BatchableContext bc, List<string> recordIds) {
    
    try{
        BLN_MDMConfiguration.MDMParameters upParam=new BLN_MDMConfiguration.MDMParameters();
        //5167 started
        Map<String, Map<String, String>> fieldsToSyncMap = (Map<String, Map<String, String>>) mdmParameter.fieldsToSync;
        List<Map<String, String>> currentBatch = new List<Map<String, String>>();
        if(mdmParameter.streamName == System.label.BLN_ServiceStream){
            //initalizeSetup();
            string objectName=mdmParameter.sourceObject;
            list<sobject> lstMDMMetaConfig=getMDMFieldMapping(objectName);
            Map<string,Map<string,string>> mpFieldsToSync=(Map<string,Map<string,string>>)mdmParameter.fieldsToSync;

           
           
                for (String recordId : recordIds) {
                    Map<string,string> mpChangedField=mpFieldsToSync.get(recordId);
                    fieldsJson=getJsonBodyByMDMMapping(mpChangedField,lstMDMMetaConfig);
                    if(!string.isempty(fieldsJson)){
                    Map<String, String> fieldsMap = fieldsToSyncMap.get(recordId);
                    currentBatch.add(fieldsMap);
                    upParam.streamName = mdmParameter.streamName;
                    upParam.sourceObject = mdmParameter.sourceObject;
                    upParam.fieldsToSync = JSON.serialize(currentBatch);
                    upParam.accountId = recordId;
                    ///5167 ended
                   // upParam=mdmParameter;
                    upParam.fieldsToSyncDataType='STRING';
                    upParam.eventType = mdmParameter.eventType;
                   enqueueJob(upParam);
                //HTTP callout //break here
               // BLN_QueueMDMCallout mdmGateway=new BLN_QueueMDMCallout(fieldsJson,upParam); 
              //  System.enqueueJob(mdmGateway);
                currentBatch.clear();  // 5167
            }
            }
           
            //initalizeSetup();
        }
        else if(mdmParameter.streamName == System.label.BLN_SalesStream) {
            for (String recordId : recordIds) {
                Map<String, String> fieldsMap = fieldsToSyncMap.get(recordId);
                currentBatch.add(fieldsMap);
                upParam.streamName = mdmParameter.streamName;
                upParam.sourceObject = mdmParameter.sourceObject;
                upParam.fieldsToSync = JSON.serialize(currentBatch);
                if((mdmParameter.sourceObject == 'Contact' || mdmParameter.sourceObject == 'BLN_AccountRuleParameter__c' || mdmParameter.sourceObject == 'BLN_AccountGroupRule__c' || mdmParameter.sourceObject == 'BLN_PDSCode__c' || mdmParameter.sourceObject == 'BLN_AccountAlternativeName__c' || mdmParameter.sourceObject == 'BLN_SLADefinition__c') && fieldsMap.get('accountId') == null){
                    continue;
                 }
                 
                 else if (mdmParameter.sourceObject == 'Contact' || mdmParameter.sourceObject == 'BLN_AccountRuleParameter__c' || mdmParameter.sourceObject == 'BLN_AccountGroupRule__c' || mdmParameter.sourceObject == 'BLN_PDSCode__c' || mdmParameter.sourceObject == 'BLN_AccountAlternativeName__c' || mdmParameter.sourceObject == 'BLN_SLADefinition__c'){
                     upParam.accountId = fieldsMap.get('accountId');
                 }
                else{
                    upParam.accountId = recordId;
                }
                upParam.accountName = fieldsMap.get('Name');
                if(fieldsMap.containsKey('BLN_MDMAccountID__c')){
                    upParam.mdmAccountId = fieldsMap.get('BLN_MDMAccountID__c');
                }
                upParam.fieldsToSyncDataType='STRING';
                upParam.eventType = mdmParameter.eventType;
                enqueueJob(upParam);
                currentBatch.clear(); 
            }
        }
     
        
                
        }catch(exception ex){
            BLN_ExceptionLogger.captureException(ex);
        }
    } 
    
public void finish(Database.BatchableContext bc){
    AsyncApexJob asyncJobId = [SELECT Id,Status,NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :bc.getJobId()];
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    String[] toAddresses = new String[] {asyncJobId.CreatedBy.Email};
    mail.setToAddresses(toAddresses);
    mail.setSubject('Apex Sharing Recalculation ' + asyncJobId.Status);
    mail.setPlainTextBody
    ('The batch Apex job processed ' + asyncJobId.TotalJobItems +
    ' batches with '+ asyncJobId.NumberOfErrors + ' failures.');
  // Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

    //System.debug('AsyncJobId--> '+asyncJobId);
}

    /**
    *@description:This method is used to send json based on changed field.
    *@return void
    */
// void initalizeSetup(){
//     string objectName=mdmParameter.sourceObject;
//     list<sobject> lstMDMMetaConfig=getMDMFieldMapping(objectName);
//     system.debug('lstMDMMetaConfig321'+lstMDMMetaConfig );
//     Map<string,Map<string,string>> mpFieldsToSync=(Map<string,Map<string,string>>)mdmParameter.fieldsToSync;
//     system.debug('mpFieldsToSync321'+mpFieldsToSync );
//     Map<string,string> mpChangedField=mpFieldsToSync.values()[0];
//     system.debug('mpChangedField'+mpFieldsToSync );
//     fieldsJson=getJsonBodyByMDMMapping(mpChangedField,lstMDMMetaConfig);
// }
    
    /**
    *@description:This method is used to enequeu job.
    *@return void
    */
    public  void enqueueJob(BLN_MDMConfiguration.MDMParameters upParam) {
  

        BLN_QueueMDMCallout mdmGateway = new BLN_QueueMDMCallout(fieldsJson, upParam);
        System.enqueueJob(mdmGateway);
    }
    }