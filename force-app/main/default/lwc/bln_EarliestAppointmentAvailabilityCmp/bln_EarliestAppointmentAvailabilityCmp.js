import { LightningElement,api,track,wire } from 'lwc';
import prepData from '@salesforce/apex/BLN_AppointmentCreateUpdate.prepData'
import getBranchSlots from '@salesforce/apex/BLN_AppointmentCreateUpdate.getBranchSlots';
import getMobileSlots from '@salesforce/apex/BLN_AppointmentCreateUpdate.getMobileSlots';
import updateAppointment from '@salesforce/apex/BLN_AppointmentCreateUpdate.updateAppointment';
import getAppointmentExcludedProductCodes from '@salesforce/apex/BLN_ProductIdentifierUtility.getAppointmentExcludedProductCodes';

import noSlotsErrorMsg from '@salesforce/label/c.BLN_NoSlotsAvailable';
import errorOccurredMsg from '@salesforce/label/c.BLN_ErrorOccur';
import error from '@salesforce/label/c.BLN_ErrorTitle';
import noSlots from '@salesforce/label/c.BLN_NoSlots';



export default class Bln_EarliestAppointmentAvailabilityCmp extends LightningElement {
    
    @api wrapIndex;

    @api caseId; // ip
    @api earliestDate; //op
    @api earliestDateList; //ip
    @api appointmentId; //ip/op
    @api currentPayload; //ip/op
    @api location; // ip
    @api selectedProductList;
    @api addOnProductList;
    @api hiddenProductList;
    @api isRebooking;
    
    stockEarliestDateString = new Date();
    excludeProductCodeList = [];
    earliestData = [];
    earliestDate_formatted
    showErrorText = false;
    showNoSlotsText = false;
    showLoading = true;

    earliestAvailabilityForStock;
    doNotIncludeProductCodeList = [];
    prepDataList = [];
        

    label = {
        error,
        noSlots,
        errorOccurredMsg,
        noSlotsErrorMsg
    };

    connectedCallback(){
        this.earliestData = [];
        this.showLoading = true;
        if(this.wrapIndex == 0){
            if(this.appointmentId && this.earliestDate){
                this.earliestDate_formatted = this.formatDate(new Date(this.earliestDate));
                this.noError();
            }
            else if(this.appointmentId){
                this.prepDataCreateForStock(false);
                this.retrieveSlots(this.appointmentId);
            }
            else{
                this.calculateEarliestDate(false);
            }
        }
    }

    @api 
    calculateEarliestDate(isFirstInitSuccesParam){
        this.prepDataCreateForStock(isFirstInitSuccesParam);
        if(this.earliestAvailabilityForStock){
            this.createPerpDataList(this.currentPayload);
        }
    }

    prepDataCreateForStock (isFirstInitSuccesParam){
        this.isFirstInitSucces = isFirstInitSuccesParam;
        this.earliestDateList = this.objConvert(this.earliestDateList);
        this.location = this.objConvert(this.location);
        this.currentPayload = JSON.parse(this.currentPayload);
        
        // calculate availability dates of each stock location of the selected products 
        let stockLocIdVsAvailDate = new Map();
        this.earliestDateList.forEach(prod => {
            if(prod.quoteId == this.location.quoteId){
                if(prod.isSelected == true ){ //&& prod.earliestDateList.length > 0
                    prod.earliestDateList.forEach(earlyDate => {
                        if(stockLocIdVsAvailDate.has(earlyDate.stockLocationId)){
                            (stockLocIdVsAvailDate.get(earlyDate.stockLocationId)).push(earlyDate);
                        }
                        else{
                            stockLocIdVsAvailDate.set(earlyDate.stockLocationId,[earlyDate]);
                        }
                    })
                }
            }
        });

        // calculate the earliest date of each stock location
        let stockListVsEarlyDate = new Map();
        stockLocIdVsAvailDate.forEach((dateList,stockId) => {
            let dateVar = dateList[0];
            let stockLocId = dateList[0].stockLocationId;
            dateList.forEach(earlyDate => {
                let dt = new Date(earlyDate.availableFromDate);
                let dateVardt = new Date(dateVar.availableFromDate);

                if(dateVardt > dt){
                    dateVar = dateVar;
                    stockLocId = dateVar.stockLocationId;
                }
                else{
                    dateVar = earlyDate;
                    stockLocId = earlyDate.stockLocationId;
                }                
            });
            stockListVsEarlyDate.set(stockLocId, dateVar); 
            //stockListVsEarlyDate.push(dateVar);
        });

        // calculate the earliest date and location from where stock will be sent
        stockListVsEarlyDate.forEach((earliestDt,stockId) => {
            console.log('dateList',earliestDt);
            if(!this.earliestAvailabilityForStock){
                this.earliestAvailabilityForStock = earliestDt;
            }

            let dt = new Date(this.earliestAvailabilityForStock.availableFromDate);
            let dateVardt = new Date(earliestDt.availableFromDate);

            this.earliestAvailabilityForStock = dt < dateVardt ? this.earliestAvailabilityForStock : earliestDt;
        });

        if(!this.earliestAvailabilityForStock){
            this.earliestAvailabilityForStock = {
                availableFromDate : new Date(),
                isOutOfStock : false,
                stockLocationId : ''
            }
        }
    }

