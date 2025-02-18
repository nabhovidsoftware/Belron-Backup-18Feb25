import { LightningElement,api, wire, track } from 'lwc';
import firstName from '@salesforce/label/c.BLN_FirstName';
import lastName from '@salesforce/label/c.BLN_LastName';
import mobilePhone from '@salesforce/label/c.BLN_PersonalMobilePhone';
import homePhone from '@salesforce/label/c.BLN_HomeNumber';
import email from '@salesforce/label/c.BLN_Email';
import source from '@salesforce/label/c.BLN_Source';
import cancelLabel from '@salesforce/label/c.BLN_Cancel';
import selectOne from '@salesforce/label/c.BLN_SelectOne';
import salutation from '@salesforce/label/c.BLN_Salutation';
import motoristId from '@salesforce/label/c.BLN_MotoristId';
import preferredConMethod from '@salesforce/label/c.BLN_PreferredContactMethod';
import accountType from '@salesforce/label/c.BLN_AccountType';
import saveAndCaptureAdd from '@salesforce/label/c.BLN_SaveAndCaptureAddress';
import accountEdit from '@salesforce/label/c.BLN_AccountEdit';
import motoristNoResultFound from '@salesforce/label/c.BLN_MDMMotoristsNoResultFound'; 
import homeCountry from '@salesforce/label/c.BLN_HomeCountry';
import homePostalCode from '@salesforce/label/c.BLN_HomePostCode';
import homeState from '@salesforce/label/c.BLN_HomeCounty'; 
import homeStreet from '@salesforce/label/c.BLN_HomeStreet';
import homeTown from '@salesforce/label/c.BLN_HomeTown';
import requiredFieldEmailAndLastName from '@salesforce/label/c.BLN_RequiredFieldEmailLastName';
import motoristAccountUpdatedSuccessfully from '@salesforce/label/c.BLN_MotoristAccountUpdatedSuccessfully';
import motoristAccountCreatedSuccessfully from '@salesforce/label/c.BLN_MotoristAccountCreatedSuccessfully';
import phoneMobile from '@salesforce/label/c.BLN_MobilePhone';
import motorist from '@salesforce/label/c.BLN_Motorist';
import phonePreferredContactMethod from '@salesforce/label/c.BLN_PreferredContactPhone';
import cell from '@salesforce/label/c.BLN_Cell';
import mdm from '@salesforce/label/c.BLN_MDM';
import sf from '@salesforce/label/c.BLN_SF';
import searchMotorist from '@salesforce/label/c.BLN_SearchMotorist';
import createMotorist from '@salesforce/label/c.BLN_CreateMotorist';
import showMotorist from '@salesforce/label/c.BLN_ShowMotorist';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import SALUTATION_FIELD from '@salesforce/schema/Account.Salutation';
import searchAndGetMotorists from '@salesforce/apex/BLN_SearchAndGetMotoristController.searchAndGetMotorists';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {getObjectInfo} from "lightning/uiObjectInfoApi";
import createAccount from '@salesforce/apex/BLN_SearchAndGetMotoristController.createAccount';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent, } from 'lightning/flowSupport';
import otherPhone from '@salesforce/label/c.BLN_OtherPhoneMDM';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import LightningAlert from 'lightning/alert';
import MDMMotoristID from '@salesforce/label/c.BLN_MdmMotoristID';
import MdmErrorMessage from '@salesforce/label/c.BLN_MdmErrorMessage';
import MdmFirstName from '@salesforce/label/c.BLN_MdmFirstName';
import MdmlastName from '@salesforce/label/c.BLN_MdmlastName';
import MdmPrimaryEmail from '@salesforce/label/c.BLN_MdmPrimaryEmail';
import MdmMobilePhone from '@salesforce/label/c.BLN_MdmMobilePhone';
import MdmhomePhone from '@salesforce/label/c.BLN_MdmHomePhone';
import MdmOtherPhone from '@salesforce/label/c.BLN_MdmOtherPhone';
import MdmpreferredContactMethod from '@salesforce/label/c.BLN_MdmpreferredContactMethod';
import MdmTitle from '@salesforce/label/c.BLN_MdmTitle';
import MdmhomeStreet from '@salesforce/label/c.BLN_MdmHomeStreet';
import MdmHomeState from '@salesforce/label/c.BLN_MdmHomeState';
import MdmHomePostalCode from '@salesforce/label/c.BLN_MdmHomePostalCode';
import MdmHomeCountry from '@salesforce/label/c.BLN_MdmHomeCountry';
import MdmHomeTown from '@salesforce/label/c.BLN_MdmHomeTown';
import MdmPersonType from '@salesforce/label/c.BLN_MdmPersonType';
import NominatedPerson from '@salesforce/label/c.BLN_NominatedPerson';
import MotoristAccountType from '@salesforce/label/c.BLN_MotoristAccountType';
import PreferredContactMethod_FIELD from '@salesforce/schema/Account.BLN_PreferredContactMethod__c';
import PrimaryContactNumber_FIELD from '@salesforce/schema/Account.BLN_PrimaryContactNumber__c';
import MdmPrimaryContactNumber from '@salesforce/label/c.BLN_MdmPrimaryContactNumber';


