use Amnesia

defdatabase Eden.Database do
  deftable EntityData, [{:id, autoincrement}, :component, :key, :value], type: :bag, index: [:component, :key] do
    @type t :: %EntityData{id: non_neg_integer, component: atom(), key: any(), value: any()}
  end
end