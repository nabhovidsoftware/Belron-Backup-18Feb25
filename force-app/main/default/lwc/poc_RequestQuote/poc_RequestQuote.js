import { LightningElement,wire,track,api} from 'lwc';
//import products from '@salesforce/apex/BLN_ProductAvailability.product';
//import jsonFile from '@salesforce/apex/BLN_QuoteJsonFile.parseJson';
import showProduct from '@salesforce/apex/BLN_ProductAvailability.createOrderItems';
//import orderList from '@salesforce/apex/BLN_TempProductAvailability.getAcceptedOrder';

//import showProduct from '@salesforce/apex/BLN_ProductResponseWrapper.parseJson';
import cancelLabel from '@salesforce/label/c.BLN_Cancel';
import knowledgeArticleFlowName from '@salesforce/label/c.BLN_KnowledgeArticleflow';
import select from '@salesforce/label/c.BLN_QuoteSelect';
import product from '@salesforce/label/c.BLN_QuoteProduct';
import QuotePresentation from '@salesforce/label/c.BLN_QuotePresentation';
//import insurance from '@salesforce/apex/BLN_ProductAvailability.insurance';
//import otherInsurance from '@salesforce/apex/BLN_ProductAvailability.liability';
import price from '@salesforce/label/c.BLN_QuotePrice';
import quantity from '@salesforce/label/c.BLN_QuoteQty';
import discount from '@salesforce/label/c.BLN_QuoteDiscount';
import reprise from '@salesforce/label/c.BLN_Reprise';
import Confirm from '@salesforce/label/c.BLN_QuoteConfirm';
import Vat from '@salesforce/label/c.BLN_QuoteVAT';
import Total from '@salesforce/label/c.BLN_QuoteTotal';
import Net from '@salesforce/label/c.BLN_QuoteNet';
import Name from '@salesforce/label/c.BLN_QuoteName';
import lowOffer from '@salesforce/label/c.BLN_Lowoffer';
import mediumOffer from '@salesforce/label/c.BLN_Mediumoffer';
import highOffer from '@salesforce/label/c.BLN_Highoffer';
import location from '@salesforce/label/c.BLN_Location';
import discountError from '@salesforce/label/c.BLN_DiscountError';
import discountBandHeader from '@salesforce/label/c.BLN_DiscountBandHeader';
import lowOfferStartValue from '@salesforce/label/c.BLN_LowOfferStartValue';
import negativeDiscountError from '@salesforce/label/c.BLN_NegativeDiscountError';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import selectLocationError from '@salesforce/label/c.BLN_SelectLocationError';
//import otherProduct from '@salesforce/apex/BLN_ProductAvailability.otherProducts';
import knowledgeArticle from '@salesforce/apex/BLN_ProductAvailability.displayLocation';
import makeQuoteCallout from '@salesforce/apex/BLN_ProductAvailability.makeQuoteCallout';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';
import hasPermission from '@salesforce/customPermission/BLN_ProductSelectionDiscountBand';
import hasPermissionSet from '@salesforce/customPermission/BLN_CERCustom';
import errorForTeamManager from '@salesforce/label/c.BLN_ErrorForTeamManager';
import USER_ID from '@salesforce/user/Id';
import PROFILE_FIELD from '@salesforce/schema/User.Profile.Name';
import IsWiper from '@salesforce/label/c.BLN_IsWiper';
import IsMotabilityAccount from '@salesforce/label/c.BLN_IsMotabilityAccount';
import NotMandatory from '@salesforce/label/c.BLN_NotMandatory';
import Mandatory from '@salesforce/label/c.BLN_Mandatory';
import { getRecord } from 'lightning/uiRecordApi';
import LightningAlert from 'lightning/alert';

