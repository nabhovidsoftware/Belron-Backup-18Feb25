import { LightningElement,api,wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import RecordType_FIELD from '@salesforce/schema/BLN_Corporate__c.RecordTypeId';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const FIELDS = [RecordType_FIELD];

export default class Bln_BvtAuthorisationScreenCmp extends LightningElement {
    
    @api recordId;
    recordTypeName;
    isInsurance=false;
    isCorporate=false;
    isSpiltBill=false;
    @wire(getRecord, { recordId: "$recordId",fields: FIELDS })
    wiredRecord({ error, data }) {
        if (data) {
            console.log('12979',data);
            this.recordTypeName = data.recordTypeInfo.name;
            if(this.recordTypeName=='Insurance'){
                this.isInsurance=true;
            }
            else if(this.recordTypeName=='Corporate/Fleet'){
                this.isCorporate=true;
            }
            else if (this.recordTypeName=='Split Bill'){
                this.isSpiltBill=true;
            }


        } else if (error) {
          
            console.log('error' + JSON.stringify(error));
        }
      }
      handleSucess(event){
           console.log('sucess');
        this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: event.detail.message,
                            variant: 'success'
                        })
                    );
                    this.dispatchEvent(new CloseActionScreenEvent());
      }
      handlefailure(event){
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: event.detail.message,
                variant: 'error'
            })
        );
        this.dispatchEvent(new CloseActionScreenEvent());
      }
      handleCancel(event){
        this.dispatchEvent(new CloseActionScreenEvent());
      }
}