export default class Bln_SearchAndGetMotorist extends NavigationMixin(LightningElement) {

    @api content;
    @api firstName;
    @track FirstName;
    @api lastName;
    @api email;
    @api salutation;
    @api phone;
    @api caseId;
    @api recordId;
    @track displayData;
    @track motorists = [];
    @track selectedRows = [];
    @track isMotorists = false;
    @track isMotoristsEmpty = false;    
    openErrorModal= false;
    @track ObjectInfo;
    @track isShowModal = false;
    @track isCreateModal = false;
    @api serviceStreet;
    @api serviceTown;
    @api serviceCountry;
    @api serviceCounty;
    @api servicePostCode;
    @api outputserviceStreet;
    @api outputserviceTown;
    @api outputserviceCountry;
    @api outputservicePostCode;
    @track isLoaded = true;
    @api IsCancelled = false;
    @api availableActions = [];
    @api callMotoristFlow1 = false;
    @api persontypefield;
    @track disableShowMotorist = true;
    @track disableCreateMotorist = false;
    @track SelectedOptions ='';
    @track options=[];
    @track PersonOptions ='';
    @track options1=[];
    @track lastPersonName;
    @track mobilePersonPhone;
    @track firstPersonName;
    @track emailPerson;
    @track showTable = false;
    selectedRowId;
    @track motoristWrap = {};
    @track searchMotoristWrap = {};
    label = {
        showMotorist,
        searchMotorist,
        createMotorist,
        sf,
        mdm,
        cell,
        phonePreferredContactMethod,
        phoneMobile,
        motoristNoResultFound,
        lastName,
        firstName,
        mobilePhone,
        homePhone,
        email,
        source,
        cancelLabel,
        selectOne,
        salutation,
        motoristId, 
        preferredConMethod, 
        homeCountry, 
        accountType, 
        homePostalCode, 
        homeState,
        saveAndCaptureAdd, 
        accountEdit, 
        homeStreet,
        homeTown, 
        requiredFieldEmailAndLastName,
        motoristAccountCreatedSuccessfully,
        motoristAccountUpdatedSuccessfully,
        motorist,
        MDMMotoristID,
        otherPhone,
        MdmErrorMessage,
        MdmFirstName,
        MdmlastName,
        MdmPrimaryEmail,
        MdmMobilePhone,
        MdmhomePhone,
        MdmOtherPhone,
        MdmpreferredContactMethod,
        MdmTitle,
        MdmhomeStreet,
        MdmHomeState,
        MdmHomePostalCode,
        MdmHomeCountry,
        MdmHomeTown,
        MdmPersonType,
        MotoristAccountType,
        NominatedPerson,
        MdmPrimaryContactNumber
        
    };

    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    recordtypeIDbyWire
    ({ error, data }) {
        if (data) {
            this.storeRecordTypeId =data.defaultRecordTypeId;
        } else if (error) {
        }
    }
    @wire(getPicklistValues, {
        
        recordTypeId: "$storeRecordTypeId",
        fieldApiName: SALUTATION_FIELD
    })
    
    picklistValues({error, data}) {
        if(data) {
            this.options = 
               data.values.map(item => ({
                   label: item.label,
                   value: item.value
               }));
           
       } else if (error) {
           console.error('Error fetching picklist values:', error);
       }
    }
    @wire(getPicklistValues, {
        
        recordTypeId: "$storeRecordTypeId",
        fieldApiName: PreferredContactMethod_FIELD
    })
    
    picklistcontactValues({error, data}) {
        if(data) {
            this.preferredContactMethodoptions = 
               data.values.map(item => ({
                   label: item.label,
                   value: item.value
               }));
           
       } else if (error) {
           console.error('Error fetching picklist values:', error);
       }
    }

