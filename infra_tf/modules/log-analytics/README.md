---
title: Log Analytics Module
description: Creates the application Log Analytics workspace
---

## Purpose

Creates the managed-identity-enabled Log Analytics workspace with the Bicep
template's SKU and retention period.

## Usage

Call this module when an existing workspace ID is not supplied. The deployment
identity needs Log Analytics workspace write access.