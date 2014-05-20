require 'mm'
require 'nmatrix'
require 'mm/nmatrix'

module MM; end

class MM::Pairs 
  # Conenience method for getting the shape of a pairs array
  # 
  # vector    - The input vector to be broken into pairs
  # type      - Symbol. :adjacent or :combinatorial. Passed to
  #             #get_pairs_shape to determine the number of 
  #             combinations. (default: :adjacent) 
  #
  # Returns Array outlining the shape of the eventual pairs Array.
  def get_pairs_shape(vector, type = :adjacent)
    out_shape = vector.shape
    if type == :adjacent
      out_shape[0] -= 1
      out_shape.insert 1, 2
    elsif type == :combinatorial
      out_shape << 2
      out_shape[0] = (out_shape[0]-1).downto(1).reduce(:+)
    end
    out_shape
  end

  # Gets the arguments to assign a full slice
  #
  # out       - The input vector to assign to
  #
  # Returns Array with :* for each dimension
  def slice_args(out)
    out.shape.map {:*}
  end

  # Generates an NMatrix for assignment of pair values.
  #
  # vector    - The input vector to be broken into pairs
  # type      - Either :adjacent or :combinatorial. Passed to #get_pairs_shape
  #             to determine the number of combinations
  #
  # Returns an NMatrix of all 0s.
  def get_pairs_output_vector(vector, type = :adjacent)
    NMatrix.zeros(get_pairs_shape(vector, type), dtype: vector.dtype, stype: vector.stype)
  end

  def pairs_args(v, i, j)
    [i, (j...(v.shape[i] - 1 + j))]
  end

  # Adjacent pairs of an NMatrix's outermost dimension
  # Optimized for use with large NMatrix objects (anything over 10 elements)
  # Note that all matrics must be the same size
  def get_adjacent_pairs_large(vector)
    responds_to_arguments vector, [:rank, :shape]
    # Set up the output matrix
    out = get_pairs_output_vector vector
    [0, 1].each do |i|
      out.rank(*pairs_args(out, 1, i), :reference)[*slice_args(out)]= vector.rank(*pairs_args(vector, 0, i))
    end
    out
  end

  def get_combinatorial_range(vs, i)
    # For shape[0]==3, returns starting indices 0, 3, 5
    start_range = (vs.downto(vs-i).inject(0, :+) - vs)
    # Ranges are exclusive
    end_range = start_range + vs - 1 - i
    [start_range, end_range]
  end

  def assign_range_slice(out, assign, element, range)
    out.rank(1, element, :reference)[range[0]...range[1], *slice_args(out).drop(1)] = assign
  end

  # Vectorized, slice-assignment alternate implementation to get combinatorial pairs
  # Should be much faster on large matrices, because it doesn't convert back
  # and forth to Array.
  def get_combinatorial_pairs_nmatrix(vector)
    # Initialize the output vector
    out = get_pairs_output_vector vector, :combinatorial
    # Shorthand for the number of elements
    vs = vector.shape[0]
    
    # Iterates through each element in the original vector
    (0...vs-1).each do |i|
      # The range of elements in the output we will be modifying
      r = get_combinatorial_range(vs, i)
      # Assigns the primary element in each pair
      assign_range_slice(out, vector.rank(0, i), 0, r)
      # Assigns the comparison element in each pair
      assign_range_slice(out, vector.rank(0, (i+1)...vs), 1, r)
    end
    out
  end
end

