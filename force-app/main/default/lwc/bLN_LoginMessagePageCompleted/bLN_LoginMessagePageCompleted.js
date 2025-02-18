/**
 * @description       :
 * @author            : Sourabh Bhattacharjee
 * @group             :
 * @last modified on  : 11-19-2024
 * @last modified by  : Sourabh Bhattacharjee
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   11-19-2024   Sourabh Bhattacharjee   Initial Version
**/
import { LightningElement, api } from 'lwc';
import BLN_LOGOHEAD from '@salesforce/resourceUrl/BLN_LOGOREDYELLOW';
import BLN_LOGO from '@salesforce/resourceUrl/BLN_AutoglassLogo';
import noAppt from "@salesforce/label/c.BLN_NoApptText";

export default class BLN_LoginMessagePageCompleted extends LightningElement {
    @api logoUrl;
    @api headUrl;


    label = { noAppt };

    connectedCallback() {
        this.logoUrl = BLN_LOGO;

        this.headUrl = BLN_LOGOHEAD;

    }
}