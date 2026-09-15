---
name: pwa-page-redesign
description: Use when redesigning OR building any web page/site (component-based, responsive/PWA sizing, no overflow, no emoji, light/dark mode complete).
---

# PWA Page Redesign

Trigger: user asks to redesign an existing page "for the PWA version", OR
asks to build/create a new page or website. Applies to new builds too — a new
page must be responsive/PWA-ready from the first draft, not fixed up after.

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
4. **Responsive at every breakpoint, no overflow.** Layout must reflow (not
   just shrink) at mobile (~360-428px), tablet (~768px), and desktop. Use the
   project's existing responsive utilities (Tailwind `sm:`/`md:`/`lg:` etc. or
   equivalent) — don't ship a fixed desktop-only layout. This applies to
   popups/modals too: `max-h-[90vh] overflow-y-auto`, content wraps, no fixed
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

**Redesigning an existing page:**
1. Open the given page/route, read the current markup/component tree.
2. List every UI element on the page and classify it against the component
   list above (existing component vs raw HTML vs emoji vs inline SVG).
3. Rebuild using existing components, applying rules 2–7.
4. Verify: resize to mobile/tablet/desktop widths, open every modal, toggle
   light/dark mode, confirm no overflow and no emoji remain.

**Building a new page/website:**
1. Apply rules 1–7 from the first draft — same rules, no separate "make it
   responsive later" pass.
2. Reuse existing components for every UI element in the list above; only
   write raw markup for what the design system doesn't cover.
3. Verify the same way: mobile/tablet/desktop widths, modals, light/dark mode.

## What NOT to do

- Don't redesign layout/spacing beyond what's needed for PWA/mobile fit —
  this is a component + overflow + theme pass, not a visual redesign.
- Don't introduce a new component library; use what the project already has.
- Don't add pagination/search/etc. that the original page didn't have.
- Don't ship a new page/component desktop-only "for now" — responsive sizing
  is part of done, not a follow-up ticket.
