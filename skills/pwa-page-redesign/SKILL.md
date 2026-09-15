---
name: pwa-page-redesign
description: Use when redesigning any web page into its PWA version (component-based, no overflow, no emoji, light/dark mode complete).
---

# PWA Page Redesign

Trigger: user gives a page/URL and asks to redesign it "for the PWA version"
(or "PWA-ify this page").

## Non-negotiable rules

1. **Use existing components** for: Button, Badge, SearchBar, Dropdown,
   DatePicker, TimePicker, Tabs, ConfirmationDialog, AccordionItem, Pagination,
   DataTable, ActionButton, Modal — for whichever of these the page actually
   has. Do not invent new one-off components for things the design system
   already covers.
2. **Keep existing button/badge colors and emoji-as-icon meaning** — e.g. a
   green "Approve ✓" button stays green with a check icon, just swap the emoji
   glyph for a real icon component with the same meaning.
3. **No emoji anywhere in the UI.** Replace every emoji with a real icon
   (lucide/heroicons/whatever icon set the project already uses). If an emoji
   was doing a job (status, action), the icon must do the same job.
4. **No overflow at any screen size**, including popups/modals. Test at
   mobile width (~360px) and make sure nothing clips or requires horizontal
   scroll. Modals: `max-h-[90vh] overflow-y-auto`, content wraps, no fixed
   pixel widths wider than viewport.
5. **Modal/popup header:** title + a single X icon button, same row, X at the
   top-right. No separate "Close" or "Cancel" button — the X is the only close
   affordance.
6. **DataTable action column:** if a row has more than 1 action, group them
   into an ActionButton (dropdown/kebab) component instead of a row of loose
   icon buttons. If an action icon is raw inline SVG, extract it into its own
   component under an `icons/` folder and import it.
7. **Light/dark mode:** every text color, background, border, divider, and
   icon color must have both a light and dark value (Tailwind `dark:` variant
   or equivalent theme token). Don't leave anything hardcoded to one mode.

## Process

1. Open the given page/route, read the current markup/component tree.
2. List every UI element on the page and classify it against the component
   list above (existing component vs raw HTML vs emoji vs inline SVG).
3. Rebuild using existing components, applying rules 2–7.
4. Verify: resize to mobile width, open every modal, toggle light/dark mode,
   confirm no overflow and no emoji remain.

## What NOT to do

- Don't redesign layout/spacing beyond what's needed for PWA/mobile fit —
  this is a component + overflow + theme pass, not a visual redesign.
- Don't introduce a new component library; use what the project already has.
- Don't add pagination/search/etc. that the original page didn't have.
