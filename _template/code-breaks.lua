-- 本文中のコード(`analysis/sample.py` など)を、/ _ - . の直後で改行できるようにする。
-- 長いパスが行末に来ても、その行の字間が広がらないようにするため。

function Code(el)
  if not FORMAT:match("latex") then
    return nil
  end
  local parts = {}
  for piece in el.text:gmatch("[^/_%-%.]*[/_%-%.]?") do
    if piece ~= "" then
      if #parts > 0 then
        table.insert(parts, pandoc.RawInline("latex", "\\allowbreak{}"))
      end
      table.insert(parts, pandoc.Code(piece, el.attr))
    end
  end
  return parts
end
