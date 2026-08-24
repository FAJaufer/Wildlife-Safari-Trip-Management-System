# Wildlife-Safari-Trip-Management-System
🦁 Web-based Wildlife Safari Trip Management System
A Java web application for online wildlife safari trip booking and management, built as a group project using Servlets, JSP, JDBC, and MySQL following the MVC architecture pattern.

**Institution:** Sri Lanka Institute of Information Technology (SLIIT)
**Module:** SE2030 – Software Engineering | Year 2, Semester 1 – 2026
**Group ID:** 2026-Y2-S1-MLB-B13G2-06

---

## 📋 Tech Stack

| Layer | Technology |
|---|---|
| Backend | Java Servlets |
| Frontend | JSP + Bootstrap 5 (CDN) |
| Database | MySQL (JDBC) |
| Build Tool | Apache Maven |
| Server | Apache Tomcat 9+ |
| Pattern | MVC (Model-View-Controller) |

---

## 📁 Project Structure

```
wildlife-safari-management/
├── pom.xml
├── README.md
├── .gitignore
├── database/
│   └── safari_db.sql
└── src/
    └── main/
        ├── java/
        │   └── com/wildlifesafari/
        │       ├── model/          ← Data classes (POJOs)
        │       │   └── User.java
        │       ├── dao/            ← Database operations
        │       │   └── UserDAO.java
        │       ├── servlet/        ← Controllers (Servlets)
        │       │   └── TestServlet.java
        │       └── util/           ← Utility classes
        │           └── DBConnection.java
        └── webapp/
            ├── css/
            │   └── style.css
            ├── js/
            │   └── script.js
            ├── views/
            │   ├── login.jsp
            │   ├── register.jsp
            │   └── dashboard.jsp
            └── WEB-INF/
                └── web.xml
```

### Package Descriptions

| Package | Purpose |
|---|---|
| `com.wildlifesafari.model` | Java classes representing database tables |
| `com.wildlifesafari.dao` | Data Access Objects for DB operations |
| `com.wildlifesafari.servlet` | Servlet controllers handling requests |
| `com.wildlifesafari.util` | Utility classes (DB connection, etc.) |

---

## 🚀 Setup Instructions

### Prerequisites

- Java JDK 17
- Apache Tomcat 9+
- MySQL Server 8.0+
- Apache Maven 3.6+
- IntelliJ IDEA (recommended)

### Step-by-Step Setup

**1. Clone the Repository**

```
git clone <your-repository-url>
cd wildlife-safari-management
```

**2. Create the MySQL Database**

Open MySQL command line or MySQL Workbench and run:

```
SOURCE database/safari_db.sql;
```

Or manually create the database:

```sql
CREATE DATABASE safari_db;
```

**3. Update Database Credentials**

Open `src/main/java/com/wildlifesafari/util/DBConnection.java` and update:

```java
private static final String URL = "jdbc:mysql://localhost:3306/safari_db";
private static final String USER = "root";
private static final String PASSWORD = "your_password_here";
```

**4. Open in IntelliJ IDEA**

- Open IntelliJ IDEA
- Click **File → Open** and select the project folder
- IntelliJ will detect it as a Maven project and import dependencies automatically
- Wait for Maven to download all dependencies

**5. Configure Tomcat in IntelliJ**

- Go to **Run → Edit Configurations**
- Click **+ → Tomcat Server → Local**
- Set the Tomcat home directory
- Go to the **Deployment** tab
- Click **+ → Artifact →** select `wildlife-safari-management:war exploded`
- Set **Application Context** to `/wildlife-safari-management`
- Click **Apply → OK**

**6. Run the Project**

- Click the **Run** button (green play icon)
- Open browser and go to: `http://localhost:8080/wildlife-safari-management/test`
- You should see: `✅ Project is working!`

---

## 🧩 Team Responsibilities (6 Members)

