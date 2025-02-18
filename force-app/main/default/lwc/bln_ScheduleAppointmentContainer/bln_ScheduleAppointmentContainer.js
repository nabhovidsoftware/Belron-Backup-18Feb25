import {
    LightningElement,
    api,
    track,
    wire
} from 'lwc';
import QuoteLocation1 from '@salesforce/label/c.BLN_QuoteLocation';
import ServiceLocationLbl1 from '@salesforce/label/c.BLN_ServiceLocation';
import ServiceLocationAlreadyAdded from '@salesforce/label/c.bln_ServiceLocationAlreadyAdded';
import Products1 from '@salesforce/label/c.BLN_Products';
import EarliestAvailability1 from '@salesforce/label/c.BLN_EarliestAvailability';
import SelectSlot1 from '@salesforce/label/c.BLN_SelectSlot';
import {
    ShowToastEvent
} from "lightning/platformShowToastEvent";
import addLocation from '@salesforce/label/c.BLN_AddLocation';
import confirmBooking from '@salesforce/label/c.BLN_ConfirmBooking';
import changeLocation from '@salesforce/label/c.BLN_ChangeLocation';
import locationAlreadyExist from '@salesforce/label/c.BLN_LocationAlreadyExist';
import changeProduct from '@salesforce/label/c.BLN_ChangeProduct';
import locationAtLeastLineItem from '@salesforce/label/c.BLN_LocationAtLeastLineItem';
import NoSAAtBillingLocation from '@salesforce/label/c.BLN_NoSAAtBillingLocation';
import weatherGuard from '@salesforce/label/c.BLN_WeatherGuard';
import BodyGlass from '@salesforce/label/c.Bln_BodyGlassLbl';
import AppointmenSlotErrorMsg  from '@salesforce/label/c.BLN_AppointmenSlotErrorMsg';
import WeatherGuardErrorMsg from '@salesforce/label/c.BLN_WeatherGuardErrorMsg';
import WeatherAndBodyGlassError from '@salesforce/label/c.BLN_WeatherAndBodyGlassError';
import ErrorTitle from '@salesforce/label/c.BLN_ErrorTitle';
import noActiveOrderOnCaseError from '@salesforce/label/c.BLN_NoActiveOrderOnCaseError';
import failedToFetchOrderErrorRebook from '@salesforce/label/c.BLN_FailedToFetchOrderErrorRebook';
import errorOccurred from '@salesforce/label/c.BLN_ErrorOccur';
import getAfterHour from '@salesforce/apex/BLN_AfterHoursUtility.afterHourUtility';
import rebookSA from '@salesforce/apex/BLN_ProductAvailabilityRebook.rebookServiceAppointments';
import getAcceptedOrder from '@salesforce/apex/BLN_ProductAvailabilityRebook.getAcceptedOrder';
import LightningAlert from 'lightning/alert';
import appointmentConfirmError from '@salesforce/label/c.BLN_AppointmentConfirmError';
import {
    getFocusedTabInfo,
    closeTab
} from 'lightning/platformWorkspaceApi';
import bufferCalculationMethod from '@salesforce/apex/BLN_ProductAvailabilityUtility.bufferCalculation';
import orderItemExisting from '@salesforce/apex/BLN_ProductAvailabilityRebook.getWorkOrderItemExisting';
import completeEarliestDates from '@salesforce/apex/BLN_ProductAvailabilityRebook.getEarliestDateList'


import {
    updateRecord,
    getRecord,
    getFieldValue
} from 'lightning/uiRecordApi';
import OEAUTHARIZATIONREQUIRED_FIELD from "@salesforce/schema/Case.BLN_Corporate__r.BLN_OEAuthorizationRequired__c";
import AUTHORIZATIONSATUS_FIELD from "@salesforce/schema/Case.BLN_Corporate__r.BLN_AuthorizationStatus__c";
import CASEID_FIELD from "@salesforce/schema/Case.Id"
const FIELDS = [
    'Case.BLN_IsForceReprice__c'
   ];

export default class Bln_ScheduleAppointmentContainer extends LightningElement {
    

    @api isTopParent = false;
    @api caseType;
    @api caseSubType;
    @api liabilityList = [];
    @api locationList = [];
    @api selectedLocation;
    @api addOnProductList = [];
    @api hiddenProductList = [];
    @api oldAddOnProductListV = [];
    @api oldAddOnProducts;
    @api selectedProductList = [];
    @api oldSelectedProductListV = [];
    @api oldSelectedProducts;
    @api firstScreenVisited = false;

    @api earliestDateList = [];
    @api selectedLocationOptions = null;
    @api selectedQuoteLocation = null;
    @api caseId;
    @api accountId = '';
    @api productDataList = [];
    @api discount;
    @api isCashJourney;
    @api currentPayload;
    @api isProductSelected;
    @api isRebooking = false; //Re-book
    @api isRebookingchild = false; //Re-book
    @api getQuotePayload = []; //Re-book
    rebookSaList = [] //Re-book
    @api caseExternalIds;
    @api isClickAddLocation;
    @api setProductDataList;
    isAddLocation = false;
    @track appointmentIds = [];
    @track selectedAddLocation = [];
    primaryLocation = '';
    isSchduleAppointment = false;
    appointmentAddLimit = 0;
    @track counter = 0;
    appointmentCounter = 1;
    options = [];
    value = '';
    isAddLocationDisabled = true;
    isProductSummary = false;
    isConnectedCall = false;
    screenThreeArrey = [];
    @track selectedLocationId;
    @track selectedQuoteId;
    @track dateArray = [];
    @track dateWeatherGuardArray = [];
    isDropOff = false;
    @api taskId = '';
    afterHours = '£0.00';   
    afterHourObj = {};
    isLoading = false; 
      // Varible for Rebook 6283
      isChangeLocation = false;
      @api isForceReprise = false;
      showProductSelectionPage = false;
      @api isFirstScreen = false;
      @api isRebookAssign = false;
      @api isLocationChange = false;
      @api adressList = [];
    @api quoteDataList;
      existingGuid = '';
      isQuoteScreen = false;
      externalQuoteId = '';
    @api productReuiredList = [];
      @api allOrderItemsList = [];
    @api isRefresh = false;
      @api isChangeProduct = false;
      @api oldSelectedProductList;
      @api oldAddOnProductList;
    @track existingProductData = [];
      @api allOrderDetailsIds = [];
      @api productDataListRebook = [];
      @api isChangeProductFirstTime;
      @track buffer = 0;
      @track orderId;
      @api workOrderItemWithSA = [];
    @api earliestDataDetail = [];
    @api bomIdWithPromseDateTime = [];
    earliestDate;
    appointmentId;
    earliestStockLocation;
    
    get showProductSelection() {
        return (this.isTopParent && this.isQuoteScreen);
      }
      
    get locationOptions() {
        let allAddLocations = '';
        this.productDataList.forEach(pdEle => {
            allAddLocations += pdEle.serviceLocationId;
        });

        let options = this.locationList.map(location => ({
            label: location.quotelocation,
            value: location.quotelocation, 
            quoteId: location.quoteId,
            locationId: location.locationGUID
        }));

        return options;
    }
      
    /* Used for add the custom labels */
    label = {
        ServiceLocationLbl1,
        Products1,
        EarliestAvailability1,
        SelectSlot1,
        QuoteLocation1,
        ServiceLocationAlreadyAdded,
        addLocation,
        confirmBooking,
        changeLocation,
        changeProduct,
        weatherGuard,
        BodyGlass,
        AppointmenSlotErrorMsg,
        WeatherGuardErrorMsg,
        WeatherAndBodyGlassError,
        ErrorTitle,
        noActiveOrderOnCaseError,
        failedToFetchOrderErrorRebook,
        errorOccurred,
        appointmentConfirmError,
        locationAtLeastLineItem,
        NoSAAtBillingLocation,
        locationAlreadyExist
    }
   
    //PopUp
    async calculateBuffer() {   
        try {
            const result = await bufferCalculationMethod({
                caseId: this.caseId
            });
        
            if (result != null && result != undefined && result != '') {
                this.buffer = result != null ? result : 0;
            }
        } catch (error) {
            console.error('Error calculating buffer:', error);
        }
    }

