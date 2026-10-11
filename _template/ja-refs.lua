-- 文献が和文か英文かを自動で見分け、参考文献スタイルに伝える。
-- 題目か著者名に日本語(かな・漢字)があれば和文として扱う。

local function is_japanese(ref)
  local text = pandoc.utils.stringify(ref.title or "")
  for _, name in ipairs(ref.author or {}) do
    text = text .. (name.family or "") .. (name.literal or "")
  end
  return text:find("[\227-\233]") ~= nil   -- UTF-8 で U+3000〜U+9FFF の先頭バイト
end

function Pandoc(doc)
  local refs = pandoc.utils.references(doc)
  for _, ref in ipairs(refs) do
    ref.language = is_japanese(ref) and "ja" or nil
  end
  doc.meta.references = refs
  doc.meta.bibliography = nil
  return doc
end
