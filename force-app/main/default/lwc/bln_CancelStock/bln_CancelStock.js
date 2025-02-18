import { LightningElement, api, wire } from 'lwc';
import { getFocusedTabInfo, closeTab } from 'lightning/platformWorkspaceApi';
import { CurrentPageReference } from 'lightning/navigation';
import cancelStock from '@salesforce/apex/BLN_StockReservationController.cancelStockCallout';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Bln_CancelStock extends LightningElement {
    @api recordId;

    orderProductIds = [];

    @wire(CurrentPageReference)
    getPageReference(pageRef) {
        if(pageRef && pageRef.state.c__recordId) {
            this.recordId = pageRef.state.c__recordId;
        }
        
        this.orderProductIds = this.recordId;
        cancelStock({ orderItemId: this.orderProductIds})
        .then((result) => {
            console.log(JSON.parse(result));
            if(result)
            {
                let resultObj = JSON.parse(result);
                if(resultObj)
                    {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: resultObj.Message,
                                variant: resultObj.Status,
                            })
                        );
                    }
                }
            getFocusedTabInfo().then((tabInfo) => {
                closeTab(tabInfo.tabId);
            });
        })
        .catch((error) => {
            console.log(error);
            getFocusedTabInfo().then((tabInfo) => {
                closeTab(tabInfo.tabId);
            });
        });
    }
}