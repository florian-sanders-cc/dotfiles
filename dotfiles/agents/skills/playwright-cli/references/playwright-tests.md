# NixOS / Sandbox Environment Guard

> **If the project has `playwright-docker/`** (i.e. the `pw_test` tool is available), **every test run in this document must go through `pw_test`**. Pass the full command verbatim — including `PLAYWRIGHT_HTML_OPEN=never` and any flags — as `pw_test "<command>"`. `pw_test` wraps it as `pw-test -- sh -c "<command>"`, so environment variables, `&&`, pipes, and quotes survive. Do **not** shell out to `npx playwright test` or `npm run …` from the sandbox; that path is for plain non-NixOS environments only.

> The `--debug=cli` + `playwright-cli attach tw-XXXX` debug-attach flow **does not work through the Docker broker**: the broker launches a fresh `compose run --rm` container per invocation and only streams `run.log` + `result.json` back over the file queue. There is no Playwright CLI server socket, no CDP port, and no persistent container to attach to. For interactive debugging, ask the human to run `npx playwright test --debug=cli` + `playwright-cli attach` on the host.

> See the `pw_test` tool guidelines and the `playwright-docker-setup` skill for setup details.

---

# Running Playwright Tests

To run Playwright tests, use the `npx playwright test` command, or a package manager script. To avoid opening the interactive html report, use `PLAYWRIGHT_HTML_OPEN=never` environment variable.

```bash
# Run all tests
PLAYWRIGHT_HTML_OPEN=never npx playwright test

# Run all tests through a custom npm script
PLAYWRIGHT_HTML_OPEN=never npm run special-test-command
```

# Debugging Playwright Tests

To debug a failing Playwright test, run it with `--debug=cli` option. This command will pause the test at the start and print the debugging instructions.

**IMPORTANT**: run the command in the background and check the output until "Debugging Instructions" is printed. Make sure to stop the command after you have finished.

Once instructions containing a session name are printed, use `playwright-cli` to attach the session and explore the page.

```bash
# Run the test
PLAYWRIGHT_HTML_OPEN=never npx playwright test --debug=cli
# ...
# ... debugging instructions for "tw-abcdef" session ...
# ...

# Attach to the test
playwright-cli attach tw-abcdef
```

Keep the test running in the background while you explore and look for a fix.
The test is paused at the start, so you should step over or pause at a particular location
where the problem is most likely to be.

Every action you perform with `playwright-cli` generates corresponding Playwright TypeScript code.
This code appears in the output and can be copied directly into the test. Most of the time, a specific locator or an expectation should be updated, but it could also be a bug in the app. Use your judgement.

After fixing the test, stop the background test run. Rerun to check that test passes.
