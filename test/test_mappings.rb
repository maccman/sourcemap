require 'minitest/autorun'
require 'source_map/mappings'

class TestMappings < MiniTest::Test
  include SourceMap

  def setup
    @mappings = Mappings.new([
      Mapping.new('a.js', Offset.new(0, 0), Offset.new(0, 0)),
      Mapping.new('b.js', Offset.new(1, 0), Offset.new(20, 0)),
      Mapping.new('c.js', Offset.new(2, 0), Offset.new(30, 0))
    ])
  end

  def test_line_count
    # assert_equal 3, @mappings.line_count
  end

  def test_to_s
    assert_equal "ACoBA;ACUA;", @mappings.to_s
  end

  def test_sources
    assert_equal ["a.js", "b.js", "c.js"], @mappings.sources
  end

  def test_names
    assert_equal [], @mappings.names
  end

  def test_add
    mappings2 = Mappings.new([
      Mapping.new('d.js', Offset.new(0, 0), Offset.new(0, 0))
    ])
    mappings3 = @mappings + mappings2
    assert_equal 0, mappings3[0].generated.line
    assert_equal 1, mappings3[1].generated.line
    assert_equal 2, mappings3[2].generated.line
    assert_equal 3, mappings3[3].generated.line
  end

  def test_bsearch
    assert_equal Offset.new(0, 0), @mappings.bsearch(Offset.new(0, 0)).original
    assert_equal Offset.new(0, 0), @mappings.bsearch(Offset.new(0, 5)).original
    assert_equal Offset.new(20, 0), @mappings.bsearch(Offset.new(1, 0)).original
    assert_equal Offset.new(20, 0), @mappings.bsearch(Offset.new(1, 0)).original
    assert_equal Offset.new(30, 0), @mappings.bsearch(Offset.new(2, 0)).original
  end
end
