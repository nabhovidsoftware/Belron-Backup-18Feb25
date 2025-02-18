/** @description :  This component is part of the lad_builderProductPurchaseOptions component.
*   @Story :        FOUK-9051; FOUK-8454; FOUK-8231; FOUK-8232; FOUK-8230; FOUK-7684; FOUK-8367
*   @author:        (binayak.debnath@pwc.com (IN))
*   @CreatedDate:   22-05-2024
*/
import { api, LightningElement } from 'lwc';
import {
    generateButtonSizeClass,
    generateButtonStretchClass,
    generateButtonStyleClass,
    generateElementAlignmentClass,
} from 'experience/styling';

export default class Lad_commonButton extends LightningElement {

    static renderMode = 'light';
    @api
    disabled = false;

    /**
     * The assistive text for the button.
     * @type {?string}
     */
    @api
    assistiveText;

    /**
     * The button variant.
     * @type {?('primary' | 'secondary' | 'tertiary')}
     */
    @api
    variant;

    /**
     * The button size.
     * @type {?('small' | 'large')}
     */
    @api
    size;

    /**
     * The width of the button.
     * @type {?('stretch' | 'standard')}
     */
    @api
    width;

    /**
     * The alignment of the content inside the button.
     * @type {?('center' | 'left' | 'right')}
     */
    @api
    alignment;

    @api
    focus() {
        this.querySelector('button')?.focus();
    }
    get buttonClasses() {
        return [
            'slds-button',
            generateButtonStyleClass(this.variant ?? null),
            generateButtonSizeClass(this.size ?? null),
            generateButtonStretchClass(this.width ?? null),
            generateElementAlignmentClass(this.alignment ?? null),
        ].join(' ');
    }
}