import { LightningElement, track, api,wire } from 'lwc';
//import {FlowAttributeChangeEvent} from 'lightning/flowSupport';
import getOrderProductDetails from '@salesforce/apex/LAD_CancelOrder.getOrderProductDetails';
import createPlatformEvent from '@salesforce/apex/LAD_CancelOrder.createPlatformEvent';
import checkSpecialOrder from '@salesforce/apex/LAD_CancelOrder.checkSpecialOrder';
import Toast from 'lightning/toast';
import { RefreshEvent } from 'lightning/refresh';
import { getPicklistValues ,getObjectInfo} from "lightning/uiObjectInfoApi";
import Reason_Field from "@salesforce/schema/OrderItemSummaryChange.Reason";
import OrderItemSummaryChange from '@salesforce/schema/OrderItemSummaryChange'; 
export default class LAD_cancelItemComponent extends LightningElement {
    @track flowStarted = false;
    @track showModal = false;
    @track inputVariable = [];
    conditionForEditableDelivery=['Awaiting Shipping','Ordered','Backordered'];
    conditionForEditableCollection=['Ready to release','Awaiting Shipping','Ordered','Backordered'];

    @api recordId ;
    @track dataSet;
    showCancelButton=true;
    selectAllVariant='base';
    selectAllName='utility:add';
    @track options;
    @track recordtypeId;

     // GET OBJECT INFO
     @wire (getObjectInfo, {objectApiName: OrderItemSummaryChange})
     objectInfo({
         error,data
     })
     {if(data){
         console.log(data); 
         this.recordtypeId=data.defaultRecordTypeId;
     } else if(error){
         console.log(error);
     }}  

    @wire(getPicklistValues, {recordTypeId: '$recordtypeId',fieldApiName: Reason_Field }) 
    picklistResults({ error, data }) {
        console.log(37);

        console.log(data);
        this.options=undefined;
        if (data) {
            console.log(38,data);
            this.options = data.values;
        }else if(error){
            console.log(45);
            console.log(39,error);
        }
    }  



    


    handleOpenModal(){
        this.showModal= true;
        console.log(this.showModal);
    }

    hideModalBox(){
        this.showModal= false;

    }


    connectedCallback() {
        checkSpecialOrder({orderSummaryId:this.recordId})
        .then(result=>{
            this.showCancelButton=result;
            if(result){
                this.fetchOrderProductDetails();
            }
        }).catch(error=>{
            console.log(error);
        })
    }

    fetchOrderProductDetails(){
        getOrderProductDetails({orderSummaryId:this.recordId})
        .then(result=>{
            console.log(result);
            let countOfCollectionAfterShipped=0;
            let countOfDeliveryAfterDelivery=0;

            this.dataSet=result.map(i=>{

                // if((i.OrderDeliveryGroupSummary.OrderDeliveryMethod.Name=='Laddaw Collection' ||!this.conditionForEditableCollection.includes(i.LAD_Status__c)) &&(i.OrderDeliveryGroupSummary.OrderDeliveryMethod.Name!='Laddaw Delivery' ||!this.conditionForEditableDelivery.includes(i.LAD_Status__c))&& i.LAD_Status__c!='Cancelled'){
                //     this.showCancelButton=true;
                // }

                if(i.OrderDeliveryGroupSummary.OrderDeliveryMethod.Name=='Laddaw Collection' && !this.conditionForEditableCollection.includes(i.LAD_Status__c)){
                    countOfCollectionAfterShipped++;
                }
                if(i.OrderDeliveryGroupSummary.OrderDeliveryMethod.Name=='Laddaw Delivery' && !this.conditionForEditableDelivery.includes(i.LAD_Status__c)){
                    countOfDeliveryAfterDelivery++;
                }

                if(this.conditionForEditableCollection.includes(i.LAD_Status__c) && i.OrderDeliveryGroupSummary.OrderDeliveryMethod.Name=='Laddaw Collection' ){
                    i.isDisabled=false;
                    i.background='background-color: white;';

                }else if(this.conditionForEditableDelivery.includes(i.LAD_Status__c) && i.OrderDeliveryGroupSummary.OrderDeliveryMethod.Name=='Laddaw Delivery' ){
                    i.isDisabled=false;
                    i.background='background-color: white;';
 
                }else if(this.conditionForEditableDelivery.includes(i.LAD_Status__c) && i.OrderDeliveryGroupSummary.OrderDeliveryMethod.Name=='Laddaw Shipping' ){
                    i.isDisabled=false;
                    i.background='background-color: white;';
                }

                else{
                    i.isDisabled=true;
                    i.background='background-color: #e5e5e5;';
                }
                i.buttonVariant='base';
                i.iconName='utility:add';
                return i;
            })
            if(this.dataSet.filter(i=>i.isDisabled==false).length==1){
                this.dataSet.filter(i=>i.isDisabled==false)[0].buttonVariant='brand';
                this.dataSet.filter(i=>i.isDisabled==false)[0].iconName='utility:check';
                this.selectAllName='utility:check';
                this.selectAllVariant='brand';
            }
            console.log(this.dataSet);
            console.log(countOfCollectionAfterShipped,countOfDeliveryAfterDelivery,result.length);
            if(countOfCollectionAfterShipped==result.length ||countOfDeliveryAfterDelivery==result.length){
                this.showCancelButton=false;
            }
        }).catch(error=>{
            console.log(error);
        })
    }

   