    async connectedCallback() {
        
        this.isChangeProduct = this.isChangeProduct == null || this.isChangeProduct == undefined || this.isChangeProduct != true ? false : true;
        this.isRebookingchild = this.isChangeProduct == true ? this.isChangeProduct : false;
        this.oldSelectedProductList = this.oldSelectedProductList ? JSON.parse(JSON.stringify(this.oldSelectedProductList)) : [];
        this.oldAddOnProductList = this.oldAddOnProductList ? JSON.parse(JSON.stringify(this.oldAddOnProductList)) : [];
        await this.calculateBuffer();
        this.buffer = this.buffer == undefined || this.buffer == null ? 0 : this.buffer;

        getAcceptedOrder({
                caseId: this.caseId
            })
            .then(result => {
                if (result) {
                    this.orderId = result.Id;
                    this.workOrderItemChecker(this.orderId);
                }      
            });
            
        if (this.isLocationChange) {
                await this.calculatedEarliestDates(this.currentPayload, this.caseId, this.bomIdWithPromseDateTime) ;

                let productDataListRebookClone = JSON.parse(JSON.stringify(this.productDataListRebook));
            if (this.selectedLocation != undefined && this.selectedLocation.quotelocation != undefined && productDataListRebookClone.length > 0 && productDataListRebookClone != '[]' && productDataListRebookClone != null && productDataListRebookClone != undefined && productDataListRebookClone[0].serviceLocationName != undefined && !productDataListRebookClone[0].serviceLocationName.includes(this.selectedLocation.quotelocation)) {
                            productDataListRebookClone[0].serviceLocationName = productDataListRebookClone[0].serviceLocationLabel[0].serviceLabel + ' ' + productDataListRebookClone[0].appointments[0].locationName;
                            productDataListRebookClone[0].serviceLocationId = productDataListRebookClone[0].appointments[0].locationId;
                productDataListRebookClone[0].earliestAvailablity[0].serviceName = productDataListRebookClone[0].appointments[0].locationName;
                            productDataListRebookClone[0].appointments[0].locationId = this.selectedLocation.locationGUID;
                            productDataListRebookClone[0].appointments[0].locationName = this.selectedLocation.quotelocation;
                    }

            this.selectedProductList.forEach(selectedEle => {
                let productNames = JSON.parse(JSON.stringify(productDataListRebookClone[0].serviceLocationLabel[0].productNames));
                    var selectedEleBomId = selectedEle.bomId == null ? "" : selectedEle.bomId;
                    var selectedEleBundleName = selectedEle.bundleName == null ? "" : selectedEle.bundleName;
                    var selectedEleProductCode = selectedEle.productCode == null ? "" : selectedEle.productCode;
                    let mathchingProducts = productNames.filter(productName => 
                                                                ((selectedEleProductCode == productName.productCode || (!selectedEleProductCode && !productName.productCode)) && 
                                                                (selectedEleBomId == productName.bomId || (!selectedEleBomId && !productName.bomId)) && 
                                                                (selectedEleBundleName == productName.bundleName || (!selectedEleBundleName&& !productName.bundleName))));
                
                if (mathchingProducts.length == 0) {
                    productDataListRebookClone.forEach(parentLocationBlock => {
                        parentLocationBlock.serviceLocationLabel[0].productNames.push(selectedEle);

                        let earlyDateSet = this.getAvailableDate(parentLocationBlock.serviceLocationId, selectedEle);
                        let earliestDate;
                        if (earlyDateSet && earlyDateSet.length > 0) {
                            earliestDate = earlyDateSet[0];
                                for (let earlyDate of earlyDateSet) {
                                earliestDate = (new Date(earlyDate.availableFromDate) < new Date(earliestDate.availableFromDate)) ? earlyDate : false;
                            }
                        }
                        
                        let isOutOfStockEarlyDate = earliestDate ? earliestDate.isOutOfStock : false;
                        let earlyDate = earliestDate ? this.convertDate(new Date(earliestDate.availableFromDate)) : this.convertDate(new Date(new Date().getTime() + (parseInt(this.buffer) * 24 * 60 * 60 * 1000)));
                        parentLocationBlock.earliestAvailablity[0].productDate.push({
                            "earliestDate": earlyDate,
                            "productCode": selectedEle.mdmId,
                            "EarliestDateTime": earlyDate,
                            "isCPTDate": isOutOfStockEarlyDate,
                                "prodCategory": selectedEle.prodCategory,
                                "bomId": selectedEle.bomId == null || selectedEle.bomId == undefined ? '' : selectedEle.bomId,
                                "bundleName": selectedEle.bundleName == null || selectedEle.bundleName == undefined ? '' : selectedEle.bundleName
                        });
                    
                        let product = {
                            "productCode": selectedEle.mdmId,
                            "quantity": selectedEle.quantity,
                                "bomId": selectedEle.bomId == null || selectedEle.bomId == undefined ? '' : selectedEle.bomId,
                                "lineItemId": selectedEle.lineItemId,
                                "partOfBundle": selectedEle.partOfBundle,
                                "bundleName": selectedEle.bundleName == null || selectedEle.bundleName == undefined ? '' : selectedEle.bundleName,
                            "isCPTDate": isOutOfStockEarlyDate,
                            "isChecked": false,
                            "productEnable": false,
                            "prodCategory": selectedEle.prodCategory,
                            "productDescription": selectedEle.productName,
                        }
                            
                        parentLocationBlock.appointments.forEach(appBlock => {
                            appBlock.productAvailibilities[0].products.push(JSON.parse(JSON.stringify(product)));
                        });

                        parentLocationBlock.location = this.locationList.find(ele=> ele.locationGUID == this.selectedLocation.locationGUID);
                    });
                }
            });
            
            let productNames = JSON.parse(JSON.stringify(productDataListRebookClone[0].serviceLocationLabel[0].productNames));
            productNames.forEach((selectedEle, indexEle) => {
                if(selectedEle.productCode) {
                    var selectedEleBomId = selectedEle.bomId == null ? "" : selectedEle.bomId;
                    var selectedEleBundleName = selectedEle.bundleName == null ? "" : selectedEle.bundleName;
                    var selectedEleProductCode = selectedEle.productCode == null ? "" : selectedEle.productCode;
                    let mathchingProducts = this.selectedProductList.filter(productName => ((selectedEleProductCode == productName.productCode) && 
                                                                            (selectedEleBomId == productName.bomId) && (selectedEleBundleName == productName.bundleName)));
                    if (mathchingProducts.length == 0) {
                        productDataListRebookClone.forEach(parentLocationBlock => {
                            for(let i =0 ;i<parentLocationBlock.serviceLocationLabel[0].productNames.length; i++){
                                    if(selectedEle.productCode && parentLocationBlock.serviceLocationLabel[0].productNames[i].productCode && selectedEle.productCode == parentLocationBlock.serviceLocationLabel[0].productNames[i].productCode) {
                                        const indexToRemove = parentLocationBlock.serviceLocationLabel[0].productNames.findIndex(item => item.productCode === selectedEle.productCode && item.bomId === selectedEle.bomId && item.bundleName === selectedEle.bundleName);
                                        if (indexToRemove !== -1) {
                                            parentLocationBlock.serviceLocationLabel[0].productNames.splice(indexToRemove, 1);
                                            parentLocationBlock.earliestAvailablity[0].productDate.splice(indexToRemove, 1);
                                        }
                                    }
                                }
                                /*for(let i = 0 ;i<parentLocationBlock.earliestAvailablity[0].productDate.length; i++){
                                    if(selectedEle.productCode && parentLocationBlock.earliestAvailablity[0].productDate[i].productCode != undefined && selectedEle.productCode == parentLocationBlock.earliestAvailablity[0].productDate[i].productCode) {
                                        const indexToRemove =  parentLocationBlock.earliestAvailablity[0].productDate.findIndex(item => item.productCode === selectedEle.productCode && item.bomId === selectedEle.bomId && item.bundleName === selectedEle.bundleName);
                                        if (indexToRemove !== -1) {
                                            parentLocationBlock.earliestAvailablity[0].productDate.splice(indexToRemove, 1);
                                        }
                                    }
                                }*/
                                parentLocationBlock.appointments.forEach(appBlock => {
                                    for(let i =0 ;i<appBlock.productAvailibilities[0].products.length; i++){
                                        if(selectedEle.productCode && appBlock.productAvailibilities[0].products[i].productCode != undefined && selectedEle.productCode == appBlock.productAvailibilities[0].products[i].productCode) {
                                            const indexToRemove =  appBlock.productAvailibilities[0].products.findIndex(item => item.productCode === selectedEle.productCode && item.bomId === selectedEle.bomId && item.bundleName === selectedEle.bundleName);
                                            if (indexToRemove !== -1) {
                                                appBlock.productAvailibilities[0].products.splice(indexToRemove, 1);
                                            }
                                    }
                                }
                            });
                        });
                    }
                }
            });

            this.populateEarliestDates(productDataListRebookClone);

            this.productDataListRebook = JSON.parse(JSON.stringify(productDataListRebookClone));
            this.productDataList = [...this.productDataListRebook];
            this.isSchduleAppointment = true;

        } else if (!this.isChangeProduct) {
            this.onLoad();

            } else {
            await this.calculatedEarliestDates(this.currentPayload, this.caseId, this.bomIdWithPromseDateTime) ;
                let productDataListRebookClone = JSON.parse(JSON.stringify(this.productDataListRebook));
            if (this.selectedLocation != undefined && this.selectedLocation.quotelocation != undefined && productDataListRebookClone.length > 0 && productDataListRebookClone != '[]' && productDataListRebookClone != null && productDataListRebookClone != undefined && productDataListRebookClone[0].serviceLocationName != undefined && !productDataListRebookClone[0].serviceLocationName.includes(this.selectedLocation.quotelocation)) {
                    productDataListRebookClone[0].serviceLocationName = productDataListRebookClone[0].serviceLocationLabel[0].serviceLabel + ' ' + productDataListRebookClone[0].appointments[0].locationName;
                    productDataListRebookClone[0].serviceLocationId = productDataListRebookClone[0].appointments[0].locationId;
                productDataListRebookClone[0].earliestAvailablity[0].serviceName = productDataListRebookClone[0].appointments[0].locationName;
                    productDataListRebookClone[0].appointments[0].locationId = this.selectedLocation.locationGUID;
                    productDataListRebookClone[0].appointments[0].locationName = this.selectedLocation.quotelocation;
                }


                this.selectedProductList.forEach(selectedEle => {
                    let productNames = JSON.parse(JSON.stringify(productDataListRebookClone[0].serviceLocationLabel[0].productNames));
                    var selectedEleBomId = selectedEle.bomId == null ? "" : selectedEle.bomId;
                    var selectedEleBundleName = selectedEle.bundleName == null ? "" : selectedEle.bundleName;
                    var selectedEleProductCode = selectedEle.productCode == null ? "" : selectedEle.productCode;
                    let mathchingProducts = productNames.filter(productName => 
                                                            ((selectedEleProductCode == productName.productCode || (!selectedEleProductCode && !productName.productCode)) && 
                                                            (selectedEleBomId == productName.bomId || (!selectedEleBomId && !productName.bomId)) && 
                                                            (selectedEleBundleName == productName.bundleName || (!selectedEleBundleName && !productName.bundleName))));
                
                if (mathchingProducts.length == 0) {
                    
                    productDataListRebookClone.forEach(parentLocationBlock => {
                        parentLocationBlock.serviceLocationLabel[0].productNames.push(selectedEle);

                        let earlyDateSet = this.getAvailableDate(parentLocationBlock.serviceLocationId, selectedEle);
                        let earliestDate;
                        if (earlyDateSet && earlyDateSet.length > 0) {
                            earliestDate = earlyDateSet[0];
                            for (let earlyDate of earlyDateSet) {
                                earliestDate = (new Date(earlyDate.availableFromDate) < new Date(earliestDate.availableFromDate)) ? earlyDate : false;
                            }
                        }
                        
                        let isOutOfStockEarlyDate = earliestDate ? earliestDate.isOutOfStock : false;
                        let earlyDate = earliestDate ? this.convertDate(new Date(earliestDate.availableFromDate)) : this.convertDate(new Date(new Date().getTime() + (parseInt(this.buffer) * 24 * 60 * 60 * 1000)));
                        parentLocationBlock.earliestAvailablity[0].productDate.push({
                            "earliestDate": earlyDate,
                            "productCode": selectedEle.mdmId,
                            "EarliestDateTime": earlyDate,
                            "isCPTDate": isOutOfStockEarlyDate,
                                "prodCategory": selectedEle.prodCategory,
                                "bomId": selectedEle.bomId == null || selectedEle.bomId == undefined ? '' : selectedEle.bomId,
                                "bundleName": selectedEle.bundleName == null || selectedEle.bundleName == undefined ? '' : selectedEle.bundleName
                        });
                    
                        let product = {
                            "productCode": selectedEle.mdmId,
                            "quantity": selectedEle.quantity,
                                "bomId": selectedEle.bomId == null || selectedEle.bomId == undefined ? '' : selectedEle.bomId,
                                "lineItemId": selectedEle.lineItemId,
                                "partOfBundle": selectedEle.partOfBundle == null || selectedEle.partOfBundle == undefined ? '' : selectedEle.partOfBundle,
                            "bundleName": selectedEle.bundleName,
                            "isCPTDate": isOutOfStockEarlyDate,
                            "isChecked": false,
                            "productEnable": false,
                            "prodCategory": selectedEle.prodCategory,
                            "productDescription": selectedEle.productName,
                        }
                        let productFirstApp = JSON.parse(JSON.stringify(product));
                        
                        parentLocationBlock.appointments.forEach(appBlock => {
                            appBlock.productAvailibilities[0].products.push(JSON.parse(JSON.stringify(product)));
                        });
                        parentLocationBlock.location = this.locationList.find(ele=> ele.locationGUID == this.selectedLocation.locationGUID);
                    });
                }
            });

                let productNames = JSON.parse(JSON.stringify(productDataListRebookClone[0].serviceLocationLabel[0].productNames));
                productNames.forEach((selectedEle, indexEle) => {
                    if(selectedEle.productCode) {
                        var selectedEleBomId = selectedEle.bomId == null ? "" : selectedEle.bomId;
                        var selectedEleBundleName = selectedEle.bundleName == null ? "" : selectedEle.bundleName;
                        var selectedEleProductCode = selectedEle.productCode == null ? "" : selectedEle.productCode;
                        let mathchingProducts = this.selectedProductList.filter(productName => ((selectedEleProductCode == productName.productCode) && 
                                                                                (selectedEleBomId == productName.bomId) && (selectedEleBundleName == productName.bundleName)));
                        if (mathchingProducts.length == 0) {
                            productDataListRebookClone.forEach(parentLocationBlock => {
                                for(let i =0 ;i<parentLocationBlock.serviceLocationLabel[0].productNames.length; i++){
                                    if(selectedEle.productCode && parentLocationBlock.serviceLocationLabel[0].productNames[i].productCode && selectedEle.productCode == parentLocationBlock.serviceLocationLabel[0].productNames[i].productCode) {
                                        const indexToRemove = parentLocationBlock.serviceLocationLabel[0].productNames.findIndex(item => item.productCode === selectedEle.productCode && item.bomId === selectedEle.bomId && item.bundleName === selectedEle.bundleName);
                                        if (indexToRemove !== -1) {
                                            parentLocationBlock.serviceLocationLabel[0].productNames.splice(indexToRemove, 1);
                                            parentLocationBlock.earliestAvailablity[0].productDate.splice(indexToRemove, 1);
                                        }
                                    }
                                }
                                /*for(let i = 0 ;i<parentLocationBlock.earliestAvailablity[0].productDate.length; i++){
                                    if(selectedEle.productCode && parentLocationBlock.earliestAvailablity[0].productDate[i].productCode != undefined && selectedEle.productCode == parentLocationBlock.earliestAvailablity[0].productDate[i].productCode) {
                                        const indexToRemove =  parentLocationBlock.earliestAvailablity[0].productDate.findIndex(item => item.productCode === selectedEle.productCode && item.bomId === selectedEle.bomId && item.bundleName === selectedEle.bundleName);
                                        if (indexToRemove !== -1) {
                                            parentLocationBlock.earliestAvailablity[0].productDate.splice(indexToRemove, 1);
                                        }
                                    }
                                }*/
                                parentLocationBlock.appointments.forEach(appBlock => {
                                    for(let i =0 ;i<appBlock.productAvailibilities[0].products.length; i++){
                                        if(selectedEle.productCode && appBlock.productAvailibilities[0].products[i].productCode != undefined && selectedEle.productCode == appBlock.productAvailibilities[0].products[i].productCode) {
                                            const indexToRemove =  appBlock.productAvailibilities[0].products.findIndex(item => item.productCode === selectedEle.productCode && item.bomId === selectedEle.bomId && item.bundleName === selectedEle.bundleName);
                                            if (indexToRemove !== -1) {
                                                appBlock.productAvailibilities[0].products.splice(indexToRemove, 1);
                                            }
                                        }
                                    }
                                });
                            });
                        }
                    }
                });

                this.populateEarliestDates(productDataListRebookClone);

            this.productDataListRebook = JSON.parse(JSON.stringify(productDataListRebookClone));
            this.productDataList = [...this.productDataListRebook];
            this.isSchduleAppointment = true;
        }

        if (this.caseType == 'Job Request' && this.caseSubType == 'ISP' && this.isChangeProduct == false) {
            setTimeout(() => {
                this.handleConfirm(); 
            }, 5);
        }
    }

