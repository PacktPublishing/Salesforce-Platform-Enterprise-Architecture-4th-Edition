public with sharing class RaceService {
    
	public static Map<Id, List<RaceServiceResults.ProvisionalResult>> calculateProvisionResults(Set<Id> raceIds) {
		return service().calculateProvisionResults(raceIds);
	}

	public static void applyRaceResults(Map<Id, List<RaceServiceResults.ProvisionalResult>> provisionalResultsByRaceId) {
		service().applyRaceResults(provisionalResultsByRaceId);
	}

	public static void awardChampionshipPoints(Set<Id> raceIds) {
		service().awardChampionshipPoints(raceIds);
	}

	private static IRaceService service() {
		return (IRaceService) Application.Service.newInstance(IRaceService.class);
	}
}