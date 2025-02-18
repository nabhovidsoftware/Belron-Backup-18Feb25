import { LightningElement, api,track } from "lwc";
import LightningConfirm from "lightning/confirm";
import { debug, getComputedHeight } from "c/bln_UtilsImageCapture";

export default class Bln_ImageSelector extends LightningElement {
    @api
  allImagesData;
  @api numOfDamage;
  @api workStepName;
  @track controllingValue;
  @track dependingValues;
  @track inspectionStep;
  @track selectedDependingOption;
  @track showUploadButton = true;
  @track showAreaAndPart = true;
  @track updatedName;
  @track initateFromWindscreenWS;
  @track isShowSpinner = true;
  @track disbaleAfterUpdate = false;

  dependingOptions = [];
  previewImage = null;
  maxHeightForPreview;
  pageWidth;

  get totalSelectedImages() {
    return this.allImagesData.length;
  }

  get noImagesSelected() {
    return this.totalSelectedImages === 0 && !this.isPreviewingImage;
  }

  get someImagesSelected() {
    return this.totalSelectedImages > 0 && !this.isPreviewingImage;
  }

  get isPreviewingImage() {
    return this.previewImage !== null;
  }

  get imageText() {
    return this.totalSelectedImages > 1 ? "images" : "image";
  }

  get previewContainer() {
    return this.template.querySelector('[data-id="preview-container"]');
  }

  get imagesListContainer() {
    return this.template.querySelector('[data-id="images-list-container"]');
  }

  get imageInfoViewer() {
    return this.template.querySelector('[data-id="image-info-viewer"]');
  }

  handleImageSelectedForPreview(event) {
    const selectedId = parseInt(event.currentTarget.dataset.id, 10);
    for (const item of this.allImagesData) {
      if (item.id === selectedId) {
        this.previewImage = item;
        break;
      }
    }

    // Use the height of the images list container as the max height for the preview
    this.maxHeightForPreview = getComputedHeight(this.imagesListContainer);

    this.pageWidth = window.innerWidth;
  }

  handlePreviewScreenRendered() {
    debug("Preview container max height = " + this.maxHeightForPreview);
    this.previewContainer.style.maxHeight = this.maxHeightForPreview + "px";
    this.imageInfoViewer.style.maxWidth =
      this.previewContainer.offsetWidth + "px";
  }

  backToPreviewAllImages() {
    this.previewImage = null;
  }

  async handleRemoveClicked() {
    const result = await LightningConfirm.open({
      message: "Removing the image deletes it from your uploaded images.",
      variant: "header",
      label: "Remove image?",
      theme: "error"
    });

    if (result === true) {
      this.dispatchEvent(
        new CustomEvent("delete", {
          detail: this.previewImage.id
        })
      );

      this.previewImage = null;
    }
  }

  handleImageSelectedForAnnotation() {
    const selectedId = this.previewImage.id;
    this.dispatchEvent(
      new CustomEvent("annotateimage", {
        detail: selectedId
      })
    );
  }

  async handleFilesSelected(event) {
    if (this.workStepName && this.workStepName.includes('Capture Windscreen Damage')) {
      this.updatedName = 'Pre-Inspection' + '-' + 'Windscreen Damage';
    } else if (this.inspectionStep == 'Pre-Inspection' || this.inspectionStep == 'Post-Inspection' || this.inspectionStep == 'Additional-Inspection') {
      this.updatedName = this.inspectionStep+'-'+this.controllingValue+'-'+this.selectedDependingOption;
    }else{
      this.updatedName = this.inspectionStep;
    }
    
    const customEvents = new CustomEvent('sendimagename', {
      detail: { imageName: this.updatedName}
    });
    this.dispatchEvent(customEvents);
    const files = event.target.files;
    this.dispatchEvent(
      new CustomEvent("selectimages", {
        detail: files
      })
    );
    
    this.inspectionStep = '';
    this.controllingValue = '';
    this.dependingValues = '';
    this.showUploadButton = true;
    this.showAreaAndPart = true;
  }

  connectedCallback(){
    setTimeout(() => {
      this.isShowSpinner = false;
      if (this.workStepName && this.workStepName.includes('Capture Windscreen Damage')) {
        this.initateFromWindscreenWS = true;
        this.showUploadButton = false;
      } else if (this.workStepName == '' || this.workStepName == undefined || this.workStepName == null) {
        this.initateFromWindscreenWS = false;
        this.showUploadButton = true;
      }
    }, 5000);
  }

