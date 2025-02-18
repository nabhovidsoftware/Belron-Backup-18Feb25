import { LightningElement,api,wire } from 'lwc';
import ScreenHeader from '@salesforce/label/c.BLN_DebtorScreenConfirmationMessage';
import DebtorReason from '@salesforce/label/c.BLN_DebtorReason';
import Back from '@salesforce/label/c.BLN_QuoteBack';
import Confirm from '@salesforce/label/c.BLN_QuoteConfirm';
import WaivedReceiptReason from '@salesforce/label/c.BLN_WaivedReceiptReason';
import BACSPayment from '@salesforce/label/c.BLN_BACSPayment';
import BLN_CustomerNon_Contactable from '@salesforce/label/c.BLN_CustomerNon_Contactable';
import CardStolen from '@salesforce/label/c.BLN_CardStolen';
import DebtorInitiatedBy from '@salesforce/label/c.BLN_DebtorInitiatedBy';
import UserName_FIELD from '@salesforce/schema/User.Name';
import Id from "@salesforce/user/Id";
import AccountField from '@salesforce/schema/Case.AccountId';
import AccountId from '@salesforce/schema/Account.Id';
import CaseId from '@salesforce/schema/Case.Id';
import { updateRecord } from 'lightning/uiRecordApi';
import DebtorCreatedBy_FIELD from '@salesforce/schema/Case.BLN_DebtorCreatedBy__c';

import DebtorFlagAccount_FIELD from '@salesforce/schema/Account.BLN_DebtorFlag__c';
import DebtorFlagCorporate_FIELD from '@salesforce/schema/BLN_Corporate__c.BLN_DebtorFlag__c';
import DebtorReason_FIELD from '@salesforce/schema/Case.BLN_DebtorReason__c';
import Corporate_FIELD from '@salesforce/schema/Case.BLN_Corporate__c';
import EBSDebtorReason_FIELD from '@salesforce/schema/Case.BLN_EBSDebtorReason__c';
import Status_FIELD from '@salesforce/schema/Case.Status';
import DebtorCreateationDateTime_FIELD from '@salesforce/schema/Case.BLN_DebtorCreationDateTime__c';
import BillingMethod_FIELD from '@salesforce/schema/Case.BLN_BillingMethod__c';
import { NavigationMixin } from 'lightning/navigation';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent,FlowNavigationFinishEvent,FlowNavigationBackEvent,FlowNavigationPauseEvent } from 'lightning/flowSupport';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import IncorrectBilling from '@salesforce/label/c.BLN_IncorrectBilling';
import GONEWITHOUTPAYING from '@salesforce/label/c.BLN_GONEWITHOUTPAYING';
import NoPaymentFromMobileJob from '@salesforce/label/c.BLN_NoPaymentFromMobileJob';
import NoMeansOfPayment from '@salesforce/label/c.BLN_NoMeansOfPayment';
import NotPaidEnough from '@salesforce/label/c.BLN_NotPaidEnough';
import hasPermission from '@salesforce/customPermission/BLN_CustomerAccountsAdvisor';


export default class Bln_CreateDebator extends NavigationMixin(LightningElement) {
    @api recordId;
    @api finishFlow;
    @api availableActions = [];
    @api successflag;
    disableFlag=true;
    hasPermission = hasPermission;
    userName;
    reason='';
    label={
        ScreenHeader,
        DebtorReason,
        Back,
        Confirm,
        WaivedReceiptReason,
        DebtorInitiatedBy
    }

    get options() {
        if((this.hasPermission)){
            return [
                { label: BACSPayment, value: BACSPayment },
                { label: BLN_CustomerNon_Contactable, value: BLN_CustomerNon_Contactable },
                { label: CardStolen, value: CardStolen},
                { label: IncorrectBilling, value: IncorrectBilling}
            ];
        } else {
            return [
                { label: BACSPayment, value: BACSPayment },
                { label: BLN_CustomerNon_Contactable, value: BLN_CustomerNon_Contactable },
                { label: CardStolen, value: CardStolen}
            ];
        }
    }
    //Get the case's policyholderID and debtor flag fields
    @wire(getRecord, { recordId: '$recordId', fields:[ DebtorFlagCorporate_FIELD, BillingMethod_FIELD, Corporate_FIELD, AccountField] })
    caseRecord;

