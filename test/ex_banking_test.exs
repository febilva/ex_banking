defmodule ExBankingTest do
  use ExUnit.Case
  doctest ExBanking

  describe "create_user/1" do
    @valid_name "febil"
    @invalid_name 1
    test "should create a user" do
      assert ExBanking.create_user(@valid_name) == :ok
      assert ExBanking.create_user(@invalid_name) == {:error, :wrong_arguments}
      assert ExBanking.create_user("") == {:error, :wrong_arguments}
      assert ExBanking.create_user("  ") == {:error, :wrong_arguments}
    end

    test "should not create a user with the same name" do
      :ok = ExBanking.create_user(@valid_name)

      assert ExBanking.create_user(@valid_name) == {:error, :user_already_exists}
    end
  end

  describe "deposit/3" do
    @user "febil"
    test "will credit the given amount to the user" do
      :ok = ExBanking.create_user(@user)

      assert ExBanking.deposit(@user, 0.1, "USD") == {:ok, 0.1}
      assert ExBanking.deposit(@user, 0.2, "USD") == {:ok, 0.3}
    end

    test "should not deposit with invalid values" do
      assert ExBanking.deposit("", 200.00, "USD") == {:error, :wrong_arguments}
      assert ExBanking.deposit(@user, 200.001, "USD") == {:error, :wrong_arguments}
      assert ExBanking.deposit(@user, 200.00, "") == {:error, :wrong_arguments}
      assert ExBanking.deposit(@user, 200.00, "    ") == {:error, :wrong_arguments}
    end

    test "shouldnt allow the deposit if the user doesnt exists" do
      assert ExBanking.deposit("user", 200.00, "USD") == {:error, :user_does_not_exist}
    end

    test "shouldnt allow more than 10 requests at same time" do
      :ok = ExBanking.create_user(@user)
      pids = for _ <- 1..200, do: Task.async(fn -> ExBanking.deposit(@user, 200.00, "USD") end)

      assert {:error, :too_many_requests_to_user} in Task.await_many(pids)
    end
  end

  describe "withdraw/3" do
    @user "febil"
    test "will reduce the given amont from the user" do
      :ok = ExBanking.create_user(@user)
      ExBanking.deposit(@user, 100, "USD")
      assert ExBanking.withdraw(@user, 100, "USD") == {:ok, 0.0}
    end

    test "should not withdraw with invalid values" do
      assert ExBanking.withdraw("", 200.00, "USD") == {:error, :wrong_arguments}
      assert ExBanking.withdraw(@user, 200.001, "USD") == {:error, :wrong_arguments}
      assert ExBanking.withdraw(@user, 200.00, "") == {:error, :wrong_arguments}
      assert ExBanking.withdraw(@user, 200.00, "    ") == {:error, :wrong_arguments}
    end

    test "shouldnt allow the deposit if the user doesnt exists" do
      assert ExBanking.withdraw(@user, 200.00, "USD") == {:error, :user_does_not_exist}
    end

    test "shouldnt allow the user to withdraw if the user doesnt have enough balance" do
      :ok = ExBanking.create_user(@user)

      assert ExBanking.withdraw(@user, 200.00, "USD") == {:error, :not_enough_money}
    end

    test "shouldnt allow more than 10 requests at same time" do
      :ok = ExBanking.create_user(@user)
      pids = for _ <- 1..200, do: Task.async(fn -> ExBanking.withdraw(@user, 200.00, "USD") end)

      assert {:error, :too_many_requests_to_user} in Task.await_many(pids)
    end
  end

  describe "get_balance/2" do
    test "will return the balance of the user" do
      :ok = ExBanking.create_user(@user)
      ExBanking.deposit(@user, 100, "USD")

      assert ExBanking.get_balance(@user, "USD") == {:ok, 100.0}
    end

    test "should not show balance with invalid user or currency" do
      :ok = ExBanking.create_user(@user)
      assert ExBanking.get_balance("", "USD") == {:error, :wrong_arguments}
      assert ExBanking.get_balance(@user, "") == {:error, :wrong_arguments}
    end

    test "shouldn't return the balance is the user doesn't exist" do
      assert ExBanking.get_balance(@user, "USD") == {:error, :user_does_not_exist}
    end

    test "shouldnt allow more than 10 requests at same time" do
      :ok = ExBanking.create_user(@user)

      pids = for _ <- 1..200, do: Task.async(fn -> ExBanking.get_balance(@user, "USD") end)

      assert {:error, :too_many_requests_to_user} in Task.await_many(pids)
    end
  end
end