export default class Bln_ProductSelectionAndAvailability extends LightningElement {
    @api caseid;
    @track date1 ;
    @track date2 ;
    @track date3 =new Date();
    @track whiteStyle="height:2rem;width:11.6rem; border:1px solid black;background:white";
    @track locStyle = "height:3rem;width:58.3rem; border:1px solid black;background:Darkgreen";
    @track product = [];
    @track showProductData = [];
    @track otherProduct = [];
    @track insurance = [];
    @track otherInsurance = [];
    @track selectedRows = [];
    @track insuranceRows = [];
    @track discount = 0 ;
    weathersTrue = false;
    @track backQuoteArrey = [];
    @api availableActions = [];
    @track arreyMapQuote = [];
    @track backProduct =[];
    @track backValueArray = [];
    @track maindateMap = [];
    @track parentArrayMap = [];
    @track childArrayMap = [];
    @track articleRes = [];
    @track slotDataFromChild = [];
    @track slotDataFromChildTwo = [];
    @api articleOpenprod = false;
    @track buttonBooleanConfirm = true;
    payloadBody;
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
    @api location = '';
    @api earlyAppoitment = '';
    @api weatherAppoitment;
    @api vat;
    @api total;
	@api earlyAppoitmentSlot = '';
    @api weatherAppoitmentSlot;
    @api earlyAppoitmentMainDate = '';
    @api weatherAppoitmentMainDate;
    orderIdList = [];
    slotstfromparent ='';
    slotedfromparent = '';
    saIdfromParent = '';
    mainDateQuoteList = [];
    trueBoolean = false;
    spinnerSiwtch = false;
    isVaps = false;
    isDiscountDisabled = false;
    @track jsonFileVar = [];
    productDataList = [];
    @track quoteDetailsDataList = [];
    @track liabilityDataList =[];
   loadLocationDateTimeSlot = false;
   sampleCheck = 5;
    discountBandDetails = [];
  
    @track earlistAvailibilityDetailsList = [];
    slotStTimeOne = '';
    slotEdTimeOne = '';
    sAId = '';
    @api screenName;
    @api knowladgeArticleObj;
    @track quoteRanges;
    @track maxdiscount;
    @track quoteRangeLocation;
    @api booleanFlagproduct=false;
    @api isVapsEnabled=false;
    @api isWiperEnabled=false;
    @api showArticle;
    @api accountName;
    isInsuranceDisount = true;
    hasPermission = hasPermission;
    hasPermissionCer = hasPermissionSet;
    profileName = '';
    label = {
        cancelLabel,
        quantity,
        discount,
        price,
        product,
        select,
        Vat,
        Total,
        Net,
        Name,
        reprise,
        Confirm,
        lowOffer,
        mediumOffer,
        highOffer,
        location,
        discountError,
        discountBandHeader,
        negativeDiscountError,
        selectLocationError,
        lowOfferStartValue,
        knowledgeArticleFlowName

    }
    
    get inputVariables() {
        return [
            {
                name: 'isVapsEnabled',
                type: 'Boolean',
                value: this.isVapsEnabled
            },
            {
                name: 'isWiperEnabled',
                type: 'Boolean',
                value: this.isWiperEnabled
            }
            
        ];
    }

    connectedCallback(){
        console.log('CaseID', this.caseid);
        console.log('Account name', this.accountName);
        console.log('billing method name', this.recordId);
        this.getknowledgeArticlesQuote();
          
        // if(!this.hasPermissionCer){
        //     this.isInsuranceDisount = true;
        // }
        //let response = await this.getknowledgeArticle();
     //  this.getknowledgeArticle();
        // this.articleRes = this.article.map((record)=>{
        //     return {
        //         ...record,
        //       ScreenName : record.BLN_Display_Location__c,
        //       Value :record.id,
        //     };
        // });
       // console.log('this.jsonFileVar',JSON.stringify(this.jsonFileVar));
       
         /* Old Json Code
       products()
        .then(result=>{
       // this.product = result;
        console.log('old-->',JSON.parse(JSON.stringify(result)));
        })
        .catch(error=>{
        const event = new ShowToastEvent({	
        variant: 'error',	
        message: 'Search text missing..'+JSON.stringify(error),	
        });	
        this.dispatchEvent(event);
        });*/


        /******3114  with new json*****/
    
        var today = new Date();
        this.date1= new Intl.DateTimeFormat( 'en-US' ).format( today );
        today.setDate(today.getDate()+1)
        this.date2 = new Intl.DateTimeFormat( 'en-US' ).format( today );
        today.setDate(today.getDate()+1)
        this.date3 = new Intl.DateTimeFormat( 'en-US' ).format( today );
        
        /*orderList({
            motoCaseId : this.caseid
        })
        .then( result => {
            console.log('orderList+++++',JSON.stringify(result));
            console.log('orderListSize++',result.length);
         
           this.makeQuoteCall();
        })
        .catch(error=>{
            console.log('ERR',error);
        });*/
        this.makeQuoteCall();
        // makeQuoteCallout({
        //     motoristCaseId : this.caseid
        // })
        // .then( result => {
        //     console.log('motristresult++',JSON.parse(JSON.stringify(result)));
        //     this.payloadBody = result;
        //     this.requiredProcesses();
        // })
        // .catch(error=>{
        //     console.log('ERR',error);
        // })


    }


