import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class Bln_ReturnToOverviewButton extends NavigationMixin(LightningElement) {
  
    returnToOverview() {
        window.history.back();
    }
}