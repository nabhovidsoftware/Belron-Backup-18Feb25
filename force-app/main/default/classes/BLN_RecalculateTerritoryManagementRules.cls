/*****************************************
*ClassName : BLN_RecalculateTerritoryManagementRules
*@description : FOUK-4467 This  class is used in Record Trigger Flow.
*CreatedDate: 14-12-2023
*CreatedBy : PwC-India
****************************************/
public  with sharing class BLN_RecalculateTerritoryManagementRules {
    /*MethodName : handleAccountsForTerritoryManagement
    *@description : This method is used to recieve accounts from record Trigger flow and run a Queueable class (Asynchrounous Process)
    *@return:void
    *@param List<String>
    *Output Parameter : 
    *CreatedDate: 14-12-2023
    *CreatedBy : Pwc-India
    *Change log :
    ****************************************/
    @InvocableMethod(label='runTerritoryManagementRules')
    public static void handleAccountsForTerritoryManagement(List<String> accountList){
        try{
            if(!accountList.isEmpty()){

                BLN_RunTerritoryRulesQueueable territoryRulesJob = new BLN_RunTerritoryRulesQueueable();
                territoryRulesJob.accountIds = accountList;
                System.enqueueJob(territoryRulesJob);
            }
        }
        catch(Exception ex){
            BLN_ExceptionLogger.captureException(ex); 
        }  
    }
    
}