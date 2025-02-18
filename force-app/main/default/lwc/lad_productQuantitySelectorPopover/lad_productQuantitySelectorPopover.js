/** @description :  This component is part of the lad_builderProductPurchaseOptions component.
*   @Story :        FOUK-9051; FOUK-8454; FOUK-8231; FOUK-8232; FOUK-8230; FOUK-7684; FOUK-8367
*   @author:        (binayak.debnath@pwc.com (IN))
*   @CreatedDate:   22-05-2024
*/
import { LightningElement, api } from 'lwc';
import { closeButtonText, quantityHelpLabel } from './lad_labels';

/**
 * @param {string} [text] The text/value to check
 * @returns {boolean} Whether the given text is neither `undefined`, `null`, nor empty.
 */
function isNotBlank(text) {
    return typeof text === 'string' && text.trim().length > 0;
}

export default class Lad_productQuantitySelectorPopover extends LightningElement {
    static renderMode = 'light';

    /**
     * Gets or sets the Minimum Text
     * @type {string}
     */
    @api
    minimumText;

    /**
     * Gets or sets the Maximum Text
     * @type {string}
     */
    @api
    maximumText;

    /**
     * Gets or sets the Increment Text
     * @type {string}
     */
    @api
    incrementText;

    /**
     * Shows/opens the popup.
     * @private
     */
    openPopup() {
        this.popup?.open({
            alignment: 'top',
            autoFlip: true,
            size: 'small',
        });
    }

    /**
     * Closes/hides the popup.
     * @private
     */
    closePopup() {
        this.popup?.close();
    }

    /**
     * Gets the popup-source
     * @returns {?HTMLElement} The popup source element
     * @readonly
     * @private
     */
    get popup() {
        return this.querySelector('experience-popup-source');
    }

    /**
     * Whether to display the increment text.
     * @type {boolean}
     * @readonly
     * @private
     */
    get showIncrementText() {
        return isNotBlank(this.incrementText);
    }

    /**
     * Whether to display the maximum text.
     * @type {boolean}
     * @readonly
     * @private
     */
    get showMaxText() {
        return isNotBlank(this.maximumText);
    }

    /**
     * Whether to display the minimum text.
     * @type {boolean}
     * @readonly
     * @private
     */
    get showMinText() {
        return isNotBlank(this.minimumText);
    }

    /**
     * Gets the i18n labels to display in the template
     * @type {object}
     * @readonly
     * @private
     */
    get i18n() {
        return {
            closeButtonText,
            quantityHelpLabel,
        };
    }
}