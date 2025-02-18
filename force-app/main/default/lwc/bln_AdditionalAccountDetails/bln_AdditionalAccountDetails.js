/**
 * @description       :
 * @author            : Sourabh Bhattacharjee
 * @group             :
 * @last modified on  : 12-04-2024
 * @last modified by  : Sourabh Bhattacharjee
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   09-24-2024   Sourabh Bhattacharjee   Initial Version
**/
import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import PERSON_MAILING_STREET from '@salesforce/schema/Account.PersonMailingStreet';
import PERSON_MAILING_CITY from '@salesforce/schema/Account.PersonMailingCity';
import PERSON_MAILING_POSTAL_CODE from '@salesforce/schema/Account.PersonMailingPostalCode';
import getLoggedInUserAccountId from '@salesforce/apex/Bln_AdditionalAccountDetailsController.getLoggedInUserAccount';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import BLN_LOGO from '@salesforce/resourceUrl/BLN_ChatLogo';
import BLN_LOGO1 from '@salesforce/resourceUrl/BLN_PhoneLogo';
import BLN_LOGOHEAD from '@salesforce/resourceUrl/BLN_LOGOREDYELLOW';
import BLN_EDITICON from '@salesforce/resourceUrl/BLN_EDITICON';
import BLN_Iconsuccess from '@salesforce/resourceUrl/BLN_Success';

import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import ACCOUNT_OBJECT from "@salesforce/schema/Account";
import SALUTATION_FIELD from '@salesforce/schema/Account.Salutation';
import FIRSTNAME_FIELD from '@salesforce/schema/Account.FirstName';
import LASTNAME_FIELD from '@salesforce/schema/Account.LastName';
import PHONE_FIELD from '@salesforce/schema/Account.PersonMobilePhone';
import PERSONAL_HOME_FIELD from '@salesforce/schema/Account.PersonHomePhone';
import PERSONAL_OTHER_FIELD from '@salesforce/schema/Account.PersonOtherPhone';
import PRIMARYCONTACT_FIELD from '@salesforce/schema/Account.BLN_PrimaryContactNumber__c';
import ValidationErrorMessagehome from '@salesforce/label/c.BLN_PortalValidationErrorMessagehome'; 
import ValidationErrorMessagemobile from '@salesforce/label/c.BLN_PortalValidationErrorMessagemobile'; 
import ValidationErrorMessageother from '@salesforce/label/c.BLN_PortalValidationErrorMessageOther'; 
import ValidationErrorMessageany from '@salesforce/label/c.BLN_PortalValidationErrorMessageany'; 

const FIELDS = [SALUTATION_FIELD, FIRSTNAME_FIELD, LASTNAME_FIELD, PHONE_FIELD, PERSONAL_HOME_FIELD, PERSONAL_OTHER_FIELD,PRIMARYCONTACT_FIELD]

export default class Bln_AdditionalAccountDetails extends LightningElement {
    @api accountId;
    @track isEditing = false;
    @track isUpdating = false;
    @api successurl;
    @api chatUrl;
    @api phUrl;
    @api headUrl;
    @api editUrl;
    
    @track accountData = {};
    @track recordTypeId = ''

    @track salutationOptions = [];
    @track selectedSalutationValue = '';
    @track isHomePhoneRequiredForHome = false;  
    @track isHomePhoneRequiredForMobile = false;  
    @track isHomePhoneRequiredForOther = false; 
    error;

    fields = {};

    constructor(){
        super();
        const style = document.createElement('style');
        style.innerText = `
        lightning-base-combobox-item{
            outline: none !important;
            box-shadow: none !important;
        }
        lightning-base-combobox-item:hover{
            outline: none !important;
            box-shadow: none !important;
        } 
            
        `;
        document.querySelector('head').appendChild(style);

//         super();
//         const style1 = document.createElement('style1');
//         style.innerText = `
//        .slds-form-element__static {
//     overflow-wrap: break-word;
//     word-wrap: break-word;
//     word-break: break-word;
//     display: inline-block;
//     font-size: var(--lwc-inputStaticFontSize, 0.8125rem);
//     font-weight: var(--lwc-inputStaticFontWeight, 400);
//     color: #475158 !important;
//     width: 100%;
// }
            
//         `;
//         document.querySelector('head').appendChild(style1);
        
    }

