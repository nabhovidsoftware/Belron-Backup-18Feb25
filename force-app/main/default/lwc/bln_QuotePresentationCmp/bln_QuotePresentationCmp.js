import { LightningElement, track,wire, api } from 'lwc';
import Price from '@salesforce/label/c.BLN_QuotePrice';
import AfterHours from '@salesforce/label/c.BLN_QuoteAfterHours';
import Appointment from '@salesforce/label/c.BLN_QuoteAppointment';
import Back from '@salesforce/label/c.BLN_QuoteBack';
import Confirm from '@salesforce/label/c.BLN_QuoteConfirm';
import Discount from '@salesforce/label/c.BLN_QuoteDiscount';
import Name from '@salesforce/label/c.BLN_QuoteName';
import Net from '@salesforce/label/c.BLN_QuoteNet';
import Product from '@salesforce/label/c.BLN_QuoteProduct';
import Qty from '@salesforce/label/c.BLN_QuoteQty';
import Select from '@salesforce/label/c.BLN_QuoteSelect';
import Total from '@salesforce/label/c.BLN_QuoteTotal';
import VAT from '@salesforce/label/c.BLN_QuoteVAT';
//import insuranceTotal from '@salesforce/label/c.BLN_Total';
import insuranceLiability from '@salesforce/label/c.BLN_InsuranceLiability';
import accountLiability from '@salesforce/label/c.BLN_AccountLiability';
import motoristLiability from '@salesforce/label/c.BLN_MotoristLiability';
import CASE_OBJECT from "@salesforce/schema/Case";
import CASE_FIELD from "@salesforce/schema/Case.Id";
import TOTAL_MOTORIST_FIELD from "@salesforce/schema/Case.BLN_TotalMotoristLiability__c";
import TOTAL_ACCOUNT_FIELD from "@salesforce/schema/Case.BLN_TotalAccountLiability__c";
import TOTAL_INSURANCE_FIELD from "@salesforce/schema/Case.BLN_TotalInsuranceLiability__c";
import WeatherGuardAppointment from '@salesforce/label/c.BLN_QuoteWeatherGuardAppointment';
//import liability from '@salesforce/apex/BLN_ProductAvailability.liability';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import billingMethod from '@salesforce/label/c.BLN_billingMethod';
import slotBooked from '@salesforce/apex/BLN_AppointmentBooking.bookAppointment';
import knowledgeArticle from '@salesforce/apex/BLN_ProductAvailability.displayLocation';
import schduleAppoitment from '@salesforce/apex/BLN_AppointmentBooking.scheduleAppointment';

export default class Bln_QuotePresentationCmp extends LightningElement {
    
    label = {
        Price,
        AfterHours,
        Appointment,
        Back,
        Confirm,
        Discount,
        Name,
        Net,
        Product,
        Qty,
        Select,
        Total,
        VAT,
        WeatherGuardAppointment
    };

    @track tableData;
    showProduct;
    hideQuote;
    tableDataboolean=false;
    cash = false;
    insurance = false;
    @api insurancepayment =false;
    @api cashpayment =false;
    @track backProduct =[];
   @api handlePaymentScreen= false;    
   @api location;
   @api earlyAppoitment;
   @api weatherAppoitment;
   @api vat;
   @api total;
   @api earlyAppoitmentSlot;
   @api weatherAppoitmentSlot;
   @api discount = 0;
   @api productvalue;
   @api product;
   @api insurancevalue;
   @api otherinsurance;
   @api slotdatafromparent;
   @api recordid;
   @track appointmentDate;
   @track weatherAppoitmentDate;
   @api earlyAppoitmentMainDate;
   @api weatherAppoitmentMainDate;
   @api maindatemap;
   @api parentarraymap;
   @track test=false;
   @api emptyProductList;
   @api detailProduct;
   @api detailQuote;
    confirmquote =false;
   @api confirmproduct;
   @track backValueArray = [];
   @track backQuoteArrey = [];
   trueBoolean = false;
   mainDateQuoteList = [];
   @track childArrayMap = [];
   @api availableActions = [];
   @api caseid;
  // @api balance=0;
   @api fromquote=false;
   @api outstandingBalance=0;
   @api amountDue=0; 
   totalInsuranceLiability=0;
   totalAccountLiability=0;
   @api fromconfirmquote=false;
   @api articleOpen=false;
   @api knowladgeArticleObj; 
   @api screenName;
   @api showArticle;
   @api said;
   @api slotendparent;
   @api slotstartparent;
   @api booleanFlagQuote=false;
   @api articles;
   
