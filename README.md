# Hybrid Attendance System (BLE + QR + Facial Recognition)

## Project Overview
Attendance tracking in most colleges is still done manually through roll calls or paper registers, consuming valuable teaching time and often leading to errors such as incorrect entries or proxy attendance.  

Our **Hybrid Attendance System** addresses this problem by combining **Bluetooth Low Energy (BLE), QR codes, and AI-based facial recognition** to create a **seamless, proxy-proof, and analytics-driven attendance solution**.  
It is **user-friendly, reliable, and compatible with both in-person and online classes**, supporting the digital transformation of higher education.

---

## Novelty & Key Features
- **Hybrid Model (BLE + QR + Facial Recognition)** – Flexible multi-mode verification for large classrooms, small batches, and online sessions.  
- **Proxy-Proof Mechanism** – **Classroom grid mapping via BLE RSSI + facial liveness check** ensures students cannot mark attendance from outside the classroom.  
- **No Hardware Required** – Works entirely on teacher and student mobile devices, reducing cost and complexity.  
- **AI-Based Smart Analytics** – Provides **attendance trends, engagement predictions, and risk alerts for students at risk**.  

---

## Tech Stack
- **Mobile Apps:** Flutter / React Native (cross-platform for Teacher and Student apps)  
- **BLE Communication:** Android/iOS Core Bluetooth APIs for beacon broadcasting and scanning  
- **Facial Recognition & Liveness Detection:** OpenCV + TensorFlow Lite  
- **QR Scanning:** Google ML Kit / Zxing  
- **Backend & Cloud Storage:** Firebase + Firestore / Node.js + MongoDB  
- **AI Analytics:** Python (Pandas, Scikit-learn) for trends, predictions, and risk alerts  

---

## System Structure & Workflow

### Teacher App
1. **Session Initialization:** Teacher selects the class and starts a session.  
2. **BLE Broadcasting:** Teacher’s phone acts as a BLE beacon with a unique session ID.  
3. **QR Code Generation:** Optional QR code for small or online classes.  
4. **Real-Time Monitoring:** Teacher views student attendance in real-time.  
5. **Cloud Sync:** Attendance data sent to Firestore/MongoDB for analytics.  

### Student App
1. **BLE Detection:** Student devices detect teacher BLE beacons to automatically register presence.  
2. **Classroom Grid Proxy Check:** BLE RSSI is used to estimate the student’s location within the classroom grid; **out-of-bound signals are flagged as potential proxy attempts**.  
3. **Facial Verification:** AI-based liveness check ensures real-time student presence.  
4. **QR Scan (Optional):** Backup verification method for small or online classes.  
5. **Cloud Sync & Analytics:** Attendance data, BLE location, and facial verification results are sent to the backend for AI analytics and **risk alerts for students at risk**.  

---

## Benefits
- **Saves Teaching Time:** Eliminates manual roll-calls.  
- **Reduces Errors & Proxies:** BLE-based classroom mapping + facial liveness prevents unauthorized attendance.  
- **Student Risk Alerts:** AI analytics identify disengaged or at-risk students and notify faculty/admins.  
- **Actionable Insights:** Attendance trends and engagement patterns help academic planning.  
- **Transparent & Accountable:** Provides clear, verifiable attendance records.  
- **Flexible & Affordable:** Works on mobile devices, supports in-person and online classes.  

---

## Demo & Prototype
- **Demo Video:** [Watch Demo](https://your-demo-video-link.com)  
- **Prototype Screenshots:**  
  ![Teacher App Dashboard](./screenshots/teacher_dashboard.png)  
  ![Student App BLE Detection](./screenshots/student_ble_scan.png)  
  ![Student App Facial Verification](./screenshots/student_face_verify.png)  

---

## Related Repositories
- **Teacher App Repository:** [Link to Teacher Repo](https://github.com/yourusername/teacher-attendance-app)  
- **Student App Repository:** [Link to Student Repo](https://github.com/yourusername/student-attendance-app)  

---

## Impact / Why This Problem Needs to be Solved
- Saves valuable teaching time otherwise spent on manual attendance.  
- Reduces errors and eliminates proxy attendance issues.  
- Provides actionable insights to identify disengaged or struggling students.  
- Enhances transparency and accountability in academic processes.  
- Supports digital transformation of higher education institutions.  

---

## Expected Outcomes
- Fully **automated attendance system** using BLE, QR codes, and facial recognition.  
- **Cloud-based dashboards** for faculty and administrators.  
- **AI analytics** to identify attendance trends, student engagement, and risk alerts.  
- Works seamlessly in **both offline and online classes**.  

---

## Stakeholders / Beneficiaries
- **Students** – Reliable, fast, and fair attendance tracking.  
- **Faculty & Administrators** – Insights, risk alerts, and efficient attendance management.  
- **College Management Bodies** – Transparency, accountability, and process automation.  
- **Education Departments & Policymakers** – Data-driven insights for institutional planning.  

---

## License
This project is licensed under the MIT License.