    createPerpDataList(payload){
        getAppointmentExcludedProductCodes()
        .then(codeList => {
            this.doNotIncludeProductCodeList = codeList;

            this.createPerpDataListResult(payload);
        })
        .catch(error => {
            this.doNotIncludeProductCodeList = [];
            this.createPerpDataListResult(payload);
        });
    }

    createPerpDataListResult(payload){
        this.prepDataList = [];
        for(let quote of payload.quotes){
            if(quote.quoteId == this.location.quoteId){
                for(let lineItem of quote.lineItems){
                    if(lineItem.selectProduct == true){
                        let mdmId = lineItem.partNumber == null && lineItem.bundleName != null ? 'bundle' : lineItem.partNumber == null ? 'null' : lineItem.partNumber;
                        let bomId = lineItem.parentBOMId == null ? 'null' : lineItem.parentBOMId;
                        let bundleName = lineItem.bundleName == null ? 'null' : lineItem.bundleName;
                        if(!this.doNotIncludeProductCodeList.includes(lineItem.belronPartNumber)){
                            this.prepDataList.push({
                                "productCode": mdmId,
                                "quantity": lineItem.quantity,
                                "productOLIKey": mdmId+'_'+bomId+'_'+bundleName
                            });
                        }
                    }
                }
            }
        }

        if(this.prepDataList.length > 0){
            this.findFirstAvailabilityDate(this.prepDataList);
        }
    }


    findFirstAvailabilityDate(prepDataList){
        // call to ProductAvailabilityLocations 
        this.dispatchEvent(new CustomEvent('appointmentdata',{
            detail:{
                type: "appointmentInfo",
                earliestDate: '',
                appointmentId : '',
                locationId: this.location.locationGUID,
                showOutofStockBanner: this.earliestAvailabilityForStock && this.earliestAvailabilityForStock.isOutOfStock ? true : false,
                stockEarliestDate : this.earliestAvailabilityForStock.availableFromDate,
                stockLocationId: this.earliestAvailabilityForStock.stockLocationId
            }
        }));

        let earliestDateString = this.stockEarliestDateString =  new Date(new Date(this.earliestAvailabilityForStock.availableFromDate).getTime() - (new Date(this.earliestAvailabilityForStock.availableFromDate).getTimezoneOffset() * 60000)).toISOString();
        
        prepData({
            productList: prepDataList,
            caseId: this.caseId,
            earliestAvailableDate: earliestDateString,
            locationId: this.location.locationGUID
        })
        .then(appointment => {
            if(appointment.isSuceess){
                this.noError();

                if( !this.isFirstInitSucces ){
                    this.dispatchEvent(new CustomEvent('appointmentdata',{
                        detail:{
                            type: "prepSuccess"
                        }
                    }));
                }
                this.retrieveSlots(appointment.appointmentId);
                
            }
            else{

                this.captureErrorMsg(appointment.msg);

                this.dispatchEvent(new CustomEvent('appointmentdata',{
                    detail:{
                        type: "prepError",
                        stockEarliestDate: this.stockEarliestDateString
                    }
                }));

                this.showError();
            }
        })
        .catch(err => {

            this.captureErrorMsg(this.label.errorOccurredMsg);

            this.dispatchEvent(new CustomEvent('appointmentdata',{
                detail:{
                    type: "prepError",
                    stockEarliestDate: this.stockEarliestDateString
                }
            }));
            this.showError();
        });
    }