    populateEarliestDates( productDataListRebookClone ){
        if( !this.earliestDataDetail ){
            return;
        }
        productDataListRebookClone.forEach(parentLocationBlock => {
            for(var earliestIns of this.earliestDataDetail) {
                if(earliestIns.locationId == parentLocationBlock.serviceLocationId) {
                    parentLocationBlock.earlierAvailabilityPrepDateTime = earliestIns.earliestDate;
                    parentLocationBlock.earlierAvailabilityDateHeader = earliestIns.earliestDate;
                    parentLocationBlock.earlierAvailabilityAppointmentId = earliestIns.appointmentId;
                    
                    if( !earliestIns.earliestDate ){
                        parentLocationBlock.earlierAvailabilityPrepDateTime = earliestIns.stockEarliestDate;
                    }
                }
            }
        });
    }

    async calculatedEarliestDates(currentPayload,caseId) {
        await completeEarliestDates({responsePayload: currentPayload, caseId: caseId }).then(result => {
            this.earliestDateList = result;
            })
            .catch(error => {
                this.error = error;
                this.accounts = undefined;
            })
    
        }

    async onLoad() {
        await this.calculatedEarliestDates(this.currentPayload, this.caseId, this.bomIdWithPromseDateTime);
        if (this.isRebooking == true && this.isForceReprise == true) {
            this.isSchduleAppointment = false;
            getAcceptedOrder({
                caseId: this.caseId
            })
            .then(result => { 
                    if (result) {
                        this.externalQuoteId = result.BLN_CPQExternalQuoteId__c;
                        this.orderId = result.Id;
                        this.showProductSelectionPage = true;
                        this.isQuoteScreen = true;
                        this.workOrderItemChecker(this.orderId);
                    } else {
                    this.showErrorAlert(this.label.noActiveOrderOnCaseError, 'error', this.label.errorOccurred);
                }      
                });
                
        } else if (this.isRebooking == true) {
            rebookSA({
                caseId: this.caseId,
                    currentPayload: this.currentPayload
            })
                .then(result => {
                    this.currentPayload = result.getQuotePayload;
                    this.externalQuoteId = result.externalQuoteId;
                    this.existingGuid = result.existingGUId;
                    this.locationList = result.quoteDetailsDataList;
                    this.selectedQuoteLocation = result.selectedLocation;
                    this.getQuotePayload = result.getQuotePayload;
                    this.productReuiredList = result.productrequiredWrappList;
                    this.allOrderDetailsIds = result.orderItemDetails;
                    this.bomIdWithPromseDateTime = result.bomIdWithPromseDateTime;
                    this.productDataList = JSON.parse(result.appointmentWrapperList);
                    if (this.firstScreenVisited == false) {
                        this.liabilityList = result.liabilityDataList;
                        this.selectedProductList = JSON.parse(JSON.stringify(result.prodLists))[0];
                        this.addOnProductList = JSON.parse(JSON.stringify(result.prodLists)).length > 1 ? JSON.parse(JSON.stringify(result.prodLists))[1] : [];
                        this.hiddenProductList = JSON.parse(JSON.stringify(result.prodLists)).length > 2 ? JSON.parse(JSON.stringify(result.prodLists))[2] : [];
                        this.selectedLocation = result.selectedLocation;
                        this.earliestDateList = result.earliestAvailabilityList;
                    }

                this.oldSelectedProductList = JSON.parse(JSON.stringify(this.selectedProductList));
                this.oldAddOnProductList = JSON.parse(JSON.stringify(this.addOnProductList));
                this.orderId = result.orderId;
                let productDataListRebookClone = JSON.parse(JSON.stringify(this.productDataList));
                    if (this.selectedLocation != undefined && this.selectedLocation.quotelocation != undefined && productDataListRebookClone.length > 0 && productDataListRebookClone != '[]' && productDataListRebookClone != null && productDataListRebookClone != undefined && productDataListRebookClone[0].serviceLocationName != undefined && !productDataListRebookClone[0].serviceLocationName.includes(this.selectedLocation.quotelocation)) {
                            productDataListRebookClone[0].serviceLocationName = productDataListRebookClone[0].serviceLocationLabel[0].serviceLabel + ' ' + productDataListRebookClone[0].appointments[0].locationName;
                            productDataListRebookClone[0].serviceLocationId = productDataListRebookClone[0].appointments[0].locationId;
                        productDataListRebookClone[0].earliestAvailablity[0].serviceName = productDataListRebookClone[0].appointments[0].locationName;
                            productDataListRebookClone[0].appointments[0].locationId = this.selectedLocation.locationGUID;
                            productDataListRebookClone[0].appointments[0].locationName = this.selectedLocation.quotelocation;
                    }

                    this.selectedProductList.forEach(selectedEle => {
                        let productNames = JSON.parse(JSON.stringify(productDataListRebookClone[0].serviceLocationLabel[0].productNames));
                        var selectedEleBomId = selectedEle.bomId == null ? "" : selectedEle.bomId;
                        var selectedEleBundleName = selectedEle.bundleName == null ? "" : selectedEle.bundleName;
                        var selectedEleProductCode = selectedEle.productCode == null ? "" : selectedEle.productCode;
                        let mathchingProducts = productNames.filter(productName => 
                                                                ((selectedEleProductCode == productName.productCode || (!selectedEleProductCode && !productName.productCode)) && 
                                                                (selectedEleBomId == productName.bomId || (!selectedEleBomId && !productName.bomId)) && 
                                                                (selectedEleBundleName == productName.bundleName || (!selectedEleBundleName && !productName.bundleName))));
                    
                        if (mathchingProducts.length == 0) {
                        productDataListRebookClone.forEach(parentLocationBlock => {
                            parentLocationBlock.serviceLocationLabel[0].productNames.push(selectedEle);

                            let earlyDateSet = this.getAvailableDate(parentLocationBlock.serviceLocationId, selectedEle);
                            let earliestDate;
                                if (earlyDateSet && earlyDateSet.length > 0) {
                                earliestDate = earlyDateSet[0];
                                for (let earlyDate of earlyDateSet) {
                                    earliestDate = (new Date(earlyDate.availableFromDate) < new Date(earliestDate.availableFromDate)) ? earlyDate : false;
                                }
                            }

                                let isOutOfStockEarlyDate = earliestDate ? earliestDate.isOutOfStock : false;
                                let earlyDate = earliestDate ? this.convertDate(new Date(earliestDate.availableFromDate)) : this.convertDate(new Date(new Date().getTime() + (parseInt(this.buffer) * 24 * 60 * 60 * 1000)));
                                parentLocationBlock.earliestAvailablity[0].productDate.push({
                                    "earliestDate": earlyDate,
                                    "productCode": selectedEle.mdmId,
                                    "EarliestDateTime": earlyDate,
                                    "isCPTDate": isOutOfStockEarlyDate,
                                    "prodCategory": selectedEle.prodCategory,
                                    "bomId": selectedEle.bomId == null || selectedEle.bomId == undefined ? '' : selectedEle.bomId,
                                    "bundleName": selectedEle.bundleName == null || selectedEle.bundleName == undefined ? '' : selectedEle.bundleName
                                });
                            
                            let product = {
                                "productCode": selectedEle.mdmId,
                                    "quantity": selectedEle.quantity,
                                    "bomId": selectedEle.bomId == null || selectedEle.bomId == undefined ? '' : selectedEle.bomId,
                                    "lineItemId": selectedEle.lineItemId,
                                    "partOfBundle": selectedEle.partOfBundle == null || selectedEle.partOfBundle == undefined ? '' : selectedEle.partOfBundle,
                                    "bundleName": selectedEle.bundleName,
                                "isCPTDate": isOutOfStockEarlyDate,
                                    "isChecked": false,
                                    "productEnable": false,
                                "prodCategory": selectedEle.prodCategory,
                                "productDescription": selectedEle.productName,
                            }
                            
                            parentLocationBlock.appointments.forEach(appBlock => {
                                appBlock.productAvailibilities[0].products.push(JSON.parse(JSON.stringify(product)));
                            });
                            parentLocationBlock.location = this.locationList.find(ele=> ele.locationGUID == result.selectedLocation);
                        });
                    }
                });

                    let productNames = JSON.parse(JSON.stringify(productDataListRebookClone[0].serviceLocationLabel[0].productNames));
                    productNames.forEach((selectedEle, indexEle) => {
                        if(selectedEle.productCode) {
                            var selectedEleBomId = selectedEle.bomId == null ? "" : selectedEle.bomId;
                            var selectedEleBundleName = selectedEle.bundleName == null ? "" : selectedEle.bundleName;
                            var selectedEleProductCode = selectedEle.productCode == null ? "" : selectedEle.productCode;
                            let mathchingProducts = this.selectedProductList.filter(productName => ((selectedEleProductCode == productName.productCode) && 
                                                                                    (selectedEleBomId == productName.bomId) && (selectedEleBundleName == productName.bundleName)));
                            if (mathchingProducts.length == 0) {
                                productDataListRebookClone.forEach(parentLocationBlock => {
                                    for(let i =0 ;i<parentLocationBlock.serviceLocationLabel[0].productNames.length; i++){
                                        if(selectedEle.productCode && parentLocationBlock.serviceLocationLabel[0].productNames[i].productCode && selectedEle.productCode == parentLocationBlock.serviceLocationLabel[0].productNames[i].productCode) {
                                            const indexToRemove = parentLocationBlock.serviceLocationLabel[0].productNames.findIndex(item => item.productCode === selectedEle.productCode && item.bomId === selectedEle.bomId && item.bundleName === selectedEle.bundleName);
                                            if (indexToRemove !== -1) {
                                                parentLocationBlock.serviceLocationLabel[0].productNames.splice(indexToRemove, 1);
                                                parentLocationBlock.earliestAvailablity[0].productDate.splice(indexToRemove, 1);
                                            }
                                        }
                                    }
                                    /*for(let i = 0 ;i<parentLocationBlock.earliestAvailablity[0].productDate.length; i++){
                                        if(selectedEle.productCode && parentLocationBlock.earliestAvailablity[0].productDate[i].productCode != undefined && selectedEle.productCode == parentLocationBlock.earliestAvailablity[0].productDate[i].productCode) {
                                            const indexToRemove =  parentLocationBlock.earliestAvailablity[0].productDate.findIndex(item => item.productCode === selectedEle.productCode && item.bomId === selectedEle.bomId && item.bundleName === selectedEle.bundleName);
                                            if (indexToRemove !== -1) {
                                                parentLocationBlock.earliestAvailablity[0].productDate.splice(indexToRemove, 1);
                                            }
                                        }
                                    }*/
                                    parentLocationBlock.appointments.forEach(appBlock => {
                                        for(let i =0 ;i<appBlock.productAvailibilities[0].products.length; i++){
                                            if(selectedEle.productCode && appBlock.productAvailibilities[0].products[i].productCode != undefined && selectedEle.productCode == appBlock.productAvailibilities[0].products[i].productCode) {
                                                const indexToRemove =  appBlock.productAvailibilities[0].products.findIndex(item => item.productCode === selectedEle.productCode && item.bomId === selectedEle.bomId && item.bundleName === selectedEle.bundleName);
                                                if (indexToRemove !== -1) {
                                                    appBlock.productAvailibilities[0].products.splice(indexToRemove, 1);
                                                }
                                            }
                                        }
                                    });
                                });
                            }
                        }
                    });

                this.productDataListRebook = JSON.parse(JSON.stringify(productDataListRebookClone));
                this.productDataList = [...this.productDataListRebook];
                
                    this.workOrderItemChecker(this.orderId);
                    this.fillRequiredDataLocation();
                })
                .catch(error => {
                this.showErrorAlert(this.label.failedToFetchOrderErrorRebook, 'error', this.label.errorOccurred);
                })
        } else {
            let filteredLocations = this.locationList.filter(location => location.quotelocation == this.selectedLocation.quotelocation);
            if (filteredLocations != null && filteredLocations != undefined && filteredLocations.length > 0) {
                this.selectedQuoteLocation = filteredLocations[0].quotelocation != null && filteredLocations[0].quotelocation != undefined ? filteredLocations[0].quotelocation : '';
                this.selectedLocationId = filteredLocations[0].locationGUID != undefined && filteredLocations[0].locationGUID != null ? filteredLocations[0].locationGUID : '';
                this.selectedQuoteId = filteredLocations[0].quoteId != undefined && filteredLocations[0].quoteId != null ? filteredLocations[0].quoteId : '';
            }
            
            this.handleAddLocationClick();
            this.isSchduleAppointment = true;
        }
    }

