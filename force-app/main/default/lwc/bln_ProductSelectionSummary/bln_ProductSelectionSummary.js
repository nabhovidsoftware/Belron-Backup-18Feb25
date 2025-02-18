import { LightningElement, track, api, wire } from 'lwc';
import userLocaleCurrency from "@salesforce/i18n/currency";
import ServiceLocation from '@salesforce/label/c.BLN_ServiceLocation';
import bookAppointment from '@salesforce/apex/BLN_AppointmentBooking.bookAppointment';
import scheduleAppointment from '@salesforce/apex/BLN_AppointmentBooking.scheduleAppointment';
import orderAndOrderItem from '@salesforce/apex/BLN_ProductAvailability.createOrdersAndOrderItems';
import getDataCollectAnswer from '@salesforce/apex/BLN_DataCollectAnswers.getDataCollectAnswer';
import makeRepriceCallout from '@salesforce/apex/BLN_ProductAvailability.makeRepriceCallout';
import structureDataForQuoteUI from '@salesforce/apex/BLN_ProductAvailability.structureDataForQuoteUI';
import VAT from '@salesforce/label/c.BLN_VAT';
import Location from '@salesforce/label/c.BLN_PrimaryLocation';
import quoteDiscount from '@salesforce/label/c.BLN_QuoteDiscount';
import quoteAfterHours from '@salesforce/label/c.BLN_QuoteAfterHours';
import quoteTotal from '@salesforce/label/c.BLN_QuoteTotal';
import totalMotoristLiability from '@salesforce/label/c.Bln_TotalMotoristLiability';
import QuoteProduct from '@salesforce/label/c.BLN_QuoteProduct';
import QuotePrice from '@salesforce/label/c.BLN_QuotePrice';
import reprice from '@salesforce/label/c.BLN_Reprise';
import Quantity from '@salesforce/label/c.BLN_Quantity';
import Confirm from '@salesforce/label/c.BLN_QuoteConfirm';
import Back from '@salesforce/label/c.BLN_QuoteBack';
import insuranceLiability from '@salesforce/label/c.BLN_InsuranceLiability';
import accountLiability from '@salesforce/label/c.BLN_AccountLiability';
import motoristLiability from '@salesforce/label/c.BLN_MotoristLiability';
import orderFailureMessage from '@salesforce/label/c.BLN_OrderFailureMessage';
import TOTAL_MOTORIST_FIELD from "@salesforce/schema/Case.BLN_TotalMotoristLiability__c";
import Status from "@salesforce/schema/Case.Status";
import TOTAL_ACCOUNT_FIELD from "@salesforce/schema/Case.BLN_TotalAccountLiability__c";
import TOTAL_INSURANCE_FIELD from "@salesforce/schema/Case.BLN_TotalInsuranceLiability__c";
import OUTSTANDING_BALANCE_FIELD from "@salesforce/schema/Case.BLN_OutstandingBalance__c";
import CASE_FIELD from "@salesforce/schema/Case.Id";
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { updateRecord } from 'lightning/uiRecordApi';
import { getFocusedTabInfo, closeTab } from 'lightning/platformWorkspaceApi';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent, FlowNavigationFinishEvent } from 'lightning/flowSupport';
import accRuleParam from '@salesforce/apex/BLN_AccountRuleParameterUtil.getAccountRuleParameters';//
import createBvtTask from '@salesforce/apex/BLN_ProductAuthorisation.createBvtTask';//
import getCorporateRecord from '@salesforce/apex/BLN_ProductAuthorisation.getCorporateRecord';//
import AutoDivertoAuthTeamRecordType from '@salesforce/label/c.BLN_AutoDivertoAuthTeamRecordType';//
import AssignDirectToBVT from '@salesforce/label/c.BLN_AssignDirectToBVT';//
import NonPDSCasesForValidation from '@salesforce/label/c.BLN_NonPDSCasesForValidation';//
import AllCasesForValidation from '@salesforce/label/c.BLN_AllCasesForValidation';//
import AccountId from "@salesforce/schema/Case.AccountId";//
import CreateNoStock from '@salesforce/apex/BLN_ProductAuthorisation.createNoStockTask';//
import OEAuthorisedSubject from '@salesforce/label/c.BLN_OEAuthorisedSubject';
import productExcessRecType from '@salesforce/label/c.BLN_ProductExcessRecTypeName';
import productAllowanceRecType from '@salesforce/label/c.BLN_ProductAllowanceRecTypeName';
import BVTSubject from '@salesforce/label/c.BLN_BVTSubject';
import CoverageVerificationTheme from "@salesforce/schema/Case.BLN_CoverageVerificationTheme__c";
import SplitBillBVT from '@salesforce/apex/BLN_ProductAuthorisation.splitBillBVT';

import authRequiredAmountLabel from '@salesforce/label/c.BLN_AuthRequiredAmount';
import appointmentRebook from '@salesforce/apex/BLN_AppointmentRebook.appointmentRebook';
import updateServiceAppointments from '@salesforce/apex/BLN_ProductAvailabilityRebook.updateServiceAppointments';
import oEAuthorizationLabel from '@salesforce/label/c.BLN_OEAuthorizationLabel';
import dataCollectSubType from '@salesforce/label/c.BLN_DataCollectSubType';
import updateCorporateAccount from '@salesforce/apex/BLN_ProductAuthorisation.corporateAccountUpdate';
import Authorization_Limit from '@salesforce/label/c.BLN_AuthorizationLimitArgument';
import AdditionalCharges from '@salesforce/label/c.BLN_AdditionalCharges';
import insuranceRecType from '@salesforce/label/c.BLN_Insurance';
import corporateRecType from '@salesforce/label/c.BLN_CorporateFleet';
import spiltBill from '@salesforce/label/c.BLN_SpiltBill';
import spiltInsurance from '@salesforce/label/c.BLN_SpiltInsurance';
import spiltCorporate from '@salesforce/label/c.BLN_SpiltCorporate';
import insuranceAmountAuthorizationRequired from '@salesforce/label/c.BLN_AmountAuthorizationRequired';
import corporateAmountAuthorizationRequiredTrade from '@salesforce/label/c.BLN_AmountAuthorizationRequiredTrade';
import corpObjId from '@salesforce/label/c.BLN_CorpObjId';
import corporateAuthorizationReqLabel from '@salesforce/label/c.BLN_CorporateAuthorizationReqLabel';
import oEAuthorizationReq from '@salesforce/label/c.BLN_OEAuthorizationReq';
import oEMotoristLiability from '@salesforce/label/c.BLN_OEMotoristLiability';
import authorizationStatus from '@salesforce/label/c.BLN_AuthorizationStatus';
import oEAuthorizationRequired from '@salesforce/label/c.BLN_OEAuthorizationRequired';
import authorizationStatusTrade from '@salesforce/label/c.BLN_AuthorizationStatusTrade';
import oEAuthorizationRequiredTrade from '@salesforce/label/c.BLN_OEAuthorizationRequiredTrade';
import productAuthorisationRequired from '@salesforce/label/c.BLN_ProductAuthorisationRequired';
import productAuthorisationRequiredTrade from '@salesforce/label/c.BLN_ProductAuthorisationRequiredTrade';
import productAuthorisedTaskSubtype from '@salesforce/label/c.BLN_productAuthorisedTaskSubtype';

import Type from "@salesforce/schema/Case.Type";
import BLN_SubType__c from "@salesforce/schema/Case.BLN_SubType__c";
import BLN_ProvisionalDriver__c from "@salesforce/schema/Case.BLN_ProvisionalDriver__c"; //FOUK-12749

const fields = [OUTSTANDING_BALANCE_FIELD, AccountId, TOTAL_MOTORIST_FIELD, Status, CoverageVerificationTheme,Type,BLN_SubType__c,BLN_ProvisionalDriver__c]; //FOUK-12749- added BLN_ProvisionalDriver__c

export default class Bln_ProductSelectionSummary extends NavigationMixin(LightningElement) {
    caseData;
    error;
    isLoading = false;
    isAfterHour = false;
    includingTax;
    CoverageVerificationTheme = true;
    @api responseData;
    @api selectedProductList;
    @api hiddenProductList;
    @api appointmentScreenData = [];
    @api screenThreeChildMap;
    @api quoteDataList;
    @api addOnProductList = [];
    @api oldSelectedProductList = [];
    @api oldAddOnProductList = [];
    @api selectedLocation = [];
    @api locationList = [];
    @api liabilityList = [];
    @api discount = '';
    @track primaryLocation = '';
    @track quoteVat = '';
    @track quoteTotal = '';
    @api isCashJourney;
    @api caseId = '';
    @api accountId;
    @api taskId = '';
    @api currentPayload;
    @api isRebooking = false;
    @track timeRange;
    @track datePart;
    @track afterHoursVar = '';
    @track slotDateOnly;
    @api IsCancelled = false;
    @api availableActions = [];
    @api isRepairApplied;
    @api earliestAvailabilityList;
    handlePaymentScreen = false;
    isProductSummary = true;
    totalInsuranceLiability = 0;
    totalAccountLiability = 0;
    @track totalMotoristLiability = 0
    outstandingBalance = 0;
    status;
    total
    corpObj = {};
    corporateAccId = null;
    appointSlotDate = '';
    @api getQuotePayload = [];
    @api rebookSaList = [];
    @api stocksCreateList = [];
    @api stocksUpdateList = [];
    @api stocksDeleteList = [];
    @api adressList = [];
    @api afterHourObj = {};
    afterHourData = {};
    isOrderSuccessFullCreated = true;
    isArp = false;
    //FOUK-11499
    @track isBvtTaskCreated = false;
    @track isDataCollectQualityTaskCreated = false;
    insuranceAccId = null;
    dataCollectCheck = false;
    isCorporateAuthorised = false;

