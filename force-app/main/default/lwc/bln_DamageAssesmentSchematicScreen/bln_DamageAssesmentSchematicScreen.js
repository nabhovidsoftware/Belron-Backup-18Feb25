import { LightningElement, api, track} from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import { FlowAttributeChangeEvent,FlowNavigationNextEvent } from 'lightning/flowSupport';
import getSchematicApi from '@salesforce/apex/BLN_ConnectWithGPS.getSchematicApi';
import LightningAlert from 'lightning/alert';
import { getFocusedTabInfo, closeTab } from 'lightning/platformWorkspaceApi';
import BLN_BackSchematic from '@salesforce/resourceUrl/BLN_BackSchematic';
import BLN_BackLeft from '@salesforce/resourceUrl/BLN_BackLeft';
import BLN_BackRight from '@salesforce/resourceUrl/BLN_BackRight';
import BLN_Front from '@salesforce/resourceUrl/BLN_Front';
import BLN_FrontLeft from '@salesforce/resourceUrl/BLN_FrontLeft';
import BLN_FrontRight from '@salesforce/resourceUrl/BLN_FrontRight';
import BLN_Left from '@salesforce/resourceUrl/BLN_Left';
import BLN_Right from '@salesforce/resourceUrl/BLN_Right';
import BLN_Top from '@salesforce/resourceUrl/BLN_Top';
import BLN_WhiteBG from '@salesforce/resourceUrl/BLN_WhiteBG';
import repairLabel from '@salesforce/label/c.BLN_RepairQuestions';
import areyousure from '@salesforce/label/c.BLN_AreYouSure';
import display from '@salesforce/label/c.BLN_Display';
import holeType from '@salesforce/label/c.BLN_HoleType';
import holeId from '@salesforce/label/c.BLN_HoleId';
import cancel from '@salesforce/label/c.BLN_Cancel';
import confirm from '@salesforce/label/c.BLN_QuoteConfirm';
import errorMsg from '@salesforce/label/c.BLN_ErrorMsg';

import ErrorOccurred from '@salesforce/label/c.BLN_ErrorOccurred';
import errorOccurred from '@salesforce/label/c.BLN_ErrorOccur';
import leftLabel from '@salesforce/label/c.BLN_Left';
import rightLabel from '@salesforce/label/c.BLN_Right';
import backLabel from '@salesforce/label/c.BLN_Back';
import frontLabel from '@salesforce/label/c.BLN_Front';
import ContactPIDTeam from '@salesforce/label/c.BLN_ConPidTeam';
import tarzenCar from "@salesforce/resourceUrl/BLN_VehicleCar";
import {ShowToastEvent} from 'lightning/platformShowToastEvent';


export default class Bln_DamageAssesmentSchematicScreen extends NavigationMixin(LightningElement) {

    label = {
        repairLabel,
        holeType,
        display,
        areyousure,
        holeId,
        cancel,
        confirm,
        ErrorOccurred,
        errorOccurred,
        leftLabel,
        rightLabel,
        backLabel,
        frontLabel,
        errorMsg,
        ContactPIDTeam
    }
    vehicleImage = '';
    @api recordId;
    @api holetype;
    @api vehicleType;
    @api bomId;
    @api transactionId;
    @api vehicleHoleId;
    @api finishFlow;
    @api pidQuestion;
    @api availableActions = [];
    statusSchematic = false;
    openmodalError = false;
    showSchematic = false;

    
    @track glassImageMapping=[];
    @track VehicleHoleId = [];
    dataCheckArrey = [];
    question_transactionId;
    question_statement;
    spinnerShow=true;
    visibleInfoPopup = false;
    selctedVehicalHoleId;
    selectedVehicalHoleType;
    selectedDisplayType;
    modalContent;
    cellKey;
    selectedVehicleHoleId;
    selectedCells;
    repairButtonStatus=true;
    showSpinner=true;
    
