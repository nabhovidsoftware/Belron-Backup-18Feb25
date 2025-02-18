/** @description :  This component is a custom Submit Order button to be placed to Checkout page to handle Order and
 *                  Order Summary creation.
*   @Story :        
*   @author:        (binayak.debnath@pwc.com (IN))
*   @CreatedDate:   22-05-2024
*/
import { api, LightningElement, wire, track } from 'lwc';
import Id from '@salesforce/user/Id';
import { registerListener, unregisterAllListeners } from 'c/lad_pubsub';
import { CurrentPageReference } from 'lightning/navigation';
import processOrderAndOrderSummaries from '@salesforce/apex/LAD_SubmitOrderHandler.processOrderAndOrderSummaries';
import checkAccountViability from '@salesforce/apex/LAD_SubmitOrderHandler.checkAccountViability';
import processAmendOrder from '@salesforce/apex/LAD_AmendOrderHandler.processAmendOrder';
import orderAmendmentViability from '@salesforce/apex/LAD_AmendOrderHandler.orderAmendmentViability';
import Toast from 'lightning/toast';
import basePath from '@salesforce/community/basePath';
import OrderConfirmTag from '@salesforce/label/c.LAD_SubmitOrderButton_OrderConfirmTag';
import AccountOnHoldBody from '@salesforce/label/c.LAD_AccountOnHold_Body';
import AccountOnHoldTitle from '@salesforce/label/c.LAD_AccountOnHold_Title';
import CreditLimitBody from '@salesforce/label/c.LAD_CreditLimit_Body';
import CreditLimitTitle from '@salesforce/label/c.LAD_CreditLimit_Title';
import { effectiveAccount } from 'commerce/effectiveAccountApi';
import { NavigationMixin } from 'lightning/navigation';



export default class Lad_submitOrderButton extends NavigationMixin(LightningElement) {

    isLoading = false;
    checkoutComplete = false;
    isAccountValid = true;
    cartId;
    comment;
    invoiceURL;
    @track submitMode = true;
    @track amendMode = false;
    @track specialOrderMode = false;

    @api submitOrderButtonText;
    @api amendOrderButtonText;
    @api specialOrderbuttonText;
    specialOrderButtonTextinfo='Submit Special Order';
    //Amend Mode
    existingOrderId;

    get amendModeandNotSpecialOrder(){
        return this.amendMode && !this.specialOrderMode;
    }

    @wire(CurrentPageReference) pageRef;

    connectedCallback() {
        registerListener('checkoutComplete', this.setCheckoutCompletion, this);
        registerListener('amendOrder', this.setAmendMode, this);
        registerListener('specialOrder', this.setSpecialOrderMode, this);

        const invoicePage = {
            type: 'comm__namedPage',
            attributes: {
                name: 'Invoice__c',
            },
        };
        this[NavigationMixin.GenerateUrl](invoicePage)
            .then(url => {
                console.log('Generated URL:', url);
                this.invoiceURL = url;
                // Redirect to the generated URL
                //window.open(url, "_self");
                this.checkAccountViability(Id);

            })
            .catch(error => {
                console.error('Error generating URL:', error);
            });

    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }
    setSpecialOrderMode(){
        console.log('SPECIALORDERMODE>>'+this.specialOrderMode,'AMENDMODE>>>'+this.amendMode);
        this.specialOrderMode=true;
        this.submitMode=false;
        if(this.amendMode == true && this.specialOrderMode==true){
            this.specialOrderButtonTextinfo='Add to existing Special Order';
        }
    }

    setAmendMode(orderId) {
        console.log(this.amendOrderButtonText, this.submitOrderButtonText);
        this.amendMode = true;
        this.submitMode = false;
        this.existingOrderId = orderId;
    }

    setCheckoutCompletion(response) {
        if (response.cartId !== null) {
            this.checkoutComplete = true;
            this.cartId = response.cartId;
            this.comment = response.comment;
            console.log('COMMENT', this.comment);
        }
        else {
            this.checkoutComplete = false;
        }
        //Check for Account Validity
        this.checkAccountViability(Id);
    }


