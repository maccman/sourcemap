require 'minitest/autorun'
require 'source_map/mapping'

class TestMapping < MiniTest::Test
  include SourceMap

  def setup
    @mapping = Mapping.new('script.js', Offset.new(1, 8), Offset.new(2, 9), 'hello')
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

  def test_compare
    assert @mapping == @mapping
    assert @mapping <= @mapping
    assert @mapping >= @mapping

    other = Mapping.new('script.js', Offset.new(2, 0), Offset.new(3, 0), 'goodbye')
    assert @mapping < other
    assert other > @mapping

    other = Mapping.new('script.js', Offset.new(1, 9), Offset.new(3, 0), 'goodbye')
    assert @mapping < other
    assert other > @mapping
  end

  def test_compare_offset
    other = Offset.new(1, 8)

    assert @mapping == other
    assert @mapping <= other
    assert @mapping >= other

    other = Offset.new(2, 0)
    assert @mapping < other

    other = Offset.new(1, 9)
    assert @mapping < other
  end

  def test_inspect
    assert_equal "#<SourceMap::Mapping generated=1:8, original=2:9, source=script.js, name=hello>", @mapping.inspect
  end
end
