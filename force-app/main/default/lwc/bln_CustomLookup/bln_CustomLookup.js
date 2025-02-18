import { LightningElement, api, wire } from 'lwc';
import fetchLookupData from '@salesforce/apex/BLN_FetchJobRequestCases.getRelatedJobs';
import iconName from '@salesforce/label/c.BLN_IconName';

const DELAY = 300;

export default class Bln_Customlookup extends LightningElement {
    @api iconName = iconName;
    @api accountId;
    lstResult = [];
    hasRecords = true;
    searchKey = '';
    isSearchLoading = false;
    delayTimeout;
    selectedRecord = {};

    // wire function property to fetch search record based on user input
    @wire(fetchLookupData, { accountId: '$accountId', searchKey: '$searchKey' })
    searchResult(value) {
        const { data, error } = value;
        this.isSearchLoading = false;
        if (data) {
            this.hasRecords = data.length == 0 ? false : true;
            this.lstResult = JSON.parse(JSON.stringify(data));
        }
        else if (error) {
            console.log('error--->' + JSON.stringify(error));
        }
    };
    // update searchKey property on input field change  
    handleKeyChange(event) {

        this.isSearchLoading = true;
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        this.delayTimeout = setTimeout(() => {
            this.searchKey = searchKey;
        }, DELAY);
    }
    // method to toggle lookup result section on UI 
    toggleResult(event) {
        const lookupInputContainer = this.template.querySelector('.lookupInputContainer');
        const clsList = lookupInputContainer.classList;
        const whichEvent = event.target.getAttribute('data-source');
        switch (whichEvent) {
            case 'searchInputField':
                clsList.add('slds-is-open');
                break;
            case 'lookupContainer':
                clsList.remove('slds-is-open');
                break;
        }
    }
    // method to clear selected lookup record  
    handleRemove() {
        this.searchKey = '';
        this.selectedRecord = {};
        this.lookupUpdatehandler('');
        const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
        searchBoxWrapper.classList.remove('slds-hide');
        searchBoxWrapper.classList.add('slds-show');

        const pillDiv = this.template.querySelector('.pillDiv');
        pillDiv.classList.remove('slds-show');
        pillDiv.classList.add('slds-hide');
    }

    handelSelectedRecord(event) {

        var objId = event.target.getAttribute('data-recid');
        this.selectedRecord = this.lstResult.find(data => data.Id === objId);

        this.lookupUpdatehandler(this.selectedRecord);
        this.handelSelectRecordHelper();
    }

    handelSelectRecordHelper() {
        this.template.querySelector('.lookupInputContainer').classList.remove('slds-is-open');
        const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
        searchBoxWrapper.classList.remove('slds-show');
        searchBoxWrapper.classList.add('slds-hide');
        const pillDiv = this.template.querySelector('.pillDiv');
        pillDiv.classList.remove('slds-hide');
        pillDiv.classList.add('slds-show');
    }
    // send selected lookup record to parent component using custom event
    lookupUpdatehandler(value) {
        const oEvent = new CustomEvent('lookupupdate',
            {
                'detail': { selectedRecord: value }
            }
        );
        this.dispatchEvent(oEvent);
    }


}