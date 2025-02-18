import { LightningElement, track, api, wire } from 'lwc';
import assistedPayment from '@salesforce/apex/BLN_AssistedPaymentsController.generatedHexDigestkey';
import { NavigationMixin } from 'lightning/navigation';
import { FlowAttributeChangeEvent} from 'lightning/flowSupport';
import { IsConsoleNavigation, getFocusedTabInfo, closeTab } from 'lightning/platformWorkspaceApi';


export default class Bln_AssistedPayments extends NavigationMixin(LightningElement) {
    @track height = '700px';
    @track referrerPolicy = 'no-referrer';
    @track sandbox = 'allow-same-origin allow-scripts allow-popups allow-forms';
    @track url = '';
    @track width = '1200px';
    @api paymentId ;
    @api finishFlow;


    connectedCallback(){
        console.log('this.paymentId is : ',this.paymentId);
        assistedPayment({paymentId : this.paymentId})
        .then(result=>{
          console.log('result is : ',result);
          this.url = result;
          console.log('url is : ',JSON.stringify(this.url));
        })
        .catch(error=>{
            console.log('error is ---->',error);
        });
        console.log('url is : ',JSON.stringify(this.url));
     //this.url = 'https://lb.Belron.sycurioha.com/semafone/service/capture/getBelronSmartpaySPayment.html?clientReference=TBC&semafoneMode=MANUAL_CR&gatewayId=SmartpaySPayment&tenantId=R&clientId=1&accountId=735913&principle=RTPFNPA&licenseCode=TBC&responseType=web&transactionType=PaymentAuthSettlePanSecurityCode&responseURL=https://lb.Belron.sycurioha.com/semafone/service/capture/getBelronSmartpaySPaymentResults.html&amount=99.99&currency=826&returnBin=false&postForwardURL=https://pcipal.belronuk.com/CardPayment_prduk/PCIPalResultsCallbackWS.jsp&digest='+this.digestKey;
    }

    @wire(IsConsoleNavigation) isConsoleNavigation;

    async closeTab() {
        try {
            if (this.isConsoleNavigation) {
                const { tabId } = await getFocusedTabInfo();
                await closeTab(tabId);
            }
        } catch (error) {
            console.error('Error closing tab:', error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'There was an error closing the tab.',
                    variant: 'error',
                }),
            );
        }
    }
    async  handleOk(){
        console.log('this.paymentId',this.paymentId);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.paymentId,
                objectApiName: 'BLN_Payment__c',
                actionName: 'view'
            } 
        });
        //this.dispatchEvent(new FlowAttributeChangeEvent("finishFlow",true));
        await this.closeTab()
        
        
    }
}