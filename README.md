## Off-Grid Community Suite

A suite of community tools for [NomadNet](https://github.com/markqvist/NomadNet) nodes — built for off-grid, decentralised mesh networks running on the [Reticulum](https://github.com/markqvist/Reticulum) protocol.

All tools share the same stack: **Python 3 · Micron Markup · SQLite · No external dependencies**.

---

## Tools

Go to the individual sites for the tools you need.
In this project you find an indx.mu for your Node to link them all for easy access

|Project|Description|
|---|---|
|[./nomadComBoard](https://github.com/Nezugi/nomadComBoard)|Community discussion forum with subforums, tags, user roles and moderation|
|[./nomadChat](https://github.com/Nezugi/nomadChat/tree/main)|Public chat room — single file, no login required|
|[./nomadBlog](https://github.com/Nezugi/nomadBlog)|Node blog and news page|
|[./nomadYellow](https://github.com/Nezugi/nomadYellow)|Curated community directory — like Yellow Pages for the mesh|
|[./nomadMarket](https://github.com/Nezugi/nomadMarket)|Classifieds board — Offer / Wanted / Trade / Free|
|[./nomadCalendar](https://github.com/Nezugi/nomadCalendar/tree/main)|Shared event calendar with recurring event support|
|[./nomadMission](https://github.com/Nezugi/nomadMission)|Task board for closed groups with granular permissions|
|[./nomadWarehouse](https://github.com/Nezugi/nomadWarehouse)|Inventory management with per-category user permissions|

---

## Design Principles

Built for real use in an off-grid community. Every tool follows the same philosophy:

- **No internet required** — everything runs locally on the mesh
- **No external Python packages** — only the standard library; no `pip install`
- **No background processes** — cleanup and maintenance happen passively on page load
- **No cookies** — session tokens are passed as URL parameters (NomadNet requirement)
- **Minimal hardware** — runs well on Raspberry Pi–class devices
- **SQLite storage** — simple, reliable, serverless
- **Consistent UI** — shared header, navigation, and footer across all tools

---

## Common Architecture

Each tool follows the same structure:

```text
tool/
├── main.py           # SQLite DB, sessions, shared functions
├── setup_admin.py    # CLI script to set the admin password
├── help.mu           # Built-in user guide
└── *.mu              # Micron/Python pages served by NomadNet
```

`main.py` initializes the database on import, runs passive cleanup, and provides:

- `print_header(subtitle=None)` — consistent title + description header
- `print_footer()` — suite attribution footer
- `nav_bar(...)` — navigation with orange ← Node Start as the last link
- `lxmf_link(address)` — clickable `lxmf` address links for direct contact to everyone

---

## Shared Configuration Variables

Each tool defines the following in `main.py`:

```python
storage_path = "/home/YOUR_USER/.nomadToolName"  # always set this
page_path = ":/page/toolname"
site_name = "nomadToolName"
site_description = "Short description shown below the title"
node_homepage = ":/page/index.mu"
```

---

## Installation Pattern


All tools follow the same installation steps:

```bash
# 1. Copy tool to your node's pages directory
cp -r TOOL/ ~/.nomadnetwork/storage/pages/TOOL/

# 2. Make .mu files executable
chmod +x ~/.nomadnetwork/storage/pages/TOOL/*.mu

# 3. Set storage_path in main.py to your real user path

# 4. Set admin password
python3 ~/.nomadnetwork/storage/pages/TOOL/setup_admin.py

# 5. Restart NomadNet
```

---

## Structure on the Node

```text
pages/
├── blog
├── calendar
├── chat
├── comboard
├── market
├── mission
├── warehouse
├── yellow
└──index.mu
```
---

## License

MIT

---

*Built for an off‑grid community that needed practical communication and coordination tools on a local mesh network. Shared in the hope that other communities find it useful.*
