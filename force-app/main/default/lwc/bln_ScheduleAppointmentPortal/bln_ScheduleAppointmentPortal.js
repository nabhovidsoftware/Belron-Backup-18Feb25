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
//import updateSADueDate from '@salesforce/apex/BLN_ProductIdentifierUtility.updateAppointment'
// import getBranchSlots from '@salesforce/apex/BLN_AppointmentCreateUpdate.getBranchSlots'
// import getMobileSlots from '@salesforce/apex/BLN_AppointmentCreateUpdate.getMobileSlots'
import LightningAlert from 'lightning/alert';

import { CurrentPageReference } from 'lightning/navigation';


export default class Bln_ScheduleAppointmentPortal extends LightningElement {
    
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

    showSpinner = false;
    @track screen3childMap = {};
    
    isDisableSelectSlot = false;
    @track selectedAppointmentName;
    @api liabilityList = [];
    @api newshedule;
    @api portalstatus;
    @api selectedValue = '';
    
    @api locationList = [];
    @api selectedLocation = [];
    @api addOnProductList = [];
    @api setProductDataList = [];
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
    
    @api
repairProducts    =
[];    
@api    mobileRepairProduct;
    @api branchRepairProduct;
    @api locationForReapirSort = [];
    
    showSelectSlotPopUp = false;
    selectSlotAppointment;
    selectedData = '';
    @api selectedLocationOptions = [];
    isAddLocationDisabled = true;
    @api quoteLocationData;
    
    isDisableSelectSlot = false;
    appointmentAddLimit = 0;
    @track selectedAppointmentName;
    
    
    
    
    quoteLocation = '';

    
    
    showSelectSlotPopUp = false;
    selectSlotAppointment;
    selectedAppointmentRow;
    selectedData = '';
    appointmentId = '';
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

    @track rebookSAList = [{
        "caseId": this.caseId,
        "rebookDetails": []
    }];
    get shouldRenderDiv() {
        // Example condition based on portalstatus1 and portalstatus2
        return (this.portalstatus || this.newshedule);
    }

