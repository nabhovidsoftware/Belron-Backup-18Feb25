import { LightningElement, track, wire ,api } from 'lwc';
import MelissaApiAddressService from '@salesforce/apex/BLN_MelissaApiAddressService.searchAddress';
import updateAddressDetails from '@salesforce/apex/BLN_MelissaApiAddressService.updateAddress'
import homeStreetLabel from '@salesforce/label/c.BLN_HomeStreet';
import LightningAlert from 'lightning/alert';
import homeTownLabel from '@salesforce/label/c.BLN_HomeTown';
import homeCountyLabel from '@salesforce/label/c.BLN_HomeCounty';
import homeCountryLabel from '@salesforce/label/c.BLN_HomeCountry';
import homePostCodeLabel from '@salesforce/label/c.BLN_HomePostCode';
import otherStreetLabel from '@salesforce/label/c.BLN_OtherStreet';
import otherTownLabel from '@salesforce/label/c.BLN_OtherTown';
import otherCountyLabel from '@salesforce/label/c.BLN_OtherCounty';
import otherCountryLabel from '@salesforce/label/c.BLN_OtherCountry';
import otherPostCodeLabel from '@salesforce/label/c.BLN_OtherPostCode';
import cancelLabel from '@salesforce/label/c.BLN_Cancel';
import saveLabel from '@salesforce/label/c.BLN_SaveLabel';
import homeLabel from '@salesforce/label/c.BLN_Home';
import otherLabel from '@salesforce/label/c.BLN_Other';
import homeTownkey from '@salesforce/label/c.BLN_homeTownValue';
import homeCountrykey from '@salesforce/label/c.BLN_homeCountryValue';
import homeStreetkey from '@salesforce/label/c.BLN_homeStreetValue';
import homeCountykey from '@salesforce/label/c.BLN_homeCountyValue';
import homePostkey from '@salesforce/label/c.BLN_homePostCodeValue';
import homeLatitudekey from '@salesforce/label/c.BLN_homeLatitudeValue';
import homeLongitudekey from '@salesforce/label/c.BLN_homeLongitudeValue';
import otherStreetkey from '@salesforce/label/c.BLN_otherStreetValue';
import otherTownkey from '@salesforce/label/c.BLN_otherTownValue';
import otherCountykey from '@salesforce/label/c.BLN_otherCountyValue';
import otherPostCodekey from '@salesforce/label/c.BLN_otherPostCodeValue';
import otherLatitudekey from '@salesforce/label/c.BLN_otherLatitudeValue';
import otherLongitudekey from '@salesforce/label/c.BLN_otherLongitudeValue';
import otherCountrykey from '@salesforce/label/c.BLN_otherCountryValue';
import errorMsgMelissa from '@salesforce/label/c.BLN_MelissaErrorMsg';
import fieldCustomValidationException from '@salesforce/label/c.BLN_FieldCustomValidation';
import OtherCountryCode from '@salesforce/label/c.BLN_OtherCountryCode';
import HomeCountryCode from '@salesforce/label/c.BLN_HomeCountryCode';
import changedHomePostCodekey from '@salesforce/label/c.BLN_changedHomePostCodeValue';
import changedOtherPostCodekey from '@salesforce/label/c.BLN_changedOtherPostCodeValue';
import UpdateLabel from '@salesforce/label/c.BLN_UpdateAddress';
import errorTitle from '@salesforce/label/c.BLN_ErrorTitle';
import errorOccurred from '@salesforce/label/c.BLN_ErrorOccur';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getFocusedTabInfo, closeTab } from 'lightning/platformWorkspaceApi';


import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';

export default class Bln_UpdateMotoristAddressCmp extends LightningElement {
  label = {
    homeStreetLabel,
    homeTownLabel,
    homeCountyLabel,
    homeCountryLabel,
    homePostCodeLabel,
    homePostkey,
    otherStreetLabel,
    otherTownLabel,
    otherCountyLabel,
    otherCountryLabel,
    otherPostCodeLabel,
    cancelLabel,
    UpdateLabel,
    errorTitle,
    saveLabel,
    homeTownkey,
    homeCountrykey,
    homeStreetkey,
    errorMsgMelissa,
    homeCountykey,
    errorOccurred
  }