    //FOUK-12172
    @track ordersCreatedBoolean = false;

    label = {
        ServiceLocation,
        Location,
        quoteDiscount,
        quoteAfterHours,
        VAT,
        quoteTotal,
        totalMotoristLiability,
        QuoteProduct,
        QuotePrice,
        Quantity,
        Confirm,
        Back,
        reprice,
        insuranceLiability,
        accountLiability,
        motoristLiability,
        TOTAL_MOTORIST_FIELD,
        TOTAL_ACCOUNT_FIELD,
        TOTAL_INSURANCE_FIELD,
        AssignDirectToBVT,
        AutoDivertoAuthTeamRecordType,
        OEAuthorisedSubject,
        authRequiredAmountLabel,
        productExcessRecType,
        oEAuthorizationLabel,
        dataCollectSubType,
        orderFailureMessage,
        BVTSubject,
        AdditionalCharges,
        insuranceRecType,
        corporateRecType,
        spiltBill,
        spiltInsurance,
        spiltCorporate,
        insuranceAmountAuthorizationRequired,
        corporateAmountAuthorizationRequiredTrade,
        corpObjId,
        corporateAuthorizationReqLabel,
        oEAuthorizationReq,
        oEMotoristLiability,
        authorizationStatus,
        oEAuthorizationRequired,
        authorizationStatusTrade,
        oEAuthorizationRequiredTrade,
        productAuthorisationRequired,
        productAuthorisationRequiredTrade,
        productAuthorisedTaskSubtype

    }

    @track ProductSummaryData = [{}];
    @track appointmentList = [];
    corporateFields = {};
    caseFields = {};
    @wire(getRecord, {
        recordId: "$caseId",
        fields
    })
    case;
    @wire(getCorporateRecord,{caseId: "$caseId"})
    getCorporateRecord(result){
        this.refreshCorpObj = result;
        if(result.data){
            this.corpObj = result.data;
        }
        else if(result.error){
         
        }

       

    }

    dataFromSecondScreen =
        [
            {
                "serviceLocation": "undefined Cardington",
                "serviceLocationLabel": [
                    {
                        "serviceLabel": {
                            "serviceLocation": "SERVICE LOCATION"
                        },
                        "product": {
                            "products": "Products"
                        },
                        "productNames": [
                            {
                                "productName": "VAPS Product",
                                "productCode": "PWWBH384"
                            },
                            {
                                "productName": "ABCLIDAR",
                                "productCode": "PWWBH451"
                            }
                        ]
                    }
                ],
                "earliestAvailablity": [
                    {
                        "serviceName": "Cardington",
                        "earliestAvailablity": {
                            "earliestAvailability": "Earliest Availability"
                        },
                        "productDate": [
                            {
                                "earliestDate": "March 23, 2024",
                                "productCode": "PWWBH384"
                            },
                            {
                                "earliestDate": "March 24, 2024",
                                "productCode": "PWWBH451"
                            }
                        ]
                    }
                ],
                "appointments": [
                    {
                        "appointmentName": "Appointment 1",
                        "keyIndex": "0",
                        "locationId": "9y8hfh9",
                        "locationName": "Cardington",
                        "earlierAvailabilityDateHeader": "March 23, 2024",
                        "slotSelectedDate": " April 23, 2024, 14.30-15",
                        "serviceAppointmentId": "",
                        "slotDate": "",
                        "slotTime": "",
                        "slotDateTimeStart": "",
                        "slotDateTimeFinish": "",
                        "productAvailibilities": [
                            {
                                "products": [
                                    {
                                        "productCode": "PWWBH384",
                                        "productEnable": true,
                                        "quantity": 1,
                                        "isChecked": false
                                    },
                                    {
                                        "productCode": "PWWBH451",
                                        "productEnable": false,
                                        "quantity": 1,
                                        "isChecked": false
                                    }
                                ]
                            }
                        ]
                    },
                    {
                        "appointmentName": "Appointment 2",
                        "keyIndex": 1,
                        "locationId": "9y8hfh9",
                        "locationName": "Cardington",
                        "earlierAvailabilityDateHeader": "March 24, 2024",
                        "slotSelectedDate": " April 25, 2024, 15-15.30",
                        "serviceAppointmentId": "",
                        "slotDate": "",
                        "slotTime": "",
                        "slotDateTimeStart": "",
                        "slotDateTimeFinish": "",
                        "productAvailibilities": [
                            {
                                "products": [
                                    {
                                        "productCode": "PWWBH384",
                                        "productEnable": false,
                                        "quantity": 1,
                                        "isChecked": false
                                    },
                                    {
                                        "productCode": "PWWBH451",
                                        "productEnable": true,
                                        "quantity": 1,
                                        "isChecked": false
                                    }
                                ]
                            }
                        ]
                    }
                ]
            }
        ]

    localeCurrency = userLocaleCurrency;
    vatValue = '50.00';
    @api afterHours = '';
    discount = this.discount;
    total = '1150.00';

