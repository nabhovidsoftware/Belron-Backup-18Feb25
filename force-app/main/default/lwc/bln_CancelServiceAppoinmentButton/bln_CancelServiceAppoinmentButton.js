import { LightningElement,track,api,wire } from 'lwc';
import {getObjectInfo} from 'lightning/uiObjectInfoApi';
import ACCOUNT_OBJECT from '@salesforce/schema/ServiceAppointment';
import {getPicklistValues} from 'lightning/uiObjectInfoApi';
import COUNTRY_FIELD from '@salesforce/schema/ServiceAppointment.BLN_FailureReason__c';
import CONTINENT_FIELD from '@salesforce/schema/ServiceAppointment.BLN_SubFailureReason__c';


export default class Bln_CancelServiceAppoinmentButton extends LightningElement {

    @wire(getObjectInfo, {objectApiName: ACCOUNT_OBJECT })

    accountInfo;

 

    @track countyOptions;

    @track continentOptions;

    @track country;

 

    @wire(getPicklistValues, {recordTypeId: '$accountInfo.data.defaultRecordTypeId', fieldApiName: COUNTRY_FIELD })

    countryFieldInfo({ data, error }) {

        if (data) this.countryFieldData = data;

    }

    @wire(getPicklistValues, {recordTypeId:'$accountInfo.data.defaultRecordTypeId', fieldApiName: CONTINENT_FIELD })

    continentFieldInfo({ data, error }) {

        if (data) this.continentOptions = data.values;

    }

    handleContinentChange(event) {

        let key = this.countryFieldData.controllerValues[event.target.value];

        this.countyOptions = this.countryFieldData.values.filter(opt => opt.validFor.includes(key));

    }

    handleCountryChange(event)

    {

        var country =event.target.value;

    }

 
    @track isShowModal = false;
    @api recordId;
    @track selectedReason;
    @track reasonOptions = [
        { label: 'Reason 1', value: 'reason1' },
        { label: 'Reason 2', value: 'reason2' },
        { label: 'Reason 3', value: 'reason3' }
    ];



    connectedCallback() {
        
    }

    
    handleReasonChange(event) {
        this.selectedReason = event.detail.value;
    }

    handleCancelAppointment() {
        // Add your logic here to handle the cancellation based on the selected reason
        console.log('Selected reason:', this.selectedReason);
        // For example, you can close the modal or perform other actions
        this.hideModalBox();
    }

    showModalBox() {  
        this.isShowModal = true;
        alert(this.recordId);
    }

    hideModalBox() {  
        this.isShowModal = false;
    }
}