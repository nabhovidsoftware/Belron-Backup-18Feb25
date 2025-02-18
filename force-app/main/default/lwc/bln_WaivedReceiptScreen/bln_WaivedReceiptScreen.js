import { LightningElement, api, track, wire } from 'lwc';
import CustomLookup from 'c/bln_CustomLookup';
import WaivedReceiptComment from '@salesforce/label/c.BLN_WaivedReceiptComment';
import WaivedReceiptReason from '@salesforce/label/c.BLN_WaivedReceiptReason';
import BLN_WaivedReceiptOBValidation from '@salesforce/label/c.BLN_WaivedReceiptOBValidation';
import WaivedReceiptAmountValidation from '@salesforce/label/c.BLN_WaivedReceiptAmountValidation';
import WaivedReceiptScreenHeader from '@salesforce/label/c.BLN_WaivedReceiptScreenHeader';
import refundErrorMessage from '@salesforce/label/c.BLN_RefundErrorMessage';
import Amount from '@salesforce/label/c.BLN_Amount';
import Back from '@salesforce/label/c.BLN_QuoteBack';
import Confirm from '@salesforce/label/c.BLN_QuoteConfirm';
import WaivedReceiptInitiatedBy from '@salesforce/label/c.BLN_WaivedReceiptInitiatedBy';
import WaivedReceiptCreation from '@salesforce/label/c.BLN_WaivedReceiptCreation';
import RefundRecordCreationMessage from '@salesforce/label/c.BLN_RefundRecordCreationMessage';
import Goodwill from '@salesforce/label/c.BLN_Goodwill';
import ScratchedGlass from '@salesforce/label/c.BLN_ScratchedGlass';
import StaffSale from '@salesforce/label/c.BLN_StaffSale';
import WaivedReceipts from '@salesforce/label/c.BLN_WaivedReceipts';
import RelatedJob from '@salesforce/label/c.BLN_RelatedJob';
import JobRequest from '@salesforce/label/c.BLN_JobRequest';
import OutstandingBalanceLabel from '@salesforce/label/c.BLN_OutstandingBalanceLabel';
import Feedback from '@salesforce/label/c.BLN_Feedback';
import Complaint from '@salesforce/label/c.BLN_Complaint';
import zero from '@salesforce/label/c.BLN_Zero';
import UserName_FIELD from '@salesforce/schema/User.Name';
import Id from "@salesforce/user/Id";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { createRecord } from 'lightning/uiRecordApi';
import Payment_OBJECT from '@salesforce/schema/BLN_Payment__c';
import Amount_FIELD from '@salesforce/schema/BLN_Payment__c.BLN_PaymentAmountTaken__c';
import Case_FIELD from '@salesforce/schema/BLN_Payment__c.BLN_Case__c';
import Reason_FIELD from '@salesforce/schema/BLN_Payment__c.BLN_Reason__c';
import InitiatedBy_FIELD from '@salesforce/schema/BLN_Payment__c.BLN_InitiatedBy__c';
import Comment_FIELD from '@salesforce/schema/BLN_Payment__c.BLN_Comment__c';
import RelatedComplaintCase_FIELD from '@salesforce/schema/BLN_Payment__c.BLN_RelatedComplaintCase__c';
import RecordType_FIELD from '@salesforce/schema/BLN_Payment__c.RecordTypeId';
import PaymentTime_FIELD from '@salesforce/schema/BLN_Payment__c.BLN_InitiatedDateTime__c';
import TotalMotoristLiability_FIELD from '@salesforce/schema/Case.BLN_TotalMotoristLiability__c';
import Oustandingbalance_FIELD from '@salesforce/schema/Case.BLN_OutstandingBalance__c';
import CaseNumber_FIELD from '@salesforce/schema/Case.CaseNumber';
import RELATED_JOB_FIELD from '@salesforce/schema/Case.AccountId';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';
import { NavigationMixin } from 'lightning/navigation';
import PaymentStatus_FIELD from '@salesforce/schema/BLN_Payment__c.BLN_PaymentStatus__c';
import PaymentType_FIELD from '@salesforce/schema/BLN_Payment__c.BLN_PaymentType__c';
import StatusFIELD from '@salesforce/schema/BLN_Payment__c.BLN_Status__c';
import RctMethodId_FIELD from '@salesforce/schema/BLN_Payment__c.BLN_RctMethodId__c';
import RctMethod_FIELD from '@salesforce/schema/BLN_Payment__c.BLN_RctMethod__c';
import BLN_BBWaived from '@salesforce/label/c.BLN_BBWaived';
import BLN_RecMethodID from '@salesforce/label/c.BLN_RecMethodID';
import BLN_BranchPaymentType from '@salesforce/label/c.BLN_BranchPaymentType';
import BLN_PaymentStatusSuccess from '@salesforce/label/c.BLN_PaymentStatusSuccess'

