---
title: Application Insights Module
description: Creates workspace-based Application Insights monitoring
---

## Purpose

Creates the Application Insights component and links it to a Log Analytics
workspace while preserving retention and public ingestion settings.

## Usage

Call this module from the root configuration with a workspace resource ID. The
workspace must exist before Application Insights is created.