require 'minitest/autorun'
require 'mm/nmatrix'

class TestMMPairs < Minitest::Test
  def setup
    @pairs = ::MM::Pairs.new
    @input = Minitest::Mock.new
  end
  
  def test_get_pairs_shape
    exp = [2, 2, 2]
    @input.expect :shape, [3, 2]
    assert_equal exp, @pairs.get_pairs_shape(@input)
    assert @input.verify
  end
  
  def test_slice_args
    exp = [:*, :*]
    @input.expect :shape, [3, 2]
    assert_equal exp, @pairs.slice_args(@input)
    assert @input.verify
  end

  def test_get_pairs_output_vector
    @input.expect :dtype, :int32
    @input.expect :stype, :dense
    @input.expect :shape, [3, 2]
    output = @pairs.get_pairs_output_vector(@input)

    assert @input.verify
    assert_equal :int32, output.dtype
    assert_equal :dense, output.stype
    assert_equal [2, 2, 2], output.shape
  end

  def test_pairs_args
    @input.expect :shape, [3, 2]
    output = @pairs.pairs_args(@input, 0, 1)
    assert_equal [0, (1...3)], output
    assert @input.verify
  end

  def test_get_combinatorial_range
    output = @pairs.get_combinatorial_range(3, 0)
    assert_equal [0, 2], @pairs.get_combinatorial_range(3, 0)
    assert_equal [2, 3], @pairs.get_combinatorial_range(3, 1)
    assert_equal [3, 3], @pairs.get_combinatorial_range(3, 2)
  end
end