   @api recordId;
   //showSpinner = true;
    manualAddressMap = [];
    selectedAddressType = '';
    showHomeAddressFields = false;
    showOtherAddressFields = false;
    showBothAddressFields = true;
    @api IsCancelled = false;
    alphabetCount ;
    showOptionTypeEvent = false;
    @track homeStreet;
    @track homeTown;
    @track homeCounty;
    @track homeCountry;
    @track homePostCode;
    sendInputText;
    addressList = [];
    onSelectedValues = [];
    oldPostCode ;
    oldOtherPostCode;
    changedPostCode = 'false';
    changedOtherPostCode = 'false';
    homeLatitude;
    homeLongitude;
    otherLatitude;
    otherLongitude;
    homeCountryCode = '';
    otherCountryCode = '';
    @api availableActions = [];
    @track adressFieldMap = [];
    @track chnageAddressMap = [];
    @api caseId;
    @api updateBillingAddress = false;
    @api caseBillingMethod = '';
    showErrorModal;
    openmodalError;

    addressOptions =[
        {label:homeLabel, value:homeLabel},
        {label:otherLabel,value:otherLabel}
    ];
	
    handleAddressChange(event){
        this.selectedAddressType = event.target.value;

        if(this.selectedAddressType === homeLabel){
            this.showHomeAddressFields = true;
            this.showOtherAddressFields = false;
            this.showBothAddressFields = true;
            this.showOptionTypeEvent = false;
            this.adressFieldMap = [];
            this.otherStreet = '';
            this.otherTown = '';
            this.otherCounty = '';
            this.otherCountry = '';
            this.otherPostCode= '';
        }else if (this.selectedAddressType === otherLabel){
            this.showHomeAddressFields = false;
            this.showBothAddressFields = true;
            this.showOtherAddressFields = true;
            this.showOptionTypeEvent = false;
            this.adressFieldMap = [];
            this.homeStreet = '';
            this.homeTown = '';
            this.homeCounty = '';
            this.homeCountry = '';
            this.homePostCode= '';
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

  handleResultClick(event){
        let street = event.currentTarget.dataset.street;
        let postalCode = event.currentTarget.dataset.postalcode;
        let city =  event.currentTarget.dataset.city;
        let county = event.currentTarget.dataset.county;
        let country = event.currentTarget.dataset.country;
        let latitude = event.currentTarget.dataset.latitude;
        let longitude = event.currentTarget.dataset.longitude;
        let countryCode = event.currentTarget.dataset.countrycode;
        this.adressFieldMap = [];
        console.log('street',street);
        console.log('countryCode',countryCode);
        if(this.selectedAddressType === homeLabel){
          this.showOptionTypeEvent = false;
          
          if(street != '' || postalCode != '' || city != '' || county != '' || country != '' || latitude!= ''|| longitude != ''){
            this.homeStreet = street;
            this.homeTown = city;
            this.homeCounty = county;
            this.homeCountry = country
            this.homePostCode= postalCode;
            this.homeLatitude = latitude;
            this.homeLongitude = longitude;
            this.oldPostCode = this.homePostCode;
            this.homeCountryCode = countryCode;
            this.adressFieldMap.push({
              key: homeTownkey,
              value: this.homeTown
            },
            {
              key: homeStreetkey,
              value: this.homeStreet
            },
            {
              key: homeCountykey,
              value: this.homeCounty
            },
            {
              key: homeCountrykey,
              value: this.homeCountry
            },
            {
              key: homePostkey,
              value: this.homePostCode
            },
            {
              key: homeLatitudekey,
              value: this.homeLatitude
            },
            {
              key: homeLongitudekey,
              value: this.homeLongitude
            },
              { key: HomeCountryCode,
                value: this.homeCountryCode })
		} 
    console.log('adressFieldMap-168-->',this.adressFieldMap); 

        }

        if(this.selectedAddressType === otherLabel){
          this.showOptionTypeEvent = false;
          
          if(street != '' || postalCode != '' || city != '' || county != '' || country != '' || latitude!= ''|| longitude != ''){
            this.otherStreet = street;
            this.otherTown = city;
            this.otherCounty = county;
            this.otherCountry = country //country
            this.otherPostCode= postalCode;
            this.oldOtherPostCode = this.otherPostCode;
            this.otherLatitude = latitude;
            this.otherLongitude = longitude;
            this.otherCountryCode = countryCode;
            this.adressFieldMap.push({
              key: otherStreetkey,
              value: this.otherStreet
            },
            {
              key: otherTownkey,
              value: this.otherTown
            },
            {
              key: otherCountykey,
              value: this.otherCounty
            },
            {
              key: otherCountrykey,
              value: this.otherCountry
            },
            {
              key: otherPostCodekey,
              value: this.otherPostCode
            },
            {
              key: otherLatitudekey,
              value: this.otherLatitude
            },
            {
              key: otherLongitudekey,
              value: this.otherLongitude
            },
            {
              key: OtherCountryCode,
              value: this.otherCountryCode
            }
            )
        } 
        }
       
        this.showOptionTypeEvent = false;
    }

    addressValueChange(event){
      let valueName = event.currentTarget.dataset.name;
      if( valueName == homeStreetkey && this.template.querySelector(".homestreet").value != this.homeStreet){
       this.homeStreet = this.template.querySelector(".homestreet").value;
        this.chnageAddressMap = [];
        this.chnageAddressMap.push({
          key: homeStreetkey,
        value: this.homeStreet
       })
      }
    
      if( valueName == homeTownkey && this.template.querySelector(".townhome").value != this.homeTown){
       this.homeTown = this.template.querySelector(".townhome").value;
        this.chnageAddressMap = [];
        this.chnageAddressMap.push({
          key: homeTownkey,
        value: this.homeTown
       })
      }
 
      if( valueName == homeCountykey && this.template.querySelector(".countyhome").value != this.homeCounty){
       this.homeCounty = this.template.querySelector(".countyhome").value;
        this.chnageAddressMap = [];
        this.chnageAddressMap.push({
          key: homeCountykey,
        value: this.homeCounty
       })
      }
 
      if( valueName == homeCountrykey && this.template.querySelector(".countryhome").value != this.homeCountry){
       this.homeCountry = this.template.querySelector(".countryhome").value;
        this.chnageAddressMap = [];
        this.chnageAddressMap.push({
          key: homeCountrykey,
        value: this.homeCountry
       })
      }
 
      if( valueName == homePostkey && this.template.querySelector(".postcodehome").value != this.homePostCode){
       this.homePostCode = this.template.querySelector(".postcodehome").value;
        this.chnageAddressMap = [];
        this.chnageAddressMap.push({
          key: homePostkey,
        value: this.homePostCode
       })
      }
      if(this.adressFieldMap.length != 0){
      this.adressFieldMap.forEach(element => {
       if(element.key == this.chnageAddressMap[0].key){
        element.value = this.chnageAddressMap[0].value;
      }
      })
    }else{
      this.manualAddressMap.push(this.chnageAddressMap[0]);
     }
     }

    otherAddressValueChange(event){
      let valueName = event.currentTarget.dataset.name;
      if( valueName == otherStreetkey && this.template.querySelector(".otherStreet").value != this.otherStreet){
        this.otherStreet = this.template.querySelector(".otherStreet").value;
          this.chnageAddressMap = [];
          this.chnageAddressMap.push({
            key: otherStreetkey,
          value: this.otherStreet
         })
       }

       if( valueName == otherTownkey && this.template.querySelector(".otherTown").value != this.otherTown){
        this.otherTown = this.template.querySelector(".otherTown").value;
          this.chnageAddressMap = [];
          this.chnageAddressMap.push({
            key: otherTownkey,
          value: this.otherTown
         })
       }
  
       if( valueName == otherCountykey && this.template.querySelector(".otherCounty").value != this.otherCounty){
        this.otherCounty = this.template.querySelector(".otherCounty").value;
          this.chnageAddressMap = [];
          this.chnageAddressMap.push({
            key: otherCountykey,
          value: this.otherCounty
         })
       }
  
       if( valueName == otherCountrykey && this.template.querySelector(".otherCountry").value != this.otherCountry){
        this.otherCountry = this.template.querySelector(".otherCountry").value;
      
        this.chnageAddressMap =[];
        this.chnageAddressMap.push({
            key: otherCountrykey,
          value: this.otherCountry
         })
       }
  
       if( valueName == otherPostCodekey && this.template.querySelector(".otherPostCode").value != this.otherPostCode){
        this.otherPostCode = this.template.querySelector(".otherPostCode").value;
      this.chnageAddressMap = [];
        this.chnageAddressMap.push({
          key: otherPostCodekey,
          value: this.otherPostCode
         })
       }
      if(this.adressFieldMap.length != 0){
       this.adressFieldMap.forEach(element => {
        if(element.key == this.chnageAddressMap[0].key){
         element.value = this.chnageAddressMap[0].value;
       }
       })
      }else{
      this.manualAddressMap.push(this.chnageAddressMap[0]);
     }
     }
     
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
            this.showOptionTypeEvent = false;
           // this.showSpinner = false ;
            // this.showErrorModal = 'true';
             this.openmodalError = 'true';
             //this.showErrorAlert(this.label.errorMsgMelissa, 'error', this.label.errorOccurred);

          }
      }
      })
      .catch(error => {
        this.dispatchEvent(
          new ShowToastEvent({
              title: errorTitle,
              message: error,
              variant: 'error',
          }),
      );
      })
    }
    
    /*To update the address into the record*/
    handleUpdate(event) {
      let events = event.target.name;
      this.adressFieldMap.forEach(element => {
        if(element.key == homePostkey){
          if(this.oldPostCode != element.value){
            this.changedPostCode = 'true';
          }
        }
          if(element.key == otherPostCodekey){
            if(this.oldOtherPostCode != element.value){
              this.changedOtherPostCode = 'true';
            }
          }
        })
        if(this.manualAddressMap.length > 0){
          this.adressFieldMap = this.manualAddressMap;
        }
        this.adressFieldMap.push({
          key: changedHomePostCodekey,
          value: this.changedPostCode
        })
        this.adressFieldMap.push({
          key: changedOtherPostCodekey,
          value: this.changedOtherPostCode
        })

      /*update method call*/
      console.log(this.caseId);
      console.log(this.updateBillingAddress);
      console.log('caseBillingMethod'+this.caseBillingMethod);
      updateAddressDetails({
        addressMap : JSON.stringify(this.adressFieldMap),
        recordId : this.recordId,
        caseId : this.caseId,
        updateBilling : this.updateBillingAddress,
        caseBillingMethod : this.caseBillingMethod
      })
      .then((data) => {
          this.dispatchEvent(new FlowAttributeChangeEvent('IsCancelled', true));
          if (this.availableActions.find((action) => action === 'NEXT')) {
              const navigateNextEvent = new FlowNavigationNextEvent();
              this.dispatchEvent(navigateNextEvent)
          }
          
          let validateData = data.toString();
          if(validateData.includes(fieldCustomValidationException)){
          const event = new ShowToastEvent({
            message: validateData.split(',')[1],
            variant: 'error',
            mode: 'dismissable'
          
        });
        this.dispatchEvent(event); 
      }else{
        const event = new ShowToastEvent({
          message: UpdateLabel,
          variant: 'success',
          mode: 'dismissable'
      });
     
      this.dispatchEvent(event);
      }
      })
      .catch(error => {
        this.dispatchEvent(
          new ShowToastEvent({
              title: errorTitle,
              message: error,
              variant: 'error',
          }),
      );
      });
    }
     
    closeErrorModal(){
      this.openmodalError = '';
      this.showErrorModal = '';
    }
     showErrorAlert(msg, theme, heading) {
      //if (this.showSpinner) {
           LightningAlert.open({
              message: msg,
              theme: theme,
              label: heading
          });

          this.closeFlow();
    //  }
  }

      closeFlow() {
      getFocusedTabInfo().then(tabinfo => closeTab(tabinfo.tabId));
  }
     
}