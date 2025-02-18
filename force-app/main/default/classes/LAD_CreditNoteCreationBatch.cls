/* description :   This apex class is used to create Credit Notes for Return Accepted Return Items grouped by Return records
   author:         (binayak.debnath@pwc.com (IN))
   Story:          FOUK-10582
*/

public class LAD_CreditNoteCreationBatch implements Database.Batchable<SObject>, Database.Stateful{

    // Start method to define the query to retrieve records
    public Database.QueryLocator start(Database.BatchableContext BC) {
        // Create a set of Return Ids for all Return Items with Status 'Return Accepted' and Credit Note at null
        Set<String> returnIds = new Set<String>();
        for(LAD_Return_Item__c item: [SELECT LAD_Return_Order__c FROM LAD_Return_Item__c WHERE LAD_Status__c = 'Return Accepted' AND LAD_CreditNote__c = null]){
            returnIds.add(item.LAD_Return_Order__c);
        }

        //Query String for all records grouped by Order Summary
        String query =  'SELECT Id, ' + 
                                'LAD_Account__c	, ' +
                                'LAD_Account__r.BLN_PaymentTerms__c, ' + 
                                'CurrencyIsoCode, ' +
                                'LAD_Original_Order_Summary__c, ' +
                                '(SELECT Id, ' + 
                                    'Name, ' + 
                                    'LAD_CreditNote__c, ' + 
                                    'LAD_Status__c, ' + 
                                    'LAD_Original_Order_Summary_Product__r.AdjustedLineAmtWithTax, ' + 
                                    'LAD_Return_Order__c ' + 
                                'FROM Return_Items__r ' + 
                                'WHERE LAD_Status__c = \'Return Accepted\' AND LAD_CreditNote__c = null) ' + 
                        'FROM LAD_Return__c ' + 
                        'WHERE Id IN :returnIds';
        System.debug(query);   
        return Database.getQueryLocator(query);
    }

    // Execute method to process each batch of records
    public void execute(Database.BatchableContext BC, List<LAD_Return__c> returns) {
        try {
            Map<String, LAD_Financial_Document__c> returnIdCreditNoteMap = new Map<String, LAD_Financial_Document__c>();
            List<LAD_Financial_Document__c> insertCreditNoteList = new List<LAD_Financial_Document__c>();
            List<LAD_Return_Item__c> updateReturnItemList = new List<LAD_Return_Item__c>();
            for(LAD_Return__c ret : returns){
                LAD_Financial_Document__c fin = new LAD_Financial_Document__c();
                fin.LAD_Type__c = 'Credit Note';
                fin.LAD_Account__c = ret.LAD_Account__c;
                fin.LAD_Order_Summary__c = ret.LAD_Original_Order_Summary__c;
                fin.LAD_Return_Order__c = ret.Id;
                fin.CurrencyIsoCode = ret.CurrencyIsoCode;
                fin.LAD_Status__c = 'Open';
                fin.LAD_Total_Amount__c = 0;

                for(LAD_Return_Item__c item : ret.Return_Items__r){
                    fin.LAD_Total_Amount__c -= item.LAD_Original_Order_Summary_Product__r.AdjustedLineAmtWithTax;
                }

                Date today = Date.today();
                Date firstOf30Month = today.toStartOfMonth().addMonths(1);
                Date firstOf60Month = firstOf30Month.addMonths(1);
                system.debug(ret.LAD_Account__r.BLN_PaymentTerms__c);

                if(ret.LAD_Account__r.BLN_PaymentTerms__c == '30 END OF MONTH') {
                    fin.LAD_Due_Date__c = Date.daysInMonth(firstOf30Month.year(), firstOf30Month.month()) >= 30 ? firstOf30Month.addDays(29) : firstOf30Month.addDays(Date.daysInMonth(firstOf30Month.year(), firstOf30Month.month()) - 1);
                }
                else if(ret.LAD_Account__r.BLN_PaymentTerms__c == '60 END OF MONTH') {
                    fin.LAD_Due_Date__c = Date.daysInMonth(firstOf60Month.year(), firstOf60Month.month()) >= 30 ? firstOf60Month.addDays(29) : firstOf60Month.addDays(Date.daysInMonth(firstOf60Month.year(), firstOf60Month.month()) - 1);
                }
                else if(ret.LAD_Account__r.BLN_PaymentTerms__c == '5 END OF MONTH') {
                    fin.LAD_Due_Date__c = firstOf30Month.addDays(4);
                }

                fin.LAD_Remaining_Amount__c = fin.LAD_Total_Amount__c;
                returnIdCreditNoteMap.put(ret.Id, fin);
                insertCreditNoteList.add(fin);
            }

            if(insertCreditNoteList.size() > 0){
                insert insertCreditNoteList;
            }

            for(LAD_Return__c ret : returns){
                for(LAD_Return_Item__c item : ret.Return_Items__r){
                    item.LAD_CreditNote__c = returnIdCreditNoteMap.get(ret.Id).Id;
                }
                updateReturnItemList.addAll(ret.Return_Items__r);
            }

            update updateReturnItemList;
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