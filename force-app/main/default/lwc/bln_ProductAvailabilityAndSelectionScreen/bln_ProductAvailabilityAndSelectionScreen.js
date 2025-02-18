import { LightningElement, api, track, wire } from 'lwc';
import { updateRecord, getRecord,getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import structureDataForQuoteUI from '@salesforce/apex/BLN_ProductAvailability.structureDataForQuoteUI';
import makeQuoteCalloutWithFourLocations from '@salesforce/apex/BLN_ProductAvailability.makeQuoteCalloutWithFourLocations';
import makeRepriceCallout from '@salesforce/apex/BLN_ProductAvailability.makeRepriceCallout';
import getCorporateRecord from '@salesforce/apex/BLN_ProductAuthorisation.getCorporateRecord';
import accRuleParam from '@salesforce/apex/BLN_AccountRuleParameterUtil.getAccountRuleParameters';//
import updateCorporateReAmt from '@salesforce/apex/BLN_ProductAuthorisation.updateCorporateReAmt';
import productAllowanceRecType from '@salesforce/label/c.BLN_ProductAllowanceRecTypeName';
import getProductAllowance from '@salesforce/apex/BLN_ProductAuthorisation.getProductAllowance';
import getKnowledgeArticles from '@salesforce/apex/BLN_FetchKnowledgeArticles.getKnowledgeArticles';
import makeQuoteCalloutWithSpecificOrderLocation from '@salesforce/apex/BLN_CreditAndRebillController.makeQuoteCalloutWithSpecificOrderLocation';
import makeQuoteCalloutForISPLocation from '@salesforce/apex/BLN_ProductAvailability.makeQuoteCalloutForISPLocation';
import createOrderAndOrderItemsForISP from '@salesforce/apex/BLN_QuoteBookingHandler.createOrderAndOrderItemsForISP';

import AutoDivertoAuthTeamRecordType from '@salesforce/label/c.BLN_AutoDivertoAuthTeamRecordType';
import AssignDirectToBVT from '@salesforce/label/c.BLN_AssignDirectToBVT';
import NonPDSCasesForValidation from '@salesforce/label/c.BLN_NonPDSCasesForValidation';
import AllCasesForValidation from '@salesforce/label/c.BLN_AllCasesForValidation';
import BundleProductCheckJobRequest from '@salesforce/label/c.BLN_BundleProductCheckJobRequest';
import JobRequest from '@salesforce/label/c.BLN_JobRequest';
import PrimeProdBODY_GLASS from '@salesforce/label/c.BLN_PrimeProdBodyGlass';
import PrimeProdWINDSCREEN from '@salesforce/label/c.BLN_PrimeProdWindscreen';
import  prompt from '@salesforce/label/c.bln_RepairCustomMessage';
import Warranty from '@salesforce/label/c.BLN_Warranty';
import AccountId from "@salesforce/schema/Case.AccountId";
import isQuantityEditable from '@salesforce/customPermission/BLN_AllowedQuantityChange';
import createOrderAndOrderItemsAfterRebill from '@salesforce/apex/BLN_CreditAndRebillController.createOrderAndOrderItemsAfterRebill'
import getAccountRuleParameters from '@salesforce/apex/BLN_AccountRuleParameterUtil.getAccountRuleParameters';

import LightningAlert from 'lightning/alert';
import { getFocusedTabInfo, closeTab } from 'lightning/platformWorkspaceApi';
import { FlowAttributeChangeEvent, FlowNavigationBackEvent, FlowNavigationNextEvent, FlowNavigationFinishEvent } from 'lightning/flowSupport';

import select from '@salesforce/label/c.BLN_QuoteSelect';
import product from '@salesforce/label/c.BLN_QuoteProduct';
import price from '@salesforce/label/c.BLN_QuotePrice';
import quantity from '@salesforce/label/c.BLN_QuoteQty';
import discount from '@salesforce/label/c.BLN_QuoteDiscount';
import reprice from '@salesforce/label/c.BLN_Reprise';
import Vat from '@salesforce/label/c.BLN_QuoteVAT';
import Total from '@salesforce/label/c.BLN_QuoteTotal';
import Net from '@salesforce/label/c.BLN_QuoteNet';
import Name from '@salesforce/label/c.BLN_QuoteName';
import lowOffer from '@salesforce/label/c.BLN_Lowoffer';
import mediumOffer from '@salesforce/label/c.BLN_Mediumoffer';
import highOffer from '@salesforce/label/c.BLN_Highoffer';
import location from '@salesforce/label/c.BLN_Location';
import discountError from '@salesforce/label/c.BLN_DiscountError';
import discountBandHeader from '@salesforce/label/c.BLN_DiscountBandHeader';
import lowOfferStartValue from '@salesforce/label/c.BLN_LowOfferStartValue';
import negativeDiscountError from '@salesforce/label/c.BLN_NegativeDiscountError';
import selectLocationError from '@salesforce/label/c.BLN_SelectLocationError';
import hasPermission from '@salesforce/customPermission/BLN_ProductSelectionDiscountBand';
import hasPermissionSet from '@salesforce/customPermission/BLN_CERCustom';
import errorForTeamManager from '@salesforce/label/c.BLN_ErrorForTeamManager';
import NonMandatory from '@salesforce/label/c.BLN_NotMandatory';
import Mandatory from '@salesforce/label/c.BLN_Mandatory';
import Authorization_Limit from '@salesforce/label/c.BLN_AuthorizationLimitArgument';
import Authorization_Limit_Error from '@salesforce/label/c.BLN_AuthorizationLimitBreachError';
import closeWindowErrorMessage from '@salesforce/label/c.BLN_CloseWindowErrorMessage';
import Repair1Branch from '@salesforce/label/c.BLN_Repair1Branch';
import Repair1Mobile from '@salesforce/label/c.BLN_Repair1Mobile';
import Repair2 from '@salesforce/label/c.BLN_Repair2';
import Repair3 from '@salesforce/label/c.BLN_Repair3';
import error from '@salesforce/label/c.BLN_Error';
import errorOccurred from '@salesforce/label/c.BLN_ErrorOccur';
import addAll from '@salesforce/label/c.BLN_AddAll';
import close from '@salesforce/label/c.BLN_CLoseLabel';
import cancel from '@salesforce/label/c.BLN_Cancel';
import next from '@salesforce/label/c.BLN_Next';
import InvalidPrice from '@salesforce/label/c.BLN_InvalidPrice';
import MoreThanOneBundleSelectedError from '@salesforce/label/c.BLN_QuotePresentationBundleRestrictionMsg';
import OEAuthorisedSubject from '@salesforce/label/c.BLN_OEAuthorisedSubject';
import assignedDirectSubject from '@salesforce/label/c.BLN_AssignedDirectSubject';
import productExcessRecType from '@salesforce/label/c.BLN_ProductExcessRecTypeName';
import authRequiredAmountLabel from '@salesforce/label/c.BLN_AuthRequiredAmount';
import oEAuthorizationLabel from '@salesforce/label/c.BLN_OEAuthorizationLabel';
import getIsFirstCustomPermission from '@salesforce/apex/BLN_ProductAvailability.getIsFirstCustomPermission';
import makeNewQuoteCallout from '@salesforce/apex/BLN_ProductAvailabilityRebook.makeNewQuoteCallout';
import getOrderItemsToIdentifyByCPQExternalId from '@salesforce/apex/BLN_ProductAvailabilityRebook.getOrderItemsToIdentifyByCPQExternalId';
import getOrderItemsToIdentifyByStatus from '@salesforce/apex/BLN_ProductAvailabilityRebook.getOrderItemsToIdentifyByStatus';
import callCPQCloneAPI from '@salesforce/apex/BLN_ProductAvailabilityRebook.callCPQCloneAPI';
import getCaseData from '@salesforce/apex/BLN_ProductAvailabilityRebook.getCaseData';
import QuoteId_FIELD from "@salesforce/schema/Case.BLN_CPQQuoteIdCollection__c";
import makeCloneQuoteCallout from '@salesforce/apex/BLN_ProductAvailabilityRebook.callCPQCloneAPI';
import branchavailableError from '@salesforce/label/c.BLN_BranchavailableError';
import caseSubType from "@salesforce/schema/Case.BLN_SubType__c";
import insuranceRecType from '@salesforce/label/c.BLN_Insurance';
import corporateRecType from '@salesforce/label/c.BLN_CorporateFleet';
import spiltBill from '@salesforce/label/c.BLN_SpiltBill';
import productCodeLabel from '@salesforce/label/c.BLN_ProductCode';
import checkADASScriptProduct from '@salesforce/apex/BLN_FetchKnowledgeArticles.checkADASScriptProduct';
const FIELDS = ['Case.BLN_SubType__c',QuoteId_FIELD,];





const fields = [AccountId,QuoteId_FIELD];//
export default class Bln_ProductAvailabilityAndSelectionScreen extends LightningElement {

    @api caseId;
    @api caseIdTask='';//
    @api isOrderExistOnCase;
    @api isCashJourney;
    @api caseType;
    @api caseSubType;
    @api accountName;
    @api isExitFlow;
    @api productSelectionData;
    @api availableActions = [];
    @api accountId;
    @track productList;
    @track discountBandList;
    @api taskId;
    @api cpqExternalId;
    @api fromCnRFlow = false;
    customPermission = false;
    firstScreenVisited;
    @track locationList;
    @track liabilityList;
    @track earliestDateList = [];
    @track isShowModal = false;
    invalidAgreedPrice = false;
    selectedLocation = null;
    isBranchavailable = true;
    quoteDataList = [];
    addOnProductList = [];
    selectedProductList = [];
    hiddenProductList = [];
    locationThresholdList = [];
    initialParentChildRatios = new Map();
    isVapsSelected;
    authorizationErrorModalClosed = false;
    isProductSelected = false;
    showSpinner = true;
    showModal = false;
    triggerArticles = false;
    showLocationPanel = false;
    isNextDisabled = false;
    hasPermission = hasPermission;
    hasPermissionCer = hasPermissionSet;
    showAppointmentBookingPage = false;
    @api showProductSelectionPage;
    @api currentPayload;
    @api getQuotePayload;
    discountBandDetails = [];
    isDiscountDisabled = true;
    isRepriceBttnDisabled = true;
    selectionChanged;
    isDataRevised = false;
    discountAmount = null;
    agreedPrice = null;
    isReprice = false;
    isQtyUpdated = false;
    repricedPayload;
    repriceRequest = null;
    isUserInputCorrect;
    oeActionFlag = false;
    discountUpdated = false;
    agreedPriceUpdated = false;
    isConfirmDisabled = false;
    @track quoteRanges;
    @track discount = 0;
    oeAuthorized;
    isPrimaryProduct = false;
    locationDisabled = false;
    isProductAuthorized = false;
    productAuthorized;
 	@api isFirstLoadComplete = false;

    // fouk-6283 Varible
    isPrimaryProduct = false;
    isFirstScreen = true;
    isRebookingchild = false;
    isRebookAssign = false;
    @api isLocationChange = false;
    @api isRebooking = false;
    @api adressList = [];
    @api articleList = [];
    showArticleComp = false;
    @api displayedArticles = [];
    @api lastSelectedProd = {};
    userLatitude = '';
    userLongitude = '';
    showConfirmButton = false;
    @api existingGuid = '';
    @api cpqExternalCode = '';
    @api caseExternalIds = '';
    @api isForceReprice = false;
    @track chfVatStatus = '';
    @api isRefresh;
    identifierList = null;
    @api oldSelectedProductList;
    @api oldAddOnProductList;
    @api isChangeProduct;
    @api existingProductData = [];
    @api  allOrderItemsList = [];
    @api accountRuleParameters = [];
    isFirstRepriceComplete = false;
    corporateAccId =null;
    corporateObj = {};
    quoteIds = '';
    @api productDataListRebook = [];
    @api isChangeProductFirstTime;
    hasCompletedAppointments = false;
    repairPartFlag=false; 

    showAuthorizationLimitError = true;
    productIdentifierValidate = [];
    @api earliestDataDetail = [];
    @api adasProductList = [];
    @api bomIdWithPromseDateTime = [];
   
    subjectArticleList = ['CE Location Job', 'Centre appointment', 'Dynamic Appointments', 'Dealer Referral', 'Removed Advisor', 'Motability Account Script'];
    label = {
        select,
        product,
        price,
        productCodeLabel,
        quantity,
        Vat,
        Total,
        Net,
        Name,
        Mandatory,
        highOffer,
        lowOffer,
        mediumOffer,
        discountBandHeader,
        discountError,
        location,
        negativeDiscountError,
        lowOfferStartValue,
        selectLocationError,
        errorForTeamManager,
        discount,
        reprice,
        NonMandatory,
        Authorization_Limit,
        Authorization_Limit_Error,
        closeWindowErrorMessage,
        error,
        errorOccurred,
        addAll,
        close,
        cancel,
        next,
        Warranty,
        OEAuthorisedSubject,
        assignedDirectSubject,
        authRequiredAmountLabel,
        productExcessRecType,
        AssignDirectToBVT,//
        AutoDivertoAuthTeamRecordType,
        MoreThanOneBundleSelectedError,//
        oEAuthorizationLabel,
        branchavailableError,
        InvalidPrice,
        BundleProductCheckJobRequest,
        JobRequest,
        PrimeProdBODY_GLASS,
        PrimeProdWINDSCREEN,
        insuranceRecType,
        corporateRecType,
        spiltBill,
    Repair1Branch,
        Repair1Mobile,
        Repair2,
        Repair3
    }

    checkedEvent = false;

    @wire(getRecord, {
        recordId: "$caseId",
        fields
      })
      case;

     @wire(getRecord,{recordId: "$caseId", fields: FIELDS}) 
     caseRecord;

    get subType(){
        return this.caseRecord.data ? this.caseRecord.data.fields.BLN_SubType__c.value : '';
    }

    @wire(getIsFirstCustomPermission)
    checkCustomPermission({ error, data }) {
        if (data) {
            this.locationDisabled = this.fromCnRFlow && data ? true : false;;
        } 
        else if (error) {
            console.log('error is : ' + JSON.stringify(error))
        }
    }

    renderedCallback(){
        console.log('this.prod lists-->',this.selectedProductList, this.addOnProductList);
        console.log('earliestDateList',this.earliestDateList);
    }

    async connectedCallback() {
        this.isOrderExistOnCase = false;
        this.showSpinner = true;
        this.showConfirmButton = this.fromCnRFlow || (this.caseType == 'Job Request' && this.caseSubType == 'ISP') ? true : false;
        this.oldSelectedProductList = this.oldSelectedProductList ? this.objConvert(this.oldSelectedProductList) : [];
        this.oldAddOnProductList = this.oldAddOnProductList ? this.objConvert(this.oldAddOnProductList) : [];

        checkADASScriptProduct()
        .then(adasProdList => {
        console.log('adasProdList',JSON.stringify(adasProdList));
        this.adasProductList = adasProdList;
           
        }).catch(error=>{
            console.log('Error while fetching Adas products from metadata',error);
        });
  
        await getCorporateRecord({ caseId: this.caseId })
        .then(result=>{
            this.corporateObj = result;
            console.log('corporateObj', this.corporateObj);
            if( this.corporateObj ){
                if( (this.corporateObj.RecordType.DeveloperName == this.label.insuranceRecType || this.corporateObj.RecordType.DeveloperName == this.label.spiltBill)  && this.corporateObj.BLN_InsuranceSite__c !== undefined){
                    this.corporateAccId = this.corporateObj.BLN_InsuranceSite__c;
                }
                else if((this.corporateObj.RecordType.DeveloperName == this.label.insuranceRecType || this.corporateObj.RecordType.DeveloperName == this.label.spiltBill)  && this.corporateObj.BLN_InsuranceSite__c === undefined){
                    this.corporateAccId = this.corporateObj.BLN_InsuranceLegalEntity__c;
                }
                else if(this.corporateObj.RecordType.DeveloperName == this.label.corporateRecType && this.corporateObj.BLN_CorporateSite__c!==undefined){
                    this.corporateAccId = this.corporateObj.BLN_CorporateSite__c;
                }
                else if(this.corporateObj.RecordType.DeveloperName == this.label.corporateRecType && this.corporateObj.BLN_CorporateSite__c===undefined){
                    this.corporateAccId = this.corporateObj.BLN_CorporateLegalEntity__c;
                }
            }
        })
        .catch(error=>{
            console.log('Error while fetching corporate records',error);
        });

        getKnowledgeArticles({
            articleTitle: this.subjectArticleList
        })
        .then(res => {
            this.articleList = res;
        })
        .catch(error => {
            console.log('article error-->',error);
        });
        
        this.runBookingPath();
    }

    handleBackArray(event) {
        if (event.detail.isback) {
            this.showAppointmentBookingPage = false;
            this.showProductSelectionPage = true;
            setTimeout(() => {
                this.selectAllDefaultProducts();
            }, 1);
        }
        else {
            this.showProductSelectionPage = false;
            this.showAppointmentBookingPage = true;
        }
    }

    /* Custom event to pass the appointmentId & earliestAvailability Date both para to scheduleAppointmentContainer Cmp */
    earliestavaiDetailfromlocationHandler(event) {
        this.earliestDataDetail.push(event.detail);
    }

    runBookingPath() {
        let userLatitude = this.adressList.latitude;
        let userLongitude = this.adressList.longitude;
        
        if (this.isRebooking == true) {
            if(this.isLocationChange == true ){
            makeNewQuoteCallout({
                userLatitude: parseFloat(userLatitude),
                userLongitude: parseFloat(userLongitude),
                motoristCaseId: this.caseId,
                    existingGUId: this.existingGuid
                })
                .then(result => {
                    let calloutResult = JSON.parse(result);
                    if( calloutResult.status == 'Success'){
                        this.currentPayload = calloutResult.currentPayload;

                    getOrderItemsToIdentifyByCPQExternalId({
                        cpqExtrnlId: this.cpqExternalCode,
                    })
                        .then((res) => {
                            this.identifierList = res;
                            this.handleRepriceClick();
                        })
                        .catch(error => {
                            this.showErrorAlert(`\n Error : ${error.body.message}`, 'error', this.label.errorOccurred);
                        });
                    }else{
                        this.showErrorAlert(`\n Error : ${calloutResult.errorMessage}`, 'error', this.label.errorOccurred);
                    }
                })
                .catch(error => {
                    this.showErrorAlert(`\n Error : ${error.body.message}`, 'error', this.label.errorOccurred);
                })
            }
             else if(this.isChangeProduct == true){
                this.quoteIds = getFieldValue(this.caseRecord.data, QuoteId_FIELD);
                this.productList = [...this.existingProductData];
                
                if(this.isChangeProductFirstTime) {
                    if(this.isForceReprice){
                        makeQuoteCalloutWithFourLocations({
                            motoristCaseId: this.caseId
                        })
                        .then(result => {
                            let calloutResult = JSON.parse(result);
                            if( calloutResult.status == 'Success'){
                                this.currentPayload = calloutResult.currentPayload;

                            getOrderItemsToIdentifyByCPQExternalId({
                                cpqExtrnlId: this.cpqExternalCode,
                            })
                            .then(res => {
                                this.identifierList = res;
                                this.handleRepriceClick();
                            })
                            .catch(error => {
                                    this.showErrorAlert(`\n Error : ${error.body.message}`, 'error', this.label.errorOccurred);
                                });
                            }else{
                                this.showErrorAlert(`\n Error : ${calloutResult.errorMessage}`, 'error', this.label.errorOccurred);
                            }
                            })
                        .catch(error => {
                            this.showErrorAlert(`\n Error : ${error.body.message}`, 'error', this.label.errorOccurred);
                        })
                    }
                    else{
                        console.log('caseExternalIds',this.caseExternalIds);
                        console.log('isChangeProductFirstTime',this.isChangeProductFirstTime);
                        this.isChangeProductFirstTime = false;
                        callCPQCloneAPI({
                            quoteIds: this.caseExternalIds,
                            caseId: this.caseId
                        })
                        .then(result => {
                            this.currentPayload = result;
                            this.showProductsOnUI(this.currentPayload, this.caseId);

                            this.showProductSelectionPage = true;
                        })
                        .catch(error => {
                            this.showErrorAlert(`\n Error : ${error.body.message}`, 'error', this.label.errorOccurred);
                        });
                        
                    }
                } 
                else {
                    this.showProductsOnUI(this.currentPayload, this.caseId);
                    this.showProductSelectionPage = true;
                }
            }
            else if(this.isForceReprice == true){
                console.log('isForceReprice in runBookingPath',this.isForceReprice);
                makeQuoteCalloutWithFourLocations({
                    motoristCaseId: this.caseId
                })
                .then(result => {
                    let calloutResult = JSON.parse(result);
                    if( calloutResult.status == 'Success'){
                        this.currentPayload = calloutResult.currentPayload;

                    getOrderItemsToIdentifyByCPQExternalId({
                        cpqExtrnlId: this.cpqExternalCode,
                    })
                    .then(res => {
                        this.identifierList = res;
                        this.handleRepriceClick();
                    })
                    .catch(error => {
                            this.showErrorAlert(this.label.closeWindowErrorMessage + `\n Error : ${error.body.message}`, 'error', this.label.errorOccurred);
                        });
                    }else{
                        this.showErrorAlert(`\n Error : ${calloutResult.errorMessage}`, 'error', this.label.errorOccurred);
                    }
                    })
                .catch(error => {
                    this.showErrorAlert(`\n Error : ${error.body.message}`, 'error', this.label.errorOccurred);
                })
            }
           
        }
        else if(this.fromCnRFlow){
            getCaseData({ caseId: this.caseId })
            .then(result => {
                this.isForceReprice = result.BLN_IsForceReprice__c;

                if(this.isForceReprice == false){
                    getOrderItemsToIdentifyByCPQExternalId({
                        cpqExtrnlId: this.cpqExternalId,
                    })
                    .then(res => {
                        this.identifierList = res;
                        callCPQCloneAPI({
                            quoteIds: this.cpqExternalId,
                            caseId: this.caseId
                        })
                        .then(result => {
                            this.currentPayload = result;
                            this.showProductsOnUI(this.currentPayload, this.caseId);

                            this.showProductSelectionPage = true;
                        })
                        .catch(error => {
                            this.showErrorAlert( `\n Error : ${error.body.message}`, 'error', this.label.errorOccurred);
                        })    
                    })
                    .catch(error =>{
                        this.showErrorAlert( `\n Error : ${error.body.message}`, 'error', this.label.errorOccurred);
                    })
                }
                else{
                    makeQuoteCalloutWithSpecificOrderLocation({
                        cpqExternalId: this.cpqExternalId
                    })
                    .then(result => {
                        let calloutResult = JSON.parse(result);
                        if( calloutResult.status == 'Success'){
                            this.currentPayload = calloutResult.currentPayload;

                        getOrderItemsToIdentifyByCPQExternalId({
                            cpqExtrnlId: this.cpqExternalId,
                        })
                        .then(res => {
                            this.identifierList = res;
                            this.handleRepriceClick();
                        })
                        .catch(error => {
                                this.showErrorAlert( `\n Error : ${error.body.message}`, 'error', this.label.errorOccurred);
                        })
                        }else{
                            this.showErrorAlert(`\n Error : ${calloutResult.errorMessage}`, 'error', this.label.errorOccurred);
                        }
                    })
                    .catch(error => {
                        this.showErrorAlert(`\n Error : ${error.body.message}`, 'error', this.label.errorOccurred);
                    })
                }
            })
        }
        else{
            if( !this.isChangeProductFirstTime && this.isChangeProduct ){
                this.showProductsOnUI(this.currentPayload, this.caseId);
            }
            else{
                if(this.caseType == 'Job Request' && this.caseSubType == 'ISP'){
                    makeQuoteCalloutForISPLocation({
                        motoristCaseId: this.caseId
                    })
                    .then(result => {
                        let calloutResult = JSON.parse(result);
                        if( calloutResult.status == 'Success'){
                            this.currentPayload = calloutResult.currentPayload;

                            this.showProductsOnUI(this.currentPayload,this.caseId);
                        this.showProductSelectionPage = true;
                        }else{
                            this.showErrorAlert(`\n Error : ${calloutResult.errorMessage}`, 'error', this.label.errorOccurred);
                        }
                    })
                    .catch(error => {
                        this.showErrorAlert(`\n Error : ${error.body.message}`, 'error', this.label.errorOccurred);
                    })    
                }
                else{    
            makeQuoteCalloutWithFourLocations({
                motoristCaseId: this.caseId
            })
            .then(result => {
                        let calloutResult = JSON.parse(result);
                        if( calloutResult.status == 'Success'){
                            this.currentPayload = calloutResult.currentPayload;

                            this.showProductsOnUI(this.currentPayload, this.caseId);
                    this.showProductSelectionPage = true;
                        }else{
                            this.showErrorAlert(`\n Error : ${calloutResult.errorMessage}`, 'error', this.label.errorOccurred);
                        }
                })
                .catch(error => {
                        this.showErrorAlert(`\n Error : ${error.body.message}`, 'error', this.label.errorOccurred);
                    });
    }
            }
        }
    }

    async closeFlow() {
        getFocusedTabInfo().then(tabinfo => closeTab(tabinfo.tabId));
    }

    showProductsOnUI(payload) {
        structureDataForQuoteUI({
            payload : payload,
            caseId : this.caseId
        })
            .then(res => {
                this.productIdentifierValidate = res.productIdentifier != null ? res.productIdentifier: '';
                let parsedDisplayData = this.objConvert(res);
                this.discountBandDetails = this.objConvert(parsedDisplayData.discountBandDetails);
                this.earliestDateList = this.objConvert(parsedDisplayData.earliestAvailabilityList);
                this.liabilityList = this.objConvert(parsedDisplayData.liabilityDataList);
                this.selectedLocation = parsedDisplayData.selectedLocation ? this.objConvert(parsedDisplayData.selectedLocation):null;
                this.selectedProductList = JSON.parse(JSON.stringify(parsedDisplayData.prodLists))[0];
                this.addOnProductList = JSON.parse(JSON.stringify(parsedDisplayData.prodLists)).length > 1 ? JSON.parse(JSON.stringify(parsedDisplayData.prodLists))[1] : [];
                this.hasCompletedAppointments = parsedDisplayData.hasCompletedAppointments;
                this.accountRuleParameters = res.accountRuleParameters;
                this.quoteDataList = this.objConvert(parsedDisplayData.quoteDataList);
                console.log('this.quoteDataList',this.quoteDataList);
                let count = 0;
                let childProductList = [];
                let parentProductList = [];
                let hiddenProdList = [];
                let isPrompt = true;
                for (let prod of parsedDisplayData.productDataList) {
                    if(this.accountRuleParameters.length > 0 && isPrompt && prod.repairPart == true && !this.repairPartFlag && prod.selectProduct){
                    
                        //this.repairPartFlag = true; 
                        this.showAlert(prompt, 'warning', this.label.errorOccurred);
                        isPrompt = false;
                    }
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

                    if (prod.isParent) {
                        parentProductList.push(prod);
                    }
                    else if(prod.isChildBOM) {
                        childProductList.push(prod);
                    }

                    if(prod.selectProduct && prod.hideOnUI){
                        console.log('prodhit',prod);
                        hiddenProdList.push(prod);
                        console.log('prodhit2',hiddenProdList);
                    }
                }
                this.hiddenProductList = this.objConvert(hiddenProdList);
                this.hiddenProductList = JSON.parse(JSON.stringify(this.hiddenProductList));
                console.log('hiddenProdStringify',JSON.stringify(this.hiddenProductList));
                console.log('hiddenProductList',this.hiddenProductList);
                this.productList = this.objConvert(parsedDisplayData.productDataList);

                if (this.initialParentChildRatios.size == 0) {
                    for (let parentProd of parentProductList) {
                        let childProds = this.productList.filter(child => child.bomId == parentProd.bomId);
                        let childRatioList = [];
                        childProds.forEach(childProd => {
                            childRatioList.push({
                                mdmId: childProd.mdmId,
                                ratio: parseInt(parentProd.quantity) / parseInt(childProd.quantity)
                            });
                        });
                        this.initialParentChildRatios.set(parentProd.bomId, [...childRatioList]);
                    }
                }

                for (let loc of parsedDisplayData.quoteDetailsDataList) {
                    loc.class = "locationStyle slds-align_absolute-center section-title section-title-background slds-m-top_medium slds-m-around_small  slds-listbox__item";
                    loc.quoteEarliestAppointmentAvailability_Formatted = this.formatDate(new Date(loc.quoteEarliestAppointmentAvailability));
            }
            this.locationList = this.objConvert(parsedDisplayData.quoteDetailsDataList);
            
                this.isUserInputCorrect = true;
                this.quoteRanges = this.agreedPriceCalc();

                this.showSpinner = false;
                this.triggerArticles = true;
                
                if (!this.selectedLocation) {
                    this.isDiscountDisabled = true;
                }else {
                    this.isDiscountDisabled = false;
                }

                this.checkForConditionalRendering();

                this.isReprice = false;
                this.isQtyUpdated = false;
                this.agreedPriceUpdated = false;
                this.selectionChanged = false;
                this.showLocationPanel = true;

            setTimeout(()=> {
                    this.selectAllDefaultProducts();
                }, 1);
            })
            .catch(error => {
                this.showErrorAlert(this.label.closeWindowErrorMessage + `\n Error : ${error.message}`, 'error', this.label.errorOccurred);
        })
    }

     async showErrorAlert(msg,theme,heading){
        if(this.showSpinner){
            await LightningAlert.open({
                 message: msg,
                 theme: theme,
                 label: heading
             });

            this.closeFlow();
        }
    }
    showAlert(msg, theme, heading) {       
        LightningAlert.open({
            message: msg,
            theme: theme,
            label: heading
        });
    }

    selectPreviouslySelectedProds(){
        let productsToSelect = this.addOnProductList.concat(this.selectedProductList);
        if(productsToSelect.length > 0){
            productsToSelect = this.objConvert(productsToSelect);
            this.addOnProductList = [];
            this.selectedProductList = [];
            for(let prod of productsToSelect){
                let elementToSelect = this.template.querySelector(`lightning-input[data-bom-id="${prod.bomId}"][data-hierarchy="${prod.hierarchy}"][data-prod-code="${prod.mdmId}"]`);
                if(!elementToSelect.checked){
                    elementToSelect.checked = true;
                    elementToSelect.dispatchEvent(new CustomEvent('change'));
                }
            }
        }
        this.selectionChanged = false;
        //console.log('sel list', this.selectedProductList, this.addOnProductList);
       console.log('SelectedProductList1234', JSON.stringify(this.selectedProductList), this.addOnProductList);
    }

    checkForConditionalRendering(){
        this.checkSelectionReprice();

        this.isPrimaryProduct = false;
        this.selectedProductList.forEach( res => {
          if(res.isParent == true){
           this.isPrimaryProduct = true;
          }
        });

        this.isPrimaryProduct = true;

        if(this.isPrimaryProduct == true && this.subType != this.label.Warranty){
            this.isProductSelected = this.selectedProductList.length ? true : false;
        } 
        else if(this.subType == this.label.Warranty){
        this.isProductSelected = this.selectedProductList.length ? true : false;
       }
        console.log('sadsad',this.repairPartFlag,this.isQtyUpdated,this.isReprice,this.agreedPriceUpdated,this.selectionChanged);
        this.isRepriceBttnDisabled = !(this.isQtyUpdated || this.isReprice || this.agreedPriceUpdated || this.selectionChanged); //this.repairPartFlag ||
         
        this.checkForNextAndConfirmButtonStatus();
        //this.showLocationPanel = false;

        for (let i = 0; i < this.selectedProductList.length; i++) {
            if (this.selectedProductList[i].prodCategory != null && this.selectedProductList[i].prodCategory != '' && (this.selectedProductList[i].prodCategory.toLowerCase()).includes('vaps')) {
                this.isVapsSelected = true;
                break;
            }
            else{
                this.isVapsSelected = false;
            }
        }
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


    handleQtyChange(event){
        let updatedQty = parseInt(event.target.value);
        //console.log('uq', updatedQty);
        let allSelectedProductList = this.selectedProductList.concat(this.addOnProductList);
        //console.log('all', allSelectedProductList);
        allSelectedProductList.forEach(element => {
            if (element.itemIndex == event.target.dataset.indexQty && element.mdmId == event.target.dataset.productCodeQty) {
                //console.log('got it', element);
                    element.quantity = updatedQty;
                }          
            });


        this.isQtyUpdated = false;
        if(updatedQty != NaN && updatedQty > 0 && event.target.checkValidity()){        
            for(let i = 0 ; i < allSelectedProductList.length; i++){
                let elementFromProdList = this.productList.find(element => element.itemIndex == allSelectedProductList[i].itemIndex);
                //console.log('elementFromProdList-->', elementFromProdList);
                //console.log('selectedProductList-->', allSelectedProductList[i]);
                if(allSelectedProductList[i].quantity != NaN && allSelectedProductList[i].quantity > 0){
                    if(elementFromProdList.quantity != allSelectedProductList[i].quantity){
                        this.isQtyUpdated = true;
                    }
                }
                else {
                    this.isQtyUpdated = false;
                    break;
                }
            }
        }
        this.checkForConditionalRendering();
    }

    selectAllDefaultProducts() {
        this.selectedProductList = [];
        this.addOnProductList = [];
        
        let allMandatoryProdElements  = this.template.querySelectorAll(`lightning-input[data-is-checked-by-default=true]`);
        allMandatoryProdElements.forEach(element => {
            if (!element.checked) {
                element.checked = true;
                element.dispatchEvent(new CustomEvent('change', { detail: { clickHistory: 'onload' } }));
            }
        });

        let allNonMandatoryProdElements = this.template.querySelectorAll('lightning-input[data-is-checked-by-default=false]');
        allNonMandatoryProdElements.forEach(element => {
            if (element.checked) {
                element.checked = false;
                element.dispatchEvent(new CustomEvent('change', { detail: { clickHistory: 'onload' } }));
            }
        });

        setTimeout(() => {
            if(this.isFirstLoadComplete == false){
                this.isFirstLoadComplete = true;
                this.triggerArticles = true;
               // this.showAlert();
            }    
        }, 10);
        this.selectionChanged = false;
        this.isQtyUpdated = false;
        this.refreshLocationPanel();
    }

    checkSelectionReprice() {
        this.selectionChanged = false;

        this.productList.every(item => {
            if (item.isCheckedByDefault) {
                this.selectionChanged = !this.addOnProductList.concat(this.selectedProductList).some(prod => prod.itemIndex == item.itemIndex);
            }
            else{
                this.selectionChanged = this.addOnProductList.concat(this.selectedProductList).some(prod => prod.itemIndex == item.itemIndex);
            }
            return !this.selectionChanged;
        });
    }
    

    flipQtyInput(selectedProduct) {
        let currentItem = this.productList.find(item => item.itemIndex == selectedProduct.itemIndex);
        try{
        if(isQuantityEditable){
        currentItem.isQtyDisabled = selectedProduct.isQtyDisabled = !currentItem.isQtyDisabled;
            }
            else{
                currentItem.isQtyDisabled = true;
            }
        }
        catch(error){
            console.log(error); 
            console.log('You do not have permission to edit Quantity field, Please add Allow Product Qty Update Permission -', JSON.stringify(isQuantityEditable));
        }
    }

    flipAddAllBttn(selectedProduct) {
        let currentItem = this.productList.find(item => item.itemIndex == selectedProduct.itemIndex);
        if(currentItem.isParent){
            currentItem.isAddAllDisabled = selectedProduct.isAddAllDisabled = !currentItem.isAddAllDisabled;
        }
    }

    addAllBttnOn(selectedProduct) {
        let currentItem = this.productList.find(item => item.itemIndex == selectedProduct.itemIndex);
        if (currentItem.isParent) {
            currentItem.isAddAllDisabled = selectedProduct.isAddAllDisabled = false;
        }

    }
    addAllBttnOff(selectedProduct){
        let currentItem = this.productList.find(item => item.itemIndex == selectedProduct.itemIndex);
        if (currentItem.isParent) {
            currentItem.isAddAllDisabled = selectedProduct.isAddAllDisabled = true;
        }

    }

    handleAddAllClick(event) {
        let currentItemChildElements = this.template.querySelectorAll(`lightning-input[data-hierarchy="child"][data-bom-id="${event.target.dataset.bomIdAddBttn}"]`);
        for (let element of currentItemChildElements) {
            if (element.checked != true) {
                element.checked = true;
                element.dispatchEvent(new CustomEvent('change'));
            }
        }

        let currentItemQtyElement = this.template.querySelector(`lightning-input[data-index-qty="${event.target.dataset.indexAddBttn}"]`);
        let selectedProd = this.productList.find(element => element.itemIndex == event.target.dataset.indexAddBttn);
        currentItemQtyElement.value = parseInt(parseInt(currentItemQtyElement.value) ? parseInt(currentItemQtyElement.value) < 0 ? selectedProd.quantity : currentItemQtyElement.value : selectedProd.quantity) + 1;
        currentItemQtyElement.dispatchEvent(new CustomEvent('change'));

        let currentItemChildQtyElements = this.template.querySelectorAll(`lightning-input[data-hierarchy-qty="child"][data-bom-id-qty="${selectedProd.bomId}"]`);
        for (let element of currentItemChildQtyElements) {
            let ratioValue = this.initialParentChildRatios.get(element.dataset.bomIdQty).find(item => item.mdmId == element.dataset.productCodeQty).ratio;
            element.value = Math.ceil(ratioValue) + (parseInt(element.value) <= 0 ? 0 : parseInt(element.value));          
            element.dispatchEvent(new CustomEvent('change'));
        }
    }

    resetQtyValue(selectedProduct) {
        let currentElement = this.template.querySelector(`lightning-input[data-product-code-qty="${selectedProduct.mdmId}"][data-index-qty="${selectedProduct.itemIndex}"]`);
        currentElement.value = selectedProduct.quantity;
        currentElement.dispatchEvent(new CustomEvent('change',{detail : 'qtyReset'}));
    }

    createNewRepriceJson(){
        let currentPayloadData = JSON.parse(this.currentPayload);
        let repriceRequest = [];
        
        for (let quote of currentPayloadData.quotes) {
            let lineItems = [];
            let eachQuoteData = {
                id: quote.quoteId,
                caseId: this.caseId,
                afterHours: '',
                chfVATStatus: this.corporateObj && this.corporateObj.BLN_CHFVATStatus__c ? this.corporateObj.BLN_CHFVATStatus__c : '',
            };
            if(this.agreedPriceUpdated){
                eachQuoteData.quoteDiscountType = "targetPrice";
                eachQuoteData.quoteDiscountValue = this.selectedLocation ?  this.agreedPrice ? this.agreedPrice : 0 : 0;
            }
            // if(this.oeActionFlag) {
            //     eachQuoteData.oeAuthorized = this.oeAuthorized;
                
            // }
            if(this.isProductAuthorized){
                eachQuoteData.productAuthorized = this.productAuthorized;
            }
            for(let lineItem of quote.lineItems){
                let lineItemData = {};
                lineItemData.lineId = (lineItem.lineItemId).toString();
                
                let currentProd = this.hiddenProductList.concat(this.addOnProductList.concat(this.selectedProductList)).find(prod => prod.lineItemId == lineItem.lineItemId);
                if (currentProd) {
                    lineItemData.quantity = parseInt(currentProd.quantity);
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
        
        return JSON.stringify(repriceRequest);
    }

    buildRepriceJsonForRebooking(mainJson,identifierList){
        let mainJson_parsed = JSON.parse(mainJson);
        let identifierList_parsed = JSON.parse(identifierList);
        console.log('identifierList_parsed',identifierList);
        let repriceRequest = [];

        for(let quote of mainJson_parsed.quotes){
            let lineItems = [];
            let eachQuoteData = {
                id: quote.quoteId,
                caseId: this.caseId
            };

            if(this.oeActionFlag) {
                eachQuoteData.oeAuthorized = this.oeAuthorized;
                
            }

            for(let lineItem of quote.lineItems){
                let lineItemData = {};
                lineItemData.lineId = (lineItem.lineItemId).toString();

                let currentLineItem = identifierList_parsed.find(item => lineItem.partNumber == (item.partNumber == '' ? null : item.partNumber)  && lineItem.parentBOMId == (item.bomId == '' ? null : item.bomId)  && lineItem.bundleName == (item.bundleName == '' ? null : item.bundleName));
                 console.log('currentLineItem',currentLineItem);
                if(currentLineItem){
                    lineItemData.quantity = parseInt(currentLineItem.quantity) == null ? 1 : parseInt(currentLineItem.quantity);
                    lineItemData.selectProduct = currentLineItem.isSelected;
                }
                else{
                    lineItemData.quantity = parseInt(lineItem.quantity);
                    lineItemData.selectProduct = false;
                }
                lineItems.push(lineItemData);
            }
            eachQuoteData.lineItems = [...lineItems];
            repriceRequest.push(eachQuoteData);
        }
        return JSON.stringify(repriceRequest);
    }


    async handleRepriceClick() {
        this.locationDisabled = false;      
        this.showSpinner = true;
        this.showAuthorizationLimitError = true;

        let repriceRequest;
        if(!this.isFirstRepriceComplete && ((this.isRebooking == true && this.isLocationChange == true) || (this.fromCnRFlow == true && this.isForceReprice == true) || this.isForceReprice == true)){

            repriceRequest = this.buildRepriceJsonForRebooking(this.currentPayload,this.identifierList);
            //this.isLocationChange = false;
            this.isForceReprice = false;
        }
        else{
            if(this.corporateAccId){
                //await this.checkForOEAuthorizedReprice();
                //await this.checkForPassLiability();
            }
            repriceRequest = this.createNewRepriceJson();
        }

        makeRepriceCallout({
            repriceRequestPayload : repriceRequest,
            currentPayload : this.currentPayload,
            caseRecordId : this.caseId
        })
            .then(result => {
                let calloutResult = JSON.parse(result);

                if(calloutResult.status == 'Success'){
                    this.currentPayload = calloutResult.currentPayload;
            this.isFirstRepriceComplete = true;
                    this.showProductsOnUI(this.currentPayload);
            this.showProductSelectionPage = true;
                }
                else{
                    this.showErrorAlert(`\n Error : ${calloutResult.errorMessage}`, 'error', this.label.errorOccurred);
                }
        })
        .catch(error => {
            this.showErrorAlert(`\n Error : ${error.body.message}`, 'error', this.label.errorOccurred);        
        })
        .finally(() => {
            this.invalidAgreedPrice = false;
        } )
        
        // if(this.corporateAccId){
        //    this.productRequiredAuthorizationReprice();
        // }    
        this.checkForReAuthorisation();
    }

    async checkForReAuthorisation(){
           let quotsTotalIncludingTax = [];
            for (let x of JSON.parse(this.currentPayload).quotes) {
                quotsTotalIncludingTax.push(x.quoteTotals.totalIncludingTax);
            }
            let maxQuotsquoTsTotalIncludingTax = Math.max(...quotsTotalIncludingTax);
        /*Fouk-10664*/
        if(this.corporateObj && this.corporateObj.RecordType.DeveloperName != this.label.spiltBill){
            if (this.corporateObj.RecordType.DeveloperName == this.label.insuranceRecType && this.corporateObj && this.corporateObj.BLN_ApprovedLimit__c != undefined && this.corporateObj.BLN_AuthorizationStatus__c == this.label.approvedLabel) {
                console.log('this.corporateObj.BLN_AmountAuthorized__c',this.corporateObj.BLN_AmountAuthorized__c,maxQuotsquoTsTotalIncludingTax)
                if (this.corporateObj.BLN_AmountAuthorized__c < maxQuotsquoTsTotalIncludingTax) {
    
                    const fields = {};
                    fields[this.label.corpObjId] = this.corporateObj.Id;
                    fields[this.label.authorizationStatus] = this.label.corporateAuthorizationReqLabel;
                    fields[this.label.amountAuthorizationRequired] = true;
                    fields[this.label.amountAuthorized] = maxQuotsquoTsTotalIncludingTax;
                    const corpRecordInput = { fields };
                    updateRecord(corpRecordInput)
                        .then(() => {
                            console.log('Insurance record updated 1121');
                    })
                    .catch(error => {
                        console.log('Error', error);
                    });
                }
            }
            else if (this.corporateObj && this.corporateObj.RecordType.DeveloperName == this.label.corporateRecType && this.corporateObj.BLN_ApprovedLimit__c != undefined && this.corporateObj.BLN_AuthorizationStatusTrade__c == this.label.approvedLabel) {
         
                if (this.corporateObj.BLN_AmountAuthorizedTrade__c < maxQuotsquoTsTotalIncludingTax) {
    
                    const fields = {};
                    fields[this.label.corpObjId] = this.corporateObj.Id;
                    fields[this.label.authorizationStatusTrade] = this.label.corporateAuthorizationReqLabel;
                    fields[this.label.amountAuthorizationRequiredTrade] = true;
                    fields[this.label.amountAuthorizedTrade] = maxQuotsquoTsTotalIncludingTax;
                    const corpRecordInput = { fields };
                    updateRecord(corpRecordInput)
                        .then(() => {
                            console.log('Corporate record updated1140');
                    })
                    .catch(error => {
                        console.log('Error', error);
                    });
                }
            }
        }/*Fouk-10664*/
        

    }
    //Added for FOUK-3801 start
   async checkForAuthorizationLimit() {
        let today = new Date().toISOString();
        let authVal = [];
        let quotsTotalIncludingTax = [];
        for (let x of JSON.parse(this.currentPayload).quotes) {
            quotsTotalIncludingTax.push(x.quoteTotals.totalIncludingTax);
        }
        let maxQuotsquoTsTotalIncludingTax = Math.max(...quotsTotalIncludingTax);
       await getAccountRuleParameters({
            arpRecordType: Authorization_Limit,
            accountId: this.corporateAccId,
            jobDate: today
            
        })
            .then(result => {
            if(result == null){
                authVal.push(maxQuotsquoTsTotalIncludingTax);
            }
            else{
                for(let x of JSON.parse(JSON.stringify(result))) {
                    authVal.push(x.BLN_AuthorizationLimit__c);
                }
            }
            let minauthVal = Math.max(...authVal);
            if (minauthVal < maxQuotsquoTsTotalIncludingTax) {
                this.showSpinner = false;
                this.isShowModal = true;
            }
            else{
                this.authorizationErrorModalClosed = true;
            }
        })
        .catch(error => {
            this.authorizationErrorModalClosed = true;
                console.log('error log', error);
            })
    }

   async checkForPassLiability() {
       let today = new Date().toISOString().slice(0, 10);
        this.isProductAuthorized = false;

        await getProductAllowance({
            arpRecordType: productAllowanceRecType,
            accountId: this.corporateAccId,
            jobDate: today

        })
            .then(result => {
                if(result.length > 0){
                const productAllownceSet = new Set();
                const productAllownceCategorySet = new Set();
                for (let x of result) {
                    if (x.BLN_ProductAllowance__c == 'Pass Liability' && x.BLN_AuthorisationRequired__c == true) {
                        productAllownceSet.add(x.BLN_Product__c);
                        productAllownceCategorySet.add(x.BLN_ProductCategory__c);
                    }
                }

                if (this.selectedProductList.length > 0 && this.selectedProductList.some(product => productAllownceCategorySet.has(product.prodCategory) || productAllownceSet.has(product.productId)) && this.corporateObj.BLN_AuthorizationStatus__c == 'Approved') {
                    this.isProductAuthorized = true;
                    this.productAuthorized = this.corporateObj.BLN_ProductAuthorised__c;
                }
            }
            })
            .catch(error => {
                console.log('error log while fetching product allowance', error);
            })
    }

    hideModalBox() {
        this.isShowModal = false;
        this.isBranchavailable = true;
        this.authorizationErrorModalClosed = true;
        const fields = {
            Id: this.caseId,
            BLN_AuthLimitBreached__c: true
        };

        const recordInput = { fields };
        updateRecord(recordInput)
        .then(() => {
        })
        .catch(error => {
                console.log('Error updating case record: ',error);
        })
            this.handleNextClick();
    }
    //Added for FOUK-3801 End

    handleCheckboxClick(event){
        let isCheckboxChecked = event.target.checked;
        this.checkedEvent = event.target.checked;
        let itemCode = event.target.value;
        let itemIndex = event.target.dataset.index;
        let selectedProduct = Object.assign({}, this.productList.find(item => item.mdmId == itemCode && item.itemIndex == itemIndex));
        this.lastSelectedProd = selectedProduct;
        this.flipQtyInput(selectedProduct);
        
        if (isCheckboxChecked) {
            this.addAllBttnOn(selectedProduct);

            if(selectedProduct.partOfBundle){
                this.selectedProductList.push(selectedProduct);
                let childProducts = this.productList.filter(item => (item.lineItemId != selectedProduct.lineItemId) && (item.parentLineItemId == selectedProduct.lineItemId));
                childProducts.forEach(item => {
                    this.addOnProductList.push(Object.assign({},item));
                });
            }

            else if(selectedProduct.hierarchy == 'child') {
                let parentProduct = this.productList.find(item => item.bomId == selectedProduct.bomId && item.hierarchy == 'parent');

                let parentElement = this.template.querySelector(`lightning-input[data-hierarchy="parent"][data-index="${parentProduct.itemIndex}"]`);
                this.addOnProductList.push(selectedProduct);
                if(parentElement.checked != true){
                    parentElement.checked = true;
                    parentElement.dispatchEvent(new CustomEvent('change',{detail : {clickHistory : 'childClicked'}}));
                }
            }
            else if (selectedProduct.hierarchy == 'parent') {
                this.selectedProductList.push(selectedProduct);
                    let uncheckedChildProductsElements = this.template.querySelectorAll(`lightning-input[data-child-mandatory=true][data-hierarchy="child"][data-bom-id="${selectedProduct.bomId}"]`);
                    for(let element of uncheckedChildProductsElements){
                        if(element.checked != true){
                            element.checked = true;
                            element.dispatchEvent(new CustomEvent('change',{detail : {clickHistory : 'parentClicked'}}));
                        }
                    }
            }
            else {
                this.selectedProductList.push(selectedProduct);
            }

            if(this.triggerArticles && this.articleList.length > 0){
                this.showArticle();
            }
        }
        else{
            this.resetQtyValue(selectedProduct);
            this.addAllBttnOff(selectedProduct);

            let itemToRemove = this.addOnProductList.concat(this.selectedProductList).find(item => item.itemIndex == selectedProduct.itemIndex);

            if(selectedProduct.partOfBundle){
                this.selectedProductList.splice(this.selectedProductList.indexOf(itemToRemove), 1);
                this.addOnProductList = this.addOnProductList.filter(item => item.parentLineItemId != itemToRemove.lineItemId);
            }

            else if (selectedProduct.hierarchy == 'child') {
                this.addOnProductList.splice(this.addOnProductList.indexOf(itemToRemove), this.addOnProductList.indexOf(itemToRemove) == -1 ? 0 : 1);
            }
            else if (selectedProduct.hierarchy == 'parent') {
                this.selectedProductList.splice(this.selectedProductList.indexOf(itemToRemove), 1);
                let childProductElements = [...this.template.querySelectorAll(`lightning-input[data-hierarchy="child"][data-bom-id="${itemToRemove.bomId}"]`)];
                for(let element of childProductElements){
                    if(element.checked == true){
                        element.checked = false;
                        element.dispatchEvent(new CustomEvent('change'));
                    }
                }
            }
            else{
                this.selectedProductList.splice(this.selectedProductList.indexOf(itemToRemove), 1);
            }

            if(this.triggerArticles && this.articleList.length > 0){
                this.showArticle();
                // this.selectedProductChanged = itemToRemove;
                //ANKITA
            }
        }
        //this.refreshLocationPanel();
        this.checkForConditionalRendering();
    }
    refreshLocationPanel(){
        this.showLocationPanel = false;
        console.log('falseee');
        setTimeout(() => {
            this.showLocationPanel = true;
            console.log('truee');
        }, 10);
    }
    showArticle(){
        this.showArticleComp = false;
        setTimeout(() => {
            this.showArticleComp = true;
        }, 1);
    }

    handleDisplayedArticles(event){
        this.showArticleComp = false;
        this.displayedArticles = JSON.parse(event.detail.alreadyDisplayedArticles);
    }

    handleSelectedLocation(event) {
        let clickedLocation = JSON.parse(event.detail.selectedLocation);
        if (this.selectedLocation && clickedLocation && (clickedLocation.locationGUID == this.selectedLocation.locationGUID)) {
            this.selectedLocation = null;
            this.isDiscountDisabled = true;
        } else {
            this.selectedLocation = clickedLocation;
this.template.querySelectorAll('lightning-input').forEach(element => {
            element.setCustomValidity('');
            element.reportValidity();
        });
            this.isDiscountDisabled = false;
        }

        if(!this.selectedLocation){
            this.isDiscountDisabled = true;
            this.agreedPrice = null;
        }

        this.locationList = JSON.parse(event.detail.locationData);
        this.checkForNextAndConfirmButtonStatus();
    }
              
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
    handleAppointmentData(event){

        

        if(this.earliestDataDetail){
            for(let i = 0; i < this.earliestDataDetail.length; i++){
                if(this.earliestDataDetail[i].locationId == event.detail.locationId){
                    this.earliestDataDetail.splice(i,1);
                    break;
                }
            }
        }

        this.earliestDataDetail.push(event.detail);

    }


    checkForNextAndConfirmButtonStatus() {
        let areAllProductsUnchanged = false;
        let allProds = this.selectedProductList.concat(this.addOnProductList);

        for (let i = 0; i < allProds.length; i++) {
            let currentProd = null;
            currentProd = this.productList.find(prod => prod.itemIndex == allProds[i].itemIndex);
            if (JSON.stringify(currentProd) == JSON.stringify(allProds[i])) {
                areAllProductsUnchanged = true;
            }
            else {
                areAllProductsUnchanged = false;
                break;
            }

        }

        /* repair product should be select then you can procced */
        let isRepairProduct = false;
        if(this.accountRuleParameters.length > 0 ){
            this.selectedProductList.forEach(item => {
                this.accountRuleParameters.forEach(arp => {
                    if(!isRepairProduct && arp.isDoNotShowAll == true) {
                        isRepairProduct = true;
                    } else if(!isRepairProduct && (arp.productCategory == this.label.Repair1Branch || arp.productCategory == this.label.Repair2 ||
                        arp.productCategory == this.label.Repair3 || arp.productCategory == this.label.Repair1Mobile)) {
                        isRepairProduct = true;  
                    }
                });
            });
        } else {
            isRepairProduct = false;
        }
        this.isNextDisabled = areAllProductsUnchanged && this.isProductSelected && this.selectedLocation && this.isRepriceBttnDisabled && !this.invalidAgreedPrice ? false : true; //this.isConfirmDisabled = !this.repairPartFlag &&
        this.isNextDisabled = isRepairProduct ? isRepairProduct : this.isNextDisabled;
    }

    objConvert(obj){
        return JSON.parse(JSON.stringify(obj));
    }

    async handleNextClick() {
        let isValid = this.validateConfirm();
        console.log('--isValid--',isValid);
        console.log(this.subType,'--this.isRebooking--',this.isRebooking);
        if(this.subType === this.label.JobRequest && isValid == false) {
            this.showErrorAlert(this.label.BundleProductCheckJobRequest, 'error', this.label.errorOccurred);
        } else {
            isValid = true;
        }

        if(isValid){
        this.showSpinner = true;
        
        if(this.showAuthorizationLimitError){
            await this.checkForAuthorizationLimit();
            this.showAuthorizationLimitError = false;
        }
        this.showSpinner = false;
        
        if(this.authorizationErrorModalClosed){
        let countBundle = 0;

        let isRepairProduct = false;
        if(this.accountRuleParameters.length > 0) {
            this.selectedProductList.forEach(item => {
                countBundle = item.partOfBundle == true ? countBundle + 1 : countBundle;
                this.accountRuleParameters.forEach(arp => {
                    if(!isRepairProduct && arp.isDoNotShowAll == true) {
                        isRepairProduct = true;
                    } else if(!isRepairProduct && arp.productCategory == item.prodCategory && arp.productCode == item.productCode) {
                        isRepairProduct = true;  
                    }
                });
            });
        } else {
            isRepairProduct = false;
        }
        if (countBundle > 1) {
            let showError = new ShowToastEvent({
                title : 'Error!',
                message : this.label.MoreThanOneBundleSelectedError
            });
            this.dispatchEvent(showError);
            } 
            // else if(isRepairProduct == false) {
            //     let showError = new ShowToastEvent({
            //         title : 'Error!',
            //         message : 'Atleast one product should be repair select.'
            //     });
            //     this.dispatchEvent(showError);
            // }
            else if(isValid == true) {
            if(this.isChangeProduct == true){
                this.isRebooking=true;
                if(this.existingProductData != null && this.existingProductData.length > 0)
                    this.existingProductData = [...this.existingProductData];
                if(this.allOrderItemsList != null && this.allOrderItemsList.length > 0)
                    this.allOrderItemsList = [...this.allOrderItemsList];
            }
          
                this.firstScreenVisited = true;
            this.showAppointmentBookingPage = true;
            this.showProductSelectionPage = false;
            this.isChangeProductFirstTime = false;
        }
    }
    }
    }

    async handleConfirmClick(){
        this.showSpinner = true;
        
        if(this.showAuthorizationLimitError){
            await this.checkForAuthorizationLimit();
            this.showAuthorizationLimitError = false;
        }

        if(this.authorizationErrorModalClosed){
            this.showSpinner = true; 
                // this.selectedProductList.forEach(res => {
                //     this.identifierList.forEach(result =>{                       
                //         if (result.outOfStock && res.selectProduct && this.fromCnRFlow) {
                //          this.isBranchavailable  = true;
                //          }
                //     });                 
                //  });
                //  console.log('this.identifierList',this.identifierList);          
        // this.addOnProductList.forEach(res => {
        //     if (res.isBranchOnlyProduct == false && res.selectProduct && this.fromCnRFlow) {
        //         this.isBranchavailable  = false;
        //     }
        // });
       
        if(this.fromCnRFlow){
          // if(this.isBranchavailable){
                createOrderAndOrderItemsAfterRebill({
                    mainJson: this.currentPayload,
                    existingOrderItemData: this.identifierList,
                    quoteId: this.cpqExternalId,
                    locationId: this.selectedLocation.locationGUID
                })
                .then(res =>{
                        this.showSpinner = false;
                        this.closeFlow();
                })
                .catch(error =>{
                    this.showSpinner = false;
                })
        //    }
        //     else{
        //         this.showSpinner = false;
        //         this.hideModalBoxForBranch();
                
        //     }
        }
        else if(this.caseType == 'Job Request' && this.caseSubType == 'ISP'){
                createOrderAndOrderItemsForISP({
                payload: this.currentPayload,
                caseId : this.caseId
            })
            .then(res =>{
                    this.showSpinner = false;
                    this.closeFlow();
            })
            .catch(error =>{
                this.showSpinner = false;
            })
        }
    }
        
    }

    validateConfirm() {
        let matchList = [];
        let unSelectedDifferenceList = [];
        this.oldSelectedProductList.forEach(item => {
            var isMatchCorrect = false;
            this.selectedProductList.forEach(itemIdent => {
                if(!matchList.includes(item.prodCategory) && item.prodCategory === itemIdent.prodCategory) {
                    isMatchCorrect = true;    
                }
                if(!unSelectedDifferenceList.includes(item.prodCategory) && item.prodCategory != itemIdent.prodCategory) {
                    unSelectedDifferenceList.push(item); 
                }
            });
            if(isMatchCorrect) {
                matchList.push(item);
            }
        });
        let countBundleValid = true;
        if(matchList.length === this.oldSelectedProductList.length){
            return countBundleValid;
        }

        unSelectedDifferenceList.forEach(item => {
            this.productIdentifierValidate.forEach(itemIdent => {
                if(item.prodCategory === itemIdent.categoryCode) {
                    countBundleValid = false;
                }
            });
        });
        return countBundleValid;
}

    handleChangeProductSA(event){
        this.isChangeProductFirstTime = event.detail.isChangeProductFirstTime;
        this.isChangeProduct = event.detail.isChangeProduct;
        this.productDataListRebook = JSON.parse(JSON.stringify(event.detail.productDataListRebook));
        this.runBookingPath();

        this.showAppointmentBookingPage = false;
        this.showProductSelectionPage = true;
    }


    

    handleCancelClick(){
        this.closeFlow();
    }

     /*Discount Band Code start here
     handleQuoteLocation(event){
    
        this.quoteRangeLocation = event.detail;
        console.log('quoteRangeLocation--->',this.quoteRangeLocation);
      

    }*/

   handleAgreedPriceChange(event) {
        //console.log("inside handleDiscountChange");
        let highOffer = 0;
        let lowOffer = 0;
        let priceAgreed = parseFloat(event.target.value);

        console.log('start',priceAgreed);
        //console.log('discountValue', discountValue);
        if (!this.selectedLocation || !this.agreedPrice) {
            this.isDiscountDisabled = true;
            // event.target.setCustomValidity('');
        }
        if (this.selectedLocation != null) {
            this.isDiscountDisabled = false;
            lowOffer = this.locationThresholdList.find(loc => loc.locationId == this.selectedLocation.locationGUID).lowOffer;
            highOffer = this.locationThresholdList.find(loc => loc.locationId == this.selectedLocation.locationGUID).highOffer; //this.getMaxDiscountThreshold();
            console.log("start lowValue: ",lowOffer);
            console.log('start highValue',highOffer)
        }
        if (priceAgreed < 0) {
            event.target.setCustomValidity(this.label.InvalidPrice);
            this.invalidAgreedPrice = true;
        }
        else if (this.selectedLocation != null && priceAgreed > 0 && (priceAgreed > lowOffer || priceAgreed < highOffer) && (!this.hasPermission)) {
            event.target.setCustomValidity(this.label.InvalidPrice);
            this.invalidAgreedPrice = true;
        }
        else if (this.selectedLocation != null && priceAgreed > 0 && (priceAgreed > lowOffer || priceAgreed < highOffer) && (this.hasPermission)) {
            event.target.setCustomValidity(this.label.InvalidPrice);
            this.invalidAgreedPrice = true;
        }
        else {
            event.target.setCustomValidity('');
            this.invalidAgreedPrice = false;
        }
        event.target.reportValidity();
        this.agreedPriceUpdated = priceAgreed > 0 && !this.invalidAgreedPrice ? true : false;
        this.agreedPrice = priceAgreed;
        this.checkForConditionalRendering();
    }
    


    agreedPriceCalc(){
        let dynamicQuoteRanges = [];
        let locationIdVsQuoteOriginalPrice = new Map();
        this.locationThresholdList = [];

        this.locationList.forEach(loc => {
            locationIdVsQuoteOriginalPrice.set(loc.locationGUID, loc.quoteOriginalPrice);
        });

        this.discountBandDetails.forEach(band => {
           
                let locationThreshold = {
                    locationId: band.locationId,
                    locationName: band.locationName,
                    highOffer: band.discountThresholdC,
                    lowOffer: locationIdVsQuoteOriginalPrice.get(band.locationId)
                };
                this.locationThresholdList.push(Object.assign({},locationThreshold));

                dynamicQuoteRanges.push({
                    location: band.locationName,
                    lowOffer: `£${(locationIdVsQuoteOriginalPrice.get(band.locationId))} - £${(band.discountThresholdA).toString()}`,
                    mediumOffer: `£${(band.discountThresholdA).toString()} - £${(band.discountThresholdB).toString()}`,
                    highOffer: `£${(band.discountThresholdB).toString()} - £${(band.discountThresholdC).toString()}`
                });
        
    
        });        
        return dynamicQuoteRanges;
    }
    

  

        formatDate(dateObject){
            const day = dateObject.getDate();
            const dayWithSuffix = this.addSuffixToDay(day);
            const formattedDate = new Intl.DateTimeFormat('en-US',{
                year:'numeric',
                month:'long',
            day: 'numeric'
        }).format(dateObject);
            return formattedDate.replace(String(day),dayWithSuffix);
        }    
        addSuffixToDay(day){
            if(day>=11 && day<=13){
                return day +'th';
            }
            switch(day % 10){
                case 1: 
                    return day + 'st';
                case 2: 
                    return day + 'nd';
                case 3: 
                    return day + 'rd';
                default:
                    return day+ 'th';
            }
        }          
   
    async showErrorAlert(msg, theme, heading) {
        await LightningAlert.open({
            message: msg,
            theme: theme,
            label: heading
        });
    }

}