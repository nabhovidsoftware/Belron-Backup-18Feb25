import { LightningElement, track, api, wire } from 'lwc';
import generateSaltAndHash from '@salesforce/apex/BLN_InvokeWorldPayMobileApp.generateSaltAndHash';
import generateEncodedURL from '@salesforce/apex/BLN_InvokeWorldPayMobileApp.generateEncodedURL';
import checkSTRelease from '@salesforce/apex/BLN_InvokeWorldPayMobileApp.checkSTRelease';
import WorldPayMobileBaseURL from '@salesforce/label/c.BLN_WorldPayMobileBaseURL';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';

export default class Bln_InvokeWorldPayMobileApp extends NavigationMixin(LightningElement) {
    @api recordId;
    @api encodedLinkToInovke;
    @track isShowModal = false;
    @track isShowSpinner = true;
    @api usedForR1 = false;
    WOLIId;
    outstandingBalance;
    urlToEncodeString;
    transactionrefrence;
    transactionType = 0;
    outstandingBal;
    returnURL;
    endParameter = 0;
    hashVal;
    timeStamp;
    returnIdentifier = 'com.belron';

    label = {
        WorldPayMobileBaseURL
    }

    currentPageReference;
    @wire(CurrentPageReference)    
    setCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference;
      }
    connectedCallback() {
        this.outstandingBalance = this.currentPageReference.state.outstandingBalance;
        this.WOLIId = this.currentPageReference.state.WOLIId;
        this.returnURL = 'com.salesforce.fieldservice://v1/sObject/'+ this.WOLIId +'/quickaction/BLN_PaymentResponse?woliId='+this.WOLIId+'&returnResp={{data}}'
        this.outstandingBal = this.outstandingBalance;
        generateSaltAndHash()
            .then(result => {
                this.hashVal = result.hashVal;
                this.saltVar = result.saltVal;
                this.timeStamp = result.dateTimeVal;
                this.transactionrefrence = result.transactionRefrence;
                this.urlToEncodeString = '1=' + this.transactionrefrence + '\n'
                                        + '2=' + this.transactionType + '\n'
                                        + '3=' + this.outstandingBal + '\n'
                                        + '70=' + this.returnURL + '\n'
                                        + '71=' + this.returnIdentifier + '\n'
                                        + '74=' + this.saltVar + '\n'
                                        + '75=' + this.hashVal + '\n'
                                        + '76=' + this.timeStamp + '\n'
                                        + '99=' + this.endParameter + '\n';
                this.getEnodedURLFromApex();
                this.isShowSpinner = false;
                this.isShowModal = true;
            })
            .catch(error => {
                console.error(error, 'error thrown while generating salt and hash');
            })

        checkSTRelease({ woliID: this.recordId })
        .then(result => {
        if(result)
        {
            this.usedForR1 = result;
        }
        })
        .catch(error => {
        console.error('Error fetching Territory R1/R2:', error);
        });
    }

    getEnodedURLFromApex() {
        generateEncodedURL({ urlToEncodeString: this.urlToEncodeString })
            .then(result => {
                this.encodedLinkToInovke = this.label.WorldPayMobileBaseURL + '?' + result;
            })
            .catch(error => {
                console.error(error, 'error thrown while encoding url');
            })
        this.isShowSpinner = false;
        this.isShowModal = true;
    }
    hideModalBox() {
        this.isShowModal = false;
    }
    onNextClick() {
        //window.location.href = this.encodedLinkToInovke;
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
            url: this.encodedLinkToInovke
            }
            });
    }
}