    async checkAccountViability(userId) {
        return checkAccountViability({ userId: userId ,accountId: effectiveAccount.accountId})
            .then(result => {
                if (result.status === 'Success') {
                    if (result.onHold === true) {
                        Toast.show({
                            label: AccountOnHoldTitle,
                            message: AccountOnHoldBody,
                            messageLinks: {
                                invoiceURL: {
                                    url: this.invoiceURL,
                                    label: 'here'
                                },
                            },
                            mode: 'sticky',
                            variant: 'error'
                        }, this);
                        this.isAccountValid = false;
                    }

                    if (result.limitExceeded === true) {
                        Toast.show({
                            label: CreditLimitTitle,
                            message: CreditLimitBody,
                            messageLinks: {
                                invoiceURL: {
                                    url: this.invoiceURL,
                                    label: 'here'
                                },
                            },
                            mode: 'sticky',
                            variant: 'error'
                        }, this);
                        this.isAccountValid = false;
                    }

                    if (result.limitExceeded === false && result.onHold === false) {
                        this.isAccountValid = true;
                    }
                    return this.isAccountValid;
                }
                else {
                    Toast.show({
                        label: result.status,
                        message: result.message,
                        mode: 'sticky',
                        variant: 'error'
                    }, this);
                    this.isAccountValid = false;
                    return this.isAccountValid;
                }
            })
            .catch(error => {
                Toast.show({
                    label: 'Error',
                    message: error.body.message,
                    mode: 'sticky',
                    variant: 'error'
                }, this);
                this.isAccountValid = false;
                return this.isAccountValid;
            })
    }


    //Handles Place Order Functionality
    handleOrder() {
        console.log('IN SUBMIT ORDER');
        //Check for Account Validity
        this.checkAccountViability(Id)
            .then(result => {
                if (result) {
                    //ApexCallOut for Order Creation
                    this.isLoading = true;
                    if ((this.submitMode || this.specialOrderMode) && !this.amendMode) {
                        this.handleSubmit();
                    }
                    else if (!(this.submitMode ) && this.amendMode) {
                        this.handleAmend();
                    }
                }
            })
            .catch(error => {
                Toast.show({
                    label: 'Error',
                    message: error.body.message,
                    mode: 'sticky',
                    variant: 'error'
                }, this);
            })

    }


    handleSubmit() {
        processOrderAndOrderSummaries({ cartId: this.cartId, comment: this.comment })
            .then(result => {
                this.isLoading = false;
                if (result.status === 'Success') {
                    Toast.show({
                        label: 'Success',
                        message: result.message,
                        mode: 'sticky',
                        variant: 'success'
                    }, this);
                    //Navigate to Order Page
                    this.navigateToOrder(result.orderNumber);
                }
                else {
                    Toast.show({
                        label: 'Error',
                        message: result.message,
                        mode: 'sticky',
                        variant: 'error'
                    }, this);
                }
            })
            .catch(error => {
                this.isLoading = false;
                Toast.show({
                    label: 'Error',
                    message: error.body.message,
                    mode: 'sticky',
                    variant: 'error'
                }, this);
            })
    }



    async handleAmend() {
        const amendViable = await orderAmendmentViability({ orderId: this.existingOrderId });
        if (amendViable) {
            processAmendOrder({ cartId: this.cartId, comment: this.comment })
                .then(result => {
                    this.isLoading = false;
                    if (result.status === 'Success') {
                        Toast.show({
                            label: 'Success',
                            message: result.message,
                            mode: 'sticky',
                            variant: 'success'
                        }, this);
                        //Navigate to Order Page
                        this.navigateToOrder(result.orderNumber);
                    }
                    else {
                        Toast.show({
                            label: 'Error',
                            message: result.message,
                            mode: 'sticky',
                            variant: 'error'
                        }, this);
                    }
                })
                .catch(error => {
                    this.isLoading = false;
                Toast.show({
                    label: 'Error',
                    message: error.body.message,
                    mode: 'sticky',
                    variant: 'error'
                }, this);
            })
        }
        else {
            this.isLoading = false;
            Toast.show({
                label: 'Error',
                message: 'Order cannot be amended since atleast one of the products are Ready to Release',
                mode: 'dismissible',
                variant: 'Error',
            })
        }

    }

    /**
     * Whether the 'Submit Order' button should be disabled.
     * @type {boolean}
     * @readonly
     * @private
     */
    get isSubmitOrderDisabled() {
        return !this.checkoutComplete ||
            !this.isAccountValid;
    }

    /**
     * Naviagte to the order confirmation page
     * @param navigationContext lightning naviagtion context
     * @param orderNumber the order number from Apex
     */
    navigateToOrder(orderNumber) {
        /* this[NavigationMixin.Navigate]({
            type: "comm__namedPage",
            attributes: {
                name: "Order"
            },
            state: {
                orderNumber: orderNumber
            }
        }); */
        let url = basePath + OrderConfirmTag + orderNumber;
        console.log(url);
        location.replace(url);
    }


}