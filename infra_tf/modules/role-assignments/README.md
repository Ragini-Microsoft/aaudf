---
title: Role Assignments Module
description: Creates application control-plane and data-plane role assignments
---

## Purpose

Creates the Foundry, Search, Storage, Cosmos DB, deployer, and Container Registry
assignments defined by the centralized Bicep RBAC module.

## Usage

Call this module after all service identities are available. The deployment
identity needs permission to create role assignments at every target scope.