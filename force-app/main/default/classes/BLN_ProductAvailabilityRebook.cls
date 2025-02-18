public with sharing class BLN_ProductAvailabilityRebook {

    static final String QUEUE_SPECIALS = 'Specials';
    static final String QUEUE_NO_STOCK = 'No Stock';
    static final String QUEUE = 'Queue';
    static final String ISSUE = 'Issue';


    /*public class ServiceLabel {
        @AuraEnabled public String serviceLocation {get; set;}
    }*/
    public class Product {
        @AuraEnabled public String products {get; set;}
    }
    
    @AuraEnabled 
    public static BLN_ProductAvailabilityWrapper.AppointmentWrapper parse(String json){
        return (BLN_ProductAvailabilityWrapper.AppointmentWrapper) System.JSON.deserialize(json, BLN_ProductAvailabilityWrapper.AppointmentWrapper.class);
    }

    @AuraEnabled
    public static String getQuoteApi(String cpqExtenalCode,String caseId){
        HttpResponse response = BLN_QuoteBookingHandler.getQuoteCallout(cpqExtenalCode,caseId);
        String returnPayloadAsString = response.getStatusCode() == 200 ? response.getBody() : System.label.BLN_CalloutFailed;
        return returnPayloadAsString;
        
    }
    //description:FOUK-4455
    @AuraEnabled
	public static String callCPQCloneAPI(String quoteIds,String caseId){
        HttpResponse response = BLN_QuoteBookingHandler.cloneQuoteCallout(quoteIds,caseId);
        String returnPayloadAsString = response.getStatusCode() == 201 ? response.getBody() : System.label.BLN_CalloutFailed;
        return returnPayloadAsString; 
    }
    @AuraEnabled
    public static case getCaseData(String caseId){
		Case cse = new Case();
        //Added a condition for portal User check
		Boolean isPortalUser = getPortalUserProfile();
       	If(isPortalUser){
            Case.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
            cse = [Select Id, BLN_IsForceReprice__c From Case where Id =: caseId   LIMIT 1];
       	}
       	else{
            cse = [Select Id, BLN_IsForceReprice__c From Case where Id =: caseId WITH SECURITY_ENFORCED LIMIT 1];
       	}
        return cse;
    }
    public static List<BLN_ProductAvailabilityWrapper.LocationWrapper> getNearestServiceLocationsByLatLong(Case motoristCase, Double userLatitude, Double userLongitude){
        //FOUK-4639
        List<BLN_ProductAvailabilityWrapper.LocationWrapper> nearestLocationDetails = new List<BLN_ProductAvailabilityWrapper.LocationWrapper>();
        BLN_ProductAvailabilityWrapper.LocationWrapper locWrapper;
        List<ServiceTerritory> branchST = new List<ServiceTerritory>();
        Boolean isPortalUser = getPortalUserProfile();
            if(test.isRunningTest()){
				//Added a condition for portal User check
                
				If(isPortalUser){
                    ServiceTerritory.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
					branchST = [SELECT id, Latitude,Longitude,BLN_GUID__c,BLN_ExcludedProduct__c, BLN_CostCenter__c,BLN_OrgCodeLocation__c FROM ServiceTerritory   LIMIT 1];
				}
				else{
					branchST = [SELECT id, Latitude,Longitude,BLN_GUID__c,BLN_ExcludedProduct__c, BLN_CostCenter__c,BLN_OrgCodeLocation__c FROM ServiceTerritory WITH SECURITY_ENFORCED LIMIT 1];
				}
            }
            else{
                branchST = motoristCase.BLN_Vehicle__r.BLN_SpecialVehicle__c ? [SELECT Id,Address,BLN_GUID__c,BLN_CostCenter__c,BLN_OrgCodeLocation__c, BLN_ExcludedProduct__c, BLN_Type__c, DISTANCE(Address,GEOLOCATION(:userLatitude,:userLongitude),'mi') distanceChart FROM ServiceTerritory WHERE BLN_ConsiderforR1__c = false AND IsActive = true AND BLN_Type__c = :System.label.BLN_Branch AND BLN_Specials__c = true AND BLN_GUID__c != '' AND BLN_CostCenter__c != '' AND Longitude != null AND Latitude != null ORDER BY DISTANCE(Address,GEOLOCATION(:userLatitude,:userLongitude),'mi') ASC limit 3] :
                [SELECT id,Address,BLN_GUID__c,BLN_CostCenter__c,BLN_Type__c,BLN_OrgCodeLocation__c, BLN_ExcludedProduct__c, DISTANCE(Address,GEOLOCATION(:userLatitude,:userLongitude),'mi') sampleDistance FROM ServiceTerritory WHERE BLN_ConsiderforR1__c = false AND IsActive=true AND BLN_Type__c= :System.label.BLN_Branch AND BLN_GUID__c != '' AND BLN_CostCenter__c != '' AND Longitude != null AND Latitude != null ORDER BY DISTANCE(Address,GEOLOCATION(:userLatitude,:userLongitude),'mi') ASC limit 3];
                    }
            
            /* Collect the GUID for get OrgCodeLocation */
            Set<String> guIds = new Set<String>();
            for(ServiceTerritory st : branchST){
                if(String.isNotBlank(st.BLN_GUID__c)){
                    guIds.add(st.BLN_GUID__c);
                }
            }

            for(ServiceTerritory st : branchST){
                locWrapper = new BLN_ProductAvailabilityWrapper.LocationWrapper();
                locWrapper.costCenterId = st.BLN_OrgCodeLocation__c;
                locWrapper.locationId = st.BLN_GUID__c;
                locWrapper.mobileLocationIndicator = false;
                locWrapper.countryCode = 'GB';
                locWrapper.excludeProduct = st.BLN_ExcludedProduct__c != null ? st.BLN_ExcludedProduct__c : 'TestExcludProduct';
                nearestLocationDetails.add(locWrapper);
            }
            
            if(!motoristCase.BLN_Vehicle__r.BLN_SpecialVehicle__c){
                List<FSL__Polygon__c> polygonList = new List<FSL__Polygon__c>();
       
                if(FSL__Polygon__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible() && !test.isRunningTest()){   
                    //Added a condition for portal User check
                    If(isPortalUser){
						polygonList = [SELECT id,FSL__Service_Territory__r.BLN_GUID__c,FSL__Service_Territory__r.BLN_CostCenter__c,FSL__Service_Territory__r.BLN_OrgCodeLocation__c,FSL__Service_Territory__r.BLN_Type__c,FSL__Service_Territory__r.Address FROM FSL__Polygon__c WHERE FSL__Service_Territory__r.BLN_ConsiderforR1__c = false AND FSL__Service_Territory__r.isActive = true AND FSL__Service_Territory__r.BLN_Type__c = :System.label.BLN_Mobile AND Id IN :FSL.PolygonUtils.getAllPolygonsByLatLong(userLongitude,userLatitude)   ORDER BY DISTANCE(FSL__Service_Territory__r.Address,GEOLOCATION(:userLatitude,:userLongitude),'mi') ASC LIMIT 1];
					}
					else{
						polygonList = [SELECT id,FSL__Service_Territory__r.BLN_GUID__c,FSL__Service_Territory__r.Id,FSL__Service_Territory__r.BLN_CostCenter__c,FSL__Service_Territory__r.BLN_OrgCodeLocation__c,FSL__Service_Territory__r.BLN_Type__c,FSL__Service_Territory__r.Address FROM FSL__Polygon__c WHERE FSL__Service_Territory__r.BLN_ConsiderforR1__c = false AND FSL__Service_Territory__r.isActive = true AND FSL__Service_Territory__r.BLN_Type__c = :System.label.BLN_Mobile AND Id IN :FSL.PolygonUtils.getAllPolygonsByLatLong(userLongitude,userLatitude) WITH SECURITY_ENFORCED ORDER BY DISTANCE(FSL__Service_Territory__r.Address,GEOLOCATION(:userLatitude,:userLongitude),'mi') ASC LIMIT 1];
                }
                }
                if(test.isRunningTest()){
					//Added a condition for portal User check
                    If(isPortalUser){
						polygonList = [SELECT FSL__KML__c, FSL__Mi_Lo__c, FSL__Color__c, Name, FSL__Service_Territory__r.BLN_GUID__c,FSL__Service_Territory__r.BLN_CostCenter__c,FSL__Service_Territory__r.BLN_OrgCodeLocation__c,  FSL__Ma_Lo__c, FSL__Mi_La__c, FSL__Ma_La__c, FSL__Service_Territory__c FROM FSL__Polygon__c LIMIT 1];
					}
					else{
						polygonList = [SELECT FSL__KML__c, FSL__Mi_Lo__c, FSL__Color__c, Name, FSL__Service_Territory__r.BLN_GUID__c,FSL__Service_Territory__r.BLN_CostCenter__c,FSL__Service_Territory__r.BLN_OrgCodeLocation__c,  FSL__Ma_Lo__c, FSL__Mi_La__c, FSL__Ma_La__c, FSL__Service_Territory__c FROM FSL__Polygon__c WITH SECURITY_ENFORCED LIMIT 1];
					}
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
	
    @AuraEnabled
    public static String makeNewQuoteCallout(String motoristCaseId, Double userLatitude, Double userLongitude,String existingGUId){        

        Case motoCase = BLN_QuoteBookingHandler.getCaseForQuoteCallout(motoristCaseId);
        List<BLN_ProductAvailabilityWrapper.LocationWrapper> nearestLocations = BLN_ProductAvailabilityRebook.getNearestServiceLocationsByLatLong(motoCase,userLatitude,userLongitude);            
       
        Boolean isGUIdExists = false;
        BLN_ProductAvailabilityWrapper.LocationWrapper existingLocationData = new BLN_ProductAvailabilityWrapper.LocationWrapper();
        Integer indexToRemove = -1;
        for(Integer i = 0; i < nearestLocations.size(); i++){
            if(nearestLocations[i].locationId == existingGUId){
                existingLocationData.costCenterId = nearestLocations[i].costCenterId;
                existingLocationData.locationId = nearestLocations[i].locationId;
                existingLocationData.mobileLocationIndicator = nearestLocations[i].mobileLocationIndicator;
                existingLocationData.countryCode = nearestLocations[i].countryCode;
                existingLocationData.excludeProduct = nearestLocations[i].excludeProduct != null ? nearestLocations[i].excludeProduct : 'TestExcludProduct';
        
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
			//Added a condition for portal User check
            Boolean isPortalUser = getPortalUserProfile();
			If(isPortalUser){
                ServiceTerritory.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
				serv = [SELECT id,BLN_GUID__c,BLN_CostCenter__c,BLN_Type__c,BLN_ExcludedProduct__c FROM ServiceTerritory WHERE BLN_GUID__c = :existingGUId   LIMIT 1 ];
			}
			else{
            serv = [SELECT id,BLN_GUID__c,BLN_CostCenter__c,BLN_Type__c,BLN_ExcludedProduct__c FROM ServiceTerritory WHERE BLN_GUID__c = :existingGUId WITH SECURITY_ENFORCED LIMIT 1 ];
			}
			existingLocationData.costCenterId = serv.BLN_CostCenter__c;existingLocationData.locationId = serv.BLN_GUID__c;existingLocationData.mobileLocationIndicator = serv.BLN_Type__c == System.label.BLN_Mobile ? true : false;existingLocationData.countryCode = 'GB';existingLocationData.excludeProduct = serv.BLN_ExcludedProduct__c != null ? serv.BLN_ExcludedProduct__c : 'TestExcludProduct';
            
          
            if(nearestLocations.size() != 0){
            nearestLocations.add(0,existingLocationData);
         }
        }

        String returnPayloadAsString = BLN_QuoteBookingHandler.makeQuoteCallout(motoCase,nearestLocations);       

      
        return returnPayloadAsString;
        
    }
    
    @AuraEnabled
    public static String getOrderItemsToIdentifyByCPQExternalId(String cpqExtrnlId){
        Order orderRecord  = new Order();
		//Added a condition for portal User check
        Boolean isPortalUser = getPortalUserProfile();
       	If(isPortalUser){
            OrderItem.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
            Order.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
            orderRecord  = [SELECT Id,BLN_CPQExternalQuoteId__c,Status,CreatedDate,(SELECT Id,BLN_DocumentNumber__c,Quantity,BLN_ServiceAppointment__c,BLN_FittingLocation__c,BLN_StockLocation__c,BLN_IsProductSelected__c,BLN_OutOfStock__c,BLN_BOMId__c,BLN_BundleName__c,Product2.BLN_MDMID__c FROM OrderItems) FROM ORDER WHERE BLN_CPQExternalQuoteId__c = :cpqExtrnlId   LIMIT 1];
       	}
       	else{
           orderRecord  = [SELECT Id,BLN_CPQExternalQuoteId__c,Status,CreatedDate,(SELECT Id,BLN_DocumentNumber__c,Quantity,BLN_ServiceAppointment__c,BLN_FittingLocation__c,BLN_StockLocation__c,BLN_IsProductSelected__c,BLN_OutOfStock__c,BLN_BOMId__c,BLN_BundleName__c,Product2.BLN_MDMID__c FROM OrderItems) FROM ORDER WHERE BLN_CPQExternalQuoteId__c = :cpqExtrnlId WITH SECURITY_ENFORCED LIMIT 1];
       	}
        String returnData  = getOrderItemsToIdentify(orderRecord);

        return returnData;
    }

    @AuraEnabled
    public static String getOrderItemsToIdentifyByStatus(String caseId, String orderStatus){
		Order orderRecord  = new Order();
		//Added a condition for portal User check
        Boolean isPortalUser = getPortalUserProfile();
       	If(isPortalUser){
            OrderItem.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
            Order.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
			orderRecord  = [SELECT Id,BLN_CPQExternalQuoteId__c,Status,CreatedDate,(SELECT Id,BLN_DocumentNumber__c,Quantity,BLN_ServiceAppointment__c,BLN_FittingLocation__c,BLN_StockLocation__c,BLN_IsProductSelected__c,BLN_BOMId__c,BLN_BundleName__c,Product2.BLN_MDMID__c,BLN_OutOfStock__c FROM OrderItems) FROM ORDER WHERE BLN_Case__c = :caseId AND Status = :System.label.BLN_Invoiced   ORDER BY CreatedDate DESC LIMIT 1];
		}
		else{
			orderRecord  = [SELECT Id,BLN_CPQExternalQuoteId__c,Status,CreatedDate,(SELECT Id,BLN_DocumentNumber__c,Quantity,BLN_ServiceAppointment__c,BLN_FittingLocation__c,BLN_StockLocation__c,BLN_IsProductSelected__c,BLN_BOMId__c,BLN_BundleName__c,Product2.BLN_MDMID__c,BLN_OutOfStock__c FROM OrderItems) FROM ORDER WHERE BLN_Case__c = :caseId AND Status = :System.label.BLN_Invoiced WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC LIMIT 1];
		}
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
            orderItemIdentifier.isOutOfStock = oi.BLN_OutOfStock__c ;
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

		//Added a condition for portal User check
        Boolean isPortalUser = getPortalUserProfile();
       	If(isPortalUser){
            Order.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
			orderRecord = [SELECT Id, AccountId,BLN_CPQExternalQuoteId__c,BLN_ServiceTerritory__r.BLN_GUID__c,BLN_TotalTax__c,BLN_TotalIncludingTaxTrade__c,BLN_TotalTaxPayablebyTrade__c,BLN_TotalPayablebyTradeCompany__c,BLN_TotalIncludingTaxInsuranceCompany__c,BLN_TotalTaxPayablebyInsurance__c,BLN_PayableByInsuranceRepair__c,BLN_TotalIncludingTaxMotorist__c,BLN_TotalTaxPayablebyMotorist__c,BLN_TotalPrice__c,BLN_TotalPayableByMotorist__c, Status,BLN_ServiceTerritory__r.Name,BLN_Case__c,BLN_DiscountThresholdAmountA__c, BLN_DiscountThresholdAmountB__c,
			BLN_DiscountThresholdAmountC__c, BLN_PriceExpirationDate__c, BLN_TotalIncludingTax__c,BLN_ServiceTerritory__c
			FROM Order WHERE Status =: System.label.BLN_Accepted AND BLN_Case__c =:caseId AND BLN_CPQExternalQuoteId__c IN : externalOrderIdList   ORDER BY createddate DESC LIMIT 1];
       	}
       	else{
        orderRecord = [SELECT Id, AccountId,BLN_CPQExternalQuoteId__c,BLN_ServiceTerritory__r.BLN_GUID__c,BLN_TotalTax__c,BLN_TotalIncludingTaxTrade__c,BLN_TotalTaxPayablebyTrade__c,BLN_TotalPayablebyTradeCompany__c,BLN_TotalIncludingTaxInsuranceCompany__c,BLN_TotalTaxPayablebyInsurance__c,BLN_PayableByInsuranceRepair__c,BLN_TotalIncludingTaxMotorist__c,BLN_TotalTaxPayablebyMotorist__c,BLN_TotalPrice__c,BLN_TotalPayableByMotorist__c, Status,BLN_ServiceTerritory__r.Name,BLN_Case__c,BLN_DiscountThresholdAmountA__c, BLN_DiscountThresholdAmountB__c,
        BLN_DiscountThresholdAmountC__c, BLN_PriceExpirationDate__c, BLN_TotalIncludingTax__c,BLN_ServiceTerritory__c
        FROM Order WHERE Status =: System.label.BLN_Accepted AND BLN_Case__c =:caseId AND BLN_CPQExternalQuoteId__c IN : externalOrderIdList WITH SECURITY_ENFORCED ORDER BY createddate DESC LIMIT 1];
			
       	}
        orderIds.add(orderRecord.Id);

        map<string, orderItem> orderItemMap = new map<string, orderItem>();
       	//Added a condition for portal User check
        If(isPortalUser){
            OrderItem.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
            for(orderItem oli : [SELECT Id, Product2.Name, Product2.BLN_MDMID__c, OrderId, BLN_IsProductSelected__c,BLN_ServiceAppointment__c,BLN_DocumentNumber__c  FROM OrderItem where orderId = :orderRecord.Id AND BLN_IsProductSelected__c = true  ]){
                orderItemMap.put(oli.Product2.BLN_MDMID__c, oli);
            }
       	}
       	else{
        // query orderItemList
        for(orderItem oli : [SELECT Id, Product2.Name,Product2.Description, Product2.BLN_MDMID__c, OrderId, BLN_IsProductSelected__c,BLN_ServiceAppointment__c,BLN_DocumentNumber__c  FROM OrderItem where orderId = :orderRecord.Id AND BLN_IsProductSelected__c = true WITH SECURITY_ENFORCED]){
            orderItemMap.put(oli.Product2.BLN_MDMID__c, oli);
        }
       	}

        for(BLN_ProductAvailabilityWrapper.AppointmentWrapper order : appointmentData){
            for(BLN_ProductAvailabilityWrapper.Appointments appointment : order.Appointments){
                for(BLN_ProductAvailabilityWrapper.ProductAvailibilities productList : appointment.productAvailibilities){
                    for(BLN_ProductAvailabilityWrapper.Products product : productList.Products){
                        if(product.productEnable && orderItemMap.containsKey(product.productCode)){
                            orderItemMap.get(product.productCode).BLN_ServiceAppointment__c = appointment.serviceAppointmentId;
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
		List<Order> orderData = new List<Order>();
		//Added a condition for portal User check
        Boolean isPortalUser = getPortalUserProfile();
       	If(isPortalUser){
            Order.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
            orderData = [SELECT Id, AccountId,BLN_CPQExternalQuoteId__c,BLN_ServiceTerritory__r.BLN_GUID__c,BLN_TotalTax__c,BLN_TotalIncludingTaxTrade__c,
                                        BLN_TotalTaxPayablebyTrade__c,BLN_TotalPayablebyTradeCompany__c,BLN_TotalIncludingTaxInsuranceCompany__c,
                                        BLN_TotalTaxPayablebyInsurance__c,BLN_PayableByInsuranceRepair__c,BLN_TotalIncludingTaxMotorist__c,BLN_TotalTaxPayablebyMotorist__c,
                                        BLN_TotalPrice__c,BLN_TotalPayableByMotorist__c, Status,BLN_ServiceTerritory__r.Name,BLN_Case__c,BLN_DiscountThresholdAmountA__c, 
                                        BLN_DiscountThresholdAmountB__c, BLN_DiscountThresholdAmountC__c,BLN_ServiceTerritory__r.BLN_Type__c, 
                                        BLN_PriceExpirationDate__c, BLN_TotalIncludingTax__c,BLN_ServiceTerritory__c
                                FROM Order 
                                WHERE Status = :System.label.BLN_Accepted AND BLN_Case__c =: caseId   ORDER BY createddate DESC LIMIT 1 ];
        
       	}
       	else{
            orderData = [SELECT Id, AccountId,BLN_CPQExternalQuoteId__c,BLN_ServiceTerritory__r.BLN_GUID__c,BLN_TotalTax__c,BLN_TotalIncludingTaxTrade__c,
                                        BLN_TotalTaxPayablebyTrade__c,BLN_TotalPayablebyTradeCompany__c,BLN_TotalIncludingTaxInsuranceCompany__c,
                                        BLN_TotalTaxPayablebyInsurance__c,BLN_PayableByInsuranceRepair__c,BLN_TotalIncludingTaxMotorist__c,BLN_TotalTaxPayablebyMotorist__c,
                                        BLN_TotalPrice__c,BLN_TotalPayableByMotorist__c, Status,BLN_ServiceTerritory__r.Name,BLN_Case__c,BLN_DiscountThresholdAmountA__c, 
                                        BLN_DiscountThresholdAmountB__c, BLN_DiscountThresholdAmountC__c,BLN_ServiceTerritory__r.BLN_Type__c, 
                                        BLN_PriceExpirationDate__c, BLN_TotalIncludingTax__c,BLN_ServiceTerritory__c
                                FROM Order 
                                WHERE Status = :System.label.BLN_Accepted AND BLN_Case__c =: caseId WITH SECURITY_ENFORCED ORDER BY createddate DESC LIMIT 1 ];
       	}
        
        if( !orderData.isEmpty() ){
            return orderData[0];
        }

        return null;
    }
        
    /* This method is used for existing workorderlineItem check */
    @AuraEnabled
    public static Map<String, List<String>> getWorkOrderItemExisting(String orderId){
        Map<String, List<String>> serviceAppointmentWithProductCode = new Map<String, List<String>>();
        if(orderId != null && orderId != 'undefined') {
            for(OrderItem orderItem: [SELECT Id, Product2.BLN_MDMID__c, OrderId, BLN_ServiceAppointment__c FROM OrderItem WHERE OrderId =: orderId WITH SECURITY_ENFORCED]) {
                List<String> mdmIds = new List<String>();
                if(serviceAppointmentWithProductCode.containsKey(orderItem.BLN_ServiceAppointment__c)) {
                    serviceAppointmentWithProductCode.get(orderItem.BLN_ServiceAppointment__c).add(orderItem.Product2.BLN_MDMID__c);
                    //mdmIds.add(orderItem.Product2.ProductCode);
                } 
                else {
                    mdmIds.add(orderItem.Product2.BLN_MDMID__c);
                    serviceAppointmentWithProductCode.put(orderItem.BLN_ServiceAppointment__c, mdmIds);
                }                    
            }
        }
        return serviceAppointmentWithProductCode;
    }

    @AuraEnabled
    public static DisplayDetailsWrapper rebookServiceAppointments(String caseId, String currentPayload){
         List<BLN_ProductAvailabilityWrapper.productNames> productNameList = new List<BLN_ProductAvailabilityWrapper.productNames>();
       List<BLN_ProductAvailabilityWrapper.AppointmentWrapper> appWrapperList = new List<BLN_ProductAvailabilityWrapper.AppointmentWrapper>();
        List<ProductRequiredWrapper> productRequiredWrapperList= new List<ProductRequiredWrapper>();
        map<String,String> locationNameFromGuidMap = new map<String,String>();
        //FOUK-12289 Adding a new map for GUID-->Service territory
        map<String, ServiceTerritory> guidMapToST = new map<String, ServiceTerritory>();
        
        Order orderData = getAcceptedOrder(caseId);
        Set<String> partNumbersSet = new Set<String>();
        if( orderData != NULL ){
			Case cs = new Case();
			//Added a condition for portal User check
            Boolean isPortalUser = getPortalUserProfile();
			If(isPortalUser){
                case.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
				cs = [Select Id,BLN_CPQQuoteIdCollection__c from case where Id =: caseId   LIMIT 1];
			}
			else{
				cs = [Select Id,BLN_CPQQuoteIdCollection__c from case where Id =: caseId WITH SECURITY_ENFORCED LIMIT 1];
			}
            String payload = String.isBlank(currentPayload) ? getQuoteApi(cs.BLN_CPQQuoteIdCollection__c,caseId) : currentPayload;

            String locationId = orderData.BLN_ServiceTerritory__r.BLN_GUID__c;
            String externalQuoteId = orderData.BLN_CPQExternalQuoteId__c;
            String caseExternalIds = cs.BLN_CPQQuoteIdCollection__c;
            
            //location data start
            BLN_ProductResponseWrapper.ResponseProduct data = (BLN_ProductResponseWrapper.ResponseProduct) System.JSON.deserialize(payload,BLN_ProductResponseWrapper.ResponseProduct.class);
            
            Set<String> locationIds = new Set<String>();
            BLN_ProductAvailabilityRebook.LocationWrapper selectedLocationWrap = new BLN_ProductAvailabilityRebook.LocationWrapper(); 
        List<BLN_ProductAvailabilityWrapper.DisplayQuoteDetailsWrapper> quoteDetailsList = new List<BLN_ProductAvailabilityWrapper.DisplayQuoteDetailsWrapper>();
        for(BLN_ProductResponseWrapper.ResponseQuotes quoteVar : data.quotes){
            locationIds.add(quoteVar.locationId);
       }
            //Added a condition for portal User check
            If(isPortalUser){
                ServiceTerritory.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
				for(ServiceTerritory st : [Select Id, Name,BLN_GUID__c,BLN_Type__c From ServiceTerritory where BLN_GUID__c =: locationIds  ]){
					locationNameFromGuidMap.put(st.BLN_GUID__c,st.Name);
                    //FOUK-12289, populating map
                    guidMapToST.put(st.BLN_GUID__c, st);
				}
			}
			else{
        for(ServiceTerritory st : [Select Id, Name,BLN_GUID__c,BLN_Type__c From ServiceTerritory where BLN_GUID__c =: locationIds WITH SECURITY_ENFORCED]){
            locationNameFromGuidMap.put(st.BLN_GUID__c,st.Name);
                    //FOUK-12289, populating map
                    guidMapToST.put(st.BLN_GUID__c, st);
        }
			}
            /*for(ServiceTerritory st : [Select Id, Name,BLN_GUID__c,BLN_Type__c From ServiceTerritory where BLN_GUID__c =: locationIds WITH SECURITY_ENFORCED]){
                locationNameFromGuidMap.put(st.BLN_GUID__c,st.Name);
            }*/

            for(BLN_ProductResponseWrapper.ResponseQuotes quoteVar : data.quotes){
                BLN_ProductAvailabilityWrapper.DisplayQuoteDetailsWrapper displayDetailsData = new BLN_ProductAvailabilityWrapper.DisplayQuoteDetailsWrapper();
                displayDetailsData.quoteId = quoteVar.quoteId;
                if(locationNameFromGuidMap.containsKey(quoteVar.locationId)){
                displayDetailsData.quotelocation = locationNameFromGuidMap.get(quoteVar.locationId);
                    //FOUK-12289, Add isMobileLocation parameter
                    displayDetailsData.isMobileLocation = guidMapToST.get(quoteVar.locationId).BLN_Type__c == 'Mobile' ? true : false;
                }
                displayDetailsData.quoteTotal = quoteVar.quoteTotals.totalPrice;
                displayDetailsData.locationGUID = quoteVar.locationId;
                displayDetailsData.quoteVAT = quoteVar.quoteTotals.totaltax;
                displayDetailsData.quoteNetTotal = quoteVar.quoteTotals.totalIncludingTax;
                quoteDetailsList.add(displayDetailsData);
                
                if(orderData.BLN_ServiceTerritory__r.BLN_GUID__c == quoteVar.locationId){
                    LocationWrapper locations = new LocationWrapper();locations.locationGUID = quoteVar.locationId;locations.quoteId = quoteVar.quoteId;locations.quotelocation = locationNameFromGuidMap.get(quoteVar.locationId);locations.isMobileLocation = (orderData.BLN_ServiceTerritory__r.BLN_Type__c == System.label.BLN_Mobile? true:false);locations.quoteTotal = quoteVar.quoteTotals.totalPrice;locations.quoteVAT = quoteVar.quoteTotals.totaltax;locations.quoteNetTotal = quoteVar.quoteTotals.totalIncludingTax;selectedLocationWrap = locations;
                }
        }
        //location data end
        
            List<BLN_ProductAvailabilityWrapper.EarliestAvailabilityDetailsWrapper> earliestAvailabilityDateList = getEarliestDateList(payload, caseId);
        List<BLN_ProductAvailabilityWrapper.InsuranceLiabilityWrapper> liabilityList = getLiabilityList(payload,orderData.BLN_CPQExternalQuoteId__c);
        
        Map<Id,List<OrderItem>> serviceAppointmentOrderItemsMap = new Map<Id,List<OrderItem>>();
            List<OrderItem> orderItemList = new List<OrderItem>();
            List<OrderItemDetails> allItemsDetails = new List<OrderItemDetails>();
			List<OrderItem> allOrderItemList = new List<OrderItem>();
			//Added a condition for portal User check
            If(isPortalUser){
                OrderItem.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
				allOrderItemList = [SELECT  Id,Product2.BLN_MDMID__c, Product2.Name,Product2.Description,Product2.BLN_ProductCategory__c,Product2.ProductCode, 
                                                        OrderId, BLN_StockStatus__c,Quantity, UnitPrice, TotalPrice, EndDate,BLN_BundleName__c,BLN_BOMID__c,
                                                        BLN_IsProductSelected__c,BLN_TotalTax__c,BLN_NetPriceAfterPromotion__c,BLN_NetPriceIncludingTax__c,BLN_Optional__c,
                                                        BLN_ServiceAppointment__c,BLN_FittingLocation__r.Name,BLN_FittingLocation__r.BLN_GUID__c,BLN_DocumentNumber__c,
                                                        BLN_LeadingPartIndicator__c,BLN_ParentDocumentNumber__c
                                                FROM OrderItem where orderId =:orderData.Id  ];
			}
			else{
				allOrderItemList = [SELECT  Id,Product2.BLN_MDMID__c, Product2.Name,Product2.Description,Product2.BLN_ProductCategory__c,Product2.ProductCode, 
                                            OrderId, BLN_StockStatus__c,Quantity, UnitPrice, TotalPrice, EndDate,BLN_BundleName__c,BLN_BOMID__c,
                                            BLN_IsProductSelected__c,BLN_TotalTax__c,BLN_NetPriceAfterPromotion__c,BLN_NetPriceIncludingTax__c,BLN_Optional__c,
                                            BLN_ServiceAppointment__c,BLN_FittingLocation__r.Name,BLN_FittingLocation__r.BLN_GUID__c,BLN_DocumentNumber__c,
                                            BLN_LeadingPartIndicator__c,BLN_ParentDocumentNumber__c  
                                                FROM OrderItem where orderId =:orderData.Id WITH SECURITY_ENFORCED];
			}
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
                                where orderId =:orderData.Id WITH SECURITY_ENFORCED];
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
                                        FROM OrderItem where orderId =:orderData.Id AND BLN_IsProductSelected__c = true WITH SECURITY_ENFORCED];

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
                prod.productCode = orderItems.Product2.BLN_MDMID__c;
                prod.prodCategory = orderItems.Product2.BLN_ProductCategory__c;
                prod.bomId = orderItems.BLN_BOMID__c;
                prod.bundleName = orderItems.BLN_BundleName__c;
                prod.leadingProductIndicator = orderItems.BLN_LeadingPartIndicator__c;
                prod.productDescription = orderItems.Product2.Description;
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
        map<String,String> locationGuIDMap = new map<String,String>();
        Integer i = 1;
        Integer keyIndex = 0;
        Set<Id> workorderlineItemIds= new Set<Id>();
			List<ServiceAppointment> serviceAppts = new List<ServiceAppointment>();
			//Added a condition for portal User check
            If(isPortalUser){
                ServiceAppointment.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
				serviceAppts  = [Select Id,ServiceTerritoryId,ParentRecordId,ServiceTerritory.Name,ServiceTerritory.BLN_GUID__c,
                                                        ServiceTerritory.BLN_Type__c,ArrivalWindowStartTime,ArrivalWindowEndTime,SchedStartTime,Status 
                                                        from ServiceAppointment 
                                                        where Id IN : serviceAppointmentOrderItemsMap.keySet()];
			}
			else{
				serviceAppts  = [Select Id,ServiceTerritoryId,ParentRecordId,ServiceTerritory.Name,ServiceTerritory.BLN_GUID__c,
                                                    ServiceTerritory.BLN_Type__c,ArrivalWindowStartTime,ArrivalWindowEndTime,SchedStartTime,Status 
                                                    from ServiceAppointment 
                                                    where Id IN : serviceAppointmentOrderItemsMap.keySet() WITH SECURITY_ENFORCED];
			}   
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
            }
            locationGuIDMap.put(locationGUID,locationName);

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
            appData.locationName = serviceAppt.ServiceTerritory.Name;
            appData.isFirstAppointment = true;
            appData.earlierAvailabilityDateHeader = null;
            appData.slotSelectedDate = result;
            appData.serviceAppointmentId = serviceAppt.Id;
                appData.serviceAppointmentIdAccepted = serviceAppt.Id;
            appData.slotDate = null;
            appData.slotTime = null;
            appData.isDropOff = 'false';
            appData.slotDateTimeStart = String.valueOf(serviceAppt.ArrivalWindowStartTime);
            appData.slotDateTimeFinish = String.valueOf(serviceAppt.ArrivalWindowEndTime);
            appData.schedStartTime = serviceAppt.SchedStartTime;
            appData.productAvailibilities = productAvailibilitiesList;
            appData.status=serviceAppt.Status;
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

			List<ProductRequired> prodRequiredList= new List<ProductRequired>();
			//Added a condition for portal User check
            If(isPortalUser){
                ProductRequired.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
				prodRequiredList=[Select Id,ParentRecordId,BLN_IsConsumed__c,Product2Id, BLN_ProductCode__c, BLN_OLIKey__c
                                                    from ProductRequired
                                                    where ParentRecordId IN : workorderlineItemIds   ];
			}
			else{
				prodRequiredList=[Select Id,ParentRecordId,BLN_IsConsumed__c,Product2Id, BLN_ProductCode__c, BLN_OLIKey__c
                                                from ProductRequired
                                                where ParentRecordId IN : workorderlineItemIds  WITH SECURITY_ENFORCED];
			}
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
            returnData.orderId = orderData.Id;
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
		//Added a condition for portal User check
        Boolean isPortalUser = getPortalUserProfile();
        If(isPortalUser){
            for(BLN_ProductResponseWrapper.ResponseQuotes quoteVar : data.quotes){
                for(BLN_ProductResponseWrapper.ResponseLineItems lineItem : quoteVar.lineItems){
                    if(lineItem != null && lineItem.partNumber != null && lineItem.partNumber != ''){
                        partNumberSet.add(lineItem.partNumber);
                    }
                }
            }
            Map<String,Product2> mdmIdVsProductsMap = new Map<String,Product2>();
            Product2.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
            for(Product2 prod : [SELECT Id, Name, BLN_MDMID__c, BLN_BusinessUnitSpecificBranchOnly__c, BLN_ProductCategory__c, BLN_ProductStockable__c,BLN_BondedNonBonded__c FROM Product2 WHERE isActive = true AND  BLN_MDMID__c IN :partNumberSet  ]){
                mdmIdVsProductsMap.put(prod.BLN_MDMID__c,prod);
            }
            //Integer bufferDaysToAdd = BLN_ProductAvailabilityUtility.bufferCalculation(caseId);
            for(BLN_ProductResponseWrapper.ResponseQuotes quoteVar : data.quotes){
                for(BLN_ProductResponseWrapper.ResponseLineItems lineItem : quoteVar.lineItems){
                    BLN_ProductAvailabilityWrapper.EarliestAvailabilityDetailsWrapper earliestAvailabilityVar = new BLN_ProductAvailabilityWrapper.EarliestAvailabilityDetailsWrapper();
                    earliestAvailabilityVar.quoteId = quoteVar.quoteId;
                    earliestAvailabilityVar.locationId = quoteVar.locationId;
                    earliestAvailabilityVar.mdmId = lineItem.partNumber != null ? lineItem.partNumber : '';
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
        }
        else{
        Integer noStockBuffer = Integer.valueOf(System.label.BLN_NoStockBufferPeriod);
        Integer pricingThemeBuffer = BLN_ProductAvailabilityUtility.pricingThemeBuffer(caseId);

        Integer provisionalBuffer = BLN_ProductAvailabilityUtility.bufferCalculation(caseId);
        Integer accRuleBUffer = BLN_ProductAvailabilityUtility.accRuleBuffer(data,caseId);        

        Integer largestJobBuffer =  accRuleBUffer > provisionalBuffer ? accRuleBUffer : provisionalBuffer;

        for(BLN_ProductResponseWrapper.ResponseQuotes quoteVar : data.quotes){
            for(BLN_ProductResponseWrapper.ResponseLineItems lineItem : quoteVar.lineItems){
                if(lineItem != null && lineItem.partNumber != null && lineItem.partNumber != ''){
                    partNumberSet.add(lineItem.partNumber);
                }
            }
        }
        partNumberSet.add(System.label.BLN_Bundle);
        
        Map<String,Product2> mdmIdVsProductsMap = new Map<String,Product2>();
        for(Product2 prod : [SELECT Id, Name, BLN_MDMID__c, BLN_BusinessUnitSpecificBranchOnly__c, BLN_ProductCategory__c, BLN_ProductStockable__c,BLN_BondedNonBonded__c FROM Product2 WHERE isActive = true AND  BLN_MDMID__c IN :partNumberSet WITH SECURITY_ENFORCED]){
            mdmIdVsProductsMap.put(prod.BLN_MDMID__c,prod);
        }
            
            /*for(Product2 prod : [SELECT Id, Name, BLN_MDMID__c, BLN_BusinessUnitSpecificBranchOnly__c, BLN_ProductCategory__c, BLN_ProductStockable__c,BLN_BondedNonBonded__c FROM Product2 WHERE isActive = true AND  BLN_MDMID__c IN :partNumberSet WITH SECURITY_ENFORCED]){
System.debug('prod.BLN_MDMID__c'+prod.BLN_MDMID__c+'-->   '+prod.BLN_ProductStockable__c);
mdmIdVsProductsMap.put(prod.BLN_MDMID__c,prod);
}*/
            
        for(BLN_ProductResponseWrapper.ResponseQuotes quoteVar : data.quotes){
            for(BLN_ProductResponseWrapper.ResponseLineItems lineItem : quoteVar.lineItems){
                BLN_ProductAvailabilityWrapper.EarliestAvailabilityDetailsWrapper earliestAvailabilityVar = new BLN_ProductAvailabilityWrapper.EarliestAvailabilityDetailsWrapper();
                earliestAvailabilityVar.quoteId = quoteVar.quoteId;
                earliestAvailabilityVar.locationId = quoteVar.locationId;
                earliestAvailabilityVar.mdmId = earliestAvailabilityVar.productCode = lineItem.partNumber != null ? lineItem.partNumber : '';
                earliestAvailabilityVar.bundleName = lineItem.bundleName != null ? lineItem.bundleName : '';
                earliestAvailabilityVar.bomId = lineItem.parentBOMId != null ? lineItem.parentBOMId : '';
                earliestAvailabilityVar.leadingProductIndicator = lineItem.leadingProductIndicator;
                earliestAvailabilityVar.lineItemId = lineItem.lineItemId;
                earliestAvailabilityVar.isSelected = lineItem.selectProduct;
                earliestAvailabilityVar.isStockableProduct = lineItem.partNumber != null ? mdmIdVsProductsMap.containsKey(lineItem.partNumber) ? mdmIdVsProductsMap.get(lineItem.partNumber).BLN_ProductStockable__c : false : lineItem.bundleName != null ? mdmIdVsProductsMap.get(System.label.BLN_Bundle).BLN_ProductStockable__c : false;
                    //earliestAvailabilityVar.bufferAdded = 0;
                 
                earliestAvailabilityVar.earliestDateList = new List<BLN_ProductResponseWrapper.ResponseAvailabilityDetails>();
                
                if( lineItem.availabilityDetails != null && !lineItem.availabilityDetails.isEmpty() ){
                    for(BLN_ProductResponseWrapper.ResponseAvailabilityDetails availDetail : lineItem.availabilityDetails){

                        noStockBuffer = noStockBuffer > largestJobBuffer ? noStockBuffer : largestJobBuffer;
                        pricingThemeBuffer = pricingThemeBuffer > largestJobBuffer ? pricingThemeBuffer : largestJobBuffer;
                        Integer largestLineBuffer = noStockBuffer > pricingThemeBuffer ? noStockBuffer : pricingThemeBuffer;
                        List<Integer> bufferList = new List<Integer>();
                        bufferList.add(0);
                       //Added By Shailendra:                      
                       availDetail.isOutOfStock = lineItem.partNumber != null && mdmIdVsProductsMap.containsKey(lineItem.partNumber) && mdmIdVsProductsMap.get(lineItem.partNumber) != null && mdmIdVsProductsMap.get(lineItem.partNumber).BLN_ProductStockable__c && (String.isBlank(availDetail.availableFromDate) || availDetail.availableFromDate == null)  ? true : false;
                        
                        if((lineItem.poaStatus != 'NA' || lineItem.priceFound == false) && availDetail.isOutOfStock){
                            bufferList.add(largestLineBuffer);     
                                //availDetail.availableFromDate = availDetail.availableFromDate == null || availDetail.availableFromDate == '' ? String.valueOf(DateTime.newInstance(System.now().date().addDays(largestLineBuffer),System.now().time()).format('YYYY-MM-dd\'T\'HH:mm:ssXXX')) : String.valueOf(((DateTime)JSON.deserialize('"'+availDetail.availableFromDate+'"',DateTime.class)).addDays(largestLineBuffer));
                        }
                        else if((lineItem.poaStatus != 'NA' || lineItem.priceFound == false) && !availDetail.isOutOfStock){
                            bufferList.add(pricingThemeBuffer);
                                //availDetail.availableFromDate = availDetail.availableFromDate == null || availDetail.availableFromDate == '' ? String.valueOf(DateTime.newInstance(System.now().date().addDays(pricingThemeBuffer),System.now().time()).format('YYYY-MM-dd\'T\'HH:mm:ssXXX')) : String.valueOf(((DateTime)JSON.deserialize('"'+availDetail.availableFromDate+'"',DateTime.class)).addDays(pricingThemeBuffer));
                        }
                        else if(lineItem.poaStatus == 'NA' && lineItem.priceFound == true) {
                            Integer buffer = availDetail.availableFromDate == null || availDetail.availableFromDate == '' ? noStockBuffer : largestJobBuffer;
                            bufferList.add(buffer);
                        }

                        bufferList.sort();
                        Integer appliedBuffer = bufferList[bufferList.size() - 1];
                            availDetail.availableFromDate = availDetail.availableFromDate == null || availDetail.availableFromDate == '' ? String.valueOf(DateTime.newInstance(System.now().date().addDays(appliedBuffer),System.now().time()).format('YYYY-MM-dd\'T\'HH:mm:ssXXX')) : availDetail.availableFromDate.contains('T') ? String.valueOf(DateTime.valueOf(availDetail.availableFromDate.split('T')[0]+' '+availDetail.availableFromDate.split('T')[1]).addDays(appliedBuffer)) : String.valueOf(DateTime.valueOf(availDetail.availableFromDate).addDays(appliedBuffer));                            

                        earliestAvailabilityVar.earliestDateList.add(availDetail);
                    }
                    
                }
                    else if(String.isNotBlank(lineItem.bundleName) && lineItem.lineItemId == lineitem.parentLineItemId){
                    Map<String,BLN_ProductResponseWrapper.ResponseAvailabilityDetails> locIDCategoryMap = new Map<String,BLN_ProductResponseWrapper.ResponseAvailabilityDetails>();
                    for(BLN_ProductResponseWrapper.ResponseLineItems lineItemChild : quoteVar.lineItems){
                        if( String.isNotBlank(lineItemChild.bundleName) && lineItemChild.lineItemId != lineItemChild.parentLineItemId &&  lineItemChild.availabilityDetails != null && !lineItemChild.availabilityDetails.isEmpty() && lineItem.bundleName == lineItemChild.bundleName ){                            
                            for(BLN_ProductResponseWrapper.ResponseAvailabilityDetails availDetail : lineItemChild.availabilityDetails){

                                noStockBuffer = noStockBuffer > largestJobBuffer ? noStockBuffer : largestJobBuffer;
                                pricingThemeBuffer = pricingThemeBuffer > largestJobBuffer ? pricingThemeBuffer : largestJobBuffer;
                                Integer largestLineBuffer = noStockBuffer > pricingThemeBuffer ? noStockBuffer : pricingThemeBuffer;
                                List<Integer> bufferList = new List<Integer>();
                                bufferList.add(0);
                
                                availDetail.isOutOfStock = mdmIdVsProductsMap.containsKey(lineItemChild.partNumber) && mdmIdVsProductsMap.get(lineItemChild.partNumber).BLN_ProductStockable__c != null && mdmIdVsProductsMap.get(lineItemChild.partNumber).BLN_ProductStockable__c && (String.isBlank(availDetail.availableFromDate) || availDetail.availableFromDate == null) ? true : false;

                                if((lineItem.poaStatus != 'NA' || lineItem.priceFound == false) && availDetail.isOutOfStock){
                                    bufferList.add(largestLineBuffer);     
                                        //availDetail.availableFromDate = availDetail.availableFromDate == null || availDetail.availableFromDate == '' ? String.valueOf(DateTime.newInstance(System.now().date().addDays(largestLineBuffer),System.now().time()).format('YYYY-MM-dd\'T\'HH:mm:ssXXX')) : String.valueOf(((DateTime)JSON.deserialize('"'+availDetail.availableFromDate+'"',DateTime.class)).addDays(largestLineBuffer));
                                }
                                else if((lineItem.poaStatus != 'NA' || lineItem.priceFound == false) && !availDetail.isOutOfStock){
                                    bufferList.add(pricingThemeBuffer);
                                        //availDetail.availableFromDate = availDetail.availableFromDate == null || availDetail.availableFromDate == '' ? String.valueOf(DateTime.newInstance(System.now().date().addDays(pricingThemeBuffer),System.now().time()).format('YYYY-MM-dd\'T\'HH:mm:ssXXX')) : String.valueOf(((DateTime)JSON.deserialize('"'+availDetail.availableFromDate+'"',DateTime.class)).addDays(pricingThemeBuffer));
                                }
                                else if(lineItem.poaStatus == 'NA' && lineItem.priceFound == true) {
                                    Integer buffer = availDetail.availableFromDate == null || availDetail.availableFromDate == '' ? noStockBuffer : largestJobBuffer;
                                    bufferList.add(buffer);
                                }

                                bufferList.sort();
                                Integer appliedBuffer = bufferList[bufferList.size() - 1];
                                    availDetail.availableFromDate = availDetail.availableFromDate == null || availDetail.availableFromDate == '' ? String.valueOf(DateTime.newInstance(System.now().date().addDays(appliedBuffer),System.now().time()).format('YYYY-MM-dd\'T\'HH:mm:ssXXX')) : availDetail.availableFromDate.contains('T') ? String.valueOf(DateTime.valueOf(availDetail.availableFromDate.split('T')[0]+' '+availDetail.availableFromDate.split('T')[1]).addDays(appliedBuffer)) : String.valueOf(DateTime.valueOf(availDetail.availableFromDate.split('T')[0]+' '+availDetail.availableFromDate.split('T')[1]).addDays(appliedBuffer));                            
                                    while(!locIDCategoryMap.containsKey(availDetail.stockLocationId) || (String.isNotBlank(availDetail.availableFromDate) && String.isNotBlank(locIDCategoryMap.get(availDetail.stockLocationId).availableFromDate) && Date.valueOf(availDetail.availableFromDate) > Date.valueOf(locIDCategoryMap.get(availDetail.stockLocationId).availableFromDate)) ){                                   
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
                
                
                // if( lineItem.availabilityDetails != null && !lineItem.availabilityDetails.isEmpty() ){
                //     for(BLN_ProductResponseWrapper.ResponseAvailabilityDetails availDetail : lineItem.availabilityDetails){
                //         //Added By Shailendra:
                //         availDetail.isOutOfStock = lineItem.partNumber != null && mdmIdVsProductsMap.containsKey(lineItem.partNumber) && mdmIdVsProductsMap.get(lineItem.partNumber) != null && mdmIdVsProductsMap.get(lineItem.partNumber).BLN_ProductStockable__c && (String.isBlank(availDetail.availableFromDate) || availDetail.availableFromDate == null)  ? true : false;
                //         System.debug('availDetail-->'+availDetail.availableFromDate+'  oos-->'+availDetail.isOutOfStock);
                //         availDetail.availableFromDate = availDetail.availableFromDate == null || availDetail.availableFromDate == ''? String.valueOf(System.now().date()) : availDetail.availableFromDate;
                //         availDetail.availableFromDate =  availDetail.isOutOfStock ? System.now().addDays(Integer.valueOf(System.label.BLN_NoStockBufferPeriod)).format('YYYY-MM-dd\'T\'HH:mm:ssXXX') : availDetail.availableFromDate == String.valueOf(System.now().date()) ? String.valueOf(DateTime.newInstance(System.now().date().addDays(bufferDaysToAdd),System.now().time()).format('YYYY-MM-dd\'T\'HH:mm:ssXXX'))  : String.valueOf(DateTime.newInstance(Date.valueOf(availDetail.availableFromDate).addDays(bufferDaysToAdd),System.now().time()).format('YYYY-MM-dd\'T\'HH:mm:ssXXX'));
                //         earliestAvailabilityVar.earliestDateList.add(availDetail);
                //     }
                // }else if( String.isNotBlank(lineItem.bundleName) && lineItem.lineItemId == lineItem.parentLineItemId ){
                //     //calculate date for bundle products based on child products..
                //     Map<String,BLN_ProductResponseWrapper.ResponseAvailabilityDetails> locIDCategoryMap = new Map<String,BLN_ProductResponseWrapper.ResponseAvailabilityDetails>();
                //     for(BLN_ProductResponseWrapper.ResponseLineItems lineItemChild : quoteVar.lineItems){
                //         if( String.isNotBlank(lineItemChild.bundleName) && lineItemChild.lineItemId != lineItemChild.parentLineItemId &&  lineItemChild.availabilityDetails != null && !lineItemChild.availabilityDetails.isEmpty() && lineItem.bundleName == lineItemChild.bundleName ){
                            
                //             for(BLN_ProductResponseWrapper.ResponseAvailabilityDetails availDetail : lineItemChild.availabilityDetails){
                //                 availDetail.isOutOfStock = mdmIdVsProductsMap.containsKey(lineItemChild.partNumber) && mdmIdVsProductsMap.get(lineItemChild.partNumber).BLN_ProductStockable__c != null && mdmIdVsProductsMap.get(lineItemChild.partNumber).BLN_ProductStockable__c && (String.isBlank(availDetail.availableFromDate) || availDetail.availableFromDate == null) ? true : false;
                //                 availDetail.availableFromDate = availDetail.availableFromDate == null || availDetail.availableFromDate == '' ? String.valueOf(System.now().date()) : availDetail.availableFromDate;
                //                  availDetail.availableFromDate =  availDetail.isOutOfStock ? System.now().addDays(Integer.valueOf(System.label.BLN_NoStockBufferPeriod)).format('YYYY-MM-dd\'T\'HH:mm:ssXXX') : availDetail.availableFromDate == String.valueOf(System.now().date()) ? String.valueOf(DateTime.newInstance(System.now().date(),System.now().time()).format('YYYY-MM-dd\'T\'HH:mm:ssXXX'))  : String.valueOf(DateTime.newInstance(Date.valueOf(availDetail.availableFromDate),System.now().time()).format('YYYY-MM-dd\'T\'HH:mm:ssXXX'));
                //                 while( !locIDCategoryMap.containsKey(availDetail.stockLocationId) || (String.isNotBlank(availDetail.availableFromDate) && String.isNotBlank(locIDCategoryMap.get(availDetail.stockLocationId).availableFromDate) && Date.valueOf(availDetail.availableFromDate) > Date.valueOf(locIDCategoryMap.get(availDetail.stockLocationId).availableFromDate)) ){                                   
                //                     locIDCategoryMap.put(availDetail.stockLocationId, availDetail);
                //                     break;
                //                     }       
                //                 }
                            
                //         }
                //     }

                //     for( String locationId : locIDCategoryMap.keySet()){
                //         earliestAvailabilityVar.earliestDateList.add(locIDCategoryMap.get(locationId));
                //     }
                // }
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
        }
        return earliestDatesList;
    }



    //Get selectedProductList & get addOnProdList
    public static List<List<BLN_ProductAvailabilityWrapper.ProductSelectionWrapper>> getAllSelectedProductLists(String orderId){
		//Added a condition for portal User check
        Boolean isPortalUser = getPortalUserProfile();
        If(isPortalUser){
            Order.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
            OrderItem.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
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
        else{
            
        Order ord = [SELECT Id,BLN_CPQExternalQuoteId__c,
                            (SELECT Id,BLN_DocumentNumber__c,BLN_ParentDocumentNumber__c,BLN_BOMID__c,BLN_BundleName__c,
                                    BLN_LeadingPartIndicator__c,Product2.BLN_ProductCategory__c,Quantity,BLN_NetPriceAfterPromotion__c,BLN_NetPriceIncludingTax__c,
                                     BLN_TaxRate__c,Product2.BLN_MDMID__c,Product2.Name,Product2.Description,Product2.ProductCode
                            FROM OrderItems 
                            WHERE BLN_IsProductSelected__c = true) 
                    FROM Order 
                    WHERE BLN_CPQExternalQuoteId__c = :orderId WITH SECURITY_ENFORCED LIMIT 1];

            List<BLN_ProductIdentifier__mdt> productIdentifierListHideOnUI = new List<BLN_ProductIdentifier__mdt>();
            
            productIdentifierListHideOnUI = [SELECT Id,BLN_ProductCode__c,BLN_Type__c FROM BLN_ProductIdentifier__mdt WHERE BLN_Type__c ='HIDE ON UI' WITH SECURITY_ENFORCED];
            
            //productIdentifierList_hideOnUI = [SELECT Id,BLN_ProductCode__c,BLN_Type__c FROM BLN_ProductIdentifier__mdt WHERE BLN_Type__c ='HIDE ON UI' WITH SECURITY_ENFORCED];  
    Map<String,Boolean> hideOnUIMap = new Map<String,Boolean>();
            for(BLN_ProductIdentifier__mdt prodIdentifier : productIdentifierListHideOnUI){
        hideOnUIMap.put(prodIdentifier.BLN_ProductCode__c,true);
    }
                
        List<BLN_ProductAvailabilityWrapper.ProductSelectionWrapper> selectedProdsList = new List<BLN_ProductAvailabilityWrapper.ProductSelectionWrapper>();
        List<BLN_ProductAvailabilityWrapper.ProductSelectionWrapper> addOnProdsList = new List<BLN_ProductAvailabilityWrapper.ProductSelectionWrapper>();
        List<BLN_ProductAvailabilityWrapper.ProductSelectionWrapper> hiddenProdsList = new List<BLN_ProductAvailabilityWrapper.ProductSelectionWrapper>();

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
            prod.mdmId = prod.productCode = oi.Product2.BLN_MDMID__c;
            prod.belronProductCode = oi.Product2.ProductCode != null ? oi.Product2.ProductCode : '';
            prod.productName = oi.Product2.Name;
            prod.productDescription = oi.Product2.Description;
            prod.hierarchy = '';
            prod.partOfBundle = false;
            prod.orderItemId = oi.id;

            if(hideOnUIMap.containsKey(prod.belronProductCode)){
                hiddenProdsList.add(prod);
            }
            else if(String.isNotBlank(oi.BLN_BOMID__c)){
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
        
    }
	
	/** @description : getPortalUserProfile method to get portal user for Portal Login Check
    * @param : No param
    * @return : Boolean
    */
   public static Boolean getPortalUserProfile(){
        Boolean result = (UserInfo.getUserType() == 'CustomerSuccess' || UserInfo.getUserType() == 'CspLitePortal' || UserInfo.getUserType() == 'PowerCustomerSuccess') ? true : false;
       	return result;
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
        @auraEnabled
        public Id orderId;
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