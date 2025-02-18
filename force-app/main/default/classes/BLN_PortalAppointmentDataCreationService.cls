/**@description : The Handler class for Remedy Webservice (FOR PORTAL)
*  @author: 
*  @Story: FOUK-4342
*  @CreatedDate: 28/05/2024
*/

public without sharing class BLN_PortalAppointmentDataCreationService {
    public static DateTime earliestStartTime;
    public static List<OrderItem> orderItemList = new List<OrderItem>();
    public static Map<String, WorkType> workTypeMap = new Map<String, WorkType>();
    public static String workOrderWorkTypeName;
    public static BLN_BU__mdt bumetadata = new BLN_BU__mdt();
    
    public static TimeSlotWrapper slotWrapper = new TimeSlotWrapper();
    public static Map<String, Decimal> productQuantityMap = new Map<String, Decimal>();
    public static Map<String, String> productOLIKeyMap = new Map<String, String>();//Newly added
    public static BLN_WeatherGuardAppointmentConfiguration__mdt weatherGuardMetadata = new BLN_WeatherGuardAppointmentConfiguration__mdt();
    public static String prodCodeFromMetadata;
    public static String prodCategoryFromMetadata;
    public static Boolean weatherGuardOnSA = False;
    public static ServiceTerritory serviceTerritory = new ServiceTerritory();
    public static Case caseObj = new Case();

    /*
        @description : This method is used to return TimeSlotWrapper.
        @param : List<ProductData> productList, String caseId, DateTime earliestAvailableDate, String locationId
        @retun : TimeSlotWrapper
    */
    @auraEnabled
    public static TimeSlotWrapper prepData(List<ProductData> productList, String caseId, DateTime earliestAvailableDate, String locationId) {
        /* line removed by service
        for(ProductData prodObj : productList){
             productQuantityMap.put(prodObj.productCode, prodObj.quantity);
         }*/

        earliestStartTime = earliestAvailableDate;
        caseObj = BLN_PortalHandlerWebservice.getCaseFromId(caseId);
        serviceTerritory = BLN_PortalHandlerWebservice.getServiceTerritoryFromGUID(locationId);
        bumetadata = BLN_PortalHandlerWebservice.getBUMetadata(System.label.BLN_UnitedKingdom);
        
        Set<String> productCodeSet = new Set<String>();
        List<Product2> productsList = new List<Product2>();//added
        Set<String> excludedProductCategory = new Set<String>();//added
        Set<String> excludedProduct = new Set<String>();//added

        /*removed by service
        for(ProductData prodObj : productList){
            if(String.isNotBlank(prodObj.productCode)){
                productCodeSet.add(prodObj.productCode);
            }
        }*/
       //added by service
        for (Integer i = 0; i < productList.size(); i++) {
            productQuantityMap.put(productList[i].productCode + '-' + i, productList[i].quantity);
            productOLIKeyMap.put(productList[i].productCode + '-' + i, productList[i].productOLIKey);
            productCodeSet.add(productList[i].productCode);
        }
        //added by service
         if(productCodeSet != null){
            productsList = BLN_PortalHandlerWebservice.getProductByProductCode(productCodeSet);
        }
        if(productsList!= null && String.isNotBlank(serviceTerritory.BLN_ExcludedProductCategory__c)){
            for(String ecProdCat : serviceTerritory.BLN_ExcludedProductCategory__c.split(';')){
                excludedProductCategory.add(ecProdCat);
            }
        }
        if(productsList!= null && String.isNotBlank(serviceTerritory.BLN_ExcludedProduct__c)){
            for(String ecProd : serviceTerritory.BLN_ExcludedProduct__c.split(';')){
                excludedProduct.add(ecProd);
            }
        }
        if(productsList != null){
            for(Product2 prodObj : productsList){
                if(containsOrBeginWith(prodObj.BLN_ProductCategory__c,excludedProductCategory) || containsOrBeginWith(prodObj.ProductCode,excludedProduct)){
                    TimeSlotWrapper timeSlotWrap = new TimeSlotWrapper();
                    timeSlotWrap.appointmentId = '';
                    timeSlotWrap.msg = 'One of the product or product category is excluded from the Territory';
                    timeSlotWrap.isSuceess = false;
                    return timeSlotWrap;
                }
            }

       /* removed by service
        if(productCodeSet.size() > 0){
            List<Product2> productsList = BLN_PortalHandlerWebservice.getProductByProductCode(productCodeSet);
            Set<String> excludedProductCategory = new Set<String>();
            Set<String> excludedProduct = new Set<String>();
            if(String.isNotBlank(serviceTerritory.BLN_ExcludedProductCategory__c)){
                for(String ecProdCat : serviceTerritory.BLN_ExcludedProductCategory__c.split(';')){
                    excludedProductCategory.add(ecProdCat);
                }
            }
            if(String.isNotBlank(serviceTerritory.BLN_ExcludedProduct__c)){
                for(String ecProd : serviceTerritory.BLN_ExcludedProduct__c.split(';')){
                    excludedProduct.add(ecProd);
                }
            }

            for(Product2 prodObj : productsList){
                if((prodObj.BLN_ProductCategory__c != null && excludedProductCategory.contains(prodObj.BLN_ProductCategory__c)) || 
                (prodObj.Name != null && excludedProduct.contains(prodObj.Name))) {
                    TimeSlotWrapper timeSlotWrap = new TimeSlotWrapper();
                    timeSlotWrap.appointmentId = '';
                    timeSlotWrap.msg = 'One of the product or product category is excluded from the Territory';
                    timeSlotWrap.isSuceess = false;
                    return timeSlotWrap;
                }
            }
*/
            try{
                if(productsList.size() > 0) {
                    BLN_PortalAppointmentDataCreationService.createWO(caseObj, productsList);
                }
            } catch(exception ex) {
                BLN_ExceptionLogger.captureException(ex);
                string jsonResponse = '{"response": {"status": "Failure", "message": Something went wrong, please check with Salesforce System Administrator"}}';
                TimeSlotWrapper timeSlotWrap = new TimeSlotWrapper();
                timeSlotWrap.appointmentId = '';
                timeSlotWrap.msg = jsonResponse;
                timeSlotWrap.isSuceess = false;
                return timeSlotWrap;
            }
        }else {
            TimeSlotWrapper timeSlotWrap = new TimeSlotWrapper();
            timeSlotWrap.appointmentId = '';
            timeSlotWrap.msg = 'Product is not available';
            timeSlotWrap.isSuceess = false;
            return timeSlotWrap;
        }
        return slotWrapper;
    }
    /*
@description : This method is used to check if product begins/contain/equal to excludedlist.
@param : String stringItem, Set<String> listToFilter
@author : Akhilesh Kumar Saini
@CreatedDate: 26/11/2024
*/
    public static Boolean containsOrBeginWith(String stringItem, Set<String> listToFilter){
        Boolean isFound=false;
        stringItem=stringItem.trim();
        for(String searchStr : listToFilter){
            searchStr=searchStr.trim();
            Boolean isContain=false;
            Boolean isBegin=false;
            if(searchStr.indexOf('%') == 0){isContain=true;}
            else if(searchStr.indexOf('%') > 0){isBegin=true;}
            searchStr = searchStr.replace('%', '');

            if(isContain && stringItem.containsIgnoreCase(searchStr)){
                isFound = true;break;
            }
            else if(isBegin && stringItem.startsWithIgnoreCase(searchStr)){
                isFound = true;break;
            }
            else if(stringItem.equalsIgnoreCase(searchStr)){
                isFound = true;break;
            }
        }
        return isFound;
    }        
    /*
        @description : This method is used to Create WO WOLI and SA.
        @param : Case caseObj, List<Product2> productList
    */
    public static void createWO(Case caseObj, List<Product2> prodList){
        Set<String> workTypeName = new Set<String>();
        Pricebook2 stdPriceBook = BLN_PortalHandlerWebservice.getStandardPriceBook(True, System.label.BLN_StandardPriceBook);
        //System.debug('serviceTerritory---140---'+serviceTerritory);
        Set<String> workTypeNames = getWorkType(prodList, caseObj, serviceTerritory);

        for (Product2 prodObj : prodList){
            if(prodObj.BLN_BusinessUnitSpecificBranchOnly__c == True && serviceTerritory.BLN_Type__c == System.label.BLN_Mobile){
                slotWrapper.appointmentId = '';
                slotWrapper.msg = 'One or more products is only supported for branch appointments';
                slotWrapper.isSuceess = false;
                return;
            }
        }
        
        if(String.isNotBlank(serviceTerritory.BLN_ExcludedWorkType__c)){
            Set<String> excludedWorkType = new Set<String>(serviceTerritory.BLN_ExcludedWorkType__c.split(';'));
            for(String stringItem : workTypeNames){
                if(containsOrBeginWith(stringItem, excludedWorkType)){
                    slotWrapper.appointmentId = '';
                    slotWrapper.msg = 'One of the worktype is excluded from the Territory';
                    slotWrapper.isSuceess = false;
                    return;
                }
            }
        }

        workTypeName.add(workOrderWorkTypeName);
        List<WorkType> workType = BLN_PortalHandlerWebservice.getWorkTypeRec(workTypeName);

        List<WorkOrder> existingWorkOrder = BLN_PortalHandlerWebservice.getWorkOrderFromCase(caseObj.Id);
        WorkOrder workOrder = new WorkOrder();
        if(existingWorkOrder==null){
            if(String.isNotBlank(caseObj.Id)){
                workOrder.AccountId = String.isNotBlank(caseObj.AccountId) ? caseObj.AccountId : Null;
                workOrder.CaseId = String.isNotBlank(caseObj.Id) ? caseObj.Id : Null;
            }
            workOrder.ServiceTerritoryId = String.isNotBlank(serviceTerritory.Id) ? serviceTerritory.Id : Null;
            workOrder.Status = System.label.BLN_New;
            workOrder.Subject = System.label.BLN_WorkOrderFor + ' ' + workType[0].Name;
            workOrder.Description = System.label.BLN_WorkOrderFor + ' ' + workType[0].Name;
            workOrder.WorkTypeId = workType != null ? workType[0].Id : Null;//added by service
           // workOrder.WorkTypeId = workType.size() > 0 ? workType[0].Id : Null;
            workOrder.Pricebook2Id = String.isNotBlank(stdPriceBook.Id) ? stdPriceBook.id : Null;
        } else {
            workOrder = existingWorkOrder[0];
            workOrder.WorkTypeId = workType != null ? workType[0].Id : Null;//added by service
            //workOrder.WorkTypeId = workType.size() > 0 ? workType[0].Id : Null;
        }

        if(Schema.sObjectType.WorkOrder.isCreateable() && Schema.sObjectType.WorkOrder.isUpdateable()){
            UPSERT workOrder;
        }
        if(workTypeNames.size() == 0){
            slotWrapper.msg = label.BLN_AppointmentFailMsg;
            slotWrapper.isSuceess = false;
            return;
        }
            List<WorkType> workTypeList = BLN_PortalHandlerWebservice.getWorkTypeRec(workTypeNames);
            List<WorkOrderLineItem> woliList = new List<WorkOrderLineItem>();
            List<ServiceAppointment> saList = new List<ServiceAppointment>();
            WorkOrder workOrderObj = BLN_PortalHandlerWebservice.getWorkOrderById(workOrder.Id);
            decimal specificAssistDuration = 0;
            if(prodList.size() > 0){
                for (Product2 durationCal : prodList){
                    specificAssistDuration += durationCal.BLN_BusinessUnitSpecificAssistDuration__c != Null ? durationCal.BLN_BusinessUnitSpecificAssistDuration__c : 0;
                }
            }
        if(workTypeList != null){
            for(WorkType eachWorkType : workTypeList){
                String isAssistNeedToCreate = '';
                if(eachWorkType.Name == System.label.BLN_Assist){
                    isAssistNeedToCreate = BLN_DurationCalculation.durationCal(eachWorkType, serviceTerritory, new WorkOrderLineItem(), specificAssistDuration, bumetadata, workOrderObj.WorkType.Name);
                }
                if(isAssistNeedToCreate != System.label.BLN_NotNeeded){
                    workTypeMap.put(eachWorkType.Id, eachWorkType);
                    woliList.add(BLN_PortalAppointmentDataCreationService.generateWoLi(workOrder, eachWorkType));
                }
            }
            
            if(woliList.size() > 0 && Schema.sObjectType.WorkOrderLineItem.isCreateable()){
                INSERT woliList;
            }
        }
            List<PriceBookEntry> priceBookEntryList = BLN_PortalHandlerWebservice.getPriceBookEntryMap(prodList);
            Map<String, PriceBookEntry> priceBookEntryMap = new Map<String, PriceBookEntry>();
            Boolean isADASProd = False;
            for(Product2 eachProd : prodList){
                if(eachProd.BLN_ADASRecalibrationNeeded__c == True){
                    isADASProd = True;
                }

            if(priceBookEntryList != null && !priceBookEntryList.isEmpty()){
                for(PriceBookEntry eachPriceBook : priceBookEntryList){
                    if(eachProd.Id == eachPriceBook.Product2Id){
                        priceBookEntryMap.put(eachProd.Id, eachPriceBook);
                    }
                }
            }
        }
            List<ProductRequired> productReqList = new List<ProductRequired>();
            Map<String, List<ProductRequired>> parentChildsWoliMap = new Map<String, List<ProductRequired>>();

            weatherGuardMetadata = BLN_PortalHandlerWebservice.getWeatherGuardProductMetadata();
            prodCodeFromMetadata = weatherGuardMetadata.BLN_ProductCode__c;
            prodCategoryFromMetadata = weatherGuardMetadata.BLN_ProductCategory__c;

            for(WorkOrderLineItem eachWoli : woliList){
                for(Product2 prodObj : prodList){
                    if(weatherGuardMetadata != null && String.isNotBlank(prodCodeFromMetadata) && String.isNotBlank(prodCategoryFromMetadata) && prodObj.ProductCode == prodCodeFromMetadata && prodObj.BLN_ProductCategory__c == prodCategoryFromMetadata){
                        weatherGuardOnSA = True;
                    }
                }
            }
        for(WorkOrderLineItem eachWoli : woliList){
            for (Integer i = 0; i < prodList.size(); i++) {
                ProductRequired prodReq = generateProductRequired(eachWoli, prodList[i], workType[0], serviceTerritory, productQuantityMap, productOLIKeyMap, i);
                    if(String.isNotBlank(prodReq.Product2Id)){
                        productReqList.add(prodReq);
                        List<ProductRequired> productReq = new List<ProductRequired>();
                        productReq = parentChildsWoliMap.containsKey(eachWoli.Id) ? parentChildsWoliMap.get(eachWoli.Id) : new List<ProductRequired>();
                        productReq.add(prodReq);
                        parentChildsWoliMap.put(eachWoli.Id, productReq);
                    }
                }
            }
            if(productReqList.size() > 0 && Schema.sObjectType.ProductRequired.isCreateable()){
                INSERT productReqList;
            }
            List<WorkOrderLineItem> woliToUpdate = new List<WorkOrderLineItem>();
            List<Skill> skillList = BLN_PortalHandlerWebservice.getSkills();
            Map<String, String> skillMap = new Map<String, String>();
            for(Skill skillObj : skillList){
                skillMap.put(skillObj.DeveloperName, skillObj.Id);
            }
            List<SkillRequirement> skillRequirementList = new List<SkillRequirement>();
            for(WorkOrderLineItem parent : woliList){
                skillRequirementList = BLN_GenerateSkillRequirement.createSkillRequirement(parent, skillMap, caseObj, isADASProd, prodList, workTypeMap, serviceTerritory);
                if(parentChildsWoliMap.containsKey(parent.Id)){
                    for(ProductRequired child : parentChildsWoliMap.get(parent.Id)){
                        parent.BLN_ProductFittingDuration__c += child.BLN_Duration__c != Null ? child.BLN_Duration__c : 0;
                    }
                    woliToUpdate.add(parent);
                }
            }
            if(woliToUpdate.size() > 0 && Schema.sObjectType.WorkOrderLineItem.isUpdateable()){
                UPDATE woliToUpdate;
            }

            if(skillRequirementList.size() > 0 && Schema.sObjectType.SkillRequirement.isCreateable()){
                INSERT skillRequirementList;
            }
            if(woliList.size() > 0){
                for(WorkOrderLineItem woliObj : woliList){
                    saList.add(BLN_PortalAppointmentDataCreationService.generateSA(woliObj, specificAssistDuration, workOrderObj.WorkType.Name, weatherGuardOnSA));
                }
            }
            
            if(saList.size() > 0 && Schema.sObjectType.ServiceAppointment.isCreateable()){
            // for(ServiceAppointment sa: saList ){
            //     sa.OwnerId ='0057Z00000DoZXRQA3';
            // }
                INSERT saList;
            }
            BLN_LeadTimeFieldCalculation.setLeadTimeFields(saList, /*isDropOff,*/ serviceTerritory, workTypeNames, earliestStartTime, caseObj.Id);
            ServiceAppointment stockCollectSA = new ServiceAppointment();
            ServiceAppointment assistSA = new ServiceAppointment();
            ServiceAppointment mainSA = new ServiceAppointment();
            ServiceAppointment replacementSA = new ServiceAppointment();
            ServiceAppointment recalibrationSA = new ServiceAppointment();

            for(ServiceAppointment serviceAppObj : saList){
                if(workTypeMap.get(serviceAppObj.WorkTypeId).Name == System.label.BLN_StockCollect){
                    stockCollectSA = serviceAppObj;
                }else if(workTypeMap.get(serviceAppObj.WorkTypeId).Name == System.label.BLN_Assist){
                    assistSA = serviceAppObj;
                } else if(serviceTerritory.BLN_SplitReplaceAndRecalibration__c == TRUE && (workTypeMap.get(serviceAppObj.WorkTypeId).Name == System.label.BLN_Replacements || workTypeMap.get(serviceAppObj.WorkTypeId).Name == System.label.BLN_WarrantyReplacement)){
                    replacementSA = serviceAppObj;
                    mainSA = serviceAppObj;
                } else if(serviceTerritory.BLN_SplitReplaceAndRecalibration__c == TRUE && workTypeMap.get(serviceAppObj.WorkTypeId).Name == System.label.BLN_Recalibration){
                    recalibrationSA = serviceAppObj;
                } else {
                    mainSA = serviceAppObj;
                }   
            }
            if(String.isNotBlank(stockCollectSA.Id) && String.isNotBlank(mainSA.Id)){
                mainAndStockOrAssistSADependency(stockCollectSA.Id, mainSA.Id, True, System.label.BLN_StartAfterFinishAndSameDay);
            }
            if(String.isNotBlank(assistSA.Id) && String.isNotBlank(mainSA.Id)){
                mainAndStockOrAssistSADependency(assistSA.Id, mainSA.Id, False, System.label.BLN_Dependency);
            }
            if(String.isNotBlank(replacementSA.Id) && String.isNotBlank(recalibrationSA.Id)){
                mainAndStockOrAssistSADependency(replacementSA.Id, recalibrationSA.Id, False, System.label.BLN_StartAfterFinish);
            }
            String appointmentId = '';
            for(ServiceAppointment serviceAppObj : saList){
                if((workTypeMap.get(serviceAppObj.WorkTypeId).Name != System.label.BLN_StockCollect && workTypeMap.get(serviceAppObj.WorkTypeId).Name != System.label.BLN_Assist && serviceTerritory.BLN_SplitReplaceAndRecalibration__c == true) && (workTypeMap.get(serviceAppObj.WorkTypeId).Name == System.label.BLN_Replacements || workTypeMap.get(serviceAppObj.WorkTypeId).Name == System.label.BLN_WarrantyReplacement || workType[0].Name == System.label.BLN_Recalibration)){
                    appointmentId = serviceAppObj.Id;
            } else if(serviceTerritory.BLN_SplitReplaceAndRecalibration__c == false && (workTypeMap.get(serviceAppObj.WorkTypeId).Name != System.label.BLN_StockCollect && workTypeMap.get(serviceAppObj.WorkTypeId).Name != System.label.BLN_Assist)){
                appointmentId = serviceAppObj.Id;
            }
        }
        if(String.isNotBlank(appointmentId) && appointmentId != null){
            slotWrapper.appointmentId = appointmentId;
            slotWrapper.msg = label.BLN_AppointmentSuccessMsg;
            slotWrapper.isSuceess = true;
        }
    }
    
    /*
        @description : This method is used to Populate proper work type on WO WOLI and SA.
        @param : List<Product2> productList, Case caseObj, ServiceTerritory serviceTerritory
        @retun : return WorkType Names Set
    */
    public static Set<String> getWorkType(List<Product2> productList, Case caseObj, ServiceTerritory serviceTerritory){
        Time leadTime = earliestStartTime.Time();
        Set<String> workType = new Set<String>();
        Datetime dateToday = System.Today();
        Date todayDate = Date.valueOf(dateToday);
        Time eightAM = dateToday.Time().addHours(Integer.valueOf(System.label.BLN_ConfigTime));
        Date leadDate = Date.valueOf(earliestStartTime);
        String dayOfWeek = dateToday.format(System.label.BLN_EEEEText);
        TimeSlot timeSlot = BLN_PortalHandlerWebservice.getEndTimeFromTimeSlot(serviceTerritory.OperatingHoursId, dayOfWeek);
        
        DateTime currentDateTime = System.now();
        Time currentTime = currentDateTime.Time();
        Time operatingHourEnd = timeSlot.EndTime;
        Boolean isAdasChecked = FALSE;
        Boolean isStockable = FALSE;
        for(Product2 prod: productList){
            if(prod.BLN_ADASRecalibrationNeeded__c == TRUE){
                isAdasChecked = TRUE;
            }
            if(prod.BLN_ProductStockable__c == TRUE){
                isStockable = TRUE;
            }
        }
        Set<String> secondryWorkType = new Set<String>();
        for(Product2 prod: productList){
            //Stock Collect
            // leadTime.addMinutes(5) 5 minutes is buffer for stock collect for currect time
            if(serviceTerritory.BLN_Type__c == System.label.BLN_Mobile && isStockable == TRUE && (
                (leadDate == todayDate && leadTime.addMinutes(5) >= currentTime && leadTime <= operatingHourEnd) ||
                (leadDate > todayDate && leadTime > eightAM && leadTime <= operatingHourEnd))){
                    secondryWorkType.add(System.label.BLN_StockCollect);
            }

            //Assist
            if(prod.BLN_NumberofTechnicianNeeded__c > 1) {
                secondryWorkType.add(System.label.BLN_Assist);
            }
        }
        Map<Integer, Set<String>> workTypePriorityMap = new Map<Integer, Set<String>>();
        Map<Integer, String> workTypePriorityMapForWO = new Map<Integer, String>();
        for(Product2 prod: productList){
            //Warranty Replacement & Recalibration
            if(isAdasChecked == TRUE && String.isNotBlank(caseObj.Id) && caseObj.BLN_SubType__c == System.label.BLN_Warranty) {
                workOrderWorkTypeName = System.label.BLN_WarrantyReplacementRecalibration;
                workTypePriorityMapForWO.put(1, workOrderWorkTypeName);
                if(String.isNotBlank(serviceTerritory.Id) && serviceTerritory.BLN_SplitReplaceAndRecalibration__c == TRUE) {
                    workType = new Set<String>();
                    workType.add(System.label.BLN_WarrantyReplacement);
                    workType.add(System.label.BLN_Recalibration);
                    workTypePriorityMap.put(1, workType);
                } else {
                    workType.add(System.label.BLN_WarrantyReplacementRecalibration);
                    workTypePriorityMap.put(1, workType);
                }
            }
            //Warranty Replacement
            else if(String.isNotBlank(caseObj.Id) && caseObj.BLN_SubType__c == System.label.BLN_Warranty) {
                workType = new Set<String>();
                workOrderWorkTypeName = System.label.BLN_WarrantyReplacement;
                workTypePriorityMapForWO.put(2, workOrderWorkTypeName);
                workType.add(System.label.BLN_WarrantyReplacement);
                workTypePriorityMap.put(2, workType);
            }
            //Side & Rear Replacement
            else if((prod.BLN_ProductCategory__c !=null) &&
                    (prod.BLN_ProductCategory__c == System.label.BLN_SideGlass || prod.BLN_ProductCategory__c == System.label.BLN_RearGlass ||
                    (String.valueOf(prod.BLN_ProductCategory__c).startsWith('12')) ||
                    (String.valueOf(prod.BLN_ProductCategory__c).startsWith('13')) ||
                    (String.valueOf(prod.BLN_ProductCategory__c).startsWith('262'))||
                    (String.valueOf(prod.BLN_ProductCategory__c).startsWith('263')) ||
                    (String.valueOf(prod.BLN_ProductCategory__c).startsWith('242')) ||
                    (String.valueOf(prod.BLN_ProductCategory__c).startsWith('243')))||
                    ((String.valueOf(prod.BLN_ProductCategory__c) == '5120') ||
                    (String.valueOf(prod.BLN_ProductCategory__c) == '5220') ||
                    (String.valueOf(prod.BLN_ProductCategory__c) == '5320') ||
                    (String.valueOf(prod.BLN_ProductCategory__c) == '5420') ||
                    (String.valueOf(prod.BLN_ProductCategory__c) == '5130') ||
                    (String.valueOf(prod.BLN_ProductCategory__c) == '5230') ||
                    (String.valueOf(prod.BLN_ProductCategory__c) == '5430') ||
                    (String.valueOf(prod.BLN_ProductCategory__c) == '5330'))) {
                        workType = new Set<String>();
                workOrderWorkTypeName = System.label.BLN_SideRearReplacementWT;
                workTypePriorityMapForWO.put(3, workOrderWorkTypeName);
                workType.add(System.label.BLN_SideRearReplacementWT);
                workTypePriorityMap.put(3, workType);
            }
            //Replacement & Recalibration
            else if((prod.BLN_ProductCategory__c != null) && (prod.BLN_ProductCategory__c == System.label.BLN_Sunroof ||
                (prod.BLN_ProductCategory__c == System.label.BLN_Windscreen ||
                (String.valueOf(prod.BLN_ProductCategory__c).startsWith('11')) ||
                (String.valueOf(prod.BLN_ProductCategory__c).startsWith('261')) ||
                (String.valueOf(prod.BLN_ProductCategory__c).startsWith('24'))) ||
                (String.valueOf(prod.BLN_ProductCategory__c).startsWith('20')) ||
                ((String.valueOf(prod.BLN_ProductCategory__c) == '5110') ||
                (String.valueOf(prod.BLN_ProductCategory__c) == '5210') ||
                (String.valueOf(prod.BLN_ProductCategory__c) == '5310') ||
                (String.valueOf(prod.BLN_ProductCategory__c) == '5410') ||
                (String.valueOf(prod.BLN_ProductCategory__c) == '5450') ||
                (String.valueOf(prod.BLN_ProductCategory__c) == '5810') ||
                (String.valueOf(prod.BLN_ProductCategory__c) == '2510')))) {
                    workType = new Set<String>();
                if(isAdasChecked == FALSE) {
                    workOrderWorkTypeName = System.label.BLN_Replacements;
                    workTypePriorityMapForWO.put(4, workOrderWorkTypeName);
                    workType.add(System.label.BLN_Replacements);
                    workTypePriorityMap.put(4, workType);
                } else if(isAdasChecked == TRUE && String.isNotBlank(serviceTerritory.Id) && serviceTerritory.BLN_SplitReplaceAndRecalibration__c == TRUE){
                    workOrderWorkTypeName = System.label.BLN_ReplaceAndRecal;
                    workTypePriorityMapForWO.put(5, workOrderWorkTypeName);
                    workType.add(System.label.BLN_Replacements);
                    workType.add(System.label.BLN_Recalibration);
                    workTypePriorityMap.put(5, workType);
                }else if(isAdasChecked == TRUE && String.isNotBlank(serviceTerritory.Id) && serviceTerritory.BLN_SplitReplaceAndRecalibration__c == FALSE) {
                    workOrderWorkTypeName = System.label.BLN_ReplaceAndRecal;
                    workTypePriorityMapForWO.put(5, workOrderWorkTypeName);
                    workType.add(System.label.BLN_ReplaceAndRecal);
                    workTypePriorityMap.put(5, workType);
                }
            }
            //Recalibration
            else if(isAdasChecked == TRUE) {
                workType = new Set<String>();
                workOrderWorkTypeName = System.label.BLN_Recalibration;
                workTypePriorityMapForWO.put(6, workOrderWorkTypeName);
                workType.add(System.label.BLN_Recalibration);
                workTypePriorityMap.put(6, workType);
            }
            //Repair
            else if((prod.BLN_ProductCategory__c !=null) && (prod.BLN_ProductCategory__c == System.label.BLN_Repair || String.valueOf(prod.BLN_ProductCategory__c).startsWith('14'))) {
                workType = new Set<String>();
                workOrderWorkTypeName = System.label.BLN_Repair;
                workTypePriorityMapForWO.put(7, workOrderWorkTypeName);
                workType.add(System.label.BLN_Repair);
                workTypePriorityMap.put(7, workType);
            }
        }
        /*for(Product2 prod: productList){
            //Stock Collect
            if(serviceTerritory.BLN_Type__c == System.label.BLN_Mobile && isStockable == TRUE && (
                (leadDate == todayDate && leadTime.addMinutes(5) >= currentTime && leadTime <= operatingHourEnd) ||
                (leadDate > todayDate && leadTime > eightAM && leadTime <= operatingHourEnd))){
                      secondryWorkType.add(System.label.BLN_StockCollect);
            }

            //Assist             
            if(prod.BLN_NumberofTechnicianNeeded__c > 1) {
                workType.add(System.label.BLN_Assist);
            }
            //Warranty Replacement & Recalibration
            if(isAdasChecked == TRUE && String.isNotBlank(caseObj.Id) && caseObj.BLN_SubType__c == System.label.BLN_Warranty) {
                workOrderWorkTypeName = System.label.BLN_WarrantyReplacementRecalibration;
                if(String.isNotBlank(serviceTerritory.Id) && serviceTerritory.BLN_SplitReplaceAndRecalibration__c == TRUE) {
                    workType.add(System.label.BLN_WarrantyReplacement);
                    workType.add(System.label.BLN_Recalibration);
                } else {
                    workType.add(System.label.BLN_WarrantyReplacementRecalibration);
                }
            }
            //Warranty Replacement
            else if(String.isNotBlank(caseObj.Id) && caseObj.BLN_SubType__c == System.label.BLN_Warranty) {workOrderWorkTypeName = System.label.BLN_WarrantyReplacement;workType.add(System.label.BLN_WarrantyReplacement);
            }
            //Side & Rear Replacement
            else if((prod.BLN_ProductCategory__c !=null) &&
                    (prod.BLN_ProductCategory__c == System.label.BLN_SideGlass || prod.BLN_ProductCategory__c == System.label.BLN_RearGlass || 
                    (String.valueOf(prod.BLN_ProductCategory__c).startsWith('12')) ||
                    (String.valueOf(prod.BLN_ProductCategory__c).startsWith('13')) ||
                    (String.valueOf(prod.BLN_ProductCategory__c).startsWith('262'))||
                    (String.valueOf(prod.BLN_ProductCategory__c).startsWith('263')) ||
                    (String.valueOf(prod.BLN_ProductCategory__c).startsWith('242')) ||
                    (String.valueOf(prod.BLN_ProductCategory__c).startsWith('243')))|| 
                    ((String.valueOf(prod.BLN_ProductCategory__c) == '5120') ||
                    (String.valueOf(prod.BLN_ProductCategory__c) == '5220') ||
                    (String.valueOf(prod.BLN_ProductCategory__c) == '5320') ||
                    (String.valueOf(prod.BLN_ProductCategory__c) == '5420') ||
                    (String.valueOf(prod.BLN_ProductCategory__c) == '5130') ||
                    (String.valueOf(prod.BLN_ProductCategory__c) == '5230') ||
                    (String.valueOf(prod.BLN_ProductCategory__c) == '5430') ||
                    (String.valueOf(prod.BLN_ProductCategory__c) == '5330'))) {
                workOrderWorkTypeName = System.label.BLN_SideRearReplacementWT;
                workType.add(System.label.BLN_SideRearReplacementWT);
            }
            //Replacement & Recalibration
            else if((prod.BLN_ProductCategory__c != null) && (prod.BLN_ProductCategory__c == System.label.BLN_Sunroof || 
                (prod.BLN_ProductCategory__c == System.label.BLN_Windscreen ||
                (String.valueOf(prod.BLN_ProductCategory__c).startsWith('11')) ||
                (String.valueOf(prod.BLN_ProductCategory__c).startsWith('261')) ||
                (String.valueOf(prod.BLN_ProductCategory__c).startsWith('24'))) || 
                (String.valueOf(prod.BLN_ProductCategory__c).startsWith('20')) ||
                ((String.valueOf(prod.BLN_ProductCategory__c) == '5110') ||
                (String.valueOf(prod.BLN_ProductCategory__c) == '5210') ||
                (String.valueOf(prod.BLN_ProductCategory__c) == '5310') ||
                (String.valueOf(prod.BLN_ProductCategory__c) == '5410') ||
                (String.valueOf(prod.BLN_ProductCategory__c) == '5450') ||
                (String.valueOf(prod.BLN_ProductCategory__c) == '5810') ||
                (String.valueOf(prod.BLN_ProductCategory__c) == '2510')))) {
                    
                if(isAdasChecked == FALSE) {
                    workOrderWorkTypeName = System.label.BLN_Replacements;
                    workType.add(System.label.BLN_Replacements);
                } else if(isAdasChecked == TRUE && String.isNotBlank(serviceTerritory.Id) && serviceTerritory.BLN_SplitReplaceAndRecalibration__c == TRUE){
                    workOrderWorkTypeName = System.label.BLN_ReplaceAndRecal;
                    workType.add(System.label.BLN_Replacements);
                    workType.add(System.label.BLN_Recalibration);
                }else if(isAdasChecked == TRUE && String.isNotBlank(serviceTerritory.Id) && serviceTerritory.BLN_SplitReplaceAndRecalibration__c == FALSE) {
                    workOrderWorkTypeName = System.label.BLN_ReplaceAndRecal;
                    workType.add(System.label.BLN_ReplaceAndRecal);
                }
            }
            //Recalibration
            else if(isAdasChecked == TRUE) {
                workOrderWorkTypeName = System.label.BLN_Recalibration;
                workType.add(System.label.BLN_Recalibration);
            }
            //Repair
            else if((prod.BLN_ProductCategory__c !=null) && (prod.BLN_ProductCategory__c == System.label.BLN_Repair || String.valueOf(prod.BLN_ProductCategory__c).startsWith('14'))) {
                workOrderWorkTypeName = System.label.BLN_Repair;
                workType.add(System.label.BLN_Repair);
            }
        }*/
        //Replacement
        //Replacement
        if(( workType != null || !workType.isEmpty() || workType.size() == 0 ) && (workOrderWorkTypeName == '' || workOrderWorkTypeName == null)) {
            workOrderWorkTypeName = System.label.BLN_Replacements;
            workType = new Set<String>();
            workType.add(System.label.BLN_Replacements);
            workTypePriorityMap.put(1, workType);
        }
        Integer index = 10;
        for(Integer i : workTypePriorityMap.keySet()){
            if(i < index){
                index = i;
            }
        }
        Integer indexWO = 10;
        for(Integer i : workTypePriorityMapForWO.keySet()){
            if(i < indexWO){
                indexWO = i;
            }
        }
        workOrderWorkTypeName = workTypePriorityMapForWO.get(indexWO);
        Set<String> workTypeToBeCreate = new Set<String>();
        workTypeToBeCreate = workTypePriorityMap.get(index);
        workTypeToBeCreate.addAll(secondryWorkType);
        return workTypeToBeCreate;
    }
    
    /*
        @description : This method is used to generate WOLI.
        @param : WorkOrder workOrder, WorkType workType
        @retun : WorkOrderLineItem
    */
    public static WorkOrderLineItem generateWoLi(WorkOrder workOrder, WorkType workType){
        Schema.Location locationObj = new Schema.Location();
        if(serviceTerritory.BLN_Type__c == System.label.BLN_Mobile && workType.Name == System.label.BLN_StockCollect){
            if(String.isNotBlank(serviceTerritory.BLN_GUID__c)){
                locationObj = BLN_PortalHandlerWebservice.getLocationByGuid(serviceTerritory.BLN_GUID__c);
            }
        }

        WorkOrderLineItem woLi = new WorkOrderLineItem();
        if(String.isNotBlank(serviceTerritory.Id) && serviceTerritory.BLN_Type__c == System.label.BLN_Mobile && workType.Name == System.label.BLN_StockCollect){
            if(String.isNotBlank(locationObj.Id) && String.isNotBlank(locationObj.BLN_PrimarySourceCollectId__c)){
                Schema.Location locationByPrimarySourceCollect = new Schema.Location();
                locationByPrimarySourceCollect = BLN_PortalHandlerWebservice.getLocationByPrimarySourceCollectId(locationObj.BLN_PrimarySourceCollectId__c);
                woLi.Street = String.isNotBlank(locationByPrimarySourceCollect.Id) ? String.isNotBlank(locationByPrimarySourceCollect.VisitorAddress.Street) ? locationByPrimarySourceCollect.VisitorAddress.Street : '' : '';
                woLi.City = String.isNotBlank(locationByPrimarySourceCollect.Id) ? String.isNotBlank(locationByPrimarySourceCollect.VisitorAddress.City) ? locationByPrimarySourceCollect.VisitorAddress.City : '' : '';
                woLi.State = String.isNotBlank(locationByPrimarySourceCollect.Id) ? String.isNotBlank(locationByPrimarySourceCollect.VisitorAddress.State) ? locationByPrimarySourceCollect.VisitorAddress.State : '' : '';
                woLi.PostalCode = String.isNotBlank(locationByPrimarySourceCollect.Id) ? String.isNotBlank(locationByPrimarySourceCollect.VisitorAddress.PostalCode) ? locationByPrimarySourceCollect.VisitorAddress.PostalCode : '' : '';
                woLi.Country = String.isNotBlank(locationByPrimarySourceCollect.Id) ? String.isNotBlank(locationByPrimarySourceCollect.VisitorAddress.Country) ? locationByPrimarySourceCollect.VisitorAddress.Country : '' : '';
            } else {
                woLi.Street = String.isNotBlank(serviceTerritory.Street) ? serviceTerritory.Street : '';
                woLi.City = String.isNotBlank(serviceTerritory.City) ? serviceTerritory.City : '';
                woLi.State = String.isNotBlank(serviceTerritory.State) ? serviceTerritory.State : '';
                woLi.PostalCode = String.isNotBlank(serviceTerritory.PostalCode) ? serviceTerritory.PostalCode : '';
                woLi.Country = String.isNotBlank(serviceTerritory.Country) ? serviceTerritory.Country : '';
            }
        } else {
            woLi.Street = String.isNotBlank(caseObj.BLN_ServiceStreet__c) ? caseObj.BLN_ServiceStreet__c : '';
            woLi.City = String.isNotBlank(caseObj.BLN_ServiceTown__c) ? caseObj.BLN_ServiceTown__c : '';
            woLi.State = String.isNotBlank(caseObj.BLN_ServiceCounty__c) ? caseObj.BLN_ServiceCounty__c : '';
            woLi.PostalCode = String.isNotBlank(caseObj.BLN_ServicePostCode__c) ? caseObj.BLN_ServicePostCode__c : '';
            woLi.Country = String.isNotBlank(caseObj.BLN_ServiceCountry__c) ? caseObj.BLN_ServiceCountry__c : '';
        }
        woLi.WorkTypeId = String.isNotBlank(workType.Id) ? workType.Id : Null;
        woLi.ServiceTerritoryId = String.isNotBlank(serviceTerritory.Id) ? serviceTerritory.Id : Null;
        woLi.WorkOrderId = workOrder.Id;
        woLi.Status = System.label.BLN_New;
        woLi.Subject = System.label.BLN_WorkOrderLineItemForText + ' ' + workType.Name;
        woLi.Description = System.label.BLN_WorkOrderLineItemForText + ' ' + workType.Name;
        woLi.Priority = workType.Name == System.label.BLN_StockCollect ? System.label.BLN_Critical : System.label.BLN_LowText;
        ServiceReportLayout sRLayout = new ServiceReportLayout();
        sRLayout = BLN_PortalHandlerWebservice.getServiceReportLayoutByName(System.Label.BLN_PreInspectionSRLName);
        woli.ServiceReportTemplateId = sRLayout.Id;
        if(String.isNotBlank(serviceTerritory.OperatingHoursId) && workType.Name != System.label.BLN_StockCollect){
            woLi.FSL__VisitingHours__c = serviceTerritory.OperatingHoursId;
        }
        
        if(workType.Name != System.label.BLN_StockCollect && workType.Name != System.label.BLN_Assist){
            woLi.BLN_ProductFittingDuration__c = 0;
            woLi.BLN_IsStockCheckInCompleted__c = false;
        }
        return woLi;
    }
    
    /*
        @description : This method is used to generate SA.
        @param : WorkOrderLineItem woLi, Decimal specificAssistDuration, String woWorkType, Boolean weatherGuardOnSA
        @retun : ServiceAppointment
    */
    public static ServiceAppointment generateSA(WorkOrderLineItem woLi, Decimal specificAssistDuration, String woWorkType, Boolean weatherGuardOnSA){
        //Integer bufferDaysVal = caseObj.BLN_BufferDays__c > 0 ? Integer.valueOf(caseObj.BLN_BufferDays__c) : 0;
        WorkType woliWorkType = workTypeMap.get(woLi.workTypeId);
        String schPolicy = System.label.BLN_BUKSchedulingPolicy; 
        FSL__Scheduling_Policy__c schedulingPolicy = BLN_PortalHandlerWebservice.getSchedulingPolicyName(schPolicy);
        Datetime dateToday = System.Today();
        String dayOfWeek = dateToday.format(System.label.BLN_EEEEText);
        TimeSlot timeSlot = BLN_PortalHandlerWebservice.getEndTimeFromTimeSlot(serviceTerritory.OperatingHoursId, dayOfWeek);
        Date interimDate = earliestStartTime.date().addDays(Integer.valueOf(System.label.BLN_7Text));
        ServiceAppointment servAppointment = new ServiceAppointment();
        // servAppointment.BLN_DropOffAppointment__c = serviceTerritory.BLN_Type__c == 'Branch' ? True : False;
        servAppointment.BLN_IsWeatherGuardAppointment__c = weatherGuardOnSA;

        String duration = BLN_DurationCalculation.durationCal(woliWorkType, serviceTerritory, woLi, specificAssistDuration, bumetadata, woWorkType);
        Decimal calculatedDuration = 0;
        if(duration != System.label.BLN_NotNeeded){
            calculatedDuration = Decimal.valueOf(duration);
        } else {
            calculatedDuration = 0;
        }
        servAppointment.Duration = calculatedDuration;
        servAppointment.EarliestStartTime = earliestStartTime; //.addDays(bufferDaysVal);
        Time dueTime = timeSlot.EndTime.addMinutes(-Integer.valueOf(calculatedDuration));
        DateTime dueDate = datetime.newInstance(interimDate, dueTime);
        servAppointment.DueDate = dueDate;
        servAppointment.ArrivalWindowStartTime = earliestStartTime; //.addDays(bufferDaysVal);
        // DateTime arrivalWindowEndTime = dueDate;
        servAppointment.ArrivalWindowEndTime = dueDate;
        servAppointment.ServiceTerritory = serviceTerritory;
        servAppointment.WorkTypeId = woLi.workTypeId;
        servAppointment.ParentRecordId = woLi.Id;
        if(String.isNotBlank(serviceTerritory.Id) && serviceTerritory.BLN_Type__c == System.label.BLN_Branch){
            servAppointment.BLN_IsBranchAppointment__c = TRUE;
        } else if(String.isNotBlank(serviceTerritory.Id) && serviceTerritory.BLN_Type__c == System.label.BLN_Mobile){
            servAppointment.BLN_IsBranchAppointment__c = FALSE;
        }
        
        servAppointment.Subject = System.label.BLN_AppointmentForText + ' ' + woliWorkType.Name + ' ' + System.label.BLN_Task;
        servAppointment.Description =  System.label.BLN_AppointmentForText + ' ' + woliWorkType.Name + ' ' + System.label.BLN_Task;
        servAppointment.FSL__Scheduling_Policy_Used__c = serviceTerritory.BLN_SchedulingPolicy__c != Null ? serviceTerritory.BLN_SchedulingPolicy__c : schedulingPolicy.Id;
        //servAppointment.BLN_IsForcedAppointment__c = ;
        servAppointment.BLN_WorkOrderLineItem__c = woLi.Id;
        servAppointment.BLN_WorkOrderNumber__c = woli.WorkOrderId;
        servAppointment.BLN_Vehicle__c = caseObj.BLN_Vehicle__c ;
        servAppointment.BLN_MakeOfVehicle__c = caseObj.BLN_Vehicle__r.BLN_MakeOfVehicle__c;
        servAppointment.BLN_ModelOfVehicle__c = caseObj.BLN_Vehicle__r.BLN_ModelOfVehicle__c;
        servAppointment.DurationType = System.label.BLN_Minutes;
        servAppointment.BLN_IsPrepDataCall__c = true;
        servAppointment.FSL__GanttColor__c = '#000000';
        servAppointment.ContactId = caseObj.ContactId;
        if(serviceTerritory.BLN_IsPrioritized__c == true){
            servAppointment.BLN_CriticalPriority__c = caseObj.Priority == 'Critical' ? true : false;
            servAppointment.BLN_HighPriority__c = caseObj.Priority == 'High' ? true : false;
            servAppointment.BLN_MediumPriority__c = caseObj.Priority == 'Medium' ? true : false;
        }
        return servAppointment;
    }

    /*
        @description : This method is used to create Appointment Dependency.
        @param : String mainSAId, String stockSAId, Boolean isSameResource, String dependency
    */
    public static void mainAndStockOrAssistSADependency(String mainSAId, String stockSAId, Boolean isSameResource, String dependency){
        FSL__Time_Dependency__c timeDependency = new FSL__Time_Dependency__c();
        timeDependency.FSL__Dependency__c = dependency;
        timeDependency.FSL__Same_Resource__c = isSameResource;
        timeDependency.FSL__Service_Appointment_1__c = stockSAId;
        timeDependency.FSL__Service_Appointment_2__c = mainSAId;
        timeDependency.FSL__Root_Service_Appointment__c = stockSAId;
        
        if(Schema.sObjectType.FSL__Time_Dependency__c.isCreateable()){
            INSERT timeDependency;
        }
    }
    
    /*
        @description : This method is used to generate WOLI.
        @param : WorkOrderLineItem parentwoLi, Product2 eachProduct, Map<String, WorkType workType, ServiceTerritory serviceTerritory
        @retun : WorkOrderLineItem
    */
    public static ProductRequired generateProductRequired(WorkOrderLineItem parentwoLi, Product2 eachProduct, WorkType workType, ServiceTerritory serviceTerritory, Map<String, Decimal> productQuantityMap, Map<String, String> oLIKeyMap, Integer index){
        ProductRequired prodReq = new ProductRequired();
        // WorkType parentWoliWorkType = workTypeMap.get(parentwoLi.WorkTypeId);
        WorkType parentWoliWorkType = BLN_PortalQueryHandlerWebservice.getWorkTypeById(parentwoLi.WorkTypeId);
        // if(eachOrderItem.BLN_IsProductSelected__c == true){
        //     prodReq.BLN_IsProductSelected__c = true;
        // }
        
        if(parentWoliWorkType.Name != System.label.BLN_StockCollect && parentWoliWorkType.Name != System.label.BLN_Assist){
            //WorkType: Warranty Replacement & Recalibration
            if(workType.Name == System.label.BLN_WarrantyReplacementRecalibration && serviceTerritory.BLN_SplitReplaceAndRecalibration__c == FALSE){
                prodReq = setCommonWoliFields(parentwoLi, eachProduct, productQuantityMap, oLIKeyMap, index);
            }
            else if(workType.Name == System.label.BLN_WarrantyReplacementRecalibration && serviceTerritory.BLN_SplitReplaceAndRecalibration__c == TRUE && eachProduct.BLN_ADASRecalibrationNeeded__c == TRUE && parentWoliWorkType.Name == System.label.BLN_Recalibration){
                prodReq = setCommonWoliFields(parentwoLi, eachProduct, productQuantityMap, oLIKeyMap, index);
            } else if(workType.Name == System.label.BLN_WarrantyReplacementRecalibration && serviceTerritory.BLN_SplitReplaceAndRecalibration__c == TRUE && eachProduct.BLN_ADASRecalibrationNeeded__c == FALSE && parentWoliWorkType.Name != System.label.BLN_Recalibration){
                prodReq = setCommonWoliFields(parentwoLi, eachProduct, productQuantityMap, oLIKeyMap, index);
            }
            //WorkType: Replacement & Recalibration
            else if(workType.Name == System.label.BLN_ReplaceAndRecal && serviceTerritory.BLN_SplitReplaceAndRecalibration__c == FALSE){
                prodReq = setCommonWoliFields(parentwoLi, eachProduct, productQuantityMap, oLIKeyMap, index);
            } else if (workType.Name == System.label.BLN_ReplaceAndRecal && serviceTerritory.BLN_SplitReplaceAndRecalibration__c == TRUE && eachProduct.BLN_ADASRecalibrationNeeded__c == TRUE && parentWoliWorkType.Name == System.label.BLN_Recalibration){
                prodReq = setCommonWoliFields(parentwoLi, eachProduct, productQuantityMap, oLIKeyMap, index);
            } else if(workType.Name == System.label.BLN_ReplaceAndRecal && serviceTerritory.BLN_SplitReplaceAndRecalibration__c == TRUE && eachProduct.BLN_ADASRecalibrationNeeded__c == FALSE && parentWoliWorkType.Name != System.label.BLN_Recalibration){
                prodReq = setCommonWoliFields(parentwoLi, eachProduct, productQuantityMap, oLIKeyMap, index);
            }
            //WorkType: Recalibration
            else if((workType.Name == System.label.BLN_Recalibration && parentWoliWorkType.Name == System.label.BLN_Recalibration) && (eachProduct.BLN_ADASRecalibrationNeeded__c == TRUE || (eachProduct.BLN_ProductCategory__c !=null && eachProduct.BLN_ProductCategory__c == System.label.BLN_VAPS))){
                prodReq = setCommonWoliFields(parentwoLi, eachProduct, productQuantityMap, oLIKeyMap, index);
            }
            //WorkType: Warranty Replacement
            else if(workType.Name == System.label.BLN_WarrantyReplacement && parentWoliWorkType.Name == System.label.BLN_WarrantyReplacement && eachProduct.BLN_ADASRecalibrationNeeded__c == FALSE){
                prodReq = setCommonWoliFields(parentwoLi, eachProduct, productQuantityMap, oLIKeyMap, index);
            }
            //WorkType: Side & Rear Replacement
            else if(workType.Name == System.label.BLN_SideRearReplacementWT && parentWoliWorkType.Name == System.label.BLN_SideRearReplacementWT && eachProduct.BLN_ADASRecalibrationNeeded__c == FALSE){
                prodReq = setCommonWoliFields(parentwoLi, eachProduct, productQuantityMap, oLIKeyMap, index);
            }
            //WorkType: Replacement
            else if(workType.Name == System.label.BLN_Replacements && parentWoliWorkType.Name == System.label.BLN_Replacements && eachProduct.BLN_ADASRecalibrationNeeded__c == FALSE){
                prodReq = setCommonWoliFields(parentwoLi, eachProduct, productQuantityMap, oLIKeyMap, index);
            }
            //WorkType: Repair
            else if((workType.Name == System.label.BLN_Repair && parentWoliWorkType.Name == System.label.BLN_Repair && eachProduct.BLN_ProductCategory__c !=null) && (eachProduct.BLN_ProductCategory__c == System.label.BLN_VAPS || eachProduct.BLN_ProductCategory__c == System.label.BLN_Repair || String.valueOf(eachProduct.BLN_ProductCategory__c).startsWith('14')|| String.valueOf(eachProduct.BLN_ProductCategory__c).startsWith('29'))){
                prodReq = setCommonWoliFields(parentwoLi, eachProduct, productQuantityMap, oLIKeyMap, index);
            }
        }
        return prodReq;
    }
    
    /*
        @description : This method is used to populate common fields on WOLI.
        @param : WorkOrderLineItem parentwoLi, Product2 eachProduct
        @retun : WorkOrderLineItem
    */
    public static ProductRequired setCommonWoliFields(WorkOrderLineItem parentwoLi, Product2 eachProduct, Map<String, Decimal> productQuantityMap, Map<String, String> oLIKeyMap, Integer index){
        ProductRequired productReq = new ProductRequired();
        Decimal belronFittingTime = eachProduct.BLN_BelronFittingTime__c != Null ? eachProduct.BLN_BelronFittingTime__c : 0;
        Decimal quantity = 1;
        if(index != null && productQuantityMap.containsKey(eachProduct.BLN_MDMID__c + '-' + index)){
            quantity = productQuantityMap.get(eachProduct.BLN_MDMID__c + '-' + index);
        }
       // Decimal quantity = productQuantityMap.get(eachProduct.ProductCode) != Null ? (Decimal) productQuantityMap.get(eachProduct.ProductCode) : 0;

        productReq.BLN_WorkOrder__c = parentwoLi.WorkOrderId;
        productReq.BLN_IsProductStockable__c = eachProduct.BLN_ProductStockable__c;
        productReq.Product2Id = eachProduct.Id;
        productReq.QuantityUnitOfMeasure = 'Each';
        productReq.QuantityRequired = quantity;
        productReq.ParentRecordId = parentwoLi.Id;
        productReq.BLN_ProductQuantityConsumedOrTransferred__c = 0;
        productReq.BLN_IsWMSTracked__c = eachProduct.BLN_WMSTracked__c;
        productReq.BLN_WOLI__c = parentwoLi.Id;
        productReq.BLN_Duration__c = belronFittingTime * quantity;
        productReq.BLN_OLIKey__c = oLIKeyMap.get(eachProduct.BLN_MDMID__c + '-' + index);
        return productReq;
    }

    /*
        @description : This method is used to delete Appointments.
        @param : String appointmentId
        @retun : String
    */
    @AuraEnabled
    public static String deleteAppointment(String appointmentId){
        if(String.isNotBlank(appointmentId)){
            Set<Id> appointmentIds = new Set<Id>();
            List<FSL__Time_Dependency__c> dependencyList = BLN_PortalQueryHandlerWebservice.getTimeDependencyByAppointmentId(appointmentId);
            if(dependencyList != null) {
                for(FSL__Time_Dependency__c dependencyRec : dependencyList){
                    appointmentIds.add(dependencyRec.FSL__Service_Appointment_1__c);
                    appointmentIds.add(dependencyRec.FSL__Service_Appointment_2__c);
                }
            } else {
                appointmentIds.add(appointmentId);
            }

            Set<Id> woLiIdSet = new Set<Id>();
            List<ServiceAppointment> appointmentList = new List<ServiceAppointment>();
            if(!appointmentIds.isEmpty() && appointmentIds.size() > 0){
                appointmentList = BLN_PortalQueryHandlerWebservice.getServiceAppointmentByIds(appointmentIds);
                for(ServiceAppointment serviceApp : appointmentList){
                    woLiIdSet.add(serviceApp.ParentRecordId);
                }
            }

            List<WorkOrderLineItem> woliToBeDelete = new List<WorkOrderLineItem>();
            if(!woLiIdSet.isEmpty() && woLiIdSet.size() > 0){
                woliToBeDelete = BLN_PortalQueryHandlerWebservice.getWorkOrderLineItemById(woLiIdSet);
            }

            try{
                if(appointmentList != null && Schema.sObjectType.ServiceAppointment.isDeletable()){
                    DELETE appointmentList;
                }

                if(woliToBeDelete.size() > 0 && Schema.sObjectType.WorkOrderLineItem.isDeletable()){
                    DELETE woliToBeDelete;
                }
                return 'Appointments Removed Successfully';
            } catch (Exception ex) {
                BLN_ExceptionLogger.captureException(ex);
                return 'Deletion Fail';
            }
        } else {
            return '';
        }
    }
    @AuraEnabled
    public static void updateWOwithOrder(String orderId){
        order.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
        
        Order ord = [Select id, BLN_Case__c from order where Id =:orderId];
        Case.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
        Case cs = [Select id,(Select id,BLN_Order__c from WorkOrders) from Case where id =: ord.BLN_Case__c WITH SECURITY_ENFORCED];
        workOrder wo = new workOrder();
        wo = cs.WorkOrders[0];
        wo.BLN_Order__c = ord.Id;
        if(Schema.sObjectType.workOrder.isUpdateable()){
            update wo;
        }
    }
    
    /*
        *  @description : Wrappre Class for getting appointment slots.
        *  @author: Wasim Akram
        *  @Story: 
        *  @CreatedDate: 08/01/2024
    */
    public class TimeSlotWrapper {
        @AuraEnabled public String appointmentId;
        @AuraEnabled public String msg;
        @AuraEnabled public Boolean isSuceess;
    }

    /*
        *  @description : Wrappre Class for return appointment slots Date and Time with Profile.
        *  @author: Wasim Akram
        *  @Story: 
        *  @CreatedDate: 08/01/2024
    */
    public class TimeSlotsWithProfile {
        @AuraEnabled public String profileName;
        @AuraEnabled public Date slotDate;
        @AuraEnabled public String slotStart;
        @AuraEnabled public String slotEnd;
        @AuraEnabled public Boolean isSuceess;
        @AuraEnabled public String msg;
    }

    /*
        *  @description : Wrappre Class for return appointment slots Date and Time.
        *  @param : Set<String> dateTimeSet
        *  @author: Wasim Akram
        *  @Story: 
        *  @CreatedDate: 08/01/2024
    */
    public class SlotData {
        @AuraEnabled public String startTime;
        @AuraEnabled public String endTime;
    }

    public class Slots {
        @AuraEnabled public List<SlotData> waitingSlots;
        @AuraEnabled public List<SlotData> dropOffSlots;
        @AuraEnabled public Boolean isSuceess;
        @AuraEnabled public String msg;
    }
    
    public class ProductData{
        @auraEnabled public String productCode;
        @auraEnabled public Decimal quantity;
        @auraEnabled public String productOLIKey;//added by service
    }
    public class BookingResponse {
        @AuraEnabled public String appointmentId;
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public String message;
    }
}