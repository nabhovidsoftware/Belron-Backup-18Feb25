import { LightningElement, api, wire } from 'lwc';
import MelissaApiAddressService from '@salesforce/apex/BLN_MelissaApiAddressService.searchAddress';

import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';
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
import homeStreet from '@salesforce/label/c.BLN_homeStreetValue';
import homeTown from '@salesforce/label/c.BLN_homeTownValue';
import homeCounty from '@salesforce/label/c.BLN_homeCountyValue';
import homeCountry from '@salesforce/label/c.BLN_homeCountryValue';
import homePostCode from '@salesforce/label/c.BLN_homePostCodeValue';
import homeLatitude from '@salesforce/label/c.BLN_homeLatitudeValue';
import homeLongitude from '@salesforce/label/c.BLN_homeLongitudeValue';
import errorMsg from '@salesforce/label/c.BLN_MelissaErrorMsg';
//FOUK 6283
import isCerServiceAddress from '@salesforce/customPermission/BLN_CerServiceAddress';
import { getFieldValue, getRecord, updateRecord } from 'lightning/uiRecordApi';

const FIELDS = [
 'Case.BLN_ServiceStreet__c',
 'Case.BLN_ServicePostCode__c',
 'Case.BLN_ServiceCounty__c',
 'Case.BLN_ServiceCountry__c',
 'Case.BLN_ServiceTown__c',
 'Case.BLN_ServiceGeolocation__Latitude__s',
 'Case.BLN_ServiceGeolocation__Longitude__s',
];

export default class Bln_ChangeLocationAddress extends LightningElement {
    alphabetCount ;
    showOptionTypeEvent = false;
    disablevalue=true;

    recordId;
    ispAddress;
    
    serviceStreet;
    serviceTown;
    serviceCountry;
    serviceCounty;
    servicePostCode;
    serviceLatitudeNum;
    serviceLongitudeNum;

    oldPostCode;
    selectedaddress='';
    openmodalError ;
    ispTypeId;
    isLocationChange = false;
    outputserviceStreet;
    outputserviceTown;
    outputserviceCounty;
    outputserviceCountry;
    outputserviceISPAddress;
    outputservicePostCode;
    outputserviceLatitudeNum = ''; 
    outputserviceLongitudeNum = '';
    oldserviceLatitudeNum;
    oldserviceLongitudeNum;

    oldServicePostCode;
    serviceLatitudeNum;
    serviceLongitudeNum;
    serviceGeoLocation;
    serviceGeoLocationLatitude;
    serviceGeoLocationLongitude;
    
    adressFieldMap=[];
    availableActions = [];
    @api chnageAddressMap=[];
    @api isSave=false;
    @api IsCancelled = false;

