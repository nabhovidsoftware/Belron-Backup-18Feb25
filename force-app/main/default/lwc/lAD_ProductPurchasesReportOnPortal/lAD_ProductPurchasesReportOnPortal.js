import { effectiveAccount } from 'commerce/effectiveAccountApi';
import { LightningElement ,api,track} from 'lwc';
import fetchRecords3 from '@salesforce/apex/LAD_CsvController.fetchRecords3';
import getAccId  from '@salesforce/apex/LAD_ReturnAssociatedLocationDetails.getAccId';
import Id from '@salesforce/user/Id';

export default class LAD_ProductPurchasesReportOnPortal extends LightningElement {


   //pagination
   accounts;   
   totalAccounts = 0;
   pageSize = 5;



    orderItemData= [];
    @track sortBy='OrderNumber';
    @track sortDirection='asc';  
    
   

    @api accountId;
    connectedCallback()
    {   
        getAccId({userid:Id})
        .then(result => {
            this.accountId=result;
            this.fetchDetails();
        })
        .catch(error=>{
            console.log(error);
        })
    }


    

    fetchDetails()
    {   let variable = effectiveAccount.accountId!=null & effectiveAccount.accountId!=undefined? effectiveAccount.accountId:this.accountId
        fetchRecords3({accountId:variable}) 
        .then(result => {
            this.orderItemData = result;
            console.log(result);

             //pagination
             this.totalAccounts = this.orderItemData.length;
             this.accounts = this.orderItemData.slice(0,this.pageSize);
        })
        .catch(error => {
            console.log(error);
        });
        
    }

    handlePagination(event){
        const start = (event.detail-1)*this.pageSize;
        const end = this.pageSize*event.detail;
        this.accounts = this.orderItemData.slice(start, end);
    }
    
     columns = [
        { label: 'Product Name', fieldName:'LAD_Product_Name__c' , sortable: "true"},
        { label: 'Quantity', fieldName: 'Quantity', sortable: "true"},
        
    ];
   

 


   
    
    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.accounts));
       
        let keyValue = (a) => {
            return a[fieldname];
        };


       let isReverse = direction === 'asc' ? 1: -1;


           parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; 
            y = keyValue(y) ? keyValue(y) : '';
           
            return isReverse * ((x > y) - (y > x));
        });
        
        this.accounts = parseData;
    }    





 

 get checkRecord(){

    return this.orderItemData.length > 0 ? false : true;

 }

 clickHandler(){


   
   
       let selectedRows = [];
       let downloadRecords = [];
       selectedRows = this.template.querySelector("lightning-datatable").getSelectedRows();

       if(selectedRows.length > 0){
         downloadRecords = [...selectedRows];
       }
       else
       {
        downloadRecords = [...this.orderItemData];
       }



       
       let csvfile = this.convertArrayToCsv(downloadRecords);
       this.createLinkForDownload(csvfile);
       
 }
 //convert array into csv

 convertArrayToCsv(downloadRecords){
    let csvHeader = Object.keys(downloadRecords[0]).toString();
    let csvBody = downloadRecords.map((currItem)=>
        Object.values(currItem).toString()
    );

    let csvfile = csvHeader + '\n' + csvBody.join('\n');
    return csvfile;

 }

 createLinkForDownload(csvfile)
 {
    const downlink = document.createElement("a");
    downlink.href = "data:text/csv;charset=utf-8," + encodeURI(csvfile);
    downlink.target = '_blank';
    downlink.download = 'ProductPurchasesReportsData.csv';
    downlink.click();
 }
}