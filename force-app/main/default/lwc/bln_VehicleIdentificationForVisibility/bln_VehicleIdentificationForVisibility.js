import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import duplicateVrnCases from '@salesforce/apex/BLN_VehicleSearchAPI.duplicateVrnCases';
import searchLabel from '@salesforce/label/c.BLN_SearchLabel';
import vrnError from '@salesforce/label/c.BLN_VrnError';
import vinLabel from '@salesforce/label/c.BLN_VinLabel';
import vrnLabel from '@salesforce/label/c.BLN_VrnLabel';
import modelLabel from '@salesforce/label/c.BLN_ModelLabel';
import errorOccurred from '@salesforce/label/c.BLN_ErrorOccur';
import yearLabel from '@salesforce/label/c.BLN_YearLabel';
import bodyTypeLabel from '@salesforce/label/c.BLN_BodyTypeLabel';
import registrationAuthorityLabel from '@salesforce/label/c.BLN_RegistrationAuthorityLabel';
import makeLabel from '@salesforce/label/c.BLN_MakeLabel';
import colorLabel from '@salesforce/label/c.BLN_ColorLabel';
import specialVehicleLabel from '@salesforce/label/c.BLN_SpecialVehicleLabel';
import mvrisLabel from '@salesforce/label/c.BLN_MvrisLabel';
import specialTypesLabel from '@salesforce/label/c.BLN_SpecialTypesLabel';
import specialType from '@salesforce/label/c.BLN_VehicleSTLabel';
import saveLabel from '@salesforce/label/c.BLN_SaveLabel';
import TruncateRange from '@salesforce/label/c.BLN_TruncateRange';
import serachVRN from '@salesforce/apex/BLN_VehicleSearchAPI.searchVRN'
import searchMake from '@salesforce/apex/BLN_VehicleSearchAPI.returnMake'
import searchModel from '@salesforce/apex/BLN_VehicleSearchAPI.returnModel'
import searchBody from '@salesforce/apex/BLN_VehicleSearchAPI.returnBodyType'
import searchYear from '@salesforce/apex/BLN_VehicleSearchAPI.returnYear'
import searchMDMId from '@salesforce/apex/BLN_VehicleSearchAPI.returnMDMId'
import insertEditVehicle from '@salesforce/apex/BLN_VehicleSearchAPI.insertEditVehicle'
import searchSpecialvehicle from '@salesforce/apex/BLN_VehicleSearchAPI.returnSpecialVehicle'
import createVehicle from '@salesforce/apex/BLN_VehicleSearchAPI.insertVehicle'
import getVehicle from '@salesforce/apex/BLN_VehicleSearchAPI.returnVehicle'
import cancelLabel from '@salesforce/label/c.BLN_Cancel';
import duplicateVin from '@salesforce/label/c.BLN_DupliacteVinFound';
import whiteSpaceMsg from '@salesforce/label/c.BLN_WhiteSpaceErrorMsg';
import errorMsg from '@salesforce/label/c.BLN_DvlaError';
import vrnEmptyMsg from '@salesforce/label/c.BLN_VRNEmptyMsg';
import bodyType from '@salesforce/label/c.BLN_BodyType';
import mvris from '@salesforce/label/c.BLN_MVRIS';
import regAuth from '@salesforce/label/c.BLN_RegAuth';
import colour from '@salesforce/label/c.BLN_Colour';
import externalIdlabel from '@salesforce/label/c.BLN_VehicleExternalIdLabel';
import isCalibrationlabel from '@salesforce/label/c.BLN_IsCalibration';
import Otherlabel from '@salesforce/label/c.BLN_Other';
import vehicleSpecial from '@salesforce/label/c.BLN_VehicleSPLabel';
import ChangeVRN from '@salesforce/label/c.BLN_ChangeVRN';
import IsVehicleCalibration from '@salesforce/label/c.BLN_IsVehicleCalibrationRequired';
import MdmId from '@salesforce/label/c.BLN_MDMID';
import ClearInput from '@salesforce/label/c.BLN_ClearInput';
import Next from '@salesforce/label/c.BLN_Next';
import dropDownMenu from '@salesforce/label/c.BLN_DropdownMenu';
import duplicateValue from '@salesforce/label/c.BLN_DuplicateValue';
import insufficientAccess from '@salesforce/label/c.BLN_InsufficientAccess';
import conversion from '@salesforce/label/c.BLN_VehicleConversion'
import trueLabel from '@salesforce/label/c.BLN_VehicleIdentificationTrue';
import caseNumber from '@salesforce/label/c.BLN_CaseNumber';
import yearRange from '@salesforce/label/c.BLN_YearRange';
import vrnNumber from '@salesforce/schema/Case.BLN_VRN__c';
import searchExistingCase from '@salesforce/label/c.BLN_SearchExistingCases';
import VRNMissing from '@salesforce/label/c.BLN_VRNRequiredError';
import VRNUpperCase from '@salesforce/label/c.BLN_VRN';
import multipleMvris from '@salesforce/label/c.BLN_MultipleMatchingVehicle';
import CaptureVehicleDetails from '@salesforce/label/c.BLN_CaptureVehicleDetails';
//import AvailableStartDate from '@salesforce/label/c.BLN_AvailableStartDate__c';
//import AvailableEndDate from '@salesforce/label/c.BLN_AvailableEndDate__c';
//import VehicleNote from '@salesforce/label/c.BLN_VehicleNote__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningAlert from 'lightning/alert';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent,FlowNavigationFinishEvent } from 'lightning/flowSupport';



export default class Bln_VehicleIdentificationForVisibility extends NavigationMixin(LightningElement) {
  //NavigationMixin
   openmodalError;
  vin;
  vrn;
  @api recordId = '';
  @api recordVehicleId = '';
  @api vehicleId = '';
  @api vrnValue = '';
  @track model;
  @track bodyType;
  @track make;
  year;
  registrationAuthority;
  color;
  specialVehicle;
  mvlris;
  @api availableActions = [];
  @api IsCancelled = false;
  @api IsSave = false;
  @api IsSaveFinish = false;
  @api checkEdit = '';
  vinFieldDisabled = true;
  modelDisabled = true;
  bodayTypeDisabled = true;
  makeDisabled = true;
  yearDisabled = true;
  registrationDiasabled = false;
  colorDisabled = true;
  specialVeicleDisabled = true;
  mvrisDisabled = true;
  specialTypesDisabled = true;
  showSpecialType = true;
  showMakeTable = false;
  showVrnScreen = false;
  vrnButtonDisabled = true;
  firstScreen = true;
  isCalibrationdisabled = false;
  showSearchbutton = true;
  mdmDisabled = true;
  vrnDisabled = false;
  saveDisabled = false;
  @track makeList = [];
  @track modelList = [];
  @track bodyTypeList = [];
  @track yearList = [];
  @track colorList = [];
  makeModelBodyList = [];
 @track makeValue = '';
  showModelTable = false;
  @track modelValue = '';
  @track showBodyTypeTabel = false;
  bodyTypeValue = '';
  //vrnValue = '';
  vrnValueA = '';
  vinValue = '';
  yearValue = '';
  colorValue = '';
  regisTrationValue = '';
  mvrisValue = '';
  dynamicScrollMake = false;
  dynamicScrollModel = false;
  dynamicScrollBody = false;
  dynamicScrollYear = false;
  dynamicScrollColor = false;

  specialVehicleMap = [];
 @track handleSaveMap = [];
  specialTypeValue = [];
  showSpecialVehicleType = false;
  specialVehicleValue = false;
  jsSpecialTypeValue = '';
  spinnerSiwtch = false;
  emptyCheckboxVisible = false;
  recordPageUrl;
  externalId = '';
  isCalibration = false;
  sldsColoum = '';
  sldsGrid = '';
  vehicleid = '';
  hideExistingCases = true;
  showErrorMessage = false;
  existingCases = [];
  vrnError = VRNMissing;
  getMvrisList = [];
  mvrisList = [];

