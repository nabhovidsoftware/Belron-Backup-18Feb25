/** @description :  This component is used in Product Detail Page to select delivery/collection location based 
 *                  on Availability and Stock.
*   @Story :        FOUK-9051; FOUK-8454; FOUK-8231; FOUK-8232; FOUK-8230; FOUK-7684; FOUK-8367
*   @author:        (binayak.debnath@pwc.com (IN))
*   @CreatedDate:   22-05-2024
*/
import { LightningElement, api, track, wire } from 'lwc';
import getProductAvailability from '@salesforce/apex/LAD_ReturnAssociatedLocationDetails.getProductAvailability';
import createMDCPreferenceRecord from '@salesforce/apex/LAD_ReturnAssociatedLocationDetails.createMDCPreferenceRecord';
import getAccId from '@salesforce/apex/LAD_ReturnAssociatedLocationDetails.getAccId';
import { CurrentPageReference } from 'lightning/navigation';
import Id from '@salesforce/user/Id';
import { mockLocationData } from './Lad_LocationCheckOnCartProductPage_mock';
import { fireEvent } from 'c/lad_pubsub';
import Buyer from '@salesforce/customPermission/LAD_Laddaw_Buyer_Credit_Info';
import BuyerManager from '@salesforce/customPermission/LAD_Laddaw_Buyer_Manager_Credit_Info';
import InternalPortal from '@salesforce/customPermission/LAD_Laddaw_Internal_Portal';
import NotAvailable from '@salesforce/label/c.LAD_LocationCheckPDP_NotAvailable';
import { effectiveAccount } from 'commerce/effectiveAccountApi';


export default class Lad_LocationCheckOnCartProductPage extends LightningElement {

    @api Product;
    @wire(CurrentPageReference)
    pageRef;

    isLoading = true;
    @track sectionClosed = true;
    @track responseData;
    @track productId;
    @track location = 'New York';
    @track quantity = 100;
    @track deliveryDate;
    @track location;
    @track primarylocations = [];
    @track secondarylocations = [];
    @track seeAllClosed = true;
    @track seeAllData;
    @track selLocId;
    userId = Id;
    @track userConId;
    @track notavl = false;
    @track upArrow = true;
    @track isAllSecondaryDisabled = true;
    secondaryLocationAvailabilityForInternalUser=false;
    primaryLocationAvailabilityForInternalUser=false;
    isSpecialOrderCartItem=false;


    connectedCallback() {
        console.log('test', this.pageRef.attributes.recordId);
        this.productId = this.pageRef.attributes.recordId;

        console.log('Userid>>>', this.userId);
        console.log('productid>>>>', this.productId);

        if (this.isInSitePreview()) {
            //Mock Data if Preview
            this.responseData = JSON.parse(JSON.stringify(mockLocationData));
            this.handleResponseData();
            this.isLoading = false;
        }
        else {
            //Real Data
            let productDetails = { userId: this.userId, productIdList: [this.productId], location: this.location ? this.location : null, quantity: this.quantity ? this.quantity : null, effectiveAccountId: effectiveAccount.accountId ? effectiveAccount.accountId : null };
            getProductAvailability({ productDetails: productDetails })
                .then(result => {
                    this.responseData = JSON.parse(JSON.stringify(result[0]));
                    this.handleResponseData();
                    this.isLoading = false;
                })
                .catch(error => {
                    console.error('Error fetching response:', error);
                    this.isLoading = false;
                });
        }


    }




    get internalUser() {
        return InternalPortal;
    }

    get buyerUser() {
        return Buyer || BuyerManager;
    }

    handleResponseData() {
         
       

        this.primaryLocations = this.responseData.primarylocations;
        this.secondaryLocations = this.responseData.secondarylocations;
        console.log('this.primaryLocations>=', this.primaryLocations);
        console.log('this.secondaryLocations>=', this.secondaryLocations);
        console.log('responseData>>>' + this.responseData);

        for (let obj of this.secondaryLocations) {
            if (!this.internalUser && this.buyerUser) {
                if (!obj.dateIsToday) {
                    console.log('INSIDE NOT TODAY---->', obj.location, obj.dateIsToday);
                    obj.avlStatus = NotAvailable;
                    obj.isDisabled = true;
                    
                }
            }else if(this.internalUser && obj.avlStatus !=NotAvailable){// Special Order Logic
                this.secondaryLocationAvailabilityForInternalUser=true;// Special Order Logic
            }// Special Order Logic
            else {
                //Logic for other user.
            }

            if (obj.isDisabled !== true) {
                this.isAllSecondaryDisabled = obj.isDisabled;
            }

            obj.isRadioButtonDisabled=obj.isDisabled;
        }

        for (let obj of this.primaryLocations) {
            obj.avlStatus = obj.avlStatus.replace('delivery', '<b>delivery</b>');
            obj.avlStatus = obj.avlStatus.replace('collection', '<b>collection</b>');
            if(this.internalUser && obj.avlStatus !=NotAvailable){// Special Order Logic
                this.primaryLocationAvailabilityForInternalUser=true;// Special Order Logic
            }// Special Order Logic
            obj.isRadioButtonDisabled=obj.isDisabled;
        }
        console.log(133,this.primaryLocationAvailabilityForInternalUser,this.secondaryLocationAvailabilityForInternalUser ,this.internalUser);
        if(! this.primaryLocationAvailabilityForInternalUser && !this.secondaryLocationAvailabilityForInternalUser && this.internalUser){    // Special Order Logic.

            this.enableRadioForSpecialOrder();    // Special Order Logic.
            this.isSpecialOrderCartItem=true;
        }    // Special Order Logic.

    }

    // Special Order Logic.
    enableRadioForSpecialOrder(){
        for (let obj of this.primaryLocations) {
            obj.isRadioButtonDisabled=false;
        }
        for (let obj of this.secondaryLocations) {
            obj.isRadioButtonDisabled=false;
        }
    }

    //Handles the Check Other Locations section
    handleSeeAllView() {
        this.seeAllClosed = !this.seeAllClosed;
        this.upArrow = !this.upArrow;
        console.log(this.seeAllClosed);
    }

    //handles Location Selection
    handleLocationChange(event) {
        this.isLoading = true;
        this.selLocId = event.target.value;
        console.log('selLocId', this.selLocId);
        let selectedLocation = this.primaryLocations.find(location => location.locId === this.selLocId);
        if (!selectedLocation) {
            selectedLocation = this.secondaryLocations.find(location => location.locId === this.selLocId);
        }

        if (selectedLocation) {
            // Extract the delivery date from the selected location
            this.deliveryDate = selectedLocation.deliveryDate;

        }
        console.log('selLocId', this.selLocId);
        console.log('deliveryDate', this.deliveryDate);
        console.log('productId', this.productId);
        console.log('userId', this.userId);
        if (!this.isInSitePreview()) {

            let createMDCPreferenceRecordInput = { locationId: this.selLocId, productIdList: [this.productId], userId: this.userId, deliveryDate: this.deliveryDate, effectiveAccountId: effectiveAccount.accountId }


            createMDCPreferenceRecord({ createMDCPreferenceRecordInput: createMDCPreferenceRecordInput })
                .then(result => {
                    fireEvent(this.pageRef, 'locationSelected', { status: true, locationId: this.selLocId ,isSpecialOrderCartItem:this.isSpecialOrderCartItem});
                    this.isLoading = false;
                })
                .catch(error => {
                    console.error('ERROR IN MDC' + error.body.message);
                    this.isLoading = false;
                })
        }
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
            || url.indexOf('.builder.') > 0
            || url.indexOf('lightning') > 0);
    }
}