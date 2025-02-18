import { LightningElement , api, track,wire} from 'lwc';
import QuoteLocation1 from '@salesforce/label/c.BLN_QuoteLocation';
import ServiceLocationLbl1 from '@salesforce/label/c.BLN_ServiceLocation';
import ServiceLocationAlreadyAdded from '@salesforce/label/c.bln_ServiceLocationAlreadyAdded';
import Products1 from '@salesforce/label/c.BLN_Products';
import EarliestAvailability1 from '@salesforce/label/c.BLN_EarliestAvailability';
import SelectSlot1 from '@salesforce/label/c.BLN_SelectSlot';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import addLocation from '@salesforce/label/c.BLN_AddLocation';
import confirmBooking from '@salesforce/label/c.BLN_ConfirmBooking';
import changeLocation from '@salesforce/label/c.BLN_ChangeLocation';
import changeProduct from '@salesforce/label/c.BLN_ChangeProduct';
import weatherGuard from '@salesforce/label/c.BLN_WeatherGuard';
    import BodyGlass from '@salesforce/label/c.Bln_BodyGlassLbl';
import AppointmenSlotErrorMsg  from '@salesforce/label/c.BLN_AppointmenSlotErrorMsg';
import WeatherGuardErrorMsg from '@salesforce/label/c.BLN_WeatherGuardErrorMsg';
import WeatherAndBodyGlassError  from '@salesforce/label/c.BLN_WeatherAndBodyGlassError';
import ErrorTitle from '@salesforce/label/c.BLN_ErrorTitle';
    import noActiveOrderOnCaseError from '@salesforce/label/c.BLN_NoActiveOrderOnCaseError';
    import failedToFetchOrderErrorRebook from '@salesforce/label/c.BLN_FailedToFetchOrderErrorRebook';
    import errorOccurred from '@salesforce/label/c.BLN_ErrorOccur';
    import rebookSA from '@salesforce/apex/BLN_ProductAvailabilityRebook.rebookServiceAppointments';
    import getAcceptedOrder from '@salesforce/apex/BLN_ProductAvailabilityRebook.getAcceptedOrder';
import getRepairProduct from '@salesforce/apex/BLN_ProductIdentifierUtility.getRepairProduct';
    import LightningAlert from 'lightning/alert';

    import appointmentConfirmError from '@salesforce/label/c.BLN_AppointmentConfirmError';
    import { getFocusedTabInfo, closeTab } from 'lightning/platformWorkspaceApi';
   import getCaseFields from "@salesforce/apex/BLN_PortalAppoinmentUpdate.getCaseFields";
   import { updateRecord ,getRecord,getFieldValue} from 'lightning/uiRecordApi';
   const FIELDS = [
       'Case.BLN_IsForceReprice__c'
      ];
export default class Bln_PortalRebook extends LightningElement {
        @api isTopParent = false;
        @api caseType;
        @api caseSubType;
        @api liabilityList = [];
        @api locationList = [];
        @api selectedLocation = [];
        @api addOnProductList = [];
        @api oldAddOnProductListV = [];
        @api oldAddOnProducts;
        @api selectedProductList = [];
        @api oldSelectedProductListV = [];
        @api oldSelectedProducts;
    
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
    @api isRebooking = false;//Re-book
    @api isRebookingchild = false; //Re-book
        @api getQuotePayload = [];//Re-book
        rebookSaList = []//Re-book
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
    value ='';
    isAddLocationDisabled  = true;
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
    afterHourObj ={};  
    isLoading = false; 
        @api portalstatus ='';
        @api newshedule='';
      // Varible for Rebook 6283
      isChangeLocation = false;
        @api isForceReprise = false;
      showProductSelectionPage = false;
      @api isFirstScreen = false;
      @api isRebookAssign = false;
      isLocationChange = false;
      @api adressList = [];
      existingGuid = '';
      isQuoteScreen = false;
      externalQuoteId = '';
      @api productReuiredList=[];
        @api allOrderItemsList = [];
        @api isRefresh = false;
        @api isChangeProduct = false;
        @api oldSelectedProductList;
        @api oldAddOnProductList;
        @track existingProductData = [];
        @api allOrderDetailsIds = [];
        @api productDataListRebook = [];
        @api isChangeProductFirstTime;
        weatherGuardAndBodyGlassDateList = [];
        @track buffer = 0;
        get showProductSelection() {
            return (this.isTopParent && this.isQuoteScreen);
        }
    
