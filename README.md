<div align="center">

# Tape

### A calculator that edits the way you think.

**Tap anywhere. Move the cursor. Fix the number. Keep going.**

![iOS 26](https://img.shields.io/badge/iOS-26%2B-black?style=flat-square&logo=apple)
![SwiftUI](https://img.shields.io/badge/SwiftUI-native-F05138?style=flat-square&logo=swift)
![Tuist](https://img.shields.io/badge/project-Tuist-6C47FF?style=flat-square)

</div>

---

Most calculators make one small mistake expensive: delete everything after it, or start again.

Tape treats arithmetic as **editable text**. The expression has a real cursor, so correcting `128 × 4` to `128 × 5` feels as natural as editing a message.

## One expression. Direct manipulation.

| Gesture | What happens |
|:--|:--|
| **Tap a character** | Places the cursor before or after it |
| **Hold the keypad, then drag** | Scrubs the cursor through the expression with haptic ticks |
| **Press a key** | Inserts at the cursor—not just at the end |
| **Press backspace** | Deletes directly behind the cursor |
| **Tap a history entry** | Reloads the original expression for editing |

> `2 + 2` → place the cursor after the first `2` → tap `5` → `25 + 2`

No modes to learn. No tiny arrow buttons. The keypad itself becomes the trackpad.

## Designed to feel obvious

- **A visible, blinking cursor** always shows where the next character will go.
- **Live results** update quietly beneath the expression while you edit.
- **Long-press and drag** turns the whole keypad into a generous cursor surface.
- **Haptic feedback** marks each cursor step without demanding your attention.
- **Session history** keeps previous calculations close and fully editable.
- **Liquid Glass controls** provide depth while keeping the expression in focus.

## Focused by design

Tape does the everyday arithmetic well: addition, subtraction, multiplication, division, decimals, negative values, and parentheses.

It intentionally has no scientific mode, unit conversion, account, settings screen, or persistent history. Every element serves one idea: **arithmetic is editing**.

## Built with

- SwiftUI
- Observation (`@Observable`)
- Native Liquid Glass
- XCTest UI testing
- Tuist
- Zero third-party dependencies

## Run locally

Requirements: **Xcode 26+**, **iOS 26+**, and [Tuist](https://tuist.dev).

```bash
tuist generate
open Tape.xcworkspace
```

Choose an iPhone simulator and run the `Tape` scheme.

<details>
<summary><strong>Project structure</strong></summary>

```text
Sources/Tape/
├── App/       # App entry point
├── Design/    # Theme and Liquid Glass primitives
├── Model/     # Calculator state and expression evaluator
└── Views/     # Expression editor, keypad, history, and root layout
```

The evaluator is a small recursive-descent parser supporting `+`, `-`, `*`, `/`, unary signs, and parentheses. UI state lives in one `@MainActor @Observable` model.

</details>

---

<div align="center">

**Tape turns correcting a calculation from a restart into a tiny edit.**

</div>
