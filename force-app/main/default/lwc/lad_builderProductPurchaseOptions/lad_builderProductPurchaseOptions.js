/** @description :  This component is a custom development aimed to replicate the standard 'Add to Cart', 'Quantity Selector' and
 *                  'Add to List' functionality.
*   @Story :        FOUK-9051; FOUK-8454; FOUK-8231; FOUK-8232; FOUK-8230; FOUK-7684; FOUK-8367
*   @author:        (binayak.debnath@pwc.com (IN))
*   @CreatedDate:   22-05-2024
*/
import { api, LightningElement, wire, track } from 'lwc';
import { navigate, NavigationContext } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Toast from 'lightning/toast';

import { generateStyleProperties } from 'experience/styling';
import { SessionContextAdapter } from 'commerce/contextApi';
import { CartStatusAdapter } from 'commerce/cartApi';
import {
    createCartItemAddAction,
    createProductQuantityUpdateAction,
    createWishlistItemAddAction,
    dispatchAction,
} from 'commerce/actionApi';
import Id from '@salesforce/user/Id';
import { effectiveAccount } from 'commerce/effectiveAccountApi';

import checkIfCartExists from '@salesforce/apex/LAD_checkoutPageController.checkIfCartExists';
import updateSpecialOrderflagOnCart from '@salesforce/apex/LAD_checkoutPageController.updateSpecialOrderflagOnCart';
import CommonModal from 'c/lad_commonModal';
import {
    errorAccessInsufficient,
    errorDefault,
    errorLimitExceeded,
    errorLimitIncrement,
    errorLimitMaximum,
    errorLimitMinimum,
    modalCartActionContinue,
    modalCartActionView,
    modalCartTitleSuccess,
    toastTitleError,
    toastTitleSuccess,
    toastWishlistError,
    toastWishlistSuccess,
} from './lad_labels';

import { registerListener, unregisterAllListeners } from 'c/lad_pubsub';
import { CurrentPageReference } from 'lightning/navigation';


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

export default class Lad_builderProductPurchaseOptions extends LightningElement {
    static renderMode = 'light';

    @wire(NavigationContext)
    navContext;

    @wire(SessionContextAdapter)
    sessionContext;

    @wire(CartStatusAdapter)
    cartStatus;

    @api
    product;

    @api
    productInventory;

    @api
    productVariant;

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
    showWishlistButton = false;

    @api
    wishlistButtonText;

    @api
    wishlistButtonColor;

    @api
    wishlistButtonColorHover;

    @api
    wishlistButtonColorBackground;

    @api
    wishlistButtonColorBackgroundHover;

    @api
    wishlistButtonColorBorder;

    @api
    wishlistButtonRadiusBorder;

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

    @track locationSelected = false;

    @wire(CurrentPageReference) pageRef;
    @track isSpecialOrderCartItem;
    specialOrderCartStatus='';
    blockAddtoCartforSpecialCartItem=false;
    connectedCallback() {
        registerListener('locationSelected', this.checkLocation, this);
        this.checkForSpecialOrderEligibility();
    }
    disconnectedCallback() {
        unregisterAllListeners(this);
    }
    checkLocation(response) {
        const { status,isSpecialOrderCartItem } = response;
        this.locationSelected = status;
        this.isSpecialOrderCartItem=isSpecialOrderCartItem;
        console.log(169+'--PDP>>>',this.isSpecialOrderCartItem);
        this.fireSpecialOrderValidation();
        
        
    }

    fireSpecialOrderValidation(){
        console.log(184,this.isSpecialOrderCartItem,this.specialOrderCartStatus);
        if(this.isSpecialOrderCartItem==true && this.specialOrderCartStatus=='Not a special Order cart'){
           
            Toast.show({
                label: 'Error',
                message: 'You can not have special Order Items and In stock items in the same Cart. Please create seperate Orders',
                variant: 'error',
                mode: 'dismissable',
            }, this);
            this.blockAddtoCartforSpecialCartItem=true;
        }else if(this.isSpecialOrderCartItem==false && this.specialOrderCartStatus=='Special Order cart'){
            
            Toast.show({
                label: 'Error',

                message: 'Special Order Cart is already created for your user. You can not add in stock items corrosponding to this cart.',
                mode: 'dismissible',
                variant: 'error'
            }, this);
            this.blockAddtoCartforSpecialCartItem=true;
        }
    }


