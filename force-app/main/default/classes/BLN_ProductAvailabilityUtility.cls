public without sharing class BLN_ProductAvailabilityUtility {
    static final String ISSUE = 'REQUISITION';
    static final String CPT = System.label.BLN_CPT;

    @AuraEnabled          
        public static Integer bufferCalculation(String caseId) {
        // Integer arBuffer = 0;
        Integer cvBuffer = 0;
        // Integer prBuffer = 0;
        Case caseRecord = [SELECT BLN_ServiceType__c, AccountId, BLN_AccountRulesTheme__c, BLN_CoverageVerificationTheme__c, BLN_ProvisionalDriver__c, BLN_BillingMethod__c, BLN_PricingTheme__c FROM Case WHERE Id = :caseId WITH SECURITY_ENFORCED LIMIT 1];            
        List<BLN_BufferRule__mdt> bufferRules = [SELECT BLN_BufferDays__c FROM BLN_BufferRule__mdt WHERE BLN_ServiceType__c = :caseRecord.BLN_ServiceType__c WITH SECURITY_ENFORCED];
        if(bufferRules.size() == 1) {                
            //if (caseRecord.AccountId != null && !caseRecord.BLN_AccountRulesTheme__c && caseRecord.BLN_BillingMethod__c == 'Insurance / Account') {
            //    arBuffer = bufferRules[0].BLN_BufferDays__c.intValue();                    
            //}                
                if (!caseRecord.BLN_CoverageVerificationTheme__c && caseRecord.BLN_ProvisionalDriver__c == 'Customer Driven' && caseRecord.BLN_BillingMethod__c == 'Insurance / Account') {
                   cvBuffer = bufferRules[0].BLN_BufferDays__c.intValue() +Integer.valueOf(Label.BLN_ExtraDayBuffer);
                }
                else if (!caseRecord.BLN_CoverageVerificationTheme__c && caseRecord.BLN_ProvisionalDriver__c == 'Belron Driven' && caseRecord.BLN_BillingMethod__c == 'Insurance / Account') {
                    cvBuffer = bufferRules[0].BLN_BufferDays__c.intValue();
                }
            //if (!caseRecord.BLN_PricingTheme__c) {
            //    prBuffer = bufferRules[0].BLN_BufferDays__c.intValue();
            //}
            //buffer = Math.max(arBuffer, Math.max(cvBuffer, prBuffer));
        }
             return cvBuffer;
    }

    public static Integer pricingThemeBuffer(String caseId){
        Integer buffer = 0;

        Case caseRecord = [SELECT Id, BLN_PricingTheme__c,BLN_ServiceType__c FROM Case WHERE Id =: caseId WITH SECURITY_ENFORCED LIMIT 1];
        BLN_BufferRule__mdt bufferRule = [SELECT BLN_BufferDays__c FROM BLN_BufferRule__mdt WHERE BLN_ServiceType__c =: caseRecord.BLN_ServiceType__c WITH SECURITY_ENFORCED LIMIT 1];

        if(!caseRecord.BLN_PricingTheme__c && bufferRule != null){
            buffer = bufferRule.BLN_BufferDays__c.intValue();
        }

        return buffer;
    }

    public static Integer accRuleBuffer(BLN_ProductResponseWrapper.ResponseProduct payload,String caseId){
        Integer buffer = 0;
        // Boolean result = false; //BLN_CheckBvtTaskCreationUtility.checkBvtTaskCreation(payloadString, caseId);
        String payloadString = JSON.serialize(payload);
        Boolean result = BLN_CheckBvtTaskCreationUtility.checkBvtTaskCreation(payloadString, caseId);
        // Boolean result = false;
        Case caseRecord = [SELECT Id,AccountId,BLN_BillingMethod__c,BLN_ServiceType__c,BLN_AccountRulesTheme__c FROM Case WHERE Id =: caseId WITH SECURITY_ENFORCED LIMIT 1];
        BLN_BufferRule__mdt bufferRule = [SELECT BLN_BufferDays__c FROM BLN_BufferRule__mdt WHERE BLN_ServiceType__c =: caseRecord.BLN_ServiceType__c WITH SECURITY_ENFORCED LIMIT 1];

        // if (caseRecord.AccountId != null && !caseRecord.BLN_AccountRulesTheme__c && caseRecord.BLN_BillingMethod__c == 'Insurance / Account' && bufferRule != null) {
        if (caseRecord.AccountId != null && result && caseRecord.BLN_BillingMethod__c == 'Insurance / Account' && bufferRule != null) {
            buffer = bufferRule.BLN_BufferDays__c.intValue();                    
        }
        
             return buffer;
        }
       
    public static String getTradeAccountId(Case motoCase){
        String tradeAccountId = '';
        String corporateSplitBillRecordType = SObjectType.BLN_Corporate__c.getRecordTypeInfosByDeveloperName().get('BLN_SpiltBill').getRecordTypeId();

        if(motoCase.BLN_BillingMethod__c == 'Insurance / Account' && motoCase.BLN_Corporate__c != null && motoCase.BLN_Corporate__r.RecordTypeId == corporateSplitBillRecordType){
            tradeAccountId = motoCase.BLN_Corporate__c != null ? motoCase.BLN_Corporate__r.BLN_CorporateSite__c != null ? motoCase.BLN_Corporate__r.BLN_CorporateSite__r.BLN_MDMAccountID__c : '' : '';
        }
        return tradeAccountId == null ? '' : tradeAccountId;
    }
    
    public static String getAccountId(Case motoCase) {            
        String accountId = '';
            
            if(motoCase.BLN_SubType__c == System.label.BLN_Warranty || motoCase.BLN_SubType__c == System.label.BLN_QualityCheck){                
                List<Account> accountList = [SELECT BLN_MDMAccountID__c,BLN_ClientType__c,RecordType.DeveloperName FROM Account WHERE BLN_ClientSubType__c = :System.label.BLN_Warranty AND RecordType.DeveloperName = :System.label.BLN_CustomerB2BAccount AND BLN_MDMAccountID__c != null WITH SECURITY_ENFORCED LIMIT 1];
                if(accountList.size() == 1){                    
                    accountId = accountList[0].BLN_MDMAccountID__c;                  
                } 
        }
        else if(motoCase.BLN_Corporate__c != NULL && 
                (
                    (motoCase.BLN_BillingMethod__c == 'Cash' && motoCase.BLN_Corporate__c != null && ( motoCase.BLN_Corporate__r.BLN_InsuranceSite__r.BLN_NonDirectBilling__c || motoCase.BLN_Corporate__r.BLN_CorporateSite__r.BLN_NonDirectBilling__c)) ||
                    motoCase.BLN_BillingMethod__c == 'Insurance / Account'
                )
        ){
            accountId = motoCase.BLN_Corporate__r.BLN_InsuranceSite__r.BLN_MDMAccountID__c != null ? 
                            motoCase.BLN_Corporate__r.BLN_InsuranceSite__r.BLN_MDMAccountID__c : 
                            motoCase.BLN_Corporate__r.BLN_InsuranceLegalEntity__r.BLN_MDMAccountID__c != null ? 
                                motoCase.BLN_Corporate__r.BLN_InsuranceLegalEntity__r.BLN_MDMAccountID__c : 
                                motoCase.BLN_Corporate__r.BLN_CorporateSite__r.BLN_MDMAccountID__c != null ? 
                                    motoCase.BLN_Corporate__r.BLN_CorporateSite__r.BLN_MDMAccountID__c : 
                                    motoCase.BLN_Corporate__r.BLN_CorporateLegalEntity__r.BLN_MDMAccountID__c != null ? 
                                        motoCase.BLN_Corporate__r.BLN_CorporateLegalEntity__r.BLN_MDMAccountID__c : '';
        }

            return accountId;
        }
    
        public static String getQuoteType(Case motoCase) {            
        
        Map<String,String> clientTypeVsQuoteTypeMap = new Map<String,String>{
            'Fleet National' => 'Fleet',
            'Fleet Local' => 'Fleet',
            'Trade/Commercial' => 'Trade',
            'Wholesale' => 'Trade',
            'Agent/Broker' => 'Insurance',
            'Government' => 'Fleet',
            'Intermediary' => 'Fleet',
            'Rental' => 'Fleet'
        };
            String quoteType=''; 
        String corporateInsuranceRecordType  = SObjectType.BLN_Corporate__c.getRecordTypeInfosByDeveloperName().get('BLN_Insurance').getRecordTypeId();
        String corporateFleetRecordType  = SObjectType.BLN_Corporate__c.getRecordTypeInfosByDeveloperName().get('BLN_CorporateFleet').getRecordTypeId();
        String corporateSplitBillRecordType = SObjectType.BLN_Corporate__c.getRecordTypeInfosByDeveloperName().get('BLN_SpiltBill').getRecordTypeId();

        if(motoCase.BLN_SubType__c == System.label.BLN_Warranty || motoCase.BLN_SubType__c == System.label.BLN_QualityCheck){
            Account b2bAcc = [SELECT BLN_MDMAccountID__c,BLN_ClientType__c,RecordType.DeveloperName FROM Account WHERE BLN_ClientSubType__c = :System.label.BLN_Warranty AND RecordType.DeveloperName = :System.label.BLN_CustomerB2BAccount AND BLN_MDMAccountID__c != null WITH SECURITY_ENFORCED LIMIT 1];
            if(b2bAcc != null){ 
              quoteType = System.label.BLN_Warranty;
            }
        }
        else if(motoCase.BLN_BillingMethod__c == 'Cash' && motoCase.BLN_Corporate__c != null && ((motoCase.BLN_Corporate__r.BLN_CorporateLegalEntity__c != null && motoCase.BLN_Corporate__r.BLN_CorporateLegalEntity__r.BLN_NonDirectBilling__c) || (motoCase.BLN_Corporate__r.BLN_InsuranceSite__c != null && motoCase.BLN_Corporate__r.BLN_InsuranceSite__r.BLN_NonDirectBilling__c))){
            quoteType = 'NoDirectBilling';
        }
        else if((motoCase.BLN_BillingMethod__c == 'Cash') || (motoCase.BLN_BillingMethod__c == 'Insurance / Account' && motoCase.BLN_Corporate__c == null)
                ||(motoCase.BLN_BillingMethod__c == 'Insurance / Account' && motoCase.BLN_Corporate__r.BLN_InsuranceSite__c == null && motoCase.BLN_Corporate__r.BLN_InsuranceLegalEntity__c == null && motoCase.BLN_Corporate__r.BLN_CorporateSite__c == null && motoCase.BLN_Corporate__r.BLN_CorporateLegalEntity__c == null)){
                    
            quoteType = 'Motorist';
        }
               
        else if (motoCase.BLN_BillingMethod__c == 'Insurance / Account' && motoCase.BLN_Corporate__c != null &&  (motoCase.BLN_Corporate__r.RecordTypeId == corporateInsuranceRecordType || motoCase.BLN_Corporate__r.RecordTypeId == corporateFleetRecordType)) {
            String clientType = motoCase.BLN_Corporate__r.BLN_InsuranceSite__c != null ? 
                                    motoCase.BLN_Corporate__r.BLN_InsuranceSite__r.BLN_ClientType__c :  
                                    motoCase.BLN_Corporate__r.BLN_InsuranceLegalEntity__c != null ? 
                                        motoCase.BLN_Corporate__r.BLN_InsuranceLegalEntity__r.BLN_ClientType__c : 
                                        motoCase.BLN_Corporate__r.BLN_CorporateSite__c != null ? 
                                            motoCase.BLN_Corporate__r.BLN_CorporateSite__r.BLN_ClientType__c : 
                                            motoCase.BLN_Corporate__r.BLN_CorporateLegalEntity__c != null ? 
                                                motoCase.BLN_Corporate__r.BLN_CorporateLegalEntity__r.BLN_ClientType__c : '';
            quoteType = clientTypeVsQuoteTypeMap.containsKey(clientType) ? clientTypeVsQuoteTypeMap.get(clientType) : clientType;
        }
        else if(motoCase.BLN_BillingMethod__c == 'Insurance / Account' && motoCase.BLN_Corporate__c != null && motoCase.BLN_Corporate__r.RecordTypeId == corporateSplitBillRecordType){
            quoteType = 'TradeSplit';
        }
        return quoteType;
    }

    @AuraEnabled
    public static String getQuoteApi(String cpqExtenalCode,String caseId){
        //BLN_APICalloutMapper__mdt calloutDetails = BLN_APICalloutMapper__mdt.getInstance(System.label.BLN_GetQuoteAPI);
        //Map<String,String> headerMap = new Map<String,String>();
        //headerMap.put(System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[0],System.label.BLN_AuthorizationBearer.split(System.label.BLN_Comma)[1]+' '+BLN_HTTPCallOutAccessToken.getAccessToken()?.accessToken);        
        //String hCode = EncodingUtil.convertToHex(Crypto.generateAesKey(128));
        //String correlID = hCode.substring(0,4)+'-'+hCode.substring(0,4)+'-'+hCode.substring(5,8)+'-'+hCode.substring(9,12)+'-'+hCode.substring(12,16)+'-'+hCode.substring(16,20);
        //headerMap.put(System.label.BLN_XCORRELATIONID,correlID);
        HttpResponse response = BLN_QuoteBookingHandler.getQuoteCallout(cpqExtenalCode,caseId);
        
        String returnPayloadAsString = response.getStatusCode() == 200 ? response.getBody() : System.label.BLN_CalloutFailed;
        
        return returnPayloadAsString;
        
    } 
    
    @AuraEnabled
    public static DisplayDetailsWrapper rebookServiceAppointments(String caseId){
      
        List<OrderItem> orderItemList = new List<OrderItem>();      
        List<OrderItem> allSelectedOrderItemList = new List<OrderItem>();
        Set<Id> serviceAppointmentId = new Set<Id>();
        List<productNames> productNameList = new List<productNames>();
        list<productDate> productDateList = new list<productDate>();
        Map<String,String> saIdWithSaNumberMap = new  Map<String,String>();
        String externalQuoteId = '';
        String locationId = '';
        Set<Id> orderItemIdList = new Set<Id>();
        List<AppointmentWrapper> appWrapperList = new List<AppointmentWrapper>();        
        List<ProductRequiredWrapper> productRequiredWrapperList= new List<ProductRequiredWrapper>();
        Map<String, String> locationNameFromGuidMap = new Map<String,String>();

        Order orderData = [SELECT Id, AccountId,BLN_CPQExternalQuoteId__c,BLN_ServiceTerritory__r.BLN_GUID__c,BLN_TotalTax__c,BLN_TotalIncludingTaxTrade__c,
                            BLN_TotalTaxPayablebyTrade__c,BLN_TotalPayablebyTradeCompany__c,BLN_TotalIncludingTaxInsuranceCompany__c,
                            BLN_TotalTaxPayablebyInsurance__c,BLN_PayableByInsuranceRepair__c,BLN_TotalIncludingTaxMotorist__c,
                            BLN_TotalTaxPayablebyMotorist__c,BLN_TotalPrice__c,BLN_TotalPayableByMotorist__c, Status,
                            BLN_ServiceTerritory__r.Name,BLN_Case__c,BLN_DiscountThresholdAmountA__c, BLN_DiscountThresholdAmountB__c,
                            BLN_DiscountThresholdAmountC__c,BLN_ServiceTerritory__r.BLN_Type__c, BLN_PriceExpirationDate__c, BLN_TotalIncludingTax__c,BLN_ServiceTerritory__c
                            FROM Order WHERE Status = :label.BLN_Accepted AND BLN_Case__c = :caseId WITH SECURITY_ENFORCED ORDER BY createddate DESC LIMIT 1 ];
        
        locationId = orderData.BLN_ServiceTerritory__r.BLN_GUID__c;
        externalQuoteId = orderData.BLN_CPQExternalQuoteId__c;
        String payload = getQuoteApi(orderData.BLN_CPQExternalQuoteId__c,caseId);//orderData.BLN_CPQExternalQuoteId__c
        BLN_ProductResponseWrapper.ResponseProduct data = (BLN_ProductResponseWrapper.ResponseProduct) System.JSON.deserialize(payload,BLN_ProductResponseWrapper.ResponseProduct.class);
        
        Set<String> locationIds = new Set<String>();
        List<LocationWrapper> selectedLocationWrapList = new List<LocationWrapper>(); 
        List<BLN_ProductAvailabilityWrapper.DisplayQuoteDetailsWrapper> quoteDetailsList = new List<BLN_ProductAvailabilityWrapper.DisplayQuoteDetailsWrapper>();
        for(BLN_ProductResponseWrapper.ResponseQuotes quoteVar : data.quotes){
            locationIds.add(quoteVar.locationId);
        }
        for(ServiceTerritory st : [Select Id, Name,BLN_GUID__c,BLN_Type__c From ServiceTerritory where BLN_GUID__c = :locationIds WITH SECURITY_ENFORCED]){
            locationNameFromGuidMap.put(st.BLN_GUID__c, st.Name);
        }
        for(BLN_ProductResponseWrapper.ResponseQuotes quoteVar : data.quotes){
            BLN_ProductAvailabilityWrapper.DisplayQuoteDetailsWrapper displayDetailsData = new BLN_ProductAvailabilityWrapper.DisplayQuoteDetailsWrapper();
            displayDetailsData.quoteId = quoteVar.quoteId;
            if(locationNameFromGuidMap.containsKey(quoteVar.locationId)){
                displayDetailsData.quotelocation = locationNameFromGuidMap.get(quoteVar.locationId);//displayDetailsData.locationGUID = quoteVar.locationId;
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
                if(orderData.BLN_ServiceTerritory__r.BLN_Type__c == System.label.BLN_Mobile){
                    locations.isMobileLocation = true;
                }else{
                    locations.isMobileLocation = false;
                } 
                locations.quoteTotal = quoteVar.quoteTotals.totalPrice;
                locations.quoteVAT = quoteVar.quoteTotals.totaltax;
                locations.quoteNetTotal = quoteVar.quoteTotals.totalIncludingTax;
                selectedLocationWrapList.add(locations);
            }            
        }
        
        List<BLN_ProductAvailabilityWrapper.EarliestAvailabilityDetailsWrapper> earliestAvailabilityDateList = new List<BLN_ProductAvailabilityWrapper.EarliestAvailabilityDetailsWrapper>();
        earliestAvailabilityDateList = getEarliestDateList(payload);
        map<Id,List<OrderItem>> serviceAppointmentOrderItemsMap = new map<Id,List<OrderItem>>();
        String cpqQuoteId = '';
        // Map<String,Set<String>> bomIdVsAddonPartIdListMap = new Map<String,Set<String>>();
        Map<String, List<OrderItem>> bomIdVsAddonPartIdListMap = new Map<String, List<OrderItem>>();
        allSelectedOrderItemList = [SELECT Id,Product2.BLN_MDMID__c, Product2.Name,Product2.BLN_ProductCategory__c, Product2.ProductCode, OrderId, Quantity, UnitPrice, TotalPrice, EndDate,BLN_BundleName__c,BLN_BOMID__c,BLN_IsProductSelected__c,BLN_TotalTax__c, 
                                    BLN_NetPriceAfterPromotion__c,BLN_NetPriceIncludingTax__c,BLN_Optional__c,BLN_ServiceAppointment__c,BLN_FittingLocation__r.Name,BLN_FittingLocation__r.BLN_GUID__c,BLN_DocumentNumber__c,
                                    BLN_LeadingPartIndicator__c,BLN_ParentDocumentNumber__c,BLN_UnConsumedQuantity__c,Order.BLN_ServiceTerritory__r.BLN_CostCenter__c,BLN_ServiceAppointment__r.AppointmentNumber,
                                    Order.BLN_CPQExternalQuoteId__c,BLN_StockLineNumber__c,Product2.BLN_SKU__c,BLN_StockLocation__r.BLN_OrgCodeLocation__c ,BLN_StockCurrentQuantity__c,
                                    BLN_FittingLocation__c, BLN_ServiceAppointment__r.ArrivalWindowStartTime
                                    FROM OrderItem where orderId = :orderData.Id AND BLN_IsProductSelected__c = true AND BLN_ServiceAppointment__r.status = 'Scheduled' AND Product2.BLN_ProductStockable__c = true  WITH SECURITY_ENFORCED];
        for(OrderItem oi : allSelectedOrderItemList){

            if(oi.BLN_BOMId__c != '' && oi.BLN_BOMId__c != null && oi.BLN_LeadingPartIndicator__c){
                bomIdVsAddonPartIdListMap.put(oi.BLN_BOMId__c, new List<OrderItem>{oi});
            }
                orderItemList.add(oi);
        }
        for(orderItem orderItems:orderItemList){
            productNames prod = new productNames();  
            prod.productName = orderItems.Product2.Name;
            prod.productCode = orderItems.Product2.BLN_MDMID__c;
            prod.prodCategory = orderItems.Product2.BLN_ProductCategory__c;
            productNameList.add(prod); 
            orderItemIdList.add(orderItems.Id);
            saIdWithSaNumberMap.put(orderItems.BLN_ServiceAppointment__c, orderItems.BLN_ServiceAppointment__r.AppointmentNumber);
            if (orderItems?.Order.BLN_CPQExternalQuoteId__c != null) {
                cpqQuoteId = orderItems.Order.BLN_CPQExternalQuoteId__c;
            }
            if(serviceAppointmentOrderItemsMap.containsKey(orderItems.BLN_ServiceAppointment__c)){
                serviceAppointmentOrderItemsMap.get(orderItems.BLN_ServiceAppointment__c).add(orderItems);
            }else{
                serviceAppointmentOrderItemsMap.put(orderItems.BLN_ServiceAppointment__c,new List<OrderItem>{orderItems});
            }       
        }

        map<String,List<Appointments>> appointmentsMap = new map<String,List<Appointments>>();
        map<String,List<productNames>> productNamesWithLocationMap = new map<String,List<productNames>>();
        map<String,String> locationGuIDMap = new map<String,String>();
        Integer i = 1;
        Integer keyIndex = 0;
        Set<Id> workorderlineItemIds= new Set<Id>();
        for(ServiceAppointment serviceAppt : [Select Id,ServiceTerritoryId,ParentRecordId,ServiceTerritory.Name,ServiceTerritory.BLN_GUID__c,ServiceTerritory.BLN_Type__c,ArrivalWindowStartTime,ArrivalWindowEndTime,SchedStartTime,Status from ServiceAppointment WHERE  Id IN : serviceAppointmentOrderItemsMap.keySet() WITH SECURITY_ENFORCED]){
            String locationGUID = serviceAppt.ServiceTerritory.BLN_GUID__c;
            String locationName = serviceAppt.ServiceTerritory.Name;
            list<products> prodList = new list<products>(); 
            workorderlineItemIds.add(serviceAppt.ParentRecordId);
            for(orderItem orderItem : orderItemList){
                if(serviceAppt.Id == orderItem.BLN_ServiceAppointment__c){
                    locationGUID = orderItem.BLN_FittingLocation__r.BLN_GUID__c;
                    locationName = orderItem.BLN_FittingLocation__r.Name; 
                }
                Products prod1 = new Products(); 
                prod1.quantity = integer.valueOf(orderItem.quantity);
                prod1.productCode = orderItem.Product2.BLN_MDMID__c;
                prod1.isChecked = false;
                prod1.prodCategory = orderItem.Product2.BLN_ProductCategory__c;
                if(serviceAppt.Id == orderItem.BLN_ServiceAppointment__c && orderItem.BLN_IsProductSelected__c){
                    prod1.productEnable = true;
                }else{
                    prod1.productEnable = false;
                }
                prod1.bomId = orderItem.BLN_BOMId__c;
                prod1.lineItemId = Integer.valueOf(orderItem.BLN_DocumentNumber__c);
                prod1.orderItemId = orderItem.Id;
                prod1.stockLocation = orderItem.BLN_StockLocation__r.BLN_OrgCodeLocation__c;
                prodList.add(prod1);
                ProductNames prod = new ProductNames();  
                prod.productName = orderItem.Product2.Name;
                prod.productCode = orderItem.Product2.BLN_MDMID__c;
                prod.prodCategory = orderItem.Product2.BLN_ProductCategory__c;                
                if(productNamesWithLocationMap.containsKey(locationGUID)){
                    productNamesWithLocationMap.get(locationGUID).add(prod);
                }else{
                    productNamesWithLocationMap.put(locationGUID,new List<ProductNames>{prod});
                }   
            }
            locationGuIDMap.put(locationGUID,locationName);
            String formattedStartDate = serviceAppt.ArrivalWindowStartTime.format('MMMM d, yyyy');
            String arrivalWindowStartTime =  String.valueOfGMT(serviceAppt.ArrivalWindowStartTime);
            String arrivalWindowEndTime =  String.valueOfGMT(serviceAppt.ArrivalWindowEndTime);          
            List<String> partsA = arrivalWindowStartTime.split(' ');
            String formattedhhmm = partsA[1].substring(0, 5);            
            List<String> partsB = arrivalWindowEndTime.split(' ');
            String formattedEndDate = partsB[1].substring(0, 5);
            String result = formattedStartDate + ' '+ formattedhhmm + '-' + formattedEndDate;
            list<productAvailibilities> productAvailibilitiesList = new list<productAvailibilities>();
            productAvailibilities productAvailibilities = new productAvailibilities();
            ProductAvailibilities.products = prodList;
            productAvailibilitiesList.add(productAvailibilities);
           
            Appointments appData = new Appointments(); 
            appData.appointmentName = 'Appointment'+ ' '+  String.valueOf(i);
            appData.keyIndex = String.valueOf(keyIndex);
            appData.locationId = serviceAppt.ServiceTerritory.BLN_GUID__c;
            appData.locationName = serviceAppt.ServiceTerritory.Name;
            appData.isFirstAppointment = true;
            appData.earlierAvailabilityDateHeader = null;
            appData.slotSelectedDate = result; //String.valueOf((serviceAppt.ArrivalWindowStartTime.dateGMT())+ startTime);
            appData.serviceAppointmentId = serviceAppt.Id;
            appData.slotDate = null;
            appData.slotTime = null;
            appData.isDropOff = 'false';
            appData.slotDateTimeStart = serviceAppt.ArrivalWindowStartTime;
            appData.slotDateTimeFinish = serviceAppt.ArrivalWindowEndTime;
            appData.schedStartTime = serviceAppt.SchedStartTime;
            appData.productAvailibilities = productAvailibilitiesList;
            appData.status=serviceAppt.Status;
            if(serviceAppt.ServiceTerritory.BLN_Type__c == System.label.BLN_Mobile){
                appData.isMobileLocation = true;
            }else{
                appData.isMobileLocation = false;
            }          
            if(appointmentsMap.containsKey(locationGUID)){
                appointmentsMap.get(locationGUID).add(appData);
            }else{
                appointmentsMap.put(locationGUID,new List<Appointments>{appData});
            }
            keyIndex++;
            i++;
        }
        List<ProductRequired> prodRequiredList=[Select Id,ParentRecordId,BLN_IsConsumed__c,Product2Id, BLN_ProductCode__c from ProductRequired where ParentRecordId IN : workorderlineItemIds  WITH SECURITY_ENFORCED];

        for(ProductRequired prod2List: prodRequiredList){
            ProductRequiredWrapper prodWrapp= new ProductRequiredWrapper ();
            prodWrapp.productCode = prod2List.BLN_ProductCode__c;
            prodWrapp.isConsumed = prod2List.BLN_IsConsumed__c;
            productRequiredWrapperList.add(prodWrapp);
        }      
        List<earliestAvailablity> earliestAvailabilityList = new List<earliestAvailablity>();
        List<ServiceLocationLabel> serviceLocationLabelList = new List<ServiceLocationLabel>();
        
        for(String locationGuId : appointmentsMap.keySet()){
            earliestAvailablity earliestAvailablity = new earliestAvailablity();
            earliestAvailablity.serviceName = locationGuIDMap.get(locationGuId);
            earliestAvailablity.earliestAvailability = System.label.BLN_EarliestAvailability;
            earliestAvailablity.productDate = productDateList;
            earliestAvailabilityList.add(earliestAvailablity);
            ServiceLocationLabel serviceLocationLabel = new ServiceLocationLabel();
            ServiceLocationLabel.serviceLabel = System.label.BLN_ServiceLocationCap;
            ServiceLocationLabel.Product = System.label.BLN_Products;
            serviceLocationLabel.productNames = productNameList;
            serviceLocationLabelList.add(serviceLocationLabel);
            AppointmentWrapper appWrapper = new AppointmentWrapper();        
            appWrapper.serviceLocationName = System.label.BLN_ServiceLocation +' '+ locationGuIDMap.get(locationGuId);//serviceLocationLabel.ServiceLabel +' '+ locationGuIDMap.get(locationGuId);
            appWrapper.externalQuoteId = orderData.BLN_CPQExternalQuoteId__c;
            appWrapper.serviceLocationId = locationGUID;
            if(orderData.BLN_ServiceTerritory__r.BLN_GUID__c == locationGuId){
                appWrapper.isPrimaryLocation = true;
            }else {
                appWrapper.isPrimaryLocation = false;
            }           
            appWrapper.serviceLocationLabel = serviceLocationLabelList;
            appWrapper.earliestAvailablity = earliestAvailabilityList;
            appWrapper.appointments = appointmentsMap.get(locationGuId);
            appWrapperList.add(appWrapper);
        }
        DisplayDetailsWrapper returnData = new DisplayDetailsWrapper();
        returnData.appointmentWrapperList = JSON.serialize(appWrapperList);
        returnData.earliestAvailabilityList = earliestAvailabilityDateList;
        returnData.selectedLocation = JSON.serialize(selectedLocationWrapList);
        returnData.getQuotePayload = payload;
        returnData.existingGUId = locationId;
        returnData.productrequiredWrappList=productRequiredWrapperList;
        returnData.externalQuoteId = externalQuoteId;
        returnData.prodLists = getAllSelectedProductLists(orderData.BLN_CPQExternalQuoteId__c);
        returnData.quoteDetailsDataList = quoteDetailsList;
        return returnData;
    }

    //Get selectedProductList & get addOnProdList
    public static List<List<BLN_ProductAvailabilityWrapper.ProductSelectionWrapper>> getAllSelectedProductLists(String orderId){
        Order ord = [SELECT Id,BLN_CPQExternalQuoteId__c,(SELECT Id,BLN_DocumentNumber__c,BLN_ParentDocumentNumber__c,BLN_BOMID__c,BLN_BundleName__c,BLN_LeadingPartIndicator__c,Product2.BLN_ProductCategory__c,Quantity,BLN_NetPriceAfterPromotion__c,BLN_NetPriceIncludingTax__c,BLN_TaxRate__c,Product2.BLN_MDMID__c,Product2.Name FROM OrderItems WHERE BLN_IsProductSelected__c = true) FROM Order WHERE BLN_CPQExternalQuoteId__c = :orderId AND Status = 'Accepted' WITH SECURITY_ENFORCED LIMIT 1];
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
            prod.mdmId = oi.Product2.BLN_MDMID__c;
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
                    selectedProdsList.add(prod);
                }
                else{
                    addOnProdsList.add(prod);
                }
            }
            else{
                selectedProdsList.add(prod);
            }
        }
        return new List<List<BLN_ProductAvailabilityWrapper.ProductSelectionWrapper>>{selectedProdsList,addOnProdsList};
    }

    @AuraEnabled
    public static List<BLN_ProductAvailabilityWrapper.EarliestAvailabilityDetailsWrapper> getEarliestDateList(String responsePayload){
        BLN_ProductResponseWrapper.ResponseProduct data = (BLN_ProductResponseWrapper.ResponseProduct) System.JSON.deserialize(responsePayload,BLN_ProductResponseWrapper.ResponseProduct.class);
        List<BLN_ProductAvailabilityWrapper.EarliestAvailabilityDetailsWrapper> earliestDatesList = new List<BLN_ProductAvailabilityWrapper.EarliestAvailabilityDetailsWrapper>();
        Set<String> partNumberSet = new Set<String>(); 
        for(BLN_ProductResponseWrapper.ResponseQuotes quoteVar : data.quotes){
            for(BLN_ProductResponseWrapper.ResponseLineItems lineItem : quoteVar.lineItems){
                if(lineItem.partNumber != '' && lineItem.partNumber != null){
                    partNumberSet.add(lineItem.partNumber);
                }
            }
        }
        Map<String,Product2> mdmIdVsProductsMap = new Map<String,Product2>();
        for(Product2 prod : [SELECT Id, Name, BLN_MDMID__c, BLN_BusinessUnitSpecificBranchOnly__c, BLN_ProductCategory__c, BLN_ProductStockable__c,BLN_BondedNonBonded__c FROM Product2 WHERE isActive = true AND  BLN_MDMID__c IN :partNumberSet WITH SECURITY_ENFORCED]){
            mdmIdVsProductsMap.put(prod.BLN_MDMID__c,prod);
        }

        for(BLN_ProductResponseWrapper.ResponseQuotes quoteVar : data.quotes){
            for(BLN_ProductResponseWrapper.ResponseLineItems lineItem : quoteVar.lineItems){
                BLN_ProductAvailabilityWrapper.EarliestAvailabilityDetailsWrapper earliestAvailabilityVar = new BLN_ProductAvailabilityWrapper.EarliestAvailabilityDetailsWrapper();
                earliestAvailabilityVar.quoteId = quoteVar.quoteId;
                earliestAvailabilityVar.mdmId = lineItem.partNumber;
                earliestAvailabilityVar.bundleName = lineItem.bundleName;                
                earliestAvailabilityVar.earliestDateList = new List<BLN_ProductResponseWrapper.ResponseAvailabilityDetails>();                
                if(lineItem.availabilityDetails.size() > 0){
                    if(lineItem.partNumber != '' && lineItem.partNumber != null && mdmIdVsProductsMap.containsKey(lineItem.partNumber)){
                        
                        for(BLN_ProductResponseWrapper.ResponseAvailabilityDetails availDetail : lineItem.availabilityDetails){
                            BLN_ProductResponseWrapper.ResponseAvailabilityDetails earliestDateData = new BLN_ProductResponseWrapper.ResponseAvailabilityDetails();
                            switch on availDetail.availableFromDate{
                                when null {
                                    earliestDateData.isOutofStock = true;
                                    continue;
                                }
                                when '' {
                                    earliestDateData.isOutofStock = true;
                                    continue;
                                }
                                when else{
                                    earliestDateData.stockLocationId = availDetail.stockLocationId;
                                    earliestDateData.availableFromDate = availDetail.availableFromDate;        
                                    earliestAvailabilityVar.earliestDateList.add(earliestDateData);   
                                    earliestDateData.isOutofStock = false;     
                                }  
                            }
                        }
                        while(earliestAvailabilityVar.earliestDateList.size() == 0){
                            BLN_ProductResponseWrapper.ResponseAvailabilityDetails earliestDateData = new BLN_ProductResponseWrapper.ResponseAvailabilityDetails();
                            earliestDateData.stockLocationId = mdmIdVsProductsMap.get(lineItem.partNumber).BLN_ProductStockable__c ? System.label.BLN_StockableItem : quoteVar.locationId ;
                            earliestDateData.availableFromDate = mdmIdVsProductsMap.get(lineItem.partNumber).BLN_ProductStockable__c ? String.valueOf(DateTime.newInstance(System.now().date().addDays(Integer.valueOf(System.label.BLN_NoStockBufferPeriod)),System.now().time()).format('YYYY-MM-dd\'T\'HH:mm:ssXXX')) : String.valueOf(System.now().format('YYYY-MM-dd\'T\'HH:mm:ssXXX'));
                            earliestAvailabilityVar.earliestDateList = new List<BLN_ProductResponseWrapper.ResponseAvailabilityDetails>{earliestDateData};
                        }
                    }
                }
                else{
                    BLN_ProductResponseWrapper.ResponseAvailabilityDetails earliestDateData = new BLN_ProductResponseWrapper.ResponseAvailabilityDetails();
                    if(lineItem.partNumber != '' && lineItem.partNumber != null && mdmIdVsProductsMap.containsKey(lineItem.partNumber)){
                        earliestDateData.stockLocationId = mdmIdVsProductsMap.get(lineItem.partNumber).BLN_ProductStockable__c ? System.label.BLN_StockableItem : quoteVar.locationId;
                        earliestDateData.availableFromDate = mdmIdVsProductsMap.get(lineItem.partNumber).BLN_ProductStockable__c ? String.valueOf(DateTime.newInstance(System.now().date().addDays(Integer.valueOf(System.label.BLN_NoStockBufferPeriod)),System.now().time()).format('YYYY-MM-dd\'T\'HH:mm:ssXXX')) : String.valueOf(System.now().format('YYYY-MM-dd\'T\'HH:mm:ssXXX'));
                        earliestDateData.isOutofStock = true; 
                    }
                    else{
                        earliestDateData.stockLocationId = System.label.BLN_StockableItem;
                        earliestDateData.availableFromDate = String.valueOf(DateTime.newInstance(System.now().date().addDays(Integer.valueOf(System.label.BLN_NoStockBufferPeriod)),System.now().time()).format('YYYY-MM-dd\'T\'HH:mm:ssXXX'));
                        earliestDateData.isOutofStock = true;   
                    }
                    earliestAvailabilityVar.earliestDateList.add(earliestDateData);
                }
                // if (!productCodeSet.contains(lineItem.partNumber)) {
                    earliestDatesList.add(earliestAvailabilityVar);
                // }
                // productCodeSet.add(lineItem.partNumber);
            }       
        }
        return earliestDatesList;
    }
    /* This method is used for product allow not*/
    public static List<BLN_ProductAvailabilityWrapper.AccountRuleParameterWrapper> getAccountRuleParameters(String arpRecordType,Id accountId ,Date jobDate) {
        List<BLN_ProductAvailabilityWrapper.AccountRuleParameterWrapper> arpWrappers = new List<BLN_ProductAvailabilityWrapper.AccountRuleParameterWrapper>();
        //Making a list of Product allowance
        List<BLN_AccountRuleParameter__c> arpRecords = new List<BLN_AccountRuleParameter__c>();
        //Null check for paramerter before arp get
        if(arpRecordType != null && accountId != null && jobDate != null){
            arpRecords = BLN_AccountRuleParameterUtil.getAccountRuleParameters(arpRecordType, accountId, jobDate);
        }
        //Null check for arpRecords.
        if(arpRecords != null && arpRecords.size() > 0){
            for(BLN_AccountRuleParameter__c arp: arpRecords){
                if(arp.BLN_ProductAllowance__c?.contains(System.Label.BLN_DoNotShow)) {
                    BLN_ProductAvailabilityWrapper.AccountRuleParameterWrapper arpWrp = new BLN_ProductAvailabilityWrapper.AccountRuleParameterWrapper();
                    arpWrp.productCategory =  arp.BLN_Product__c != null && arp.BLN_Product__r.BLN_ProductCategory__c != null ? arp.BLN_Product__r.BLN_ProductCategory__c : arp.BLN_ProductCategory__c;
                    arpWrp.productCode = arp.BLN_Product__r.ProductCode != null ? arp.BLN_Product__r.ProductCode : null;
                    arpWrp.isDoNotShow = arp.BLN_ProductAllowance__c == System.Label.BLN_DoNotShow ? true : false;
                    arpWrp.isDoNotShowAll = arp.BLN_ProductAllowance__c == System.Label.BLN_DoNotShowAll ? true : false;
                    arpWrappers.add(arpWrp);
                }
            }
        }

        return arpWrappers;
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
        public String selectedLocation;
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
    }

    public class LocationWrapper{
        public boolean isMobileLocation;
        public String locationGUID;	
        public String quoteEarliestAppointmentAvailability;	
        public String quoteId;	
        public String quotelocation;
        public Decimal quoteVAT;
        public Decimal quoteTotal;
        public Decimal quoteNetTotal;
        public String quoteWeatherGuard;
        public Boolean isCPT;
        public Boolean locDisabled;
    }

    public class AppointmentWrapper {
        @AuraEnabled public String serviceLocationName {get; set;}	
        @AuraEnabled public String externalQuoteId {get; set;}
        @AuraEnabled public String serviceLocationId {get; set;}	
        @AuraEnabled public Boolean isPrimaryLocation {get; set;}
        @AuraEnabled public List<ServiceLocationLabel> serviceLocationLabel {get; set;}
        @AuraEnabled public List<EarliestAvailablity> earliestAvailablity {get; set;}
        @AuraEnabled public List<Appointments> appointments {get; set;}
    }

    public class ServiceLocationLabel {
        @AuraEnabled public string serviceLabel {get; set;}
        @AuraEnabled public string product {get; set;}
        @AuraEnabled public List<ProductNames> productNames {get; set;}
    }

    public class ServiceLabel {
        @AuraEnabled public String serviceLocation {get; set;}
    }

    public class ProductNames {
        @AuraEnabled public String productName {get; set;}
        @AuraEnabled public String productDescription {get; set;}
        @AuraEnabled public String productCode {get; set;}
        @AuraEnabled public String bundleName {get; set;}
        @AuraEnabled public String prodCategory {get; set;}
    }
    public class EarliestAvailablity {
        @AuraEnabled public String serviceName {get; set;}
        @AuraEnabled public String earliestAvailability {get; set;}	
        @AuraEnabled public List<productDate> productDate {get; set;}
    }

    public class ProductDate {
        @AuraEnabled public String earliestDate {get; set;}
        @AuraEnabled public String productCode {get; set;}
    }

    public class Appointments {
        @AuraEnabled public String appointmentName {get; set;}
        @AuraEnabled public String keyIndex {get; set;}
        @AuraEnabled public String locationId {get; set;}
        @AuraEnabled public String locationName {get; set;}
        @AuraEnabled public String earlierAvailabilityDateHeader {get; set;}	
        @AuraEnabled public String slotSelectedDate {get; set;}
        @AuraEnabled public String serviceAppointmentId {get; set;}
        @AuraEnabled public String slotDate {get; set;}
        @AuraEnabled public String slotTime {get; set;}
        @AuraEnabled public Datetime slotDateTimeStart {get; set;}	
        @AuraEnabled public Datetime slotDateTimeFinish {get; set;}
        @AuraEnabled public Datetime schedStartTime {get; set;}
        @AuraEnabled public Boolean isFirstAppointment {get; set;}
        @AuraEnabled public Boolean isMobileLocation {get; set;}
        @AuraEnabled public String isDropOff {get; set;}
        @AuraEnabled public String status {get; set;}
        @AuraEnabled public List<ProductAvailibilities> productAvailibilities {get; set;}
    }

    public class ProductAvailibilities {
        @AuraEnabled public List<Products> products {get; set;}
    }

    public class Products {
        @AuraEnabled public String productCode {get; set;}
        @AuraEnabled public boolean productEnable {get; set;}
        @AuraEnabled public Integer quantity {get; set;}
        @AuraEnabled public boolean isChecked {get; set;}
        @AuraEnabled public String bomId {get; set;}
        @AuraEnabled public Integer lineItemId {get; set;}
        @AuraEnabled public String orderItemId {get; set;}
        @AuraEnabled public String prodCategory {get; set;}
        @AuraEnabled public String productName {get; set;}
        @AuraEnabled public String stockLocation {get; set;}
        @AuraEnabled public List<Products> childProductList {get; set;}
    }
    }