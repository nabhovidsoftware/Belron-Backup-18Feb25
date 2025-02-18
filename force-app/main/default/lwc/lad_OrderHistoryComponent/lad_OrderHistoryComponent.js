/** @description :  This component is used to Order History, navigate to Order Details of specific Orders and to Reorder specific Orders
*   @Story :        FOUK-9870; FOUK-9872
*   @author:        (binayak.debnath@pwc.com (IN))
*   @CreatedDate:   06-09-2024
*/
import { LightningElement, track, wire } from 'lwc';
import { MOCKorderSummaryProducts } from './lad_OrderHistoryComponent_Mock';
import fetchOrderDetails from '@salesforce/apex/LAD_OrderHistoryHandler.fetchOrderDetails';
import getAccId from '@salesforce/apex/LAD_ReturnAssociatedLocationDetails.getAccId';
import executeReorder from '@salesforce/apex/LAD_ReOrderHandler.executeReorder';
import removeDateFormat from '@salesforce/resourceUrl/RemoveDateFormatStyle';
import { loadStyle } from 'lightning/platformResourceLoader';
import { effectiveAccount } from 'commerce/effectiveAccountApi';
import { NavigationMixin, navigate, NavigationContext } from 'lightning/navigation';
import communityId from "@salesforce/community/Id";
import Id from '@salesforce/user/Id';
import Toast from 'lightning/toast';
import doesCartExist from '@salesforce/apex/LAD_AmendOrderHandler.doesCartExist';
import LAD_OrderHistoryComponent_ProductDelayedMessage from '@salesforce/label/c.LAD_OrderHistoryComponent_ProductDelayedMessage'
const cartPage = {
    type: 'comm__namedPage',
    attributes: {
        name: 'Current_Cart',
    },
};

export default class Lad_OrderHistoryComponent extends NavigationMixin(LightningElement) {

    label={
        LAD_OrderHistoryComponent_ProductDelayedMessage
    }

    isLoading = false;
    accountId;


    //Filter and Sorting variables
    @track startDate;
    @track endDate;
    @track currentSorting = 'recent';

    @track errorMessage;

    //Search variables
    @track queryTerm;

    //Order Summary Card variables
    orderSummaryList_MASTER;
    @track orderSummaryList;

    //pagination
    @track paginatedRecords = [];
    recordsPerPage = 10;
    currentPage = 1;
    //totalPages = 1;


    @wire(NavigationContext)
    navContext;

    connectedCallback() {
        if (this.isInSitePreview()) {
            this.orderSummaryList_MASTER = MOCKorderSummaryProducts;
            this.orderSummaryList = JSON.parse(JSON.stringify(MOCKorderSummaryProducts));
            // this.totalPages = Math.ceil(this.orderSummaryList?.length / this.recordsPerPage);
            this.updatePagination();
        }
        else {

            this.isLoading = true;
            getAccId({ userid: Id })
                .then(result => {
                    this.accountId = result;
                    console.log("account id=" + result);
                    let variable = effectiveAccount.accountId !== null && effectiveAccount.accountId !== undefined ? effectiveAccount.accountId : this.accountId;

                    this.fetchOrdersHandler(variable, null, null);
                })
                .catch(error => {
                    this.isLoading = false;
                    console.log('ERROR IN Account' + error);
                })
        }
    }

    renderedCallback() {
        Promise.all([
            loadStyle(this, removeDateFormat) //specified filename
        ]).then(() => {
            window.console.log('Files loaded.');
        }).catch(error => {
            window.console.log("Error " + error.body.message);
        });
    }

