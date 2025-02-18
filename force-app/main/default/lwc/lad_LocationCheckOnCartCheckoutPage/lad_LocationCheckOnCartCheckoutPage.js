/** @description :  This component is used in Checkout Page to select delivery/collection location based 
 *                  on Availability and Stock and PO Number details
*   @Story :        FOUK-8221; FOUK-8178; FOUK-8052; FOUK-8206; FOUK-8229; FOUK-8230; FOUK-8447; FOUK-8478; FOUK-8476; FOUK-8367
*   @author:        (prajjawal.tiwari@pwc.com (IN))
*   @CreatedDate:   22-05-2024
*/
import { LightningElement, wire, api, track } from 'lwc';
import getCartId from '@salesforce/apex/LAD_checkoutPageController.getCartId';
import getCartItems from '@salesforce/apex/LAD_checkoutPageController.getCartItems';
import createDelGrp from '@salesforce/apex/LAD_checkoutPageController.createDelGrp';
import checkProductAvailability from '@salesforce/apex/LAD_ReturnAssociatedLocationDetails.getProductAvailability';
import getPrefilledData from '@salesforce/apex/LAD_checkoutPageController.returnPrefilledData';
import returnOrderItems from '@salesforce/apex/LAD_checkoutPageController.returnOrderItems';
import fetchPreferredTimeLimits from '@salesforce/apex/LAD_checkoutPageController.fetchPreferredTimeLimits';
import getWebStoreId from '@salesforce/apex/LAD_checkoutPageController.getWebStoreId';

import Toast from 'lightning/toast';


import siteId from '@salesforce/site/Id';
import { CurrentPageReference } from 'lightning/navigation';
import Id from '@salesforce/user/Id';
import { fireEvent } from 'c/lad_pubsub';
import Buyer from '@salesforce/customPermission/LAD_Laddaw_Buyer_Credit_Info';
import BuyerManager from '@salesforce/customPermission/LAD_Laddaw_Buyer_Manager_Credit_Info';
import InternalPortal from '@salesforce/customPermission/LAD_Laddaw_Internal_Portal';


import LAD_LocationCheckCheckout_AdditionalOrderInformation from '@salesforce/label/c.LAD_LocationCheckCheckout_AdditionalOrderInformation';
import LAD_LocationCheckCheckout_Address from '@salesforce/label/c.LAD_LocationCheckCheckout_Address';
import LAD_LocationCheckCheckout_Collect from '@salesforce/label/c.LAD_LocationCheckCheckout_Collect';
import LAD_LocationCheckCheckout_From from '@salesforce/label/c.LAD_LocationCheckCheckout_From';
import LAD_LocationCheckCheckout_Laddaw_Delivery from '@salesforce/label/c.LAD_LocationCheckCheckout_Laddaw_Delivery';
import LAD_LocationCheckCheckout_LaddawCollection from '@salesforce/label/c.LAD_LocationCheckCheckout_LaddawCollection';
import LAD_LocationCheckCheckout_PO_Number from '@salesforce/label/c.LAD_LocationCheckCheckout_PO_Number';
import LAD_LocationCheckCheckout_Price from '@salesforce/label/c.LAD_LocationCheckCheckout_Price';
import LAD_LocationCheckCheckout_Quantity from '@salesforce/label/c.LAD_LocationCheckCheckout_Quantity';
import LAD_LocationCheckCheckout_YourCart from '@salesforce/label/c.LAD_LocationCheckCheckout_YourCart';
import LAD_LocationCheckCheckout_Delivery from '@salesforce/label/c.LAD_LocationCheckCheckout_Delivery';
import LAD_LocationCheckPDP_AvailableDeliveryOrCollection from '@salesforce/label/c.LAD_LocationCheckPDP_AvailableDeliveryOrCollection';
import LAD_LocationCheckPDP_AvailableCollection from '@salesforce/label/c.LAD_LocationCheckPDP_AvailableCollection';
import LAD_LocationCheckPDP_NotAvailable from '@salesforce/label/c.LAD_LocationCheckPDP_NotAvailable';
import LAD_LocationCheckPDP_Available from '@salesforce/label/c.LAD_LocationCheckPDP_Available';
import LAD_Collectiondiscountof from '@salesforce/label/c.LAD_Collectiondiscountof';
import LAD_isavailable from '@salesforce/label/c.LAD_isavailable';

import { effectiveAccount } from 'commerce/effectiveAccountApi';
import { loadStyle } from 'lightning/platformResourceLoader';
import styles from '@salesforce/resourceUrl/RemoveDateFormatStyle';
import { loadCheckout } from "commerce/checkoutApi";
import { refreshCartSummary } from "commerce/cartApi";
import { NavigationMixin } from "lightning/navigation";
//creditlimitimports
import creditlimit from '@salesforce/apex/LAD_checkoutPageController.creditlimit';
import getAccId from '@salesforce/apex/LAD_checkoutPageController.getAccId';
import currencyfetch from '@salesforce/apex/LAD_checkoutPageController.currencyfetch';

