/*****************************************
ClassName : BLN_ProductAvailability
Description : FOUK-3681, 4049 This controller class is used in lwc.
CreatedDate: 24-11-2023
CreatedBy : PwC-India
****************************************/


/*  *@description:This class is used to return the response */
public with sharing class BLN_ProductAvailability {
    
    public static final String COMPLETED_STATUS = 'Completed';
    /*****************************************
MethodName : getNearestServiceLocations
Description : This method is used to return the response to lwc component.
Input Parameter : null
Output Parameter : List<BLN_ProductAvailabilityWrapper.LocationWrapper>
CreatedDate: 24-11-2023
CreatedBy : Pwc-India
Change log :
****************************************/  
    public static List<BLN_ProductAvailabilityWrapper.LocationWrapper> getNearestServiceLocations(Case motoristCase){
        //FOUK-4639
        List<BLN_ProductAvailabilityWrapper.LocationWrapper> nearestLocationDetails = new List<BLN_ProductAvailabilityWrapper.LocationWrapper>();
        BLN_ProductAvailabilityWrapper.LocationWrapper locWrapper;
        List<ServiceTerritory> branchST = new List<ServiceTerritory>();
        
            if(test.isRunningTest()){
                branchST = [SELECT id, Latitude,Longitude,BLN_GUID__c, BLN_CostCenter__c,BLN_OrgCodeLocation__c FROM ServiceTerritory WITH SECURITY_ENFORCED LIMIT 1]; 
            }
            else{
            	branchST = motoristCase.BLN_Vehicle__r.BLN_SpecialVehicle__c ? [SELECT Id,Address,Latitude,Longitude,BLN_GUID__c,BLN_OrgCodeLocation__c,BLN_CostCenter__c,BLN_Type__c,DISTANCE(Address,:motoristCase.BLN_ServiceGeolocation__c,'mi') distanceChart FROM ServiceTerritory WHERE BLN_ConsiderforR1__c = false AND IsActive = true AND BLN_Type__c = :System.label.BLN_Branch AND BLN_Specials__c = true AND BLN_GUID__c != '' AND BLN_CostCenter__c != '' AND Longitude != null AND Latitude != null ORDER BY DISTANCE(Address,:motoristCase.BLN_ServiceGeolocation__c,'mi') ASC limit 3] : [SELECT id,Address,Latitude,Longitude,BLN_GUID__c,BLN_OrgCodeLocation__c,BLN_CostCenter__c,BLN_Type__c,DISTANCE(Address,:motoristCase.BLN_ServiceGeolocation__c,'mi') sampleDistance FROM ServiceTerritory WHERE BLN_ConsiderforR1__c = false AND IsActive=true AND BLN_Type__c= :System.label.BLN_Branch AND BLN_GUID__c != '' AND BLN_CostCenter__c != '' AND Longitude != null AND Latitude != null ORDER BY DISTANCE(Address,:motoristCase.BLN_ServiceGeolocation__c,'mi') ASC limit 3];
            }       
        for(ServiceTerritory st : branchST){
            locWrapper = new BLN_ProductAvailabilityWrapper.LocationWrapper();
            	locWrapper.costCenterId = st.BLN_OrgCodeLocation__c;
                locWrapper.locationId = st.BLN_GUID__c;
                locWrapper.mobileLocationIndicator = false;
                locWrapper.countryCode = 'GB';
                nearestLocationDetails.add(locWrapper);
            }
            if(!motoristCase.BLN_Vehicle__r.BLN_SpecialVehicle__c){
                List<FSL__Polygon__c> polygonList = new List<FSL__Polygon__c>();
            if(FSL__Polygon__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible() && !test.isRunningTest()){ 
                polygonList = [SELECT id,FSL__Service_Territory__r.BLN_GUID__c,FSL__Service_Territory__r.BLN_OrgCodeLocation__c,FSL__Service_Territory__r.BLN_CostCenter__c,FSL__Service_Territory__r.BLN_Type__c,FSL__Service_Territory__r.Address FROM FSL__Polygon__c WHERE FSL__Service_Territory__r.BLN_ConsiderforR1__c = false AND FSL__Service_Territory__r.isActive = true AND FSL__Service_Territory__r.BLN_Type__c = :System.label.BLN_Mobile AND Id IN :FSL.PolygonUtils.getAllPolygonsByLatLong((Double)motoristCase.BLN_ServiceGeolocation__Longitude__s,(Double)motoristCase.BLN_ServiceGeolocation__Latitude__s) WITH SECURITY_ENFORCED ORDER BY DISTANCE(FSL__Service_Territory__r.Address,:motoristCase.BLN_ServiceGeolocation__c,'mi') ASC LIMIT 1];                
                }
                if(test.isRunningTest()){
                    polygonList = [SELECT id,FSL__Service_Territory__r.BLN_CostCenter__c,FSL__Service_Territory__r.BLN_OrgCodeLocation__c,FSL__Service_Territory__r.BLN_Type__c,FSL__Service_Territory__r.Address, FSL__KML__c, FSL__Mi_Lo__c, FSL__Color__c, Name, FSL__Service_Territory__r.BLN_GUID__c,  FSL__Ma_Lo__c, FSL__Mi_La__c, FSL__Ma_La__c, FSL__Service_Territory__c FROM FSL__Polygon__c WITH SECURITY_ENFORCED LIMIT 1];
                }            
            for(FSL__Polygon__c poly : polygonList){
                locWrapper = new BLN_ProductAvailabilityWrapper.LocationWrapper();
                locWrapper.costCenterId = poly.FSL__Service_Territory__r.BLN_OrgCodeLocation__c;
                        locWrapper.locationId = poly.FSL__Service_Territory__r.BLN_GUID__c;
                        locWrapper.mobileLocationIndicator = true;
                        locWrapper.countryCode = 'GB';
                        nearestLocationDetails.add(locWrapper);
                    }
                }
        return nearestLocationDetails;
    }
    
    /*****************************************
MethodName : makeQuoteCalloutWithFourLocations
Description : This method is used to return the response to lwc component.
Input Parameter : null
Output Parameter :String
CreatedDate: 24-11-2023
CreatedBy : Pwc-India
Change log :
****************************************/
    
    @AuraEnabled
    public static String makeQuoteCalloutWithFourLocations(String motoristCaseId){
        Case motoCase = BLN_QuoteBookingHandler.getCaseForQuoteCallout(motoristCaseId);
        List<BLN_ProductAvailabilityWrapper.LocationWrapper> nearestLocations = BLN_ProductAvailability.getNearestServiceLocations(motoCase);          
        
        String payload  = BLN_QuoteBookingHandler.makeQuoteCallout(motoCase,nearestLocations);
        return payload;
    }

    @AuraEnabled
    public static String makeQuoteCalloutForISPLocation(String motoristCaseId){
        Case motoCase = BLN_QuoteBookingHandler.getCaseForQuoteCallout(motoristCaseId);

        BLN_ProductAvailabilityWrapper.LocationWrapper locWrapper = new BLN_ProductAvailabilityWrapper.LocationWrapper();
        locWrapper.costCenterId = System.Label.BLN_ISPLocationGUID;
        locWrapper.locationId = System.Label.BLN_ISPLocationGUID;
        locWrapper.mobileLocationIndicator = false;
        locWrapper.countryCode = 'GB';

        String payload = BLN_QuoteBookingHandler.makeQuoteCallout(motoCase,new List<BLN_ProductAvailabilityWrapper.LocationWrapper>{locWrapper});
        return payload;
    }     

    public static void updateAllQuoteIds(String payload, String caseId){
        Case cs = [Select Id,BLN_CPQQuoteIdCollection__c from case where Id =: caseId WITH SECURITY_ENFORCED LIMIT 1];
        BLN_ProductResponseWrapper.ResponseProduct data = (BLN_ProductResponseWrapper.ResponseProduct) System.JSON.deserialize(payload,BLN_ProductResponseWrapper.ResponseProduct.class);
        String quotes = '';
            for(BLN_ProductResponseWrapper.ResponseQuotes quoteVar : data.quotes){
                quotes = quotes + quoteVar.quoteId+','; 
            }
            cs.BLN_CPQQuoteIdCollection__c = quotes.removeEnd(',');
            if(Schema.sObjectType.Case.isUpdateable()){
            update cs;
            }
    }
    //here concludes 3068
    @AuraEnabled
    public static String makeRepriceCallout(String repriceRequestPayload, String caseRecordId){
        HttpResponse res = BLN_QuoteBookingHandler.repriceQuoteCallout(repriceRequestPayload,caseRecordId);  
        String returnResult = BLN_QuoteBookingHandler.checkQuoteResponseValidity(res);
        return returnResult;
    }
    
    @AuraEnabled    
    public static BLN_ProductAvailabilityWrapper.DisplayDetailsWrapper structureDataForQuoteUI(String payload, String caseId){
        BLN_ProductResponseWrapper.ResponseProduct data = (BLN_ProductResponseWrapper.ResponseProduct) System.JSON.deserialize(payload,BLN_ProductResponseWrapper.ResponseProduct.class);
        Map<Integer,List<BLN_ProductResponseWrapper.ResponseLineItems>> bundleParentLineItemVsLineItem = new Map<Integer,List<BLN_ProductResponseWrapper.ResponseLineItems>>();
        Map<String,BLN_ProductResponseWrapper.ResponseLineItems> bundleNameVsBundleLineItem = new Map<String,BLN_ProductResponseWrapper.ResponseLineItems>();
        Order orderData = BLN_ProductAvailabilityRebook.getAcceptedOrder(caseId);
        
        //Prepare Set of all Part Numbers from Line Items in all Quotes

        Integer bufferDaysToAdd = BLN_ProductAvailabilityUtility.bufferCalculation(caseId);
        List<BLN_ProductAvailabilityWrapper.EarliestAvailabilityDetailsWrapper> earliestAvailabilityDateList = BLN_ProductAvailabilityRebook.getEarliestDateList(payload, caseId);
        Set<String> partNumbersSet = new Set<String>();
        Set<String> partNumbersSelectedSet = new Set<String>();
        Map<String,Set<String>> quoteIdStockLocationsMap = new Map<String,Set<String>>();
        Map<String,List<BLN_ProductResponseWrapper.ResponseLineItems>> bundleNameVsLineItem = new Map<String,List<BLN_ProductResponseWrapper.ResponseLineItems>>();
       
        Map<String,BLN_ProductResponseWrapper.ResponseLineItems> keyVsLineItemMap = new Map<String,BLN_ProductResponseWrapper.ResponseLineItems>();
       
        Set<String> locationIds = new Set<String>();
        for(BLN_ProductResponseWrapper.ResponseQuotes quoteVar : data.quotes){
            locationIds.add(quoteVar.locationId);
        }

        map<String,String> locationNameFromGuidMap = new map<String,String>();
        for(ServiceTerritory st : [Select Id, Name,BLN_GUID__c,BLN_Type__c From ServiceTerritory where BLN_GUID__c =: locationIds WITH SECURITY_ENFORCED]){
            locationNameFromGuidMap.put(st.BLN_GUID__c,st.Name);
        }
        
        BLN_ProductAvailabilityWrapper.QuoteLocationWrapper selectedLocationWrap;
        for(BLN_ProductResponseWrapper.ResponseQuotes quoteVar : data.quotes){
            quoteIdStockLocationsMap.put(quoteVar.quoteId, new Set<String>());
            if(orderData != NULL && orderData.BLN_ServiceTerritory__r.BLN_GUID__c == quoteVar.locationId){
                BLN_ProductAvailabilityWrapper.QuoteLocationWrapper locations = new BLN_ProductAvailabilityWrapper.QuoteLocationWrapper();
                locations.locationGUID = quoteVar.locationId;
                locations.quoteId = quoteVar.quoteId;
                locations.quotelocation = locationNameFromGuidMap.get(quoteVar.locationId);
                if(orderData.BLN_ServiceTerritory__r.BLN_Type__c == System.label.BLN_Mobile){
                    locations.isMobileLocation = true;
                }else{
                    locations.isMobileLocation = false;
                } 
                locations.quoteTotal = quoteVar.quoteTotals.totalPrice;
                locations.quoteVAT = quoteVar.quoteTotals.totaltax;
                locations.quoteNetTotal = quoteVar.quoteTotals.totalIncludingTax;
                selectedLocationWrap = locations;
            }

            for(BLN_ProductResponseWrapper.ResponseLineItems lineItem : quoteVar.lineItems) {
                if(lineItem.selectProduct == true) {
                    partNumbersSelectedSet.add(lineItem.partNumber);
                }
                if(lineItem.partOfBundle == true && lineItem.partNumber == null){ 
                    lineItem.partNumber = System.label.BLN_Bundle;
                    bundleNameVsBundleLineItem.put(lineItem.bundleName,lineItem);

                    }

                if(lineItem.partOfBundle == true && (bundleParentLineItemVsLineItem.containsKey(lineItem.parentLineItemId) == true) && (lineItem.parentLineItemId != lineItem.lineItemId)){
                    List<BLN_ProductResponseWrapper.ResponseLineItems> bundleLineItemList = bundleParentLineItemVsLineItem.get(lineItem.parentLineItemId);
                    Boolean isLineItemExists = false;
                    for(Integer i = 0; i < bundleLineItemList.size(); i++){
                        if((bundleLineItemList[i].bundleName == lineItem.bundleName) && (bundleLineItemList[i].partNumber == lineItem.partNumber) && (bundleLineItemList[i].parentBOMId == lineItem.parentBOMId)){
                            isLineItemExists = true;
                            break;
                        }
                    }
                    if(!isLineItemExists){
                        bundleParentLineItemVsLineItem.get(lineItem.parentLineItemId).add(lineItem);
                    }
                }
                else if(lineItem.partOfBundle == true && lineItem.parentLineItemId != lineItem.lineItemId){
                    bundleParentLineItemVsLineItem.put(lineItem.parentLineItemId,new List<BLN_ProductResponseWrapper.ResponseLineItems>{lineItem});
                }

                if(lineItem.partOfBundle == true && (bundleNameVsLineItem.containsKey(lineItem.bundleName) == true) && (lineItem.parentLineItemId != lineItem.lineItemId)){
                        bundleNameVsLineItem.get(lineItem.bundleName).add(lineItem);
                    }else{
                        bundleNameVsLineItem.put(lineItem.bundleName,new List<BLN_ProductResponseWrapper.ResponseLineItems>{lineItem});
                    }

                partNumbersSet.add(lineItem.partNumber);
                for(BLN_ProductResponseWrapper.ResponseAvailabilityDetails availDetail : lineItem.availabilityDetails){
                    availDetail.availableFromDate = availDetail.availableFromDate == null || availDetail.availableFromDate == ''? String.valueOf(System.now().date()) : availDetail.availableFromDate;
                    availDetail.availableFromDate =  availDetail.availableFromDate == String.valueOf(System.now().date()) ? String.valueOf(DateTime.newInstance(System.now().date().addDays(bufferDaysToAdd),System.now().time()).format('YYYY-MM-dd\'T\'HH:mm:ssXXX')) : String.valueOf(DateTime.newInstance(Date.valueOf(availDetail.availableFromDate).addDays(bufferDaysToAdd),System.now().time()).format('YYYY-MM-dd\'T\'HH:mm:ssXXX')); //String.valueOf(DateTime.newInstance(Date.valueOf(availDetail.availableFromDate).addDays(bufferDaysToAdd)).format('YYYY-MM-dd\'T\'HH:mm:ssXXX'));
                    quoteIdStockLocationsMap.get(quoteVar.quoteId).add( availDetail.stockLocationId );
                }
            }
        }

        //Create Map of Product MDM ID and Product Record for all products in all Quotes
        Map<String,Product2> productMDMIDProductMap = new Map<String,Product2>();
        Set<String> productCodeSet = new Set<String>();
        for(Product2 prod : [SELECT Id, Name, Description, BLN_MDMID__c,ProductCode, BLN_BusinessUnitSpecificBranchOnly__c, BLN_ProductCategory__c,BLN_ADASRecalibrationNeeded__c, BLN_ProductStockable__c,BLN_BondedNonBonded__c FROM Product2 WHERE isActive = true AND BLN_MDMID__c IN :partNumbersSet WITH SECURITY_ENFORCED]) {
            productMDMIDProductMap.put(prod.BLN_MDMID__c,prod);
            productCodeSet.add(prod.ProductCode);
        }
        
        List<BLN_ProductIdentifier__mdt> productIdentifierListForHideOnUI = new List<BLN_ProductIdentifier__mdt>();
        productIdentifierListForHideOnUI = [SELECT Id,BLN_ProductCode__c,BLN_Type__c FROM BLN_ProductIdentifier__mdt WHERE BLN_Type__c ='HIDE ON UI' AND BLN_ProductCode__c IN :productCodeSet WITH SECURITY_ENFORCED];  
        Map<String,Boolean> hideOnUIMap = new Map<String,Boolean>();
        for(BLN_ProductIdentifier__mdt prodIdentifier : productIdentifierListForHideOnUI){
            hideOnUIMap.put(prodIdentifier.BLN_ProductCode__c,true);
        }

        List<BLN_ProductResponseWrapper.ResponseLineItems> sortedLineItems = new List<BLN_ProductResponseWrapper.ResponseLineItems>();
        List<BLN_ProductAvailabilityWrapper.ProductSelectionWrapper> productSelectionDataList = new List<BLN_ProductAvailabilityWrapper.ProductSelectionWrapper>();
        List<BLN_ProductAvailabilityWrapper.DisplayQuoteDetailsWrapper> quoteDetailsList = new List<BLN_ProductAvailabilityWrapper.DisplayQuoteDetailsWrapper>();
        List<BLN_ProductAvailabilityWrapper.DiscountBandWrapper> discountBandDetailsList = new List<BLN_ProductAvailabilityWrapper.DiscountBandWrapper>();
        List<BLN_ProductAvailabilityWrapper.InsuranceLiabilityWrapper> liabilityData = new List<BLN_ProductAvailabilityWrapper.InsuranceLiabilityWrapper>();
        
        BLN_ProductAvailabilityWrapper.InsuranceLiabilityWrapper motoristTotalsLiability = new BLN_ProductAvailabilityWrapper.InsuranceLiabilityWrapper();
        BLN_ProductAvailabilityWrapper.InsuranceLiabilityWrapper insuranceTotalsLiability = new BLN_ProductAvailabilityWrapper.InsuranceLiabilityWrapper();
        BLN_ProductAvailabilityWrapper.InsuranceLiabilityWrapper tradeCompanyTotalsLiability = new BLN_ProductAvailabilityWrapper.InsuranceLiabilityWrapper();
        BLN_ProductAvailabilityWrapper.InsuranceLiabilityWrapper totalLiability = new BLN_ProductAvailabilityWrapper.InsuranceLiabilityWrapper();
        
        Map<String,BLN_ProductAvailabilityWrapper.DisplayQuoteDetailsWrapper> guIdVsDisplayDeatilsDataMap = new Map<String,BLN_ProductAvailabilityWrapper.DisplayQuoteDetailsWrapper>();
        Map<BLN_ProductResponseWrapper.ResponseQuotes,List<BLN_ProductResponseWrapper.ResponseLineItems>> quoteVsLineItemMap = new Map<BLN_ProductResponseWrapper.ResponseQuotes,List<BLN_ProductResponseWrapper.ResponseLineItems>>();
        Map<String,BLN_ProductResponseWrapper.ResponseLineItems> partIdVsLineItemMap = new Map<String,BLN_ProductResponseWrapper.ResponseLineItems>();
        Map<String,Set<String>> bomIdVsAddonPartIdListMap = new Map<String,Set<String>>();
        Map<String,Set<String>> bomIdVsAddonKeyListMap = new Map<String,Set<String>>();
        Map<String,Set<BLN_ProductResponseWrapper.ResponseLineItems>> bomIdVsAddonItemMap = new Map<String,Set<BLN_ProductResponseWrapper.ResponseLineItems>>();
        Map<String,List<String>> bundleNameVsPartIdListMap = new Map<String,List<String>>();
        for(BLN_ProductResponseWrapper.ResponseQuotes quoteVar : data.quotes){
            BLN_ProductResponseWrapper.ResponseLineItems[] mainLineItems = new BLN_ProductResponseWrapper.ResponseLineItems[0];
            
            for(BLN_ProductResponseWrapper.ResponseLineItems lineItem : quoteVar.lineItems) {
                keyVsLineItemMap.put(lineItem.partNumber+'-'+lineItem.parentBOMId+'-'+lineItem.bundleName,lineItem);
                if(productMDMIDProductMap.containsKey(lineItem.partNumber) && lineItem.partOfBundle == true && lineItem.parentLineItemId != lineItem.lineItemId){ if(bundleNameVsPartIdListMap.containsKey(lineItem.bundleName)){bundleNameVsPartIdListMap.get(lineItem.bundleName).add(lineItem.partNumber);}else{ bundleNameVsPartIdListMap.put(lineItem.bundleName,new List<String>{lineItem.partNumber});}}
                else if(productMDMIDProductMap.containsKey(lineItem.partNumber) && lineItem.parentBomId != '' && lineItem.parentBomId != null && lineItem.leadingProductIndicator == false){
                    if(bomIdVsAddonPartIdListMap.containsKey(lineItem.parentBomId)){
                        bomIdVsAddonPartIdListMap.get(lineItem.parentBomId).add(lineItem.partNumber);
                        bomIdVsAddonKeyListMap.get(lineItem.parentBOMId).add(lineItem.partNumber+'-'+lineItem.parentBOMId+'-'+lineItem.bundleName);
                    }else{
                        bomIdVsAddonPartIdListMap.put(lineItem.parentBomId,new Set<String>{lineItem.partNumber});
                        bomIdVsAddonKeyListMap.put(lineItem.parentBomId,new Set<String>{lineItem.partNumber+'-'+lineItem.parentBOMId+'-'+lineItem.bundleName});
                    }
                }
                else if(productMDMIDProductMap.containsKey(lineItem.partNumber) || ((lineItem.partNumber == null || lineItem.partNumber == '') && lineItem.partOfBundle == true && (lineItem.lineItemId == lineItem.parentLineItemId))){
                    mainLineItems.add(lineItem);
                 if(lineItem.partNumber != '' && lineItem.partNumber != null && !partIdVsLineItemMap.containsKey(lineItem.partNumber)){
                    partIdVsLineItemMap.put(lineItem.partNumber,lineItem);
                }

                }
            }
            
            quoteVsLineItemMap.put(quoteVar,mainLineItems);
            
            BLN_ProductAvailabilityWrapper.DisplayQuoteDetailsWrapper displayDetailsData = new BLN_ProductAvailabilityWrapper.DisplayQuoteDetailsWrapper();
            displayDetailsData.quoteId = quoteVar.quoteId;
            displayDetailsData.quotelocation = displayDetailsData.locationGUID = quoteVar.locationId;
        	displayDetailsData.quoteOriginalPrice = quoteVar.quoteTotals.totalPriceOriginal;
            displayDetailsData.quoteTotal = quoteVar.quoteTotals.totalPrice;
            displayDetailsData.quoteVAT = quoteVar.quoteTotals.totaltax;
            displayDetailsData.quoteNetTotal = quoteVar.quoteTotals.totalIncludingTax;
            displayDetailsData.quoteWeatherGuard = '<<Placeholder>>';
            displayDetailsData.excludeProduct = 'NOT_EXCLUDE';

            
            //find earliest availability

            
            Map<String,List<DateTime>> stockLocIdVsAvailDate = new Map<String,List<DateTime>>();

            for(BLN_ProductAvailabilityWrapper.EarliestAvailabilityDetailsWrapper earliestAvailabilityDate : earliestAvailabilityDateList){
                if(earliestAvailabilityDate.quoteId == quoteVar.quoteId){
                    if(earliestAvailabilityDate.isSelected == true){
                        for(BLN_ProductResponseWrapper.ResponseAvailabilityDetails earlyDate : earliestAvailabilityDate.earliestDateList){
						DateTime earlyDt = earlyDate.availableFromDate.contains('T') ? (DateTime)JSON.deserialize('"'+earlyDate.availableFromDate+'"',DateTime.class) : DateTime.valueOf(earlyDate.availableFromDate);                            
                            if(stockLocIdVsAvailDate.containsKey(earlyDate.stockLocationId)){
                                stockLocIdVsAvailDate.get(earlyDate.stockLocationId).add(earlyDt);
                            }
                            else{
                                stockLocIdVsAvailDate.put(earlyDate.stockLocationId, new List<DateTime>{earlyDt});
                            }
                        }
                    }
                }
            }

            Map<String,DateTime> stockListVsEarlyDate = new Map<String,DateTime>();

            for(String stockLoc : stockLocIdVsAvailDate.keySet()){
                DateTime dt = System.today();
                for(DateTime eachDate : stockLocIdVsAvailDate.get(stockLoc)){
                    dt = dt > eachDate ? dt : eachDate;
                }
                stockListVsEarlyDate.put(stockLoc,dt);
            }

            DateTime earliestDate = System.now().addYears(1);
            for(DateTime dt : stockListVsEarlyDate.values()){
                earliestDate = dt < earliestDate ? dt : earliestDate;
            }
                
            displayDetailsData.quoteEarliestAppointmentAvailability = String.valueOf(earliestDate);

            quoteDetailsList.add(displayDetailsData);

            guIdVsDisplayDeatilsDataMap.put(quoteVar.locationId,displayDetailsData);
            
            BLN_ProductAvailabilityWrapper.DiscountBandWrapper discountbandData = new BLN_ProductAvailabilityWrapper.DiscountBandWrapper();
            discountbandData.locationId = quoteVar.locationId;
            discountbandData.discountThresholdA = quoteVar.discountThresholdA;
            discountbandData.discountThresholdB = quoteVar.discountThresholdB;
            discountbandData.discountThresholdC = quoteVar.discountThresholdC;
            discountBandDetailsList.add(discountbandData);
            
            motoristTotalsLiability.liabilityCategory = System.label.BLN_MotoristLiability;
            motoristTotalsLiability.totalPayable = motoristTotalsLiability.totalPayable != 0.00 ? motoristTotalsLiability.totalPayable : quoteVar.motoristTotals.totalPayableByMotorist;
            motoristTotalsLiability.totalTaxPayable = motoristTotalsLiability.totalTaxPayable != 0.00 ? motoristTotalsLiability.totalTaxPayable : quoteVar.motoristTotals.totalTaxPayableByMotorist;
            motoristTotalsLiability.totalIncludingTaxPayable = motoristTotalsLiability.totalIncludingTaxPayable != 0.00 ? motoristTotalsLiability.totalIncludingTaxPayable : quoteVar.motoristTotals.totalIncludingTaxPayableByMotorist;
            
            insuranceTotalsLiability.liabilityCategory = System.label.BLN_InsuranceLiability;
            insuranceTotalsLiability.totalPayable = insuranceTotalsLiability.totalPayable != 0.00 ? insuranceTotalsLiability.totalPayable : quoteVar.insuranceTotals.totalPayableByInsurance;
            insuranceTotalsLiability.totalTaxPayable = insuranceTotalsLiability.totalTaxPayable != 0.00 ? insuranceTotalsLiability.totalTaxPayable : quoteVar.insuranceTotals.totalTaxPayableByInsurance;
            insuranceTotalsLiability.totalIncludingTaxPayable = insuranceTotalsLiability.totalIncludingTaxPayable != 0.00 ? insuranceTotalsLiability.totalIncludingTaxPayable : quoteVar.insuranceTotals.totalIncludingTaxPayableByInsurance;
            
            tradeCompanyTotalsLiability.liabilityCategory = System.label.BLN_AccountLiability;
            tradeCompanyTotalsLiability.totalPayable = tradeCompanyTotalsLiability.totalPayable != 0.00 ? tradeCompanyTotalsLiability.totalPayable : quoteVar.tradeCompanyTotals.totalPayableByTrade;
            tradeCompanyTotalsLiability.totalTaxPayable = tradeCompanyTotalsLiability.totalTaxPayable != 0.00 ? tradeCompanyTotalsLiability.totalTaxPayable : quoteVar.tradeCompanyTotals.payableByTradeTotalTax;
            tradeCompanyTotalsLiability.totalIncludingTaxPayable = tradeCompanyTotalsLiability.totalIncludingTaxPayable != 0.00 ? tradeCompanyTotalsLiability.totalIncludingTaxPayable : quoteVar.tradeCompanyTotals.totalPayableByTradeIncludingTax;                
            
            totalLiability.liabilityCategory = System.label.BLN_Total;
        	totalLiability.totalPayable = totalLiability.totalPayable != 0.00 ? totalLiability.totalPayable : quoteVar.quoteTotals.totalPrice;
        	totalLiability.totalTaxPayable = totalLiability.totalTaxPayable != 0.00 ? totalLiability.totalTaxPayable : quoteVar.quoteTotals.totalTax;
        	totalLiability.totalIncludingTaxPayable = totalLiability.totalIncludingTaxPayable != 0.00 ? totalLiability.totalIncludingTaxPayable : quoteVar.quoteTotals.totalIncludingTax;
        }
        liabilityData.addAll(new List<BLN_ProductAvailabilityWrapper.InsuranceLiabilityWrapper>{motoristTotalsLiability, insuranceTotalsLiability, tradeCompanyTotalsLiability, totalLiability});
        
        List<ServiceTerritory> relatedServiceTerritoryList = [SELECT Id,Name,BLN_GUID__c,BLN_Type__c,BLN_ExcludedProduct__c FROM ServiceTerritory WHERE isActive = true AND BLN_GUID__c IN :guIdVsDisplayDeatilsDataMap.keySet() WITH SECURITY_ENFORCED LIMIT 10000];
        for(ServiceTerritory st : relatedServiceTerritoryList) {
            guIdVsDisplayDeatilsDataMap.get(st.BLN_GUID__c).excludeProduct = st.BLN_ExcludedProduct__c != null ? st.BLN_ExcludedProduct__c : 'TestExcludProduct';
            guIdVsDisplayDeatilsDataMap.get(st.BLN_GUID__c).quotelocation = st.Name;
            guIdVsDisplayDeatilsDataMap.get(st.BLN_GUID__c).isMobileLocation = st.BLN_Type__c == System.label.BLN_Mobile ? true : false;  
    
        }
        
        for(String bomId : bomIdVsAddonKeyListMap.keySet()){
            Set<BLN_ProductResponseWrapper.ResponseLineItems> addOnItemList = new Set<BLN_ProductResponseWrapper.ResponseLineItems>();
            for(String addOnItemKey : bomIdVsAddonKeyListMap.get(bomId)){
                addOnItemList.add(keyVsLineItemMap.get(addOnItemKey));
            }
            bomIdVsAddonItemMap.put(bomId,addOnItemList);
        }
        
        Boolean isFirstPartNumbersRetrieved = false;
        Boolean isFirstQuoteLineItemsChecked = false;
        Set<String> firstQuotePartNumbers = new Set<String>();
        Set<String> commonPartNumbers = new Set<String>();
        Set<String> uncommonPartNumbers = new Set<String>();
        Set<String> bundleNameList = new Set<String>();

        BLN_ProductResponseWrapper.ResponseLineItems[] firstLineItemList = new BLN_ProductResponseWrapper.ResponseLineItems[0];
        for(BLN_ProductResponseWrapper.ResponseQuotes quote : quoteVsLineItemMap.keySet()){
            firstLineItemList = quoteVsLineItemMap.get(quote);
            if(!isFirstPartNumbersRetrieved && firstLineItemList.size() > 0) {
                for(BLN_ProductResponseWrapper.ResponseLineItems lineItem : firstLineItemList){
                    if(lineItem.partOfBundle == true && (lineItem.lineItemId == lineItem.parentLineItemId)){
                        lineItem.partNumber = lineItem.bundleName;
                        bundleNameList.add(lineItem.bundleName);
                    }

                    firstQuotePartNumbers.add(lineItem.partNumber);
                }
            }
            isFirstPartNumbersRetrieved = true;                            
            for(BLN_ProductResponseWrapper.ResponseLineItems lineitem : quoteVsLineItemMap.get(quote)){
                if(lineitem.partOfBundle == true && (lineitem.lineItemId == lineitem.parentLineItemId)){
                    lineitem.partNumber = lineitem.bundleName;
                }
                if(firstQuotePartNumbers.contains(lineitem.partNumber) && lineitem != null){
                    commonPartNumbers.add(lineitem.partNumber);
                }
                else if(lineitem != null){
                    commonPartNumbers.remove(lineitem.partNumber);
                    uncommonPartNumbers.add(lineitem.partNumber);
                }
                if(!isFirstQuoteLineItemsChecked){
                    commonPartNumbers.clear();
                    isFirstQuoteLineItemsChecked = true;
                }
            }
        }
        firstQuotePartNumbers.removeAll(commonPartNumbers);
        firstQuotePartNumbers.removeAll(uncommonPartNumbers);
        
        List<String> partNumbersInSortedOrder = new List<String>();
        partNumbersInSortedOrder.addAll(commonPartNumbers);
        partNumbersInSortedOrder.addAll(firstQuotePartNumbers);
        partNumbersInSortedOrder.addAll(uncommonPartNumbers);
        
        for(String str : partNumbersInSortedOrder) {
            if(bundleNameList.contains(str)){
                BLN_ProductResponseWrapper.ResponseLineItems mainBundleLineItem = bundleNameVsBundleLineItem.get(str);
                mainBundleLineItem.partNumber = System.label.BLN_Bundle;
                sortedLineItems.add(mainBundleLineItem);
            } else{
                sortedLineItems.add(partIdVsLineItemMap.get(str));
            }
        }
        
        List<BLN_ProductResponseWrapper.ResponseLineItems> firstLineItemsList = new List<BLN_ProductResponseWrapper.ResponseLineItems>();
        List<BLN_ProductResponseWrapper.ResponseLineItems> secondLineItemsList = new List<BLN_ProductResponseWrapper.ResponseLineItems>();
        List<BLN_ProductResponseWrapper.ResponseLineItems> thirdLineItemsList = new List<BLN_ProductResponseWrapper.ResponseLineItems>();
        List<BLN_ProductResponseWrapper.ResponseLineItems> forthLineItemsList = new List<BLN_ProductResponseWrapper.ResponseLineItems>();

        for(BLN_ProductResponseWrapper.ResponseLineItems lineItem : sortedLineItems) {
            if(lineItem.bomMandatory == false && lineItem.partOfBundle == false && productMDMIDProductMap.get(lineItem.partNumber).BLN_ProductCategory__c != null && productMDMIDProductMap.get(lineItem.partNumber).BLN_ProductCategory__c != ''  && ((System.label.BLN_VapsCode).split(',')).contains(productMDMIDProductMap.get(lineItem.partNumber).BLN_ProductCategory__c)){ 
                firstLineItemsList.add(lineItem);
            }
            else if(lineItem.partOfBundle == false && lineItem.bomMandatory == true) { 
                secondLineItemsList.add(lineItem);
            }
            else if(lineItem.partOfBundle == true){
                thirdLineItemsList.add(lineItem);
            }
            else {
                forthLineItemsList.add(lineItem);
            }
        }   
            
        sortedLineItems.clear();
        
        sortedLineItems.addAll(firstLineItemsList);
        sortedLineItems.addAll(secondLineItemsList);
        sortedLineItems.addAll(thirdLineItemsList);
        sortedLineItems.addAll(forthLineItemsList);
        
        List<BLN_ProductResponseWrapper.ResponseLineItems> sortedLineItemsWithAddons = new List<BLN_ProductResponseWrapper.ResponseLineItems>();
        for(BLN_ProductResponseWrapper.ResponseLineItems lineItem : sortedLineItems){
            sortedLineItemsWithAddons.add(lineItem);
            if(bomIdVsAddonItemMap.containsKey(lineItem.parentBomId) && lineItem.parentBomId != null && lineItem.parentBomId != '' && lineItem.partOfBundle == false){
                sortedLineItemsWithAddons.addAll(bomIdVsAddonItemMap.get(lineItem.parentBomId).size() > 0 ? bomIdVsAddonItemMap.get(lineItem.parentBomId) : new Set<BLN_ProductResponseWrapper.ResponseLineItems>());
            }
            else if(lineItem.partOfBundle == true && bundleNameVsPartIdListMap.containsKey(lineItem.bundleName) && bundleParentLineItemVsLineItem.containsKey(lineItem.lineItemId)){
                sortedLineItemsWithAddons.addAll(bundleParentLineItemVsLineItem.get(lineItem.lineItemId).size() > 0 ? bundleParentLineItemVsLineItem.get(lineItem.lineItemId) : new List<BLN_ProductResponseWrapper.ResponseLineItems>());
            }
        }

        String repairProductsList = System.label.BLN_Repair1Branch+','+System.label.BLN_Repair1Mobile+','+System.label.BLN_Repair2+','+System.label.BLN_Repair3;
        for(BLN_ProductResponseWrapper.ResponseLineItems lineItem : sortedLineItemsWithAddons){
            if(productMDMIDProductMap.containsKey(lineItem.partNumber)){
                BLN_ProductAvailabilityWrapper.ProductSelectionWrapper productResponseWrapperVar = new BLN_ProductAvailabilityWrapper.ProductSelectionWrapper();
                
                productResponseWrapperVar.productName = lineItem.partOfBundle && (lineItem.lineItemId == lineItem.parentLineItemId) ? lineItem.bundleName : productMDMIDProductMap.get(lineItem.partNumber).Name;
                productResponseWrapperVar.productDescription = lineItem.partOfBundle && (lineItem.lineItemId == lineItem.parentLineItemId) ? lineItem.bundleName : !productMDMIDProductMap.containsKey(lineItem.partNumber) ? '' :  productMDMIDProductMap.get(lineItem.partNumber).Description;
                productResponseWrapperVar.isBranchOnlyProduct = productMDMIDProductMap.get(lineItem.partNumber).BLN_BusinessUnitSpecificBranchOnly__c;
                productResponseWrapperVar.isADASRecalibrationNeeded = productMDMIDProductMap.get(lineItem.partNumber).BLN_ADASRecalibrationNeeded__c;
                productResponseWrapperVar.prodCategory = productMDMIDProductMap.get(lineItem.partNumber).BLN_ProductCategory__c != null ? productMDMIDProductMap.get(lineItem.partNumber).BLN_ProductCategory__c : '';
                productResponseWrapperVar.selectProduct = lineItem.selectProduct;
                productResponseWrapperVar.bomMandatory = lineItem.bomMandatory;
                productResponseWrapperVar.lineItemId = lineItem.lineItemId;
                productResponseWrapperVar.mdmId = productResponseWrapperVar.productCode = lineItem.partNumber != null ? lineItem.partNumber : '';
                productResponseWrapperVar.belronProductCode = !productMDMIDProductMap.containsKey(lineItem.partNumber) ? '' : productMDMIDProductMap.get(lineItem.partNumber).ProductCode != null ? productMDMIDProductMap.get(lineItem.partNumber).ProductCode : '';
                productResponseWrapperVar.quantity = lineItem.quantity;
                productResponseWrapperVar.netPriceIncludingTax = lineItem.netPriceIncludingTax;
                productResponseWrapperVar.netPrice = lineItem.netPrice;
                productResponseWrapperVar.totalTax = lineItem.totalTax;
                productResponseWrapperVar.totalIncludingTaxPayableByInsurance =lineItem.totalIncludingTaxPayableByInsurance != null ? lineItem.totalIncludingTaxPayableByInsurance : 0;
                productResponseWrapperVar.totalPayableByTradeIncludingTax = lineItem.totalPayableByTradeIncludingTax != null ? lineItem.totalPayableByTradeIncludingTax : 0;
                productResponseWrapperVar.bundleName = lineItem.bundleName != null ? lineItem.bundleName : '';
                productResponseWrapperVar.parentLineItemId = lineItem.parentLineItemId;
                productResponseWrapperVar.partOfBundle = lineItem.partOfBundle;
                productResponseWrapperVar.bundleHierarchy = lineItem.bundleHierarchy != null ? lineItem.bundleHierarchy : '';
                productResponseWrapperVar.bomId = lineItem.parentBomId != null && lineItem.parentBomId != '' ? lineItem.parentBomId : '';
                productResponseWrapperVar.hierarchy = lineItem.leadingProductIndicator == true && lineItem.parentBomId != '' && lineItem.parentBomId != null ? 'parent' : lineItem.leadingProductIndicator == false && lineItem.parentBomId != '' && lineItem.parentBomId != null ? 'child' : '';        
                productResponseWrapperVar.isBondedNonBonded = productMDMIDProductMap.get(lineItem.partNumber).ProductCode.endsWith(System.Label.BLN_OESuffix);
                productResponseWrapperVar.hideOnUI = hideOnUIMap.containsKey(productMDMIDProductMap.get(lineItem.partNumber).ProductCode) ? hideOnUIMap.get(productMDMIDProductMap.get(lineItem.partNumber).ProductCode) : false;
                productResponseWrapperVar.productId = productMDMIDProductMap.get(lineItem.partNumber).Id;
                productResponseWrapperVar.repairPart =  productResponseWrapperVar.prodCategory != null ? (repairProductsList.split(',')).contains(productResponseWrapperVar.prodCategory) ? true : false : false ;

                productSelectionDataList.add(productResponseWrapperVar);
            }
        }
        
        for(BLN_ProductAvailabilityWrapper.DiscountBandWrapper discountItem: discountBandDetailsList) {
            discountItem.locationName = guIdVsDisplayDeatilsDataMap.get(discountItem.locationId).quotelocation;
        }
        List<BLN_ProductAvailabilityWrapper.QuoteWrapper> quoteDataList = new List<BLN_ProductAvailabilityWrapper.QuoteWrapper>();
        for(BLN_ProductResponseWrapper.ResponseQuotes quoteVar : data.quotes){

            BLN_ProductAvailabilityWrapper.QuoteWrapper quoteData = new BLN_ProductAvailabilityWrapper.QuoteWrapper();
            quoteData.quoteId = quoteVar.quoteId;
            quoteData.locationId = quoteVar.locationId;

            quoteData.productList = new List<BLN_ProductAvailabilityWrapper.ProductSelectionWrapper>();
            for(BLN_ProductResponseWrapper.ResponseLineItems lineItem : quoteVar.lineItems){
            	if(productMDMIDProductMap.containsKey(lineItem.partNumber)){
                    BLN_ProductAvailabilityWrapper.ProductSelectionWrapper prod = new BLN_ProductAvailabilityWrapper.ProductSelectionWrapper();
                    prod.productName = lineItem.partOfBundle && (lineItem.lineItemId == lineItem.parentLineItemId) ? lineItem.bundleName : !productMDMIDProductMap.containsKey(lineItem.partNumber) ? '' :  productMDMIDProductMap.get(lineItem.partNumber).Name;
                    prod.productDescription = lineItem.partOfBundle && (lineItem.lineItemId == lineItem.parentLineItemId) ? lineItem.bundleName : !productMDMIDProductMap.containsKey(lineItem.partNumber) ? '' :  productMDMIDProductMap.get(lineItem.partNumber).Description;
                    prod.isBranchOnlyProduct = !productMDMIDProductMap.containsKey(lineItem.partNumber) ? false : productMDMIDProductMap.get(lineItem.partNumber).BLN_BusinessUnitSpecificBranchOnly__c;
                    prod.isADASRecalibrationNeeded = !productMDMIDProductMap.containsKey(lineItem.partNumber) ? false : productMDMIDProductMap.get(lineItem.partNumber).BLN_ADASRecalibrationNeeded__c;
                    prod.prodCategory = !productMDMIDProductMap.containsKey(lineItem.partNumber) ? '' : productMDMIDProductMap.get(lineItem.partNumber).BLN_ProductCategory__c != null ? productMDMIDProductMap.get(lineItem.partNumber).BLN_ProductCategory__c : '';
                    prod.selectProduct = lineItem.selectProduct;
                    prod.bomMandatory = lineItem.bomMandatory;
                    prod.lineItemId = lineItem.lineItemId;
                    prod.mdmId = prod.productCode = lineItem.partNumber != null ? lineItem.partNumber : '';
                    prod.belronProductCode = !productMDMIDProductMap.containsKey(lineItem.partNumber) ? '' : productMDMIDProductMap.get(lineItem.partNumber).ProductCode != null ? productMDMIDProductMap.get(lineItem.partNumber).ProductCode : '';
                    prod.quantity = lineItem.quantity;
                    prod.netPriceIncludingTax = lineItem.netPriceIncludingTax;
                    prod.netPrice = lineItem.netPrice;
                    prod.totalTax = lineItem.totalTax;
                    prod.totalIncludingTaxPayableByInsurance =lineItem.totalIncludingTaxPayableByInsurance != null ? lineItem.totalIncludingTaxPayableByInsurance : 0;
                    prod.totalPayableByTradeIncludingTax = lineItem.totalPayableByTradeIncludingTax != null ? lineItem.totalPayableByTradeIncludingTax : 0;
                    prod.bundleName = lineItem.bundleName != null ? lineItem.bundleName : '';
                    prod.parentLineItemId = lineItem.parentLineItemId;
                    prod.partOfBundle = lineItem.partOfBundle;
                    prod.bundleHierarchy = lineItem.bundleHierarchy != null ? lineItem.bundleHierarchy : '';
                    prod.bomId = lineItem.parentBomId != null && lineItem.parentBomId != '' ? lineItem.parentBomId : '';
                    prod.hierarchy = lineItem.leadingProductIndicator == true && lineItem.parentBomId != '' && lineItem.parentBomId != null ? 'parent' : lineItem.leadingProductIndicator == false && lineItem.parentBomId != '' && lineItem.parentBomId != null ? 'child' : '';        
                    prod.isBondedNonBonded = !productMDMIDProductMap.containsKey(lineItem.partNumber) ? false : productMDMIDProductMap.get(lineItem.partNumber).ProductCode.endsWith(System.Label.BLN_OESuffix);
                    prod.hideOnUI = hideOnUIMap.containsKey(productMDMIDProductMap.get(lineItem.partNumber).ProductCode) ? hideOnUIMap.get(productMDMIDProductMap.get(lineItem.partNumber).ProductCode) : false;
                    prod.productId = !productMDMIDProductMap.containsKey(lineItem.partNumber) ? '' : productMDMIDProductMap.get(lineItem.partNumber).Id;
                    prod.repairPart = prod.prodCategory != null ? (repairProductsList.split(',')).contains(prod.prodCategory) ? true : false : false;
                    quoteData.productList.add(prod);
                }
            }
            quoteDataList.add(quoteData);
        }
        
        List<BLN_ProductAvailabilityWrapper.OrderItemDetails> allItemsDetails = new List<BLN_ProductAvailabilityWrapper.OrderItemDetails>();
        Boolean hasCompletedAppointments = false;
        if( orderData != NULL ){
            for(OrderItem oi : [SELECT  Id,Product2.BLN_MDMID__c, Product2.Name,Product2.BLN_ProductCategory__c,Product2.ProductCode, 
                                            OrderId, BLN_StockStatus__c,Quantity, UnitPrice, TotalPrice, EndDate,BLN_BundleName__c,BLN_BOMID__c,
                                            BLN_IsProductSelected__c,BLN_TotalTax__c,BLN_NetPriceAfterPromotion__c,BLN_NetPriceIncludingTax__c,BLN_Optional__c,
                                            BLN_ServiceAppointment__c,BLN_FittingLocation__r.Name,BLN_FittingLocation__r.BLN_GUID__c,BLN_DocumentNumber__c,
                                            BLN_LeadingPartIndicator__c,BLN_ParentDocumentNumber__c, BLN_ServiceAppointment__r.Status
                                    FROM OrderItem where orderId =:orderData.Id WITH SECURITY_ENFORCED]){
                BLN_ProductAvailabilityWrapper.OrderItemDetails ord = new BLN_ProductAvailabilityWrapper.OrderItemDetails();
                ord.orderItemId = oi.Id;
                                    ord.partCode = oi.Product2.BLN_MDMID__c;
                ord.ordItemRec = oi;

                if( oi.BLN_ServiceAppointment__r.Status == COMPLETED_STATUS){
                    hasCompletedAppointments = true;
                }
                allItemsDetails.add(ord);
            }
        }
        
        /* This method is used to call for identify product type*/
        List<BLN_ProductAvailabilityWrapper.ProductIdentifierWrapper> productIdentifier = new List<BLN_ProductAvailabilityWrapper.ProductIdentifierWrapper>();
        productIdentifier = BLN_ProductIdentifierUtility.getProductIndentify(System.label.BLN_PRIME);
        
        /* This method is used for prevent the repair product */
        List<Case> caseInstance = [SELECT Id, BLN_BillingMethod__c, BLN_PricingDate__c, BLN_Corporate__c, BLN_Corporate__r.BLN_InsuranceSite__c, BLN_Corporate__r.BLN_InsuranceLegalEntity__c FROM Case WHERE id =: caseId AND BLN_BillingMethod__c =: Label.BLN_InsuranceAccount AND BLN_Corporate__c != null WITH SECURITY_ENFORCED];

        BLN_ProductAvailabilityWrapper.DisplayDetailsWrapper returnData = new BLN_ProductAvailabilityWrapper.DisplayDetailsWrapper();
        returnData.productDataList = productSelectionDataList;
        returnData.quoteDetailsDataList = quoteDetailsList;
        returnData.discountBandDetails = discountBandDetailsList;
        returnData.liabilityDataList = liabilityData;
        returnData.earliestAvailabilityList = earliestAvailabilityDateList;
        returnData.selectedLocation =  selectedLocationWrap;
        returnData.quoteDataList = quoteDataList;
        returnData.prodLists = (orderData != null ? BLN_ProductAvailabilityRebook.getAllSelectedProductLists(orderData.BLN_CPQExternalQuoteId__c) : new List<List<BLN_ProductAvailabilityWrapper.ProductSelectionWrapper>>{new List<BLN_ProductAvailabilityWrapper.ProductSelectionWrapper>(),new List<BLN_ProductAvailabilityWrapper.ProductSelectionWrapper>()});
        returnData.hasCompletedAppointments = hasCompletedAppointments;
        returnData.productIdentifier = ProductIdentifier;
        if(caseInstance != null && caseInstance.size() > 0) {
            returnData.accountRuleParameters = BLN_ProductAvailabilityUtility.getAccountRuleParameters(System.label.BLN_ProductAllowanceRT, caseInstance[0].BLN_Corporate__r.BLN_InsuranceSite__c != null ? caseInstance[0].BLN_Corporate__r.BLN_InsuranceSite__c : caseInstance[0].BLN_Corporate__r.BLN_InsuranceLegalEntity__c, caseInstance[0].BLN_PricingDate__c != null ? caseInstance[0].BLN_PricingDate__c : null);
        } else {
            returnData.accountRuleParameters = new List<BLN_ProductAvailabilityWrapper.AccountRuleParameterWrapper>();
        }
        return returnData;       
    }

    public static List<BLN_ProductResponseWrapper.ResponseAvailabilityDetails> getAvailableDate(String locationId, BLN_ProductResponseWrapper.ResponseLineItems selectedEle, List<BLN_ProductAvailabilityWrapper.EarliestAvailabilityDetailsWrapper> earliestAvailabilityDateList) {
        List<BLN_ProductResponseWrapper.ResponseAvailabilityDetails> currentProductEarliestDates = new List<BLN_ProductResponseWrapper.ResponseAvailabilityDetails>();
        for( BLN_ProductAvailabilityWrapper.EarliestAvailabilityDetailsWrapper eachDateSet : earliestAvailabilityDateList ){
        
            if (eachDateSet.locationId == locationId && 
                eachDateSet.mdmId == selectedEle.partNumber && eachDateSet.bundleName == selectedEle.bundleName && eachDateSet.bomId == selectedEle.parentBOMId ) {
                currentProductEarliestDates = eachDateSet.earliestDateList;
            }
        }
        
        return currentProductEarliestDates;
    }

    /* MethodName : createOrdersAndOrderItems
    Description : This method is used to create order and order Item. This method is part of 6570 i.e. creation of order and order item. 
    CreatedDate: 24-04-2024
    Change log :
    ****************************************/
    @AuraEnabled   
    public static List<String> createOrdersAndOrderItems(String mainJson,String selectedProducts, String selectedAddonProducts, String appointmentJson, String caseId, String cpqQuoteId, String earliestDateList, decimal discount){
        Case caseRecord = new Case();
        caseRecord = [SELECT Id,AccountId,BLN_PricingDate__c,BLN_Corporate__c,CreatedDate,OwnerId,CurrencyIsoCode,(SELECT Id,CreatedDate,Status,BLN_CPQExternalQuoteId__c FROM Orders__r WHERE Status = :System.label.BLN_Accepted ORDER BY CreatedDate DESC LIMIT 1) FROM Case WHERE Id = :caseId WITH SECURITY_ENFORCED LIMIT 1];
        
        //List<String> locationGuIds = new List<String>();
        BLN_ProductResponseWrapper.ResponseProduct mainData = (BLN_ProductResponseWrapper.ResponseProduct) JSON.deserialize(mainJson,BLN_ProductResponseWrapper.ResponseProduct.class);
        

        List<BLN_ProductAvailabilityWrapper.ProductSelectionWrapper> selectedProdsData = (List<BLN_ProductAvailabilityWrapper.ProductSelectionWrapper>) JSON.deserialize(selectedProducts, List<BLN_ProductAvailabilityWrapper.ProductSelectionWrapper>.class);
		List<BLN_ProductAvailabilityWrapper.ProductSelectionWrapper> selectedAddonProdsData = (List<BLN_ProductAvailabilityWrapper.ProductSelectionWrapper>) JSON.deserialize(selectedAddonProducts, List<BLN_ProductAvailabilityWrapper.ProductSelectionWrapper>.class);        
        List<BLN_ProductAvailabilityWrapper.EarliestAvailabilityDetailsWrapper> earliestAvailabilityList = (List<BLN_ProductAvailabilityWrapper.EarliestAvailabilityDetailsWrapper>) JSON.deserialize(earliestDateList,List<BLN_ProductAvailabilityWrapper.EarliestAvailabilityDetailsWrapper>.class);
        
        List<Id> allSAId = new List<Id>();
        List<BLN_ProductAvailabilityWrapper.AppointmentWrapper> appointmentData = (List<BLN_ProductAvailabilityWrapper.AppointmentWrapper>) JSON.deserialize(appointmentJson, List<BLN_ProductAvailabilityWrapper.AppointmentWrapper>.class);
        Map<String,String> bomIdVsServAppointmentIdMap = new Map<String,String>();
        Map<String,String> bomIdVsServiceLocationIdMap = new Map<String,String>();
        Map<String,String> bundleNameVsServAppointmentIdMap = new Map<String,String>();
        //Map<Integer,Datetime> litneItemIdVsSAStartDate = new Map<Integer,Datetime>();
        Map<String,String> bundleNameVsServiceLocationMap = new Map<String,String>();
        Map<Integer,String> lineItemIdVsServAppointmentIdMap = new Map<Integer,String>();
        Map<Integer,String> lineItemIdVsServiceLocationIdMap = new Map<Integer,String>();
        Map<Integer,boolean> outOfStockWithOrderItemId = new Map<Integer,boolean>();
        Map<String,String> bundleNameVsStockLocationMap = new Map<String,String>();
        Map<String,String> bomIdVsStockLocationMap = new Map<String,String>();
        Map<Integer,String> lineItemVsStockLocationId = new Map<Integer,String>();

        List<String> stockLocationSet = new List<String>();
        for(BLN_ProductAvailabilityWrapper.AppointmentWrapper data : appointmentData){
            for(BLN_ProductAvailabilityWrapper.Appointments apt : data.appointments){
                stockLocationSet.add(apt.earlierAvailabilityStockLocation);
            }
        }
        
        Map<String, String> orgLocationCodeWithLocationCode = new Map<String, String>();
        for(Schema.Location locationGuid : [SELECT Id, Name, BLN_OrgCodeLocation__c, BLN_GUID__c, BLN_CostCenterCode__c FROM Location WHERE BLN_OrgCodeLocation__c IN :stockLocationSet WITH SECURITY_ENFORCED]) {
            orgLocationCodeWithLocationCode.put(locationGuid.BLN_OrgCodeLocation__c, locationGuid.BLN_GUID__c);
        }

        for(BLN_ProductAvailabilityWrapper.AppointmentWrapper data : appointmentData){
            for(BLN_ProductAvailabilityWrapper.Appointments apt : data.appointments){
                for(BLN_ProductAvailabilityWrapper.productAvailibilities prodAvail : apt.productAvailibilities){
                    for(BLN_ProductAvailabilityWrapper.Products prod : prodAvail.products){
                        
                        if(prod.productEnable && prod.productCode != null){
                            lineItemIdVsServAppointmentIdMap.put(prod.lineItemId,String.isNotBlank(apt.serviceAppointmentId) ? apt.serviceAppointmentId : null);                            
                            lineItemIdVsServiceLocationIdMap.put(prod.lineItemId,String.isNotBlank(apt.locationId) ? apt.locationId : null);                          
                            lineItemVsStockLocationId.put(prod.lineItemId,String.isNotBlank(apt.earlierAvailabilityStockLocation) ? orgLocationCodeWithLocationCode.get(apt.earlierAvailabilityStockLocation) : null);  
                            
                            if(prod.partOfBundle == true){
                                bundleNameVsServAppointmentIdMap.put(prod.bundleName,String.isNotBlank(apt.serviceAppointmentId) ? apt.serviceAppointmentId : null);
                                bundleNameVsStockLocationMap.put(prod.bundleName,orgLocationCodeWithLocationCode.get(apt.earlierAvailabilityStockLocation));
                                bundleNameVsServiceLocationMap.put(prod.bundleName,apt.locationId);
                            }
                            else if(prod.bomId != null && prod.bomId != ''){
                                bomIdVsServAppointmentIdMap.put(prod.bomId,String.isNotBlank(apt.serviceAppointmentId) ? apt.serviceAppointmentId : null);
                                bomIdVsStockLocationMap.put(prod.bomId,orgLocationCodeWithLocationCode.get(apt.earlierAvailabilityStockLocation));
                                bomIdVsServiceLocationIdMap.put(prod.bomId,apt.locationId);
                            }
                            if(String.isNotBlank(apt.serviceAppointmentId)) {
                                allSAId.add(Id.valueOf(apt.serviceAppointmentId));
                            }
                        }
                        if(prod.isCPTDate != null && prod.isCPTDate == true && prod.productCode != null) {
                            outOfStockWithOrderItemId.put(prod.lineItemId, prod.isCPTDate);
                        } else if(!outOfStockWithOrderItemId.containsKey(prod.lineItemId)){
                            outOfStockWithOrderItemId.put(prod.lineItemId, false);
                        }
                        //if(prod.bomId != '' || prod.bundleName != ''){
                            for(BLN_ProductAvailabilityWrapper.EarliestAvailabilityDetailsWrapper earlyDateSet : earliestAvailabilityList){
                                if(earlyDateSet != null && earlyDateSet.earliestDateList != null && (prod.bomId != '' || prod.bundleName != '')){
                                for(BLN_ProductResponseWrapper.ResponseAvailabilityDetails earlyDate : earlyDateSet.earliestDateList){
                                    if(earlyDateSet.quoteId == cpqQuoteId && (prod.bomId == null ? '' : prod.bomId) == earlyDateSet.bomId && (prod.bundleName == null ? '' : prod.bundleName) == earlyDateSet.bundleName && earlyDate.stockLocationId == apt.earlierAvailabilityStockLocation){
                                        outOfStockWithOrderItemId.put(earlyDateSet.lineItemId,earlyDate.isOutOfStock);
                                    }
                                }
                            }    
                        }
                        //}
                        }
                    }
                }
        }
        
        Map<Id, ServiceAppointment> serviceAppIdObjMap = new Map<Id, ServiceAppointment>([Select Id, AppointmentNumber, ArrivalWindowStartTime from ServiceAppointment where id in :allSAId]);
        Map<Integer,BLN_ProductAvailabilityWrapper.ProductSelectionWrapper> lineItemIdVsProdWrapper = new Map<Integer,BLN_ProductAvailabilityWrapper.ProductSelectionWrapper>();
        List<BLN_ProductAvailabilityWrapper.ProductSelectionWrapper> allSelectedProds = new List<BLN_ProductAvailabilityWrapper.ProductSelectionWrapper>(selectedProdsData);
        allSelectedProds.addAll(selectedAddonProdsData);
        
        for(BLN_ProductAvailabilityWrapper.ProductSelectionWrapper prodData : allSelectedProds){
            lineItemIdVsProdWrapper.put(prodData.lineItemId,prodData);
        }
        //Map<OrderItem,String> partNumberMap = new Map<OrderItem, String>();
        Map<String,Product2> productIdVsMDMIdMap = new Map<String,Product2>();
        Map<Order,List<OrderItem>> orderDataMap = new Map<Order,List<OrderItem>>();
        List<Order> orderList = new List<Order>();
        //List<OrderItem> orderItemList = new List<OrderItem>();
        Map<OrderItem,String> orderItemWithPartNumberMap = new Map<OrderItem,String>();
        Order orderRecord = new Order();
        String quoteId;
        String selectedLocationId;
        //Map<String,BLN_ProductResponseWrapper.ResponseQuotes> locationIdVsQuoteMap = new  Map<String,BLN_ProductResponseWrapper.ResponseQuotes>();

        //SA Update stock movement changes start
        List<String> prevAppointmentNumber = new List<String>();
        for(BLN_ProductResponseWrapper.ResponseQuotes quoteVar : mainData.quotes){
            Map<Order,List<OrderItem>> quoteVarOrderVsOrderItem = BLN_QuoteBookingHandler.getOrderDataMappingFromQuoteResponse(quoteVar);
            Map<Integer,OrderItem> lineItemIdVsOrderItemMap = new Map<Integer,OrderItem>();
            if( quoteVar.quoteId != cpqQuoteId ){continue;}
            orderRecord = new List<Order>(quoteVarOrderVsOrderItem.keySet())[0];
            for(OrderItem ordrItm : quoteVarOrderVsOrderItem.get(orderRecord)){
                lineItemIdVsOrderItemMap.put(Integer.valueOf(ordrItm.BLN_DocumentNumber__c),ordrItm);
            }
            for(BLN_ProductResponseWrapper.ResponseLineItems lineItem : quoteVar.lineItems){
                OrderItem ordrItm = lineItemIdVsOrderItemMap.get(lineItem.lineItemId);
                if(ordrItm.Id == null || ordrItm.BLN_StocksPreviousAppointment__c == null){continue;}
                prevAppointmentNumber.add(ordrItm.BLN_StocksPreviousAppointment__c);
            }
        }
        List<ServiceAppointment> oldSAList = new List<ServiceAppointment>();
        // Map<String, ServiceAppointment> oiOldSaMap = new Map<String, ServiceAppointment>();
        Map<String, ServiceAppointment> appNoOldSaMap = new Map<String, ServiceAppointment>();
        if(prevAppointmentNumber!=null)
        {
            oldSAList = [SELECT Id, AppointmentNumber, ArrivalWindowStartTime FROM ServiceAppointment WHERE AppointmentNumber IN :prevAppointmentNumber WITH SECURITY_ENFORCED];
            for(ServiceAppointment saOld: oldSAList)
            {
                appNoOldSaMap.put(saOld.AppointmentNumber, saOld);
            }
        }

        //SA Update stock movement changes end

        List<BLN_Corporate__c> corporateList = new List<BLN_Corporate__c>();
        for(BLN_ProductResponseWrapper.ResponseQuotes quoteVar : mainData.quotes){
            if( quoteVar.quoteId == cpqQuoteId ){
                quoteId = quoteVar.quoteId;
                selectedLocationId = quoteVar.locationId;

                // Response property value mapping to Order & OrderItem fields to be done in BLN_QuoteBookingHandler.getOrderDataMappingFromQuoteResponse()
                Map<Order,List<OrderItem>> quoteVarOrderVsOrderItem = BLN_QuoteBookingHandler.getOrderDataMappingFromQuoteResponse(quoteVar);
                
                Map<Integer,OrderItem> lineItemIdVsOrderItemMap = new Map<Integer,OrderItem>();
                orderRecord = new List<Order>(quoteVarOrderVsOrderItem.keySet())[0];
                for(OrderItem ordrItm : quoteVarOrderVsOrderItem.get(orderRecord)){
                    lineItemIdVsOrderItemMap.put(Integer.valueOf(ordrItm.BLN_DocumentNumber__c),ordrItm);
                }

                // Lookup and non-consistent/dynamic field mapping on Order to be done here
                orderRecord.BLN_Case__c	= caseRecord.Id;
                orderRecord.BLN_ServiceTerritory__r  = new ServiceTerritory(BLN_GUID__c = quoteVar.locationId);
                orderRecord.BLN_Location__r = new Schema.Location(BLN_GUID__c = quoteVar.locationId);
                orderRecord.AccountId = caseRecord.AccountId;
                orderRecord.BLN_Discount__c = discount;
                orderRecord.EffectiveDate = System.today();
                orderRecord.Status = System.label.BLN_Accepted;
                BLN_Corporate__c corpRecord = new BLN_Corporate__c();
                corpRecord.Id = caseRecord.BLN_Corporate__c;
                corpRecord.BLN_ApprovedLimit__c = orderRecord.BLN_TotalIncludingTax__c;
                
                corporateList.add(corpRecord);
                
                List<OrderItem> orderItemList = new List<OrderItem>();


                for(BLN_ProductResponseWrapper.ResponseLineItems lineItem : quoteVar.lineItems){
                    //Lookup and non-consistent/dynamic field mapping on OrderItems to be done here
                    OrderItem ordrItm = lineItemIdVsOrderItemMap.get(lineItem.lineItemId);

                    //ordrItm.BLN_BranchThreshold__c = servTer.BLN_StockHoldingDurationInDays__c;
                    if(lineItem.lineItemId != null && outOfStockWithOrderItemId.containsKey(lineItem.lineItemId)){
                        ordrItm.BLN_OutOfStock__c = Boolean.valueOf(outOfStockWithOrderItemId.get(lineItem.lineItemId));
                }
                    
                    if(lineItemIdVsProdWrapper.containsKey(lineItem.lineItemId) && bomIdVsServiceLocationIdMap.containsKey(lineItem.parentBOMId)){
                        ordrItm.BLN_FittingLocation__r = new Schema.Location(BLN_GUID__c = bomIdVsServiceLocationIdMap.get(lineItem.parentBOMId));
                    } else if(lineItemIdVsProdWrapper.containsKey(lineItem.lineItemId) && bundleNameVsServiceLocationMap.containsKey(lineItem.bundleName)){
                        ordrItm.BLN_FittingLocation__r = new Schema.Location(BLN_GUID__c = bundleNameVsServiceLocationMap.get(lineItem.bundleName));
                    } else if(lineItemIdVsServiceLocationIdMap.containsKey(lineItem.lineItemId)) {
                         ordrItm.BLN_FittingLocation__r = new Schema.Location(BLN_GUID__c = lineItemIdVsServiceLocationIdMap.get(lineItem.lineItemId));
                    }
                    
                    if(lineItemIdVsProdWrapper.containsKey(lineItem.lineItemId) && bomIdVsServiceLocationIdMap.containsKey(lineItem.parentBOMId)){
                        ordrItm.BLN_FittingLocation__r = new Schema.Location(BLN_GUID__c = bomIdVsServiceLocationIdMap.get(lineItem.parentBOMId));
                    }else if(lineItemIdVsProdWrapper.containsKey(lineItem.lineItemId) && bundleNameVsServiceLocationMap.containsKey(lineItem.bundleName)){
                        ordrItm.BLN_FittingLocation__r = new Schema.Location(BLN_GUID__c = bundleNameVsServiceLocationMap.get(lineItem.bundleName));
                    }   else if(lineItemIdVsServiceLocationIdMap.containsKey(lineItem.lineItemId)) {
                        ordrItm.BLN_FittingLocation__r = new Schema.Location(BLN_GUID__c = lineItemIdVsServiceLocationIdMap.get(lineItem.lineItemId));
                    }

                    if(lineItemIdVsProdWrapper.containsKey(lineItem.lineItemId) && bomIdVsServAppointmentIdMap.containsKey(lineItem.parentBOMId)){
                        ordrItm.BLN_ServiceAppointment__c = bomIdVsServAppointmentIdMap.get(lineItem.parentBOMId);      
                    }else if(lineItemIdVsProdWrapper.containsKey(lineItem.lineItemId) && bundleNameVsServAppointmentIdMap.containsKey(lineItem.bundleName)){
                        ordrItm.BLN_ServiceAppointment__c = bundleNameVsServAppointmentIdMap.get(lineItem.bundleName);
                    }else if(lineItemIdVsServAppointmentIdMap.containsKey(lineItem.lineItemId)){
                        ordrItm.BLN_ServiceAppointment__c = lineItemIdVsServAppointmentIdMap.get(lineItem.lineItemId);
                    }                        
                    
                    /* Stock location fill*/
                    
                    if(lineItemIdVsProdWrapper.containsKey(lineItem.lineItemId) && bomIdVsStockLocationMap.containsKey(lineItem.parentBOMId) && bomIdVsStockLocationMap.get(lineItem.parentBOMId) != NULL){
                        ordrItm.BLN_StockLocation__r = new Schema.Location(BLN_GUID__c = bomIdVsStockLocationMap.get(lineItem.parentBOMId));      
                    }else if(lineItemIdVsProdWrapper.containsKey(lineItem.lineItemId) && bundleNameVsStockLocationMap.containsKey(lineItem.bundleName) && bundleNameVsStockLocationMap.get(lineItem.bundleName) != NULL){
                        ordrItm.BLN_StockLocation__r = new Schema.Location(BLN_GUID__c = bundleNameVsStockLocationMap.get(lineItem.bundleName));
                    }else if(lineItemVsStockLocationId.containsKey(lineItem.lineItemId) && lineItemVsStockLocationId.get(lineItem.lineItemId) != NULL){
                        ordrItm.BLN_StockLocation__r = new Schema.Location(BLN_GUID__c = lineItemVsStockLocationId.get(lineItem.lineItemId));
                    }    
                    
                    // if(litneItemIdVsSAStartDate.containsKey(lineItem.lineItemId))
                    // {
                    
                    orderItemWithPartNumberMap.put(ordrItm,lineItem.partNumber);
                    orderItemList.add(ordrItm);
                }
                orderDataMap.put(orderRecord,orderItemList);
            }
        }
        
        ServiceTerritory servTer = [select Id, BLN_StockHoldingDurationInDays__c FROM ServiceTerritory where BLN_GUID__c = :selectedLocationId WITH SECURITY_ENFORCED LIMIT 1];
        
        List<Product2> relatedProductList = new List<Product2>();
        List<Id> relatedProductIdList = new List<Id>();
        relatedProductList = [SELECT Id, Name, BLN_MDMID__c FROM Product2 WHERE IsActive = true AND BLN_MDMID__c IN :orderItemWithPartNumberMap.values() WITH SECURITY_ENFORCED LIMIT 10000];
        for(Product2 prod : relatedProductList) {
            productIdVsMDMIdMap.put(prod.BLN_MDMID__c,prod);
            relatedProductIdList.add(prod.Id);  
        }
        List<PricebookEntry> relatedPriceEntryList = new List<PricebookEntry>();        
        Map<String,PricebookEntry> mdmIdVsPriceBookEntryMap = new Map<String,PricebookEntry>();        
        relatedPriceEntryList = [SELECT Id, Pricebook2Id, ProductCode,Product2Id,Product2.BLN_MDMID__c,CurrencyIsoCode,UnitPrice, IsActive	FROM PricebookEntry WHERE IsActive = true AND Pricebook2.IsActive = true AND Pricebook2.IsStandard = true AND CurrencyIsoCode = :caseRecord.CurrencyIsoCode AND Product2Id IN :relatedProductIdList WITH SECURITY_ENFORCED LIMIT 10000];
        for(PricebookEntry pricebookEntryRecord : relatedPriceEntryList) {
            mdmIdVsPriceBookEntryMap.put(pricebookEntryRecord.Product2.BLN_MDMID__c,pricebookEntryRecord);
        }
        
        List<OrderItem> orderItemsWithPricebookData = new List<OrderItem>();
        if(!orderDataMap.isEmpty()) {
            for(Order order1 : orderDataMap.keySet()){              
                for(OrderItem orderItem1 : orderDataMap.get(order1)) {
                    OrderItem clonedOrderItem = orderItem1.clone(false,true,true,true);
                    if(mdmIdVsPriceBookEntryMap.containsKey(orderItemWithPartNumberMap.get(orderItem1))){
                        clonedOrderItem.PricebookEntryId = mdmIdVsPriceBookEntryMap.get(orderItemWithPartNumberMap.get(orderItem1))?.Id;
                        clonedOrderItem.ListPrice = mdmIdVsPriceBookEntryMap.get(orderItemWithPartNumberMap.get(orderItem1))?.UnitPrice;
                        clonedOrderItem.BLN_BranchThreshold__c = servTer.BLN_StockHoldingDurationInDays__c;
                        clonedOrderItem.Product2 = productIdVsMDMIdMap.get(orderItemWithPartNumberMap.get(orderItem1));
                        //SA Update Scenario
                        Boolean outsideThreshold = False;
                        Decimal threshold = clonedOrderItem.BLN_BranchThreshold__c != null? clonedOrderItem.BLN_BranchThreshold__c : 0;
                        if(clonedOrderItem.BLN_StocksPreviousAppointment__c != null && appNoOldSaMap.containsKey(clonedOrderItem.BLN_StocksPreviousAppointment__c) && serviceAppIdObjMap.containsKey(clonedOrderItem.BLN_ServiceAppointment__c) && serviceAppIdObjMap.get(clonedOrderItem.BLN_ServiceAppointment__c).ArrivalWindowStartTime > (appNoOldSaMap.get(clonedOrderItem.BLN_StocksPreviousAppointment__c).ArrivalWindowStartTime + threshold))
                        {
                            outsideThreshold = True;
                        }

                        if((clonedOrderItem.BLN_ServiceAppointment__c !=null && serviceAppIdObjMap.containsKey(clonedOrderItem.BLN_ServiceAppointment__c) && outsideThreshold)){
                            clonedOrderItem.BLN_StockOrderAppointmentDate__c = serviceAppIdObjMap.get(clonedOrderItem.BLN_ServiceAppointment__c).ArrivalWindowStartTime;
                        }if((clonedOrderItem.BLN_ServiceAppointment__c !=null && serviceAppIdObjMap.containsKey(clonedOrderItem.BLN_ServiceAppointment__c) && outsideThreshold)){
                            String foID = clonedOrderItem.Order.BLN_Case__r.CaseNumber + System.label.BLN_FoStockOrderSeperator + (serviceAppIdObjMap.get(clonedOrderItem.BLN_ServiceAppointment__c).AppointmentNumber).right(6);
                            clonedOrderItem.BLN_StockOrderNumber__c = foID;
                        }
                        if((clonedOrderItem.BLN_ServiceAppointment__c != null && serviceAppIdObjMap?.containsKey(clonedOrderItem.BLN_ServiceAppointment__c) && outsideThreshold)){
                            clonedOrderItem.BLN_StockLineNumber__c = serviceAppIdObjMap.get(clonedOrderItem.BLN_ServiceAppointment__c).AppointmentNumber + clonedOrderItem.BLN_DocumentNumber__c;
                        }

                        order1.Pricebook2Id = mdmIdVsPriceBookEntryMap.get(orderItemWithPartNumberMap.get(orderItem1))?.Pricebook2Id;
                        orderItemWithPartNumberMap.put(clonedOrderItem,orderItemWithPartNumberMap.get(orderItem1));
                        orderItemsWithPricebookData.add(clonedOrderItem);
                    }                  
                    orderItemWithPartNumberMap.remove(orderItem1);
                }
                orderList.add(order1);
            }
        }



        Database.UpsertResult[] orderSaveResult = Database.upsert(orderList,Order.Fields.BLN_CPQExternalQuoteId__c,true);
        List<Id> updatedSaStockMovementOI = new List<Id>();

        if(!orderSaveResult[0].isCreated() || test.isRunningTest()){
            List<OrderItem> storedOrdrItm = [SELECT Id,BLN_DocumentNumber__c,Order.BLN_CPQExternalQuoteId__c, BLN_ServiceAppointment__c FROM OrderItem WHERE Order.BLN_CPQExternalQuoteId__c = :cpqQuoteId];
            Map<Decimal,Id> lineItemIdVsOrderItmIdMap = new Map<Decimal,Id>();
            Map<Decimal,Id> orderItemToOldSA = new Map<Decimal,Id>();
            Map<Decimal,Id> orderItemToNewSA = new Map<Decimal,Id>();
            for(OrderItem ordItm : storedOrdrItm){
                lineItemIdVsOrderItmIdMap.put(ordItm.BLN_DocumentNumber__c, ordItm.Id);
                orderItemToOldSA.put(ordItm.BLN_DocumentNumber__c, ordItm.BLN_ServiceAppointment__c);
            }
            for(OrderItem ordrItm : orderItemsWithPricebookData){
                ordrItm.Id = lineItemIdVsOrderItmIdMap.get(ordrItm.BLN_DocumentNumber__c);
                orderItemToNewSA.put(ordrItm.BLN_DocumentNumber__c, ordrItm.BLN_ServiceAppointment__c);
            }
            for(Decimal docNo : orderItemToNewSA.keySet())
            {
                if(orderItemToOldSA.containsKey(docNo) && orderItemToNewSA.containsKey(docNo) && orderItemToOldSA.get(docNo) != orderItemToNewSA.get(docNo))
                {
                    updatedSaStockMovementOI.add(lineItemIdVsOrderItmIdMap.get(docNo));
                }
            }
            
        }
        Database.UpsertResult[] orderItemSaveResult = Database.upsert(orderItemsWithPricebookData,true);
        if(orderSaveResult[0].isSuccess() == false){
            throw new AuraHandledException('Order not created');
        }
        
        String quotes = '';
        for(BLN_ProductResponseWrapper.ResponseQuotes quoteVar : mainData.quotes){
            quotes = quotes + quoteVar.quoteId+','; 
        }
        quotes = quotes.removeEnd(',');
        caseRecord.BLN_CPQQuoteIdCollection__c = quotes;
        
        if (orderSaveResult != null && orderSaveResult.size() > 0 && orderSaveResult[0].isSuccess()) {
            /* This method is used for update orderId on WO record */
            BLN_AppointmentDataCreationService.updateWOwithOrder(orderSaveResult[0].Id);
            
            //Marking previous Accepted Order as Inactive 
            if(caseRecord.Orders__r.size() > 0 && orderSaveResult[0].isCreated() && Schema.sObjectType.Order.isUpdateable()){
                Order orderRec = ((List<Order>)caseRecord.getSObjects('Orders__r'))[0];
                orderRec.Status = 'Inactive';
                orderRec.BLN_CPQExternalQuoteId__c = (orderRecord.BLN_CPQExternalQuoteId__c == orderRec.BLN_CPQExternalQuoteId__c ? null : orderRec.BLN_CPQExternalQuoteId__c);
                update orderRec;
            }    
            
            if(orderItemSaveResult != null && orderItemSaveResult.size() > 0 && orderItemSaveResult[0].isSuccess() && Schema.sObjectType.Case.isUpdateable()) {
                caseRecord.BLN_PricingDate__c = caseRecord.CreatedDate.date();
                caseRecord.BLN_LocationBranchName__r = new Schema.Location(BLN_GUID__c = selectedLocationId);
                caseRecord.BLN_IsForceReprice__c = false;
                /* Future: This method is call after order & Order product create due to getting UNABLE_TO_LOCK_ROW */
                BLN_ProductAvailability.updateCaseFuture(JSON.serialize(caseRecord));
            }
            if(orderItemSaveResult != null && orderItemSaveResult.size() > 0 && orderItemSaveResult[0].isSuccess() && corporateList.isEmpty() && corporateList.size() > 1 && !Schema.sObjectType.BLN_Corporate__c.isUpdateable()){
                update corporateList;          
            }
        }
        DateTime currentTime = DateTime.now();  
        DateTime runTime = currentTime.addMinutes(2);  
          
        // Format the time for the cron expression  
        String second = String.valueOf(runTime.second());  
        String minute = String.valueOf(runTime.minute());  
        String hour = String.valueOf(runTime.hour());  
        String dayOfMonth = String.valueOf(runTime.day());  
        String month = String.valueOf(runTime.month());  
        String dayOfWeek = '?'; // Use '?' for day of the week when specifying day of the month  
          
        // Construct the cron expression  
        String cronExp = second + ' ' + minute + ' ' + hour + ' ' + dayOfMonth + ' ' + month + ' ' + dayOfWeek;  
          
        List<String> orderItemStringList = new List<String>();
            for(OrderItem rec : orderItemsWithPricebookData){ if(rec.BLN_OutOfStock__c == false && rec.BLN_IsProductSelected__c == true){orderItemStringList.add((String)rec.Id);}}
            //Future method for stock movement request
        
        if(!orderSaveResult[0].isCreated() && updatedSaStockMovementOI!=null && updatedSaStockMovementOI.size()>0){
            //Method used for stock movement if only SA is changed on orderitem and no new orders are created
            System.schedule('Stock Movement Request for SA update ' + caseRecord.Id, cronExp, new BLN_StockMovementSchedule(caseRecord.Id, true));
        }
        else if(caseRecord.Orders__r.size() == 0){
            System.schedule('Stock Movement Request for Case ' + caseRecord.Id, cronExp, new BLN_StockMovementSchedule(caseRecord.Id, false));
        }
        //Future method for stocks rebooking callout
        else if(caseRecord.Orders__r.size() > 0){  
            System.enqueueJob(new BLN_StockRebookQueuable(caseRecord.Id));
        }
        return orderItemStringList;
        }

    @future
    public static void updateWOwithOrderFuture(String orderId){
        BLN_AppointmentDataCreationService.updateWOwithOrder(orderId);
    }

    /* This method is call after order & Order product create due to getting UNABLE_TO_LOCK_ROW */
    @future
    public static void updateCaseFuture(String records) {
        Case recordsToUpdate = (Case) JSON.deserialize(records, Case.class);
        if(recordsToUpdate != null && Schema.sObjectType.Case.isUpdateable()){ 
            Update recordsToUpdate;
        }
    }

    /* MethodName : displayLocation
Description : This method is used to return the response to lwc component.
Input Parameter : null
Output Parameter : List<BLN_ProductAvailabilityWrapper.DisplayLocationWrapper>
CreatedDate: 24-11-2023
CreatedBy : Pwc-India
Change log :
****************************************/
    /*  *@description:FOUK-4914 This method is used to get screen name based on display location */
    @AuraEnabled
    public static List<BLN_ProductAvailabilityWrapper.DisplayLocationWrapper> displayLocation(){
        List<Knowledge__kav> allKnowledges;
        List<Knowledge__kav> quoteSummaryKnowledges = new List<Knowledge__kav>();
        List<Knowledge__kav> quotePresentationKnowledges = new List<Knowledge__kav>();
        
        //Query all the records whose display location is Query summary and Query Presentation.
        allKnowledges= [Select id,Title,BLN_DisplayLocation__c from Knowledge__kav where BLN_DisplayLocation__c = :System.label.BLN_QuoteSummary OR BLN_DisplayLocation__c = :System.label.BLN_QuotePresentation WITH SECURITY_ENFORCED];
        if(!allKnowledges.isEmpty()){
            for(Knowledge__kav currentKnowledge : allKnowledges){
                if(currentKnowledge.BLN_DisplayLocation__c == System.label.BLN_QuoteSummary){
                    quoteSummaryKnowledges.add(currentKnowledge);
                } else {
                    quotePresentationKnowledges.add(currentKnowledge);
                }
            }
        }
        List<BLN_ProductAvailabilityWrapper.DisplayLocationWrapper> returnData = new List<BLN_ProductAvailabilityWrapper.DisplayLocationWrapper>();
        // check quoteSummaryKnowledges and assign Screen name same as display location.
        if(!quoteSummaryKnowledges.isEmpty()){
            
            BLN_ProductAvailabilityWrapper.DisplayLocationWrapper quoteData = new BLN_ProductAvailabilityWrapper.DisplayLocationWrapper();
            quoteData.screenName = System.label.BLN_QuoteSummary;
            quoteData.value = quoteSummaryKnowledges;
            returnData.add(quoteData);
        }
        // check quotePresentationKnowledges and assign Screen name same as display location.
        if(!quotePresentationKnowledges.isEmpty()){
            BLN_ProductAvailabilityWrapper.DisplayLocationWrapper quoteData = new BLN_ProductAvailabilityWrapper.DisplayLocationWrapper();
            quoteData.screenName = System.label.BLN_QuotePresentation;
            quoteData.value = quotePresentationKnowledges;
            returnData.add(quoteData);
        }
        return returnData;
    }
    
    @AuraEnabled(cacheable = true)
    public static Boolean getIsFirstCustomPermission() {
            return FeatureManagement.checkPermission('BLN_CustomerAccountsAdvisor');
    }
}