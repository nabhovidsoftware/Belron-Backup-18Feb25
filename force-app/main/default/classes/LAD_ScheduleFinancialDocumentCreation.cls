/* description:     This apex class is used to schedule LAD_InvoiceCreationBatch batch class for creation of Invoices and 
                    schedule the LAD_CreditNoteCreationBatch for creation of Credit Notes.
   author:          (binayak.debnath@pwc.com (IN))
   Story:           FOUK-10522; FOUK-10582
*/
public class LAD_ScheduleFinancialDocumentCreation implements Schedulable{
    //creat schedule
    public void execute(SchedulableContext context){
        if(([SELECT OrderSummaryId FROM OrderItemSummary WHERE LAD_Status__c = 'Shipped' AND LAD_Invoice__c = null LIMIT 1]).size() != 0){
            Database.executeBatch(new LAD_InvoiceCreationBatch(), 200);
        }

        if(([SELECT LAD_Return_Order__c FROM LAD_Return_Item__c WHERE LAD_Status__c = 'Return Accepted' AND LAD_CreditNote__c = null LIMIT 1]).size() != 0){
            Database.executeBatch(new LAD_CreditNoteCreationBatch(), 200);
        }
    }
}