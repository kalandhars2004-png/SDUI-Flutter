# SDUI JSON Schema v1.0

Generic wire format. No business fields hardcoded.

## Root
```json
{
  "version": "1.0",
  "type": "column",
  "props": {},
  "style": {},
  "events": {},
  "children": []
}
```
- `version` optional, defaults to `"1.0"` on parse if missing.
- `type` **required** string — resolved via `ComponentRegistry`.
- `props` optional map — component configuration.
- `style` optional map — visual overrides (padding, color, radius, etc.).
- `events` optional map — `{"onTap": {"action": "show_snackbar", "message": "Hi"}}` or `{"onTap": "navigate"}`.
- `children` optional array — recursive `UiNode` objects. Arbitrarily nested.
- `id` optional string — engine generates stable ids if absent; preserved in `toJsonWithIds()` but omitted in wire JSON (`toWireJson()`). Builder retains ids locally.

## Example
```json
{
  "version": "1.0",
  "type": "column",
  "style": { "gap": 12, "padding": 16 },
  "children": [
    { "type": "text", "props": { "text": "Hello World" }, "style": { "fontSize": 24, "fontWeight": "bold" } },
    { "type": "button", "props": { "text": "Continue" }, "events": { "onTap": { "action": "show_dialog", "title": "Hi", "message": "Tapped" } } },
    {
      "type": "card",
      "style": { "borderRadius": 16, "padding": 16 },
      "children": [
        { "type": "text", "props": { "text": "Inside card" } },
        { "type": "profile_card", "props": { "name": "Demo User" } }
      ]
    }
  ]
}
```

## Style Keys (resolved via `PropertyResolver`)
- `color`, `backgroundColor`, `borderColor` → `Color` (hex `#RRGGBB`, `#AARRGGBB`, `#RGB`, int)
- `padding`, `margin` → `EdgeInsets` (number = all, or `{top,bottom,left,right,horizontal,vertical,all}`)
- `borderRadius` / `radius` → double
- `fontSize` → double
- `fontWeight` → `normal|medium|bold|w100..w900`
- `textAlign` → `left|center|right|justify`
- `gap` / `spacing` → double
- `mainAxisAlignment` → `start|center|end|spaceBetween|spaceAround|spaceEvenly`
- `crossAxisAlignment` → `start|center|end|stretch`
- `alignment` → `topLeft|center|bottomRight` etc.

## Events
```json
"events": {
  "onTap": { "action": "show_snackbar", "message": "Saved" },
  "onPressed": { "action": "open_payment", "amount": "199" }
}
```
`action` string is looked up in `ActionRegistry`. Legacy string shorthand also supported: `"onTap": "navigate"`.

## Validation
`SduiValidator.validate` checks:
- `type` non-empty string at every node
- `props/style/events` are maps if present
- `children` is array of objects
- `version` is string if present
Returns `ValidationResult {isValid, errors[]}`; `SduiParser` throws `SduiParseException` with errors.

## Extensibility
New component types just need a new `type` string — no schema migration. Custom props/style keys are free-form; each renderer picks what it needs via `PropertyResolver`.
