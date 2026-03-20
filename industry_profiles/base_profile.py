"""
Abstract base for industry profiles.

Every industry (dental, med_spa, hvac, restoration, etc.) inherits from
IndustryProfile and provides its own system prompt, service keywords,
filler phrases, and knowledge-base categories.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Optional, Dict, List


@dataclass
class IndustryProfile:
    industry_type: str           # 'dental', 'med_spa', 'hvac', 'restoration'
    display_name: str            # "Medical Spa"
    agent_role: str              # "receptionist", "booking agent"
    business_noun: str           # "clinic", "spa", "company"
    appointment_noun: str        # "appointment", "treatment", "service call"
    services_noun: str           # "services", "treatments", "procedures"

    # System prompt template — uses {placeholders} filled at runtime
    system_prompt_template: str = ""

    # Extraction patterns for this industry
    service_keywords: Dict[str, str] = field(default_factory=dict)  # keyword → canonical service name
    emergency_keywords: List[str] = field(default_factory=list)     # words that trigger emergency routing

    # Slot detection patterns specific to this industry
    continuation_hints: List[str] = field(default_factory=list)     # phrases that suggest turn is incomplete

    # Post-booking questions specific to this industry
    post_booking_questions: List[str] = field(default_factory=list)

    # Filler phrases appropriate for this industry tone
    filler_phrases: Dict[str, List[str]] = field(default_factory=dict)

    # Knowledge base category names
    kb_categories: List[str] = field(default_factory=list)

    def get_system_prompt(self, **kwargs) -> str:
        """Format the system prompt template with runtime values."""
        return self.system_prompt_template.format(**kwargs)
