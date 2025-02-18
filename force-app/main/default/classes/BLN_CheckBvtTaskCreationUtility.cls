/**@description : This Apex class used to check if BVT task is created or not and also checks for Data collect quality parameter.
*  @author: PwC India
*  @Story: 
*  @CreatedDate: 08/11/2024  **/
public with sharing class BLN_CheckBvtTaskCreationUtility {

    public static String insuranceSiteId = null;
    public static String corporateSiteId = null;

        /* MethodName : checkBvtTaskCreation
            Description : This method is used to check if any BVT task or data collect task created or not.
            Input Parameter : String payload, String caseId
            Output Parameter : Boolean result
            CreatedDate: 08-11-2024
            CreatedBy : Pwc-India
            Change log :
            ****************************************/
    /*  *@description:This method is used to check if any BVT task or data collect task created or not. */
    public static Boolean checkBvtTaskCreation(String payload, String caseId){
        Boolean result = false;
        Boolean oeCheckBoolean = false;
        Boolean covergaVerification = false;
        Boolean productAuthCheckBoolean = false;
        Boolean productAllowanceCheckBoolean = false;
        Boolean checkDataCollect = false;
        BLN_Corporate__c corporateRecord;
        Set<BLN_ProductResponseWrapper.ResponseLineItems> selectedProductSet = new Set<BLN_ProductResponseWrapper.ResponseLineItems>();
        List<BLN_ProductResponseWrapper.ResponseLineItems> selectedProductList = new List<BLN_ProductResponseWrapper.ResponseLineItems>();
        try {
            BLN_ProductResponseWrapper.ResponseProduct data = (BLN_ProductResponseWrapper.ResponseProduct) System.JSON.deserialize(payload, BLN_ProductResponseWrapper.ResponseProduct.class);
            //Get corporate record from case
            Case caseRecord = [SELECT Id, BLN_Corporate__c,BLN_CoverageVerificationTheme__c FROM Case WHERE Id = :caseId WITH SECURITY_ENFORCED LIMIT 1];
            if(caseRecord != null && caseRecord.BLN_Corporate__c!=null){
                corporateRecord = [SELECT Id, BLN_OEAuthorizationRequired__c, BLN_OEAuthorized__c, BLN_OEAuthorizationRequiredTrade__c,
                                        BLN_OEAuthorizedTrade__c, BLN_AmountAuthorized__c, BLN_AmountAuthorizedTrade__c,
                                        BLN_ApprovedLimit__c, BLN_AuthorizationStatus__c, BLN_AuthorizationStatusTrade__c,
                                        BLN_AmountAuthorizationRequired__c, BLN_AmountAuthorizationRequiredTrade__c, BLN_Origin__c,
                                        BLN_CHFVATStatus__c, BLN_ProductAuthorised__c, BLN_ProductAuthorisedTrade__c, 
                                        BLN_CorporateSite__c, BLN_InsuranceSite__c, RecordType.DeveloperName, BLN_InsuranceLegalEntity__c,
                                        BLN_CorporateLegalEntity__c FROM BLN_Corporate__c 
                                        WHERE Id =:caseRecord.BLN_Corporate__c WITH SECURITY_ENFORCED limit 1];
            }
            //get selected products
            for(BLN_ProductResponseWrapper.ResponseQuotes quote: data.quotes){
                for(BLN_ProductResponseWrapper.ResponseLineItems lineItem: quote.lineItems){
                    if(lineItem.selectProduct == true){
                        selectedProductSet.add(lineItem);
                    }
                }
            }
            
            selectedProductList.addAll(selectedProductSet);

            if(corporateRecord != null){
                //Call mehtod to set account ids
                setAccountId(corporateRecord);
                //call all methods here.
                //call to set site id
                oeCheckBoolean = checkForOEAuthorized(corporateRecord, selectedProductList);
                productAuthCheckBoolean = checkAuthorizedLimit(corporateRecord, data);
                productAllowanceCheckBoolean = checkProductAllowance(corporateRecord, selectedProductList);
                checkDataCollect = checkDataCollectTask(corporateRecord, caseId);
                covergaVerification =  !caseRecord.BLN_CoverageVerificationTheme__c;
            }
            if(oeCheckBoolean == true || productAuthCheckBoolean == true || productAllowanceCheckBoolean == true || checkDataCollect == true ||  covergaVerification == true){
                result = true;
            }
        } catch (Exception e) {
            BLN_ExceptionLogger.captureException(e);
        }
        return result;
    }

    /* MethodName : setAccountId
            Description : This method is used to set corporate site ids based on record type of corporate.
            Input Parameter : BLN_Corporate__c corporateRecord
            Output Parameter : 
            CreatedDate: 26-11-2024
            CreatedBy : Pwc-India
            Change log :
            ****************************************/
    /*  *@description:This method is used to set corporate site ids based on record type of corporate. */
    public static void setAccountId(BLN_Corporate__c corporateRecord){
        if(corporateRecord.BLN_InsuranceSite__c != null && corporateRecord.RecordType.DeveloperName == System.Label.BLN_Insurance){
            insuranceSiteId = corporateRecord.BLN_InsuranceSite__c;
        } else if(corporateRecord.BLN_CorporateSite__c != null && corporateRecord.RecordType.DeveloperName == System.Label.BLN_CorporateFleet){
            corporateSiteId = corporateRecord.BLN_CorporateSite__c;
        } else if(corporateRecord.BLN_CorporateSite__c != null && corporateRecord.BLN_InsuranceSite__c != null && corporateRecord.RecordType.DeveloperName == System.Label.BLN_SpiltBill){
            insuranceSiteId = corporateRecord.BLN_InsuranceSite__c;
            corporateSiteId = corporateRecord.BLN_CorporateSite__c;
        } else if(corporateRecord.BLN_CorporateSite__c == null && corporateRecord.BLN_InsuranceSite__c != null && corporateRecord.RecordType.DeveloperName == System.Label.BLN_SpiltBill){
            insuranceSiteId = corporateRecord.BLN_InsuranceSite__c;
        } else if(corporateRecord.BLN_CorporateSite__c != null && corporateRecord.BLN_InsuranceSite__c == null && corporateRecord.RecordType.DeveloperName == System.Label.BLN_SpiltBill){
            corporateSiteId = corporateRecord.BLN_CorporateSite__c;
        } 
    }

    /* MethodName : setAccocheckForOEAuthorizeduntId
            Description : This method is used to check OE authorized ARP.
            Input Parameter : BLN_Corporate__c corporateRecord, List<BLN_ProductResponseWrapper.ResponseLineItems> selectedProductList
            Output Parameter : Boolean result
            CreatedDate: 08-11-2024
            CreatedBy : Pwc-India
            Change log :
            ****************************************/
    /*  *@description:This method is used to check OE authorized ARP.*/
    public static Boolean checkForOEAuthorized(BLN_Corporate__c corporateRecord, List<BLN_ProductResponseWrapper.ResponseLineItems> selectedProductList){
        Boolean result = false;
        Boolean isBondedNonBonded = false;
        Set<String> partNumberSet = new Set<String>();
        List<BLN_AccountRuleParameter__c> arpRecords = new List<BLN_AccountRuleParameter__c>();
        List<BLN_AccountRuleParameter__c> arpRecords1 = new List<BLN_AccountRuleParameter__c>();
        try {
            
            for(BLN_ProductResponseWrapper.ResponseLineItems lineItem: selectedProductList){
                    partNumberSet.add(lineItem.partNumber);
            }

            Map<String, Product2> productMap = new Map<String, Product2>();
            List<Product2> productList = [SELECT Id, BLN_MDMID__c, BLN_BondedNonBonded__c FROM Product2 WHERE BLN_MDMID__c IN :partNumberSet WITH SECURITY_ENFORCED];
            for(Product2 product: productList){
                productMap.put(product.BLN_MDMID__c, product);
            }

            //check size and is bonded param
            if(selectedProductList != null && selectedProductList.size() > 0){
                for(BLN_ProductResponseWrapper.ResponseLineItems lineItem: selectedProductList){
                    if(productMap.containsKey(lineItem.partNumber) && productMap.get(lineItem.partNumber).BLN_BondedNonBonded__c == true){
                        isBondedNonBonded = true;
                        break;
                    }
                }
            }
            Date jobDate = Date.today();
            if(isBondedNonBonded == true && corporateRecord.RecordType.DeveloperName == System.Label.BLN_Insurance){
                    arpRecords = BLN_AccountRuleParameterUtil.getAccountRuleParameters(System.Label.BLN_OEAuthorizationLabel, insuranceSiteId, jobDate);
            } else if(isBondedNonBonded == true && corporateRecord.RecordType.DeveloperName == System.Label.BLN_CorporateFleet){
                arpRecords = BLN_AccountRuleParameterUtil.getAccountRuleParameters(System.Label.BLN_OEAuthorizationLabel, corporateSiteId, jobDate);
            } else if(isBondedNonBonded == true && corporateRecord.RecordType.DeveloperName == System.Label.BLN_SpiltBill){
                // For insurance site
                arpRecords = BLN_AccountRuleParameterUtil.getAccountRuleParameters(System.Label.BLN_OEAuthorizationLabel, insuranceSiteId, jobDate);
                arpRecords1 = BLN_AccountRuleParameterUtil.getAccountRuleParameters(System.Label.BLN_OEAuthorizationLabel, corporateSiteId, jobDate);
                if(arpRecords != null &&  !arpRecords.isEmpty() && arpRecords[0].BLN_OEAuthorization__c == System.label.BLN_OEAuthorizationReq){
                    result = true;
                } else if((arpRecords != null &&  !arpRecords.isEmpty() && arpRecords[0].BLN_OEAuthorization__c == System.label.BLN_OEMotoristLiability) && (arpRecords1 != null &&  !arpRecords1.isEmpty() && arpRecords1[0].BLN_OEAuthorization__c == System.label.BLN_OEAuthorizationReq)){
                    //For corporate site
                    result = true;
                }
            } 

            if(corporateRecord.RecordType.DeveloperName == System.Label.BLN_Insurance || corporateRecord.RecordType.DeveloperName == System.Label.BLN_CorporateFleet){
                if(arpRecords == null || (arpRecords!=null && arpRecords.size() > 0 && arpRecords[0].BLN_OEAuthorization__c == System.label.BLN_OEAuthorizationReq)){
                    result = true;
                }
            } 
        } catch (Exception e) {
            BLN_ExceptionLogger.captureException(e);
        }
        return result;
    }

    /* MethodName : checkAuthorizedLimit
            Description : This method is used to check Authorized limit ARP.
            Input Parameter : BLN_Corporate__c corporateRecord, List<BLN_ProductResponseWrapper.ResponseLineItems> payload
            Output Parameter : Boolean result
            CreatedDate: 08-11-2024
            CreatedBy : Pwc-India
            Change log :
            ****************************************/
    /*  *@description:This method is used to check Authorized limit ARP. */
    public static Boolean checkAuthorizedLimit(BLN_Corporate__c corporateRecord, BLN_ProductResponseWrapper.ResponseProduct payload){
        Boolean result = false;
        List<BLN_AccountRuleParameter__c> arpRecords = new List<BLN_AccountRuleParameter__c>();
        List<BLN_AccountRuleParameter__c> arpRecords1 = new List<BLN_AccountRuleParameter__c>();
        try {
            Date jobDate = Date.today();
            List<Decimal> authVal = new List<Decimal>();
            Decimal minauthValOfInsurance = 0.0;
            Decimal minauthValOfCorporate = 0.0;
            List<Decimal> insuranceVsAccountRules = new List<Decimal>();
            List<Decimal> corporateVsAccountRules = new List<Decimal>();
            List<Decimal> quotsTotalIncludingTax = new List<Decimal>();
            List<Decimal> quoteTotalIncludingTaxPayableByInsurance = new List<Decimal>();
            List<Decimal> quoteTotalPayableByTradeIncludingTax = new List<Decimal>();

            Decimal maxQuotsquoTsTotalIncludingTax = 0.0;
            Decimal maxQuoteTotalInclusingTaxByInsurance = 0.0;
            Decimal maxquoteTotalPayableByTradeIncludingTax = 0.0;

            for(BLN_ProductResponseWrapper.ResponseQuotes quote: payload.quotes){
                quotsTotalIncludingTax.add(Decimal.valueOf(quote.quoteTotals.totalIncludingTax));
                quoteTotalIncludingTaxPayableByInsurance.add(Decimal.valueOf(quote.insuranceTotals.totalIncludingTaxPayableByInsurance));
                quoteTotalPayableByTradeIncludingTax.add(Decimal.valueOf(quote.tradeCompanyTotals.totalPayableByTradeIncludingTax));
            }

            //Finding max for quotsTotalIncludingTax
            maxQuotsquoTsTotalIncludingTax = quotsTotalIncludingTax[0];
            for(Decimal value: quotsTotalIncludingTax){
                if(value > maxQuotsquoTsTotalIncludingTax){
                    maxQuotsquoTsTotalIncludingTax = value;
                }
            }
            //Finding max for quoteTotalIncludingTaxPayableByInsurance
            maxQuoteTotalInclusingTaxByInsurance = quoteTotalIncludingTaxPayableByInsurance[0];
            for(Decimal value: quoteTotalIncludingTaxPayableByInsurance){
                if(value > maxQuoteTotalInclusingTaxByInsurance){
                    maxQuoteTotalInclusingTaxByInsurance = value;
                }
            }
            //Finding max for quoteTotalPayableByTradeIncludingTax
            maxquoteTotalPayableByTradeIncludingTax = quoteTotalPayableByTradeIncludingTax[0];
            for(Decimal value: quoteTotalPayableByTradeIncludingTax){
                if(value > maxquoteTotalPayableByTradeIncludingTax){
                    maxquoteTotalPayableByTradeIncludingTax = value;
                }
            }

            if(corporateRecord.RecordType.DeveloperName == System.Label.BLN_Insurance){
                if(insuranceSiteId != null){
                    arpRecords = BLN_AccountRuleParameterUtil.getAccountRuleParameters(System.Label.BLN_AuthorizationLimitArgument, insuranceSiteId, jobDate);
                }
            } else if(corporateRecord.RecordType.DeveloperName == System.Label.BLN_CorporateFleet){
                if(corporateSiteId != null){
                    arpRecords = BLN_AccountRuleParameterUtil.getAccountRuleParameters(System.Label.BLN_AuthorizationLimitArgument, corporateSiteId, jobDate);
                }
            } else if(corporateRecord.RecordType.DeveloperName == System.Label.BLN_SpiltBill){
                //For split bill
                if(insuranceSiteId != null){
                    arpRecords = BLN_AccountRuleParameterUtil.getAccountRuleParameters(System.Label.BLN_AuthorizationLimitArgument, insuranceSiteId, jobDate);
                }
                if(corporateSiteId != null){
                    arpRecords1 = BLN_AccountRuleParameterUtil.getAccountRuleParameters(System.Label.BLN_AuthorizationLimitArgument, corporateSiteId, jobDate);
            } 

                if(arpRecords != null && arpRecords.size() > 0){
                    for(BLN_AccountRuleParameter__c arp: arpRecords){
                        insuranceVsAccountRules.add(arp.BLN_AuthorizationLimit__c);
                    }
                }
                if(arpRecords1 != null && arpRecords1.size() > 0){
                    for(BLN_AccountRuleParameter__c arp: arpRecords1){
                        corporateVsAccountRules.add(arp.BLN_AuthorizationLimit__c);
                    }
                }
            }

            if(((arpRecords != null) || (arpRecords != null && arpRecords.size() > 0)) && (corporateRecord.RecordType.DeveloperName == System.Label.BLN_Insurance || corporateRecord.RecordType.DeveloperName == System.Label.BLN_CorporateFleet)){
                for(BLN_AccountRuleParameter__c arp: arpRecords){
                    authVal.add(arp.BLN_AuthorizationLimit__c);
                }
            }
            
            if(authVal.size() > 0 && (corporateRecord.RecordType.DeveloperName == System.Label.BLN_Insurance || corporateRecord.RecordType.DeveloperName == System.Label.BLN_CorporateFleet)){
                Decimal minauthVal = authVal[0];
                //Find maximum from authval
                for(Decimal value: authVal){
                    if(value > minauthVal){
                        minauthVal = value;
                    }
                } 
                if(minauthVal < maxQuotsquoTsTotalIncludingTax){
                    result = true;
                }
            }
            //For split bill max values.
            if((insuranceVsAccountRules != null && insuranceVsAccountRules.size() > 0) && (corporateRecord.RecordType.DeveloperName == System.Label.BLN_SpiltBill)){
                //Find max values for insuranceVsAccountRules
                minauthValOfInsurance = insuranceVsAccountRules[0];
                for(Decimal value: insuranceVsAccountRules){
                    if(value > minauthValOfInsurance){
                        minauthValOfInsurance = value;
                    }
                }
                if((maxQuoteTotalInclusingTaxByInsurance > 0 && maxQuoteTotalInclusingTaxByInsurance == maxQuotsquoTsTotalIncludingTax) && (minauthValOfInsurance < maxQuotsquoTsTotalIncludingTax)){
                    result = true;
                } else if((minauthValOfInsurance < maxQuoteTotalInclusingTaxByInsurance) && (maxQuoteTotalInclusingTaxByInsurance > 0 && maxQuoteTotalInclusingTaxByInsurance != maxQuotsquoTsTotalIncludingTax)){
                    result = true;
                }
            }
            if((corporateVsAccountRules != null && corporateVsAccountRules.size() > 0) && (corporateRecord.RecordType.DeveloperName == System.Label.BLN_SpiltBill)){
                //Find max values for corporateVsAccountRules
                minauthValOfCorporate = corporateVsAccountRules[0];
                for(Decimal value: corporateVsAccountRules){
                    if(value > minauthValOfCorporate){
                        minauthValOfCorporate = value;
                    }
                }
                if ((maxquoteTotalPayableByTradeIncludingTax > 0 && maxquoteTotalPayableByTradeIncludingTax == maxQuotsquoTsTotalIncludingTax) && (minauthValOfCorporate < maxQuotsquoTsTotalIncludingTax)) {
                    result = true;
                } else if ((minauthValOfCorporate < maxquoteTotalPayableByTradeIncludingTax) && (maxquoteTotalPayableByTradeIncludingTax > 0 && maxquoteTotalPayableByTradeIncludingTax != maxQuotsquoTsTotalIncludingTax)) {
                    result = true;
                }
            }
        } catch (Exception e) {
            BLN_ExceptionLogger.captureException(e);
        }
        return result;
    }

    /* MethodName : checkProductAllowance
            Description : This method is used to check product allowance ARP.
            Input Parameter : BLN_Corporate__c corporateRecord, List<BLN_ProductResponseWrapper.ResponseLineItems> selectedProductList
            Output Parameter : Boolean result
            CreatedDate: 08-11-2024
            CreatedBy : Pwc-India
            Change log :
            ****************************************/
    /*  *@description:This method is used to check product allowance ARP. */
    public static Boolean checkProductAllowance(BLN_Corporate__c corporateRecord, List<BLN_ProductResponseWrapper.ResponseLineItems> selectedProductList){
        Boolean result = false;
        Boolean isPRoductInARP = false;
        Set<String> productAllownceSet = new Set<String>();
        Set<String> productAllownceCategorySet = new Set<String>();
        
        List<BLN_AccountRuleParameter__c> arpRecords = new List<BLN_AccountRuleParameter__c>();
        List<BLN_AccountRuleParameter__c> arpRecords1 = new List<BLN_AccountRuleParameter__c>();
        Set<String> partNumberSet = new Set<String>();

        List<Product2> productList = new List<Product2>();
        Map<String, Product2> productMap = new Map<String, Product2>();

        List<BLN_ProductResponseWrapper.ResponseLineItems> liableSelectedInsuranceProdList = new List<BLN_ProductResponseWrapper.ResponseLineItems>();
        List<BLN_ProductResponseWrapper.ResponseLineItems> liableSelectedTradeProdList = new List<BLN_ProductResponseWrapper.ResponseLineItems>();
        try {
            Date jobDate = Date.today();
            if(corporateRecord.RecordType.DeveloperName == System.Label.BLN_Insurance){
                if(insuranceSiteId != null){
                    arpRecords = BLN_AccountRuleParameterUtil.getAccountRuleParameters(System.Label.BLN_ProductAllowanceRecTypeName, insuranceSiteId, jobDate);
                }
            } else if(corporateRecord.RecordType.DeveloperName == System.Label.BLN_CorporateFleet){
                if(corporateSiteId != null){
                    arpRecords = BLN_AccountRuleParameterUtil.getAccountRuleParameters(System.Label.BLN_ProductAllowanceRecTypeName, corporateSiteId, jobDate);
                }
            } else if(corporateRecord.RecordType.DeveloperName == System.Label.BLN_SpiltBill){
                //For split bill
                if(insuranceSiteId != null && corporateSiteId != null){
                    arpRecords = BLN_AccountRuleParameterUtil.getAccountRuleParameters(System.Label.BLN_ProductAllowanceRecTypeName, insuranceSiteId, jobDate);
                    arpRecords1 = BLN_AccountRuleParameterUtil.getAccountRuleParameters(System.Label.BLN_ProductAllowanceRecTypeName, corporateSiteId, jobDate);
                }
                // set products in respective lists
                for(BLN_ProductResponseWrapper.ResponseLineItems lineItem: selectedProductList){
                    if(Decimal.valueOf(lineItem.totalIncludingTaxPayableByInsurance) > 0){
                        liableSelectedInsuranceProdList.add(lineItem);
                    }
                    if(Decimal.valueOf(lineItem.totalPayableByTradeIncludingTax) > 0){
                        liableSelectedTradeProdList.add(lineItem);
                    }
                }
            } 

            if(selectedProductList != null && selectedProductList.size() > 0){
                for(BLN_ProductResponseWrapper.ResponseLineItems lineItem: selectedProductList){
                    partNumberSet.add(lineItem.partNumber);
                }
                productList = [SELECT Id, BLN_MDMID__c, BLN_ProductCategory__c, BLN_BondedNonBonded__c FROM Product2 WHERE BLN_MDMID__c IN :partNumberSet WITH SECURITY_ENFORCED];
                for(Product2 product: productList){
                    productMap.put(product.BLN_MDMID__c, product);
                }
            }

            if((selectedProductList != null && selectedProductList.size() > 0) && (arpRecords != null && arpRecords.size() > 0) && (corporateRecord.RecordType.DeveloperName == System.Label.BLN_Insurance || corporateRecord.RecordType.DeveloperName == System.Label.BLN_CorporateFleet)){
                for(BLN_AccountRuleParameter__c arp: arpRecords){
                 if((arp.BLN_ProductAllowance__c == 'Allow' || arp.BLN_ProductAllowance__c == 'Allow All') && arp.BLN_AuthorisationRequired__c ==  true){
                    for(BLN_ProductResponseWrapper.ResponseLineItems lineItem: selectedProductList){
                         if( (lineItem!=null && productMap.containsKey(lineItem.partNumber) && (productMap.get(lineItem.partNumber).Id == arp.BLN_Product__c)) || (productMap.containsKey(lineItem.partNumber) && productMap.get(lineItem.partNumber).BLN_ProductCategory__c!=null && arp.BLN_ProductCategory__c!=null && productMap.get(lineItem.partNumber).BLN_ProductCategory__c.startswith(arp.BLN_ProductCategory__c)) ){
                            isPRoductInARP = true;
                            break;
                        }
                       
                    }
                    }
                    if(isPRoductInARP){
                        break;
                    }
                }
            } 
            //For split bill
            if(corporateRecord.RecordType.DeveloperName == System.Label.BLN_SpiltBill && insuranceSiteId != null && (arpRecords != null && arpRecords.size() > 0) &&(liableSelectedInsuranceProdList != null && liableSelectedInsuranceProdList.size() > 0)){

                for(BLN_AccountRuleParameter__c arp: arpRecords){
                    if((arp.BLN_ProductAllowance__c == 'Allow' || arp.BLN_ProductAllowance__c == 'Allow All') && arp.BLN_AuthorisationRequired__c ==  true){
                       for(BLN_ProductResponseWrapper.ResponseLineItems lineItem: liableSelectedInsuranceProdList){
                            if(( lineItem!=null && productMap.containsKey(lineItem.partNumber) && (productMap.get(lineItem.partNumber).Id == arp.BLN_Product__c)) || (productMap.containsKey(lineItem.partNumber) && productMap.get(lineItem.partNumber).BLN_ProductCategory__c!=null && arp.BLN_ProductCategory__c!=null && productMap.get(lineItem.partNumber).BLN_ProductCategory__c.startswith(arp.BLN_ProductCategory__c))){
                        isPRoductInARP = true;
                        break;
                    }
                }
            }
                       if(isPRoductInARP){
                           break;
                       }
                   }
            }
            if(corporateRecord.RecordType.DeveloperName == System.Label.BLN_SpiltBill && corporateSiteId != null && (arpRecords1 != null && arpRecords1.size() > 0) && (liableSelectedTradeProdList != null && liableSelectedTradeProdList.size() > 0)){

                for(BLN_AccountRuleParameter__c arp: arpRecords1){
                    if((arp.BLN_ProductAllowance__c == 'Allow' || arp.BLN_ProductAllowance__c == 'Allow All') && arp.BLN_AuthorisationRequired__c ==  true){
                       for(BLN_ProductResponseWrapper.ResponseLineItems lineItem: liableSelectedTradeProdList){
                            if(( lineItem!=null && productMap.containsKey(lineItem.partNumber) && (productMap.get(lineItem.partNumber).Id == arp.BLN_Product__c)) || (productMap.containsKey(lineItem.partNumber) && productMap.get(lineItem.partNumber).BLN_ProductCategory__c!=null && arp.BLN_ProductCategory__c!=null && productMap.get(lineItem.partNumber).BLN_ProductCategory__c.startswith(arp.BLN_ProductCategory__c))){
                        isPRoductInARP = true;
                        break;
                    }
                }
            }
                       if(isPRoductInARP){
                           break;
                       }
                   }
            }

            if(isPRoductInARP == true){
                result = true;
            }

        } catch (Exception e) {
            BLN_ExceptionLogger.captureException(e);
        }
        return result;
    }

    /* MethodName : checkDataCollectTask
            Description : This method is used to check Data collect ARP.
            Input Parameter : BLN_Corporate__c corporateRecord, String caseId
            Output Parameter : Boolean result
            CreatedDate: 08-11-2024
            CreatedBy : Pwc-India
            Change log :
            ****************************************/
    /*  *@description:This method is used to check Data collect ARP. */
    public static Boolean checkDataCollectTask(BLN_Corporate__c corporateRecord, String caseId){
        Boolean result = false;
        Boolean dataCollectBoolean;
        try {

            if(corporateRecord.RecordType.DeveloperName == System.Label.BLN_Insurance && insuranceSiteId!=null){
                dataCollectBoolean = BLN_DataCollectAnswers.submitButtonOnClick(caseId,  new List<String>{insuranceSiteId});
            } else if(corporateRecord.RecordType.DeveloperName == System.Label.BLN_CorporateFleet && corporateSiteId!=null){
                dataCollectBoolean = BLN_DataCollectAnswers.submitButtonOnClick(caseId,  new List<String>{corporateSiteId});
            }
            else if(corporateRecord.RecordType.DeveloperName == System.Label.BLN_SpiltBill && insuranceSiteId!=null && corporateSiteId!=null){
                dataCollectBoolean = BLN_DataCollectAnswers.submitButtonOnClick(caseId, new List<String>{insuranceSiteId,corporateSiteId});
            }

            
            
            result = !dataCollectBoolean;
        } catch (Exception e) {
            BLN_ExceptionLogger.captureException(e);
        }
        return result;
    }
}