import { LightningElement,api,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import EarlyAppointment from '@salesforce/label/c.BLN_EarliestAppointmentAvailable';
import Vat from '@salesforce/label/c.BLN_QuoteVAT';
import Total from '@salesforce/label/c.BLN_QuoteTotal';
import excludedMsg from '@salesforce/label/c.BLN_TerritoryProductExclusionError';
import TooltipText from '@salesforce/label/c.BLN_CPTAvailability';
import BufferText from '@salesforce/label/c.BLN_ProductNotInStock';
import BufferPeriod from '@salesforce/label/c.BLN_NoStockBufferPeriod';
import StockableItem from '@salesforce/label/c.BLN_StockableItem';
import Warranty from '@salesforce/label/c.BLN_Warranty';
import checkPermission from '@salesforce/customPermission/BLN_AppointmentOverride';

export default class Bln_ProductAvailableLocations extends LightningElement {
    @api locationData;
    @api isProductSelected = false;
    @api selectedProductList;
    @api addOnProductList;
    @api hiddenProductList;
    @api selectedLocation;
    @api isCashJourney;
    @api earliestDateList;
    @api productList;
    @api subType = '';
    @api locationDisabledPs;
    @api capturedError;
    @api hasCompletedAppointments;
    @api fromCnRFlow;
    @api caseId;
    @api currentPayload;

    mobileProductSelected = false;
    allEarliestDatesList;
    showEarlyAppointment = false;
    allSelectedProductsList;
    @track checkUncheck; 
    @track locationList;
   @track isLocationCss = false;
    @track isExcludedProduct = false;
    checkPermissionName = false;
    @track earliestDetailsAllLocations = [];

    label={
        EarlyAppointment,
        Vat,
        Total,
        TooltipText,
        BufferText,
        BufferPeriod,
        StockableItem,
        Warranty,
        excludedMsg
    }

    
    connectedCallback(){
        if(checkPermission){
            this.checkPermissionName = true;
        }

        this.locationList = JSON.parse(JSON.stringify(this.locationData));
        this.allEarliestDatesList = JSON.parse(JSON.stringify(this.earliestDateList));
        this.allSelectedProductsList = JSON.parse(JSON.stringify(this.selectedProductList));

        if(this.selectedLocation){
            this.selectedLocation = JSON.parse(JSON.stringify(this.selectedLocation));
            this.highlightHandle();
        }
        if(this.fromCnRFlow){
            this.hasCompletedAppointments = false;
            this.selectedLocation = JSON.parse(JSON.stringify(this.locationList[0]));
            this.highlightHandle();
            this.dispatchAllData();
        }

        let needReset = false;
        this.locationList.forEach(loc => {
            let isCPT_Loc_Flag = false;
            this.mobileProductSelected = false;
            
            for(let prod of this.allSelectedProductsList){
                let isCPT_Prod_Flag = false;
                if(prod.isBranchOnlyProduct == true){
                    this.mobileProductSelected = true;
                }

                let currentAvailabilityDetails = this.allEarliestDatesList.find(item =>item.mdmId == prod.mdmId && item.quoteId == loc.quoteId);
                if(currentAvailabilityDetails){
                    for(let earliestDate of currentAvailabilityDetails.earliestDateList){
                        if(earliestDate.isOutOfStock == true){
                            isCPT_Prod_Flag = true;
                            earliestDate.isCPT = true;
                        }else{
                            isCPT_Prod_Flag = false;
                            earliestDate.isCPT = false;
                        }

                        if(isCPT_Prod_Flag){
                            isCPT_Loc_Flag = true;
                        }
                    }
                }
            }

            if(isCPT_Loc_Flag){
                loc.isCPT = true;
                loc.class = loc.class + ' cpt-location ';
            }else{
                loc.isCPT = false;
            }

            if(loc.isMobileLocation == true && this.mobileProductSelected == true && this.checkPermissionName != true && this.subType != 'ISP'){
                loc.locDisabled = true;
                loc.class = loc.class + ' locationDisabled';

                if(this.selectedLocation && loc.locationGUID == this.selectedLocation.locationGUID){
                    needReset = true;
                }
            } 
            else if ( this.hasCompletedAppointments && this.selectedLocation && loc.locationGUID != this.selectedLocation.locationGUID){
                loc.locDisabled = true;
            }
        });
        
        if(!this.isProductSelected){
            this.resetLocationSelection();
        }

        if(needReset){
            this.selectedLocation = null;
            this.dispatchAllData();
        }

        

        this.showEarlyAppointment = false;
        setTimeout(() => {
            this.showEarlyAppointment = true;
        }, 10);

    
    }

    selectLocationValue(event){
        if( !this.hasCompletedAppointments ){
        let disabledLocation = event.currentTarget.dataset.disbledlocation;
        let locationdisabledps = event.currentTarget.dataset.locationdisabledps;
        let currentSelectedLocation = this.locationList.find(element => element.locationGUID == event.currentTarget.dataset.value);
        let excludeLocationParts;
        if((currentSelectedLocation.excludeProduct).includes(';')){
            excludeLocationParts =  currentSelectedLocation.excludeProduct.split(';');
            excludeLocationParts.forEach(ele =>{
            this.selectedProductList.forEach(element =>{
              if(element.productName == ele && element.productName != undefined && element.productName != null){
               this.isExcludedProduct = true;
              }
              else{
                this.isExcludedProduct = false;
              }
            })
         });
        }
        else{
            excludeLocationParts =  currentSelectedLocation.excludeProduct;
            this.selectedProductList.forEach(element =>{
                if(element.productName == excludeLocationParts && element.productName != undefined && element.productName != null){
             this.isExcludedProduct = true;
            }
            else{
                this.isExcludedProduct = false;
              }
          })

        }

        if(this.isExcludedProduct == true){
            this.dispatchEvent(new ShowToastEvent({
                title : 'Error!',
                message : this.label.excludedMsg,
                variant : 'error',
                mode : 'pester'
            }));

            return;
        }

        //ADDED FOR FOUK-6283 END;

        if(disabledLocation == 'true' || locationdisabledps == 'true'){
            return;
        }
        if(this.isProductSelected && this.subType != this.label.Warranty){
            let currentSelectedLocation = this.locationList.find(element => element.locationGUID == event.currentTarget.dataset.value);
            this.selectedLocation = this.selectedLocation && (this.selectedLocation.locationGUID == currentSelectedLocation.locationGUID) ? null : currentSelectedLocation;  
            this.highlightHandle();
            this.dispatchAllData();
        }
        else
          if(this.subType == this.label.Warranty){
            let currentSelectedLocation = this.locationList.find(element => element.locationGUID == event.currentTarget.dataset.value);
            this.selectedLocation = this.selectedLocation && (this.selectedLocation.locationGUID == currentSelectedLocation.locationGUID) ? null : currentSelectedLocation;  
         
            this.highlightHandle();
            this.dispatchAllData();
        }
        else{
            this.dispatchEvent(new ShowToastEvent({
                title : 'Error!',
                message : 'Product not selected',
                variant : 'error',
                mode : 'pester'
            }));
        }
        }

    }

    highlightHandle(){
        this.locationList.forEach(ele => {
            if( this.selectedLocation && this.selectedLocation.locationGUID && ele.locationGUID == this.selectedLocation.locationGUID ){ 
                ele.class = ele.class + " highlight ";
            }
            else{
                ele.class = "locationStyle slds-align_absolute-center section-title section-title-background slds-m-top_medium slds-m-around_small  slds-listbox__item";
            }
        });
    }

    resetLocationSelection(){
        this.selectedLocation = null;
        this.locationList.forEach(ele => 
            ele.class = "locationStyle slds-align_absolute-center section-title section-title-background slds-m-top_medium slds-m-around_small  slds-listbox__item"
        );
        this.dispatchAllData();    
    }

    dispatchAllData(){
        this.dispatchEvent(new CustomEvent('receiveselectedlocation',{
            detail : {
                selectedLocation : JSON.stringify(this.selectedLocation),
                locationData : JSON.stringify(this.locationList),
                earliestDateList : JSON.stringify(this.allEarliestDatesList)
            }
        }));
    }

    apppintmentContainerLoadingIndex = 0;
    // receive service appointment data from EarliestAvailabilityComp and send to 1st screen
    handleAppointmentData(event){
        console.log('--event-detail handleAppointmentData--',JSON.stringify(event.detail));
        if( event.detail.type == 'prepError' ){
            this.apppintmentContainerLoadingIndex++;
            if( this.apppintmentContainerLoadingIndex < this.template.querySelectorAll("c-bln-_-earliest-appointment-availability-cmp").length){
                this.template.querySelectorAll("c-bln-_-earliest-appointment-availability-cmp")[this.apppintmentContainerLoadingIndex].calculateEarliestDate(false);
            }
        }else if( event.detail.type == 'prepSuccess' ){
            this.template.querySelectorAll("c-bln-_-earliest-appointment-availability-cmp").forEach((ele,index)=>{
                if(index > this.apppintmentContainerLoadingIndex){
                    ele.calculateEarliestDate(true);
                }
            });
            this.apppintmentContainerLoadingIndex = 5; //since one was sucess ignore next prepError based in index
        }else{
       this.locationList.forEach(loc => {
            if(loc.locationGUID == event.detail.locationId){
                loc.isCPT = event.detail.showOutofStockBanner;
            }
       });
            this.dispatchEvent(new CustomEvent('receiveappointmentdata',{
                detail : event.detail
            }));
        }
    }


}