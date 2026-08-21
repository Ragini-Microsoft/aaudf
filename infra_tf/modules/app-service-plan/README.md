---
title: App Service Plan Module
description: Creates the shared Linux App Service Plan
---

## Purpose

Creates the Linux App Service Plan with the selected SKU, worker count, and zone
balancing setting.

## Usage

Call this module from the root configuration before creating application web
apps. The deployment identity needs App Service Plan write access.