    handleChangeProductClick() {
        this.isChangeProductFirstTime = this.isChangeProductFirstTime == null || this.isChangeProductFirstTime == undefined || this.isChangeProductFirstTime != false ? true : false; 
       this.isSchduleAppointment = false;
        this.isRebooking = true;
        this.isRefresh = true;
        this.isChangeProduct = true;
        this.isLocationChange = false;
        this.allOrderItemsList = [...this.allOrderDetailsIds];
        this.isQuoteScreen = true;

        if (!this.isTopParent) {
            let changeProductEvent = new CustomEvent('changeproductclick', {
                detail: {
                    "isChangeProductFirstTime": this.isChangeProductFirstTime,
                    "isChangeProduct": this.isChangeProduct,
                    "productDataListRebook":this.productDataList
                }
            });
            this.dispatchEvent(changeProductEvent);
        }
    }

    handleOldProduct(event){
        this.oldAddOnProductList = event.detail.oldAddOnProductList;
        this.oldSelectedProductList = event.detail.oldSelectedProductList;
        this.isChangeProduct = true;
    }

    handleKeyIndexes(){
        let productDataListCopy = JSON.parse(JSON.stringify(this.productDataList));
        for(let h = 0 ; h< productDataListCopy.length; h++) {
            if( !productDataListCopy[h].keyIndex ) {
                if( h == 0 ){
                    productDataListCopy[h].keyIndex = 'Location_'+h;
                }else{
                    productDataListCopy[h].keyIndex = 'Location_'+(parseInt(productDataListCopy[h-1].keyIndex.split('_')[1])+1);
                }
            } 

            for(let i=0 ; i< productDataListCopy[h].appointments.length; i++) {
                if( !productDataListCopy[h].appointments[i].keyIndex ) {
                    if( i == 0 ){
                        productDataListCopy[h].appointments[i].keyIndex = 'App'+productDataListCopy[h].keyIndex.split('_')[1]+'_'+i;
                    }else{
                        productDataListCopy[h].appointments[i].keyIndex = 'App'+productDataListCopy[h].keyIndex.split('_')[1]+'_'+(parseInt(productDataListCopy[h].appointments[i-1].keyIndex.split('_')[1])+1);
                    }
                }

                for(let j=0 ; j< productDataListCopy[h].appointments[i].productAvailibilities[0].products.length; j++) {
                    if( !productDataListCopy[h].appointments[i].productAvailibilities[0].products[j].keyIndex ) {
                        if( j == 0 ){
                            productDataListCopy[h].appointments[i].productAvailibilities[0].products[j].keyIndex = 'AppPrd'+productDataListCopy[h].keyIndex.split('_')[1]+''+productDataListCopy[h].appointments[i].keyIndex.split('_')[1]+'_'+i;
                        }else{
                            productDataListCopy[h].appointments[i].productAvailibilities[0].products[j].keyIndex = 'AppPrd'+productDataListCopy[h].keyIndex.split('_')[1]+''+productDataListCopy[h].appointments[i].keyIndex.split('_')[1]+'_'+(parseInt(productDataListCopy[h].appointments[i].productAvailibilities[0].products[j-1].keyIndex.split('_')[1])+1);
                        }
                    }
                }
            }

            for(let i=0 ; i< productDataListCopy[h].serviceLocationLabel[0].productNames.length; i++) {
                if( !productDataListCopy[h].serviceLocationLabel[0].productNames[i].keyIndexSLP ) {
                    if( i == 0 ){
                        productDataListCopy[h].serviceLocationLabel[0].productNames[i].keyIndexSLP = 'SLP'+productDataListCopy[h].keyIndex.split('_')[1]+'_'+i;
                    }else{
                        productDataListCopy[h].serviceLocationLabel[0].productNames[i].keyIndexSLP = 'SLP'+productDataListCopy[h].keyIndex.split('_')[1]+'_'+(parseInt(productDataListCopy[h].serviceLocationLabel[0].productNames[i-1].keyIndexSLP.split('_')[1])+1);
                    }
                }
            }
            for(let i=0 ; i< productDataListCopy[h].earliestAvailablity[0].productDate.length; i++) {
                if( !productDataListCopy[h].earliestAvailablity[0].productDate[i].keyIndex ) {
                    if( i == 0 ){
                        productDataListCopy[h].earliestAvailablity[0].productDate[i].keyIndex = 'EA'+productDataListCopy[h].keyIndex.split('_')[1]+'_'+i;
                    }else{
                        productDataListCopy[h].earliestAvailablity[0].productDate[i].keyIndex = 'EA'+productDataListCopy[h].keyIndex.split('_')[1]+'_'+(parseInt(productDataListCopy[h].earliestAvailablity[0].productDate[i-1].keyIndex.split('_')[1])+1);
                    }
                }
                productDataListCopy[h].earliestAvailablity[0].serviceName =  this.selectedLocation.quotelocation;
                productDataListCopy[h].appointments[0].locationId = this.selectedLocation.locationGUID;
                productDataListCopy[h].appointments[0].locationName = this.selectedLocation.quotelocation;
                productDataListCopy[h].appointments[0].isMobileLocation = this.locationList.find(option => option.locationGUID === this.selectedLocation.locationGUID).isMobileLocation;
            }
        }

        this.productDataList = [...productDataListCopy];
    }
    