    async fetchOrdersHandler(effectiveAccountId, startDate, endDate) {
        this.isLoading = true;
        let SearchParameters = {
            effectiveAccountId: effectiveAccountId,
            startDate: startDate,
            endDate: endDate,
            communityId: communityId,
        }

        try {
            let result = await fetchOrderDetails({ searchDetails: SearchParameters })
            this.isLoading = false;

            console.log('ORDER LIST---> ' + JSON.stringify(result));
            if (result.status === 'Success') {
                this.orderSummaryList_MASTER = result.orderDetails;
                this.orderSummaryList = JSON.parse(JSON.stringify(result.orderDetails));

                // this.totalPages = Math.ceil(this.orderSummaryList?.length / this.recordsPerPage);
                this.updatePagination();
                return 'Success';
            }
            else {
                Toast.show({
                    label: 'Error',
                    message: 'Unable to fetch Order List. Error: ' + result.message,
                    mode: 'sticky',
                    variant: 'error'
                }, this);
                return 'Failure';
            }


        } catch (error) {
            this.isLoading = false;
            console.log('ERROR IN Account' + JSON.stringify(error));
            return 'Failure';
        }
    }

    /**
    * Handle Start Date change
    */
    handleStartDate(event) {
        let inputDate = event.target.value;

        console.log('START DATE--> ', inputDate);
        if (inputDate) {
            if (this.endDate && new Date(inputDate) > new Date(this.endDate)) {
                //throw Error for start date more than end date
                console.log('start date more than end date');
                this.errorMessage = 'Please select a start date equal to or before the selected end date';
                this.startDate = null;

                let dateElement = this.template.querySelector(`[data-id="start"]`);
                dateElement.value = null;
            }
            else {
                console.log('in right start');
                this.startDate = inputDate;
                this.errorMessage = null;
            }
        }
    }

    /**
    * Handle End Date change
    */
    handleEndDate(event) {
        let inputDate = event.target.value;

        console.log('END DATE--> ', inputDate);
        if (inputDate) {
            if (this.startDate && new Date(inputDate) < new Date(this.startDate)) {
                //throw Error for end date less than start date
                console.log('end date less than start date');
                this.errorMessage = 'Please select an end date equal to or after the selected start date';
                this.endDate = null;

                let dateElement = this.template.querySelector(`[data-id="end"]`);
                dateElement.value = null;
            }
            else {
                console.log('in right end');
                this.endDate = inputDate;
                this.errorMessage = null;
            }
        }

    }

    get showError() {
        if (this.errorMessage) {
            return true;
        }
        return false;
    }

    /**
    * Getter to control Apply button disability
    */
    get disableFilterApply() {
        if (this.startDate && this.endDate) {
            return false;
        }
        else {
            return true;
        }

    }

    /**
    * Getter to control Search functionality
    */
    get disableSearch() {
        if (this.queryTerm?.length > 0) {
            return false;
        }
        else {
            return true;
        }

    }

    /**
    * Getter for sorting options
    */
    get sortingOptions() {
        return [
            {
                label: 'Sort by most Recent Order',
                value: 'recent'
            },
            {
                label: 'Sort by Oldest Order',
                value: 'oldest',
            }
        ];
    }

    /**
    * Getter for itemCountMessage
    */
    get itemCountMessage() {

        if (this.orderSummaryList?.length > 0) {
            if (this.orderSummaryList?.length < 250) {
                return `${this.orderSummaryList.length} items`;
            }
            else {
                return 'List too large to display. Please use the filter to limit the number of results.';
            }
        }
        else {
            return '0 items';
        }

    }

    /**
    * Handles Apply button click on filter
    */
    async handleApplyDateFilter() {
        this.isLoading = true;
        try {
            this.currentPage = 1;
            if (this.startDate && this.endDate) {

                //this.orderSummaryList = JSON.parse(JSON.stringify(MOCKorderSummaryProducts)).filter(item => item.OrderedDate >= this.startDate && item.OrderedDate <= this.endDate);
                let variable = effectiveAccount.accountId !== null && effectiveAccount.accountId !== undefined ? effectiveAccount.accountId : this.accountId;
                let response = await this.fetchOrdersHandler(variable, this.startDate, this.endDate);
                console.log('RESPONSE ' + response);
                console.log('INSIDE RESPONSE');
                if (this.orderSummaryList.length === 0) {
                    this.errorMessage = 'ߚ뎯 orders found';
                }
                this.handleSortData();
                this.isLoading = false;
                return 'Updated records';

            }
            else {
                this.orderSummaryList = JSON.parse(JSON.stringify(this.orderSummaryList_MASTER));
                console.log('completed assignment');
                this.handleSortData();
                this.isLoading = false;
                return 'Old records';

            }

        }
        catch (error) {
            console.error(error);
            this.isLoading = false;
        }

    }

