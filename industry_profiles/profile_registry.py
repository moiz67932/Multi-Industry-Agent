"""
Industry profile registry.

Central lookup for all registered industry profiles.
New industries are added here by importing their builder and registering.
"""

from __future__ import annotations

from .base_profile import IndustryProfile
from .dental_profile import build_dental_profile
from .med_spa_profile import build_med_spa_profile


PROFILE_REGISTRY: dict[str, IndustryProfile] = {
    "dental": build_dental_profile(),
    "med_spa": build_med_spa_profile(),
}


def get_profile(industry_type: str) -> IndustryProfile:
    """Return the profile for the given industry_type, defaulting to dental."""
    return PROFILE_REGISTRY.get(industry_type, PROFILE_REGISTRY["dental"])
