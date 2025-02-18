import { LightningElement, track, api,wire } from 'lwc';
import quoteLocationLbl from '@salesforce/label/c.BLN_QuoteLocation';
import ServiceLocationLbl from '@salesforce/label/c.BLN_ServiceLocation';
import Products from '@salesforce/label/c.BLN_Products';
import StatusCompleted from '@salesforce/label/c.BLN_Completed';
import StatusInProgress from '@salesforce/label/c.BLN_InProgress';
import EarliestAvailability from '@salesforce/label/c.BLN_EarliestAvailability';
import StockableItem from '@salesforce/label/c.BLN_StockableItem';
import SelectSlot from '@salesforce/label/c.BLN_SelectSlot';
import EarliestDateError from '@salesforce/label/c.BLN_EarliestDateError';
import ErrorTitle from '@salesforce/label/c.BLN_ErrorTitle';
import EarlistNotAvailableHelpText from '@salesforce/label/c.EarlistNotAvailableHelpText';
import SAError from '@salesforce/label/c.BLN_SAError';
import SACreationError from '@salesforce/label/c.BLN_SACreationError';
import WeatherGuard from '@salesforce/label/c.Bln_WeatherGuardLbl';
import BodyGlass from '@salesforce/label/c.Bln_BodyGlassLbl';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createAppoitment from '@salesforce/apex/BLN_AppointmentCreateUpdate.prepData'
import bufferCalculationMethod from '@salesforce/apex/BLN_ProductAvailabilityUtility.bufferCalculation'
import completeEarliestDates from '@salesforce/apex/BLN_ProductAvailabilityRebook.getEarliestDateList'
//import updateSADueDate from '@salesforce/apex/BLN_ProductIdentifierUtility.updateAppointment'
import getBranchSlots from '@salesforce/apex/BLN_AppointmentCreateUpdate.getBranchSlots'
import getMobileSlots from '@salesforce/apex/BLN_AppointmentCreateUpdate.getMobileSlots'
import LightningAlert from 'lightning/alert';


import { CurrentPageReference } from 'lightning/navigation';


export default class Bln_ScheduleAppointment extends LightningElement {
    
    /* This is the custom label */
    label = {
        ServiceLocationLbl,
        Products,
        EarliestAvailability,
        SelectSlot,
        quoteLocationLbl,
        EarliestDateError,
        ErrorTitle,
        SAError,
        SACreationError,
        WeatherGuard,
        BodyGlass,
        StockableItem,
        EarlistNotAvailableHelpText,
        StatusCompleted,
        StatusInProgress
    }

    showSpinner= false;
    @track screen3childMap = {};
    
    isDisableSelectSlot = false;
    @track selectedAppointmentName;
    @api liabilityList = [];
    
    @api locationList = [];
    @api selectedLocation = [];
    @api addOnProductList = [];
    @api setProductDataList= [];
    @api rebookProductDataList = [];//re-book variables
    @api selectedProductList = [];
    @api earliestDateList = [];
   @api isProductSummary = false;
    @api caseId;
    @api isConnectedCall = false;
    @track disableAppointment = false;
    @api primaryLocation;
    @api isAddLocation = false;
    @api isChangeProduct;
    stockEarliestDate
    showSelectSlotPopUp = false;
    selectSlotAppointment;
    selectedData = '';
    @api selectedLocationOptions = [];
    isAddLocationDisabled  = true;
    @api quoteLocationData;
    
    isDisableSelectSlot = false;
    appointmentAddLimit = 0;
    @track selectedAppointmentName;
    @api isLocationChange = false;
    quoteLocation = '';

    showSelectSlotPopUp = false;
    selectSlotAppointment;
    selectedAppointmentRow;
    selectedData = '';
    appointmentIdList = [];
    isMobileLocation = '';
    isDropOff = false;
    
    @api currentPayload;
    @api isCashJourney;
    @track isCheckboxSelected = true;
    @track prepDataList = [];
    /*Re-booking*/
    @api isRebooking = false;
    oldAppointmentId = '';
    oldSlotDetails = '';
    isCancellChange  = false;
    rebookReasonValue = '';
    rebookSubReasonOptionValue = '';
    oldSAOfRemovedAppointment = '';
    oldSAIndex = '';
    oldAppIndex = '';
    isRebookingRequestModel = false;
    oldSAOfDeletedAppointment = '';
    @track isForceappointmentResult = '';
    //disableCrossButton = false;
    @api productReuiredList=[];
    @api getQuotePayload = [];
    isDisableSelectSlot = false;
    @track buffer = 0;
    showBufferSection = false;
    earlistHelpText;
    @api productDataListRebook = [];
    @track productDataList;
    @api earliestDataDetail = [];
    @api bomIdWithPromseDateTime = [];
    earliestDate;
    appointmentId;
    earliestStockLocation;
    isEarliestDates = false;