    /**
    * Handles Reset button click on filter
    */
    async handleResetDateFilter() {
        this.isLoading = true;
        try {
            this.currentPage = 1;
            this.startDate = null;
            this.endDate = null;
            let startDateElement = this.template.querySelector(`[data-id="start"]`);
            let endDateElement = this.template.querySelector(`[data-id="end"]`);
            startDateElement.value = null;
            endDateElement.value = null;
            this.errorMessage = null;
            //this.orderSummaryList = JSON.parse(JSON.stringify(MOCKorderSummaryProducts));
            let variable = effectiveAccount.accountId !== null && effectiveAccount.accountId !== undefined ? effectiveAccount.accountId : this.accountId;
            let response = await this.fetchOrdersHandler(variable, this.startDate, this.endDate);
            this.handleSortData();
            if (this.orderSummaryList.length === 0) {
                this.errorMessage = 'ߚ뎯 orders found';
            }
            this.isLoading = false;

        } catch (error) {
            console.error(error);
            this.isLoading = false;
        }
    }


    /**
    * Handles Sorting of Order Summaries
    */
    handleSortChange(event) {
        this.isLoading = true;
        try {
            let selectedSorting = event.target.value;
            console.log(selectedSorting);
            this.currentSorting = selectedSorting;
            this.handleSortData();
            this.isLoading = false;
        } catch (error) {
            console.error(error);
            this.isLoading = false;
        }

    }

    /**
    * Function for sorting
    */
    handleSortData() {
        if (this.currentSorting === 'recent') {
            this.orderSummaryList.sort((a, b) => new Date(b.OrderedDate) - new Date(a.OrderedDate));
        } else if (this.currentSorting === 'oldest') {
            this.orderSummaryList.sort((a, b) => new Date(a.OrderedDate) - new Date(b.OrderedDate));

        }
        //this.totalPages = Math.ceil(this.orderSummaryList?.length / this.recordsPerPage);
        this.updatePagination();
    }

    /**
    * Handles Clear Search Bar
    */
    async handleClear(event) {
        this.isLoading = true;
        try {
            if (event.target.value.length !== 0) {
                //Necessary duplication of code in if and else block to only enforce filter and sorting in events where
                //Enter is clicked for search or cross is clicked to clear. If below to function calls are placed outside the loop
                //filters and sorting will be enforced for every change in search field.
                this.queryTerm = event.target.value;

                /* const response = await this.handleApplyDateFilter();
                console.log(response);

                console.log('ENTER PRESSED', this.queryTerm);
                let searchedObjectArray = this.orderSummaryList.filter(item => item.OrderSummaryNumber === this.queryTerm);
                if (searchedObjectArray.length !== 0) {
                    this.orderSummaryList = searchedObjectArray;
                }
                else {
                    this.errorMessage = 'ߚ뎯 orders found';
                    this.orderSummaryList = [];
                } */
            }
            else if (event.target.value.length === 0) {
                this.currentPage = 1;

                console.log('IN DE-SEARCH')
                this.queryTerm = null;
                this.errorMessage = null;
                //const response = await this.handleApplyDateFilter();
                this.orderSummaryList = JSON.parse(JSON.stringify(this.orderSummaryList_MASTER));
                this.handleSortData();
            }
            this.isLoading = false;
        } catch (error) {
            console.error(error);
            this.isLoading = false;
        }

    }

