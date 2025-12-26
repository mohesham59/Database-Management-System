# Bash-DBMS

A simple **Database Management System (DBMS)** implemented entirely in **Bash**, supporting **CLI, SQL, and GUI interfaces**.  
It uses the filesystem for storage, where each database is a folder, each table is a CSV file, and metadata is stored separately.

---

## 🏗️ Project Structure

```text
bash-dbms/
│
├─ README.md                  # Documentation & instructions
├─ LICENSE
├─ .gitignore
│
├─ storage/                   # 🔹 Storage Layer
│   ├─ databases/             # Each DB is a folder
│   │   └─ <db_name>/
│   │       ├─ tables/        # Each table as a CSV file
│   │       │   └─ <table_name>.csv
│   │       └─ metadata/      # Table metadata
│   │           ├─ <table_name>_columns.meta
│   │           ├─ <table_name>_types.meta
│   │           └─ <table_name>_pk.meta
│   └─ db_list.meta           # List of existing databases
│
├─ DatabaseScripts/           # 🔹 Database Logic
│   ├─ Create_DB.sh
│   ├─ Drop_DB.sh
│   ├─ List_DB.sh
│   ├─ Rename_DB.sh
│   └─ DB_Menu.sh             # Calls the above functions
│
├─ TableScripts/              # 🔹 Table & Data Logic + Interface
│
│   ├─ GUI_Scripts/           # Zenity GUI forms & windows
│   │   ├─ Table_Header.sh
│   │   ├─ create_Table.sh
│   │   ├─ drop_Table.sh
│   │   ├─ insert_into_Table.sh
│   │   ├─ delete_from_table.sh
│   │   ├─ update_Table.sh
│   │   ├─ select_from_Table.sh
│   │   ├─ list_Tables.sh
│   │   └─ table_Operations.sh   # Orchestrates GUI actions
│   │
│   ├─ SQL_Scripts/           # SQL input handlers (calls same logic)
│   │   ├─ SQLDeleteFromTable.sh
│   │   ├─ SQLDropTable.sh
│   │   ├─ SQLInsertIntoTable.sh
│   │   ├─ SQLUpdateTable.sh
│   │   └─ SQLSelectFromTable.sh
│   │
│   └─ Table_Menu.sh          # CLI table menu (optional)
│

