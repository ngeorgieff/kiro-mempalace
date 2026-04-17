# Session Workflow

Step-by-step guide for using MemPalace throughout a Kiro session.

## Session Start

When a new session begins, immediately load palace context:

1. Call `mempalace_status` to get the palace overview
2. Call `mempalace_list_wings` to see which projects have stored memory
3. Note the current workspace name — this is your primary wing for filtering

This takes under a second and gives you full awareness of what memory exists.

## Mid-Session — Answering Memory Questions

When the user references past work:

1. Identify keywords from their question
2. Call `mempalace_search` with:
   - `query`: short keyword-focused search terms
   - `wing`: current workspace name (always filter when known)
   - `room`: topic area if clear from context (e.g., "decisions", "bugs")
3. Present the search results naturally in your answer
4. Never fabricate past context — if search returns nothing, say so

### Examples

User says: "What did we decide about the auth approach?"
```
mempalace_search(query="auth approach decision", wing="my-project", room="decisions")
```

User says: "Remind me about that bug we fixed last week"
```
mempalace_search(query="bug fix", wing="my-project", room="bugs")
```

## After Significant Events — Save Context

After any of these, propose saving to the palace:

- Architecture decision made
- Bug fix with root cause identified
- Configuration change applied
- Design pattern chosen
- Trade-off discussed and resolved

### How to Save

1. Summarize the decision/change concisely but completely
2. Choose the right wing (workspace name) and room (topic)
3. Present the proposed `mempalace_add_drawer` call
4. Wait for user approval — never auto-execute writes

### Room Selection Guide

| Event Type | Suggested Room |
|-----------|---------------|
| Architecture decision | `architecture` or `decisions` |
| Bug fix | `bugs` |
| Config change | `config` |
| API design | `api` |
| Frontend decision | `frontend` |
| Backend decision | `backend` |
| General discussion | `general` |

## Session End

If the session involved significant decisions or context:

1. Summarize what was accomplished
2. Propose saving key decisions via `mempalace_add_drawer`
3. Optionally write a diary entry via `mempalace_diary_write` in AAAK format

The "Save to MemPalace" hook button can also be used to trigger this manually.
