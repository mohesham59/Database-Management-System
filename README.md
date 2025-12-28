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

