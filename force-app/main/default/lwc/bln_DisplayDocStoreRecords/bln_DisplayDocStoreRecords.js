import { LightningElement, wire, track, api } from 'lwc';
import FileCategory from '@salesforce/label/c.BLN_Category';
import FileName from '@salesforce/label/c.BLN_Name';
import FileType from '@salesforce/label/c.BLN_FileType';
import FileSize from '@salesforce/label/c.BLN_Size';
import CreatedDate from '@salesforce/label/c.BLN_CreatedDate';
import LinkToExternalFiles from '@salesforce/label/c.BLN_LinkToExternalFiles';
import NoRecordsToDisplay from '@salesforce/label/c.BLN_NoRecordsToDisplay';

import getFileDetails from '@salesforce/apex/BLN_DisplayDocStoreRecordsController.getFileDetails';
import fetchDocumentDetails from '@salesforce/apex/BLN_DisplayDocStoreRecordsController.fetchDocumentDetails';


const COLS = [
  {
    label: FileCategory,
    type: "text",
    fieldName: "fileCategory",
    cellAttributes: {
      class: { fieldName: "fileCategory" },
    },
    wrapText: true,
    initialWidth: 100,
    hideDefaultActions: true,
  },
  {
    label: FileName,
    type: "url",
    fieldName: "fileUrl",
    typeAttributes: {
      label: { fieldName: "fileName" },
      //target: '_blank'
    },
    wrapText: true,
    initialWidth: 200,
    hideDefaultActions: true,
    // cellAttributes: {
    //   class: { fieldName: "fileName" },
    // },
  },
  {
    label: FileType,
    fieldName: "fileType",
    cellAttributes: {
      class: { fieldName: "fileType" },
    },
    initialWidth: 100,
    hideDefaultActions: true,
  },
  {
    label: FileSize,
    type: "text",
    fieldName: "fileSize",
    cellAttributes: {
      class: { fieldName: "fileSize" },
    },
    initialWidth: 70,
    hideDefaultActions: true,


  },
  {
    label: CreatedDate,
    fieldName: 'recDate',
    type: 'date',
    typeAttributes: {
      day: 'numeric',
      month: 'numeric',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
      // second: '2-digit',
      hour12: false
    },
    cellAttributes: {
      class: { fieldName: "recDate" },
    },
    wrapText: true,
    initialWidth: 120,
    hideDefaultActions: true,
  },
];

export default class Bln_DisplayDocStoreRecords extends LightningElement {

  label = {
    FileCategory,
    FileName,
    FileType,
    FileSize,
    CreatedDate,
		LinkToExternalFiles,
		NoRecordsToDisplay
	}

	@track docStoreRecordList;
  @api recordId;
  isModalOpen = false;
  @track isLoading = false;
  columns = COLS;
  date;
  @api isCommunity = false;

  
  formatFileSize(bytes, decimalPoint) {
    if (bytes == 0) return '0 Bytes';    
    var k = 1000,dm = decimalPoint || 2,sizes = ['KB'],
     i = bytes/k;
    return i + ' ' + sizes[0];   
  }

  /*This method will convert date in (DD MONTH,YYYY)  format */
  formatCurrentDate(date) {
    const today = date;
    const options = { day: '2-digit', month: '2-digit', year: 'numeric' };
    const formatter = new Intl.DateTimeFormat('en-GB', options);
    const formattedDate = formatter.format(today);
    return formattedDate;
  }

  handleDocRecords() {
    this.isModalOpen = true;
		getFileDetails({ parentId: this.recordId, isCommunity: this.isCommunity })
			.then(result => {
				result = JSON.parse(JSON.stringify(result));
				let fileList = result.fileList.map(row => {
					const today = new Date();
					var systemDate = this.formatCurrentDate(today);
          var dayDifferenceForUrl;
          var fileUrl;
          var fileURL;
          var filesizeInKB = this.formatFileSize(row.BLN_FileSize__c,2);

          if (row.BLN_FileCreationDate__c != '' && row.BLN_FileCreationDate__c != null && row.BLN_FileCreationDate__c != undefined) {
						var getDocDate = this.formatCurrentDate(new Date(row.BLN_FileCreationDate__c));

            var sysDateday = parseInt(systemDate.substring(0, 2), 10);
            var sysDatemonth = parseInt(systemDate.substring(3, 5), 10);
            var sysDateyear = parseInt(systemDate.substring(6, 10), 10);

            var docDateday = parseInt(getDocDate.substring(0, 2), 10);
            var docDatemonth = parseInt(getDocDate.substring(3, 5), 10);
            var docDateyear = parseInt(getDocDate.substring(6, 10), 10);
            console.log(sysDateday, sysDatemonth, sysDateyear)
            console.log(docDateday, docDatemonth, docDateyear)

            var date1 = new Date(sysDateyear, sysDatemonth - 1, sysDateday);
            var date2 = new Date(docDateyear, docDatemonth - 1, docDateday);

            console.log('date1', date1);
            console.log('date2', date2);

            var daysDifference = date1 - date2;
            //const diffTime = Math.abs(new Date(systemDate) - new Date(getDocDate));
            const diffDays = Math.floor(daysDifference / (1000 * 60 * 60 * 24));
            dayDifferenceForUrl = diffDays;
					}
					if (dayDifferenceForUrl <= 60) {
						fileURL = row.BLN_S3BucketLink__c;

          } else {

           fileURL =  row.BLN_FileName__c ;
            var fileNameToDownload = row.BLN_FileName__c;
            var link;
            fetchDocumentDetails({ docId: row.BLN_DocumentId__c })
              .then(result => {
                result = JSON.parse(result);
                console.log('Get file info data')
                console.log(result)

								var fileBytes = result.fileBytes;

                var a = document.createElement("a"); //Create <a>
                
                if (result.fileExtension == 'txt' || result.fileExtension == 'pdf') {
                  a.href = "data:application/pdf;base64," + fileBytes; //PDF Base64 Goes here
                  a.download = fileNameToDownload;

								} else if (result.fileExtension == 'png' || result.fileExtension == 'jpg') {
									a.href = "data:image/png;base64," + fileBytes; //Image Base64 Goes here
									// let link = window.open(a.href, "_blank");
									// link.opener = null;
									//window.open(a.href, '_blank');
									// a.target = '_blank';
                  a.download = fileNameToDownload;
               
                }
    
                //a.download = row.BLN_FileName__c; //File name Here
                a.click();
    
              })
              .catch(error => {
                console.log('error', error);
              });

          }
          
            return {
              ...row,
              fileName: row.BLN_FileName__c,
              fileUrl: fileURL,
              fileType: row.BLN_FileType__c,
          fileSize: filesizeInKB,
              fileCategory: row.BLN_Category__c,
              recDate: row.BLN_FileCreationDate__c
            }
      
          
        })
				if(fileList.length > 0){
					this.docStoreRecordList = fileList;
				}


      })
      .catch(error => {
        console.log(JSON.stringify(error));
      })

  }

  closeModal() {
    // to close modal set isModalOpen tarck value as false
    this.isModalOpen = false;
  }

	handleClick(event) {
		const data = event.currentTarget.data;
  }


}