import { LightningElement, api, track, wire } from 'lwc';
import amendOrderController from '@salesforce/apex/LAD_AmendOrderHandler.amendOrderController';
import orderAmendmentViabilityDetailsPage from '@salesforce/apex/LAD_AmendOrderHandler.orderAmendmentViabilityDetailsPage';
import Toast from 'lightning/toast';
import USERID from '@salesforce/user/Id';
import { navigate, NavigationContext, NavigationMixin } from 'lightning/navigation';
import { effectiveAccount } from 'commerce/effectiveAccountApi';
import doesCartExist from '@salesforce/apex/LAD_AmendOrderHandler.doesCartExist';

const cartPage = {
    type: 'comm__namedPage',
    attributes: {
        name: 'Current_Cart',
    },
};

export default class Lad_amendOrder extends NavigationMixin(LightningElement) {
    @api orderId;
    @track isLoading = false;
    @track amendViable = false;


    @wire(NavigationContext)
    navContext;


    handleClick() {
        
        this.checkForexistingOrder()

    }

    checkForexistingOrder(){
        //this.handleCartFromOrder()
        doesCartExist({userId:USERID,effectiveAccountId:effectiveAccount.accountId})
        .then(result=>{
                console.log('Cart Status ', result);
            if(result==true){
                Toast.show({
                    label: 'Error',
                    message: 'There is an existing Order corrosponding to your user for this Account. Please empty Cart to amend this order.',
                    mode: 'dismissible',
                    variant: 'Error',
                })
            }else{
                this.handleCartFromOrder();
            }
        })
        .catch(error=>{
            console.log(error);
        })

    }

    connectedCallback(){
        console.log('this.amendViable0',this.amendViable);
        console.log('Order Id' + this.orderId);
        orderAmendmentViabilityDetailsPage({ orderSummaryId: this.orderId })
            .then(result => {
                console.log('VIABILITY ' + result);
                this.amendViable = result;
                console.log('this.amendViable', this.amendViable);

        }).catch(error=>{
            console.log(error);
        })

    }

    async amendViabilityCheck() {
        try {
            const response = await orderAmendmentViabilityDetailsPage({ orderSummaryId: this.orderId });
            this.amendViable = response;
            return this.amendViable;
        } catch (error) {
            console.error(error);
            return false;
        }

    }

    async handleCartFromOrder() {
        this.isLoading = true;
        console.log('BEFORE VIABILITY');
        const response = await this.amendViabilityCheck();
        console.log('AFTER VIABILITY', this.amendViable);

        console.log('RESPONSE ' + response);
        if (this.amendViable) {
            console.log('INSIDE ORDER VIABLE');
            let paramters = {
                orderSummaryId: this.orderId,
                userId: USERID,
                isAmend: true,
                isReorder: false,
            }
            amendOrderController({ orderSummaryDetails: paramters })
                .then(result => {
                    console.log('NAVIGATING NOW');

                    this.isLoading = false;
                    this.handleNavigate();
                }).catch(error => {
                    this.isLoading = false;

                    console.log(JSON.stringify(error));
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

    handleNavigate() {
        this[NavigationMixin.GenerateUrl](cartPage)
            .then(url => {
                console.log('Generated URL:', url);

                // Redirect to the generated URL
                window.open(url, "_self");
            })
            .catch(error => {
                console.error('Error generating URL:', error);
            });
    }
}