    closeModal(event){
        this.isChangeLocation = false;
    }

    handleChangeLocation(){
        this.isChangeLocation = true;
        
    }
    
    adressDetail(event){
        this.adressList = event.detail;
         this.isLocationChange = event.detail.isLocationChange;
         this.isQuoteScreen = true;
         this.isRebookingchild = false;
         this.isSchduleAppointment = false;
        this.isTopParent = true;
        this.isChangeProduct = event.detail.isChangeProduct;
     }

    /* Method is used for date filter */
    getAvailableDate(locationId, selectedEle) {
        let currentProductEarliestDates = [];
        if(this.earliestDateList) {
        this.earliestDateList.forEach(eachDateSet => {
            if( eachDateSet.locationId == locationId && 
                (eachDateSet.productCode == selectedEle.productCode || (!eachDateSet.productCode && !selectedEle.productCode)) && 
                (eachDateSet.bomId == selectedEle.bomId || (!eachDateSet.bomId && !selectedEle.bomId)) && 
                (eachDateSet.bundleName == selectedEle.bundleName || (!eachDateSet.bundleName && !selectedEle.bundleName)) ) {  
                currentProductEarliestDates = eachDateSet.earliestDateList;
            }
        });
        }
        
        return currentProductEarliestDates;
    }
    
     /*This method will convert date in (DD MONTH,YYYY)  format */
     convertDate(actualDate) {
        const options = {
            year: "numeric",
            month: "long",
            day: "numeric",
        };
        let convertedDate = actualDate.toLocaleDateString("en-US", options);
        return convertedDate;
    }

   /*method to calculate max date from array of dates*/
    maxDateCalculation(arrayDate) {
        const maxDate = arrayDate.reduce((max, obj) => (new Date(obj.date) > new Date(max.date)) ? obj : max);
        return maxDate;
    }

    handleLocationChange(event) {
        this.selectedQuoteLocation =  event.target.value;
        this.selectedLocationOptions = this.locationOptions.find(option => option.label === this.selectedQuoteLocation);
        
        this.selectedLocationId = this.selectedLocationOptions.locationId;
        this.selectedQuoteId =  this.selectedLocationOptions.quoteId;
        this.isAddLocationDisabled = !this.selectedLocationOptions;
        this.selectedQuoteLocation = this.selectedLocationOptions;
    }

