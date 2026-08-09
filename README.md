# ABU Smart Energy Monitoring & Control System

## Overview

This project is a SCADA-based electrical energy monitoring and control system built as a Final Year Project (Master's, Networks and Security Systems) at Ahmadu Bello University (ABU), Zaria. It addresses a concrete gap on campus: electricity consumption across administrative buildings, classrooms, and labs is neither finely measured nor monitored in real time, making it impossible to catch waste, plan preventive maintenance, or react to a localized overload without cutting power to an entire building.

The system is a Flutter application that visualizes energy consumption in real time across multiple buildings and, on a pilot building, goes a step further than typical remote-cutoff systems: instead of a single all-or-nothing breaker, it can switch off **one specific piece of equipment** — an office AC unit, a room's fans, a charging point — without affecting anything else in the building. This device-level granularity is the project's core contribution.

Behind the application sits a fully **virtualized SCADA testbed** (OpenPLC + ScadaBR communicating over Modbus TCP), proving out real data acquisition and control-command writing without depending on any physical hardware, campus wiring access, or administrative approvals — a deliberate choice given the project's 4-month academic timeframe.

## What it does

- Simulates and displays multi-building energy consumption in real time.
- Stores historical readings locally for trend analysis.
- Raises threshold-based alerts within seconds of an anomaly.
- Lets authorized users disconnect or reconnect individual equipment on a pilot building, with mandatory confirmation and full audit logging.
- Runs against a virtualized OpenPLC/ScadaBR testbed to validate the approach with real SCADA acquisition and Modbus control writes.
- Documents a STRIDE threat model for the critical control-command flow from day one.

## How it's built

The architecture is layered and provider-based: the UI and business logic only ever talk to an abstract `DataProvider` interface, never to a concrete data source. This means the app can run entirely on simulated data (`FakeDataProvider`) during early development and later switch to the live SCADA testbed (`ScadaBRProvider`) without touching a single screen. Flutter was chosen for a single codebase across desktop, mobile, and web; Provider for state management; and Hive for lightweight local storage — all deliberately low-overhead choices suited to a solo, time-boxed academic project.

## Scope

The 4-month deliverable is a working, fully virtualized proof of concept: a Flutter app with dashboard, alerts, history, and admin screens, backed by a simulated multi-building dataset and a real (but virtual) SCADA control loop demonstrated on one pilot building. Physical hardware deployment, campus-wide rollout, network segmentation (pfSense/WireGuard), OT network monitoring (Zeek), and AI-based analytics are explicitly out of scope for this phase — but the architecture (particularly the `relay_address` field and the Repository/Provider abstraction) is designed so none of it requires a rewrite later.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
