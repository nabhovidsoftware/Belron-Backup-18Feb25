import { LightningElement,api,track,wire } from 'lwc';
import Back from '@salesforce/label/c.BLN_QuoteBack';
import Confirm from '@salesforce/label/c.BLN_QuoteConfirm';
import amountToBePaidError from '@salesforce/label/c.BLN_AmountToBePaidError';
import cardholderName from '@salesforce/label/c.BLN_CardHolderName';
import onlineCardPayment from '@salesforce/label/c.BLN_OnlineCardPayment';
import amountToBePaid from '@salesforce/label/c.BLN_AmountToBePaid';
import amountDue from '@salesforce/label/c.BLN_AmountDue';
import outstandingBalance from '@salesforce/label/c.BLN_OutstandingBalance';
import True from '@salesforce/label/c.BLN_True';
import False from '@salesforce/label/c.BLN_False';
import automated from '@salesforce/label/c.BLN_Automated';
import assisted from '@salesforce/label/c.BLN_Assisted';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions'; 
import { FlowAttributeChangeEvent, FlowNavigationNextEvent,FlowNavigationFinishEvent,FlowNavigationBackEvent,FlowNavigationPauseEvent } from 'lightning/flowSupport';
import { getRecord,getFieldValue} from 'lightning/uiRecordApi';
import userHasPermissionSet from '@salesforce/apex/BLN_PaymentScreenController.getUserPermissionSet';
import paymentAutomatedInit from '@salesforce/apex/BLN_InitiateAutomPayment.paymentAutomatedInit';
import paymentAssisted from '@salesforce/apex/BLN_AssistedPaymentsController.generatedHexDigestkey';

//import { refreshApex } from '@salesforce/apex';
//import {CurrentPageReference} from 'lightning/navigation';
import TOTAL_MOTORIST_FIELD from "@salesforce/schema/Case.BLN_TotalMotoristLiability__c";
import OUTSTANDING_BALANCE_FIELD from "@salesforce/schema/Case.BLN_OutstandingBalance__c";
import Payment_Method from "@salesforce/schema/BLN_Payment__c.BLN_PaymentMethod__c";
import Payment_OBJECT from '@salesforce/schema/BLN_Payment__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { createRecord } from 'lightning/uiRecordApi';
import Case_FIELD  from '@salesforce/schema/BLN_Payment__c.BLN_Case__c';
import RecordType_FIELD from '@salesforce/schema/BLN_Payment__c.RecordTypeId';
import PaymentRecordType from '@salesforce/label/c.BLN_PaymentRecordType';
import UserName_FIELD from '@salesforce/schema/User.Name';
import InitiatedBy_FIELD from '@salesforce/schema/BLN_Payment__c.BLN_InitiatedBy__c';
import PaymentType_FIELD from '@salesforce/schema/BLN_Payment__c.BLN_PaymentType__c';
import Id from "@salesforce/user/Id";
import PaymentAmountTaken_FIELD from '@salesforce/schema/BLN_Payment__c.BLN_PaymentAmountTaken__c';
import CardHolderName_FIELD from '@salesforce/schema/BLN_Payment__c.BLN_CardholderName__c';
import BarclaysGatewayProvider from '@salesforce/label/c.BLN_BarclaysGatewayProvider';
import ONLINEPAYMENTSValue from '@salesforce/label/c.BLN_ONLINEPAYMENTSValue';
import PmtGatewayProvider from '@salesforce/schema/BLN_Payment__c.BLN_PmtGatewayProvider__c';
import { getFocusedTabInfo, closeTab } from 'lightning/platformWorkspaceApi';


const fields = [TOTAL_MOTORIST_FIELD,OUTSTANDING_BALANCE_FIELD]
export default class Bln_PaymentScreenCmp extends NavigationMixin(LightningElement) {

    label = {
        cardholderName,
        onlineCardPayment,
        amountToBePaid,
        amountDue,
        outstandingBalance  ,
        Back,
        Confirm,
    };
    //4608
    @track insurance = [];
    @track otherInsurance = [];
    @track selectedRows = [];
    @track insuranceRows = [];
    @api discount ;
   
    weathersTrue = false;
    isAssisted=false;
    isAutomated = true;
    @track backQuoteArrey = [];
    @api availableActions = [];
    @track arreyMapQuote = [];
    @track backProduct =[];
    @track backValueArray = [];
    @api maindatemap;
    @api parentArrayMap = [];
    @track childArrayMap = [];
    @track buttonBooleanConfirm = true;
    confirmButton = true;
    @api recordId;
    @api IsCancelled = false;
    @api IsConfirmed = false;
    confirmquote = false;
    confirmproduct = true;
    productTrue = true;
    closeTimeCalender = true;
    weather = false ; 
    isInsurance =false;
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
    @api fromquote=false;
    @api fromconfirmquote=false;
    @api amountDue=0; 
    @api outstandingBalance=0;
    @track record;
    @api caseid;
    @api finishFlow;
    @api paymentmethod;
    @api paymentId;
    paymentrecordtype;
    userName;
    @track userId = Id;
    @track capturePayment = true;

