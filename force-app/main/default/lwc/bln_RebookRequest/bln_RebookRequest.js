import { LightningElement, track, wire, api } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import SERVICE_APPOINTMENT_OBJECT from '@salesforce/schema/ServiceAppointment';
import FailureReason from "@salesforce/schema/ServiceAppointment.BLN_FailureReason__c";
import SubFailureReason from "@salesforce/schema/ServiceAppointment.BLN_SubFailureReason__c";
import AutoglassLogo from '@salesforce/resourceUrl/BLN_AutoglassLogo';
import Notification from '@salesforce/label/c.BLN_Notification';
import RebookReason from '@salesforce/label/c.BLN_RebookReason';
import RebookSubReason from '@salesforce/label/c.Bln_RebookSubReason';
import Confirm from '@salesforce/label/c.BLN_Confirm';
import Cancel from '@salesforce/label/c.BLN_Cancel';
import LightningAlert from 'lightning/alert';
import ChangingtheAppointmentTime from '@salesforce/label/c.Bln_ChangingtheAppointmentTime';
import ChangingtheAppointmentDate from '@salesforce/label/c.BLN_ChangingtheAppointmentDate';


export default class Bln_RebookRequest extends LightningElement {

    @api isRebookingRequestModel;
    isRequestModel = true;
    @api serviceappointmentId;
    @track rebookReasonValue;
    @track rebookSubReasonValue;
    @track rebookSubReasonOptions;


    srcImg = AutoglassLogo;
    @track reasonValue;
    @track subReasonValue;
    @track disableSubReason = true;
    @track selectedValueBLN_failurereason;
    @track selectedValueBLN_SubFailureReason;
    FailureReason;
    @track picklistValues;
    serviceAppointmentRecordTypeId;
    @api selectslot;

    reasonOptions = [];
    reasonOptionValue;
    subReasonOptions = [];
    subReasonOptionValue
    subReasonOptionsData = [];
    @api setProductDataList;
    @api isCashJourney;
    @api currentPayload;

    label = {
        Notification,
        RebookReason,
        RebookSubReason,
        Confirm,
        Cancel,
        ChangingtheAppointmentTime,
        ChangingtheAppointmentDate
    }

    connectedCallback() {
        this.isRequestModel = this.isRebookingRequestModel ;
        console.log('this.isRequestModel',this.currentPayload);
        console.log('this.isRequestMode2',this.isCashJourney);
        console.log('this.isRequestMode3',this.setProductDataList);
        console.log('this.isRequestModel inside Rebook request',this.isRequestModel);
        console.log('this.isRebookingRequestModel inside Rebook request',this.isRebookingRequestModel)
    }


    @wire(getObjectInfo, { objectApiName: SERVICE_APPOINTMENT_OBJECT })
    objectInfo({ error, data }) {
        if (data) {
            console.log('data', data);
            this.serviceAppointmentRecordTypeId = data.defaultRecordTypeId;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.serviceAppointmentRecordTypeId = undefined;
        }
    }


    @wire(getPicklistValues, { recordTypeId: "$serviceAppointmentRecordTypeId", fieldApiName: FailureReason })
    wiredReasonValues({ error, data }) {

        if (data) {
            this.reasonOptions = data.values;
            // this.reasonOptions = data.values.map(picklistValue => {
            //     return { label: picklistValue.label, value: picklistValue.value };
            // });
            console.log('this.reasonOptions', this.reasonOptions)
        } else if (error) {
            // Handle error
            console.error('error fetching picklist values for failure reason : '+JSON.stringify(error))
        }
    }



    /*@wire(getPicklistValues, {
        
        objectApiName: SERVICE_APPOINTMENT_OBJECT,
        
        fieldApiName: FailureReason
    })
    FailureReason({ error, data }) {
        console.log('objectApiName ----', JSON.stringify(SERVICE_APPOINTMENT_OBJECT));
        console.log('FailureReason ----', JSON.stringify(FailureReason));
        if (data) {
            this.picklistValues = {
                FailureReason: data.values.map(value => ({
                    label: value.label,
                    value: value.value
                }))
            };
        } else if (error) {
            console.error(error);
        }
    }*/

    @wire(getPicklistValues, { recordTypeId: "$serviceAppointmentRecordTypeId", fieldApiName: SubFailureReason })
    SubFailureReason({ error, data }) {
        //     if (data) {
        //         this.picklistValues = {
        //             //...this.picklistValues,
        //             SubFailureReason: data.values.map(value => ({
        //                 label: value.label,
        //                 value: value.value
        //             }))
        //         };

        //         console.log('this.picklistValues',this.picklistValues)
        //     } else if (error) {
        //         console.error(error);
        //     }


        if (data) {
            this.subReasonOptionsData = data;
            console.log('this.subReasonOptionsData', this.subReasonOptionsData)
            // this.picklistValues = data.values.map(picklistValue => {
            //     return { label: picklistValue.label, value: picklistValue.value };
            // });
            // console.log('this.picklistValues', this.picklistValues)
        } else if (error) {
            // Handle error
            console.error('error fetching picklist values for sub failure reason : '+JSON.stringify(error))
        
        }
    }


    /* handleBLN_failurereasonChange(event) {
         this.selectedValueBLN_failurereason = event.target.value;
     }*/
     handleReasonOptionChange(event) {
        // this.reasonValue = event.target.value;
        // this.disableSubReason = false;
        this.reasonOptionValue = event.target.value;
        let key = this.subReasonOptionsData.controllerValues[event.target.value];
        this.subReasonOptions = this.subReasonOptionsData.values.filter(opt => opt.validFor.includes(key));

    }

    handleBLN_SubFailureReasonChange(event) {
        this.subReasonOptionValue= event.target.value;
        console.log('this.selectedValueBLN_SubFailureReason',this.subReasonOptionValue);
    }
    handleConfirm() {
        if(this.subReasonOptionValue == '' || this.subReasonOptionValue == null || this.subReasonOptionValue == undefined || this.reasonOptionValue == '' || this.reasonOptionValue == null || this.reasonOptionValue == undefined) {
            console.log('this.reasonValue',this.reasonOptionValue);
            console.log('this.selectedValueBLN_SubFailureReason',this.subReasonOptionValue);
            this.toastError('Please fill required values','Error');
        } else {
            console.log('this.selectedValueBLN_SubFailureReason',this.subReasonOptionValue);
            const confirmEvent = new CustomEvent('confirm', {
                detail: {
                    rebookSubReasonOptionValue: this.subReasonOptionValue,
                    rebookReasonValue: this.reasonOptionValue
                }
            });
            console.log('Confirm event dispatched with detail:', JSON.stringify(confirmEvent.detail));
            this.dispatchEvent(confirmEvent);
        }
    }

    cancel() {
        this.isRequestModel = false;
        this.dispatchEvent(new CustomEvent('close'));
    }
    toastError(errorMsg, ErrorTitle) {
        LightningAlert.open({
            message: errorMsg,
            theme: 'error',
            label: ErrorTitle
        });
     }
}