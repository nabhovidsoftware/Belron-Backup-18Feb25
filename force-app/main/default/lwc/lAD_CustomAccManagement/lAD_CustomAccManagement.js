/** @description :  This component is used for Acccout management on portal, this display active cart records with button take ownership.
*   @Story :        FOUK-10651; 
*   @author:        (punam.patil@pwc.com (IN))
*  */
import { LightningElement, track, api,wire } from 'lwc';
import getMembers from '@salesforce/apex/lAD_CustomAccManagementController.getMembers';
import getCarts from '@salesforce/apex/lAD_CustomAccManagementController.getCarts';
import updateCartOwner from '@salesforce/apex/lAD_CustomAccManagementController.updateCartOwner';

import updateCartStatus from '@salesforce/apex/lAD_CustomAccManagementController.updateCartStatus';
import getActiveCartForUser from '@salesforce/apex/lAD_CustomAccManagementController.getActiveCartForUser';
import Buyer from '@salesforce/customPermission/LAD_Laddaw_Buyer_Credit_Info';
import Id from '@salesforce/user/Id';
import { NavigationMixin } from 'lightning/navigation';
import { effectiveAccount } from 'commerce/effectiveAccountApi';
import getAccId  from '@salesforce/apex/lAD_CustomAccManagementController.getAccId';
import { refreshApex } from '@salesforce/apex';

const USER_COLUMNS = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'Email', fieldName: 'Email' },
    { label: 'Username', fieldName: 'Username' },
    { label: 'FirstName', fieldName: 'FirstName' },
    { label: 'LastName', fieldName: 'LastName' },
    { label: 'IsActive', fieldName: 'IsActive' },
    
];

const CART_COLUMNS = [
    { label: 'Account', fieldName: 'AccountName' },
    { label: 'Owner', fieldName: 'OwnerName' },
    { label: 'Grand Total Amount', fieldName: 'GrandTotalAmount', type: 'currency', cellAttributes :{alignment:'left'}  },
    { type: 'button', cellAttributes :{alignment:'center'},
            typeAttributes: {
                label: ' Take Ownership',
                name: 'viewCart',
                variant: 'brand-outline',
            }
    }        
];


export default class LAD_CustomAccManagement extends NavigationMixin(LightningElement) {

   // @api recordId; // The Account ID
    @api accountId;
    @track users = [];
    @track carts = [];
    @track showModal = false;
    userColumns = USER_COLUMNS;
    cartColumns = CART_COLUMNS;
    confirm = 0;

    @track isModalOpen = false;
    selectedCartId;
    selectedCartRecord;
    accId= this.accountId;
    isHidden = false;

    get buyerUser() {
        return Buyer;
    }
    connectedCallback()
    {   
        if ( this.buyerUser) {
            this.isHidden= true;
        }
         getAccId({userid:Id})
         .then(result => {

            
            this.accountId=result;
          console.log('RECORD ID1>>>'+ this.accountId);
          refreshApex(this.fetchDetailsCart());
            this.fetchDetails();
            //this.fetchDetailsCart();
         })
         .catch(error=>{
             console.log(error);
         })
    }

    fetchDetails(){
        console.log('RECORD ID2>>>'+ this.accountId);
        let variable = effectiveAccount.accountId!=null & effectiveAccount.accountId!=undefined? effectiveAccount.accountId:this.accountId;
        console.log('variable : '+variable);
       
        getMembers( { accountId: variable })
        .then(data => {
          console.log('RECORD ID3>>>'+ this.accountId);
        if (data) {
            
            this.users = data;
            console.log('Get member data : '+ JSON.stringify(data));
        } else if (error) {
            console.error(error);
        }

         })
         .catch(error => {
            console.log(error);
        });

    }

    fetchDetailsCart(){
        let variable = effectiveAccount.accountId!=null & effectiveAccount.accountId!=undefined? effectiveAccount.accountId:this.accountId;
        console.log('variable in cart : '+variable);
        getCarts({ accountId: variable, userId: Id })
        .then(data => {
           console.log('variable2 : '+variable);
           console.log('RECORD ID4>>>'+ this.accountId);
       if (data) {
           console.log('Cart data : '+ JSON.stringify(data));
           this.carts = data;
        //     this.carts = data.map(cart => ({ 
        //        ...cart,
        //        OwnerName: cart.Owner.Name // Adding Owner Name to display

        //    }));
       } else if (error) {
           console.error(error);
       }
       })
       .catch(error => {
           console.log(error);
       });
    }
    // @wire(getMembers, { accountId: '$recordId' })
    // wiredUsers({ error, data }) {

    //     console.log('RECORD ID>>>'+ this.recordId);
    //     if (data) {
            
    //         this.users = data;
    //         console.log('Get member data : '+ JSON.stringify(data));
    //     } else if (error) {
    //         console.error(error);
    //     }
    // }

    // @wire(getCarts, { accountId: '$recordId' })
    // wiredCarts({ error, data }) {
    //     if (data) {
    //         console.log('Cart data : '+ JSON.stringify(data));
    //         this.carts = data.map(cart => ({
    //             ...cart,
    //             OwnerName: cart.Owner.Name // Adding Owner Name to display

    //         }));
    //     } else if (error) {
    //         console.error(error);
    //     }
    // }

   
    handleRowAction(event) {
        const action = event.detail.action.name;
        const row = event.detail.row;
        this.selectedCartId = row.Id;
        this.selectedCartRecord = row;
        this.openModal();
    }

    openModal() {
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
    }

    changeOwner() {
        getActiveCartForUser()
            .then(activeCart => {
                console.log('active cart Id'+activeCart.length);
                if (activeCart.length != 0) {
                    updateCartStatus({ cartId: activeCart[0].Id, status: 'PendingDelete' })
                        .then(() => this.updateOwner())
                        .catch(error => console.error('Error updating active cart status', error));
                } else {
                    this.updateOwner();
                }
            })
            .catch(error => console.error('Error getting active cart for user', error)
            //console.error('activeCart ', JSON.stringify(activeCart));
        );
    }

    // changeOwnerDirectly() {
    //     this.updateOwner();
    // }

    updateOwner() {
        const newOwnerId = Id;

        updateCartOwner({ cartId: this.selectedCartId, newOwnerId: newOwnerId }) // Replace with logged-in user ID
            .then(() => {
                //this.loadCartRecords(); // Refresh records after update
                this.closeModal();
                //window.location.reload();
                const pageReference = {
                
                                    type: 'comm__namedPage',
                                    attributes: {
                                        name: 'Current_Cart'
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
            })
            .catch(error => {
                console.error('Error changing cart owner', error);
            });
    }


    

}