# Global Rules

## Behavior
- Before making changes, briefly explain what you're about to do
- Make small, focused changes. Don't refactor unrelated code
- Ask before deleting files or making large structural changes
- If something is unclear, ask instead of guessing

## Git
- Never commit directly to main. Always use a branch
- Commit frequently at logical stopping points
- Never run `gh pr merge`. Merging is done by the human
- Never commit .env files or credentials
- Never run `git push --force` without confirmation

## Commit Messages
- Format: `<type>: <description in Japanese>`
- Types: feat / fix / docs / refactor / test / chore
- Example: `feat: ログイン機能を追加`
- Keep the first line under 50 characters

## Code Style
- Prefer simple and readable over clever
- Don't over-engineer. Match the existing style in the codebase
