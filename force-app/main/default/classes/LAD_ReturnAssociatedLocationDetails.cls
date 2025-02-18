/** @description :  This apex class is used to return Associated Location Details Corrosponding to an account in Experience Cloud.
*   @Story :        FOUK-9051; FOUK-8454; FOUK-8231; FOUK-8232; FOUK-8230; FOUK-7684; FOUK-8367
*   @author:        (prajjawal.tiwari@pwc.com (IN)) (binayak.debnath@pwc.com (IN))
*   @CreatedDate:   22-05-2024
*/

public without sharing class LAD_ReturnAssociatedLocationDetails {
    /**@MethodName :    returnLocationDetails
    * @description :    This method is used to return AssociatedLocation records from the Parent Account record.
    * @param:           string AccountId
    * @return:          List<AssociatedLocation>
    */
    @auraenabled
    public static List<AssociatedLocation> returnLocationDetails(string AccountId){
        try {
            List<AssociatedLocation> associatedLocationList= [Select Id,Location.name,Location.BLN_GUID__c,LocationId,LAD_Location_Type__c, LAD_Available_for_Delivery__c  from AssociatedLocation where ParentRecordId =: AccountId];        
            system.debug(associatedLocationList);
            return associatedLocationList;
            
        } catch (Exception e) {
            // Handling the exceptions and log an error message
            BLN_ExceptionLogger.captureException(e);
            system.debug(e);
            return null;
        }
       
    } 
    
    
     public class createMDCPreferenceRecordInputWrapper{
        @AuraEnabled public  string locationId {get; set;}
        @AuraEnabled public  String[] productIdList {get; set;}
        @AuraEnabled public  string userId {get; set;}
        @AuraEnabled public  string deliveryDate {get; set;}
        @AuraEnabled public  string effectiveAccountId {get; set;}
    }
    
    /**@MethodName :    createMDCPreferenceRecord
    * @description :    This method is used to create or update MDC Preference records for selected Product and Location.
    * @param:           String locationId , String[] productIdList, String userId, String deliveryDate
    * @return:          void
    */
    @AuraEnabled
    public static void createMDCPreferenceRecord(createMDCPreferenceRecordInputWrapper createMDCPreferenceRecordInput ) {
        system.debug(42);
        system.debug(createMDCPreferenceRecordInput);
        string locationId=createMDCPreferenceRecordInput.locationId;
        String[] productIdList=createMDCPreferenceRecordInput.productIdList;
        string userId=createMDCPreferenceRecordInput.userId;
        string deliveryDate=createMDCPreferenceRecordInput.deliveryDate;
        string effectiveAccountId=createMDCPreferenceRecordInput.effectiveAccountId;

        
        
        try {
            String accId = effectiveAccountId!=null & effectiveAccountId!='' & effectiveAccountId!='undefined' ?effectiveAccountId:getAccId(userId);
            String primaryLocationId = [SELECT Id,LAD_Location_Type__c  FROM AssociatedLocation WHERE ParentRecordId = :accId AND LAD_Location_Type__c = 'Primary' LIMIT 1].Id;
            List<CartItem> cartItemToUpdate = new List<CartItem>();
            List<LAD_MDC_Preference__c> mdcToUpdate = new List<LAD_MDC_Preference__c>();
            Set<String> newMdcForProductIdSet = new Set<String>();
            List<LAD_MDC_Preference__c> mdcToInsert = new List<LAD_MDC_Preference__c>();

            List<LAD_MDC_Preference__c> existingRecords = [ SELECT  Id, 
                                                                    LAD_Delivery_Date__c, 
                                                                    LAD_Associated_Location__c, 
                                                                    LAD_CartItem__c,
                                                                    LAD_Product__c
                                                            FROM LAD_MDC_Preference__c 
                                                            WHERE LAD_Product__c IN :productIdList AND LAD_User__c = :userId AND LAD_Account__c = :accId ];
            System.debug('Existing Records: ' + existingRecords);

            Map<Id, Object> prodIdToMdcMap = new Map<Id, Object>();

            if (!existingRecords.isEmpty()) {
                Set<Id> cartItemIdList = new Set<Id>();
                Map<Id, Object> cartItemIdtoCartItemMap = new Map<Id, Object>();
                for(LAD_MDC_Preference__c mdc : existingRecords){
                    prodIdToMdcMap.put(mdc.LAD_Product__c, mdc);
                    if(mdc.LAD_CartItem__c != null){
                        cartItemIdList.add(mdc.LAD_CartItem__c);
                    }
                }

                for(CartItem item : [SELECT Cart.Status, LAD_Associated_Location__c  FROM CartItem WHERE Id IN :cartItemIdList]){
                    cartItemIdtoCartItemMap.put(item.Id, item);
                }

                for(Id productId : productIdList){
                    if(prodIdToMdcMap.keySet().contains(productId)){

                        LAD_MDC_Preference__c currentMDC = (LAD_MDC_Preference__c) prodIdToMdcMap.get(productId);
                        currentMDC.LAD_Delivery_Date__c = deliveryDate != null ? deliveryDate : '';                        
                        currentMDC.LAD_Associated_Location__c = locationId!=null ? locationId : primaryLocationId;
                        
                        
                        if(currentMDC.LAD_CartItem__c != null){
                            CartItem currentItem = (CartItem) cartItemIdtoCartItemMap.get(currentMDC.LAD_CartItem__c);
                            if((currentItem.Cart.Status) == System.Label.LAD_LocationCheckPDP_CartStatusPendingDelete || (currentItem.Cart.Status) ==System.Label.LAD_LocationCheckPDP_CartStatus_Closed ){
                                currentMDC.LAD_CartItem__c = null;
                            }
                            else{
                                currentItem.LAD_Associated_Location__c = locationId;
                                cartItemToUpdate.add(currentItem);
                            }               
                        }
                        mdcToUpdate.add(currentMDC);
                    }
                    else{
                        newMdcForProductIdSet.add(productId);
                    }
                }
            }
            else{
                Set<String> productIdSet = new Set<String>(productIdList);
                newMdcForProductIdSet.addAll(productIdSet);
                
            }

            if(!newMdcForProductIdSet.isEmpty()){
                for (Id productId : newMdcForProductIdSet) {
                    LAD_MDC_Preference__c mdcPreference = new LAD_MDC_Preference__c();
                    mdcPreference.LAD_Account__c = accId;
                    mdcPreference.LAD_Delivery_Date__c = deliveryDate != null ? deliveryDate : '';    
                    mdcPreference.LAD_Associated_Location__c = locationId!=null ? locationId : primaryLocationId;
                    mdcPreference.LAD_Product__c = productId;
                    mdcPreference.LAD_User__c = userId;

                    mdcToInsert.add(mdcPreference);
                    System.debug('Inserted Preference Record: ' + mdcPreference);
                }
            }

            if(!mdcToInsert.isEmpty()){
                insert mdcToInsert;
            }

            if(!cartItemToUpdate.isEmpty()){
                update cartItemToUpdate;
            }

            if(!mdcToUpdate.isEmpty()){
                update mdcToUpdate;
            }

            
                        
            /* if (!existingRecords.isEmpty()) {
                existingRecords[0].LAD_Delivery_Date__c = deliveryDate;
    
                if(locationId!=null){ 
                    existingRecords[0].LAD_Associated_Location__c = locationId;
                }
                
                if(existingRecords[0].LAD_CartItem__c != null){
                    CartItem item = [SELECT LAD_Associated_Location__c, Cart.Status FROM CartItem WHERE Id = :existingRecords[0].LAD_CartItem__c LIMIT 1];
                    if(item.cart.status == System.Label.LAD_LocationCheckPDP_CartStatusPendingDelete){
                        existingRecords[0].LAD_CartItem__c = null;
                    }
                    else{
                        item.LAD_Associated_Location__c = locationId;
                        update item;
                    }               
                }
                update existingRecords;
                System.debug('Updated Preference Record: ' + existingRecords[0]);
            } else {
                LAD_MDC_Preference__c mdcPreference = new LAD_MDC_Preference__c();
                mdcPreference.LAD_Account__c = accId;
                mdcPreference.LAD_Delivery_Date__c = deliveryDate;
    
                if(locationId!=null){ 
                    mdcPreference.LAD_Associated_Location__c = locationId;
                }
                if(productId != null){
                    mdcPreference.LAD_Product__c = productId;
                }
                if(userId!=null){
                    mdcPreference.LAD_User__c = userId;
                }
                insert mdcPreference;
                System.debug('Inserted Preference Record: ' + mdcPreference);
            } */
        } catch (Exception e) {
            // Handling the exceptions and log an error message
            BLN_ExceptionLogger.captureException(e);
        }
       
    }

    /**@MethodName :    getAccId
    * @description :    This method is used to fetch Account Id of the user's contact record.
    * @param:           string userid
    * @return:          Id
    */
    @auraenabled
    public static Id getAccId(string userid){
        try {
            system.debug('userid'+userid);
            Id accountId;
            List<user> accidfromuser = [select id, AccountId  from user where id =:userid  limit 1];
            if (!accidfromuser.isEmpty()) {
                accountId = accidfromuser[0].AccountId;
            }
            system.debug('accountId>>'+accountId);
            return accountId;
        } catch (Exception e) {
            // Handling the exceptions and log an error message
            BLN_ExceptionLogger.captureException(e);
            return null;
        }
       
    } 
    
    
    public class productDetailWrapper{
        @AuraEnabled public  string userId {get; set;}
        @AuraEnabled public  String[] productIdList {get; set;}
        @AuraEnabled public  string location {get; set;}
        @AuraEnabled public  Integer quantity {get; set;}
        @AuraEnabled public  string effectiveAccountId {get; set;}
    }
    
    
    /**@MethodName :    getProductAvailability
    * @description :    This method is used to fetch Location based Availability and Stock data for the product.
    * @param:           String userId, string accountId, String productId, String location, Integer quantity
    * @return:          HttpResponseWrapper
    */
    @AuraEnabled
    public static List<HttpResponseWrapper> getProductAvailability(productDetailWrapper productDetails ) {
        system.debug(productDetails);
        String userId=productDetails.userId;
        String[] productIdList=productDetails.productIdList;
        String location=productDetails.location;
        Integer quantity=productDetails.quantity;
        string effectiveAccountId=productDetails.effectiveAccountId;
        
        try {
            //Boolean isInternal = true;
       // system.debug('isInternal>>'+isInternal);
        String accountId = effectiveAccountId!=null & effectiveAccountId!='' & effectiveAccountId!='undefined' ?effectiveAccountId:getAccId(userId);
        List<AssociatedLocation> associatedLocations = returnLocationDetails(accountId);
        system.debug('associatedLocations>'+associatedLocations);
        List<HttpResponseWrapper> responseWrapperList = new List<HttpResponseWrapper>();

        for(String productId : productIdList){
            HttpResponseWrapper responseWrapper = new HttpResponseWrapper();
            responseWrapper.primarylocations = new List<LocationDetails>();
            responseWrapper.secondarylocations = new List<LocationDetails>();
            responseWrapper.productId = productId;
            
            List<Object> allLocationResults = new List<Object>();          
        
        for (AssociatedLocation assocLoc : associatedLocations) {
            HttpRequest req = new HttpRequest();
            req.setEndpoint(System.Label.LAD_LocationCheckPDP_EndpointURL);
            req.setMethod(System.Label.LAD_LocationCheckPDP_MethodType);
            String username = System.Label.LAD_LocationCheckPDP_Username;
            String password = System.Label.LAD_LocationCheckPDP_Password; 
            Blob headerValue = Blob.valueOf(username + ':' + password);
            String authorizationHeader = System.Label.LAD_LocationCheckPDP_AuthHeaderPrefix+' ' + EncodingUtil.base64Encode(headerValue);
            req.setHeader(System.Label.LAD_LocationCheckPDP_AuthHeader, authorizationHeader);
            String assLoc = assocLoc.Location.BLN_GUID__c != null ? assocLoc.Location.BLN_GUID__c : assocLoc.Location.Name;
            system.debug('assLoc>>'+assLoc);
            DateTime todaysDate = System.today();
            String todaysDateStr ='"'+ todaysDate.format(System.Label.LAD_LocationCheckPDP_DateFormat)+'"';
            String requestBody = '{"CallingModule": "GOP","CallingInstance": "GOP","RequestCreationDate": '+todaysDateStr+',"RequestTimeZone": "EST","ReleaseNumber": "1110900","UniqueOrderIdentifier": "123456","FulfillmentLineEntryList":{"FulfillmentLine":{"FulfillmentLineIdentifier":"1","SalesOrderNumber":"283474","InstanceNumber": "GOP","SalesOrderLineNumber": "001","RequestType": "Order","RequestedCreationDate":'+todaysDateStr+',"RequestedItem": "6558LGSV3FVZ","PromisingType": "Ship","RequestedDateTime": '+todaysDateStr+',"RequestedQuantity": "10","RequestedQuantityUOM": "EA","UnitPrice": "5","PlanningMultiple": "1","SubstitutionsAllowedFlag": "false","SplitsAllowedFlag": "false","GenerateAltAvailabilityFlag": "true","AvailabilityBasis": "Delivery","GeneratePeggingFlag": "true","IgnoreReservationFlag": "false","IgnoreDateReservationFlag": "false","CustomerDetails" : {"Party":"TEST MOTORIST","PartySite":"28009"},"RequestedShipFromOrg" :{"OrgIdentifier" : "' + assLoc.replaceAll('"', '') + '"}}}}';
            system.debug('reqBODY');
            system.debug(requestBody);
            req.setBody(requestBody);
            req.setHeader(System.Label.LAD_LocationCheckPDP_ContentTypeHeader,System.Label.LAD_LocationCheckPDP_ContentTypeValue);    
            //system.debug('request'+req); 
                Map<String, Object> responseBody = new Map<String, Object>();
                List<String> mockProductIdList = new List<String>{'01t9K000006dMDVQA2', '01t9K000006dMDXQA2'};
                if(mockProductIdList.contains(productId)){
                    responseBody = (Map<String, Object>) JSON.deserializeUntyped(mockJsonMethod(productId,assLoc));
                    system.debug('RESULT MOCK-----> ' + responseBody);
                }
                else{ 
                Http http = new Http();
                HTTPResponse res = http.send(req);
                system.debug('RESULT-----> ' + String.valueOf(res.getBody()));
                responseBody = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
               } 
            
                // Create a wrapper object to hold the response data
            
            if (responseBody.containsKey(System.Label.LAD_LocationCheckPDP_Response_CheckAvailabilityOutput)) {
                Map<String, Object> checkAvailabilityOutput = (Map<String, Object>) responseBody.get(System.Label.LAD_LocationCheckPDP_Response_CheckAvailabilityOutput);
                
                if (checkAvailabilityOutput.containsKey(System.Label.LAD_LocationCheckPDP_Response_FulfillmentLineEntryResultList)) {
                    List<Object> fulfillmentLineEntryResultList = (List<Object>) checkAvailabilityOutput.get(System.Label.LAD_LocationCheckPDP_Response_FulfillmentLineEntryResultList);
                    
                    for (Object entryResult : fulfillmentLineEntryResultList) {
                        Map<String, Object> entryResultMap = (Map<String, Object>) entryResult;
                        if (entryResultMap.containsKey(System.Label.LAD_LocationCheckPDP_Response_FulfillmentLineReplyList)) {
                            List<Object> fulfillmentLineReplyList = (List<Object>) entryResultMap.get(System.Label.LAD_LocationCheckPDP_Response_FulfillmentLineReplyList);
                            
                            for (Object lineReply : fulfillmentLineReplyList) {
                                Map<String, Object> lineReplyMap = (Map<String, Object>) lineReply;
                                if (lineReplyMap.containsKey(System.Label.LAD_LocationCheckPDP_Response_DefaultAvailabilityOption)) {
                                    Map<String, Object> defaultAvailabilityOption = (Map<String, Object>) lineReplyMap.get(System.Label.LAD_LocationCheckPDP_Response_DefaultAvailabilityOption);
                                    
                                    if (defaultAvailabilityOption.containsKey(System.Label.LAD_LocationCheckPDP_Response_FulfillmentLineResultList)) {
                                        List<Object> fulfillmentLineResultList = (List<Object>) defaultAvailabilityOption.get(System.Label.LAD_LocationCheckPDP_Response_FulfillmentLineResultList);
                                        
                                        for (Object resultDetail : fulfillmentLineResultList) {
                                            Map<String, Object> resultDetailMap = (Map<String, Object>) resultDetail;
                                            
                                            if (resultDetailMap.containsKey(System.Label.LAD_LocationCheckPDP_Response_ResultDetailList)) {
                                                List<Object> resultDetailList = (List<Object>) resultDetailMap.get(System.Label.LAD_LocationCheckPDP_Response_ResultDetailList);
                                                
                                                allLocationResults.addAll(resultDetailList);
                                                
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        system.debug('allLocationResults>>'+allLocationResults);
        for (Object locObj : allLocationResults) {
            Map<String, Object> locationData = (Map<String, Object>) locObj;
            system.debug('locObj>'+locObj);
            List<Object> expectedShipFromOrgList = (List<Object>) locationData.get(System.Label.LAD_LocationCheckPDP_Response_ExpectedShipFromOrgList);
            
            if (expectedShipFromOrgList != null && !expectedShipFromOrgList.isEmpty()) {
                Map<String, Object> orgData = (Map<String, Object>) expectedShipFromOrgList[0];
                system.debug('orgData--'+orgData);
                String locName = (String) orgData.get(System.Label.LAD_LocationCheckPDP_Response_OrgIdentifier);
                
                
                String expectedArrivalDateTime = (String) locationData.get(System.Label.LAD_LocationCheckPDP_Response_ExpectedArrivalDateTime);
                String deliveryDate = expectedArrivalDateTime != null ? expectedArrivalDateTime.substring(0, 10) : null;

                //10 Days Check
                Date delDate = Date.valueOf(deliveryDate);
                Date tenDaysFromToday = Date.today().addDays(10);
                Boolean isOverTenDays = delDate > tenDaysFromToday;
                
                
                String availability;

                Integer stock = Integer.valueOf(locationData.get(System.Label.LAD_LocationCheckPDP_Response_ExpectedAvailabilityOnRequestedDate));
                system.debug('prilocname>'+locName+deliveryDate);
                for (AssociatedLocation loc : associatedLocations) {
                    Id locId = loc.Id;
                    system.debug('locId>'+locId+loc.Location.Name);
                    if (loc.Location.Name == locName || loc.Location.BLN_GUID__c == locName) {
                        if (loc.LAD_Location_Type__c == System.Label.LAD_LocationCheckPDP_PrimaryLocationType) {
                            if(isOverTenDays){
                                availability = System.Label.LAD_LocationCheckPDP_NotAvailable;
                            }
                            else if (loc.LAD_Available_for_Delivery__c == true) {
                                availability = System.Label.LAD_LocationCheckPDP_AvailableDeliveryOrCollection;
                            } else {
                                availability = System.Label.LAD_LocationCheckPDP_AvailableCollection;
                            }
                            system.debug('prilocname>' + locName + deliveryDate + locId + availability);
                            
                            LocationDetails locationDetails = new LocationDetails(loc.Location.Name, deliveryDate, locId, availability, isOverTenDays, stock, delDate == Date.today()/* ,isInternal */);
                            responseWrapper.primarylocations.add(locationDetails);
                        } else {
                            if(isOverTenDays){
                                availability = System.Label.LAD_LocationCheckPDP_NotAvailable;
                            }
                            else {
                                availability = System.Label.LAD_LocationCheckPDP_Available;
                            }
                            system.debug('secondary>' + locName + deliveryDate + locId + availability);
                            LocationDetails locationDetails = new LocationDetails(loc.Location.Name, deliveryDate, locId, availability, isOverTenDays, stock, delDate == Date.today()/* ,isInternal */);
                            responseWrapper.secondarylocations.add(locationDetails);
                        }
                        break;
                    }
                }
            }
        }
        system.debug('responseWrapper>>'+responseWrapper);
            responseWrapperList.add(responseWrapper);
        }
        
        return responseWrapperList;
        } catch (Exception e) {
            // Handling the exceptions and log an error message
            BLN_ExceptionLogger.captureException(e);
            return null;
        }
        
        
    }
    
    //Wrapper Class 
    public class HttpResponseWrapper {
        //productId
        @AuraEnabled
        public String productId { get; set; }
        //primarylocations
        @AuraEnabled
        public List<LocationDetails> primarylocations { get; set; }
        //secondarylocations
        @AuraEnabled
        public List<LocationDetails> secondarylocations { get; set; }
    }
    
    public class LocationDetails {
        //location
        @AuraEnabled public  String location { get; set; }
        //deliveryDate
        @AuraEnabled public  String deliveryDate { get; set; }
        //locId
        @AuraEnabled public  String locId { get; set; } 
        //avlStatus
        @AuraEnabled public  String avlStatus { get; set; }
        //isDisabled
        @AuraEnabled public  Boolean isDisabled {get; set;}
        //stockCount
        @AuraEnabled public  Integer stockCount {get; set;}
        //dateIsToday
        @AuraEnabled public  Boolean dateIsToday {get; set;}
       
        public LocationDetails( String loc, 
                                String deliveryDate, 
                                String locationId,
                                String availability, 
                                Boolean isDisabled, 
                                Integer stockCount,
                                Boolean dateIsToday) {
            this.location = loc;
            this.deliveryDate = deliveryDate;
            this.locId = locationId;
            this.avlStatus = availability;
            this.isDisabled = isDisabled;
            this.stockCount = stockCount;
            this.dateIsToday = dateIsToday;
        }
    }

     private static String mockJsonMethod(String productId, string orgIndentifier){
        string json = '' + 
        '{' + 
        '"CheckAvailabilityOutput":{' + 
        '"PromisingSystem":"HVGOP",' + 
        '"PromisingInstance":"GOP",' + 
        '"PromiseDateTime":"2024-06-07T00:00:00.000+0000",' + 
        '"FulfillmentLineEntryResultList":[' + 
        '{' + 
        '"FulfillmentLineReplyList":[' + 
        '{' + 
        '"FulillmentLineIdentifier":"1",' + 
        '"NumberOfAltOptions":0,' + 
        '"DefaultAvailabilityOption":{' + 
        '"OptionRank":0,' + 
        '"OptionSummary":"0",' + 
        '"FulfillmentLineResultList":[' + 
        '{' + 
        '"FulfillmentLineIdentifier":"1",' + 
        '"TotalPrice":50.0,' + 
        '"TotalProfit":50.0,' + 
        '"TotalMargin":100.0,' + 
        '"TotalValue":0.0,' + 
        '"NumberOfSplits":0,' + 
        '"NumberOfSubstitutions":0,' + 
        '"FillRate":100.0,' + 
        '"NumberOfAtpItems":1,' + 
        '"NumberOfCtpItems":0,' + 
        '"ResultDetailList":[' + 
        '{' + 
        '"SplitLineIdentifier":"",' + 
        '"PromisingStatus":"",' + 
        '"RequestedDateTime":"2024-06-07T00:00:00.000+0000",' + 
        '"PromisingType":"Ship",' + 
        '"ExpectedArrivalDateTime":"2024-06-30T22:59:59.000+0000",' +    //Expected Arrival Date
        '"ExpectedShipDateTime":"2024-06-07T22:59:59.000+0000",' + 
        '"ExpectedPickDateTime":"2024-06-07T22:59:59.000+0000",' + 
        '"RequestedItem":"6558LGSV3FVZ",' +                             //Product Code
        '"ExpectedAvailableItem":"6558LGSV3FVZ",' + 
        '"ExpectedAvailabilityOnRequestedDate":10.0,' +                 //Stock
        '"ExpectedAvailableQuantity":10.0,' + 
        '"ExpectedAvailableQuantityUOM":"EA",' + 
        '"ExpectedDropShipSupplierSourceSystem":"",' + 
        '"ExpectedDemandClass":"",' + 
        '"ExpectedTotalFulfilmentCost":0.0,' + 
        '"ExpectedShippingCost":0.0,' + 
        '"LineFillRate":100.0,' + 
        '"ExpectedShipFromOrgList":[' + 
        '{' + 
        '"OrgIdentifier":"L31_UK"}' +                                      //Org Identifier
        ']' + 
        ',' + 
        '"PeggingDetailList":[' + 
        '{' + 
        '"ItemIdentifier":"6558LGSV3FVZ",' + 
        '"ShippingCalendar":"Belron Facility Schedule",' + 
        '"ReceivingCalendar":"Belron Facility Schedule",' + 
        '"ManufacturingCalendar":"Belron Facility Schedule",' + 
        '"BackToBackFlag":false,' + 
        '"AtpDetailList":[' + 
        '{' + 
        '"Quantity":10.0,' + 
        '"QuantityUom":"EA",' + 
        '"AtpCost":0.0,' + 
        '"AtpMode":"3",' + 
        '"LeadTime":0.0,' + 
        '"RequiredQuantity":10.0,' + 
        '"RequiredDateTime":"2024-06-07T22:59:59.000+0000"}' + 
        ']' + 
        ',' + 
        '"OrgInfoList":[' + 
        '{' + 
        '"OrgIdentifier":"L31_UK"}' + 
        '' + 
        ']' + 
        '}' + 
        ']' + 
        '}' + 
        ']' + 
        '}' + 
        ']' + 
        '}' + 
        '}' + 
        ']' + 
        '}' + 
        ']' + 
        '}' + 
        '}' + 
        '';

        if(!String.isBlank(productId)){
           json = json.replace('L31_UK', orgIndentifier);
            switch on productId{
               // when  '01t9K000006dMFFQA2'{  // < 10 days && !today || SKU: 2467BGNHAJ | Rear Toughened Bonded ZHt/En - BACKLIGHT
                 //   return json;
               // }
			
                when '01t9K000006dMDVQA2'{  // > 10 days || SKU: 8104GYPS4PR12 | Panoramic Roof - 1 part - SUNROOF
                    return json.replace('ExpectedArrivalDateTime":"2024-06-30T22:59:59.000+0000', 'ExpectedArrivalDateTime":"2024-12-30T22:59:59.000+0000');
                }
                when '01t9K000006dMDXQA2'{ // == today ||   SKU: 2737BGSVR6J | Rear Toughened Bonded Ht/En - BACKLIGHT RIGHT
                    return json.replace('ExpectedArrivalDateTime":"2024-06-30T22:59:59.000+0000', 'ExpectedArrivalDateTime":"2024-12-30T22:59:59.000+0000');
                }
                //when '01t9K000006dMF9QAM'{ // == 10 days || SKU: 3579AGACHMVW30 | ADAS Windscreen Enhanced - WINDSCREEN
                  //  return json.replace('ExpectedArrivalDateTime":"2024-06-30T22:59:59.000+0000', 'ExpectedArrivalDateTime":"2024-07-07T22:59:59.000+0000');
                //
            }
        }
        return null;
    } 
}