    @wire(getPicklistValues, {
        
        recordTypeId: "$storeRecordTypeId",
        fieldApiName: PrimaryContactNumber_FIELD
    })
    
    picklistcontactNumberValues({error, data}) {
        if(data) {
            this.primaryContactNumberoptions = 
               data.values.map(item => ({
                   label: item.label,
                   value: item.value
               }));
           
       } else if (error) {
           console.error('Error fetching picklist values:', error);
       }
    }
get persontypeoptions() {
        return [
          { label: NominatedPerson, value: NominatedPerson },
          { label: MotoristAccountType, value: MotoristAccountType }
        ];
      }

    hideModalBox(){

        this.isShowModal = false;
    }
    hideModalBox1(){

        this.isCreateModal = false;
    }
    connectedCallback() {
        this.isLoaded = false;
 
    }
    handleInput(event) {
       
        var val = event.target.value;
        if(event.target.name === this.label.MdmFirstName){

            this.motoristWrap.firstName = val;
        }
        if(event.target.name === this.label.MdmlastName){

            this.motoristWrap.lastName = val;
        }
        if(event.target.name === this.label.MdmPrimaryEmail){

            this.motoristWrap.primaryEmail = val;
        }
        if(event.target.name === this.label.MdmMobilePhone){

            this.motoristWrap.mobilePhone = val;
        }
        if(event.target.name === this.label.MdmhomePhone){

            this.motoristWrap.homePhone = val;
        }
        if(event.target.name === this.label.MdmOtherPhone){

            this.motoristWrap.otherPhone = val;
        } if(event.target.name === 'preferredContactMethod'){

            this.motoristWrap.preferredContactMethod = val;
        }
        if(event.target.name === 'primaryContactNumber'){

            this.motoristWrap.primaryContactNumber = val;
        }
                       
    }

    handleShowInput(event) {
       
        var val = event.target.value;
        if(event.target.name === this.label.MdmTitle){

            this.motoristWrap.title = val;
        }
        if(event.target.name === this.label.MdmFirstName){

            this.motoristWrap.firstName = val;
        }
        if(event.target.name === this.label.MdmlastName){

            this.motoristWrap.lastName = val;
        }
        if(event.target.name === this.label.MdmPrimaryEmail){

            this.motoristWrap.primaryEmail = val;
        }
        if(event.target.name === this.label.MdmMobilePhone){

            this.motoristWrap.mobilePhone = val;
        }
        if(event.target.name === this.label.MdmhomePhone){

            this.motoristWrap.homePhone = val;
        }
        if(event.target.name === this.label.MdmOtherPhone){

            this.motoristWrap.otherPhone = val;
        }
        if(event.target.name === this.label.MdmpreferredContactMethod){

            this.motoristWrap.preferredContactMethod = val;
        }
        if(event.target.name === this.label.MdmhomeStreet){

            this.motoristWrap.homeStreet = val;
        }
        if(event.target.name === this.label.MdmHomeState){

            this.motoristWrap.homeState = val;
        }
        if(event.target.name === this.label.MdmHomePostalCode){

            this.motoristWrap.homePostalCode = val;
        }
        if(event.target.name === this.label.MdmHomeCountry){

            this.motoristWrap.homeCountry = val;
        }
        if(event.target.name === this.label.MdmHomeTown){

            this.motoristWrap.homeTown = val;
        }
        if(event.target.name === 'preferredContactMethod'){

            this.motoristWrap.preferredContactMethod = val;
        }
        if(event.target.name === 'primaryContactNumber'){

            this.motoristWrap.primaryContactNumber = val;
        }
        
                       
    }

    handleFirstScreenInput(event) {
       
        this.showTable=false;
        this.disableShowMotorist = true;
        this.disableCreateMotorist = false;
        var val = event.target.value;
        if(event.target.name === this.label.MdmFirstName){

            this.searchMotoristWrap.firstName = val;

        }
        if(event.target.name === this.label.MdmlastName){

            this.searchMotoristWrap.lastName = val;

        }
        if(event.target.name === this.label.MdmTitle){

            this.searchMotoristWrap.title = val;

        }
        if(event.target.name === this.label.MdmMobilePhone){

            this.searchMotoristWrap.mobilePhone = val;

        }
        if(event.target.name === this.label.MdmPrimaryEmail){

            this.searchMotoristWrap.primaryEmail = val;

        }
        if(event.target.name === this.label.MdmPersonType){

            this.searchMotoristWrap.personType = val;

        }
                       
    }

