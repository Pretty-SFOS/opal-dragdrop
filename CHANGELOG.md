<!--
SPDX-FileCopyrightText: 2023-2025 Mirian Margiani
SPDX-License-Identifier: GFDL-1.3-or-later
-->

# Changelog

## 1.0.4 (2025-06-29)

- Fix missing "highlighted" property in `DragHandle`
  This made it impossible to highlight the grab handle, and it was causing
  issues down the line in `Opal.Delegates`.

## 1.0.3 (2025-06-17)

- Don't inherit grab handle highlighted state from parent

## 1.0.2 (2025-02-18)

- Fix warning when list view doesn't support `cacheBuffer`

## 1.0.1 (2024-10-11)

- include license info for `drag-handle.png` in release bundles
  to make the released code `reuse` compliant

## 1.0.0 (2024-10-11)

- first public release
