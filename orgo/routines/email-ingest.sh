#!/usr/bin/env bash
# SafeClaw email-ingestion routine.
# Runs the DEFAULT profile (single-profile architecture; the default gateway is the
# only one that runs). Generic across boxes: it uses whatever Gmail MCP tools are
# present in the tool list, so it does not care whether the server is named gmail,
# gmail_reader, gmail_elise, etc. The default profile loads the box's full MCP set,
# so prefer the email-ingest-cron.sh wrapper (cold-start pre-check + retries) for
# the scheduled run rather than calling this script bare.
#   usage: email-ingest.sh [WINDOW] [MAXTURNS]
#   WINDOW   gmail newer_than window for this run (default 2h incremental; pass 14d to backfill)
#   MAXTURNS agent turn cap (default 60; raise for a backfill)
export HERMES_HOME=/root/.hermes
export PATH=/usr/local/bin:/tmp/node-v20.18.1-linux-x64/bin:$PATH

WINDOW="${1:-2h}"
MAXTURNS="${2:-60}"

hermes chat -Q --max-turns "$MAXTURNS" -q 'You are the scheduled email-ingestion routine. Work silently and do not ask questions.

CRITICAL - tool availability check FIRST: your Gmail tools appear in your tool list with PREFIXED names - look for ANY tool whose name CONTAINS the substring GMAIL or FETCH_EMAILS (for example mcp_gmail_elise_GMAIL_FETCH_EMAILS, mcp_gmail_GMAIL_FETCH_EMAILS, or plain GMAIL_FETCH_EMAILS). Match by SUBSTRING, never by exact name - the server prefix varies per box. If at least one tool name contains GMAIL, gmail IS available, use it and proceed. Only if NO tool name anywhere contains GMAIL do you stop and output exactly one line: INGEST ERROR: gmail MCP tools unavailable. Your brain tools are likewise prefixed (for example mcp_gbrain_put_page, mcp_gbrain_get_page); if no tool name contains put_page, output: INGEST ERROR: gbrain MCP tools unavailable. Do NOT improvise with CLI tools and do NOT report zero results when the tools are simply prefixed.

IMPORTANT - keep tool outputs SMALL. Never fetch full email bodies in a list call: list with snippets/headers only, and fetch the full body of ONE email at a time, only for emails that pass the filter.

STEP 1 - LIST. For EACH connected Gmail inbox available to you, list emails using the Gmail search query: in:inbox -in:spam -in:trash newer_than:'"$WINDOW"'
Use max_results=25 and request MINIMAL payload (no bodies - ids, from, subject, date, snippet only; e.g. include_payload=false or verbose=false if the tool supports it). Do NOT add category:primary - these mailboxes do not use Gmail category tabs and that filter returns nothing. If a list returns nothing, that inbox has no mail in the window; move on.

STEP 2 - FILTER on from/subject/snippet. Keep ONLY emails worth remembering:
- written by a real person, OR
- containing actionable business content: deals, invoices, payments, commitments, questions, meeting requests, deadlines, decisions.
DISCARD: newsletters, marketing/promotional mail, automated notifications, OTP/verification codes, social-network updates, no-action receipts, calendar auto-responses.

STEP 3 - STORE. For each email that passed the filter, oldest first:
a) Check the brain with get_page for slug: emails/<YYYY-MM-DD>-<short-kebab-subject>  - if it exists, skip (already ingested).
b) Otherwise fetch that single email by its message id to get the body.
c) Create the page with put_page:
   - slug: emails/<YYYY-MM-DD>-<short-kebab-subject>
   - title: the email subject
   - content: From, To, Date, Subject, a 3-5 sentence summary, any action items as a bullet list, and the Gmail message id.

STEP 4 - REPORT. End with exactly one line: INGEST RESULT: <listed> listed, <ingested> ingested, <filtered-out> filtered out, <dupes> already known.'
