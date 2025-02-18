import { LightningElement, api, wire,track } from 'lwc';
import { RefreshEvent } from 'lightning/refresh';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getQueueName from '@salesforce/apex/BLN_UpdateCaseOwnerController.getQueueName';
import labelName from '@salesforce/label/c.BLN_UpdateButtonText';
import caseOwnerText from '@salesforce/label/c.BLN_CaseOwner';
import submitButton from '@salesforce/label/c.BLN_SubmitButton';
import toastMessage from '@salesforce/label/c.BLN_ToastMessage';
import errorToastMessage from '@salesforce/label/c.BLN_ToastErrorMessage';
import errorTitle from '@salesforce/label/c.BLN_ErrorTitle';
import successTitle from '@salesforce/label/c.BLN_SuccessTitle';
import recoveryTeam from '@salesforce/label/c.BLN_RecoveryTeamQueue';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord,getFieldValue} from 'lightning/uiRecordApi';

export default class Bln_AssignToRecoveryTeam extends NavigationMixin(LightningElement) {
    label = {
        labelName,
        caseOwnerText,
        submitButton,
        toastMessage,
        errorToastMessage,
        errorTitle,
        successTitle
    };
    @api recordId;
    @track isLoading = false;
    @track disableButton = false;
    isModalOpen = false;
    queue = {};
    @track record;
    @track error;
    @wire(getRecord, { recordId: '$recordId', fields : ['Case.OwnerId','Case.Owner.Name'] })
    wiredCase({ error, data }) {
        if (data) {
          this.record = data;
          this.disableButton = getFieldValue(this.record,'Case.Owner.Name' ) == recoveryTeam ? true:false ; 
          this.error = undefined;
        } else if (error) {
          this.error = error;
          this.record = undefined;
        }
      }
      
    handleUpdateCaseOwner(){
        this.isLoading = true;
        this.isModalOpen = true;
        getQueueName()
        .then(result => {
            this.queue = result;
            this.isLoading = false;            
        })
        .catch(error => {
            
            this.dispatchEvent(
                new ShowToastEvent({
                    titile: errorTitle,
                    message: errorToastMessage,
                    variant:'error'
                })
            );
        });
        
    }
    
    handleSuccess(event){
        const updatedRecordId = event.detail.id;
        if(updatedRecordId){
            this.disableButton = true;
        }
        else{
            this.disableButton = false;
        }
        this.isLoading = false;
        this.dispatchEvent(new RefreshEvent());
        this.isModalOpen = false;
        this.dispatchEvent(
            new ShowToastEvent({
                title: successTitle,
                message: toastMessage,
                variant: 'success'
            })
        );
        
    }
    
    handleSubmit(event){
        event.preventDefault();       
        const fields = event.detail.fields;
        fields.OwnerId = this.queueId;
        this.template.querySelector('lightning-record-edit-form').submit(fields);             
    }

    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }
}