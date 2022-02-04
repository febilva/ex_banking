defmodule ExBanking.User do
  use GenServer

  @impl true
  def init(user) do
    {:ok, user}
  end

  def create(user) do
    case GenServer.start_link(__MODULE__, [], name: {:via, Registry, {ExBanking.UserRegistry, user}}) do
      {:ok, _pid} ->
        :ok

      {:error, {:already_started, _pid}} ->
        {:error, :user_already_exists}
    end
  end
end
