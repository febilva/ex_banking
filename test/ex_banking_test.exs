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
end