   get inputVariables() {
    return [
        {
            name: 'booleanFlagQuote',
            type: 'Boolean',
            value: this.booleanFlagQuote
        }
    ];
}

   connectedCallback() {
    this.getknowledgeArticlesQuote();
    console.log('slotdatafromparent',JSON.stringify(this.slotdatafromparent));
    console.log('insurancedataFromParent',JSON.stringify(this.insurancevalue));
   }

   // FOUK-4914 to fetch knowledge article on the basis of screen value.
   getknowledgeArticlesQuote(){
       return knowledgeArticle()
       .then(result=>{
        const copyItems = [];
           this.knowladgeArticleObj = result;
           this.knowladgeArticleObj .forEach((item) => {
            if(item.screenName=='Quote Summary'){
            copyItems.push(item);
            }
          });
          if(copyItems.length>0){
          this.showArticle=copyItems;
          this.articleOpen =true;
          this.booleanFlagQuote=true;
          console.log('quoteboolean'+this.booleanFlagQuote);
           return result;
          }
       })
           .catch(error=>{
           console.log('Error 97 : ',error.body.message);
       })
   }

   
   backScreen(){
      let productArrey = [...this.productvalue];
        let insuranceArrey = [...this.insurancevalue];

     this.hideQuote = false;
     this.showProduct = true;
        const selectEvent = new CustomEvent('hideshow', {
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
            mainDateList : this.maindatemap,
            childarraymap : this.parentarraymap,
            product : this.product,
            slotfromchildtwo : this.slotdatafromparent,
            slotstfromchtwo : this.slotstartparent,
            slotedfromchtwo : this.slotendparent,
            slotsaid : this.said
        },
      });
      this.dispatchEvent(selectEvent);
      this.productvalue = [];
    }

    @api childDetails(){
       /*Check Billing Method On Case Record*/
        if(this.recordid == 'Cash'){
           this.cash = true;
           this.cashpayment=true;
        }

        if(this.recordid == 'Insurance / Account'){
            this.insurance = true;
            this.insurancepayment=true;
        }

        /*Convert the date format*/
        if(this.earlyAppoitment){
            const dateString = this.earlyAppoitment; //input appointment date string
            const dateObject = new Date(dateString); //parse the date string to a JavaScript Date Object
            const formattedDate = this.formatDate(dateObject); //format the date using Intl.DateTimeFormat
            this.appointmentDate = formattedDate; // assign formated date
        }
        if(this.weatherAppoitment){
            const weatherAppDateString = this.weatherAppoitment; //input weatherAppoitment date string
            const weatherDateObject = new Date(weatherAppDateString); //parse the date string to a JavaScript Date Object
            const whatherformattedDate = this.formatDate(weatherDateObject);//format the date using Intl.DateTimeFormat
            this.weatherAppoitmentDate = whatherformattedDate; //assign formated date
        }
    }

    formatDate(dateObject){
        const day = dateObject.getDate();
        const dayWithSuffix = this.addSuffixToDay(day);
        const formattedDate = new Intl.DateTimeFormat('en-US',{
            year:'numeric',
            month:'long',
            day:'numeric'}).format(dateObject);
        return formattedDate.replace(String(day),dayWithSuffix);
       }
        
        addSuffixToDay(day){
            if(day>=11 && day<=13){
                return day +'th';
            }
            switch(day % 10){
                case 1: 
                    return day + 'st';
                case 2: 
                    return day + 'nd';
                case 3: 
                    return day + 'rd';
                default:
                    return day+ 'th';
            }
        }
     // Navigate to payment screen or case record page based on recordid and Motorist Liability's total value
        handleConfirm(event){

            if(this.recordid == billingMethod){
            for (let i = 0; i < this.otherinsurance.length; i++) {
                const currentInsurance = this.otherinsurance[i];
                
               
               /* if (currentInsurance.liability === insuranceTotal ) { //FOUK-4980 Pass value on payment screen for amount Due
                    const total=currentInsurance.total;
                    this.amountDue = parseInt( total.replaceAll(',',''));
                }*/
                if(currentInsurance.liability === insuranceLiability ){
                    const totalInsuranceValue = currentInsurance.totalIncludingTaxPayable; //FOUK-4740
                    this.totalInsuranceLiability=totalInsuranceValue;
                    //this.totalInsuranceLiability =parseInt(totalInsuranceValue.replaceAll(',',''));
                }
                if(currentInsurance.liability === accountLiability ){
                    const totalAccountValue = currentInsurance.totalIncludingTaxPayable; //FOUK-4740
                    //this.totalAccountLiability =parseInt(totalAccountValue.replaceAll(',',''));
                    this.totalAccountLiability=totalAccountValue;
                }

                if (currentInsurance.liabilityCategory === motoristLiability ) {
                  const totalValue = currentInsurance.totalIncludingTaxPayable; //FOUK-4980 pass the value on payment screen for OB
                    this.outstandingBalance =totalValue;
                    this.amountDue=totalValue;
                    //this.outstandingBalance =parseInt(totalValue.replaceAll(',',''));

        
                    if (this.outstandingBalance <= 0) {                 // Navigate to payment screen if Motorist Liability's total value greater than zero'
                        const fields = {};
                         fields['Id'] = this.caseid; //populate caseid
                         fields['Status'] = 'Open'; //populate status field for update
                          const recordInput = { fields };
                           updateRecord(recordInput) .then(() => {
                           this.dispatchEvent(
                              new ShowToastEvent({
                              title: 'Success',
                              message: 'Record updated',
                              variant: 'success'
                                })
                              );
                            }) .catch(error => {
                                    this.dispatchEvent(
                                            new ShowToastEvent({
                                                    title: 'Error creating record',
                                                    message: error.body.message,
                                                    variant: 'error'
                                            })
                                    );
                            });
                            this.dispatchEvent(                                     // Show the warning message pmce user redirect to case record
                                new ShowToastEvent({
                                title: 'Redirecting to case]',
                                message: 'Motorist liabitlity total value is less than zero',
                                variant: 'warning'
                                  })
                                );
                        this.dispatchEvent(new FlowAttributeChangeEvent('IsCancelled', true));
                        const navigateNextEvent = new FlowNavigationNextEvent();
                        this.dispatchEvent(navigateNextEvent)
                            
                    } else {   
                        console.log('Inside else handle payment');                           // Navigate to payment screen if Motorist Liability's total value greater than zero'
                        this.handlePaymentScreen = true;
                        this.fromquote = true;   //4979  send true it is coming from quote presentation screen
                        this.fromconfirmquote = true//4980 if it from confirm button
                    } 
                }
                
            } 
            /*FOUK-4740 update case fields*/
            if(this.outstandingBalance!=null ||  this.totalAccountLiability!=null || this.totalInsuranceLiability!=null){
                const fields = {};
                console.log('Inside If');
                fields[CASE_FIELD.fieldApiName] = this.caseid;
                fields[TOTAL_MOTORIST_FIELD.fieldApiName] = this.outstandingBalance;
                fields[TOTAL_ACCOUNT_FIELD.fieldApiName] = this.totalAccountLiability; 
                fields[TOTAL_INSURANCE_FIELD.fieldApiName] =this.totalInsuranceLiability; 
                
                const recordInput = { fields };
                updateRecord(recordInput);
            }  //End FOUK-4740 
        }else {
            this.handlePaymentScreen = true;   // Navigate to payment screen if recordid ='cash'
            this.fromquote = true;   //4979  send true it is coming from quote presentation screen
            this.fromconfirmquote= true; //4980 if it from confirm button

            console.log('Inside cash'+this.total);
            if(this.total!= null){ //4980 when case populate OB R amount on payment screen
                const amountValue = this.total; 
                console.log('Amount Value'+amountValue);
                this.outstandingBalance =amountValue;
                this.amountDue=amountValue; 
            }
            if(this.outstandingBalance!=null){
                const fields = {};
                console.log('Inside If case');
                fields[CASE_FIELD.fieldApiName] = this.caseid;
                fields[TOTAL_MOTORIST_FIELD.fieldApiName] = this.outstandingBalance; 
                
                const recordInput = { fields };
                updateRecord(recordInput);
            }  //End FOUK-4980 cash

        }
        this.slotBooking();
          
        }


      slotBooking(){
            // if(this.saidparent != '' && this.slotendparent != '' && this.slotstartparent != ''){
            //  this.startSlotTime = this.slotstartparent,
            //  this.endSlotTime = this.slotendparent,
            //  this.serviceAppId = this.saidparent
            // }
 
     slotBooked({
         slotStart : this.slotstartparent,
         slotFinish : this.slotendparent,
         appointmentId : this.said
     })
     .then( (result)=> {
         console.log('SlotBooking',result);
         this.schduleAppoitment();
     })
     .catch((error)=>{
         console.log('SlotBookingError',JSON.stringify(error));
     });
        }
 
  schduleAppoitment(){
     
    schduleAppoitment({
        appointmentId : this.said  
    })
    .then((result)=>{
        console.log('schduleAppoitment',result);
    })
    .catch((error)=>{
        console.log('schduleAppoitmentError',JSON.stringify(error));
    });
  }
        ///4608 handle back button functionality from payment screen
        handlePaymentScreenValue(event){
            this.backValueArray = [];
            this.handlePaymentScreen= false;
            this.cash=this.cashpayment;
            this.insurance=this.insurancepayment;
            this.confirmquote = event.detail.detailQuote;   // get all the values dispatch from the event.
            
            this.confirmproduct = event.detail.detailProduct;
            
            if(this.cashpayment == true){
                this.backQuoteArrey =  event.detail.productvalue;
            }else{
                this.backQuoteArrey =  event.detail.insuranceValue; 
            }

            this.trueBoolean =  event.detail.slotsOpen;
            this.earlyAppoitmentMainDate = event.detail.earlyMainDate;
            this.weatherAppoitmentMainDate = event.detail.weatherMaindate;
            this.mainDateQuoteList = event.detail.mainDateList;
            this.childArrayMap = event.detail.childarraymap;
            let newArray = [];
            this.location = event.detail.location;
           
            if( event.detail.earlyMainDate != '' && event.detail.earlyMainDate != undefined){
                newArray.push({
                    "earlyAppoitmentMainDate" : event.detail.earlyMainDate,
                    "vat" : event.detail.vat,
                    "discount" : event.detail.discount,
                    "total" : event.detail.total,
                    "earlyAppoitment" : event.detail.earlyAppoitment,
                    "earlyAppoitmentSlot" : event.detail.earlyAppoitmentSlot,
                    "slotsOpen" : event.detail.slotsOpen,
                    "dateOpen" : event.detail.dateOpen,
                    "location" : event.detail.location
               });
               console.log('event.details'+event.detail);
            }
            if( event.detail.weatherMaindate != '' && event.detail.weatherMaindate != undefined){ 
            newArray.push({
                "weatherAppoitmentMainDate" : event.detail.weatherMaindate,
                "vat" : event.detail.vat,
                "discount" : event.detail.discount,
                "total" : event.detail.total,
                "weatherAppoitment" : event.detail.weatherAppoitment,
                "weatherAppoitmentSlot" : event.detail.weatherAppoitmentSlot,
                "slotsOpen" : event.detail.slotsOpen,
                "dateOpen" : event.detail.dateOpen,
                "location" : event.detail.location
            });
            }
           this.backValueArray = JSON.parse(JSON.stringify(newArray));
    }
}