> Suggested classes and database tables below are starting points derived from the functional requirements in the project proposal (each member's assigned major function). Finalize exact fields and relationships during the team's database design phase (Week 4–5).

### Member 1: Sajini S. B. (IT25103526) — Safari Booking Management
*Scrum Role: Product Owner*

**Features:**
- Browse and book safari trips (select park, date, time slot, number of participants)
- Check package/schedule availability and calculate total cost
- View, modify, and cancel bookings
- View booking history and status
- Booking confirmation

**Suggested Classes:**
- `model/Booking.java`
- `dao/BookingDAO.java`
- `servlet/BookingServlet.java`
- `servlet/BookingHistoryServlet.java`

**Suggested Database Tables:**

```sql
CREATE TABLE bookings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    package_id INT,
    safari_date DATE,
    time_slot VARCHAR(50),
    participants INT,
    total_cost DECIMAL(10,2),
    status ENUM('pending', 'confirmed', 'modified', 'cancelled') DEFAULT 'pending',
    booking_reference VARCHAR(50) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (package_id) REFERENCES safari_packages(id)
);
```

---

### Member 2: Thrikawalage S.R (IT25100556) — Safari Package Management
*Scrum Role: Developer*

**Features:**
- Create, edit, and delete safari packages (Manager/Admin)
- Manage package type, destination, duration, pricing, schedule, availability, description
- Browse, search, and filter packages (Tourist)
- View package details

**Suggested Classes:**
- `model/SafariPackage.java`
- `dao/SafariPackageDAO.java`
- `servlet/SafariPackageServlet.java`
- `servlet/PackageSearchServlet.java`

**Suggested Database Tables:**

```sql
CREATE TABLE safari_packages (
    id INT PRIMARY KEY AUTO_INCREMENT,
    safari_type VARCHAR(100),
    destination VARCHAR(200),
    duration VARCHAR(50),
    price DECIMAL(10,2),
    description TEXT,
    availability_status ENUM('available', 'unavailable') DEFAULT 'available',
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(id)
);
```

---

### Member 3: Ekanayake E.M.S.D. (IT25102257) — Vehicle & Driver Management
*Scrum Role: Developer*

**Features:**
- Register and update safari vehicles and drivers
- Track vehicle maintenance status and insurance
- Verify driver license and availability
- Assign vehicles/drivers to bookings, preventing double-booking

**Suggested Classes:**
- `model/Vehicle.java`
- `model/Driver.java`
- `dao/VehicleDAO.java`
- `dao/DriverDAO.java`
- `servlet/VehicleServlet.java`
- `servlet/DriverServlet.java`

**Suggested Database Tables:**

```sql
CREATE TABLE vehicles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    registration_number VARCHAR(50) UNIQUE,
    vehicle_type VARCHAR(50),
    insurance_expiry DATE,
    maintenance_status ENUM('active', 'under_maintenance', 'inactive') DEFAULT 'active',
    availability_status ENUM('available', 'assigned', 'unavailable') DEFAULT 'available'
);

CREATE TABLE drivers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    license_number VARCHAR(50) UNIQUE,
    license_expiry DATE,
    experience_years INT,
    employment_status ENUM('active', 'inactive') DEFAULT 'active',
    availability_status ENUM('available', 'assigned', 'unavailable') DEFAULT 'available',
    FOREIGN KEY (user_id) REFERENCES users(id)
);
```

---

### Member 4: Hettiarachige S.S.H (IT25100508) — Wildlife Sighting Records
*Scrum Role: Developer*

**Features:**
- Guides record wildlife sightings (species, location, date, time, photos)
- Store and display recent sightings to tourists and administrators
- Handle optional photo upload

**Suggested Classes:**
- `model/WildlifeSighting.java`
- `dao/WildlifeSightingDAO.java`
- `servlet/WildlifeSightingServlet.java`

**Suggested Database Tables:**

```sql
CREATE TABLE wildlife_sightings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    guide_id INT,
    booking_id INT,
    species VARCHAR(150),
    location VARCHAR(200),
    sighting_date DATE,
    sighting_time TIME,
    photo_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (guide_id) REFERENCES users(id),
    FOREIGN KEY (booking_id) REFERENCES bookings(id)
);
```

---

### Member 5: Amani J F (IT25100782) — Safari Schedule & Resource Management
*Scrum Role: Developer*

**Features:**
- Create and update safari schedules
- Allocate guides, drivers, and vehicles to bookings
- Detect and prevent scheduling conflicts
- Update and view daily trip status

**Suggested Classes:**
- `model/SafariSchedule.java`
- `dao/SafariScheduleDAO.java`
- `servlet/ScheduleServlet.java`

**Suggested Database Tables:**

```sql
CREATE TABLE safari_schedules (
    id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT,
    guide_id INT,
    driver_id INT,
    vehicle_id INT,
    schedule_date DATE,
    schedule_time TIME,
    trip_status ENUM('scheduled', 'in_progress', 'completed', 'cancelled') DEFAULT 'scheduled',
    FOREIGN KEY (booking_id) REFERENCES bookings(id),
    FOREIGN KEY (guide_id) REFERENCES users(id),
    FOREIGN KEY (driver_id) REFERENCES drivers(id),
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id)
);
```

---

### Member 6: Kithila S (IT25100081) — Emergency & Customer Support Management
*Scrum Role: Scrum Master*

**Features:**
- Manage customer inquiries, complaints, and refund requests
- Guides/drivers report emergencies or incidents during trips
- Notify managers/administrators and track resolution status
- Send status updates to affected customers

**Suggested Classes:**
- `model/SupportRequest.java`
- `model/EmergencyReport.java`
- `dao/SupportRequestDAO.java`
- `dao/EmergencyReportDAO.java`
- `servlet/SupportServlet.java`
- `servlet/EmergencyServlet.java`

**Suggested Database Tables:**

```sql
CREATE TABLE support_requests (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    booking_id INT,
    request_type ENUM('inquiry', 'complaint', 'refund') NOT NULL,
    details TEXT,
    status ENUM('open', 'in_progress', 'resolved') DEFAULT 'open',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (booking_id) REFERENCES bookings(id)
);

CREATE TABLE emergency_reports (
    id INT PRIMARY KEY AUTO_INCREMENT,
    reported_by INT,
    schedule_id INT,
    incident_type ENUM('vehicle_breakdown', 'medical_incident', 'wildlife_threat', 'other') NOT NULL,
    details TEXT,
    status ENUM('reported', 'in_progress', 'resolved') DEFAULT 'reported',
    reported_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (reported_by) REFERENCES users(id),
    FOREIGN KEY (schedule_id) REFERENCES safari_schedules(id)
);
```

---

### Shared / Foundational: User Account Management

Not one of the six major functions individually assigned to a member, but required as shared infrastructure (FR1 — User Account Management, RBAC) that every module above depends on. The team should agree who implements this — commonly whoever needs it first, or split across pairs.

**Features:**
- Registration, login, logout, password recovery/change
- Role-Based Access Control (RBAC) for: Safari Tourist, Safari Guide, Safari Vehicle Driver, Safari Company Manager, Customer Support Officer, System Administrator
- Profile management

**Suggested Classes:**
- `model/User.java` (already created as sample)
- `dao/UserDAO.java` (already created as sample)
- `servlet/LoginServlet.java`
- `servlet/RegisterServlet.java`
- `servlet/ProfileServlet.java`

**Suggested Database Tables:**

```sql
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('tourist', 'guide', 'driver', 'manager', 'support_officer', 'admin') DEFAULT 'tourist',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Also Not Individually Assigned: Payment & Notifications

Payment & Billing (FR8) and Notification Management (FR9) are also documented functional requirements not owned by a single member. They support the Booking module (Member 1) and the online payment gateway / email-SMS notification service shown in the system architecture. Suggested starting table:

```sql
CREATE TABLE payments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT,
    amount DECIMAL(10,2),
    payment_method ENUM('credit_card', 'debit_card', 'online_banking') NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('success', 'failed', 'refunded') DEFAULT 'success',
    FOREIGN KEY (booking_id) REFERENCES bookings(id)
);
```

No additional table is required for notifications if sent via email/SMS in real time and not stored; add one only if the team decides to log notification history.

---

## 🔀 Git Workflow

### Branch Strategy

Each team member must work on their own branch. Do NOT push directly to `main`.

```bash
# Create your branch (do this once)
git checkout -b feature/safari-booking             # Sajini S. B.
git checkout -b feature/package-management         # Thrikawalage S.R
git checkout -b feature/vehicle-driver-management  # Ekanayake E.M.S.D.
git checkout -b feature/wildlife-sightings         # Hettiarachige S.S.H
git checkout -b feature/schedule-resource          # Amani J F
git checkout -b feature/emergency-support          # Kithila S
```

### Daily Workflow

```bash
# 1. Pull latest changes from main
git checkout main
git pull origin main

