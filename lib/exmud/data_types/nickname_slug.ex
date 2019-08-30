defmodule Exmud.DataType.NicknameSlug do
  use EctoAutoslugField.Slug, from: :nickname, to: :slug
end
