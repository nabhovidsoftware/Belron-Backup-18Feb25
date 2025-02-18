/** @description :  This component displays Quote details and Quote items on portal page.
*   @Story :        FOUK-9920; FOUK-9922; FOUK-9923; FOUK-9925
*   @author:        (binayak.debnath@pwc.com (IN))
*   @CreatedDate:   29-08-2024
*/
import { LightningElement, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getQuoteDetailsAndItems from '@salesforce/apex/LAD_QuoteHandler.getQuoteDetailsAndItems';
import { fireEvent } from 'c/lad_pubsub';
import Toast from 'lightning/toast';


export default class Lad_QuoteDetail extends LightningElement {


    quoteId;
    @track quote;
    @track quoteItems;


    @wire(CurrentPageReference) pageRef;

    connectedCallback() {
        this.quoteId = this.pageRef.attributes.recordId;

        console.log('QUOTE ID ' + this.quoteId);
        if (this.quoteId !== null && this.quoteId !== undefined) {
            this.handleQuoteAndItems(this.quoteId);
        }
        else {
            this.handleQuoteAndItems('a44Fg00003qxDReIAM');

        }
    }

    handleQuoteAndItems(Id) {
        let objDetails = { quoteId: Id };
        console.log('QUOTE PARAMETERS ' + JSON.stringify(objDetails));
        getQuoteDetailsAndItems({ quoteDetails: objDetails })
            .then(result => {
                console.log('QUOTE DETAILS ' + JSON.stringify(result));
                if (result.Error !== null && result.Error !== undefined) {
                    Toast.show({
                        label: 'Error',
                        message: 'Unable to fetch Quote Details. Error: ' + result.Error,
                        mode: 'sticky',
                        variant: 'error'
                    }, this);
                }
                else {
                    this.quoteItems = JSON.parse(JSON.stringify(result.quoteItems));
                    this.quote = JSON.parse(JSON.stringify(result));
                    this.handleReplacementMap();
                }
            })
            .catch(error => {
                console.error('ERROR IN QUOTE ' + error);
            })
    }

    handleReplacementMap() {
        if (this.quote !== null && this.quote !== undefined) {
            let stringProductCodes = '';
            let stringProductNames = '';
            let stringProductQuantities = '';
            let stringProductPrices = '';
            this.quoteItems.forEach(item => {
                stringProductCodes += '\r\n' + item.ProductCode;
                stringProductNames += '\r\n' + item.ProductName;
                stringProductQuantities += '\r\n' + item.Quantity;
                stringProductPrices += '\r\n' + item.Price;
            })
            let map = {
                'AccountName': this.quote.AccountName,
                'ContactName': this.quote.ContactName,
                'QuoteNumber': this.quote.QuoteNumber,
                'Date': this.quote.CreatedDate,
                'ProductCode': stringProductCodes,
                'ProductName': stringProductNames,
                'ProductQuantity': stringProductQuantities,
                'ProductPrice': stringProductPrices,
                'TotalPrice': this.quote.TotalPrice,
            }

            fireEvent(this.pageRef, 'downloadQuote', map);

        }
    }

    get quoteNumber() {
        return this.quote ? this.quote.QuoteNumber : '';
    }

    get accountName() {
        return this.quote ? this.quote.AccountName : '';
    }

    get contactName() {
        return this.quote ? this.quote.ContactName : '';
    }

    get totalPrice() {
        return this.quote ? this.quote.TotalPrice : '';
    }

    get ownerName() {
        return this.quote ? this.quote.OwnerName : '';
    }

    get currencyIsoCode() {
        return this.quote ? this.quote.CurrencyIsoCode : '';
    }

    get createdDate() {
        return this.quote ? this.quote.CreatedDate : '';
    }

    get columns() {
        return [
            { label: 'Product Code', fieldName: 'ProductCode', type: 'text' },
            { label: 'Product Name', fieldName: 'ProductName', type: 'text' },
            { label: 'Quantity', fieldName: 'Quantity', type: 'text' },
            { label: 'Price', fieldName: 'Price', type: 'text' }
        ];
    }
}