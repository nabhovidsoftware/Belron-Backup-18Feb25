public class LAD_IsInvoicedUpdate {
	@invocableMethod(label='Update LAD_Amount_Not_Invoiced__c ')
    
    public static void updateAmountNotInvoiced(List<inputVariables> inputVariable){
        
        string accountId=inputVariable.get(0).accountId;
     AggregateResult[] groupedResults= [select sum(TotalAmtWithTax) from orderitemsummary where LAD_Is_Invoiced__c=false and OrderSummary.accountid=:accountId and (LAD_Status__c !='Cancelled' or LAD_Status__c!='Closed' ) ];
        
        Account updateAccount=new Account();
        updateAccount.id=accountId;
        updateAccount.LAD_Amount_Not_Invoiced__c  =(decimal)groupedResults[0].get('expr0');
        update updateAccount;
    }
    
    public class inputVariables{
        @invocableVariable
        public string accountId;
    }
}