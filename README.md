# Bash DBMS 🐚🗄️

A simple **Database Management System (DBMS)** implemented using **Bash scripting**.  
This project simulates basic database operations (Databases, Tables, CRUD) using the Linux file system.

The main goal of this project is to understand:
- How DBMS works internally
- How data and metadata are managed using files
- Advanced Bash scripting concepts
- CLI & GUI integration using Bash

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
├─ Zenity GUI/            # GUI Version (Zenity)
│ ├─ Databases/
│ ├─ Database_menu.sh
│ ├─ Connect_DB.sh
│ ├─ Create_DB.sh
│ ├─ Drop_DB.sh
│ ├─ List_DB.sh
│ ├─ Create_Table.sh
│ ├─ Drop_Table.sh
│ ├─ Insert_Table.sh
│ ├─ Select_Table.sh
│ ├─ Update_Table.sh
│ ├─ Delete_From_Table.sh
│ └─ Table_Menu.sh
│
└─ README.md
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



```

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
🖥️ GUI Version (Zenity Interface)
In addition to the CLI-based menus, this project also provides a
Graphical User Interface (GUI) built using Zenity.

🎨 GUI Features
User-friendly dialog windows
No need to interact directly with the terminal
Performs the same operations as the CLI version
▶️ How to Run the GUI
Make sure Zenity is installed:

bash
sudo apt install zenity
Run the GUI:

bash
bash "Zenity GUI/Database_menu.sh"
```

## 🛠️ Technologies Used

Bash Scripting
Linux File System
awk / grep / sed
Zenity (GUI)
CLI-based Menus


---

## 📌 Naming Rules

* Database & Table names:

  * Must start with a letter or underscore
  * Can contain letters, numbers, underscores only

* Data Types:

  * `Int`
  * `Str`

---

## Educational Goals

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

## Contact Us

Fouad Yasser 
LinkedIn: https://www.linkedin.com/in/fouadyasser
Mohamed Hisham
LinkedIn: https://www.linkedin.com/in/mohamedhesham

Feel free to reach out for feedback, suggestions, or collaboration 🤝






e to use for educational purposes.
