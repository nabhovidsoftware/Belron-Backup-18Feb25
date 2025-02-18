/** @description :  This component is used for display Return ownership button on cart page of portal, used to give cart back to cart owner.
*   @Story :        FOUK-10652; 
*   @author:        (punam.patil@pwc.com (IN))
*  */


import { LightningElement,track,api } from 'lwc';
import updateCartOwner from '@salesforce/apex/lAD_CustomAccManagementController.updateCartOwner';
import getcartCreatedBy from '@salesforce/apex/lAD_CustomAccManagementController.getcartCreatedBy';
import getActiveCartForUser from '@salesforce/apex/lAD_CustomAccManagementController.getActiveCartForUser';
import updateCartStatusReturn from '@salesforce/apex/lAD_CustomAccManagementController.updateCartStatusReturn';
import { NavigationMixin } from 'lightning/navigation';
import Buyer from '@salesforce/customPermission/LAD_Laddaw_Buyer_Credit_Info';
import BuyerManager from '@salesforce/customPermission/LAD_Laddaw_Buyer_Manager_Credit_Info';
import InternalPortal from '@salesforce/customPermission/LAD_Laddaw_Internal_Portal';
import Toast from 'lightning/toast';

export default class LAD_CartReturnButton extends NavigationMixin(LightningElement) {
    @track isModalOpen = false;
    @api cartId;
    createdByOwnerId;
    count;
    isHidden = true;

    get internalUser() {
        return InternalPortal;
    }

    get buyerUser() {
        return BuyerManager;
    }
    connectedCallback() {
        // if (!this.internalUser && this.buyerUser) {
        //     this.isHidden= false;
        // }
        console.log('this.cartId here:'+this.cartId);
        this.count=0;
        getcartCreatedBy({cartid: this.cartId })
        .then(result=>{
            console.log('count here1:'+this.count);
            console.log('getcartCreatedBy:'+result.CreatedById);
            console.log('getcartOwnerId:'+result.OwnerId);
            if(result.CreatedById != result.OwnerId)
            {
                console.log('Inside If');
                this.count=1;
            }
            console.log('count here2:'+this.count);
            if ((this.internalUser || this.buyerUser ) && this.count==1) {
                this.isHidden= false;
            }
        });

       // this.checkOwner();

        
        console.log('this.internalUser: '+this.internalUser+' this.buyerUser: '+this.buyerUser);
       
    }

    // checkOwner()
    // {
    //     console.log('this.cartId here2:'+this.cartId);
        
    // }
    handleButtonClick() {
        this.isModalOpen = true;
    }

    // Close the modal
    closeModal() {
        this.isModalOpen = false;
    }

    // Confirm the cart return
    confirmReturn() {
        // Assume we have the current cartId and createdByOwnerId
        getActiveCartForUser()
            .then(activeCart => {
                console.log('active cart Id'+activeCart.length);
                if (activeCart.length != 0) {
                        updateCartStatusReturn({cartId: activeCart[0].Id})
                        .then(result=> 
                            {console.log('active cart Id value'+activeCart[0].Id);
                            this.closeModal();
                            Toast.show({
                                label: 'Success',
                                message:'You have successfully returned the Cart to its original owner.',
                                mode: 'dismissible',
                                variant: 'Success'
                            }, this);
                            this.redirectToAccountManagement();    
                        }
                       )
                         .catch(error => console.error('Error updating active cart status', error));
                } else {
                    //this.cartreturn();
                    console.log('error');
                }
            })
            .catch(error => console.error('Error getting active cart for user', error)
            //console.error('activeCart ', JSON.stringify(activeCart));
        );
        
        
    }

    // cartreturn()
    // {
    //     console.log('cartId here:'+this.cartId);
    //         getcartCreatedBy({cartid: this.cartId })
    //              .then(result=>{
    //                 console.log('getcartCreatedBy:'+result);
    //                 this.createdByOwnerId=result.CreatedById;
    //                 console.log('newOwnerId:'+ this.createdByOwnerId);
    //                 this.cartUpdate();
    //     });
    //     console.log('newOwnerId 2 :'+ this.createdByOwnerId);
    // }

    cartUpdate()
    {
        updateCartOwner({ cartId: this.cartId , newOwnerId: this.createdByOwnerId })
        .then(() => {
            this.closeModal();
            Toast.show({
                label: 'Success',
                message:'You have successfully returned the Cart to its original owner.',
                mode: 'dismissible',
                variant: 'Success'
            }, this);
            this.redirectToAccountManagement();
        })
        .catch(error => {
            console.error('Error changing cart owner', error);
        });
    }

    // Redirect to the Account Management page
    redirectToAccountManagement() {
        const pageReference = {
                
            type: 'comm__namedPage',
            attributes: {
                name: 'Account_Management__c'
            }
        
    };
    this[NavigationMixin.GenerateUrl](pageReference)
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
}