    @track rebookSAList = [{
        "caseId": this.caseId,
        "rebookDetails": []
    }];

    async calculatedEarliestDates(currentPayload,caseId, bomIdWithPromseDateTime) {
        completeEarliestDates({responsePayload: currentPayload, caseId: caseId, bomIdWithPromseDateTime: bomIdWithPromseDateTime }).then(result => {
            this.earliestDateList = result;
            this.isEarliestDates = true;
        })
        .catch(error => {
            this.error = error;
            this.accounts = undefined;
        })

    }

    
    /* This is onload method which is execute onload component */
    async connectedCallback() {
        
        this.isChangeProduct = this.isChangeProduct == null || this.isChangeProduct == undefined || this.isChangeProduct == '' ? false : true;
        await this.calculatedEarliestDates(this.currentPayload, this.caseId, this.bomIdWithPromseDateTime);
        await this.calculateBuffer();
        let isContainsWeatherGuard = false;
        let isContainsBodyGlass = false;
        if( this.selectedProductList ){
            for (let i = 0; i < this.selectedProductList.length; i++) {
                if (this.selectedProductList[i].prodCategory != null && this.selectedProductList[i].prodCategory  != undefined && this.selectedProductList[i].prodCategory != '' && this.selectedProductList[i].prodCategory.toUpperCase() === this.label.WeatherGuard.toUpperCase()) {
                    isContainsWeatherGuard = true;
            }
                if (this.selectedProductList[i].prodCategory != null && this.selectedProductList[i].prodCategory != '' && this.selectedProductList[i].prodCategory != undefined && this.selectedProductList[i].prodCategory.toUpperCase() === this.label.BodyGlass.toUpperCase()) {
                isContainsBodyGlass = true;
            }
        }
        }

        this.earlistHelpText = this.label.EarlistNotAvailableHelpText;
        this.productDataList = JSON.parse(JSON.stringify(this.setProductDataList));

        if(this.isChangeProduct == true) {
            for (let i = 0; i < this.productDataListRebook.length; i++) {
                for(let j = 0; j < this.productDataListRebook[i].appointments.length; j++){
                    if( this.productDataList[i].appointments.length-1 < j ){
                        let productsDL = JSON.parse(JSON.stringify(this.productDataList[i].appointments[0].productAvailibilities[0].products));
                        this.productDataList[i].appointments.push(JSON.parse(JSON.stringify(this.productDataListRebook[i].appointments[j])));
                        this.productDataList[i].appointments[j].productAvailibilities[0].products = productsDL;
                    }

                    this.productDataList[i].appointments[j].isFirstAppointment =  this.productDataListRebook[i].appointments[j].isFirstAppointment;
                    this.productDataList[i].appointments[j].isExistingAppointment =  this.productDataListRebook[i].appointments[j].isExistingAppointment;
                    this.productDataList[i].appointments[j].appointmentName =  this.productDataListRebook[i].appointments[j].appointmentName;
                    this.productDataList[i].appointments[j].keyIndex =  this.productDataListRebook[i].appointments[j].keyIndex;
                    this.productDataList[i].appointments[j].locationId =  this.selectedLocation.locationGUID;
                    this.productDataList[i].appointments[j].locationName =  this.selectedLocation.quotelocation;
                    this.productDataList[i].appointments[j].slotSelectedDate =  this.productDataListRebook[i].appointments[j].slotSelectedDate
                    this.productDataList[i].appointments[j].isMobileLocation =  this.productDataListRebook[i].appointments[j].isMobileLocation
                    this.productDataList[i].appointments[j].appointmentName =  this.productDataListRebook[i].appointments[j].appointmentName
                    this.productDataList[i].appointments[j].serviceAppointmentId =  this.productDataListRebook[i].appointments[j].serviceAppointmentId
                    this.productDataList[i].appointments[j].slotDate =  this.productDataListRebook[i].appointments[j].slotDate
                    this.productDataList[i].appointments[j].slotTime =  this.productDataListRebook[i].appointments[j].slotTime
                    this.productDataList[i].appointments[j].isDropOff =  this.productDataListRebook[i].appointments[j].isDropOff
                    this.productDataList[i].appointments[j].isForceAppointment =  this.productDataListRebook[i].appointments[j].isForceAppointment
                    this.productDataList[i].appointments[j].slotDateTimeStart =  this.productDataListRebook[i].appointments[j].slotDateTimeStart
                    this.productDataList[i].appointments[j].slotDateTimeFinish =  this.productDataListRebook[i].appointments[j].slotDateTimeFinish
                    
                    for(let p = 0; p < this.productDataList[i].appointments[j].productAvailibilities[0].products.length; p++){
                        this.productDataList[i].appointments[j].productAvailibilities[0].products[p].productEnable = false;
                        this.productDataList[i].appointments[j].productAvailibilities[0].products[p].isChecked = false;
                    }

                    for(let k = 0; k < this.productDataListRebook[i].appointments[j].productAvailibilities[0].products.length; k++){
                        for(let p = 0; p < this.productDataList[i].appointments[j].productAvailibilities[0].products.length; p++){
                            
                            let productDLProductCode = this.productDataList[i].appointments[j].productAvailibilities[0].products[p].productCode;
                            let productRLProductCode = this.productDataListRebook[i].appointments[j].productAvailibilities[0].products[k].productCode;
                            let productDLBundleName = this.productDataList[i].appointments[j].productAvailibilities[0].products[p].bundleName;
                            let productRLBundleName = this.productDataListRebook[i].appointments[j].productAvailibilities[0].products[k].bundleName;
                            let productDLBomId = this.productDataList[i].appointments[j].productAvailibilities[0].products[p].bomId;
                            let productRLBomId = this.productDataListRebook[i].appointments[j].productAvailibilities[0].products[k].bomId;
                            productDLProductCode = productDLProductCode == '' || productDLProductCode == undefined ? null : productDLProductCode;
                            productRLProductCode = productRLProductCode == '' || productRLProductCode == undefined ? null : productRLProductCode;
                            productDLBundleName = productDLBundleName == '' || productDLBundleName == undefined ? null : productDLBundleName;
                            productRLBundleName = productRLBundleName == '' || productRLBundleName == undefined ? null : productRLBundleName;
                            productDLBomId = productDLBomId == '' || productDLBomId == undefined ? null : productDLBomId;
                            productRLBomId = productRLBomId == '' || productRLBomId == undefined ? null : productRLBomId;
                            
                            if(productDLProductCode == productRLProductCode && 
                                productDLBundleName == productRLBundleName &&
                                productDLBomId == productRLBomId){

                                this.productDataList[i].appointments[j].productAvailibilities[0].products[p] = {
                                    "productCode":this.productDataListRebook[i].appointments[j].productAvailibilities[0].products[k].productCode,
                                    "productEnable": this.productDataListRebook[i].appointments[j].productAvailibilities[0].products[k].productEnable,
                                    "quantity": this.productDataListRebook[i].appointments[j].productAvailibilities[0].products[k].quantity,
                                    "isChecked": this.productDataListRebook[i].appointments[j].productAvailibilities[0].products[k].isChecked,
                                    "bomId":this.productDataListRebook[i].appointments[j].productAvailibilities[0].products[k].bomId,
                                    "lineItemId":this.productDataListRebook[i].appointments[j].productAvailibilities[0].products[k].lineItemId,
                                    "partOfBundle":this.productDataListRebook[i].appointments[j].productAvailibilities[0].products[k].partOfBundle,
                                    "bundleName":this.productDataListRebook[i].appointments[j].productAvailibilities[0].products[k].bundleName,
                                    "prodCategory" : this.productDataListRebook[i].appointments[j].productAvailibilities[0].products[k].prodCategory
                                };
                            }
                        }
                    }
                }
            }
        }

        this.quoteId = this.selectedLocation.quoteId;
        this.quoteLocation = this.selectedLocation.quotelocation;

        this.productDataList = JSON.parse(JSON.stringify(this.productDataList));
        this.calculateAppointmentHeaderDates();
        
    }