   makeQuoteCall(){
        makeQuoteCallout({
            motoristCaseId : this.caseid
        })
        .then( result => {
            console.log('motristresult++',JSON.parse(JSON.stringify(result)));
            this.payloadBody = result;
            this.requiredProcesses();
        })
        .catch(error=>{
            console.log('ERR',error);
        })
    }
     requiredProcesses() {
     
       showProduct({ payload : this.payloadBody,
                   caseRecordId : this.caseid
        })
        .then(result=>{
           console.log('productDataList'+result.productDataList);
           console.log('RES-->',JSON.stringify(result));
           this.orderIdList = JSON.stringify(result);
             this.showProductData =  JSON.parse(JSON.stringify(result));
            console.log('SHOW-->',this.showProductData);
            this.productDataList = JSON.parse(JSON.stringify(this.showProductData.productDataList));
            this.insurance = this.productDataList;

            this.discountBandDetails = JSON.parse(JSON.stringify(this.showProductData.discountBandDetails));
            this.quoteDetailsDataList = JSON.parse(JSON.stringify(this.showProductData.quoteDetailsDataList));
            this.earlistAvailibilityDetailsList = JSON.parse(JSON.stringify(this.showProductData.earlistAvailibilityDetails));
            this.liabilityDataList = JSON.parse(JSON.stringify(this.showProductData.liabilityDataList));
            this.loadLocationDateTimeSlot = true;
            // this.product = this.productDataList; /*discount quote range code */
            this.quoteRanges = this.calculateQuoteRanges();
            console.log(' this.quoteRanges'+ JSON.stringify(this.quoteRanges));
            /*band code*/ 
            console.log('Show Insurance-->',this.insurance);
            console.log('SHOWWW-->',JSON.parse(JSON.stringify(this.showProductData.productDataList)));
            console.log('Show Product-->',this.productDataList);
            console.log('Show discountBandDetails-->'+JSON.stringify(this.discountBandDetails));
            console.log('Show quotedetails-->'+JSON.stringify(this.quoteDetailsDataList));
            console.log('Show earlistAvailibilityDetailsList-->'+JSON.stringify(this.earlistAvailibilityDetailsList));
            console.log('Show liabilityDataList--> ',this.liabilityDataList);
        }).catch(error=>{
            console.log('error occured-->'+JSON.stringify(error));
            const event = new ShowToastEvent({	
            variant: 'error',	
            message: 'Search text missing..'+JSON.stringify(error),
            title : 'Error'	
            });	
            this.dispatchEvent(event);
            });
            /* end 3114  with new json*/

        /*otherProduct()
        .then(result=>{
        this.otherProduct = result;
        const disc = this.otherProduct.shift()
        this.discount = disc.Discount
        })
        .catch(error=>{
          
        });*/
        if(this.recordId == 'Insurance / Account'){
            this.isInsurance = true;
            this.productTrue = false;
            
//        insurance()
//        .then(result=>{
//            console.log('InsuranceResult', JSON.stringify(result));
//            this.insurance = this.productDataList;
//       })
//        .catch(error =>{
//       });
        /*otherInsurance()
        .then(result=>{
            this.otherInsurance = result
        })
        .catch(error =>{
        });*/
        }
    }

