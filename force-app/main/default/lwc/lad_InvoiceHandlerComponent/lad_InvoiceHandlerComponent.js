import { LightningElement, track } from 'lwc';
import { MOCKfinDocList } from './lad_InvoiceHandlerComponent_Mock';
import { loadStyle } from 'lightning/platformResourceLoader';
import removeDateFormat from '@salesforce/resourceUrl/RemoveDateFormatStyle';
import InternalPortal from '@salesforce/customPermission/LAD_Laddaw_Internal_Portal';
import { NavigationMixin, } from 'lightning/navigation';
import { effectiveAccount } from 'commerce/effectiveAccountApi';
import getAccId from '@salesforce/apex/LAD_ReturnAssociatedLocationDetails.getAccId';
import Id from '@salesforce/user/Id';
import fetchFinancialDocuments from '@salesforce/apex/LAD_InvoiceHandler.fetchFinancialDocuments';



export default class Lad_InvoiceHandlerComponent extends NavigationMixin(LightningElement) {

    accountId;

    finDocList_MASTER;
    finDocList;

    @track currentSearchMode = 'document';
    @track queryTerm;
    @track showFilterModal = false;
    @track issueMode = true;
    @track dueMode = false;
    @track filterDates = [
        {
            filterName: 'issue',
            start: null,
            end: null,
        },
        {
            filterName: 'due',
            start: null,
            end: null,
        }
    ]

    @track errorMessages = [
        {
            filterName: 'issue',
            error: null,
        },
        {
            filterName: 'due',
            error: null,
        }
    ];

    @track searchErrorMessage;

    @track selectedFinDocsLabel_Prefix = "Pay selected invoices";
    @track selectedFinDocsList = [];
    @track paginatedRecords = [];
    recordsPerPage = 10;
    currentPage = 1;

    @track filterItemPillList = [];

    //PAY CUSTOM AMOUNT VARIABLES
    @track showPaymentModal = false;
    @track customAmount;
    @track minimumCustomAmount = '100.00';
    @track accountOutstandingBalance = '500.00';
    @track payCustomErrorMessage;

    get disableModalPaymentButton() {
        if (this.customAmount) {
            return this.customAmount.length === 0;
        }
        return true;
    }

    /**
    * Getter for Search Modes
    */
    get searchModes() {
        return [
            {
                label: 'Search by Document Number',
                value: 'document',
            },
            {
                label: 'Search by Order Number',
                value: 'order',
            }
        ];
    }

