# Source discovery (the shared framework every skill pack follows)

Every box is different: different connections, different CLIs, different brain
content. Skills ADAPT to what exists. The rules:

1. **Probe before you promise.** Run `agent-sources --pretty` (on every box at
   /usr/local/bin/agent-sources) at the start of any skill run that depends on
   external data. It reports: active Composio connections, running services
   (MCPs/bridges), known CLIs (rentcast-comp, MLS bridges, lead-forge), brain
   availability, and portal collections.
2. **Use the best source present, in the skill's stated order.** Each pack's
   SKILL.md lists its source preference (e.g. comping: MLS bridge > RentCast >
   public web). Never invent a source that isn't in the probe.
3. **Name your source in the output.** Every answer that used data says where
   it came from ("MLS", "RentCast estimate", "assessment data").
4. **Degrade gracefully, out loud.** If a preferred source is missing, do the
   task with what exists and tell the user what would improve with the missing
   connection ("connect Gmail on the Connections tab and I can draft this for
   you"). That sentence is also the upsell.
5. **The brain is both a source and a sink.** Check it first (cache), write
   results back (so the next ask is free). Deal pages, person pages, and
   email pages are the cross-skill memory.
6. **Budgeted sources go through their wrapper.** RentCast only via
   rentcast-comp. Never call a metered API raw.

Pack authors: declare in frontmatter `metadata.hermes.sources` (ordered list,
each with `kind` and `optional: true/false`) so the installer and the skills
page can show "what this skill uses" and "what's missing on this box."
