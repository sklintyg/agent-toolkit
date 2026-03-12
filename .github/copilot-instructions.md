# Copilot Workspace Instructions

## What
This workspace is an **Agent Skills Library** — a curated collection of reusable prompts, instructions, custom agents, and skills for GitHub Copilot.

## Why
To accelerate and standardize the development of agents and skills across the organization, enabling teams to build on each other's work and share best practices.

## How
- When a response is corrected, ask: *is this a one-off or systemic?* If systemic, update the source file that caused it (agent, skill, prompt, or instruction) — not just the output. Keep edits minimal and targeted.
- Agent needs to collaborate with developer and not go over the defined limits or make assumptions. If it needs something, it should ask.
- If an agent is making a decision that requires developer input, it should communicate this to the developer

## Available Tools & Skills
- Browser automation via playwright-cli: #file: ./instructions/playwright-cli/SKILL.md