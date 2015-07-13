require File.expand_path('../../test_helper', __FILE__)

module Stripe
  class BankAccountTest < Test::Unit::TestCase
    CUSTOMER_BANK_ACCOUNT_URL = '/v1/customers/c_test_customer/sources/ba_test_bank_account'

    def customer
      @mock.expects(:get).once.returns(make_response(make_customer))
      Stripe::Customer.retrieve('c_test_customer')
    end

    should "customer bank accounts should be listable" do
      c = customer
      @mock.expects(:get).once.returns(make_response(test_customer_bank_account_array(customer.id)))
      bank_accounts = c.bank_accounts.all(:object => "bank_accounts").data
      assert bank_accounts.kind_of? Array
      assert bank_accounts[0].kind_of? Stripe::BankAccount
    end

    should "customer bank accounts should have the correct url" do
      c = customer
      @mock.expects(:get).once.returns(make_response(test_bank_account(
        :id => 'ba_test_bank_account',
        :customer => 'c_test_customer'
      )))
      bank_account = c.bank_accounts.retrieve('ba_test_bank_account')
      assert_equal CUSTOMER_BANK_ACCOUNT_URL, bank_account.url
    end

    should "customer bank accounts should be deletable" do
      c = customer
      @mock.expects(:get).once.returns(make_response(test_bank_account))
      @mock.expects(:delete).once.returns(make_response(test_bank_account(:deleted => true)))
      bank_account = c.bank_accounts.retrieve('ba_test_bank_account')
      bank_account.delete
      assert bank_account.deleted
    end

    should "create should return a new customer bank account" do
      c = customer
      @mock.expects(:post).once.returns(make_response(test_bank_account(:id => "ba_test_bank_account")))
      bank_account = c.bank_accounts.create(:source => "tok_41YJ05ijAaWaFS")
      assert_equal "ba_test_bank_account", bank_account.id
    end

    should "customer bank accounts should be verifiable" do
      c = customer
      @mock.expects(:get).once.returns(make_response(test_bank_account))
      @mock.expects(:post).once.returns(make_response(test_bank_account(:status => "verified")))
      bank_account = c.bank_accounts.retrieve('ba_test_bank_account')
      bank_account.verify({:amounts => [32, 45]})
      assert_equal "verified", bank_account.status
    end
  end
end
