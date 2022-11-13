import { LightningElement, track } from 'lwc';
import { getRaces } from 'data/races'; 

export default class App extends LightningElement {
    races = '';
    connectedCallback() {
        getRaces().then((result) => {
            console.log(result);
            this.races = result;
        });
    }
}