    connectedCallback() {
        console.log('selectedProductList----',JSON.stringify(this.selectedProductList));
        console.log('earliestAvailabilityList',this.earliestAvailabilityList);
        this.mobileChargeStatusCheck(this.currentPayload);

        if (this.isRebooking == true) {/*Re-book*/
            this.isLoading = false;
            let quoteJson = this.appointmentScreenData;
            this.primaryLocation = quoteJson[0].serviceLocationName;
        } else {
            this.primaryLocation = this.selectedLocation.quotelocation;
        }

        console.log(this.isCashJourney, '-this.selectedLocation-', JSON.stringify(this.selectedLocation));
        console.log(JSON.stringify(this.afterHourObj), '-this.isRebooking-', this.isRebooking);
        if (this.isCashJourney == true && this.isRebooking == false) {
            if (Object.keys(this.afterHourObj).length === 0) {
                this.isAfterHour = false;
               
                if(this.isRepairApplied){
                    this.repriceCallout();
                }
                else{
                    this.quoteVat = this.selectedLocation.quoteVAT;
                    this.quoteTotal = '£' + parseFloat(this.selectedLocation.quoteTotal + this.selectedLocation.quoteVAT).toFixed(2);    
                }
            }
            else {
                this.isAfterHour = true;
                this.afterHourData = this.afterHourObj;
                this.repriceCallout();
            }
        } else if (this.isCashJourney == false) {
            if (Object.keys(this.afterHourObj).length === 0) {
                this.isAfterHour = false;

                if(this.isRepairApplied){
                    this.repriceCallout();
                }

                let currentPayloadData = JSON.parse(this.currentPayload);
                console.log('===this.selectedLocation==',JSON.stringify(this.selectedLocation));
                let totalsArray = this.getTotalsFromPayloadOnLocation(currentPayloadData,this.selectedLocation.locationGUID);
                this.quoteTotal = '£' + parseFloat(totalsArray.motoristTotal).toFixed(2);

            }
            else {
                this.isAfterHour = true;
                if (this.isRebooking == true) {
                    this.currentPayload = this.getQuotePayload;
                }
                this.afterHourData = this.afterHourObj;
                this.repriceCallout();
            }
        }

        /*to set VAT and Total on 3rd screen*/
        if (this.isRebooking == true && this.isCashJourney == true) {
            if (Object.keys(this.afterHourObj).length === 0) {
                this.isAfterHour = false;
                if (this.getQuotePayload != null || this.getQuotePayload != undefined) {
                    let currentPayloadData = JSON.parse(this.getQuotePayload);
                    let totalsArray = this.getTotalsFromPayloadOnLocation(currentPayloadData,this.selectedLocation.locationGUID);
                    this.quoteTotal = '£' + parseFloat(totalsArray.motoristTotal).toFixed(2);
    
                }
            }
            else {
                this.isAfterHour = true;
                this.afterHourData = this.afterHourObj;
                this.currentPayload = this.getQuotePayload;
                this.repriceCallout();
            }

        }else if (this.isRebooking == true && this.isCashJourney == false) {
            if (Object.keys(this.afterHourObj).length === 0) {
                this.isAfterHour = false;
                if (this.getQuotePayload != null || this.getQuotePayload != undefined) {
                    let currentPayloadData = JSON.parse(this.getQuotePayload);
                    let totalsArray = this.getTotalsFromPayloadOnLocation(currentPayloadData,this.selectedLocation.locationGUID);
                    this.quoteTotal = '£' + parseFloat(totalsArray.motoristTotal).toFixed(2);

                }
            }
            else {
                this.isAfterHour = true;
                this.afterHourData = this.afterHourObj;
                this.currentPayload = this.getQuotePayload;
                this.repriceCallout();
            }

        }

        /*if(this.oldSelectedProductList!=null || this.oldSelectedProductList!=undefined){
            console.log('----oldddata---> ',this.objConvert(this.oldSelectedProductList));
        }
        if(this.appointmentScreenData!=null || this.appointmentScreenData!=undefined){
            console.log('----newwdata---> ',this.objConvert(this.appointmentScreenData));
        }*/

        let oldData = [];
        let newData = [];
        let slotDateTime = [];

        if (this.oldSelectedProductList != null || this.oldSelectedProductList != undefined) {
            oldData = this.objConvert(this.oldSelectedProductList);
        }
        if (this.oldSelectedProductList != null || this.oldSelectedProductList != undefined) {
            this.objConvert(this.oldSelectedProductList).forEach(obj => obj.appointments.forEach(obj2 => obj2.productAvailibilities.forEach(obj3 => obj3.products.forEach(obj4 => { oldData.push(obj4); slotDateTime.push({ "lineItemId": obj4.lineItemId, "slotDate": obj2.slotDateTimeStart }); }))));
        }

        if (this.appointmentScreenData != null || this.appointmentScreenData != undefined) {
            this.objConvert(this.appointmentScreenData).forEach(obj => obj.appointments.forEach(obj2 => obj2.productAvailibilities.forEach(obj3 => obj3.products.forEach(obj4 => {
                newData.push(obj4);
                if (slotDateTime.find(x => x.lineItemId === obj4.lineItemId)) {
                    const indexSlot = slotDateTime.findIndex(obj5 => obj5.lineItemId === obj4.lineItemId);
                    slotDateTime[indexSlot].slotDate = obj2.slotDateTimeStart;
                    // slotDateTime.push({"lineItemId": obj4.lineItemId, "slotDate": obj2.slotDateTimeStart});
                }
                else {
                    slotDateTime.push({ "lineItemId": obj4.lineItemId, "slotDate": obj2.slotDateTimeStart });
                }
            }))));
        }

        //let slotDateTime = this.objConvert(this.appointmentScreenData)[0].appointments[0].slotDateTimeStart;
        let differenceList = [];
        let createList = [];
        let deleteList = [];
        if (JSON.stringify(oldData) !== JSON.stringify(newData)) {
            differenceList = oldData.reduce((result, obj1) => {
                const match = newData.find(obj2 => this.isEqual(obj1, obj2));
                const key = match ? 'match' : 'unmatched';
                (result[key] || (result[key] = [])).push(obj1);
                return result;
            }, {}).unmatched;

            createList = newData.reduce((result, obj1) => {
                const match = oldData.find(obj2 => this.isEqual(obj1, obj2));
                const key = match ? 'match' : 'unmatched';
                (result[key] || (result[key] = [])).push(obj1);
                return result;
            }, {});
            if (createList.unmatched != null && differenceList != null) {
                deleteList = differenceList.filter(obj1 =>
                    !createList.unmatched.some(obj2 => obj1.orderItemId === obj2.orderItemId)
                );
            }
            else { deleteList = differenceList; }
        }
        this.showSummaryOnUI();
    }

    isEqual(obj1, obj2) {
        if (obj1.lineItemId == obj2.lineItemId && obj1.quantity == obj2.quantity) { return true; }
        return false;
    }

    showSummaryOnUI() {
        let dataFromSecondScreen = this.objConvert(this.appointmentScreenData);
        for (let currentLocationData of dataFromSecondScreen) {
            var counter = 1;
            for (let appointmentDetails of currentLocationData.appointments) {
               
                let currentAppointmentName = appointmentDetails.appointmentName;
                let currentServiceAppointmentId = appointmentDetails.serviceAppointmentId;
                let currentServiceLocation = appointmentDetails.locationName;
                this.datePart = '';
                this.timeRange = '';
                if (appointmentDetails.slotSelectedDate != '') {

                    const dateRegex = /(\w+\s\d+,\s\d+)/;
                    const dateMatch = appointmentDetails.slotSelectedDate.match(dateRegex);
                    this.datePart = dateMatch ? dateMatch[1] : '';

                    const timeRangeRegex = /(\d+:\d+)-(\d+:\d+)/;
                    const timeRangeMatch = appointmentDetails.slotSelectedDate.match(timeRangeRegex);
                    this.timeRange = timeRangeMatch ? `${timeRangeMatch[1]}-${timeRangeMatch[2]}` : '';
                }

                let currentProdsList = [];
                let productSummaryListWithChild = [];

                for (let prodAvail of appointmentDetails.productAvailibilities) {
                    for (let prod of prodAvail.products) {
                        if (prod.productEnable == true) {
                            console.log('-selectedProductList-Summary',JSON.stringify(this.selectedProductList));
                            console.log('-selectedProductList-prod-Summary',JSON.stringify(prod));
                             let currentProd = this.selectedProductList.find(item => item.productCode == prod.productCode && item.quantity == prod.quantity);
                            if(currentProd){

                            console.log('currentProd',currentProd);
                            let prodVar = {
                                prodName: currentProd.productDescription != undefined ? currentProd.productDescription : currentProd.productName,
                                prodQuantity: currentProd.quantity,
                                prodPrice: currentProd.netPriceIncludingTax,
                                appointmentIndex: counter,
                                isBundle: false,
                                showChildData: false,
                            };
                            if (currentProd.hierarchy == 'parent' || currentProd.partOfBundle == true) {
                                let innerList = [];
                                let currentChildProdList = [];
                                if (currentProd.partOfBundle == true) {
                                    currentChildProdList = this.addOnProductList.filter(item => item.partOfBundle && (item.parentLineItemId == currentProd.lineItemId));
                                }
                                if (currentProd.hierarchy == 'parent') {
                                    currentChildProdList = this.addOnProductList.filter(item => item.bomId == currentProd.bomId);
                                }
                                prodVar.isBundle = true;
                                currentChildProdList.forEach(child => {
                                    let childProdVar = {
                                        innerProdName : child.productName,
                                        innerProdQuantity: child.quantity,
                                        innerProdPrice: child.netPriceIncludingTax,
                                        isBundle: false,
                                        showChildData: false
                                    }
                                    innerList.push(childProdVar)
                                });
                                prodVar.innerProductsList = innerList;
                            }
                            currentProdsList.push(prodVar);
                        }
                    }  
                    }  
                                 
                }
                let eachAppointment = {
                    appointmentName: currentAppointmentName,
                    serviceAppointmentId: currentServiceAppointmentId,
                    serviceLocation: currentLocationData.serviceLocationName.includes('Service Location') ? currentLocationData.serviceLocationName.split('Service Location')[1] : currentLocationData.serviceLocationName,
                    slotDate: this.datePart,
                    slotTime: this.timeRange,
                    productsList: currentProdsList,
                    isDropOff: appointmentDetails.isDropOff != null || appointmentDetails.isDropOff != undefined ? appointmentDetails.isDropOff : false,
                    appointmentIndex: counter,
                }
                console.log('eachAppointment----> ',eachAppointment.appointmentIndex,eachAppointment.serviceLocation,eachAppointment.slotDate,eachAppointment.slotTime);
                this.appointmentList.push(eachAppointment);
                counter++;  
            }
        }
       
        console.log(JSON.stringify(this.appointmentList));
        this.isLoading = false;
    }

    splitDateTime(dateTimeStr) {

        const [datePart, timePart] = dateTimeStr.split(/(?=\d{2}:\d{2})/);
        this.datePart = datePart.trim();
        this.timeRange = timePart.trim();
    }

    objConvert(str) {
        return JSON.parse(JSON.stringify(str));
    }

    toggleChildData(event) {
        let parentIndex = event.currentTarget.dataset.id;
        let index = event.currentTarget.dataset.index;
        this.appointmentList[parentIndex].productsList[index].showChildData = !this.appointmentList[parentIndex].productsList[index].showChildData;
    }

    async createOrderAndOrderItem() {
            await orderAndOrderItem({ mainJson: this.currentPayload, selectedProducts: JSON.stringify(this.selectedProductList), selectedAddonProducts: JSON.stringify(this.addOnProductList), appointmentJson: JSON.stringify(this.appointmentScreenData), caseId: this.caseId, cpqQuoteId: this.selectedLocation.quoteId, earliestDateList: JSON.stringify(this.earliestAvailabilityList), discount: this.discount })
                .then((result) => {
                    this.ordersCreatedBoolean = true;

                let quoteJson = JSON.parse(this.currentPayload);

                let dataFromSecondScreen = this.objConvert(this.appointmentScreenData);
                for (let currentLocationData of dataFromSecondScreen) {
                    for (let appointmentDetails of currentLocationData.appointments) {
                        CreateNoStock({ serAppId: appointmentDetails.serviceAppointmentId, caseId: this.caseId })
                            .then((result) => {
                            })
                            .catch((err) => {
                            })
                            .finally(() => {

                            }
                            );
                    }
                }
            })
            .catch((err) => {
                this.error = err;
                    this.ordersCreatedBoolean = false;
            })
            .finally(() => {
            }
            );
    }