    ///end 4608
    disableFlag=true;
    value = '';
    paymentScreen = false;
    cardName='';
    amount='';
    result;
    error;

    //added for 6982 to get payment record type
    @wire(getObjectInfo, { objectApiName: Payment_OBJECT })
    objectInfo({data,error}){
        if(data){
            // Returns a map of record type Ids
            const rtis = data.recordTypeInfos;
            Object.keys(rtis).forEach(element => {
                if(rtis[element].name == PaymentRecordType){
                    this.paymentrecordtype = element;// this will store id of paymentrecordtype record type from Record Type object
                }
            });
        }
        if(error){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error",
                    message: error.body.message,
                    variant: 'error',
                }),
            );
        }
    }
    //added for 6982 to get the logged in user name
    @wire(getRecord, { recordId: Id, fields: [UserName_FIELD] })
    userRecord({data,error}){
    if(data){
        this.userName = data.fields.Name.value;
    }
};
    /*4980 Get Value from case and show on Payment Screen*/
    @wire(getRecord, { recordId: '$recordId', fields})
    wiredCase({ error, data }) {
        if (data && this.fromconfirmquote==false) {
          this.record = data;
          console.log('Data'+JSON.stringify (this.record));
          this.amountDue = getFieldValue(this.record, TOTAL_MOTORIST_FIELD); 
          this.outstandingBalance= getFieldValue(this.record, OUTSTANDING_BALANCE_FIELD);
          this.error = undefined;
        } else if (error) {
          this.error = error;
          this.record = undefined;
        }
    }

    /* To display radio options on the payment screen*/
      get options() {
        return [
            { label:automated, value:automated },
            { label:assisted, value:assisted,}
        ];
    }
    value = automated;/* To select default radio option */
   /* To check which permission set is asssigned to logged-in user*/
   connectedCallback(){
    userHasPermissionSet()
        .then(result=>{
        this.userPS = result;
		if(this.userPS == True){
            this.value = automated;
            this.paymentmethod = automated;  //added for 6982 to set payment method
        }
        /*FOUK-4766 Assisted button to be the default payment option selected */
        if(this.userPS == False){
            console.log('PSassigned123')
            this.value = assisted;
            this.paymentmethod = assisted; //added for 6982 to set payment method
            
        }
        })
        .catch((error) => {
           this.error = error;
        });
    }
    handleOptions(event) {
        this.paymentmethod = event.target.value;
    }
    /*To enable/disable  StartPayment button */
    handleNameChange(event){
        this.cardName=event.target.value;
        if(this.cardName != '' && this.amount!=''){
            this.disableFlag=false;
        }else {
            this.disableFlag=true; 
        }
    }
    /*To enable/disable  StartPayment button */
    handleAmountChange(event){
        this.amount=event.target.value;
        if(this.amount != '' && this.cardName != '' && this.amount <= this.outstandingBalance && this.amount > 0){
            this.disableFlag = false;
        }
        else{
            this.disableFlag = true; 
        }
        if (this.amount > this.outstandingBalance) {
            event.target.setCustomValidity(amountToBePaidError);
            let amountcolour= this.template.querySelector('.inputamount');
            amountcolour.classList.add("amountRed");
           
        } else {
            
            event.target.setCustomValidity('');
            let amountcolour= this.template.querySelector('.inputamount');
            amountcolour.classList.remove("amountRed");
        }
        event.target.reportValidity();
    }
    // 4979, skip payment on the basis of fromquote
    skipPayment() {
        getFocusedTabInfo().then(tabinfo => closeTab(tabinfo.tabId));
      
        //this.dispatchEvent(new FlowAttributeChangeEvent('IsCancelled', true));
        // if (this.availableActions.find((action) => action === 'FINISH')){
        //     const navigationEvent = new FlowNavigationFinishEvent();
        //     this.dispatchEvent(navigationEvent);
        // }
        // this.dispatchEvent(new FlowAttributeChangeEvent('IsCancelled', true));
        // if (this.availableActions.find((action) => action === 'FINISH')) {
        // navigationEvent = new FlowNavigationFinishEvent();
        // this.dispatchEvent(navigationEvent)
        // }
        //  }
                            //  this.dispatchEvent(new FlowAttributeChangeEvent("finishFlow",true));
                            //  if(this.availableActions.find(element => element=='NEXT')){
                            //      this.dispatchEvent(new FlowNavigationNextEvent());
                            //  } 

   if(this.fromquote == true) {
        console.log('skip1');
        // this.dispatchEvent(new FlowAttributeChangeEvent('IsCancelled', true));
        // const navigateNextEvent = new FlowNavigationNextEvent();
        // this.dispatchEvent(navigateNextEvent)
        // this[NavigationMixin.Navigate]({
        //     type: 'standard__recordPage',
        //     attributes: {
        //         recordId: this.caseid,
        //         objectApiName: 'Case',
        //         actionName: 'view',
        //     },
        // });
    }
    else{ 
            // this[NavigationMixin.Navigate]({
            //     type: 'standard__recordPage',
            //     attributes: {
            //         recordId: this.recordId,
            //         objectApiName: 'Case',
            //         actionName: 'view',
            //     },
            // });
            // this.dispatchEvent(new FlowAttributeChangeEvent("finishFlow",true));
            // if(this.availableActions.find(element => element=='NEXT')){
            //     this.dispatchEvent(new FlowNavigationNextEvent()); 
            // }
           
    }
         
}
    ///4608 added logic for back button from payement screen

    backPaymentScreen() {
    if(this.fromquote == true) {     // 4979 check payment screen appear thrugh quote screen.
    let productArrey = [...this.productvalue];
    let insuranceArrey = [...this.insurancevalue];

    this.hideQuote = false;
    this.showProduct = true;
    this.handlePaymentScreen=false;
    const selectBackEvent = new CustomEvent('backevent', {     // Custom event for back button
    detail: {
        detailQuote : this.hideQuote,
        detailProduct : this.showProduct,
        emptyProductList : true,
        location : this.location,
        earlyAppoitment : this.earlyAppoitment,
        weatherAppoitment : this.weatherAppoitment,
        vat : this.vat,
        total : this.total,
        earlyAppoitmentSlot : this.earlyAppoitmentSlot,
        weatherAppoitmentSlot : this.weatherAppoitmentSlot,
        discount : this.discount,
        productvalue : productArrey,
        insuranceValue : insuranceArrey,
        earlyMainDate : this.earlyAppoitmentMainDate,
        weatherMaindate : this.weatherAppoitmentMainDate,
        dateOpen : true,
        slotsOpen : true,
        cashpayment : this.cashpayment,
        insurancepayment : this.insurancepayment,
        mainDateList : this.maindatemap,
        childarraymap : this.parentArrayMap,
        handlePaymentScreen :false,
        product : this.product,
        appointmentDate : this.appointmentDate,
       fromquote: this.fromquote
    },
    });
    this.dispatchEvent(selectBackEvent);
    this.productvalue = [];
    }
    else{   //4979  if back is on payment action
            getFocusedTabInfo().then(tabinfo => closeTab(tabinfo.tabId));
            // this[NavigationMixin.Navigate]({
            //     type: 'standard__recordPage',
            //     attributes: {
            //         recordId: this.recordId,
            //         objectApiName: 'Case',
            //         actionName: 'view',
            //     },
            // });
            console.log('inside closeAction ');
            //this.capturePayment = false;
            //this.dispatchEvent(new CloseActionScreenEvent());
           // this.closeTab();
        // this.dispatchEvent(new FlowAttributeChangeEvent("finishFlow",true));
        // if(this.availableActions.find(element => element=='NEXT')){
        //     this.dispatchEvent(new FlowNavigationNextEvent());
        // }   
        
            // this.dispatchEvent(new FlowAttributeChangeEvent('IsCancelled', true));
            // //  if (this.availableActions.find((action) => action === 'FINISH')) {
            // const navigateNextEvent = new FlowNavigationFinishEvent();
            // this.dispatchEvent(navigateNextEvent)
            //  }
        }
    }
