defmodule Exmud.DataType.NicknameSlug do
  use EctoAutoslugField.Slug, from: :nickname, to: :slug, always_change: true
end