    async handleConfirmAppointment() {
        this.isProductSummary = false;
        this.isLoading = true;

        await this.createOrderAndOrderItem();
        if(this.ordersCreatedBoolean){

        //Imperative Apex to call bookAppointment method
        if (this.isRebooking == false) {
            let dataFromSecondScreen = this.objConvert(this.appointmentScreenData);
            for (let currentLocationData of dataFromSecondScreen) {
                for (let appointmentDetails of currentLocationData.appointments) {
                    this.appointSlotDate = new Date(appointmentDetails.slotDateTimeStart);

                    await bookAppointment({ slotStart: new Date(appointmentDetails.slotDateTimeStart), slotFinish: new Date(appointmentDetails.slotDateTimeFinish), appointmentId: appointmentDetails.serviceAppointmentId, isDropOff: (appointmentDetails.isDropOff == 'true' ? true : false), isForceAppointment: (appointmentDetails.isForceAppointment == 'true' ? true : false) })
                        .then((result) => {
                            console.log('--result-bookApp-', result);

                            if (result) {
                                let res = JSON.parse(result);

                                if (res.isSuccess == true && (res.message == null || res.message == '')) {
                                    scheduleAppointment({ appointmentId: appointmentDetails.serviceAppointmentId })
                                        .then((result) => {
                                            console.log('result321', result);

                                        })
                                        .catch((err) => {
                                            this.error = err;
                                            console.log('err321', err);
                                        })
                                        .finally(() => {
                                            this.isLoading = false;
                                        });
                                }
                                else {
                                    this.isOrderSuccessFullCreated = false;
                                    this.successErrorToast('Error', this.label.orderFailureMessage, 'error');
                                }
                            }
                            else {
                                this.isOrderSuccessFullCreated = false;
                                this.successErrorToast('Error', this.label.orderFailureMessage, 'error');
                            }
                        })
                        .catch((err) => {
                            this.error = err;
                        })
                        .finally(() => {
                            this.isLoading = false;
                        });
                }
            }
        }

        // Appointment Rebook start FOUK-6286
        console.log('-rebookSaList--',JSON.stringify(this.rebookSaList));
        if (this.isRebooking == true) {
            //7148 Start
            let dataFromRebookSAList = this.rebookSaList;
            for (let currentData of dataFromRebookSAList) {
                // if(currentData.rebookDetails !='' && currentData.rebookDetails!=null && currentData.rebookDetails!=undefined){
                for (let appointmentDetails of currentData.rebookDetails) {
                    if (appointmentDetails.action == 'New') {

                        await bookAppointment({ slotStart: new Date(appointmentDetails.slotStart), slotFinish: new Date(appointmentDetails.slotFinish), appointmentId: appointmentDetails.saId, isDropOff: (appointmentDetails.isDropOff == 'true' ? true : false), isForceAppointment: (appointmentDetails.isForceAppointment == 'true' ? true : false) })
                            .then((result) => {
                            })
                            .catch((err) => {
                                this.error = err;
                            })
                            .finally(() => {
                                this.isLoading = false;
                            });
                    }
                }
                //}    
            }

                //just rebbok new, existing, delete
                let rebookSAListNew = [{"rebookDetails":[]}];
                for (let currentData of dataFromRebookSAList) {
                    for (let appointmentDetails of currentData.rebookDetails) {
                        if (appointmentDetails.action == 'New' || appointmentDetails.action == 'Existing' || appointmentDetails.action == 'Delete' ) {
                            rebookSAListNew[0].rebookDetails.push(appointmentDetails);
                        }
                    }
                }

                await appointmentRebook({ paramsForRebook: rebookSAListNew })
                .then((result) => {
                })
                .catch((err) => {
                    this.error = err;
                })
                .finally(() => {
                    this.isLoading = false;
                });

                //just rebbok cancel
                let rebookSAListCancel = [{"rebookDetails":[]}];
                for (let currentData of dataFromRebookSAList) {
                    for (let appointmentDetails of currentData.rebookDetails) {
                        if (appointmentDetails.action == 'Cancel') {
                            rebookSAListCancel[0].rebookDetails.push(appointmentDetails);
                        }
                    }
                }

                //for other actions
                await appointmentRebook({ paramsForRebook: rebookSAListCancel })
                .then((result) => {
                })
                .catch((err) => {
                    this.error = err;
                })
                .finally(() => {
                    this.isLoading = false;
                });

            // To schedule multiple SA for NEW action in Re-book
            for (let currentData of dataFromRebookSAList) {
                for (let i = 0; i < currentData.rebookDetails.length; i++) {
                    const element = currentData.rebookDetails[i];
                    if (element.action == 'New') {
                        await scheduleAppointment({ appointmentId: element.saId })
                            .then((result) => {
                            })
                            .catch((err) => {
                                this.error = err;
                            })
                            .finally(() => {
                                this.isLoading = false;
                            });
                    }
                }
            }

            //7148 END

            //Imperative Apex to call to update SA on Order Item

                await updateServiceAppointments({ data: JSON.stringify(this.appointmentScreenData), caseId: this.caseId })
            .then((result) => {

            })
            .catch((err) => {
                this.error = err;

            })
            .finally(() => {
            }
            );

        }// Appointment Rebook END FOUK-6286

        //FOUK-6287 Start here
            //TRY CODE
            let currentPayloadData = JSON.parse(this.currentPayload);
            for (let quote of currentPayloadData.quotes) {
                if (quote.quoteId == this.selectedLocation.quoteId) {
                    const insuranceTotals = quote.insuranceTotals;
                    const motoristTotals = quote.motoristTotals;
                    const tradeTotals = quote.tradeCompanyTotals;
                    const totalInsuranceValue = insuranceTotals.totalIncludingTaxPayableByInsurance;
                    this.includingTax = insuranceTotals.totalIncludingTaxPayableByInsurance;
                    this.totalInsuranceLiability = totalInsuranceValue;
                    const totalAccountValue = tradeTotals.totalPayableByTradeIncludingTax;
                    this.includingTax = tradeTotals.totalPayableByTradeIncludingTax;
                    this.totalAccountLiability = totalAccountValue;
                    const totalValue = motoristTotals.totalIncludingTaxPayableByMotorist;
                    this.includingTax = motoristTotals.totalIncludingTaxPayableByMotorist;
                    this.totalMotoristLiability = totalValue;
                }
            } 

        if (this.totalMotoristLiability != null || this.totalAccountLiability != null || this.totalInsuranceLiability != null) {
            const fields = {};
            fields[CASE_FIELD.fieldApiName] = this.caseId;
            fields[TOTAL_MOTORIST_FIELD.fieldApiName] = this.totalMotoristLiability;
            fields[TOTAL_ACCOUNT_FIELD.fieldApiName] = this.totalAccountLiability;
            fields[TOTAL_INSURANCE_FIELD.fieldApiName] = this.totalInsuranceLiability;
            if (this.outstandingBalance <= 0) {
                fields[Status.fieldApiName] = 'Open';
            }
            const recordInput = { fields };
            updateRecord(recordInput).then(() => {
                //  this.dispatchEvent(
                //     new ShowToastEvent({
                //     title: 'Success',
                //     message: 'Case Record updated',
                //     variant: 'success'
                //       })
                //     );
                this.outstandingBalance = getFieldValue(this.case.data, OUTSTANDING_BALANCE_FIELD);
                var totalMotoristValue = getFieldValue(this.case.data, TOTAL_MOTORIST_FIELD);
                // let SUM = this.totalMotoristLiability - (totalMotoristValue + this.outstandingBalance);

                totalMotoristValue = totalMotoristValue == null ? 0 : totalMotoristValue;
                if ((this.totalMotoristLiability - totalMotoristValue) > 0 && this.isOrderSuccessFullCreated) {
                    this.handlePaymentScreen = true;
                            try{
                                const navigateNextEvent = new FlowNavigationNextEvent();
                                this.dispatchEvent(navigateNextEvent);
                            }
                            catch(err) {
                                console.log('ERROR: ',err.message);
                                this.closeFlow();
                            }

                } else if ((this.totalMotoristLiability - totalMotoristValue) <= 0 && this.isOrderSuccessFullCreated) {
                    const fields = {};
                    fields['Id'] = this.caseId;
                    fields['Status'] = 'Open';
                    this.handlePaymentScreen = false;
                    if (this.availableActions.find((action) => action == 'NEXT')) {
                        this.dispatchEvent(new FlowAttributeChangeEvent('IsCancelled', true));
                        const navigateNextEvent = new FlowNavigationNextEvent();
                        this.dispatchEvent(navigateNextEvent);
                        this.navigateToViewCasePage();
                    }
                    else if (this.availableActions.find((action) => action == 'FINISH')) {
                        const navigateFinishEvent = new FlowNavigationFinishEvent();
                        this.dispatchEvent(navigateFinishEvent);
                        this.navigateToViewCasePage();
                    }
                    else {
                        this.closeFlow();
                    }
                } else if (this.isOrderSuccessFullCreated) {
                    this.handlePaymentScreen = false;
                    if (this.availableActions.find((action) => action == 'NEXT')) {
                        this.dispatchEvent(new FlowAttributeChangeEvent('IsCancelled', true));
                        const navigateNextEvent = new FlowNavigationNextEvent();
                        this.dispatchEvent(navigateNextEvent);
                        this.navigateToViewCasePage();
                    }
                    else if (this.availableActions.find((action) => action == 'FINISH')) {
                        const navigateFinishEvent = new FlowNavigationFinishEvent();
                        this.dispatchEvent(navigateFinishEvent);
                        this.navigateToViewCasePage();
                    }
                    else {
                        this.closeFlow();
                    }
                } else {
                    this.handlePaymentScreen = false;
                }
            }).catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error while updating record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
        }

        if (this.adressList.longitude != null && this.adressList.longitude != '' && this.adressList.longitude != undefined && this.adressList.latitude != null && this.adressList.latitude != '' && this.adressList.latitude != undefined) {
            this.updateAddress();
        }

            await updateCorporateAccount({ caseId: this.caseId, cpqAmount: this.includingTax })
            .then(result => {
            })
            .catch((err) => {
                this.error = err;
            })


            if(this.isRebooking == false && getFieldValue(this.case.data, Type) == 'Job Request' && getFieldValue(this.case.data, BLN_SubType__c) == 'Job Request' && this.isCashJourney == false){
                if ((this.corpObj.RecordType.DeveloperName == this.label.insuranceRecType) && this.corpObj.BLN_InsuranceSite__c !== undefined) {//|| this.corpObj.RecordType.DeveloperName == 'BLN_SpiltBill'
                    this.corporateAccId = this.corpObj.BLN_InsuranceSite__c;
                }

                else if (this.corpObj.RecordType.DeveloperName == this.label.corporateRecType && this.corpObj.BLN_CorporateSite__c !== undefined) {
                    this.corporateAccId = this.corpObj.BLN_CorporateSite__c;
                }

                /*FOUK-10505 start*/
                else if (this.corpObj.RecordType.DeveloperName == this.label.spiltBill && (this.corpObj.BLN_InsuranceSite__c != undefined && this.corpObj.BLN_CorporateSite__c == undefined)) {
                    this.insuranceAccId = this.corpObj.BLN_InsuranceSite__c;
                }
                else if (this.corpObj.RecordType.DeveloperName == this.label.spiltBill && (this.corpObj.BLN_InsuranceSite__c == undefined && this.corpObj.BLN_CorporateSite__c != undefined)) {
                    this.corporateAccId = this.corpObj.BLN_CorporateSite__c;
                }
                else if (this.corpObj.RecordType.DeveloperName == this.label.spiltBill && (this.corpObj.BLN_InsuranceSite__c != undefined && this.corpObj.BLN_CorporateSite__c != undefined)) {
                    this.corporateAccId = this.corpObj.BLN_CorporateSite__c;
                    this.insuranceAccId = this.corpObj.BLN_InsuranceSite__c;
                }
    await this.checkForAuthorizationLimit(); //fouk - 7331
    await this.checkForOEAuthorizedNext(); //FOUK- 3167
    await this.productRequiredAuthorizationNext() //FOUK -7082
    await this.automaticBVTTaskCreation();//5040-41
                    await this.getDataCollectAnswer(); // FOUK - 5015
                    //FOUK-12749
                    let provisionalDriver = getFieldValue(this.case.data,BLN_ProvisionalDriver__c);
                    if(provisionalDriver != 'Customer Driven'){
    this.CoverageVerificationTheme = getFieldValue(this.case.data, CoverageVerificationTheme);
    if (!this.CoverageVerificationTheme && this.isCashJourney == false) {
            await this.createBvtTask(this.label.BVTSubject);

    }
                    }
                    
                    if(Object.keys(this.corporateFields).length > 0){
                    
                        this.corporateFields['Id']= this.corpObj.Id;
                    const fields =  this.corporateFields;
    const corpRecordInput = { fields };
    await updateRecord(corpRecordInput)
        .then(() => {
            this.isCorporateAuthorised = true;
        })
        .catch(error => {
        });

    }

                    if(this.isCorporateAuthorised == true) {
                        this.caseFields['BLN_ARCheck1__c'] = false;
                    }
                    if(this.isCorporateAuthorised == false) {
                        this.caseFields['BLN_ARCheck1__c'] = true;
                }
                if(this.dataCollectCheck == false) {
                  this.caseFields['BLN_ARCheck2__c'] =  false;
                }
                if(this.dataCollectCheck ==true) {
                    this.caseFields['BLN_ARCheck2__c'] =  true;
                }


                if(Object.keys(this.caseFields).length > 0) {
                    this.caseFields['Id'] = this.caseId;
                    const recordInput = {
                        fields: this.caseFields
            };
       
            updateRecord(recordInput)
                .then(() => {
                })
                .catch(error => {
                });

        }
           }
        } else{
            this.isProductSummary = true;
            //Throw a toast message
            this.successErrorToast('ERROR', 'Order could not be created. Please retry.', 'error');
        }
             this.isLoading = false;
     
           
    }

