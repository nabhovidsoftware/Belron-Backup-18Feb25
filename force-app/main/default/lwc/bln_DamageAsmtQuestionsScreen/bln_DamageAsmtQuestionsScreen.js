import { LightningElement,api,wire, track } from 'lwc';
import {FlowAttributeChangeEvent,FlowNavigationFinishEvent,FlowNavigationNextEvent} from 'lightning/flowSupport';
import {NavigationMixin} from 'lightning/navigation';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getAnswerFromGPS from '@salesforce/apex/BLN_ConnectWithGPS.getAnswerFromGPS';
import getProductIdFromGPS from '@salesforce/apex/BLN_ConnectWithGPS.getPidQuestionGPS';
import LightningAlert from 'lightning/alert';
import { getFocusedTabInfo, closeTab } from 'lightning/platformWorkspaceApi';
import NoProductId from '@salesforce/label/c.BLN_NoProductId';
import AddProductId from '@salesforce/label/c.BLN_AddProductId';
import PIdNote from '@salesforce/label/c.BLN_PIDNote';
import ErrorOccurred from '@salesforce/label/c.BLN_ErrorOccurred';
import Questions from '@salesforce/label/c.BLN_Questions';
import errorMsg from '@salesforce/label/c.BLN_ErrorMsg';
import errorOccurred from '@salesforce/label/c.BLN_ErrorOccur';
import bomIderrorMsg from '@salesforce/label/c.BLN_GPSBomIdErrorMsg';
import ContactPIDTeam from '@salesforce/label/c.BLN_ConPidTeam';
export default class Bln_DamageAsmtQuestionsScreen extends NavigationMixin(LightningElement) {
    
    @api transactionId;
    @api recordId;
    @api vehicleHoleId;
    @api finishFlow;
    @api Question;
    @api vehicleHoleType;

    isContinueDisabled=true;
    continueClick = false;
    isPidClicked = false;
    isContClicked = true;
    question_response;
    @track ProductId;
    question_transactionId;
    question_statement;
    radioButtonStatus;
    questionGPS = false;
    questionGPS2 = false;
    spinnerShow=true;
    openmodalError;
    openBomModalError = false;
    errorGpsMsg = '';

    label = {
        NoProductId,
        AddProductId,
        PIdNote,
        ErrorOccurred,
        Questions,
        errorMsg,
        bomIderrorMsg,
        errorOccurred,
        ContactPIDTeam
    } 
    

    get radioOptions(){
        return [
            {label: "Yes" , value:"true"},
            {label: "No", value:"false"},
            {label:"Don't Know/Not Sure", value:'null'}
        ]
    }
    connectedCallback(){
        console.log('transId is ---->',this.transactionId,'   holeId----',this.vehicleHoleId);
        console.log('recordId is ----'+this.recordId);
        console.log('Question is ---->',this.Question);
        this.questionGPS = true;
        if(this.continueClick == false){
        // receiveBomIdFromGPS({recordId:this.recordId, transactionId:this.transactionId, vehicleHoleId:this.vehicleHoleId})
        // .then(data=>{
        //     if(data){
        //         console.log("RESSSSS--->",data[0]);
        //         if(data[0]=='RESULT'){
        //             this.dispatchEvent(new ShowToastEvent({
        //                 title:'Success',
        //                 message:'Damage assessment complete!',
        //                 variant:'success',
        //                 mode:'dismissible',
        //             }));
        //             this.dispatchEvent(new FlowNavigationFinishEvent());
        //         }
        //         else{
                this.question_transactionId = this.transactionId;
                this.question_statement = this.Question;
                this.spinnerShow=false;
                console.log("Q1---->",this.question_statment);
        //         }
        //     }
        // })
        // .catch(error=>{
        //     this.dispatchEvent(new FlowAttributeChangeEvent('finishFlow',true));
        //     this.dispatchEvent(new FlowNavigationNextEvent());
        //     this.dispatchEvent(new ShowToastEvent({
        //         title:'Error',
        //         message:this.label.ErrorOccurred,
        //         variant:'error',
        //         mode:'dismissible',
        //     }));
        //     console.log(error);
        // })
    }
    }

    renderedCallback(){
        this.radioButtonStatus=undefined;
    }

        
        // @wire(receiveBomIdFromGPS, {recordId:'$recordId', transactionId:'$transactionId', vehicleHoleId:'$vehicleHoleId' })
        // GetQuestions_RetValue({error,data}){
        //     if(data){
        //         console.log("RESSSSS--->",data[0]);
        //         if(data[0]=='RESULT'){
        //             this.dispatchEvent(new ShowToastEvent({
        //                 title:'Success',
        //                 message:'Damage assessment complete!',
        //                 variant:'success',
        //                 mode:'dismissible',
        //             }));
        //             this.dispatchEvent(new FlowNavigationFinishEvent());
        //         }
        //         else{
        //         this.question_transactionId = data[1];
        //         this.question_statement = data[2];
        //         this.spinnerShow=false;
        //         console.log("Q1---->",this.question_statment);
        //         }
        //     }
        //     else if(error){
        //         this.dispatchEvent(new FlowAttributeChangeEvent('finishFlow',true));
        //         this.dispatchEvent(new FlowNavigationNextEvent());
        //         this.dispatchEvent(new ShowToastEvent({
        //             title:'Error',
        //             message:this.label.ErrorOccurred,
        //             variant:'error',
        //             mode:'dismissible',
        //         }));
    
        //         console.log(error);
        //     }
        // }

    storeResponse(event){
        this.question_response = event.detail.value;
        this.isContinueDisabled=false;
        console.log("TRN ID-->",this.question_transactionId);
        console.log("Q--->",this.question_response);
        console.log("UP Radio-->",this.radioButtonStatus);
    }

