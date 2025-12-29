# Bash-DBMS

A simple **Database Management System (DBMS)** implemented entirely in **Bash**, supporting **CLI, SQL, and GUI interfaces**.  
It uses the filesystem for storage, where each database is a folder, each table is a CSV file, and metadata is stored separately.

---

## 🏗️ Project Structure

```text
bash-dbms/
│
├─ README.md
├─ LICENSE
├─ .gitignore
│
├─ storage/                     # 🔹 Persistent Data Layer
│   ├─ databases/
│   │   └─ <db_name>/
│   │       ├─ tables/
│   │       │   └─ <table_name>.csv
│   │       └─ metadata/
│   │           ├─ <table_name>.columns
│   │           ├─ <table_name>.types
│   │           └─ <table_name>.pk
│   │
│   └─ db_list.meta
│
├─ lib/                         # 🔹 Core Logic (NO UI)
│   ├─ db/
│   │   ├─ create_db.sh
│   │   ├─ drop_db.sh
│   │   ├─ list_db.sh
│   │   └─ rename_db.sh
│   │
│   ├─ table/
│   │   ├─ create_table.sh
│   │   ├─ drop_table.sh
│   │   ├─ insert.sh
│   │   ├─ delete.sh
│   │   ├─ update.sh
│   │   └─ select.sh
│   │
│   └─ utils.sh                # validation, logging, helpers
│
├─ cli/                         # 🔹 CLI Interface
│   ├─ db_menu.sh
│   └─ table_menu.sh
│
├─ gui/                         # 🔹 Zenity Interface
│   ├─ db/
│   │   ├─ create_db_gui.sh
│   │   ├─ drop_db_gui.sh
│   │   └─ list_db_gui.sh
│   │
│   └─ table/
│       ├─ create_table_gui.sh
│       ├─ drop_table_gui.sh
│       ├─ insert_gui.sh
│       ├─ delete_gui.sh
│       ├─ update_gui.sh
│       └─ select_gui.sh
│
├─ sql/                         # 🔹 SQL-like Interface
│   ├─ sql_parser.sh
│   ├─ sql_insert.sh
│   ├─ sql_delete.sh
│   ├─ sql_update.sh
│   └─ sql_select.sh
│
└─ main.sh                      # 🔹 Entry point
```
=======
# Bash DBMS 🐚🗄️

A simple **Database Management System (DBMS)** implemented using **Bash scripting**.  
This project simulates basic database operations (Databases, Tables, CRUD) using the Linux file system.

The goal of this project is to understand:
- How DBMS works internally
- How data and metadata can be managed using files
- Advanced Bash scripting concepts

---

## 📁 Project Structure



bash-dbms/
│
├─ storage/                   # Storage Layer
│   ├─ databases/             # Each database is a directory
│   │   └─ <db_name>/
│   │       ├─ tables/        # Table data files
│   │       └─ metadata/      # Table metadata files
│   └─ db_list.meta           # List of all databases
│
├─ DatabaseScripts/           # Database Logic
│   ├─ Create_DB.sh           # Create a new database
│   ├─ Drop_DB.sh             # Drop an existing database
│   ├─ List_DB.sh             # List all databases
│   ├─ Rename_DB.sh           # Rename a database
│   └─ menuDB.sh              # Database main menu
│
└─ TableScripts/              # Table & Data Logic
├─ lib/
│   ├─ CreateTable.sh     # Create table
│   ├─ DropTable.sh       # Drop table
│   ├─ InsertIntoTable.sh # Insert data into table
│   ├─ SelectFromTable.sh # Select data from table
│   ├─ DeleteFromTable.sh # Delete records
│   ├─ UpdateTable.sh     # Update records
│   └─ ListTable.sh       # List tables
└─ TableMenu.sh           # Table main menu


---

## ⚙️ Features

### 📦 Database Operations
- Create Database
- List Databases
- Connect to Database
- Rename Database
- Drop Database

### 📋 Table Operations
- Create Table
- List Tables
- Drop Table
- Insert Into Table
- Select From Table
- Update Table
- Delete From Table

---

## 🗄️ Storage Design

### Databases
Each database is stored as a directory under:
```

storage/databases/<db_name>/

```

### Tables
- Table data files are stored in:
```

storage/databases/<db_name>/tables/

```

- Table metadata files are stored in:
```

storage/databases/<db_name>/metadata/

````

---

## 🧾 Metadata Format

Each table has a metadata file describing its schema.

Example:

```text
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
````

---

## ▶️ How to Run

### 1️⃣ Clone the repository

```bash
git clone <repo-url>
cd bash-dbms
```

### 2️⃣ Run Database Menu

```bash
bash DatabaseScripts/menuDB.sh
```

### 3️⃣ After connecting to a database

```bash
bash TableScripts/TableMenu.sh
```

---

## 🛠️ Technologies Used

* Bash Scripting
* Linux File System
* awk / grep / sed
* CLI-based Menus

---

## 📌 Naming Rules

* Database & Table names:

  * Must start with a letter or underscore
  * Can contain letters, numbers, underscores only

* Data Types:

  * `Int`
  * `Str`

---

## 🎯 Educational Goals

This project helps in learning:

* Bash scripting best practices
* File-based data storage
* Metadata handling
* Input validation
* Modular shell scripting

---

## 🚀 Future Improvements

* NOT NULL constraints
* Foreign Keys
* Indexing
* Export / Import tables
* Better error handling
* Logging system

---

## 👨‍💻 Author

Built with ❤️ using Bash for learning and educational purposes.

---

## 📜 License

This project is open-source and free to use for educational purposes.



