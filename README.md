# Bash DBMS 

A simple **Database Management System (DBMS)** implemented using **Bash scripting**.  
This project simulates basic database operations (Databases, Tables, CRUD) using the Linux file system.

The main goal of this project is to understand:
- How DBMS works internally
- How data and metadata are managed using files
- Advanced Bash scripting concepts
- CLI & GUI integration using Bash

---

##  Project Structure

    bash-dbms/
    │
    ├── storage/                     # Storage Layer
    │   ├── databases/               # Each database is a directory
    │      └── <db_name>/
    │          ├── tables/           # Table data files
    │          └── metadata/         # Table metadata files
    │             
    │
    ├── DatabaseScripts/              # Database Logic (CLI)
    │   ├── Create_DB.sh
    │   ├── Drop_DB.sh
    │   ├── List_DB.sh
    │   ├── Rename_DB.sh
    │   └── menuDB.sh
    │
    ├── TableScripts/                 # Table & Data Logic (CLI)
    │   ├── lib/
    │   │   ├── CreateTable.sh
    │   │   ├── DropTable.sh
    │   │   ├── InsertIntoTable.sh
    │   │   ├── SelectFromTable.sh
    │   │   ├── DeleteFromTable.sh
    │   │   ├── UpdateTable.sh
    │   │   └── ListTable.sh
    │   └── TableMenu.sh
    │
    ├── Zenity GUI/                   # GUI Version (Zenity)
    │   ├── Databases/
    │   ├── Database_menu.sh
    │   ├── Connect_DB.sh
    │   ├── Create_DB.sh
    │   ├── Drop_DB.sh
    │   ├── List_DB.sh
    │   ├── Create_Table.sh
    │   ├── Drop_Table.sh
    │   ├── Insert_Table.sh
    │   ├── Select_Table.sh
    │   ├── Update_Table.sh
    │   ├── Delete_From_Table.sh
    │   └── Table_Menu.sh
    │
    └── README.md

---

##  Features

###  Database Operations
- Create Database
- List Databases
- Connect to Database
- Rename Database
- Drop Database

###  Table Operations
- Create Table
- List Tables
- Drop Table
- Insert Into Table
- Select From Table
- Update Table
- Delete From Table

---

##  Storage Design

### Databases
Each database is stored as a directory under:

    storage/databases/<db_name>/

### Tables
- **Table data files:**

      storage/databases/<db_name>/tables/

- **Table metadata files:**

      storage/databases/<db_name>/metadata/

---

##  Metadata Format

Each table has a metadata file describing its schema.

**Example:**

    "Table Name": Students
    "Number of Columns": 3
    "Column Name": ID
    "Column Type": Int
    "Primary Key": y
    --------------------
    "Column Name": Name
    "Column Type": Str
    "Primary Key": n
    --------------------
    "Column Name": Age
    "Column Type": Int
    "Primary Key": n

---

##  How to Run (CLI Version)

### 1️ Clone the repository

    git clone https://github.com/fouad64/Bash_DBMS.git
    cd Bash_DBMS

### 2️ Run Database Menu

    bash DatabaseScripts/menuDB.sh

### 3️ After connecting to a database

    bash TableScripts/TableMenu.sh

---

##  GUI Version (Zenity Interface)

In addition to the CLI-based menus, this project also provides a **Graphical User Interface (GUI)** built using **Zenity**.

###  GUI Features
- User-friendly dialog windows
- No need to interact directly with the terminal
- Performs the same operations as the CLI version

### How to Run the GUI

**Make sure Zenity is installed:**

    sudo apt install zenity

**Run the GUI:**

    bash "Zenity GUI/Database_menu.sh"

>  The GUI uses the same backend logic and storage structure as the CLI version.

---

##  Technologies Used

- Bash Scripting
- Linux File System
- awk / grep / sed
- Zenity (GUI)
- CLI-based Menus

---

##  Naming Rules

**Database & Table names:**
- Must start with a letter or underscore
- Can contain letters, numbers, underscores only

**Data Types:**
- `Int`
- `Str`

---

## Educational Goals

This project helps in learning:
- Bash scripting best practices
- File-based data storage
- Metadata handling
- Input validation
- Modular shell scripting
- CLI & GUI integration

---

## Future Improvements

- NOT NULL constraints
- Foreign Keys
- Indexing
- Export / Import tables
- Better error handling
- Logging system

---
---

## Contact Us



**Fouad Yasser**  
[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=flat&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/fouadyasser)

**Mohamed Hisham**  
[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=flat&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/mohamed-hesham-729352230/)

Feel free to reach out for feedback, suggestions, or collaboration 🤝