        get locationOptions() {
            let allAddLocations = '';
            this.productDataList.forEach(pdEle => {
                allAddLocations += pdEle.serviceLocationId;
            });
    
            let filteredLocations = this.locationList.filter(location => !allAddLocations.includes(location.locationGUID));
            let options = filteredLocations.map(location => ({
                label: location.quotelocation,
                value: location.quotelocation,
                quoteId: location.quoteId,
                locationId: location.locationGUID
            }));
    
            this.isAddLocationDisabled = options.length > 0 ? false : true;
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
            appointmentConfirmError
        }
    
        //PopUp
        // async calculateBuffer() {   
        //     try {
        //         const result = await bufferCalculationMethod({ caseId: this.caseId });
            
        //         if(result != null && result != undefined && result!= '' && this.isRebooking == false){
        //             this.buffer = result != null ? result : 0;
        //             console.log('this.buffer', this.buffer);
                
        //         }
        //     } catch (error) {
        //         console.error('Error calculating buffer:', error);
        //     }
        // }
    
        async connectedCallback() {
            this.isChangeProduct = this.isChangeProduct == null || this.isChangeProduct == undefined || this.isChangeProduct != true ? false : true;
            this.isRebookingchild = this.isChangeProduct == true ? this.isChangeProduct : false;
            this.oldSelectedProductList = this.oldSelectedProductList ? JSON.parse(JSON.stringify(this.oldSelectedProductList)) : [];
            this.oldAddOnProductList = this.oldAddOnProductList ? JSON.parse(JSON.stringify(this.oldAddOnProductList)) : [];
           // await this.calculateBuffer();
          //  this.buffer = this.buffer == undefined || this.buffer == null ? 0 : this.buffer;
            if (!this.isChangeProduct) {
                this.onLoad();
            } else {
                let productDataListRebookClone = JSON.parse(JSON.stringify(this.productDataListRebook));
                console.log('JSON.stringify(this.productDataListRebook) : ss',this.productDataListRebook)
    
                if(!productDataListRebookClone[0].serviceLocationName.includes(this.selectedLocation.quotelocation)){
                    console.log(`selected location ${this.selectedLocation.quotelocation} is not matching with 1st product list service location ${productDataListRebookClone[0].serviceLocationName}`);
                    // productDataListRebookClone[0].serviceLocationName
                    productDataListRebookClone[0].serviceLocationName = productDataListRebookClone[0].serviceLocationLabel[0].serviceLabel + ' ' + this.selectedLocation.quotelocation;
                    productDataListRebookClone[0].serviceLocationId = this.selectedLocation.quoteId;
                    productDataListRebookClone[0].earliestAvailablity[0].serviceName = this.selectedLocation.quotelocation;
                    productDataListRebookClone[0].appointments[0].locationId = this.selectedLocation.quoteId;
                    productDataListRebookClone[0].appointments[0].locationName = this.selectedLocation.quotelocation;
    
                    
                }
    
                this.selectedProductList.forEach(selectedEle => {
                    let productNames = JSON.parse(JSON.stringify(productDataListRebookClone[0].serviceLocationLabel[0].productNames));
    
                    let mathchingProducts = productNames.filter(productName =>
                    ((selectedEle.productCode == productName.productCode || (!selectedEle.productCode && !productName.productCode)) &&
                        (selectedEle.bomId == productName.bomId || (!selectedEle.bomId && !productName.bomId)) &&
                        (selectedEle.bundleName == productName.bundleName || (!selectedEle.bundleName && !productName.bundleName))));
    
                    if (mathchingProducts.length == 0) {
                        productDataListRebookClone.forEach(parentLocationBlock => {
                            parentLocationBlock.serviceLocationLabel[0].productNames.push(selectedEle);
    
                            let earlyDateSet = this.getAvailableDate(parentLocationBlock.serviceLocationId, selectedEle);
                            let earliestDate;
                            if (earlyDateSet && earlyDateSet.length > 0) {
                                earliestDate = earlyDateSet[0];
                                console.log(this.selectedLocationId,'--this.selectedLocationId == earliestDate.stockLocationId && -',earliestDate.stockLocationId );
                                for (let earlyDate of earlyDateSet) {
                                    console.log('-earlyDate -',earlyDate);
                                    console.log(earlyDate.availableFromDate,'-earliestDate.availableFromDate 2 -',earliestDate.availableFromDate );
                                    earliestDate = (new Date(earlyDate.availableFromDate) < new Date(earliestDate.availableFromDate)) ? earlyDate : false;
                                }
                            }
    
                            let isOutOfStockEarlyDate = earliestDate ? earliestDate.isOutOfStock : false;
                            console.log('-earliestDate--',earliestDate);
                            let earlyDate = earliestDate ? this.convertDate(new Date(earliestDate.availableFromDate)) : this.convertDate(new Date(new Date().getTime())); //(parseInt(this.buffer)*24*60*60*1000)
    
                            parentLocationBlock.earliestAvailablity[0].productDate.push({
                                "earliestDate": earlyDate,
                                "productCode": selectedEle.productCode,
                                "EarliestDateTime": earlyDate,
                                "isCPTDate": isOutOfStockEarlyDate,
                                "prodCategory": selectedEle.prodCategory
                            });
    
                            let product = {
                                "productCode": selectedEle.productCode,
                                "quantity": selectedEle.quantity,
                                "bomId": selectedEle.bomId,
                                "lineItemId": selectedEle.lineItemId,
                                "partOfBundle": selectedEle.partOfBundle,
                                "bundleName": selectedEle.bundleName,
                                "isCPTDate": isOutOfStockEarlyDate,
                                "isChecked": false,
                                "productEnable": false,
                                "prodCategory": selectedEle.prodCategory
                            }
                            let productFirstApp = JSON.parse(JSON.stringify(product));
                            parentLocationBlock.appointments.forEach(appBlock => {
                                appBlock.productAvailibilities[0].products.push(JSON.parse(JSON.stringify(product)));
                            });
                        });
                    }
                });
    
    
                let hasItemsToRemove = true;
                while (hasItemsToRemove) {
                    hasItemsToRemove = false;
    
                    let productNames = JSON.parse(JSON.stringify(productDataListRebookClone[0].serviceLocationLabel[0].productNames));
                    productNames.forEach((selectedEle, indexEle) => {
                        let mathchingProducts = this.selectedProductList.filter(productName =>
                        ((selectedEle.productCode == productName.productCode || (!selectedEle.productCode && !productName.productCode)) &&
                            (selectedEle.bomId == productName.bomId || (!selectedEle.bomId && !productName.bomId)) &&
                            (selectedEle.bundleName == productName.bundleName || (!selectedEle.bundleName && !productName.bundleName))));
    
                        if (mathchingProducts.length == 0) {
                            productDataListRebookClone.forEach(parentLocationBlock => {
                                parentLocationBlock.serviceLocationLabel[0].productNames.splice(indexEle, 1);
                                parentLocationBlock.earliestAvailablity[0].productDate.splice(indexEle, 1);
    
                                parentLocationBlock.appointments.forEach(appBlock => {
                                    appBlock.productAvailibilities[0].products.splice(indexEle, 1);
                                });
                            });
    
                            hasItemsToRemove = true;
                        }
                    });
                }
    
    
                this.productDataListRebook = JSON.parse(JSON.stringify(productDataListRebookClone));
                if (this.productDataList.length == 0) {
                    this.productDataList = [...this.productDataListRebook];
                }
    
                this.isSchduleAppointment = true;
            }
    
            if (this.caseType == 'Job Request' && this.caseSubType == 'ISP' && this.isChangeProduct == false) {
                setTimeout(() => {
                    this.handleConfirm();
                }, 5);
            }
        }
    
