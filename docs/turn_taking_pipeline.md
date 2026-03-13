# Turn-Taking Pipeline

This agent now uses a lightweight 3-layer turn-taking policy on top of the existing LiveKit STT -> LLM -> TTS pipeline.

## Layers

1. Streaming turn tracker
   - Lives in `utils/turn_taking.py`
   - Updates from partial and final `user_input_transcribed` events
   - Tracks:
     - raw and normalized partial text
     - latest finalized text
     - accumulated current-turn text across fragmented speech
     - caller name, intent, service, date, and time with heuristic confidence
     - whether the utterance looks incomplete or actionable
     - whether filler already played this turn
     - whether a deterministic next question or lookup path is available

2. Completion classifier
   - Emits one of:
     - `INCOMPLETE`
     - `LIKELY_CONTINUING`
     - `COMPLETE`
     - `COMPLETE_AND_ACTIONABLE`
   - Uses more than silence alone:
     - self-introduction prefixes like `this is`
     - request lead-ins like `I wanted to`
     - trailing incomplete phrases like `tomorrow at`
     - extracted slots and intent confidence

3. Response policy
   - Lives in `utils/turn_taking.py` and is executed from `agent.py`
   - Decisions:
     - wait for continuation
     - deterministic fast-path response
     - direct backend lookup with contextual bridge filler
     - LLM/default path

## Current fast paths

- Booking
  - service missing -> ask which service
  - service known, date/time missing -> ask for day and time
  - service + date known, time missing -> ask for time
  - service + time known, date missing -> ask for day

- Reschedule / cancellation
  - missing caller identifier -> ask for phone or name
  - caller identifier available -> direct `find_existing_appointment` lookup path

- Existing appointment lookup
  - caller phone available -> direct lookup path
  - caller phone missing -> ask for phone number

- General tooth issue
  - safe clarification: `Can you tell me a little more about the issue?`

## Filler behavior

- Filler is suppressed when the classifier says `INCOMPLETE` or `LIKELY_CONTINUING`
- Deterministic fast paths skip filler entirely
- Lookup-heavy turns can use a short bridge like `Let me check that for you.`
- If filler already played, deterministic and LLM responses should continue without repeating another acknowledgement

## Key config knobs

Defined in `config.py`:

- `TURN_TRACKER_ENABLED`
- `DETERMINISTIC_FAST_PATH_ENABLED`
- `TURN_SHORT_PAUSE_MS`
- `TURN_CONTINUATION_WAIT_MS`
- `TURN_LOW_CONFIDENCE_THRESHOLD`
- `LOOKUP_FILLER_DELAY_MS`
- existing filler controls:
  - `FILLER_ENABLED`
  - `FILLER_DEBOUNCE_MS`
  - `FILLER_MAX_MS`

## Extending fast paths

Add new deterministic flows in `StreamingTurnTracker._populate_deterministic_route`.

Guidelines:

- prefer high-confidence, receptionist-safe follow-up questions
- keep responses short and natural
- if confidence is low, leave `deterministic_response` unset and fall back to the LLM
- for backend work, prefer a direct tool path only when the next step is obvious and low-risk
