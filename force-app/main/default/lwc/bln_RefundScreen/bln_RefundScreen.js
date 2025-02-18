import { LightningElement,api,wire,track } from 'lwc';
import RefundScreenHeader from '@salesforce/label/c.BLN_RefundScreenHeader';
import RefundPaymentLinkRecord from '@salesforce/label/c.BLN_RefundPaymentLinkRecord';
import PaymentReceived from '@salesforce/label/c.BLN_PaymentReceived';
import AvailableToRefund from '@salesforce/label/c.BLN_AvailableToRefund';
import Amount from '@salesforce/label/c.BLN_Amount';
import RefundReason from '@salesforce/label/c.BLN_RefundReason';
import RefundInitiatedBy from '@salesforce/label/c.BLN_RefundInitiatedBy';
import Back from '@salesforce/label/c.BLN_QuoteBack';
import Refund from '@salesforce/label/c.BLN_RefundButton';
import refundScreenAmountValidation from '@salesforce/label/c.BLN_RefundScreenAmountValidation';
import refundRecordCreationMessage from '@salesforce/label/c.BLN_RefundRecordCreationMessage';
import refundErrorMessage from '@salesforce/label/c.BLN_RefundErrorMessage';
import pushRefund from '@salesforce/apex/BLN_PushRefundtoGateway.pushRefundToGateway';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { createRecord } from 'lightning/uiRecordApi';
import Id from "@salesforce/user/Id";
import UserName_FIELD from '@salesforce/schema/User.Name';
import Payment_OBJECT from '@salesforce/schema/BLN_Payment__c';
import { getObjectInfo, getPicklistValues  } from 'lightning/uiObjectInfoApi';
import Name_FIELD from '@salesforce/schema/BLN_Payment__c.Name';
import PaymentAmountTaken_FIELD from '@salesforce/schema/BLN_Payment__c.BLN_PaymentAmountTaken__c';
import AmountAlreadyRefunded_FIELD from '@salesforce/schema/BLN_Payment__c.BLN_AmountAlreadyRefunded__c';
import Reason_FIELD from '@salesforce/schema/BLN_Payment__c.BLN_Reason__c';
import InitiatedBy_FIELD from '@salesforce/schema/BLN_Payment__c.BLN_InitiatedBy__c';
import PaymentTime_FIELD from '@salesforce/schema/BLN_Payment__c.BLN_InitiatedDateTime__c';
import BarclaysGatewayProvider from '@salesforce/label/c.BLN_BarclaysGatewayProvider';
import Case_FIELD from '@salesforce/schema/BLN_Payment__c.BLN_Case__c';
import RecordType_FIELD from '@salesforce/schema/BLN_Payment__c.RecordTypeId';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import OriginalPayment_FIELD from '@salesforce/schema/BLN_Payment__c.BLN_OriginalPayment__c';
import RefundType_FIELD from '@salesforce/schema/BLN_Payment__c.BLN_RefundType__c'; 
import PmtGatewayProvider_FIELD from '@salesforce/schema/BLN_Payment__c.BLN_PmtGatewayProvider__c';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';
import { NavigationMixin } from 'lightning/navigation';
import RctMethodId_FIELD from '@salesforce/schema/BLN_Payment__c.BLN_RctMethodId__c';
import RctMethod_FIELD from '@salesforce/schema/BLN_Payment__c.BLN_RctMethod__c';
import PmtType_FIELD from '@salesforce/schema/BLN_Payment__c.BLN_PaymentType__c';
import TokenNumber_FIELD from '@salesforce/schema/BLN_Payment__c.BLN_PaymentId__c';
const fields = [Name_FIELD, PaymentAmountTaken_FIELD, AmountAlreadyRefunded_FIELD,Reason_FIELD,InitiatedBy_FIELD,PaymentTime_FIELD,Case_FIELD,RecordType_FIELD,OriginalPayment_FIELD,RctMethodId_FIELD,RctMethod_FIELD,RefundType_FIELD,PmtGatewayProvider_FIELD,TokenNumber_FIELD, PmtType_FIELD];

