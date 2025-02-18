import { LightningElement, track, wire, api } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import SERVICE_APPOINTMENT_OBJECT from '@salesforce/schema/ServiceAppointment';
import FailureReason from "@salesforce/schema/ServiceAppointment.BLN_FailureReason__c";
import SubFailureReason from "@salesforce/schema/ServiceAppointment.BLN_SubFailureReason__c";
import updatenewSA from "@salesforce/apex/bln_PortalServiceAppoinmentupdate.updateServiceRequest";
//import updateoldSA from "@salesforce/apex/bln_PortalServiceAppoinmentupdate.updateOldServiceRequest";
import AutoglassLogo from '@salesforce/resourceUrl/BLN_AutoglassLogo';
import Notification from '@salesforce/label/c.BLN_Notification';
import RebookReason from '@salesforce/label/c.BLN_RebookReason';
import RebookSubReason from '@salesforce/label/c.Bln_RebookSubReason';
import Confirm from '@salesforce/label/c.BLN_Confirm';
import Cancel from '@salesforce/label/c.BLN_Cancel';
import ChangingtheAppointmentTime from '@salesforce/label/c.Bln_ChangingtheAppointmentTime';
import ChangingtheAppointmentDate from '@salesforce/label/c.BLN_ChangingtheAppointmentDate';
import { NavigationMixin } from 'lightning/navigation';

export default class Bln_RebookRequestPortal extends  NavigationMixin(LightningElement) {
   // export default class Bln_RebookRequestPortal extends LightningElement {
    message;
    @api selectslotdate;
    @api startdate;
    @api enddate;
    @api isRebookingRequestModel;
    @api recordId;
    isRequestModel = true;
    @api serviceappointmentId;
    @api newappoinmetid;
    @track starttime;
    @track endtime;
    @track rebookReasonValue;
    @track rebookSubReasonValue;
    @track rebookSubReasonOptions;
    @track showModal = false;

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
        // console.log('this.isRequestModel',this.currentPayload);
        // console.log('this.isRequestMode2',this.isCashJourney);
        // console.log('this.isRequestMode3',this.setProductDataList);
        // console.log('this.isRequestModel inside Rebook request',this.isRequestModel);
        // console.log('this.isRebookingRequestModel inside Rebook request',this.isRebookingRequestModel)
    }
    


    @wire(getObjectInfo, { objectApiName: SERVICE_APPOINTMENT_OBJECT })
    objectInfo({ error, data }) {
        if (data) {
            // console.log('data', data);
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
            // console.log('this.reasonOptions', this.reasonOptions)
        } else if (error) {
            // Handle error
            // console.error('error fetching picklist values for failure reason : '+JSON.stringify(error))
        }
    }

    get formattedSlotDate() {
        const date = new Date(this.selectslotdate);
        const weekday = date.toLocaleDateString('en-US', { weekday: 'short' });
        const day = date.getDate();
        const month = date.toLocaleDateString('en-US', { month: 'short' });
    
        return `${weekday} ${day} ${month}`;
    }
    
    
    get formattedTime() {
        // Split the selectslot string to extract the start time
        const startTime = this.selectslot.split('-')[0].trim();
        const endTime = this.selectslot.split('-')[1].trim();
        this.starttime = startTime;
        this.endtime = endTime;
        //alert('starttime=>'+startTime);
        //alert('selectslot=>'+this.selectslot);
        return startTime; // Return the formatted start time
    }
   

    @wire(getPicklistValues, { recordTypeId: "$serviceAppointmentRecordTypeId", fieldApiName: SubFailureReason })
    SubFailureReason({ error, data }) {
       

        if (data) {
            this.subReasonOptionsData = data;
            // console.log('this.subReasonOptionsData', this.subReasonOptionsData)
            // this.picklistValues = data.values.map(picklistValue => {
            //     return { label: picklistValue.label, value: picklistValue.value };
            // });
            // console.log('this.picklistValues', this.picklistValues)
        } else if (error) {
            // Handle error
            // console.error('error fetching picklist values for sub failure reason : '+JSON.stringify(error))
        
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
        // console.log('this.selectedValueBLN_SubFailureReason',this.subReasonOptionValue);
    }
    handleConfirm() {
      
          // Additional validation if needed
          if (!this.selectslot) {
            throw new Error('selectslot cannot be null.');
        }

        updatenewSA({
            recordId : this.recordId,
            newAppointmentId : this.newappoinmetid,
            selectslotdate : this.selectslotdate,
            starttime : this.starttime,
            endtime : this.endtime

        })
        .then( result => {
           
            
          //  alert('enter success newappoinmetid '+this.newappoinmetid);
         

            // let url = '/SelfServe/s/case/';
            //     url += this.recordId + '/detail' + '?sid=' + this.newappoinmetid;
            // // Navigate to the URL using NavigationMixin
            //     this[NavigationMixin.Navigate]({
            //     type: 'standard__webPage',
            //     attributes: {
            //         url: url
            //     }
                
            // });
          
        })
        .catch( err => {
            console.log('afterhr Error', err);
        })
        .finally( () => {
            // window.location.reload();
        });
        
        let url = '/SelfServe/s/case/';
        url += this.recordId + '/detail' + '?sid=' + this.newappoinmetid;
         // Navigate to the URL using NavigationMixin
        this[NavigationMixin.Navigate]({
        type: 'standard__webPage',
        attributes: {
            url: url
        }
       
    });
    window.location.href = url;
    }
    
    
    cancel() {
        this.isRequestModel = false;
       
    }
   
}