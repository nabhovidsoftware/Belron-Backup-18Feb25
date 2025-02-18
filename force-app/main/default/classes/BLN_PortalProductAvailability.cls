/*****************************************
ClassName : BLN_ProductAvailability
Description : FOUK-4243, 4049 This controller class is used in lwc [Portal].
CreatedDate: 24-11-2023
CreatedBy : PwC-India
****************************************/


/*  *@description:This class is used to return the response */
public without sharing class BLN_PortalProductAvailability {
    
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
                branchST = [SELECT id, Latitude,Longitude,BLN_GUID__c, BLN_CostCenter__c FROM ServiceTerritory  LIMIT 1]; 
            }
            else{
                branchST = motoristCase.BLN_Vehicle__r.BLN_SpecialVehicle__c ? [SELECT Id,Address,Latitude,Longitude,BLN_GUID__c,BLN_CostCenter__c,BLN_Type__c,DISTANCE(Address,:motoristCase.BLN_ServiceGeolocation__c,'mi') distanceChart FROM ServiceTerritory WHERE BLN_ConsiderforR1__c = false AND IsActive = true AND BLN_Type__c = :System.label.BLN_Branch AND BLN_Specials__c = true AND BLN_GUID__c != '' AND Latitude != null AND Longitude != null AND BLN_CostCenter__c != '' ORDER BY DISTANCE(Address,:motoristCase.BLN_ServiceGeolocation__c,'mi') ASC limit 3] : [SELECT id,Address,Latitude,Longitude,BLN_GUID__c,BLN_CostCenter__c,BLN_Type__c,DISTANCE(Address,:motoristCase.BLN_ServiceGeolocation__c,'mi') sampleDistance FROM ServiceTerritory WHERE BLN_ConsiderforR1__c = false AND IsActive=true AND BLN_Type__c= :System.label.BLN_Branch AND BLN_GUID__c != '' AND Latitude != null AND Longitude != null AND BLN_CostCenter__c != '' ORDER BY DISTANCE(Address,:motoristCase.BLN_ServiceGeolocation__c,'mi') ASC limit 3];
            }
            /* Collect the GUID for get OrgCodeLocation */
            Set<String> guIds = new Set<String>();
            for(ServiceTerritory st : branchST){
                if(st.BLN_GUID__c != null){
                    guIds.add(st.BLN_GUID__c);
                }
            }
            Map<String, String> guidWithOrgCodeLocations = new Map<String, String>();
            for(Schema.Location loc:  [SELECT Id, BLN_OrgCodeLocation__c, BLN_GUID__c FROM Location WHERE BLN_GUID__c IN: guIds WITH SECURITY_ENFORCED ]) {
                guidWithOrgCodeLocations.put(loc.BLN_GUID__c, loc.BLN_OrgCodeLocation__c);
            }

            for(ServiceTerritory st : branchST){
                locWrapper = new BLN_ProductAvailabilityWrapper.LocationWrapper();
                locWrapper.costCenterId = guidWithOrgCodeLocations.containsKey(st.BLN_GUID__c) ? guidWithOrgCodeLocations.get(st.BLN_GUID__c) : '';
                locWrapper.locationId = st.BLN_GUID__c;
                locWrapper.mobileLocationIndicator = false;
                locWrapper.countryCode = 'GB';
                nearestLocationDetails.add(locWrapper);
            }
            
            if(!motoristCase.BLN_Vehicle__r.BLN_SpecialVehicle__c){
                List<FSL__Polygon__c> polygonList = new List<FSL__Polygon__c>();
                if(FSL__Polygon__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible() && !test.isRunningTest()){   
                    polygonList = [SELECT id,FSL__Service_Territory__r.BLN_GUID__c,FSL__Service_Territory__r.BLN_CostCenter__c,FSL__Service_Territory__r.BLN_Type__c,FSL__Service_Territory__r.Address FROM FSL__Polygon__c WHERE FSL__Service_Territory__r.BLN_ConsiderforR1__c = false AND FSL__Service_Territory__r.isActive = true AND FSL__Service_Territory__r.BLN_Type__c = :System.label.BLN_Mobile AND Id IN :FSL.PolygonUtils.getAllPolygonsByLatLong((Double)motoristCase.BLN_ServiceGeolocation__Longitude__s,(Double)motoristCase.BLN_ServiceGeolocation__Latitude__s)  ORDER BY DISTANCE(FSL__Service_Territory__r.Address,:motoristCase.BLN_ServiceGeolocation__c,'mi') ASC LIMIT 1];                
                }
                if(test.isRunningTest()){
                    polygonList = [SELECT id,FSL__Service_Territory__r.BLN_CostCenter__c,FSL__Service_Territory__r.BLN_Type__c,FSL__Service_Territory__r.Address, FSL__KML__c, FSL__Mi_Lo__c, FSL__Color__c, Name, FSL__Service_Territory__r.BLN_GUID__c,  FSL__Ma_Lo__c, FSL__Mi_La__c, FSL__Ma_La__c, FSL__Service_Territory__c FROM FSL__Polygon__c  LIMIT 1];
                }
                
                for(FSL__Polygon__c poly : polygonList){
                    locWrapper = new BLN_ProductAvailabilityWrapper.LocationWrapper();
                    locWrapper.costCenterId = poly.FSL__Service_Territory__r != null && poly.FSL__Service_Territory__r.BLN_GUID__c != null && guidWithOrgCodeLocations.containsKey(poly.FSL__Service_Territory__r.BLN_GUID__c) ? guidWithOrgCodeLocations.get(poly.FSL__Service_Territory__r.BLN_GUID__c) : '';
                    locWrapper.locationId = poly.FSL__Service_Territory__r.BLN_GUID__c;
                    locWrapper.mobileLocationIndicator = true;
                    locWrapper.countryCode = 'GB';
                    nearestLocationDetails.add(locWrapper);
                }
            }
        return nearestLocationDetails;
    }    
    
    /*****************************************
MethodName : makeQuoteCallout
Description : This method is used to return the response to lwc component.
Input Parameter : null
Output Parameter :String
CreatedDate: 24-11-2023
CreatedBy : Pwc-India
Change log :
****************************************/
    
    
    @AuraEnabled
    public static String makeQuoteCallout(String motoristCaseId){        
        Case motoCase = new Case();        
                
        if(case.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible()){
            motoCase = [SELECT Id,BLN_SubType__c,BLN_Corporate__r.BLN_VehicleDamageExcess__c,BLN_BillingMethod__c,BLN_MotoristTaxStatus__c,BLN_Corporate__r.BLN_InsuranceSite__r.BLN_MDMAccountPartyId__c,BLN_Corporate__r.BLN_InsuranceSite__r.BLN_MDMAccountID__c,BLN_Corporate__r.BLN_InsuranceSite__r.BLN_MDMMotoristId__c,BLN_ServiceCountry__c,BLN_Vehicle__r.BLN_MDMID__c,Account.BLN_MDMAccountPartyId__c,Account.BLN_MDMAccountID__c,Account.BLN_MDMMotoristId__c,BLN_ServiceGeolocation__c,BLN_ServiceGeolocation__Longitude__s,BLN_ServiceGeolocation__Latitude__s,BLN_Vehicle__r.BLN_SpecialVehicle__c FROM Case WHERE Id = :motoristCaseId LIMIT 1];
            
        }
        Map<String,Object> payloadMap = new Map<String,Object>();
        
        payloadMap.put(system.label.BLN_MotoristVATStatus,motoCase.BLN_MotoristTaxStatus__c == System.label.BLN_Yes ? System.label.BLN_Registered : System.label.BLN_Exempt);
        payloadMap.put(system.label.BLN_CaseId,motoristCaseId);
        payloadMap.put(system.label.BLN_ServiceCountry,motoCase.BLN_ServiceCountry__c);
        payloadMap.put(system.label.BLN_Currency,system.label.BLN_GBP);
        BLN_VehicleDamage__c[] relatedVehicleDamages = [SELECT Id,BLN_BOMID__c,BLN_ProductId__c FROM BLN_VehicleDamage__c WHERE BLN_Case__c=:motoCase.Id ];
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
                    if(partIdMap.containsKey(str)){
                        count = partIdMap.get(str) + 1;
                    }
                    partIdMap.put(str,count);
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
            partIdList.add(partIds);
        }
        payloadMap.put(system.label.BLN_PartIds,partIdList);
        
        payloadMap.put(system.label.BLN_VehicleId,motoCase.BLN_Vehicle__r.BLN_MDMID__c != null ? motoCase.BLN_Vehicle__r.BLN_MDMID__c : '');
        payloadMap.put(system.label.BLN_AccountId,BLN_ProductAvailabilityUtility.getAccountId(motoCase));
        payloadMap.put(system.label.BLN_Profile,'');
        payloadMap.put(system.label.BLN_VoucherCode,'');
        payloadMap.put(System.label.BLN_QuoteTypeLabel,BLN_ProductAvailabilityUtility.getQuoteType(motoCase));
        List<BLN_ProductAvailabilityWrapper.LocationWrapper> nearestLocations = BLN_ProductAvailability.getNearestServiceLocations(motoCase);          
        payloadMap.put(system.label.BLN_Locations,nearestLocations);
        
        BLN_ProductAvailabilityWrapper.InsuranceDetailsWrapper insuranceDetails = new BLN_ProductAvailabilityWrapper.InsuranceDetailsWrapper();
        insuranceDetails.glassLimit = 0;
        insuranceDetails.repairExcess = 0;
        insuranceDetails.replacementExcess = 0;
        insuranceDetails.calibrationExcess = 0;
        insuranceDetails.sundryExcess = 0;
        if(motoCase.BLN_Corporate__c !=null){
            insuranceDetails.vehicleDamageExcess = motoCase.BLN_Corporate__r.BLN_VehicleDamageExcess__c == null ? 0 : motoCase.BLN_Corporate__r.BLN_VehicleDamageExcess__c;
        }
        
        payloadMap.put(system.label.BLN_InsuranceDetails,insuranceDetails);
        
        payloadMap.put('tradeAccountId','1234');
        payloadMap.put('pricingDate','2024-06-13');
        payloadMap.put('taxRegistrationNumber','129783');
        payloadMap.put('chfVATStatus','Exempt');
        payloadMap.put('channel','FrontOffice');
        
        String payload = JSON.serializePretty(payloadMap);
        //system.debug('payload1212'+payload);

        BLN_APICalloutMapper__mdt calloutDetails = BLN_APICalloutMapper__mdt.getInstance(System.label.BLN_QuoteApi);
        Map<String,String> headerMap = new Map<String,String>();
        Integer timeout = 30000;
        headerMap.put(System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[0],System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[1]+' '+BLN_HTTPCallOutAccessToken.getAccessToken()?.accessToken);
        
        String hCode = EncodingUtil.convertToHex(Crypto.generateAesKey(128));
        String correlID = hCode.substring(0,4)+'-'+hCode.substring(0,4)+'-'+hCode.substring(5,8)+'-'+hCode.substring(9,12)+'-'+hCode.substring(12,16)+'-'+hCode.substring(16,20);
        headerMap.put(System.label.BLN_XCORRELATIONID,correlID);
        
        for(String str : calloutDetails.BLN_Headers__c.split(System.label.BLN_Semicolon)){
            headerMap.put(str.split(System.label.BLN_Comma)[0],str.split(System.label.BLN_Comma)[1]);
        }
        
        // system.debug('calloutDetails.BLN_DestinationSystem__c booking'+'-'+calloutDetails.BLN_DestinationSystem__c);
        // system.debug('calloutDetails.BLN_NamedCredential__c booking'+'-'+calloutDetails.BLN_NamedCredential__c);
        // system.debug('calloutDetails.BLN_CalloutURL__c booking'+'-'+calloutDetails.BLN_CalloutURL__c);
        // system.debug('calloutDetails.BLN_Method__c booking'+'-'+calloutDetails.BLN_Method__c);
        // system.debug('headerMap booking'+'-'+headerMap);
        // system.debug('payload booking'+'-'+payload);
        // system.debug('motoristCaseId booking'+'-'+motoristCaseId);
        // system.debug('timeout booking'+'-'+timeout);


        HttpResponse response = BLN_HttpCalloutUtility.makeCallout(calloutDetails.BLN_DestinationSystem__c,calloutDetails.BLN_NamedCredential__c + calloutDetails.BLN_CalloutURL__c, calloutDetails.BLN_Method__c, headerMap, motoristCaseId, payload,timeout);
        
        String returnPayloadAsString = response.getStatusCode() == 201 ? response.getBody() : System.label.BLN_CalloutFailed;
        return returnPayloadAsString;
        
    }

    public static void updateAllQuoteIds(String payload, String caseId){
        Case cs = [Select Id,BLN_CPQQuoteIdCollection__c from case where Id =: caseId  LIMIT 1];
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
        BLN_APICalloutMapper__mdt calloutData = BLN_APICalloutMapper__mdt.getInstance(System.label.BLN_QuoteRepriceApi);
        Map<String,String> headerMap = new Map<String,String>();
        headerMap.put(System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[0],System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[1]+' '+BLN_HTTPCallOutAccessToken.getAccessToken()?.accessToken);
        for(String header : calloutData.BLN_Headers__c.split(System.label.BLN_Semicolon)){
            headerMap.put(header.split(System.label.BLN_Comma)[0],header.split(System.label.BLN_Comma)[1]);
        }
        HttpResponse res = BLN_HttpCalloutUtility.makeCallout(calloutData.BLN_DestinationSystem__c,calloutData.BLN_NamedCredential__c+calloutData.BLN_CalloutURL__c,calloutData.BLN_Method__c,headerMap,caseRecordId,repriceRequestPayload);  
        
        String repricedPayload = res.getStatusCode() == 200 ? res.getBody() : 'Reprice'+System.label.BLN_CalloutFailed;       
        return repricedPayload;
    }
    
    @AuraEnabled public static String dummyMainPayload(String motoristCaseId){return [SELECT id,body from StaticResource WHERE Name = 'BLN_TempMainResponse'][0].Body.toString();}    
    
    
    @AuraEnabled    
    public static BLN_ProductAvailabilityWrapper.DisplayDetailsWrapper structureDataForQuoteUI(String payload, String caseId){
		
        BLN_ProductResponseWrapper.ResponseProduct data = (BLN_ProductResponseWrapper.ResponseProduct) System.JSON.deserialize(payload,BLN_ProductResponseWrapper.ResponseProduct.class);
        Map<Integer,List<BLN_ProductResponseWrapper.ResponseLineItems>> bundleParentLineItemVsLineItem = new Map<Integer,List<BLN_ProductResponseWrapper.ResponseLineItems>>();
        Map<String,BLN_ProductResponseWrapper.ResponseLineItems> bundleNameVsBundleLineItem = new Map<String,BLN_ProductResponseWrapper.ResponseLineItems>();
        //Prepare Set of all Part Numbers from Line Items in all Quotes

        Integer bufferDaysToAdd = BLN_ProductAvailabilityUtility.bufferCalculation(caseId);

        Set<String> partNumbersSet = new Set<String>();
        Map<String,Set<String>> quoteIdStockLocationsMap = new Map<String,Set<String>>();
        Map<String,List<BLN_ProductResponseWrapper.ResponseLineItems>> bundleNameVsLineItem = new Map<String,List<BLN_ProductResponseWrapper.ResponseLineItems>>();
        for(BLN_ProductResponseWrapper.ResponseQuotes quoteVar : data.quotes){
            quoteIdStockLocationsMap.put(quoteVar.quoteId, new Set<String>());
            for(BLN_ProductResponseWrapper.ResponseLineItems lineItem : quoteVar.lineItems) {
                if(lineItem.partOfBundle == false){
                    partNumbersSet.add(lineItem.partNumber);
                }
                else if(lineItem.partOfBundle == true){ 
                    if(lineItem.partNumber == null){
                        lineItem.partNumber = System.label.BLN_Bundle;
                        bundleNameVsBundleLineItem.put(lineItem.bundleName,lineItem);

                    }
                    if((bundleParentLineItemVsLineItem.containsKey(lineItem.parentLineItemId) == true) && (lineItem.parentLineItemId != lineItem.lineItemId)){
                        bundleParentLineItemVsLineItem.get(lineItem.parentLineItemId).add(lineItem);
                    }
                    else if(lineItem.parentLineItemId != lineItem.lineItemId){
                        bundleParentLineItemVsLineItem.put(lineItem.parentLineItemId,new List<BLN_ProductResponseWrapper.ResponseLineItems>{lineItem});
                    }
                    if(bundleNameVsLineItem.containsKey(lineItem.bundleName) == true){
                        bundleNameVsLineItem.get(lineItem.bundleName).add(lineItem);
                    }
                    else{
                        bundleNameVsLineItem.put(lineItem.bundleName,new List<BLN_ProductResponseWrapper.ResponseLineItems>{lineItem});
                    }
                    if(lineItem.partNumber != '' && lineItem.partNumber != null){
                        partNumbersSet.add(lineItem.partNumber);
                    }
                }
                for(BLN_ProductResponseWrapper.ResponseAvailabilityDetails availDetail : lineItem.availabilityDetails){
                    availDetail.availableFromDate = availDetail.availableFromDate != null && availDetail.availableFromDate != '' ? String.valueOf(DateTime.newInstance(System.now().date().addDays(bufferDaysToAdd),System.now().time()).format('YYYY-MM-dd\'T\'HH:mm:ssXXX')) : availDetail.availableFromDate;
                    quoteIdStockLocationsMap.get(quoteVar.quoteId).add(availDetail.stockLocationId);
                }
            }
        }
        
        //Create Map of Product MDM ID and Product Record for all products in all Quotes
        Map<String,Product2> productMDMIDProductMap = new Map<String,Product2>();
        for(Product2 prod : [SELECT Id, Name, BLN_MDMID__c, BLN_BranchOnlyProduct__c, BLN_ProductCategory__c, BLN_ProductStockable__c,BLN_BondedNonBonded__c FROM Product2 WHERE isActive = true AND BLN_MDMID__c IN :partNumbersSet ]) {
            productMDMIDProductMap.put(prod.BLN_MDMID__c,prod);
        }
        
        Set<String> commonPartNumbers = new Set<String>();
        Set<String> uncommonPartNumbers = new Set<String>();
        Set<String> bundleNameList = new Set<String>();
        List<BLN_ProductResponseWrapper.ResponseLineItems> sortedLineItems = new List<BLN_ProductResponseWrapper.ResponseLineItems>();
        List<BLN_ProductAvailabilityWrapper.ProductSelectionWrapper> productSelectionDataList = new List<BLN_ProductAvailabilityWrapper.ProductSelectionWrapper>();
        List<BLN_ProductAvailabilityWrapper.DisplayQuoteDetailsWrapper> quoteDetailsList = new List<BLN_ProductAvailabilityWrapper.DisplayQuoteDetailsWrapper>();
        List<BLN_ProductAvailabilityWrapper.EarliestAvailabilityDetailsWrapper> earliestAvailabilityData = new List<BLN_ProductAvailabilityWrapper.EarliestAvailabilityDetailsWrapper>();    
        List<BLN_ProductAvailabilityWrapper.DiscountBandWrapper> discountBandDetailsList = new List<BLN_ProductAvailabilityWrapper.DiscountBandWrapper>();
        List<BLN_ProductAvailabilityWrapper.AvailabilityDatesWrapper> availibilityDatesList = new List<BLN_ProductAvailabilityWrapper.AvailabilityDatesWrapper>();
        List<BLN_ProductAvailabilityWrapper.InsuranceLiabilityWrapper> liabilityData = new List<BLN_ProductAvailabilityWrapper.InsuranceLiabilityWrapper>();
        
        BLN_ProductAvailabilityWrapper.InsuranceLiabilityWrapper motoristTotalsLiability = new BLN_ProductAvailabilityWrapper.InsuranceLiabilityWrapper();
        BLN_ProductAvailabilityWrapper.InsuranceLiabilityWrapper insuranceTotalsLiability = new BLN_ProductAvailabilityWrapper.InsuranceLiabilityWrapper();
        BLN_ProductAvailabilityWrapper.InsuranceLiabilityWrapper tradeCompanyTotalsLiability = new BLN_ProductAvailabilityWrapper.InsuranceLiabilityWrapper();
        BLN_ProductAvailabilityWrapper.InsuranceLiabilityWrapper totalLiability = new BLN_ProductAvailabilityWrapper.InsuranceLiabilityWrapper();
        
        Map<String,BLN_ProductAvailabilityWrapper.DisplayQuoteDetailsWrapper> guIdVsDisplayDeatilsDataMap = new Map<String,BLN_ProductAvailabilityWrapper.DisplayQuoteDetailsWrapper>();
        Map<BLN_ProductResponseWrapper.ResponseQuotes,List<BLN_ProductResponseWrapper.ResponseLineItems>> quoteVsLineItemMap = new Map<BLN_ProductResponseWrapper.ResponseQuotes,List<BLN_ProductResponseWrapper.ResponseLineItems>>();
        Map<String,BLN_ProductResponseWrapper.ResponseLineItems> partIdVsLineItemMap = new Map<String,BLN_ProductResponseWrapper.ResponseLineItems>();
        Map<String,Set<String>> bomIdVsAddonPartIdListMap = new Map<String,Set<String>>();
        Map<String,Set<BLN_ProductResponseWrapper.ResponseLineItems>> bomIdVsAddonItemMap = new Map<String,Set<BLN_ProductResponseWrapper.ResponseLineItems>>();
        Map<String,List<String>> bundleNameVsPartIdListMap = new Map<String,List<String>>();
        for(BLN_ProductResponseWrapper.ResponseQuotes quoteVar : data.quotes){
            BLN_ProductResponseWrapper.ResponseLineItems[] mainLineItems = new BLN_ProductResponseWrapper.ResponseLineItems[0];
            List<List<String>> dtList = new List<List<String>>();
            Map<String,List<BLN_ProductResponseWrapper.ResponseAvailabilityDetails>> dateVsAvailibilityDetailsMap = new Map<String,List<BLN_ProductResponseWrapper.ResponseAvailabilityDetails>>();        
            
            for(BLN_ProductResponseWrapper.ResponseLineItems lineItem : quoteVar.lineItems) {
                if(lineItem.partNumber != '' && lineItem.partNumber != null){
                    partIdVsLineItemMap.put(lineItem.partNumber,lineItem);
                }
                if(productMDMIDProductMap.containsKey(lineItem.partNumber) && lineItem.partOfBundle == true && lineItem.parentLineItemId != lineItem.lineItemId){
                    if(bundleNameVsPartIdListMap.containsKey(lineItem.bundleName)){
                        bundleNameVsPartIdListMap.get(lineItem.bundleName).add(lineItem.partNumber);
                    }
                    else{
                        bundleNameVsPartIdListMap.put(lineItem.bundleName,new List<String>{lineItem.partNumber});
                    }
                }
                else if(productMDMIDProductMap.containsKey(lineItem.partNumber) && lineItem.parentBomId != '' && lineItem.parentBomId != null && lineItem.leadingProductIndicator == false){
                    if(bomIdVsAddonPartIdListMap.containsKey(lineItem.parentBomId)){
                        bomIdVsAddonPartIdListMap.get(lineItem.parentBomId).add(lineItem.partNumber);
                    }
                    else{
                        bomIdVsAddonPartIdListMap.put(lineItem.parentBomId,new Set<String>{lineItem.partNumber});
                    }
                } 
                else if(productMDMIDProductMap.containsKey(lineItem.partNumber) || ((lineItem.partNumber == null || lineItem.partNumber == '') && lineItem.partOfBundle == true && (lineItem.lineItemId == lineItem.parentLineItemId))){
                    mainLineItems.add(lineItem);
                }
                
                List<String> currentDtList = new List<String>();
                if(productMDMIDProductMap.containsKey(lineItem.partNumber)){
                    BLN_ProductAvailabilityWrapper.EarliestAvailabilityDetailsWrapper earliestAvailabilityVar = new BLN_ProductAvailabilityWrapper.EarliestAvailabilityDetailsWrapper();
                    earliestAvailabilityVar.quoteId = quoteVar.quoteId;
                    earliestAvailabilityVar.productCode = lineItem.partNumber;
                    earliestAvailabilityVar.bundleName = lineItem.bundleName;
                    
                    if(lineItem.availabilityDetails.size() >= 1){
                        for(BLN_ProductResponseWrapper.ResponseAvailabilityDetails availDetail : lineItem.availabilityDetails){
                            switch on availDetail.availableFromDate {
                                when null {
                                    continue;
                                }
                                when '' {
                                    continue;
                                }
                                when else{
                                    currentDtList.add(availDetail.availableFromDate);
                                    dateVsAvailibilityDetailsMap.put(availDetail.availableFromDate,lineItem.availabilityDetails);
                                    earliestAvailabilityVar.earliestDateList.add(availDetail);
                                }
                            }
                        }

                        while(earliestAvailabilityVar.earliestDateList.size() == 0){

                            BLN_ProductResponseWrapper.ResponseAvailabilityDetails currentDateVar = new BLN_ProductResponseWrapper.ResponseAvailabilityDetails();
                            currentDateVar.stockLocationId = quoteVar.locationId ;
                            currentDateVar.isOutOfStock = productMDMIDProductMap.get(lineItem.partNumber).BLN_ProductStockable__c ? true : false;
                            String checkNoBufferDate = productMDMIDProductMap.get(lineItem.partNumber).BLN_ProductStockable__c == true ? String.valueOf(DateTime.newInstance(System.now().date().addDays(Integer.valueOf(System.label.BLN_NoStockBufferPeriod)),System.now().time()).format('YYYY-MM-dd\'T\'HH:mm:ssXXX')) : String.valueOf(DateTime.newInstance(System.now().date(),System.now().time()).format('YYYY-MM-dd\'T\'HH:mm:ssXXX'));
                            currentDateVar.availableFromDate = productMDMIDProductMap.get(lineItem.partNumber).BLN_ProductStockable__c ? String.valueOf(DateTime.newInstance(System.now().date().addDays(Integer.valueOf(System.label.BLN_NoStockBufferPeriod) + bufferDaysToAdd),System.now().time()).format('YYYY-MM-dd\'T\'HH:mm:ssXXX')) : String.valueOf(DateTime.newInstance(System.now().date().addDays(bufferDaysToAdd),System.now().time()).format('YYYY-MM-dd\'T\'HH:mm:ssXXX'));
                            earliestAvailabilityVar.earliestDateList = new List<BLN_ProductResponseWrapper.ResponseAvailabilityDetails>{currentDateVar};
                            currentDtList.add(currentDateVar.availableFromDate);
                            dateVsAvailibilityDetailsMap.put(currentDateVar.availableFromDate,earliestAvailabilityVar.earliestDateList);
                            break;
                        }
                    }
                    else{
                        BLN_ProductResponseWrapper.ResponseAvailabilityDetails currentDateVar = new BLN_ProductResponseWrapper.ResponseAvailabilityDetails();
                            currentDateVar.stockLocationId = quoteVar.locationId;
                            currentDateVar.isOutOfStock = productMDMIDProductMap.get(lineItem.partNumber).BLN_ProductStockable__c ? true : false;

                            currentDateVar.availableFromDate = productMDMIDProductMap.get(lineItem.partNumber).BLN_ProductStockable__c ? String.valueOf(DateTime.newInstance(System.now().date().addDays(Integer.valueOf(System.label.BLN_NoStockBufferPeriod) + bufferDaysToAdd),System.now().time()).format('YYYY-MM-dd\'T\'HH:mm:ssXXX')) : String.valueOf(DateTime.newInstance(System.now().date().addDays(bufferDaysToAdd),System.now().time()).format('YYYY-MM-dd\'T\'HH:mm:ssXXX'));
                            earliestAvailabilityVar.earliestDateList = new List<BLN_ProductResponseWrapper.ResponseAvailabilityDetails>{currentDateVar};
        
                        currentDtList.add(currentDateVar.availableFromDate);
                        dateVsAvailibilityDetailsMap.put(currentDateVar.availableFromDate,earliestAvailabilityVar.earliestDateList);
                    }
                    earliestAvailabilityData.add(earliestAvailabilityVar);
                    currentDtList.sort();
                    dtList.add(currentDtList);
                }
            }
            
            quoteVsLineItemMap.put(quoteVar,mainLineItems);
            
            List<String> sortedList = new List<String>();
            for(List<String> innerStrList : dtList ) {
                if(innerStrList != null && innerStrList.size() > 0){
                    sortedList.add(innerStrList[0]);
                }
            }
            sortedList.sort();
        
            String earliestDateValue = sortedList.size() >= 1 ? sortedList[(sortedList.size() - 1)] : String.valueOf(DateTime.newInstance(System.now().date().addDays(Integer.valueOf(System.label.BLN_NoStockBufferPeriod) + bufferDaysToAdd),System.now().time()).format('YYYY-MM-dd\'T\'HH:mm:ssXXX')); //String.value(System.now().addDays(-10000));  
            BLN_ProductAvailabilityWrapper.AvailabilityDatesWrapper earliestDateSet = new BLN_ProductAvailabilityWrapper.AvailabilityDatesWrapper();
            if(dateVsAvailibilityDetailsMap.containsKey(earliestDateValue)){
                earliestDateSet.earliestDates = dateVsAvailibilityDetailsMap.get(earliestDateValue);
            }
            earliestDateSet.quoteId = quoteVar.quoteId;
            availibilityDatesList.add(earliestDateSet);
            
            BLN_ProductAvailabilityWrapper.DisplayQuoteDetailsWrapper displayDetailsData = new BLN_ProductAvailabilityWrapper.DisplayQuoteDetailsWrapper();
            displayDetailsData.quoteId = quoteVar.quoteId;
            displayDetailsData.quotelocation = displayDetailsData.locationGUID = quoteVar.locationId;
        
            displayDetailsData.quoteTotal = quoteVar.quoteTotals.totalPrice;
            displayDetailsData.quoteVAT = quoteVar.quoteTotals.totaltax;
            displayDetailsData.quoteNetTotal = quoteVar.quoteTotals.totalIncludingTax;
            displayDetailsData.quoteWeatherGuard = '<<Placeholder>>';
            displayDetailsData.quoteEarliestAppointmentAvailability = earliestDateValue;
            quoteDetailsList.add(displayDetailsData);

            guIdVsDisplayDeatilsDataMap.put(quoteVar.locationId,displayDetailsData);
            
            BLN_ProductAvailabilityWrapper.DiscountBandWrapper discountbandData = new BLN_ProductAvailabilityWrapper.DiscountBandWrapper();
            discountbandData.locationId = quoteVar.locationId;
            discountbandData.discountThresholdA = quoteVar.discountThresholdA;
            discountbandData.discountThresholdB = quoteVar.discountThresholdB;
            discountbandData.discountThresholdC = quoteVar.discountThresholdC;
            discountBandDetailsList.add(discountbandData);
            
            motoristTotalsLiability.liabilityCategory = System.label.BLN_MotoristLiability;
            motoristTotalsLiability.totalPayable = quoteVar.motoristTotals.totalPayableByMotorist;
            motoristTotalsLiability.totalTaxPayable = quoteVar.motoristTotals.totalTaxPayableByMotorist;
            motoristTotalsLiability.totalIncludingTaxPayable = quoteVar.motoristTotals.totalIncludingTaxPayableByMotorist;
            
            insuranceTotalsLiability.liabilityCategory = System.label.BLN_InsuranceLiability;
            insuranceTotalsLiability.totalPayable = quoteVar.insuranceTotals.totalPayableByInsurance;
            insuranceTotalsLiability.totalTaxPayable = quoteVar.insuranceTotals.totalTaxPayableByInsurance;
            insuranceTotalsLiability.totalIncludingTaxPayable = quoteVar.insuranceTotals.totalIncludingTaxPayableByInsurance;
            
            tradeCompanyTotalsLiability.liabilityCategory = System.label.BLN_AccountLiability;
            tradeCompanyTotalsLiability.totalPayable = quoteVar.tradeCompanyTotals.totalPayableByTrade;
            tradeCompanyTotalsLiability.totalTaxPayable = quoteVar.tradeCompanyTotals.payableByTradeTotalTax;
            tradeCompanyTotalsLiability.totalIncludingTaxPayable = quoteVar.tradeCompanyTotals.totalPayableByTradeIncludingTax;                
            
            totalLiability.liabilityCategory = System.label.BLN_Total;
            totalLiability.totalPayable = quoteVar.quoteTotals.totalPrice;
            totalLiability.totalTaxPayable  = quoteVar.quoteTotals.totalTax;
            totalLiability.totalIncludingTaxPayable = quoteVar.quoteTotals.totalIncludingTax;            
        }              
        liabilityData.addAll(new List<BLN_ProductAvailabilityWrapper.InsuranceLiabilityWrapper>{motoristTotalsLiability, insuranceTotalsLiability, tradeCompanyTotalsLiability, totalLiability});
        
        List<ServiceTerritory> relatedServiceTerritoryList = [SELECT Id,Name,BLN_GUID__c,BLN_Type__c,BLN_ExcludedProduct__c FROM ServiceTerritory WHERE isActive = true AND BLN_GUID__c IN :guIdVsDisplayDeatilsDataMap.keySet()  LIMIT 10000];
        for(ServiceTerritory st : relatedServiceTerritoryList) {
            guIdVsDisplayDeatilsDataMap.get(st.BLN_GUID__c).excludeProduct = st.BLN_ExcludedProduct__c != null ? st.BLN_ExcludedProduct__c : 'TestExcludProduct';
            guIdVsDisplayDeatilsDataMap.get(st.BLN_GUID__c).quotelocation = st.Name;
            guIdVsDisplayDeatilsDataMap.get(st.BLN_GUID__c).isMobileLocation = st.BLN_Type__c == System.label.BLN_Mobile ? true : false;  
    
        }       
        for(String bomId : bomIdVsAddonPartIdListMap.keySet()){
            Set<BLN_ProductResponseWrapper.ResponseLineItems> addOnItemList = new Set<BLN_ProductResponseWrapper.ResponseLineItems>();
            for(String addOnItemPartId : bomIdVsAddonPartIdListMap.get(bomId)){
                addOnItemList.add(partIdVsLineItemMap.get(addOnItemPartId));
            }
            bomIdVsAddonItemMap.put(bomId,addOnItemList);
        }       
        Boolean isFirstPartNumbersRetrieved = false;
        Boolean isFirstQuoteLineItemsChecked = false;
        Set<String> firstQuotePartNumbers = new Set<String>();
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
            }
            else{
                sortedLineItems.add(partIdVsLineItemMap.get(str));
            }
        }
        
        List<BLN_ProductResponseWrapper.ResponseLineItems> firstLineItemsList = new List<BLN_ProductResponseWrapper.ResponseLineItems>();
        List<BLN_ProductResponseWrapper.ResponseLineItems> secondLineItemsList = new List<BLN_ProductResponseWrapper.ResponseLineItems>();
        List<BLN_ProductResponseWrapper.ResponseLineItems> thirdLineItemsList = new List<BLN_ProductResponseWrapper.ResponseLineItems>();
        List<BLN_ProductResponseWrapper.ResponseLineItems> forthLineItemsList = new List<BLN_ProductResponseWrapper.ResponseLineItems>();

        
        for(BLN_ProductResponseWrapper.ResponseLineItems lineItem : sortedLineItems) {
            if(lineItem.bomMandatory == false && lineItem.partOfBundle == false && productMDMIDProductMap.get(lineItem.partNumber).BLN_ProductCategory__c != null && !(productMDMIDProductMap.get(lineItem.partNumber).BLN_ProductCategory__c).containsIgnoreCase('vaps')){
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
            else if(lineItem.partOfBundle == true && bundleNameVsPartIdListMap.containsKey(lineItem.bundleName) && bundleParentLineItemVsLineItem.containsKey(lineItem.parentLineItemId)){
                sortedLineItemsWithAddons.addAll(bundleParentLineItemVsLineItem.get(lineItem.lineItemId).size() > 0 ? bundleParentLineItemVsLineItem.get(lineItem.lineItemId) : new List<BLN_ProductResponseWrapper.ResponseLineItems>());
            }
        }       
        
        for(BLN_ProductResponseWrapper.ResponseLineItems lineItem : sortedLineItemsWithAddons){
            if(productMDMIDProductMap.containsKey(lineItem.partNumber)){
                BLN_ProductAvailabilityWrapper.ProductSelectionWrapper productResponseWrapperVar = new BLN_ProductAvailabilityWrapper.ProductSelectionWrapper();
                
                productResponseWrapperVar.productName = lineItem.partOfBundle && (lineItem.lineItemId == lineItem.parentLineItemId) ? lineItem.bundleName : productMDMIDProductMap.get(lineItem.partNumber).Name;
                productResponseWrapperVar.isBranchOnlyProduct = productMDMIDProductMap.get(lineItem.partNumber).BLN_BranchOnlyProduct__c;
                productResponseWrapperVar.prodCategory = productMDMIDProductMap.get(lineItem.partNumber).BLN_ProductCategory__c != null ? productMDMIDProductMap.get(lineItem.partNumber).BLN_ProductCategory__c : '';
                productResponseWrapperVar.selectProduct = lineItem.selectProduct;
                productResponseWrapperVar.bomMandatory = lineItem.bomMandatory;
                productResponseWrapperVar.lineItemId = lineItem.lineItemId;
                productResponseWrapperVar.productCode = lineItem.partNumber != null ? lineItem.partNumber : '';
                productResponseWrapperVar.quantity = lineItem.quantity;
                productResponseWrapperVar.netPriceIncludingTax = lineItem.netPriceIncludingTax;
                productResponseWrapperVar.netPrice = lineItem.netPrice;
                productResponseWrapperVar.totalTax = lineItem.totalTax;
                productResponseWrapperVar.bundleName = lineItem.bundleName != null ? lineItem.bundleName : '';
                productResponseWrapperVar.parentLineItemId = lineItem.parentLineItemId;
                productResponseWrapperVar.partOfBundle = lineItem.partOfBundle;
                productResponseWrapperVar.bundleHierarchy = lineItem.bundleHierarchy != null ? lineItem.bundleHierarchy : '';
                productResponseWrapperVar.bomId = lineItem.parentBomId != null && lineItem.parentBomId != '' ? lineItem.parentBomId : '';
                productResponseWrapperVar.hierarchy = lineItem.leadingProductIndicator == true && lineItem.parentBomId != '' && lineItem.parentBomId != null ? 'parent' : lineItem.leadingProductIndicator == false && lineItem.parentBomId != '' && lineItem.parentBomId != null ? 'child' : '';        
                productResponseWrapperVar.isBondedNonBonded = productMDMIDProductMap.get(lineItem.partNumber).BLN_BondedNonBonded__c;
                productResponseWrapperVar.productId = productMDMIDProductMap.get(lineItem.partNumber).Id;
                productSelectionDataList.add(productResponseWrapperVar);
            }
        }
        
        for(BLN_ProductAvailabilityWrapper.DiscountBandWrapper discountItem: discountBandDetailsList) {
            discountItem.locationName = guIdVsDisplayDeatilsDataMap.get(discountItem.locationId).quotelocation;
        }
        
        BLN_ProductAvailabilityWrapper.DisplayDetailsWrapper returnData = new BLN_ProductAvailabilityWrapper.DisplayDetailsWrapper();
        returnData.productDataList = productSelectionDataList;
        returnData.quoteDetailsDataList = quoteDetailsList;
        returnData.discountBandDetails = discountBandDetailsList;
        //returnData.earliestAvailabilityDetails = availibilityDatesList;
        returnData.liabilityDataList = liabilityData;
        returnData.earliestAvailabilityList = earliestAvailabilityData;
        
        return returnData;       
    }

    /* MethodName : createOrdersAndOrderItems
Description : This method is used to create order and order Item.
CreatedDate: 24-04-2024
Change log :
****************************************/
    // This method is part of 6570 i.e. creation of order and order item. 
    

    @AuraEnabled   
    public static List<String> createOrdersAndOrderItems(String mainJson,String selectedProducts, String selectedAddonProducts, String appointmentJson, String caseId, decimal discount){
        Case caseRecord = new Case();
        caseRecord = [SELECT Id,AccountId,BLN_PricingDate__c,CreatedDate,OwnerId FROM Case WHERE Id = :caseId  LIMIT 1];
        
        List<String> locationGuIds = new List<String>();
        BLN_ProductResponseWrapper.ResponseProduct mainData = (BLN_ProductResponseWrapper.ResponseProduct) JSON.deserialize(mainJson,BLN_ProductResponseWrapper.ResponseProduct.class);
        
        List<BLN_ProductAvailabilityWrapper.ProductSelectionWrapper> selectedProdsData = (List<BLN_ProductAvailabilityWrapper.ProductSelectionWrapper>) JSON.deserialize(selectedProducts, List<BLN_ProductAvailabilityWrapper.ProductSelectionWrapper>.class);
		List<BLN_ProductAvailabilityWrapper.ProductSelectionWrapper> selectedAddonProdsData = (List<BLN_ProductAvailabilityWrapper.ProductSelectionWrapper>) JSON.deserialize(selectedAddonProducts, List<BLN_ProductAvailabilityWrapper.ProductSelectionWrapper>.class);        
        
        List<BLN_ProductAvailabilityWrapper.AppointmentWrapper> appointmentData = (List<BLN_ProductAvailabilityWrapper.AppointmentWrapper>) JSON.deserialize(appointmentJson, List<BLN_ProductAvailabilityWrapper.AppointmentWrapper>.class);
        String primaryLocationId = '';
        Map<String,String> bomIdVsServAppointmentIdMap = new Map<String,String>();
        Map<String,String> bomIdVsServiceLocationIdMap = new Map<String,String>();
        Map<String,String> bundleNameVsServAppointmentIdMap = new Map<String,String>();
        Map<Integer,Datetime> litneItemIdVsSAStartDate = new Map<Integer,Datetime>();
        Map<String,String> bundleNameVsServiceLocationMap = new Map<String,String>();
        Map<Integer,String> lineItemIdVsServAppointmentIdMap = new Map<Integer,String>();
        Map<Integer,String> lineItemIdVsServiceLocationIdMap = new Map<Integer,String>();
        Map<Integer,boolean> outOfStockWithOrderItemId = new Map<Integer,boolean>();
        for(BLN_ProductAvailabilityWrapper.AppointmentWrapper data : appointmentData){
            if(data.isPrimaryLocation){
                primaryLocationId = data.serviceLocationId;
            }
            
            for(BLN_ProductAvailabilityWrapper.Appointments apt : data.appointments){
                for(BLN_ProductAvailabilityWrapper.productAvailibilities prodAvail : apt.productAvailibilities){
                    for(BLN_ProductAvailabilityWrapper.Products prod : prodAvail.products){
                        if(prod.productEnable && prod.productCode != null){
                            lineItemIdVsServAppointmentIdMap.put(prod.lineItemId,String.isNotBlank(apt.serviceAppointmentId) ? apt.serviceAppointmentId : null);                            
                            lineItemIdVsServiceLocationIdMap.put(prod.lineItemId,String.isNotBlank(apt.locationId) ? apt.locationId : null);                          
                            if(prod.partOfBundle == true){
                                bundleNameVsServAppointmentIdMap.put(prod.bundleName,String.isNotBlank(apt.serviceAppointmentId) ? apt.serviceAppointmentId : null);
                                bundleNameVsServiceLocationMap.put(prod.bundleName,apt.locationId);
                            }
                            else if(prod.bomId != ''){
                                bomIdVsServAppointmentIdMap.put(prod.bomId,String.isNotBlank(apt.serviceAppointmentId) ? apt.serviceAppointmentId : null);
                                bomIdVsServiceLocationIdMap.put(prod.bomId,apt.locationId);
                            }
                            prod.isCPTDate = prod.isCPTDate != null ? prod.isCPTDate : false;
                            outOfStockWithOrderItemId.put(prod.lineItemId, prod.isCPTDate);
                        }
                        
                    }
                }
            }
        }

        Map<Integer,BLN_ProductAvailabilityWrapper.ProductSelectionWrapper> lineItemIdVsProdWrapper = new Map<Integer,BLN_ProductAvailabilityWrapper.ProductSelectionWrapper>();
        List<BLN_ProductAvailabilityWrapper.ProductSelectionWrapper> allSelectedProds = new List<BLN_ProductAvailabilityWrapper.ProductSelectionWrapper>(selectedProdsData);
        allSelectedProds.addAll(selectedAddonProdsData);
        
        for(BLN_ProductAvailabilityWrapper.ProductSelectionWrapper prodData : allSelectedProds){
            lineItemIdVsProdWrapper.put(prodData.lineItemId,prodData);
        }
        Map<OrderItem,String> partNumberMap = new Map<OrderItem, String>();
        Map<String,Product2> productIdVsMDMIdMap = new Map<String,Product2>();
        Map<String,PricebookEntry> productCodeVsPriceBookEntryMap = new Map<String,PricebookEntry>();
        Map<Order,List<OrderItem>> orderDataMap = new Map<Order,List<OrderItem>>();
        List<Order> orderList = new List<Order>();
        List<OrderItem> orderItemList = new List<OrderItem>();
        Map<OrderItem,String> orderItemWithPartNumberMap = new Map<OrderItem,String>();
        
        Order orderRecord = new Order();
        String quoteId;
        Map<String,BLN_ProductResponseWrapper.ResponseQuotes> locationIdVsQuoteMap = new  Map<String,BLN_ProductResponseWrapper.ResponseQuotes>();

        ServiceTerritory servTer = [select id, BLN_StockHoldingDurationInDays__c from ServiceTerritory where BLN_GUID__c = :mainData.quotes[0].locationId  limit 1];

        for(BLN_ProductResponseWrapper.ResponseQuotes quoteVar : mainData.quotes){
            if(quoteVar.locationId == primaryLocationId){
                quoteId = quoteVar.quoteId;
                orderRecord.BLN_Case__c	= caseRecord.Id;
                orderRecord.BLN_CPQExternalQuoteId__c = quoteVar.quoteId;
                if(servTer!=null){
                    orderRecord.BLN_ServiceTerritory__c  = servTer.id;
                }
                else{
                    orderRecord.BLN_ServiceTerritory__r  = new ServiceTerritory(BLN_GUID__c = quoteVar.locationId);
                }
                orderRecord.BLN_TotalPrice__c = quoteVar.quoteTotals.totalPrice;
                orderRecord.BLN_TotalTax__c = quoteVar.quoteTotals.totalTax;
                orderRecord.BLN_TotalRepair__c	= quoteVar.quoteTotals.totalRepair;
                orderRecord.BLN_TotalReplacement__c = quoteVar.quoteTotals.totalReplacement;
                orderRecord.BLN_TotalCalibration__c = quoteVar.quoteTotals.totalCalibration;
                orderRecord.BLN_TotalSundries__c = quoteVar.quoteTotals.totalSundries;
                orderRecord.BLN_PayableByInsuranceRepair__c = quoteVar.insuranceTotals.payablebyInsuranceRepair;
                orderRecord.BLN_PayableByInsuranceReplacement__c = quoteVar.insuranceTotals.payablebyInsuranceReplacement;
                orderRecord.BLN_PayableByInsuranceCalibration__c = quoteVar.insuranceTotals.payablebyInsuranceCalibration;
                orderRecord.BLN_PayableByInsuranceSundry__c = quoteVar.insuranceTotals.payablebyInsuranceSundry;
                orderRecord.BLN_TotalPayableByInsurance__c = quoteVar.insuranceTotals.totalPayablebyInsurance;
                orderRecord.BLN_PayableByMotoristRepair__c = quoteVar.MotoristTotals.payablebyMotoristRepair;
                orderRecord.BLN_PayableByMotoristReplacement__c = quoteVar.MotoristTotals.payablebyMotoristReplacement;
                orderRecord.BLN_PayableByMotoristCalibration__c = quoteVar.MotoristTotals.payablebyMotoristCalibration;
                orderRecord.BLN_PayableByMotoristSundry__c = quoteVar.MotoristTotals.payablebyMotoristSundry;
                orderRecord.BLN_TotalTaxPayablebyMotorist__c = quoteVar.MotoristTotals.totalTaxPayablebyMotorist;
                orderRecord.BLN_TotalPayableByMotorist__c = quoteVar.MotoristTotals.totalPayableByMotorist;
                orderRecord.BLN_TotalTaxPayablebyInsurance__c = quoteVar.insuranceTotals.totalTaxPayablebyInsurance;
                orderRecord.BLN_PriceExpirationDate__c = Date.valueOf(quoteVar.priceExpirationDate);
                orderRecord.BLN_TotalPayablebyTradeCompany__c = quoteVar.TradeCompanyTotals.totalPayableByTrade;
                orderRecord.BLN_TotalTaxRepair__c = quoteVar.TaxTotals.totalTaxRepair;
                orderRecord.BLN_TotalTaxReplacement__c = quoteVar.TaxTotals.totalTaxReplacement;
                orderRecord.BLN_TotalTaxCalibration__c	= quoteVar.TaxTotals.totalTaxCalibration;
                orderRecord.BLN_TotalTaxSundries__c = quoteVar.TaxTotals.totalTaxSundries;
                orderRecord.BLN_PayablebyTradeRepair__c = quoteVar.TradeCompanyTotals.payablebyTradeRepair;
                orderRecord.BLN_PayablebyTradeReplacement__c = quoteVar.TradeCompanyTotals.payablebyTradeReplacement;
                orderRecord.BLN_PayablebyTradeCalibration__c = quoteVar.TradeCompanyTotals.payablebyTradeCalibration;
                orderRecord.BLN_PayablebyTradeSundry__c = quoteVar.TradeCompanyTotals.payablebyTradeSundry;
                orderRecord.BLN_TotalTaxPayablebyTrade__c = quoteVar.TradeCompanyTotals.payableByTradeTotalTax;
                orderRecord.BLN_TotalIncludingTaxMotorist__c = quoteVar.MotoristTotals.totalIncludingTaxPayableByMotorist;
                orderRecord.BLN_TotalIncludingTaxInsuranceCompany__c = quoteVar.InsuranceTotals.totalIncludingTaxPayableByInsurance;
                orderRecord.BLN_TotalIncludingTaxTrade__c = quoteVar.TradeCompanyTotals.totalPayableByTradeIncludingTax;
                orderRecord.BLN_TotalIncludingTax__c = quoteVar.QuoteTotals.totalIncludingTax;
                orderRecord.BLN_DiscountThresholdAmountA__c = quoteVar.discountThresholdA;
                orderRecord.BLN_DiscountThresholdAmountB__c = quoteVar.discountThresholdB;
                orderRecord.BLN_DiscountThresholdAmountC__c = quoteVar.discountThresholdC;
                orderRecord.AccountId = caseRecord.AccountId;
                orderRecord.BLN_Discount__c = discount;
                orderRecord.EffectiveDate = System.today();
                orderRecord.Status = System.label.BLN_Accepted;

                for(BLN_ProductResponseWrapper.ResponseLineItems lineItem : quoteVar.lineItems){
                    OrderItem ordrItm = new OrderItem();
                    Order orderRec = new Order(BLN_CPQExternalQuoteId__c = quoteId);
                    ordrItm.Order = new Order(BLN_CPQExternalQuoteId__c = quoteId);
                    ordrItm.BLN_DocumentNumber__c = lineItem.lineItemId;
                    ordrItm.BLN_BundleName__c = lineItem.bundleName;
                    ordrItm.Quantity = lineItem.quantity;
                    ordrItm.Description	= lineItem.partDescription;
                    ordrItm.UnitPrice = lineItem.baseListPrice;
                    ordrItm.BLN_NetPriceAfterPromotion__c = lineItem.netPrice;                
                    ordrItm.BLN_NetPriceIncludingTax__c = lineItem.netPriceIncludingTax;
                    ordrItm.BLN_TaxRate__c = lineItem.taxRate;
                    ordrItm.BLN_TotalTax__c = lineItem.totalTax;
                    ordrItm.BLN_Optional__c = lineItem.selectProduct == true ? 'Mandatory' : 'Non-Mandatory';
                    ordrItm.BLN_IsProductSelected__c = lineItem.selectProduct;
                    ordrItm.BLN_PartOfBundle__c = lineItem.partOfBundle;
                    ordrItm.BLN_BOMId__c = lineItem.parentBOMId;
                    ordrItm.BLN_LeadingPartIndicator__c = lineItem.leadingProductIndicator;
                    ordrItm.BLN_BranchThreshold__c = servTer.BLN_StockHoldingDurationInDays__c;

                    if(lineItem.lineItemId != null && outOfStockWithOrderItemId.containsKey(lineItem.lineItemId)){
                        ordrItm.BLN_OutOfStock__c = Boolean.valueOf(outOfStockWithOrderItemId.get(lineItem.lineItemId));
                    }
                    
                    if(lineItemIdVsProdWrapper.containsKey(lineItem.lineItemId) && bomIdVsServiceLocationIdMap.containsKey(lineItem.parentBOMId)){
                        ordrItm.BLN_FittingLocation__r = new Schema.Location(BLN_GUID__c = bomIdVsServiceLocationIdMap.get(lineItem.parentBOMId));
                    }
                    else if(lineItemIdVsProdWrapper.containsKey(lineItem.lineItemId) && bundleNameVsServiceLocationMap.containsKey(lineItem.bundleName)){
                        ordrItm.BLN_FittingLocation__r = new Schema.Location(BLN_GUID__c = bundleNameVsServiceLocationMap.get(lineItem.bundleName));
                    }   
                    else if(lineItemIdVsServiceLocationIdMap.containsKey(lineItem.lineItemId)) {
                        ordrItm.BLN_FittingLocation__r = new Schema.Location(BLN_GUID__c = lineItemIdVsServiceLocationIdMap.get(lineItem.lineItemId));
                    }
                    
                    if(lineItemIdVsProdWrapper.containsKey(lineItem.lineItemId) && bomIdVsServAppointmentIdMap.containsKey(lineItem.parentBOMId)){
                        ordrItm.BLN_ServiceAppointment__c = bomIdVsServAppointmentIdMap.get(lineItem.parentBOMId);      
                    }
                    else if(lineItemIdVsProdWrapper.containsKey(lineItem.lineItemId) && bundleNameVsServAppointmentIdMap.containsKey(lineItem.bundleName)){
                        ordrItm.BLN_ServiceAppointment__c = bundleNameVsServAppointmentIdMap.get(lineItem.bundleName);
                    }
                    else if(lineItemIdVsServAppointmentIdMap.containsKey(lineItem.lineItemId)){
                        ordrItm.BLN_ServiceAppointment__c = lineItemIdVsServAppointmentIdMap.get(lineItem.lineItemId);
                    }    
                    
                    if(litneItemIdVsSAStartDate.containsKey(lineItem.lineItemId))
                    {
                        ordrItm.BLN_StockOrderAppointmentDate__c = litneItemIdVsSAStartDate.get(lineItem.lineItemId);
                    }
                    orderItemWithPartNumberMap.put(ordrItm,lineItem.partNumber);
                    orderItemList.add(ordrItm);
                }
                orderDataMap.put(orderRecord,orderItemList);
            }
        }

        List<Product2> relatedProductList = new List<Product2>();
        relatedProductList = [SELECT Id, Name, BLN_MDMID__c FROM Product2 WHERE IsActive = true AND BLN_MDMID__c IN :orderItemWithPartNumberMap.values()  LIMIT 10000];
        for(Product2 prod : relatedProductList) {
            productIdVsMDMIdMap.put(prod.BLN_MDMID__c,prod);  
        }
        List<PricebookEntry> relatedPriceEntryList = new List<PricebookEntry>();        
        relatedPriceEntryList = [SELECT Id, Pricebook2Id, ProductCode, UnitPrice, IsActive	FROM PricebookEntry WHERE IsActive = true AND Pricebook2.IsActive = true AND Pricebook2.IsStandard = true AND ProductCode IN :orderItemWithPartNumberMap.values()  LIMIT 10000];
        for(PricebookEntry pricebookEntryRecord : relatedPriceEntryList) {
            productCodeVsPriceBookEntryMap.put(pricebookEntryRecord.ProductCode,pricebookEntryRecord);
        }
        
        List<OrderItem> orderItemsWithPricebookData = new List<OrderItem>();
        
        if(!orderDataMap.isEmpty()) {
            for(Order order1 : orderDataMap.keySet()){            
                for(OrderItem orderItem1 : orderDataMap.get(order1)) {
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
        Database.SaveResult[] orderSaveResult = new Database.SaveResult[0]; 
        Database.SaveResult[] orderItemSaveResult = new Database.SaveResult[0]; 
        orderSaveResult = Database.insert(orderList,true);
        orderItemSaveResult = Database.insert(orderItemsWithPricebookData,true);
        
        // Update Case.BLN_PricingDate__c with Case.CreatedDate after successful order and order item creation
        if (orderSaveResult != null && orderSaveResult.size() > 0 && orderSaveResult[0].isSuccess() &&
        orderItemSaveResult != null && orderItemSaveResult.size() > 0 && orderItemSaveResult[0].isSuccess()) {
            caseRecord.BLN_PricingDate__c = caseRecord.CreatedDate.date();
            if(Schema.sObjectType.Case.isUpdateable()){
            update caseRecord;
            }
        }
        //update case cpq quote Id Collection
        updateAllQuoteIds(mainJson,caseId);

        List<Group> queueQualityId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = :System.label.BLN_QualityQueue ];
        List<Group> queueProvisionalId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = :System.label.BLN_ProvisionalQueue ];
        
        List<Id> orderItemIdsStockCall = new List<Id>();
        List<String> orderItemStringList = new List<String>();
        if(caseRecord.OwnerId == queueQualityId[0].Id || caseRecord.OwnerId == queueProvisionalId[0].Id || test.isRunningTest()){
            for(OrderItem rec : orderItemsWithPricebookData){
                if(rec.BLN_OutOfStock__c == false)
                {
                    orderItemIdsStockCall.add(rec.Id);
                    orderItemStringList.add((String)rec.Id);
                }
            }
            //Future method for stock movement request
           BLN_StockReservationController.stockMovementCallout(orderItemIdsStockCall);
        }
        return orderItemStringList;
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
        allKnowledges= [Select id,Title,BLN_DisplayLocation__c from Knowledge__kav where BLN_DisplayLocation__c = :System.label.BLN_QuoteSummary OR BLN_DisplayLocation__c = :System.label.BLN_QuotePresentation ];
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