    @wire(getRecord, {recordId: '$accountId', fields: FIELDS})
    wiredAccount({error, data}){
        if(data){
            console.log('95 ',data)
            console.log('96 ',data.fields.BLN_PrimaryContactNumber__c.value)
            this.accountData = {
                salutation: data.fields.Salutation.value || '',
                firstName: data.fields.FirstName.value || '',
                lastName: data.fields.LastName.value || '',
                phone: data.fields.PersonMobilePhone.value || '',
                homePhone: data.fields.PersonHomePhone.value || '',
                otherPhone: data.fields.PersonOtherPhone.value || '',
                recordTypeId: data.recordTypeId || '',
                PrimaryContact:data.fields.BLN_PrimaryContactNumber__c.value || ''
            }
            console.log('107',this.accountData)
            console.log( '108',data)
           this.selectedSalutationValue = data.fields.Salutation.value || '';
            console.log( '110',data)
            this.recordTypeId = data.recordTypeId
            console.log('112',this.accountData)
            //console.log( '113',PrimaryContact)

           this.PrimaryContact =  data.fields.BLN_PrimaryContactNumber__c.value || '';
           console.log( '116',this.PrimaryContact)
           const primaryContactNormalized = this.PrimaryContact.toLowerCase().trim(); 
           console.log( '118',primaryContactNormalized)
            if (primaryContactNormalized.includes('home phone')) {  
                this.isHomePhoneRequiredForHome = true;  
                console.log( '121', this.isHomePhoneRequiredForHome)
            } else if (primaryContactNormalized.includes('mobile phone') ) {  
                this.isHomePhoneRequiredForMobile = true;  
                console.log( '124',this.isHomePhoneRequiredForMobile)
            } else if (primaryContactNormalized.includes('other phone') ) {  
                this.isHomePhoneRequiredForOther = true;  
                console.log( '127', this.isHomePhoneRequiredForOther)
            }  
        } else{
            console.log(error)
            this.error = error;
        }
    }

    //Get object info to fetch recordTypeId
    // @wire(getObjectInfo, {objecApiName: ACCOUNT_OBJECT})
    // accountObjectInfo

    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    accountObjectInfo({error,data}){
       if(data){
        let rectype= data.recordTypeInfos;
        console.log('83 ',rectype)
            // Iterate over the record types to find the one with the desired name
            Object.keys(rectype).forEach(key => {
                if (rectype[key].name == 'Person Account') {
                    // Store the record type ID in the property
                   this.recordTypeId = rectype[key].recordTypeId;
                }
            });
       }else if(error){
        // this.showNotification('Error Message', 'Error occured in this process.Please contact your System Admin.' , 'error');
        console.log(error)
        }
     };

    // Fetch picklist values
    @wire(getPicklistValues, {
        // recordTypeId: '$accountObjectInfo.data.defaultRecordTypeId',
        recordTypeId: '$recordTypeId',
        fieldApiName: SALUTATION_FIELD
    })
    wiredPicklistValues({error, data}){
        console.log('picklist options methiod', this.accountObjectInfo)
        if(data){
            this.salutationOptions = data.values;
            console.log(this.salutationOptions);
            
            // this.salutationOptions.map(item =>{
                //     if(item.value == this.accountData.salutation){
                    //         console.log(item.value)
                    //         item.selected = 'selected'
                    //     } else{
                        //         item.selected = ''
                        //     }
                        // })
                        // console.log('inner render callback--->>', this.template.querySelectorAll('lightning-base-combobox-item'));
        
                        // this.template.querySelectorAll('lightning-base-combobox-item').forEach(element => {
                        //     element.classList.remove('slds-has-focus');
                        // });
                        console.log('113 ',this.salutationOptions)
                        this.error = undefined;
                    } else if(error){
            console.log(error)
            this.error = error;
            this.salutationOptions = [];
        }
    }
    
    connectedCallback() {        
        this.successurl = BLN_Iconsuccess;
        this.chatUrl = BLN_LOGO;
        this.phUrl = BLN_LOGO1;
        this.headUrl =  BLN_LOGOHEAD;
        this.editUrl = BLN_EDITICON;
       
        if(this.CheckoutjsLoaded){
            return;
        }

        this.loadUserAccountId();
    }
    renderedCallback() {
        const style = document.createElement('style');
        style.innerText = `
        
        .overrideslds   .fix-slds-input_faux {
            background: inherit !important;
            box-shadow: none; !important;
            border: none !important;
            --lwc-shadowButtonFocus : 0 0  3px #fe9d6d;
    }`;
        try {
         this.template.querySelector('.overrideslds').appendChild(style);
        }
        catch (err) {
        }
        
    }
    