//added for 6982 on click of start payment
async handleConfirm(){
   // this.URL = true;
   var today = new Date();
   this.date = today.toISOString();
   const fields = {};

   if(this.fromquote == true){  // payment screen open through request quote 
    fields[Case_FIELD.fieldApiName] = this.caseid;
   }
   else{
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
                console.log('payment id is : ',this.paymentId)
                if(this.paymentmethod == assisted){
                    this.isAutomated = false;

                this.dispatchEvent(new FlowAttributeChangeEvent("finishFlow",true));
                    if(this.availableActions.find(element => element=='NEXT')){
                        this.dispatchEvent(new FlowNavigationNextEvent());
                    }
                   else {
                       this.dispatchEvent(new FlowNavigationFinishEvent()); 
                       //this.closeTab();
                    }
                }
                /*if(this.paymentmethod == assisted){
                    
                    paymentAssisted({paymentId:this.paymentId})
                    this.isAutomated = false;
                    this.isAssisted=true;
                    console.log('inside if at 420'+this.paymentmethod);
                    console.log('this.paymentId-in-->',this.paymentId);
             }4767*/
             console.log('this.paymentId--->',this.paymentId);
                if(this.paymentId && this.paymentmethod != assisted){
                    paymentAutomatedInit({paymentRecordId:this.paymentId})
                }
                if (this.paymentId && this.paymentmethod != assisted) {
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: this.paymentId,
                            actionName: 'view'
                        } 
                    });
                    this.dispatchEvent(new FlowAttributeChangeEvent('IsCancelled', true));
                    const navigateNextEvent = new FlowNavigationNextEvent();
                    this.dispatchEvent(navigateNextEvent)

                    this.dispatchEvent(new FlowAttributeChangeEvent("finishFlow",true));
                    if(this.availableActions.find(element => element=='NEXT')){
                    this.dispatchEvent(new FlowNavigationNextEvent());
        }  
                }    
            })
            .catch(error => {
                console.log('error'+JSON.stringify(error));
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'error while creating',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            });
            console.log('payment method is -- : ',this.paymentmethod);
            console.log('is assisted : ',assisted);
    }
}