    //scheduling Rebook New appointments in await mode
    async scheduleRebookNewAppts(saId) {
    }

    //for 6283  
    // BLN_ServiceCounty__c : this.adressList.serviceStreet,
    updateAddress() {
        const fields = {
            Id: this.caseId,
            BLN_ServiceStreet__c: this.adressList.serviceStreet,
            BLN_ServiceTown__c: this.adressList.serviceTown,
            BLN_ServiceCountry__c: this.adressList.serviceCountry,
            BLN_ServicePostCode__c: this.adressList.servicePostCode,
            BLN_ServiceGeolocation__Latitude__s: parseFloat(this.adressList.latitude),
            BLN_ServiceGeolocation__Longitude__s: parseFloat(this.adressList.longitude)
        };

        const recordInput = { fields };
        updateRecord(recordInput)
            .then(() => {
            })
            .catch(error => {
            })

    }
    //FOUK - 7331
    async checkForAuthorizationLimit() {
        let today = new Date();
        let authVal = [];
        let minauthValOfInsurance;
        let minauthValOfCorporate;
        let insuranceVsAccountRules = [];
        let corporateVsAccountRules = [];
        let quotsTotalIncludingTax = [];
        let quoteTotalIncludingTaxPayableByInsurance = [];
        let quoteTotalPayableByTradeIncludingTax = []

        for (let x of JSON.parse(this.currentPayload).quotes) {
            quotsTotalIncludingTax.push(x.quoteTotals.totalIncludingTax);
            quoteTotalIncludingTaxPayableByInsurance.push(x.insuranceTotals.totalIncludingTaxPayableByInsurance);
            quoteTotalPayableByTradeIncludingTax.push(x.tradeCompanyTotals.totalPayableByTradeIncludingTax);
        }
        let maxQuotsquoTsTotalIncludingTax = Math.max(...quotsTotalIncludingTax);
        let maxQuoteTotalInclusingTaxByInsurance = Math.max(...quoteTotalIncludingTaxPayableByInsurance);
        let maxquoteTotalPayableByTradeIncludingTax = Math.max(...quoteTotalPayableByTradeIncludingTax);

        if (this.corporateAccId != null && (this.corpObj.RecordType.DeveloperName == this.label.insuranceRecType || this.corpObj.RecordType.DeveloperName == this.label.corporateRecType)) {
            await accRuleParam({
                arpRecordType: Authorization_Limit,
                accountId: this.corporateAccId,
                jobDate: today

            })
                .then(async (result) => {

                    if (result != null) {
                        this.isArp = true;
                        for (let x of JSON.parse(JSON.stringify(result))) {
                            authVal.push(x.BLN_AuthorizationLimit__c);
                        }
                        let minauthVal = Math.max(...authVal);
                        if (minauthVal < maxQuotsquoTsTotalIncludingTax) {
                            await this.createBvtTask(this.label.authRequiredAmountLabel, this.corporateAccId);
                            if (this.corpObj.RecordType.DeveloperName == this.label.insuranceRecType) {
                                this.corporateFields[this.label.authorizationStatus] = this.label.corporateAuthorizationReqLabel;
                                this.corporateFields[this.label.insuranceAmountAuthorizationRequired] = true;

                            }
                            else {
                                this.corporateFields[this.label.authorizationStatusTrade] = this.label.corporateAuthorizationReqLabel;
                                this.corporateFields[this.label.corporateAmountAuthorizationRequiredTrade] = true;
                            }

                        }
                    }
                })
                .catch(error => {
                })
        }
        else if (this.corpObj.RecordType.DeveloperName == this.label.spiltBill && (this.insuranceAccId != null || this.corporateAccId != null)) {
            if (this.insuranceAccId != null) {
                await accRuleParam({
                    arpRecordType: Authorization_Limit,
                    accountId: this.insuranceAccId,
                    jobDate: today

                })
                    .then(async (result) => {
                        if (result != null) {
                            this.isArp = true;
                            for (let x of JSON.parse(JSON.stringify(result))) {
                                insuranceVsAccountRules.push(x.BLN_AuthorizationLimit__c);
                            }
                            if (insuranceVsAccountRules != null) {
                                minauthValOfInsurance = Math.max(...insuranceVsAccountRules);
                            }

                            if ((maxQuoteTotalInclusingTaxByInsurance > 0 && maxQuoteTotalInclusingTaxByInsurance == maxQuotsquoTsTotalIncludingTax) && (minauthValOfInsurance < maxQuotsquoTsTotalIncludingTax)) { 
                                await this.createBvtTask(this.label.authRequiredAmountLabel, this.insuranceAccId);
                            }
                            else if ((minauthValOfInsurance < maxQuoteTotalInclusingTaxByInsurance)&& (maxQuoteTotalInclusingTaxByInsurance > 0 && maxQuoteTotalInclusingTaxByInsurance != maxQuotsquoTsTotalIncludingTax)) {
                                await this.createBvtTask(this.label.authRequiredAmountLabel, this.insuranceAccId);
                            }

                            
                        }
                    })
                    .catch(error => {
                    })
            }

            if (this.corporateAccId != null) {
                await accRuleParam({
                    arpRecordType: Authorization_Limit,
                    accountId: this.corporateAccId,
                    jobDate: today
                })
                    .then(async (result) => {
                        if (result != null) {
                            this.isArp = true;
                            for (let x of JSON.parse(JSON.stringify(result))) {
                                corporateVsAccountRules.push(x.BLN_AuthorizationLimit__c);
                            }
                            if (corporateVsAccountRules != null) {
                                minauthValOfCorporate = Math.max(...corporateVsAccountRules);
                            }

                            if ((maxquoteTotalPayableByTradeIncludingTax > 0 && maxquoteTotalPayableByTradeIncludingTax == maxQuotsquoTsTotalIncludingTax) && (minauthValOfCorporate < maxQuotsquoTsTotalIncludingTax)) {
                                await this.createBvtTask(this.label.authRequiredAmountLabel, this.corporateAccId);
                            }
                            else if ((minauthValOfCorporate < maxquoteTotalPayableByTradeIncludingTax) && (maxquoteTotalPayableByTradeIncludingTax > 0 && maxquoteTotalPayableByTradeIncludingTax != maxQuotsquoTsTotalIncludingTax)) {
                                await this.createBvtTask(this.label.authRequiredAmountLabel, this.corporateAccId);
                            }
                        }
                    })
                    .catch(error => {
                    })
            }
            if (((minauthValOfInsurance < maxQuoteTotalInclusingTaxByInsurance)|| ((maxQuoteTotalInclusingTaxByInsurance > 0 && maxQuoteTotalInclusingTaxByInsurance == maxQuotsquoTsTotalIncludingTax) && (minauthValOfInsurance < maxQuotsquoTsTotalIncludingTax)) && (this.insuranceAccId != null))) {
                this.corporateFields[this.label.insuranceAmountAuthorizationRequired] = true;
                this.corporateFields[this.label.authorizationStatus] = this.label.corporateAuthorizationReqLabel;
            } else if ((minauthValOfCorporate < maxquoteTotalPayableByTradeIncludingTax) || ((maxquoteTotalPayableByTradeIncludingTax > 0 && maxquoteTotalPayableByTradeIncludingTax == maxQuotsquoTsTotalIncludingTax) && (minauthValOfCorporate < maxQuotsquoTsTotalIncludingTax)) && (this.corporateAccId != null)) {
                this.corporateFields[this.label.authorizationStatusTrade] = this.label.corporateAuthorizationReqLabel;
                this.corporateFields[this.label.corporateAmountAuthorizationRequiredTrade] = true;
            }
        }
    }
   
