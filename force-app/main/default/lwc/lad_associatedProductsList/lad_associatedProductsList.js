/** @description :  This component is used to show associated products of a leading product on the lead product PDP.
*   @Story :        FOUK-7848; FOUK-7866; FOUK-7867; FOUK-7868; FOUK-8518
*   @author:        (binayak.debnath@pwc.com (IN))
*   @CreatedDate:   26-06-2024
*/
import { api, LightningElement, wire, track } from 'lwc';
import userId from '@salesforce/user/Id';
import networkId from "@salesforce/community/Id";
import siteId from "@salesforce/site/Id";
import { NavigationContext, NavigationMixin } from 'lightning/navigation';
import Toast from 'lightning/toast';
import { generateStyleProperties } from 'experience/styling';
import { SessionContextAdapter } from 'commerce/contextApi';
import { CartStatusAdapter, addItemToCart } from 'commerce/cartApi';
import { createProductQuantityUpdateAction, dispatchAction } from 'commerce/actionApi';
import {
    errorAccessInsufficient,
    errorDefault,
    errorLimitExceeded,
    errorLimitIncrement,
    errorLimitMaximum,
    errorLimitMinimum,
    toastTitleError,
    toastTitleSuccess,
} from './lad_labels';
import { mockProductData } from './lad_associatedProductsListMock';
import { registerListener, unregisterAllListeners } from 'c/lad_pubsub';
import { CurrentPageReference } from 'lightning/navigation';
import Buyer from '@salesforce/customPermission/LAD_Laddaw_Buyer_Credit_Info';
import BuyerManager from '@salesforce/customPermission/LAD_Laddaw_Buyer_Manager_Credit_Info';
import InternalPortal from '@salesforce/customPermission/LAD_Laddaw_Internal_Portal';
import NotAvailable from '@salesforce/label/c.LAD_LocationCheckPDP_NotAvailable';
import Available from '@salesforce/label/c.LAD_LocationCheckPDP_Available';

import findAssociatedProductsHandler from '@salesforce/apex/LAD_AssociatedProductsHandler.findAssociatedProductsHandler';
import getProductAvailability from '@salesforce/apex/LAD_ReturnAssociatedLocationDetails.getProductAvailability';
import createMDCPreferenceRecord from '@salesforce/apex/LAD_ReturnAssociatedLocationDetails.createMDCPreferenceRecord';

import { effectiveAccount } from 'commerce/effectiveAccountApi';

const loginPage = {
    type: 'comm__namedPage',
    attributes: {
        name: 'Login',
    },
};

const cartPage = {
    type: 'comm__namedPage',
    attributes: {
        name: 'Current_Cart',
    },
};

const errorMessageToLabelMap = new Map([
    ['INSUFFICIENT_ACCESS', errorAccessInsufficient],
    ['MAX_LIMIT_EXCEEDED', errorLimitMaximum],
    ['LIMIT_EXCEEDED', errorLimitExceeded],
    ['MISSING_RECORD', errorLimitMinimum],
    ['INVALID_BATCH_SIZE', errorLimitIncrement],
]);

/**
 * @param {string} [errorCode] An error code to retrieve an error message for
 * @returns {string} An error message for the given _`errorCode`_ or a default error message in case no specific message exists
 */
function getErrorMessage(errorCode) {
    return errorMessageToLabelMap.get(errorCode) || errorDefault;
}


export default class Lad_associatedProductsList extends NavigationMixin(LightningElement) {

    static renderMode = 'light';

    @wire(NavigationContext)
    navContext;

    @wire(SessionContextAdapter)
    sessionContext;

    @wire(CartStatusAdapter)
    cartStatus;

    leadProductId;

    @track associatedProductsAvailable = true;

    @track locationSelected = false;

    @track mdcCreated = false;

    @track associatedProductsList

    productIdList = [];

    availabilityMatrix;

    currentLocationId;

    bomIdSet;

    bomIdFromAdvanedSearch = false;

    NotAvailableText = NotAvailable;

    @api
    leadProduct;

    @api
    cartButtonText;

    @api
    cartButtonProcessingText;

    @api
    cartButtonColor;

    @api
    cartButtonColorHover;

    @api
    cartButtonColorBackground;

    @api
    cartButtonColorBackgroundHover;

    @api
    cartButtonColorBorder;

    @api
    cartButtonRadiusBorder;


    @api
    minimumValueGuideText;

    @api
    maximumValueGuideText;

    @api
    stepValueGuideText;

    @api
    quantitySelectorLabel;

    @api
    outOfStockText;


    @wire(CurrentPageReference) pageRef;

