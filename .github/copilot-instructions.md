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
- When needed ALWAYS choose playwright-cli for browser automation or playwright features. #file: ./instructions/playwright-cli/SKILL.md
- For agent design and creation, follow the SkillWriter agent's skills. #file: ./agents/skillwriter.agent.md
- For IDS-related work, follow the IDS agent's skills. #file: ./agents/ids.agent.md or instructions. #file: ./instructions/ids.instructions.md
- For Playwright testing, follow the Playwright agent's skills. #file: ./agents/playwright.agent.md or instructions. #file: ./instructions/playwright.instructions.md
- For migration-related work, follow the Migrator agent's skills. #file: ./agents/migrator.agent.md or instructions. #file: ./instructions/migrate.instructions.md
- For generating designs and drawing follow the excalidraw skill: #file ./skills/excalidraw/SKILL.md