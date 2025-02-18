import { LightningElement, api, track, wire } from 'lwc';
import Back from '@salesforce/label/c.BLN_QuoteBack';
import Confirm from '@salesforce/label/c.BLN_QuoteConfirm';
import cardholderName from '@salesforce/label/c.BLN_CardHolderName';
import onlineCardPayment from '@salesforce/label/c.BLN_OnlineCardPayment';
import amountToBePaid from '@salesforce/label/c.BLN_AmountToBePaid';
import amountDue from '@salesforce/label/c.BLN_AmountDue';
import outstandingBalance from '@salesforce/label/c.BLN_OutstandingBalance';
import assisted from '@salesforce/label/c.BLN_Assisted';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent, FlowNavigationFinishEvent, FlowNavigationBackEvent, FlowNavigationPauseEvent } from 'lightning/flowSupport';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { IsConsoleNavigation, getFocusedTabInfo, closeTab } from 'lightning/platformWorkspaceApi';
import Payment_Method from "@salesforce/schema/BLN_Payment__c.BLN_PaymentMethod__c";
import Payment_OBJECT from '@salesforce/schema/BLN_Payment__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { createRecord } from 'lightning/uiRecordApi';
import Case_FIELD from '@salesforce/schema/BLN_Payment__c.BLN_Case__c';
import RecordType_FIELD from '@salesforce/schema/BLN_Payment__c.RecordTypeId';
import PaymentRecordType from '@salesforce/label/c.BLN_PaymentRecordType';
import UserName_FIELD from '@salesforce/schema/User.Name';
import InitiatedBy_FIELD from '@salesforce/schema/BLN_Payment__c.BLN_InitiatedBy__c';
import PaymentType_FIELD from '@salesforce/schema/BLN_Payment__c.BLN_PaymentType__c';
import PaymentTime_FIELD from '@salesforce/schema/BLN_Payment__c.BLN_PaymentTime__c';
import Id from "@salesforce/user/Id";
import PaymentAmountTaken_FIELD from '@salesforce/schema/BLN_Payment__c.BLN_PaymentAmountTaken__c';
import CardHolderName_FIELD from '@salesforce/schema/BLN_Payment__c.BLN_CardholderName__c';
import BarclaysGatewayProvider from '@salesforce/label/c.BLN_BarclaysGatewayProvider';
import ONLINEPAYMENTSValue from '@salesforce/label/c.BLN_ONLINEPAYMENTSValue';
import PmtGatewayProvider from '@salesforce/schema/BLN_Payment__c.BLN_PmtGatewayProvider__c';


export default class Bln_TradeAccountPaymentScreen extends NavigationMixin(LightningElement) {
    label = {
        cardholderName,
        onlineCardPayment,
        amountToBePaid,
        amountDue,
        outstandingBalance,
        Back,
        Confirm,
    };



    @api availableActions = [];
    @api maindatemap;
    @api parentArrayMap = [];
    @track childArrayMap = [];
    
    @api recordId;
    @api IsCancelled = false;
    @api IsConfirmed = false;
    confirmquote = false;
    confirmproduct = true;
    productTrue = true;
    closeTimeCalender = true;
    weather = false;
    isInsurance = false;
    @api location;
    @api earlyAppoitment;
    @api weatherAppoitment;
    @api vat;
    @api total;
    @api earlyAppoitmentSlot;
    @api weatherAppoitmentSlot;
    @api earlyAppoitmentMainDate;
    @api weatherAppoitmentMainDate;
    @api insurancevalue;
    @api productvalue;
    hideQuote;
    @api product;
    showProduct;
    @api handlePaymentScreen;
    @api emptyProductList;
    @api cashpayment;
    @api insurancepayment;
    @api detailQuote;
    @api detailProduct;
    @api appointmentDate;
    @api balance;
    @api fromquote = false;
    @api fromconfirmquote = false;
    @api amountDue = 0;
    @api outstandingBalance = 0;
    @track record;
    @api caseid;
    @api finishFlow;
    @api back;
    @api paymentmethod;
    @api paymentId;
    paymentrecordtype;
    userName;
    @track userId = Id;


    isback = true;
    disableFlag = true;
    @track value = '';
    isAssisted = true;
    paymentScreen = false;
    cardName = '';
    amount = '';
    result;
    error;


