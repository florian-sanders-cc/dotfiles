; Parse the contents of tagged template literals using
; a language inferred from the tag.

(call_expression
  function: (identifier) @injection.language
  arguments: (template_string) @injection.content
  (#set! injection.include-children))

; Parse the contents of template strings for specific languages

((call_expression
   function: (identifier) @_template_function_name
   arguments: (template_string) @injection.content)
 (#eq? @_template_function_name "html")
 (#set! injection.language "html"))

((call_expression
   function: (identifier) @_template_function_name
   arguments: (template_string) @injection.content)
 (#eq? @_template_function_name "css")
 (#set! injection.language "css"))

((call_expression
   function: (identifier) @_template_function_name
   arguments: (template_string) @injection.content)
 (#eq? @_template_function_name "json")
 (#set! injection.language "json"))

((call_expression
   function: (identifier) @_template_function_name
   arguments: (template_string) @injection.content)
 (#eq? @_template_function_name "sql")
 (#set! injection.language "sql"))

((call_expression
   function: (identifier) @_template_function_name
   arguments: (template_string) @injection.content)
 (#eq? @_template_function_name "js")
 (#set! injection.language "javascript"))

((call_expression
   function: (identifier) @_template_function_name
   arguments: (template_string) @injection.content)
 (#eq? @_template_function_name "ts")
 (#set! injection.language "typescript"))

((call_expression
   function: (identifier) @_template_function_name
   arguments: (template_string) @injection.content)
 (#eq? @_template_function_name "bash")
 (#set! injection.language "bash"))

; Parse shell command template literals

((call_expression
   function: (member_expression) @_template_function_name
   arguments: (template_string) @injection.content)
 (#match? @_template_function_name "\\$\\$?$")
 (#set! injection.language "bash"))

; Parse the contents of gql template literals

((call_expression
   function: (identifier) @_template_function_name
   arguments: (template_string) @injection.content)
 (#eq? @_template_function_name "gql")
 (#set! injection.language "graphql"))

; Parse regex syntax within regex literals

((regex_pattern) @injection.content
 (#set! injection.language "regex"))

; Parse JSDoc annotations in multiline comments

((comment) @injection.content
 (#set! injection.language "jsdoc")
 (#match? @injection.content "^/\\*+"))

; Parse general tags in single line comments

((comment) @injection.content
 (#set! injection.language "comment")
 (#match? @injection.content "^//"))

