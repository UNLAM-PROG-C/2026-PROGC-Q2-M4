from fighter import Fighter
from fight import Fight, Round
from enum import Enum
import random

class TournamentAlreadyFinishedError(Exception):
    """Raised when the tournament has already finished and wants to be started again."""
    pass

class Tournament_Status(Enum):
    PENDING = 1
    PROCESSING = 2
    FINISHED = 3
    FAILED = 4

class Tournament:
    """
    Represents a tournament.
    """
    fighters: list[Fighter]
    fights: list[Fight]

    def __init__(self, candidates: list[Fighter]) -> None:
        selected = random.sample(candidates, k=8)
        self.fighters = [fighter.model_copy(deep=True) for fighter in selected]
        self.fights = []
        self.status = Tournament_Status.PENDING

    def run(self) -> Fighter:
        current_fighters = self.fighters
        round = 1
        while(current_fighters.__len__() != 1):
            next_round = []
            fighters_len = current_fighters.__len__()
            for i in range(0, fighters_len, 2):
                fight = Fight(current_fighters[i], current_fighters[i+1], Round(round))
                winner = fight.start()
                self.fights.append(fight)
                next_round.append(winner)
            current_fighters = next_round
            round+=1
        return winner
    
    def start(self):
        if (self.status is Tournament_Status.FINISHED):
            raise TournamentAlreadyFinishedError("Tournament has already finished.") 
        self.status = Tournament_Status.PROCESSING
        self.winner = self.run()
        self.status = Tournament_Status.FINISHED
