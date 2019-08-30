defmodule Exmud do
  @moduledoc """

  """

  # @doc """
  # Initialize Exmud by providing it with a config.

  # This should be called before any other interactions with Exmud. Behaviour of parts of the system are undefined
  # otherwise.
  # """
  # def initialize(config = %Exmud.Config{}) do
  #   with :ok <- Exmud.Config.configure(config),
  #        :ok <- start_openid_worker(config) do
  #     :ok
  #   else
  #     err -> err
  #   end
  # end

  # defp start_openid_worker(config) do
  #   openid_providers =
  #     Enum.map(
  #       config.openid_providers,
  #       fn provider = %Exmud.Config.OpenID{} ->
  #         {provider.provider,
  #          [
  #            {:client_id, provider.client_id},
  #            {:client_secret, provider.client_secret},
  #            {:discovery_document_uri, provider.discovery_document_uri},
  #            {:redirect_uri, ExmudWeb.Endpoint.url() <> "/auth/#{provider.provider}/callback"},
  #            {:response_type, "code"},
  #            {:scope, "openid email profile"}
  #          ]}
  #       end
  #     )

  #   {:ok, _} =
  #     DynamicSupervisor.start_child(
  #       Exmud.DynamicSupervisor,
  #       {OpenIDConnect.Worker, openid_providers}
  #     )

  #   :ok
  # end
end
