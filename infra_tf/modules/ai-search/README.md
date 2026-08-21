---
title: AI Search Module
description: Creates the Azure AI Search service used by the application
---

## Purpose

Creates AI Search with the Bicep template's SKU, capacity, semantic search,
network, local-authentication, and managed-identity settings.

## Usage

Call this module from the root configuration with the resource group, solution
name, and location. The deployment identity needs Search write access.