    async getDataCollectAnswer() {
        const accountIds = [];
        if(this.corporateAccId != null && (this.corpObj.RecordType.DeveloperName == this.label.insuranceRecType || this.corpObj.RecordType.DeveloperName == this.label.corporateRecType)){
            accountIds.push(this.corporateAccId);
        }
        if(this.corpObj.RecordType.DeveloperName == this.label.spiltBill && this.corpObj.BLN_InsuranceSite__c !== undefined){
            accountIds.push(this.corpObj.BLN_InsuranceSite__c);
        }
        if(this.corpObj.RecordType.DeveloperName == this.label.spiltBill && this.corpObj.BLN_CorporateSite__c != undefined){
            accountIds.push(this.corpObj.BLN_CorporateSite__c);
        }
        if(accountIds.length > 0){
            await getDataCollectAnswer({accountIds: accountIds, caseId: this.caseId})
            .then(result => {
                this.dataCollectCheck = result;
            })
            .catch(error => {
            })
    }


    }

    async checkForOEAuthorizedNext() {
        let today = new Date().toISOString().slice(0, 10);
        let allSelectedProductList = this.selectedProductList.concat(this.addOnProductList);
        if (allSelectedProductList.length > 0 && allSelectedProductList.some(product => product.isBondedNonBonded === true)) {
            if ((this.corpObj.RecordType.DeveloperName == this.label.insuranceRecType || this.corpObj.RecordType.DeveloperName == this.label.corporateRecType) && this.corporateAccId != null) {
               await accRuleParam({
                    arpRecordType: this.label.oEAuthorizationLabel,
                    accountId: this.corporateAccId,
                    jobDate: today
                })
                    .then(async(result) => {
                        if (result == null || result[0].BLN_OEAuthorization__c == this.label.oEAuthorizationReq) {
                           await this.createBvtTask(this.label.OEAuthorisedSubject, this.corporateAccId);

                            if (this.corpObj.RecordType.DeveloperName == this.label.insuranceRecType) {
                                this.corporateFields[this.label.authorizationStatus] = this.label.corporateAuthorizationReqLabel;
                                this.corporateFields[this.label.oEAuthorizationRequired] = true;

                            }
                            else {
                                this.corporateFields[this.label.authorizationStatusTrade] = this.label.corporateAuthorizationReqLabel;
                                this.corporateFields[this.label.oEAuthorizationRequiredTrade] = true;

                            }
                        }
                    })
                    .catch(error => {
                    })
            }
            else if (this.corpObj.RecordType.DeveloperName == this.label.spiltBill && this.corpObj.BLN_InsuranceSite__c !== undefined) {
               await accRuleParam({
                    arpRecordType: this.label.oEAuthorizationLabel,
                    accountId: this.corpObj.BLN_InsuranceSite__c,
                    jobDate: today

                })
                    .then(async(result) => {
                        if (result != null) {
                            this.isArp = true;
                        }
                        if (result != null && result[0].BLN_OEAuthorization__c == this.label.oEAuthorizationReq) {
                                await this.createBvtTask(this.label.OEAuthorisedSubject, this.corpObj.BLN_InsuranceSite__c);
                            this.corporateFields[this.label.authorizationStatus] = this.label.corporateAuthorizationReqLabel;
                            this.corporateFields[this.label.oEAuthorizationRequired] = true;

                        }
                        else if (result != null && result[0].BLN_OEAuthorization__c == this.label.oEMotoristLiability && this.corpObj.BLN_CorporateSite__c != undefined) {
                            await accRuleParam({
                                arpRecordType: this.label.oEAuthorizationLabel,
                                accountId: this.corpObj.BLN_CorporateSite__c,
                                jobDate: today

                            })
                                .then(async(result) => {
                                    if (result != null) {
                                        this.isArp = true;
                                    }
                                    if (result != null && result[0].BLN_OEAuthorization__c == this.label.oEAuthorizationReq) {
                                        await this.createBvtTask(this.label.OEAuthorisedSubject, this.corpObj.BLN_CorporateSite__c);
                                        this.corporateFields[this.label.authorizationStatusTrade] = this.label.corporateAuthorizationReqLabel;
                                        this.corporateFields[this.label.oEAuthorizationRequiredTrade] = true;
                                    }
                                })
                                .catch(error => {
                                })
                        }
                    })
                    .catch(error => {
                    })
            }
        }
    }
    async productRequiredAuthorizationNext() {
        let today = new Date().toISOString().slice(0, 10);
        let allSelectedProductList = this.selectedProductList.concat(this.addOnProductList);
        console.log('liableSelectedInsuranceProdList1108',liableSelectedInsuranceProdList);
        if((this.corpObj.RecordType.DeveloperName == this.label.insuranceRecType || this.corpObj.RecordType.DeveloperName == this.label.corporateRecType) && this.corporateAccId !=null){

           await accRuleParam({
            arpRecordType: productAllowanceRecType,
            accountId: this.corporateAccId,
            jobDate: today

        })
            .then(async(result) => {
                if(result!=null){

                    let isbvtAuth = false;

                    for (let x of result) {
                        if ((x.BLN_ProductAllowance__c === 'Allow All' || x.BLN_ProductAllowance__c === 'Allow') && x.BLN_AuthorisationRequired__c === true) {
                            if (allSelectedProductList.some(selectedProd =>selectedProd.prodCategory.startsWith(x.BLN_ProductCategory__c) || selectedProd.productId == x.BLN_Product__c )) {
                                isbvtAuth = true;
                                break;
                            }
                        }
                    }
                    if (isbvtAuth) {
                            await this.createBvtTask(this.label.productAuthorisedTaskSubtype,this.corporateAccId);
                        if (this.corpObj.RecordType.DeveloperName == this.label.insuranceRecType) {
                            this.corporateFields[this.label.authorizationStatus] = this.label.corporateAuthorizationReqLabel;
                            this.corporateFields[this.label.productAuthorisationRequired] = true;

                        }
                        else {
                            this.corporateFields[this.label.authorizationStatusTrade] = this.label.corporateAuthorizationReqLabel;
                            this.corporateFields[this.label.productAuthorisationRequiredTrade] = true;

                        }

                    }
                }
            })
            .catch(error => {
            })
        }
        if(this.corpObj.RecordType.DeveloperName == this.label.spiltBill && this.insuranceAccId !=null){
            
            await accRuleParam({
            arpRecordType: productAllowanceRecType,
            accountId: this.insuranceAccId,
            jobDate: today

        })
        .then(async(result)=>{
            if(result!=null){
                console.log('result1152',result);
                let isbvtAuth = false;

                    for (let x of result) {
                        if ((x.BLN_ProductAllowance__c === 'Allow All' || x.BLN_ProductAllowance__c === 'Allow') && x.BLN_AuthorisationRequired__c === true) {
                            if (allSelectedProductList.some(selectedProd => (selectedProd.prodCategory.startsWith(x.BLN_ProductCategory__c) || selectedProd.productId == x.BLN_Product__c ) && selectedProd.totalIncludingTaxPayableByInsurance > 0)) {
                                isbvtAuth = true;
                                break;
                            }
                        }
                    }

                if (isbvtAuth) {
                   
                    await this.createBvtTask(this.label.productAuthorisedTaskSubtype,this.insuranceAccId);
                    this.corporateFields[this.label.authorizationStatus] = this.label.corporateAuthorizationReqLabel;
                    this.corporateFields[this.label.productAuthorisationRequired] = true;
                }



            }

        }).catch(error=>{

        })
            
        }
        if(this.corpObj.RecordType.DeveloperName == this.label.spiltBill && this.corporateAccId !=null){
            
            await accRuleParam({
            arpRecordType: productAllowanceRecType,
            accountId: this.corporateAccId,
            jobDate: today

        })
        .then(async(result)=>{
            if(result!=null){
                let isbvtAuth = false;

                for (let x of result) {
                    if ((x.BLN_ProductAllowance__c === 'Allow All' || x.BLN_ProductAllowance__c === 'Allow') && x.BLN_AuthorisationRequired__c === true) {
                        if (allSelectedProductList.some(selectedProd =>(selectedProd.prodCategory.startsWith(x.BLN_ProductCategory__c) || selectedProd.productId == x.BLN_Product__c )&& selectedProd.totalPayableByTradeIncludingTax > 0)) {
                            isbvtAuth = true;
                            break;
                        }
                    }
                }
                if (isbvtAuth) {
                    await this.createBvtTask(this.label.productAuthorisedTaskSubtype,this.corporateAccId);
                    this.corporateFields[this.label.authorizationStatusTrade] = this.label.corporateAuthorizationReqLabel;
                    this.corporateFields[this.label.productAuthorisationRequiredTrade] = true;
                }
            }

        }).catch(error=>{

        });
            
        }
    }
    //5040-5041
    async automaticBVTTaskCreation() {
        if (this.corpObj.BLN_Origin__c != undefined && (this.corpObj.RecordType.DeveloperName == this.label.insuranceRecType || this.corpObj.RecordType.DeveloperName == this.label.corporateRecType) && this.corporateAccId != null) {
            //get today's date
            const today = new Date().toISOString();

            //method call
            await accRuleParam({ arpRecordType: 'Automatic Divert to Authorisation Team', accountId: this.corporateAccId, jobDate: today })
                .then(
                    async (accountRuleList) => {
                        if (accountRuleList != null && accountRuleList[0].BLN_AutomaticDiverttoAuthorisationTeam__c == AllCasesForValidation) {
                            this.isArp = true;

                            if (this.corpObj.BLN_Origin__c == 'Manual' || this.corpObj.BLN_Origin__c == 'PDS' || this.corpObj.BLN_Origin__c == 'Direct API') {

                                await this.createBvtTask(this.label.AssignDirectToBVT, this.corporateAccId);
                            }
                        }

                        if (accountRuleList != null && accountRuleList[0].BLN_AutomaticDiverttoAuthorisationTeam__c == NonPDSCasesForValidation) {
                            this.isArp = true;
                            if (this.corpObj.BLN_Origin__c == 'Manual') {
                                await this.createBvtTask(this.label.AssignDirectToBVT, this.corporateAccId);
                            }
                        }
                    }
                )
                .catch(error => {
                });
        }
        else if (this.corpObj.BLN_Origin__c != undefined && (this.corpObj.RecordType.DeveloperName == this.label.spiltBill) && (this.insuranceAccId != null || this.corporateAccId != null)) {
            await SplitBillBVT({ caseId: this.caseId, corporateObj: this.corpObj, slotDate: this.appointSlotDate })
            .then(() => {
                // Task updated successfully, perform any necessary actions
            })
            .catch(error => {
                // Handle error
                console.error('Error updating task New:', error);
            });
        }
        // }
    }

