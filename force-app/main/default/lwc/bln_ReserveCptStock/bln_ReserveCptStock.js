import { LightningElement, api, wire } from 'lwc';
import { setTabLabel, getFocusedTabInfo, closeTab } from 'lightning/platformWorkspaceApi';
import { CurrentPageReference } from 'lightning/navigation';
import sendRequest from '@salesforce/apex/BLN_StockReservationController.reserveStockCallout';
import APIErrorMessage from '@salesforce/label/c.BLN_StockRequisitionFailed';
import ReserveCPTStock from '@salesforce/label/c.BLN_ReserveCPTStock';
import ReserveCPTSuccess from '@salesforce/label/c.BLN_ReserveCPTSuccess';
import CPTSuccessCode from '@salesforce/label/c.BLN_StatusValue';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Bln_ReserveCptStock extends LightningElement {
@api recordId;
@api tabId;
@api responseAPISuccess;
errorMsg = APIErrorMessage;
ReserveCPTStock = ReserveCPTStock;
ReserveCPTSuccess = ReserveCPTSuccess;
CPTSuccessCode = CPTSuccessCode;

@wire(CurrentPageReference)
getPageReference(pageRef) {
    if(pageRef && pageRef.state.c__recordId) {
        this.recordId = pageRef.state.c__recordId;
    }
    if(!this.recordId) {
            getFocusedTabInfo().then((tabInfo) => {
                closeTab(tabInfo.tabId);
            }).catch(function(error) {
                console.log(error);
            });
        }
    }

    connectedCallback(){
    getFocusedTabInfo().then((tabInfo) => {
        this.tabId = tabInfo.tabId;
        setTabLabel(this.tabId, this.ReserveCPTStock);
    });

    if(this.recordId){
        sendRequest({orderItemId: this.recordId})
        .then((result) => {
            if(result){
                if(result.items[0]?.errorCode == CPTSuccessCode){
                    this.showToast('Success', this.ReserveCPTSuccess, 'success');
                } else {
                    this.showToast('Error', this.errorMsg, 'error');
                }
            }
            else{
                this.showToast('Error', this.errorMsg , 'Error');
            }
        }).catch((error) => {
            this.showToast('Error', this.errorMsg, 'Error');
        }).finally(() => {
                getFocusedTabInfo().then((tabInfo) => {
                    closeTab(tabInfo.tabId);
                });
            });
        }
    }

    showToast(title, detail, variant){
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: detail,
                variant: variant,
            })
        );
    }
}