    handleCloseModal() {
        this.showModal = false;
        console.log('Modal closed');
    }

    handleSelectIcon(event){
        console.log(event.target.dataset.id);
        this.dataSet= this.dataSet.map(i=>{
            if(i.isDisabled!=true && i.Id==event.target.dataset.id){
                i.buttonVariant=i.buttonVariant=='base'?'brand':'base';
                i.iconName=i.buttonVariant=='brand'?'utility:check':'utility:add';

            }
            return i;
        })

    }
    handleSelectAll(){
        let areAllSelected=this.selectAllVariant=='base'?true:false;
        this.selectAllVariant=areAllSelected==true?'brand':'base';
        this.selectAllName=areAllSelected==true?'utility:check':'utility:add';
        console.log('areAllSelected>>',areAllSelected,this.selectAllVariant,this.selectAllName);

        console.log( this.selectAllVariant);
        this.dataSet= this.dataSet.map(i=>{
            if(i.isDisabled!=true){
                i.buttonVariant=this.selectAllVariant;
                i.iconName=i.buttonVariant=='brand'?'utility:check':'utility:add';

            }
            return i;
        })
        console.log( this.dataSet);

    }
    handleOrderCancel(event){
        console.log(event.target.dataset.id);
        this.handleValidation();

    }

    async handleValidation(){
        console.log(this.dataSet);
        let throwException=false;


        let counter=0;




        await this.dataSet.forEach(i=>{
            if(i.buttonVariant==='brand' && (i.description==null || i.description==undefined || i.description=='' )){
                console.log(i.buttonVariant,i.description);
                throwException=true;
            }
            if(i.buttonVariant==='brand'){
                counter=counter+1;
            }
        })
        console.log('counter',counter);
        
        let errorMessage='';

        if(counter===0){
            errorMessage='Please select atleast one Item for Cancellation'
        }else if(throwException===true){
            errorMessage='Please select the reason for cancellation for all selected Items.'
        }


        if(errorMessage!=''){
            Toast.show({
                label: 'Error',

                message: errorMessage,
                mode: 'dismissible',
                variant: 'error'
            }, this);
        }else{
            this.createDataStructure();
        }
    }

    handleDescription(event){
        let record=event.target.dataset.id;
        this.dataSet= this.dataSet.map(i=>{
            if(i.Id==record){
                i.description=event.detail.value;;
            }
            return i;
        })

    }

    isProcessing=false;
    createDataStructure(){
        this.isProcessing=true;
        console.log(this.dataSet);
        let datastructure=[];
        this.dataSet.forEach(i=>{
            if(i.buttonVariant=='brand'){
                datastructure=[...datastructure,{'orderproductSummaryId':i.Id,'reasonForCancellation':i.description}];
            }
        })

        let body=JSON.stringify(datastructure);
        console.log(body);
        createPlatformEvent({platformEventBody:body})
        .then(result=>{
            console.log(result);
            setTimeout(() => {
                this.isProcessing=false;
                Toast.show({
                    label: 'Success',

                    message: 'Thank you, your cancellation request has now been processed.',
                    mode: 'dismissible',
                    variant: 'success'
                }, this);
                window.location.reload();
            }, 3000);
            

        }).catch(error=>{
            console.log(error);
            this.isProcessing=false;

        })
    }
}