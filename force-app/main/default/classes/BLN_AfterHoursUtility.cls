/**@description : This Apex class used to calculate after hours and return maximum chanrges coming from selected product CPQ.
*  @author: PwC India
*  @Story: FOUK-3762
*  @CreatedDate: 15/05/2024
*/
public with sharing class BLN_AfterHoursUtility {
    
    public static DateTime startDateTime;
    public static RecordType recordType;
    public static BLN_Corporate__c corporateRecord;

    /**
*@description:This method is used to get maximum after hour charges based on business hours.
*@return decimal
*/
    @AuraEnabled
    public static AfterHourWrapper afterHourUtility(List<String> saList, String jsonProductData,String selectedProductJson, boolean isCashJourney,id caseId, String slotdate) {
        
        String day;
        // String endDay;
        String timePartString;
        Time timePart;
        String slotDateTimeString;
        // String slotDateTimeEndString;
        List<String> dateTimeParts;
        String dateString;
        String timeString ;
        Date datePart;
        Datetime dateTimePart ;
        Boolean productEnable;
        String prodCategory;

        Date newDate;
        
        List<AfterHourWrapper> ahwrapList = new List<AfterHourWrapper>();
        AfterHourWrapper ahwrap = new AfterHourWrapper();
        Map<String, Object> appointmentMap= new Map<String, Object>();
        List<object>oblist=new List<Object>();
        List<Object> appointments = new List<Object> ();
        Map<String, Object> appointmentInner=new Map<String, Object>();
        List<Object> productAvailabilitiesList=new List<Object>();
        Map<String, Object> productAvailabilitiesMap=new Map<String, Object>();
        List<Object> productAvailabilities =new List<Object>();
        Map<String, Object> product=new Map<String, Object>();
        List<AfterHourWrapper>ahlist=new List<AfterHourWrapper>();
        try{
            oblist = (List<object>) JSON.deserializeUntyped(slotdate);
            for (Object appointmentObj : oblist) {
                appointmentMap = (Map<String, Object>) appointmentObj;

                
                // Access the 'Appointments' map
                if (appointmentMap.containsKey('appointments')) {
                    appointments = (List<Object>) appointmentMap.get('appointments');
                }
                    for (Object appointmentObjInner : appointments) {
                       appointmentInner = (Map<String, Object>) appointmentObjInner;
                        if (appointmentInner.containsKey('slotDateTimeStart') && appointmentInner.get('slotDateTimeStart') != null &&
                        (appointmentInner.get('slotDateTimeStart')) !='') {
                            slotDateTimeString = (String) appointmentInner.get('slotDateTimeStart');                      
                            slotDateTimeString = slotDateTimeString.removeEnd('Z');
                            dateTimeParts = slotDateTimeString.contains('T') ? slotDateTimeString.split('T') : slotDateTimeString.split(' ');

                            //Added by Shailendra : Added condition due List index out of bounds
                            dateString = dateTimeParts != null && dateTimeParts.size() > 0 ? dateTimeParts[0] : null;
                            timeString = dateTimeParts != null && dateTimeParts.size() >= 1 ? dateTimeParts[1] : null;
                            
                            //to check holiday
                            newDate = Date.valueOf(dateString);
                            //to check holiday

                            System.debug('newDate'+newDate);
                            
                            
                            if(dateString != null && timeString != null){
                            datePart = Date.valueOf(dateString);
                            dateTimePart = Datetime.newInstance(datePart.year(), datePart.month(), datePart.day());
                            day = dateTimePart.format('EEEE'); // Getting the day
                            // Extracting time from timeString
                            timePartString = timeString.substring(0, 8); // Extracting the time part
                            timePart = Time.newInstance(
                                Integer.valueOf(timePartString.substring(0, 2)), // Hours
                                Integer.valueOf(timePartString.substring(3, 5)), // Minutes
                                Integer.valueOf(timePartString.substring(6, 8)), // Seconds
                                0 // Milliseconds (optional, set to 0)
                            );
                                System.debug('timePart'+timePart);
                            }
                        }else{
                            continue;
                        }
                            if (appointmentInner.containsKey('productAvailibilities')) {
                                 productAvailabilitiesList = (List<Object>) appointmentInner.get('productAvailibilities');
                                 productAvailabilitiesMap = (Map<String, Object>) productAvailabilitiesList[0];
                            }
                                if (productAvailabilitiesMap.containsKey('products')) {
                                    productAvailabilities = (List<Object>) productAvailabilitiesMap.get('products');
                                }
                                    for (Object productObj : productAvailabilities) {
                                        product = (Map<String, Object>) productObj;
                                       if (product.containsKey('productEnable') && product.containsKey('prodCategory') ) { //
                                            productEnable = (Boolean) product.get('productEnable');
                                            prodCategory = (String) product.get('prodCategory');
                                       }
                                            if (productEnable) {
                                            ahlist= checkBusinessHours( isCashJourney, jsonProductData, day, timePart, prodCategory, caseId, newDate);
                                                ahwrapList.addAll(ahlist);
                                            }
                                    }
                        }
            }
            if(!ahwrapList.isEmpty()){
                ahwrap = ahwrapList[0];
                for(AfterHourWrapper ah: ahwrapList){
                    if(ah.netPriceIncludingTax > ahwrap.netPriceIncludingTax){
                        ahwrap = ah;
                    }
                }
                
            }
        }catch(Exception e){
            BLN_ExceptionLogger.captureException(e);
        }
        return ahwrap;
    }
    
 /**
*@description:This method is used to get day, time to calculate charges.
*@return decimal
*/
    public static List<AfterHourWrapper> checkBusinessHours(boolean isCashJourney, String jsonProductData, String dayOfWeek, time appointmentTime, String prodCategory ,Id caseId, Date startDate){//,time endSlotTime
        List<AfterHourWrapper> ahwrapList = new List<AfterHourWrapper>();
        //BLN_Corporate__c corporateRecord;
        Case cases;
        Id recordTypeId;
       // RecordType recordType;
        Datetime incidentDateTime;
        Date incidentDate;
        if (Schema.sObjectType.Case.isAccessible() && caseId != null) {
            cases=[select Id, BLN_BillingMethod__c, BLN_Corporate__c,BLN_IncidentDate__c from Case where Id =:caseId];
        }

        List<Decimal> netTotalPrices = new List<Decimal>();
        Id accountId;
        string productWeekDescription = '';
        List<BusinessHours> businessHour = new List<BusinessHours>();
        String customLabelValues = System.Label.BLN_ProdCategoryWindscreen;
        List<String> labelValues = customLabelValues.split(',');
        String labelBodyGlassValues = System.Label.BLN_ProdCategoryRearGlass;
        List<String> bodyGlassValues = labelBodyGlassValues.split(',');
        //Added by Shailendra : Added condition due List has no rows for assignment to SObject
        if(cases != null && cases.BLN_Corporate__c != null) {
            Id corporateId = cases.BLN_Corporate__c;

        if (Schema.sObjectType.BLN_Corporate__c.isAccessible() || Schema.sObjectType.RecordType.isAccessible()) {
            corporateRecord=[select Id,BLN_InsuranceSite__c,BLN_CorporateSite__c,BLN_CorporateLegalEntity__c,RecordTypeId,BLN_InsuranceLegalEntity__c from BLN_Corporate__c where Id =:corporateId];
            recordTypeId = corporateRecord.RecordTypeId;
         recordType = [SELECT Id, DeveloperName FROM RecordType WHERE Id = :recordTypeId];
       }
            if(isCashJourney==false && (recordType.DeveloperName == System.label.BLN_Insurance) && corporateRecord.BLN_InsuranceSite__c !=null){
            accountId = corporateRecord.BLN_InsuranceSite__c;

            }else if(isCashJourney==false && (recordType.DeveloperName == System.label.BLN_Insurance) && corporateRecord.BLN_InsuranceSite__c ==null){
                accountId = corporateRecord.BLN_InsuranceLegalEntity__c;
            }
            else if(isCashJourney==false && recordType.DeveloperName == System.label.BLN_CorporateFleet && corporateRecord.BLN_CorporateSite__c !=null){
                accountId = corporateRecord.BLN_CorporateSite__c;
            }else if(isCashJourney==false && recordType.DeveloperName == System.label.BLN_CorporateFleet && corporateRecord.BLN_CorporateSite__c ==null){
                accountId = corporateRecord.BLN_CorporateLegalEntity__c;
            }else if(isCashJourney==false && recordType.DeveloperName == System.label.BLN_SpiltBill && corporateRecord.BLN_InsuranceSite__c !=null){
                accountId = corporateRecord.BLN_InsuranceSite__c;//FOUK-10504
            }
        }
    
        List<BLN_AfterHourProductMapping__mdt> productMappingMetaData = BLN_AfterHourProductMapping__mdt.getall().values();
        Map<String, String> afterHourProductMap = new Map<String, String>();
        for (BLN_AfterHourProductMapping__mdt afterHourProduct : productMappingMetaData) {
            afterHourProductMap.put(afterHourProduct.BLN_PartDescription__c, afterHourProduct.BLN_PartNumber__c);
        }
        
        BLN_ProductResponseWrapper.ResponseProduct allProductData = (BLN_ProductResponseWrapper.ResponseProduct) System.JSON.deserialize(jsonProductData, BLN_ProductResponseWrapper.ResponseProduct.class);
        Map<String, Decimal> partNumberToNetPriceMap = new Map<String, Decimal>();
        for (BLN_ProductResponseWrapper.ResponseQuotes quoteVar : allProductData.quotes) {
            for (BLN_ProductResponseWrapper.ResponseLineItems lineItem : quoteVar.lineItems) {
                partNumberToNetPriceMap.put(lineItem.belronPartNumber, lineItem.netPriceIncludingTax);
            }
        }
        List<product2> aHproductList = new List<Product2>();
        if (Schema.sObjectType.product2.isAccessible() ) {
            aHproductList = [select Id, ProductCode,BLN_ProductCategory__c from product2 where ProductCode in: afterHourProductMap.values() WITH SECURITY_ENFORCED];
        }
        
        
        string productDayweek= '';
        if (cases != null && cases.BLN_Corporate__c != null && Schema.sObjectType.BusinessHours.isAccessible() && !isCashJourney && accountId != null) {
    
            incidentDateTime = cases.BLN_IncidentDate__c != null ? cases.BLN_IncidentDate__c : null;
            if (incidentDateTime == null) {
                throw new BLN_CustomException('Incident date missing on case');
            }
            
            incidentDate = incidentDateTime.date();
            
            // Fetch product allowance ARPs
            List<BLN_AccountRuleParameter__c> productAllowanceInsuranceArps = BLN_AccountRuleParameterUtil.getAccountRuleParameters(
                System.label.BLN_ProductAllowanceRecTypeName, accountId, incidentDate);
        
            if (productAllowanceInsuranceArps == null || productAllowanceInsuranceArps.isEmpty()) {
                businessHour = getBusinessHours(System.label.BLN_BusinessHourID);
            } else {
                businessHour = processInsuranceArps(productAllowanceInsuranceArps, accountId, incidentDate, aHproductList[0]);
            }
            
        } else if (Schema.sObjectType.BusinessHours.isAccessible()) {
                businessHour = getBusinessHours(System.label.BLN_BusinessHourID);
            }
        
        Map<String,List<Time>>businessHourMap = new Map<String,List<Time>>();
        If(businessHour!=null && !businessHour.isEmpty()){
            businessHourMap.put('Monday', new list<Time>{businessHour[0].MondayStartTime, businessHour[0].MondayEndTime});
            businessHourMap.put('Tuesday', new list<Time>{businessHour[0].TuesdayStartTime, businessHour[0].TuesdayEndTime});
            businessHourMap.put('Wednesday', new list<Time>{businessHour[0].WednesdayStartTime, businessHour[0].WednesdayEndTime});
            businessHourMap.put('Thursday', new list<Time>{businessHour[0].ThursdayStartTime, businessHour[0].ThursdayEndTime});
            businessHourMap.put('Friday', new list<Time>{businessHour[0].FridayStartTime, businessHour[0].FridayEndTime});
            businessHourMap.put('Saturday', new list<Time>{businessHour[0].SaturdayStartTime, businessHour[0].SaturdayEndTime});
        }
        
        /*to check holiday*/
        Date myDate = startDate;
        List<Holiday> holidayList = [SELECT Id, Name, IsAllDay, ActivityDate, StartTimeInMinutes FROM Holiday WITH SECURITY_ENFORCED];
        Set<Date> holidaySet = new Set<Date>();
        if(holidayList != null && holidayList.size() >0){
            for(Holiday hl :holidayList){
                holidaySet.add(hl.ActivityDate);
            }
        }

        system.debug('holidayList'+holidayList);
        system.debug('holidaySet'+holidaySet);
        

        if(holidaySet.contains(myDate)){
             system.debug('its true for holiday'+myDate);
             for (String labelValue : labelValues) {
                if(prodCategory.contains(labelValue.trim())){
                    productWeekDescription =System.label.BLN_AfterHours + System.label.BLN_WeekdaySaturday + ' ' + System.label.BLN_Repairs;
                    calculateAfterHourCharges(afterHourProductMap, partNumberToNetPriceMap, productWeekDescription, netTotalPrices, ahwrapList);
                    
                }
            }
            for (String bodyGlass : bodyGlassValues) {
                if(prodCategory.contains(bodyGlass.trim()) ){
                    productDayweek =System.label.BLN_AfterHours + System.label.BLN_WeekdaySaturday  + ' ' + System.label.BLN_BodyGlass;
                    calculateAfterHourCharges(afterHourProductMap, partNumberToNetPriceMap, productDayweek, netTotalPrices ,ahwrapList);
                }
            }
        }
        else if(dayOfWeek != null && businessHourMap.containsKey(dayOfWeek) && ( appointmentTime < businessHourMap.get(dayOfWeek)[0] || appointmentTime > businessHourMap.get(dayOfWeek)[1])){
            system.debug('businessHourMap.get(dayOfWeek)[0]'+businessHourMap.get(dayOfWeek)[0]);
            system.debug(' businessHourMap.get(dayOfWeek)[1])'+ businessHourMap.get(dayOfWeek)[1]);
            for (String labelValue : labelValues) {
            if(prodCategory.contains(labelValue.trim())){
                productWeekDescription =System.label.BLN_AfterHours + System.label.BLN_WeekdaySaturday + ' ' + System.label.BLN_Repairs;
                calculateAfterHourCharges(afterHourProductMap, partNumberToNetPriceMap, productWeekDescription, netTotalPrices, ahwrapList);
                
            }
        }
        for (String bodyGlass : bodyGlassValues) {
             if(prodCategory.contains(bodyGlass.trim()) ){
                productDayweek =System.label.BLN_AfterHours + System.label.BLN_WeekdaySaturday  + ' ' + System.label.BLN_BodyGlass;
                calculateAfterHourCharges(afterHourProductMap, partNumberToNetPriceMap, productDayweek, netTotalPrices ,ahwrapList);
            }
        }
            
        }
        else if(dayOfWeek == 'Sunday'){
            if(prodCategory == System.label.BLN_ProdCategoryWindscreen){
                productWeekDescription =System.label.BLN_AfterHours + System.label.BLN_WeekEndSunday + ' ' + System.label.BLN_Repairs;
                calculateAfterHourCharges(afterHourProductMap, partNumberToNetPriceMap, productWeekDescription, netTotalPrices,ahwrapList);
            }
            else if(prodCategory ==  System.label.BLN_ProdCategoryRearGlass){
                productDayweek =System.label.BLN_AfterHours + System.label.BLN_WeekEndSunday + ' ' + System.label.BLN_BodyGlass;
                calculateAfterHourCharges(afterHourProductMap, partNumberToNetPriceMap, productDayweek, netTotalPrices,ahwrapList);
            }
        }
        return ahwrapList;
    }                        
    
    /**
*@description:This method is used to calulate charges.
*@return void
*/
    public static void calculateAfterHourCharges(Map<String, String> afterHourProductMap, Map<String, Decimal> partNumberToNetPriceMap, String productWeekDescription, List<Decimal> netTotalPrices,List<AfterHourWrapper>ahwrapList) {
        if (afterHourProductMap.containsKey(productWeekDescription)) {
            if (partNumberToNetPriceMap.containsKey(afterHourProductMap.get(productWeekDescription))) {
                Decimal netPriceIncludingTax = partNumberToNetPriceMap.get(afterHourProductMap.get(productWeekDescription));
                netTotalPrices.add(netPriceIncludingTax);
                AfterHourWrapper ahwrap = new AfterHourWrapper();
                ahwrap.partNumber = afterHourProductMap.get(productWeekDescription);
                ahwrap.netPriceIncludingTax = netPriceIncludingTax;
                ahwrap.partDescription = productWeekDescription;
                ahwrapList.add(ahwrap);
                
            }
        }
        
    }

    private static boolean isProductAllowed(BLN_AccountRuleParameter__c allowanceArp, Product2 product) {
        return (allowanceArp.BLN_ProductAllowance__c == 'Allow All' || allowanceArp.BLN_ProductAllowance__c == 'Allow') 
                && (allowanceArp.BLN_Product__c == product.Id || (allowanceArp.BLN_ProductCategory__c != null && product.BLN_ProductCategory__c.startswith(allowanceArp.BLN_ProductCategory__c)));
    }
    private static boolean isLiabilityInsurance(BLN_AccountRuleParameter__c allowanceArp, Product2 product) {
        return allowanceArp.BLN_ProductAllowance__c == 'Pass Liability' 
                && (allowanceArp.BLN_Product__c == product.Id || (allowanceArp.BLN_ProductCategory__c != null && product.BLN_ProductCategory__c.startswith(allowanceArp.BLN_ProductCategory__c)));
    }
    private static boolean isProductNotAllowed(BLN_AccountRuleParameter__c allowanceArp, Product2 product) {
        return (allowanceArp.BLN_ProductAllowance__c == 'Do Not Show' || allowanceArp.BLN_ProductAllowance__c == 'Do Not Show All' )
                && (allowanceArp.BLN_Product__c == product.Id || (allowanceArp.BLN_ProductCategory__c != null && product.BLN_ProductCategory__c.startswith(allowanceArp.BLN_ProductCategory__c)));
    }
    private static  List<BusinessHours> setBusinessHoursForAccount(Id accountId, Date incidentDate) {
        List<BLN_AccountRuleParameter__c> accountRuleParameters = BLN_AccountRuleParameterUtil.getAccountRuleParameters(System.label.BLN_AfterHours, accountId, incidentDate);
        List<BusinessHours> businessHour = new List<BusinessHours>();
        return (accountRuleParameters != null && !accountRuleParameters.isEmpty() && accountRuleParameters[0].BLN_AfterHours__c != null) ? getBusinessHours(accountRuleParameters[0].BLN_AfterHours__c) : getBusinessHours(System.label.BLN_BusinessHourID);
    }



    // Helper method to handle liability insurance case
    private static  List<BusinessHours> handleLiabilityInsurance(Product2 ahProduct, Date incidentDate) {
        if (recordType.DeveloperName == System.label.BLN_SpiltBill && corporateRecord.BLN_CorporateSite__c != null) {
            List<BLN_AccountRuleParameter__c> productAllowanceCorpArps = BLN_AccountRuleParameterUtil.getAccountRuleParameters(
                System.label.BLN_ProductAllowanceRecTypeName, corporateRecord.BLN_CorporateSite__c, incidentDate);
    
            if (productAllowanceCorpArps != null && !productAllowanceCorpArps.isEmpty()) {
                return processCorpSiteArps(productAllowanceCorpArps, corporateRecord.BLN_CorporateSite__c, incidentDate, ahProduct);
            } else {
                return getBusinessHours(System.label.BLN_BusinessHourID);
            }
        } else {
            return getBusinessHours(System.label.BLN_BusinessHourID);
        }
    }

// Helper method to process ARPs for product allowance
private static List<BusinessHours> processInsuranceArps(List<BLN_AccountRuleParameter__c> productAllowanceInsuranceArps, String accountId, Date incidentDate, Product2 ahProduct) {
    boolean checkAllowInsuranceARP = false;
    boolean checkPassLiabilityInsurance = false;

    for (BLN_AccountRuleParameter__c allowanceArp : productAllowanceInsuranceArps) {
        if (isProductAllowed(allowanceArp, ahProduct)) {
            checkAllowInsuranceARP = true;
            break;
        } else if (isLiabilityInsurance(allowanceArp, ahProduct)) {
            checkPassLiabilityInsurance = true;
            break;
        } else if (isProductNotAllowed(allowanceArp, ahProduct)) {
            return null; // Early return if product is not allowed
        }
    }
    
    
    // Decide business hour based on checks
    if (checkAllowInsuranceARP) {
        return setBusinessHoursForAccount(accountId, incidentDate);
    } else if (checkPassLiabilityInsurance) {
        return handleLiabilityInsurance(ahProduct, incidentDate);
    } else {
        return getBusinessHours(System.label.BLN_BusinessHourID);
    }
}
// Helper method to process ARPs for product allowance and liability insurance
private static List<BusinessHours> processCorpSiteArps(List<BLN_AccountRuleParameter__c> productAllowanceCorpArps, String accountId, Date incidentDate, Product2 ahProduct) {
    boolean checkAllowCorpARP = false;
    boolean checkPassLiabilityCorp = false;

    for (BLN_AccountRuleParameter__c allowanceArp : productAllowanceCorpArps) {
        // If product is allowed, set the flag to true
        if (isProductAllowed(allowanceArp, ahProduct)) {
            checkAllowCorpARP = true;
            break;
        }
        // If liability insurance is applicable, set the flag to true
        else if (isLiabilityInsurance(allowanceArp, ahProduct)) {
            checkPassLiabilityCorp = true;
            break;
        }
        // If product is not allowed, return null (early exit)
        else if (isProductNotAllowed(allowanceArp, ahProduct)) {
            return null;
        }
    }

    // Decide business hour based on checks
    if (checkAllowCorpARP) {
        return setBusinessHoursForAccount(accountId, incidentDate);
    } else if (checkPassLiabilityCorp) {
        return getBusinessHours(System.label.BLN_BusinessHourID);  
    } else {
        return getBusinessHours(System.label.BLN_BusinessHourID);
    }
}
    

    
     /**
*@description:This method is used to get businessHours.
*@return List<BusinessHours>
*/ //FOUK-10504
    public static List<BusinessHours> getBusinessHours(Id businessHourName){
        List<BusinessHours> businessHour = new List<BusinessHours>();
        businessHour = [
                    SELECT Id, Name, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, 
                    WednesdayStartTime, WednesdayEndTime, ThursdayStartTime, ThursdayEndTime, 
                    FridayStartTime, FridayEndTime,SaturdayStartTime, SaturdayEndTime,SundayStartTime,SundayEndTime
                    FROM BusinessHours 
                    WHERE Id =: businessHourName LIMIT 1
                ];
        return businessHour;
    }

    public class AfterHourWrapper {
        @auraEnabled
        public  string partNumber;
        
        @auraEnabled
        public decimal netPriceIncludingTax; 
        
        @auraEnabled
        public string partDescription;
        
    }
    public class BLN_CustomException extends Exception {}

}