    checkForSpecialOrderEligibility(){
        checkIfCartExists({userId:Id,effectiveAccountId:effectiveAccount.accountId})
        .then(result=>{
            console.log(result);
            this.specialOrderCartStatus=result;
        })
        .catch(error=>{
            console.log(error);
        })
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
            !this.product ||
            this.productVariant?.isValid === false ||
            this.product?.productClass === 'Set' ||
            this.product?.productClass === 'VariationParent' ||
            this.locationSelected === false ||
            this.blockAddtoCartforSpecialCartItem === true
        );
    }

    /**
     * Whether the 'Add to Wishlist' button should be disabled.
     * @type {boolean}
     * @readonly
     * @private
     */
    get isWishlistButtonDisabled() {
        return !this.product;
    }

    /**
     * Gets the total inventory count for the product.
     * @type {?number}
     * @readonly
     * @private
     */
    get availableQuantity() {
        return this.productInventory?.details?.availableToOrder ?? null;
    }

    get quantityRule() {
        return this.product?.purchaseQuantityRule;
    }

    get normalizedMinimumText() {
        const text = this.minimumValueGuideText;
        const value = this.quantityRule?.minimum;
        return text && value ? text?.replace('{0}', Number(value)) : null;
    }

    get normalizedMaximumText() {
        const text = this.maximumValueGuideText;
        const value = this.quantityRule?.maximum;
        return text && value ? text?.replace('{0}', Number(value)) : null;
    }

    get normalizedIncrementText() {
        const text = this.stepValueGuideText;
        const value = this.quantityRule?.increment;
        return text && value ? text?.replace('{0}', Number(value)) : null;
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

    /**
     * Sets the custom CSS properties for the "Add To Wishlist" Button
     * @type {string}
     * @readonly
     * @private
     */
    get wishlistButtonStyles() {
        return generateStyleProperties({
            '--ref-c-lad_common-button-primary-color': this.wishlistButtonColor || 'initial',
            '--ref-c-lad_common-button-primary-color-background': this.wishlistButtonColorBackground || 'initial',
            '--ref-c-lad_common-button-primary-color-background-hover':
                this.wishlistButtonColorBackgroundHover || 'initial',
            '--ref-c-lad_common-button-primary-color-border': this.wishlistButtonColorBorder || 'initial',
            '--ref-c-lad_common-button-primary-color-hover': this.wishlistButtonColorHover || 'initial',
            '--ref-c-lad_common-button-radius-border': this.wishlistButtonRadiusBorder
                ? this.wishlistButtonRadiusBorder + 'px'
                : 'initial',
        });
    }

    handleQuantityChanged({ detail }) {
        const productId = this.product?.id;
        dispatchAction(this, createProductQuantityUpdateAction(productId, Number(detail.value)));
    }

    handleAddToCart({ detail }) {
        const productId = this.product?.id;
        productId &&
            dispatchAction(this, createCartItemAddAction(productId, detail.quantity), {
                onSuccess: () => {
                    CommonModal.open({
                        label: modalCartTitleSuccess,
                        size: 'small',
                        secondaryActionLabel: modalCartActionContinue,
                        primaryActionLabel: modalCartActionView,
                        onprimaryactionclick: () => navigate(this.navContext, cartPage),
                    });
                    if(this.isSpecialOrderCartItem){
                        this.updateSpecialOrderflagOnCart();

                    }
                },
                onError: (error) => {
                    const err = error?.error ?? error;
                    if (err?.code === 'GUEST_INSUFFICIENT_ACCESS') {
                        navigate(this.navContext, loginPage);
                    } else {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: toastTitleError,
                                message: getErrorMessage(err?.code),
                                variant: 'error',
                                mode: 'sticky',
                            })
                        );
                    }
                },
            });
    }


    updateSpecialOrderflagOnCart(){
        updateSpecialOrderflagOnCart({userId:Id,effectiveAccountId:effectiveAccount.accountId})
        .then(result=>{
            console.log(result);
        })
        .catch(error=>{
            console.log(366,error);
        })
    }

    handleAddToWishlist() {
        dispatchAction(this, createWishlistItemAddAction(this.product?.id), {
            onSuccess: () => {
                // this.dispatchEvent(
                //     new ShowToastEvent({
                //         title: toastTitleSuccess,
                //         message: toastWishlistSuccess,
                //         variant: 'success',
                //         mode: 'sticky',
                //     })
                // );
                Toast.show({
                    label: toastTitleSuccess,
                    message: toastWishlistSuccess,
                    mode: 'sticky',
                    variant: 'success'
                }, this);
            },
            onError: () => {
                if (!this.sessionContext?.data?.isLoggedIn) {
                    navigate(this.navContext, loginPage);
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: toastTitleError,
                            message: toastWishlistError,
                            variant: 'error',
                            mode: 'sticky',
                        })
                    );
                }
            },
        });
    }



}