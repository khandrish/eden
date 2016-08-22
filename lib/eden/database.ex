use Amnesia

defdatabase Eden.Database do
  deftable EntityComponent, [{:id, autoincrement}, :component, :data], type: :bag, index: [:component] do
    @type t :: %EntityComponent{id: non_neg_integer, component: String.t, data: map()}
  end
end