alias Exmud.DB.Model.ObjectModel
alias Exmud.DB.Model.ComponentModel
alias Exmud.DB.Repo.EngineRepo

for _ <- 1..10 do
  object =
    EngineRepo.insert!(%ObjectModel{
      key: Faker.Name.first_name()
    })

  for n <- 1..10 do
    EngineRepo.insert!(%ComponentModel{
      component: :erlang.term_to_binary("foo#{n}"),
      object_id: object.id
    })
  end
end
