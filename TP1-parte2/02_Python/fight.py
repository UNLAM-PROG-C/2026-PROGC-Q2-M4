from fighter import Fighter
from enum import Enum
import random

class Fight_Status(Enum):
    PENDING = 1
    PROCESSING = 2
    FINISHED = 3
    FAILED = 4

class Round(Enum):
    QUARTERFINALS = 1
    SEMIFINALS = 2
    FINAL = 3

class FightAlreadyFinishedError(Exception):
    """Raised when the fight has already finished and wants to be started again."""
    pass

class Fight:
    """
    Represents a fight.
    """
    fighters: list[Fighter]
    winner: Fighter
    round: Round
    def __init__(self, fighter1: Fighter, fighter2: Fighter, round: Round):
        self.fighters = [fighter1, fighter2]
        self.fighters.sort(reverse=True, key=lambda f: (f.velocity, random.random()))
        self.round = round
        self.status = Fight_Status.PENDING
        
    def start(self) -> Fighter:
        if(self.status is Fight_Status.FINISHED):
            raise FightAlreadyFinishedError("Fight has already finished.") 

        self.status = Fight_Status.PROCESSING
        attacker = 0
        defender = 1
        while True:
            self.fighters[attacker].attack(self.fighters[defender])
            if not self.fighters[defender].is_alive():
                self.winner = self.fighters[attacker]
                break
            attacker = 1 if attacker == 0 else 0
            defender = 1 if attacker == 0 else 0
        self.status = Fight_Status.FINISHED
        return self.winner
'''
liu_kang = Fighter(name="Liu Kang", health=100, damage=25, defense=15, velocity=2, critical=0.25, blockage=0.25)
kung_lao = Fighter(name="Kung Lao", health=120, damage=30, defense=10, velocity=5, critical=0.05, blockage=0.05)

fight = Fight(liu_kang, kung_lao)

winner = fight.start()
print("Winner:", winner.name)
'''