  @track makeRecordList = [];
  @track currentMakeList = []
  @track modelRecordList = [];
  @track currentModelList = [];
  @track bodyRecordList = [];
  @track currentBodyList = [];
  @track yearRecordList = [];
  @track currentYearList = [];
  @track currentColorList = [];
  @track colorRecordList = [];
  @track uniqueMakes = [];
  @track uniqueModels = [];
  @track uniqueBodyTypes = [];
  @track uniqueYears = [];
  isMakeSearch = false;
  isModelSearch = false;
  isBodySearch = false;
  isYearSearch = false;

  showMakeField = false;
  showModelDropDown = false;
  showBodyDropdown = false;
  showYearDropdown = false;
  showColorDropDown = false;
  //cr changes
  currentFormatedDate = '';
  yearRangeValue = '';
  showYearRangedropDown = false;
  yearRangeDisabled = true;
  yearRangeRecordList = [];
  currentYearRangeList = [];

  dynamicScrollYearRange = false;
  @track numberArray = [];
  @track noteTruncatedLength = '';
  isSaveDataValidate = false;
  isPdsFlow = false;

  isFlowHeader = false;

  label = {
    errorMsg,
    vrnNumber,
    searchLabel,
    vinLabel,
    vrnLabel,
    modelLabel,
    yearLabel,
    bodyTypeLabel,
    bodyType,
    registrationAuthorityLabel,
    makeLabel,
    colorLabel,
    specialVehicleLabel,
    mvrisLabel,
    specialTypesLabel,
    saveLabel,
    cancelLabel,
    duplicateVin,
    whiteSpaceMsg,
    vrnEmptyMsg,
    ChangeVRN,
    MdmId,
    IsVehicleCalibration,
    ClearInput,
    Next,
    vrnError,
    caseNumber,
    searchExistingCase,
    VRNUpperCase,
    errorOccurred,
    multipleMvris,
    specialType,
    yearRange,
    CaptureVehicleDetails
  }

  specialTypeOptions = [
    { label: 'Agricultural', value: 'Agricultural' },
    { label: 'Bus', value: 'Bus' },
    { label: 'Coach', value: 'Coach' },
    { label: 'Motorhome', value: 'Motorhome' },
    { label: 'Truck', value: 'Truck' },
    { label: 'Other', value: 'Other' }
  ];

  /////////////////

  // @wire(IsConsoleNavigation) isConsoleNavigation;
  // focusedTabInfo;




 

  connectedCallback() {

    //console.log('caseRecordId',this.recordId);
    //console.log('VehicleRecordId',this.recordVehicleId);
    //console.log('VehicleId', this.vehicleId);
   // this.currentFormatedDate = this.getFormattedDate();
   this.dispatchEvent(new FlowAttributeChangeEvent('IsSaveFinish', false));
   const today = new Date();  
   today.setUTCHours(0, 0, 0, 0);
   this.currentFormatedDate = today.toISOString();
    console.log('currentFormatedDate321',this.currentFormatedDate);
    
    if (this.recordVehicleId == '') {
      this.firstScreen = false;
      this.vrnDisabled = false;
      // this.showVrnScreen = false;
    } else {
      this.firstScreen = true;
      this.sldsColoum = "slds-col";
      this.sldsGrid = "slds-grid slds-gutters";
      //  this.showVrnScreen = true;
      this.fetchVehicle();
    }

    if (this.checkEdit == trueLabel) {
      this.firstScreen = false;
      this.vrnDisabled = false;
    }


    this.makeSearch('', this.isMakeSearch) 
  }


  /////////////////////

  handleInputChange(event) {
    this.vrnValue = event.target.value;
    let fieldName = event.currentTarget.dataset.name;
   if(fieldName == this.label.VRNUpperCase ){
    if (this.vrnValue != '') {
      this.vrnButtonDisabled = false;
      this.hideExistingCases = true;
      this.saveDisabled = false;
    } else {
      this.vrnButtonDisabled = true;
      this.hideExistingCases = true;
      this.saveDisabled = true;
    }
  }

  if(fieldName == this.label.registrationAuthorityLabel){
       this.regisTrationValue = event.target.value;
  }

    if(!event.target.checked){
      this.specialTypesDisabled = true;
      this.jsSpecialTypeValue = '';
      console.log('jsSpecialTypeValue',this.jsSpecialTypeValue);

    }else{
      this.specialTypesDisabled = false;
      console.log('jsSpecialTypeValue',this.jsSpecialTypeValue);
    }
     
    if(fieldName == this.label.specialVehicleLabel){
      this.specialVehicleValue = event.target.checked;
    }

    if(fieldName == this.label.specialVehicleLabel){
      this.specialVehicleValue = event.target.checked;
    }

    
    if(fieldName == this.label.IsVehicleCalibration){
      this.isCalibration = event.target.checked;
    }
         
  }

 @wire(duplicateVrnCases, { vrn: '$vrnValue' })
  wiredCases(result) {
    if (result.data && this.vrn !== '' && this.vrn != undefined) {
      this.searchExistingCases(result);
    } else if (result.error) {
      console.error('Error searching existing cases:', result.error);
    }
  }

  // @wire(getMvris,{id : 'abcd'})
  //  wireGetMvris(result) {
  //   this.getMvrisList = result;
  //   console.error('getMvrisList', JSON.stringify(this.getMvrisList));
  // }

  

 /**Old Code Start */

 /* @wire(searchMake,{make : 'abcd'})
    wiredMakeRecords({error,data}){
      if(data){
        console.log('Search Make',JSON.stringify(data));
        this.makeRecordList = data;
        this.uniqueMakeList();
      }
      else if(error){
        console.log('error',error);
      }
    }*/

 /**Old Code End */

   
    
  
 



  searchExistingCases() {
    this.hideExistingCases = false;
    duplicateVrnCases({ vrn: this.vrnValue })
      .then(result => {
        this.existingCases = result.map(record => ({
          Id: record.Id,
          CaseNumber: record.CaseNumber,
          vrnNumber: this.vrnValue

        }));
      })
      .catch(error => {
        console.error('Error searching existing cases:', error);
      });
  }

  /*searchExistingCases() {
    if (this.vrnValue !== '') {
        this.hideExistingCases = false;
        duplicateVrnCases({ vrn: this.vrnValue })
            .then(result => {
              
                this.existingCases = result.map(record => ({
                    Id: record.Id,
                    CaseNumber: record.CaseNumber,
                    vrnNumber: this.vrnValue
              }));
                if (this.existingCases.length === null) {
                  this.showErrorMessage = true;
              } 
            })
            .catch(error => {
                console.error('Error searching existing cases:', error);
            });
    }
}

handleSearchButtonClick(){
  console.log('inside handlebutton ');
  this.searchExistingCases();
}*/


  openRecord(event) {
    console.log('inside openrecord');
    const recordId = event.currentTarget.dataset.recordId;

    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: {
        recordId: recordId,
        actionName: 'view',
      },
    });
  }

  handleCancel(event) {
    var actionClicked = event.target.name;
    // console.log('actionClicked', actionClicked);
    if (actionClicked) {
      this.dispatchEvent(new FlowAttributeChangeEvent('IsCancelled', true));
      if (this.availableActions.find((action) => action === 'NEXT')) {
        const navigateNextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent)
      }
    }
  }