export default class Bln_RefundScreen extends NavigationMixin(LightningElement){
    label={
        RefundScreenHeader,
        RefundPaymentLinkRecord,
        PaymentReceived,
        AvailableToRefund,
        Amount,
        RefundReason,
        RefundInitiatedBy,
        Back,
        Refund,
        refundRecordCreationMessage,
        refundErrorMessage

    }
    @api availableActions = [];
    @api recordId;
    @api finishFlow;
    @api refundButtonClicked;
    @track userId = Id;
    @track objectInfo;
    error;
    data;
    paymentId;
    name;
    userName;
    paymentTaken;
    paymentGateway;
    availableToRefundAmount;
    reasonText;
    amount='';
    caseId;
    refundRecordTypeId;
    disableFlag=true;
    reason='';
    paymentDefaultRecordTypeId;
    @track optionsList = [];
    recMethod;
    recMethodId;
    paymentType;
    
    
    /*To get payment record data */
    @wire(getRecord, { recordId: "$recordId", fields })
    paymentRecord ;
    
    
    /*To get current logged-in user details*/
    @wire(getRecord, { recordId: Id, fields: [UserName_FIELD] })
    userRecord({data,error}){
        if(data){
            this.userName = data.fields.Name.value;
        }
        if(error){
            this.error = error;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error",
                    message: this.error,
                    variant: 'error',
                }),
            );
        }
    };
    
    /*This method will store record id of refunds record type in 'refundRecordTypeId' this variable */
    @wire(getObjectInfo, { objectApiName: Payment_OBJECT })
    objectInfoResult({data,error}){
        if(data){
            this.paymentDefaultRecordTypeId = data.defaultRecordTypeId; //to store default recordtypeid to get picklist values
           // Returns a map of record type Ids
            const rtis = data.recordTypeInfos;
            Object.keys(rtis).forEach(element => {
                if(rtis[element].name == 'Refunds'){
                    this.refundRecordTypeId = element;// this will store id of refunds record type from Record Type object
                }
            });
        }
        if(error){
            this.error = error;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error",
                    message:this.error,
                    variant: 'error',
                }),
            );
        }
    }
    
    /*To show reasons options*/
    @wire(getPicklistValues, { recordTypeId: "$paymentDefaultRecordTypeId", fieldApiName: Reason_FIELD })
    picklistResults({ error, data }) {
        if (data) {
            this.optionsList = data.values;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.optionsList = undefined;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error",
                    message: this.error,
                    variant: 'error',
                }),
            );
        }
    }

    /*To get linkToPaymentRecord id */
    get linkToPaymentRecord() {
        this.name = getFieldValue(this.paymentRecord.data, Name_FIELD);
        this.caseId = getFieldValue(this.paymentRecord.data , Case_FIELD);// to assign caseId

        return this.name;
    }




    /*To get paymentReceived field value  */
    get paymentReceived() {
        this.paymentTaken = getFieldValue(this.paymentRecord.data, PaymentAmountTaken_FIELD);
        this.paymentGateway = getFieldValue(this.paymentRecord.data, PmtGatewayProvider_FIELD);
        this.recMethod=getFieldValue(this.paymentRecord.data , RctMethod_FIELD);
        this.recMethodId=getFieldValue(this.paymentRecord.data , RctMethodId_FIELD);
        this.paymentType=getFieldValue(this.paymentRecord.data , PmtType_FIELD);
        return getFieldValue(this.paymentRecord.data, PaymentAmountTaken_FIELD);
    }
  
    /*To find availableToRefund amount */
    get availableToRefund(){
        let paymentAmountTaken = getFieldValue(this.paymentRecord.data, PaymentAmountTaken_FIELD);
        let amountAlreadyRefunded =  getFieldValue(this.paymentRecord.data,AmountAlreadyRefunded_FIELD);
        let diff = paymentAmountTaken - amountAlreadyRefunded;
        let ret = Math.round((diff + Number.EPSILON) * 100) / 100
        // this.availableToRefundAmount = paymentAmountTaken - amountAlreadyRefunded;
        this.availableToRefundAmount = ret;

        return (ret);
    }

    /*To handle amount value entered on screen*/
    handleAmount(event){
        this.amount = event.target.value;
        if(this.amount != '' && this.reason != '' && this.amount > 0 && this.amount <= this.availableToRefundAmount){
            this.disableFlag=false;
        }else{
            this.disableFlag=true;
        }

        if (this.amount > Math.abs(this.availableToRefundAmount)) {
            event.target.setCustomValidity(refundScreenAmountValidation);
            let amountcolour= this.template.querySelector('.inputAmount');
            amountcolour.classList.add("amountRed");
           
        } else {
            
            event.target.setCustomValidity('');
            let amountcolour= this.template.querySelector('.inputAmount');
            amountcolour.classList.remove("amountRed");
        }
        event.target.reportValidity();
    }
    
    /*to handle selected reason on the screen*/
    handleReason(event){
        this.reason = event.target.value;

        if(this.amount != '' && this.reason != '' && this.amount <= this.availableToRefundAmount){
           this. disableFlag=false;
        }else{
            this.disableFlag=true;
        }
    }
    
    /*To navigate to back to payment record */
    handleBackButton(event){
        var actionClicked = event.target.name;
        if (actionClicked) {
            this.dispatchEvent(new FlowAttributeChangeEvent("finishFlow",true));
            if(this.availableActions.find(element => element=='NEXT')){
                this.dispatchEvent(new FlowNavigationNextEvent());
            }  
        } 
    }

    /*To create refund record after clicking on refund button from screen */
    createRefundRecord(){
       
        this.errorFlag=false;
        var today = new Date();
        this.date = today.toISOString();
        const fields = {};
        fields[Case_FIELD.fieldApiName] = this.caseId;
        fields[PaymentAmountTaken_FIELD.fieldApiName] = this.amount;
        fields[Reason_FIELD.fieldApiName] = this.reason ;
        fields[InitiatedBy_FIELD.fieldApiName] = this.userName;
        fields[PaymentTime_FIELD.fieldApiName] = this.date; 
        fields[RecordType_FIELD.fieldApiName] = this.refundRecordTypeId;
        fields[OriginalPayment_FIELD.fieldApiName] = this.recordId;
        fields[RctMethodId_FIELD.fieldApiName] = this.recMethodId;
        fields[RctMethod_FIELD.fieldApiName] = this.recMethod;
        fields[PmtGatewayProvider_FIELD.fieldApiName] = this.paymentGateway;
        fields[PmtType_FIELD.fieldApiName] = this.paymentType;
        fields[TokenNumber_FIELD.fieldApiName] = getFieldValue(this.paymentRecord.data, TokenNumber_FIELD) != null ? getFieldValue(this.paymentRecord.data, TokenNumber_FIELD) : '';
        if(this.amount < this.paymentTaken){
            fields[RefundType_FIELD.fieldApiName] = 'Partial';
        }else if(this.amount == this.paymentTaken){
            fields[RefundType_FIELD.fieldApiName] = 'Full';
        }
        
        const recordInput = { apiName: Payment_OBJECT.objectApiName, fields };
            createRecord(recordInput)
                .then(payment => {
                    this.paymentId = payment.id;
                    if(this.paymentId){
                    pushRefund({paymentRecordId:this.paymentId})
                    }
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: refundRecordCreationMessage,
                            variant: 'success',
                        }),
                    );
                    

                    if (this.paymentId) {
                        this[NavigationMixin.Navigate]({
                                type: 'standard__recordPage',
                                attributes: {
                                    recordId: this.paymentId,
                                    actionName: 'view'
                                }
                            });
                    } 
                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: refundErrorMessage,
                            message: error.body.message,
                            variant: 'error',
                        }),
                    );
                });
    }
}