import { LightningElement, wire } from 'lwc';
import stockCheckInList from '@salesforce/apex/BLN_StockCheckInList.returnData';
import callCreatePT from '@salesforce/apex/BLN_StockCheckInList.createPT';

export default class Bln_StockCheckInList extends LightningElement {

    stockCheckInListData;

    // @wire(stockCheckInList)
    // stockCheckInListData({ error, data }) {
    //     if (data) {
    //         this.stockCheckInListData = JSON.parse(data);
    //         console.log('data is : ' + JSON.stringify(this.stockCheckInListData));
    //     } else if (error) {
    //         console.log('error is : ' + JSON.stringify(error))
    //             ;
    //     }
    // }

    getStockData() {
        stockCheckInList()
            .then((data) => {
                this.stockCheckInListData = JSON.parse(data);
                console.log('1 Data received from apex is : ' + JSON.stringify(this.stockCheckInListData));
            })
            .catch((error) => {
                console.log('1 Data result error : ' + JSON.stringify(error));
            })
    }

    confirmEventHandler(event) {
        const data = event.detail;

        callCreatePT({ wrapperData: JSON.stringify(data) })
            .then((result) => {
                console.log('Data result : ' + JSON.stringify(result))
                this.template.querySelector('c-bln_-stock-check-in-inventory').confirmedSucessfully();
            })
            .catch((error) => {
                this.error = error;
                console.log('Data result error : ' + JSON.stringify(error));
                this.template.querySelector('c-bln_-stock-check-in-inventory').confirmedFailed();
            });
    }

    continueEventHandler(){
        try{
            this.getStockData();
            this.template.querySelector('c-bln_-stock-check-in-inventory').continueSuccessfully();
        }catch(error){
            console.log('Error fetching data : '+JSON.stringify(error));
            this.template.querySelector('c-bln_-stock-check-in-inventory').continueFailed();
        }
    }

    connectedCallback() {
        console.log('Connected Callback log.');
        this.getStockData();
    }

    renderedCallback() {
        console.log('Rendered Callback log.');
    }

    disconnectedCallback() {
        console.log('Disconnected Callback log.');
    }

    errorCallback() {
        console.log('Error Callback log.');
    }
}