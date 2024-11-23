[![codecov](https://codecov.io/gh/ian-l-kennedy/milk-bash/graph/badge.svg?token=DMtEr45cC3)](https://codecov.io/gh/ian-l-kennedy/milk-bash)

![MISSING BADGE! PLEASE FIX ME](https://github.com/ian-l-kennedy/dockwright/actions/workflows/checks.yaml/badge.svg)

---

# milk-bash

All of the bash defines that could be project agnostic

### By following these guidelines, users can ensure their JSON input is properly formatted and compatible with the `BASH_EVALUATED_JSON` function.

1. **Escaped Double Quotes:**
   - Ensure all double quotes within JSON values are escaped (i.e., `\"`).

2. **Allowed Data Types:**
   - Only strings and arrays of strings are supported as JSON values.
   - Boolean, number, and nested objects are not allowed.

3. **Escaped Characters:**
   - Only escaped double quotes (`\"`) are allowed in the JSON values.
   - Any other escaped characters (e.g., `\n`, `\t`, etc.) will cause the function to fail.

4. **Command Execution:**
   - JSON values can include Bash commands enclosed in `$()`, which will be evaluated.
   - Ensure the commands do not produce unexpected results.

5. **Nested Structures:**
   - Nested JSON objects and nested arrays are not allowed.
