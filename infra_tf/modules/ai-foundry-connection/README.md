---
title: AI Foundry Connection Module
description: Creates one connection on an Azure AI Foundry project
---

## Purpose

Creates a `2025-12-01` Foundry project connection through AzAPI. The root module
calls it once per Search, Storage, and Application Insights connection.

## Usage

Call this module from the root configuration with the account, project,
connection category, target, authentication type, and metadata. Azure access to
the target resource group is required.