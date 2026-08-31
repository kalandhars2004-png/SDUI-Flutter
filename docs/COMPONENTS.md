# Components

Built-ins registered in `packages/sdui_engine/lib/components/built_in.dart:1`:

| type | file | children? | key props |
|------|------|-----------|-----------|
| `text` | `text_renderer.dart` | no | `text`, `fontSize`, `color`, `fontWeight`, `textAlign`, `maxLines` |
| `button` | `button_renderer.dart` | no | `text`, `variant`=`elevated|outlined|text`, `backgroundColor`, `borderRadius` |
| `column` | `layout_renderers.dart` | yes | `gap`, `padding`, `mainAxisAlignment`, `crossAxisAlignment` |
| `row` | `layout_renderers.dart` | yes | `gap`, `padding`, alignments |
| `container` | `layout_renderers.dart` | yes | `width`, `height`, `color`, `borderRadius`, `padding`, `margin`, `borderColor` |
| `padding` | `layout_renderers.dart` | yes | `padding` |
| `center` | `layout_renderers.dart` | yes | — |
| `stack` | `layout_renderers.dart` | yes | `alignment` |
| `image` | `image_renderer.dart` | no | `src`/`url`, `width`, `height`, `fit`=`cover|contain|fill`, `borderRadius` |
| `card` | `card_renderer.dart` | yes | `title`, `subtitle`, `elevation`, `borderRadius`, `padding` |
| `icon` | `common_renderers.dart` | no | `icon` name, `size`, `color` |
| `divider` | `common_renderers.dart` | no | `thickness`, `color` |
| `list` | `common_renderers.dart` | yes | `direction`=`vertical|horizontal`, `gap`, `scrollable` |
| `sizedbox` / `spacer` | `common_renderers.dart` | no | `width`, `height` |

## Adding 50 Components
Add a new class implementing `ComponentRenderer`, then register. No core changes.

## Icon Names
Supported in `IconRenderer`: `home, star, favorite, person, settings, search, add, arrow_forward, check, info, warning, shopping_cart, menu, close, delete, edit, calendar_today` — extend by editing `_iconFor`.
