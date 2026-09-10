from fighter import Fighter
from fight import Fight, Round
from enum import Enum
import random

_FIGHTERS = [
    Fighter("Liu Kang", 100, 25, 10, 8, 0.20, 0.15),
    Fighter("Kung Lao", 95, 26, 8, 9, 0.25, 0.10),
    Fighter("Johnny Cage", 110, 22, 12, 7, 0.15, 0.20),
    Fighter("Reptile", 90, 24, 9, 10, 0.20, 0.25),
    Fighter("Sub-Zero", 105, 23, 14, 6, 0.10, 0.25),
    Fighter("Shang Tsung", 85, 30, 5, 8, 0.25, 0.05),
    Fighter("Kitana", 85, 27, 7, 10, 0.20, 0.15),
    Fighter("Jax", 120, 20, 15, 4, 0.10, 0.25),
    Fighter("Mileena", 90, 28, 6, 9, 0.25, 0.10),
    Fighter("Baraka", 115, 29, 8, 5, 0.25, 0.05),
    Fighter("Scorpion", 100, 26, 11, 7, 0.20, 0.15),
    Fighter("Raiden", 110, 24, 10, 8, 0.15, 0.20)
]

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

    def __init__(self) -> None:
        selected = random.sample(_FIGHTERS, k=8)
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
