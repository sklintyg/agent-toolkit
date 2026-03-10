---
name: certificate
description: Start or resume a certificate model implementation
agent: agent
tools:
  - search/codebase
  - edit/editFiles
  - search
  - search/usages
  - read/problems
  - execute/getTerminalOutput
  - execute/runInTerminal
  - read/terminalLastCommand
  - read/terminalSelection
---

Invoke the Certificate agent to implement or update a certificate model.

**To create a new certificate:**
Attach your filled specification file and say: "Implement certificate [TYPE] from this specification."

**To add a major version:**
Attach your filled specification file and say: "Add V[X] to certificate [TYPE]."

**If you don't have a specification yet:**
Use the template at #file: ../agents/certificate/templates/certificate-specification.template.md

---

The agent will follow:
- New certificate: #file: ../agents/certificate/skills/create-certificate-model.md
- Major version: #file: ../agents/certificate/skills/add-major-version.md