    connectedCallback() {
        registerListener('locationSelected', this.checkLocation, this);
        registerListener('bomidList', this.handleBomIdListFromAdvancedSearch, this);
        console.log('PAGE REF >> ' + JSON.stringify(this.pageRef), siteId);
        this.leadProductId = this.pageRef.attributes.recordId;
        if (this.isInSitePreview()) {
            console.log('in mock');
            this.locationSelected = true;
            this.associatedProductsList = JSON.parse(JSON.stringify(mockProductData));
        }
        else if (!this.bomIdFromAdvanedSearch) {
            console.log('in find lead product');
            findAssociatedProductsHandler({ leadProductId: this.leadProductId, userId: userId, networkId: networkId })
                .then(result => {
                    console.log('associated product ' + JSON.stringify(result));
                    this.associatedProductsList = JSON.parse(JSON.stringify(result));

                    if (this.associatedProductsList !== null && this.associatedProductsList.length > 0) {
                        this.associatedProductsList.forEach(obj => {
                            obj.isDisabled = true;
                            obj.unitPrice = (parseFloat(obj.unitPrice)).toFixed(2);
                            obj.currencyIsoCode = this.getCurrencySymbol(obj.currencyIsoCode);
                            this.productIdList.push(obj.id);
                        })

                        console.log('PRODUCT ID List', this.productIdList);
                        //All data manipulations on associated products DS
                        this.handleAssociatedProductsList();
                        let productDetails={ userId:userId, productIdList: this.productIdList, location: '', quantity: 0,effectiveAccountId:effectiveAccount.accountId };

                        getProductAvailability({ productDetails:productDetails })
                            .then(result => {
                                this.availabilityMatrix = JSON.parse(JSON.stringify(result));
                                console.log(JSON.stringify(result));

                                this.availabilityMatrix.forEach(prod => {
                                    prod.primarylocations.forEach(obj => {
                                        if (obj.isDisabled === false) {
                                            obj.avlStatus = Available;
                                        }
                                    })
                                })
                            })
                            .catch(error => {
                                console.error('Error in getting Product Availablity:', error);
                            })


                        /* Toast.show({
                            label: 'Success',
                            message: ,
                            mode: 'dismissible',
                            variant: 'success',
                        }, this); */
                    }
                    else {
                        this.associatedProductsAvailable = false;
                    }



                })
                .catch(error => {
                    console.error('Error in finding Associated Products:', error);
                    this.associatedProductsAvailable = false;
                })
        }




    }
    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    checkLocation(response) {
        console.log('IN LOCATION', JSON.stringify(response));
        const { status, locationId } = response;
        this.locationSelected = status;
        this.currentLocationId = locationId;
        this.handleAssociatedProductsList();
        this.handleMDCPreferences();
        //Modify fire event in product page component to throw location id to check in availability
    }

    handleBomIdListFromAdvancedSearch() {
        // this.bomIdFromAdvanedSearch = true;
    }


    /**
     * Gets whether the cart is processing or (still) loading.
     * @type {boolean}
     * @readonly
     * @private
     */
    get isCartProcessing() {
        return Boolean(this.cartStatus?.data?.isProcessing) || Boolean(this.cartStatus?.loading);
    }

    /**
     * Whether the 'Add to Cart' button should be disabled.
     * @type {boolean}
     * @readonly
     * @private
     */
    get isCartButtonDisabled() {
        return (
            this.isCartProcessing ||
            !this.leadProduct ||
            this.leadProduct?.productClass === 'Set' ||
            this.leadProduct?.productClass === 'VariationParent' ||
            this.locationSelected === false ||
            this.mdcCreated === false
        );
    }

    /**
     * Whether the 'Add to Wishlist' button should be disabled.
     * @type {boolean}
     * @readonly
     * @private
     */
    /*  get isWishlistButtonDisabled() {
         return !this.product;
     } */

    /**
     * Gets the total inventory count for the product.
     * @type {?number}
     * @readonly
     * @private
     */
    get availableQuantity() {
        return null;
    }

    get normalizedButtonText() {
        return this.isCartProcessing && this.cartButtonProcessingText
            ? this.cartButtonProcessingText
            : this.cartButtonText;
    }

    /**
     * Sets the custom CSS properties for the "Add To Cart" Button
     * @type {string}
     * @readonly
     * @private
     */
    get cartButtonStyles() {
        return generateStyleProperties({
            '--ref-c-lad_common-button-primary-color': this.cartButtonColor || 'initial',
            '--ref-c-lad_common-button-primary-color-background': this.cartButtonColorBackground || 'initial',
            '--ref-c-lad_common-button-primary-color-background-hover': this.cartButtonColorBackgroundHover || 'initial',
            '--ref-c-lad_common-button-primary-color-border': this.cartButtonColorBorder || 'initial',
            '--ref-c-lad_common-button-primary-color-hover': this.cartButtonColorHover || 'initial',
            '--ref-c-lad_common-button-radius-border': this.cartButtonRadiusBorder
                ? this.cartButtonRadiusBorder + 'px'
                : 'initial',
        });
    }

    get internalUser() {
        return InternalPortal;
    }

    get buyerUser() {
        return Buyer || BuyerManager;
    }


