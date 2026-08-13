---
title: AI Foundry Model Deployment Module
description: Deploys one model to an Azure AI Services account
---

## Purpose

Creates one `2025-12-01` AI model deployment through AzAPI with its model,
policy, SKU, and capacity settings.

## Usage

Call this module from the root configuration for each model. The target AI
Services account must exist and the deployment identity needs write access.