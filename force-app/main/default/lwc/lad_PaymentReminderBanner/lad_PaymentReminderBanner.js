/** @description :  This component is used to show banner according to the Invoice Status 
*   @Story :        FOUK-10157
*   @author:        (hrithas.sardar@pwc.com (IN))
*   @CreatedDate:   24-09-2024
*/
import { LightningElement, wire, track } from 'lwc';
import { MOCKcolour } from './lad_PaymentReminderBanner_Mock';
import { getRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import { effectiveAccount } from 'commerce/effectiveAccountApi';
import UserNameFIELD from '@salesforce/schema/User.Name';
import { NavigationMixin } from 'lightning/navigation';
import LAD_InvoiceHandler_RedBannerMessage from '@salesforce/label/c.LAD_InvoiceHandler_RedBannerMessage';
import LAD_InvoiceHandler_OrangeBannerMessage from '@salesforce/label/c.LAD_InvoiceHandler_OrangeBannerMessage';
import LAD_InvoiceHandler_BlueBannerMessage from '@salesforce/label/c.LAD_InvoiceHandler_BlueBannerMessage';
import invoiceBannerCheck from '@salesforce/apex/LAD_InvoiceHandler.invoiceBannerCheck';
import getAccId from '@salesforce/apex/LAD_ReturnAssociatedLocationDetails.getAccId';




export default class Lad_PaymentReminderBanner extends NavigationMixin(LightningElement) {

    accountId;
    @track labels = {
        Red: LAD_InvoiceHandler_RedBannerMessage,
        Orange: LAD_InvoiceHandler_OrangeBannerMessage,
        Blue: LAD_InvoiceHandler_BlueBannerMessage,
    }

    @track name;

    @track invoiceURL;
    orange = false;
    red = false;
    blue = false;

    @wire(getRecord, { recordId: Id, fields: UserNameFIELD })
    currentUserInfo({ error, data }) {
        if (data) {
            this.name = data.fields.Name.value;

        } else if (error) {
            this.error = error;
        }
    }


    connectedCallback() {
        if (this.isInSitePreview()) {
            const colour = MOCKcolour;
            this.handleBannerShow(colour);
        }
        else {
            getAccId({ userid: Id }).then(result => {
                if (result) {
                    this.accountId = effectiveAccount.accountId !== null && effectiveAccount.accountId !== undefined ? effectiveAccount.accountId : result;
                    console.log('ACCOUNT ID: ' + this.accountId);
                    invoiceBannerCheck({ accountId: this.accountId })
                        .then(result => {
                            if (result) {
                                this.handleBannerShow(result);
                            }
                            console.log('RESULT: ' + result);

                        })
                        .catch(error => {
                            console.error("ERROR IN BANNER FETCHING: ", error);
                        })
                }
                else {
                    console.error('Unable to fetch Account Id');
                }

            }).catch(error => {
                console.error("Error in fetching account Id: ", error);
            })
        }


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

    /**
    * function for handling showing banner
    */
    handleBannerShow(colour) {
        switch (colour) {
            case 'Orange':
                this.orange = true;

                break;
            case 'Blue':
                this.blue = true;

                break;
            case 'Red':
                this.red = true;

                break;

            default:
                break;
        }

    }


    /**
    * helper function that checks if we are in site preview mode
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