---
title: App Service Module
description: Creates one containerized Linux App Service
---

## Purpose

Creates a Linux web app with a system identity, application settings, container
configuration, diagnostics, TLS, and disabled basic publishing credentials.

## Usage

Call this module once per backend or frontend application. An App Service Plan
must exist, and the deployment identity needs Web App write access.