   /*  getknowledgeArticle(){
        return knowledgeArticle()
        .then(result=>{
            this.knowladgeArticleObj = result;
            console.log('kno article111',JSON.stringify(this.knowladgeArticleObj));
            this.screenName = 'Quote Summary';
            this.articleOpen =true;
            return result;
        })
        .catch(error=>{
            console.log('Error 97 : ',error.body.message);
        })
    }
*/
    getknowledgeArticlesQuote(){
        return knowledgeArticle()
        .then(result=>{
         const copyItems = [];
            this.knowladgeArticleObj = result;
            this.knowladgeArticleObj .forEach((item) => {
             if(item.screenName==QuotePresentation){
             copyItems.push(item);
             console.log('screen1'+item.screenName);
             }
           });
           if(copyItems.length>0){
           this.showArticle=copyItems;
           this.articleOpenprod =true;
           console.log('screen');
            return result;
           }
        })
            .catch(error=>{
            console.log('Error 97 : ',error.body.message);
        })
    }
    
    // handleDiscount(event){
    //         this.discount = event.target.value;
    // }

    @wire(getRecord, { recordId: USER_ID, fields: [PROFILE_FIELD]}) 
    userDetails({error, data}) {
        if (data) {
           console.log('profileName12',JSON.stringify(data));
            this.profileName = data.fields.Profile.displayValue;
            console.log('profileName',this.profileName);
        } else if (error) {
            this.error = error ;
        }
    }
        
    handleCancel(event){
            /*redirect to case record*/
            var actionClicked = event.target.name;
            console.log('actionClicked'+actionClicked);
            console.log('this.availableActions'+this.availableActions);
            if (actionClicked) {
            this.dispatchEvent(new FlowAttributeChangeEvent('IsCancelled', true));
              if (this.availableActions.find((action) => action === 'NEXT')) {
                    const navigateNextEvent = new FlowNavigationNextEvent();
                    this.dispatchEvent(navigateNextEvent)
                }
            }
        }

        childValueReceive(event){
         //  this.handleConfirm();
            // if(event.detail.location != undefined &&  (event.detail.earlyAppoitment != undefined || event.detail.weatherAppoitment != undefined) 
            //   ){
            //   this.buttonBooleanConfirm = false;
            //   return;
            // }else{
            //     this.buttonBooleanConfirm = true;
            // }
           this.location = event.detail.location;
           this.earlyAppoitment= event.detail.earlyAppoitment;
           this.weatherAppoitment= event.detail.weatherAppoitment;
           this.vat= event.detail.vat;
           this.total= event.detail.total;
           this.earlyAppoitmentSlot= event.detail.earlyAppoitmentSlot;
           this.weatherAppoitmentSlot= event.detail.weatherAppoitmentSlot;
           this.weatherAppoitmentMainDate = event.detail.weatherAppoitmentMainDate;
           this.earlyAppoitmentMainDate = event.detail.earlyAppoitmentMainDate;
           this.maindateMap = event.detail.maindateList;
           this.parentArrayMap = event.detail.arrayMapChild1;
            this.slotDataFromChild = event.detail.slotDataToParent;
            this.slotStTimeOne = event.detail.slotstarttime;
            this.slotEdTimeOne = event.detail.slotendtime;
            this.sAId = event.detail.saId;
            //this.confirmbuttonDisabled();
        }