    //To get current logged-in user details*/
    @wire(getRecord, { recordId: Id, fields: [UserName_FIELD] })
    userRecord({data,error}){
        if(data){
            this.userName = data.fields.Name.value;
        }
    };
   // To handle reson selected  by user on the screen */
    handleReason(event){
        this.reason = event.target.value;
        if(this.reason != ''){
            this. disableFlag=false;
        } else{
            this.disableFlag=true;
        }
    }

    //on click of back button navigate to case record
    handleBackButton(event){        
        if (this.recordId) {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.recordId,
                    objectApiName: 'Case',
                    actionName: 'view'
                }
            });
            this.dispatchEvent(new FlowAttributeChangeEvent("finishFlow",true));
            if(this.availableActions.find(element => element=='NEXT')){
                this.dispatchEvent(new FlowNavigationNextEvent()); 
            }else{
                this.dispatchEvent(new FlowNavigationFinishEvent()); 
            }
            
        }
    }

    // on click of confirm button case and account fields updated.
    updateCaseFields(){
        var today = new Date();
        this.date = today.toISOString();
        const fields = {};

        fields[CaseId.fieldApiName] = this.recordId; //populate caseid
        fields[Status_FIELD.fieldApiName] = 'Closed-Completed'; //populate status field for update
        fields[DebtorReason_FIELD.fieldApiName] = this.reason;  //populate reason field
        fields[DebtorCreatedBy_FIELD.fieldApiName] = this.userName;
        fields[DebtorCreateationDateTime_FIELD.fieldApiName] = this.date;
        
        if(this.reason === BACSPayment){
            fields[EBSDebtorReason_FIELD.fieldApiName] = NoPaymentFromMobileJob; 
        }
        if(this.reason === BLN_CustomerNon_Contactable){
            fields[EBSDebtorReason_FIELD.fieldApiName] = GONEWITHOUTPAYING;
        }
        if(this.reason === CardStolen){
            fields[EBSDebtorReason_FIELD.fieldApiName] = NoMeansOfPayment;
        }
        if(this.reason === IncorrectBilling){
            fields[EBSDebtorReason_FIELD.fieldApiName] = NotPaidEnough;
        }

        // const accountId = getFieldValue(this.caseRecord.data, PolicyHolderId_FIELD);
        const accountId = getFieldValue(this.caseRecord.data, AccountField);
        const accountFields = {};
    //    accountFields[AccountId.fieldApiName] = accountId;
       
       const billMethod = getFieldValue(this.caseRecord.data, BillingMethod_FIELD);
       const corporateID = getFieldValue(this.caseRecord.data, Corporate_FIELD);
    //    console.log('corporate ', getFieldValue(this.caseRecord.data, Corporate_FIELD));
        if(billMethod === 'Cash')
        {
            accountFields[AccountId.fieldApiName] = accountId;
            accountFields[DebtorFlagAccount_FIELD.fieldApiName] = true;
        }
        else
        {
            accountFields[AccountId.fieldApiName] = corporateID;
            accountFields[DebtorFlagCorporate_FIELD.fieldApiName] = true;
        }

        // accountFields[AccountField.fieldApiName] = true;
       const accountRecordInput = { fields: accountFields };
        const recordInput = { fields };
        console.log(accountRecordInput);
        // console.log(recordInput);
        
        updateRecord(accountRecordInput).then(() =>{
            updateRecord(recordInput).then(()=>{
                this.dispatchEvent(
                    new ShowToastEvent({
                    title: 'Success',
                    message: 'Case Record updated with Debtor values',
                    variant: 'success'
                      })
                    );
               if (this.recordId) {
                   this[NavigationMixin.Navigate]({
                       type: 'standard__recordPage',
                       attributes: {
                           recordId: this.recordId,
                           objectApiName: 'Case',
                           actionName: 'view'
                       }
                   });
               }
               this.dispatchEvent(new FlowAttributeChangeEvent("finishFlow",true));
               if(this.availableActions.find(element => element=='NEXT')){
                   this.dispatchEvent(new FlowNavigationNextEvent()); 
               }else{
                   this.dispatchEvent(new FlowNavigationFinishEvent()); 
               }
            }).catch(error =>{
                console.log(error);
                this.dispatchEvent(
                    new ShowToastEvent({
                            title: 'Error creating record',
                            message: error.body.message,
                            variant: 'error'
                    })
            );
            })
        }).catch(error => {
            console.log(error);
            this.dispatchEvent(
                    new ShowToastEvent({
                            title: 'Error creating record',
                            message: error.body.message,
                            variant: 'error'
                    })
            );
        }); 
    }
}