# 2. Switch to your branch and merge main
git checkout feature/your-branch
git merge main

# 3. Do your work, then commit
git add .
git commit -m "Add: description of your changes"

# 4. Push your branch
git push origin feature/your-branch

# 5. Create a Pull Request on GitHub for review
```

### Rules

- ⚠️ Never push directly to `main`
- ✅ Always create a Pull Request for merging
- ✅ Get at least 1 team member to review your PR
- ✅ Write meaningful commit messages
- ✅ Pull from `main` before starting new work

---

## 🧪 Testing the Project

1. Start Tomcat and deploy the project
2. Visit: `http://localhost:8080/wildlife-safari-management/test`
3. You should see the success message
4. Visit: `http://localhost:8080/wildlife-safari-management/views/login.jsp`
5. You should see the login page

---

## 📝 Notes

- This is a starter template only. Each team member should implement their assigned module as described in [Team Responsibilities](#-team-responsibilities-6-members).
- Follow the MVC pattern: **Model → DAO → Servlet → JSP**
- Use `PreparedStatement` for all SQL queries (prevents SQL injection)
- Use `HttpSession` for managing logged-in users and role-based access
- Add your own JSP pages under the `views/` folder
- Add your own CSS/JS files under `css/` and `js/` folders
- Suggested database tables are starting points based on the project's functional requirements — review and finalize the full ER design as a team before implementation (per the Week 4–5 database design milestone).

---

## 📌 Project Reference

For full requirements, stakeholders, use case scenarios, Scrum backlog, sprint plan, and timeline behind this project, see the group's Project Proposal Report and Lab Sheet 02 (Agile Development) documents.

**Group ID:** 2026-Y2-S1-MLB-B13G2-06
