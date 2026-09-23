"""Defines the classes and logic for fighters in the tournament."""
import random

from pydantic import BaseModel, Field


class FighterAutoDamagingError(Exception):
    """Raised when the fighter wants to attack itself."""


class FighterIsNotAliveError(Exception):
    """Raised when a dead fighter tries to attack."""


class Fighter(BaseModel):
    """Represents a fighter with attributes like health, damage and defense.

    Attributes:
        name: The fighter's name.
        health: The fighter's current health points.
        damage: The base damage dealt on a successful attack.
        defense: Reduces the damage received from an attack.
        velocity: Determines who attacks first in a fight.
        critical: Probability of dealing double damage on a hit.
        blockage: Probability of blocking an incoming attack entirely.
    """

    name: str
    health: int = Field(ge=80, le=120)
    damage: int = Field(ge=15, le=30, frozen=True)
    defense: int = Field(ge=5, le=15, frozen=True)
    velocity: int = Field(ge=1, le=10, frozen=True)
    critical: float = Field(ge=0.05, le=0.25, frozen=True)
    blockage: float = Field(ge=0.05, le=0.25, frozen=True)
    _max_health: int

    def __init__(self, name: str, health: int, damage: int, defense: int,
                 velocity: int, critical: float, blockage: float,
                 **kwargs) -> None:
        super().__init__(
            name=name, health=health, damage=damage, defense=defense,
            velocity=velocity, critical=critical, blockage=blockage,
            **kwargs)
        self._max_health = health

    def is_alive(self) -> bool:
        """Returns whether the fighter still has health points left."""
        return self.health > 0

    def block(self) -> bool:
        """Returns whether the fighter blocks an incoming attack."""
        return random.choices(
            [True, False], weights=[self.blockage, 1 - self.blockage],
            k=1)[0]

    def is_critical(self) -> bool:
        """Returns whether the fighter's next hit is a critical hit."""
        return random.choices(
            [True, False], weights=[self.critical, 1 - self.critical],
            k=1)[0]

    def heals(self) -> None:
        """Restores the fighter's health to its maximum value."""
        self.health = self._max_health

    def receive_damage(self, damage_points: int, is_critical: bool) -> None:
        """Applies incoming damage to the fighter's health.

        Args:
            damage_points: The attacker's base damage, before defense.
            is_critical: Whether the hit is a critical hit.
        """
        final_damage = max(1, damage_points - self.defense)
        final_damage = final_damage * 2 if is_critical else final_damage
        if self.health > final_damage:
            self.health -= final_damage
        else:
            self.health = 0

    def attack(self, rival: "Fighter") -> bool:
        """Attacks a rival fighter.

        Args:
            rival: The fighter being attacked.

        Returns:
            True if the attack landed, False if the rival blocked it.

        Raises:
            FighterIsNotAliveError: If this fighter is no longer alive.
            FighterAutoDamagingError: If the rival is this same fighter.
        """
        if not self.is_alive():
            raise FighterIsNotAliveError("A dead fighter cannot attack.")
        if rival is self:
            raise FighterAutoDamagingError(
                "The fighter cannot attack itself.")

        if rival.block():
            return False

        rival.receive_damage(self.damage, self.is_critical())
        return True

    def __hash__(self) -> int:
        return hash(self.name)

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, Fighter):
            return NotImplemented
        return self.name == other.name
