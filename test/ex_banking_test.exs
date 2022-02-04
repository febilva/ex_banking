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
      :ok = ExBanking.create_user(@user)

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
end
