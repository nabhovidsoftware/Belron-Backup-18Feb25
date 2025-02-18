/**
 * @description       : Component to show Balance in Portal based on condition
 * @author            : Sourabh Bhattacharjee
 * @last modified on  : 10-24-2024
 * @last modified by  : Sourabh Bhattacharjee
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   08-12-2024   Sourabh Bhattacharjee   Initial Version
**/
import { LightningElement, api, track } from 'lwc';
import getBal from '@salesforce/apex/BLN_ShowOutstandingBalance.getBal';
import BLN_Escalation from '@salesforce/resourceUrl/BLN_EscalationLogo';
import BLN_Right from '@salesforce/resourceUrl/BLN_RightIcon';
import LightningAlert from 'lightning/alert';
import errorMsg from '@salesforce/label/c.BLN_ErrorMsg';

export default class BLN_ShowOutstandingBalance extends LightningElement {

    @api recordId;
    outstandingBalance;
    balance;
    bookingStatus;
    @track showmessage;
    @track outstandingBalanceStatus;
    @track isModalOpen = false;
    @api serviceId;
    @api headUrl;
    @api right;
    hideMessage = false;
    showPaymentScreen = false;
    isDisabled = false;
    msg = 'To be confirmed';
    showSpinner = true;
    borderClass;
    label = { errorMsg };
    // Lifecycle hook that is executed when the component is inserted into the DOM
    connectedCallback() {
        this.headUrl = BLN_Escalation;
        this.right = BLN_Right;
        if (this.recordId) {
            this.fetchBal();
        }
    }

    fetchBal() {
        getBal({ recordId: this.recordId })
            .then((result => {
                this.showSpinner = false;
                console.log('result in get Bal---> ', result);

                if (result === this.msg) {
                    this.showPaymentScreen = false;
                    this.hideMessage = true;
                    this.isDisabled = true;
                    this.borderClass = 'custom-border';

                } else if (result === '0') {
                    this.showPaymentScreen = false;
                    this.hideMessage = false;
                    this.isDisabled = true;
                    this.borderClass = 'custom-border-disabled';

                } else {
                    this.showPaymentScreen = true;
                    this.isDisabled = false;
                    this.borderClass = 'custom-border';

                    var counter = parseInt(result, 10);

            const formatter = new Intl.NumberFormat('en-GB', {
                style: 'currency',
                currency: 'GBP',
                minimumFractionDigits: 2,
                maximumFractionDigits: 2
            });
                    let ob1 = formatter.format(result);
                    console.log('herre3--->', ob1);
                    this.balance = ob1;
                }
            }))
            .catch((error => {
                this.showSpinner = false;
                this.showErrorAlert(this.label.errorMsg, 'error', 'Error Occured');
                console.log('ERR FROM ShowOutstandingBal--->', error.body.message);
            }))
    }

    get isDisabledBlance() {
        return (this.outstandingBalance <= 2.99);
    }

    get payNowButtonClass() {
        return ((this.outstandingBalanceStatus > 2.99)) ? 'active' : 'inactive';
    }

    async showErrorAlert(msg, theme, heading) {
        if (this.showSpinner) {
            await LightningAlert.open({
                message: msg,
                theme: theme,
                label: heading
            });
        }
    }

    // Handler for the Pay Now button click
    handlePayNow() {
        let buttonStatus = this.isDisabled;
        if (buttonStatus == false) {
            const recordId = this.recordId;
            const serviceId = this.serviceId;
            let url = '/SelfServe/s/worldpayportalpage';
            url += '?recordId=' + recordId + '&serviceId=' + serviceId;
            window.location.href = url;
        }
    }
}