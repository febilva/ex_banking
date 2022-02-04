defmodule ExBanking.User do
  use GenServer

  @impl true
  def init(_user) do
    {:ok, %{}}
  end

  def create(user) do
    case GenServer.start_link(__MODULE__, [],
           name: {:via, Registry, {ExBanking.UserRegistry, user}}
         ) do
      {:ok, _pid} ->
        :ok

      {:error, {:already_started, _pid}} ->
        {:error, :user_already_exists}
    end
  end

  # find the user pid to check wheather the user exists
  # if the user exists check the number of requests
  # depost the amount
  def deposit(user, amount, currency) do
    with pid when is_pid(pid) <- user_exists?(user) do
      {:message_queue_len, mailbox_len} = Process.info(pid, :message_queue_len)

      if mailbox_len <= 10 do
        GenServer.call(pid, {:deposit, amount, currency})
      else
        {:error, :too_many_requests_to_user}
      end
    else
      nil ->
        {:error, :user_does_not_exist}
    end
  end

  def withdraw(user, amount, currency) do
    with pid when is_pid(pid) <- user_exists?(user) do
      {:message_queue_len, mailbox_len} = Process.info(pid, :message_queue_len)

      if mailbox_len <= 10 do
        GenServer.call(pid, {:withdraw, amount, currency})
      else
        {:error, :too_many_requests_to_user}
      end
    else
      nil ->
        {:error, :user_does_not_exist}
    end
  end

  def get_balance(user, currency) do
    with pid when is_pid(pid) <- user_exists?(user) do
      {:message_queue_len, mailbox_len} = Process.info(pid, :message_queue_len)

      if mailbox_len <= 10 do
        GenServer.call(pid, {:balance, currency})
      else
        {:error, :too_many_requests_to_user}
      end
    else
      nil ->
        {:error, :user_does_not_exist}
    end
  end

  def user_exists?(user) do
    user
    |> user_pid()
    |> GenServer.whereis()
  end

  def user_pid(user) do
    {:via, Registry, {ExBanking.UserRegistry, user}}
  end

  @impl GenServer
  def handle_call({:deposit, amount, currency}, _from, balances) do
    balance = Map.get(balances, currency, Decimal.new(0))
    {:ok, amount} = Decimal.cast(amount)
    new_balance = Decimal.add(balance, amount)
    {:reply, {:ok, Decimal.to_float(new_balance)}, Map.put(balances, currency, new_balance)}
  end

  @impl GenServer
  def handle_call({:withdraw, amount, currency}, _from, balances) do
    balance = Map.get(balances, currency, Decimal.new(0))
    {:ok, amount} = Decimal.cast(amount)

    if Decimal.gt?(amount, balance) do
      {:reply, {:error, :not_enough_money}, balances}
    else
      new_balance = Decimal.sub(balance, amount)
      {:reply, {:ok, Decimal.to_float(new_balance)}, Map.put(balances, currency, new_balance)}
    end
  end

  @impl GenServer
  def handle_call({:balance, currency}, _from, balances) do
    balance = Map.get(balances, currency, Decimal.new(0))
    {:reply, {:ok, Decimal.to_float(balance)}, balances}
  end
end