    /**
    * Handles Search
    */
    handleSearch() {
        this.currentPage = 1;

        let searchedObjectArray = this.orderSummaryList.filter(item => item.OrderSummaryNumber === this.queryTerm);
        if (searchedObjectArray.length !== 0) {
            this.orderSummaryList = searchedObjectArray;

        }
        else {
            this.errorMessage = 'No orders found';
            this.orderSummaryList = [];
        }

        // this.totalPages = Math.ceil(this.orderSummaryList?.length / this.recordsPerPage);
        this.updatePagination();
    }

    /**
    * Handles View Details functionality
    */
    handleViewDetails(event) {
        let orderSummaryId = event.target.dataset.orderId;
        console.log(orderSummaryId);
        const pageReference = {
            type: 'standard__recordPage',
            attributes: {
                recordId: orderSummaryId,
                objectApiName: 'OrderSummary',
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
    * handles Pagination
    */
    updatePagination() {

        if (this.recordsPerPage >= this.orderSummaryList.length) {
            this.paginatedRecords = this.orderSummaryList;
        }
        else {
            const start = (this.currentPage - 1) * this.recordsPerPage;
            if (start > (this.orderSummaryList.length - 1)) {
                start = 0;
            }
            const end = start + this.recordsPerPage;

            this.paginatedRecords = this.orderSummaryList.slice(start, end);
        }

    }

    /**
    * handles Next Page
    */
    nextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;

            this.updatePagination();
            window.scrollTo(0, 0);
        }
    }

    /**
    * handles Previous Page
    */
    previousPage() {
        if (this.currentPage > 1) {
            this.currentPage--;

            this.updatePagination();
            window.scrollTo(0, 0);
        }
    }

    get totalPages() {
        return Math.ceil(this.orderSummaryList?.length / this.recordsPerPage) > 0 ? Math.ceil(this.orderSummaryList?.length / this.recordsPerPage) : 1
    }

    get isFirstPage() {
        return this.currentPage === 1;
    }

    get isLastPage() {
        return this.currentPage === this.totalPages;
    }


    /**
    * handles Reorder Functionality
    */
    async handleReorder(event) {
        event.preventDefault();
        try {
            let orderSummaryId = event.target.dataset.orderId;
            let variable = effectiveAccount.accountId !== null && effectiveAccount.accountId !== undefined ? effectiveAccount.accountId : this.accountId;

            this.isLoading = true;
            const existingCart = await doesCartExist({ userId: Id, effectiveAccountId: variable });
            this.isLoading = false;

            if (existingCart === true) {
                console.log('CART EXISTS ', existingCart);
                Toast.show({
                    label: 'Error',
                    message: 'There is an existing Order corresponding to your user for this Account. Please empty Cart to proceed with Reorder.',
                    mode: 'dismissible',
                    variant: 'Error',
                });
            }
            else if (existingCart === false) {
                console.log('CART NOT EXISTS ', existingCart);
                const parameters = {
                    orderSummaryId: orderSummaryId,
                    userId: Id,
                };
                this.isLoading = true;
                const result = await executeReorder({ reorderDetails: parameters });
                this.isLoading = false;

                if (result.includes('Success')) {
                    Toast.show({
                        label: 'Success',
                        message: result,
                        mode: 'dismissible',
                        variant: 'Success',
                    });
                    //navigate(this.navContext, cartPage);
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
                else {
                    Toast.show({
                        label: 'Error',
                        message: result,
                        mode: 'dismissible',
                        variant: 'Error',
                    });
                }
            }
        } catch (error) {
            console.log('CAUGHT ERROR IN EXECUTE REORDER---> ' + JSON.stringify(error));
            this.isLoading = false;
            Toast.show({
                label: 'Error',
                message: 'Something went wrong. Please try again later.',
                mode: 'sticky',
                variant: 'Error',
            });
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