        handleChangeCheck(event){
            const checkedVlue = event.target.checked;
            console.log('checkedVlue',checkedVlue);
            const selesctedId = event.target.value;
            console.log('selesctedId',selesctedId);
            let selectedRow = this.productDataList.find(row => row.partOrBundleCode===selesctedId);
            console.log('selectedRow',selectedRow);
            console.log('optional',event.target.dataset.optionalvalue);
            let vapsCheckVar  = event.target.dataset.optionalvalue;
            if(vapsCheckVar.toLowerCase() != (Mandatory).toLowerCase()) {
                if(!this.isVapsEnabled){
                    this.isVapsEnabled = true;
                }
                else{
                    this.isVapsEnabled = false;
                }
            }
            //selectedRow.checked = event.target.checked;
            /*if(event.target.dataset.optionalvalue !='Mandatory' && checkedVlue==true){
				this.isVapsEnabled=true;
                console.log('mandatory');
            }
            else{
                
                /*    let isOptionalSelected = false;
                    for (let i = 0; i < this.selectedRows.length; i++) {
                        if (this.selectedRows[i].optional != 'Mandatory') {
                            console.log('nonm'+this.selectedRows[i].optional);
                            isOptionalSelected = true;
                            break;
                        }else{
                            console.log('non123');
                            this.isVapsEnabled =false;
                        }
                    }
                    this.isVapsEnabled = isOptionalSelected;
                
                this.isVapsEnabled=false;
            }*/
            if(checkedVlue){
                this.selectedRows.push(selectedRow);
                console.log('in if --selectedRow',selectedRow);
            }else{
                const product2 = this.selectedRows.find(item => item.productName );

                const index = this.selectedRows.findIndex(row =>row.partOrBundleCode === selesctedId);
                if(selesctedId !== null || selesctedId === ''){
                    this.selectedRows.splice(index,1);
                    if(this.selectedRows.length == 0) {
                        let discountField = this.template.querySelector('.inputamount');
                        discountField.value = null;
                        this.discount = 0;
                        discountField.setCustomValidity('');
                        discountField.reportValidity();
                    }
                }
            }
            if(this.selectedRows.find(item => item.productName === 'Weather Guard')){
                this.weathersTrue = true;
            }else{
                    this.weathersTrue = false;
            }

            if(this.selectedRows.find(item => (item.productName).includes(IsWiper) && (this.accountName).includes(IsMotabilityAccount))){
                console.log('wiper');
                this.isWiperEnabled = true;
                console.log(IsWiper+this.isWiperEnabled );
            }else{
                    this.isWiperEnabled = false;
                    console.log('wiper'+this.isWiperEnabled );
            }

            this.confimButton(event);
          //  this.confirmbuttonDisabled();
    }
    
    handleInsuranceCheck(event){
            const checkedVlue = event.target.checked;
            console.log('event.target.checked',event.target.checked);
            console.log('isVapProduct',event.target.dataset.isvap);
            const selesctedId = event.target.value;
            console.log('SeletedID-->',selesctedId);
            let selectedRow = this.insurance.find(row => row.partOrBundleCode == selesctedId);

            // if(event.target.dataset.isvap == 'true'){
            //     this.isInsuranceDisount = false;
            // }else{
            //     this.isInsuranceDisount = true; 
            // }
            let isVapArrey = [];
            if(checkedVlue){
                this.insuranceRows.push(selectedRow);
                console.log('insuranceRows', JSON.stringify(this.insuranceRows));
               
               


               /* //3993
                if(this.insuranceRows.find(item => item.qLIisVap === 'true')){
                    this.isVaps = true
					this.isDiscountDisabled = true;
                    console.log('isDiscountDisabled',this.isDiscountDisabled);
                    console.log('this.insuranceRows-->',this.insuranceRows);
                }*/
            }else{
              //  this.isVaps = false;//3393
			//	this.isDiscountDisabled = false;//3393
               // console.log('isDiscountDisabled',this.isDiscountDisabled);
               // console.log('this.insuranceRows-->',this.insuranceRows);
               const product2 = this.insuranceRows.find(item => item.productName );
                const index = this.insuranceRows.findIndex(row =>row.partOrBundleCode == selesctedId);
                if(selesctedId !== null || selesctedId === ''){
                    this.insuranceRows.splice(index,1);  
                }
                console.log('insuranceRowselse', JSON.stringify(this.insuranceRows));
            }

            this.insuranceRows.forEach( ele => {
                if((ele.optionalAttributeValue).toLowerCase() == (Mandatory).toLowerCase()){
                  isVapArrey.push(ele.optionalAttributeValue);
                }else{
                 isVapArrey.push(ele.optionalAttributeValue);  
                }
              });
               console.log('IsvapList', JSON.stringify(isVapArrey));

               if(isVapArrey.includes(NotMandatory)){
                this.isVapsEnabled = true;
                
               }else{
                this.isVapsEnabled = false;
               }

               if(this.insuranceRows.find(item => (item.productName).includes(IsWiper) && (this.accountName).includes(IsMotabilityAccount))){
                console.log('wi[erinsu');
                this.isWiperEnabled = true;
                console.log('erinsu'+this.isWiperEnabled );
            }else{
                    this.isWiperEnabled = false;
                    console.log('wi[erinsu24534');
            }
             
               if(this.hasPermissionCer || this.profileName == 'System Administrator'){
             if(isVapArrey.includes(NotMandatory)){
                this.isInsuranceDisount = false;
                //this.isVapsEnabled = true;
             }else{
                this.discount = 0;
                let discountField = this.template.querySelector('.inputamount');
                discountField.value = '';
                discountField.setCustomValidity('');
                discountField.reportValidity();
              //  this.isVapsEnabled = false;
                this.isInsuranceDisount = true;

             }//'NOT Mandatory'
            }
            if(this.hasPermissionCer || this.profileName == 'System Administrator'){
              if(isVapArrey.length == 0){
                this.isInsuranceDisount = true;
              } 
            }   
            // if(this.insuranceRows.find(item => item.qLIname === 'Weather Guard')){
            //         this.weathersTrue = true
            //     }else{
            //         this.weathersTrue = false
            //     }
             //this.confirmbuttonDisabled();
           //  this.confimButton(event);
    }