const fields = [TotalMotoristLiability_FIELD, Oustandingbalance_FIELD, CaseNumber_FIELD, RELATED_JOB_FIELD];


export default class Bln_WaivedReceiptScreen extends NavigationMixin(LightningElement) {
    label = {
        WaivedReceiptComment,
        WaivedReceiptReason,
        WaivedReceiptAmountValidation,
        WaivedReceiptScreenHeader,
        Amount,
        WaivedReceiptInitiatedBy,
        Back,
        Confirm,
        WaivedReceiptCreation,
        RefundRecordCreationMessage,
        WaivedReceiptAmountValidation,
        RelatedJob,
        OutstandingBalanceLabel,
        BLN_BranchPaymentType,
        BLN_PaymentStatusSuccess

    }

    @api recordId;
    @track caseNumber;
    @track relatedJobId;
    @track relatedCases = [];
    @api finishFlow;
    @api caseType;
    @api caseSubType;
    @api confirmButtonClicked;
    @track userId = Id;
    @api availableActions = [];
    @track objectInfo;
    userName;
    paymentStatus;
    paymentType;
    status;
    comment;
    refundRecordTypeId;
    caseId;
    reason = '';
    amount = '';
   jobcasenumber = '';
    disableFlag = true;
    totalMotoristLiability;
    amountValidation = false;
    paymentId;
    oustandingbalancevalue = 0;


    /*To show reasons options*/
    get options() {
        return [
            { label: Goodwill, value: Goodwill },
            { label: ScratchedGlass, value: ScratchedGlass },
            { label: StaffSale, value: StaffSale }
        ];
    }

    // added for FOUK-5730 to get totalMotoristLiability value
    @wire(getRecord, { recordId: "$recordId", fields })
    caseRecord({ data, error }) {
        if (data) {
      
            
            if (this.caseType === JobRequest) {
                this.totalMotoristLiability = getFieldValue(data, TotalMotoristLiability_FIELD);
                this.oustandingbalancevalue = getFieldValue(data, Oustandingbalance_FIELD);
                this.caseNumber = getFieldValue(data, CaseNumber_FIELD);
                console.log('this.caseNumber', this.caseNumber);
            }
            else if (this.caseSubType === Complaint && this.caseType === Feedback) {
               this.relatedJobId = getFieldValue(data, RELATED_JOB_FIELD);
                 //console.log('data :::', JSON.stringify(data));

                
            }
        }
        if (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error",
                    message: error.body.message,
                    variant: 'error',
                }),
            );
        }
    }

