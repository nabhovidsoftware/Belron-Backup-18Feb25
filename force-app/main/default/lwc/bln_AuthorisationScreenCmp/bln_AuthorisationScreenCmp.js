import { LightningElement, track , wire,api } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecord,updateRecord } from 'lightning/uiRecordApi';
import CORPORATE_RECORD_OBJECT from '@salesforce/schema/BLN_Corporate__c';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import TYPE_FIELD from '@salesforce/schema/BLN_Corporate__c.BLN_CHFVATStatus__c';

import AMOUNT_AUTHORIZATION_REQUIRED_FIELD from '@salesforce/schema/BLN_Corporate__c.BLN_AmountAuthorizationRequired__c';
import PRODUCT_AUTHORIZATION_REQUIRED_FIELD from '@salesforce/schema/BLN_Corporate__c.BLN_ProductAuthorisationRequired__c';

import DA_TREATMENT_FIELD from '@salesforce/schema/BLN_Corporate__c.BLN_InsuranceSite__r.BLN_DATreatment__c';
import AUTH_REASON from '@salesforce/schema/BLN_Corporate__c.BLN_AuthorisationReason__c';
import AUTH_CODE_NAME from '@salesforce/schema/BLN_Corporate__c.BLN_AuthorisationCodeName__c';
import VALUE_AUTH_REAUTH from '@salesforce/schema/BLN_Corporate__c.BLN_ValueAuthorisedReauthorised__c';
import Vehicle_Damage_Excess from '@salesforce/schema/BLN_Corporate__c.BLN_VehicleDamageExcess__c';
import OE_AUTH from '@salesforce/schema/BLN_Corporate__c.BLN_OEAuthorized__c';
import OEAuthRequired from '@salesforce/schema/BLN_Corporate__c.BLN_OEAuthorizationRequired__c';

import PROD_AUTH from '@salesforce/schema/BLN_Corporate__c.BLN_ProductAuthorised__c';
import MULT_GLASS_CLAIMED_AUTH from '@salesforce/schema/BLN_Corporate__c.BLN_MultipleGlassClaimsAuthorised__c';
import AUTH_STATUS from '@salesforce/schema/BLN_Corporate__c.BLN_AuthorizationStatus__c';
import APPROVE_LIMIT from '@salesforce/schema/BLN_Corporate__c.BLN_ApprovedLimit__c';
import daAndNonDa from '@salesforce/label/c.BLN_DaAndNonDa';
import updateCaseRecord from '@salesforce/apex/BLN_AuthorisationScreenController.updateCaseRecord';
import { CloseActionScreenEvent } from 'lightning/actions';
import authorisationApprovedLabel from '@salesforce/label/c.BLN_AuthorisationApprovedLabel';
import authorisationRejectedLabel from '@salesforce/label/c.BLN_AuthorisationRejectedLabel';
import corporateAuthorizationReqLabel from '@salesforce/label/c.BLN_CorporateAuthorizationReqLabel';


const FIELDS = [AMOUNT_AUTHORIZATION_REQUIRED_FIELD,DA_TREATMENT_FIELD,OE_AUTH,AUTH_CODE_NAME,AUTH_REASON,PROD_AUTH,MULT_GLASS_CLAIMED_AUTH,AUTH_STATUS,VALUE_AUTH_REAUTH,Vehicle_Damage_Excess,APPROVE_LIMIT,PRODUCT_AUTHORIZATION_REQUIRED_FIELD,OEAuthRequired];

export default class Bln_AuthorisationScreenCmp extends LightningElement {
    @track authorisationReason = '';
    @track authorisationCodeName = '';
    @track valueAuthorisedReauthorised;
    @track oeAuthorised;
    @track chfVatStatus;
    @track productAuthorised = false;
    @track multipleGlassClaimsAuthorised = false;
    @track picklistOptions = [];
    @track oeAuthorisedOptions = [];
    @track selectedCHF;
    @track approveLimit;
    @api recordId;
    @track value;
    productAuthRequired;
    daTreatment;
    daTreatmentFlag = false;
    @track isOpen = true;
    recordTypeName;
    isLoading = false;
    noNeedAuth = false;
    

