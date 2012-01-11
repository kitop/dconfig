require 'test_helper'

context "Dconfig" do

  setup do
    Dconfig.redis.flushall

    @original_redis = Dconfig.redis
  end

  teardown do
    Dconfig.redis = @original_redis
  end

  test "can set a db through a url-like string" do
    assert Dconfig.redis
    assert_equal "dconfig", Dconfig.key
    Dconfig.redis = 'localhost:9736:1'
    assert_equal 1, Dconfig.redis.client.db
  end

  test "can set and get a key and value" do
    key, value = "name", "John"
    assert Dconfig.set(key, value)
    assert_equal value, Dconfig.get(key)
  end

  test "can set a and get a key via method missing" do
    value = "Smith"
    assert Dconfig.lastname = value
    assert_equal value, Dconfig.lastname
  end

  test "can multi set and multi get keys" do
    values = {"phone" => "555-1234", "zip_code" => "1234", "address" => "742 Evergreen Terrace"}
    assert Dconfig.mset values
    assert_equal values, Dconfig.mget(*values.keys)
  end

  test "can add only missing fields" do
    should_be_added = {"country" => "AR", "state" => "BA"}
    should_not_be_added = {"city" => "CABA"}

    Dconfig.set "city", "other city"

    assert Dconfig.add_missing_fields should_be_added.merge(should_not_be_added)

    assert_equal should_be_added, Dconfig.mget(*should_be_added.keys)
    assert_not_equal "CABA", Dconfig.get("city")
  end

  test "can detect having keys" do
    key = "missing_key"
    assert_equal false, Dconfig.has_key?(key)
    Dconfig.set key, "now exists"
    assert_equal true, Dconfig.has_key?(key)
  end

  test "can delete a key" do
    key = "disposable"
    Dconfig.set key, "here it is"
    assert Dconfig.delete(key)
    assert_equal false, Dconfig.has_key?(key)
  end

  test "can get a boolean value" do 
    key = "boolean"
    Dconfig.set key, 1
    assert_equal true, Dconfig.get_boolean(key)
    Dconfig.set key, 0
    assert_equal false, Dconfig.get_boolean(key)
  end

end