    calculateAppointmentHeaderDates() {
        this.productDataList.forEach(prodEle => {
            this.earliestDate = null;
            this.appointmentId = null;
            this.earliestStockLocation = null;
            this.stockEarliestDate = new Date();

            prodEle.appointments.forEach(eleApp => {

                if( eleApp.status == this.label.StatusCompleted || eleApp.status ==  this.label.StatusInProgress){
                    eleApp.disableCrossButton=true;
                    eleApp.isDisableSelectSlot=true;
                    eleApp.productAvailibilities[0].products.forEach(prodElement => {
                        prodElement.isChecked=true;
                    });
                }

                let availabilityList = [];
                let hasEnabledProducts = false;
                let productRequiredData;
                eleApp.productAvailibilities[0].products.forEach(prodElement => {

                    productRequiredData = this.productReuiredList.find(ele => ele.productOLIKey == prodElement.productCode+'_'+prodElement.bomId+'_'+prodElement.bundleName);
                    if(productRequiredData != undefined && productRequiredData.isConsumed != null && productRequiredData.isConsumed == true){
                        if(eleApp.woliId != undefined && eleApp.woliId != null && eleApp.woliId === productRequiredData.woliId) {
                            prodElement.productEnable = true;
                        } else {
                            prodElement.productEnable = false;
                        }
                        prodElement.isChecked=true;
                    }

                    if( prodElement.productEnable ){
                        hasEnabledProducts = true;
                        let earlyDateSet = this.getAvailableDate(prodEle.serviceLocationId, prodElement);
                        
                        if( earlyDateSet != null && earlyDateSet.length > 0 ){
                            availabilityList.push(earlyDateSet)
                        }
                    }
                });

                let earliestDate;
                let earliestStockLocation;
                let locationAvailibility;
                this.buffer = this.buffer == undefined || this.buffer == null ? 0 : this.buffer;
                if(this.earliestDataDetail != null && this.earliestDataDetail != undefined && this.earliestDataDetail.length > 0) {
                for(var earliestIns of this.earliestDataDetail) {
                            if(earliestIns.locationId == this.selectedLocation.locationGUID) {
                                if(earliestIns.earliestDate) {
                                    eleApp.earlierAvailabilityPrepDateTime = earliestIns.earliestDate;
                                    eleApp.earlierAvailabilityDateHeader = earliestIns.earliestDate;
                        } else {
                            eleApp.earlierAvailabilityPrepDateTime = earliestIns.stockEarliestDate;
                                }
                                if(earliestIns.appointmentId) {
                                    eleApp.earlierAvailabilityAppointmentId = earliestIns.appointmentId;
                                }
                        if(earliestIns.stockLocationId) {
                            eleApp.earlierAvailabilityStockLocation = earliestIns.stockLocationId;
                                }
                            }
                        }
                }
                if( hasEnabledProducts ){ 
                    if( availabilityList.length > 0 ){
                        for (let availableAtLocation of availabilityList[0] ) {
                            let locationId = availableAtLocation.stockLocationId;
                            locationAvailibility = new Date(availableAtLocation.availableFromDate);
                            for( let availabilityObjList of availabilityList ){
                                for( let availabilityObj of availabilityObjList ){
                                    if( locationId == availabilityObj.stockLocationId && locationAvailibility <= new Date(availabilityObj.availableFromDate) ){
                                        locationAvailibility = new Date(availabilityObj.availableFromDate);
                                    }
                                }
                            }
                            earliestStockLocation = !earliestDate? locationId: (locationAvailibility<earliestDate?locationId:earliestStockLocation);
                            earliestDate = !earliestDate? locationAvailibility: (locationAvailibility<earliestDate?locationAvailibility:earliestDate);
                        }
                    }else{
                        //this handles service and charge products
                        let availDetail  = {};
                        availDetail.stockLocationId = prodEle.serviceLocationId;
                        availDetail.isOutOfStock = false;
                        availDetail.availableFromDate = this.convertDate(new Date(new Date().getTime()+parseInt(this.buffer)*24*60*60*1000));
                        earliestDate =  new Date(new Date().getTime()+(parseInt(this.buffer)*24*60*60*1000));
                        earliestStockLocation = prodEle.serviceLocationId;
                        locationAvailibility = this.convertDate(new Date(new Date().getTime()+(parseInt(this.buffer)*24*60*60*1000)));
                    }
                    eleApp.earlierAvailabilityPrepDateTime = this.convertDate(earliestDate);
                    eleApp.earlierAvailabilityDateHeader = earliestDate != null && earliestDate != undefined ? this.convertDate(earliestDate) : this.convertDate(new Date(new Date().getTime() + parseInt(this.buffer)*24*60*60*1000));
                    //eleApp.earlierAvailabilityDateHeader = this.convertDate(earliestDate);
                    eleApp.earlierAvailabilityStockLocation = earliestStockLocation;
                }else{
                    eleApp.earlierAvailabilityDateHeader = '';
                }
            })

            prodEle.location = this.locationList.find(ele=> ele.locationGUID == this.selectedLocation.locationGUID); 
        });
        this.handleKeyIndexes();
        this.setDataScheduleAppointment();
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
            }
        }

        this.productDataList = [...productDataListCopy];
        //this.handleRepairProductFilter(this.productDataList);
    }

    get productDataList(){
        if(this.productDataList.length > 0 )
        return null;
    }    

    objConvert(obj) {
        return JSON.parse(JSON.stringify(obj));
    }

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
        var convertedDate = actualDate.toLocaleDateString("en-US", options);
        return convertedDate;
    }

    /*This method will execute after clicking on + button on the screen to add new Appointment column  */
    handleClick(event) {
        let rowIndex = parseInt(event.currentTarget.dataset.rowindex);
        let serviceLocation = event.currentTarget.dataset.location;

        let location = serviceLocation.replace(this.label.ServiceLocationLbl,'');
        let locationName = this.productDataList[rowIndex].serviceLocationName;
        let locationID = this.productDataList[rowIndex].serviceLocationId;
        let mobileLocation = this.locationList.find(ele=> ele.locationGUID ==  this.productDataList[rowIndex].serviceLocationId).isMobileLocation
        
        let appCount = this.productDataList[rowIndex].appointments.length;
        let jsonAppointment = {
            "appointmentName": "Appointment" + ' ' + (appCount+1),
            "keyIndex": '',
                    "locationId": locationID,
            "locationName": locationName,
            "isFirstAppointment": false,
            "isMobileLocation": mobileLocation,
                    "earlierAvailabilityDateHeader": "",
                "earlierAvailabilityAppointmentId": "",
            "earlierAvailabilityPrepDateTime": "",
                    "slotSelectedDate": "",
                    "serviceAppointmentId": "",
                    "slotDate": "",
                    "slotTime": "",
                    "isDropOff":this.isDropOff,
                "isForceAppointment":false,
                    "slotDateTimeStart": "",
                    "slotDateTimeFinish": "",
                "isExistingAppointment": false,
                "productAvailibilities": [
                    {
                    "products": []
                    }
                    ]
                };

        this.productDataList[rowIndex].serviceLocationLabel[0].productNames.forEach(productDataEle => {
            let selectedEle = this.selectedProductList.find(ele => (ele.productCode == productDataEle.productCode && ((ele.bomId == null? '':ele.bomId) == (productDataEle.bomId == null? '':productDataEle.bomId)) && ((ele.bundleName == null? '':ele.bundleName) == (productDataEle.bundleName == null? '':productDataEle.bundleName))));

            let product = {
                "productCode": selectedEle.productCode,
                "quantity":selectedEle.quantity,
                "bomId":selectedEle.bomId == '' || selectedEle.bomId == undefined ? null : selectedEle.bomId,
                "lineItemId":selectedEle.lineItemId,
                "partOfBundle":selectedEle.partOfBundle,
                "bundleName":selectedEle.bundleName == '' || selectedEle.bundleName == undefined ? null : selectedEle.bundleName,
                "isChecked" : false,
                "productEnable":false,
            }

            /*This is used for when a product required consumed is true then product's radio button disable & false */
            let productRequiredData = this.productReuiredList.find(ele => ele.productOLIKey == selectedEle.productCode+'_'+selectedEle.bomId+'_'+selectedEle.bundleName);

            let productFirstApp = JSON.parse(JSON.stringify(product));
            if(( selectedEle.prodCategory != null && selectedEle.prodCategory != undefined && selectedEle.prodCategory.toUpperCase() === this.label.WeatherGuard.toUpperCase()) || 
                (this.isRebooking == true && productRequiredData !== undefined && productRequiredData.isConsumed != null && productRequiredData.isConsumed == true)){
                productFirstApp.isChecked = true;
                productFirstApp.productEnable = true;
            }else{
                productFirstApp.isChecked = false;
                productFirstApp.productEnable = false;
            }

            jsonAppointment.productAvailibilities[0].products.push(productFirstApp);
        });
        
        this.productDataList[rowIndex].appointments.push(jsonAppointment);
        
        /*for(var earliestIns of this.earliestDataDetail) {
                if(earliestIns.locationId == this.productDataList[rowIndex].serviceLocationId) {
                    if(earliestIns.earliestDate) {
                        this.productDataList[rowIndex].earlierAvailabilityPrepDateTime = earliestIns.earliestDate;
                        this.productDataList[rowIndex].earlierAvailabilityDateHeader = earliestIns.earliestDate;
                } else {
                    this.productDataList[rowIndex].earlierAvailabilityPrepDateTime = earliestIns.stockEarliestDate;
                    }
                    if(earliestIns.appointmentId) {
                        this.productDataList[rowIndex].earlierAvailabilityAppointmentId = earliestIns.appointmentId;
                    }
                if(earliestIns.stockLocationId) {
                    this.productDataList[rowIndex].earlierAvailabilityStockLocation = earliestIns.stockLocationId;
                    }
                }
        }*/
        this.calculateAppointmentHeaderDates();
    }
    
    /* This method is used for set value on event which event is used for scheduleAppointmentContainer */
    @api
    setDataScheduleAppointment() {
        const sendProdData = new CustomEvent('selectionappointmentcontainer', {
            detail: this.productDataList
        });
        this.dispatchEvent(sendProdData);
    }

    /*methdod calculates max date*/
    maxDateCalculation(arrayDate) {
        return arrayDate.reduce((max, obj) => (new Date(obj.date) > new Date(max.date)) ? obj : max);
    }

    /* Method is call when product checkbox check or uncheck */
    onchangebox(event) {
        let rowindex = parseInt(event.currentTarget.dataset.rowindex);
        let appointmentindex = parseInt(event.currentTarget.dataset.appointmentindex);
        let prodindex = parseInt(event.currentTarget.dataset.prodindex);

        for (let h = 0; h < this.productDataList.length; h++) {
            for (let i = 0; i < this.productDataList[h].appointments.length; i++) {
                if( rowindex == h && appointmentindex == i ){
                    this.productDataList[h].appointments[i].slotSelectedDate = '';
                    this.productDataList[h].appointments[i].productAvailibilities[0].products[prodindex].productEnable = true;
                }else if( this.productDataList[h].appointments[i].productAvailibilities[0].products[prodindex].productEnable ){
                    this.productDataList[h].appointments[i].productAvailibilities[0].products[prodindex].productEnable = false;
                }
            }
        }
        this.productDataList[rowindex].appointments[appointmentindex].productAvailibilities[0].products[prodindex].productEnable = true;
        this.calculateAppointmentHeaderDates();
    }

    /* Method is calling when remove the appointment */
    handleRemoveAppointment(event) {
        
        //add check for existing SA and isRebook then show popup reason-subreason
        if(this.isRebooking == true && this.productDataList[event.currentTarget.dataset.servicelocindex].appointments[event.currentTarget.dataset.appointmentcolumn].isExistingAppointment) { // != null && this.productDataList[event.currentTarget.dataset.servicelocindex].appointments[event.currentTarget.dataset.appointmentcolumn].schedStartTime != undefined && this.productDataList[event.currentTarget.dataset.servicelocindex].appointments[event.currentTarget.dataset.appointmentcolumn].schedStartTime != '' ) { //&& (this.productDataList[event.currentTarget.dataset.servicelocindex].Appointments[event.currentTarget.dataset.appointmentcolumn].slotSelectedDate == '' || this.productDataList[event.currentTarget.dataset.servicelocindex].Appointments[event.currentTarget.dataset.appointmentcolumn].slotSelectedDate == null || this.productDataList[event.currentTarget.dataset.servicelocindex].Appointments[event.currentTarget.dataset.appointmentcolumn].slotSelectedDate == undefined
            this.oldSAOfRemovedAppointment = this.productDataList[event.currentTarget.dataset.servicelocindex].appointments[event.currentTarget.dataset.appointmentcolumn].serviceAppointmentId;
            this.oldSAIndex = event.currentTarget.dataset.servicelocindex;
            this.oldAppIndex = event.currentTarget.dataset.appointmentcolumn;
            // this.productDataList[event.currentTarget.dataset.servicelocindex].appointments.splice(event.currentTarget.dataset.appointmentcolumn, 1);
            // for (let j = 0; j < this.productDataList[event.currentTarget.dataset.servicelocindex].appointments.length; j++) {
            //     this.productDataList[event.currentTarget.dataset.servicelocindex].appointments[j].appointmentName = 'Appointment ' + parseInt(j + 1);
            // }
            this.isCancellChange  = true;
            this.isRebookingRequestModel = true;
    
        } else if(this.isRebooking == true && this.productDataList[event.currentTarget.dataset.servicelocindex].appointments[event.currentTarget.dataset.appointmentcolumn].slotSelectedDate != null && this.productDataList[event.currentTarget.dataset.servicelocindex].appointments[event.currentTarget.dataset.appointmentcolumn].slotSelectedDate != undefined && this.productDataList[event.currentTarget.dataset.servicelocindex].appointments[event.currentTarget.dataset.appointmentcolumn].slotSelectedDate != '' )
        {
            this.isCancellChange  = false;
            this.isRebookingRequestModel = false;
            this.oldSAOfDeletedAppointment = this.productDataList[event.currentTarget.dataset.servicelocindex].appointments[event.currentTarget.dataset.appointmentcolumn].serviceAppointmentId;
            this.productDataList[event.currentTarget.dataset.servicelocindex].appointments.splice(event.currentTarget.dataset.appointmentcolumn, 1);
            for (let j = 0; j < this.productDataList[event.currentTarget.dataset.servicelocindex].appointments.length; j++) {
                
                this.productDataList[event.currentTarget.dataset.servicelocindex].appointments[j].appointmentName = 'Appointment ' + parseInt(j + 1);
            }
            
            this.rebookSAList[0].rebookDetails.push({
                "saId": this.oldSAOfDeletedAppointment,
                "action":'Delete'
            });
    
        }else {
            this.isCancellChange  = false;
            this.isRebookingRequestModel = false;

            this.productDataList[event.currentTarget.dataset.servicelocindex].appointments.splice(event.currentTarget.dataset.appointmentcolumn, 1);
            for (let j = 0; j < this.productDataList[event.currentTarget.dataset.servicelocindex].appointments.length; j++) {
            this.productDataList[event.currentTarget.dataset.servicelocindex].appointments[j].appointmentName = 'Appointment ' + parseInt(j + 1);
            }   
        }
        this.calculateAppointmentHeaderDates();
    }

