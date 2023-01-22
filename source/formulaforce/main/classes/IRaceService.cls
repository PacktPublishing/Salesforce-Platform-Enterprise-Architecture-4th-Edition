public interface IRaceService {
    
    Map<Id, List<RaceServiceResults.ProvisionalResult>> calculateProvisionResults(Set<Id> raceIds);
    
    void applyRaceResults(Map<Id, List<RaceServiceResults.ProvisionalResult>> provisionalResultsByRaceId);
    
    void awardChampionshipPoints(Set<Id> raceIds);
    
	String generateSummaryAsCSV(Set<Id> raceIds);    
}