    confimButton(event){
        if((this.selectedRows.length != 0 || this.insuranceRows.length != 0)  ){
            this.buttonBooleanConfirm = false;
        }else{
            this.buttonBooleanConfirm = true;
        }
    }

    /* confirmbuttonDisabled(){
            if(this.confirmButton != false){
            if(this.recordId == 'Insurance / Account'){
                if(this.insuranceRows.length != 0 && this.location != undefined &&  (this.earlyAppoitment != undefined || this.weatherAppoitment != undefined) && 
                (this.earlyAppoitmentSlot != undefined || this.weatherAppoitmentSlot != undefined)){
                    this.buttonBooleanConfirm = false;
              }else{
                  this.buttonBooleanConfirm = true;
              } 
            }else{
            if(this.selectedRows.length != 0 && this.location != undefined &&  (this.earlyAppoitment != undefined || this.weatherAppoitment != undefined) && 
            (this.earlyAppoitmentSlot != undefined || this.weatherAppoitmentSlot != undefined)){
                this.buttonBooleanConfirm = false;
          }else{
              this.buttonBooleanConfirm = true;
          }
        }
        }
    }*/

    handleScreenValue(event){
        console.log('eventScreenBack', JSON.stringify(event.detail));
            this.backValueArray = [];
            this.confirmButton = event.detail.confirmButtonBoolean;
            let productCopy= [...this.productDataList];
            this.confirmquote = event.detail.detailQuote;
            this.confirmproduct = event.detail.detailProduct;
            if(this.recordId != 'Insurance / Account'){
                this.backQuoteArrey =  event.detail.productvalue;
            }else{
                this.backQuoteArrey =  event.detail.insuranceValue; 
            }
            this.slotDataFromChildTwo =  event.detail.slotfromchildtwo;
            this.trueBoolean =  event.detail.slotsOpen;
            this.earlyAppoitmentMainDate = event.detail.earlyMainDate;
            this.weatherAppoitmentMainDate = event.detail.weatherMaindate;
            this.mainDateQuoteList = event.detail.mainDateList;
            this.childArrayMap = event.detail.childarraymap;
            this.slotstfromparent = event.detail.slotstfromchtwo;
            this.slotedfromparent = event.detail.slotedfromchtwo;
            this.saIdfromParent = event.detail.slotsaid;
            let newArray = [];
            this.location = event.detail.location;
           
            this.discount = event.detail.discount;

            window.setTimeout(()=>{
                this.template.querySelector('.inputamount').value = event.detail.discount;
            },500)
           
            if( event.detail.earlyMainDate != '' && event.detail.earlyMainDate != undefined){
                newArray.push({
                    "earlyAppoitmentMainDate" : event.detail.earlyMainDate,
                    //"weatherAppoitmentMainDate" : event.detail.weatherMaindate,
                "vat" : event.detail.vat,
                "discount" : event.detail.discount,
                "total" : event.detail.total,
                "earlyAppoitment" : event.detail.earlyAppoitment,
                "earlyAppoitmentSlot" : event.detail.earlyAppoitmentSlot,
                   // "weatherAppoitment" : event.detail.weatherAppoitment,
                   // "weatherAppoitmentSlot" : event.detail.weatherAppoitmentSlot,
                    "slotsOpen" : event.detail.slotsOpen,
                    "dateOpen" : event.detail.dateOpen,
                    "location" : event.detail.location
               });
            }
            if( event.detail.weatherMaindate != '' && event.detail.weatherMaindate != undefined){ 
            newArray.push({
                //"earlyAppoitmentMainDate" : event.detail.earlyMainDate,
                "weatherAppoitmentMainDate" : event.detail.weatherMaindate,
                "vat" : event.detail.vat,
                "discount" : event.detail.discount,
                "total" : event.detail.total,
                //"earlyAppoitment" : event.detail.earlyAppoitment,
                //"earlyAppoitmentSlot" : event.detail.earlyAppoitmentSlot,
                "weatherAppoitment" : event.detail.weatherAppoitment,
                "weatherAppoitmentSlot" : event.detail.weatherAppoitmentSlot,
                "slotsOpen" : event.detail.slotsOpen,
                "dateOpen" : event.detail.dateOpen,
                "location" : event.detail.location
            });
            }
           this.backValueArray = JSON.parse(JSON.stringify(newArray));
         // logic added by priyanka
        if(this.recordId != 'Insurance / Account'){
               
                const newArrayA = this.productDataList.map(item => {
                const matchingElement  = this.backQuoteArrey.find(ele => ele.partOrBundleCode === item.partOrBundleCode);
                if(matchingElement){
                   return {...item, checked: true};
                 
                }
                return {...item, checked: false};
            });
       
            let empty = [];
           // this.product = empty;
            this.productDataList = newArrayA;
            this.backProduct = newArrayA;
           // this.confirmbuttonDisabled();
        }else{
       
        const newArrayB = this.insurance.map(item => {
            const matchingElement  = this.backQuoteArrey.find(ele => ele.partOrBundleCode === item.partOrBundleCode);
                if(matchingElement){
                   return {...item, checked: true};
                 
                }
            return {...item, checked: false};
        });
        let empty = [];
        this.insurance = empty;
        this.insurance = newArrayB;
      //  this.confirmbuttonDisabled();
    }
    }
    