    retrieveSlots(serviceAppointmentId){
        let slotList = [];
        let isDropOff = false;
        let earliestSlotDate ;
        if(!this.location.isMobileLocation){
            getBranchSlots({
                appointmentId: serviceAppointmentId
            })
            .then(slots => {
                if(slots.isSuceess){
                    if(slots.waitingSlots.length > 0){
                        
                        slotList = slots.waitingSlots;
                        isDropOff = false;
                        this.earliestDate = earliestSlotDate = slotList[0].startTime;
                        if(this.earliestDate){
                            this.earliestDate_formatted = this.formatDate(new Date(this.earliestDate));
                        }

                        this.noError();

                    }
                    else if(slots.dropOffSlots.length > 0){
                        slotList = slots.dropOffSlots;
                        isDropOff = true;
                        this.earliestDate = earliestSlotDate = slotList[0].startTime;
                        if(this.earliestDate){
                            this.earliestDate_formatted = this.formatDate(new Date(this.earliestDate));
                        }

                        this.noError();
                    }
                    else{
                        this.showNoSlots();
                    }    
                }
                else{
                    this.showNoSlots();
                }
                this.dispatchEarliestDetails('appointmentInfo',earliestSlotDate,serviceAppointmentId,this.location.locationGUID,this.earliestAvailabilityForStock && this.earliestAvailabilityForStock.isOutOfStock ? true : false,this.stockEarliestDateString, this.earliestAvailabilityForStock.stockLocationId);
            })
            .catch(err => {
                this.captureErrorMsg(this.label.errorOccurredMsg);
                this.showError();
                this.dispatchEarliestDetails('appointmentInfo',earliestSlotDate,serviceAppointmentId,this.location.locationGUID,this.earliestAvailabilityForStock && this.earliestAvailabilityForStock.isOutOfStock ? true : false,this.stockEarliestDateString, this.earliestAvailabilityForStock.stockLocationId);

            })
        }
        else{
            getMobileSlots({
                appointmentId: serviceAppointmentId
            })
            .then(slots => {
                if(slots.length > 0){
                    if(slots[0].isSuceess){
                        if(slots[0].msg == this.label.noSlotsErrorMsg){
                            this.showNoSlots();
                        }
                        else{
                            this.earliestDate = earliestSlotDate = slots[0].slotDate;
                            if(this.earliestDate){
                                this.earliestDate_formatted = this.formatDate(new Date(this.earliestDate));
                            }

                            this.noError();
                        }
                    }
                    else if(slots[0].msg == this.label.noSlotsErrorMsg){
                        this.showNoSlots();
                    }
                    else{
                        this.showNoSlots();
                    }
                }
                else{
                    this.showNoSlots();
                }
                this.dispatchEarliestDetails('appointmentInfo',earliestSlotDate,serviceAppointmentId,this.location.locationGUID,this.earliestAvailabilityForStock && this.earliestAvailabilityForStock.isOutOfStock ? true : false,this.stockEarliestDateString, this.earliestAvailabilityForStock.stockLocationId);
            })
            .catch(err => {
                this.captureErrorMsg(this.label.errorOccurredMsg);
                this.showError();
                this.dispatchEarliestDetails('appointmentInfo',earliestSlotDate,serviceAppointmentId,this.location.locationGUID,this.earliestAvailabilityForStock && this.earliestAvailabilityForStock.isOutOfStock ? true : false,this.stockEarliestDateString, this.earliestAvailabilityForStock.stockLocationId);
            })
        }
    }

    updateServiceAppointment(servAppointmentId,earliestDateString,isDropOff){
        let updatedServiceAppointmentId;
        updateAppointment({
            appointmentId: servAppointmentId,
            arrivalStartAndEndDate: earliestDateString,
            isDropOff : isDropOff    
        })
        .then(appointment => {
            this.noError();
            this.retrieveSlots(appointment);
        })
        .catch(err => {
            this.showError();
            console.log('err',err);
        })

        return updatedServiceAppointmentId;
    }

    /* Earliest Availability data custom event to pass parameter to location cmp  */

    dispatchEarliestDetails(type, earliestDate, serviceAppointmentId, locationGUID, isOutOfStock, stockEarliestDate, stockLocationId){

        this.dispatchEvent(new CustomEvent('appointmentdata',{
            detail:{
                type: type, 
                earliestDate: earliestDate ? earliestDate : '',
                appointmentId: serviceAppointmentId ? serviceAppointmentId : '',
                locationId: locationGUID,
                showOutofStockBanner: isOutOfStock, 
                stockEarliestDate: stockEarliestDate,
                stockLocationId: stockLocationId 
            }
        }));
    }    

    formatDate(dateObject) {
        const day = dateObject.getDate();
        const dayWithSuffix = this.addSuffixToDay(day);
        const formattedDate = new Intl.DateTimeFormat('en-US', {
            year: 'numeric',
            month: 'long',
            day: 'numeric'
        }).format(dateObject);
        return formattedDate.replace(String(day), dayWithSuffix);
    }

    addSuffixToDay(day) {
        if (day >= 11 && day <= 13) {
            return day + 'th';
        }
        switch (day % 10) {
            case 1:
                return day + 'st';
            case 2:
                return day + 'nd';
            case 3:
                return day + 'rd';
            default:
                return day + 'th';
        }
    }


    captureErrorMsg(msg){
        this.errorMsg = msg;
    }

    noError(){
        this.showLoading = false;
        this.showErrorText = false;
        this.showNoSlotsText = false;
    }

    showError(){
        this.showLoading = false;
        this.showErrorText = true;
        this.showNoSlotsText = false;
        
    }

    showNoSlots(){
        this.showLoading = false;
        this.showErrorText = false;
        this.showNoSlotsText = true;
    }

    objConvert(str){
        return JSON.parse(JSON.stringify(str));
    }
}