    BACK=BLN_BackSchematic;
    BACK_LEFT=BLN_BackLeft;
    BACK_RIGHT=BLN_BackRight;
    FRONT=BLN_Front;
    FRONT_LEFT=BLN_FrontLeft;
    FRONT_RIGHT=BLN_FrontRight;
    LEFT=BLN_Left;
    RIGHT=BLN_Right;
    TOP=BLN_Top;
    WhiteBG = BLN_WhiteBG;
    //11331
    schemtaicErrorMsg = '';

    schematicImgMap = new Map([
        ["BACK",this.BACK],
        ["BACK_LEFT",this.BACK_LEFT],
        ["BACK_RIGHT",this.BACK_RIGHT],
        ["FRONT",this.FRONT],
        ["FRONT_LEFT",this.FRONT_LEFT],
        ["FRONT_RIGHT",this.FRONT_RIGHT],
        ["LEFT",this.LEFT],
        ["RIGHT",this.RIGHT],
        ["TOP",this.TOP],
        ["BACKGROUND",this.WhiteBG],
    ]);

    connectedCallback(){
        this.transactionId = '';
        this.showSpinner=true;
        this.showSchematic = true;
        let parsedResult={};
        getSchematicApi({recordId: this.recordId})
        .then(result =>{
        
            console.log('SchematicData', result);
           // console.log('SchematicData54321', data[0]);
            if(result){
                window.setTimeout( ()=> {
                    this.showSpinner = false;
                    }, 5000);
                   // this.dataCheckArrey = JSON.parse(data.hoverMap);
            }
            
            parsedResult = JSON.parse(result);
           console.log('parsedResult54321',parsedResult);


           let data = parsedResult.hoverMap;
           this.vehicleImage = parsedResult.vehicleImage;
           console.log('errorReuslt12345',parsedResult.errorDetail);
           console.log('tarzenTheCar321',this.vehicleImage);

           if(parsedResult.errorDetail == null){
            console.log('errorReuslt12345',result);
           
            this.statusSchematic = true;
            this.openmodalError = false;
            this.showSchematic = false;
            console.log('statusSchematic---',this.statusSchematic);
          }else{
            this.showSchematic = false;
            this.openmodalError = true;
            window.setTimeout( ()=> {
                this.showSpinner = false;
                   }, 5000);
                   this.schemtaicErrorMsg = parsedResult.errorDetail;
          }


          
            for (let keyVal in data){
                let innerList = [];
                for(let innerKeyVal in data[keyVal]){
                    this.transactionId=data[keyVal][innerKeyVal].transactionId;
                    console.log('transaction id new',this.transactionId);
                    innerList.push({
                        key:innerKeyVal,
                        cellIndex:innerKeyVal+keyVal+data[keyVal][innerKeyVal].vhid,
                        displayTypeImg:this.schematicImgMap.get(data[keyVal][innerKeyVal].displayType),
                        vehicalId:data[keyVal][innerKeyVal].vhid!=0 ? data[keyVal][innerKeyVal].vhid : '',
                        vehicalType:data[keyVal][innerKeyVal].vtype!="BACKGROUND" ? data[keyVal][innerKeyVal].vtype : '' ,
                        displayType:data[keyVal][innerKeyVal].displayType,
                        highlightStatus:"no-highlight",
                    });//overlay-image
                   
                    if(data[keyVal][innerKeyVal].vhid != 0){
                        this.VehicleHoleId.push(data[keyVal][innerKeyVal].vhid);
                    }
                }
                this.glassImageMapping.push({key:keyVal, value:innerList});
            }   
          //  this.receiveBom();
         
        })
        .catch(error => {
            if(error){
                console.log('error in schematic', error)
               // window.location.reload();
            }
    
        })   
       
      
     //window.setTimeout( ()=> {
    // if(this.dataCheckArrey.length != 0){
    //    this.receiveBom();
    //    }
      // }, 5000);
        
      
    }

    // receiveBom(){
      
    //     receiveBomIdFromGPS({recordId:this.recordId, transactionId:this.transactionId, vehicleHoleId:this.VehicleHoleId[0]})
    //     .then(data=>{
    //         if(data){
               