import { CheckoutInformationAdapter, simplePurchaseOrderPayment, CheckoutComponentBase } from 'commerce/checkoutApi';
export default class Lad_LocationCheckOnCartCheckoutPage extends NavigationMixin(CheckoutComponentBase) {

    label = {
        LAD_LocationCheckCheckout_AdditionalOrderInformation,
        LAD_LocationCheckCheckout_Address,
        LAD_LocationCheckCheckout_Collect,
        LAD_LocationCheckCheckout_From,
        LAD_LocationCheckCheckout_Laddaw_Delivery,
        LAD_LocationCheckCheckout_LaddawCollection,
        LAD_LocationCheckCheckout_PO_Number,
        LAD_LocationCheckCheckout_Price,
        LAD_LocationCheckCheckout_Quantity,
        LAD_LocationCheckCheckout_YourCart,
        LAD_LocationCheckCheckout_Delivery,
        LAD_LocationCheckPDP_Available,
        LAD_LocationCheckPDP_NotAvailable,
        LAD_LocationCheckPDP_AvailableCollection,
        LAD_LocationCheckPDP_AvailableDeliveryOrCollection,
        LAD_Collectiondiscountof,
        LAD_isavailable
    }
    isDisabled = false;

    isCartFromAmendment = false;

    cartPoNumber = '';

    buttonLabel = 'Save';
    @wire(CurrentPageReference) pageRef;
    @track cartId;
    @track cartItems;
    error;
    @api Cart;
    @api recordId;
    isLoading = false;
    comment;

    @track sId = siteId;
    @track data;
    userId = Id
    orderId;
    @api accountId;
    @track productImageMap = {}; // map to hold images against cartitemid
    timeLimitForCollection; //FOUK-9758 & 9759
    timeLimitForDelivery; //FOUK-9940; FOUK-9941
    isSpecialOrderCart = false;//FOUK-9945
    availableProductList = [];//FOUK-9945
    // Effective Account Id from Account Switcher

    //creditlimit
    credit1 = false;
    currencyvalue = 'GP';
    creditlimit = 'nocreditnow';
    @track invoiceURL;


    renderedCallback() {
        Promise.all([
            loadStyle(this, styles) //specified filename
        ]).then(() => {
            window.console.log('Files loaded.');
        }).catch(error => {
            window.console.log("Error " + error.body.message);
        });
    }

    effectiveAccountId() {
        return effectiveAccount.accountId != null & effectiveAccount.accountId != '' ? effectiveAccount.accountId : this.accountId;
    }

    get internalUser() {
        return InternalPortal;
    }

    get buyerUser() {
        return Buyer || BuyerManager;
    }

    get isPoDisabled() {
        return this.isDisabled || this.isCartFromAmendment;
    }

    //function loaded from connectedCallback.
    // fetches webstore Id

    loadCartFromCallout() {
        getWebStoreId()
            .then(result => {
                this.invokeCallout(result);
            })
            .catch(error => {
                console.error('Error in finding Wishlist Items:', error);
            })
    }
    extractStoreUrl(url) {

        let index = url.indexOf('/', 8);

        if (index !== -1) {
            index = url.indexOf('/', index + 1);

            if (index !== -1) {
                return url.substring(0, index);
            }
        }

        return url;
    }

    // functions calls out to a externalUrl to fetch cartDetails
    invokeCallout(webStoreId) {
        console.log(30);
        let url = '';
        if (effectiveAccount.accountId != null && effectiveAccount.accountId != '') {
            url = this.extractStoreUrl(window.location.href) + '/webruntime/api/services/data/v61.0/commerce/webstores/' + webStoreId + '/carts/current/cart-items?includePromotions=true&includeCoupons=true&sort=CreatedDateDesc&productFields=*&pageNumber=1&pageSize=25&effectiveAccountId=' + effectiveAccount.accountId + '&language=en-US&asGuest=false&htmlEncode=false';
        } else {
            url = this.extractStoreUrl(window.location.href) + '/webruntime/api/services/data/v61.0/commerce/webstores/' + webStoreId + '/carts/current/cart-items?includePromotions=true&includeCoupons=true&sort=CreatedDateDesc&productFields=*&pageNumber=1&pageSize=25&language=en-US&asGuest=false&htmlEncode=false';

        }
        fetch(url)
            .then(response => {
                if (!response.ok) {
                    throw new Error('Network response was not ok');
                }
                return response.json();
            })
            .then(data => {

                this.productImageMap = this.extractProductDetails(data);
                console.log(this.productImageMap);
            })
            .catch(error => {
                console.error('There was a problem with the fetch operation:', error);
            });
    }

