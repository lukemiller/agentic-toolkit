---
name: verify
description: Run full lint and test suite to validate changes before committing. Use after making code changes to ensure nothing is broken.
when_to_use: after code changes are complete.
---

Run the full lint and test suite for <this-service-name> to validate the current state of the code.

**DEVELOPER NOTE** This is a template!  Update the service name above and the specific `just` or `make` commands below to lint and test your service.

## Steps

1. Run linting (formatting checks, type checking, security scanning, flake8):
   ```sh
   just lint
   ```

2. If linting fails, report the specific errors and fix them before proceeding.

3. Run the test suite:
   ```sh
   just test
   ```

4. If tests fail, report the specific failures with file paths and error messages.

5. Summarize results: which checks passed, which failed, and what needs attention.
