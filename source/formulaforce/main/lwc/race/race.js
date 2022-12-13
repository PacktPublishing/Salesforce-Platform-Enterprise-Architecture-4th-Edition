import { LightningElement, api } from 'lwc';

export default class Race extends LightningElement {

    // Public properties
    @api
    completed;
    @api
    raceId;
    @api
    name;
    @api
    location;
    @api
    raceDate;
    @api
    selected;

    // Internal properties
    get raceIcon() {
        return this.completed===true ? 'action:goal' : 'action:defer';
    }
    get raceStyle() {
        return this.selected===true ? 'selected' : ''
    }

    // Dispatch a custom event when the user clicks on a race
    raceClicked() {
        this.dispatchEvent(new CustomEvent('select', { detail: this.raceId }));
    }
}