    // Navigate to case Page
    navigateToViewCasePage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.caseId,
                objectApiName: 'Case',
                actionName: 'view'
            },
        });
    }
    

    handleAfterHour(event) {
        if (event.target.checked) {
            this.isAfterHour = true;
            this.isRepriceBttnDisabled = false;

        } else {
            this.isAfterHour = false;
            this.isRepriceBttnDisabled = false;
        }
    }

    handleBack() {
        const summaryToSecondScreen = new CustomEvent('backscreen', {
            detail: {
                caseIdBack: this.caseId,
                liabilityListBack: this.liabilityList,
                isCashJourneyBack: this.isCashJourney,
                discountBack: this.discount,
                currentPayloadBack: this.currentPayload,
                selectedProductListBack: this.selectedProductList,
                addOnProductListBack: this.addOnProductList,
                selectedLocationBack: this.selectedLocation,
                locationListBack: this.locationList,
                appointmentScreenData: this.appointmentScreenData,
                isBack: true,
                isPrimaryLocation: this.primaryLocation

            }
        })
        this.dispatchEvent(summaryToSecondScreen);
    }

    handleRepriceClick() {
        // const afterHoursElement = this.template.querySelector('.spanTextContainerthree');
        this.isLoading = true;
        if (this.isAfterHour) {
            // afterHoursElement.innerText = this.afterHours;
            this.afterHourData = this.afterHourObj;
        }
        else {
            // afterHoursElement.innerText = '£0.00';
            this.afterHourData = {};
        }
        if (this.isRebooking == true) {
            this.currentPayload = this.getQuotePayload;
        }
        this.repriceCallout();
    }

    repriceCallout() {
        console.log('thisafter1205', JSON.stringify(this.afterHourObj));
        this.isLoading = true;
        let repriceRequest = this.createNewRepriceJson();
        console.log('repriceRequest1209', repriceRequest);
        makeRepriceCallout({
            repriceRequestPayload: repriceRequest,
            currentPayload: this.currentPayload,
            caseRecordId: this.caseId
        })
        .then(result => {
            let calloutResult = JSON.parse(result);
            if(calloutResult.status == 'Success'){
                this.currentPayload = calloutResult.currentPayload;
                console.log('currentPayload1217', this.currentPayload);
                this.appointmentList = [];
                setTimeout(() => {
                    this.refreshPrices(this.currentPayload);
                    this.showSummaryOnUI();
                    this.mobileChargeStatusCheck(this.currentPayload);    
                },1);
            }
            else{
                this.showErrorAlert(`\n Error : ${calloutResult.errorMessage}`, 'error', this.label.errorOccurred);
            }
        })
        .catch(error => {
            this.showErrorAlert(`\n Error : ${error.body.message}`, 'error', this.label.errorOccurred);        
            this.isLoading = false;
        })
    }

    refreshPrices(payload) {
        structureDataForQuoteUI({
            payload: payload,
            caseId: this.caseId
        })
            .then(res => {
                let parsedDisplayData = this.objConvert(res);
                this.liabilityList = this.objConvert(parsedDisplayData.liabilityDataList);
                let selectedProdList = [];
                let count = 0;
                for (let prod of parsedDisplayData.productDataList) {
                    prod.activeElement = "active";
                    prod.isChildBOM = prod.hierarchy == 'child' ? true : false;
                    prod.isParent = prod.hierarchy == 'parent' ? true : false;
                    prod.isChildBundle = prod.partOfBundle && prod.bundleHierarchy ? Number.isInteger(parseFloat(prod.bundleHierarchy)) ? false : true : false;
                    prod.isCheckedByDefault = prod.selectProduct && !prod.hideOnUI;
                    prod.childMandatory = prod.bomMandatory;
                    prod.itemIndex = count++;
                    prod.isQtyDisabled = true;
                    prod.colorCode = this.setTileColor(prod);
                    prod.isAddAllDisabled = true;
                    prod.isChild = (prod.isChildBOM || prod.isChildBundle) ? true : false;
                    let selectProd = this.selectedProductList.find(selectProd => selectProd.belronProductCode == prod.belronProductCode && prod.selectProduct == true);
                    if(selectProd){
                        selectedProdList.push(prod);
                    }
                    else if(prod.selectProduct == true && this.afterHourData.partNumber == prod.belronProductCode){
                        selectedProdList.push(prod);
                    }

                }
                this.selectedProductList = selectedProdList;
                if (this.isCashJourney == true && this.isRebooking == false) {
                    let currentPayloadData = JSON.parse(this.currentPayload);
                    console.log('currentPayloadData1236', currentPayloadData);
                    for (let quote of currentPayloadData.quotes) {
                        if (quote.quoteId == this.selectedLocation.quoteId) {
                            this.quoteVat = quote.motoristTotals.totalIncludingTaxPayableByMotorist;
                            this.quoteTotal = '£' + parseFloat(quote.motoristTotals.totalIncludingTaxPayableByMotorist).toFixed(2);
                        }
                    }
                } 
                else if (this.isCashJourney == false) {
                    let currentPayloadData = JSON.parse(this.currentPayload);
                    let totalsArray = this.getTotalsFromPayloadOnLocation(currentPayloadData,this.selectedLocation.locationGUID);
                    this.quoteTotal = '£' + parseFloat(totalsArray.motoristTotal).toFixed(2);

                    // this.liabilityList.forEach(ele => {
                    //     if (ele.liabilityCategory == this.label.motoristLiability) {
                    //         this.quoteTotal = '£' + ele.totalIncludingTaxPayable;
                    //         this.includingTax = ele.totalIncludingTaxPayable;
                    //         this.quoteVat = ele.totalTaxPayable
                    //     }
                    // })
                }
                if (this.isRebooking == true && this.isCashJourney == true) {
                    let currentPayloadData = JSON.parse(this.currentPayload);
                    let totalsArray = this.getTotalsFromPayloadOnLocation(currentPayloadData,this.selectedLocation.locationGUID);
                    //this.quoteVat = currentPayloadData.quotes[0].quoteTotals.totalTax;
                    //this.quoteTotal = '£' + currentPayloadData.quotes[0].quoteTotals.totalIncludingTax;
                    this.quoteTotal = '£' + parseFloat(totalsArray.motoristTotal).toFixed(2);
                }
                this.isLoading = false;
            })
            .catch(error => {
                this.isLoading = false;
            })
    }
    setTileColor(prod) {
        let colorCode = "background-color: white;";

        if (prod != null && prod.prodCategory != null && prod.prodCategory != '' && (prod.prodCategory.toLowerCase()).includes('vaps')) {
            colorCode = "background-color: lightgreen;"
        }
        else if (prod != null && prod.hierarchy != '') {
            colorCode = "background-color: yellow;";
        }

        return colorCode;
    }
    createNewRepriceJson() {
        let currentPayloadData = JSON.parse(this.currentPayload);
        let repriceRequest = [];
        for (let quote of currentPayloadData.quotes) {
            let lineItems = [];
            let eachQuoteData = {
                id: quote.quoteId,
                caseId: this.caseId,
                discount: this.selectedLocation ? this.selectedLocation.quoteId == quote.quoteId ? this.discountAmount ? this.discountAmount : 0 : 0 : this.discountAmount ? this.discountAmount : 0,
                chfVATStatus: '',
            };
            if (Object.keys(this.afterHourData).length>0) {
                eachQuoteData.afterHours = this.afterHourData.partDescription;
            }

            for (let lineItem of quote.lineItems) {
                let lineItemData = {};
                lineItemData.lineId = (lineItem.lineItemId).toString();

                let currentProd = this.hiddenProductList.concat(this.addOnProductList.concat(this.selectedProductList)).find(prod => prod.mdmId == lineItem.partNumber && prod.netPriceIncludingTax == lineItem.netPriceIncludingTax && prod.bomId == (lineItem.parentBOMId == undefined ? '' : lineItem.parentBOMId));
                if (currentProd) {

                    lineItemData.quantity = parseInt(currentProd.quantity);
                    lineItemData.selectProduct = true;
                }
                else if (this.afterHourData.partNumber == lineItem.belronPartNumber) {
                    lineItemData.quantity = parseInt(lineItem.quantity);
                    lineItemData.selectProduct = true;
                }
                else {
                    lineItemData.quantity = parseInt(lineItem.quantity);
                    lineItemData.selectProduct = false;
                }
                lineItems.push(lineItemData);
            }
            eachQuoteData.lineItems = [...lineItems];
            repriceRequest.push(eachQuoteData);
        }
        console.log('repriceRequest',repriceRequest);
        return JSON.stringify(repriceRequest);
    }

    async createBvtTask(subjectType, accountId) {
        await createBvtTask({ caseId: this.caseId, subjectType: subjectType, slotDate: this.appointSlotDate, taskAccId: accountId })
            .then(async (result) => {
                if (result != null && result != undefined && result != null) {
                    this.taskId = result;
                   
                }
            })
            .catch(error => {
                console.log('error in createBVT', JSON.stringify(error));
            });
    }
    // This is creating an issue for rebooking deployment
    stockReqCallout(createList, updateList, deleteList) {

    }

    getTotalsFromPayloadOnLocation(payload,locationId){
        let totalsArray = {};
        for(let quote of payload.quotes){
            if(quote.locationId == locationId){
                totalsArray.motoristTotal = parseFloat(quote.motoristTotals.totalIncludingTaxPayableByMotorist);
                totalsArray.tradeCompanyTotal = parseFloat(quote.tradeCompanyTotals.totalPayableByTradeIncludingTax);
                totalsArray.insuranceTotal = parseFloat(quote.insuranceTotals.totalIncludingTaxPayableByInsurance);
                totalsArray.quoteTotal = parseFloat(quote.quoteTotals.totalIncludingTax);

                break;
            }
        }
        return totalsArray;
    }

    handleMobileChargeClick(event){
        this.isMobileChargeApplied = event.target.checked;
        this.hiddenProductList = this.objConvert(this.hiddenProductList);

        if(this.isMobileChargeApplied){
            let quoteData = JSON.parse(JSON.stringify(this.quoteDataList));
            for(let quote of quoteData){
                if(quote.quoteId === this.selectedLocation.quoteId){
                    for(let prod of quote.productList){
                      if(((prod.productDescription).toUpperCase()).includes('MOBILE CHARGE')){
                        this.hiddenProductList.push(prod);
                        break;
                      }  
                    }
                    break;
                }
            }
        }
        else{
            let mobProd = null;
            mobProd = this.hiddenProductList.find(prod => ((prod.productDescription).toUpperCase()).includes('MOBILE CHARGE'));
            if(mobProd){
                this.hiddenProductList.splice(this.hiddenProductList.indexOf(mobProd), 1);                
            }   
        }
    }

    async mobileChargeStatusCheck(currentPayload){
        if(this.selectedLocation.isMobileLocation == true){
            console.log('step1',this.selectedLocation.isMobileLocation);
            this.isBranchLocSelected = false;
            let currentPayloadData = JSON.parse(currentPayload);

            for(let quote of currentPayloadData.quotes){
                if(quote.quoteId == this.selectedLocation.quoteId){
                    for(let lineItem of quote.lineItems){
                        if(lineItem.partDescription == 'MOBILE CHARGE'){
                            this.isMobileChargeApplied = lineItem.selectProduct;
                        }
                    }
                }
            }
        }
        else{
            this.isBranchLocSelected = true;
        }
    }

    successErrorToast(title, errorMessage, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: errorMessage,
                variant: variant
            })
        );
    }

    closeFlow() {
        getFocusedTabInfo().then(tabinfo => closeTab(tabinfo.tabId));
    }
}