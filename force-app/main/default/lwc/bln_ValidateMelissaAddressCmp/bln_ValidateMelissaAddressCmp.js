import { LightningElement, api,track,wire } from 'lwc';
import MelissaApiAddressService from '@salesforce/apex/BLN_MelissaApiAddressService.searchAddress';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import cancelLabel from '@salesforce/label/c.BLN_Cancel';
import saveLabel from '@salesforce/label/c.BLN_SaveLabel';
import serviceAddressLabel from '@salesforce/label/c.BLN_ServiceAddress';
import searchAddressLabel from '@salesforce/label/c.BLN_SearchAddress';
import streetLabel from '@salesforce/label/c.BLN_Street';
import townLabel from '@salesforce/label/c.BLN_Town';
import countyLabel from '@salesforce/label/c.BLN_County';
import countryLabel from '@salesforce/label/c.BLN_Country';
import ispAddressLabel from '@salesforce/label/c.BLN_ISPAddress';
import postCodeLabel from '@salesforce/label/c.BLN_PostCode';
import errorOccurred from '@salesforce/label/c.BLN_ErrorOccur';
import errorMsg from '@salesforce/label/c.BLN_MelissaErrorMsg';
import billingAddress from '@salesforce/label/c.BLN_BillingAddress';
import updateAddLabel from '@salesforce/label/c.BLN_UpdateAddLabel';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { IsConsoleNavigation, getFocusedTabInfo, closeTab, refreshTab, getAllTabInfo } from 'lightning/platformWorkspaceApi';


export default class Bln_ValidateMelissaAddressCmp extends LightningElement {
    alphabetCount ;
    showOptionTypeEvent = false;
    disablevalue=false;

    @api recordId;
    @api ispAddress;
    @api caseSubtype;
    @api disableaddressvalue = false;
    
    @api serviceStreet;
    @api serviceTown;
    @api serviceCountry;
    @api serviceCounty;
    @api servicePostCode;
    @api serviceLatitudeNum;
    @api serviceLongitudeNum;

    @api billingStreet;
    @api billingTown;
    @api billingCountry;
    @api billingCounty;
    @api billingPostCode;

    @track serviceAddress = {};
    @api outputserviceStreet;
    @api outputserviceTown;
    @api outputserviceCounty;
    @api outputserviceCountry;
    @api outputserviceISPAddress;
    @api outputservicePostCode;
    @api outputserviceLatitudeNum;
    @api outputserviceLongitudeNum;

    @api outputbillingPostCode;
    @api outputbillingCountry;
    @api outputbillingCounty;
    @api outputbillingTown;
    @api outputbillingStreet;

    @api pdsPostalCode = '';
    @api availableActions = [];
    @api isSave=false;
    @api IsCancelled = false;
    @api callAderessFlow = false;
    @api callDataCollectFlow = false;
    @api callAderessFlowNew = false;
    @api unhappyAddressFlow = false;
    @api isCheckFlow = false;
    @api isAddressType = false;
    isFlowHeader = true;
    picklistCss = '';
    /*_booleanVariableForFlow = true;

    @api
    get booleanVariableForFlow() {
        return this._booleanVariableForFlow;
    }
    set booleanVariableForFlow(value) {
        
        this._booleanVariableForFlow = value;
        const attributeChangeEvent = new FlowAttributeChangeEvent('booleanVariableForFlow', value);
        console.log('this.attributeChangeEvent', JSON.stringify(attributeChangeEvent));
        this.dispatchEvent(attributeChangeEvent);
    }*/
        @api booleanVariableForFlow = false;
    @api pdsPostalCodeNew = '';

    @wire(IsConsoleNavigation) isConsoleNavigation;

    label={
      cancelLabel,
      saveLabel,
      serviceAddressLabel,
      searchAddressLabel,
      streetLabel,
      townLabel,
      countyLabel,
      countryLabel,
      ispAddressLabel,
      postCodeLabel,
      errorMsg,
      errorOccurred,
      billingAddress,
      updateAddLabel
    }
    //FOUK-11617
    // selectedServiceAddress = true;
    // selectedServiceAddress = this.options[0].value;
     defaultAddress = true;

   addressOptions =[
    {label:this.label.serviceAddressLabel, value: this.label.serviceAddressLabel , Boolean: true} ,
      {label:this.label.billingAddress, value:this.label.billingAddress,Boolean: false}
  ];
  options = [
    { label: serviceAddressLabel, value: serviceAddressLabel },
    { label: billingAddress, value: billingAddress }
];
   value = serviceAddressLabel;