/*This method is used to save Re-book reason and subreason FOUK-6281*/
handleRebookReason(event){
        this.rebookReasonValue = event.detail.rebookReasonValue;
        this.rebookSubReasonOptionValue = event.detail.rebookSubReasonOptionValue;
        if(this.rebookReasonValue != '' && this.rebookSubReasonOptionValue != '' && this.oldSAIndex != '' && this.oldAppIndex != ''){
            this.productDataList[this.oldSAIndex].appointments.splice(this.oldAppIndex, 1);
            for (let j = 0; j < this.productDataList[this.oldSAIndex].appointments.length; j++) {
                this.productDataList[this.oldSAIndex].appointments[j].appointmentName = 'Appointment ' + parseInt(j + 1);
            }
        }
        this.isCancellChange  = false;
        this.oldSAIndex = '';
        this.oldAppIndex = '';
            this.rebookSAList[0].caseId = this.rebookSAList.length > 0 && this.rebookSAList[0].caseId == undefined ? this.caseId : this.rebookSAList[0].caseId;
            this.rebookSAList[0].rebookDetails.push({
        "oldSAId": this.oldSAOfRemovedAppointment,
        "cancellationReason":this.rebookReasonValue,
        "subReason":this.rebookSubReasonOptionValue,
        "action":'Cancel'
            });
}

