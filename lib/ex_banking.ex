defmodule ExBanking do
  alias ExBanking.User

  @spec create_user(user :: String.t()) :: :ok | {:error, :wrong_arguments | :user_already_exists}
  def create_user(user) when is_binary(user) do
    with true <- valid_name?(user), :ok <- User.create(user) do
      :ok
    else
      false ->
        {:error, :wrong_arguments}

      error ->
        error
    end
  end

  def create_user(_user), do: {:error, :wrong_arguments}

  @spec deposit(user :: String.t(), amount :: number, currency :: String.t()) ::
          {:ok, new_balance :: number}
          | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}
  def deposit(user, amount, currency) do
    with true <- valid_name?(user),
         true <- valid_amount?(amount, 2),
         true <- valid_currency?(currency) do
      User.deposit(user, amount, currency)
    else
      false ->
        {:error, :wrong_arguments}

      error ->
        error
    end
  end

  @spec withdraw(user :: String.t(), amount :: number, currency :: String.t()) ::
          {:ok, new_balance :: number}
          | {:error,
             :wrong_arguments
             | :user_does_not_exist
             | :not_enough_money
             | :too_many_requests_to_user}
  def withdraw(user, amount, currency) do
    with true <- valid_name?(user),
         true <- valid_amount?(amount, 2),
         true <- valid_currency?(currency) do
      User.withdraw(user, amount, currency)
    else
      false ->
        {:error, :wrong_arguments}

      error ->
        error
    end
  end

  def valid_name?(user) do
    String.trim(user) != ""
  end

  def valid_amount?(amount, max_precision) when is_number(amount) and is_integer(max_precision) do
    amount >= 0 && has_max_precision?(amount, max_precision)
  end

  defp has_max_precision?(number, max_precision) when is_float(number) do
    number
    |> to_string()
    |> String.split(".")
    |> List.last()
    |> String.length()
    |> Kernel.<=(max_precision)
  end

  defp has_max_precision?(_number, _max_precision), do: true

  def valid_currency?(currency) do
    valid_name?(currency)
  end
end
