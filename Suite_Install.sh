#!/bin/bash

echo "==========================================="
echo "   NomadNet Community Suite Installer"
echo "   Interactive Setup Tool"
echo "==========================================="
echo ""

USER_NAME=$(whoami)
PAGES_DIR="$HOME/.nomadnetwork/storage/pages"
INDEX_FILE="$PAGES_DIR/index.mu"

# Track installed modules
declare -A INSTALLED

# ---------------------------------------------------------------------------
# install_module <repo_url> <folder_name> <admin_script> <needs_subfolder>
#
#   repo_url      — GitHub URL to clone
#   folder_name   — target directory name (used as clone dest and pages subdir)
#   admin_script  — relative path to admin setup script inside the module,
#                   or "" if none
#   needs_subfolder — "yes" if the module needs its own pages subdirectory
#                     created explicitly (e.g. chat)
# ---------------------------------------------------------------------------
install_module() {
    local repo_url=$1
    local folder_name=$2
    local admin_script=$3
    local needs_subfolder=$4

    echo ""
    echo "-------------------------------------------"
    echo "Installing: $folder_name"
    echo "-------------------------------------------"

    # Clone into exactly $folder_name so subsequent paths are predictable
    git clone "$repo_url" "$folder_name" || { echo "ERROR: git clone failed for $repo_url"; return 1; }

    cd "$folder_name" || { echo "ERROR: could not enter $folder_name"; return 1; }

    # Create target pages subdirectory if required
    if [ "$needs_subfolder" = "yes" ]; then
        mkdir -p "$PAGES_DIR/$folder_name"
    fi

    # Copy everything from the cloned repo into the pages directory
    cp -r . "$PAGES_DIR/$folder_name/"

    # Make all .mu files executable (root level, admin/ subdir, admin_* prefix)
    chmod +x "$PAGES_DIR/$folder_name"/*.mu          2>/dev/null
    chmod +x "$PAGES_DIR/$folder_name"/admin/*.mu    2>/dev/null
    chmod +x "$PAGES_DIR/$folder_name"/admin_*.mu    2>/dev/null

    # Patch storage_path in main.py if present.
    # Each module uses the pattern /home/user/.nomad<ModuleName> as placeholder.
    # We replace it with the real user's home path.
    if [ -f "$PAGES_DIR/$folder_name/main.py" ]; then
        # Capitalise first letter of folder_name for the storage dir name
        # e.g. warehouse -> .nomadWarehouse, yellow -> .nomadYellow
        local cap_name
        cap_name="$(echo "${folder_name:0:1}" | tr '[:lower:]' '[:upper:]')${folder_name:1}"
        sed -i "s|/home/user/.nomad${cap_name}|/home/$USER_NAME/.nomad${cap_name}|g" \
            "$PAGES_DIR/$folder_name/main.py"
    fi

    # Admin account / password setup
    if [ -n "$admin_script" ]; then
        echo ""
        echo "Admin setup for $folder_name"
        python3 "$PAGES_DIR/$folder_name/$admin_script"
    fi

    INSTALLED[$folder_name]=1

    cd ..
}

echo "Which modules do you want to install?"
echo "1) nomadWarehouse"
echo "2) nomadMission"
echo "3) nomadCalendar"
echo "4) nomadMarket"
echo "5) nomadYellow"
echo "6) nomadBlog"
echo "7) nomadComBoard"
echo "8) nomadChat"
echo "9) All modules"
echo ""

read -p "Your selection (e.g. 1 3 5): " choices

for choice in $choices; do
    case $choice in
        1) install_module "https://github.com/Nezugi/nomadWarehouse" "warehouse" "create_admin.py"          "no"  ;;
        2) install_module "https://github.com/Nezugi/nomadMission"   "mission"   "setup_admin.py"           "no"  ;;
        3) install_module "https://github.com/Nezugi/nomadCalendar"  "calendar"  "setup_admin.py"           "no"  ;;
        4) install_module "https://github.com/Nezugi/nomadMarket"    "market"    "setup_admin.py"           "no"  ;;
        5) install_module "https://github.com/Nezugi/nomadYellow"    "yellow"    "setup_admin.py"           "no"  ;;
        6) install_module "https://github.com/Nezugi/nomadBlog"      "blog"      "setup.py"                 "no"  ;;
        7) install_module "https://github.com/Nezugi/nomadComBoard"  "comboard"  "admin/create_admin.py"    "no"  ;;
        8) install_module "https://github.com/Nezugi/nomadChat"      "chat"      ""                         "yes" ;;
        9)
            install_module "https://github.com/Nezugi/nomadWarehouse" "warehouse" "create_admin.py"          "no"
            install_module "https://github.com/Nezugi/nomadMission"   "mission"   "setup_admin.py"           "no"
            install_module "https://github.com/Nezugi/nomadCalendar"  "calendar"  "setup_admin.py"           "no"
            install_module "https://github.com/Nezugi/nomadMarket"    "market"    "setup_admin.py"           "no"
            install_module "https://github.com/Nezugi/nomadYellow"    "yellow"    "setup_admin.py"           "no"
            install_module "https://github.com/Nezugi/nomadBlog"      "blog"      "setup.py"                 "no"
            install_module "https://github.com/Nezugi/nomadComBoard"  "comboard"  "admin/create_admin.py"    "no"
            install_module "https://github.com/Nezugi/nomadChat"      "chat"      ""                         "yes"
            ;;
    esac
done

echo ""
echo "-------------------------------------------"
echo "Generating index.mu"
echo "-------------------------------------------"

if [ -f "$INDEX_FILE" ]; then
    read -p "index.mu already exists. Overwrite? (y/n): " overwrite
    if [ "$overwrite" != "y" ]; then
        echo "Keeping existing index.mu"
        exit 0
    fi
fi

# ---------------------------------------------------------------------------
# Write index.mu header
# ---------------------------------------------------------------------------
cat > "$INDEX_FILE" << 'EOF'
#!c=3600
#!bg=111
#!fg=ddd

`c`F0af`!nomadNode`!`f
`c`F555Off-Grid Community Suite`f
`a

-

>Services
EOF

# ---------------------------------------------------------------------------
# Append a service block only for each installed module
# ---------------------------------------------------------------------------
add_block() {
    echo "$1" >> "$INDEX_FILE"
}

if [ ${INSTALLED[comboard]} ]; then
add_block "
\`F0af\`![ ComBoard ]\`!\`f\`F777  Discussions, topics & comments\`f
\`F555Register an account and join the conversation.\`f
\`[-> open nomadComBoard\`:/page/comboard/index.mu]

-="
fi

if [ ${INSTALLED[chat]} ]; then
add_block "
\`Faff\`![ Chat ]\`!\`f\`F777  Public chat on this node\`f
\`F555Send a message - no account needed, just a nickname.\`f
\`[-> open nomadChat\`:/page/chat/chat.mu]

-="
fi

if [ ${INSTALLED[blog]} ]; then
add_block "
\`F5d5\`![ Blog ]\`!\`f\`F777  Articles & news from this node\`f
\`F555Posts, notes and updates from the node operator.\`f
\`[-> open nomadBlog\`:/page/blog/index.mu]

-="
fi

if [ ${INSTALLED[yellow]} ]; then
add_block "
\`Fd95\`![ Yellow ]\`!\`f\`F777  Community directory\`f
\`F555People & services on the mesh - submit, discover, contact.\`f
\`[-> open nomadYellow\`:/page/yellow/index.mu]

-="
fi

if [ ${INSTALLED[market]} ]; then
add_block "
\`F1a6\`![ Market ]\`!\`f\`F777  Classifieds board\`f
\`F555Offer, wanted, trade, free - listings expire after 7 days.\`f
\`[-> open nomadMarket\`:/page/market/index.mu]

-="
fi

if [ ${INSTALLED[warehouse]} ]; then
add_block "
\`Fda6\`![ Warehouse ]\`!\`f\`F777  Inventory & loan management\`f
\`F555Add items, withdraw, deposit - with loan tracking and low stock alerts.\`f
\`[-> open nomadWarehouse\`:/page/warehouse/index.mu]

-="
fi

if [ ${INSTALLED[mission]} ]; then
add_block "
\`F0f8\`![ Mission ]\`!\`f\`F777  Task board for communities\`f
\`F555Post missions, apply, rate - trust & collaboration.\`f
\`[-> open nomadMission\`:/page/mission/index.mu]

-="
fi

if [ ${INSTALLED[calendar]} ]; then
add_block "
\`F4be\`![ Calendar ]\`!\`f\`F777  Events & meetups\`f
\`F555Shared community calendar. Submit events and recurring meetups.\`f
\`[-> open nomadCalendar\`:/page/calendar/index.mu]

-="
fi

# ---------------------------------------------------------------------------
# Footer
# ---------------------------------------------------------------------------
cat >> "$INDEX_FILE" << 'EOF'

-

>>About this Suite

`F777A collection of open tools for community organisation`f
`F777without relying on the internet, servers or central platforms.`f
`F777Communication, knowledge sharing and resource management -`f
`F777all local, all under your control.`f

-

`c`F444Off-Grid Community Suite - decentralised & offline-first`f
`a
EOF

echo ""
echo "==========================================="
echo "Installation complete!"
echo "index.mu generated."
echo "Restart NomadNet to activate the modules."
echo "==========================================="
