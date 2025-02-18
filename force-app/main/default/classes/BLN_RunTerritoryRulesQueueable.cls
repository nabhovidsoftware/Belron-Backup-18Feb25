/*****************************************
*ClassName : BLN_RunTerritoryRules
*@description : FOUK-4467 This  class is used to recalculate territory management rules on account  .
*CreatedDate: 14-12-2023
*CreatedBy : PwC-India
****************************************/
public with sharing  class  BLN_RunTerritoryRulesQueueable implements Queueable, Database.AllowsCallouts  {
        /*MethodName : execute
*@description : This method is used for callout to salesforce for recalculate territory rules 
*@return void
*@param Queueable Context
*Output Parameter : 
*CreatedDate: 14-12-2023
*CreatedBy : Pwc-India
*Change log :
****************************************/
    public List<String>  accountIds = null;
    public String sessionId = BLN_SessionIdController.getSessionId(page.BLN_SessionIdVfPage);
    
    public void execute(QueueableContext context) {
        try{
            
            List<String> accountIdsList = new List<String>();
            String accountTag = BLN_AppConstants.territoryRulesInstance.accountTag; 
            String requestTemplate = BLN_AppConstants.territoryRulesInstance.requestTemplate;
            Map<String,String> headerMap = new Map<String,String>();

            if(accountIds != null){
                for(String accountId : accountIds){
                    accountIdsList.add(accountTag.replace('{ACCID}', accountId)); 
                }
            }            
            requestTemplate = requestTemplate.replace('{ACCLISTS}', String.join(accountIdsList, ' '));
            requestTemplate = requestTemplate.replace('{SESSID}', sessionId); 
            headerMap.put(BLN_AppConstants.territoryRulesInstance.contentTypeKey, BLN_AppConstants.territoryRulesInstance.contentTypeValue);
            headerMap.put(BLN_AppConstants.territoryRulesInstance.soapActionKey, BLN_AppConstants.territoryRulesInstance.soapActionValue);
            HttpResponse response =  BLN_HttpCalloutUtility.makeCallout('',BLN_AppConstants.territoryRulesInstance.endpoint,BLN_AppConstants.HTTPMETHODTYPEPOST,headerMap,'',requestTemplate);
        
        }
        catch(Exception ex){
            BLN_ExceptionLogger.captureException(ex); 
        } 
    }  
}