    // Wire adapter to get Account record details based on accountId
    @wire(getRecord, { recordId: '$accountId', fields: [PERSON_MAILING_STREET, PERSON_MAILING_POSTAL_CODE, PERSON_MAILING_CITY] })
    account;

    get isPersonMailingCity() {
       const isEmpty = getFieldValue(this.account.data, PERSON_MAILING_CITY);
       console.log('isEmpty', isEmpty);
       return isEmpty;

    }
    get emailStyle() {
        const style = this.isEditing ? '-webkit-text-fill-color:#475158' : '-webkit-text-fill-color:  #8B9196;';
        console.log('isEditing:', this.isEditing);
        console.log('emailStyle:', style);
        return style;
    }

    
    get isPersonMailingStreet() {
       const isEmpty = getFieldValue(this.account.data, PERSON_MAILING_STREET);
       return isEmpty;
    }
    get isPersonMailingPostalCode() {
        const isEmpty = getFieldValue(this.account.data, PERSON_MAILING_POSTAL_CODE);
        return isEmpty;
     }
     get uppercasePersonMailingCity() {
        console.log('Uppercase inside');
        const uppercaseCity = this.personMailingCity ? this.personMailingCity.toUpperCase() : '';
        console.log('Uppercase Person Mailing City:', uppercaseCity);
        return uppercaseCity;
    }

   
   // Method to load the Account ID of the logged-in user from the Apex controller
    loadUserAccountId() {
        getLoggedInUserAccountId()
            .then(result => {
                this.accountId = result;
            })
            .catch(error => {
                console.error('Error retrieving user account ID:', error);
            });
    }

    handleSuccess(event) {
        // Show success message
        this.showToast('Success', '', 'success');
        this.isUpdating = false; 
        this.isEditing = false;
    }

    // Event handler for form submission
    handleSubmit(event) {
        console.log('inside handleSubmit');
        /*event.preventDefault(); 
            const fields = event.detail.fields; 
            console.log('Fields submitted:', JSON.stringify(fields));
            this.fields = fields; 
            console.log('this.fields', this.fields);*/
           
        console.log('onsubmit event recordEditForm 283', event.detail.fields);
        //Saving new data
        const fields = {
            Id: this.accountId,
            Salutation: this.accountData.salutation,
            // Salutation: this.selectedSalutationValue,
            FirstName: this.accountData.firstName,
            LastName: this.accountData.lastName,
            PersonMobilePhone: this.accountData.phone,
            PersonHomePhone: this.accountData.homePhone,
            PersonOtherPhone: this.accountData.otherPhone

        }
        const recordInput = {fields};
        console.log('209 ', recordInput)

            // Validation checks 
            function showToast(title, message, variant) {  
            const event = new ShowToastEvent({  
                title: title,  
                message: message,  
                variant: variant  
            });  
            this.dispatchEvent(event);  
        } 
        let errorMessage = '';  
        let errorTitle = 'Error';
        if (this.isHomePhoneRequiredForHome && !fields.PersonHomePhone) {    
            errorMessage = ValidationErrorMessagehome; 
        } else if (this.isHomePhoneRequiredForMobile && !fields.PersonMobilePhone) {    
            errorMessage = ValidationErrorMessagemobile;  
        } else if (this.isHomePhoneRequiredForOther && !fields.PersonOtherPhone) {    
            errorMessage = ValidationErrorMessageother;  
        }  else if(!fields.PersonHomePhone && !fields.PersonMobilePhone && !fields.PersonOtherPhone) {
            errorMessage = ValidationErrorMessageany;
        }

        
        if (errorMessage) {  

            showToast.call(this, errorTitle, errorMessage, 'error');  
            return; // Exit the function early if there's an error  
        }  
         
        console.log('324 this.handleSuccess ', this.handleSuccess)
        updateRecord(recordInput)
        .then(()=>{
            console.log('324 this.handleSuccess ', this.handleSuccess)
            this.handleSuccess();
            console.log(' this.handleSuccess 326', this.handleSuccess)
        })
        .catch(error =>{
            console.log('error while saving329 ',error)
        })

        this.isUpdating = true; 
        console.log('  this.isUpdating ',  this.isUpdating)
    }

    editField(event) {
        this.isEditing = true;
    }

    handleCancel() {
        this.isEditing = false;
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    handleSalutationChange(event){
        this.selectedSalutationValue = event.target.value;
        console.log(this.selectedSalutationValue);
    }

    handleInputChange(event){
        const fieldName = event.target.name;
        const fieldValue = event.target.value;
        this.accountData[fieldName] = fieldValue
        console.log('after update ',this.accountData)
        
    }
}