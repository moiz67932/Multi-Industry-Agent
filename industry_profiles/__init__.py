"""
Industry profile system for multi-industry AI receptionist platform.
"""

from .profile_registry import get_profile, PROFILE_REGISTRY
from .base_profile import IndustryProfile

__all__ = [
    "IndustryProfile",
    "get_profile",
    "PROFILE_REGISTRY",
]
