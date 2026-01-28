# Assessment Management System - Comprehensive Documentation

## 1. Project Overview & Purpose
The **Assessment Management System** is a high-performance, mobile-first application designed for educators to streamline the student evaluation process. 

### Why we built this project?
Traditional assessment methods often suffer from:
*   **Connectivity Issues**: Reliance on constant internet leads to data loss in remote areas or schools with poor Wi-Fi.
*   **Slow Interfaces**: Web-based systems often feel sluggish, causing friction during fast-paced classroom evaluations.
*   **Manual Errors**: Selecting students and ensuring marks don't exceed limits manually is prone to human error.

This project was built to provide a **Zero-Downtime, High-Speed, and Error-Proof** solution that feels premium and professional.

---

## 2. Methodology: How We Built It
The app is built using a **Modular, Repository-First Architecture**. This decouples the User Interface from the complex logic of data synchronization and networking.

### Key Architectural Pillars:
1.  **Local-First Strategy**: The app treats the local database (Hive) as the primary source of truth. The UI always loads from Hive first for instant responsiveness.
2.  **Background Synchronization**: Networking happens in the background. When the user "saves" an evaluation, it is queued locally and synced silently when the internet is available.
3.  **Idempotent Backend**: The PHP backend is designed to handle "Upserts" (Update or Insert), ensuring that re-syncing the same data doesn't create duplicates.

---

## 3. Technical Stack (Why We Used It)

### Frontend: Flutter (Dart)
*   **Why**: Cross-platform capability with "60 FPS" performance. It allows us to build complex, beautiful UI elements (like Glassmorphism) that run smoothly on both Android and iOS.

### Local Storage: Hive (NoSQL)
*   **Why**: Unlike SQLite, Hive is extremely fast and write-heavy. It is perfect for a mobile app where we constanty cache student lists and evaluation queues.

### Backend: PHP & MySQL
*   **Why**: PHP is reliable, lightweight, and easy to deploy on standard XAMPP or Linux servers. MySQL provides structured storage for relational data like Student-to-Assessment mappings.

### State & Sync: SharedPreferences & Connectivity Plus
*   **Why**: SharedPreferences handles lightweight user session data (Login status), while Connectivity Plus allows the app to "know" when it's back online so it can trigger the Sync Service.

---

## 4. Fully Detailed Functionalities

### A. Authentication & Persistent Login
*   **What**: Users login with credentials that are verified against the MySQL database.
*   **Why**: To ensure only authorized teachers can access student data and submit evaluations.
*   **How**: After a successful API response, the user's `ID` and `Encrypted Key` are saved in **SharedPreferences**. On the next app launch, the `SplashScreen` checks this storage; if data exists, it skips the login screen and goes straight to the dashboard.

### B. Intelligent Evaluation Form
*   **What**: A form where teachers select a student and input marks/comments.
*   **Why**: To make data entry as fast as possible.
*   **How**:
    *   **Searchable Dropdowns**: Uses `dropdown_search` to find students by Name or ID instantly.
    *   **Automated Logic**: If a teacher selects a certain finding, the system automatically checks "Comment: Yes" to reduce repetitive clicking.
    *   **Validation**: The system reads the "Max Marks" from the database and prevents the user from typing a higher number, showing a real-time error message.

### C. Local-First Strategy (Offline Support)
*   **What**: The ability to work without internet.
*   **Why**: Most classrooms have "dead zones." A teacher shouldn't stop working because the Wi-Fi dropped.
*   **How**:
    *   The `AssessmentRepository` checks if data is in the Hive Box.
    *   If yes, it returns it to the UI in **under 10ms**.
    *   In the background, it calls the API. If the server has new data, it updates the Hive Box and notifies the UI.

### D. Background Syncing (Queue System)
*   **What**: A "Queue" that stores pending work.
*   **Why**: To prevent data loss during network failures.
*   **How**: If `submitEvaluation` fails due to no internet, the data is pushed into a Hive box called `evaluation_queue`. The `SyncService` monitors the network status. As soon as a connection is detected, it runs an **Isolate (Background Thread)** to push all queued items to the server without freezing the user's screen.

### E. User Profile & Security
*   **What**: A dedicated screen showing account details and a Logout option.
*   **Why**: To allow users to verify who they are logged in as and securely clear their local session.
*   **How**: Tapping "Logout" clears the SharedPreferences and Hive boxes, ensuring no data leftovers on the device.


## 6. Small Details (Premium Touches)

### Glassmorphism UI
To give a "wow" factor, we used the **Apple-style Glassmorphism**. This is achieved using `BackdropFilter`. The containers have a semi-transparent white border which creates look against the pure black background.

### Dart Isolates
For complex data mapping (like converting 1000+ student records from JSON to Objects), we use `Isolate.run()`. This deleguates the heavy work to a separate CPU core, ensuring the app's animations never stutter.

### Search Performance
The search bars in the app use **Real-time Filtering**. Instead of calling the API for every keystroke, the app filters the *already cached* Hive data, making the search feel "instant" to the user.

---
**Developed by**: Usman Ahmad
**Project Type**: Academic Semester Project (5th Semester)
**Course**: BS Computer Science