    connectedCallback() {
      console.log('callAderessFlow', this.callAderessFlow);
      this.booleanVariableForFlow = true;
    
      if(this.caseSubtype != 'ISP' && this.caseSubtype != 'Job Request'){
        this.disableaddressvalue = true;
      }

      if(this.callAderessFlow == false){
        this.serviceAddress = {
          homeStreet : this.serviceStreet,
          homeTown : this.serviceTown,
          homeCounty : this.serviceCounty,
          homeCountry : this.serviceCountry,
          homePostCode: this.servicePostCode,
          homeLatitudeNum: this.serviceLatitudeNum,
          homeLongitudeNum: this.serviceLongitudeNum,
          homeISPAddress : this.ispAddress
        };
      this.picklistCss = "slds-dropdown slds-dropdown_fluid size3 dropdownclass"    
      } else{
        this.picklistCss = "slds-dropdown slds-dropdown_fluid size3 dropdownclasscapture" 
      }
    }

    handleAddressChange(event){
      // this.selectedServiceAddress = event.detail.value;
      // console.log(this.selectedServiceAddress);
     
      let selectedAddressType = event.target.value;

      if(selectedAddressType === this.label.billingAddress){
        this.callAderessFlow = true;

        this.addressOptions.forEach(option => {
          if(option.value === selectedAddressType){
            option.Boolean = true;
          }else{
            option.Boolean = false;
          }
        });

        if(this.isCheckFlow == false){
        this.serviceAddress = {
          homeStreet : this.billingStreet,
          homeTown : this.billingTown,
          homeCounty : this.billingCounty,
          homeCountry : this.billingCountry,
          homePostCode: this.billingPostCode,
        };
      }

      }else if (selectedAddressType === this.label.serviceAddressLabel){
        this.callAderessFlow = false;

        this.addressOptions.forEach(option => {
          if(option.value === selectedAddressType){
            option.Boolean = true;
          }else{
            option.Boolean = false;
          }
        });

        this.serviceAddress = {
          homeStreet : this.serviceStreet,
          homeTown : this.serviceTown,
          homeCounty : this.serviceCounty,
          homeCountry : this.serviceCountry,
          homePostCode: this.servicePostCode,
          homeLatitudeNum: this.serviceLatitudeNum,
          homeLongitudeNum: this.serviceLongitudeNum,
          homeISPAddress : this.ispAddress
        };
      }

      console.log(JSON.stringify(this.addressOptions));
    }

    

  searchAddressHandle(event){ 
    this.alphabetCount = event.target.value;
    this.showOptionTypeEvent = false;
    if(this.alphabetCount.length >= 3){
      this.sendInputText =  this.alphabetCount;
      this.getAddressDetails();
    }
  }

  handleISPChange(event){
    this.serviceAddress.homeISPAddress = this.ispAddress = event.target.checked;
    // if( (!this.isEmpty(this.serviceAddress.homeStreet) ||
    // !this.isEmpty(this.serviceAddress.homeTown) ||
    // !this.isEmpty(this.serviceAddress.homeCounty) ||
    // !this.isEmpty(this.serviceAddress.homeCountry) ||
    // !this.isEmpty(this.serviceAddress.homePostCode)) &&
    // this.ispAddress ){
    // this.disablevalue=false;
    // }

  }

    handleResultClick(event){
      this.showOptionTypeEvent = false;
      let latitude = event.currentTarget.dataset.latitude != '' ? event.currentTarget.dataset.latitude : 0;
      let longitude = event.currentTarget.dataset.longitude != '' ? event.currentTarget.dataset.longitude : 0;
 /////test12345345
      this.serviceAddress = {
        homeStreet : event.currentTarget.dataset.street,
        homeTown : event.currentTarget.dataset.city,
        homeCounty : event.currentTarget.dataset.county,
        homeCountry : event.currentTarget.dataset.country,
        homePostCode: event.currentTarget.dataset.postalcode,
        homeLatitudeNum: latitude,
        homeLongitudeNum: longitude,
        homeISPAddress : this.ispAddress
      };

      this.disablevalue = false;
    }

     /*To get address list from Melissa Api*/
    getAddressDetails(){
      MelissaApiAddressService({
        inputText : this.sendInputText
      })
      .then((result)=>{
        if(result){
          if(result != null && result.length != 0){
            this.showOptionTypeEvent = true;
            this.addressList = result;
          }else{
            this.showToast(this.label.errorOccurred, this.label.errorMsg, 'error');
          }
        }
      })
      .catch((error) => {
        this.showToast(this.label.errorOccurred, this.label.errorMsg, 'error');
      });
    }

