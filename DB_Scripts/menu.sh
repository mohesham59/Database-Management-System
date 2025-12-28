#!/usr/bin/env bash
#============== source partion =============== 
source ./Creation_function.sh 
source ./List_function.sh
source ./Drop_function.sh
source ./TableMenu.sh
source ./Connect_function.sh

while true 
do
#============== baner section =================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'


clear


echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                                                              ║${NC}"
echo -e "${CYAN}║${YELLOW}  ██╗████████╗██╗    ██████╗ ██████╗ ███╗   ███╗███████╗  ${CYAN}    ║${NC}"
echo -e "${CYAN}║${YELLOW}  ██║╚══██╔══╝██║    ██╔══██╗██╔══██╗████╗ ████║██╔════╝  ${CYAN}    ║${NC}"
echo -e "${CYAN}║${YELLOW}  ██║   ██║   ██║    ██║  ██║██████╔╝██╔████╔██║███████╗  ${CYAN}    ║${NC}"
echo -e "${CYAN}║${YELLOW}  ██║   ██║   ██║    ██║  ██║██╔══██╗██║╚██╔╝██║╚════██║  ${CYAN}    ║${NC}"
echo -e "${CYAN}║${YELLOW}  ██║   ██║   ██║    ██████╔╝██████╔╝██║ ╚═╝ ██║███████║  ${CYAN}    ║${NC}"
echo -e "${CYAN}║${YELLOW}  ╚═╝   ╚═╝   ╚═╝    ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝  ${CYAN}    ║${NC}"
echo -e "${CYAN}║                                                              ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${GREEN}                  Supervised by : ${NC}"
echo -e "${CYAN}                  DR|Shreen Bahader${NC}"
echo -e "${GREEN}                  Created  by :${NC}"
echo -e "${MAGENTA}                  Fouad Yasser${NC}"
echo -e "${MAGENTA}                  Mohamed Hesham${NC}"
echo ""
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
   echo "1) Create Database"
    echo "2) List Databases"
    echo "3) Connect To Database"
    echo "4) Drop Database"
    echo "5) Exit"
    echo ""
    
    read -p "Select an option (1-5): " choice
            case $choice in
            1)
            
            CreationFunction
            read 
	    ;;
            2)
           
            List_func
            read 
	    ;;
            3)
            connect_func
            read 
	    ;;
            4)
             
            Drop_func
            read 
	    ;;
            5)
	     
            echo "Exit... "
	    exit 0
            ;;
            *)
	    
            echo "Please Enter a valed choise (1-5) "
            read 
            ;;
            esac    

    
done