    handleAddLocationClick(event) {
        
    /* This is used for compare the location, If location already exist then we can't add the same */
        let locationsAlreadyExists = false;
        for (let h = 0; h < this.productDataList.length; h++) {
            if(this.productDataList[h].serviceLocationId == this.selectedQuoteLocation.locationId ) {
                locationsAlreadyExists = true;
                break;
            } 
        }

        if(locationsAlreadyExists) {
            const evt = new ShowToastEvent({
                title: this.label.ErrorTitle,
                message: this.label.locationAlreadyExist,
                variant: 'error',
            });
            this.dispatchEvent(evt);
            return;
        }

        this.isAddLocation = true;
            let isValidLocation = true;
            let j = 0;
            
            for(let i = 0; i < this.productDataList.length; i++) {
            if(this.selectedQuoteLocation == this.productDataList[i].earliestAvailablity[0].serviceName){
                    isValidLocation = false;    
                }
            }

            // start added for 6663
            let isContainsWeatherGuard = false;
            for (let i = 0; i < this.selectedProductList.length; i++) {
                if (this.selectedProductList[i].prodCategory != null && this.selectedProductList[i].prodCategory != undefined && this.selectedProductList[i].prodCategory.toUpperCase() === this.label.weatherGuard.toUpperCase()) {
                    isContainsWeatherGuard = true;
                break;
                }
            }
            
            if(isValidLocation == true) {

            let isFirstLocation = (this.productDataList.length == 0);
            let cloneProductDataList = this.setJSONBlankForAppointment();
                cloneProductDataList.earliestAvailablity[0].serviceName =  this.selectedQuoteLocation.value;
            cloneProductDataList.serviceLocationId = this.selectedLocationId;
            cloneProductDataList.location = this.locationList.find(ele=> ele.locationGUID == this.selectedQuoteLocation.locationId);
            this.existingGuid = this.selectedLocationId;
            var locationValue = typeof this.selectedQuoteLocation == 'object' ? this.selectedQuoteLocation.label:this.selectedQuoteLocation;
            cloneProductDataList.serviceLocationName = this.label.ServiceLocationLbl1 + ' ' + locationValue;
            cloneProductDataList.appointments[0].locationId = this.selectedLocationId;
                cloneProductDataList.appointments[0].locationName = this.selectedQuoteLocation.value;
                cloneProductDataList.appointments[0].isMobileLocation = this.locationList.find(option => option.locationGUID === this.selectedLocation.locationGUID).isMobileLocation;
            
                if( isContainsWeatherGuard && this.selectedProductList.length > 1){
                let secondAppointment = JSON.parse(JSON.stringify(cloneProductDataList.appointments[0]));
                secondAppointment.isFirstAppointment = false;
                cloneProductDataList.appointments.push( secondAppointment );
            }

                let orderOfProdcuts = this.selectedProductList;
                if( this.productDataList && this.productDataList.length > 0 ){
                    orderOfProdcuts = this.productDataList[0].serviceLocationLabel[0].productNames;
                }


                orderOfProdcuts.forEach(productDataEle => {
                    let selectedEle = this.selectedProductList.find(ele => (ele.productCode == productDataEle.productCode && ((ele.bomId == null? '':ele.bomId) == (productDataEle.bomId == null? '':productDataEle.bomId)) && ((ele.bundleName == null? '':ele.bundleName) == (productDataEle.bundleName == null? '':productDataEle.bundleName))));

                cloneProductDataList.serviceLocationLabel[0].productNames.push(selectedEle);

                let earlyDateSet = this.getAvailableDate(this.selectedLocationId, selectedEle);
                let earliestDate;
                if( earlyDateSet && earlyDateSet.length > 0){
                    earliestDate = earlyDateSet[0];
                    for( let earlyDate of earlyDateSet ){
                        earliestDate = (new Date(earlyDate.availableFromDate) < new Date(earliestDate.availableFromDate))?earlyDate:earliestDate;
                    }
                }
                
                let isOutOfStockEarlyDate = earliestDate?earliestDate.isOutOfStock:false;
                let earlyDate = earliestDate ? this.convertDate(new Date(earliestDate.availableFromDate)) : this.convertDate(new Date(new Date().getTime()+(parseInt(this.buffer)*24*60*60*1000)));
                //let earlyDate = this.convertDate(new Date(earliestDate.availableFromDate));
                
                cloneProductDataList.earliestAvailablity[0].productDate.push({
                    "earliestDate":earlyDate,
                    "productCode": selectedEle.productCode,
                    "EarliestDateTime":earlyDate,
                    "isCPTDate":isOutOfStockEarlyDate,
                    "prodCategory": selectedEle.prodCategory,
                    "bomId": selectedEle.bomId == null || selectedEle.bomId == undefined ? '' : selectedEle.bomId,
                    "bundleName": selectedEle.bundleName == null || selectedEle.bundleName == undefined ? '' : selectedEle.bundleName
                });
            
                let product = {
                    "productCode": selectedEle.productCode,
                    "quantity":selectedEle.quantity,
                    "bomId":selectedEle.bomId == null || selectedEle.bomId == undefined ? '' : selectedEle.bomId,
                    "lineItemId":selectedEle.lineItemId,
                    "partOfBundle":selectedEle.partOfBundle,
                    "bundleName":selectedEle.bundleName == null || selectedEle.bundleName == undefined ? '' : selectedEle.bundleName,
                    "isCPTDate": isOutOfStockEarlyDate,
                    "isChecked" : false,
                    "productEnable":false,
                    "prodCategory": selectedEle.prodCategory
                }
                let productFirstApp = JSON.parse(JSON.stringify(product));
                let productSecondApp = JSON.parse(JSON.stringify(product));

                product.productEnable = (isFirstLocation?true:false);

                /*This is used for when a product required consumed is true then product's radio button disable & false */
                let productCodeN = selectedEle.productCode == '' || selectedEle.productCode == undefined ? null : selectedEle.productCode;
                let bomIdN = selectedEle.bomId == '' || selectedEle.bomId == undefined ? null : selectedEle.bomId;
                let bundleNameN = selectedEle.bundleName == '' || selectedEle.bundleName == undefined ? null : selectedEle.bundleName;
            
                let productRequiredData = this.productReuiredList.find(ele => ele.productOLIKey == productCodeN+'_'+bomIdN+'_'+bundleNameN);
                if( isContainsWeatherGuard ){
                    if( selectedEle.prodCategory != null && selectedEle.prodCategory != undefined && selectedEle.prodCategory.toUpperCase() === this.label.weatherGuard.toUpperCase() ){
                        productFirstApp.isChecked = false;
                        productFirstApp.productEnable = (isFirstLocation?true:false);
                        productSecondApp.isChecked = true;
                        productSecondApp.productEnable = false;
                    }else{
                        productFirstApp.isChecked = true;
                        productFirstApp.productEnable = false;
                        productSecondApp.isChecked = false;
                        productSecondApp.productEnable = (isFirstLocation ? true : false);

                    }
                    cloneProductDataList.appointments[0].productAvailibilities[0].products.push(productFirstApp);
                    if(this.selectedProductList.length > 1) {
                        cloneProductDataList.appointments[1].productAvailibilities[0].products.push(productSecondApp);
                        cloneProductDataList.appointments[1].appointmentName = 'Appointment 2';
                    }
                }else if(this.isRebooking == true && productRequiredData != undefined && productRequiredData.isConsumed != null && productRequiredData.isConsumed == true){
                    productFirstApp.productEnable = false;
                    productFirstApp.isChecked = true;

                    cloneProductDataList.appointments[0].productAvailibilities[0].products.push(productFirstApp);
                }else{
                    productFirstApp.isChecked = false;
                    productFirstApp.productEnable = (isFirstLocation?true:false);

                    cloneProductDataList.appointments[0].productAvailibilities[0].products.push(productFirstApp);
                }
            });

            this.productDataList.push(cloneProductDataList);

            this.populateEarliestDates(this.productDataList);
        } else {
            const evt = new ShowToastEvent({
                title: this.label.ErrorTitle,
                message: this.label.ServiceLocationAlreadyAdded,
                variant: 'error',
            });
            this.dispatchEvent(evt);
        }

        this.handleKeyIndexes();
        this.isClickAddLocation = false;
        this.isSchduleAppointment = true;
    
    }

