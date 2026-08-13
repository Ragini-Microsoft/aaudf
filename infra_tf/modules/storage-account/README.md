---
title: Storage Account Module
description: Creates application storage and blob containers
---

## Purpose

Creates the system-identity-enabled Storage account and blob containers with the
Bicep template's encryption, TLS, access-tier, and shared-key settings.

## Usage

Call this module from the root configuration with the required containers. The
deployment identity needs Storage account and blob-service write access.