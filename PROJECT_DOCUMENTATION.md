# Assessment Management System: Project Documentation

## 1. Project Overview
The **Assessment Management System** is a mobile application developed using Flutter, designed to streamline the evaluation process for educators. It allows teachers to manage student assessments, input marks/feedback, and synchronize data with a remote MySQL backend. The app is built with a focus on **Offline-First** reliability and a **Premium UI/UX** following modern glassmorphism design principles.

---

## 2. Technical Stack
- **Frontend**: Flutter (Dart)
- **Local Database**: Hive (NoSQL) for high-performance caching.
- **Backend Communication**: RESTful APIs via PHP.
- **State/Storage**: Shared Preferences for user session management.
- **Connectivity**: `connectivity_plus` for real-time network status detection.
- **UI Design**: Vanilla CSS-like styling in Flutter with `BackdropFilter` (Glassmorphism).

---

## 3. Core Architecture
The project follows a modular architecture to ensure maintainability and scalability:

### A. Data Models (`lib/model`)
- **Assessment**: Represents the high-level assessment entity (e.g., "Final Exam").
- **AssessmentDetail**: Represents specific criteria within an assessment (e.g., "Performance," "Attendance").
- **Student**: Represents the student being evaluated.

### B. Logical Layer (`lib/repos`)
- **AssessmentRepository**: The single source of truth for the UI. It implements the **Local-First Strategy**, deciding whether to serve data from the local Hive cache or the network.

### C. Services Layer (`lib/services`)
- **ApiService**: Handles HTTP requests to the PHP backend.
- **StorageService**: Manages the local Hive database (Box management, CRUD operations).
- **SyncService**: A background task manager that identifies unsynced evaluations and uploads them when the internet is restored.

---

## 4. Key Functionalities

### 🔐 1. Authentication & Persistent Login
- **Secure Login**: Authenticates users against the remote database.
- **Persistence**: Uses `SharedPreferences` to keep users logged in across sessions, ensuring they don't have to re-enter credentials every time.
- **Profile Management**: A dedicated screen to view user details and handle secure logouts.

### ⚡ 2. Local-First Data Strategy
- **Instant Loading**: Unlike traditional apps that show a loading spinner for minutes, this app loads data instantly from the local Hive cache.
- **Background Refresh**: While the user interacts with cached data, the app silently fetches updates from the server and updates the local storage for the next session.

### 📶 3. Full Offline Support
- **Offline Evaluation**: Teachers can conduct assessments even in areas with zero internet. Data is queued locally in the `evaluationQueue`.
- **Automatic Syncing**: The app detects when the device comes back online and automatically pushes pending evaluations to the server, preventing data loss.

### 📝 4. Intelligent Evaluation Form
- **Student Selection**: Powered by a professional search-enabled dropdown.
- **Smart Validation**: 
    - Prevents inputting marks that exceed the maximum allowed for a specific criterion.
    - **Logic Implementation**: If a teacher provides a specific finding/comment (or marks "Yes" for identifying a trait), the system automatically sets the marks to 0 per project rules.

### 🔍 5. Professional Search & Filtering
- **Real-time Assessment Search**: Filters the main dashboard list instantly as the user types, making it easy to find specific tasks.
- **Integrated Student Search**: A refined, minimalist search interface within evaluation forms.

---

## 5. Professional UI/UX (Glassmorphism)
The app features a state-of-the-art "Apple Water Effect" (Glassmorphism):
- **Blur Effects**: Using `BackdropFilter` with Gaussian blur to create depth.
- **Dynamic Backgrounds**: Subtle gradients and mesh-like aesthetic containers.
- **Minimalist Aesthetic**: Pure black backgrounds (`#000000`), thin borders, and refined white/blue typography for a premium feel.

---

## 6. Project Results & Impact
This implementation successfully solves the primary pain points of mobile assessment:
1. **Zero Downtime**: Works perfectly regardless of internet availability.
2. **High Performance**: Instant UI response times due to local database priority.
3. **Data Integrity**: Background synchronization ensures that offline work is never lost.
4. **Professionalism**: A modern, high-end look that meets current industry standards for mobile application design.

---
*Developed for [Semester Project / Presentation]*