    @api caseId = '';
    isFieldDisabled = false;

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
      errorMsg
    }

    @wire(getRecord, { recordId:'$caseId', fields: FIELDS})
     caseRecord({error, data}){
        if(data) {
            this.serviceStreet = getFieldValue(data, 'Case.BLN_ServiceStreet__c');
            this.serviceTown = getFieldValue(data, 'Case.BLN_ServiceTown__c');
            this.serviceCounty = getFieldValue(data, 'Case.BLN_ServiceCounty__c');
            this.serviceCountry = getFieldValue(data, 'Case.BLN_ServiceCountry__c');
            this.servicePostCode = getFieldValue(data, 'Case.BLN_ServicePostCode__c');
            this.oldserviceLatitudeNum = getFieldValue(data, 'Case.BLN_ServiceGeolocation__Latitude__s');
            this.oldserviceLongitudeNum = getFieldValue(data, 'Case.BLN_ServiceGeolocation__Longitude__s');
            console.log('oldserviceLatitudeNum',this.oldserviceLatitudeNum);
            console.log('oldserviceLongitudeNum',this.oldserviceLongitudeNum);
            if(isCerServiceAddress == true){
             this.isFieldDisabled = false;
            }else{
              this.isFieldDisabled = true;
            }
        }

        
     }
    

  


   searchAddressHandle(event){ 
        this.alphabetCount = event.target.value;
        this.showOptionTypeEvent = false;
        if(this.alphabetCount.length >= 3){
             this.showOptionTypeEvent = false;
             this.sendInputText =  this.alphabetCount;
             this.getAddressDetails();
        }
        if(this.alphabetCount == ''){
         this.showOptionTypeEvent = false;
        }
    }

    handleChange(event){
      this.ispAddress = event.target.checked;
    }

    handleResultClick(event){
      this.showOptionTypeEvent = false;

      let street = event.currentTarget.dataset.street;
      let postalcode = event.currentTarget.dataset.postalcode;
      let city = event.currentTarget.dataset.city;
      let county = event.currentTarget.dataset.county;
      let country = event.currentTarget.dataset.country;
      let latitude = event.currentTarget.dataset.latitude;
      let longitude = event.currentTarget.dataset.longitude;
      
      if(street != '' || postalcode != '' || city != '' || county != '' || country != '' || latitude!= ''|| longitude != ''){
        this.serviceStreet = street;
        this.serviceTown = city;
        this.serviceCounty = county;
        this.serviceCountry = country;
        this.servicePostCode= postalcode;
        this.serviceLatitudeNum = latitude;
        this.serviceLongitudeNum = longitude;
        this.oldPostCode = this.servicePostCode;

        this.outputserviceStreet = street;
        this.outputserviceTown = city;
        this.outputserviceCounty = county;
        this.outputserviceCountry = country;
        this.outputservicePostCode= postalcode;
        this.outputserviceLatitudeNum= latitude;
        this.outputserviceLongitudeNum= longitude;
        this.outputserviceISPAddress = this.ispAddress;
        this.disablevalue=false;

        }
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
                console.log('getadressIn', this.addressList);
            }else{
              this.showOptionTypeEvent = false;
              
              this.openmodalError = 'true';
            }
        }
        })
        .catch((error) => {
        })
      }

  /*Save buttonon click*/
 


  handleCancel(event){
    var actionClicked = event.target.name;
    if (actionClicked) {
      this.dispatchEvent(new FlowAttributeChangeEvent('IsCancelled', true));
      if (this.availableActions.find((action) => action === 'NEXT')) {
          const navigateNextEvent = new FlowNavigationNextEvent();
          this.dispatchEvent(navigateNextEvent)
      }
    }
  }
    
  addressValueChange(event){
    let valueName = event.currentTarget.dataset.name;
    if( valueName = homeStreet && this.template.querySelector(".homestreet").value != this.homeStreet){
        this.outputserviceStreet = this.template.querySelector(".homestreet").value;
      //this.outputserviceStreet=this.serviceStreet;
     this.chnageAddressMap =[];
     this.chnageAddressMap.push({
      key: this.homestreet,
      value: this.serviceStreet
     })
    }
  
    if( valueName = homeTown && this.template.querySelector(".townhome").value != this.homeTown){
        this.outputserviceTown = this.template.querySelector(".townhome").value;
     //this.outputserviceTown=this.serviceTown;
     this.chnageAddressMap =[];
     this.chnageAddressMap.push({
      key: homeTown,
      value: this.serviceTown
     })
    }

    if( valueName = homeCounty && this.template.querySelector(".countyhome").value != this.homeCounty){
        this.outputserviceCounty = this.template.querySelector(".countyhome").value;
    // this.outputserviceCounty=this.serviceCounty;
     this.chnageAddressMap = [];
     this.chnageAddressMap.push({
      key: homeCounty,
      value: this.serviceCounty
     })
    }

    if( valueName = homeCountry && this.template.querySelector(".countryhome").value != this.homeCountry){
        this.outputserviceCountry = this.template.querySelector(".countryhome").value;
    // this.outputserviceCountry=this.serviceCountry
     this.chnageAddressMap = [];
     this.chnageAddressMap.push({
      key: homeCountry,
      value: this.serviceCountry
     })
    }

    if( valueName = homePostCode && this.template.querySelector(".postcodehome").value != this.homePostCode){
        this.outputservicePostCode = this.template.querySelector(".postcodehome").value;
     //this.outputservicePostCode=this.servicePostCode;
     this.chnageAddressMap = [];
     this.chnageAddressMap.push({
      key: homePostCode,
      value: this.servicePostCode
     })
     //this.outputserviceLatitudeNum=null;
     //this.outputserviceLongitudeNum=null;

    }

     
   

    if(this.servicePostCode!='' && this.serviceCountry!='' &&  this.serviceTown!='' && this.serviceStreet!='' && this.outputserviceLatitudeNum != '' && this.outputserviceLongitudeNum != ''){
      this.disablevalue=false;
    } //this.serviceCounty!='' && this.ispAddress!=''
    else{
      this.disablevalue=true;
    }

    if(this.servicePostCode != this.outputservicePostCode || this.serviceCountry != this.outputserviceCounty || this.serviceTown != this.outputserviceTown
      ||   this.serviceStreet != this.outputserviceStreet
    ){
         this.isLocationChange = true;
         

    }else{
      this.isLocationChange = false;
    }
   }

   handleUpdate(event){
    this.outputservicePostCode = this.template.querySelector(".postcodehome").value;
    this.outputserviceCountry = this.template.querySelector(".countryhome").value;
    this.outputserviceCounty = this.template.querySelector(".countyhome").value;
    this.outputserviceTown = this.template.querySelector(".townhome").value;
    this.outputserviceStreet = this.template.querySelector(".homestreet").value;
     
   


    if(this.servicePostCode != this.outputservicePostCode || this.serviceCountry != this.outputserviceCounty || this.serviceTown != this.outputserviceTown
      ||   this.serviceStreet != this.outputserviceStreet 
    ){
         this.isLocationChange = true;

         const updateNewAddress = new CustomEvent('adressdetail',{
          detail : {
            servicePostCode : this.servicePostCode,
            serviceCountry : this.serviceCountry,
            serviceCounty : this.serviceCounty,
            serviceTown : this.serviceTown,
            serviceStreet : this.serviceStreet,
            latitude : this.outputserviceLatitudeNum,
            longitude : this.outputserviceLongitudeNum,
            isLocationChange : this.isLocationChange,
            isChangeProduct : false
          }
        });
        this.dispatchEvent(updateNewAddress);
        window.setTimeout(()=>{
          this.dispatchEvent(new CustomEvent('close'));
        },100);
       
    }else{
      this.isLocationChange = false;
    }



   }



   closeErrorModal(){
   this.dispatchEvent(new CustomEvent('close'));
   }

   handleCancel(){
    this.dispatchEvent(new CustomEvent('close'));
   }
  
}