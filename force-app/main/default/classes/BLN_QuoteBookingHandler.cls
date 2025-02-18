public with sharing class BLN_QuoteBookingHandler {
    
    @AuraEnabled
    public static Boolean createOrderAndOrderItemsForISP(String payload,String caseId){
        Case caseRecord = [SELECT Id,AccountId,CurrencyIsoCode FROM Case WHERE Id = :caseId WITH SECURITY_ENFORCED LIMIT 1];
        BLN_ProductResponseWrapper.ResponseProduct payloadData = (BLN_ProductResponseWrapper.ResponseProduct) JSON.deserialize(payload,BLN_ProductResponseWrapper.ResponseProduct.class);
        
        Map<Order,List<OrderItem>> orderVsOrderItemMap = new Map<Order,List<OrderItem>>();
        Map<Integer,OrderItem> lineItemIdVsOrderItemMap = new Map<Integer,OrderItem>();
        Map<OrderItem,String> orderItemWithPartNumberMap = new Map<OrderItem,String>();

        for(BLN_ProductResponseWrapper.ResponseQuotes quoteVar : payloadData.quotes){ 
            Map<Order,List<OrderItem>> quoteVarOrderVsOrderItem = getOrderDataMappingFromQuoteResponse(quoteVar);
            
            Order orderRecord = new List<Order>(quoteVarOrderVsOrderItem.keySet())[0];
            
            List<OrderItem> ordItmList = new List<OrderItem>();
            for(OrderItem ordrItm : quoteVarOrderVsOrderItem.get(orderRecord)){
                lineItemIdVsOrderItemMap.put(Integer.valueOf(ordrItm.BLN_DocumentNumber__c),ordrItm);
                ordItmList.add(ordrItm);
            }
            
            for(BLN_ProductResponseWrapper.ResponseLineItems lineItem : quoteVar.lineItems){
                orderItemWithPartNumberMap.put(lineItemIdVsOrderItemMap.get(lineItem.lineItemId),lineItem.partNumber != null ? lineItem.partNumber : lineItem.partOfBundle == true ? 'bundle' : '');
            }
            
            orderRecord.BLN_Case__c = caseRecord.Id;
            orderRecord.AccountId = caseRecord.AccountId;
            orderRecord.EffectiveDate = System.today();
            orderRecord.Status = System.label.BLN_Accepted;

            orderVsOrderItemMap.put(orderRecord,ordItmList);
        }
        
        
        Map<String,Product2> productIdVsMDMIdMap = new Map<String,Product2>();
		List<Product2> relatedProductList = new List<Product2>();
        relatedProductList = [SELECT Id, Name, BLN_MDMID__c FROM Product2 WHERE IsActive = true AND BLN_MDMID__c IN :orderItemWithPartNumberMap.values() WITH SECURITY_ENFORCED LIMIT 10000];
        for(Product2 prod : relatedProductList) {
            productIdVsMDMIdMap.put(prod.BLN_MDMID__c,prod);
        }
        Map<String,PricebookEntry> productCodeVsPriceBookEntryMap = new Map<String,PricebookEntry>();
        List<PricebookEntry> relatedPriceEntryList = new List<PricebookEntry>();        
        relatedPriceEntryList = [SELECT Id, Pricebook2Id, Product2.BLN_MDMID__c, UnitPrice,CurrencyIsoCode, IsActive FROM PricebookEntry WHERE IsActive = true AND Pricebook2.IsActive = true AND Pricebook2.IsStandard = true AND CurrencyIsoCode = :caseRecord.CurrencyIsoCode AND Product2.BLN_MDMID__c IN :orderItemWithPartNumberMap.values() WITH SECURITY_ENFORCED LIMIT 10000];
        for(PricebookEntry pricebookEntryRecord : relatedPriceEntryList) {
            productCodeVsPriceBookEntryMap.put(pricebookEntryRecord.Product2.BLN_MDMID__c,pricebookEntryRecord);
        }
        
        List<Order> orderList = new List<Order>();
        List<OrderItem> orderItemsWithPricebookData = new List<OrderItem>();
        
        if(!orderVsOrderItemMap.isEmpty()) {
            for(Order order1 : orderVsOrderItemMap.keySet()){            
                for(OrderItem orderItem1 : orderVsOrderItemMap.get(order1)) {
                    OrderItem clonedOrderItem = orderItem1.clone(false,true,true,true);
                    if(productCodeVsPriceBookEntryMap.containsKey(orderItemWithPartNumberMap.get(orderItem1))){
                        clonedOrderItem.PricebookEntryId = productCodeVsPriceBookEntryMap.get(orderItemWithPartNumberMap.get(orderItem1))?.Id;
                        clonedOrderItem.ListPrice = productCodeVsPriceBookEntryMap.get(orderItemWithPartNumberMap.get(orderItem1))?.UnitPrice;
                        order1.Pricebook2Id = productCodeVsPriceBookEntryMap.get(orderItemWithPartNumberMap.get(orderItem1))?.Pricebook2Id;
                        clonedOrderItem.Product2 = productIdVsMDMIdMap.get(orderItemWithPartNumberMap.get(orderItem1));
                        orderItemWithPartNumberMap.put(clonedOrderItem,orderItemWithPartNumberMap.get(orderItem1));
                        orderItemsWithPricebookData.add(clonedOrderItem);
                    }                  
                    orderItemWithPartNumberMap.remove(orderItem1);
                }
                orderList.add(order1);
            }
        }          
        List<Database.SaveResult> ordSr = Database.insert(orderList,true);
        List<Database.SaveResult> ordItmSr = Database.insert(orderItemsWithPricebookData,true);
        
        Boolean isOrderCreated = ordItmSr.size() > 0 ? ordItmSr[0].isSuccess() : false;
        isOrderCreated = ordSr[0].isSuccess();
        
        return isOrderCreated;
    }

    /************************
     * Method name : getCaseForQuoteCallout
     * Description : method to get Case data for Quote related queries
     *************************/

    public static Case getCaseForQuoteCallout(String motoristCaseId){
        Case motoCase = new Case();
        if(case.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible()){

            motoCase = [SELECT  Id,CreatedDate,BLN_SubType__c,BLN_Corporate__r.BLN_VehicleDamageExcess__c,BLN_BillingMethod__c,
                        BLN_MotoristTaxStatus__c,BLN_Corporate__r.BLN_InsuranceSite__r.BLN_MDMAccountPartyId__c,
                        BLN_Corporate__r.BLN_InsuranceSite__r.BLN_MDMAccountID__c,BLN_Corporate__r.BLN_InsuranceSite__r.BLN_MDMMotoristId__c,
                        BLN_ServiceCountry__c,BLN_Vehicle__r.BLN_MDMID__c,Account.BLN_MDMAccountPartyId__c,Account.BLN_MDMAccountID__c,
                        Account.BLN_MDMMotoristId__c,BLN_ServiceGeolocation__c,BLN_ServiceGeolocation__Longitude__s,BLN_ServiceGeolocation__Latitude__s,
                        BLN_Vehicle__r.BLN_SpecialVehicle__c,BLN_Corporate__r.BLN_ADASExcess__c,BLN_Corporate__r.BLN_BodyGlassExcess__c,
            BLN_Corporate__r.BLN_RepairExcess__c,BLN_Corporate__r.BLN_ReplacementExcess__c,BLN_Corporate__r.BLN_WindscreenExcess__c,BLN_Corporate__r.BLN_PolicyLimit__c,
            BLN_Corporate__c,BLN_Corporate__r.BLN_CorporateLegalEntity__r.BLN_NonDirectBilling__c,BLN_Corporate__r.BLN_InsuranceSite__r.BLN_NonDirectBilling__c,
            BLN_Corporate__r.RecordTypeId,BLN_Corporate__r.BLN_InsuranceSite__c,BLN_Corporate__r.BLN_InsuranceSite__r.BLN_ClientType__c,
                        BLN_Corporate__r.BLN_InsuranceLegalEntity__c,BLN_Corporate__r.BLN_InsuranceLegalEntity__r.BLN_ClientType__c,BLN_Corporate__r.BLN_CorporateSite__r.BLN_MDMAccountID__c,
                        BLN_Corporate__r.BLN_InsuranceLegalEntity__r.BLN_MDMAccountID__c,BLN_Corporate__r.BLN_CorporateSite__c,BLN_Corporate__r.BLN_CorporateSite__r.BLN_NonDirectBilling__c,
                        BLN_Corporate__r.BLN_HeatedRearExcess__c,BLN_Corporate__r.BLN_CorporateLegalEntity__r.BLN_MDMAccountID__c, BLN_PricingDate__c,
            BLN_Corporate__r.BLN_CHFVATStatus__c, BLN_Corporate__r.BLN_OEAuthorized__c,BLN_Corporate__r.BLN_OEAuthorizedTrade__c, BLN_Corporate__r.BLN_CorporateSite__r.BLN_ClientType__c,
            BLN_Corporate__r.BLN_CorporateLegalEntity__r.BLN_ClientType__c,BLN_Corporate__r.RecordType.DeveloperName,BLN_Corporate__r.BLN_LimitIncludedInExcess__c,BLN_Corporate__r.BLN_ProductAuthorised__c,BLN_Corporate__r.BLN_ProductAuthorisedTrade__c,BLN_Corporate__r.BLN_ProductAuthorisationRequiredTrade__c,
            BLN_Corporate__r.BLN_ProductAuthorisationRequired__c,BLN_Corporate__r.BLN_AuthorizationStatus__c,BLN_Corporate__r.BLN_AuthorizationStatusTrade__c
                        FROM Case WHERE Id = :motoristCaseId WITH SECURITY_ENFORCED LIMIT 1];   
        }
        return motoCase;
    }

    /***************************************
    * MethodName : getOrderDataMappingFromQuoteResponse
    * Description : This method is used to return order & orderItem mapping for Quote Response.
    *******************************************/
    
    public static Map<Order,List<OrderItem>> getOrderDataMappingFromQuoteResponse(BLN_ProductResponseWrapper.ResponseQuotes quoteVar){
        Map<Order,List<OrderItem>> orderVsOrderItemMap = new Map<Order,List<OrderItem>>();
       
        if(quoteVar != null){
            Order orderRecord = new Order();
            orderRecord.BLN_CPQExternalQuoteId__c = quoteVar.quoteId;            
			orderRecord.BLN_ServiceTerritory__r  = new ServiceTerritory(BLN_GUID__c = quoteVar.locationId);
            orderRecord.BLN_Location__r = new Schema.Location(BLN_GUID__c = quoteVar.locationId);
            orderRecord.BLN_AppliedExcessType__c = quoteVar.appliedExcessType;            

            orderRecord.BLN_TotalPrice__c = quoteVar.quoteTotals.totalPrice;
            orderRecord.BLN_TotalTax__c = quoteVar.quoteTotals.totalTax;
            orderRecord.BLN_TotalRepair__c	= quoteVar.quoteTotals.totalRepair;
            orderRecord.BLN_TotalReplacement__c = quoteVar.quoteTotals.totalReplacement;
            orderRecord.BLN_TotalCalibration__c = quoteVar.quoteTotals.totalCalibration;
            orderRecord.BLN_TotalSundries__c = quoteVar.quoteTotals.totalSundries;
            orderRecord.BLN_TotalIncludingTax__c = quoteVar.QuoteTotals.totalIncludingTax;

            orderRecord.BLN_PayableByInsuranceRepair__c = quoteVar.insuranceTotals.payablebyInsuranceRepair;
            orderRecord.BLN_PayableByInsuranceReplacement__c = quoteVar.insuranceTotals.payablebyInsuranceReplacement;
            orderRecord.BLN_PayableByInsuranceCalibration__c = quoteVar.insuranceTotals.payablebyInsuranceCalibration;
            orderRecord.BLN_PayableByInsuranceSundry__c = quoteVar.insuranceTotals.payablebyInsuranceSundry;
            orderRecord.BLN_TotalPayableByInsurance__c = quoteVar.insuranceTotals.totalPayablebyInsurance;
            orderRecord.BLN_TotalTaxPayablebyInsurance__c = quoteVar.insuranceTotals.totalTaxPayablebyInsurance;
            orderRecord.BLN_TotalIncludingTaxInsuranceCompany__c = quoteVar.InsuranceTotals.totalIncludingTaxPayableByInsurance;

            orderRecord.BLN_PolicyLimit__c = quoteVar.MotoristTotals.motoristLimit;            
            orderRecord.BLN_PayableByMotoristRepair__c = quoteVar.MotoristTotals.payablebyMotoristRepair;
            orderRecord.BLN_PayableByMotoristReplacement__c = quoteVar.MotoristTotals.payablebyMotoristReplacement;
            orderRecord.BLN_PayableByMotoristCalibration__c = quoteVar.MotoristTotals.payablebyMotoristCalibration;
            orderRecord.BLN_PayableByMotoristSundry__c = quoteVar.MotoristTotals.payablebyMotoristSundry;
            orderRecord.BLN_TotalTaxPayablebyMotorist__c = quoteVar.MotoristTotals.totalTaxPayablebyMotorist;
            orderRecord.BLN_TotalPayableByMotorist__c = quoteVar.MotoristTotals.totalPayableByMotorist;
            orderRecord.BLN_TotalIncludingTaxMotorist__c = quoteVar.MotoristTotals.totalIncludingTaxPayableByMotorist;

            orderRecord.BLN_TotalTaxRepair__c = quoteVar.TaxTotals.totalTaxRepair;
            orderRecord.BLN_TotalTaxReplacement__c = quoteVar.TaxTotals.totalTaxReplacement;
            orderRecord.BLN_TotalTaxCalibration__c	= quoteVar.TaxTotals.totalTaxCalibration;
            orderRecord.BLN_TotalTaxSundries__c = quoteVar.TaxTotals.totalTaxSundries;

            orderRecord.BLN_TotalPayablebyTradeCompany__c = quoteVar.TradeCompanyTotals.totalPayableByTrade;
            orderRecord.BLN_PayablebyTradeRepair__c = quoteVar.TradeCompanyTotals.payablebyTradeRepair;
            orderRecord.BLN_PayablebyTradeReplacement__c = quoteVar.TradeCompanyTotals.payablebyTradeReplacement;
            orderRecord.BLN_PayablebyTradeCalibration__c = quoteVar.TradeCompanyTotals.payablebyTradeCalibration;
            orderRecord.BLN_PayablebyTradeSundry__c = quoteVar.TradeCompanyTotals.payablebyTradeSundry;
            orderRecord.BLN_TotalTaxPayablebyTrade__c = quoteVar.TradeCompanyTotals.payableByTradeTotalTax;
            orderRecord.BLN_TotalIncludingTaxTrade__c = quoteVar.TradeCompanyTotals.totalPayableByTradeIncludingTax;

            orderRecord.BLN_DiscountThresholdAmountA__c = quoteVar.discountThresholdA;
            orderRecord.BLN_DiscountThresholdAmountB__c = quoteVar.discountThresholdB;
            orderRecord.BLN_DiscountThresholdAmountC__c = quoteVar.discountThresholdC;
            orderRecord.BLN_PriceExpirationDate__c = Date.valueOf(quoteVar.priceExpirationDate);
            
            List<OrderItem> ordItmList = new List<OrderItem>();
            for(BLN_ProductResponseWrapper.ResponseLineItems lineItem : quoteVar.lineItems){
                OrderItem ordrItm = new OrderItem();
                ordrItm.Order = new Order(BLN_CPQExternalQuoteId__c = quoteVar.quoteId);
                ordrItm.BLN_DocumentNumber__c = lineItem.lineItemId;
                ordrItm.BLN_ParentDocumentNumber__c = lineItem.parentLineItemId;
                ordrItm.BLN_BundleName__c = lineItem.bundleName;
                ordrItm.Quantity = lineItem.quantity;
                ordrItm.Description	= lineItem.partDescription;
                ordrItm.UnitPrice = lineItem.baseListPrice;
                ordrItm.BLN_NetPriceAfterPromotion__c = lineItem.netPrice;                
                ordrItm.BLN_NetPriceIncludingTax__c = lineItem.netPriceIncludingTax;
                ordrItm.BLN_TaxCode__c = lineitem.taxCode;
                ordrItm.BLN_TaxRate__c = lineItem.taxRate;
                ordrItm.BLN_TotalTax__c = lineItem.totalTax;
                ordrItm.BLN_IsProductSelected__c = lineItem.selectProduct;
                ordrItm.BLN_PartOfBundle__c = lineItem.partOfBundle;
                ordrItm.BLN_BOMId__c = lineItem.parentBOMId;
                ordrItm.BLN_POA__c = lineItem.poaStatus == null || lineItem.poaStatus == 'NA' ? '' : lineItem.poaStatus;
                ordrItm.BLN_PriceFound__c = lineItem.priceFound;
                ordrItm.BLN_LeadingPartIndicator__c = lineItem.leadingProductIndicator;
                ordrItm.BLN_TotalPayableByInsurance__c = lineItem.totalPayableByInsurance;
                ordrItm.BLN_TotalTaxPayablebyInsurance__c = lineItem.totalTaxPayableByInsurance;
                ordrItm.BLN_TotalIncludingTaxInsuranceCompany__c = lineItem.totalIncludingTaxPayableByInsurance;
                ordrItm.BLN_TotalPayableByMotorist__c = lineItem.totalPayableByMotorist;
                ordrItm.BLN_TotalTaxPayablebyMotorist__c = lineItem.totalTaxPayableByMotorist;
                ordrItm.BLN_TotalIncludingTaxByMotorist__c = lineItem.totalIncludingTaxPayableByMotorist;
                ordrItm.BLN_TotalTaxPayablebyTrade__c = lineItem.payableByTradeTotalTax;
                ordrItm.BLN_TotalPayablebyTradeCompany__c = lineItem.totalPayableByTrade;
                ordrItm.BLN_TotalIncludingTaxTrade__c = lineItem.totalPayableByTradeIncludingTax;
                ordrItm.BLN_PayableBy__c = lineItem.payableBy;
                ordrItm.BLN_TaxPayableBy__c = lineItem.vATPayableBy;
                
                ordItmList.add(ordrItm);
            }
            orderVsOrderItemMap.put(orderRecord,ordItmList);
    	}
        return orderVsOrderItemMap;
    }
    /***************************************
    * MethodName : makeQuoteCallout
    * Description : This method is used to return the response to lwc component.
    * Output Parameter :String
    * CreatedDate: 24-11-2023
    * CreatedBy : Pwc-India
    ****************************************/
    public static String makeQuoteCallout(Case motoCase,List<BLN_ProductAvailabilityWrapper.LocationWrapper> nearestLocations){                        
        HttpResponse res = createQuoteCallout(motoCase,nearestLocations);
        String returnResult = checkQuoteResponseValidity(res);    
        return returnResult;
    }

    /***************************************
    * MethodName : createQuoteCallout
    * Description : This method makes a create quote request.
    * Output Parameter :HttpResponse
    * CreatedDate: 24-11-2023
    * CreatedBy : Pwc-India
    ****************************************/
    public static HttpResponse createQuoteCallout(Case motoCase,List<BLN_ProductAvailabilityWrapper.LocationWrapper> nearestLocations){
        Map<String,Object> payloadMap = new Map<String,Object>();
        /*FOUK-10513*/
        If(motoCase.BLN_Corporate__r.RecordType.DeveloperName == System.label.BLN_Insurance){
            payloadMap.put(system.label.BLN_MotoristVATStatus,motoCase.BLN_MotoristTaxStatus__c == System.label.BLN_Yes ? System.label.BLN_Registered : System.label.BLN_Exempt);
        }
        else{
            payloadMap.put(system.label.BLN_MotoristVATStatus,System.label.BLN_Exempt);
        }
        //*FOUK-10513*/
        payloadMap.put(system.label.BLN_CaseId,motoCase.Id);
        payloadMap.put(system.label.BLN_ServiceCountry,motoCase.BLN_ServiceCountry__c);
        payloadMap.put(system.label.BLN_Currency,system.label.BLN_GBP);
        BLN_VehicleDamage__c[] relatedVehicleDamages = [SELECT Id,BLN_BOMID__c,BLN_ProductId__c FROM BLN_VehicleDamage__c WHERE BLN_Case__c=:motoCase.Id AND BLN_WorkType__c !=: System.label.BLN_Repair WITH SECURITY_ENFORCED];
        Map<String, Integer> bomIdMap = new Map<String,Integer>();
        Map<String,Integer> partIdMap = new Map<String,Integer>();
        Integer count;
        
        for(BLN_VehicleDamage__c vd : relatedVehicleDamages){
            if(String.isNotBlank(vd.BLN_BOMID__c)){
                for(String str : (vd.BLN_BOMID__c).split(System.label.BLN_Comma)){
                    count = 1;
                    if(bomIdMap.containsKey(str)){
                        count = bomIdMap.get(str) + 1;
                    }
                    bomIdMap.put(str,count);                    
                }	
            }
            if(String.isNotBlank(vd.BLN_ProductId__c)){
                for(String str : (vd.BLN_ProductId__c).split(System.label.BLN_Comma)){
                    count = 1;
                    if(partIdMap.containsKey(str)){count = partIdMap.get(str) + 1;
                    }
                    partIdMap.put(str,count);
                }
            }
        }
        List<Product2> productList = new List<Product2>();
        productList = [SELECT Id,ProductCode,BLN_MDMID__c,BLN_ProductCategory__c FROM Product2 WHERE isActive = true AND ProductCode IN :partIdMap.keySet() WITH SECURITY_ENFORCED];

        List<BLN_ProductIdentifier__mdt> prodIdentifierList = [SELECT Id, BLN_ProductCode__c,BLN_BranchOnlyOrMobileOnly__c FROM BLN_ProductIdentifier__mdt WHERE BLN_ProductCode__c != '' AND BLN_ProductCode__c IN :partIdMap.keySet() WITH SECURITY_ENFORCED];
        Map<String,BLN_ProductIdentifier__mdt> prodIdentifierMap = new Map<String,BLN_ProductIdentifier__mdt>();

        for(BLN_ProductIdentifier__mdt mdtProdId : prodIdentifierList){
            prodIdentifierMap.put(mdtProdId.BLN_ProductCode__c,mdtProdId);
        }

        for(Product2 prod : productList){
            if(String.isNotBlank(prod.ProductCode) && partIdMap.containsKey(prod.ProductCode)){
                Integer quantity = partIdMap.get(prod.ProductCode);
                partIdMap.remove(prod.ProductCode);
                partIdMap.put(prod.BLN_MDMID__c,quantity);

                if(prodIdentifierMap.containsKey(prod.ProductCode)){
                    prodIdentifierMap.put(prod.BLN_MDMID__c,prodIdentifierMap.get(prod.ProductCode));
                }

            }
        }

        List<BLN_ProductAvailabilityWrapper.BomIdWrap> bomIdList = new List<BLN_ProductAvailabilityWrapper.BomIdWrap>();
        BLN_ProductAvailabilityWrapper.BomIdWrap bomIds;
        for(String str : bomIdMap.keySet()){
            bomIds = new BLN_ProductAvailabilityWrapper.BomIdWrap();
            bomIds.bomId = str;
            bomIds.quantity = bomIdMap.get(str);
            bomIds.branch = true;
            bomIds.mobile = true;
            bomIds.isSelected = true;
            bomIdList.add(bomIds);
        }
        payloadMap.put(system.label.BLN_BomIds,bomIdList);
        
        List<BLN_ProductAvailabilityWrapper.PartIdWrap> partIdList = new List<BLN_ProductAvailabilityWrapper.PartIdWrap>();
        BLN_ProductAvailabilityWrapper.PartIdWrap partIds;
        
        for(String str : partIdMap.keySet()){
            partIds = new BLN_ProductAvailabilityWrapper.PartIdWrap();
            partIds.partId = str;
            partIds.quantity = partIdMap.get(str);
            partIds.branch = true;
            partIds.mobile = true;
            partIds.isSelected = !prodIdentifierMap.containsKey(str) ? true : prodIdentifierMap.get(str).BLN_BranchOnlyOrMobileOnly__c != 'BranchOnlyProduct' ? true : false;
            
            //!prodIdentifierMap.containsKey(str) ? true : prodIdentifierMap.get(str).BLN_BranchOnlyOrMobileOnly__c != 'BranchOnlyProduct' ? true : false;
            partIdList.add(partIds);
        }
        payloadMap.put(system.label.BLN_PartIds,partIdList);
        
        payloadMap.put(system.label.BLN_VehicleId,motoCase.BLN_Vehicle__r.BLN_MDMID__c != null ? motoCase.BLN_Vehicle__r.BLN_MDMID__c : '');
        payloadMap.put(system.label.BLN_AccountId,BLN_ProductAvailabilityUtility.getAccountId(motoCase));
        payloadMap.put(system.label.BLN_Profile,(String.isNotBlank(UserInfo.getUserRoleId())? [Select id,DeveloperName from UserRole where Id = :UserInfo.getUserRoleId()].DeveloperName:''));
        payloadMap.put(system.label.BLN_VoucherCode,'');
        payloadMap.put(System.label.BLN_QuoteTypeLabel,BLN_ProductAvailabilityUtility.getQuoteType(motoCase));
        payloadMap.put(system.label.BLN_Locations,nearestLocations);
         
        BLN_ProductAvailabilityWrapper.InsuranceDetailsWrapper insuranceDetails = new BLN_ProductAvailabilityWrapper.InsuranceDetailsWrapper();
        //FOUK-11745 changes start
        //insuranceDetails.glassLimit = 0;
        //FOUK-11745 changes end
        insuranceDetails.sundryExcess = 0;
        payloadMap.put('chfVATStatus',(String.isNotBlank(motoCase.BLN_Corporate__r.BLN_CHFVATStatus__c)?motoCase.BLN_Corporate__r.BLN_CHFVATStatus__c:''));
        payloadMap.put('tradeAccountId',BLN_ProductAvailabilityUtility.getTradeAccountId(motoCase));
        if(motoCase.BLN_SubType__c == 'ISP'){
            payloadMap.put('isISPJob','Applies');
        }
        if((motoCase.BLN_Corporate__r.RecordType.DeveloperName == System.label.BLN_Insurance || (motoCase.BLN_Corporate__r.RecordType.DeveloperName == System.label.BLN_SpiltBill  && motoCase.BLN_Corporate__r.BLN_CorporateSite__c ==null)) && motoCase.BLN_Corporate__r.BLN_ProductAuthorisationRequired__c == true && motoCase.BLN_Corporate__r.BLN_AuthorizationStatus__c == System.label.BLN_ApprovedLabel && motoCase.BLN_Corporate__r.BLN_InsuranceSite__c!=null){
            payloadMap.put(System.label.BLN_ProductAuthorized,motoCase.BLN_Corporate__r.BLN_ProductAuthorised__c);

        }
        else if ((motoCase.BLN_Corporate__r.RecordType.DeveloperName == System.label.BLN_CorporateFleet || (motoCase.BLN_Corporate__r.RecordType.DeveloperName == System.label.BLN_SpiltBill && motoCase.BLN_Corporate__r.BLN_InsuranceSite__c==null)) && motoCase.BLN_Corporate__r.BLN_ProductAuthorisationRequiredTrade__c == true && motoCase.BLN_Corporate__r.BLN_AuthorizationStatusTrade__c == System.label.BLN_ApprovedLabel && motoCase.BLN_Corporate__r.BLN_CorporateSite__c!=null ){
            payloadMap.put(System.label.BLN_ProductAuthorizedTrade,motoCase.BLN_Corporate__r.BLN_ProductAuthorisedTrade__c);

        }
        else if(motoCase.BLN_Corporate__r.RecordType.DeveloperName == System.label.BLN_SpiltBill && motoCase.BLN_Corporate__r.BLN_CorporateSite__c!=null && motoCase.BLN_Corporate__r.BLN_InsuranceSite__c!=null){
            if((motoCase.BLN_Corporate__r.BLN_ProductAuthorisationRequired__c == true && motoCase.BLN_Corporate__r.BLN_AuthorizationStatus__c == System.label.BLN_ApprovedLabel)){
                payloadMap.put(System.label.BLN_ProductAuthorized,motoCase.BLN_Corporate__r.BLN_ProductAuthorised__c);
            }
            if((motoCase.BLN_Corporate__r.BLN_ProductAuthorisationRequiredTrade__c == true && motoCase.BLN_Corporate__r.BLN_AuthorizationStatusTrade__c == System.label.BLN_ApprovedLabel) ){
                payloadMap.put(System.label.BLN_ProductAuthorizedTrade,motoCase.BLN_Corporate__r.BLN_ProductAuthorisedTrade__c);

            }
        
        }

        if((motoCase.BLN_Corporate__r.RecordType.DeveloperName == System.label.BLN_Insurance || (motoCase.BLN_Corporate__r.RecordType.DeveloperName == System.label.BLN_SpiltBill && motoCase.BLN_Corporate__r.BLN_InsuranceSite__c!=null && motoCase.BLN_Corporate__r.BLN_CorporateSite__c ==null)) && String.isNotBlank(motoCase.BLN_Corporate__r.BLN_OEAuthorized__c) ){
            boolean isOEAuthorized = motoCase.BLN_Corporate__r.BLN_OEAuthorized__c.equalsIgnoreCase(System.Label.BLN_Y) ? true : false;
            payloadMap.put(System.label.BLN_OEAuthorized,isOEAuthorized);
        }
        else if((motoCase.BLN_Corporate__r.RecordType.DeveloperName == System.label.BLN_CorporateFleet || (motoCase.BLN_Corporate__r.RecordType.DeveloperName == System.label.BLN_SpiltBill && motoCase.BLN_Corporate__r.BLN_CorporateSite__c!=null && motoCase.BLN_Corporate__r.BLN_InsuranceSite__c==null)) && String.isNotBlank(motoCase.BLN_Corporate__r.BLN_OEAuthorizedTrade__c))  {
            boolean isOEAuthorizedTrade = motoCase.BLN_Corporate__r.BLN_OEAuthorizedTrade__c.equalsIgnoreCase(System.Label.BLN_Y) ? true : false;
            payloadMap.put(System.label.BLN_OEAuthorizedTrade,isOEAuthorizedTrade);
        }
        else if(motoCase.BLN_Corporate__r.RecordType.DeveloperName == System.label.BLN_SpiltBill && motoCase.BLN_Corporate__r.BLN_CorporateSite__c!=null && motoCase.BLN_Corporate__r.BLN_InsuranceSite__c!=null ){
            if(String.isNotBlank(motoCase.BLN_Corporate__r.BLN_OEAuthorized__c)){
                boolean isOEAuthorized = motoCase.BLN_Corporate__r.BLN_OEAuthorized__c.equalsIgnoreCase(System.Label.BLN_Y) ? true : false;
                payloadMap.put(System.label.BLN_OEAuthorized,isOEAuthorized);
            }
            if(String.isNotBlank(motoCase.BLN_Corporate__r.BLN_OEAuthorizedTrade__c)){
            boolean isOEAuthorizedTrade = motoCase.BLN_Corporate__r.BLN_OEAuthorizedTrade__c.equalsIgnoreCase(System.Label.BLN_Y) ? true : false;
            payloadMap.put(System.label.BLN_OEAuthorizedTrade,isOEAuthorizedTrade);
        } 
        
        } 
        
        payloadMap.put('taxRegistrationNumber','');
        
        if(motoCase.BLN_Corporate__c !=null){
            payloadMap.put('totalPolicyClaimLimitIncludesExcessInd',motoCase.BLN_Corporate__r.BLN_LimitIncludedInExcess__c == null ? '' : motoCase.BLN_Corporate__r.BLN_LimitIncludedInExcess__c == 'Y' ? 'Yes' : 'No');
            //FOUK-11745 changes start
            insuranceDetails.glassLimit = motoCase.BLN_Corporate__r.BLN_PolicyLimit__c == null || String.valueOf (motoCase.BLN_Corporate__r.BLN_PolicyLimit__c) == '' ? 0:  motoCase.BLN_Corporate__r.BLN_PolicyLimit__c;		
            //FOUK-11745 changes end 
            insuranceDetails.calibrationExcess = motoCase.BLN_Corporate__r.BLN_ADASExcess__c == null || String.valueOf (motoCase.BLN_Corporate__r.BLN_ADASExcess__c) == '' ? 0:  motoCase.BLN_Corporate__r.BLN_ADASExcess__c;		
            insuranceDetails.bodyglassExcess = motoCase.BLN_Corporate__r.BLN_BodyGlassExcess__c == null || String.valueOf(motoCase.BLN_Corporate__r.BLN_BodyGlassExcess__c) == '' ? 0:  motoCase.BLN_Corporate__r.BLN_BodyGlassExcess__c;	
            insuranceDetails.repairExcess = motoCase.BLN_Corporate__r.BLN_RepairExcess__c == null || String.valueOf(motoCase.BLN_Corporate__r.BLN_RepairExcess__c) == '' ? 0:  motoCase.BLN_Corporate__r.BLN_RepairExcess__c;
            insuranceDetails.replacementExcess = motoCase.BLN_Corporate__r.BLN_ReplacementExcess__c == null || String.valueOf(motoCase.BLN_Corporate__r.BLN_ReplacementExcess__c) == '' ? 0:  motoCase.BLN_Corporate__r.BLN_ReplacementExcess__c;
            insuranceDetails.windscreenExcess = motoCase.BLN_Corporate__r.BLN_WindscreenExcess__c == null || String.valueOf(motoCase.BLN_Corporate__r.BLN_WindscreenExcess__c) == '' ? 0:  motoCase.BLN_Corporate__r.BLN_WindscreenExcess__c;
            insuranceDetails.vehicleDamageExcess = motoCase.BLN_Corporate__r.BLN_VehicleDamageExcess__c == null || String.valueOf(motoCase.BLN_Corporate__r.BLN_VehicleDamageExcess__c) == '' ? 0:  motoCase.BLN_Corporate__r.BLN_VehicleDamageExcess__c;
            insuranceDetails.heatedRearExcess = motoCase.BLN_Corporate__r.BLN_HeatedRearExcess__c == null || String.valueOf(motoCase.BLN_Corporate__r.BLN_HeatedRearExcess__c) == '' ? 0:  motoCase.BLN_Corporate__r.BLN_HeatedRearExcess__c;     
            
            payloadMap.put(system.label.BLN_InsuranceDetails,insuranceDetails);
        }
        
        payloadMap.put('pricingDate',String.valueOf(motoCase.BLN_PricingDate__c));
        payloadMap.put('channel','FrontOffice');
        
        String payload = JSON.serializePretty(payloadMap);
        
        
        //making callout
        BLN_APICalloutMapper__mdt calloutDetails = BLN_APICalloutMapper__mdt.getInstance(System.label.BLN_QuoteApi);
        
        Map<String,String> headerMap = new Map<String,String>();
        headerMap.put(System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[0],System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[1]+' '+BLN_HTTPCallOutAccessToken.getAccessToken().accessToken);
        
        if(String.isNotBlank(calloutDetails.BLN_Headers__c)){
        for(String header : calloutDetails.BLN_Headers__c.split(System.label.BLN_Semicolon)){
            if(header.contains(System.label.BLN_Comma)){
                headerMap.put(header.split(System.label.BLN_Comma)[0],header.split(System.label.BLN_Comma)[1]);
            }
        }
        }
        Integer timeout = Integer.valueOf(calloutDetails.BLN_APITimeout__c);
        return BLN_HttpCalloutUtility.makeCallout(calloutDetails.BLN_DestinationSystem__c,calloutDetails.BLN_NamedCredential__c + calloutDetails.BLN_CalloutURL__c, calloutDetails.BLN_Method__c, headerMap, motoCase.Id, payload,timeout);
    }

    /***************************************
    * MethodName : repriceQuoteCallout
    * Description : This method makes a reprice quote request.
    * Output Parameter :HttpResponse
    * CreatedDate: 24-11-2023
    * CreatedBy : Pwc-India
    ****************************************/
    public static HttpResponse repriceQuoteCallout(String payload, String caseRecordId){
        BLN_APICalloutMapper__mdt calloutData = BLN_APICalloutMapper__mdt.getInstance(System.label.BLN_QuoteRepriceApi);
        
        Map<String,String> headerMap = new Map<String,String>();
        headerMap.put(System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[0],System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[1]+' '+BLN_HTTPCallOutAccessToken.getAccessToken().accessToken);
        
        if(String.isNotBlank(calloutData.BLN_Headers__c)){
        for(String header : calloutData.BLN_Headers__c.split(System.label.BLN_Semicolon)){
            if(header.contains(System.label.BLN_Comma)){
                headerMap.put(header.split(System.label.BLN_Comma)[0],header.split(System.label.BLN_Comma)[1]);
            }
        }
        }
        Integer timeout = Integer.valueOf(calloutData.BLN_APITimeout__c);  
        return BLN_HttpCalloutUtility.makeCallout(calloutData.BLN_DestinationSystem__c,calloutData.BLN_NamedCredential__c+calloutData.BLN_CalloutURL__c,calloutData.BLN_Method__c,headerMap,caseRecordId,payload,timeout);  
    }

    /***************************************
    * MethodName : getQuoteCallout
    * Description : This method makes a get-quote request.
    * Output Parameter :HttpResponse
    * CreatedDate: 24-11-2023
    * CreatedBy : Pwc-India
    ****************************************/
    public static HttpResponse getQuoteCallout(String cpqExtenalCode,String caseId){
        BLN_APICalloutMapper__mdt calloutDetails = BLN_APICalloutMapper__mdt.getInstance(System.label.BLN_GetQuoteAPI);
        
        Map<String,String> headerMap = new Map<String,String>();
        headerMap.put(System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[0],System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[1]+' '+BLN_HTTPCallOutAccessToken.getAccessToken().accessToken);

        if(String.isNotBlank(calloutDetails.BLN_Headers__c)){
        for(String header : calloutDetails.BLN_Headers__c.split(System.label.BLN_Semicolon)){
            if(header.contains(System.label.BLN_Comma)){
                headerMap.put(header.split(System.label.BLN_Comma)[0],header.split(System.label.BLN_Comma)[1]);
            } 
        }
        }
        Integer timeout = Integer.valueOf(calloutDetails.BLN_APITimeout__c);
        return BLN_HttpCalloutUtility.makeCallout(calloutDetails.BLN_DestinationSystem__c,calloutDetails.BLN_NamedCredential__c + calloutDetails.BLN_CalloutURL__c + cpqExtenalCode, calloutDetails.BLN_Method__c,headerMap,caseId,timeout);
    }


    /***************************************
    * MethodName : cloneQuoteCallout
    * Description : This method makes a clone-quote request.
    * Output Parameter :HttpResponse
    * CreatedDate: 24-11-2023
    * CreatedBy : Pwc-India
    ****************************************/
    public static HttpResponse cloneQuoteCallout(String quoteIds,String caseId){

        List<String> quoteIdList = new List<String>(quoteIds.split(','));
        Map<String,List<String>> payloadMap = new Map<String,List<String>>();
        payloadMap.put(System.label.BLN_QuoteIdsProperty,quoteIdList);
        String payload = JSON.serializePretty(payloadMap);
        
        BLN_APICalloutMapper__mdt calloutDetails = BLN_APICalloutMapper__mdt.getInstance(System.label.BLN_CloneQuoteAPI);
        
        Map<String,String> headerMap = new Map<String,String>();
        headerMap.put(System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[0],System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[1]+' '+BLN_HTTPCallOutAccessToken.getAccessToken().accessToken);
        
        if(String.isNotBlank(calloutDetails.BLN_Headers__c)){
        for(String header : calloutDetails.BLN_Headers__c.split(System.label.BLN_Semicolon)){
            if(header.contains(System.label.BLN_Comma)){
                headerMap.put(header.split(System.label.BLN_Comma)[0],header.split(System.label.BLN_Comma)[1]);
            }  
        }
        }
                
        Integer timeout = Integer.valueOf(calloutDetails.BLN_APITimeout__c);
        return BLN_HttpCalloutUtility.makeCallout(calloutDetails.BLN_DestinationSystem__c,calloutDetails.BLN_NamedCredential__c + calloutDetails.BLN_CalloutURL__c, calloutDetails.BLN_Method__c,headerMap,caseId,payload,timeout);

    }

    /***************************************
    * MethodName : checkQuoteResponseValidity
    * Description : This method makes a quote response validity.
    * Output Parameter :HttpResponse
    * CreatedDate: 24-11-2023
    * CreatedBy : Pwc-India
    ****************************************/

    public static String checkQuoteResponseValidity(HttpResponse res){        
       	Map<String,String> returnResult = new Map<String,String>();
        try {
            if ((res.getStatusCode() == 200 || res.getStatusCode() == 201 ) &&
                res.getBody() != null && res.getBody() != '' && 
                !res.getBody().contains('errors') && 
                !res.getBody().contains('Bad Request') && 
                !res.getBody().contains('partial_success')) {

                returnResult.put('status', 'Success');
                returnResult.put('currentPayload', res.getBody());
            }
            else{
                returnResult.put('status', 'Error');
                returnResult.put('errorMessage', System.Label.BLN_CPQCalloutFailed);
            }
        } 
        catch (Exception e) {
            returnResult.put('status', 'Error');
            returnResult.put('errorMessage', System.Label.BLN_CPQCalloutFailed);
        }
        return JSON.serialize(returnResult); 
    }
}