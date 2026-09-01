# Pi worker profiles

Use these defaults unless the dispatch names an override.

| Role | Pi model | Thinking |
|---|---|---|
| Explore | `openai-codex/gpt-5.6-sol` | `medium` |
| Implement | `openai-codex/gpt-5.6-sol` | `medium` |
| Review | `openai-codex/gpt-5.6-sol` | `high` |
| Judgment | `openai-codex/gpt-5.6-sol` | `xhigh` |

All four profiles use the same GPT model family. A higher thinking level does not supply model-family diversity. Label fresh reviews from these profiles `same-family independent review`.
