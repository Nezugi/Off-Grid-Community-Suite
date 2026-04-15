Off-Grid Community Suite
A suite of community tools for NomadNet nodes — built for off-grid, decentralised mesh networks running on the Reticulum protocol.
All tools share the same stack: Python 3 · Micron Markup · SQLite · no external dependencies.
---
Tools
Project	Description
nomadComBoard	Community discussion forum with subforums, tags, user roles and moderation
nomadChat	Public chat room — single file, no login required
nomadBlog	Node blog and news page with comments
nomadYellow	Curated community directory — like a Yellow Pages for the mesh
nomadMarket	Classifieds board — Offer / Wanted / Trade / Free
nomadCalendar	Shared event calendar with recurring event support
nomadMission	Task board for closed groups with granular permissions
nomadWarehouse	Inventory management with per-category user permissions
---
Design Principles
Built for real use in an off-grid community. Every tool follows the same philosophy:
No internet required — everything runs locally on the mesh
No external Python packages — only the standard library; no `pip install` needed
No background processes — cleanup and maintenance happen passively on page load
No cookies — session tokens passed as URL parameters, as NomadNet requires
Minimal hardware — runs well on a Raspberry Pi or similar low-power device
SQLite storage — simple, reliable, no database server needed
Consistent UI — shared header, navigation, and footer across all tools
---
Common Architecture
Every tool follows the same pattern:
```
tool/
├── main.py         ← SQLite DB, sessions, shared functions (imported by all pages)
├── setup\_admin.py  ← CLI script to set the admin password
├── help.mu         ← built-in user guide
└── \*.mu            ← Micron/Python pages served by NomadNet
```
`main.py` initialises the database on import, runs passive cleanup, and provides:
`print\_header(subtitle=None)` — consistent title + description header
`print\_footer()` — suite attribution footer
`nav\_bar(...)` — navigation with orange `← Node Start` as the last link
`lxmf\_link(address)` — clickable `lxmf://` address links
---
Shared Configuration Variables
Every tool has these in `main.py`:
```python
storage\_path     = "/home/YOUR\_USER/.nomadToolName"  # ← always set this
page\_path        = ":/page/toolname"
site\_name        = "nomadToolName"
site\_description = "Short description shown below the title"
node\_homepage    = ":/page/index.mu"
```
---
Installation Pattern
All tools follow the same steps:
```bash
# 1. Copy to your node's pages directory
cp -r TOOL/ \~/.nomadnetwork/storage/pages/TOOL/

# 2. Make .mu files executable
chmod +x \~/.nomadnetwork/storage/pages/TOOL/\*.mu

# 3. Create data directory
mkdir -p /home/YOUR\_USER/.nomadTOOL

# 4. Set storage\_path in main.py to your real user path

# 5. Set admin password
python3 \~/.nomadnetwork/storage/pages/TOOL/setup\_admin.py

# 6. Restart NomadNet
```
---
NomadNet Compatibility Notes
Hard-won lessons from extensive real-world testing:
Use `F`-hex color codes (`F777`, `F4af`) — grayscale codes (``gXX`) are broken in NomadNet
Never place a space before a backtick code — the backtick gets swallowed by the parser
`print("#!c=0")` must be the very first output of every dynamic page to disable caching
All `.mu` files must be `chmod +x` — without it NomadNet serves the Python source as plain text
Session tokens must be explicitly appended to submit links — ``*` only sends form fields, URL parameters are lost
When updating files while NomadNet is running: `cp file.mu /tmp/ \&\& mv /tmp/file.mu destination/` (atomic swap avoids "Text file busy")
---
License
MIT
---
Built for an off-grid community that needed practical communication and coordination tools on a local mesh network. Shared here in the hope that other communities find them useful.
