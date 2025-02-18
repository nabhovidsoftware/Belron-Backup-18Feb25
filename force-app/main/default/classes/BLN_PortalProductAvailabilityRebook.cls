/*****************************************
ClassName : BLN_ProductAvailability
Description : FOUK-4243, 4049 This controller class is used in lwc [Portal].
CreatedDate: 24-11-2023
CreatedBy : PwC-India
****************************************/
public with sharing class BLN_PortalProductAvailabilityRebook {

    static final String QUEUE_SPECIALS = 'Specials';
    static final String QUEUE_NO_STOCK = 'No Stock';
    static final String QUEUE = 'Queue';
    static final String ISSUE = 'Issue';

    public class ServiceLabel {
        @AuraEnabled public String serviceLocation {get; set;}
    }
    public class Product {
        @AuraEnabled public String products {get; set;}
    }
    
    @AuraEnabled 
    public static BLN_ProductAvailabilityWrapper.AppointmentWrapper parse(String json){
        return (BLN_ProductAvailabilityWrapper.AppointmentWrapper) System.JSON.deserialize(json, BLN_ProductAvailabilityWrapper.AppointmentWrapper.class);
    }

    @AuraEnabled
    public static String getQuoteApi(String cpqExtenalCode,String caseId){
        BLN_APICalloutMapper__mdt calloutDetails = BLN_APICalloutMapper__mdt.getInstance(System.label.BLN_GetQuoteAPI);
        Map<String,String> headerMap = new Map<String,String>();
        headerMap.put(System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[0],System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[1]+' '+BLN_HTTPCallOutAccessToken.getAccessToken()?.accessToken);
        
        String hCode = EncodingUtil.convertToHex(Crypto.generateAesKey(128));
        String correlID = hCode.substring(0,4)+'-'+hCode.substring(0,4)+'-'+hCode.substring(5,8)+'-'+hCode.substring(9,12)+'-'+hCode.substring(12,16)+'-'+hCode.substring(16,20);
        headerMap.put(System.label.BLN_XCORRELATIONID,correlID);
        Integer timeout = Integer.valueOf(calloutDetails.BLN_APITimeout__c);
        HttpResponse response = BLN_HttpCalloutUtility.makeCallout(calloutDetails.BLN_DestinationSystem__c,calloutDetails.BLN_NamedCredential__c + calloutDetails.BLN_CalloutURL__c + cpqExtenalCode, calloutDetails.BLN_Method__c,headerMap,caseId,timeout);
        String returnPayloadAsString = response.getStatusCode() == 200 ? response.getBody() : System.label.BLN_CalloutFailed;
        return returnPayloadAsString;
        
    }
    //description:FOUK-4455
    @AuraEnabled
	public static String callCPQCloneAPI(String quoteIds,String caseId){

        List<String> quoteIdList = new List<String>(quoteIds.split(','));
        Map<String,List<String>> payloadMap = new Map<String,List<String>>();
        payloadMap.put(System.label.BLN_QuoteIdsProperty,quoteIdList);

        String payload = JSON.serializePretty(payloadMap);
       // String returnPayloadAsString = BLN_QuoteJsonFile.bundleJson1();
        BLN_APICalloutMapper__mdt calloutDetails = BLN_APICalloutMapper__mdt.getInstance(System.label.BLN_CloneQuoteAPI);
        Map<String,String> headerMap = new Map<String,String>();

        for(String str : calloutDetails.BLN_Headers__c.split(System.label.BLN_Semicolon)){
            headerMap.put(str.split(System.label.BLN_Comma)[0],str.split(System.label.BLN_Comma)[1]);
        }
        headerMap.put(System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[0],System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[1]+' '+BLN_HTTPCallOutAccessToken.getAccessToken()?.accessToken);
        
        String hCode = EncodingUtil.convertToHex(Crypto.generateAesKey(128));
        String correlID = hCode.substring(0,4)+'-'+hCode.substring(0,4)+'-'+hCode.substring(5,8)+'-'+hCode.substring(9,12)+'-'+hCode.substring(12,16)+'-'+hCode.substring(16,20);
        headerMap.put(System.label.BLN_XCORRELATIONID,correlID);
        
        Integer timeout = Integer.valueOf(calloutDetails.BLN_APITimeout__c);
        HttpResponse response = BLN_HttpCalloutUtility.makeCallout(calloutDetails.BLN_DestinationSystem__c,calloutDetails.BLN_NamedCredential__c + calloutDetails.BLN_CalloutURL__c, calloutDetails.BLN_Method__c,headerMap,caseId,payload,timeout);
        String returnPayloadAsString = response.getStatusCode() == 201 ? response.getBody() : System.label.BLN_CalloutFailed;
        return returnPayloadAsString; 
    }
    @AuraEnabled
    public static case getCaseData(String caseId){
        Case cse = [Select Id, BLN_IsForceReprice__c From Case where Id =: caseId  LIMIT 1];
        return cse;
    }
    public static List<BLN_ProductAvailabilityWrapper.LocationWrapper> getNearestServiceLocationsByLatLong(Case motoristCase, Double userLatitude, Double userLongitude){
        //FOUK-4639
        List<BLN_ProductAvailabilityWrapper.LocationWrapper> nearestLocationDetails = new List<BLN_ProductAvailabilityWrapper.LocationWrapper>();
        BLN_ProductAvailabilityWrapper.LocationWrapper locWrapper;
        List<ServiceTerritory> branchST = new List<ServiceTerritory>();
            if(test.isRunningTest()){
                branchST = [SELECT id, Latitude,Longitude,BLN_GUID__c,BLN_ExcludedProduct__c, BLN_CostCenter__c FROM ServiceTerritory LIMIT 1]; 
            }
            else{
                branchST = motoristCase.BLN_Vehicle__r.BLN_SpecialVehicle__c ? [SELECT Id,Address,BLN_GUID__c,BLN_CostCenter__c, BLN_ExcludedProduct__c, BLN_Type__c, DISTANCE(Address,GEOLOCATION(:userLatitude,:userLongitude),'mi') distanceChart FROM ServiceTerritory WHERE BLN_ConsiderforR1__c = false AND IsActive = true AND BLN_Type__c = :System.label.BLN_Branch AND BLN_Specials__c = true AND Latitude != null AND Longitude != null AND BLN_GUID__c != '' AND BLN_CostCenter__c != '' ORDER BY DISTANCE(Address,GEOLOCATION(:userLatitude,:userLongitude),'mi') ASC limit 3] :
                [SELECT id,Address,BLN_GUID__c,BLN_CostCenter__c,BLN_Type__c, BLN_ExcludedProduct__c, DISTANCE(Address,GEOLOCATION(:userLatitude,:userLongitude),'mi') sampleDistance FROM ServiceTerritory WHERE BLN_ConsiderforR1__c = false AND IsActive=true AND BLN_Type__c= :System.label.BLN_Branch AND BLN_GUID__c != '' AND Latitude != null AND Longitude != null AND BLN_CostCenter__c != '' ORDER BY DISTANCE(Address,GEOLOCATION(:userLatitude,:userLongitude),'mi') ASC limit 3];
                    }
            
            /* Collect the GUID for get OrgCodeLocation */
            Set<String> guIds = new Set<String>();
            for(ServiceTerritory st : branchST){
                if(String.isNotBlank(st.BLN_GUID__c)){
                    guIds.add(st.BLN_GUID__c);
                }
            }
            Map<String, String> guidWithOrgCodeLocations = new Map<String, String>();
            for(Schema.Location loc:  [SELECT Id, BLN_OrgCodeLocation__c, BLN_GUID__c FROM Location WHERE BLN_GUID__c != '' AND BLN_GUID__c IN: guIds   ]) {
                guidWithOrgCodeLocations.put(loc.BLN_GUID__c, loc.BLN_OrgCodeLocation__c != null ? loc.BLN_OrgCodeLocation__c : '');
            }

            for(ServiceTerritory st : branchST){
                locWrapper = new BLN_ProductAvailabilityWrapper.LocationWrapper();
                locWrapper.costCenterId = guidWithOrgCodeLocations.containsKey(st.BLN_GUID__c) ? guidWithOrgCodeLocations.get(st.BLN_GUID__c) : '';
                locWrapper.locationId = st.BLN_GUID__c;
                locWrapper.mobileLocationIndicator = false;
                locWrapper.countryCode = 'GB';
                locWrapper.excludeProduct = st.BLN_ExcludedProduct__c != null ? st.BLN_ExcludedProduct__c : 'TestExcludProduct';
                nearestLocationDetails.add(locWrapper);
            }
            
            if(!motoristCase.BLN_Vehicle__r.BLN_SpecialVehicle__c){
                List<FSL__Polygon__c> polygonList = new List<FSL__Polygon__c>();
                if(FSL__Polygon__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible() && !test.isRunningTest()){   
                    polygonList = [SELECT id,FSL__Service_Territory__r.BLN_GUID__c,FSL__Service_Territory__r.BLN_CostCenter__c,FSL__Service_Territory__r.BLN_Type__c,FSL__Service_Territory__r.Address FROM FSL__Polygon__c WHERE FSL__Service_Territory__r.BLN_ConsiderforR1__c = false AND FSL__Service_Territory__r.isActive = true AND FSL__Service_Territory__r.BLN_Type__c = :System.label.BLN_Mobile AND Id IN :FSL.PolygonUtils.getAllPolygonsByLatLong(userLongitude,userLatitude)   ORDER BY DISTANCE(FSL__Service_Territory__r.Address,GEOLOCATION(:userLatitude,:userLongitude),'mi') ASC LIMIT 1];                
                }
                if(test.isRunningTest()){
                    polygonList = [SELECT FSL__KML__c, FSL__Mi_Lo__c, FSL__Color__c, Name, FSL__Service_Territory__r.BLN_GUID__c,FSL__Service_Territory__r.BLN_CostCenter__c,  FSL__Ma_Lo__c, FSL__Mi_La__c, FSL__Ma_La__c, FSL__Service_Territory__c FROM FSL__Polygon__c   LIMIT 1];
                }
                Set<String> mobGuidList = new Set<String>();
                for(FSL__Polygon__c polygon : polygonList){
                    if(String.isNotBlank(polygon.FSL__Service_Territory__r.BLN_GUID__c)){
                        mobGuidList.add(polygon.FSL__Service_Territory__r.BLN_GUID__c);
                    }
                }
                Map<String, String> mobGuidWithOrgCodeLocations = new Map<String, String>();
                for(Schema.Location loc:  [SELECT Id, BLN_OrgCodeLocation__c, BLN_GUID__c FROM Location WHERE BLN_GUID__c != '' AND BLN_GUID__c IN: mobGuidList   ]) {
                    mobGuidWithOrgCodeLocations.put(loc.BLN_GUID__c, loc.BLN_OrgCodeLocation__c != null ? loc.BLN_OrgCodeLocation__c : '');
                }        
                for(FSL__Polygon__c poly : polygonList){
                    locWrapper = new BLN_ProductAvailabilityWrapper.LocationWrapper();
                    locWrapper.costCenterId = poly.FSL__Service_Territory__r != null && poly.FSL__Service_Territory__r.BLN_GUID__c != null && mobGuidWithOrgCodeLocations.containsKey(poly.FSL__Service_Territory__r.BLN_GUID__c) ? mobGuidWithOrgCodeLocations.get(poly.FSL__Service_Territory__r.BLN_GUID__c) : '';
                    locWrapper.locationId = poly.FSL__Service_Territory__r.BLN_GUID__c;
                    locWrapper.mobileLocationIndicator = true;
                    locWrapper.countryCode = 'GB';
                    nearestLocationDetails.add(locWrapper);
                }
            }
        return nearestLocationDetails;
    }    
    
    @AuraEnabled
    public static String makeNewQuoteCallout(String motoristCaseId, Double userLatitude, Double userLongitude,String existingGUId){      

        Case motoCase = BLN_QuoteBookingHandler.getCaseForQuoteCallout(motoristCaseId);
        
        List<BLN_ProductAvailabilityWrapper.LocationWrapper> nearestLocations = BLN_PortalProductAvailabilityRebook.getNearestServiceLocationsByLatLong(motoCase,userLatitude,userLongitude);            
        
        Boolean isGUIdExists = false;
        BLN_ProductAvailabilityWrapper.LocationWrapper existingLocationData = new BLN_ProductAvailabilityWrapper.LocationWrapper();
        Integer indexToRemove = -1;
        for(Integer i = 0; i < nearestLocations.size(); i++){
            if(nearestLocations[i].locationId == existingGUId){
                existingLocationData.costCenterId = nearestLocations[i].costCenterId;
                existingLocationData.locationId = nearestLocations[i].locationId;
                existingLocationData.mobileLocationIndicator = nearestLocations[i].mobileLocationIndicator;
                existingLocationData.countryCode = nearestLocations[i].countryCode;
                existingLocationData.excludeProduct = nearestLocations[i].excludeProduct;
        
                indexToRemove = i;
                isGUIdExists = true;
                break;
            }
        }
        if(isGUIdExists && nearestLocations.size() > 1){
            nearestLocations.remove(indexToRemove);
            nearestLocations.add(0,existingLocationData);
        }
        else if(!isGUIdExists){
            ServiceTerritory serv = new ServiceTerritory();
            serv = [SELECT id,BLN_GUID__c,BLN_CostCenter__c,BLN_Type__c,BLN_ExcludedProduct__c FROM ServiceTerritory WHERE BLN_GUID__c = :existingGUId  LIMIT 1 ];
            existingLocationData.costCenterId = serv.BLN_CostCenter__c;
            existingLocationData.locationId = serv.BLN_GUID__c;
            existingLocationData.mobileLocationIndicator = serv.BLN_Type__c == System.label.BLN_Mobile ? true : false;
            existingLocationData.countryCode = 'GB';
            existingLocationData.excludeProduct = serv.BLN_ExcludedProduct__c != null ? serv.BLN_ExcludedProduct__c : 'TestExcludProduct';
            
          
            if(nearestLocations.size() != 0){
            nearestLocations.add(0,existingLocationData);
         }
        }

        String returnPayloadAsString = BLN_QuoteBookingHandler.makeQuoteCallout(motoCase,nearestLocations);       
        // Map<String,Object> payloadMap = new Map<String,Object>();
        // payloadMap.put(system.label.BLN_MotoristVATStatus,motoCase.BLN_MotoristTaxStatus__c == System.label.BLN_Yes ? System.label.BLN_Registered : System.label.BLN_Exempt);
        // payloadMap.put(system.label.BLN_CaseId,motoristCaseId);
        // payloadMap.put(system.label.BLN_ServiceCountry,motoCase.BLN_ServiceCountry__c);
        // payloadMap.put(system.label.BLN_Currency,system.label.BLN_GBP);
        // BLN_VehicleDamage__c[] relatedVehicleDamages = [SELECT Id,BLN_BOMID__c,BLN_ProductId__c FROM BLN_VehicleDamage__c WHERE BLN_Case__c=:motoCase.Id  ];
        // Map<String, Integer> bomIdMap = new Map<String,Integer>();
        // Map<String,Integer> partIdMap = new Map<String,Integer>();
        // Integer count;
        // for(BLN_VehicleDamage__c vd : relatedVehicleDamages){
        //     if(String.isNotBlank(vd.BLN_BOMID__c)){
        //         for(String str : (vd.BLN_BOMID__c).split(System.label.BLN_Comma)){
        //             count = 1;
        //             if(bomIdMap.containsKey(str)){
        //                 count = bomIdMap.get(str) + 1;
        //             }
        //             bomIdMap.put(str,count);                    
        //         }	
        //     }
        //     if(String.isNotBlank(vd.BLN_ProductId__c)){
        //         for(String str : (vd.BLN_ProductId__c).split(System.label.BLN_Comma)){
        //             count = 1;
        //             if(partIdMap.containsKey(str)){
        //                 count = partIdMap.get(str) + 1;
        //             }
        //             partIdMap.put(str,count);
        //         }
        //     }
        // }
        // List<BLN_ProductAvailabilityWrapper.BomIdWrap> bomIdList = new List<BLN_ProductAvailabilityWrapper.BomIdWrap>();
        // BLN_ProductAvailabilityWrapper.BomIdWrap bomIds;
        // for(String str : bomIdMap.keySet()){
        //     bomIds = new BLN_ProductAvailabilityWrapper.BomIdWrap();
        //     bomIds.bomId = str;
        //     bomIds.quantity = bomIdMap.get(str);
        //     bomIds.branch = true;
        //     bomIds.mobile = true;
        //     bomIdList.add(bomIds);
        // }
        // payloadMap.put(system.label.BLN_BomIds,bomIdList);
        
        // List<BLN_ProductAvailabilityWrapper.PartIdWrap> partIdList = new List<BLN_ProductAvailabilityWrapper.PartIdWrap>();
        // BLN_ProductAvailabilityWrapper.PartIdWrap partIds;
        // for(String str : partIdMap.keySet()){
        //     partIds = new BLN_ProductAvailabilityWrapper.PartIdWrap();
        //     partIds.partId = str;
        //     partIds.quantity = partIdMap.get(str);
        //     partIds.branch = true;
        //     partIds.mobile = true;
        //     partIdList.add(partIds);
        // }
        // payloadMap.put(system.label.BLN_PartIds,partIdList);
        // payloadMap.put(system.label.BLN_VehicleId,motoCase.BLN_Vehicle__r.BLN_MDMID__c != null ? motoCase.BLN_Vehicle__r.BLN_MDMID__c : '');
        // payloadMap.put(system.label.BLN_AccountId,BLN_ProductAvailabilityUtility.getAccountId(motoCase));
        // payloadMap.put(system.label.BLN_Profile,'');
        // payloadMap.put(system.label.BLN_VoucherCode,'');
        // payloadMap.put(System.label.BLN_QuoteTypeLabel,BLN_ProductAvailabilityUtility.getQuoteType(motoCase));
        // List<BLN_ProductAvailabilityWrapper.LocationWrapper> nearestLocations = BLN_PortalProductAvailabilityRebook.getNearestServiceLocationsByLatLong(motoCase,userLatitude,userLongitude);            
        // payloadMap.put(system.label.BLN_Locations,nearestLocations);
       
        // // List<BLN_ProductAvailabilityWrapper.LocationWrapper> nearestLocations = BLN_PortalProductAvailabilityRebook.getNearestServiceLocationsByLatLong(motoCase,userLatitude,userLongitude);            
        // // Boolean isGUIdExists = false;
        // // BLN_ProductAvailabilityWrapper.LocationWrapper existingLocationData = new BLN_ProductAvailabilityWrapper.LocationWrapper();
        // // Integer indexToRemove = -1;
        // // for(Integer i = 0; i < nearestLocations.size(); i++){
        // //     if(nearestLocations[i].locationId == existingGUId){
        // //         existingLocationData.costCenterId = nearestLocations[i].costCenterId;
        // //         existingLocationData.locationId = nearestLocations[i].locationId;
        // //         existingLocationData.mobileLocationIndicator = nearestLocations[i].mobileLocationIndicator;
        // //         existingLocationData.countryCode = nearestLocations[i].countryCode;
        // //         existingLocationData.excludeProduct = nearestLocations[i].excludeProduct;
        
        // //         indexToRemove = i;
        // //         isGUIdExists = true;
        // //         break;
        // //     }
        // // }
        // // if(isGUIdExists && nearestLocations.size() > 1){
        // //     nearestLocations.remove(indexToRemove);
        // //     nearestLocations.add(0,existingLocationData);
        // // }
        // // else if(!isGUIdExists){
        // //     ServiceTerritory serv = new ServiceTerritory();
        // //     serv = [SELECT id,BLN_GUID__c,BLN_CostCenter__c,BLN_Type__c,BLN_ExcludedProduct__c FROM ServiceTerritory WHERE BLN_GUID__c = :existingGUId   LIMIT 1 ];
        // //     existingLocationData.costCenterId = serv.BLN_CostCenter__c;
        // //     existingLocationData.locationId = serv.BLN_GUID__c;
        // //     existingLocationData.mobileLocationIndicator = serv.BLN_Type__c == System.label.BLN_Mobile ? true : false;
        // //     existingLocationData.countryCode = 'GB';
        // //     existingLocationData.excludeProduct = serv.BLN_ExcludedProduct__c != null ? serv.BLN_ExcludedProduct__c : 'TestExcludProduct';
            
          
        // //     if(nearestLocations.size() != 0){
        // //     nearestLocations.add(0,existingLocationData);
        // //  }
        // // }
        // BLN_ProductAvailabilityWrapper.InsuranceDetailsWrapper insuranceDetails = new BLN_ProductAvailabilityWrapper.InsuranceDetailsWrapper();
       
        // insuranceDetails.glassLimit = 0;
        // insuranceDetails.sundryExcess = 0;
        // if(motoCase.BLN_Corporate__c !=null){
        // insuranceDetails.calibrationExcess = motoCase.BLN_Corporate__r.BLN_ADASExcess__c == null || String.valueOf (motoCase.BLN_Corporate__r.BLN_ADASExcess__c) == '' ? 0:  motoCase.BLN_Corporate__r.BLN_ADASExcess__c;		
        // insuranceDetails.bodyglassExcess = motoCase.BLN_Corporate__r.BLN_BodyGlassExcess__c == null || String.valueOf(motoCase.BLN_Corporate__r.BLN_BodyGlassExcess__c) == '' ? 0:  motoCase.BLN_Corporate__r.BLN_BodyGlassExcess__c;	
        // insuranceDetails.repairExcess = motoCase.BLN_Corporate__r.BLN_RepairExcess__c == null || String.valueOf(motoCase.BLN_Corporate__r.BLN_RepairExcess__c) == '' ? 0:  motoCase.BLN_Corporate__r.BLN_RepairExcess__c;
        // insuranceDetails.replacementExcess = motoCase.BLN_Corporate__r.BLN_ReplacementExcess__c == null || String.valueOf(motoCase.BLN_Corporate__r.BLN_ReplacementExcess__c) == '' ? 0:  motoCase.BLN_Corporate__r.BLN_ReplacementExcess__c;
        // insuranceDetails.windscreenExcess = motoCase.BLN_Corporate__r.BLN_WindscreenExcess__c == null || String.valueOf(motoCase.BLN_Corporate__r.BLN_WindscreenExcess__c) == '' ? 0:  motoCase.BLN_Corporate__r.BLN_WindscreenExcess__c;
        // insuranceDetails.vehicleDamageExcess = motoCase.BLN_Corporate__r.BLN_VehicleDamageExcess__c == null || String.valueOf(motoCase.BLN_Corporate__r.BLN_VehicleDamageExcess__c) == '' ? 0:  motoCase.BLN_Corporate__r.BLN_VehicleDamageExcess__c;
        // insuranceDetails.heatedRearExcess = motoCase.BLN_Corporate__r.BLN_HeatedRearExcess__c == null || String.valueOf(motoCase.BLN_Corporate__r.BLN_HeatedRearExcess__c) == '' ? 0:  motoCase.BLN_Corporate__r.BLN_HeatedRearExcess__c;     
        // }
        // payloadMap.put(system.label.BLN_InsuranceDetails,insuranceDetails);
        // payloadMap.put('tradeAccountId','1234');
        // payloadMap.put('pricingDate','2024-06-13');
        // payloadMap.put('taxRegistrationNumber','129783');
        // payloadMap.put('chfVATStatus','Exempt');
        // payloadMap.put('channel','FrontOffice');
        
        // String payload = JSON.serializePretty(payloadMap);
        // BLN_APICalloutMapper__mdt calloutDetails = BLN_APICalloutMapper__mdt.getInstance(System.label.BLN_QuoteApi);
        // Map<String,String> headerMap = new Map<String,String>();
        // Integer timeout = 30000;
        
        // if(Test.isRunningTest()){
        //     headerMap.put(System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[0],System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[1]+' MockAccessToken123');               
        // }else{
        //     headerMap.put(System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[0],System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[1]+' '+BLN_HTTPCallOutAccessToken.getAccessToken()?.accessToken);
        // }
        // String hCode = EncodingUtil.convertToHex(Crypto.generateAesKey(128));
        // String correlID = hCode.substring(0,4)+'-'+hCode.substring(0,4)+'-'+hCode.substring(5,8)+'-'+hCode.substring(9,12)+'-'+hCode.substring(12,16)+'-'+hCode.substring(16,20);
        // headerMap.put(System.label.BLN_XCORRELATIONID,correlID);
        
        // for(String str : calloutDetails.BLN_Headers__c.split(System.label.BLN_Semicolon)){
        //     headerMap.put(str.split(System.label.BLN_Comma)[0],str.split(System.label.BLN_Comma)[1]);
        // }

        // String returnPayloadAsString = '';
      

        // if(!Test.isRunningTest()){
        //     HttpResponse response = BLN_HttpCalloutUtility.makeCallout(calloutDetails.BLN_DestinationSystem__c,calloutDetails.BLN_NamedCredential__c + calloutDetails.BLN_CalloutURL__c, calloutDetails.BLN_Method__c, headerMap, motoristCaseId, payload,timeout);
        //     returnPayloadAsString = response.getStatusCode() == 201 ? response.getBody() : System.label.BLN_CalloutFailed;
        // }
        // if(Test.isRunningTest()){
        //     returnPayloadAsString = 'Test';
        // }

      
        return returnPayloadAsString;
        
    }

    @AuraEnabled
    public static String getOrderItemsToIdentifyByCPQExternalId(String cpqExtrnlId){
        Order orderRecord  = [SELECT Id,BLN_CPQExternalQuoteId__c,Status,CreatedDate,(SELECT Id,BLN_DocumentNumber__c,Quantity,BLN_ServiceAppointment__c,BLN_FittingLocation__c,BLN_StockLocation__c,BLN_IsProductSelected__c,BLN_OutOfStock__c,BLN_BOMId__c,BLN_BundleName__c,Product2.BLN_MDMID__c FROM OrderItems) FROM ORDER WHERE BLN_CPQExternalQuoteId__c = :cpqExtrnlId   LIMIT 1];
        String returnData  = getOrderItemsToIdentify(orderRecord);

        return returnData;
    }

    @AuraEnabled
    public static String getOrderItemsToIdentifyByStatus(String caseId, String orderStatus){
        Order orderRecord  = [SELECT Id,BLN_CPQExternalQuoteId__c,Status,CreatedDate,(SELECT Id,BLN_DocumentNumber__c,Quantity,BLN_ServiceAppointment__c,BLN_FittingLocation__c,BLN_StockLocation__c,BLN_IsProductSelected__c,BLN_BOMId__c,BLN_BundleName__c,Product2.BLN_MDMID__c FROM OrderItems) FROM ORDER WHERE BLN_Case__c = :caseId AND Status = :System.label.BLN_Invoiced  ORDER BY CreatedDate DESC LIMIT 1];
        String returnData  = getOrderItemsToIdentify(orderRecord);
        return returnData;
    }
    
    public static String getOrderItemsToIdentify(Order orderRecord){
        
        List<BLN_ProductAvailabilityWrapper.LineItemIdentifier> orderItemIdentifierList = new List<BLN_ProductAvailabilityWrapper.LineItemIdentifier>();
        for(OrderItem oi : orderRecord.OrderItems){
            BLN_ProductAvailabilityWrapper.LineItemIdentifier orderItemIdentifier = new BLN_ProductAvailabilityWrapper.LineItemIdentifier();
            orderItemIdentifier.lineItemId = Integer.valueOf(oi.BLN_DocumentNumber__c);
            orderItemIdentifier.partNumber = oi.Product2.BLN_MDMID__c != null ? oi.Product2.BLN_MDMID__c : '';
            orderItemIdentifier.bomId = oi.BLN_BOMId__c != null ? oi.BLN_BOMId__c : '';
            orderItemIdentifier.bundleName = oi.BLN_BundleName__c != null ? oi.BLN_BundleName__c : '';
            orderItemIdentifier.quantity = Integer.valueOf(oi.Quantity);
            orderItemIdentifier.serviceAppointment = oi.BLN_ServiceAppointment__c;
            orderItemIdentifier.fittingLocation = oi.BLN_FittingLocation__c;
            orderItemIdentifier.stockLocation = oi.BLN_StockLocation__c;
            orderItemIdentifier.isSelected = oi.BLN_IsProductSelected__c;
           // orderItemIdentifier.isOutOfStock = oi.BLN_OutOfStock__c ;
            orderItemIdentifierList.add(orderItemIdentifier);
        }
        
        return JSON.serialize(orderItemIdentifierList);
    }

    @AuraEnabled //6286 Start
    public static void updateServiceAppointments(String data,String caseId){
        List<BLN_ProductAvailabilityWrapper.AppointmentWrapper> appointmentData = (List<BLN_ProductAvailabilityWrapper.AppointmentWrapper>) JSON.deserialize(data, List<BLN_ProductAvailabilityWrapper.AppointmentWrapper>.class);
        
        set<string> externalOrderIdList = new set<string>();
        for(BLN_ProductAvailabilityWrapper.AppointmentWrapper order : appointmentData){
            externalOrderIdList.add(order.externalQuoteId);
        }
        set<Id> orderIds =  new set<Id>();
        Order orderRecord = new Order();

        orderRecord = [SELECT Id, AccountId,BLN_CPQExternalQuoteId__c,BLN_ServiceTerritory__r.BLN_GUID__c,BLN_TotalTax__c,BLN_TotalIncludingTaxTrade__c,BLN_TotalTaxPayablebyTrade__c,BLN_TotalPayablebyTradeCompany__c,BLN_TotalIncludingTaxInsuranceCompany__c,BLN_TotalTaxPayablebyInsurance__c,BLN_PayableByInsuranceRepair__c,BLN_TotalIncludingTaxMotorist__c,BLN_TotalTaxPayablebyMotorist__c,BLN_TotalPrice__c,BLN_TotalPayableByMotorist__c, Status,BLN_ServiceTerritory__r.Name,BLN_Case__c,BLN_DiscountThresholdAmountA__c, BLN_DiscountThresholdAmountB__c,
        BLN_DiscountThresholdAmountC__c, BLN_PriceExpirationDate__c, BLN_TotalIncludingTax__c,BLN_ServiceTerritory__c
        FROM Order WHERE Status =: System.label.BLN_Accepted AND BLN_Case__c =:caseId AND BLN_CPQExternalQuoteId__c IN : externalOrderIdList  ORDER BY createddate DESC LIMIT 1];
        orderIds.add(orderRecord.Id);

        map<string, orderItem> orderItemMap = new map<string, orderItem>();
        // query orderItemList
        for(orderItem oli : [SELECT Id, Product2.Name, Product2.BLN_MDMID__c, OrderId, BLN_IsProductSelected__c,BLN_ServiceAppointment__c,BLN_DocumentNumber__c  FROM OrderItem where orderId = :orderRecord.Id AND BLN_IsProductSelected__c = true ]){
            orderItemMap.put(oli.Product2.BLN_MDMID__c, oli);
        }

        for(BLN_ProductAvailabilityWrapper.AppointmentWrapper order : appointmentData){
            for(BLN_ProductAvailabilityWrapper.Appointments appointment : order.Appointments){
                for(BLN_ProductAvailabilityWrapper.ProductAvailibilities productList : appointment.productAvailibilities){
                    for(BLN_ProductAvailabilityWrapper.Products product : productList.Products){
                        if(product.productEnable && orderItemMap.containsKey(product.productCode)){
                            orderItemMap.get(product.productCode).BLN_ServiceAppointment__c = appointment.serviceAppointmentId;
                            //orderItemMap.get(product.productCode).BLN_FittingLocation__c = appointment.fittingLocationId;
                        }
                    }
                }
            }
        }

        if(!orderItemMap.isEmpty()){
            update orderItemMap.values();
        }
    }
    //6286 End

    /*To return liability details */
    @AuraEnabled
    public static List<BLN_ProductAvailabilityWrapper.InsuranceLiabilityWrapper> getLiabilityList(String payload, String quoteId){
        BLN_ProductResponseWrapper.ResponseProduct data = (BLN_ProductResponseWrapper.ResponseProduct) System.JSON.deserialize(payload,BLN_ProductResponseWrapper.ResponseProduct.class);

        List<BLN_ProductAvailabilityWrapper.InsuranceLiabilityWrapper> liabilityData = new List<BLN_ProductAvailabilityWrapper.InsuranceLiabilityWrapper>();
        
        for(BLN_ProductResponseWrapper.ResponseQuotes quoteVar : data.quotes){
            if(quoteVar.quoteId == quoteId){
                BLN_ProductAvailabilityWrapper.InsuranceLiabilityWrapper motoristTotalsLiability = new BLN_ProductAvailabilityWrapper.InsuranceLiabilityWrapper();                
                motoristTotalsLiability.liabilityCategory = System.label.BLN_MotoristLiability;
                motoristTotalsLiability.totalPayable = quoteVar.motoristTotals.totalPayableByMotorist;
                motoristTotalsLiability.totalTaxPayable = quoteVar.motoristTotals.totalTaxPayableByMotorist;
                motoristTotalsLiability.totalIncludingTaxPayable = quoteVar.motoristTotals.totalIncludingTaxPayableByMotorist;
                
                BLN_ProductAvailabilityWrapper.InsuranceLiabilityWrapper insuranceTotalsLiability = new BLN_ProductAvailabilityWrapper.InsuranceLiabilityWrapper();
                insuranceTotalsLiability.liabilityCategory = System.label.BLN_InsuranceLiability;
                insuranceTotalsLiability.totalPayable = quoteVar.insuranceTotals.totalPayableByInsurance;
                insuranceTotalsLiability.totalTaxPayable = quoteVar.insuranceTotals.totalTaxPayableByInsurance;
                insuranceTotalsLiability.totalIncludingTaxPayable = quoteVar.insuranceTotals.totalIncludingTaxPayableByInsurance;
                
                BLN_ProductAvailabilityWrapper.InsuranceLiabilityWrapper tradeCompanyTotalsLiability = new BLN_ProductAvailabilityWrapper.InsuranceLiabilityWrapper();
                tradeCompanyTotalsLiability.liabilityCategory = System.label.BLN_AccountLiability;
                tradeCompanyTotalsLiability.totalPayable = quoteVar.tradeCompanyTotals.totalPayableByTrade;
                tradeCompanyTotalsLiability.totalTaxPayable = quoteVar.tradeCompanyTotals.payableByTradeTotalTax;
                tradeCompanyTotalsLiability.totalIncludingTaxPayable = quoteVar.tradeCompanyTotals.totalPayableByTradeIncludingTax;                
                
                BLN_ProductAvailabilityWrapper.InsuranceLiabilityWrapper totalLiability = new BLN_ProductAvailabilityWrapper.InsuranceLiabilityWrapper(); 
                totalLiability.liabilityCategory = System.label.BLN_Total;
                totalLiability.totalPayable = quoteVar.quoteTotals.totalPrice;
                totalLiability.totalTaxPayable  = quoteVar.quoteTotals.totalTax;
                totalLiability.totalIncludingTaxPayable = quoteVar.quoteTotals.totalIncludingTax;            
                
                liabilityData.addAll(new List<BLN_ProductAvailabilityWrapper.InsuranceLiabilityWrapper>{motoristTotalsLiability,insuranceTotalsLiability,tradeCompanyTotalsLiability,totalLiability});
            }
        }

        return liabilityData;
    }

    @AuraEnabled
    public static Order getAcceptedOrder(String caseId){
        List<Order> orderData = [SELECT Id, AccountId,BLN_CPQExternalQuoteId__c,BLN_ServiceTerritory__r.BLN_GUID__c,BLN_TotalTax__c,BLN_TotalIncludingTaxTrade__c,
                                        BLN_TotalTaxPayablebyTrade__c,BLN_TotalPayablebyTradeCompany__c,BLN_TotalIncludingTaxInsuranceCompany__c,
                                        BLN_TotalTaxPayablebyInsurance__c,BLN_PayableByInsuranceRepair__c,BLN_TotalIncludingTaxMotorist__c,BLN_TotalTaxPayablebyMotorist__c,
                                        BLN_TotalPrice__c,BLN_TotalPayableByMotorist__c, Status,BLN_ServiceTerritory__r.Name,BLN_Case__c,BLN_DiscountThresholdAmountA__c, 
                                        BLN_DiscountThresholdAmountB__c, BLN_DiscountThresholdAmountC__c,BLN_ServiceTerritory__r.BLN_Type__c, 
                                        BLN_PriceExpirationDate__c, BLN_TotalIncludingTax__c,BLN_ServiceTerritory__c
                                FROM Order 
                                WHERE Status = :System.label.BLN_Accepted AND BLN_Case__c =: caseId   ORDER BY createddate DESC LIMIT 1 ];
        
        if( !orderData.isEmpty() ){
            return orderData[0];
        }

        return null;
    }
        

    @AuraEnabled
    public static DisplayDetailsWrapper rebookServiceAppointments(String caseId, String currentPayload){
        Set<Id> serviceAppointmentId = new Set<Id>();
        List<BLN_ProductAvailabilityWrapper.productNames> productNameList = new List<BLN_ProductAvailabilityWrapper.productNames>();
        List<BLN_ProductAvailabilityWrapper.AppointmentWrapper> appWrapperList = new List<BLN_ProductAvailabilityWrapper.AppointmentWrapper>();
        List<ProductRequiredWrapper> productRequiredWrapperList= new List<ProductRequiredWrapper>();
        map<String,String> locationNameFromGuidMap = new map<String,String>();
        
        Order orderData = getAcceptedOrder(caseId);
        Set<String> partNumbersSet = new Set<String>();
        if( orderData != NULL ){
            Case cs = [Select Id,BLN_CPQQuoteIdCollection__c from case where Id =: caseId   LIMIT 1];
            String payload = String.isBlank(currentPayload) ? getQuoteApi(cs.BLN_CPQQuoteIdCollection__c,caseId) : currentPayload;

            String locationId = orderData.BLN_ServiceTerritory__r.BLN_GUID__c;
            String externalQuoteId = orderData.BLN_CPQExternalQuoteId__c;
            String caseExternalIds = cs.BLN_CPQQuoteIdCollection__c;
            
            //location data start
            BLN_ProductResponseWrapper.ResponseProduct data = (BLN_ProductResponseWrapper.ResponseProduct) System.JSON.deserialize(payload,BLN_ProductResponseWrapper.ResponseProduct.class);
            
            Set<String> locationIds = new Set<String>();
            BLN_PortalProductAvailabilityRebook.LocationWrapper selectedLocationWrap = new BLN_PortalProductAvailabilityRebook.LocationWrapper(); 
            List<BLN_ProductAvailabilityWrapper.DisplayQuoteDetailsWrapper> quoteDetailsList = new List<BLN_ProductAvailabilityWrapper.DisplayQuoteDetailsWrapper>();
            for(BLN_ProductResponseWrapper.ResponseQuotes quoteVar : data.quotes){
                locationIds.add(quoteVar.locationId);
            }
            
            for(ServiceTerritory st : [Select Id, Name,BLN_GUID__c,BLN_Type__c From ServiceTerritory where BLN_GUID__c =: locationIds  ]){
                locationNameFromGuidMap.put(st.BLN_GUID__c,st.Name);
            }

            for(BLN_ProductResponseWrapper.ResponseQuotes quoteVar : data.quotes){
                BLN_ProductAvailabilityWrapper.DisplayQuoteDetailsWrapper displayDetailsData = new BLN_ProductAvailabilityWrapper.DisplayQuoteDetailsWrapper();
                displayDetailsData.quoteId = quoteVar.quoteId;
                if(locationNameFromGuidMap.containsKey(quoteVar.locationId)){
                    displayDetailsData.quotelocation = locationNameFromGuidMap.get(quoteVar.locationId);
                }
                displayDetailsData.quoteTotal = quoteVar.quoteTotals.totalPrice;
                displayDetailsData.locationGUID = quoteVar.locationId;
                displayDetailsData.quoteVAT = quoteVar.quoteTotals.totaltax;
                displayDetailsData.quoteNetTotal = quoteVar.quoteTotals.totalIncludingTax;
                quoteDetailsList.add(displayDetailsData);
                
                if(orderData.BLN_ServiceTerritory__r.BLN_GUID__c == quoteVar.locationId){
                    LocationWrapper locations = new LocationWrapper();
                    locations.locationGUID = quoteVar.locationId;
                    locations.quoteId = quoteVar.quoteId;
                    locations.quotelocation = locationNameFromGuidMap.get(quoteVar.locationId);
                    locations.isMobileLocation = (orderData.BLN_ServiceTerritory__r.BLN_Type__c == System.label.BLN_Mobile? true:false);
                    locations.quoteTotal = quoteVar.quoteTotals.totalPrice;
                    locations.quoteVAT = quoteVar.quoteTotals.totaltax;
                    locations.quoteNetTotal = quoteVar.quoteTotals.totalIncludingTax;
                    selectedLocationWrap = locations;
                }
            }
            //location data end
            
            List<BLN_ProductAvailabilityWrapper.EarliestAvailabilityDetailsWrapper> earliestAvailabilityDateList = getEarliestDateList(payload, caseId);
            List<BLN_ProductAvailabilityWrapper.InsuranceLiabilityWrapper> liabilityList = getLiabilityList(payload,orderData.BLN_CPQExternalQuoteId__c);
            
            Map<Id,List<OrderItem>> serviceAppointmentOrderItemsMap = new Map<Id,List<OrderItem>>();
            List<OrderItem> orderItemList = new List<OrderItem>();
            List<OrderItemDetails> allItemsDetails = new List<OrderItemDetails>();
            List<OrderItem> allOrderItemList = [SELECT  Id,Product2.BLN_MDMID__c, Product2.Name,Product2.BLN_ProductCategory__c,Product2.ProductCode, 
                                                        OrderId, BLN_StockStatus__c,Quantity, UnitPrice, TotalPrice, EndDate,BLN_BundleName__c,BLN_BOMID__c,
                                                        BLN_IsProductSelected__c,BLN_TotalTax__c,BLN_NetPriceAfterPromotion__c,BLN_NetPriceIncludingTax__c,BLN_Optional__c,
                                                        BLN_ServiceAppointment__c,BLN_FittingLocation__r.Name,BLN_FittingLocation__r.BLN_GUID__c,BLN_DocumentNumber__c,
                                                        BLN_LeadingPartIndicator__c,BLN_ParentDocumentNumber__c
                                                FROM OrderItem where orderId =:orderData.Id  ];
            for(OrderItem oi : allOrderItemList){
                if( oi.BLN_IsProductSelected__c && ((oi.BLN_LeadingPartIndicator__c != null && oi.BLN_LeadingPartIndicator__c == false && String.isNotBlank(oi.BLN_BOMID__c)) || (String.isNotBlank(oi.BLN_BundleName__c) &&( oi.BLN_ParentDocumentNumber__c != null && oi.BLN_DocumentNumber__c != null && oi.BLN_ParentDocumentNumber__c != oi.BLN_DocumentNumber__c)))){
                    continue;
                }
                else if(oi.BLN_IsProductSelected__c){
                    orderItemList.add(oi);
                }
            }

            for(OrderItem oi : allOrderItemList){
                OrderItemDetails ord = new OrderItemDetails();
                ord.orderItemId = oi.Id;
                ord.partCode = oi.Product2.ProductCode;
                ord.ordItemRec = oi;

                allItemsDetails.add(ord);
            }

            /*Map<Id,List<OrderItem>> serviceAppointmentOrderItemsMap = new Map<Id,List<OrderItem>>();
            allOrderItemList = [SELECT  Id,Product2.BLN_MDMID__c, Product2.Name,Product2.BLN_ProductCategory__c,Product2.ProductCode, OrderId, Quantity, UnitPrice, TotalPrice, EndDate,BLN_BundleName__c,BLN_BOMID__c,
                                        BLN_IsProductSelected__c,BLN_TotalTax__c,BLN_NetPriceAfterPromotion__c,BLN_NetPriceIncludingTax__c,BLN_Optional__c,BLN_ServiceAppointment__c,BLN_FittingLocation__r.Name,BLN_FittingLocation__r.BLN_GUID__c,BLN_DocumentNumber__c,BLN_LeadingPartIndicator__c,BLN_ParentDocumentNumber__c  
                                FROM OrderItem 
                                where orderId =:orderData.Id  ];
            for(OrderItem ordItem: allOrderItemList){
                OrderItemDetails ord = new OrderItemDetails();
                ord.orderItemId = ordItem.Id;
                ord.partCode = ordItem.Product2.ProductCode;
                ord.ordItemRec = ordItem;
                allItemsDetails.add(ord);
            }
            allSelectedOrderItemList = [SELECT  Id,Product2.BLN_MDMID__c, Product2.Name,Product2.BLN_ProductCategory__c,Product2.ProductCode, 
                                                OrderId, BLN_StockStatus__c,Quantity, UnitPrice, TotalPrice, EndDate,BLN_BundleName__c,BLN_BOMID__c,
                                                BLN_IsProductSelected__c,BLN_TotalTax__c,BLN_NetPriceAfterPromotion__c,BLN_NetPriceIncludingTax__c,BLN_Optional__c,
                                                BLN_ServiceAppointment__c,BLN_FittingLocation__r.Name,BLN_FittingLocation__r.BLN_GUID__c,BLN_DocumentNumber__c,
                                                BLN_LeadingPartIndicator__c,BLN_ParentDocumentNumber__c
                                        FROM OrderItem where orderId =:orderData.Id AND BLN_IsProductSelected__c = true  ];

            for(OrderItem oi : allSelectedOrderItemList){
                if((oi.BLN_LeadingPartIndicator__c == false && String.isNotBlank(oi.BLN_BOMID__c)) || (String.isNotBlank(oi.BLN_BundleName__c) && oi.BLN_ParentDocumentNumber__c != oi.BLN_DocumentNumber__c)){
                    continue;
                }
                else{
                    orderItemList.add(oi);
                }
            }*/
            
            for(orderItem orderItems:orderItemList){
                BLN_ProductAvailabilityWrapper.ProductNames prod = new BLN_ProductAvailabilityWrapper.ProductNames();
                prod.productName = orderItems.Product2.Name;
                prod.productCode = orderItems.Product2.BLN_MDMID__c;
                prod.prodCategory = orderItems.Product2.BLN_ProductCategory__c;
                prod.bomId = orderItems.BLN_BOMID__c;
                prod.bundleName = orderItems.BLN_BundleName__c;
                prod.leadingProductIndicator = orderItems.BLN_LeadingPartIndicator__c;
                productNameList.add(prod);

            if(serviceAppointmentOrderItemsMap.containsKey(orderItems.BLN_ServiceAppointment__c)){
                serviceAppointmentOrderItemsMap.get(orderItems.BLN_ServiceAppointment__c).add(orderItems);
            }else{
                serviceAppointmentOrderItemsMap.put(orderItems.BLN_ServiceAppointment__c,new List<OrderItem>{orderItems});
            }       
                if(orderItems.Product2 != null && orderItems.Product2.BLN_MDMID__c != null){
                    partNumbersSet.add(orderItems.Product2.BLN_MDMID__c);}
            }

            map<String,List<BLN_ProductAvailabilityWrapper.Appointments>> appointmentsMap = new map<String,List<BLN_ProductAvailabilityWrapper.Appointments>>();
            map<String,List<BLN_ProductAvailabilityWrapper.productNames>> productNamesWithLocationMap = new map<String,List<BLN_ProductAvailabilityWrapper.productNames>>();
        map<String,String> locationGuIDMap = new map<String,String>();
        Integer i = 1;
        Integer keyIndex = 0;
        Set<Id> workorderlineItemIds= new Set<Id>();

            List<ServiceAppointment> serviceAppts  = [Select Id,ServiceTerritoryId,ParentRecordId,ServiceTerritory.Name,ServiceTerritory.BLN_GUID__c,
                                                        ServiceTerritory.BLN_Type__c,ArrivalWindowStartTime,ArrivalWindowEndTime,SchedStartTime,Status 
                                                        from ServiceAppointment 
                                                        where Id IN : serviceAppointmentOrderItemsMap.keySet()  ];
                
            for(ServiceAppointment serviceAppt : serviceAppts){
                String locationGUID;
                String locationName;
                list<BLN_ProductAvailabilityWrapper.products> prodList = new list<BLN_ProductAvailabilityWrapper.products>(); 
            workorderlineItemIds.add(serviceAppt.ParentRecordId);
            for(orderItem orderItem : orderItemList){
                if(serviceAppt.Id == orderItem.BLN_ServiceAppointment__c){
                    locationGUID = orderItem.BLN_FittingLocation__r.BLN_GUID__c;
                    locationName = orderItem.BLN_FittingLocation__r.Name; 
                }
                    BLN_ProductAvailabilityWrapper.Products prod1 = new BLN_ProductAvailabilityWrapper.Products(); 
                prod1.quantity = integer.valueOf(orderItem.quantity);
                prod1.productCode = orderItem.Product2.BLN_MDMID__c;
                prod1.isChecked = false;
                prod1.prodCategory = orderItem.Product2.BLN_ProductCategory__c;
                    prod1.stockStatus = orderItem.BLN_StockStatus__c;
                if(serviceAppt.Id == orderItem.BLN_ServiceAppointment__c && orderItem.BLN_IsProductSelected__c){
                    prod1.productEnable = true;
                }else{
                    prod1.productEnable = false;
                }
                prod1.bomId = orderItem.BLN_BOMId__c;
                prod1.lineItemId = Integer.valueOf(orderItem.BLN_DocumentNumber__c);
                prod1.orderItemId = orderItem.Id;
                prodList.add(prod1);
                    BLN_ProductAvailabilityWrapper.ProductNames prod = new BLN_ProductAvailabilityWrapper.ProductNames();  
                    prod.productName = orderItem.Product2.Name;
                    prod.productCode = orderItem.Product2.BLN_MDMID__c;
                    prod.prodCategory = orderItem.Product2.BLN_ProductCategory__c;
                    if(productNamesWithLocationMap.containsKey(locationGUID)){
                        productNamesWithLocationMap.get(locationGUID).add(prod);
                    }else{
                        productNamesWithLocationMap.put(locationGUID,new List<BLN_ProductAvailabilityWrapper.ProductNames>{prod});
                    }
                }
                locationGuIDMap.put(locationGUID,locationName);
                /*if(!locationGuIDMap.containsKey(locationGUID)){  
            LocationWrapper locations = new LocationWrapper();
            locations.locationGUID = locationGUID;
            locations.quoteId = orderData.BLN_CPQExternalQuoteId__c;
            locations.quotelocation = locationName;

            if(serviceAppt.ServiceTerritory.BLN_Type__c == System.label.BLN_Mobile){
                locations.isMobileLocation = true;
            }else{
                locations.isMobileLocation = false;
            }         

                    locationGuIDMap.put(locationGUID,locationName);
                }*/

            String formattedStartDate = serviceAppt.ArrivalWindowStartTime.format('MMMM d, yyyy');
            String arrivalWindowStartTime =  String.valueOfGMT(serviceAppt.ArrivalWindowStartTime);
            String arrivalWindowEndTime =  String.valueOfGMT(serviceAppt.ArrivalWindowEndTime);
          
             String[] partsA = arrivalWindowStartTime.split(' ');
             String formattedhhmm = partsA[1].substring(0, 5);
            
             String[] partsB = arrivalWindowEndTime.split(' ');
             String formattedEndDate = partsB[1].substring(0, 5);
            String result = formattedStartDate + ' '+ formattedhhmm + '-' + formattedEndDate;

                list<BLN_ProductAvailabilityWrapper.ProductAvailibilities> productAvailibilitiesList = new list<BLN_ProductAvailabilityWrapper.ProductAvailibilities>();
                BLN_ProductAvailabilityWrapper.ProductAvailibilities productAvailibilities = new BLN_ProductAvailabilityWrapper.productAvailibilities();
                ProductAvailibilities.products = prodList;
                productAvailibilitiesList.add(productAvailibilities);
            
                BLN_ProductAvailabilityWrapper.Appointments appData = new BLN_ProductAvailabilityWrapper.Appointments(); 
            appData.appointmentName = 'Appointment'+ ' '+  String.valueOf(i);
            appData.keyIndex = String.valueOf(keyIndex);
            appData.locationId = serviceAppt.ServiceTerritory.BLN_GUID__c;
            appData.locationName =  serviceAppt.ServiceTerritory.Name;
            appData.isFirstAppointment = true;
                appData.earlierAvailabilityDateHeader = null;
                appData.slotSelectedDate = result;
            appData.serviceAppointmentId = serviceAppt.Id;
            appData.slotDate = null;
            appData.slotTime = null;
            appData.isDropOff = 'false';
                appData.slotDateTimeStart = String.valueOf(serviceAppt.ArrivalWindowStartTime);
                appData.slotDateTimeFinish = String.valueOf(serviceAppt.ArrivalWindowEndTime);
                appData.schedStartTime = serviceAppt.SchedStartTime;
                appData.productAvailibilities = productAvailibilitiesList;
                appData.status = serviceAppt.Status;
                appData.woliId = serviceAppt.ParentRecordId;
                
            if(serviceAppt.ServiceTerritory.BLN_Type__c == System.label.BLN_Mobile){
                appData.isMobileLocation = true;
            }else{
                appData.isMobileLocation = false;
            }          
            if(appointmentsMap.containsKey(locationGUID)){
                appointmentsMap.get(locationGUID).add(appData);
            }else{
                    appointmentsMap.put(locationGUID,new List<BLN_ProductAvailabilityWrapper.Appointments>{appData});
            }
            keyIndex++;
            i++;
        }

            /* This method is used to call for identify product type*/
            List<BLN_ProductAvailabilityWrapper.ProductIdentifierWrapper> productIdentifier = new List<BLN_ProductAvailabilityWrapper.ProductIdentifierWrapper>();
            productIdentifier = BLN_ProductIdentifierUtility.getProductIndentify(System.label.BLN_PRIME);

            List<ProductRequired> prodRequiredList=[Select Id,ParentRecordId,BLN_IsConsumed__c,Product2Id, BLN_ProductCode__c, BLN_OLIKey__c
                                                    from ProductRequired
                                                    where ParentRecordId IN : workorderlineItemIds   ];

            for(ProductRequired prod2List: prodRequiredList){
                ProductRequiredWrapper prodWrapp= new ProductRequiredWrapper ();
                prodWrapp.productCode=prod2List.BLN_ProductCode__c;
                prodWrapp.isConsumed=prod2List.BLN_IsConsumed__c;
                prodWrapp.productOLIKey = prod2List.BLN_OLIKey__c;
                prodWrapp.woliId = prod2List.ParentRecordId;
                productRequiredWrapperList.add(prodWrapp);
            }
            for(String locationGuId : appointmentsMap.keySet()){
                BLN_ProductAvailabilityWrapper.earliestAvailablity earliestAvailablity = new BLN_ProductAvailabilityWrapper.earliestAvailablity();
                earliestAvailablity.serviceName = locationGuIDMap.get(locationGuId);
                earliestAvailablity.earliestAvailability = System.label.BLN_EarliestAvailability;
                earliestAvailablity.productDate = new list<BLN_ProductAvailabilityWrapper.ProductDate>();
            
                BLN_ProductAvailabilityWrapper.ServiceLocationLabel serviceLocationLabel = new BLN_ProductAvailabilityWrapper.ServiceLocationLabel();
                ServiceLocationLabel.serviceLabel = System.label.BLN_ServiceLocationCap;
                ServiceLocationLabel.Product = System.label.BLN_Products;
                serviceLocationLabel.productNames = productNameList;

                BLN_ProductAvailabilityWrapper.AppointmentWrapper appWrapper = new BLN_ProductAvailabilityWrapper.AppointmentWrapper();        
                appWrapper.serviceLocationName = System.label.BLN_ServiceLocation +' '+ locationGuIDMap.get(locationGuId);
                appWrapper.externalQuoteId = orderData.BLN_CPQExternalQuoteId__c;
                appWrapper.caseExternalQuoteIds = caseExternalIds;
            appWrapper.serviceLocationId = locationGUID;
            if(orderData.BLN_ServiceTerritory__r.BLN_GUID__c == locationGuId){
                appWrapper.isPrimaryLocation = true;
            }else {
                appWrapper.isPrimaryLocation = false;
            }
                appWrapper.serviceLocationLabel = new List<BLN_ProductAvailabilityWrapper.ServiceLocationLabel>{serviceLocationLabel};
                appWrapper.earliestAvailablity = new List<BLN_ProductAvailabilityWrapper.earliestAvailablity>{earliestAvailablity};
                appWrapper.appointments = appointmentsMap.get(locationGuId);
                appWrapperList.add(appWrapper);
            }

            DisplayDetailsWrapper returnData = new DisplayDetailsWrapper();
            returnData.appointmentWrapperList = JSON.serialize(appWrapperList);
            returnData.earliestAvailabilityList = earliestAvailabilityDateList;
            returnData.selectedLocation = selectedLocationWrap;
        returnData.getQuotePayload = payload;
        returnData.existingGUId = locationId;
        returnData.productrequiredWrappList=productRequiredWrapperList;
        returnData.liabilityDataList = liabilityList;
        returnData.externalQuoteId = externalQuoteId;
        returnData.prodLists = getAllSelectedProductLists(orderData.BLN_CPQExternalQuoteId__c);
            returnData.quoteDetailsDataList = quoteDetailsList;
            returnData.orderItemDetails = allItemsDetails;
            returnData.productIdentifier = ProductIdentifier;
            return returnData;
        }else{
            throw new AuraHandledException(System.Label.BLN_NoActiveOrderOnCaseError);
        }
    }

    @AuraEnabled
    public static List<BLN_ProductAvailabilityWrapper.EarliestAvailabilityDetailsWrapper> getEarliestDateList(String responsePayload, String caseId){
        BLN_ProductResponseWrapper.ResponseProduct data = (BLN_ProductResponseWrapper.ResponseProduct) System.JSON.deserialize(responsePayload,BLN_ProductResponseWrapper.ResponseProduct.class);
        List<BLN_ProductAvailabilityWrapper.EarliestAvailabilityDetailsWrapper> earliestDatesList = new List<BLN_ProductAvailabilityWrapper.EarliestAvailabilityDetailsWrapper>();
        Set<String> partNumberSet = new Set<String>(); 
        System.debug('--data.quotes----'+data.quotes);
        for(BLN_ProductResponseWrapper.ResponseQuotes quoteVar : data.quotes){
            for(BLN_ProductResponseWrapper.ResponseLineItems lineItem : quoteVar.lineItems){
                if(lineItem != null && lineItem.partNumber != null && lineItem.partNumber != ''){
                    partNumberSet.add(lineItem.partNumber);
                }
            }
        }
        Map<String,Product2> mdmIdVsProductsMap = new Map<String,Product2>();
        for(Product2 prod : [SELECT Id, Name, BLN_MDMID__c, BLN_BusinessUnitSpecificBranchOnly__c, BLN_ProductCategory__c, BLN_ProductStockable__c,BLN_BondedNonBonded__c FROM Product2 WHERE isActive = true AND  BLN_MDMID__c IN :partNumberSet  ]){
            mdmIdVsProductsMap.put(prod.BLN_MDMID__c,prod);
        }
        //Integer bufferDaysToAdd = BLN_ProductAvailabilityUtility.bufferCalculation(caseId);
        for(BLN_ProductResponseWrapper.ResponseQuotes quoteVar : data.quotes){
            for(BLN_ProductResponseWrapper.ResponseLineItems lineItem : quoteVar.lineItems){
                BLN_ProductAvailabilityWrapper.EarliestAvailabilityDetailsWrapper earliestAvailabilityVar = new BLN_ProductAvailabilityWrapper.EarliestAvailabilityDetailsWrapper();
                earliestAvailabilityVar.quoteId = quoteVar.quoteId;
                earliestAvailabilityVar.locationId = quoteVar.locationId;
                earliestAvailabilityVar.productCode = lineItem.partNumber != null ? lineItem.partNumber : '';
                earliestAvailabilityVar.bundleName = lineItem.bundleName != null ? lineItem.bundleName : '';
                earliestAvailabilityVar.bomId = lineItem.parentBOMId != null ? lineItem.parentBOMId : '';
                earliestAvailabilityVar.leadingProductIndicator = lineItem.leadingProductIndicator;
                earliestAvailabilityVar.lineItemId = lineItem.lineItemId;
                 
                earliestAvailabilityVar.earliestDateList = new List<BLN_ProductResponseWrapper.ResponseAvailabilityDetails>();
                
                if( lineItem.availabilityDetails != null && !lineItem.availabilityDetails.isEmpty() ){
                    for(BLN_ProductResponseWrapper.ResponseAvailabilityDetails availDetail : lineItem.availabilityDetails){
                        //Added By Shailendra:
                        availDetail.isOutOfStock = lineItem.partNumber != null && mdmIdVsProductsMap.containsKey(lineItem.partNumber) && mdmIdVsProductsMap.get(lineItem.partNumber) != null && mdmIdVsProductsMap.get(lineItem.partNumber).BLN_ProductStockable__c && String.isBlank(availDetail.availableFromDate)  ? true : false;
                        availDetail.availableFromDate = availDetail.availableFromDate == null || availDetail.availableFromDate == ''? String.valueOf(System.now().date()) : availDetail.availableFromDate;
                        availDetail.availableFromDate =  availDetail.isOutOfStock ? System.now().addDays(Integer.valueOf(System.label.BLN_NoStockBufferPeriod)).format('YYYY-MM-dd\'T\'HH:mm:ssXXX') : availDetail.availableFromDate == String.valueOf(System.now().date()) ? String.valueOf(DateTime.newInstance(System.now().date(),System.now().time()).format('YYYY-MM-dd\'T\'HH:mm:ssXXX'))  : String.valueOf(DateTime.newInstance(Date.valueOf(availDetail.availableFromDate),System.now().time()).format('YYYY-MM-dd\'T\'HH:mm:ssXXX'));
                        earliestAvailabilityVar.earliestDateList.add(availDetail);
                    } 
                }else if( String.isNotBlank(lineItem.bundleName) && lineItem.lineItemId == lineItem.parentLineItemId ){
                    //calculate date for bundle products based on child products..
                    Map<String,BLN_ProductResponseWrapper.ResponseAvailabilityDetails> locIDCategoryMap = new Map<String,BLN_ProductResponseWrapper.ResponseAvailabilityDetails>();
                    for(BLN_ProductResponseWrapper.ResponseLineItems lineItemChild : quoteVar.lineItems){
                        if( String.isNotBlank(lineItemChild.bundleName) && lineItemChild.lineItemId != lineItemChild.parentLineItemId &&  lineItemChild.availabilityDetails != null && !lineItemChild.availabilityDetails.isEmpty() && lineItem.bundleName == lineItemChild.bundleName ){
                            
                            for(BLN_ProductResponseWrapper.ResponseAvailabilityDetails availDetail : lineItemChild.availabilityDetails){
                                availDetail.isOutOfStock = mdmIdVsProductsMap.containsKey(lineItemChild.partNumber) && mdmIdVsProductsMap.get(lineItemChild.partNumber).BLN_ProductStockable__c != null && mdmIdVsProductsMap.get(lineItemChild.partNumber).BLN_ProductStockable__c && String.isBlank(availDetail.availableFromDate) ? true : false;
                                availDetail.availableFromDate = availDetail.availableFromDate == null || availDetail.availableFromDate == '' ? String.valueOf(System.now().date()) : availDetail.availableFromDate;
                                availDetail.availableFromDate =  availDetail.isOutOfStock ? System.now().addDays(Integer.valueOf(System.label.BLN_NoStockBufferPeriod)).format('YYYY-MM-dd\'T\'HH:mm:ssXXX') : availDetail.availableFromDate == String.valueOf(System.now().date()) ? String.valueOf(DateTime.newInstance(System.now().date(),System.now().time()).format('YYYY-MM-dd\'T\'HH:mm:ssXXX'))  : String.valueOf(DateTime.newInstance(Date.valueOf(availDetail.availableFromDate),System.now().time()).format('YYYY-MM-dd\'T\'HH:mm:ssXXX'));
                                while( !locIDCategoryMap.containsKey(availDetail.stockLocationId) || (String.isNotBlank(availDetail.availableFromDate) && String.isNotBlank(locIDCategoryMap.get(availDetail.stockLocationId).availableFromDate) && Date.valueOf(availDetail.availableFromDate) > Date.valueOf(locIDCategoryMap.get(availDetail.stockLocationId).availableFromDate)) ){                                   
                                    locIDCategoryMap.put(availDetail.stockLocationId, availDetail);
                                    break;
                                } 
                            }
                            
                        }
                    }

                    for( String locationId : locIDCategoryMap.keySet()){
                        earliestAvailabilityVar.earliestDateList.add(locIDCategoryMap.get(locationId));
                    }
                }
                /*else{
                    BLN_ProductResponseWrapper.ResponseAvailabilityDetails earliestDateData = new BLN_ProductResponseWrapper.ResponseAvailabilityDetails();
                    if(lineItem.partNumber != '' && lineItem.partNumber != null && mdmIdVsProductsMap.containsKey(lineItem.partNumber)){
                        earliestDateData.stockLocationId = mdmIdVsProductsMap.get(lineItem.partNumber).BLN_ProductStockable__c ? System.label.BLN_StockableItem : quoteVar.locationId;
                        earliestDateData.availableFromDate = mdmIdVsProductsMap.get(lineItem.partNumber).BLN_ProductStockable__c ? String.valueOf(DateTime.newInstance(System.now().date().addDays(Integer.valueOf(System.label.BLN_NoStockBufferPeriod)),System.now().time()).format('YYYY-MM-dd\'T\'HH:mm:ssXXX')) : String.valueOf(System.now().format('YYYY-MM-dd\'T\'HH:mm:ssXXX'));
                    }
                    else{
                        earliestDateData.stockLocationId = System.label.BLN_StockableItem;
                        earliestDateData.availableFromDate = String.valueOf(DateTime.newInstance(System.now().date().addDays(Integer.valueOf(System.label.BLN_NoStockBufferPeriod)),System.now().time()).format('YYYY-MM-dd\'T\'HH:mm:ssXXX'));
                    }
                    earliestAvailabilityVar.earliestDateList.add(earliestDateData);
                }*/
                earliestDatesList.add(earliestAvailabilityVar);
            }       
        }
        return earliestDatesList;
    }



    //Get selectedProductList & get addOnProdList
    public static List<List<BLN_ProductAvailabilityWrapper.ProductSelectionWrapper>> getAllSelectedProductLists(String orderId){
        Order ord = [SELECT Id,BLN_CPQExternalQuoteId__c,
                            (SELECT Id,BLN_DocumentNumber__c,BLN_ParentDocumentNumber__c,BLN_BOMID__c,BLN_BundleName__c,
                                    BLN_LeadingPartIndicator__c,Product2.BLN_ProductCategory__c,Quantity,BLN_NetPriceAfterPromotion__c,BLN_NetPriceIncludingTax__c,
                                    BLN_TaxRate__c,Product2.BLN_MDMID__c,Product2.Name 
                            FROM OrderItems 
                            WHERE BLN_IsProductSelected__c = true) 
                    FROM Order 
                    WHERE BLN_CPQExternalQuoteId__c = :orderId   LIMIT 1];

        List<BLN_ProductAvailabilityWrapper.ProductSelectionWrapper> selectedProdsList = new List<BLN_ProductAvailabilityWrapper.ProductSelectionWrapper>();
        List<BLN_ProductAvailabilityWrapper.ProductSelectionWrapper> addOnProdsList = new List<BLN_ProductAvailabilityWrapper.ProductSelectionWrapper>();
        for(OrderItem oi : ord.OrderItems){
            BLN_ProductAvailabilityWrapper.ProductSelectionWrapper prod  = new BLN_ProductAvailabilityWrapper.ProductSelectionWrapper();
            prod.selectProduct = true;
            prod.lineItemId = Integer.valueOf(oi.BLN_DocumentNumber__c);
            prod.parentLineItemId = Integer.valueOf(oi.BLN_ParentDocumentNumber__c);
            prod.bomId = oi.BLN_BOMID__c != null ? oi.BLN_BOMID__c : '';
            prod.bundleName = oi.BLN_BundleName__c != null ? oi.BLN_BundleName__c : '';
            prod.leadingProductIndicator = oi.BLN_LeadingPartIndicator__c;
            prod.prodCategory = oi.Product2.BLN_ProductCategory__c != null ? oi.Product2.BLN_ProductCategory__c : '';
            prod.quantity = oi.Quantity;
            prod.netPrice = oi.BLN_NetPriceAfterPromotion__c;
            prod.netPriceIncludingTax = oi.BLN_NetPriceIncludingTax__c;
            prod.totalTax = oi.BLN_TaxRate__c;
            prod.productCode = oi.Product2.BLN_MDMID__c;
            prod.productName = oi.Product2.Name;
            prod.hierarchy = '';
            prod.partOfBundle = false;
            prod.orderItemId = oi.id;

            if(String.isNotBlank(oi.BLN_BOMID__c)){
                if(oi.BLN_LeadingPartIndicator__c == true){
                    prod.hierarchy = 'parent';
                    selectedProdsList.add(prod);    
                }
                else{
                    prod.hierarchy = 'child';
                    addOnProdsList.add(prod);
                }
            }
            else if(String.isNotBlank(oi.BLN_BundleName__c)){
                prod.partOfBundle = true;
                if(oi.BLN_ParentDocumentNumber__c == oi.BLN_DocumentNumber__c){
                    prod.hierarchy = 'parent';
                    selectedProdsList.add(prod);
                }
                else{
                    prod.hierarchy = 'child';
                    addOnProdsList.add(prod);
                }
            }
            else{
                selectedProdsList.add(prod);
            }
        }
        return new List<List<BLN_ProductAvailabilityWrapper.ProductSelectionWrapper>>{selectedProdsList,addOnProdsList};
    }
    public class ProductSelectionWrapper {
        @auraEnabled
        public String productCode ;
        @auraEnabled
        public Double quantity;
        @auraEnabled
        public String productName;
        @AuraEnabled
        public String prodCategory;
        @AuraEnabled
        public Integer lineItemId;
        @auraEnabled
        public Double netPriceIncludingTax;
        @AuraEnabled
        public Double totalTax;
        @AuraEnabled
        public Double netPrice;
        @auraEnabled
        public String bundleName;
        @AuraEnabled
        public String selectProduct;
        @AuraEnabled
        public String bomMandatory;
        //@AuraEnabled
        //public Boolean isCheckboxDisabled;
        @AuraEnabled
        public Boolean isProductSelected;
        @AuraEnabled
        public String hierarchy;
        @AuraEnabled
        public String bomId;
        @AuraEnabled
        public Boolean leadingProductIndicator;
        @AuraEnabled
        public Boolean isBranchOnlyProduct;
        @AuraEnabled
        public Boolean isBondedNonBonded;
        public ProductSelectionWrapper(){
            this.hierarchy = '';
            this.bomId = '';
        }
    }
    public class EarliestAvailibilityDetailsWrapper{
        @AuraEnabled
        public List<BLN_ProductResponseWrapper.ResponseAvailabilityDetails> earliestDateList;
        @AuraEnabled
        public String quoteId;
        @AuraEnabled
        public String productCode;
        @AuraEnabled
        public String bundleName;
        
        public EarliestAvailibilityDetailsWrapper(){
            this.earliestDateList = new List<BLN_ProductResponseWrapper.ResponseAvailabilityDetails>();
            this.quoteId = '';
            this.productCode = '';
            this.bundleName = '';
        }
    }
    public class ProductRequiredWrapper {
        @auraEnabled
        public String productCode ;
        @auraEnabled
        public String productOLIKey;
        @auraEnabled
        public String woliId;
        @auraEnabled
        public Boolean isConsumed ;
    }
    public class DisplayDetailsWrapper {
        @auraEnabled
        public String externalQuoteId;
        @auraEnabled
        public String existingGUId;
        @auraEnabled
        public List<ProductRequiredWrapper> productrequiredWrappList;
        @auraEnabled
        public List<ProductSelectionWrapper> productDataList;
        @auraEnabled
        public String appointmentWrapperList;
        @auraEnabled
        public LocationWrapper selectedLocation;
        @auraEnabled
        public String getQuotePayload;
        @AuraEnabled
        public List<BLN_ProductAvailabilityWrapper.InsuranceLiabilityWrapper> liabilityDataList;  
        @AuraEnabled
        public List<BLN_ProductAvailabilityWrapper.EarliestAvailabilityDetailsWrapper> earliestAvailabilityList;
        @AuraEnabled
        public List<List<BLN_ProductAvailabilityWrapper.ProductSelectionWrapper>> prodLists;
        @AuraEnabled
        Public List<BLN_ProductAvailabilityWrapper.DisplayQuoteDetailsWrapper> quoteDetailsDataList;
        @auraEnabled
        public List<OrderItemDetails> orderItemDetails;
        @auraEnabled
        public List<BLN_ProductAvailabilityWrapper.ProductIdentifierWrapper> productIdentifier;
    }
    public class LocationWrapper{
        @auraEnabled public boolean isMobileLocation;
        @auraEnabled public String locationGUID;	
        @auraEnabled public String quoteEarliestAppointmentAvailability;	
        @auraEnabled public String quoteId;	
        @auraEnabled public String quotelocation;
        @auraEnabled public Decimal quoteVAT;
        @auraEnabled public Decimal quoteTotal;
        @auraEnabled public Decimal quoteNetTotal;
        @auraEnabled public String quoteWeatherGuard;
        @auraEnabled public Boolean isCPT;
        @auraEnabled public Boolean locDisabled;
    }
    public class SlotDateTimeToOrderItem{
        // public String orderItemId;
        public Integer lineItemId;
        public String slotDate;
    }
    public class OrderItemDetails{
        @auraEnabled
        public String orderItemId;
        @auraEnabled
        public String partCode;
        @auraEnabled
        public OrderItem ordItemRec;
    }
}