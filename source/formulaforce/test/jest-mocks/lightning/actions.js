/**
 * Close Screen Action Event base class
 */
export const CloseActionScreenEventName = 'lightning__actionsclosescreen';

export class CloseActionScreenEvent extends CustomEvent {
    constructor() {
        super(CloseActionScreenEventName, { bubbles: false, composed: false });
    }
}