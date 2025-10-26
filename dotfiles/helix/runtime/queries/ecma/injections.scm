; Inject HTML into the string parts of html`...` tagged templates
(call_expression
  function: (identifier) @_name
  arguments: (template_string
    (string_fragment) @injection.content)
  (#eq? @_name "html")
  (#set! injection.language "html")
  (#set! injection.combined))

; Inject CSS into the string parts of css`...` tagged templates
(call_expression
  function: (identifier) @_name
  arguments: (template_string
    (string_fragment) @injection.content)
  (#eq? @_name "css")
  (#set! injection.language "css")
  (#set! injection.combined))

; Inject JavaScript into template substitutions (the ${...} parts)
((template_substitution) @injection.content
  (#set! injection.language "javascript")
  (#set! injection.include-children))

; Generic injection for other template literals (sql, graphql, etc.)
(call_expression
  function: (identifier) @injection.language
  arguments: (template_string) @injection.content
  (#not-match? @injection.language "^(html|css)$")
  (#set! injection.include-children))

; Inject JSDoc into multiline comments
((comment) @injection.content
  (#set! injection.language "jsdoc")
  (#match? @injection.content "^/\\*+"))
