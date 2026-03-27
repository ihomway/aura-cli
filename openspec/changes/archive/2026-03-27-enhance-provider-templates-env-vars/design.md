## Context

aura-cli is a terminal UI tool built on TauTUI. All UI lives in `AppComponent.swift` using plain text rendering and keyboard handling. The current provider add/edit form renders exactly 8 hardcoded fields (name, base URL, auth token, haiku/sonnet/opus model, disable-traffic, timeout) and maps them to 8 fixed env var keys. There is no mechanism for users to configure any of the ~60 other Claude Code environment variables that Claude Code supports.

The Prism macOS app (a SwiftUI counterpart managing the same `~/.claude/settings.json`) already has `ClaudeEnvVariable.allVariables` defining all variables with categories, types, and descriptions. We will port that catalogue into aura-cli and build a TUI picker screen that lets users add any variable to a provider.

## Goals / Non-Goals

**Goals:**
- Sync provider templates with Prism's full `allTemplates` list (add 9 missing providers)
- Add `ClaudeEnvVariable` and `ClaudeEnvCategory` catalogue to Models.swift
- Extend the form to support a dynamic extra-env-vars list (beyond the 8 core fields)
- Add an `[+ Add env var]` button on forms that navigates to a new `envVarPicker` screen
- The picker screen supports category-based navigation (9 categories as tabs) and item selection
- Selecting a variable adds it to the form's extra-env-vars list and returns to the form

**Non-Goals:**
- Editing the picker categories or adding custom env var names not in the catalogue (users can still type a value once a variable is selected)
- Sorting, filtering, or searching within the picker (out of scope for v1)
- Syncing extra env vars from Prism or any other source at startup

## Decisions

### 1. Represent extra env vars as `[(key: String, value: String)]` array on AppComponent

The core 8 fields stay in `formValues[0...7]` for minimal disruption. Extra env vars are stored as a separate ordered array `extraEnvVars: [(key: String, value: String)]` on `AppComponent`. This avoids changing the fixed-index mapping that `buildEnvVars()` and `loadFormForAdd/Edit` rely on, minimising risk of regressions.

**Alternative**: Replace all form fields with a generic `[(key, value)]` list. Rejected — would require restructuring rendering and keyboard logic for the 8 core fields that have special display (e.g., masked token).

### 2. `formFieldIndex` range extension

Currently `formFieldIndex` goes 0–9 (fields 0–7, Save=8, Back=9). New layout:
- 0–7: core fields (unchanged)
- 8...(8 + extraEnvVars.count - 1): extra env-var value fields
- 8 + extraEnvVars.count: `[+ Add env var]` button
- 8 + extraEnvVars.count + 1: `[Save]`
- 8 + extraEnvVars.count + 2: `[Back]`

Computed properties `addEnvVarIndex`, `saveIndex`, `backIndex` on `AppComponent` keep the indices readable.

### 3. Env-var picker as a new `AppScreen` case

Add `.envVarPicker` to `AppScreen`. Category and item cursor state live on `AppComponent` as `pickerCategoryIndex` and `pickerItemIndex`. Because TauTUI renders the whole screen each cycle, no sub-state needs to be stored elsewhere.

**Alternative**: Push the picker as a modal overlay drawn on top of the form. Rejected — TauTUI's `render(width:)` returns `[String]` lines with no layering support.

### 4. Category as enum, variables ported from Prism

Add `ClaudeEnvCategory` enum (9 cases matching the user's requested tabs) and `ClaudeEnvVariable` struct (name, shortName, description, type, defaultValue) to Models.swift. Each `ClaudeEnvVariable` has a `category: ClaudeEnvCategory`. Variables are ported verbatim from Prism's `allVariables`, restricted to the 9 requested categories (omitting Microsoft Foundry, Vertex AI, AWS Bedrock, Certificate, OpenTelemetry groups which are infrastructure-specific).

### 5. Template additions follow Prism's data

New templates (DeepSeek, PackyCode, Aliyuncs, ModelScope, LongCat, AnyRouter, MiniMax.io, Vanchin, ZenMux) are copied from Prism's `ProviderTemplate` definitions. `ProviderTemplate.allTemplates` order mirrors Prism's order (alphabetical by provider within groups, with `other` last).

## Risks / Trade-offs

- [Formfield index arithmetic] Adding dynamic indices for extra env vars requires careful bounds checking. → Use computed properties and centralize index logic.
- [Term width] Long env var names (e.g. `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS`) may overflow narrow terminals. → Truncate key display to `width - 20` chars.
- [Extra env vars on edit] When loading an existing provider for edit, any env vars beyond the 8 core fields must be surfaced in `extraEnvVars`. → `loadFormForEdit` iterates `provider.envVariables`, skips the 8 known keys, and populates `extraEnvVars`.

## Migration Plan

No data migration required. The provider JSON file (`~/.claude/aura-providers.json`) stores raw `[String: String]` env variables; extra env vars written by the new form are stored identically to the existing ones. Old providers remain fully functional.

## Open Questions

- Should the picker allow adding a variable that is already in the core 8 fields or already in `extraEnvVars`? Recommendation: skip already-present keys (grey them out or skip selection).
- Should boolean env vars in the picker default to `"1"` (matching existing behaviour) or `"true"`? Recommendation: use `"1"` for booleans to stay consistent with existing templates.
