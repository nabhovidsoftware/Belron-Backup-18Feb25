/** @description :  This component is part of the lad_builderProductPurchaseOptions component.
*   @Story :        FOUK-9051; FOUK-8454; FOUK-8231; FOUK-8232; FOUK-8230; FOUK-7684; FOUK-8367
*   @author:        (binayak.debnath@pwc.com (IN))
*   @CreatedDate:   22-05-2024
*/
import { ERROR_RANGE_OVERFLOW, ERROR_RANGE_UNDERFLOW, STEP_MISMATCH, PATTERN_MISMATCH } from 'c/lad_commonNumberInput';
import { patternMismatch, rangeOverflow, rangeUnderflow, stepMismatch } from './lad_labels';
export const VALUE_CHANGED_EVT = 'valuechanged';
export const VALIDITY_CHANGED_EVT = 'validitychanged';
export const OUT_OF_STOCK_EVT = 'outofstock';
export const errorLabels = {
    [ERROR_RANGE_OVERFLOW]: rangeOverflow,
    [ERROR_RANGE_UNDERFLOW]: rangeUnderflow,
    [STEP_MISMATCH]: stepMismatch,
    [PATTERN_MISMATCH]: patternMismatch,
};
export const defaultRules = {
    minimum: 1,
    maximum: 100000000,
    step: 1,
};