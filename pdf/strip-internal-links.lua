-- Convert internal anchor links ([text](#anchor)) to plain text.
-- The assembled markdown concatenates many source files; cross-references
-- written for one file may not resolve in the combined document. Typst
-- errors on unresolved labels, so render them as plain text instead.
function Link(el)
  if el.target:sub(1, 1) == "#" then
    return el.content
  end
  return el
end
