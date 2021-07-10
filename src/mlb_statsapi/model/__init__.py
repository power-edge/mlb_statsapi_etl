"""
created by nikos at 4/21/21
"""
from .api_docs import ApiDocsModel
from .api import (
    AwardsModel,
    BroadcastModel,
    ConferenceModel,
    ConfigModel,
    DivisionModel,
    DraftModel,
    GameModel,
    GamepaceModel,
    HighLowModel,
    HomeRunDerbyModel,
    JobModel,
    LeagueModel,
    MilestonesModel,
    PersonModel,
    ScheduleModel,
    SeasonModel,
    SportsModel,
    StandingsModel,
    StatsModel,
    StreaksModel,
    TeamModel
)


class StatsAPI:
    ApiDocs = ApiDocsModel.from_doc()
    Awards = AwardsModel.from_doc()
    Broadcast = BroadcastModel.from_doc()
    Conference = ConferenceModel.from_doc()
    Config = ConfigModel.from_doc()
    Division = DivisionModel.from_doc()
    Draft = DraftModel.from_doc()
    Game = GameModel.from_doc()
    Gamepace = GamepaceModel.from_doc()
    HighLow = HighLowModel.from_doc()
    HomeRunDerby = HomeRunDerbyModel.from_doc()
    Job = JobModel.from_doc()
    League = LeagueModel.from_doc()
    Milestones = MilestonesModel.from_doc()
    Person = PersonModel.from_doc()
    Schedule = ScheduleModel.from_doc()
    Season = SeasonModel.from_doc()
    Sports = SportsModel.from_doc()
    Standings = StandingsModel.from_doc()
    Stats = StatsModel.from_doc()
    Streaks = StreaksModel.from_doc()
    Team = TeamModel.from_doc()

    ALL = [
        ApiDocs,
        Awards,
        Broadcast,
        Conference,
        Config,
        Division,
        Draft,
        Game,
        Gamepace,
        HighLow,
        HomeRunDerby,
        Job,
        League,
        Milestones,
        Person,
        Schedule,
        Season,
        Sports,
        Standings,
        Stats,
        Streaks,
        Team,
    ]

