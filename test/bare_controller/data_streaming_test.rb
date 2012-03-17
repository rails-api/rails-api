require 'test_helper'

module TestBareFileUtils
  def file_name() File.basename(__FILE__) end
  def file_path() File.expand_path(__FILE__) end
  def file_data() @data ||= File.open(file_path, 'rb') { |f| f.read } end
end

class DataStreamingBareController < ActionController::Bare
  include TestBareFileUtils

  def one; end
  def two
    send_data(file_data, {})
  end
end

class DataStreamingBareTest < ActionController::TestCase
  include TestBareFileUtils
  tests DataStreamingBareController

  def test_data
    response = process('two')
    assert_kind_of String, response.body
    assert_equal file_data, response.body
  end
end