    @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
    wiredRecord({ error, data }) {
        if (data) {
            this.productAuthRequired = JSON.parse(data.fields.BLN_ProductAuthorisationRequired__c.value);   //FOUK - 7082 // FOUK - 10507

            if(data.fields.BLN_InsuranceSite__r.value != null){
                this.daTreatment = data.fields.BLN_InsuranceSite__r.value.fields.BLN_DATreatment__c.value;
            }
            if(data.fields.BLN_AuthorizationStatus__c.value!=corporateAuthorizationReqLabel){
               this.noNeedAuth =  true;
            }
            this.oeAuthorisedFlag = JSON.parse(data.fields.BLN_OEAuthorizationRequired__c.value);

            this.oeAuthorised = data.fields.BLN_OEAuthorized__c.value;
            this.authorisationReason = data.fields.BLN_AuthorisationReason__c.value;
            this.authorisationCodeName = data.fields.BLN_AuthorisationCodeName__c.value;
            this.productAuthorised = data.fields.BLN_ProductAuthorised__c.value;
            this.multipleGlassClaimsAuthorised = data.fields.BLN_MultipleGlassClaimsAuthorised__c.value;
            this.valueAuthorisedReauthorised = data.fields.BLN_ValueAuthorisedReauthorised__c.value;
            this.accidentaldamageexcess = data.fields.BLN_VehicleDamageExcess__c.value;
            this.approveLimit = data.fields.BLN_ApprovedLimit__c.value;
            this.valueAuthorisedReauthorised = this.approveLimit;
           //FOUK - 8291
            if(this.daTreatment == daAndNonDa){
                this.daTreatmentFlag = true;
            }
        } else if (error) {
          
            console.error('Error in Line 73', JSON.stringify(error));
        }
      }

    
    @wire(getObjectInfo, { objectApiName: CORPORATE_RECORD_OBJECT })
    objectInfo;
    
    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: TYPE_FIELD
    })
    picklistValues({error, data}) {
        if(data) {
            this.picklistOptions = [{ label: '--None--', value: '--None--' },
               ...data.values.map(item => ({
                   label: item.label,
                   value: item.value
               }))
           ];
           // Set default value to the first actual picklist option if available
           if (data.values.length > 0) {
               this.selectedCHF = data.values[0].value;
           }
       } else if (error) {
           console.error('Error fetching picklist values in Line 98:', error);
       }
    }
    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: OE_AUTH 
    })
    oeAuthorisedPicklistValues({ error, data }) {
        if (data) {
            this.oeAuthorisedOptions = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
        } else if (error) {
            console.error('Error fetching OE Authorized picklist values in Line 112:', error);
        }
    }
        //handle input fields
        handleInputChange(event) {
            const fieldName = event.target.name;
            if (fieldName === 'authorisationCodeName') {
                this.authorisationCodeName = event.target.value;
            } else if (fieldName === 'authorisationReason') {
                this.authorisationReason = event.target.value;
            }
            else if (fieldName === 'valueAuthorisedReauthorised') {
                this.valueAuthorisedReauthorised = parseFloat(event.target.value);
            }else if (fieldName === 'accidentaldamageexcess') {
                this.accidentaldamageexcess = event.target.value;
            }

        }
    
        //Handle Checkboxs fields
        handleCheckboxChange(event) {
            const fieldName = event.target.name;
            if (fieldName === 'productAuthorised') {
                this.productAuthorised = event.target.checked;
            } else if (fieldName === 'multipleGlassClaimsAuthorised') {
                this.multipleGlassClaimsAuthorised = event.target.checked;
            }
        }
    
       // handeling picklist value of CHFVAT status
        handlePicklistChange(event) {
            const fieldName = event.target.dataset.fieldname;
            const value = event.target.value;
            if (fieldName === 'oeAuthorised') {
                this.oeAuthorised = value;
            }
            if(fieldName === 'selectedCHF')
                {
                this.chfVatStatus = value;
                this.selectedCHF = value;
            }
        }
        //FOUK-3169//
        handleApprove() {
            this.isLoading = true;
            if (!this.authorisationReason) {
                this.template.querySelector('lightning-input[name="authorisationReason"]').focus();
            }
            if (!this.authorisationCodeName) {
                this.template.querySelector('lightning-input[name="authorisationCodeName"]').focus();
            }
            if(!this.authorisationCodeName || !this.authorisationReason){
                return;
            }
            // if(this.oeAuthorised == 'N'){            //FOUK-3177
                updateCaseRecord({recordId: this.recordId})
                .then(result=>{
                })
                .catch(error=>{
                    console.error('error in Line 172',error);

                });

            // }
            const fields = {};
            fields[AMOUNT_AUTHORIZATION_REQUIRED_FIELD.fieldApiName] = true;
            fields[TYPE_FIELD.fieldApiName] = this.selectedCHF;
            fields[AUTH_CODE_NAME.fieldApiName] = this.authorisationCodeName;
            fields[AUTH_REASON.fieldApiName] = this.authorisationReason;
            fields[OE_AUTH.fieldApiName] = this.oeAuthorised;
            fields[PROD_AUTH.fieldApiName] = this.productAuthorised;
            fields[MULT_GLASS_CLAIMED_AUTH.fieldApiName] = this.multipleGlassClaimsAuthorised;
            fields[VALUE_AUTH_REAUTH.fieldApiName] = this.valueAuthorisedReauthorised;
            fields[Vehicle_Damage_Excess.fieldApiName] = this.accidentaldamageexcess;
            fields[AUTH_STATUS.fieldApiName] = 'Approved';
            fields['Id'] = this.recordId;
            const recordInput = { fields };

            updateRecord(recordInput)
                .then(() => {
                    this.isLoading = false;
                    const event = new CustomEvent('updatesuccess', {detail:{'message':authorisationApprovedLabel}});
                    this.dispatchEvent(event);
                })
                .catch(error => {
                    console.error('error while updating record in Line 198',error);
                    this.isLoading = false;
                    const event = new CustomEvent('updatefailure', {detail:{'message':'Error updating record'}});
                    this.dispatchEvent(event);
                });
        }
        //FOUK-3169//
        handleReject() {
            this.isLoading = true;
            if (!this.authorisationReason) {
                this.template.querySelector('lightning-input[name="authorisationReason"]').focus();
            }
            if (!this.authorisationCodeName) {
                this.template.querySelector('lightning-input[name="authorisationCodeName"]').focus();
            }
            if(!this.authorisationCodeName || !this.authorisationReason){
                return;
            }
            const fields = {};
            fields[AMOUNT_AUTHORIZATION_REQUIRED_FIELD.fieldApiName] = true;
            fields[TYPE_FIELD.fieldApiName] = this.selectedCHF;
            fields[AUTH_CODE_NAME.fieldApiName] = this.authorisationCodeName;
            fields[AUTH_REASON.fieldApiName] = this.authorisationReason;
            fields[OE_AUTH.fieldApiName] = this.oeAuthorised;
            fields[PROD_AUTH.fieldApiName] = this.productAuthorised;
            fields[MULT_GLASS_CLAIMED_AUTH.fieldApiName] = this.multipleGlassClaimsAuthorised;
            fields[AUTH_STATUS.fieldApiName] = 'Rejected';
            fields['Id'] = this.recordId;
            const recordInput = { fields };
            updateRecord(recordInput)
                .then(() => {
                    this.isLoading = false;
                    const event = new CustomEvent('updatesuccess', {detail:{'message':authorisationRejectedLabel}});
                    this.dispatchEvent(event);
                })
                .catch(error => {
                    this.isLoading = false;
                    const event = new CustomEvent('updatefailure', {detail:{'message':'Error updating record'}});
                    this.dispatchEvent(event);
                });
        }
        handleCancel() {
            const event = new CustomEvent('cancelevent', {detail:{'message':'Cancel'}});
            this.dispatchEvent(event);
        }
    }