/** Make Selection */

  handleMakeFocus(event){

    this.isSaveDataValidate = true;
   this.isMakeSearch =false;
   this.showMakeField = true; 

   this.showModelDropDown = false;
   this.showBodyDropdown = false;
   this.showYearRangedropDown = false;
   this.showYearDropdown = false;
   //this.makeSearch('', this.isMakeSearch)

  /* searchMake({
    make: '',
    isMakeSearch :  this.isMakeSearch
  }) 
  .then((result) => {
  console.log('makeresultonfocus', JSON.stringify(result));
  this.makeRecordList = result;
  this.showMakeField = true;  
  const map = new Map();  
  this.makeRecordList.forEach(item => {  
      if (!map.has(item.BLN_Make__c)) {  
          map.set(item.BLN_Make__c, item);  
      }  
  });  
  this.uniqueMakes = [...this.currentMakeList] = Array.from(map.values());  
 
  console.log('uniqueMakes321',JSON.stringify(this.uniqueMakes)); // Output the unique array  

    if (this.currentMakeList.length > 7) {
      this.dynamicScrollMake = true;
    } else {
      this.dynamicScrollMake = false;
    }

    if(this.makeRecordList.length == 0){
    
    this.currentMakeList =  [{"BLN_Make__c": Otherlabel }];
  }

  })
  .catch((error) => {
   
  })*/

   
  }

  handleMakeSearch(event){
    this.isMakeSearch =true;
    let searchTerm = event.target.value;
    this.makeValue = searchTerm;
    console.log('search',searchTerm);
    this. makeSearch(searchTerm, this.isMakeSearch)
  }

  makeSearch(searchTerm, isMakeSearch){

    searchMake({
      make: searchTerm,
      isMakeSearch : isMakeSearch
    }) 
    .then((result) => {
    console.log('makeresultSearch', JSON.stringify(result));
    this.makeRecordList = result;
   // this.showMakeField = true;  
    const map = new Map();  
    this.makeRecordList.forEach(item => {  
        if (!map.has(item.BLN_Make__c)) {  
            map.set(item.BLN_Make__c, item);  
        }  
    });  
    this.uniqueMakes = [...this.currentMakeList] = Array.from(map.values());  
   
    console.log('uniqueMakes321',JSON.stringify(this.uniqueMakes)); // Output the unique array  
   
    if (this.currentMakeList.length > 7) {
      this.dynamicScrollMake = true;
    } else {
      this.dynamicScrollMake = false;
    }

    if(this.currentMakeList.length == 0){
      
      this.currentMakeList =  [{"BLN_Make__c": Otherlabel }];
    }

    })
    .catch((error) => {
      //  console.log("error"+JSON.stringify(error))
    })

     /**Old Code Start */
   /* if(searchTerm){
      let exp = new RegExp(searchTerm,'i');
      console.log('search1',searchTerm);

      this.currentMakeList = [...this.uniqueMakes.filter(item => item.BLN_Make__c && exp.test(item.BLN_Make__c))];
      console.log('currentMakeList321', JSON.stringify(this.currentMakeList));
      if(this.currentMakeList.length == 0){
       this.currentMakeList = [{"BLN_Make__c": Otherlabel }];

      }
    }
    else{
     this.currentMakeList = [...this.uniqueMakes];
    }*/
    /**Old Code End */

    if (this.currentMakeList.length > 7) {
      this.dynamicScrollMake = true;
    } else {
      this.dynamicScrollMake = false;
    }
 
  }

    /**Old Code Start */

/*  uniqueMakeList(){
    const map = new Map();  
    this.makeRecordList.forEach(item => {  
        if (!map.has(item.BLN_Make__c)) {  
            map.set(item.BLN_Make__c, item);  
        }  
    });  
    this.uniqueMakes = [...this.currentMakeList] = Array.from(map.values());  
   
    console.log('uniqueMakes321',JSON.stringify(this.uniqueMakes)); // Output the unique array  
} */

  /**Old Code End */

  handleMakeSelection(event){
  //  this.makeValue = '';

   this.makeValue = event.currentTarget.dataset.value;
   

    
    console.log('makeValue',this.makeValue);
    this.modelValue = '';
   this.bodyTypeValue = '';
   this.yearValue = '';
   this.yearRangeValue = '';

    if(this.makeValue != ''){
      this.showMakeField = false;
    }

    this.yearDisabled = false;
    this.yearRangeDisabled = false;
    this.modelDisabled = false;
    //this.colorDisabled = false;
    this.mvrisValue = '';
    this.bodayTypeDisabled = false;

    if(this.makeValue != Otherlabel){
      this.showSpecialVehicleType = false;
      this.specialVeicleDisabled = true;
      this.jsSpecialTypeValue = '';
      this.specialVehicleValue = false;
      }

      this.searchModel(this.makeValue,'',this.isModelSearch);  
  }



  /** Model Selection */

  handleModelFocus(event){
    this.showModelDropDown = true; 
    this.showMakeField = false;
    this.showBodyDropdown = false;
    this.showYearRangedropDown = false;
    this.showYearDropdown = false;
  }



  handleModelSearch(event){
    this.isModelSearch = true;
    let searchModelTerm = event.target.value;
    this.modelValue = searchModelTerm;
    this.showModelTable = true;
    console.log('searchModel',searchModelTerm);
    this.searchModel(this.makeValue,searchModelTerm,this.isModelSearch);
    // Change on request
    if (this.modelValue == '') {
      this.isModelSearch = false;
      this.searchModel(this.makeValue, '', this.isModelSearch)
      this.currentBodyList = [];
      this.currentYearRangeList = [];
      this.currentYearList = [];
      this.yearValue = '';
      this.yearRangeValue = '';
      this.bodyTypeValue = '';
    }
  }

searchModel(makeValue,searchModelTerm,isModelSearch){
    searchModel({
      make: makeValue,
      model: searchModelTerm,
      isModelSearch: isModelSearch
    })
    .then(res => {
      this.modelRecordList = res;
     // this.showModelDropDown = true;
    const map = new Map();  
    this.modelRecordList.forEach(item => {  
        if (!map.has(item.BLN_Model__c)) {  
            map.set(item.BLN_Model__c, item);  
        }  
    });  
    this.uniqueModels = [...this.currentModelList] = Array.from(map.values());  
    if(this.currentModelList.length == 0){
      this.currentModelList = [{"BLN_Model__c": Otherlabel }];
   
    }

    
    if (this.currentModelList.length > 7) {
      this.dynamicScrollModel = true;
    } else {
      this.dynamicScrollModel = false;
    }
   
    console.log('uniqueModels321',JSON.stringify(this.uniqueModels)); // Output the unique array  
      
     
      console.log('modelRecordList321',JSON.stringify(this.modelRecordList));
    })
    .catch(error =>{
      console.log('error',error);
    })

    


    if (this.currentModelList.length > 7) {
      this.dynamicScrollModel = true;
    } else {
      this.dynamicScrollModel = false;
    }
   
     console.log('currentModeList123', JSON.stringify(this.currentModelList));

  }

  handleModelBlur(event){
   // window.setTimeout(() => {
    if(this.modelValue != ''){
      this.showModelDropDown = false;
    }
   // },1000);
  }


  /** Body Type Selection */

  handleBodyFocus(){
    this.showBodyDropdown = true;
    this.showModelDropDown = false; 
    this.showMakeField = false;
    this.showYearRangedropDown = false;
    this.showYearDropdown = false;
  }

    


  
  handleBodySearch(event){
    this.isBodySearch = true;
    let searchBodyTerm = event.target.value;
    this.bodyTypeValue = searchBodyTerm;
   this.bodyTypeSearch(this.makeValue,this.modelValue,searchBodyTerm,this.isBodySearch );

    // Change on request this.bodyTypeValue == '' && 
    if (this.bodyTypeValue.trim() == '' || this.bodyTypeValue == '') {
      this.isModelSearch = false;
      this.bodyTypeSearch(this.makeValue, this.modelValue, '', this.bodyTypeValue)
      this.currentYearRangeList = [];
      this.currentYearList = [];
      this.yearValue = '';
      this.yearRangeValue = '';
    }

  }


 bodyTypeSearch(makeValue,modelValue,searchBodyTerm,isBodySearch){

    searchBody({
      make: makeValue,
      model : modelValue,
      body:searchBodyTerm,
      isBodySearch:isBodySearch 
    })
    .then(res => {
      this.bodyRecordList = res;

      const map = new Map();
      this.bodyRecordList.forEach(item => {
        if(!map.has(item.BLN_BodyType__c)){
          map.set(item.BLN_BodyType__c,item);
        }
      });
      this.uniqueBodyTypes = [...this.currentBodyList] = Array.from(map.values());

      console.log('bodyRecordList4321',JSON.stringify(this.uniqueBodyTypes));

      if (this.currentBodyList.length > 7) {
        this.dynamicScrollBody = true;
      } else {
        this.dynamicScrollBody = false;
      }
      
      if (this.currentBodyList.length == 0){
        this.currentBodyList = [{"BLN_BodyType__c": Otherlabel }];
      }
      
      this.bodayTypeDisabled = false;

    })
    .catch(error => {
      console.log('error',error);
    })

    
  }

 
 /**Year Selection */

