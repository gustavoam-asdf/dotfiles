# Gemini Configuration for Gustavo's Environment

## System Context

- **OS:** Microsoft Windows 11 Home Single Language
- **Default Shell:** Windows PowerShell 5.1 (PSVersion: 5.1.26100.7705) - **STRICTLY ENFORCED**
- **CPU:** Intel(R) Core(TM) i5-8300H CPU @ 2.30GHz

## Interaction Mandates

### Shell & Commands (PowerShell 5.1 STRICT)

- **NO BASH / LINUX COMMANDS:** You must NEVER provide Bash syntax or assume GNU tools are installed. Always use native PowerShell 5.1 equivalents.
  - ❌ `export VAR="value"` -> ✅ `$env:VAR = "value"`
  - ❌ `touch file.txt` -> ✅ `New-Item file.txt -ItemType File`
  - ❌ `rm -rf dir` -> ✅ `Remove-Item -Recurse -Force dir`
  - ❌ `grep "text"` -> ✅ `Select-String "text"`
  - ❌ `source .env` -> ✅ Provide a PS script to parse and set env vars.
- **Command Chaining:** PowerShell 5.1 DOES NOT support `&&` or `||`. You must never use them.
  - ❌ `cmd1 && cmd2` -> ✅ `cmd1; if ($?) { cmd2 }`
- **Character Encoding:** Ensure all file operations and shell outputs handle UTF-8 correctly, as PS 5.1 defaults to UTF-16 or ANSI. Use `[Console]::OutputEncoding = [System.Text.Encoding]::UTF8` if necessary.
- **Path Handling:** Use backslashes (`\`) for local Windows paths. If writing scripts, use `Join-Path` to ensure cross-platform safety if needed, but default to Windows standards.

### Tool Preferences

- **Native Cmdlets First:** Prefer full PowerShell cmdlets (e.g., `Get-ChildItem`) over aliases (`ls`, `dir`) to prevent yourself from falling back into Bash habits.
- **Environment Variables:** Always use `$env:VARIABLE_NAME` syntax. Remember that setting variables this way only lasts for the current session. Provide `[Environment]::SetEnvironmentVariable` if a permanent change is needed.

### Performance

- **Wait Times:** Given the i5-8300H processor, allow reasonable timeouts for heavy operations like large file searches (`Select-String`) or builds. Provide progress indicators or verbose outputs if an operation is expected to be slow.

### Coding Standards & Architecture

- **SOLID Principles Strictly Enforced:** All generated code must be architected around SOLID principles. Do not provide "quick and dirty" monolithic solutions unless explicitly requested.
  - **Single Responsibility (SRP):** Strictly separate concerns. For instance, clearly separate data processing or hash calculation logic from client-side execution or routing logic.
  - **Open/Closed (OCP) & Liskov Substitution (LSP):** Write extensible code. Favour abstract classes or interfaces so new functionality can be added without altering existing code.
  - **Interface Segregation (ISP):** Keep interfaces lean, specific, and highly cohesive.
  - **Dependency Inversion (DIP):** Rely on abstractions and dependency injection. Decouple business logic from external frameworks, infrastructure, or database clients.
  - **Layered Architecture:** Where applicable, use Data Transfer Objects (DTOs) to pass data between layers safely, maintaining strict boundaries between API, service, and data access layers.
