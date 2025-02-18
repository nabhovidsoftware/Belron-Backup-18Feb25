/** @description :  This apex class is used to delete Financial Document records based on the time limit set by the user.
*   @Story :        FOUK-8908; FOUK-10157; FOUK-8956
*   @author:        (binayak.debnath@pwc.com(IN)) (hrithas.sardar@pwc.com (IN))
*   @CreatedDate:   23-09-2024
*/

public with sharing class LAD_InvoiceHandler {
    
    /**@MethodName :    fetchVFBaseURL
    * @description :    Returns base VF Page url for the org.
    * @param:           
    * @return:          String
    */
    @AuraEnabled 
    public static String fetchVFBaseURL(){
        return 'https://' + DomainCreator.getVisualforceHostname(null);
    }

    /**@MethodName :    invokeFinancialDocumentBatch
    * @description :    This method when invoked by a scheduled flow runs to delete Financial Document records based on the time limit set by the user.
    * @param:           
    * @return:          void
    * story:            FOUK-8956
    */
    @InvocableMethod
    public static void invokeDeleteFinancialDocumentBatch(){
        try {
            LAD_DeleteFinancialDocumentsBatch batch = new LAD_DeleteFinancialDocumentsBatch();
            Database.executeBatch(batch, 200);
        } catch (Exception e) {
            BLN_ExceptionLogger.captureException(e);
        }
    }

    /**@MethodName :    invoiceBannerCheck
    * @description :    This method is used to return the colour of the Payment Reminder Banner to be displayed based on Invoice data for the Account.
    * @param:           String accountId
    * @return:          string
    * story:            FOUK-10157
    */
    @AuraEnabled
    public static string invoiceBannerCheck(String accountId){
        try {
            String color;
            Date sevenDaysFromToday = Date.today().addDays(7);
            Date today = Date.today();
            List<LAD_Financial_Document__c> fin = new List<LAD_Financial_Document__c>();
            fin = [SELECT Id, LAD_Due_Date__c FROM LAD_Financial_Document__c WHERE LAD_Type__c = 'Invoice' AND LAD_Status__c = 'Open' AND LAD_Account__c = :accountId AND LAD_Due_Date__c <= :today LIMIT 1];
            if(fin.size() != 0){
                return fin[0].LAD_Due_Date__c == today ? 'Orange' : 'Red';
            }

            fin = [SELECT Id, LAD_Due_Date__c FROM LAD_Financial_Document__c WHERE LAD_Type__c = 'Invoice' AND LAD_Status__c = 'Open' AND LAD_Account__c = :accountId AND LAD_Due_Date__c <= :sevenDaysFromToday LIMIT 1];
            if(fin.size() != 0){
                return 'Blue';
            }
            return null;
    
        } catch (Exception e) {
            BLN_ExceptionLogger.captureException(e);
            return null;        
        }
    }


    public class FinancialDocInputWrapper{
        @AuraEnabled public String accountId{get; set;}
        @AuraEnabled public String issuedStartDate{get; set;}
        @AuraEnabled public String issuedEndDate{get; set;}
        @AuraEnabled public String dueStartDate{get; set;}
        @AuraEnabled public String dueEndDate{get; set;}
        @AuraEnabled public String searchMode{get; set;}
        @AuraEnabled public String documentNumber{get; set;}
        @AuraEnabled public String orderNumber{get; set;}

    }

    public class FinancialDocOutputWrapper{
        @AuraEnabled public String FinDocId;
        @AuraEnabled public String DocumentNumber;
        @AuraEnabled public String Type;
        @AuraEnabled public String CreatedDate;
        @AuraEnabled public String OrderNumber;
        @AuraEnabled public String OrderPONumber;
        @AuraEnabled public String PaymentId;
        @AuraEnabled public String TotalAmount;
        @AuraEnabled public String RemainingAmount;
        @AuraEnabled public String RemainingAmountValue;
        @AuraEnabled public String CurrencyIsoCode;
        @AuraEnabled public String DueDate;
        @AuraEnabled public String PaymentStatus;
        @AuraEnabled public String pdfURL;
        @AuraEnabled public Boolean disablePayNow;
        @AuraEnabled public Boolean disableDownloadPDF;
        @AuraEnabled public Boolean disableCheckbox;
        @AuraEnabled public Boolean disablePaymentTooltip;
        @AuraEnabled public Boolean disablePoTooltip;
        @AuraEnabled public String PaymentIdTooltip;
        @AuraEnabled public String OrderPoNumberToolTip;

    }

    /**@MethodName :    fetchFinancialDocuments
    * @description :    This method is used to return Financial Document data in a formatted manner to display in the Invoice Summary Page.
    * @param:           FinancialDocInputWrapper parameters
    * @return:          List<FinancialDocOutputWrapper>
    * story:            FOUK-8908
    */
    @AuraEnabled
    public static List<FinancialDocOutputWrapper> fetchFinancialDocuments(FinancialDocInputWrapper parameters){
        List<FinancialDocOutputWrapper> returnWrapper = new List<FinancialDocOutputWrapper>(); 
        Set<String> orderSummaryIdSet = new Set<String>();
        Set<String> returnIdSet = new Set<String>();
        Set<String> finDocIdSet = new Set<String>();
        Map<String, Set<String>> finDocIdPoNumbersMap = new Map<String, Set<String>>();
        try {
            string accountId = parameters.accountId;
            Date issuedStartDate = parameters.issuedStartDate != null ? Date.valueOf(parameters.issuedStartDate) : null;
            Date issuedEndDate = parameters.issuedEndDate != null  ? Date.valueOf(parameters.issuedEndDate).addDays(1) : null;
            Date dueStartDate = parameters.dueStartDate != null  ? Date.valueOf(parameters.dueStartDate) : null;
            Date dueEndDate = parameters.dueEndDate != null  ? Date.valueOf(parameters.dueEndDate).addDays(1) : null;
            String searchMode = parameters.searchMode;
            String documentNumber = parameters.documentNumber;
            String orderNumber = parameters.orderNumber;
            String issueFilter = issuedStartDate != null && issuedEndDate != null ? 'AND CreatedDate >=:issuedStartDate AND CreatedDate <=:issuedEndDate ' : '';
            String dueFilter = dueStartDate != null && dueEndDate != null ? 'AND LAD_Due_Date__c >=:dueStartDate AND LAD_Due_Date__c <=:dueEndDate ' : '';

            String query = 'SELECT  Id, ' +
                                    'LAD_Document_Number__c, ' +
                                    'LAD_Type__c, ' +
                                    'LAD_Status__c, ' +
                                    'CreatedDate, ' +
                                    'LAD_Order_Summary__c, ' +
                                    'LAD_Order_Summary__r.OrderNumber, ' +
                                    'LAD_Order_Summary__r.PoNumber, ' +
                                    'LAD_Return_Order__c, ' +
                                    'LAD_Return_Order__r.LAD_Original_Order_Summary__r.PoNumber, ' +
                                    'LAD_Return_Order__r.LAD_Original_Order_Summary__r.OrderNumber, ' +
                                    'CurrencyIsoCode, ' +
                                    'LAD_Total_Amount__c, ' +
                                    'LAD_Remaining_Amount__c, ' +
                                    'LAD_Due_Date__c, ' +
                                    'LAD_Document_URL__c, ' +
                                    'LAD_Account__c, ' +
                                    '(SELECT LAD_Payment__r.BLN_PmtReferenceId__c FROM Financial_Document_Payments__r) ' +
                            'FROM LAD_Financial_Document__c ' +
                            'WHERE LAD_Account__c = :accountId ' +
                            issueFilter + dueFilter +
                            'ORDER BY CreatedDate DESC LIMIT 500 ';
            List<LAD_Financial_Document__c> finDocList = Database.query(query);

            //Create Set of Order Summary Ids and Map of Order Summary Id to Summary PO for Invoices
            //Create Set of Return Ids for Credit Notes
            for(LAD_Financial_Document__c fin: finDocList){
                if(fin.LAD_Order_Summary__c != null && fin.LAD_Order_Summary__r.PoNumber != null){
                    finDocIdPoNumbersMap.put(fin.Id, new Set<String>{fin.LAD_Order_Summary__r.PoNumber});
                }
                else if(fin.LAD_Return_Order__c != null && fin.LAD_Return_Order__r.LAD_Original_Order_Summary__r.PoNumber != null){
                    finDocIdPoNumbersMap.put(fin.Id, new Set<String>{fin.LAD_Return_Order__r.LAD_Original_Order_Summary__r.PoNumber});
                }
                orderSummaryIdSet.add(fin.LAD_Order_Summary__c);
                returnIdSet.add(fin.LAD_Return_Order__c);
                finDocIdSet.add(fin.Id);
            }

            //Fetch all Order Item Summaries for Order Summaries and add to Map
            for(OrderItemSummary itemSum : [SELECT Id, LAD_PO_Number__c, OrderSummaryId, LAD_Invoice__c FROM OrderItemSummary WHERE OrderSummaryId IN :orderSummaryIdSet AND LAD_Invoice__c IN :finDocIdSet]){
                if(finDocIdPoNumbersMap.keySet().contains(itemSum.LAD_Invoice__c) && itemSum.LAD_PO_Number__c != null){
                    finDocIdPoNumbersMap.get(itemSum.LAD_Invoice__c).add(itemSum.LAD_PO_Number__c);
                }else if(itemSum.LAD_PO_Number__c != null){
                    finDocIdPoNumbersMap.put(itemSum.LAD_Invoice__c, new Set<String>{itemSum.LAD_PO_Number__c});
                }
            }

            for(LAD_Return_Item__c retItem : [  SELECT  LAD_CreditNote__c, LAD_Original_Order_Summary_Product__r.LAD_PO_Number__c
                                                FROM LAD_Return_Item__c
                                                WHERE LAD_Return_Order__c IN :returnIdSet AND LAD_CreditNote__c IN :finDocIdSet]){
                if(finDocIdPoNumbersMap.keySet().contains(retItem.LAD_CreditNote__c) && retItem.LAD_Original_Order_Summary_Product__r.LAD_PO_Number__c != null){
                    finDocIdPoNumbersMap.get(retItem.LAD_CreditNote__c).add(retItem.LAD_Original_Order_Summary_Product__r.LAD_PO_Number__c);
                }else if(retItem.LAD_Original_Order_Summary_Product__r.LAD_PO_Number__c != null){
                    finDocIdPoNumbersMap.put(retItem.LAD_CreditNote__c, new Set<String>{retItem.LAD_Original_Order_Summary_Product__r.LAD_PO_Number__c});
                }                                            
            }

            system.debug(finDocIdPoNumbersMap);

            for(LAD_Financial_Document__c fin : finDocList){
                FinancialDocOutputWrapper finItem = new FinancialDocOutputWrapper();
                finItem.FinDocId = fin.Id;
                finItem.DocumentNumber = fin.LAD_Document_Number__c;
                finItem.Type = fin.LAD_Type__c;
                finItem.CreatedDate = String.valueOf(fin.CreatedDate).substring(0, 10); 
                finItem.OrderNumber = fin.LAD_Order_Summary__r.OrderNumber; //Handle for Credit Note
                //finItem.OrderPONumber = fin.LAD_Order_Summary__r.PoNumber;
                //finItem.PaymentId = fin.;
                finItem.TotalAmount = LAD_checkoutPageController.returnSymbol(fin.CurrencyIsoCode) + fin.LAD_Total_Amount__c;
                finItem.RemainingAmount = LAD_checkoutPageController.returnSymbol(fin.CurrencyIsoCode) + String.valueOf(fin.LAD_Remaining_Amount__c);
                finItem.RemainingAmountValue = String.valueOf(fin.LAD_Remaining_Amount__c);
                finItem.CurrencyIsoCode = fin.CurrencyIsoCode;
                finItem.DueDate = String.valueOf(fin.LAD_Due_Date__c).substring(0, 10);
                finItem.PaymentStatus = Date.today() > fin.LAD_Due_Date__c && fin.LAD_Status__c == 'Open' && fin.LAD_Type__c == 'Invoice' ? 'Overdue' : fin.LAD_Status__c;
                finItem.pdfURL = String.isBlank(fin.LAD_Document_URL__c) ? '' : fin.LAD_Document_URL__c;
                finItem.disablePayNow = fin.LAD_Status__c == 'Closed' ? true : false;
                finItem.disableDownloadPDF = String.isBlank(fin.LAD_Document_URL__c) ? true : false;
                finItem.disableCheckbox = fin.LAD_Status__c == 'Closed' ? true : false;
                finItem.disablePaymentTooltip = (fin.Financial_Document_Payments__r).size() > 1 ? false : true;
                finItem.disablePoTooltip = finDocIdPoNumbersMap.containsKey(fin.Id) && (finDocIdPoNumbersMap.get(fin.Id)).size() > 1 ? false : true;
                if(finDocIdPoNumbersMap.containsKey(fin.Id)){
                    List<String> orderSummaryItemPONumberList = new List<String>(finDocIdPoNumbersMap.get(fin.Id));
                    finItem.OrderPONumber = orderSummaryItemPONumberList[0];
                    finItem.OrderPoNumberToolTip = (String.valueOf(orderSummaryItemPONumberList)).replace('{', '').replace('}', '').replace('(', '').replace(')', '');
                }
                finItem.PaymentId = (fin.Financial_Document_Payments__r).size() > 0 ? fin.Financial_Document_Payments__r[0].LAD_Payment__r.BLN_PmtReferenceId__c : '';
                if(finItem.disablePaymentTooltip){
                    finItem.PaymentIdTooltip = finItem.PaymentId;
                }
                else{
                    Set<String> paymentIdSet = new Set<String>();
                    for(LAD_Financial_Document_Payment__c fdp : fin.Financial_Document_Payments__r){
                        paymentIdSet.add(fdp.LAD_Payment__r.BLN_PmtReferenceId__c);
                    }
                    paymentIdSet.remove(null);
                    finItem.PaymentIdTooltip = String.valueOf(paymentIdSet).replace('{', '').replace('}', '').replace('(', '').replace(')', '');
                }
                
                returnWrapper.add(finItem);
            }
            system.debug(returnWrapper);
            return returnWrapper;
        } catch (Exception e) {
            BLN_ExceptionLogger.captureException(e);
            return null;
        }
    }

}