/*getFormattedDate() {  
  const date = new Date();  
  const year = date.getUTCFullYear();  
  const month = String(date.getUTCMonth() + 1).padStart(2, '0');  
  const day = String(date.getUTCDate()).padStart(2, '0');  
  const hours =  '00';                               //String(date.getUTCHours()).padStart(2, '0');  
  const minutes = '00';                                    //String(date.getUTCMinutes()).padStart(2, '0');  
  const seconds = '00';  //String(date.getUTCSeconds()).padStart(2, '0');  
  const milliseconds = '000';  //String(date.getUTCMilliseconds()).padStart(3, '0');  
  const timezoneOffset = '+0000';  

  return `${year}-${month}-${day}T${hours}:${minutes}:${seconds}.${milliseconds}${timezoneOffset}`;  
} */


/*getFormattedDate() {  
  const date = new Date();  
  const isoString = date.toISOString(); // e.g., "2023-04-29T09:41:54.123Z"  
  const [datePart, timePart] = isoString.split('T'); // Split into date and time  
  const [time, millisecondsAndZone] = timePart.split('.'); // Split time and milliseconds with zone  
  const milliseconds = millisecondsAndZone.slice(0, 3); // Get the milliseconds part  
  const timezoneOffset = '+0000';  

  return `${datePart}T${time}.${milliseconds}${timezoneOffset}`;  
}*/



 handleYearRangeFocus(){
    this.numberArray = [];
  this.showYearRangedropDown = true;
  this.showYearDropdown = false;
  this.yearValue = '';
  this.showModelDropDown = false; 
  this.showMakeField = false;
  this.showBodyDropdown = false;
}

handleYearRangeSearch(event){
  let searchYearParam = event.target.value;
  this.yearRangeValue = searchYearParam;
  this.isYearSearch = true;
  this.searchYearResult(this.makeValue, this.modelValue, this.bodyTypeValue, searchYearParam, this.isYearSearch);

    // Change on request
    if (this.yearRangeValue == '') {
      this.isYearSearch = false;
      this.searchYearResult(this.makeValue, this.modelValue, this.bodyTypeValue, '', this.isYearSearch)
      this.currentYearList = [];
      this.yearValue = '';
    }
}



  searchYearResult(makeValue,modelValue,bodyTypeValue,searchYearParam,isYearSearch){
    searchYear({
      make : makeValue,
      model : modelValue,
      bodyType : bodyTypeValue,
      year : searchYearParam,
      isYearSearch : isYearSearch
    })
      .then((result) => {
        this.yearRangeRecordList = result;
        console.log('yearRecordListbefore',JSON.stringify(this.yearRangeRecordList));
        
      if(this.yearRangeRecordList.length != 0){
        
        this.yearRangeRecordList.forEach(ele => {
          if (!('BLN_AvailableEndDate__c' in ele)) {  
            ele.BLN_AvailableEndDate__c = this.currentFormatedDate;  
        }
        });
}

this.yearRangeRecordList.forEach(ele=>{
  let vehiNote = '';

  if(ele.BLN_VehicleNote__c != '' && ele.BLN_VehicleNote__c != undefined){
    vehiNote = ele.BLN_VehicleNote__c;
            this.noteTruncatedLength = vehiNote //this.truncateString(vehiNote, parseInt(TruncateRange));

  }else{
    this.noteTruncatedLength = '';
  }
 
 
  let isoDateStart = ele.BLN_AvailableStartDate__c;  
  let isoDateEnd  = ele.BLN_AvailableEndDate__c;
  
   
  let dateStart = new Date(isoDateStart); 
  let dateEnd = new Date(isoDateEnd); 
    
  let AvailbleStartDate = dateStart.getFullYear();  
  let AvailbleEndDate = dateEnd.getFullYear();  

  ele.BLN_AvailableStartDate__c = AvailbleStartDate;
  ele.BLN_AvailableEndDate__c = AvailbleEndDate;
  ele.BLN_ConcatVal = AvailbleStartDate+'-'+AvailbleEndDate+' '+this.noteTruncatedLength; 
})

console.log('yearRecordListOnlyYear',JSON.stringify(this.yearRangeRecordList));

let yearRangeUnique = [];


 

 console.log('yearRecordListafter',JSON.stringify(this.yearRangeRecordList));
 const map = new Map();
 this.yearRangeRecordList.forEach(item => {
  if(!map.has(item.BLN_ConcatVal)){
    map.set(item.BLN_ConcatVal,item);
  }
});
this.currentYearRangeList = Array.from(map.values());

console.log('currentYearRangeList321',JSON.stringify(this.currentYearRangeList));



 


        if (this.currentYearRangeList.length > 7) {
          this.dynamicScrollYearRange = true;
        } else {
           this.dynamicScrollYearRange = false;
        }
      
      if(this.currentYearRangeList.length == 0){
        
       this.currentYearRangeList = [{
        "Id": "a34Fg000008cyhhIAA",
        "BLN_AvailableStartDate__c": ' ',
        "BLN_VehicleNote__c": ' ',
        "BLN_AvailableEndDate__c": '',
        "BLN_ConcatVal" : 'Other'
         }];
      }
        //this.yearDisabled = false;
        this.yearRangeDisabled = false;
        console.log('currentYearList',JSON.stringify(this.currentYearRangeList));
      })
      .catch((error) => {
        console.log("error in year" + JSON.stringify(error))
      });  
  }


  truncateString(str, maxLength) {  
    if (str.length > maxLength) {  
        return str.substring(0, maxLength) + '...';  
    }  
    return str;  
}

  handleYearFocus(){
    this.currentYearList = this.numberArray;
   //if(this.currentYearList.length != 0){
    this.showYearDropdown = true;
    this.showModelDropDown = false; 
    this.showMakeField = false;
    this.showBodyDropdown = false;
    this.showYearRangedropDown = false;
    
   //}

        if (this.currentYearList.length > 7) {
          this.dynamicScrollYear = true;
        } else {
           this.dynamicScrollYear = false;
        }
      
      if(this.currentYearList.length == 0){
    this.currentYearList = [Otherlabel];
  }

  }

  handleYearSearch(event){
    let searchTerm = event.target.value
    this.yearValue = searchTerm;
    if(searchTerm){
      let exp = new RegExp(searchTerm,'i');
      console.log('search1',searchTerm);

      this.currentYearList = [...this.numberArray.filter(item => item && exp.test(item))];
      console.log('currentMakeList321', JSON.stringify(this.currentYearList));
      if(this.currentYearList.length == 0){
       this.currentYearList = [Otherlabel];

      }
    }
    else{
     this.currentYearList = [...this.numberArray];
    }

    if (this.currentYearList.length > 7) {
      this.dynamicScrollYear = true;
    } else {
      this.dynamicScrollYear = false;
    }
  }

