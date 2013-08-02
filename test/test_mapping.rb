require 'minitest/autorun'
require 'source_map/mapping'

class TestMapping < MiniTest::Unit::TestCase
  include SourceMap

  def setup
    @mapping = Mapping.new('script.js', [1, 8], [2, 9], 'hello')
  end

  def test_generated
    assert_equal 1, @mapping.generated.line
    assert_equal 8, @mapping.generated.column
  end

  def test_original
    assert_equal 2, @mapping.original.line
    assert_equal 9, @mapping.original.column
  end

  def test_source
    assert_equal 'script.js', @mapping.source
  end

  def test_name
    assert_equal 'hello', @mapping.name
  end

  def test_inspect
    assert_equal "#<SourceMap::Mapping generated=1:8, original=2:9, source=script.js, name=hello>", @mapping.inspect
  end
end
