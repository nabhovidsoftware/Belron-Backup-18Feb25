/** @description :  This component is used to request a quote based on cart items selected.
*   @Story :        FOUK-9920; FOUK-9922; FOUK-9923; FOUK-9925
*   @author:        (ashwin.r.raja@pwc.com (IN))
*   @CreatedDate:   28-08-2024
*/

import { LightningElement, api, track } from 'lwc';
import getCartId from '@salesforce/apex/LAD_checkoutPageController.getCartId';
import getCartItems from '@salesforce/apex/LAD_checkoutPageController.getCartItems';
import getAccId from '@salesforce/apex/LAD_ReturnAssociatedLocationDetails.getAccId';
import createQuoteAndQuoteItems from '@salesforce/apex/LAD_QuoteHandler.createQuoteAndQuoteItems';
import { effectiveAccount } from 'commerce/effectiveAccountApi';
import { mockCartItemData } from './lad_generateQuote_Mock';
import { NavigationMixin } from 'lightning/navigation';
import Id from '@salesforce/user/Id';
import Toast from 'lightning/toast';



export default class Lad_generateQuote extends NavigationMixin(LightningElement) {
    @track isLoading = false;
    @api accountId;
    @api cartId;
    @track showModal = false;
    @track disableGenerateQuote = true;
    @track selectedRecords;
    cartItems = [];
    columns = [
        { label: 'Product Code', fieldName: 'ProductCode', type: 'text' },
        { label: 'Product Name', fieldName: 'CartItemName', type: 'text' },
        { label: 'Quantity', fieldName: 'Quantity', type: 'text' },
        { label: 'Price', fieldName: 'ListPrice', type: 'Number' },
        //{ label: 'Quantity', fieldName: 'Quantity', type: 'Number' }
    ];

    connectedCallback() {
        getAccId({ userid: Id })
            .then(result => {
                this.accountId = result;
                console.log("account id=" + result);
                //this.fetchCartId();
            })
            .catch(error => {
                console.log(error);
            })
    }

    fetchCartId() {
        let variable = effectiveAccount.accountId !== null && effectiveAccount.accountId !== undefined ? effectiveAccount.accountId : this.accountId;
        getCartId({ userId: Id, accountId: variable })
            .then(result => {
                this.cartId = result.cartId;
                console.log('cartId>>' + this.cartId);
                if (this.cartId !== null && this.cartId !== undefined) {
                    this.fetchCartItems();
                }
                else {
                    this.isLoading = false;
                    console.log('No cart available');
                }
            }
            ).catch(error => {
                this.isLoading = false;
                console.log(error);
            })
    }

    fetchCartItems() {
        getCartItems({ cartId: this.cartId })
            .then(result => {
                this.isLoading = false
                this.cartItems = JSON.parse(JSON.stringify(result));
                console.log('cart item>>' + JSON.stringify(result));
                this.handlePrice();
            }).catch(error => {
                this.isLoading = false;
                console.log(error);
            })
    }

    handlePrice() {
        try {
            this.cartItems.forEach(item => {
                let totalPrice = item.ListPrice * item.Quantity;
                console.log('TOTAL PRICE ' + totalPrice);
                item.ListPrice = totalPrice;
            })
        }
        catch (error) {
            this.isLoading = false;
            console.error(error);
        }

    }

    openModal() {
        this.isLoading = true;
        console.log('here');
        if (this.isInSitePreview()) {
            console.log('in mock', mockCartItemData);
            this.cartItems = JSON.parse(JSON.stringify(mockCartItemData));
            this.handlePrice();
            this.isLoading = false;

        }
        else {
            this.fetchCartId();
        }
        this.showModal = true;
    }

    hideModal() {
        this.showModal = false;
        this.cartItems = [];
        this.cartId = null;
        this.selectedRecords = [];
        this.disableGenerateQuote = true;
    }

    handleRowSelection(event) {
        this.selectedRecords = event.detail.selectedRows;
        console.log(JSON.stringify(this.selectedRecords));
        this.disableGenerateQuote = !(this.selectedRecords.length > 0);
    }


    generateQuote() {
        this.isLoading = true;
        //let selectedRecords = this.template.querySelector("lightning-datatable")?.getSelectedRows();
        if (this.selectedRecords.length > 0) {
            console.log('selectedRecords are>>>', JSON.stringify(this.selectedRecords));



            let variable = effectiveAccount.accountId !== null && effectiveAccount.accountId !== undefined ? effectiveAccount.accountId : this.accountId;
            let quoteItemsData = [];
            this.selectedRecords.forEach(item => {
                let obj = {
                    ProductId: item.ProductId,
                    Price: item.ListPrice,
                    Quantity: item.Quantity,
                };

                quoteItemsData.push(obj);
            });

            let quoteData = {
                effectiveAccountId: variable,
                userId: Id,
                quoteItems: quoteItemsData,
            }
            console.log(JSON.stringify(quoteData), variable, Id);
            createQuoteAndQuoteItems({ quoteDetails: quoteData })
                .then(result => {
                    let returnMap = {};
                    returnMap = result;
                    if (returnMap.hasOwnProperty('Error')) {
                        //Handle error
                        console.log(returnMap['Error']);
                    }
                    else {
                        //Handle Success
                        console.log('success', returnMap['Success']);
                        Toast.show({
                            label: 'Success',
                            message: 'Quote generated successfully',
                            mode: 'dismissible',
                            variant: 'success'
                        }, this);

                        this.hideModal();

                        this.navigateToQuoteDetail(returnMap['Success']);
                    }
                    this.isLoading = false;

                })
                .catch(error => {
                    this.isLoading = false;
                    console.error(error);
                })
        }
        else {
            this.isLoading = false;
            console.log('no records selected');
            Toast.show({
                label: 'Error',
                message: 'No Rows Selected',
                mode: 'sticky',
                variant: 'error'
            }, this);
        }
    }

    navigateToQuoteDetail(quoteId) {
        const pageReference = {
            type: 'standard__recordPage',
            attributes: {
                recordId: quoteId,
                objectApiName: 'LAD_Quote__c',
                actionName: 'view'
            }
        };
        this[NavigationMixin.GenerateUrl](pageReference)
            .then(url => {
                console.log('Generated URL:', url);

                // Redirect to the generated URL
                window.open(url, "_self");
            })
            .catch(error => {
                console.error('Error generating URL:', error);
            });
    }

    /**
    * helper class that checks if we are in site preview mode
    */
    isInSitePreview() {
        let url = document.URL;

        return (url.indexOf('sitepreview') > 0
            || url.indexOf('livepreview') > 0
            || url.indexOf('live-preview') > 0
            || url.indexOf('live.') > 0
            || url.indexOf('.builder.') > 0);
    }
}