    fillRequiredDataLocation(event) {
        // start added for 6663
        let isContainsWeatherGuard = false;
        for (let i = 0; i < this.selectedProductList.length; i++) {
            if (this.selectedProductList[i].prodCategory != null && this.selectedProductList[i].prodCategory != undefined && this.selectedProductList[i].prodCategory.toUpperCase() === this.label.weatherGuard.toUpperCase()) {
                isContainsWeatherGuard = true;
                break;
            }
        }

        let productDataListClone = JSON.parse(JSON.stringify(this.productDataList));
        productDataListClone.forEach(cloneProductDataList => {
            cloneProductDataList.serviceLocationLabel[0].productNames.forEach(selectedEle => {

                let earlyDateSet = this.getAvailableDate(this.selectedLocationId, selectedEle);
                let earliestDate;
                if( earlyDateSet && earlyDateSet.length > 0){
                    earliestDate = earlyDateSet[0];
                    for( let earlyDate of earlyDateSet ){
                        earliestDate = (new Date(earlyDate.availableFromDate) < new Date(earliestDate.availableFromDate)) ? earlyDate : false;
                    }
                }
                
                let isOutOfStockEarlyDate = earliestDate?earliestDate.isOutOfStock:false;
                let earlyDate = earliestDate ? this.convertDate(new Date(earliestDate.availableFromDate)) : this.convertDate(new Date(new Date().getTime()+(parseInt(this.buffer)*24*60*60*1000)));
                //let earlyDate = this.convertDate(new Date(earliestDate.availableFromDate));
                cloneProductDataList.earliestAvailablity[0].productDate.push({
                    "earliestDate":earlyDate,
                    "productCode": selectedEle.productCode,
                    "EarliestDateTime":earlyDate,
                    "isCPTDate":isOutOfStockEarlyDate,
                    "prodCategory": selectedEle.prodCategory,
                    "bomId": selectedEle.bomId == null || selectedEle.bomId == undefined ? '' : selectedEle.bomId,
                    "bundleName": selectedEle.bundleName == null || selectedEle.bundleName == undefined ? '' : selectedEle.bundleName
                });
            });
        });
        this.productDataList = [...productDataListClone];
        this.productDataListRebook =  [...this.productDataList];
        
        this.handleKeyIndexes();
        this.isSchduleAppointment = true;
    }

    setJSONBlankForAppointment() {
        return {
                "serviceLocationName": this.label.QuoteLocation1 + ' '+ this.selectedQuoteLocation,
                "serviceLocationId":"",
                "isPrimaryLocation":false,
                "location":"",
                "serviceLocationLabel": [
                    {
                        "serviceLabel": this.label.ServiceLocationLbl1,
                        "product": this.label.Products1,
                        "productNames": [
                        ]
                    }
                ],
                "earliestAvailablity": [
                    {
                        "serviceName": this.selectedQuoteLocation,
                        "earliestAvailablity": this.label.EarliestAvailability1,
                        "productDate": [
                        
                        ]
                    }
                ],
                "appointments": [
                    {
                        "appointmentName": "Appointment 1",
                        "locationId":"",
                        "locationName":"",
                        "isFirstAppointment":true,
                        "isMobileLocation" : "",
                        "earlierAvailabilityDateHeader": "",
                        "earlierAvailabilityAppointmentId": "",
                    "earlierAvailabilityPrepDateTime":"",
                        "slotSelectedDate": "",
                        "serviceAppointmentId": "",
                        "slotDate": "",
                        "slotTime": "",
                        "slotDateTimeStart": "",
                        "slotDateTimeFinish": "",
                        "isExistingAppointment": false,
                        "productAvailibilities": [
                            {
                                "products": []
                            }
                        ]
                    }
                ]
            };
    }

    handleAddLocationAdder(event) {
        this.productDataList = event.detail;
    }

    workOrderItemChecker(orderId) {
        /* Get Existing WorkorderItems With ServiceAppoitments*/
        if(orderId != undefined && orderId != null) {
            orderItemExisting({
                orderId: orderId
            }).then(result => {
                    if (result) {
                        this.workOrderItemWithSA = result;
                    }
            });
        }
    }

    handleConfirm(){

        this.isLoading = true;
        let weatherGuardCode = '';
        let bodyGlassCode = '';
        let weatherGuardAppointmentDate = [];
        let bodyGlassAppointmentDate = [];

        let isWeatherGuardValid = false;
        let isBodyGlassValid = false;
        let slotWeatherGuardDate;
        let slotBodyGlass;
        var isProductNotSelected = true;
        var noAppAtBillLoc = true;
        
        for (let h = 0; h < this.productDataList.length; h++) {
            if (this.selectedLocation.locationGUID === this.productDataList[h].serviceLocationId) {
                if (this.productDataList[h].appointments.length > 0) {
                    noAppAtBillLoc = false;
                    break;
                    }
                }
            }
            
        if (noAppAtBillLoc) {
                const evt = new ShowToastEvent({
                    title: this.label.ErrorTitle,
                    message: this.label.NoSAAtBillingLocation,
                    variant: 'error',
                });
                this.dispatchEvent(evt); 
            this.isLoading = false;
            return;
        }
        
        let productCounter = 0;
        let hasAppWithoutProducts = false;
        
        for (let h = 0; h < this.productDataList.length; h++) {
                for (let i = 0; i < this.productDataList[h].appointments.length; i++) {
                let isNoProductSelected = true;
                    for (let j = 0; j < this.productDataList[h].appointments[i].productAvailibilities[0].products.length; j++) {
                    if (this.productDataList[h].appointments[i].productAvailibilities[0].products[j].productEnable) {
                        isNoProductSelected = false;
                        productCounter++;
                        }
                    }
                if (isNoProductSelected){
                    hasAppWithoutProducts = true;
                    break;
                }
                }
            }
            
        if (hasAppWithoutProducts) {
            const evt = new ShowToastEvent({
                title: this.label.ErrorTitle,
                message: this.label.locationAtLeastLineItem,
                variant: 'error',
            });
            this.dispatchEvent(evt); 
            this.isLoading = false; 
            return;
        }
        
        let isSlotAppointmentDateMatch = false;
        let slotDateEmptyChk = false;

        let selectedProductList = {};
            if (this.productDataList[0].appointments.length > 0) {
            this.productDataList[0].appointments[0].productAvailibilities[0].products.forEach(products => {
                selectedProductList[products.productCode] = false;
            })
        }

        for (let h = 0; h < this.productDataList.length; h++) {
            for (let i = 0; i < this.productDataList[h].serviceLocationLabel[0].productNames.length; i++) {

                if (this.productDataList[h].serviceLocationLabel[0].productNames[i].prodCategory != null && this.productDataList[h].serviceLocationLabel[0].productNames[i].prodCategory != undefined && this.productDataList[h].serviceLocationLabel[0].productNames[i].prodCategory.toUpperCase() === this.label.weatherGuard.toUpperCase()) {
                    weatherGuardCode = this.productDataList[h].serviceLocationLabel[0].productNames[i].productCode;
                }
                if (this.productDataList[h].serviceLocationLabel[0].productNames[i].prodCategory != null && this.productDataList[h].serviceLocationLabel[0].productNames[i].prodCategory != undefined && this.productDataList[h].serviceLocationLabel[0].productNames[i].prodCategory.toUpperCase() === this.label.BodyGlass.toUpperCase()) {
                    bodyGlassCode = this.productDataList[h].serviceLocationLabel[0].productNames[i].productCode;
                }
            }

            for (let i = 0; i < this.productDataList[h].appointments.length; i++) {
                for (let j = 0; j < this.productDataList[h].appointments[i].productAvailibilities[0].products.length; j++) {

                    if (weatherGuardCode != '' && bodyGlassCode != '') {
                        if (!isWeatherGuardValid && this.productDataList[h].appointments[i].productAvailibilities[0].products[j].productCode == weatherGuardCode && this.productDataList[h].appointments[i].productAvailibilities[0].products[j].productEnable) {
                            isWeatherGuardValid = true;
                            slotWeatherGuardDate = new Date((this.productDataList[h].appointments[i].slotSelectedDate).split('-')[0]).toDateString();
                            weatherGuardAppointmentDate.push(slotWeatherGuardDate);
                        }
                        if (!isBodyGlassValid && this.productDataList[h].appointments[i].productAvailibilities[0].products[j].productCode == bodyGlassCode && this.productDataList[h].appointments[i].productAvailibilities[0].products[j].productEnable) {
                            isBodyGlassValid = true;
                            slotBodyGlass = new Date((this.productDataList[h].appointments[i].slotSelectedDate).split('-')[0]).toDateString();
                            bodyGlassAppointmentDate.push(slotBodyGlass);
                        }
                    }

                    if (this.productDataList[h].appointments[i].productAvailibilities[0].products[j].productEnable == true) {
                        selectedProductList[this.productDataList[h].appointments[i].productAvailibilities[0].products[j].productCode] = true;
                        
                    }

                    if ((this.productDataList[h].appointments[i].slotSelectedDate == '' || this.productDataList[h].appointments[i].slotSelectedDate == null || this.productDataList[h].appointments[i].slotSelectedDate == undefined) && this.productDataList[h].appointments[i].productAvailibilities[0].products[j].productEnable) {
                        slotDateEmptyChk = true;
                    }
                }
            }
        }

        if (weatherGuardAppointmentDate.length > 0 && bodyGlassAppointmentDate.length > 0) {
            for (let wgDate of weatherGuardAppointmentDate) {
                let wgDt = new Date(wgDate).toDateString();
                for (let bgDate of bodyGlassAppointmentDate) {
                    let bgDt = new Date(bgDate).toDateString();
                    if (new Date(wgDt) >= new Date(bgDt)) {
                    isSlotAppointmentDateMatch = true;
                        break;
                    }
                }
                if (isSlotAppointmentDateMatch) {
                        break;
                    }
                }
            }

        if (this.caseType == 'Job Request' && this.caseSubType == 'ISP') {
            slotDateEmptyChk = false;
        }
        
        if (isSlotAppointmentDateMatch) {
            const evt = new ShowToastEvent({
                title: 'Error!',
                message: this.label.WeatherGuardErrorMsg,
                variant: 'error',
            });
            this.dispatchEvent(evt);
            this.isLoading = false;
            return;
        }
        
        if (slotDateEmptyChk) {
            const evt = new ShowToastEvent({
                title: this.label.ErrorTitle,
                message: this.label.AppointmenSlotErrorMsg,
                variant: 'error',
            });
            this.dispatchEvent(evt); 
            this.isLoading = false; 
            return;
        }
        
        if (productCounter != this.selectedProductList.length) {
            const evt = new ShowToastEvent({
                title: this.label.ErrorTitle,
                message: this.label.appointmentConfirmError,
                variant: 'error',
            });
            this.dispatchEvent(evt);    
            this.isLoading = false;
            return;    
        }
    
        if (slotDateEmptyChk == false && isSlotAppointmentDateMatch == false) {
            this.template.querySelector('c-bln-_-schedule-appointment').sendProductData();
        }

        for (let h = 0; h < this.productDataList.length; h++) {
            for (let i = 0; i < this.productDataList[h].appointments.length; i++) {
                let appProducts = [];
                this.productDataList[h].appointments[i].productAvailibilities[0].products.forEach(function(ele) {
                    if (ele.productEnable) {
                        appProducts.push(ele.productCode);
                    }
                });

                let isExistingServiceAppointment = false;
                if (this.workOrderItemWithSA.hasOwnProperty(this.productDataList[h].appointments[i].serviceAppointmentId)) {
                    for (let t = 0; t < this.workOrderItemWithSA[this.productDataList[h].appointments[i].serviceAppointmentId].length; t++) {
                        if (!appProducts.includes(this.workOrderItemWithSA[this.productDataList[h].appointments[i].serviceAppointmentId][t])) {
                            isExistingServiceAppointment = true;
                        }
                    }
                }
                
                if (isExistingServiceAppointment) {
                    let productList = [];
                    for (let j = 0; j < this.productDataList[h].appointments[i].productAvailibilities[0].products.length; j++) {
                        if (this.productDataList[h].appointments[i].productAvailibilities[0].products[j].productEnable) {
                            productList.push({
                                'productCode': this.productDataList[h].appointments[i].productAvailibilities[0].products[j].productCode,
                                'quantity': this.productDataList[h].appointments[i].productAvailibilities[0].products[j].quantity,
                                'productOLIKey': this.productDataList[h].appointments[i].productAvailibilities[0].products[j].productCode + '_' + this.productDataList[h].appointments[i].productAvailibilities[0].products[j].bomId + '_' + this.productDataList[h].appointments[i].productAvailibilities[0].products[j].bundleName
                            })
                        }
                    }
                    
                    /* This one used only for child products related to bundle*/
                    if (this.addOnProductList != undefined && this.addOnProductList.length > 0) {
                        this.addOnProductList.forEach(ele => {
                            productList.push({
                                'productCode': ele.productCode,
                                'quantity': ele.quantity,
                                'productOLIKey': ele.productCode + '_' + ele.bomId + '_' + ele.bundleName
                            })
                        });
                    }

                    if (!this.rebookSaList || this.rebookSaList.length == 0) {
                        this.rebookSaList = [{
                            "caseId": this.caseId,
                            "rebookDetails": []
                        }]
                    }

                    this.rebookSaList[0].caseId = this.caseId;
                    this.rebookSaList[0].rebookDetails.push({
                        "saId": this.productDataList[h].appointments[i].serviceAppointmentId,
                        "productList": productList,
                        "action": 'Existing'
                    });
                }
            }
        }

        if (this.isRebooking == true) {
            getAfterHour({
                    saList: JSON.stringify(this.appointmentIds),
                    jsonProductData: this.getQuotePayload,
                    selectedProductJson: JSON.stringify(this.selectedProductList),
                isCashJourney: this.isCashJourney,
                caseId: this.caseId,
                    slotdate: JSON.stringify(this.productDataList)
                })
                .then(result => {
                    if (result && Object.keys(result).length > 0) {
                        this.afterHourObj = result;
                        this.afterHours = '£' + result.netPriceIncludingTax.toFixed(2);
            }
        }).catch(err => {
            console.log('afterhr Error', err);
        }).finally(() => {
           this.isLoading = false;
            
         });
            if (slotDateEmptyChk == false && isSlotAppointmentDateMatch == false) {
    
                this.isProductSummary = true;
                this.isSchduleAppointment = false;
                this.isChangeProduct = false;
            }
        } else {
             getAfterHour({
                    saList: JSON.stringify(this.appointmentIds),
                    jsonProductData: this.currentPayload,
                    selectedProductJson: JSON.stringify(this.selectedProductList),
        isCashJourney: this.isCashJourney,
        caseId: this.caseId,
        slotdate:JSON.stringify(this.setProductDataList)
        })
        .then( result => {
            if (result && Object.keys(result).length > 0) {
              this.afterHourObj = result;
            this.afterHours = '£'+result.netPriceIncludingTax.toFixed(2);
            }
        })
        .catch( err => {
            console.log('afterhr Error', err);
        })
        .finally( () => {
           this.isLoading = false;
                    if (slotDateEmptyChk == false && isSlotAppointmentDateMatch == false) {
            this.isProductSummary = true;
            this.isSchduleAppointment = false;
            this.isChangeProduct = false;
        }
                    
                });
            }
    }