//PopUp
async calculateBuffer() {
    
        try {
            const result = await bufferCalculationMethod({ caseId: this.caseId });
            if(result != null && result != undefined && result!= ''){
                this.buffer = result;
                if (this.buffer > 0) {
                    this.showBufferSection = true;
                    this.showToastMessage();
                }
            }
    } catch (error) {
        console.error('Error calculating buffer:', error);
        }
    }

showToastMessage() {
    const event = new ShowToastEvent({
            //title: `Buffer Applied - ${this.buffer} Days`,
            title: `Earliest available appointment is shown based on provisional/quality criteria.`,
        variant: 'info',
        mode: 'sticky'
    });
    this.dispatchEvent(event);
}

handleClose(){
    this.showBufferSection = false;
}

/*Re-booking FOUK-6281*/
onCloseRebook(){
    this.isCancellChange  = false;
}

    /*This method will call fsl method to create SA and according to result shows branch slot/mobile slot */
    handleSelectSlot(event) {
        this.prepDataList = [];
        var selectedSlotApp = [];
        this.showSelectSlotPopUp = false;
        this.oldAppointmentId = '';
        this.selectedAppointmentRow = event.currentTarget.dataset.rowindex;
        selectedSlotApp = this.productDataList[event.currentTarget.dataset.rowindex].appointments[event.currentTarget.dataset.columnindex];
            this.showSpinner = true;
            this.isMobileLocation = this.locationList.find(option => option.locationGUID === selectedSlotApp.locationId).isMobileLocation;
            selectedSlotApp.productAvailibilities[0].products.forEach(selectedEle => {
                if (selectedEle.productEnable == true) {
                    if( !selectedEle.bundleName ){
                        this.prepDataList.push({
                            "productCode": selectedEle.productCode,
                            "quantity": selectedEle.quantity,
                            "productOLIKey": selectedEle.productCode+'_'+selectedEle.bomId+'_'+selectedEle.bundleName
                        });
                    }

                    if( selectedEle.bundleName || selectedEle.bomId ){
                        let mathchingChildProducts = this.addOnProductList.filter(productName=>(((selectedEle.bomId == productName.bomId || (!selectedEle.bomId && !productName.bomId)) && 
                                                                                                (selectedEle.bundleName == productName.bundleName || (!selectedEle.bundleName && !productName.bundleName)))));
                        mathchingChildProducts.forEach(selectedChildEle => {
                            this.prepDataList.push({
                                "productCode": selectedChildEle.productCode,
                                "quantity": selectedChildEle.quantity,
                                "productOLIKey": selectedChildEle.productCode+'_'+selectedChildEle.bomId+'_'+selectedChildEle.bundleName
                            });
                        });
                    }
                }
            });
            var dateString;
            if(selectedSlotApp && (selectedSlotApp.earlierAvailabilityPrepDateTime || selectedSlotApp.earlierAvailabilityStockEarliestDate)) {
                var date = new Date(selectedSlotApp.earlierAvailabilityPrepDateTime ? selectedSlotApp.earlierAvailabilityPrepDateTime : selectedSlotApp.earlierAvailabilityStockEarliestDate);
                dateString = new Date(new Date(date.getTime() - (date.getTimezoneOffset() * 60000))).toISOString();
            } else {
                dateString = new Date().toISOString();
            }

        createAppoitment({
            productList : this.prepDataList,
            caseId : this.caseId,
            earliestAvailableDate : dateString,
            locationId : this.productDataList[event.currentTarget.dataset.rowindex].serviceLocationId
            }).then(result => {
                if (result.isSuceess != false && (result.appointmentId != null || result.appointmentId != '' || result.appointmentId != 'undefined')) {
                            
                            /*Re-booking 6281 code*/
                            if (this.isRebooking == true && selectedSlotApp.serviceAppointmentId != '') {
                                this.oldAppointmentId = selectedSlotApp.serviceAppointmentId;
                                this.oldSlotDetails = selectedSlotApp.slotSelectedDate;
                            }
                            /*Re-booking code End */
                            this.appointmentId = result.appointmentId;
                            this.appointmentIdList.push(result.appointmentId);
                            this.showSpinner = false;
                            this.showSelectSlotPopUp = true;
                            this.selectSlotAppointment = selectedSlotApp;
                        }
                else {
                    this.showSelectSlotPopUp = false;
                    this.showSpinner = false;
                    LightningAlert.open({
                        message: result.msg,
                            theme: 'error',
                            label: ErrorTitle
                        });
                    }
                }).catch(error => {
                    this.showSelectSlotPopUp = false;
                    this.showSpinner = false;

                    LightningAlert.open({
                        message: SACreationError,
                        theme: 'error',
                        label: ErrorTitle
                    });
            });
    }

    /* Display the slot popup when click on select slot */
    handleSelectSlotClose() {
        this.showSelectSlotPopUp = false;
    }

    /* Method is used for appointment */
    handleSelectData(event) {

        this.productDataList[this.selectedAppointmentRow].appointments.forEach(ele => {
            if (ele.keyIndex == this.selectSlotAppointment.keyIndex) {
                const { date, slot, isDropOff, startDate, endDate , rebookReasonValue,rebookSubReasonOptionValue , isForceAppointment} = event.detail;
                ele.slotSelectedDate = ` ${date}  ${slot}`;
                ele.serviceAppointmentId = this.appointmentId;
                ele.isDropOff = `${isDropOff}`;
                ele.slotDateTimeStart = `${startDate}`;
                ele.slotDateTimeFinish = `${endDate}`;
                ele.isForceAppointment = `${isForceAppointment}`;
                if(this.isRebooking == true && this.oldAppointmentId!=null && this.oldAppointmentId!='' && this.oldAppointmentId!=undefined){
                    this.isForceappointmentResult = `${isForceAppointment}`;
                    this.rebookSAList[0].rebookDetails.push({
                        "saId": this.appointmentId,
                        "oldSAId": this.oldAppointmentId,
                        "slotStart":`${startDate}`,
                        "slotFinish": `${endDate}`,
                        "isDropOff":`${isDropOff}`,
                        "action":'New',
                        "isForceAppointment":`${isForceAppointment}`
                    });
                    /*check oldAppointmentId is not blank*/
                    this.rebookSAList[0].rebookDetails.push({
                        "oldSAId": this.oldAppointmentId,
                        "cancellationReason":`${rebookReasonValue}`,
                        "subReason":`${rebookSubReasonOptionValue}`,
                        "action":'Cancel'
                    });
                    
                }
                else if(this.isRebooking == true) {
                    this.isForceappointmentResult = `${isForceAppointment}`;
                    this.rebookSAList[0].rebookDetails.push({
                        "saId": this.appointmentId,
                        "slotStart":`${startDate}`,
                        "slotFinish": `${endDate}`,
                        "isDropOff":`${isDropOff}`,
                        "action":'New',
                        "isForceAppointment":`${isForceAppointment}`
                    });
                }
                }
            
                /*Re-book json to pass 3rd screen END*/
                this.showSelectSlotPopUp = false;
        });
        this.productDataList = [...this.productDataList];
        this.sendProductData();
    }

    //method for send data from screen 2 to screen 3
    @api sendProductData(){
        const sendProdData = new CustomEvent( 'receivescreenthree',{
                detail : {
                    productList : this.productDataList,
                appoitmentId: this.appointmentId,
                appIdList : this.appointmentIdList,
                setProductDataList: this.setProductDataList,
                rebookSaList: this.rebookSAList
            }
            })
        this.dispatchEvent(sendProdData);
    }
	
    /* This is used for onload rebook  */
	earliestAppointmentDataWrapSAHandler(event) {
        if(event.detail && event.detail.locationId) {
        this.earliestHeaderDatePopulate(event.detail);
        this.dispatchEvent(new CustomEvent('earliestappointmentcontainerdatawrap',{
            detail:event.detail
        }));
    }
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