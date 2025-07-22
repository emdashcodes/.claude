---
description: Spec: Requirements Gathering
allowed-tools: Bash, Read, Write, Edit, MultiEdit, Glob, Grep, LS
---

# Spec: Requirements Gathering

Your goal is to generate an initial set of requirements in EARS (Easy Approach to Requirements Syntax) format based on the feature idea, then iterate with the user to refine them until they are complete and accurate.

Get a brief understanding of the codebase from README.MD and any other related documentation but don't focus on code exploration in this phase. Instead, just focus on writing requirements which will later be turned into a design.

## EARS (Easy Approach to Requirements Syntax) Overview

EARS categorizes requirements into five types, each with a specific template:

### 1. Ubiquitous Requirements (Always Active)

- **Template**: "The <system name> shall <system response>"
- **Example**: "The system shall encrypt all stored user data using AES-256"
- **Use for**: Core behaviors, security requirements, constant constraints

### 2. Event-Driven Requirements (Triggered by Events)

- **Template**: "When <trigger> the <system name> shall <system response>"
- **Example**: "When the user submits a form, the system shall validate all required fields"
- **Use for**: User interactions, system events, external triggers

### 3. State-Driven Requirements (Active in Specific States)

- **Template**: "While <in a specific state> the <system name> shall <system response>"
- **Example**: "While the system is in maintenance mode, the system shall display a maintenance message to users"
- **Use for**: Mode-dependent behaviors, conditional operations

### 4. Unwanted Behavior Requirements (Error Handling)

- **Template**: "If <unwanted condition>, then the <system name> shall <system response>"
- **Example**: "If the database connection fails, then the system shall queue the transaction and retry every 30 seconds"
- **Use for**: Error conditions, exception handling, failure recovery

### 5. Optional Feature Requirements (Conditional Features)

- **Template**: "Where <feature is included> the <system name> shall <system response>"
- **Example**: "Where two-factor authentication is enabled, the system shall require a verification code after password entry"
- **Use for**: Feature toggles, configuration-dependent behavior, optional modules

## Constraints

- You MUST create spec files using the following path pattern: `.claude/specs/{feature_name}/requirements.md`
- You MUST generate first draft of the requirements document based on the user's rough idea WITHOUT asking sequential questions first
- You MUST format the initial requirements.md document with:
  - A clear introduction section that summarizes the feature
  - A hierarchical numbered list of requirements where each contains:
    - A user story in the format "As a [role], I want [feature], so that [benefit]"
    - A numbered list of acceptance criteria in EARS format. Note: Not every requirement needs all 5 patterns - use only the patterns that apply:
      - Use Ubiquitous for always-active behaviors
      - Use Event-Driven for user actions and system triggers
      - Use State-Driven for mode-specific behaviors
      - Use Unwanted Behavior for error handling
      - Use Optional Feature for configurable functionality
      - You MUST NOT include the pattern name in the requirement description
- You SHOULD consider edge cases, user experience, technical constraints, and success criteria in the initial requirements
- After updating the requirement document, you MUST ask the user IN CHAT "Do the requirements look good? If so, we can move on to the design."
- You MUST make modifications to the requirements document if the user requests changes or does not explicitly approve
- You MUST ask for explicit approval after every iteration of edits to the requirements document
- You MUST NOT proceed to the design document until receiving clear approval (such as "yes", "approved", "looks good", etc.)
- You MUST continue the feedback-revision cycle until explicit approval is received
- You MUST check if a design.md already exists for this feature and warn the user if changes to requirements may impact the existing design
- When modifying existing requirements, you MUST note which sections of the design document may need updates and ask the user if they would like to update those sections
- You SHOULD suggest specific areas where the requirements might need clarification or expansion
- You MAY ask targeted questions about specific aspects of the requirements that need clarification
- You MAY suggest options when the user is unsure about a particular aspect
- Ask the user to proceed to the design phase after the user accepts the requirements

## Example Requirements Document Structure

<example1>
### Example: User Authentication Feature

**User Story**: As a user, I want to securely log into the system, so that I can access my personal data

**Acceptance Criteria**:

1. The system shall store passwords using bcrypt hashing with a minimum of 10 rounds
2. When the user submits login credentials, the system shall validate them within 2 seconds
3. When the user enters an incorrect password, the system shall increment the failed attempt counter
4. If the user exceeds 5 failed login attempts, then the system shall lock the account for 15 minutes
</example1>

<example2>
### Example: File Upload Feature

**User Story**: As a content creator, I want to upload images to my posts, so that I can share visual content

**Acceptance Criteria**:

1. When the user selects a file, the system shall validate the file type is PNG, JPG, or GIF
2. When the user uploads a file larger than 10MB, the system shall display a size limit error
3. While a file is uploading, the system shall display a progress indicator
4. If the upload fails due to network error, then the system shall allow retry with resume capability
5. Where image optimization is enabled, the system shall compress images to under 1MB while maintaining 80% quality
</example2>

<example3>
### Example: Search Functionality

**User Story**: As a user, I want to search for products by name, so that I can quickly find what I need

**Acceptance Criteria**:

1. When the user types in the search box, the system shall display suggestions after 3 characters
2. When the user submits a search query, the system shall return results within 500ms
3. The system shall support wildcard searches using * and ? characters
</example3>
