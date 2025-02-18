/* description :   This apex class is used to create Invoices for Shipped Order Item Summaries grouped by Order Summary
   author:         (binayak.debnath@pwc.com (IN))
   Story:          FOUK-10522
*/

public class LAD_InvoiceCreationBatch implements Database.Batchable<SObject>, Database.Stateful{

    // Start method to define the query to retrieve records
    public Database.QueryLocator start(Database.BatchableContext BC) {
        // Create a set of Order Summary Ids for all Order Item Summaries with Status 'Shipped' and Invoice at null
        Set<String> orderSummaryIds = new Set<String>();
        for(OrderItemSummary item: [SELECT OrderSummaryId FROM OrderItemSummary WHERE LAD_Status__c = 'Shipped' AND LAD_Invoice__c = null]){
            orderSummaryIds.add(item.OrderSummaryId);
        }

        //Query String for all records grouped by Order Summary
        String query =  'SELECT Id, ' + 
                                'AccountId, ' +
                                'Account.BLN_PaymentTerms__c, ' + 
                                'CurrencyIsoCode, ' +
                                '(SELECT Id, ' + 
                                    'Name, ' + 
                                    'LAD_Invoice__c, ' + 
                                    'LAD_Status__c, ' + 
                                    'AdjustedLineAmtWithTax, ' + 
                                    'OrderSummaryId ' + 
                                'FROM OrderItemSummaries ' + 
                                'WHERE LAD_Status__c = \'Shipped\' AND LAD_Invoice__c = null) ' + 
                        'FROM OrderSummary ' + 
                        'WHERE Id IN :orderSummaryIds';
        System.debug(query);   
        return Database.getQueryLocator(query);
    }

    // Execute method to process each batch of records
    public void execute(Database.BatchableContext BC, List<OrderSummary> orderSummaries) {
        try {
            Map<String, LAD_Financial_Document__c> orderSummaryIdInvoiceMap = new Map<String, LAD_Financial_Document__c>();
            List<LAD_Financial_Document__c> insertInvoiceList = new List<LAD_Financial_Document__c>();
            List<OrderItemSummary> updateItemSummaryList = new List<OrderItemSummary>();
            for(OrderSummary sum : orderSummaries){
                LAD_Financial_Document__c fin = new LAD_Financial_Document__c();
                fin.LAD_Type__c = 'Invoice';
                fin.LAD_Account__c = sum.AccountId;
                fin.LAD_Order_Summary__c = sum.Id;
                fin.CurrencyIsoCode = sum.CurrencyIsoCode;
                fin.LAD_Status__c = 'Open';
                fin.LAD_Total_Amount__c = 0;

                for(OrderItemSummary item : sum.OrderItemSummaries){
                    fin.LAD_Total_Amount__c += item.AdjustedLineAmtWithTax;
                }

                Date today = Date.today();
                Date firstOf30Month = today.toStartOfMonth().addMonths(1);
                Date firstOf60Month = firstOf30Month.addMonths(1);
                system.debug(sum.Account.BLN_PaymentTerms__c);

                if(sum.Account.BLN_PaymentTerms__c == '30 END OF MONTH') {
                    fin.LAD_Due_Date__c = Date.daysInMonth(firstOf30Month.year(), firstOf30Month.month()) >= 30 ? firstOf30Month.addDays(29) : firstOf30Month.addDays(Date.daysInMonth(firstOf30Month.year(), firstOf30Month.month()) - 1);
                }
                else if(sum.Account.BLN_PaymentTerms__c == '60 END OF MONTH') {
                    fin.LAD_Due_Date__c = Date.daysInMonth(firstOf60Month.year(), firstOf60Month.month()) >= 30 ? firstOf60Month.addDays(29) : firstOf60Month.addDays(Date.daysInMonth(firstOf60Month.year(), firstOf60Month.month()) - 1);
                }
                else if(sum.Account.BLN_PaymentTerms__c == '5 END OF MONTH') {
                    fin.LAD_Due_Date__c = firstOf30Month.addDays(4);
                }

                fin.LAD_Remaining_Amount__c = fin.LAD_Total_Amount__c;
                orderSummaryIdInvoiceMap.put(sum.Id, fin);
                insertInvoiceList.add(fin);
            }

            if(insertInvoiceList.size() > 0){
                insert insertInvoiceList;
            }

            for(OrderSummary sum : orderSummaries){
                for(OrderItemSummary item : sum.OrderItemSummaries){
                    item.LAD_Invoice__c = orderSummaryIdInvoiceMap.get(sum.Id).Id;
                }
                updateItemSummaryList.addAll(sum.OrderItemSummaries);
            }

            update updateItemSummaryList;
        } catch (Exception e) {
            // Handle any exceptions
            BLN_ExceptionLogger.captureException(e);
            System.debug('Exception: ' + e.getMessage());
        }
    }

    // Finish method
    public void finish(Database.BatchableContext BC) {
        // Any final processing or logging can be done here
        System.debug('Batch process finished.');
    }
}