    /**
    * Getter for Table Columns
    */
    get finDocColumns() {
        return [
            {
                label: 'Document #',
                name: 'DocumentNumber',
                priotity: 'optional',
            },
            {
                label: 'Type',
                name: 'Type',
                priotity: 'optional',
            },
            {
                label: 'Issued Date',
                name: 'CreatedDate',
                priotity: 'optional',
            },
            {
                label: 'Order #',
                name: 'OrderNumber',
                priotity: 'optional',
            },
            {
                label: 'PO #',
                name: 'OrderPONumber',
                priotity: 'optional',
            },
            {
                label: 'Payment #',
                name: 'PaymentId',
                priotity: 'optional',
            },
            {
                label: 'Total',
                name: 'TotalAmount',
                priotity: 'optional',
            },
            {
                label: 'Remaining',
                name: 'RemainingAmount',
                priotity: 'optional',
            },
            {
                label: 'Due Date',
                name: 'DueDate',
                priotity: 'optional',
            },
            {
                label: 'Status',
                name: 'PaymentStatus',
                priotity: 'optional',
            },
        ]
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
    * Getter for Filters
    */
    get filterList() {
        return [
            {
                label: 'Issue Date',
                name: 'issue',
            },
            {
                label: 'Due Date',
                name: 'due',
            }
        ]
    }

    /**
    * Getter for value of Issue Date start
    */
    get issueStartDate() {
        let obj = this.filterDates.find(item => item.filterName == 'issue');
        console.log('START DATE  ', obj.start);
        return obj.start;
    }

    /**
    * Getter for value of Issue Date end
    */
    get issueEndDate() {
        let obj = this.filterDates.find(item => item.filterName == 'issue');
        return obj.end;
    }

    /**
    * Getter for value of Due Date start
    */
    get dueStartDate() {
        let obj = this.filterDates.find(item => item.filterName == 'due');
        return obj.start;
    }

    /**
    * Getter for value of Due Date end
    */
    get dueEndDate() {
        let obj = this.filterDates.find(item => item.filterName == 'due');
        return obj.end;
    }

    /**
    * Getter for showing Issue Filter Error
    */
    get showIssueError() {
        let obj = this.errorMessages.find(item => item.filterName == 'issue');
        if (obj.error) {
            return true;
        }
        return false;
    }

    /**
    * Getter for showing Due Filter Error
    */
    get showDueError() {
        let obj = this.errorMessages.find(item => item.filterName == 'due');
        if (obj.error) {
            return true;
        }
        return false;
    }

    /**
    * Getter for Search Error Message
    */
    get showSearchError() {
        return this.searchErrorMessage?.length > 0;
    }

    /**
    * Getter for Issue Error Message
    */
    get issueErrorMessage() {
        let obj = this.errorMessages.find(item => item.filterName == 'issue');
        return obj.error;
    }

    /**
    * Getter for Due Error Message
    */
    get dueErrorMessage() {
        let obj = this.errorMessages.find(item => item.filterName == 'due');
        return obj.error;
    }

    /**
    * Getter for disabling Apply Button
    */
    get disableApplyFilters() {
        console.log(this.issueStartDate, this.issueEndDate, this.dueStartDate, this.dueEndDate);
        if ((this.issueStartDate && this.issueEndDate) || (this.dueStartDate && this.dueEndDate)) {
            return false;
        }
        return true;
    }

    /**
    * Getter for label of Pay Selected Invoices button
    */
    get selectedFinDocsLabel() {
        if (this.selectedFinDocsList.length > 0) {
            let initial = 0;
            let amtValue = this.selectedFinDocsList.reduce((result, item) => result += item.value, initial);

            return this.selectedFinDocsLabel_Prefix + ` (${this.getCurrencySymbol(this.selectedFinDocsList[0].currency)}${amtValue.toFixed(2)})`
        }
        return this.selectedFinDocsLabel_Prefix;
    }

    /**
    * Getter for disabling of Pay Selected Invoices button
    */
    get disablePayCustom() {
        return InternalPortal;
    }

    /**
    * Getter for disabling of Pay Selected Invoices button
    */
    get disablePaySelectedInvoices() {
        let initial = 0;
        let amtValue = this.selectedFinDocsList.reduce((result, item) => result += item.value, initial);

        return this.selectedFinDocsList.length === 0 || InternalPortal || amtValue < 0;
    }

    /**
    * Getter to show current item count of docs being displayed
    */
    get itemCountMessage() {
        if (this.finDocList?.length > 0) {
            if (this.finDocList?.length < 500) {
                return `${this.finDocList.length} items`;
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
    * Getter for showing Custom Amount Error
    */
    get showPayCustomError() {
        if (this.payCustomErrorMessage) {
            return true;
        }
        return false;
    }

    /**
    * Rendered Callback handling removal of date format under elements of <lightning-input type="date">
    */
    renderedCallback() {
        Promise.all([
            loadStyle(this, removeDateFormat) //specified filename
        ]).then(() => {
            window.console.log('Files loaded.');
        }).catch(error => {
            window.console.log("Error " + error.body.message);
        });
        if (this.finDocList) {
            this.handleOverDue();
        }
    }

    connectedCallback() {
        if (this.isInSitePreview()) {
            this.finDocList_MASTER = MOCKfinDocList;
            this.finDocList = JSON.parse(JSON.stringify(MOCKfinDocList));
            this.checkInternalUser();
            this.updatePagination();
        }
        else {
            getAccId({ userid: Id })
                .then(result => {
                    if (result) {
                        this.accountId = effectiveAccount.accountId !== null && effectiveAccount.accountId !== undefined ? effectiveAccount.accountId : result;
                        this.handleFetchFinancialDocs();
                        this.isLoading = false;
                    }
                    else {
                        console.error('Unable to fetch Account Id');
                        this.isLoading = false;
                    }
                }).catch(error => {
                    console.error("Error in fetching account Id: ", error);
                    this.isLoading = false;
                })

        }

    }

    async handleFetchFinancialDocs() {
        this.isLoading = true;
        try {
            let params = {
                accountId: this.accountId,
            }

            this.filterDates.forEach(obj => {
                if (obj.start && obj.end) {
                    if (obj.filterName === "issue") {
                        params.issuedStartDate = obj.start;
                        params.issuedEndDate = obj.end;
                    }
                    else {
                        params.dueStartDate = obj.start;
                        params.dueEndDate = obj.end;
                    }

                }
            })

            const result = await fetchFinancialDocuments({ parameters: params });
            if (result) {
                console.log('RESULT: ', result);
                this.finDocList_MASTER = result;
                this.finDocList = JSON.parse(JSON.stringify(result));
                this.checkInternalUser();
                this.updatePagination();
                console.log('FETCHED FINANCIAL DOCUMENTS: ', this.finDocList);
                this.isLoading = false;
            }
            else {
                console.error("Unable to fetch Financial Documents please check exception logs");
                this.isLoading = false;
            }
            console.log('IN STILL FIN DOCS: ' + this.isLoading);
        } catch (error) {
            this.isLoading = false;
            console.log('LOADING: ' + this.isLoading);
            console.error("ERROR IN FETCHING FIN DOCS: ", error);
        }

    }

    checkInternalUser() {
        this.isLoading = true;
        try {
            if (InternalPortal) {
                this.finDocList.forEach(obj => {
                    obj.disablePayNow = true;
                    obj.disableCheckbox = true;
                });
            }
            this.isLoading = false;
        } catch (error) {
            console.error("ERROR IN CHECK INTERNAL: " + error);
            this.isLoading = false;
        }

    }


    handleOverDue() {
        this.isLoading = true;
        try {
            this.finDocList.forEach(item => {
                if (item.PaymentStatus === 'Overdue') {
                    let element = this.template.querySelector(`[data-key="${item.FinDocId}"]`);
                    if (element) {
                        element.style.color = 'red';
                    }
                }
            })
            this.isLoading = false;

        } catch (error) {
            console.error('ERROR IN HANDLE OVERDUE COLOUR ', error);
            this.isLoading = false;

        }
    }
    /**
    * Function to handle switching of Search Modes
    */
    handleSearchModeChange(event) {
        this.isLoading = true;
        try {
            let selectedSearchMode = event.target.value;
            console.log(selectedSearchMode);
            this.currentSearchMode = selectedSearchMode;
            this.queryTerm = null;
            this.searchErrorMessage = null;
            //const response = await this.handleApplyDateFilter();
            this.finDocList = JSON.parse(JSON.stringify(this.finDocList_MASTER));
            //handleSearchModeChange();
            this.updatePagination();

            this.isLoading = false;

        } catch (error) {
            console.error('ERROR IN SEARCH MODE CHANGE ', error);
            this.isLoading = false;

        }
    }

    /**
    * Handles Clear Search Bar
    */
    async handleQueryChangeOrClear(event) {
        this.isLoading = true;
        try {
            if (event.target.value.length !== 0) {
                this.queryTerm = event.target.value;
                this.searchErrorMessage = null;
            }
            else if (event.target.value.length === 0) {
                this.currentPage = 1;

                console.log('IN DE-SEARCH')
                this.queryTerm = null;
                this.searchErrorMessage = null;
                //const response = await this.handleApplyDateFilter();
                this.finDocList = JSON.parse(JSON.stringify(this.finDocList_MASTER));
                //handleSearchModeChange();
                this.updatePagination();
            }
            this.isLoading = false;

        } catch (error) {
            console.error('ERROR IN SEARCH COMMIT ', error);
            this.isLoading = false;

        }
    }

    /**
    * Handles Search
    */
    handleSearch() {
        this.currentPage = 1;
        let comparingKey;
        switch (this.currentSearchMode) {
            case 'document':
                comparingKey = 'DocumentNumber';
                break;
            case 'order':
                comparingKey = 'OrderNumber';
                break;

        }
        let searchedObjectArray = this.finDocList_MASTER.filter(item => item[comparingKey] === this.queryTerm);
        if (searchedObjectArray.length !== 0) {
            this.finDocList = searchedObjectArray;

        }
        else {
            this.searchErrorMessage = 'No records found';
            this.finDocList = [];
        }

        // this.totalPages = Math.ceil(this.finDocList?.length / this.recordsPerPage);
        this.updatePagination();
    }

    /**
    * Function to opening of Filter Modal
    */
    handleOpenFilterModal() {
        this.isLoading = true;
        try {
            console.log('INSIDE MODAL OPEN')
            this.issueMode = true;
            this.dueMode = false;
            this.showFilterModal = true;
        } catch (error) {
            console.error('ERROR IN OPEN FILTER MODAL ', error);
        }
        this.isLoading = false;

    }

    /**
    * Function to handling filter switching in Modal
    */
    handleFilterSwitch(event) {
        this.isLoading = true;
        try {
            switch (event.target.dataset.id) {
                case 'issue':
                    this.dueMode = false;
                    this.issueMode = true;

                    break;
                case 'due':
                    this.issueMode = false;
                    this.dueMode = true;
                    break;
            }
        } catch (error) {
            console.error('ERROR IN FILTER SWITCH ', error)
        }
        this.isLoading = false;


    }

    /**
    * Function to handle Start Date change for all filters
    */
    handleStartDate(event) {
        this.isLoading = true;
        try {
            let inputDate = event.target.value;
            let filter = event.target.dataset.filter;
            console.log('START DATE--> ', inputDate);
            console.log('FILTER--> ', filter);
            let endDate;
            switch (filter) {
                case 'issue':
                    endDate = this.issueEndDate;
                    break;
                case 'due':
                    endDate = this.dueEndDate;
                    break;
            }
            if (inputDate) {
                if (endDate && new Date(inputDate) > new Date(endDate)) {
                    //throw Error for start date more than end date
                    console.log('start date more than end date');
                    let obj = this.errorMessages.find(item => item.filterName == filter);
                    obj.error = 'Please select a start date equal to or before the selected end date';
                    //startDate = null;
                    this.filterDates.forEach(obj => {
                        if (obj.filterName == filter) {
                            obj.start = null;
                        }
                    })
                    let dateElement = this.template.querySelector(`[data-id="start"][data-filter=${filter}]`);
                    dateElement.value = null;
                }
                else {
                    console.log('in right start');
                    this.filterDates.forEach(obj => {
                        if (obj.filterName == filter) {
                            obj.start = inputDate;
                        }
                    })
                    let obj = this.errorMessages.find(item => item.filterName == filter);
                    obj.error = null;
                }
            }
        } catch (error) {
            console.error('ERROR IN START DATE ', error)
        }
        this.isLoading = false;

    }

    /**
    * Function to handle End Date change for all filters
    */
    handleEndDate(event) {
        this.isLoading = true;
        try {
            let inputDate = event.target.value;
            let filter = event.target.dataset.filter;
            console.log('END DATE--> ', inputDate);
            console.log('FILTER--> ', filter);
            let startDate;
            switch (filter) {
                case 'issue':
                    startDate = this.issueStartDate;
                    break;
                case 'due':
                    startDate = this.dueStartDate;
                    break;
            }

            if (inputDate) {
                if (startDate && new Date(inputDate) < new Date(startDate)) {
                    //throw Error for end date less than start date
                    console.log('end date less than start date');
                    let obj = this.errorMessages.find(item => item.filterName == filter);
                    obj.error = 'Please select an end date equal to or after the selected start date';
                    this.filterDates.forEach(obj => {
                        if (obj.filterName == filter) {
                            obj.end = null;
                        }
                    })

                    let dateElement = this.template.querySelector(`[data-id="end"][data-filter=${filter}]`);
                    dateElement.value = null;
                }
                else {
                    console.log('in right end');
                    this.filterDates.forEach(obj => {
                        if (obj.filterName == filter) {
                            obj.end = inputDate;
                        }
                    })
                    let obj = this.errorMessages.find(item => item.filterName == filter);
                    obj.error = null;
                }
            }
        } catch (error) {
            console.error('ERROR IN END DATE ', error)
        }
        this.isLoading = false;


    }

    /**
    * Function to handle Reset of filters
    */
    handleResetDateFilter(event) {
        this.isLoading = true;
        try {
            let filter = event.target.dataset.filter;
            console.log('Reset filter --> ', filter);
            this.filterDates.forEach(obj => {
                if (obj.filterName == filter) {
                    obj.start = null;
                    obj.end = null;
                }
            })
            let obj = this.errorMessages.find(item => item.filterName == filter);
            obj.error = null;

            let domElementStart = this.template.querySelector(`[data-id="start"][data-filter=${filter}]`);
            domElementStart.value = null;
            let domElementEnd = this.template.querySelector(`[data-id="end"][data-filter=${filter}]`);
            domElementEnd.value = null;
            console.log('DOMS ', domElementStart, domElementEnd);
        } catch (error) {
            console.error('ERROR IN RESET FILTER ', error)
        }
        this.isLoading = false;

    }

    /**
    * Function to handle enforcing of filters saved
    */
    handleApplyAllFilters() {
        this.isLoading = true;
        try {

            let pillArray = [];
            this.filterDates.forEach(obj => {
                if (obj.start && obj.end) {
                    const filterList = this.filterList;
                    console.log('FILTER LIST  ', filterList);
                    let item = this.filterList.find(filter => filter.name === obj.filterName);
                    pillArray.push(item);
                }
            });
            console.log('PILL ARRAY ' + JSON.stringify(pillArray));
            this.filterItemPillList = pillArray;
            //Async get data based on filters.
            this.handleFetchFinancialDocs();
            this.showFilterModal = false;
        } catch (error) {
            console.error('ERROR IN APPLY ALL FILTERS: ', error);
            this.isLoading = false;

        }


    }

    /**
    * Function to handle removal of filters via pill
    */
    handlePillRemove(event) {
        this.isLoading = true;
        try {
            let filter = event.target.dataset.id;
            this.filterDates.forEach(obj => {
                if (obj.filterName == filter) {
                    obj.start = null;
                    obj.end = null;
                }
            })

            this.filterItemPillList = this.filterItemPillList.filter(obj => obj.name != filter);
            console.log('PILL ARRAY ' + this.filterItemPillList);

            //Async Operation to refetch data based on filters.
            this.handleFetchFinancialDocs();
        } catch (error) {
            console.error('ERROR IN PILL REMOVAL: ', error);
            this.isLoading = false;

        }
    }

    /**
    * Function to handle Closing of Filters Modal
    */
    handleCloseFilterModal() {
        this.isLoading = true;
        try {
            console.log('INSIDE MODAL CLOSE')
            this.showFilterModal = false;
        } catch (error) {
            console.error('ERROR IN FILTER CLOSE ', error)
        }
        this.isLoading = false;

    }

    /**
    * Function to handle selection of Financial Docs
    */
    handleFinDocSelect(event) {
        this.isLoading = true;
        try {
            console.log(event.target.checked);
            const docId = event.target.dataset.id;
            let finDoc = this.finDocList.find(item => item.FinDocId === docId);
            if (event.target.checked) {
                const obj = {
                    id: docId,
                    currency: finDoc.CurrencyIsoCode,
                    value: parseFloat(finDoc.RemainingAmountValue),
                }
                this.selectedFinDocsList.push(obj);

            } else {
                this.selectedFinDocsList = this.selectedFinDocsList.filter(obj => obj.id !== docId);
            }

            console.log(this.selectedFinDocsList);
            //Logic to check if any Credit Note has this Invoice in related Doc and enable that Credit Note for selection
            //Need to check if Selecting an Invoice with a related Credit Note should ideally select the Credit Note as well. If not, then
            // if an Invoice is already paid without the using the Credit Note then that Credit Note should be not be disabled.

        } catch (error) {
            console.error('ERROR IN FIN DOC SELECTION ', error)
        }
        this.isLoading = false;

    }

    /**
    * handles Pay Custom Amount modal show
    */
    handlePayCustomAmount() {
        //Show modal where they select amount to pay etc. then navigate
        this.showPaymentModal = true;

    }

    /**
    * handles Closing of Custom amount modal
    */
    handleClosePaymentModal() {
        this.showPaymentModal = false;
        this.customAmount = null;
    }

    /**
    * handles Custom Amount payment change
    */
    handleCustomAmountChange(event) {
        try {
            console.log('IN CUSTOM AMOUNT CHANGE: ', event.target.value);
            let amount = event.target.value;
            if (amount) {
                if (parseFloat(amount) < parseFloat(this.minimumCustomAmount)) {
                    this.payCustomErrorMessage = "Please provide a custom amount greater than the minimum allowed amount";
                    this.customAmount = null;
                }
                else if (parseFloat(this.accountOutstandingBalance) < parseFloat(amount)) {
                    this.payCustomErrorMessage = "Please provide a custom amount within the outstanding balance";
                    this.customAmount = null;
                }
                else {
                    this.customAmount = amount;
                    this.payCustomErrorMessage = null;
                }
            }
            else {
                this.customAmount = null;
            }
        } catch (error) {
            console.error('ERROR IN CUSTOM AMOUNT CHANGE: ' + error);
        }

    }

    /**
    * Shows Custom Amount Modal
    */
    handleModalPaymentButton() {
        this.handleNavigatePayment(null, 'custom');
    }

    /**
    * handles creating selected invoice id list and calls payment navigation
    */
    handlePaySelectedInvoices() {
        this.isLoading = true;
        try {
            let selectedFinDocIdList = [];
            for (let obj of this.selectedFinDocsList) {
                if (obj.id) {
                    selectedFinDocIdList.push(obj.id);
                }
            }
            console.log('SELECTED INVOICE PAYMENT ' + selectedFinDocIdList);
            this.handleNavigatePayment(selectedFinDocIdList, 'invoice');
            this.isLoading = false;
        } catch (error) {
            console.error('ERROR IN PAY SELECTED INVOICE: ', error);
            this.isLoading = false;
        }

    }

    /**
    * handles Payment Page URL generation and navigation
    */
    handleNavigatePayment(selectedFinDocIdList, paymentMode) {
        this.isLoading = true;
        console.log('FINDOCLIST ' + selectedFinDocIdList);
        const paymentReference = {
            type: 'comm__namedPage',
            attributes: {
                name: 'LAD_Payments__c',

            },
        };
        this[NavigationMixin.GenerateUrl](paymentReference)
            .then(url => {
                console.log('Generated URL:', url);
                let paymentURL = url + `?paymentMode=${paymentMode}&accountId=${this.accountId}`;

                if (selectedFinDocIdList) {
                    //Invoice Id Segment
                    for (let id of selectedFinDocIdList) {
                        console.log(id);
                        paymentURL = paymentURL + `&finDocId=${id}`;
                    }
                }
                else {
                    //Custom Amount Segment
                    paymentURL = paymentURL + `&total=${this.customAmount}`;
                }
                // Redirect to the generated URL
                console.log('PAYMENT URL ' + paymentURL);
                window.open(paymentURL, "_self");
                this.isLoading = false;
            })
            .catch(error => {
                console.error('Error generating URL:', error);
                this.isLoading = false;
            });
    }

    /**
    * handles Pay now functionality
    */
    handlePayNow(event) {
        this.isLoading = true;
        try {
            let selectedFinDocIdList = [event.target.dataset.id];
            console.log('SELECTED INVOICE PAYMENT ' + selectedFinDocIdList);
            this.handleNavigatePayment(selectedFinDocIdList, 'invoice');
            this.isLoading = false;
        } catch (error) {
            console.error('ERROR IN PAY NOW: ', error);
            this.isLoading = false;
        }
    }

    /**
    * handles Download PDF 
    */
    handleDownloadPDF(event) {
        try {
            let downloadElement = document.createElement('a');
            downloadElement.href = event.target.dataset.url;
            downloadElement.target = '_blank';
            downloadElement.download = `${event.target.dataset.number}.pdf`;
            downloadElement.click();
        } catch (error) {
            console.error('ERROR IN FILE DOWNLOAD: ', error);
        }
    }

    /**
    * handles Pagination
    */
    updatePagination() {
        this.isLoading = true;
        try {
            if (this.recordsPerPage >= this.finDocList.length) {
                this.paginatedRecords = this.finDocList;
            }
            else {
                const start = (this.currentPage - 1) * this.recordsPerPage;
                if (start > (this.finDocList.length - 1)) {
                    start = 0;
                }
                const end = start + this.recordsPerPage;

                this.paginatedRecords = this.finDocList.slice(start, end);
            }
        } catch (error) {
            console.error('ERROR IN UPDATE PAGINATION ', error)
        }
        this.isLoading = false;
    }

    /**
    * handles Next Page button click
    */
    nextPage() {
        this.isLoading = true;
        try {
            if (this.currentPage < this.totalPages) {
                this.currentPage++;

                this.updatePagination();
                window.scrollTo(0, 0);
            }
        } catch (error) {
            console.error('ERROR IN NEXT PAGE ', error)
        }
        this.isLoading = false;

    }

    /**
    * handles Previous Page button click
    */
    previousPage() {
        this.isLoading = true;
        try {
            if (this.currentPage > 1) {
                this.currentPage--;

                this.updatePagination();
                window.scrollTo(0, 0);
            }
        } catch (error) {
            console.error('ERROR IN PREVIOUS PAGE ', error)
        }
        this.isLoading = false;
    }

    /**
    * Getter for Total Pages
    */
    get totalPages() {
        return Math.ceil(this.finDocList?.length / this.recordsPerPage) > 0 ? Math.ceil(this.finDocList?.length / this.recordsPerPage) : 1
    }

    /**
    * Getter for controlling disability of Previous Button
    */
    get isFirstPage() {
        return this.currentPage === 1;
    }

    /**
    * Getter for controlling disability of Next Button
    */
    get isLastPage() {
        return this.currentPage === this.totalPages;
    }

    /**
    * helper function returns currency Symbol for currency Iso code
    */
    getCurrencySymbol(currencyCode) {
        const formatter = new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: currencyCode,
            minimumFractionDigits: 2,
            maximumFractionDigits: 2,
        });

        const parts = formatter.formatToParts(1);
        const symbol = parts.find(part => part.type === 'currency').value;
        return symbol;
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