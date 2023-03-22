import { LightningElement, api } from 'lwc';
import LightningAlert from 'lightning/alert';
import getCSVContent from '@salesforce/apex/RaceSummaryController.getCSVContent';

export default class RaceDownloadCSV extends LightningElement {
    @api recordId;
    @api async invoke() {
        getCSVContent({ raceId: this.recordId })
            .then(result => {
                var link=document.createElement('a');
                link.href = 'data:text/csv;charset=utf-8,' + encodeURI(result);
                link.target="_blank";
                link.download = 'raceSummary.csv';
                link.click();        
            })
            .catch(error => {
                LightningAlert.open({
                    message: error,
                    theme: 'error',
                    label: 'Error!',
                });        
            });        
    }
}