handleLookupUpdate(event) {
        //console.log('lookup', JSON.stringify(event.detail.selectedRecord));
     if (event.detail.selectedRecord) {
            this.jobcasenumber = event.detail.selectedRecord.Id;
            this.totalMotoristLiability = event.detail.selectedRecord.BLN_TotalMotoristLiability__c;
            this.oustandingbalancevalue = event.detail.selectedRecord.BLN_OutstandingBalance__c;

        } else {
            this.jobcasenumber = '';
            this.totalMotoristLiability = '';
            this.oustandingbalancevalue = zero;
            this.amount = '';
            this.reason = '';
            this.comment = '';
        }
        this.checkDisableFlag();
    }




    /*FOUK-5742 To handle amount value entered on screen */
    handleAmount(event) {
        this.amount = event.target.value;
        this.checkDisableFlag();

        // added for FOUK-5743 to compare amount value with oustanding balance
        if (this.amount > Math.abs(this.oustandingbalancevalue)) {
            event.target.setCustomValidity(BLN_WaivedReceiptOBValidation);
            let amountcolour = this.template.querySelector('.checkValidation');
            amountcolour.classList.add("amountRed");
        } else {
            event.target.setCustomValidity('');
            let amountcolour = this.template.querySelector('.checkValidation');
            amountcolour.classList.remove("amountRed");
        }
        event.target.reportValidity();

    }

    /*FOUK-5730 To get reson selected selected by user on the screen */
    handleReason(event) {
        this.reason = event.target.value;
        this.checkDisableFlag();
    }
    checkDisableFlag() {
         if (this.caseType === JobRequest) {
            if (this.amount != '' && this.reason != '' && this.amount > 0) {
                this.disableFlag = false;
            } else {
                this.disableFlag = true;
            }
        } else if (this.caseSubType === Complaint && this.caseType === Feedback) {
            if (this.amount != '' && this.reason != '' && this.jobcasenumber != '' && this.amount > 0) {
            this.disableFlag = false;
        } else {
            this.disableFlag = true;
        }
    }
    }
    /*FOUK-5730 To get comment added by user on the screen */
    handleComment(event) {
        this.comment = event.target.value;
    }

    /*FOUK-5730 To get current logged-in user details*/
    @wire(getRecord, { recordId: Id, fields: [UserName_FIELD] })
    userRecord({ data, error }) {
        if (data) {
            this.userName = data.fields.Name.value;
        }
    };


    /*FOUK-5730 This method will store record id of refunds record type in 'refundRecordTypeId' this variable */
    @wire(getObjectInfo, { objectApiName: Payment_OBJECT })
    objectInfo({ data, error }) {
        if (data) {
            // Returns a map of record type Ids
            const rtis = data.recordTypeInfos;
            Object.keys(rtis).forEach(element => {
                if (rtis[element].name == WaivedReceipts) {
                    this.refundRecordTypeId = element;// this will store id of refunds record type from Record Type object
                }
            });
        }
        if (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error",
                    message: error.body.message,
                    variant: 'error',
                }),
            );
        }
    }

    /*To navigate to back to payment record */
    handleBackButton(event) {
        var actionClicked = event.target.name;
        if (actionClicked) {
            this.dispatchEvent(new FlowAttributeChangeEvent("finishFlow", true));
            if (this.availableActions.find(element => element == 'NEXT')) {
                this.dispatchEvent(new FlowNavigationNextEvent());
            }
        }
    }
    /*FOUK-5730 To create refund record after clicking on refund button from screen */
    createWaivedRecord(event) {
        if (this.amount > Math.abs(this.totalMotoristLiability)) {
            this.amountValidation = true;
        }
        else if (this.amount > Math.abs(this.oustandingbalancevalue)) {
            this.amountValidation = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: refundErrorMessage,
                    message: BLN_WaivedReceiptOBValidation,
                    variant: 'error',
                }),
            );
        }
        else {
            this.amountValidation = false;
            var today = new Date();
            this.date = today.toISOString();
            const fields = {};
            fields[Case_FIELD.fieldApiName] = this.caseType === JobRequest ? this.recordId : this.jobcasenumber;                fields[Amount_FIELD.fieldApiName] = this.amount;
            fields[Reason_FIELD.fieldApiName] = this.reason;
            fields[InitiatedBy_FIELD.fieldApiName] = this.userName;
            fields[PaymentTime_FIELD.fieldApiName] = this.date;
            fields[RecordType_FIELD.fieldApiName] = this.refundRecordTypeId;
            fields[Comment_FIELD.fieldApiName] = this.comment;
            fields[PaymentStatus_FIELD.fieldApiName] =BLN_PaymentStatusSuccess;
            fields[StatusFIELD.fieldApiName] = BLN_PaymentStatusSuccess;
            fields[RctMethodId_FIELD.fieldApiName] = BLN_RecMethodID;
            fields[RctMethod_FIELD.fieldApiName] = BLN_BBWaived;
            fields[PaymentType_FIELD.fieldApiName] = BLN_BranchPaymentType;

            if (this.caseType === Feedback && this.caseSubType === Complaint) {
                fields[RelatedComplaintCase_FIELD.fieldApiName] = this.recordId;

            }

            const recordInput = { apiName: Payment_OBJECT.objectApiName, fields };

            createRecord(recordInput)
                .then(payment => {
                    this.paymentId = payment.id;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: WaivedReceiptCreation,
                            variant: 'success',
                        }),
                    );

                    this.dispatchEvent(new FlowAttributeChangeEvent('confirmButtonClicked',true));
                    this.dispatchEvent(new FlowNavigationNextEvent());

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
                    console.log('error1', JSON.stringify(error));
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
}