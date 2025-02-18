import { LightningElement,api } from 'lwc';
import orderproductDetails from '@salesforce/apex/LAD_returnProductAvailabilityDetails.orderproductDetails';
export default class Lad_productAvailabilitybanner extends LightningElement {

    orderProductList;
    @api recordId;
    connectedCallback(){

        orderproductDetails({orderSummaryId:this.recordId}).then(data => {
            
            this.parseData(data);

            console.log(this.orderProductList);
        }).catch(error => {
            console.log(error);
        })
    }
    parseData(data){
        this.orderProductList=data.map(i=>{
            if(i.LAD_Product_Availability_Date__c==null){
                i.isNotAvailable=true;
                i.message='Your confirmed product availability date will be updated shortly.'
                
            }else if(i.LAD_Product_Availability_Date__c > i.LAD_Date_Selected_By_Customer__c){
                i.isDelayed=true;

                i.message='Please be aware that your product availability date has changed. If you require support please contact us.'

            }
            i.productName=i.Product2.Name; 
            return i;
        })
        console.log('this.orderProductList',this.orderProductList);
    }
}