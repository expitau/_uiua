# A simple, parallel HTTP server good enough to serve Uiua's website
# 
# To do that, compile the site with trunk:
# ```
# cd site
# trunk build --release
# cd ..
# ```
# Then run:
# ```
# uiua run examples/http_server.ua
# ```

# Bind TCP listener
Listener ← &tcpl "0.0.0.0:8080"
&p $ Server started

# Mime types
GetExt ← |1 ⊔⊢⇌ ⊜□ ≠@. .
⍘⊟⍉[{"js" "text/javascript"}
    {"html" "text/html"}
    {"wasm" "application/wasm"}]
ExtMimeExt ←
ExtMimeMime ←
ExtMime ← |1 ⊔⊏∶⊂ExtMimeMime □⊂"text/"∶ ⊗∶ExtMimeExt□.

# Convert string to bytes
Bytes ← -@\0

# Make response: status mime bytes
Response ← (|3
  ⊙⊙(⧻.)
  ⊂ Bytes $ HTTP/1.1 _
          $ Content-Type: _
          $ Content-Length: _
          $ 
          $ 
)

# Handlers
NotFound ← Response "404 Not Found" "text/plain" Bytes"Not Found"
ServerError ← Response "500 Internal Server Error" "text/plain"
HandlePageLoadError ← ⋅⋅⋅(
  /↥⌕"The system cannot find the file specified".
  ?ServerError(NotFound;)
)
Page ← |1 ⍣(
  ExtMime GetExt ∶&frab.
  Response "200 OK"
)HandlePageLoadError ⊂"docs"
Home ← |0 Page "/index.html"

Respond ← ;spawn(
  # Extract path from request
  ⊔⊡1 ⊜□≠@ . &ru "\r\n\r\n".
  &p "Request:"
  &p.

  # Route to handler
  ?(Home;)(Page) ≅"/".
  &p "Response:"
  &pf⧻.
  &p " bytes"

  # Send response
  ⊃⋅&cl&w
)

⍥(⍣Respond⋅&p &tcpa Listener)∞
