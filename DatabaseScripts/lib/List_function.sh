#!/usr/bin/env bash
List_func(){


local DB_STORAGE="$PROJECT_ROOT/storage/databases"
ls -l "$DB_STORAGE" |grep ^d | cut -d' ' -f9

}