    handleBtnClick(event) {
      if(this.callAderessFlow == false){
        this.isAddressType = false;
      this.dispatchEvent(new FlowAttributeChangeEvent('outputserviceStreet', this.serviceAddress.homeStreet));
      this.dispatchEvent(new FlowAttributeChangeEvent('outputserviceTown', this.serviceAddress.homeTown));
      this.dispatchEvent(new FlowAttributeChangeEvent('outputserviceCounty', this.serviceAddress.homeCounty));
      this.dispatchEvent(new FlowAttributeChangeEvent('outputserviceCountry', this.serviceAddress.homeCountry));
      this.dispatchEvent(new FlowAttributeChangeEvent('outputservicePostCode', this.serviceAddress.homePostCode));
      this.dispatchEvent(new FlowAttributeChangeEvent('outputserviceLatitudeNum', this.serviceAddress.homeLatitudeNum));
      this.dispatchEvent(new FlowAttributeChangeEvent('outputserviceLongitudeNum', this.serviceAddress.homeLongitudeNum));
      this.dispatchEvent(new FlowAttributeChangeEvent('outputserviceISPAddress', this.serviceAddress.homeISPAddress));
      }else{
        this.isAddressType = true;
        if(this.isCheckFlow == false){
          this.dispatchEvent(new FlowAttributeChangeEvent('isAddressType', true));
        }
        this.dispatchEvent(new FlowAttributeChangeEvent('outputbillingStreet', this.serviceAddress.homeStreet));
        this.dispatchEvent(new FlowAttributeChangeEvent('outputbillingTown', this.serviceAddress.homeTown));
        this.dispatchEvent(new FlowAttributeChangeEvent('outputbillingCounty', this.serviceAddress.homeCounty));
        this.dispatchEvent(new FlowAttributeChangeEvent('outputbillingCountry', this.serviceAddress.homeCountry));
        this.dispatchEvent(new FlowAttributeChangeEvent('outputbillingPostCode', this.serviceAddress.homePostCode)); 
        
      }
      this.isFlowHeader = false;
      
      var actionClicked = event.target.name;
      if (actionClicked === this.label.saveLabel ) {//&& this.callAderessFlow == true
        this.dispatchEvent(new FlowAttributeChangeEvent('isSave', true));        
      }
      else if (actionClicked === this.label.cancelLabel ) {//&& this.callAderessFlow == true
        this.dispatchEvent(new FlowAttributeChangeEvent('IsCancelled', true));
      }

      if (this.availableActions.find((action) => action === 'NEXT')) {
        const navigateNextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent);
      }
       
     

    if(this.unhappyAddressFlow == true){
       window.setTimeout(() => {
        this.closeTab();
      },1000)
      
    }
  }

     async closeTab() {
      
      try {
        if (this.isConsoleNavigation) {
            const { tabId, parentTabId } = await getFocusedTabInfo();            
            
            await refreshTab(parentTabId, {
              includeAllSubtabs: false
          });          
            await closeTab(tabId);
           /// getRecordNotifyChange([{recordId: this.recordId}]);
            
            
        }
    } catch (error) {
        console.error('Error closing tab:', error);
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: 'There was an error closing the tab.',
                variant: 'error',
            }),
        );
    }
    }

  addressValueChange(event){
    let valueName = event.currentTarget.dataset.name;
    this.serviceAddress[valueName] = this.template.querySelector("."+valueName).value;
    
   if(this.callAderessFlow == false){
  //   if( (!this.isEmpty(this.serviceAddress.homeStreet) ||
  //       !this.isEmpty(this.serviceAddress.homeTown) ||
  //       !this.isEmpty(this.serviceAddress.homeCounty) ||
  //       !this.isEmpty(this.serviceAddress.homeCountry) ||
  //       !this.isEmpty(this.serviceAddress.homePostCode)) &&
  //       this.ispAddress 
  //   ){
  //     this.disablevalue = false;
  //   }else{
  //     this.disablevalue = true;
  //   }
  // } else{
  //   if( (!this.isEmpty(this.serviceAddress.homeStreet) || 
  //       !this.isEmpty(this.serviceAddress.homeTown) || 
  //       !this.isEmpty(this.serviceAddress.homeCounty) ||
  //       !this.isEmpty(this.serviceAddress.homeCountry) ||
  //       !this.isEmpty(this.serviceAddress.homePostCode) ) && !this.ispAddress
  //   ){
  //     this.disablevalue = false;
  //   }else{
  //     this.disablevalue = true;
  //   }
    // if(!this.isEmpty(this.serviceAddress.homeStreet)){
    //   this.disablevalue = false;
    // }else{
    //   this.disablevalue = true;
    // }

  }
   }

  showToast( title, message, variant ) {
    const event = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant
    });
    this.dispatchEvent(event);
  }

  isEmpty(value) {
    return (value == null || (typeof value === "string" && value.trim().length === 0));
  }

  
  
}