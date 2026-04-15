## Off-Grid Community Suite

A suite of community tools for https://github.com/markqvist/NomadNet nodes — built for off-grid, decentralised mesh networks running on the https://github.com/markqvist/Reticulum protocol.

All tools share the same stack: **Python 3 · Micron Markup · SQLite · No external dependencies**.

---

## Tools

|Project|Description|
|---|---|
|./nomadComBoard|Community discussion forum with subforums, tags, user roles and moderation|
|./nomadChat|Public chat room — single file, no login required|
|./nomadBlog|Node blog and news page with comments|
|./nomadYellow|Curated community directory — like Yellow Pages for the mesh|
|./nomadMarket|Classifieds board — Offer / Wanted / Trade / Free|
|./nomadCalendar|Shared event calendar with recurring event support|
|./nomadMission|Task board for closed groups with granular permissions|
|./nomadWarehouse|Inventory management with per-category user permissions|

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
- `lxmf_link(address)` — clickable `lxmf://` address links

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

# 3. Create data directory
mkdir -p /home/YOUR_USER/.nomadTOOL

# 4. Set storage_path in main.py to your real user path

# 5. Set admin password
python3 ~/.nomadnetwork/storage/pages/TOOL/setup_admin.py

# 6. Restart NomadNet
```

---

## NomadNet Compatibility Notes

Hard‑won lessons from extensive real‑world testing:

- Use **F‑hex color codes** (e.g. `F777`, `F4af`) — grayscale codes (`gXX`) are broken
- Never place a space before a backtick code — the parser swallows it
- `print("#!c=0")` must be the **very first output** of every dynamic page to disable caching
- All `.mu` files **must** be `chmod +x`, or NomadNet serves the source as plain text
- Session tokens must be appended to submit links — `*` only sends form fields
- When updating files while NomadNet is running:
  ```bash
  cp file.mu /tmp/ && mv /tmp/file.mu destination/
  ```
  (Atomic swap avoids `Text file busy` errors)

---

## License

MIT

---

*Built for an off‑grid community that needed practical communication and coordination tools on a local mesh network. Shared in the hope that other communities find it useful.*