        onLoad() {
            if ( this.isForceReprise == true) {
                this.isSchduleAppointment = false;
                getAcceptedOrder({
                    caseId: this.caseId
                })
                    .then(result => {
                        if (result) {
                            this.externalQuoteId = result.BLN_CPQExternalQuoteId__c;
                            this.showProductSelectionPage = true;
                            this.isQuoteScreen = true;
                        } else {
                            this.showErrorAlert(this.label.noActiveOrderOnCaseError, 'error', this.label.errorOccurred);
                        }
                    });
            } else if ( true) {
                rebookSA({
                    caseId: this.caseId,
                    currentPayload: this.currentPayload
                })
                    .then(result => {
    
                        this.currentPayload = result.getQuotePayload;
                        this.externalQuoteId = result.externalQuoteId;
                        this.existingGuid = result.existingGUId;
                        this.earliestDateList = result.earliestAvailabilityList;
                        this.productDataList = JSON.parse(result.appointmentWrapperList);
                        this.locationList = result.quoteDetailsDataList;
                        this.selectedLocation = result.selectedLocation;
                        this.selectedQuoteLocation = result.selectedLocation;
                        this.getQuotePayload = result.getQuotePayload;
                        this.productReuiredList = result.productrequiredWrappList;
                        this.allOrderDetailsIds = result.orderItemDetails;
                        this.liabilityList = result.liabilityDataList;
    
                        this.selectedProductList = JSON.parse(JSON.stringify(result.prodLists))[0];
                        this.addOnProductList = JSON.parse(JSON.stringify(result.prodLists)).length > 1 ? JSON.parse(JSON.stringify(result.prodLists))[1] : [];
    
                        this.oldSelectedProductList = JSON.parse(JSON.stringify(this.selectedProductList));
                        this.oldAddOnProductList = JSON.parse(JSON.stringify(this.addOnProductList));
    
    
                        this.fillRequiredDataLocation();
                    })
                    .catch(error => {
                       // this.showErrorAlert(this.label.failedToFetchOrderErrorRebook, 'error', this.label.errorOccurred);
                       console.error('Error fetching order:', error);
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
            this.allOrderItemsList = [...this.allOrderDetailsIds];
            this.isQuoteScreen = true;
            
            if (!this.isTopParent) {
                let changeProductEvent = new CustomEvent('changeproductclick', {
                    detail: {
                        "isChangeProductFirstTime": this.isChangeProductFirstTime,
                        "isChangeProduct": this.isChangeProduct,
                        "productDataListRebook": this.productDataList
                    }
                });
                this.dispatchEvent(changeProductEvent);
            }
        }
    
        handleOldProduct(event) {
            this.oldAddOnProductList = event.detail.oldAddOnProductList;
            this.oldSelectedProductList = event.detail.oldSelectedProductList;
            this.isChangeProduct = true;
        }
    
        handleKeyIndexes() {
            let productDataListCopy = JSON.parse(JSON.stringify(this.productDataList));
            for (let h = 0; h < productDataListCopy.length; h++) {
                if (!productDataListCopy[h].keyIndex) {
                    if (h == 0) {
                        productDataListCopy[h].keyIndex = 'Location_' + h;
                    } else {
                        productDataListCopy[h].keyIndex = 'Location_' + (parseInt(productDataListCopy[h - 1].keyIndex.split('_')[1]) + 1);
                    }
                }
    
                for (let i = 0; i < productDataListCopy[h].appointments.length; i++) {
                    if (!productDataListCopy[h].appointments[i].keyIndex) {
                        if (i == 0) {
                            productDataListCopy[h].appointments[i].keyIndex = 'App' + productDataListCopy[h].keyIndex.split('_')[1] + '_' + i;
                        } else {
                            productDataListCopy[h].appointments[i].keyIndex = 'App' + productDataListCopy[h].keyIndex.split('_')[1] + '_' + (parseInt(productDataListCopy[h].appointments[i - 1].keyIndex.split('_')[1]) + 1);
                        }
                    }
    
                    for (let j = 0; j < productDataListCopy[h].appointments[i].productAvailibilities[0].products.length; j++) {
                        if (!productDataListCopy[h].appointments[i].productAvailibilities[0].products[j].keyIndex) {
                            if (j == 0) {
                                productDataListCopy[h].appointments[i].productAvailibilities[0].products[j].keyIndex = 'AppPrd' + productDataListCopy[h].keyIndex.split('_')[1] + '' + productDataListCopy[h].appointments[i].keyIndex.split('_')[1] + '_' + i;
                            } else {
                                productDataListCopy[h].appointments[i].productAvailibilities[0].products[j].keyIndex = 'AppPrd' + productDataListCopy[h].keyIndex.split('_')[1] + '' + productDataListCopy[h].appointments[i].keyIndex.split('_')[1] + '_' + (parseInt(productDataListCopy[h].appointments[i].productAvailibilities[0].products[j - 1].keyIndex.split('_')[1]) + 1);
                            }
                        }
                    }
                }
    
                for (let i = 0; i < productDataListCopy[h].serviceLocationLabel[0].productNames.length; i++) {
                    if (!productDataListCopy[h].serviceLocationLabel[0].productNames[i].keyIndexSLP) {
                        if (i == 0) {
                            productDataListCopy[h].serviceLocationLabel[0].productNames[i].keyIndexSLP = 'SLP' + productDataListCopy[h].keyIndex.split('_')[1] + '_' + i;
                        } else {
                            productDataListCopy[h].serviceLocationLabel[0].productNames[i].keyIndexSLP = 'SLP' + productDataListCopy[h].keyIndex.split('_')[1] + '_' + (parseInt(productDataListCopy[h].serviceLocationLabel[0].productNames[i - 1].keyIndexSLP.split('_')[1]) + 1);
                        }
                    }
                }
    
                for (let i = 0; i < productDataListCopy[h].earliestAvailablity[0].productDate.length; i++) {
                    if (!productDataListCopy[h].earliestAvailablity[0].productDate[i].keyIndex) {
                        if (i == 0) {
                            productDataListCopy[h].earliestAvailablity[0].productDate[i].keyIndex = 'EA' + productDataListCopy[h].keyIndex.split('_')[1] + '_' + i;
                        } else {
                            productDataListCopy[h].earliestAvailablity[0].productDate[i].keyIndex = 'EA' + productDataListCopy[h].keyIndex.split('_')[1] + '_' + (parseInt(productDataListCopy[h].earliestAvailablity[0].productDate[i - 1].keyIndex.split('_')[1]) + 1);
                        }
                    }
                }
            }
    
            this.productDataList = [...productDataListCopy];
            console.log('product data list final : ',JSON.stringify(this.productDataList))
        }
    
        closeModal(event) {
            this.isChangeLocation = false;
        }
    
        handleChangeLocation() {
            this.isChangeLocation = true;
    
        }
    
        adressDetail(event) {
            this.adressList = event.detail;
    
            this.isLocationChange = event.detail.isLocationChange;
            this.isQuoteScreen = true;
            this.isRebookingchild = false;
            this.isSchduleAppointment = false;
        }
    
        /* Method is used for date filter */
        getAvailableDate(locationId, selectedEle) {
            let currentProductEarliestDates = [];
    
            this.earliestDateList.forEach(eachDateSet => {
                /*console.log('--earliestDateList eachDateSet--',JSON.stringify(eachDateSet));
                console.log(eachDateSet.locationId,'--locationId--',locationId);
                console.log(!selectedEle.productCode,'--eachDateSet.productCode--',!eachDateSet.productCode);
                console.log(!selectedEle.bomId,'--eachDateSet.bomId--',!eachDateSet.bomId);
                console.log(!selectedEle.bundleName,'--eachDateSet.bundleName--',!eachDateSet.bundleName);*/
                if (eachDateSet.locationId == locationId &&
                    (eachDateSet.productCode == selectedEle.productCode || (!eachDateSet.productCode && !selectedEle.productCode)) &&
                    (eachDateSet.bomId == selectedEle.bomId || (!eachDateSet.bomId && !selectedEle.bomId)) &&
                    (eachDateSet.bundleName == selectedEle.bundleName || (!eachDateSet.bundleName && !selectedEle.bundleName))) {
                    currentProductEarliestDates = eachDateSet.earliestDateList;
                    console.log(JSON.stringify(eachDateSet.earliestDateList),'11--currentProductEarliestDates----------',JSON.stringify(currentProductEarliestDates));
                }
            });
    
            return currentProductEarliestDates;
        }
    
        /*This method will convert date in (DD MONTH,YYYY)  format */
        convertDate(actualDate) {
            const options = {
                year: "numeric",
                month: "long",
                day: "numeric",
            };
            console.log('-actualDate--',actualDate);
            let convertedDate = actualDate.toLocaleDateString("en-US", options);
            return convertedDate;
        }
    
        /*method to calculate max date from array of dates*/
        maxDateCalculation(arrayDate) {
            const maxDate = arrayDate.reduce((max, obj) => (new Date(obj.date) > new Date(max.date)) ? obj : max);
            return maxDate;
        }
    
        handleLocationChange(event) {
            this.selectedQuoteLocation = event.target.value;
            console.log('-this.selectedQuoteLocation--',this.selectedQuoteLocation);
            console.log('-this.this.locationOptions--',JSON.stringify(this.locationOptions));
            this.selectedLocationOptions = this.locationOptions.find(option => option.label === this.selectedQuoteLocation);
    
            this.selectedLocationId = this.selectedLocationOptions.locationId;
            this.selectedQuoteId = this.selectedLocationOptions.quoteId;
            this.isAddLocationDisabled = !this.selectedLocationOptions;
            this.selectedQuoteLocation = this.selectedLocationOptions;
            console.log('this.sselectedQuoteLocationelected',JSON.stringify(this.selectedQuoteLocation))
        }
    
        handleAddLocationClick(event) {
            this.isAddLocation = true;
            this.locationList.forEach(ele => {
                if (ele.quotelocation == this.selectedQuoteLocation) {
                    this.selectedAddLocation = ele;
                }
            });
           
            let isValidLocation = true;
            let j = 0;
    
            for (let i = 0; i < this.productDataList.length; i++) {
                if (this.selectedQuoteLocation == this.productDataList[i].earliestAvailablity[0].serviceName) {
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
    
            if (isValidLocation == true) {
                let isFirstLocation = (this.productDataList.length == 0);
                let cloneProductDataList = this.setJSONBlankForAppointment();
    
                cloneProductDataList.earliestAvailablity[0].serviceName = this.selectedQuoteLocation;
                cloneProductDataList.serviceLocationId = this.selectedLocationId;
                var locationValue = typeof this.selectedQuoteLocation == 'object' ? this.selectedQuoteLocation.label:this.selectedQuoteLocation;
                cloneProductDataList.serviceLocationName = this.label.ServiceLocationLbl1 + ' ' + locationValue;
                cloneProductDataList.appointments[0].locationId = this.selectedLocationId;
                cloneProductDataList.appointments[0].locationName = this.selectedQuoteLocation;
                cloneProductDataList.appointments[0].isMobileLocation = this.selectedAddLocation.isMobileLocation;
    
                if (isContainsWeatherGuard) {
                    let secondAppointment = JSON.parse(JSON.stringify(cloneProductDataList.appointments[0]));
                    secondAppointment.isFirstAppointment = false;
                    cloneProductDataList.appointments.push(secondAppointment);
                }
    
                console.log('--this.selectedProductList--',this.selectedProductList);
                console.log('--this.earliestDateList--',this.earliestDateList);
                this.selectedProductList.forEach(selectedEle => {
                    console.log('-selectedEle--',JSON.stringify(selectedEle));
                    cloneProductDataList.serviceLocationLabel[0].productNames.push(selectedEle);
                    console.log(this.selectedLocationId,'--selectedLocationId-');
                    let earlyDateSet = this.getAvailableDate(this.selectedLocationId, selectedEle);
                    console.log(this.earlyDateSet,'--earlyDateSet-');
                    let earliestDate;
                    if (earlyDateSet && earlyDateSet.length > 0) {
                        earliestDate = earlyDateSet[0];
                        
                        console.log(this.selectedLocationId,'--add location method -',earliestDate.stockLocationId );
                        for (let earlyDate of earlyDateSet) {
                            earliestDate = (new Date(earlyDate.availableFromDate) < new Date(earliestDate.availableFromDate)) ? earlyDate : earliestDate;
                        }
                    }
    
                    let isOutOfStockEarlyDate = earliestDate ? earliestDate.isOutOfStock : false;
                    let earlyDate = earliestDate ? this.convertDate(new Date(earliestDate.availableFromDate)) : this.convertDate(new Date(new Date().getTime())); //(parseInt(this.buffer)*24*60*60*1000)
                    console.log('-earlyDate-',earlyDate);
                    cloneProductDataList.earliestAvailablity[0].productDate.push({
                        "earliestDate": earlyDate,
                        "productCode": selectedEle.productCode,
                        "EarliestDateTime": earlyDate,
                        "isCPTDate": isOutOfStockEarlyDate
                    });
    
                    let product = {
                        "productCode": selectedEle.productCode,
                        "quantity": selectedEle.quantity,
                        "bomId": selectedEle.bomId == '' || selectedEle.bomId == undefined ? null : selectedEle.bomId,
                        "lineItemId": selectedEle.lineItemId,
                        "partOfBundle": selectedEle.partOfBundle,
                        "bundleName": selectedEle.bundleName == '' || selectedEle.bundleName == undefined ? null : selectedEle.bundleName,
                        "isCPTDate": isOutOfStockEarlyDate,
                        "isChecked": false,
                        "productEnable": false,
                        "prodCategory": selectedEle.prodCategory
                    }
                    let productFirstApp = JSON.parse(JSON.stringify(product));
                    let productSecondApp = JSON.parse(JSON.stringify(product));
    
                    product.productEnable = (isFirstLocation ? true : false);
    
                    /*This is used for when a product required consumed is true then product's radio button disable & false */
                    let productCodeN = selectedEle.productCode == '' || selectedEle.productCode == undefined ? null : selectedEle.productCode;
                    let bomIdN = selectedEle.bomId == '' || selectedEle.bomId == undefined ? null : selectedEle.bomId;
                    let bundleNameN = selectedEle.bundleName == '' || selectedEle.bundleName == undefined ? null : selectedEle.bundleName;
    
                    let productRequiredData = this.productReuiredList.find(ele => ele.productOLIKey == productCodeN + '_' + bomIdN + '_' + bundleNameN);
    
                    if (isContainsWeatherGuard) {
                        if (selectedEle.prodCategory != null && selectedEle.prodCategory != undefined && selectedEle.prodCategory.toUpperCase() === this.label.weatherGuard.toUpperCase()) {
                            productFirstApp.isChecked = false;
                            productFirstApp.productEnable = (isFirstLocation ? true : false);
                            productSecondApp.isChecked = true;
                            productSecondApp.productEnable = false;
                        } else {
                            productFirstApp.isChecked = true;
                            productFirstApp.productEnable = false;
                            productSecondApp.isChecked = false;
                            productSecondApp.productEnable = (isFirstLocation ? true : false);
    
                        }
                        cloneProductDataList.appointments[0].productAvailibilities[0].products.push(productFirstApp);
                        cloneProductDataList.appointments[1].productAvailibilities[0].products.push(productSecondApp);
                    } else if ( productRequiredData != undefined && productRequiredData.isConsumed != null && productRequiredData.isConsumed == true) {
                        productFirstApp.productEnable = false;
                        productFirstApp.isChecked = true;
    
                        cloneProductDataList.appointments[0].productAvailibilities[0].products.push(productFirstApp);
                    } else {
                        productFirstApp.isChecked = false;
                        productFirstApp.productEnable = (isFirstLocation ? true : false);
    
                        cloneProductDataList.appointments[0].productAvailibilities[0].products.push(productFirstApp);
                    }
                });
    
                this.productDataList.push(cloneProductDataList);
                this.productDataList = [...this.productDataList];
                console.log('productDataList ',JSON.stringify(this.productDataList))
            } else {
                const evt = new ShowToastEvent({
                    title: this.label.ErrorTitle,
                    message: this.label.ServiceLocationAlreadyAdded,
                    variant: 'error',
                });
                this.dispatchEvent(evt);
            }
    
            this.handleKeyIndexes();
            this.isSchduleAppointment = true;
            this.isClickAddLocation = false;
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
                    if (earlyDateSet && earlyDateSet.length > 0) {
                        earliestDate = earlyDateSet[0];
                        for (let earlyDate of earlyDateSet) {
                            earliestDate = (new Date(earlyDate.availableFromDate) < new Date(earliestDate.availableFromDate)) ? earlyDate : false;
                        }
                    }
    
                    let isOutOfStockEarlyDate = earliestDate ? earliestDate.isOutOfStock : false;
                    let earlyDate = earliestDate ? this.convertDate(new Date(earliestDate.availableFromDate)) : this.convertDate(new Date(new Date().getTime())); //(parseInt(this.buffer)*24*60*60*1000)
    
                    cloneProductDataList.earliestAvailablity[0].productDate.push({
                        "earliestDate": earlyDate,
                        "productCode": selectedEle.productCode,
                        "EarliestDateTime": earlyDate,
                        "isCPTDate": isOutOfStockEarlyDate
                    });
                });
            });
            this.productDataList = [...productDataListClone];
            this.productDataListRebook = [...this.productDataList];
    
            this.handleKeyIndexes();
            this.isSchduleAppointment = true;
        }
        
        setJSONBlankForAppointment() {
            return {
                "serviceLocationName": this.label.QuoteLocation1 + ' ' + this.selectedQuoteLocation,
                "serviceLocationId":"",
                "isPrimaryLocation":false,
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
                        "earlierAvailabilityPrepDateTime":"",
                        "slotSelectedDate": "",
                        "serviceAppointmentId": "",
                        "slotDate": "",
                        "slotTime": "",
                        "slotDateTimeStart": "",
                        "slotDateTimeFinish": "",
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

        handleConfirm() {
            this.isLoading = true;
            let weatherGuardCode = '';
            let bodyGlassCode = '';
            let weatherGuardAppointmentDate = [];
            let bodyGlassAppointmentDate = [];
    
            let isWeatherGuardValid = false;
            let isBodyGlassValid = false;
            let slotWeatherGuardDate;
            let slotBodyGlass;
    
            let appointmentNumber = 0;
            let isSlotAppointmentDateMatch = false;
            let slotDateEmptyChk = false;
            let isEmptyAppointment = false;
    
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
                    if(this.productDataList[h].appointments.length == 0) {
                        isEmptyAppointment = true;
                        break;
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
                            // break;
                    }
                }
            }
        }

            Object.entries(selectedProductList).map(entry => {
                if (entry[1] == false && isEmptyAppointment == false) {
                    isEmptyAppointment = true;
                }          
            });
    
            if(weatherGuardAppointmentDate.length > 0 && bodyGlassAppointmentDate.length > 0) {
                for (let wgDate of weatherGuardAppointmentDate) {
                    let wgDt = new Date(wgDate).toDateString();
                    for(let bgDate of bodyGlassAppointmentDate){
                        let bgDt = new Date(bgDate).toDateString();
                        if(new Date(wgDt) >= new Date(bgDt)){
                            isSlotAppointmentDateMatch = true;
                            break;
                        }
                    }
                    if(isSlotAppointmentDateMatch){
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
            }
    
        
        if(slotDateEmptyChk) {
            const evt = new ShowToastEvent({
                title: this.label.ErrorTitle,
                message: this.label.AppointmenSlotErrorMsg,
                variant: 'error',
            });
                this.dispatchEvent(evt);
            }
            if (isEmptyAppointment) {
                const evt = new ShowToastEvent({
                    title: this.label.ErrorTitle,
                    message: this.label.appointmentConfirmError,
                    variant: 'error',
                });
                this.dispatchEvent(evt);
            }
    
            if (slotDateEmptyChk == false && isSlotAppointmentDateMatch == false) {
                this.template.querySelector('c-bln-_-schedule-appointment').sendProductData();
            }
    
            // if (true) {
            //     getAfterHour({
            //         saList: JSON.stringify(this.appointmentIds),
            //         jsonProductData: this.getQuotePayload,
            //         selectedProductJson: JSON.stringify(this.selectedProductList),
            //         isCashJourney: this.isCashJourney,
            //         caseId: this.caseId,
            //         slotdate: JSON.stringify(this.productDataList)
            //     })
            //         .then(result => {
            //             if (result && result != null && Object.keys(result).length > 0) {
            //                 this.afterHourObj = result;
            //                 result.netPriceIncludingTax = result.netPriceIncludingTax != null && result.netPriceIncludingTax != undefined && result.netPriceIncludingTax != '' ? result.netPriceIncludingTax : 0.00;
            //                 this.afterHours = '£' + result.netPriceIncludingTax.toFixed(2);
            //             }
            //         })
            //         .catch(err => {
            //             console.log('afterhr Error', err);
            //         })
            //         .finally(() => {
            //             this.isLoading = false;
    
            //         });
            //     if (slotDateEmptyChk == false && isSlotAppointmentDateMatch == false && isEmptyAppointment == false) {
            //         console.log('afterhr Result880',  this.afterHourObj);
        
            //         this.isProductSummary = true;
            //         this.isSchduleAppointment = false;
            //         this.isChangeProduct = false;
            //     }
            // }
            // else {
            //     getAfterHour({
            //         saList: JSON.stringify(this.appointmentIds),
            //         jsonProductData: this.currentPayload,
            //         selectedProductJson: JSON.stringify(this.selectedProductList),
            //         isCashJourney: this.isCashJourney,
            //         caseId: this.caseId,
            //         slotdate: JSON.stringify(this.setProductDataList)
            //     })
            //         .then(result => {
            //             console.log('afterhr Result822', result);
            //             // this.afterHourObj = {
            //             //     partNumber : 'PSERUK00012A',
            //             //     netPriceIncludingTax: 89.65,
            //             //     partDescription: 'After hoursWeekday + Saturday (Body glass & Rears)'
            //             // };
            //             // this.afterHours = '£89.65';
            //             // console.log('this.afterHourObj',this.afterHourObj);
            //             // console.log('afterhr Result112',  this.afterHours);
            //             if (result && Object.keys(result).length > 0) {
            //                 this.afterHourObj = result;
            //                 console.log('83this.afterHourObj', this.afterHourObj);
            //                 console.log('afterhr Result112', result);
            //                 this.afterHours = '£' + result.netPriceIncludingTax.toFixed(2);
            //             }
            //         })
            //         .catch(err => {
            //             console.log('afterhr Error', err);
            //         })
            //         .finally(() => {
            //             this.isLoading = false;
            //             if (slotDateEmptyChk == false && isSlotAppointmentDateMatch == false && isEmptyAppointment == false) {
            //                 console.log('afterhr Result880',  this.afterHourObj);
                
            //                 this.isProductSummary = true;
            //                 this.isSchduleAppointment = false;
            //                 this.isChangeProduct = false;
            //             }
                        
    
            //         });
            // }
    
    
    }

    formatedDate(fDate) {
            let newFDate = new Date(fDate);
        return new Date(newFDate.getFullYear(),'/',newFDate.getMonth+1,'/',newFDate.getDate());
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
        handleload(){
            const event = new CustomEvent('reload', {
                detail: false // You can pass any detail if needed
            });
            this.dispatchEvent(event);
        }
        handleBack() {
            this.selectedProductList = this.selectedProductList.map(obj => {
                return { ...obj, checked: true };
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
    
            if (this.caseType = 'Job Request' && this.caseSubType == 'ISP') {
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
}