    /* Method to use for search when an user put the input base of input getting result of SF OR Mulesoft */
    getMotorists() {
        this.isLoaded = true;
        if(!this.searchMotoristWrap.firstName || !this.searchMotoristWrap.lastName ) {
            this.motorists = []; // Clear motorists array
            this.isMotorists = false;
            this.isLoaded = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: this.label.requiredFieldEmailAndLastName,
                    variant: 'error',
                }),
            );
        } else if( this.searchMotoristWrap.firstName && this.searchMotoristWrap.lastName) {
            searchAndGetMotorists({ motoristWrap : this.searchMotoristWrap})
                .then(result => {
                    console.log('Motorist result', JSON.stringify(result));
                    if(result!= null && result !=undefined && result!=''){
                        console.log('Motorist result360');
                        this.showTable=true;
                        this.openDialog = true;
                        this.isMotorists = result.length > 0 ? true : false;;
                        this.motorists = result;
                        this.isLoaded = false;
                        this.isMotoristsEmpty =false;
                        
                    }else{
                        console.log('Motorist result369');
                        this.isMotoristsEmpty =true;
                        this.isLoaded = false;
                        LightningAlert.open({
                            message: this.label.MdmErrorMessage,
                            theme: 'Error', // a red theme intended for error states
                            label: 'Error!', // this is the header text
                          });
                    }
                    
                }).catch(error => {
                    console.error('Error: ', error);
                });
            }
    }

    createCustomer() {
        this.isLoaded = true;
        createAccount({motoristWrap: this.motoristWrap, caseId:this.caseId, callMotoristFlow1: this.callMotoristFlow1})
                            .then(result => {
                                if(result != null && result != '' && result != undefined && this.sfIdValidChecker(result)){
                                    if(!this.motoristWrap.sfId) {
                                        this.dispatchEvent(
                                            new ShowToastEvent({ 
                                                title: 'Success',
                                                message: this.label.motoristAccountCreatedSuccessfully,
                                                variant: 'success',
                                            }), 
                                        )
                                    } else if(this.motoristWrap.sfId) {
                                        this.dispatchEvent(
                                            new ShowToastEvent({ 
                                                title: 'Success',
                                                message: this.label.motoristAccountUpdatedSuccessfully,
                                                variant: 'success',
                                            }), 
                                        )
                                    }
                                    this.recordId = result;
                                    const navigateNextEvent = new FlowNavigationNextEvent();
                                    this.dispatchEvent(navigateNextEvent);
                                } else {
                                    this.dispatchEvent(
                                        new ShowToastEvent({
                                            title: 'Error',
                                            message: result,
                                            variant: 'error',
                                        }),
                                    );
                                }
                            }).catch(error=>{
                                console.log('create443'+JSON.stringify(error));
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Error creating record',
                                        message: error,
                                        variant: 'error',
                                    }),
                                );
                            }).finally(() => {
                                this.isLoaded = false;
                            });         
    }
    

    /* Selected Record need to be used for redirect detail page */
    handleRadioChange(event) {
        this.motorists.forEach((res,i) => {
            if (i == event.currentTarget.dataset.id) {
                res.selectMotorist = true;
            } else {
                res.selectMotorist = false;
            }
        });

   this.disableShowMotorist = false;
        this.disableCreateMotorist = true;
       
        
   }
 
   /* This method is use for check account SF Id is valid or not for redirect to account detail page*/
    sfIdValidChecker(sfId) {
        var sfIdRegex = '[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}';
        if(sfId.match(sfIdRegex)){
            return true;
        }else{
            return false;
        }
    }
    
    /* This method is used for create new account record if response get from mulesoft otherwise redirect to detail page*/
    showMotorist() { 
        this.motoristWrap = {};  
            
                this.motorists.forEach(item=>{
                    if(item.selectMotorist === true) {
                        
                        this.motoristWrap = JSON.parse(JSON.stringify(item));                    
                }
                });
            this.isShowModal = true;
            
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
        createMotorist(){
          this.isCreateModal = true;
          this.motoristWrap = {};
          this.motoristWrap = JSON.parse(JSON.stringify(this.searchMotoristWrap));                           
        }

        handleClear() {
            this.motorists.forEach(res => {
                res.selectMotorist = false;
               
            });

            this.disableShowMotorist = true;
            this.disableCreateMotorist = false;
            
        }
        
}