/** @description :  This apex class is used to handle all Quote related functionality
*   @Story :        FOUK-9920; FOUK-9922; FOUK-9923; FOUK-9925
*   @author:        (binayak.debnath@pwc.com (IN) & ashwin.r.raja@pwc.com (IN))
*   @CreatedDate:   27-08-2024
*/

public with sharing class LAD_QuoteHandler {

    /**@MethodName :    createQuoteAndQuoteItems
    * @description :    This method is used to create Quote and Quote Item records.
    * @param:           Map<String, String> replacementMap
    * @return:          string
    */
    @auraenabled
    public static Map<String, String> createQuoteAndQuoteItems(QuoteDetailWrapper quoteDetails){
        Map<String, String> returnMap = new Map<String, String>();
        List<LAD_Quote_Item__c> quoteItemList = new List<LAD_Quote_Item__c>();

        try {  
            String contactId = [SELECT ContactId FROM User WHERE Id = :quoteDetails.userId].ContactId;

            LAD_Quote__c currentQuote = new LAD_Quote__c(LAD_Account__c = quoteDetails.effectiveAccountId,
                                                        LAD_Contact__c = contactId);
            insert currentQuote;


            for(QuoteItemWrapper item : quoteDetails.quoteItems){
                LAD_Quote_Item__c currItem = new LAD_Quote_Item__c();
                currItem.LAD_Quote__c = currentQuote.Id;
                currItem.LAD_Product__c = item.ProductId;
                currItem.LAD_Price__c = Double.valueOf(item.Price);
                currItem.LAD_Quantity__c = Double.valueOf(item.Quantity);
                quoteItemList.add(currItem);
            }

            insert quoteItemList;
            
            returnMap.put('Success' , currentQuote.Id);
        } catch (Exception e) {
            returnMap.put('Error', 'Unable to create quotes: ' + e.getLineNumber() + '; ' + e.getMessage());
        }

        return returnMap; 
    }


    /**@MethodName :    generateQuoteDoc
    * @description :    This method is used to generate excel string replaced with Quote Details from LWC and excel template from Static Resource.
    * @param:           Map<String, String> replacementMap
    * @return:          string
    */
    @auraenabled
    public static string generateQuoteDoc(Map<String, String> replacementMap){

        try {
            // Load the Excel template from static resource
            StaticResource sr = [SELECT Body FROM StaticResource WHERE Name = 'LAD_QuoteDocTemplate'];
            Blob templateBlob = sr.Body;

            // Unzip the template (XLSX file is a zipped archive)
            LAD_Zippex sampleZip = new LAD_Zippex(templateBlob);

            // Iterate through the files in the zip
            String fileName = 'xl/sharedStrings.xml';
            Blob fileBlob = sampleZip.getFile(fileName);
            String crc32 = (sampleZip.getFileInfo(fileName)).get('crc32');
                
            // Convert the Blob to a string (XML content)
            String sheetXml = fileBlob.toString();

            // Replace placeholders with actual values
            for (String key : replacementMap.keySet()) {
                sheetXml = sheetXml.replace('${' + key + '}', replacementMap.get(key));
            }


            // Convert the string back to Blob and update the content in the map
            sampleZip.addFile(fileName, Blob.valueOf(sheetXml), crc32);
            

            // Zip the contents back into a Blob
            Blob finalExcelBlob = sampleZip.getZipArchive();
            return EncodingUtil.base64Encode(finalExcelBlob);

        } catch (Exception e) {
            return null;
        }
        
    }


    /**@MethodName :    getQuotes
    * @description :    This method returns Quote details for portal based on account.
    * @param:           String effectiveAccountId
    * @return:          List<LAD_Quote__c>
    */
    @AuraEnabled
    public static List<QuoteWrapper> getQuotes(String effectiveAccountId) {
        List<QuoteWrapper> returnList = new List<QuoteWrapper>();
        try {
            String labelValue = System.Label.LAD_QuoteHandler_ExternalLimit;
            labelValue = labelValue.trim();
            Integer days;

            if(!labelValue.isNumeric() || labelValue.contains('.')){
                days = 30;
            }
            else{
                days = Integer.valueOf(labelValue);
            }
            String soql = 'SELECT Id, LAD_Account__r.Name, Name, LAD_Contact__r.Name, LAD_Total_Price__c, CreatedDate FROM LAD_Quote__c WHERE LAD_Account__c = \'' + effectiveAccountId + '\' AND CreatedDate >= LAST_N_DAYS:'+days+ ' ORDER BY CreatedDate DESC';
            
            List<LAD_Quote__c> quoteList = (List<LAD_Quote__c>) Database.query(soql);

            for(LAD_Quote__c item : quoteList){
                QuoteWrapper wrapperItem = new QuoteWrapper();
                wrapperItem.Id = item.Id;
                wrapperItem.AccountName = item.LAD_Account__r.Name;
                wrapperItem.ContactName = item.LAD_Contact__r.Name;
                wrapperItem.TotalPrice = String.valueOf(item.LAD_Total_Price__c);
                wrapperItem.QuoteNumber = item.Name;
                returnList.add(wrapperItem);
            }
        } catch (Exception e) {
            BLN_ExceptionLogger.captureException(e);
            return null;
        }
        
        return returnList;
    }


    /**@MethodName :    getQuoteDetailsAndItems
    * @description :    This method returns Quote details for Internal Portal User based on Created Date limit.
    * @param:           QuoteDetailWrapper quoteDetails
    * @return:          List<LAD_Quote__c>
    */
    @AuraEnabled
    public static QuoteWrapper getQuoteDetailsAndItems(QuoteDetailWrapper quoteDetails) {
        //String quoteId = quoteDetails.quoteId;
        system.debug('QUOTE DETAILS   ' + quoteDetails);
        QuoteWrapper returnQuote = new QuoteWrapper();
        try {
            LAD_Quote__c quote = [  SELECT  Id,
                                            Name, 
                                            LAD_Account__r.Name, 
                                            LAD_Contact__r.Name, 
                                            LAD_Total_Price__c,
                                            Owner.FirstName,
                                            Owner.LastName,
                                            CreatedDate,
                                            CurrencyIsoCode,
                                            (SELECT LAD_Product__r.ProductCode, LAD_Product__r.Name, LAD_Price__c, LAD_Quantity__c, CurrencyIsoCode 
                                            FROM Quote_Items__r) 
                                    FROM LAD_Quote__c
                                    WHERE Id = :quoteDetails.quoteId ];
            String firstName = quote.Owner.FirstName != null ? quote.Owner.FirstName : '';
            String lastName = quote.Owner.LastName != null ? quote.Owner.LastName : '';
            
            List<LAD_Quote_Item__c> quoteItems = quote.Quote_Items__r;
            List<QuoteItemWrapper> quoteItemsList = new List<QuoteItemWrapper>();

            for(LAD_Quote_Item__c item: quoteItems){
                QuoteItemWrapper itemWrapper = new QuoteItemWrapper();
                itemWrapper.ProductCode = item.LAD_Product__r.ProductCode != 'undefined' && item.LAD_Product__r.ProductCode != null ? item.LAD_Product__r.ProductCode : '';
                itemWrapper.Price = item.CurrencyIsoCode + ' ' + item.LAD_Price__c;
                itemWrapper.ProductName = item.LAD_Product__r.Name != 'undefined' && item.LAD_Product__r.Name != null ? item.LAD_Product__r.Name : '';
                itemWrapper.Quantity = item.LAD_Quantity__c;
                quoteItemsList.add(itemWrapper);
            }

            returnQuote.quoteItems = quoteItemsList;
            returnQuote.QuoteNumber = quote.Name;
            returnQuote.AccountName = quote.LAD_Account__r.Name;
            returnQuote.ContactName = quote.LAD_Contact__r.Name;
            returnQuote.TotalPrice = quote.CurrencyIsoCode + ' ' + String.valueOf(quote.LAD_Total_Price__c);
            returnQuote.OwnerName = firstName + ' ' + lastName;
            returnQuote.CurrencyIsoCode = quote.CurrencyIsoCode;
            returnQuote.CreatedDate = (String.valueOf(quote.CreatedDate)).substring(0, 10);

        } catch (Exception e) {
            BLN_ExceptionLogger.captureException(e);
            returnQuote.Error = e.getCause() + '; ' + e.getLineNumber() + '; ' + e.getMessage();
        }

        return returnQuote;

    }

    /**@MethodName :    invokeDeleteQuoteBatch
    * @description :    This method when invoked by a scheduled flow runs the LAD_DeleteQuoteBatch to delete Quote records based on the time limit set by the user.
    * @param:           
    * @return:          void
    */
    @InvocableMethod
    public static void invokeDeleteQuoteBatch(){
        try {
            LAD_DeleteQuoteBatch batch = new LAD_DeleteQuoteBatch();
            Database.executeBatch(batch, 200);
        } catch (Exception e) {
            BLN_ExceptionLogger.captureException(e);
        }
    }

    //Wrapper Classes
    public class QuoteDetailWrapper{
        @AuraEnabled public String quoteId {get; set;}
        @AuraEnabled public String effectiveAccountId {get; set;}
        @AuraEnabled public String userId {get; set;}
        @AuraEnabled public List<QuoteItemWrapper> quoteItems {get; set;}
    }

    public class QuoteWrapper{
        @auraenabled public List<QuoteItemWrapper> quoteItems;
        @auraenabled public String Id;
        @auraenabled public String QuoteNumber;
        @auraenabled public String AccountName;
        @auraenabled public String ContactName;
        @auraenabled public String TotalPrice;
        @auraenabled public String OwnerName;
        @auraenabled public String CreatedDate;
        @auraenabled public String CurrencyIsoCode;
        @auraenabled public String Error;
    }

    public class QuoteItemWrapper{
        @auraenabled public String ProductCode;
        @auraenabled public String ProductName;
        @auraenabled public String QuoteId;
        @auraenabled public String Price {get; set;}
        @auraenabled public String ProductId {get; set;}
        @auraenabled public Double Quantity {get; set;}
    }
}