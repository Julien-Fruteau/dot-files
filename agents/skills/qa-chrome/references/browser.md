# Driven browser: Chrome DevTools MCP

The `chrome-devtools` MCP server attaches to a **visible** Chrome that the user
launched on a dedicated profile. The user logs in there themselves (SSO, OIDC)
once; the session survives from one QA to the next, and they watch live what you
do — which is what makes visual validation together possible.

If the MCP tools are not available in this agent, see
[`mcp-setup.md`](mcp-setup.md) first.

## Each QA session

The QA Chrome must run with its debugging port open. Check with
`curl -s http://127.0.0.1:9222/json/version`. Otherwise ask the user to start it:

```bash
# Linux
google-chrome --remote-debugging-port=9222 --user-data-dir="$HOME/.cache/chrome-qa" &
# macOS
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --remote-debugging-port=9222 --user-data-dir="$HOME/.cache/chrome-qa" &
```

(`chromium` works the same way.) The dedicated profile is required: Chrome
refuses the debugging port on the default profile, and it keeps the QA apart
from personal sessions. If the page requires a login, the user does it in that
window; you wait.

## Useful tools

Tool names are the server's; the agent may prefix them (`mcp__chrome-devtools__…`)
or reach them through a proxy tool — match on the bare name.

| Need | Tool |
|---|---|
| Go to a page, switch tabs | `navigate_page`, `new_page`, `select_page` |
| Read texts, roles, states, and get element `uid`s | `take_snapshot` |
| Act | `click`, `fill`, `fill_form`, `press_key`, `hover`, `upload_file` |
| Wait for a text | `wait_for` |
| Screenshot (for the user, or the mock-up comparison) | `take_screenshot` (`filePath` to keep it) |
| JS errors | `list_console_messages` |
| Back-end calls | `list_network_requests`, `get_network_request` |
| Mobile / tablet | `resize_page` (375×812, 768×1024, 1440×900) |
| Measurements, styles, scripts | `evaluate_script` |

Prefer the snapshot to the screenshot to read the page: it is exact and gives the
elements' `uid`s. The screenshot is for showing, and for comparing with a
mock-up.

## DOM measurements

Pass to `evaluate_script`, adapting the selectors.

**Gap between two blocks** (px):

```js
() => {
  const a = document.querySelector('SEL_A').getBoundingClientRect();
  const b = document.querySelector('SEL_B').getBoundingClientRect();
  return { verticalGap: b.top - a.bottom, horizontalGap: b.left - a.right };
}
```

**Icon aligned with its text** (vertical centres):

```js
() => {
  const i = document.querySelector('SEL_ICON').getBoundingClientRect();
  const t = document.querySelector('SEL_TEXT').getBoundingClientRect();
  return { offset: (i.top + i.height / 2) - (t.top + t.height / 2), icon: i.height, text: t.height };
}
```

An offset beyond ±1 px is visible; report it with the value.

**Computed styles** (what actually applies, after the stylesheets component
libraries inject at runtime):

```js
() => {
  const s = getComputedStyle(document.querySelector('SEL'));
  return { fontSize: s.fontSize, lineHeight: s.lineHeight, margin: s.margin, padding: s.padding, gap: s.gap, color: s.color };
}
```

**Row alignment** (left edges of a column of elements):

```js
() => [...document.querySelectorAll('SEL')].map(e => Math.round(e.getBoundingClientRect().left))
```

**Basic accessibility** (axe-core, if the page's CSP lets it load):

```js
async () => {
  await new Promise((ok, ko) => { const s = document.createElement('script');
    s.src = 'https://cdnjs.cloudflare.com/ajax/libs/axe-core/4.10.2/axe.min.js'; s.onload = ok; s.onerror = ko;
    document.head.appendChild(s); });
  const r = await axe.run();
  return r.violations.map(v => ({ id: v.id, impact: v.impact, n: v.nodes.length, help: v.help }));
}
```

Keyboard navigation: repeated `press_key` Tab, then `take_snapshot` to see the
focused element; check that the order follows reading order and that no
interactive element is skipped.

## Beyond the browser

- **Emails**: if the project has a local test SMTP server (smtp4dev, MailHog,
  Mailpit), read messages through its HTTP API rather than its UI — recipient,
  subject, text part and HTML part separately.
- **Database**: `psql` (or the project's client) for the expected effect of a
  submission. Read only.
- **Back-end logs**: the user runs the back end; if they redirect its output to
  a file, read it to correlate a network error with its stack trace.
