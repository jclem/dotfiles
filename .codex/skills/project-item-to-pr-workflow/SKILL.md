---
name: project-item-to-pr-workflow
description: Convert GitHub Project draft items into issues, move them to In Progress, implement changes, and open a pull request that closes the issue.
---

# Project Item → Issue → PR workflow

Use this when a user asks to process one GitHub Project item end-to-end in `jclem/dotfiles` (project `10`).

## Assumptions

- Repository is `jclem/dotfiles`.
- Project is user project `10` (`https://github.com/users/jclem/projects/10`).
- `gh` is authenticated with `project` scope.

## Inputs

- `PROJECT_NUMBER=10`
- `OWNER=@me`
- `ITEM_IDENTIFIER` (item title, draft item `databaseId`, or `itemId`).

## 1) Convert draft item into a real issue

- Find ids:
  - `PROJECT_ID=$(gh project view "$PROJECT_NUMBER" --owner "$OWNER" --format json --jq .id)`
  - `REPO_ID=$(gh api graphql -f query='query { repository(owner:"jclem", name:"dotfiles") { id } }' --jq .data.repository.id)`

- Resolve project item id (use one of these):
  - By item title:
    - `ITEM_IDENTIFIER="FISH-002 - Gate Homebrew shellenv"`
    - `ITEM_ID=$(gh project item-list "$PROJECT_NUMBER" --owner "$OWNER" --format json --jq ".items[] | select(.content.title == \"$ITEM_IDENTIFIER\") | .id")`
  - By databaseId (example `158993693`):
    - `ITEM_ID=$(gh project item-list "$PROJECT_NUMBER" --owner "$OWNER" --format json --jq '.items[] | select(.databaseId == 158993693) | .id')`
  - By existing item id:
    - `ITEM_ID="PVTI_lAHO..."`

- Convert draft item:
  - `INPUT='{\"itemId\":\"'$ITEM_ID'\",\"repositoryId\":\"'$REPO_ID'\"}'`
  - `gh api graphql -f query='mutation ($input: ConvertProjectV2DraftIssueItemToIssueInput!) { convertProjectV2DraftIssueItemToIssue(input: $input) { item { id content { ... on Issue { number title url } } } } }' -f input="$INPUT"`

- Capture issue number:
  - `ISSUE_NUMBER=$(gh project item-list "$PROJECT_NUMBER" --owner "$OWNER" --format json --jq ".items[] | select(.id == \"$ITEM_ID\") | .content.number")`

## 2) Mark item as In Progress

- Resolve status ids:
  - `STATUS_FIELD_ID=$(gh project field-list "$PROJECT_NUMBER" --owner "$OWNER" --format json --jq '.fields[] | select(.name=="Status").id')`
  - `IN_PROGRESS_ID=$(gh project field-list "$PROJECT_NUMBER" --owner "$OWNER" --format json --jq '.fields[] | select(.name=="Status").options[] | select(.name=="In Progress").id')`

- Update status:
  - `gh project item-edit --id "$ITEM_ID" --project-id "$PROJECT_ID" --field-id "$STATUS_FIELD_ID" --single-select-option-id "$IN_PROGRESS_ID"`

## 3) Implement

- Create a branch and commit your implementation changes:
  - `git checkout -b <branch-name>`
  - `git add <files>`
  - `git commit -m "<short summary>"`
  - `git push -u origin HEAD`

## 4) Open PR and link the issue

- Open PR with explicit issue closure:
  - `gh pr create --repo jclem/dotfiles --title "<title>" --body "Fixes #$ISSUE_NUMBER."`

- If you need richer body text, include the same line anywhere in the body:
  - `Fixes #$ISSUE_NUMBER.`

## End state

- PR body contains `Fixes #$ISSUE_NUMBER`.
- The project item is linked to issue `#$ISSUE_NUMBER` and is not merely a draft anymore.
