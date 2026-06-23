# 🍔 BiteDance

## Overview

**BiteDance** is a mobile application designed to help NUS students discover free food events based on their proximity.

Telegram groups frequently distribute free food notifications across campus. However, many of these opportunities are not practically useful because students may be located far away from the event location. BiteDance aims to reduce information overload by filtering and presenting only relevant opportunities that are realistically accessible to users.

---

# 💡 Ideation

## Problem Motivation

NUS students receive numerous free food notifications every day through Telegram channels and group chats.

However:

* Many events are located far from the student's current location.
* Students must manually read and evaluate each notification.
* Important nearby opportunities can easily be missed.
* Constant notifications create unnecessary distractions.

Our goal is to create a location-aware system that helps students efficiently discover nearby free food events while minimizing irrelevant information.

---

## Proposed Core Features

### Core Features

* Automatic extraction of free food event information from Telegram groups.
* Parsing and standardization of event details such as time and location.
* Conversion of location names into geographic coordinates.
* Distance-based event filtering.
* Mobile application interface for displaying event information.
* Proximity-based notifications for nearby events.

### Extension Features

* Interactive Google Maps integration.
* Visual display of nearby events and walking distances.

---

## User Stories

### Event Discovery

* As a student, I want free food events to be collected automatically so that I do not need to constantly monitor Telegram groups.

### Event Understanding

* As a student, I want event locations and timings to be standardized so that I can quickly understand where and when events are happening.

### Personalized Recommendations

* As a student, I want to receive only nearby opportunities instead of every free food notification on campus.

### Smart Notifications

* As a student, I want notifications only when events are within a distance that I am willing to travel.

### Mobile Accessibility

* As a student, I want all event information to be available through a simple and intuitive mobile application.

---

# 🏗️ Design and Plan

The project follows a pipeline-based architecture:

```text
Telegram Groups
      ↓
Message Extraction
      ↓
Event Parsing
      ↓
Location Processing
      ↓
Coordinate Conversion
      ↓
Distance Calculation
      ↓
Flutter Frontend
      ↓
Notification System
```

### Backend Responsibilities

* Connect to Telegram groups.
* Extract incoming event messages.
* Process location and timing information.
* Convert location names into coordinates.
* Prepare event data for frontend consumption.

### Frontend Responsibilities

* Display processed event information.
* Present event details clearly to users.
* Support future location-based recommendations and notifications.

---

# ✅ Features Implemented

## Feature 1 (Core): Telegram Data Extraction

### Description

The system is able to establish a connection with Telegram and automatically retrieve incoming messages from designated groups.

### Current Capabilities

* Connects directly to Telegram.
* Automatically captures newly received messages.
* Continuously monitors event-related channels.
* Retrieves event content without manual intervention.

---

## Feature 2 (Core): Event Parsing and Location Processing

### Description

The system extracts important event information from Telegram messages and converts unstructured text into structured data.

### Current Capabilities

* Detects location keywords such as:

  * COM3
  * LT27
  * Frontier
  * Other NUS locations

* Detects timing information.

* Standardizes extracted event details.

* Prepares processed data for further analysis.

---

## Feature 3 (Core): Coordinate Conversion

### Description

The system converts recognized locations into geographical coordinates.

### Current Capabilities

* Maps location names to latitude and longitude values.
* Produces coordinate representations suitable for distance calculations.
* Establishes the foundation for future proximity-based filtering.

---

## Feature 4 (Core): Flutter Frontend Integration

### Description

Processed event information can be displayed within the Flutter application.

### Current Capabilities

* Event information is transmitted to the frontend.

* Users can view:

  * Event location
  * Event timing
  * Relevant event details

* Provides a basic mobile interface for event browsing.

---

# 🚧 Planned Features

## Feature 5 (Core): User Location Detection

### Goal

Obtain the user's real-time location using mobile device GPS.

### Planned Functionality

* Real-time GPS access.
* Dynamic location updates.
* Integration with distance calculation modules.

---

## Feature 6 (Core): Distance Calculation and Filtering

### Goal

Calculate the distance between users and events.

### Planned Functionality

* Compute user-event distance.
* Filter events outside a specified threshold.
* Prioritize nearby opportunities.

---

## Feature 7 (Core): Proximity-Based Notification System

### Goal

Provide personalized notifications based on distance preferences.

### Planned Functionality

* Notify users only when relevant events appear nearby.
* Allow customizable travel distances:

  * 300m
  * 500m
  * 1km
  * Custom values

---

## Feature 8 (Extension): Google Maps Integration

### Goal

Provide map-based visualization of free food events.

### Planned Functionality

* Interactive map display.
* Event markers.
* Distance visualization.
* Navigation support.

---

# ⚠️ Problems Encountered

## Telegram Connectivity and Network Restrictions

One of the primary challenges encountered during development involved maintaining reliable access to Telegram services and required dependencies.

### Issues Faced

* VPN connectivity instability.
* Difficulty accessing external resources.
* Dependency download interruptions.
* Development environment setup challenges.

### Solutions Adopted

* Utilized Alibaba Cloud mirrors to download required dependencies.
* Adjusted development workflow to accommodate network restrictions.
* Implemented alternative package retrieval methods when necessary.

These solutions allowed development to continue despite connectivity limitations.

---

# 🔮 Future Work

The next stage of development will focus on completing the project's location-aware recommendation pipeline.

### Immediate Priorities

* Implement user GPS location detection.
* Develop distance calculation algorithms.
* Introduce event filtering mechanisms.
* Build proximity-based notification services.

### Long-Term Improvements

* Google Maps integration.
* Enhanced event visualization.
* Personalized recommendation systems.
* Improved user interface and experience.

---

## Team Vision

Our vision is to create a practical and efficient tool that helps NUS students discover nearby free food opportunities without being overwhelmed by irrelevant notifications.

By combining Telegram event extraction, location intelligence, and mobile accessibility, BiteDance aims to make free food discovery smarter, faster, and more convenient for students.