    receivProductData(event){
        this.setProductDataList= event.detail.setProductDataList;
        this.screenThreeArrey = event.detail.productList;
        this.rebookSaList = event.detail.rebookSaList;
        this.screenThreeArrey.forEach( ele => {
            ele.appointments.forEach(element => {
                this.appointmentIds.push(element.serviceAppointmentId);
            });
        });
    }

    handleBack(){
        this.selectedProductList = this.selectedProductList.map(obj =>{
              return {...obj, checked:true};
        });

        const backEvent = new CustomEvent('send', {
            detail: {
                backarrayprod: [...this.selectedProductList],
                isback : true,
                isProductSelected : this.isProductSelected,
                earliestDateList : this.earliestDateList,
                locationList : this.locationList,
                selectedLocation : this.selectedLocation,
                isCashJourney : this.isCashJourney,
                liabilityList: this.liabilityList
            }
        });
        this.dispatchEvent(backEvent);
    }

    /* This method is used for back from summary screen to screen-1*/
    productsummarydata(event){
        this.productDataList = [];
        this.isSchduleAppointment = true;
        this.caseId = event.detail.caseIdBack;
        this.locationList = event.detail.locationListBack;
        this.selectedLocation = event.detail.selectedLocationBack;
        this.addOnProductList = event.detail.addOnProductListBack;
        this.hiddenProductList = event.detail && event.detail.hiddenProductListBack ? event.detail.hiddenProductListBack : [];
        this.selectedProductList = event.detail.selectedProductListBack;
        this.currentPayload = event.detail.currentPayloadBack;
        this.discount = event.detail.discountBack;
        this.isCashJourney = event.detail.isCashJourneyBack;
        this.liabilityList = event.detail.liabilityListBack;
        this.caseId = event.detail.caseIdBack; 
        this.productDataList = event.detail.appointmentScreenData; 
        this.isConnectedCall = event.detail.isBack;
        this.isProductSummary = false;
        
        this.primaryLocation = event.detail.isPrimaryLocation;

        if(this.caseType = 'Job Request' && this.caseSubType == 'ISP'){
            setTimeout(() => {
                this.handleBack();
            }, 5);    
        }
    }

    async showErrorSuccessToast(msg, theme, heading) {
        await LightningAlert.open({
            message: msg,
            theme: theme,
            label: heading
        });
    }

    async showErrorAlert(msg, theme, heading) {
        await LightningAlert.open({
            message: msg,
            theme: theme,
            label: heading
        });

        this.closeFlow();
    }

    async closeFlow() {
        getFocusedTabInfo().then(tabinfo => closeTab(tabinfo.tabId));
    }

    /* This is used for onload rebook  */
	earliestAppointmentContainerDataWrapSAHandler(event) {
        this.earliestDataDetail = event.detail;
        this.earliestHeaderDatePopulate(event.detail);
    }

    earliestHeaderDatePopulate(earliestDataDetail) {
        for (let h = 0; h < this.productDataList.length; h++) {
            for (let i = 0; i < this.productDataList[h].appointments.length; i++) {
                if(earliestDataDetail) {
                    if(this.productDataList[h].serviceLocationId == earliestDataDetail.locationId){
                        this.productDataList[h].earlierAvailabilityDateHeader = earliestDataDetail.earliestDate;
                        this.productDataList[h].earlierAvailabilityPrepDateTime = earliestDataDetail.earliestDate ? earliestDataDetail.earliestDate : earliestDataDetail.stockEarliestDate;
                        this.productDataList[h].earlierAvailabilityStockLocation = earliestDataDetail.stockLocationId;
                    }
                }
            }
        }
    }
}