    //             console.log('BomId&Question', JSON.stringify(data));
    //             if(data[0]=='RESULT'){
    //                 this.bomId = data[1];
                
    //                 }
    //             else{
    //             this.question_transactionId = data[1];
    //             this.question_statement = data[2];
    //             this.spinnerShow=false;
                
    //             this.pidQuestion = this.question_statement;
    //             }

    //             this.showSpinner=false;
    //         }
    //     })
    //     .catch(error=>{
           
    //         this.dispatchEvent(new FlowAttributeChangeEvent('finishFlow',true));
    //         this.dispatchEvent(new FlowNavigationNextEvent());
    //         this.dispatchEvent(new ShowToastEvent({
    //             title:'Error',
    //             message:this.label.ErrorOccurred,
    //             variant:'error',
    //             mode:'dismissible',
    //         }));
           
    //     })
    // }

   /* get getBackgroundImage(){
      
        if(this.vehicleImage != ''){
        return `background-repeat:no-repeat;background-size:contain;background-image:url("${this.vehicleImage}")`;
        }
    }*/

    closeModal(){
        this.visibleInfoPopup=false;
        this.cellKey=null;
        this.selctedVehicalHoleId=null;
        this.selectedDisplayType=null;
        this.selctedVehicalHoleId=null;
        this.vehicleHoleId=null;
        this.repairButtonStatus=true;
    }

    hightlghtSet(highlightStatus){
        this.repairButtonStatus = highlightStatus=='yes-highlight' ? false : true;
        this.glassImageMapping.forEach(outerRows => {
            outerRows.value.forEach(innerElements => {
                innerElements.highlightStatus = innerElements.cellIndex==this.cellKey ? highlightStatus : "no-highlight";                
            })           
        })
    }

    modalConfirmAction(){
        this.vehicleHoleId =  this.selctedVehicalHoleId;
        this.hightlghtSet("yes-highlight");
        this.visibleInfoPopup=false;

    }

    showInfoPopup(event){
        let statusFlag = this.cellKey===event.target.dataset.cellkey ? true : false;
        this.cellKey = event.target.dataset.cellkey;
        this.selectedDisplayType = event.target.dataset.displaytype;
        this.selectedVehicalHoleType = event.target.dataset.vehicaltype;
        this.selctedVehicalHoleId = event.target.dataset.vehicalid;
        this.visibleInfoPopup = this.selctedVehicalHoleId!=null && this.selctedVehicalHoleId!=undefined && this.selctedVehicalHoleId!=0 && this.selctedVehicalHoleId!="0" && !statusFlag ? true : false;
        this.modalContent = `${this.label.areyousure} \n ${this.label.holeId} ${this.selctedVehicalHoleId} / ${this.label.holeType} ${this.selectedVehicalHoleType}`; // ${this.label.display} ${this.selectedDisplayType} /
        this.holetype = event.target.dataset.vehicaltype;

            if(statusFlag){
                this.closeModal();
                this.hightlghtSet("no-highlight");
            }
    }

    handleRepair(){
            this.dispatchEvent(new FlowAttributeChangeEvent('transactionId', this.transactionId));
            this.dispatchEvent(new FlowAttributeChangeEvent('vehicleHoleId', this.vehicleHoleId));
            if (this.availableActions.find((action) => action === 'NEXT')) {
                this.dispatchEvent(new FlowNavigationNextEvent());
            }
    }


    handleCancel(){
        this.dispatchEvent(new FlowAttributeChangeEvent("finishFlow",true));
        if(this.availableActions.find(element => element=='NEXT')){
            this.dispatchEvent(new FlowNavigationNextEvent());
        }
    }
    closeErrorModal(){
        this.dispatchEvent(new FlowAttributeChangeEvent("finishFlow",true));
        if(this.availableActions.find(element => element=='NEXT')){
            this.dispatchEvent(new FlowNavigationNextEvent());
        }
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