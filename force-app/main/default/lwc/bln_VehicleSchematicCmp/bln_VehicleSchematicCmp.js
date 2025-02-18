import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import fetchMetaListLwc from '@salesforce/apex/BLN_VehicleSchematicController.fetchMetaListLwc';
import LightningConfirm from 'lightning/confirm';
import LightningAlert from 'lightning/alert';
import selectedGlass from '@salesforce/label/c.BLN_SelectedGlass';
import selectedGlassError from '@salesforce/label/c.BLN_SelectedGlassError';
import cancelLabel from '@salesforce/label/c.BLN_Cancel';
import repairLabel from '@salesforce/label/c.BLN_RepairQuestions';
import selectLabel from '@salesforce/label/c.BLN_SelectGlass';
import repairQuestionError from '@salesforce/label/c.BLN_RepairQuestionError';
import leftLabel from '@salesforce/label/c.BLN_Left';
import rightLabel from '@salesforce/label/c.BLN_Right';
import backLabel from '@salesforce/label/c.BLN_Back';
import frontLabel from '@salesforce/label/c.BLN_Front';
import windscreen from '@salesforce/label/c.BLN_Windscreen38';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';

const FIELDS = ['BLN_IdentifyDamageAssessment__mdt.BLN_StaticResourceName__c', 'BLN_IdentifyDamageAssessment__mdt.BLN_HoleId__c'];

export default class Bln_VehicleSchematicCmp extends NavigationMixin(LightningElement) {
    label = {
        cancelLabel,
        repairLabel,
        selectLabel,
        leftLabel,
        rightLabel,
        backLabel,
        frontLabel
    };

    @api availableActions = [];
    @api recordId;
    @api selectedImage = '';
    @api name = '';
    @api IsCancelled = false;
    @api IsWindscreen = '';
    result;
    error;
    @track wrmtList = [];

    connectedCallback() {
        fetchMetaListLwc()
            .then((result) => {
                this.wrmtList = JSON.parse(JSON.stringify(result));
            })
            .catch((error) => {
                this.error = error;
            });
    }

    handleCancel(event) {
        var actionClicked = event.target.name;
        if (actionClicked) {
            this.dispatchEvent(new FlowAttributeChangeEvent('IsCancelled', true));
            if (this.availableActions.find((action) => action === 'NEXT')) {
                const navigateNextEvent = new FlowNavigationNextEvent();
                this.dispatchEvent(navigateNextEvent)
            }
        }
    }

    handleRepair() {
        if (this.selectedImage == windscreen) {
            this.dispatchEvent(new FlowAttributeChangeEvent('IsWindscreen', true));
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }
        if (this.selectedImage == '') {

            LightningAlert.open({
                message: repairQuestionError,
                theme: 'error',
                label: selectedGlass,
            });

        }
        if (this.selectedImage != windscreen && this.selectedImage != '') {

            this.dispatchEvent(new FlowAttributeChangeEvent('IsWindscreen', false));
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }
    }

    handleSelectGlass(event) {
        if (this.selectedImage) {
            LightningConfirm.open({
                message: this.selectedImage,
                label: selectedGlass,
                theme: 'shade'
            });
        }
        else {
            LightningAlert.open({
                message: selectedGlassError,
                theme: 'error',
                label: selectedGlass,
            });
        }
    }
    
    handleCheck(event) {
        if (this.selectedImage == event.currentTarget.dataset.id) {
            this.selectedImage = '';
        }
        else {
            this.selectedImage = event.currentTarget.dataset.id;
        }
        
        this.wrmtList.forEach(element => {
            element.wrapFldList.forEach(wrap => {
                if (wrap.imageLabel == this.selectedImage && this.selectedImage) {

                    wrap.checked = true;
                }
                else {

                    wrap.checked = false;
                }
            });
        });
        this.name = this.selectedImage;
    }
}