    handleAssociatedProductsList() {
        console.log('IN HANDLE');

        this.associatedProductsList.forEach(obj => {
            console.log('1');
            if ('purchaseQuantityRule' in obj) {
                console.log('2');

                if (obj.purchaseQuantityRule?.minimum) {
                    let text = this.minimumValueGuideText;
                    const value = obj.purchaseQuantityRule.minimum;
                    obj.normalizedMinimumText = text?.replace('{0}', Number(value));
                }
                if (obj.purchaseQuantityRule?.maximum) {
                    let text = this.maximumValueGuideText;
                    const value = obj.purchaseQuantityRule.maximum;
                    obj.normalizedMaximumText = text?.replace('{0}', Number(value));
                }
                if (obj.purchaseQuantityRule?.increment) {
                    let text = this.stepValueGuideText;
                    const value = obj.purchaseQuantityRule.increment;
                    obj.normalizedIncrementText = text?.replace('{0}', Number(value));
                }
            }

            console.log('HANDLER ', this.locationSelected, this.currentLocationId, this.availabilityMatrix);
            if (this.locationSelected) {
                console.log('IN AVAILABILITY STUFF');
                let productAvailability = this.availabilityMatrix.find(item => item.productId == obj.id);
                let primaryLocation = productAvailability.primarylocations.find(item => item.locId == this.currentLocationId);
                let secondaryLocation = productAvailability.secondarylocations.find(item => item.locId == this.currentLocationId);

                if (primaryLocation != null && primaryLocation != undefined) {
                    console.log('IN PRIMARY STUFF', this.associatedProductsList);

                    obj.isPrimary = true;
                    obj.isSecondary = false;
                    obj.isAvailable = !primaryLocation.isDisabled;
                    obj.avlStatus = primaryLocation.avlStatus;
                    obj.deliveryDate = primaryLocation.deliveryDate;
                    obj.isDisabled = primaryLocation.isDisabled;
                }
                else {
                    console.log('IN SECONDARY STUFF', this.associatedProductsList);
                    obj.isPrimary = false;
                    obj.isSecondary = true;
                    obj.deliveryDate = secondaryLocation.deliveryDate;
                    if (!this.internalUser && this.buyerUser && !secondaryLocation.dateIsToday) {
                        obj.isAvailable = false;
                        obj.avlStatus = NotAvailable;
                        obj.isDisabled = true;
                    }
                    else {
                        obj.isAvailable = !secondaryLocation.isDisabled;
                        obj.avlStatus = secondaryLocation.avlStatus;
                        obj.isDisabled = secondaryLocation.isDisabled;
                    }

                }
                console.log('IN OUT STUFF', this.associatedProductsList);

            }
        })

    }

    handleMDCPreferences() {
        let createMDCPreferenceRecordInput={ locationId: this.currentLocationId, productIdList: this.productIdList, userId: userId, deliveryDate: '' ,effectiveAccountId:effectiveAccount.accountId}

        createMDCPreferenceRecord({ createMDCPreferenceRecordInput:createMDCPreferenceRecordInput})
            .then(result => {
                this.mdcCreated = true;
            })
            .catch(error => {
                console.error('Error in creating MDC Preferences:', error);
            })
    }

    handleQuantityChanged({ detail }) {
        const { productId, value } = detail;
        dispatchAction(this, createProductQuantityUpdateAction(productId, Number(value)));
        console.log('Product Id ' + productId, value);

    }

    async handleAddToCart({ detail }) {

        const { productId, quantity } = detail;

        let currentProduct = this.associatedProductsList.find(product => product.id === productId);
        currentProduct.isDisabled = true;

        try {
            const response = await addItemToCart(productId, quantity);
            console.log(JSON.stringify(response));

            if (response) {
                currentProduct.isDisabled = false;
                Toast.show({
                    label: toastTitleSuccess,
                    message: 'This item has been added to your cart',
                    mode: 'dismissible',
                    variant: 'success'
                }, this);
            }
        }
        catch (error) {
            currentProduct.isDisabled = false;
            console.log('Error in Add to Cart', error);
            Toast.show({
                label: toastTitleError,
                message: error,
                variant: 'error',
                mode: 'dismissible',
            });
        }

    }

    handleNavToAssociatedProduct(event) {
        let associatedProductId = event.target.dataset.productId;
        console.log(associatedProductId);
        this.pageRef.attributes.recordId = associatedProductId;
        this[NavigationMixin.GenerateUrl](this.pageRef)
            .then(url => {
                // Output the generated URL to the console
                console.log('Generated URL:', url);

                // Redirect to the generated URL
                window.open(url, "_self");
            })
            .catch(error => {
                console.error('Error generating URL:', error);
            });

    }

    getCurrencySymbol(currencyCode) {
        const formatter = new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: currencyCode,
            minimumFractionDigits: 2,
            maximumFractionDigits: 2,
        });

        const parts = formatter.formatToParts(1);
        const symbol = parts.find(part => part.type === 'currency').value;
        return symbol;
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