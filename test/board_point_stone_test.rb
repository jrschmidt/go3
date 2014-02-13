# Tests for Board Point and Stone Methods
class BoardPointStoneTest < Test::Unit::TestCase
  include TestHelpers
  include TestData


  def test_valid_point
    game = Game.new
    board = game.board
    assert board.valid_point?([1,1])
    assert board.valid_point?([1,4])
    assert board.valid_point?([1,6])
    assert board.valid_point?([2,1])
    assert board.valid_point?([2,7])
    assert board.valid_point?([3,8])
    assert board.valid_point?([4,9])
    assert board.valid_point?([5,10])
    assert board.valid_point?([6,11])
    assert board.valid_point?([9,4])
    assert board.valid_point?([11,6])
    assert board.valid_point?([11,11])

    refute board.valid_point?([0,0])
    refute board.valid_point?([0,1])
    refute board.valid_point?([0,5])
    refute board.valid_point?([0,8])
    refute board.valid_point?([1,0])
    refute board.valid_point?([1,7])
    refute board.valid_point?([1,11])
    refute board.valid_point?([3,9])
    refute board.valid_point?([3,12])
    refute board.valid_point?([4,10])
    refute board.valid_point?([5,11])
    refute board.valid_point?([8,0])
    refute board.valid_point?([9,1])
    refute board.valid_point?([9,3])
    refute board.valid_point?([11,5])
    refute board.valid_point?([12,1])
    refute board.valid_point?([14,6])
  end


  def test_get_point
    game = Game.new
    points = game.board.points
    assert_equal points.get_point([1,1]), :empty
    assert_equal points.get_point([6,1,]), :empty
    assert_equal points.get_point([3,5]), :empty
    assert_equal points.get_point([1,6]), :empty
    assert_equal points.get_point([9,4]), :empty
    assert_equal points.get_point([8,11]), :empty
  end


  def test_set_point
    game = Game.new
    board = game.board
    points = board.points

    points.set_point([4,4], :red)
    points.set_point([9,9], :red)
    points.set_point([4,6], :white)
    points.set_point([2,3], :white)
    points.set_point([5,9], :blue)
    points.set_point([3,4], :blue)
    assert_equal  points.get_point([4,4]), :red
    assert_equal  points.get_point([9,9]), :red
    assert_equal  points.get_point([4,6]), :white
    assert_equal  points.get_point([2,3]), :white
    assert_equal  points.get_point([5,9]), :blue
    assert_equal  points.get_point([3,4]), :blue
    assert_equal  points.get_point([3,3]), :empty
    assert_equal  points.get_point([7,10]), :empty
    assert_equal  points.get_point([11,11]), :empty
    assert_equal  points.get_point([6,3]), :empty
  end


  def test_set_points
    game = Game.new
    board = game.board
    points = board.points

    points.set_points :red, [ [4,4], [9,9] ]
    points.set_points :white, [ [4,6], [2,3] ]
    points.set_points :blue, [ [5,9], [3,4] ]
    assert_equal  points.get_point([4,4]), :red
    assert_equal  points.get_point([9,9]), :red
    assert_equal  points.get_point([4,6]), :white
    assert_equal  points.get_point([2,3]), :white
    assert_equal  points.get_point([5,9]), :blue
    assert_equal  points.get_point([3,4]), :blue
    assert_equal  points.get_point([3,3]), :empty
    assert_equal  points.get_point([7,10]), :empty
    assert_equal  points.get_point([11,11]), :empty
    assert_equal  points.get_point([6,3]), :empty
  end


  def test_game_board_points_each_method
    game = Game.new
    board = game.board
    points = board.points

    total = points.count {|pt| true}
    assert_equal total, 91

    points.each {|pt| assert(board.valid_point?(pt)) }
  end


  def test_find_all_points
    game = Game.new
    board = game.board
    points = board.points
    assert_equal points.find_all_points(:empty).size, 91

    set_test_groups(board,1)
    assert_equal points.find_all_points(:red).size, 7
    assert_equal points.find_all_points(:white).size, 7
    assert_equal points.find_all_points(:blue).size, 7
    assert_equal points.find_all_points(:empty).size, 70
  end


  def test_get_empty_points
    game = Game.new
    board = game.board
    points = board.points

    assert_equal points.get_empty_points.size, 91

    set_test_groups(board,1)
    assert_equal points.get_empty_points.size, 70
  end


  def test_adjacent_points
    game = Game.new
    analyzer = game.analyzer
    board = game.board

    assert board.adjacent?([5,8],[5,7])
    assert board.adjacent?([5,8],[4,7])
    assert board.adjacent?([5,8],[4,8])
    assert board.adjacent?([5,8],[5,9])
    assert board.adjacent?([5,8],[6,9])
    assert board.adjacent?([5,8],[6,8])
    assert board.adjacent?([1,2],[1,3])
    assert board.adjacent?([9,11],[8,10])
    assert board.adjacent?([9,4],[10,5])
    assert board.adjacent?([5,3],[6,3])
    assert board.adjacent?([10,8],[11,9])

    refute(board.adjacent?([10,8,2],[11,9]))
    refute(board.adjacent?([3,1],[3,0]))
    refute(board.adjacent?([6,7],[4.5,3]))
    refute(board.adjacent?([:blue],[6,8]))
    refute(board.adjacent?([1,1],["2,1"]))
    refute(board.adjacent?([8,4],[8,4]))
    refute(board.adjacent?([5,8],[5,3]))
    refute(board.adjacent?([5,8],[11,9]))
    refute(board.adjacent?([5,8],[1,2]))
    refute(board.adjacent?([2,6],[9,9]))
    refute(board.adjacent?([7,10],[3,8]))
  end


  def test_all_adjacent_points
    game = Game.new
    analyzer = game.analyzer
    board = game.board

    assert_equal board.all_adjacent_points([6,6]), [ [6,5], [7,6], [7,7], [6,7], [5,6], [5,5] ]
    assert_equal board.all_adjacent_points([2,3]), [ [2,2], [3,3], [3,4], [2,4], [1,3], [1,2] ]
    assert_equal board.all_adjacent_points([5,4]), [ [5,3], [6,4], [6,5], [5,5], [4,4], [4,3] ]
    assert_equal board.all_adjacent_points([8,5]), [ [8,4], [9,5], [9,6], [8,6], [7,5], [7,4] ]
    assert_equal board.all_adjacent_points([7,8]), [ [7,7], [8,8], [8,9], [7,9], [6,8], [6,7] ]
    assert_equal board.all_adjacent_points([3,7]), [ [3,6], [4,7], [4,8], [3,8], [2,7], [2,6] ]
    assert_equal board.all_adjacent_points([1,1]), [ [2,1], [2,2], [1,2] ]
    assert_equal board.all_adjacent_points([4,1]), [ [5,1], [5,2], [4,2], [3,1] ]
    assert_equal board.all_adjacent_points([6,1]), [ [7,2], [6,2], [5,1] ]
    assert_equal board.all_adjacent_points([9,4]), [ [10,5], [9,5], [8,4], [8,3] ]
    assert_equal board.all_adjacent_points([11,6]), [ [11,7], [10,6], [10,5] ]
    assert_equal board.all_adjacent_points([11,8]), [ [11,7], [11,9], [10,8], [10,7] ]
    assert_equal board.all_adjacent_points([11,11]), [ [11,10], [10,11], [10,10] ]
    assert_equal board.all_adjacent_points([9,11]), [ [9,10], [10,11], [8,11], [8,10] ]
    assert_equal board.all_adjacent_points([6,11]), [ [6,10], [7,11], [5,10] ]
    assert_equal board.all_adjacent_points([2,7]), [ [2,6], [3,7], [3,8], [1,6] ]
    assert_equal board.all_adjacent_points([1,6]), [ [1,5], [2,6], [2,7] ]
    assert_equal board.all_adjacent_points([1,4]), [ [1,3], [2,4], [2,5], [1,5] ]
    assert_equal board.all_adjacent_points([7,18]), []
    assert_equal board.all_adjacent_points([4,0]), []
    assert_equal board.all_adjacent_points([3,2,7]), []
    assert_equal board.all_adjacent_points([57,11]), []
  end


end