    handleProductId(event){
        this.ProductId = event.target.value;
        if(this.ProductId != "" || this.productId != undefined){
            this.isPidClicked = true;
            this.isContClicked = false;
        }else{
            this.isPidClicked = false;
            this.isContClicked = true;
        }
    }

    continueAction(){
        console.log("-----------CONTINUE---------");
        this.isContinueDisabled=true;
        this.radioButtonStatus="";
        this.spinnerShow = true;
        this.answersApiCallback(this.question_response,this.question_transactionId, this.recordId);
    }

    cancelAction(){
        console.log("---------------Cancel------------");
        this.dispatchEvent(new FlowAttributeChangeEvent('finishFlow',true));
        this.dispatchEvent(new FlowNavigationNextEvent());
    }

    answersApiCallback(answer,transactionId,recordId){
        console.log("Ans-->",answer);
        console.log("TRN-->",transactionId);
      if(answer != undefined && transactionId != undefined && recordId != undefined){
        getAnswerFromGPS({ans:answer, transId: transactionId, recordId: recordId , glassHoleType : this.vehicleHoleType})
        .then(data =>{
            console.log("RESSSSS--->",data[0]);
            if(data[0]=='RESULT'){
                this.dispatchEvent(new FlowNavigationNextEvent());
            }
            else{
            this.question_transactionId = data[1];
            this.question_statement = data[2];
            this.spinnerShow=false;
            this.errorGpsMsg = data[0];
            }
        })
        .catch(error=>{
            // this.dispatchEvent(new FlowAttributeChangeEvent('finishFlow',true));
            // this.dispatchEvent(new FlowNavigationNextEvent());
            // this.dispatchEvent(new ShowToastEvent({
            //     title:'Error',
            //     message:this.label.ErrorOccurred,
            //     variant:'error',
            //     mode:'dismissible',
            // }));
            //this.openmodalError = 'true';
            this.showErrorAlert(this.label.errorMsg, 'error', this.label.errorOccurred);
            this.questionGPS = false;
            this.questionGPS2 = false;
            this.spinnerShow=false;
            console.log("Some error--->",error);
        })
    } else{
        this.openBomModalError = true;
    }
    }
    handlePIDQ(){
        this.questionGPS = false;
        this.questionGPS2 = true;
        console.log('transId is ---->',this.transactionId,'   holeId----',this.vehicleHoleId);
        console.log('recordId is ----'+this.recordId);
    }
    handleContinue(){
        this.continueClick = true;
        this.question_statement = '';
        this.questionGPS = false;
        console.log('product id---'+this.ProductId);
        console.log('transId is ---->',this.transactionId,'   holeId----',this.vehicleHoleId);
        console.log('recordId is ----'+this.recordId);
        if(this.ProductId != undefined && this.transactionId != undefined && this.recordId != undefined){
        getProductIdFromGPS({transactionId : this.transactionId, productId : this.ProductId, recordId : this.recordId, glassHoleType : this.vehicleHoleType})
        .then(data=>{
            if(data){
                console.log("RESSSSS4321--->",JSON.stringify(data));
                this.questionGPS2 = true;
                console.log("RESSSSS--->",data[0]);
                if(data[0]=='RESULT'){
                    this.dispatchEvent(new ShowToastEvent({
                        title:'Success',
                        message:'Damage assessment complete!',
                        variant:'success',
                        mode:'dismissible',
                    }));
                    this.dispatchEvent(new FlowAttributeChangeEvent('finishFlow',true));
                    this.dispatchEvent(new FlowNavigationNextEvent());
                }
                else{
                this.question_transactionId = data[1];
                this.question_statement = data[2];
                this.spinnerShow=false;
                console.log("Q1---->",this.question_statement);
                if(this.question_statement == undefined || this.question_statement == '' ){
                    this.questionGPS = false;
                    this.questionGPS2 = false;
                    this.openBomModalError = true;
                    this.errorGpsMsg = data[0];
                    
                  //  this.dispatchEvent(new FlowAttributeChangeEvent('finishFlow',true));
                  //  this.dispatchEvent(new FlowNavigationNextEvent());
             /*   this.dispatchEvent(new ShowToastEvent({
                title:'Error',
                message:this.label.ErrorOccurred,
                variant:'error',
                mode:'dismissible',
            }));*/
            console.log('error');
                }
                }
            }else{
                this.openBomModalError = true;
            }
        })
        .catch(error=>{
            // this.dispatchEvent(new FlowAttributeChangeEvent('finishFlow',true));
            // this.dispatchEvent(new FlowNavigationNextEvent());
            // this.dispatchEvent(new ShowToastEvent({
            //     title:'Error',
            //     message:this.label.ErrorOccurred,
            //     variant:'error',
            //     mode:'dismissible',
            // }));
            console.log(error);
            //this.openmodalError = 'true';
        })
     } else{
        this.openBomModalError = true;
     }

    }
    handleCancel(){
        this.dispatchEvent(new FlowAttributeChangeEvent('finishFlow',true));
        this.dispatchEvent(new FlowNavigationNextEvent());
    }
closeErrorModal(){
    this.openBomModalError = false;
    this.dispatchEvent(new FlowAttributeChangeEvent('finishFlow',true));
    this.dispatchEvent(new FlowNavigationNextEvent());
}
async showErrorAlert(msg, theme, heading) {
        if (this.showSpinner) {
            await LightningAlert.open({
                message: msg,
                theme: theme,
                label: heading
            });

            this.closeFlow();
        }
    }

async closeFlow() {
        getFocusedTabInfo().then(tabinfo => closeTab(tabinfo.tabId));
    }
}