  renderedCallback() {
    if ((this.allImagesData.length < this.numOfDamage) && (this.numOfDamage != undefined || this.numOfDamage != '') &&
      (this.workStepName && this.workStepName.includes('Capture Windscreen Damage')) && this.disbaleAfterUpdate == false) {
      this.initateFromWindscreenWS = true;
      this.showUploadButton = false;
    } else if (this.workStepName && this.workStepName.includes('Capture Windscreen Damage')) {
      this.showUploadButton = true;
    }
  }

  async handleUploadClicked() {
    if( (this.allImagesData.length < this.numOfDamage) && (this.numOfDamage !=undefined || this.numOfDamage != '') && 
    (this.workStepName && this.workStepName.includes('Capture Windscreen Damage'))){
      const result = await LightningConfirm.open({
        message: "Please input "+this.numOfDamage+" images as mentioned in Windscreen Damage.",
        variant: "header",
        label: "Validation Error",
        theme: "Error"
      });
    }else{
      const result = await LightningConfirm.open({
        message: "After uploading the images you can't edit them.",
        variant: "header",
        label: "Add images to record?",
        theme: "success"
      });
      if (result) {
        this.dispatchEvent(new CustomEvent("uploadrequest"));
      }
      this.disbaleAfterUpdate = true;
    }

    this.inspectionStep = '';
    this.controllingValue = '';
    this.dependingValues = '';
    this.showUploadButton = true;
    this.showAreaAndPart = true;
  }

  controllingOptions = [
    { label: 'Interior', value: 'Interior'},
    { label: 'Exterior', value: 'Exterior'}
  ];

  inspectionStepgOptions = [
    { label: 'Pre-Inspection', value: 'Pre-Inspection'},
    { label: 'Post-Inspection', value: 'Post-Inspection'},
    { label: 'Additional-Inspection', value: 'Additional-Inspection' },
    { label: 'PreScan', value: 'PreScan'},
    { label: 'PostScan', value: 'PostScan'},
    { label: 'Recalibration', value: 'Recalibration'},
    { label: 'CorrectiveActionReport', value: 'CorrectiveActionReport' },
    { label: 'RepairNotMetStandard', value: 'RepairNotMetStandard' }
  ];

  handleCinspectionStepChange(event){
    this.inspectionStep = event.detail.value;
    if (this.inspectionStep == 'PreScan' || this.inspectionStep == 'PostScan' || this.inspectionStep == 'Recalibration' || this.inspectionStep == 'CorrectiveActionReport' || this.inspectionStep == 'RepairNotMetStandard') {
      this.showAreaAndPart = true;
      this.controllingValue = '';
      this.dependingValues = '';
      this.showUploadButton = false;
    }
    if (this.inspectionStep == 'Pre-Inspection' || this.inspectionStep == 'Post-Inspection' || this.inspectionStep == 'Additional-Inspection') {
      this.showAreaAndPart = false;
      this.controllingValue = '';
      this.dependingValues = '';
      this.showUploadButton = true;
    }if(this.inspectionStep == '' || this.inspectionStep == undefined){
      this.showAreaAndPart = true;
      this.showUploadButton = true;
    }
  }

  handleControllingChange(event){
    this.controllingValue = event.detail.value;
    this.updateDependingOptions();
    
  }
  updateDependingOptions(){
    this.dependingValues = this.parenttochilddatas;
    if(this.controllingValue === 'Interior'){
      this.dependingOptions = [
        { label: 'Seats', value: 'Seats'},
        { label: 'Dash', value: 'Dash'},
        { label: 'Carpet', value: 'Carpet'},
        { label: 'Headlining', value: 'Headlining'},
        { label: 'Door Card', value: 'Door Card'},
        { label: 'Other Interior', value: 'Other Interior'}
      ];
      
    }else if(this.controllingValue === 'Exterior'){
      this.dependingOptions = [
        { label: "Windscreen Damage", value: "Windscreen Damage" },
        { label: "Bonnet", value: "Bonnet" },
        { label: "A-Pillars", value: "A-Pillars" },
        { label: "Driver's Side", value: "Driver's Side" },
        { label: "Passenger's Side", value: "Passenger's Side" },
        { label: "Front", value: "Front" },
        { label: "Rear", value: "Rear" },
        { label: "Roof", value: "Roof" }
      ];
      
    }else{
      this.dependingOptions = [];
    }
  }
  handleDependentChange(event){
    this.selectedDependingOption = event.detail.value;
    if((this.selectedDependingOption != '' || this.selectedDependingOption != undefined) && (this.dependingOptions != '' || this.dependingOptions != undefined) && (this.inspectionStepgOptions != '' || this.inspectionStepgOptions != undefined)){
        this.showUploadButton = false;
    }
  }
  
}