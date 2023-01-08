public interface IRaceService {
    
<<<<<<< HEAD
    Map<Id, List<RaceService.ProvisionalResult>> calculateProvisionResults(Set<Id> raceIds);
    
    void applyRaceResults(Map<Id, List<RaceService.ProvisionalResult>> provisionalResultsByRaceId);
=======
    Map<Id, List<RaceServiceResults.ProvisionalResult>> calculateProvisionResults(Set<Id> raceIds);
    
    void applyRaceResults(Map<Id, List<RaceServiceResults.ProvisionalResult>> provisionalResultsByRaceId);
>>>>>>> chapter-07
    
    void awardChampionshipPoints(Set<Id> raceIds);
}