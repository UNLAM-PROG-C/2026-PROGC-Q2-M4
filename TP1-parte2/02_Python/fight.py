"""Defines the classes and logic for a single fight between two fighters."""
import enum
import random

from fighter import Fighter


class FightStatus(enum.Enum):
    """The lifecycle status of a fight."""
    PENDING = 1
    PROCESSING = 2
    FINISHED = 3
    FAILED = 4


class Round(enum.Enum):
    """The stage of the tournament a fight belongs to."""
    QUARTERFINALS = 1
    SEMIFINALS = 2
    FINAL = 3


class FightAlreadyFinishedError(Exception):
    """Raised when a finished fight is started again."""


class Fight:
    """Represents a fight between two fighters.

    Attributes:
        fighters: The two fighters, sorted by who attacks first.
        winner: The fighter that won the fight, set once it finishes.
        round: The tournament stage this fight belongs to.
        total_turns: The number of turns the fight lasted.
        status: The current lifecycle status of the fight.
    """

    fighters: list[Fighter]
    winner: Fighter
    round: Round

    def __init__(self, fighter1: Fighter, fighter2: Fighter,
                 round_: Round) -> None:
        self.fighters = [fighter1, fighter2]
        self.fighters.sort(
            reverse=True, key=lambda f: (f.velocity, random.random()))
        self.round = round_
        self.total_turns = 0
        self.status = FightStatus.PENDING

    def run(self) -> None:
        """Simulates turns until one of the fighters is defeated."""
        attacker, defender = 0, 1
        while True:
            self.fighters[attacker].attack(self.fighters[defender])
            if not self.fighters[defender].is_alive():
                self.winner = self.fighters[attacker]
                break
            attacker, defender = defender, attacker
            self.total_turns += 1

    def start(self) -> Fighter:
        """Runs the fight and heals its winner.

        Returns:
            The fighter that won the fight.

        Raises:
            FightAlreadyFinishedError: If the fight has already finished.
        """
        if self.status is FightStatus.FINISHED:
            raise FightAlreadyFinishedError("Fight has already finished.")
        self.status = FightStatus.PROCESSING
        self.run()
        self.winner.heals()
        self.status = FightStatus.FINISHED
        return self.winner
