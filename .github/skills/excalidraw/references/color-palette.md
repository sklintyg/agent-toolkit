# Color Palette & Brand Style

**This is the single source of truth for all colors and brand-specific styles.** To customize diagrams for your own brand, edit this file — everything else in the skill is universal.

---

## Brand Colors

| Name | Hex | RGB |
|------|-----|-----|
| Dark Purple | `#4D1D82` | 77, 27, 130 |
| Light Purple | `#8B1D82` | 138, 30, 130 |
| Red | `#CF022B` | 207, 2, 43 |
| Orange | `#EF7D00` | 240, 125, 0 |

## Brand Background Colors

| Name | Hex | RGB |
|------|-----|-----|
| Light Purple | `#EDE9F2` | 237, 233, 242 |
| Light Orange | `#FCEADB` | 252, 234, 219 |
| Light Red | `#F7DCDF` | 247, 220, 223 |
| Light Grey | `#EDEDED` | 237, 237, 237 |

---

## Shape Colors (Semantic)

Colors encode meaning, not decoration. Each semantic purpose has a fill/stroke pair.

| Semantic Purpose | Fill | Stroke |
|------------------|------|--------|
| Primary/Neutral | `#EDE9F2` | `#4D1D82` |
| Secondary | `#8B1D82` | `#4D1D82` |
| Tertiary | `#EDEDED` | `#4D1D82` |
| Start/Trigger | `#FCEADB` | `#EF7D00` |
| End/Success | `#a7f3d0` | `#047857` |
| Warning/Reset | `#F7DCDF` | `#CF022B` |
| Decision | `#FCEADB` | `#EF7D00` |
| AI/LLM | `#EDE9F2` | `#8B1D82` |
| Inactive/Disabled | `#EDEDED` | `#4D1D82` (use dashed stroke) |
| Error | `#F7DCDF` | `#CF022B` |

**Rule**: Always pair a darker stroke with a lighter fill for contrast.

---

## Text Colors (Hierarchy)

Use color on free-floating text to create visual hierarchy without containers.

| Level | Color | Use For |
|-------|-------|---------|
| Title | `#4D1D82` | Section headings, major labels |
| Subtitle | `#8B1D82` | Subheadings, secondary labels |
| Body/Detail | `#64748b` | Descriptions, annotations, metadata |
| On light fills | `#374151` | Text inside light-colored shapes |
| On dark fills | `#ffffff` | Text inside dark-colored shapes |

---

## Evidence Artifact Colors

Used for code snippets, data examples, and other concrete evidence inside technical diagrams.

| Artifact | Background | Text Color |
|----------|-----------|------------|
| Code snippet | `#1e293b` | Syntax-colored (language-appropriate) |
| JSON/data example | `#1e293b` | `#22c55e` (green) |

---

## Default Stroke & Line Colors

| Element | Color |
|---------|-------|
| Arrows | Use the stroke color of the source element's semantic purpose |
| Structural lines (dividers, trees, timelines) | Primary stroke (`#4D1D82`) or Slate (`#64748b`) |
| Marker dots (fill + stroke) | Primary fill (`#8B1D82`) |

---

## Background

| Property | Value |
|----------|-------|
| Canvas background | `#ffffff` |
