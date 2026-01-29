# Civic-AI
Our Civic AI platform enables citizens to report issues digitally while automatically assigning SLAs, tracking deadlines, and escalating delays. With real-time monitoring, transparent workflows, and performance dashboards, the system improves accountability, reduces delays, and ensures faster, more efficient public service delivery.

# Civic-AI 🚀  
### SLA-Based Civic Issue Reporting & Tracking System

## 📌 Overview
Civic-AI is a Flutter-based mobile application designed to improve public service delivery by enabling citizens to report civic issues digitally. The system automatically assigns Service Level Agreements (SLAs), tracks deadlines in real time, escalates unresolved issues, and promotes transparency and accountability through dashboards and leaderboards.

---

## ❓ Problem Statement
Traditional civic complaint systems suffer from:
- No fixed resolution timelines
- Lack of transparency
- Manual follow-ups
- Poor accountability

This results in delays, inefficiency, and loss of citizen trust.

---

## 💡 Solution
Civic-AI transforms complaint handling into an SLA-driven workflow:
- Citizens submit issues digitally
- SLAs are assigned automatically based on issue type
- Deadlines are tracked in real time
- Delays trigger escalation
- Performance is visible through dashboards

---

## ✨ Key Features
- Citizen issue reporting
- Automatic SLA assignment
- Deadline countdown tracking
- Escalation on SLA breach
- Admin & officer dashboards
- Leaderboard for accountability
- AI-assisted issue categorization (supportive role)

---

## 🧠 Role of AI
AI is used as a **support tool**, not as a replacement for coding:
- Issue categorization
- Complaint summarization
- Urgency level detection

Core logic, workflows, and system architecture were designed and implemented manually.

---

## 🛠️ Tech Stack
- **Flutter (Dart)** – Frontend mobile application
- **Firebase Firestore** – Cloud database
- **Firebase Authentication** – User management
- **Cloud-based architecture** – Scalability & reliability

---

## 🏗️ Project Structure
```text
lib/
 ├── screens/
 │   ├── admin_dashboard.dart
 │   ├── emergency_screen.dart
 │   ├── leaderboard_screen.dart
 │   ├── login_screen.dart
 │   ├── signup_screen.dart
 │   └── report_issue.dart
 ├── services/
 │   ├── ai_service.dart
 │   ├── firestore_service.dart
 │   └── firebase_options.dart
 ├── main.dart

