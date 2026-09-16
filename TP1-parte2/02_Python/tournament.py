"""Defines the classes and logic for simulating a tournament."""
import enum
import random

from fight import Fight, Round
from fighter import Fighter


class TournamentAlreadyFinishedError(Exception):
    """Raised when a finished tournament is started again."""


class TournamentStatus(enum.Enum):
    """The lifecycle status of a tournament."""
    PENDING = 1
    PROCESSING = 2
    FINISHED = 3
    FAILED = 4


class Tournament:
    """Represents a single-elimination tournament between eight fighters.

    Attributes:
        fighters: The eight fighters selected for this tournament.
        fights: The fights played so far, in chronological order.
        status: The current lifecycle status of the tournament.
        winner: The tournament champion, set once it finishes.
    """

    fighters: list[Fighter]
    fights: list[Fight]

    def __init__(self, candidates: list[Fighter]) -> None:
        selected = random.sample(candidates, k=8)
        self.fighters = [
            fighter.model_copy(deep=True) for fighter in selected
        ]
        self.fights = []
        self.status = TournamentStatus.PENDING

    def run(self) -> Fighter:
        """Plays out every round of the tournament.

        Returns:
            The fighter that won the tournament.
        """
        current_fighters = self.fighters
        current_round = 1
        while len(current_fighters) != 1:
            next_round = []
            for i in range(0, len(current_fighters), 2):
                fight = Fight(
                    current_fighters[i], current_fighters[i + 1],
                    Round(current_round))
                winner = fight.start()
                self.fights.append(fight)
                next_round.append(winner)
            current_fighters = next_round
            current_round += 1
        return winner

    def start(self) -> None:
        """Runs the tournament.

        Raises:
            TournamentAlreadyFinishedError: If the tournament has already
                finished.
        """
        if self.status is TournamentStatus.FINISHED:
            raise TournamentAlreadyFinishedError(
                "Tournament has already finished.")
        self.status = TournamentStatus.PROCESSING
        self.winner = self.run()
        self.status = TournamentStatus.FINISHED
