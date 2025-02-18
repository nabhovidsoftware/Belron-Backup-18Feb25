import { LightningElement, wire, track, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { createRecord, createContentDocumentAndVersion, updateRecord, getRecord } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';
import START_TIME_FIELD from '@salesforce/schema/WorkStep.StartTime';
import END_TIME_FIELD from '@salesforce/schema/WorkStep.EndTime';
import STATUS_FIELD from '@salesforce/schema/WorkStep.Status';
import updateWorkStep from '@salesforce/apex/BLN_SaveSignature.getCurrentDateTime';
import checkSTRelease from '@salesforce/apex/BLN_SaveSignature.checkSTRelease';

export default class Bln_CaptureSignature extends NavigationMixin(LightningElement) {
  imgSrc;
  @track saRecordId;
  @track wsRecordId;
  @track woliId;
  @track name;
  @track conDocId;
  @track conVerId;
    _title = "Sample Title";
    message = "Sample Message";
    variant = "error";
    variantOptions = [
      { label: "error", value: "error" },
      { label: "warning", value: "warning" },
      { label: "success", value: "success" },
      { label: "info", value: "info" },
    ];

    @wire(CurrentPageReference)
    currentPageReference;

  @api recordId;
  @api usedForR1 = false;

  renderedCallback() {
    this.woliId = this.currentPageReference.attributes.recordId;
    if(!this.woliId){
        this.woliId = this.currentPageReference.state.recordId;
    }
    this.saRecordId = this.currentPageReference.state.saId;
    this.wsRecordId = this.currentPageReference.state.wsId;
    document.fonts.forEach((font) => {
      if (font.family === "Great Vibes" && font.status === "unloaded") {
        font.load();
      }
    });
  }

  connectedCallback() {
    this.getcurrentDateTime();
    checkSTRelease({ woliID: this.recordId })
    .then(result => {
      if(result)
      {
        this.usedForR1 = result;
      }
    })
    .catch(error => {
      console.error('Error fetching Territory R1/R2:', error);
    });
  }

  dataURLtoFile(dataUrl, fileName) {
    let fileBlob = this.dataURLtoBlob(dataUrl);
    return new File([fileBlob], fileName, {
      type: 'image/png',
      lastModified: new Date().getTime()
    });
  }

  dataURLtoBlob(dataURL) {
    let arr = dataURL.split(",");
    let mime = arr[0].match(/:(.*?);/)[1];
    let bstr = window.atob(arr[1]);
    let n = bstr.length;
    let u8arr = new Uint8Array(n);
    while (n--) {
      u8arr[n] = bstr.charCodeAt(n);
    }
    var blob = new Blob([u8arr], { type: "image/png" });
    return blob;
  }

  async saveSignature() {
    try {
      await this.uploadAllPhotos();
    } catch (e) {
      if (e.message) {
      } else {
      }
      return;
    }
  }


  async uploadAllPhotos() {
    const pad = this.template.querySelector("c-bln_-Generate-signature");
    if (pad) {
      const dataURL = pad.getSignature();
      if (dataURL) {
        this.imgSrc = dataURL;
        var base64Canvas = this.imgSrc.split(';base64,')[1];

        await this.uploadData(
          this.name + '.png',
          this.imgSrc,
          this.saRecordId
        );
      }
    }
  }

  // Use LDS createContentDocumentAndVersion function to upload file to a ContentVersion object.
  // This method creates drafts for ContentDocument and ContentVersion objects.
  async uploadData(fileName, fileData, recordId) {
    let fileObject = this.dataURLtoFile(fileData, fileName);
    const contentDocumentAndVersion =
      await createContentDocumentAndVersion({
        title: fileName,
        description: 'Belron Way of Fitting',
        fileData: fileObject
      });
    try {
      const contentDocumentId = contentDocumentAndVersion.contentDocument.id;
      // Create a ContentDocumentLink (CDL) to associate the uploaded file
      // to the Files Related List of a record, like a Work Order.
      await this.createCdl(recordId, contentDocumentId);
    } catch (err) { console.log(err.message); this.error = this.error + err.message; }
  }

  async createCdl(recordId, contentDocumentId) {
    await createRecord({
      apiName: "ContentDocumentLink",
      fields: {
        LinkedEntityId: recordId,
        ContentDocumentId: contentDocumentId,
        ShareType: "V"
      }
    })
      .then(() => {
            this._title = 'Save Success';
            this.message = 'File Saved Successfully';
            this.variant = 'success';
            this.showNotification();
        this.updteWorkStep();
        this.closeComponent();
      })
      .catch((e) => {
            this._title = 'Save failed';
            this.message = 'Something went wrong';
            this.variant = 'error';
            this.showNotification();
        this.error = this.error + e.message;
        throw e;
      });
  }

  handleGetName(event){
    this.name = event.detail;
  }

  titleChange(event) {
    this._title = event.target.value;
  }

  messageChange(event) {
    this.message = event.target.value;
  }

  variantChange(event) {
    this.variant = event.target.value;
  }

  showNotification() {
    const evt = new ShowToastEvent({
      title: this._title,
      message: this.message,
      variant: this.variant,
    });
    this.dispatchEvent(evt);
  }

  clearSignature() {
    const pad = this.template.querySelector("c-bln_-Generate-signature");
    if (pad) {
      pad.clearSignature();
    }

    this.imgSrc = null;
  }

  closeComponent() {
    // Dispatches the event to close the LWC screen
    this.dispatchEvent(new CloseActionScreenEvent());
  }
  updteWorkStep() {
    const fields = {};
    fields[START_TIME_FIELD.fieldApiName] = this.starttime;
    fields[END_TIME_FIELD.fieldApiName] = this.currentDateTime;
    fields[STATUS_FIELD.fieldApiName] = 'Completed';
    fields['Id'] = this.wsRecordId;
    const recordInput = { fields };
    updateRecord(recordInput)
      .then(() => {
        console.log('Record Update Successfully');
      })
      .catch(error => {
        console.log('Error Occured: ', error);
      });
  }
  fieldValue;
  starttime;
  currentDateTime;
  @wire(getRecord, { recordId: this.wsRecordId, fields: [START_TIME_FIELD.fieldApiName] })
  wiredRecord({ error, data }) {
    if (data) {
      this.fieldValue = data.fields.FieldName.value;
      if (this.fieldValue != '' && this.fieldValue != undefined && this.fieldValue != null) {
        this.starttime = this.fieldValue;
      } else {
        this.starttime = this.currentDateTime;
      }
    } else if (error) {
      console.error('Error retrieving record', error);
    }
  }
  getcurrentDateTime() {
    updateWorkStep()
      .then(result => {
        this.currentDateTime = result;
        console.log('this.currentDateTime', this.currentDateTime);
      })
      .catch(error => {
        console.error('Error to get current datetime :', error);
      });
  }
}