# 🗄️ Bash DBMS Project

A simple **Database Management System (DBMS)** built using **Bash scripting**.  
This project simulates basic database operations using directories and text files.

---

## 📌 Project Idea

The system allows users to:

- Create databases
- List databases
- Connect to a database
- Drop a database
- Create tables
- Insert, update, delete, and select data
- Validate datatypes
- Enforce primary key constraints

---

## 📂 How It Works

- **Database** → Stored as a directory inside `databases/`
- **Table** → Stored as two files inside the database folder:
  - `.meta` → Table structure (columns, types, primary key)
  - `.data` → Table data (rows)

---

## 📁 Project Structure
```
bash-dbms/
│
├── databases/ # Contains all databases (directories)
│
├── lib/
│ ├── database.sh # Database operations
│ ├── table.sh # Table operations
│ ├── validation.sh # Validation functions
│
│
├── dbms.sh # Main script (entry point)
└── README.md
```
## Authors
Mawadah Hassan & Maryam Abdelraheem