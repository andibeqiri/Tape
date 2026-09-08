# Tape

A calculator where the expression is **editable text**. Move the cursor, edit in place, drag to reposition — like a real text field, because arithmetic is editing.

## The one idea

The expression line behaves like an editable text field:

- A visible, blinking cursor sits between characters.
- Tapping a character places the cursor before or after it.
- **Long-press-drag gesture**: hold the keypad, then drag to move the cursor through the expression. This is the headline craft moment — it must feel native.
- Inserting/deleting a character happens at the cursor, not at the end. `2+2` with cursor after the first `2`, press `5` → `25+2`.
- Live result updates as the expression changes, shown below dimmed.
- Session history: past expressions are listed above the input; tapping one reloads it for re-editing.

## Source layout

```
Sources/Tape/
├── App/
│   └── TapeApp.swift          — @main entry, injects Theme into environment
├── Model/
│   ├── CalculatorModel.swift  — @Observable state: expression, cursorIndex, history
│   └── ExpressionEvaluator.swift — recursive-descent parser for + - * / and ()
├── Views/
│   ├── ContentView.swift      — root layout: history → expression card → keypad
│   ├── ExpressionView.swift   — scrollable character row with BlinkingCursor
│   ├── KeypadView.swift       — button grid + long-press-drag gesture + CalcButton
│   └── HistoryView.swift      — scrollable past entries, tap to reload
└── Design/
    ├── Theme.swift            — Theme struct + EnvironmentKey (accent colour)
    └── GlassModifiers.swift   — .inputGlass() and .pillGlass() view modifiers
```

New views go in `Views/`, new model types in `Model/`, new visual primitives in `Design/`.

## Key types

| Type | File | Role |
|---|---|---|
| `CalculatorModel` | Model/ | Single source of truth. `@Observable`, `@MainActor`. |
| `HistoryEntry` | Model/ | Immutable value type stored in `model.history`. |
| `ExpressionEvaluator` | Model/ | Stateless evaluator — call `evaluate(_:) -> Double?`. |
| `ExpressionView` | Views/ | Renders expression as tappable chars + `BlinkingCursor`. |
| `KeypadView` | Views/ | Grid + drag gesture. `CalcButton` and `CalcButtonStyle` live here. |
| `Theme` | Design/ | Single `accent: Color`. Injected via `\.theme` environment key. |

## What's built

- [x] Tuist project (`Project.swift` + `Tuist.swift`), iOS 17+
- [x] `CalculatorModel`: expression string, cursor index, insert/delete at cursor, history
- [x] `ExpressionEvaluator`: recursive-descent parser, `+ - * /`, parentheses, unary minus
- [x] `ExpressionView`: character-by-character render, tap-to-place cursor, `BlinkingCursor` with 0.53 s blink
- [x] `KeypadView`: 5×4 grid, thumb-friendly buttons, `CalcButtonStyle` with press animation
- [x] Long-press-to-drag gesture: hold keypad → dim + overlay → drag moves cursor with haptic tick per step
- [x] Live result line with `.numericText()` content transition
- [x] Session history with tap-to-reload
- [x] `Theme` + `\.theme` environment key, accent defaults to orange
- [x] `.inputGlass()` / `.pillGlass()` — Liquid Glass on iOS 26, material fallback on iOS 17–25

## What's next (priority order)

1. **Polish the drag gesture** — sensitivity tuning, edge resistance when cursor hits start/end, no jank on fast drags. Hero feature; must feel native.
2. **Cursor snap animation** — when cursor jumps position via tap, animate it sliding rather than cutting.
3. **Result number transition** — make the `= X` line animate between values more expressively than the default cross-fade.
4. **Character insert haptic** — light tap on each digit/operator inserted (cursor step tick is already in).
5. **Malformed expression handling** — `2++`, unclosed `(` — evaluator already returns `nil` silently. Add a subtle shake on `=` press when expression is invalid.
6. **Empty state** — dimmed placeholder (e.g. `0`) when expression is empty so the cursor has visual context.
7. **README + GIF** — record the cursor editing and the drag gesture. The gesture IS the demo.

## Conventions

- No third-party libraries. Native SwiftUI only.
- `CalculatorModel` is `@Observable` — read it directly from views, no `@Binding` tunnelling.
- Pass `model` by reference (it's a class). Views take `let model: CalculatorModel`.
- `Theme` values come from `@Environment(\.theme)` — don't hardcode colours.
- Keep `ExpressionEvaluator` stateless and pure — it takes a `String`, returns `Double?`.
- iOS 26 minimum (`Project.swift` sets `deploymentTargets: .iOS("26.0")`). No `#available` guards needed for Liquid Glass APIs.
- Use `swiftui-expert-skill` for SwiftUI layout/animation questions.

## Hard limits — do not add

- ❌ Tips or bill-splitting
- ❌ Scientific / trig / advanced functions
- ❌ Unit conversion, currency, percentage key
- ❌ Multi-screen navigation or settings
- ❌ Persistence beyond the current session

If a feature doesn't serve the editable-expression idea, cut it.