handleYearBlur(){
  window.setTimeout(() => {
    this.showYearDropdown = false;
  },1000);
}

  handleBodyBlur(){
    window.setTimeout(() => {
    this.showBodyDropdown = false;
    },1000)
  }

  handleResultClick(event) {


    if (event.currentTarget.dataset.name == modelLabel) {
      this.modelValue = event.currentTarget.dataset.value;
      this.showModelTable = false;
      this.mvrisValue = '';
      this.yearValue = '';
      this.yearRangeValue = '';
      this.bodyTypeValue = '';
      this.externalId = '';
      if(this.modelValue != ''){
        this.showModelDropDown = false;
      }
      this.bodyTypeSearch(this.makeValue,this.modelValue,'',this.isBodySearch );
    }

    if (event.currentTarget.dataset.name == bodyType) {
    //  this.template.querySelector(".bodyTypeValue").value = event.currentTarget.dataset.value;
      this.bodyTypeValue = event.currentTarget.dataset.value;
      this.showBodyDropdown = false;
      this.mvrisValue = '';
      this.yearValue = '';
      this.yearRangeValue = '';
      this.externalId = '';
      if(this.bodyTypeValue != ''){
        this.showBodyDropdown = false;
      }
     // this.handleYearResult();
      
      this.searchYearResult(this.makeValue, this.modelValue, this.bodyTypeValue, '', this.isYearSearch);
    }

    if (event.currentTarget.dataset.name == yearRange) {
      // this.template.querySelector(".yearValue").value = event.currentTarget.dataset.value;
      
       this.numberArray = [];
      let startDate = event.currentTarget.dataset.startdate;
      let endDate = event.currentTarget.dataset.enddate;
      let vehiclenote = '';
      let concatValue = event.currentTarget.dataset.concat;
      if(event.currentTarget.dataset.note != undefined && event.currentTarget.dataset.note != ''){
        vehiclenote = event.currentTarget.dataset.note;
      }else{
        vehiclenote = '';
      }

      if(concatValue != 'Other'){
       this.yearRangeValue = startDate+'-'+endDate+' '+vehiclenote;
      }else{
        this.yearRangeValue = 'Other';
        startDate = '';
        endDate = '';
      }
       this.showYearRangedropDown = false;
       this.mvrisValue = '';

      this.pushNumbersInRange(startDate,endDate);
     }



    if (event.currentTarget.dataset.name == yearLabel) {
     // this.template.querySelector(".yearValue").value = event.currentTarget.dataset.value;
      this.yearValue = event.currentTarget.dataset.value;
     
      if(this.yearValue != ''){
        this.showYearDropdown =false;
       
        searchMDMId({
          make: this.makeValue,
          model: this.modelValue,
          bodyType: this.bodyTypeValue,
         
        })
    
          .then((data) => {
            console.log('dataMDMId',JSON.stringify(data));

            this.externalId = data[0].BLN_MDMExternalID__c
            // data.forEach((element) => {
            //     this.externalId = element.BLN_MDMExternalID__c;
            // });
          })
          .catch((error) => {
    
          })

      }
  

      this.mvrisValue = '';
    }

    if (event.currentTarget.dataset.name == colorLabel) {
    //  this.template.querySelector(".colorValue").value = event.currentTarget.dataset.value;
      this.colorValue = event.currentTarget.dataset.value;
      
      this.mvrisValue = '';
    }

    if (this.bodyTypeValue != '' && this.modelValue != '' && this.makeValue != '' && this.yearValue != '') {
      this.searchSpecialVeicle();
    }

    if (this.makeValue == Otherlabel && this.modelValue == Otherlabel && this.bodyTypeValue == Otherlabel && this.yearValue == Otherlabel) {
      this.showSpecialVehicleType = true;
    
      this.specialVeicleDisabled = false;
    
    } else {
      this.showSpecialVehicleType = false;
    
      this.specialVeicleDisabled = true;
   
    }

 

  }

  pushNumbersInRange(start, end) {  
   let star = parseInt(start);
   
    if(start != '' && end != ''){
    for (let i = star; i <= end; i++) {  
        this.numberArray.push(i);  
    }  
  }else{
    this.numberArray = [];
  }
    console.log('numberArray',this.numberArray);  
}


  handleComboboxChange(event) {

    if (event.currentTarget.dataset.name == specialTypesLabel) {
      this.jsSpecialTypeValue = event.target.value;
      console.log('jsSpecialTypeValue',this.jsSpecialTypeValue);
    }

  }

  searchSpecialVeicle() {
    this.specialVehicleMap = [];
    if (this.template.querySelector(".makeValue").value != null && this.template.querySelector(".makeValue").value != '') {
      this.specialVehicleMap.push({
        key: makeLabel,
        value: this.template.querySelector(".makeValue").value
      });
    } else {
      this.specialVehicleMap.push({
        key: makeLabel,
        value: ''
      });
    }

    if (this.template.querySelector(".modelValue").value != null && this.template.querySelector(".modelValue").value != '') {
      this.specialVehicleMap.push({
        key: modelLabel,
        value: this.template.querySelector(".modelValue").value
      });
    } else {
      this.specialVehicleMap.push({
        key: modelLabel,
        value: ''
      });
    }

    if (this.template.querySelector(".bodyTypeValue").value != null && this.template.querySelector(".bodyTypeValue").value != '') {
      this.specialVehicleMap.push({
        key: bodyType,
        value: this.template.querySelector(".bodyTypeValue").value
      });
    } else {
      this.specialVehicleMap.push({
        key: bodyType,
        value: ''
      });
    }

    if (this.template.querySelector(".yearValue").value != null && this.template.querySelector(".yearValue").value != '') {
      this.specialVehicleMap.push({
        key: yearLabel,
        value: this.template.querySelector(".yearValue").value
      });
    } else {
      this.specialVehicleMap.push({
        key: yearLabel,
        value: ''
      });
    }

    searchSpecialvehicle({
      specialVData: JSON.stringify(this.specialVehicleMap)
    })

      .then((data) => {
        // console.log('Result', JSON.stringify(data));

        data.forEach(element => {

          if (element.BLN_SpecialVehicle__c == true) {
           // this.template.querySelector(".specialVehicle").checked = true;
           this.specialVehicleValue = true
          } else {
           // this.template.querySelector(".specialVehicle").checked = false;
           this.specialVehicleValue = false; 
          }


        })
      })
      .catch((error) => {

      })

  }




  checkWhitespace(str) {
    return /\s/.test(str);
  }


  searchVehicle() {
    this.hideExistingCases = true;
    let str = this.vrnValue;
    let recordId = '';

    if (this.checkWhitespace(str)) {
      // alert("Remove space between entered VRN");
      LightningAlert.open({
        message: this.label.whiteSpaceMsg,
        theme: 'error', // a red theme intended for error states
        label: 'Error!', // this is the header text
      });
      return;
    }

    this.spinnerSiwtch = true;
    if (this.recordId != '') {
      recordId = this.recordId;
    }
    if (this.vehicleId != '') {
      recordId = this.vehicleId;
    }

    serachVRN({
      inputText: this.vrnValue,
      recordId: recordId
    })
      .then((result) => {
        let responseVRN = '';
        if(result.length != 0 ){
        responseVRN = result[0].vrn.trimEnd();
        }
        /*result.forEach(element => {
          responseVRN = element.vrn;
        });*/

        if(responseVRN.toLowerCase() != this.vrnValue.toLowerCase() && responseVRN != ''){
          this.firstScreen = true;
          this.showSearchbutton = false;
           this.sldsColoum = "slds-col";
           this.sldsGrid = "slds-grid slds-gutters";
           this.spinnerSiwtch = false;
          // this.makeDisabled = false;
           this.saveDisabled = false;
           console.log('before make');
          // window.setTimeout(()=>{
             this.makeValue =  '';
           
            this.specialVehicleValue = false;
             this.mvrisValue = '';
             this.vinValue = '';
         
             this.modelValue = '';
            this.bodyTypeValue = '';
            this.yearValue = '';
             this.regisTrationValue = '';
             this.colorValue = '';
             this.specialVeicleDisabled = true;
             this.showSpecialVehicleType = false;
         this.vinValue = '';
         this.mvrisValue = '';
         this.regisTrationValue = '';
         this.openmodalError = 'true';
         this.isCalibration = false;
          return;
        }

        console.log('searched result'+ JSON.stringify(result));
        
        if (result.length != 0) {
          this.saveDisabled = false;
          this.showVrnScreen = true;
          this.firstScreen = true;
          this.showSearchbutton = false;
          this.spinnerSiwtch = false;
          this.vrnDisabled = false;
          this.sldsColoum = "slds-col";
          this.sldsGrid = "slds-grid slds-gutters";
          if (result.length == 0) {
            this.makeDisabled = false;
          }
          let mvrisRes = '';
         
         if(result.length == 2){
         
            if (!result[1].hasOwnProperty('AvailableEndDate')) {  
              result[1].AvailableEndDate = this.currentFormatedDate; 
          } 
            //  window.setTimeout(() => {
            result.forEach(element => { 
            



              if (element.Make != '' && element.Make != undefined) {
               // this.template.querySelector(".makeValue").value = element.Make;
                this.makeValue = element.Make;
                this.makeDisabled = false;
              } else {
                this.makeDisabled = false;
              //  this.template.querySelector(".makeValue").value = '';
                this.makeValue = '';
              }

              if (element.Model != '' && element.Model != undefined) {
               // this.template.querySelector(".modelValue").value = element.Model;
                this.modelValue = element.Model;
                this.modelDisabled = false;
              } else {
             //   this.template.querySelector(".modelValue").value = '';
                this.modelValue = '';
              }

              if (element.BodyType != '' && element.BodyType != undefined) {
               // this.template.querySelector(".bodyTypeValue").value = element.BodyType;
                this.bodyTypeValue = element.BodyType;
                this.bodayTypeDisabled = false;
              } else {
               // this.template.querySelector(".bodyTypeValue").value = '';
                this.bodyTypeValue = '';
              }

              if (element.Year != '' && element.Year != undefined) {
              //  this.template.querySelector(".yearValue").value = element.Year;
               // this.yearDisabled = false;
                this.yearValue = element.Year;
              }

              if (element.Color != '' && element.Color != undefined) {
                //this.template.querySelector(".colorValue").value = element.Color;
                //this.colorDisabled = false;
                this.colorValue = element.Color;
              } 
              if (element.Vin != '' && element.Vin != undefined) {
                this.vinValue = element.Vin;
              }

              if (element.vrn != '' && element.vrn != undefined) {
                this.vrnValueA = element.vrn;
              } 

              if (element.MVRIS != '' && element.MVRIS != undefined) {
                this.mvrisValue = element.MVRIS;
              }

              if (element.RegistrationAuthority != '' && element.RegistrationAuthority != undefined) {
                this.regisTrationValue = element.RegistrationAuthority;
              } 
              if (element.SpecialVehicle == trueLabel) {
                this.specialVehicleValue = element.SpecialVeicle;
                //this.template.querySelector(".specialVehicle").checked = true;
              }

              if (element.externalId != '' && element.externalId != undefined) {
                this.externalId = element.externalId;
                // this.template.querySelector(".mdmValue").value = element.ExternalId;
              }

              if (element.IsVehicleCalibration == trueLabel) {
                this.isCalibration = element.IsVehicleCalibration;
              //  this.template.querySelector(".iscalibration").checked = true;
              } else {
                this.isCalibration = false;
              }


              // Change Under FOUK-12329 Start
           
             if (element.AvailableStartDate != '' && element.AvailableStartDate != undefined) {
                 
              if(element.VehicleNote != '' && element.VehicleNote != undefined){
                this.noteTruncatedLength = element.VehicleNote;
              }else{
                this.noteTruncatedLength = '';
              }
              
              let dateStart = new Date(element.AvailableStartDate); 
              let AvailbleStartDate = dateStart.getFullYear();  
              let dateEnd

              if(element.AvailableEndDate != '' && element.AvailableEndDate != undefined){
                  dateEnd = new Date(element.AvailableEndDate); 
                 }

                  let AvailbleEndDate = dateEnd.getFullYear(); 
                  this.yearRangeValue = AvailbleStartDate +'-'+AvailbleEndDate+' '+this.noteTruncatedLength;
                
              
               this.yearDisabled = false;
             } else {
               this.yearRangeValue = '';
             }
              // Change Under FOUK-12329 End

            })

        //  }, 100);
     
        } else{

          const event = new ShowToastEvent({
            message: this.label.multipleMvris,
            variant: 'info',
            mode: 'dismissable'
          });
          this.dispatchEvent(event);
          this.externalId = ''
          this.yearValue = '';
          this.modelValue = '';
          this.bodyTypeValue = '';
          this.makeValue = '';
            this.yearRangeValue = '';
          this.isCalibration = false;
          result.forEach(element => {
          if (element.vrn != '' && element.vrn != undefined) {
            this.vrnValueA = element.vrn;
              }

              if (element.MVRIS != '' && element.MVRIS != undefined) {
                this.mvrisValue = element.MVRIS;
              }

              if (element.RegistrationAuthority != '' && element.RegistrationAuthority != undefined) {
                this.regisTrationValue = element.RegistrationAuthority;
              }

          if (element.Vin != '' && element.Vin != undefined) {
            this.vinValue = element.Vin;
          }

          if (element.Color != '' && element.Color != undefined) {
            //this.template.querySelector(".colorValue").value = element.Color;
            //this.colorDisabled = false;
            this.colorValue = element.Color;
          } 
        })
        }

        } else {
  
          this.firstScreen = true;
           this.showSearchbutton = false;
            this.sldsColoum = "slds-col";
            this.sldsGrid = "slds-grid slds-gutters";
            this.spinnerSiwtch = false;
           // this.makeDisabled = false;
            this.saveDisabled = false;
            console.log('before make');
           // window.setTimeout(()=>{
              this.makeValue =  '';
            
             this.specialVehicleValue = false;
              this.mvrisValue = '';
              this.vinValue = '';
          
              this.modelValue = '';
             this.bodyTypeValue = '';
             this.yearValue = '';
              this.regisTrationValue = '';
              this.colorValue = '';
              this.specialVeicleDisabled = true;
              this.showSpecialVehicleType = false;
          this.vinValue = '';
          this.mvrisValue = '';
          this.regisTrationValue = '';
          this.yearRangeValue = '';
          this.openmodalError = 'true';
          this.isCalibration = false;

           // },500);

        }

      })

      .catch((error) => {
        if (error.length == 0) {
          this.spinnerSiwtch = false;
        }
        // console.log("errorsEARCH"+JSON.stringify(error))
      })


  }
  /* @wire(duplicateVrnCases, { vrndata: '$str' })
   wiredCases({ error, data }) {
       if (data) {
           console.log('Retrieved data:', data);
         
       } else if (error) {
           // Handle errors if any
           console.error('Error fetching  Cases:', error);
       } 
   }*/

  fetchVehicle() {
    this.vehicleid = '';
    if (this.recordVehicleId != '') {
      this.vehicleid = this.recordVehicleId;
    }
    if (this.vehicleId != '') {
      this.vehicleid = this.vehicleId;
    }

    getVehicle({
      vehicleId: this.vehicleid
    })
      .then((result) => {
        console.log('result Vehicle', JSON.stringify(result));
        if (result.lenght != 0) {
          this.saveDisabled = false;
        }


        this.sldsColoum = "slds-col";
        this.sldsGrid = "slds-grid slds-gutters";
        if (this.checkEdit == trueLabel) {
          this.vrnDisabled = false;
        }/* else{
            this.vrnDisabled = true;
           } */
        this.showSearchbutton = false;
        result.forEach(element => {

          if (element.BLN_MakeOfVehicle__c != '' && element.BLN_MakeOfVehicle__c != undefined) {
          //  this.template.querySelector(".makeValue").value = element.BLN_MakeOfVehicle__c;
            this.makeValue = element.BLN_MakeOfVehicle__c;
            this.makeDisabled = false;

          } else {
            this.makeDisabled = false;
           // this.template.querySelector(".makeValue").value = '';
            this.makeValue = '';
          }

          if (element.BLN_ModelOfVehicle__c != '' && element.BLN_ModelOfVehicle__c != undefined) {
          //  this.template.querySelector(".modelValue").value = element.BLN_ModelOfVehicle__c;
            this.modelValue = element.BLN_ModelOfVehicle__c;



          } else {
          //  this.template.querySelector(".modelValue").value = '';
            this.modelValue = '';
          }

          if (element.BLN_BodyType__c != '' && element.BLN_BodyType__c != undefined) {
          //  this.template.querySelector(".bodyTypeValue").value = element.BLN_BodyType__c;
            this.bodyTypeValue = element.BLN_BodyType__c;

          } else {
          //  this.template.querySelector(".bodyTypeValue").value = '';
            this.bodyTypeValue = '';
          }

          if (element.BLN_Year__c != '' && element.BLN_Year__c != undefined) {
          //  this.template.querySelector(".yearValue").value = element.BLN_Year__c;

            this.yearValue = element.BLN_Year__c;
          } else {
           // this.template.querySelector(".yearValue").value = '';
            this.yearValue = '';
          }

          if (element.BLN_VehicleNote__c != '' && element.BLN_VehicleNote__c != undefined) {
              this.yearRangeValue = element.BLN_VehicleNote__c;
            } else {
              this.yearRangeValue = '';
            }


          if (element.BLN_Colour__c != '' && element.BLN_Colour__c != undefined) {
          //  this.template.querySelector(".colorValue").value = element.BLN_Colour__c;



            this.colorValue = element.BLN_Colour__c;
          } else {
           // this.template.querySelector(".colorValue").value = '';
            this.colorValue = '';
          }
          if (element.BLN_VIN__c != '' && element.BLN_VIN__c != undefined) {
            this.vinValue = element.BLN_VIN__c;
          } else {
            this.vinValue = '';
          }

          if (element.BLN_VehicleRegNumber__c != '' && element.BLN_VehicleRegNumber__c != undefined) {
            this.vrnValueA = element.BLN_VehicleRegNumber__c;
          } else {
            this.vrnValueA = '';
          }

          if (element.BLN_MVRIS__c != '' && element.BLN_MVRIS__c != undefined) {
            this.mvrisValue = element.BLN_MVRIS__c;
          } else {
            this.mvrisValue = '';
          }

          if (element.BLN_RegistrationAuthority__c != '' && element.BLN_RegistrationAuthority__c != undefined) {
            this.regisTrationValue = element.BLN_RegistrationAuthority__c;
          } else {
            this.regisTrationValue = '';
          }
          if (element.BLN_SpecialVehicle__c == true) {
            this.specialVehicleValue = element.BLN_SpecialVehicle__c;
           // this.template.querySelector(".specialVehicle").checked = true;
          }

          if (element.BLN_MDMID__c != '' && element.BLN_MDMID__c != undefined) {
            this.externalId = element.BLN_MDMID__c;
            // this.template.querySelector(".mdmValue").value = element.BLN_MDMID__c;
          } else {
            this.externalId = '';
          }

          if (element.BLN_IsVehicleCalibrationRequired__c == true) {
            this.isCalibration = element.BLN_IsVehicleCalibrationRequired__c;
           // this.template.querySelector(".iscalibration").checked = true;
          } else {
            this.isCalibration = false;
          }
        })
      })
      .catch((error) => {
        console.log('FetchVehicle Error', JSON.stringify(error));
      });
  }

  clearInput() {

    this.template.querySelector(".makeValue").value = '';
    this.template.querySelector(".modelValue").value = '';
    this.template.querySelector(".bodyTypeValue").value = '';
    this.template.querySelector(".yearValue").value = '';
    this.template.querySelector(".colorValue").value = '';
    this.template.querySelector(".vrnValue").value = '';
    this.template.querySelector(".vinValue").value = '';
    this.template.querySelector(".regisTrationValue").value = '';
    //this.template.querySelector(".specialVehicle").checked = false;
    this.specialVehicleValue = false;
    this.vinValue = '';
    this.mvrisValue = '';
    this.regisTrationValue = '';
    this.vrnValueA = '';
    this.modelValue = '';
    this.makeValue = '';
    this.bodyTypeValue = '';
    this.vrnValueA = '';
    this.yearValue = '';
    this.yearRangeValue = '';
    this.colorValue = '';
    this.vinValue = '';
    this.saveDisabled = true;
    //this.template.querySelector(".mdmValue").value = '';
    this.isCalibration = false;
  }

  handleSave() {

  if(this.isSaveDataValidate == true){
    let makeMap = this.currentMakeList.map(vehicle => vehicle.BLN_Make__c); 
    let makeVal =  makeMap.includes(this.makeValue);
    if( makeVal == false && this.currentMakeList.length != 0){
      this.makeValue = '';
  }
    }

    let modelMap = this.currentModelList.map(vehicle => vehicle.BLN_Model__c); 
    let bodyMap = this.currentBodyList.map(vehicle => vehicle.BLN_BodyType__c); 
    let yearMap = this.currentYearList.map(vehicle => vehicle); 
    let yearRangeMap = this.currentYearRangeList.map(vehicle => vehicle.BLN_ConcatVal );

    
    let modelVal = modelMap.includes(this.modelValue);
    let bodyVal = bodyMap.includes(this.bodyTypeValue);
    let yearVal = yearMap.includes(parseInt(this.yearValue));
    let yearrangeVal = yearRangeMap.includes(this.yearRangeValue);

   this.isSaveDataValidate = false;
   


    if(modelVal == false && this.currentModelList.length != 0){
      
      this.modelValue = '';
    }

    if(bodyVal == false && this.currentBodyList.length != 0){
     
      this.bodyTypeValue = '';
    }

    if(yearVal == false && this.currentYearList.length != 0){
      this.yearValue = '';
    }
  
    if(yearrangeVal == false && this.currentYearRangeList.length != 0){
      this.yearRangeValue = '';
    }
  
  

    this.handleSaveMap = [];

    if (this.jsSpecialTypeValue != '') {
      this.handleSaveMap.push({
        key: specialType,
        value: this.jsSpecialTypeValue
      });
    }

    if (this.makeValue != '') {
      
      this.handleSaveMap.push({
        key: makeLabel,
        value: this.makeValue
      });
    }
    if (this.modelValue != '') {
      this.handleSaveMap.push({
        key: modelLabel,
        value: this.modelValue
      });
    }
    if (this.bodyTypeValue != '') {
      this.handleSaveMap.push({
        key: bodyType,
        value: this.bodyTypeValue
      });
    }

    if (this.vrnValueA != '') {
      this.handleSaveMap.push({
        key: vrnLabel,
        value: this.vrnValueA
      });
    } else {
      this.handleSaveMap.push({
        key: vrnLabel,
        value: this.template.querySelector('.vrnValue').value
      });
    }

    if (this.yearValue != '') {
      this.handleSaveMap.push({
        key: yearLabel,
        value: this.yearValue.toString()
      });
    }

    if(this.yearRangeValue != ''){
      this.handleSaveMap.push({
        key: yearRange,
        value: this.yearRangeValue
      });
    }


    if (this.colorValue != '') {
      this.handleSaveMap.push({
        key: colour,
        value: this.colorValue
      });
    }

    if (this.vinValue != '') {
      this.handleSaveMap.push({
        key: vinLabel,
        value: this.vinValue
      });
    }

    if (this.specialVehicleValue != null) {
      this.handleSaveMap.push({
        key: vehicleSpecial,
        value: this.specialVehicleValue.toString()
      });
    }

 

    if (this.regisTrationValue != '') {
      this.handleSaveMap.push({
        key: regAuth,
        value: this.regisTrationValue
      });
    }

    if (this.mvrisValue != '') {
      this.handleSaveMap.push({
        key: mvris,
        value: this.mvrisValue
      });
    }
    console.log('this.externalId---->', this.externalId);
    if (this.externalId != '') {
      this.handleSaveMap.push({
        key: externalIdlabel,
        value: this.externalId
      });
    }

    if (this.isCalibration != null) {
      this.handleSaveMap.push({
        key: isCalibrationlabel,
        value: this.isCalibration.toString()
      });
    }

    this.spinnerSiwtch = true;
    let recordId = ''
    if (this.recordId != '') {
      recordId = this.recordId;
    }
    if (this.vehicleId != '') {
      recordId = this.vehicleId;
    }

    if (this.recordId != '') {
      console.log('handleSave Map--->', JSON.stringify(this.handleSaveMap));
      createVehicle({
        vehicleData: JSON.stringify(this.handleSaveMap),
        recordId: recordId
      })

        .then((result) => {
          console.log('createVehicle Result', JSON.stringify(result));
          if (result.includes(duplicateValue)) { // if(result.includes('failed to Insert/Update Vehicle'))
            this.spinnerSiwtch = false;
            const event = new ShowToastEvent({
              message: this.label.duplicateVin + ' : ' + this.vinValue,
              variant: 'Error',
              mode: 'dismissable'
            });
            this.dispatchEvent(event);
          } else {
            if (result != '' && result != null && !result.includes(duplicateValue) && !result.includes(insufficientAccess) && !result.includes(conversion)) {
              this.spinnerSiwtch = false;
              ////////
              const event = new ShowToastEvent({
                message: result,
                variant: 'success',
                mode: 'dismissable'
              });
              this.dispatchEvent(event);
              ///////////////////

            } else {
              this.spinnerSiwtch = false;
            }
          }
          this.dispatchEvent(new FlowAttributeChangeEvent('IsSaveFinish', true));
          this.isPdsFlow = true;
          this.isFlowHeader = true;

         

         /* if (this.availableActions.find((action) => action === 'NEXT')) {
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent)
          } */

        })
        .catch((error) => {
          // console.log("error"+JSON.stringify(error))
        })

    }

    if (this.vehicleId != '') {
      insertEditVehicle({
        vehicleData: JSON.stringify(this.handleSaveMap),
        recordId: recordId
      })

        .then((result) => {
          //console.log('insertEditVehicle Result', JSON.stringify(result));   
          if (result.includes(duplicateValue)) {
            this.spinnerSiwtch = false;
            const event = new ShowToastEvent({
              message: this.label.duplicateVin + ' : ' + this.vinValue,
              variant: 'Error',
              mode: 'dismissable'
            });
            this.dispatchEvent(event);
          } else {
            if (result != '' && result != null && !result.includes(duplicateValue) && !result.includes(insufficientAccess)) {
              this.spinnerSiwtch = false;
              ////////
              const event = new ShowToastEvent({
                message: result,
                variant: 'success',
                mode: 'dismissable'
              });
              this.dispatchEvent(event);
              ///////////////////

            }

          }
          this.isPdsFlow = false;
          this.dispatchEvent(new FlowAttributeChangeEvent('IsSaveFinish', true));
          if (this.availableActions.find((action) => action === 'NEXT')) {
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent)
          }

          //window.setTimeout(() => {
          // window.open('https://belronint--ukdev2.sandbox.lightning.force.com'+this.recordPageUrl);
          //   window.location.reload()
          //   }, 2000);




        })
        .catch((error) => {
          console.log("error" + JSON.stringify(error))
        })

    }
    //   }
    // }
  }

  changeVrn() {

    this.showVrnScreen = false;
    this.vrnButtonDisabled = true;
    this.showSearchbutton = true;
    this.firstScreen = false;
    this.vrnValue = '';
    this.vrnDisabled = false;
    this.vrnValueA = '';
    this.sldsColoum = '';
    this.sldsGrid = '';
    this.showBodyDropdown = false;
    this.showYearRangedropDown = false;
    this.showYearDropdown = false;
    this.showModelDropDown = false;
    this.showMakeField = false;

  }


  renderedCallback() {

    if (this.firstScreen == true) {

      if (this.dynamicScrollMake == true && this.showMakeField == true) {
        let makeScroll = this.template.querySelector(".makeScroll");
        makeScroll.classList.add(dropDownMenu);
    
      } else {
        if (this.showMakeField == true) {
          let makeScroll1 = this.template.querySelector(".makeScroll");
          makeScroll1.classList.remove(dropDownMenu);
 
        }
      }

      if (this.dynamicScrollModel == true && this.showModelDropDown == true) {
        let makeScrollA = this.template.querySelector(".makeScroll1");
        makeScrollA.classList.add(dropDownMenu);
      } else {
        if (this.showModelDropDown == true) {
          let makeScrollB = this.template.querySelector(".makeScroll1");
          makeScrollB.classList.remove(dropDownMenu);
        }
      }

      if (this.dynamicScrollBody == true && this.showBodyDropdown == true) {
        let makeScrollc = this.template.querySelector(".makeScroll2");
        makeScrollc.classList.add(dropDownMenu);
      } else {
        if (this.showBodyDropdown == true) {
          let makeScrolld = this.template.querySelector(".makeScroll2");
          makeScrolld.classList.remove(dropDownMenu);
        }
      }

      if (this.dynamicScrollYear == true && this.showYearDropdown == true) {
        let makeScrolle = this.template.querySelector(".makeScroll3");
        makeScrolle.classList.add(dropDownMenu);
      } else {
        if (this.showYearDropdown == true) {
          let makeScrollf = this.template.querySelector(".makeScroll3");
          makeScrollf.classList.remove(dropDownMenu);
        }
      }

      if (this.dynamicScrollYearRange == true && this.showYearRangedropDown == true) {
        let makeScrollf = this.template.querySelector(".makeScroll5");
        makeScrollf.classList.add(dropDownMenu);
      } else {
        if (this.showYearRangedropDown == true) {
          let makeScrollg = this.template.querySelector(".makeScroll5");
          makeScrollg.classList.remove(dropDownMenu);
        }
      }
    }


  }

  closeErrorModal(){
    this.openmodalError = '';
   }




}