    extractProductDetails(jsonData) {
        const resultMap = new Map();

        const cartItems = jsonData.cartItems || [];

        cartItems.forEach(item => {
            const cartItem = item.cartItem || {};
            const cartItemId = cartItem.cartItemId;
            const thumbnailImage = cartItem.productDetails.thumbnailImage || {};
            const thumbnailUrl = thumbnailImage.url;
            console.log(18200, cartItemId, thumbnailUrl);
            if (cartItemId && thumbnailUrl) {
                resultMap.set(cartItemId, thumbnailUrl);
            }
        });

        return resultMap;
    }
    connectedCallback() {
        console.log('effectiveAccountId', this.effectiveAccountId());

        this.loadCartFromCallout();



        this.isLoading = true;

        //FOUK-9758 & 9759
        fetchPreferredTimeLimits()
            .then(result => {
                this.timeLimitForCollection = result.CollectionLimit;
                this.timeLimitForDelivery = result.DeliveryLimit;
            });


        setTimeout(() => {

            console.log(this.userId, this.effectiveAccountId());
            getCartId({ userId: this.userId, accountId: this.effectiveAccountId() })
                .then(result => {
                    console.log(102);

                    console.log(JSON.stringify(result));
                    const { cartId, orderId, isSpecialOrderCart } = result;//FOUK-9945
                    this.cartId = cartId;
                    this.loadCartItems();
                    this.isSpecialOrderCart = isSpecialOrderCart;//FOUK-9945
                    console.log('ORDER ID', orderId, 'SPECIALORDER', isSpecialOrderCart);
                    if (orderId && isSpecialOrderCart) {
                        fireEvent(this.pageRef, 'amendOrder', orderId);
                        fireEvent(this.pageRef, 'specialOrder', isSpecialOrderCart);
                        this.orderId = orderId;
                        this.isCartFromAmendment = true;
                    } else if (orderId) {
                        fireEvent(this.pageRef, 'amendOrder', orderId);
                        this.orderId = orderId;
                        this.isCartFromAmendment = true;
                    } else if (isSpecialOrderCart) {
                        fireEvent(this.pageRef, 'specialOrder', isSpecialOrderCart);
                        this.isCartFromAmendment = false;

                    } else {
                        this.isCartFromAmendment = false;
                    }

                })
                .catch(error => {
                    this.isLoading = false;
                    this.error = error;
                    console.log(error);
                });

        }, 1000);




        //credit limitstart
        getAccId({ userid: Id })
            .then(result => {


                this.accountId = result;
                console.log('RECORD ID1>>>' + this.accountId);
                this.fetchDetailsCart();

            })
            .catch(error => {
                console.log(error);
            })






        //creditlimitend

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
            })
            .catch(error => {
                console.error('Error generating URL:', error);
            });


    }


    getCartDetails() {

    }

    loadCartItems() {

        getCartItems({ cartId: this.cartId })
            .then(result => {
                console.log(139);
                console.log(JSON.stringify(result));

                this.cartItems = JSON.parse(JSON.stringify(result));


                this.cartItems.forEach(item => {
                    item.poNumber = '';
                    item.poIcon = 'utility:edit';
                    item.isDisabled = false;
                    item.editMode = true;
                    console.log(256, item.Id);
                    item.ImageURL = this.productImageMap.has(item.Id) ? this.productImageMap.get(item.Id) : null;
                    console.log(258, item.ImageURL);

                    if (item.Addresses) {
                        let temp = item.Addresses;
                        let addresses = temp.map(addressObj => {
                            // const address = addressObj.address;
                            const street = addressObj.address.street;
                            const city = addressObj.address.city;
                            const state = addressObj.address.state;
                            const postal = addressObj.address.postalCode;
                            const country = addressObj.address.country;
                            const fullAdd = street + ', ' + city + ', ' + state + ', ' + postal + ', ' + country;

                            return {
                                addressId: addressObj.addressId,
                                label: fullAdd,
                                value: fullAdd,
                                isDefault: addressObj.isDefault,
                                isSelected: addressObj.isDefault
                            };
                        });
                        console.log(198, addresses);
                        const defaultAddress = addresses.find(address => address.isDefault == true);
                        console.log(200, defaultAddress);
                        try {
                            item.Addresses = addresses;
                            item.selectedAddress = defaultAddress ? defaultAddress.value : null;
                            item.selectedAddressId = defaultAddress.addressId;
                            console.log('204selectedAddressId>>>', item.selectedAddressId);

                        } catch (e) {
                            console.log(e);
                        }



                    }
                    if (!this.isCartFromAmendment) {
                        if (item.AvailableForDelivery == true && item.selectedAddress !== null) {
                            item.isDelivery = true;
                            console.log('IN DELIVERY-LOAD CART ITEMS---> ' + item.selectedAddress);
                        } else if (item.selectedAddress == null || item.selectedAddress == undefined) {
                            console.log('IN DELIVERY-LOAD CART ITEMS---> ' + item.selectedAddress);
                            item.isCollection = true;
                        }
                    }


                });

                this.loadPrefilledData();
                this.invokeProductAvailabilityCheck();
            })
            .catch(error => {
                this.isLoading = false;

                this.error = error;
                console.log(error);

            });
    }



    //fetchdetailsforcreditlimit
    fetchDetailsCart() {
        let variable = effectiveAccount.accountId != null & effectiveAccount.accountId != undefined ? effectiveAccount.accountId : this.accountId;
        console.log('variable in cart : ' + variable);
        creditlimit({ accountId: variable, userId: Id })
            .then(data => {

                if (data.startsWith('1')) {
                    this.credit1 = true;
                    this.creditlimit = data.slice(1);
                    console.log('Creditlimitchange : ' + this.creditlimit);
                }
                else {
                    this.credit1 = false;
                    this.creditlimit = data.slice(1);
                    console.log('Creditlimitchange : ' + this.creditlimit);
                }


            })

        currencyfetch({ accountId: variable, userId: Id })
            .then(data => {

                console.log('Creditlimitdata : ' + data);
                this.currencyvalue = data;
                console.log('currencyvalue' + this.currencyvalue);


            })
    }









    invokeProductAvailabilityCheck() {

        //let productIdList = [];
        let productInfoList = [];
        for (let obj of this.cartItems) {
            //productIdList.push(obj.ProductId);
            const productObj = {
                productId: obj.ProductId,
                quantity: obj.Quantity
            }

            productInfoList.push(productObj);
        }
        let productObj = {
            userId: this.userId,
            productInfo: productInfoList,
            effectiveAccountId: null
        };

        checkProductAvailability({ productDetails: productObj })
            .then(result => {
                this.isLoading = false;
                console.log('AVAILABILITY: ', result);
                console.log('CART ITEMS: ', this.cartItems);

                // try{
                result.forEach(r => {
                    console.log(464);
                    this.cartItems = this.cartItems.map(i => {
                        if (r.productId == i.ProductId) {
                            let primaryStatus = r.primarylocations.find(j => j.location == i.LocationName);
                            let secondaryStatus = r.secondarylocations.find(j => j.location == i.LocationName);
                            console.log(469);

                            if (primaryStatus == null || primaryStatus == undefined) {  //Secondary
                                console.log(472);

                                i.isSecondary = true;
                                i.isPrimary = false;
                                console.log(477);

                                if (!secondaryStatus.dateIsToday && this.buyerUser && !this.internalUser) {
                                    i.deliveryStatus = 'Not Available';
                                } else {
                                    i.deliveryStatus = secondaryStatus.avlStatus;

                                }
                                console.log(484);

                                i.stockCount = secondaryStatus.stockCount;
                                i.deliveryDate = secondaryStatus.deliveryDate;
                                i.dateIsToday = secondaryStatus.dateIsToday;
                            } else {
                                console.log(485);
                                //Primary
                                i.isSecondary = false;
                                i.isPrimary = true;
                                i.deliveryStatus = primaryStatus.avlStatus;
                                i.stockCount = primaryStatus.stockCount;
                                i.deliveryDate = primaryStatus.deliveryDate;
                                i.dateIsToday = primaryStatus.dateIsToday;
                                /* FOUK-9758 & FOUK-9759 */
                                i.minCollectDate = primaryStatus.deliveryDate; //lower limit of collection date
                                i.maxCollectDate = this.addBusinessDays(i.minCollectDate, this.timeLimitForCollection); //upper limit of collection date
                                console.log(i.minCollectDate, i.maxCollectDate);
                                /* FOUK-9940 & FOUK-9941 */
                                i.minDeliveryDate = primaryStatus.deliveryDate; //lower limit of delivery date
                                i.maxDeliveryDate = this.addBusinessDays(i.minDeliveryDate, this.timeLimitForDelivery); //upper limit of delivery date
                            }

                            console.log(504);

                            if (i.deliveryStatus == this.label.LAD_LocationCheckPDP_AvailableDeliveryOrCollection) {
                                console.log(506);

                                i.isDeliveryDisabled = false;
                                i.isCollectionDisabled = false;
                                i.isDeliveryDisabledMock = false;
                                i.isCollectionDisabledMock = false;
                                i.isStockDisabled = false;
                            } else if (i.deliveryStatus == this.label.LAD_LocationCheckPDP_AvailableCollection) {
                                console.log(514);

                                i.isDeliveryDisabled = !InternalPortal; // replaced true with check if user is an internal portal user
                                i.isCollectionDisabled = false;
                                i.isDeliveryDisabledMock = !InternalPortal; // replaced true with check if user is an internal portal user
                                i.isCollectionDisabledMock = false;
                                i.isStockDisabled = false;
                            } else if (i.deliveryStatus == this.label.LAD_LocationCheckPDP_Available) {
                                console.log(523);

                                i.isDeliveryDisabled = !InternalPortal; // replaced true with check if user is an internal portal user
                                i.isCollectionDisabled = false;
                                i.isDeliveryDisabledMock = !InternalPortal; // replaced true with check if user is an internal portal user
                                i.isCollectionDisabledMock = false;
                                i.isStockDisabled = false;
                            } else if (i.deliveryStatus == this.label.LAD_LocationCheckPDP_NotAvailable) {
                                console.log(530);

                                i.isStockDisabled = true;
                                i.isDeliveryDisabled = !InternalPortal; // replaced true with check if user is an internal portal user
                                i.isCollectionDisabled = !InternalPortal; // replaced true with check if user is an internal portal user
                                i.isDeliveryDisabledMock = !InternalPortal; // replaced true with check if user is an internal portal user
                                i.isCollectionDisabledMock = !InternalPortal; // replaced true with check if user is an internal portal user
                            }

                            console.log(i.isCollection, i.isCollectionDisabled);
                            i.isPrefCollectionDisabled = i.isCollection && !i.isCollectionDisabled ? false : true; //FOUK-9758 & FOUK-9759
                            i.isPrefDeliveryDisabled = i.isDelivery && !i.isDeliveryDisabled ? false : true; //FOUK-9940 & FOUK-9941

                            if (i.deliveryStatus != 'Not Available') {//FOUK-9945
                                console.log(544);

                                this.availableProductList.push(i.CartItemName);//FOUK-9945
                            }//FOUK-9945

                        }
                        return i;
                    })
                })

            })
            .then(i => {
                let numberOfUnavailableProducts = this.cartItems.length - this.availableProductList.length;
                console.log(436, numberOfUnavailableProducts, this.isSpecialOrderCart, -this.availableProductList.length);

                if (numberOfUnavailableProducts != 0 && this.isSpecialOrderCart == false) {
                    Toast.show({
                        label: 'Error',

                        message: 'Insufficient stock available- please navigate back to cart and update quantity',
                        mode: 'dismissible',
                        variant: 'error'
                    }, this);
                }

                console.log('CART ITEMS: ', this.cartItems);
            })
            .catch(error => {
                this.isLoading = false;

                console.log(JSON.stringify(error));
            })



    }



    /* FOUK-9758 & FOUK-9759 & FOUK-9940 & FOUK-9941*/
    //Adds Business Days as specified in the custom label
    addBusinessDays(lowerDate, timeLimit) {
        let upperDate = new Date(lowerDate);

        //Function to check weekend
        function isWeekend(date) {
            const day = date.getDay();
            return day === 0 || day === 6;
        }

        // Function to format the date back to YYYY-MM-DD
        function formatDateToString(date) {
            const year = date.getFullYear();
            const month = ('0' + (date.getMonth() + 1)).slice(-2);
            const day = ('0' + date.getDate()).slice(-2);
            return `${year}-${month}-${day}`;
        }

        let addedDays = 0;

        const daysToAdd = timeLimit;
        console.log(typeof (daysToAdd), daysToAdd);

        while (addedDays < daysToAdd) {
            upperDate.setDate(upperDate.getDate() + 1);

            /* if (!isWeekend(upperDate)) {
                addedDays++;
            } */
            addedDays++;
        }

        return formatDateToString(upperDate);



    }




    loadPrefilledData() {
        console.log(this.cartItems);

        try {
            setTimeout(() => {
                loadCheckout();
                refreshCartSummary();
            }, 500);


        } catch (e) {
            console.log(802, e);
        }

        getPrefilledData({ cartId: this.cartId })
            .then(result => {

                let responseJson = JSON.parse(JSON.stringify(result))
                console.log(responseJson);
                this.cartItems.forEach(i => {
                    try {
                        let cartmethod = responseJson.find(j => j.Id == i.Id);
                        i.poNumber = cartmethod.LAD_PO_Number__c == undefined ? '' : cartmethod.LAD_PO_Number__c;
                        this.cartPoNumber = cartmethod.Cart.PoNumber == undefined ? '' : cartmethod.Cart.PoNumber;
                        this.comment = cartmethod.Cart.LAD_Comment__c == undefined ? '' : cartmethod.Cart.LAD_Comment__c;

                        console.log('IN PREFILLED---> ' + cartmethod.CartDeliveryGroup.Name);
                        if (cartmethod.CartDeliveryGroup != null && cartmethod.CartDeliveryGroup.Name != 'Cart Delivery Group') {
                            i.selectedAddressId = cartmethod.CartDeliveryGroup.LAD_Address_Key__c != null ? cartmethod.CartDeliveryGroup.LAD_Address_Key__c : i.selectedAddressId;
                            if (cartmethod.CartDeliveryGroup.Name.includes(this.label.LAD_LocationCheckCheckout_Laddaw_Delivery)) {
                                i.isCollection = false;
                                i.isDelivery = true;
                                i.isPrefDeliveryDisabled = false; //FOUK-9940 & FOUK-9941
                                i.selectedDeliveryDate = cartmethod.CartDeliveryGroup.LAD_Date_Selected_By_Customer__c; //FOUK-9940 & FOUK-9941
                                try {
                                    i.selectedAddress = i.Addresses.find(k => k.addressId == cartmethod.CartDeliveryGroup.LAD_Address_Key__c).value;
                                } catch (e) {
                                    console.log(e);
                                }


                            } else if (cartmethod.CartDeliveryGroup.Name.includes(this.label.LAD_LocationCheckCheckout_LaddawCollection)) {
                                i.isDelivery = false;
                                i.isCollection = true;
                                i.isPrefCollectionDisabled = false; //FOUK-9758 & FOUK-9759
                                i.selectedCollectionDate = cartmethod.CartDeliveryGroup.LAD_Date_Selected_By_Customer__c; //FOUK-9758 & FOUK-9759
                            }
                        }





                    } catch (e) {
                        console.log(e);
                    }
                })
                // this.validateAndFire();

            }).catch(error => {
                this.isLoading = false;


            })
    }


    handleAddressChange(event) {
        const cartItemId = event.target.name;
        let selectedAddress = event.target.label;
        console.log(selectedAddress);
        this.cartItems = this.cartItems.map(item => {

            if (item.Id === cartItemId) {
                item.isDelivery = true;
                item.isCollection = false;
                item.selectedAddressId = event.target.value;
                console.log('436selectedAddressId>>>', item.selectedAddressId);

                item.selectedAddress = selectedAddress;
                console.log(item.selectedAddress);

                item.Addresses.forEach(i => {
                    if (i.addressId == event.target.value) {
                        i.isSelected = true;
                    } else {
                        i.isSelected = false;
                    }
                })
                /* FOUK-9758 & FOUK-9759 */
                item.selectedCollectionDate = null;
                item.isPrefCollectionDisabled = true; //FOUK-9758 & FOUK-9759
                let dateElement = this.template.querySelector(`[data-id='${item.Id}'][data-method="collection"]`);
                dateElement.value = null;
                dateElement.reportValidity(); //makes the error messages go away if any after assigning null

                item.isPrefDeliveryDisabled = false; //FOUK-9940; FOUK-9941

            }
            return item;
        });
        console.log(305, this.cartItems);
    }

    handleLocationChange(event) {
        try {

            this.cartItems = this.cartItems.map(item => {

                if (item.Id === event.target.dataset.cartitemid) {
                    item.isDelivery = false;
                    item.isCollection = true;
                    item.selectedAddressId = event.target.value;
                    console.log('465selectedAddressId>>>', item.selectedAddressId);

                    item.isPrefCollectionDisabled = false; //FOUK-9758 & FOUK-9759

                    /* FOUK-9940 & FOUK-9941 */
                    item.selectedDeliveryDate = null;
                    item.isPrefDeliveryDisabled = true; //FOUK-9940 & FOUK-9941
                    let dateElement = this.template.querySelector(`[data-id='${item.Id}'][data-method="delivery"]`);
                    dateElement.value = null;
                    dateElement.reportValidity(); //makes the error messages go away if any after assigning null

                    //item.selectedAddress = event.target.dataset.method !== this.label.LAD_LocationCheckCheckout_LaddawCollection ? event.target.attributes.addresslabel.nodeValue : null;
                    //console.log(item.selectedAddress);

                    /*  item.Addresses.forEach(i => {
                        if (i.addressId == event.target.value) {
                            i.isSelected = true;
                        } else {
                            i.isSelected = false;
                        }
                     }) */
                    //

                }
                return item;
            });


        } catch (ex) {
            console.log(ex);
        }
    }

    /* FOUK-9758 & FOUK-9759 */
    handleCollectionDateChange(event) {
        let collectDate = event.target.value;
        console.log(collectDate);

        this.cartItems.forEach(item => {
            if (item.Id === event.target.dataset.id) {
                item.selectedCollectionDate = collectDate;
            }
        })
    }

    /* FOUK-9940 & FOUK-9941 */
    handleDeliveryDateChange(event) {
        let deliveryDate = event.target.value;
        console.log(deliveryDate);

        this.cartItems.forEach(item => {
            if (item.Id === event.target.dataset.id) {
                item.selectedDeliveryDate = deliveryDate;
            }
        })
    }



    validateAndFire() {
        let counter = 0;
        this.cartItems.map(item => {

            if ((item.isCollection != true & item.isDelivery != true) /* || (item.poNumber == null || item.poNumber == '' || item.poNumber == undefined) || (this.cartPoNumber == null || this.cartPoNumber == '' || this.cartPoNumber == undefined) */) {

                counter++;


            }
        })
        let obj = { 'cartId': this.cartId, 'comment': this.comment };


        if (counter == 0) {
            fireEvent(this.pageRef, 'checkoutComplete', obj);
        }
    }


    handlePoIconClick(event) {

        this.cartItems = this.cartItems.map(item => {

            if (item.Id === event.target.value) {
                if (item.editMode) {
                    item.poIcon = 'utility:save';

                } else {
                    // this.isLoading=true;


                    item.poIcon = 'utility:edit';


                }
                item.editMode = !item.editMode;


            }
            return item;
        });


    }
    handlePOUpdate(event) {

        this.cartItems = this.cartItems.map(item => {

            if (item.Id === event.target.attributes.cartitem.nodeValue) {
                item.poNumber = event.target.value;

            }
            return item;
        });
    }
    handledefaultaddress(event) {
        try {
            let address = '';

            this.cartItems = this.cartItems.map(item => {


                if (item.Id === event.target.attributes.cartitemid.nodeValue) {


                    item.Addresses.map(i => {


                        if (i.label == event.target.attributes.selectedaddress.nodeValue) {

                            address = i.addressId;
                            console.log(391, address);

                        }
                    })
                }


                if (address != null && address != '' && address != undefined) {
                    console.log(398, address)

                    item.selectedAddressId = address;
                    console.log('588selectedAddressId>>>', item.selectedAddressId);

                }

                return item;
            })


            console.log(405, this.cartItems);

            this.cartItems = this.cartItems.map(item => {

                if (item.Id === event.target.attributes.cartitemid.nodeValue) {
                    item.isDelivery = true;
                    item.isCollection = false;
                    item.selectedAddress = event.target.attributes.selectedaddress.nodeValue;
                    item.isPrefDeliveryDisabled = false; //FOUK-9940 & FOUK-9941
                    /* FOUK-9758 & FOUK-9759 */
                    item.selectedCollectionDate = null;
                    item.isPrefCollectionDisabled = true; //FOUK-9758 & FOUK-9759
                    let dateElement = this.template.querySelector(`[data-id='${item.Id}'][data-method="collection"]`);
                    dateElement.value = null;
                    dateElement.reportValidity(); //makes the error messages go away if any after assigning null
                }
                return item;
            });
        } catch (e) {
            console.log(e);
        }

    }

    errorReason = [];
    async handleSaveButton() {
        //credit limit 

        if (this.credit1) {      //runs if credit1 is true.. so place order should not be accessed
            console.log('From handlesaveButton' + this.credit1);
            Toast.show({
                label: 'Error',
                message: 'The value of your cart exceeds your remaining available credit (' + this.currencyvalue + ' ' + this.creditlimit + '). Please reduce the value of your cart or process a {payment}  to continue with this order.',

                messageLinks: {
                    payment: {
                        url: this.invoiceURL,
                        label: 'payment'
                    }
                },
                mode: 'dismissible',
                variant: 'error'
            }, this);

        }






        else if (this.availableProductList.length != 0 && this.isSpecialOrderCart == true && this.isCartFromAmendment == false) {//FOUK-9945 This if else condition is for special order conditions.
            Toast.show({
                label: 'Error',

                message: ' Please return to the Cart page to remove these items from your Cart' + this.availableProductList.join(','),
                mode: 'dismissible',
                variant: 'error'
            }, this);
        } else {
            if (this.isCartFromAmendment) {
                this.validateSavedData()
                    .then((response) => {
                        console.log('response', response);

                        if (response == true) {
                            this.handleSave();
                        } else {
                            this.errorReason.forEach(i => {

                                Toast.show({
                                    label: 'Error',

                                    message: i.product + ':' + i.error,
                                    mode: 'dismissible',
                                    variant: 'error'
                                }, this);

                            })
                        }





                    }).catch((error) => {
                        this.error = error;
                    });

            } else {
                this.handleSave();

            }
        }
    }

    async validateSavedData() {
        console.log(this.cartItems);
        let status = true;
        this.errorReason = [];
        let reason = [];
        if (this.orderId) {
            await returnOrderItems({ orderId: this.orderId })
                .then(result => {
                    console.log(result);
                    this.cartItems.map(i => {
                        let item = result.find(j => j.Product2Id == i.ProductId);
                        if (item == null || item == undefined) {
                            status = false;
                            reason.push({ 'product': i.ProductName, 'error': 'You can not add new Products to Amended Order' });
                        } else if (item.Quantity < i.Quantity) {
                            status = false;
                            reason.push({ 'product': i.ProductName, 'error': 'You can not increase quantity of this Product' });

                        } else if (item.OrderDeliveryGroupSummary.OrderDeliveryMethod.Name == 'Laddaw Collection' && i.isDelivery == true) {
                            status = false;
                            reason.push({ 'product': i.ProductName, 'error': 'You cannot Change Delivery Method for this Product.' });

                        }
                    })
                })
            this.errorReason = [...reason];
            console.log(status);
            console.log(this.errorReason);
            return status;
        }

    }

    async handleSave() {

        /* FOUK-9758 & FOUK-9759 */
        //Check for Primary Collections with invalid Preferred Date
        let preferredDateErrorCount = [];
        this.cartItems.forEach(item => {
            if (item.isPrimary && item.isCollection) {
                if (item.selectedCollectionDate) {
                    const lowerDate = new Date(item.minCollectDate);
                    const upperDate = new Date(item.maxCollectDate);
                    const selectedDate = new Date(item.selectedCollectionDate);
                    console.log(lowerDate, upperDate, selectedDate);
                    if (selectedDate < lowerDate || selectedDate > upperDate) {
                        if (item.minCollectDate === item.maxCollectDate) {
                            preferredDateErrorCount.push({ 'product': item.ProductName, 'error': `Please select a valid Preferred Collection Date i.e. ${item.minCollectDate} before proceeding` });
                        }
                        else {
                            preferredDateErrorCount.push({ 'product': item.ProductName, 'error': `Please select a valid Preferred Collection Date between ${item.minCollectDate} and ${item.maxCollectDate} before proceeding` });
                        }
                    }
                }
                else {
                    preferredDateErrorCount.push({ 'product': item.ProductName, 'error': 'Please select a Preferred Collection Date before proceeding' });

                }
            }
            /* FOUK-9940 & FOUK-9941 */
            //Check for Primary Deliveries with invalid Preferred Date
            else if (item.isPrimary && item.isDelivery) {
                if (item.selectedDeliveryDate) {
                    const lowerDate = new Date(item.minDeliveryDate);
                    const upperDate = new Date(item.maxDeliveryDate);
                    const selectedDate = new Date(item.selectedDeliveryDate);
                    console.log(lowerDate, upperDate, selectedDate);
                    if (selectedDate < lowerDate || selectedDate > upperDate) {
                        if (item.minDeliveryDate === item.maxDeliveryDate) {
                            preferredDateErrorCount.push({ 'product': item.ProductName, 'error': `Please select a valid Preferred Delivery Date i.e. ${item.minDeliveryDate} before proceeding` });
                        }
                        else {
                            preferredDateErrorCount.push({ 'product': item.ProductName, 'error': `Please select a valid Preferred Delivery Date between ${item.minDeliveryDate} and ${item.maxDeliveryDate} before proceeding` });
                        }
                    }
                }
                else {
                    preferredDateErrorCount.push({ 'product': item.ProductName, 'error': 'Please select a Preferred Delivery Date before proceeding' });

                }
            }
        })

        /* FOUK-9758 & FOUK-9759 & FOUK-9940 & FOUK-9941*/
        //Throw error for invalid Preferred Date cases
        if (preferredDateErrorCount.length > 0) {
            preferredDateErrorCount.forEach(i => {

                Toast.show({
                    label: 'Error',

                    message: i.product + ': ' + i.error,
                    mode: 'dismissible',
                    variant: 'error'
                }, this);

            })
            this.isLoading = false;
            return;
        }

        this.isDisabled = !this.isDisabled;
        this.buttonLabel = this.isDisabled == true ? 'Edit' : 'Save';

        this.cartItems = this.cartItems.map(item => {


            item.isDisabled = this.isDisabled;

            item.isDeliveryDisabled = this.isDisabled ? this.isDisabled : item.isDeliveryDisabledMock;
            item.isCollectionDisabled = this.isDisabled ? this.isDisabled : item.isCollectionDisabledMock;
            item.isPrefCollectionDisabled = this.isDisabled ? this.isDisabled : item.isCollection ? false : true; //FOUK-9758 & FOUK-9759
            item.isPrefDeliveryDisabled = this.isDisabled ? this.isDisabled : item.isDelivery ? false : true; //FOUK-9758 & FOUK-9759
            // item.isDeliveryDisabledMock=true;
            // item.isCollectionDisabledMock=false;


            return item;
        });

        let obj = [];
        let locationSelectionDateMap = {};
        this.cartItems.forEach(item => {
            let i = '';
            let preferredDate; //FOUK-9758; FOUK-9759; FOUK-9940; FOUK-9941
            if (item.isCollection == true) {
                i = this.label.LAD_LocationCheckCheckout_LaddawCollection;
                if (item.isPrimary) {
                    preferredDate = item.selectedCollectionDate; //FOUK-9758; FOUK-9759; FOUK-9940; FOUK-9941
                }

            } else if (item.isDelivery == true) {
                i = this.label.LAD_LocationCheckCheckout_Laddaw_Delivery;
                if (item.isPrimary) {
                    preferredDate = item.selectedDeliveryDate; //FOUK-9758; FOUK-9759; FOUK-9940; FOUK-9941
                }

            }

            obj.push({ 'location': item.LocationName, 'method': i, price: item.ListPrice, product: item.ProductId, 'address': item.selectedAddressId, 'cartitemid': item.Id, 'deliverydate': item.deliveryDate, 'poNumber': item.poNumber, 'preferredDate': preferredDate ?? item.deliveryDate, 'invokeCollectionDiscount': (i == this.label.LAD_LocationCheckCheckout_LaddawCollection && item.eligibleForCollectionDiscount) });
        })





        if (this.buttonLabel == 'Edit') {
            this.isLoading = true;
            console.log({ 'cartId': this.cartId, 'cartdetails': obj, 'cartComment': this.comment, 'cartPoNumber': this.cartPoNumber });

            createDelGrp({ 'cartId': this.cartId, 'cartdetails': obj, 'cartComment': this.comment, 'cartPoNumber': this.cartPoNumber })
                .then(result => {
                    this.isLoading = false;
                    this.validateAndFire();
                    try {
                        setTimeout(() => {
                            this.getUpdatedPrices();
                            loadCheckout();
                            refreshCartSummary();
                        }, 2000);


                    } catch (e) {
                        console.log(802, e);
                    }

                })
                .catch(error => {
                    console.log(JSON.stringify(error));
                    this.isLoading = false;
                })
        } else if (this.buttonLabel == 'Save') {
            let obj = { 'cartId': null, 'comment': null };
            fireEvent(this.pageRef, 'checkoutComplete', obj);
        }

    }

    getUpdatedPrices() {
        getCartItems({ cartId: this.cartId })
            .then(result => {
                this.updatePrices(result);
            })
            .catch(error => {
                console.log(error);
            })
    }

    updatePrices(result) {
        let responseJson = JSON.parse(JSON.stringify(result));
        console.log(980, responseJson);
        this.cartItems.forEach(i => {
            console.log(i)
            let cartItem = responseJson.find(j => j.Id == i.Id);
            console.log(cartItem);
            i.ListPrice = cartItem.ListPrice;
        })

    }

    handlePONumber(event) {
        this.cartPoNumber = event.target.value
    }

    handleComment(event) {
        this.comment = event.target.value;
    }


}