    /* This is onload method which is execute onload component */
    async connectedCallback() {
  for (let i = 0; i < this.repairProducts.length; i++) {
            if(this.repairProducts[i].branchOnlyMobileOnly == 'MobileOnlyProduct') {
                this.mobileRepairProduct = this.repairProducts[i];
            } else if(this.repairProducts[i].branchOnlyMobileOnly == 'BranchOnlyProduct') {
                this.branchRepairProduct = this.repairProducts[i];
            } 
        }
        this.isChangeProduct = this.isChangeProduct == null || this.isChangeProduct == undefined || this.isChangeProduct == '' ? false : true;
        //await this.calculateBuffer();
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
        console.log('JSON.stringify(this.setProductDataList) child ',JSON.stringify(this.setProductDataList))

        if(this.isChangeProduct == true) {
            for (let i = 0; i < this.productDataListRebook.length; i++) {
                for(let j = 0; j < this.productDataListRebook[i].appointments.length; j++){
                    if(!this.productDataList[i].appointments.isMobileLocation && this.productDataListRebook[i].appointments[j].productCode != this.branchRepairProduct.productCode) {
                        if( this.productDataList[i].appointments.length-1 < j ){
                        let productsDL = JSON.parse(JSON.stringify(this.productDataList[i].appointments[0].productAvailibilities[0].products));
                        
                        this.productDataList[i].appointments.push(JSON.parse(JSON.stringify(this.productDataListRebook[i].appointments[j])));
                        this.productDataList[i].appointments[j].productAvailibilities[0].products = productsDL;
                    }

                    this.productDataList[i].appointments[j].isFirstAppointment =  this.productDataListRebook[i].appointments[j].isFirstAppointment
                    this.productDataList[i].appointments[j].appointmentName =  this.productDataListRebook[i].appointments[j].appointmentName
                    this.productDataList[i].appointments[j].keyIndex =  this.productDataListRebook[i].appointments[j].keyIndex
                    this.productDataList[i].appointments[j].locationId =  this.productDataListRebook[i].appointments[j].locationId
                    this.productDataList[i].appointments[j].locationName =  this.productDataListRebook[i].appointments[j].locationName
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
}
        this.quoteId = this.selectedLocation.quoteId;
        this.quoteLocation = this.selectedLocation.quotelocation;

        this.productDataList = JSON.parse(JSON.stringify(this.productDataList));
        console.log('product productDataList: ',JSON.stringify(this.productDataList))
        this.earliestAvailabilityDates = JSON.parse(JSON.stringify(this.earliestDateList));
        this.calculateAppointmentHeaderDates();
        
        
        console.log('product productDataList list in child : ',JSON.stringify(this.productDataList))
        
    }

    calculateAppointmentHeaderDates() {
        this.productDataList.forEach(prodEle => {
            prodEle.appointments.forEach(eleApp => {
                console.log('--appointments-',eleApp);
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
                console.log('-availabilityList-',availabilityList);
                if( hasEnabledProducts ){ 
                    if( availabilityList.length > 0 ){
                        console.log('availabilityList==',availabilityList);
                        for (let availableAtLocation of availabilityList[0] ) {
                            let locationId = availableAtLocation.stockLocationId;
                            console.log('---locationId---',locationId);
                            locationAvailibility = new Date(availableAtLocation.availableFromDate);
                            for( let availabilityObjList of availabilityList ){
                                for( let availabilityObj of availabilityObjList ){
                                    console.log(locationId,'---Something--outofstock-',availabilityObj.stockLocationId);
                                    console.log(locationAvailibility,'---locationAvailibility--outofstock-',new Date(availabilityObj.availableFromDate));
                                    if( locationId == availabilityObj.stockLocationId && locationAvailibility <= new Date(availabilityObj.availableFromDate) ){
                                        locationAvailibility = new Date(availabilityObj.availableFromDate);
                                    }
                                }
                            }
                            earliestStockLocation = !earliestDate? locationId: (locationAvailibility<earliestDate?locationId:earliestStockLocation);
                            
                            console.log(locationId,'---earliestStockLocation-',earliestStockLocation);
                            earliestDate = !earliestDate? locationAvailibility: (locationAvailibility<earliestDate?locationAvailibility:earliestDate);
                            console.log('locationAvailibility ', JSON.stringify(locationAvailibility));
                        }
                    }else{
                        console.log('Buffer Test', this.buffer);
                        //this handles service and charge products
                        let availDetail  = {};
                        availDetail.stockLocationId = prodEle.serviceLocationId;
                        console.log('---availDetail.stockLocationId-',availDetail.stockLocationId);
                        availDetail.isOutOfStock = false;
                        let finalDate1 = new Date(this.convertDate(new Date()));
                        availDetail.availableFromDate = this.convertDate(new Date(new Date().getTime())) //(parseInt(this.buffer)*24*60*60*1000)
                        earliestDate =  new Date(new Date().getTime()); //(parseInt(this.buffer)*24*60*60*1000)
                        earliestStockLocation = prodEle.serviceLocationId;
                        locationAvailibility = this.convertDate(new Date(new Date().getTime()+(parseInt(this.buffer)*24*60*60*1000)));
                    }
                    console.log('earliestDate ACC', earliestDate);
                    console.log('earliestDate Converted', this.convertDate(earliestDate));
                    eleApp.earlierAvailabilityPrepDateTime = this.convertDate(earliestDate);
                    eleApp.earlierAvailabilityDateHeader = earliestDate != null && earliestDate != undefined ? this.convertDate(earliestDate) : this.convertDate(new Date(new Date().getTime())); //(parseInt(this.buffer)*24*60*60*1000)
                    eleApp.earlierAvailabilityStockLocation = earliestStockLocation;
                }else{
                    eleApp.earlierAvailabilityDateHeader = '';
                }
            })
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
 this.handleRepairProductFilter(this.productDataList);
    }

    get productDataList(){
        if(this.productDataList.length > 0 ) console.log('product dat alist in child getter ',JSON.stringify(this.productDataList))
        return null;
    }

    objConvert(obj) {
        return JSON.parse(JSON.stringify(obj));
    }

    getAvailableDate(locationId, selectedEle) {
        let currentProductEarliestDates = [];
        this.earliestDateList.forEach(eachDateSet => {
            if( eachDateSet.locationId == locationId && 
                (eachDateSet.productCode == selectedEle.productCode || (!eachDateSet.productCode && !selectedEle.productCode)) && 
                (eachDateSet.bomId == selectedEle.bomId || (!eachDateSet.bomId && !selectedEle.bomId)) && 
                (eachDateSet.bundleName == selectedEle.bundleName || (!eachDateSet.bundleName && !selectedEle.bundleName)) ) {
                currentProductEarliestDates = eachDateSet.earliestDateList;
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
            "earlierAvailabilityPrepDateTime": "",
                    "slotSelectedDate": "",
                    "serviceAppointmentId": "",
                    "slotDate": "",
                    "slotTime": "",
                    "isDropOff": this.isDropOff,
                    "isForceAppointment":false,
                    "slotDateTimeStart": "",
                    "slotDateTimeFinish": "",
                    "productAvailibilities": [
                        {
                            "products": []
                        }
                    ]
        };

        this.selectedProductList.forEach(selectedEle => {
            let product = {
                "productCode": selectedEle.mdmId,
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
            if( (selectedEle.prodCategory != null && selectedEle.prodCategory != undefined && selectedEle.prodCategory.toUpperCase() === this.label.WeatherGuard.toUpperCase()) || 
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
        if(this.isRebooking == true && this.productDataList[event.currentTarget.dataset.servicelocindex].appointments[event.currentTarget.dataset.appointmentcolumn].schedStartTime != null && this.productDataList[event.currentTarget.dataset.servicelocindex].appointments[event.currentTarget.dataset.appointmentcolumn].schedStartTime != undefined && this.productDataList[event.currentTarget.dataset.servicelocindex].appointments[event.currentTarget.dataset.appointmentcolumn].schedStartTime != '' ) { //&& (this.productDataList[event.currentTarget.dataset.servicelocindex].Appointments[event.currentTarget.dataset.appointmentcolumn].slotSelectedDate == '' || this.productDataList[event.currentTarget.dataset.servicelocindex].Appointments[event.currentTarget.dataset.appointmentcolumn].slotSelectedDate == null || this.productDataList[event.currentTarget.dataset.servicelocindex].Appointments[event.currentTarget.dataset.appointmentcolumn].slotSelectedDate == undefined)
            this.oldSAOfRemovedAppointment = this.productDataList[event.currentTarget.dataset.servicelocindex].appointments[event.currentTarget.dataset.appointmentcolumn].serviceAppointmentId;
            this.oldSAIndex = event.currentTarget.dataset.servicelocindex;
            this.oldAppIndex = event.currentTarget.dataset.appointmentcolumn;
            // this.productDataList[event.currentTarget.dataset.servicelocindex].appointments.splice(event.currentTarget.dataset.appointmentcolumn, 1);
            // for (let j = 0; j < this.productDataList[event.currentTarget.dataset.servicelocindex].appointments.length; j++) {
            //     this.productDataList[event.currentTarget.dataset.servicelocindex].appointments[j].appointmentName = 'Appointment ' + parseInt(j + 1);
            // }
            this.isCancellChange  = true;
            this.isRebookingRequestModel = true;
    
        }else if(this.isRebooking == true && this.productDataList[event.currentTarget.dataset.servicelocindex].appointments[event.currentTarget.dataset.appointmentcolumn].slotSelectedDate != null && this.productDataList[event.currentTarget.dataset.servicelocindex].appointments[event.currentTarget.dataset.appointmentcolumn].slotSelectedDate != undefined && this.productDataList[event.currentTarget.dataset.servicelocindex].appointments[event.currentTarget.dataset.appointmentcolumn].slotSelectedDate != '' )
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

/* This method is used for productdatalist filter for branch & mobile */ 
    handleRepairProductFilter(setProductDataList) {

        var indexRepirIndex = this.locationForReapirSort.length == 0 ? 0 : this.locationForReapirSort.length;
        //let locLocation = []; 
        let locLocation  = this.locationForReapirSort.find(option => option.locationGUID == this.selectedLocation.locationGUID);
        if(locLocation == undefined) {
            let tempLocation = this.locationList.find(option => option.locationGUID === this.selectedLocation.locationGUID);
            this.locationForReapirSort = tempLocation;
            //this.locationForReapirSort[indexRepirIndex].push(this.locationList.find(option => option.locationGUID === this.selectedLocation.locationGUID)[0]);

        }
        console.log('-handleRepairProductFilter setProductDataList--', JSON.stringify(setProductDataList));
        for (let i = 0; i < setProductDataList.length; i++) {
            for(let j = 0; j < setProductDataList[i].appointments.length; j++){
                for(let k = 0; k < setProductDataList[i].appointments[j].productAvailibilities[0].products.length; k++){
                    if(this.mobileRepairProduct != null && this.selectedLocation.isMobileLocation == false &&  this.productDataList[i].appointments[j].productAvailibilities[0].products[k].productCode == this.mobileRepairProduct.productCode) {
                        this.productDataList[i].appointments[j].productAvailibilities[0].products.splice(k, 1);
                    } else if(this.branchRepairProduct != null && this.selectedLocation.isMobileLocation == true &&  this.productDataList[i].appointments[j].productAvailibilities[0].products[k].productCode == this.branchRepairProduct.productCode) {
                        this.productDataList[i].appointments[j].productAvailibilities[0].products.splice(k, 1);
                    }
                }
                for(let j = 0; j < setProductDataList[i].serviceLocationLabel[0].productNames.length; j++){
                    if(this.mobileRepairProduct != null && this.selectedLocation.isMobileLocation == false && setProductDataList[i].serviceLocationLabel[0].productNames[j].productCode == this.mobileRepairProduct.productCode) {
                        console.log('--product Name prkdlf-before-',setProductDataList[i].serviceLocationLabel[0].productNames);
                        this.productDataList[i].serviceLocationLabel[0].productNames.splice(j, 1);
                        console.log('--product Name prkdlf-after-',setProductDataList[i].serviceLocationLabel[0].productNames);
                    } else if(this.branchRepairProduct != null && this.selectedLocation.isMobileLocation == true && setProductDataList[i].serviceLocationLabel[0].productNames[j].productCode == this.branchRepairProduct.productCode) {
                        console.log('--product Name prkdlf scond-before-',setProductDataList[i].serviceLocationLabel[0].productNames);
                        this.productDataList[i].serviceLocationLabel[0].productNames.splice(j, 1);
                        console.log('--product Name prkdlf scond-after-',setProductDataList[i].serviceLocationLabel[0].productNames);
                    }
                }
                for(let j = 0; j < setProductDataList[i].earliestAvailablity[0].productDate.length; j++){
                    if( this.mobileRepairProduct != null && this.selectedLocation.isMobileLocation == false && setProductDataList[i].earliestAvailablity[0].productDate[j].productCode == this.mobileRepairProduct.productCode) {
                        this.productDataList[i].earliestAvailablity[0].productDate.splice(j, 1);
                    } else if( this.branchRepairProduct != null && this.selectedLocation.isMobileLocation == true && setProductDataList[i].earliestAvailablity[0].productDate[j].productCode == this.branchRepairProduct.productCode) {
                        this.productDataList[i].earliestAvailablity[0].productDate.splice(j, 1);
                    }
                }
            }
        }

        console.log('-handleRepairProductFilter productDataList--', JSON.stringify(this.productDataList));
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
     this.rebookSAList[0].rebookDetails.push({
        "oldSAId": this.oldSAOfRemovedAppointment,
        "cancellationReason":this.rebookReasonValue,
        "subReason":this.rebookSubReasonOptionValue,
        "action":'Cancel'
    });
}

//PopUp
// async calculateBuffer() {
     
    //     try {
    //         const result = await bufferCalculationMethod({ caseId: this.caseId });
          
//         if(result != null && result != undefined && result!= '' && this.isRebooking == false){
//             this.buffer = result;
//             console.log('this.buffer', this.buffer);
            
//             if (this.buffer > 0) {
//                 this.showBufferSection = true;
//                 this.showToastMessage();
//             }
//         }
//     } catch (error) {
//         console.error('Error calculating buffer:', error);
    //     }
    // }
    
    showToastMessage() {
        console.log('insideshowToastMessage')
        const event = new ShowToastEvent({
            //title: `Buffer Applied - ${this.buffer} Days`,
            title: `Earliest available appointment is shown based on provisional/quality criteria.`,
       variant: 'info',
        mode: 'sticky'
    });
    this.dispatchEvent(event);
}

handleClose(){
    console.log('inside handleclose');
    this.showBufferSection = false;
}

/*Re-booking FOUK-6281*/

    9979
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
        if (selectedSlotApp.earlierAvailabilityDateHeader != "" && selectedSlotApp.earlierAvailabilityDateHeader != null && selectedSlotApp.earlierAvailabilityDateHeader != 'Invalid Date') {
            this.showSpinner = true;
            this.isMobileLocation = selectedSlotApp.isMobileLocation;
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
            
            var date = new Date(selectedSlotApp.earlierAvailabilityPrepDateTime);
            var dateString = new Date(date.getTime() - (date.getTimezoneOffset() * 60000)).toISOString();
            console.log('dateString',dateString);
            createAppoitment({
                productList: this.prepDataList,
                caseId: this.caseId,
                earliestAvailableDate: dateString,
                locationId: selectedSlotApp.locationId
            }).then(result => {
                console.log('result321 productList',this.productList);
                console.log('result321 caseId',this.caseId);
                console.log('result321 earliestAvailableDate',this.earliestAvailableDate);
                console.log('result321 locationId',this.locationId);
                console.log('result321',JSON.stringify(result));
                    if (result.appointmentId) {

                        if ((result.appointmentId != null || result.appointmentId != '' || result.appointmentId != 'undefined') && result.isSuceess != false) {
                            
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
                     
                            // updateSADueDate({
                            //     appointmentId: this.appointmentId
                            //  }).then(result => {
                            //    console.log('UpdateServiceDueDate',result);
                            //   })
                            // .catch(error => {
                                
                            //   })

                         }
                    } else {
                        this.showSelectSlotPopUp = false;
                        this.showSpinner = false;
                        LightningAlert.open({
                            message: SAError,
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
        } else {
            this.showSelectSlotPopUp = false;
            this.showSpinner = false;
            LightningAlert.open({
                message: EarliestDateError,
                theme: 'error',
                label: ErrorTitle
            });
        }
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
                if(this.isRebooking == true){
                    this.isForceappointmentResult = `${isForceAppointment}`;
                    this.rebookSAList[0].rebookDetails.push({
                        "saId": this.appointmentId,
                        "slotStart":`${startDate}`,
                        "slotFinish": `${endDate}`,
                        "isDropOff":`${isDropOff}`,
                        "action":'New',
                        "isForceAppointment":`${isForceAppointment}`
                    });
                    /*check oldAppointmentId is not blank*/
                    if(this.oldAppointmentId!=null && this.oldAppointmentId!='' && this.oldAppointmentId!=undefined){
                        this.rebookSAList[0].rebookDetails.push({
                            "oldSAId": this.oldAppointmentId,
                            "cancellationReason":`${rebookReasonValue}`,
                            "subReason":`${rebookSubReasonOptionValue}`,
                            "action":'Cancel'
                            });
                    }
                       
                }
                }
               
                /*Re-book json to pass 3rd screen END*/
                this.showSelectSlotPopUp = false;
        });
 this.productDataList = [...this.productDataList];
        this.sendProductData();
    }
    loadpage(){
        const event = new CustomEvent('loadpage1', {
            detail: false // You can pass any detail if needed
        });
        this.dispatchEvent(event);
    }

    //method for send data from screen 2 to screen 3
    @api sendProductData() {
        const sendProdData = new CustomEvent('receivescreenthree', {
            detail: {
                productList: this.productDataList,
                appoitmentId: this.appointmentId,
                appIdList : this.appointmentIdList,
                setProductDataList: this.setProductDataList,
                rebookSaList: this.rebookSAList
            }
        })
        this.dispatchEvent(sendProdData);
    }
}