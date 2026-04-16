# Memory Wake-Up Protocol

At the start of a new session, if the user appears to be continuing past work or references anything from a previous conversation:

1. Call `mempalace_wake_up` with no arguments
2. Review the returned context silently — do not recite it back to the user
3. Use it to inform your responses naturally, as if you were already familiar with the context

If `mempalace_wake_up` returns nothing, proceed normally. The user may be starting a fresh context.

## When to trigger wake-up

- User references "last time", "before", "we discussed", "you mentioned"
- User asks about an ongoing project by name
- User asks you to continue something
- The conversation is clearly a continuation of prior work

## When NOT to trigger wake-up

- Brand new topic with no reference to past work
- User explicitly says they want a fresh start
- System prompts already provide full context
