---
title: Container Registry Module
description: Creates the dedicated Azure Container Registry
---

## Purpose

Creates the managed-identity-enabled registry with the Bicep template's public
network, export, administrative access, and zone settings.

## Usage

Call this module from the root configuration before assigning `AcrPull` roles.
The deployment identity needs Container Registry write access.