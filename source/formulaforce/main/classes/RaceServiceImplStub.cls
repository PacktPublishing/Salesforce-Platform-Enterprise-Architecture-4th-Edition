public inherited sharing class RaceServiceImplStub implements IRaceService {
    
    public Map<Id, List<RaceServiceResults.ProvisionalResult>> calculateProvisionResults(Set<Id> raceIds) {
        
        // Dummy behaviour to allow the client to be developed 
        //    independent of the main service implementation 
        Id raceId = new List<Id>(raceIds)[0];
        RaceServiceResults.ProvisionalResult hamilton = new RaceServiceResults.ProvisionalResult();
        hamilton.racePosition = 1;
        hamilton.contestantName = 'Lewis Hamilton';
        hamilton.contestantId = 'a03b0000006WVph';
        RaceServiceResults.ProvisionalResult rubens = new RaceServiceResults.ProvisionalResult();
        rubens.racePosition = 2;
        rubens.contestantName = 'Rubens Barrichello';
        rubens.contestantId = 'a03b00000072xx9';
        return new Map<Id, List<RaceServiceResults.ProvisionalResult>> {
                new List<Id>(raceIds)[0] => 
                    new List<RaceServiceResults.ProvisionalResult> { hamilton, rubens } };
    }

    public void applyRaceResults(Map<Id, List<RaceServiceResults.ProvisionalResult>> provisionalResultsByRaceId) {
        throw new RaceServiceException('Not implemented');
    }

    public void awardChampionshipPoints(Set<Id> raceIds) {
        throw new RaceServiceException('Not implemented');
    }    
}