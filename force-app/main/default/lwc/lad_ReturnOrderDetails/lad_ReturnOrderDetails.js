/** @description :  This component displays Return Order Item details on portal page.
*   @Story :        
*   @author:        (manoj.varma.ummadisingu@pwc.com (IN))
*   @CreatedDate:   20-09-2024
*/
import { LightningElement, api,wire} from 'lwc';
import getItemsByReturnOrder from '@salesforce/apex/LAD_ReturnOrderHandler.getItemsByReturnOrder';
import returnDetail from '@salesforce/apex/LAD_ReturnOrderHandler.returnDetail';
import Toast from 'lightning/toast';

export default class Lad_ReturnOrderDetails extends LightningElement {
    @api recordId;

    returnItems;
    return;

    columns = [
        { label: 'Item Name', fieldName: 'returnItemName', type: 'text' },
        { label: 'Sales Code', fieldName: 'salescode', type: 'text' },
        { label: 'Product Name', fieldName: 'productName', type: 'text' },
        { label: 'Quantity Ordered', fieldName: 'quantityordered',type: 'number' },
        { label: 'Quantity Returned', fieldName: 'quantityreturned',type: 'number' }
    ];

    @wire(returnDetail, { recordId: '$recordId' })
    wiredReturn({ data, error }) {
        if (data) {
            console.log('data from return>>>>'+JSON.stringify(data));
            this.return = data;
           // this.returnItems = data.map(item => ({
              //  ...item,
               // ProductName: item.Product__r.Name
           // }));
        } else if (error) {
            console.log('in return error>>', error);
            Toast.show({
                label: 'Error',

                message: 'Error in displaying Return Order',
                mode: 'dismissable',
                variant: 'error'
            }, this);
        }
    }

    @wire(getItemsByReturnOrder, { returnOrderId: '$recordId' })
    wiredReturnItems({ data, error }) {
        if (data) {
            console.log('DATA>>>>'+JSON.stringify(data));
            this.returnItems = data;
           // this.returnItems = data.map(item => ({
              //  ...item,
               // ProductName: item.Product__r.Name
           // }));
        } else if (error) {
            Toast.show({
                label: 'Error',

                message: 'Error in displaying Return Items by Return Order',
                mode: 'dismissable',
                variant: 'error'
            }, this);
        }
    }

    get returnName() {
        return this.return ? this.return.Name : '';
    }

    get accountName() {
        return this.return ? this.return.accountName : '';
    }

    get status() {
        return this.return ? this.return.status : '';
    }

    get createdBy() {
        return this.return ? this.return.createdBy : '';
    }

    get currency() {
        return this.return ? this.return.currency : '';
    }

    get owner() {
        return this.return ? this.return.owner : '';
    }

    get orderSummary() {
        return this.return ? this.return.orderSummary : '';
    }
}