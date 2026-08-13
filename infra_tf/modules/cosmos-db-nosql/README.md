---
title: Cosmos DB NoSQL Module
description: Creates the serverless conversation-history data store
---

## Purpose

Creates a serverless Cosmos DB account, SQL database, and configured containers
with local authentication disabled and a system identity.

## Usage

Call this module from the root configuration with database and container
definitions. The deployment identity needs Cosmos DB write access.