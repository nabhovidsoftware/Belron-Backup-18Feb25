/** @description :  This component is used to show the top 5 most frequently ordered products for a specific account.
*   @Story :        FOUK-9940
*   @author:        binayak.debnath@pwc.com (IN)
*   @CreatedDate:   04-09-2024
*/

import { LightningElement, track } from 'lwc';
import { mockProducts } from './lad_FrequentlyOrderedProduct_Mock';
import fetchFreqOrderedProducts from '@salesforce/apex/LAD_FrequentlyOrderedHandler.fetchFreqOrderedProducts';
import getAccId from '@salesforce/apex/LAD_ReturnAssociatedLocationDetails.getAccId';
import { effectiveAccount } from 'commerce/effectiveAccountApi';
import { NavigationMixin } from 'lightning/navigation';
import communityId from "@salesforce/community/Id";
import Id from '@salesforce/user/Id';
import Toast from 'lightning/toast';


export default class Lad_FrequentlyOrderedProduct extends NavigationMixin(LightningElement) {
    @track products;
    accountId;

    connectedCallback() {
        console.log('COMMUNITY ID----> ' + communityId);
        if (this.isInSitePreview()) {
            console.log('in insite')
            this.products = mockProducts;
        }
        else {
            getAccId({ userid: Id })
                .then(result => {
                    this.accountId = result;
                    console.log("account id=" + result);
                    this.fetchFrequentProducts();
                })
                .catch(error => {
                    console.log('ERROR IN Account ' + JSON.stringify(error));
                })

        }
    }

    fetchFrequentProducts() {
        let variable = effectiveAccount.accountId !== null && effectiveAccount.accountId !== undefined ? effectiveAccount.accountId : this.accountId;

        fetchFreqOrderedProducts({ effectiveAccountId: variable, communityId: communityId })
            .then(result => {
                if (result) {
                    this.products = result;
                } else {
                    Toast.show({
                        label: 'Error',
                        message: 'Unable to fetch Frequently Ordered Products. Please check error logs for details',
                        mode: 'sticky',
                        variant: 'error'
                    }, this);
                }
            })
            .catch(error => {
                console.error('Error in Fetch Products ---> ' + error);
            })
    }

    handleClick(event) {
        let productId = event.target.dataset.productId;
        console.log(productId);
        const pageReference = {
            type: 'standard__recordPage',
            attributes: {
                recordId: productId,
                objectApiName: 'Product2',
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