    handleConfirm(event){
        
        this.template.querySelector("c-bln-_-location-date-time-slot").childataSend();

        if(  this.earlyAppoitment == '' || this.earlyAppoitmentSlot == '' ||  this.earlyAppoitmentMainDate == '' || (this.selectedRows.length == 0 && this.insuranceRows.length == 0 )){

            LightningAlert.open({
                message:  'Please Select Location Or EarlyAppoitmentDate Or SlotDate Or Slot',//'Error While Create The Service Appointment',
                theme: 'error', // a red theme intended for error states
                label: 'Error!', // this is the header text
            });
         return;
        }
        this.spinnerSiwtch = true;
       // this.template.querySelector("c-bln-_-location-date-time-slot").slotBooking();

        if( this.location != '' && this.location != undefined && (this.selectedRows.length != 0 || this.insuranceRows.length != 0 || this.backQuoteArrey.length != 0)){ 
             this.confirmquote = true;
            this.confirmproduct = false;
        }
  
        window.setTimeout(() => {
            this.template.querySelector("c-bln-_-quote-presentation-cmp").childDetails(); 
            this.spinnerSiwtch = false;
         
        }, 1000);
          // this.selectedRows = [];
           //this.insuranceRows = [];
    }

    handleReprise(){
            if(this.recordId =='Insurance / Account'){
                if(this.insuranceRows.find(item => item.qLIname === 'Weather Guard')){
                    this.template.querySelector("c-bln-_-location-date-time-slot").showWeatherAppotment();
                }
            }
    }

