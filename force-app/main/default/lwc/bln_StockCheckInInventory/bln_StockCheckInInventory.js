import { LightningElement, api } from 'lwc';
import BLN_StockCheckInErrorMsg from '@salesforce/label/c.BLN_StockCheckInErrorMsg';
import BLN_ProductQuantityErrorMsg from '@salesforce/label/c.BLN_ProductQuantityErrorMsg';
import BLN_NoStockToCheckInError from '@salesforce/label/c.BLN_NoStockToCheckInError';
import { NavigationMixin } from 'lightning/navigation';

export default class Bln_StockCheckInInventory extends LightningElement {
    isShowModal = true;
    isFirstPage = true;
    isSecondPage = false;
    isThirdPage = false;
    spinner = false;
    selectedRecord = undefined;
    showError = false;
    errorMessage = undefined;
    screenCounter = false;
    label = {
        BLN_StockCheckInErrorMsg,
        BLN_ProductQuantityErrorMsg,
        BLN_NoStockToCheckInError
    };

    get stockData(){
        console.log('stock data lenght : ' + this.stockCheckInListData.length);
        return this.stockCheckInListData.length === 0 ? false : true;
    }

    errorMessages = {
        unSelectedProduct : this.label.BLN_StockCheckInErrorMsg,
        unableToUpdate : this.label.BLN_ProductQuantityErrorMsg,
        unableToFetch : this.label.BLN_NoStockToCheckInError
    }
    @api stockCheckInListData;

    hideModalBox() {
        this.isShowModal = false;
        this.navigateToObjectHome();
    }

    radioChecked(event) {
        console.log('Radio checked is : ' + event.detail.value);
        console.log('Radio data target value : ' + JSON.parse(event.target.value));
        this.selectedRecord = JSON.parse(event.target.value);
        console.log('json selected data is : '+JSON.stringify(this.selectedRecord));
        this.errorMessage = undefined;
        this.showError = false;
    }

    handleButtonClick(event) {
        this.spinner = true;
        console.log('Spinner = ' + this.spinner);
        console.log('Button Name : ' + event.target.name);

        if (event.target.name == 'next') {
            if (this.selectedRecord == undefined) {
                this.errorMessage = this.errorMessages.unSelectedProduct;
                this.showError = true;
                this.spinner = false;
            }
            else if (this.selectedRecord) {
                this.isFirstPage = false;
                this.isSecondPage = true;
                this.spinner = false;
                console.log('Spinner = ' + this.spinner);
                this.spinner = false;
            }

        }
        else if (event.target.name == 'back') {
            this.isFirstPage = true;
            this.isSecondPage = false;
            this.spinner = false;
            this.showError = false;
            this.errorMessage = undefined;
            this.selectedRecord = undefined;
            console.log('Spinner = ' + this.spinner);
            this.screenCounter = false;
        }
        else if (event.target.name == 'confirm') {
            if(!this.screenCounter){
                const eventData = {
                    eventName : 'confirmevent',
                    data : this.selectedRecord
                }
                this.sendEvent(eventData);
            }
        }
        else if (event.target.name == 'continue'){
            const eventData = {
                eventName : 'continueevent',
                data : this
            }
            this.sendEvent(eventData); 
        }
    }

    sendEvent(eventData) {
        // Creates the event with the contact ID data.
        console.log('Data to be Sent 1 : ' + JSON.stringify(eventData.data));
        const selectedEvent = new CustomEvent(eventData.eventName, { detail: eventData.data });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }

    @api confirmedSucessfully() {
        this.isSecondPage = false;
        this.isThirdPage = true;
        this.spinner = false;
        this.showError = false;
    }

    @api confirmedFailed(){
        this.errorMessage = this.errorMessages.unableToUpdate;
        this.showError = true;
        this.spinner = false;
        this.screenCounter = true;
    }

    @api continueSuccessfully(){
        this.isThirdPage = false;
        this.isFirstPage = true;
        this.showError = false;
        this.spinner = false;
    }

    @api continueFailed(){
        this.errorMessage = this.errorMessages.unableToFetch;
        this.showError = true;
        this.spinner = false;
    }

   /* navigateToObjectHome() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'home'
            }
        });
    } */

}