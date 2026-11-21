# FocusFlow

**A smart study planner for university students: plan your courses, focus on your tasks, and always know what to work on next.**

![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-%5E3.13.4-0175C2?logo=dart&logoColor=white)
![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS-lightgrey)
![Status](https://img.shields.io/badge/status-in%20development-orange)

---

## Table of Contents

- [About the Project](#about-the-project)
- [Problem](#problem)
- [Solution](#solution)
- [Features](#features)
- [How Task Recommendation Works](#how-task-recommendation-works)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Running Tests](#running-tests)
- [Tech Stack](#tech-stack)
- [Roadmap](#roadmap)

---

## About the Project

FocusFlow is a mobile study planner built with Flutter. It puts a student's courses, weekly class timetable and assignments in one app. A built-in Pomodoro timer helps the student focus. A rule-based recommendation engine answers one question: **"What should I work on with the time I have?"**

### Target Users

University students who take several courses at once and want one simple place to plan, focus and track their study.

---

## Problem

- Assignments, class times and deadlines are spread across Telegram, e-learning and paper notes.
- Students miss deadlines because they cannot see what is overdue or due today.
- With a short free gap between classes, students do not know which task fits that time.
- It is hard to stay focused and to measure how much real study time was done.

## Solution

FocusFlow brings everything into one place. It shows what is urgent, picks a task that fits the student's free time, runs a focus session on it, and tracks the progress.

---

## Features

### Course Management
- Create a course with a name and a color.
- Rename or recolor a course. Course names must be unique.
- Archive finished courses to hide them without losing data.

### Class Schedule
- Add weekly class times for each course (day, start time, end time).
- View today's classes and the full weekly timetable.
- Detect overlapping classes.

### Task Management
- Add tasks with a course, a deadline and an estimated time in minutes.
- Tasks are grouped as **overdue**, **due today**, **upcoming** and **completed**.
- Search by keyword. Filter by course or status.
- Complete, reopen, edit or delete tasks. Deleting a task needs confirmation.

### Focus Timer (Pomodoro)
- Start a focus session on a task, then pause, resume, complete or stop it.
- Only one session can run at a time. Completed tasks cannot be focused on.
- Default timer: **25 min** focus, **5 min** short break, **15 min** long break after every **4** sessions.
- Breaks can be 5, 10, 15 or 30 minutes. All timer values can be changed in settings.

### Smart Task Recommendation
- Enter your free minutes and get the best task to work on.
- Each pick comes with a short reason, e.g. *"Due tomorrow, fits in your 30 minutes"*.
- Reject a pick to get the next best task.

### Progress Tracking
- Tasks completed today and this week.
- Focus minutes per day and per course.
- Overall completion percentage and number of overdue tasks.

### Daily Check-in
- A daily checklist: check **Telegram**, check **e-learning**, review **tomorrow's schedule**.
- The checklist resets every day.

---

## How Task Recommendation Works

The recommendation uses clear rules, not AI. Unfinished tasks are ranked in this order:

| Priority | Rule |
|:-:|---|
| 1 | Overdue tasks come first |
| 2 | Tasks that fit in the available time |
| 3 | The closest deadline |
| 4 | Tasks never focused on, or focused on longest ago |

Completed tasks are never recommended. The time-fit rule comes before the deadline rule. Without that order, a task due a few minutes earlier would always win, even when it does not fit the student's free time.

---

## Architecture

FocusFlow uses a layered architecture:

```
┌──────────────────────────────┐
│         UI Layer             │  Flutter screens (planned)
├──────────────────────────────┤
│       Service Layer          │  Business logic and validation
├──────────────────────────────┤
│        Model Layer           │  Data classes and their own rules
└──────────────────────────────┘
```

- **Model layer**: plain Dart classes for the data. Each model holds its own small rules, such as `isOverdue()`, `fitsIn()` or `overlaps()`.
- **Service layer**: the business logic. Services check input and throw clear errors, such as `Course name already exists`.
- **UI layer**: planned. Flutter screens will call the services.

| Service | Responsibility |
|---|---|
| `CourseService` | Course CRUD and archiving |
| `ScheduleService` | Weekly class timetable and overlap checks |
| `TaskService` | Task CRUD, grouping, search and filter |
| `FocusService` | Pomodoro session lifecycle and breaks |
| `RecommendationService` | Ranks tasks and explains the pick |
| `ProgressService` | Completion and focus-time statistics |
| `CheckInService` | Daily check-in checklist |

Data is stored in memory for now.

---

## Project Structure

```
focusflow/
├── lib/
│   ├── model/
│   │   ├── course.dart
│   │   ├── class_schedule.dart
│   │   ├── student_task.dart
│   │   ├── focus_session.dart
│   │   ├── timer_settings.dart
│   │   └── daily_check_in.dart
│   ├── service/
│   │   ├── course_service.dart
│   │   ├── schedule_service.dart
│   │   ├── task_service.dart
│   │   ├── focus_service.dart
│   │   ├── recommendation_service.dart
│   │   ├── progress_service.dart
│   │   └── check_in_service.dart
│   └── test/
│       └── *_test.dart
├── android/
├── ios/
└── pubspec.yaml
```

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) with Dart `^3.13.4`
- Android Studio or Xcode, for an emulator or simulator

### Installation

```bash
git clone <repo-url>
cd focusflow
flutter pub get
```

---

## Running Tests

The unit tests are in `lib/test/`. Run them with:

```bash
flutter test lib/test
```

---

## Tech Stack

| Category | Technology |
|---|---|
| Framework | Flutter |
| Language | Dart |
| Testing | `flutter_test` |


---