    // knowledgeLocation(){
    //     let ab= knowledgeArticle.BLN_Display_Location__c
    //     console.log()
    //     const knowladgeArticleObj = {
    //         'screenName' :  response.BLN_Display_Location__c, 
    //         'value': 
    //     }
    // }


    
    /*Discount Band Code start here*/
    hanldeQuoteLocation(event){
    
        this.quoteRangeLocation = event.detail;
        console.log('quoteRangeLocation--->',this.quoteRangeLocation);
      

    }

    handleDiscountChange(event) {
        console.log("inside handleDiscountChange");
            let discountValue = parseFloat(event.target.value);
            
            let maxDiscountThreshold = this.getMaxDiscountThreshold();
        console.log("maxDiscountThreshold: " + maxDiscountThreshold);
        console.log('Discount Value-->', discountValue);
    
        if (discountValue === '' || discountValue === null || isNaN(discountValue)) {
            event.target.setCustomValidity('');
        } else if (!this.quoteRangeLocation) {
            event.target.setCustomValidity(selectLocationError);
        } else if (discountValue < 0) {
            event.target.setCustomValidity(negativeDiscountError);
        } else if (discountValue > maxDiscountThreshold && hasPermissionSet ) {
            event.target.setCustomValidity(discountError);
        } 
        else if (discountValue > maxDiscountThreshold && !hasPermissionSet) {
           event.target.setCustomValidity(errorForTeamManager);
        }
        else {
            event.target.setCustomValidity('');
        }
    
        event.target.reportValidity();
    
        this.discount = discountValue;
        console.log("this.discount value", this.discount);
    }
    
    
        calculateMinMaxMediumValues(discountBandDetails) {
            
            let allThresholdValues = discountBandDetails.reduce((acc, band) => {
                acc.push(band.discountThresholdA, band.discountThresholdB, band.discountThresholdC);
                return acc;
            }, []).filter(value => typeof value === 'number');
            console.log('inside allThresholdValues', allThresholdValues);
            let minimumValue = Math.min(...allThresholdValues);
            let maximumValue = Math.max(...allThresholdValues);
        
            let mediumValue = allThresholdValues.filter(value => value !== minimumValue && value !== maximumValue)[0];
        
            return { minimumValue, maximumValue, mediumValue };
        }
        
			getMaxDiscountThreshold() {
				
				let maxThreshold = 0;
				if (hasPermission && this.discountBandDetails && this.quoteRangeLocation) {
					let filteredDetails = this.discountBandDetails.filter(item => item.locationName === this.quoteRangeLocation);
					if (filteredDetails.length > 0) {
						let { minimumValue, maximumValue, mediumValue } = this.calculateMinMaxMediumValues(filteredDetails);
						maxThreshold = maximumValue;
					}
				} else if ((!hasPermission || hasPermissionSet) && this.discountBandDetails && this.quoteRangeLocation) {
					let filteredDetails = this.discountBandDetails.filter(item => item.locationName === this.quoteRangeLocation);
					if (filteredDetails.length > 0) {
						let { minimumValue, maximumValue, mediumValue } = this.calculateMinMaxMediumValues(filteredDetails);
						maxThreshold = mediumValue;
					}
				}
				console.log("maxThreshold", maxThreshold);
                 return maxThreshold;
        }
       
        calculateQuoteRanges() {
           
            let dynamicQuoteRanges = [];
        
            this.discountBandDetails.forEach(band => {
                let { minimumValue, maximumValue, mediumValue } = this.calculateMinMaxMediumValues([band]);
                dynamicQuoteRanges.push({
                    location: band.locationName,
                    lowOffer: `£0 - £${minimumValue}`,
                    mediumOffer: `£${minimumValue} - £${mediumValue}`,
                    highOffer: `£${mediumValue} - £${maximumValue}`
                });
            });
        
            console.log("dynamicQuoteRanges", dynamicQuoteRanges);
            return dynamicQuoteRanges;
        }
    
}