defmodule ExBanking do
  alias ExBanking.User


  @spec create_user(user :: String.t()) :: :ok | {:error, :wrong_arguments | :user_already_exists}
  def create_user(user) when is_binary(user) do
    with true  <- valid_name?(user), :ok <- User.create(user) do
      :ok
    else
      false ->
        {:error, :wrong_arguments}
      error ->
        error
    end
  end

  def create_user(_user), do: {:error, :wrong_arguments}
  def valid_name?(user) do
    String.trim(user) != ""
  end
end
