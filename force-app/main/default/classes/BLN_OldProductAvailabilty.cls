public without sharing class BLN_OldProductAvailabilty {
    
    /*****************************************
ClassName : BLN_OldProductAvailability
Description : FOUK-3681, 4049 This controller class is used in lwc.
CreatedDate: 24-11-2023
CreatedBy : PwC-India
****************************************/

   /* MethodName : createOrderItems
Description : This method is used to return the response to lwc component.
Input Parameter : null
Output Parameter : DisplayDetailsWrapper
CreatedDate: 24-11-2023
CreatedBy : Pwc-India
Change log :
****************************************/

    //here starts 3114
    @AuraEnabled    
    public static DisplayDetailsWrapper createOrderItems(String payload, Id caseRecordId){
        Case caseRecord = [SELECT Id,AccountId FROM Case WHERE Id = :caseRecordId WITH SECURITY_ENFORCED LIMIT 1];

        BLN_ProductResponseWrapper.ResponseProduct data = (BLN_ProductResponseWrapper.ResponseProduct) System.JSON.deserialize(payload,BLN_ProductResponseWrapper.ResponseProduct.class);

        List<Order> orderList = new List<Order>();
        List<OrderItem> orderItemList = new List<OrderItem>();
        Set<String> commonPartNumbers = new Set<String>();
        Set<String> uncommonPartNumbers = new Set<String>();
        Set<Double> baseListPriceList = new Set<Double>();        
        List<ProductSelectionWrapper> productSelectionDataList = new List<ProductSelectionWrapper>();
        List<BLN_ProductResponseWrapper.ResponseLineItems> vapsList = new List<BLN_ProductResponseWrapper.ResponseLineItems>();
        List<BLN_ProductResponseWrapper.ResponseLineItems> standAloneList = new List<BLN_ProductResponseWrapper.ResponseLineItems>();
        List<BLN_ProductResponseWrapper.ResponseLineItems> remainingList = new List<BLN_ProductResponseWrapper.ResponseLineItems>();
        List<BLN_ProductResponseWrapper.ResponseLineItems> sortedLineItems = new List<BLN_ProductResponseWrapper.ResponseLineItems>();
        List<DisplayQuoteDetailsWrapper> quoteDetailsList = new List<DisplayQuoteDetailsWrapper>();
        List<DiscountBandWrapper> discountBandDetailsList = new List<DiscountBandWrapper>();
        List<AvailibilityDatesWrapper> availibilityDatesList = new List<AvailibilityDatesWrapper>();
        List<InsuranceLiabilityWrapper> liabilityData = new List<InsuranceLiabilityWrapper>();
        InsuranceLiabilityWrapper motoristTotalsLiability = new InsuranceLiabilityWrapper();
        InsuranceLiabilityWrapper insuranceTotalsLiability = new InsuranceLiabilityWrapper();
        InsuranceLiabilityWrapper tradeCompanyTotalsLiability = new InsuranceLiabilityWrapper();
        InsuranceLiabilityWrapper totalLiability = new InsuranceLiabilityWrapper();
        
        Map<OrderItem,String> partNumberMap = new Map<OrderItem,String>();
        Map<String,Product2> productIdVsMDMIdMap = new Map<String,Product2>();
        Map<String,List<OrderItem>> lineItemMap = new Map<String,List<OrderItem>>();
        Map<String,DisplayQuoteDetailsWrapper> guIdVsDisplayDeatilsDataMap = new Map<String,DisplayQuoteDetailsWrapper>();
        Map<BLN_ProductResponseWrapper.ResponseQuotes,List<BLN_ProductResponseWrapper.ResponseLineItems>> quoteVsLineItemMap = new Map<BLN_ProductResponseWrapper.ResponseQuotes,List<BLN_ProductResponseWrapper.ResponseLineItems>>();
        Map<String,BLN_ProductResponseWrapper.ResponseLineItems> partIdVsLineItemMap = new Map<String,BLN_ProductResponseWrapper.ResponseLineItems>();
        Map<String,Order> quoteIdVsOrderMap = new Map<String,Order>();
        Map<String,PricebookEntry> productCodeVsPriceBookEntryMap = new Map<String,PricebookEntry>();
        Map<Order,List<OrderItem>> orderDataMap = new Map<Order,List<OrderItem>>();

        Integer count = 0;
        for(BLN_ProductResponseWrapper.ResponseQuotes quoteVar : data.quotes){
            BLN_ProductResponseWrapper.ResponseQuotes quote = new BLN_ProductResponseWrapper.ResponseQuotes(quoteVar);
            List<BLN_ProductResponseWrapper.ResponseLineItems> lineItemList = new List<BLN_ProductResponseWrapper.ResponseLineItems>();
            DisplayQuoteDetailsWrapper displayDetailsData = new DisplayQuoteDetailsWrapper();
            DiscountBandWrapper discountbandData = new DiscountBandWrapper();
            String earliestDateValue = '';    
            List<List<String>> dtList = new List<List<String>>();
            List<String> sortedList = new List<String>();
            Map<String,List<BLN_ProductResponseWrapper.ResponseAvailabilityDetails>> dateVsAvailibilityDetailsMap = new Map<String,List<BLN_ProductResponseWrapper.ResponseAvailabilityDetails>>();
            AvailibilityDatesWrapper earliestDateSet = new AvailibilityDatesWrapper();
                
            motoristTotalsLiability.liabilityCategory = System.label.BLN_MotoristLiability;
            motoristTotalsLiability.totalPayable = quoteVar.motoristTotals.totalPayableByMotorist;
            motoristTotalsLiability.totalTaxPayable = quoteVar.motoristTotals.totalTaxPayableByMotorist;
            motoristTotalsLiability.totalIncludingTaxPayable += quoteVar.motoristTotals.totalInludingTaxPayableByMotorist;
        
            insuranceTotalsLiability.liabilityCategory = System.label.BLN_InsuranceLiability;
            insuranceTotalsLiability.totalPayable = quoteVar.insuranceTotals.totalPayableByInsurance;
            insuranceTotalsLiability.totalTaxPayable = quoteVar.insuranceTotals.totalTaxPayableByInsurance;
            insuranceTotalsLiability.totalIncludingTaxPayable = quoteVar.insuranceTotals.totalIncludingTaxPayableByInsurance;
            
            tradeCompanyTotalsLiability.liabilityCategory = System.label.BLN_AccountLiability;
            tradeCompanyTotalsLiability.totalPayable = quoteVar.tradeCompanyTotals.totalPayableByTrade;
            tradeCompanyTotalsLiability.totalTaxPayable = quoteVar.tradeCompanyTotals.payableByTradeTotalTax;
            tradeCompanyTotalsLiability.totalIncludingTaxPayable = quoteVar.tradeCompanyTotals.totalPayableByTradeIncludingTax;
            
            quoteIdVsOrderMap.put(quoteVar.quoteId,quote.orderRecord);
            for(BLN_ProductResponseWrapper.ResponseLineItems lineItem : quoteVar.lineItems) {
                List<String> loopDtList = new List<String>();
                baseListPriceList.add(lineItem.baseListPrice);
                lineItemList.add(lineItem);
                partIdVsLineItemMap.put(lineItem.partNumber,lineItem);
                
                for(BLN_ProductResponseWrapper.ResponseAvailabilityDetails availabilityDetail : lineItem.availabilityDetails) {
                    loopDtList.add(availabilityDetail.availableFromDate);
                    dateVsAvailibilityDetailsMap.put(availabilityDetail.availableFromDate,lineItem.availabilityDetails);
                }
                loopDtList.sort();
                dtList.add(loopDtList);
            }   
            for(List<String> innerStrList : dtList ) {
                sortedList.add(innerStrList[0]);
            }        
            sortedList.sort();
            earliestDateValue = sortedList.get(sortedList.size() - 1);

            earliestDateSet.earliestDates = dateVsAvailibilityDetailsMap.get(earliestDateValue);
            earliestDateSet.quoteId = quoteVar.quoteId;
            availibilityDatesList.add(earliestDateSet);
            displayDetailsData.quoteEarliestAppointmentAvailability = displayDetailsData.quoteEarliestAppointmentAvailabilityUnformatted = earliestDateValue;
                    
            displayDetailsData.quotename = quoteVar.quoteId;
            displayDetailsData.quotelocation = quoteVar.locationId;
            displayDetailsData.quoteTotal = quoteVar.quoteTotals.totalIncludingTax;
            displayDetailsData.quoteVAT = quoteVar.quoteTotals.totaltax;
            displayDetailsData.quoteWeatherGuard = String.valueOf(count++);
            quoteDetailsList.add(displayDetailsData);
        
            discountbandData.locationId = quoteVar.locationId;
            discountbandData.discountThresholdA = quoteVar.discountThresholdA;
            discountbandData.discountThresholdB = quoteVar.discountThresholdB;
            discountbandData.discountThresholdC = quoteVar.discountThresholdC;
            discountBandDetailsList.add(discountbandData);

            quoteVsLineItemMap.put(quoteVar,lineItemList);        
            guIdVsDisplayDeatilsDataMap.put(quote.locationId,displayDetailsData);
            partNumberMap.putAll(quote.orderItemWithPartNumberMap);
            orderDataMap.putAll(quote.quoteData);               
        }
		
        totalLiability.liabilityCategory = System.label.BLN_Total;
        totalLiability.totalPayable = motoristTotalsLiability.totalPayable + insuranceTotalsLiability.totalPayable + tradeCompanyTotalsLiability.totalPayable;
        totalLiability.totalTaxPayable  = motoristTotalsLiability.totalTaxPayable + insuranceTotalsLiability.totalTaxPayable + tradeCompanyTotalsLiability.totalTaxPayable;
        totalLiability.totalIncludingTaxPayable = Decimal.valueOf(motoristTotalsLiability.totalIncludingTaxPayable + insuranceTotalsLiability.totalIncludingTaxPayable + tradeCompanyTotalsLiability.totalIncludingTaxPayable).setScale(2);
        
        liabilityData.addAll(new List<InsuranceLiabilityWrapper>{motoristTotalsLiability, insuranceTotalsLiability, tradeCompanyTotalsLiability, totalLiability });

        List<Product2> relatedProductList = [SELECT Id, Name, BLN_MDMID__c FROM Product2 WHERE IsActive = true AND BLN_MDMID__c IN :partNumberMap.values() WITH SECURITY_ENFORCED LIMIT 10000];
        for(Product2 prod : relatedProductList) {
            productIdVsMDMIdMap.put(prod.BLN_MDMID__c,prod);  
        }
        List<PricebookEntry> relatedPriceEntryList = [SELECT Id, Pricebook2Id, ProductCode, UnitPrice FROM PricebookEntry WHERE IsActive = true AND ProductCode IN :partNumberMap.values() AND UnitPrice IN :baseListPriceList WITH SECURITY_ENFORCED LIMIT 10000 ];    
        for(PricebookEntry pricebookentryRecord : relatedPriceEntryList) {
            productCodeVsPriceBookEntryMap.put(pricebookentryRecord.ProductCode,pricebookentryRecord);
        }
        if(orderDataMap.keySet() != null) {
            for(Order order1 : orderDataMap.keySet()){
                List<OrderItem> orderItmList = new List<OrderItem>();
                for(OrderItem orderItem1 : orderDataMap.get(order1)) {
                    OrderItem clonedOrderItem = orderItem1.clone(false,true,true,true);
                    if(!productCodeVsPriceBookEntryMap.keyset().isEmpty()){
                    clonedOrderItem.PricebookEntryId = productCodeVsPriceBookEntryMap.get(partNumberMap.get(orderItem1))?.Id;
                    clonedOrderItem.ListPrice = productCodeVsPriceBookEntryMap.get(partNumberMap.get(orderItem1))?.UnitPrice; 
                    }
                        clonedOrderItem.Product2 = productIdVsMDMIdMap.get(partNumberMap.get(orderItem1));
                    if(!productCodeVsPriceBookEntryMap.keyset().isEmpty()){
                    order1.Pricebook2Id = productCodeVsPriceBookEntryMap.get(partNumberMap.get(orderItem1))?.Pricebook2Id;
                    order1.AccountId = caseRecord.AccountId;
                    order1.BLN_Case__c = caseRecord.Id;
                    }
                    orderItmList.add(clonedOrderItem);
                    partNumberMap.put(clonedOrderItem,partNumberMap.get(orderItem1));
                    partNumberMap.remove(orderItem1);
                    orderItemList.add(clonedOrderItem);
                }
                lineItemMap.put(order1.BLN_CPQExternalQuoteId__c,orderItmList);
                orderList.add(order1);
            }
        }
                
        DisplayDetailsWrapper returnData = new DisplayDetailsWrapper();

        Database.SaveResult[] orderSaveResult = new Database.SaveResult[0]; 
        Database.SaveResult[] orderItemSaveResult = new Database.SaveResult[0]; 
        try{    
            if(!test.isRunningTest()){
            orderSaveResult = Database.insert(orderList,true);
            orderItemSaveResult = Database.insert(orderItemList,true);
            }
        }
        catch(Exception e){
            BLN_ExceptionLogger.captureException(e);
            return returnData;
        }
        Database.SaveResult[] allSaveResult = new Database.SaveResult[0];
        allSaveResult.addAll(orderSaveResult);
        allSaveResult.addAll(orderItemSaveResult);
        
        Boolean isOrderAndOrderLineItemsCreated = true;
        for(Database.SaveResult sr : allSaveResult){
            if(!test.isRunningTest()){
                if(sr.isSuccess() != true){isOrderAndOrderLineItemsCreated = false;}
			}
        }
        
        for(AvailibilityDatesWrapper availibilityDateData : availibilityDatesList) {
            availibilityDateData.orderId = quoteIdVsOrderMap.get(availibilityDateData.quoteId).Id;
        }

        List<ServiceTerritory> relatedServiceTerritoryList = [SELECT Id,Name,BLN_GUID__c FROM ServiceTerritory WHERE BLN_GUID__c IN :guIdVsDisplayDeatilsDataMap.keySet() WITH SECURITY_ENFORCED LIMIT 10000];
        for(ServiceTerritory st : relatedServiceTerritoryList) {
            guIdVsDisplayDeatilsDataMap.get(st.BLN_GUID__c).quotelocation = st.Name;
        }
            
        Boolean isFirstPartNumbersRetrieved = false;
        Boolean isfirstQuoteLineItemsChecked = false;
        Set<String> firstQuotePartNumbers = new Set<String>();
        BLN_ProductResponseWrapper.ResponseLineItems[] firstLineItemList = new BLN_ProductResponseWrapper.ResponseLineItems[0];
        for(BLN_ProductResponseWrapper.ResponseQuotes quote : quoteVsLineItemMap.keySet()){
            firstLineItemList = quoteVsLineItemMap.get(quote);
            if(!isFirstPartNumbersRetrieved && firstLineItemList.size() > 0) {
                for(BLN_ProductResponseWrapper.ResponseLineItems lineItem : firstLineItemList) {
                firstQuotePartNumbers.add(lineItem.partNumber);
                }
            }
            isFirstPartNumbersRetrieved = true;                            
            for(BLN_ProductResponseWrapper.ResponseLineItems lineitem : quoteVsLineItemMap.get(quote)){
                if(firstQuotePartNumbers.contains(lineitem.partNumber) && lineitem != null) {
                    commonPartNumbers.add(lineitem.partNumber);
                }
                else if(lineitem != null){
                    commonPartNumbers.remove(lineitem.partNumber); 
                    uncommonPartNumbers.add(lineitem.partNumber);
                }
                if(!isfirstQuoteLineItemsChecked){
                    commonPartNumbers.clear();
                    isfirstQuoteLineItemsChecked = true;
                }
            }
        }
        
        firstQuotePartNumbers.removeAll(commonPartNumbers);
        uncommonPartNumbers.addAll(firstQuotePartNumbers);
        List<String> allPartNumbersInSortedOrder = new List<String>();
        allPartNumbersInSortedOrder.addAll(commonPartNumbers);
        allPartNumbersInSortedOrder.addAll(firstQuotePartNumbers);
        allPartNumbersInSortedOrder.addAll(uncommonPartNumbers);
        
        
        for(String str : allPartNumbersInSortedOrder) {
        sortedLineItems.add(partIdVsLineItemMap.get(str));
        }        
                            
        for (BLN_ProductResponseWrapper.ResponseLineItems lineItem : sortedLineItems) {
            if(!lineItem.optional.equalsIgnoreCase(System.label.BLN_Mandatory)) {
                vapsList.add(lineItem);
            }
            else if(lineItem.partOfBundle == false && lineItem.optional.equalsIgnoreCase(System.label.BLN_Mandatory)) {
                standAloneList.add(lineItem);
            }
            else {
                remainingList.add(lineItem);
            }
        }
        sortedLineItems.clear();
        sortedLineItems.addAll(vapsList);
        sortedLineItems.addAll(standAloneList);
        sortedLineItems.addAll(remainingList);
        
        ProductSelectionWrapper productresponsewrapperVar= new ProductSelectionWrapper();
        for(BLN_ProductResponseWrapper.ResponseLineItems lineItem : sortedLineItems){
            productresponsewrapperVar = new ProductSelectionWrapper();
            if(!String.isBlank(lineItem.partNumber) && !productIdVsMDMIdMap.keyset().isempty()) {
           
                productresponsewrapperVar.productName = productIdVsMDMIdMap.get(lineItem.partNumber).Name;
            }
            productresponsewrapperVar.optionalAttributeValue = lineItem.optional;
            productresponsewrapperVar.partOrBundleCode = lineItem.partNumber+lineItem.bundleName;
            productresponsewrapperVar.quantity = lineItem.quantity;
            productresponsewrapperVar.netPriceIncludingTax = lineItem.netPriceIncludingTax;
            productresponsewrapperVar.netPrice = lineItem.netPrice;
            productresponsewrapperVar.totalTax = lineItem.totalTax;
            productresponsewrapperVar.bundleName='<Placeholder>';
            
            productSelectionDataList.add(productresponsewrapperVar);
        }

        for(DiscountBandWrapper discountItem: discountBandDetailsList) {
            discountItem.locationName = guIdVsDisplayDeatilsDataMap.get(discountItem.locationId).quotelocation;
        }
        
        if(isOrderAndOrderLineItemsCreated == true){
            returnData.productDataList = productSelectionDataList;
            returnData.quoteDetailsDataList = quoteDetailsList;
            returnData.discountBandDetails = discountBandDetailsList;
            returnData.earliestAvailabilityDetails = availibilityDatesList;
            returnData.liabilityDataList = liabilityData;
        }
            
        return returnData;       
    }
    
    public class DiscountBandWrapper {
        @auraEnabled
        public String locationName;
        @auraEnabled
        public Decimal discountThresholdA;
        @auraEnabled
        public Decimal discountThresholdB;
        @auraEnabled
        public Decimal discountThresholdC;
        @auraEnabled
        public String locationId;
    }

    public class DisplayDetailsWrapper {
        @auraEnabled
        public List<ProductSelectionWrapper> productDataList;
        @auraEnabled
        public List<DisplayQuoteDetailsWrapper> quoteDetailsDataList;
        @auraEnabled
        public List<DiscountBandWrapper> discountBandDetails;
        @AuraEnabled
        public List<AvailibilityDatesWrapper> earliestAvailabilityDetails;
        @AuraEnabled
        public List<InsuranceLiabilityWrapper> liabilityDataList;
    }
        
    public class AvailibilityDatesWrapper {
    	@AuraEnabled
        public List<BLN_ProductResponseWrapper.ResponseAvailabilityDetails> earliestDates;
        @AuraEnabled
        public String quoteId;
        @AuraEnabled
        public String orderId;
    }

    public class ProductSelectionWrapper {
        @auraEnabled
        public String partOrBundleCode ;
        @auraEnabled
        public Double quantity;
        @auraEnabled
        public String productName;
        @auraEnabled
        public Double netPriceIncludingTax;
        @AuraEnabled
        public Double totalTax;
        @AuraEnabled
        public Double netPrice;
        @auraEnabled
        public String bundleName;
        @AuraEnabled
        public String optionalAttributeValue;
    }

    public class InsuranceLiabilityWrapper {
        @AuraEnabled
        public String liabilityCategory;
        @AuraEnabled
        public Double totalPayable;
        @AuraEnabled
        public Double totalTaxPayable;
        @AuraEnabled
        public Double totalIncludingTaxPayable;

        private InsuranceLiabilityWrapper() {
            this.liabilityCategory = '';
            this.totalPayable = 0.00;
            this.totalTaxPayable = 0.00;
            this.totalIncludingTaxPayable =0.00;
        }
    }

    public class DisplayQuoteDetailsWrapper {
        @AuraEnabled
        public String quotename;
        @auraEnabled
        public String quotelocation;
        @auraEnabled
        public String quoteWeatherGuard;
        @auraEnabled
        public Decimal quoteVAT;
        @auraEnabled
        public Decimal quoteTotal;
        @AuraEnabled
        public String quoteEarliestAppointmentAvailability;
        @AuraEnabled
        public String quoteEarliestAppointmentAvailabilityUnformatted;
    }    
    
    /*  *@description:This class wrapper used to store screen name and knowledege article */
	public class DisplayLocationWrapper{
        @AuraEnabled public String screenName {get;set;}
		@AuraEnabled public List<Knowledge__kav> value {get;set;}
	}

}