    @wire(getObjectInfo, { objectApiName: Payment_OBJECT })
    objectInfo({ data, error }) {
        if (data) {
            // Returns a map of record type Ids
            const rtis = data.recordTypeInfos;
            Object.keys(rtis).forEach(element => {
                if (rtis[element].name == PaymentRecordType) {
                    this.paymentrecordtype = element;// this will store id of paymentrecordtype record type from Record Type object
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


    @wire(getRecord, { recordId: Id, fields: [UserName_FIELD] })
    userRecord({ data, error }) {
        if (data) {
            this.userName = data.fields.Name.value;
        }
    };



    connectedCallback() {
        this.paymentmethod = assisted;
    }

    /* To display radio options on the payment screen*/
    get options() {
        return [
            { label: assisted, value: assisted, }
        ];
    }
    value = assisted; //set default

    /*To enable/disable  StartPayment button */
    handleNameChange(event) {
        this.cardName = event.target.value;
        if (this.cardName != '' && this.amount != '') {
            this.disableFlag = false;
        } else {
            this.disableFlag = true;
        }
    }
    /*To enable/disable  StartPayment button */
    handleAmountChange(event) {

        this.amount = event.target.value;
        if (this.amount != '' && this.cardName != '' && this.amount > 0) {
            this.disableFlag = false;
        }
        else {
            this.disableFlag = true;
        }

    }

    @wire(IsConsoleNavigation) isConsoleNavigation;

    async closeTab() {
        try {
            if (this.isConsoleNavigation) {
                const { tabId } = await getFocusedTabInfo();
                await closeTab(tabId);
            }
        } catch (error) {
            console.error('Error closing tab:', error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'There was an error closing the tab.',
                    variant: 'error',
                }),
            );
        }
    }


    /// logic for back button from payement screen

    async backPaymentScreen() {

        if (this.fromquote == true) {     //  check payment screen appear thrugh quote screen.
            let productArrey = [...this.productvalue];
            let insuranceArrey = [...this.insurancevalue];

            this.hideQuote = false;
            this.showProduct = true;
            this.handlePaymentScreen = false;
            const selectBackEvent = new CustomEvent('backevent', {     // Custom event for back button
                detail: {
                    detailQuote: this.hideQuote,
                    detailProduct: this.showProduct,
                    emptyProductList: true,
                    location: this.location,
                    earlyAppoitment: this.earlyAppoitment,
                    weatherAppoitment: this.weatherAppoitment,
                    vat: this.vat,
                    total: this.total,
                    earlyAppoitmentSlot: this.earlyAppoitmentSlot,
                    weatherAppoitmentSlot: this.weatherAppoitmentSlot,
                    discount: this.discount,
                    productvalue: productArrey,
                    insuranceValue: insuranceArrey,
                    earlyMainDate: this.earlyAppoitmentMainDate,
                    weatherMaindate: this.weatherAppoitmentMainDate,
                    dateOpen: true,
                    slotsOpen: true,
                    cashpayment: this.cashpayment,
                    insurancepayment: this.insurancepayment,
                    mainDateList: this.maindatemap,
                    childarraymap: this.parentArrayMap,
                    handlePaymentScreen: false,
                    product: this.product,
                    appointmentDate: this.appointmentDate,
                    fromquote: this.fromquote
                },
            });
            this.dispatchEvent(selectBackEvent);
            this.productvalue = [];
        }
        else {


            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.recordId,
                    actionName: 'view',
                },
            });


            await this.closeTab();
        }

    }
   





    //added  on click of start payment
    async handleConfirm() {
        // this.URL = true;
        var today = new Date();
        this.date = today.toISOString();
        const fields = {};

        if (this.fromquote == true) {  // payment screen open through request quote 
            fields[Case_FIELD.fieldApiName] = this.caseid;
          
        }
        else {
            fields[Case_FIELD.fieldApiName] = this.recordId;   // payment screen open through Capture payment action 


        }


        // mapping of fields 
        fields[Payment_Method.fieldApiName] = this.paymentmethod;
        fields[RecordType_FIELD.fieldApiName] = this.paymentrecordtype;
        fields[InitiatedBy_FIELD.fieldApiName] = this.userName;
        fields[PaymentType_FIELD.fieldApiName] = ONLINEPAYMENTSValue;
        fields[PaymentAmountTaken_FIELD.fieldApiName] = this.amount;
        fields[CardHolderName_FIELD.fieldApiName] = this.cardName;
        fields[PmtGatewayProvider.fieldApiName] = BarclaysGatewayProvider;
        fields[PaymentTime_FIELD.fieldApiName] = new Date().toISOString();




        const recordInput = { apiName: Payment_OBJECT.objectApiName, fields }

        createRecord(recordInput)
            .then(payment => {
                this.paymentId = payment.id;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'record created',
                        variant: 'success',
                    }),
                );
                if (this.paymentmethod == assisted) {


                   this.dispatchEvent(new FlowAttributeChangeEvent("finishFlow", true));
                   if (this.availableActions.find(element => element == 'NEXT')) {

                    this.dispatchEvent(new FlowNavigationNextEvent());
                    }
                  else{
                        this.dispatchEvent(new FlowNavigationFinishEvent());

                  }
                       
                
                }

                

            })
            .catch(error => {

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'error while creating',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            });
       



    }
  
    

}