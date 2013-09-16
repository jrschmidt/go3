#
#   * *  Go3 3-player hex shaped Go game client * *
#
#  This application uses a "very thin client" approach. The coffeescript client
#  script only does three things: draw the board on a canvas element, send the
#  game point clicked to the server if user clicks on a legal move, and receive
#  from the server a new set of legal moves.


class Zipper

  constructor: () ->
    @board_specs = new BoardDimensions()
    @board = new Board(this)
    @lpp = new LegalPlayablePoints(this)
    @clickster = new ClickHandler(@lpp,@board.drawing_object)


  click: (x,y) ->
    @clickster.click_handle(x,y)



class BoardDimensions

  constructor: () ->
    @row_start = [1,1,1,1,1,1,2,3,4,5,6]
    @row_end = [6,7,8,9,10,11,11,11,11,11,11]



class Board

  constructor: (main_object) ->
    @controller = main_object
    @get_board_constants()
    @drawing_object = new GameCanvas(this)


  get_board_constants: () ->
    @row_start = @controller.board_specs.row_start
    @row_end = @controller.board_specs.row_end

    @w_e = [ [[1,1], [6,1]],
            [[1,2], [7,2]],
            [[1,3], [8,3]],
            [[1,4], [9,4]],
            [[1,5], [10,5]],
            [[1,6], [11,6]],
            [[2,7], [11,7]],
            [[3,8], [11,8]],
            [[4,9], [11,9]],
            [[5,10], [11,10]],
            [[6,11], [11,11]] ]

    @sw_ne = [ [[1,6], [1,1]],
              [[2,7], [2,1]],
              [[3,8], [3,1]],
              [[4,9], [4,1]],
              [[5,10], [5,1]],
              [[6,11], [6,1]],
              [[7,11], [7,2]],
              [[8,11], [8,3]],
              [[9,11], [9,4]],
              [[10,11], [10,5]],
              [[11,11], [11,6]] ]

    @nw_se = [ [[1,6], [6,11]],
              [[1,5], [7,11]],
              [[1,4], [8,11]],
              [[1,3], [9,11]],
              [[1,2], [10,11]],
              [[1,1], [11,11]],
              [[2,1], [11,10]],
              [[3,1], [11,9]],
              [[4,1], [11,8]],
              [[5,1], [11,7]],
              [[6,1], [11,6]] ]



class LegalPlayablePoints
# TODO This class constructs a new blank set of gamepoints from scratch, and
#      sets each point to :empty. It does not use the values generated by the
#      go_string method of the go3.rb script which the ruby script injects into
#      the data-go-game attribute of the html canvas tag. However, the go3.rb
#      script uses the go_string method, which is called from within the canvas
#      tag in index.erb, to start up the go3.rb application and instantiate its
#      objects. What is the "correct" or best way to do this?

  constructor: (main_object) ->
    @board = main_object.board
    @board_specs = main_object.board_specs
    @points = @get_init_legal_moves()


  get_init_legal_moves: () ->
    points = []
    for i in [0..10]
      for j in [@board_specs.row_start[i]..@board_specs.row_end[i]]
        pp = {}
        pp.a = j
        pp.b = i+1
        points.push(pp)
    return points


  legal_move: (point) ->
    point_in = @points.some (p) -> p.a == point[0] and p.b == point[1]
#    alert("legal_move = "+point_in)
    return point_in


  update_legal_moves: (points_string) ->
    @points = @parse_points(points_string)


  parse_points: (points_string) ->
    points = []
    for p in [0..points_string.length/2-1]
      z = {}
      z.a = parseInt("0x"+points_string[p*2])
      z.b = parseInt("0x"+points_string[p*2+1])
      points.push(z)
    return points


class ClickHandler

  constructor: (legal_moves_object,canvas_object) ->
    @lmo = legal_moves_object
    @canvas_object = canvas_object


  click_handle: (x,y) ->
    point = @canvas_object.get_point(x,y)
    if @lmo.legal_move(point)
#      alert("legal move")
      @canvas_object.draw_stone(point,"R")
      msg_out = String(point)
      @connection = new ServerConnection()
      @connection.send(msg_out)
      msg_in = @connection.receive()
      @update_legal_moves(msg_in)
#      alert (msg_in)


  update_legal_moves: (msg) ->
    @lmo.update_legal_moves(msg)


class ServerConnection

  constructor: () ->
    @xhr = new XMLHttpRequest()
    url = "/legal-points"
    @xhr.open('GET',url)

  send: () ->
     @xhr.send()


  receive: () ->
    # FIXME This will not run without this alert here. Apparently, the alert
    # provides a necessary stop which gives this script time to wait and
    # receive the XHR response. I could be wrong about that. The odd part is
    # that for some reason, the app will run just fine in the Jasmine
    # SpecRunner.html page without the alert, and you can just keep adding
    # red stones to the game board in rapid succession. Same result for any
    # standalone html page run directly in the browser without the server.
    # FIXME FIXME THE canvas TAG IN THE SpecRunner.html PAGE HAS
    # FIXME FIXME "<%= go_string %>" FOR THE VALUE OF THE data-go-game
    # FIXME FIXME ATTRIBUTE INSTEAD OF THE ACTUAL VALUES.
    alert ("ready state = "+@xhr.readyState)
    msg = @xhr.responseText
    return msg



class GameCanvas

  constructor: (board) ->
    @canvas = document.getElementById('canvas')
    @context = @canvas.getContext('2d')
    @board = board
    @board_base = new BoardBase(this)
    @board_lines = new BoardLines(this)


  get_x: (ab) ->
    return 150 + 50*ab[0] - 25*ab[1]


  get_y: (ab) ->
    return 6 + 44*ab[1]


  get_point: (x,y) ->
    point = []
    a = -1
    b = -1
    r2 = 999
    in_bounds = true
    b = Math.floor((y-28)/44)+1
    a = Math.floor((x-125+25*b)/50)
    in_bounds = false if b<1
    in_bounds = false if b>11
    in_bounds = false if a<@board.row_start[b-1]
    in_bounds = false if a>@board.row_end[b-1]
    dx = Math.abs(x-@get_x([a,b]))
    dy = Math.abs(y-@.get_y([a,b]))
    r2 = dx*dx+dy*dy
    in_bounds = false if r2>530 #(if radius > 23)
    point = [a,b] if (in_bounds == true)
    return point


  draw_stone: (ab,color) ->
    @context.strokeStyle = "#000000"
    @context.lineWidth = 2
    @context.fillStyle = @get_rgb(color)
    @context.beginPath()
    @context.arc(@get_x(ab),@get_y(ab),17,0,2*Math.PI,false)
    @context.fill()
    @context.stroke()
    @context.closePath()
    @context.beginPath()
    @context.strokeStyle = "#cc9933"
    @context.arc(@get_x(ab),@get_y(ab),19,0,2*Math.PI,false)
    @context.stroke()
    @context.closePath()


  get_rgb: (color) ->
    switch color
      when "R"
        clr = "#cc3333"
      when "W"
        clr = "#f0f0f0"
      when "B"
        clr = "#5050cc"
    return clr


  remove_stone: (ab) ->
    xx = @get_x(ab)
    yy = @get_y(ab)
    @context.beginPath()
    @context.fillStyle = "#cc9933"
    @context.arc(xx,yy,19,0,2*Math.PI,false)
    @context.fill()
    @context.closePath()
    @context.beginPath()
    @context.strokeStyle = "#000000"
    @context.lineWidth = 3
    @context.moveTo(xx-11,yy-19)
    @context.lineTo(xx+11,yy+19)
    @context.stroke()
    @context.moveTo(xx+11,yy-19)
    @context.lineTo(xx-11,yy+19)
    @context.stroke()
    @context.moveTo(xx-20,yy)
    @context.lineTo(xx+20,yy)
    @context.stroke()
    @context.closePath()



class BoardBase

  constructor: (board_canvas) ->
    @b_canvas = board_canvas
    @board = @b_canvas.board
    @draw_base()


  draw_base: () ->
    canvas = document.getElementById('canvas')
    @context = canvas.getContext('2d')
    @draw_base_hex()
    @draw_base_margin()


  draw_base_hex: () ->
    @context.strokeStyle = "#000000"
    @context.lineWidth = 5
    @context.fillStyle = "#cc9933"
    @context.beginPath()
    @context.moveTo(157,26)
    @context.lineTo(443,26)
    @context.lineTo(576,270)
    @context.lineTo(443,514)
    @context.lineTo(157,514)
    @context.lineTo(25,270)
    @context.lineTo(157,26)
    @context.fill()
    @context.stroke()
    @context.closePath()


  draw_base_margin: () ->
    @context.strokeStyle = "#000000"
    @context.lineWidth = 3
    @context.beginPath()
    @context.moveTo(163,34)
    @context.lineTo(437,34)
    @context.lineTo(567,270)
    @context.lineTo(437,506)
    @context.lineTo(163,506)
    @context.lineTo(33,270)
    @context.lineTo(163,34)
    @context.stroke()
    @context.closePath()



class BoardLines

  constructor: (board_canvas) ->
    @b_canvas = board_canvas
    @board = @b_canvas.board
    @draw_lines()

  draw_lines: () ->
    @draw_w_e_lines()
    @draw_sw_ne_lines()
    @draw_nw_se_lines()


  draw_w_e_lines: () ->
    @draw_line(@board.w_e[i][0], @board.w_e[i][1]) for i in [0..10]


  draw_sw_ne_lines: () ->
    @draw_line(@board.sw_ne[i][0],@board.sw_ne[i][1]) for i in [0..10]


  draw_nw_se_lines: () ->
    @draw_line(@board.nw_se[i][0],@board.nw_se[i][1]) for i in [0..10]


  draw_line: (beg,end) ->
    canvas = document.getElementById('canvas')
    context = canvas.getContext('2d')
    context.strokeStyle = "#000000"
    context.lineWidth = 3
    context.beginPath()
    context.moveTo(@b_canvas.get_x(beg),@b_canvas.get_y(beg))
    context.lineTo(@b_canvas.get_x(end),@b_canvas.get_y(end))
    context.stroke()
    context.closePath()


mousedown = (e) ->
  @canvas = document.getElementById('canvas')
  dx = @canvas.offsetLeft
  dy = @canvas.offsetTop
  px = e.pageX
  py = e.pageY
  x = px-dx
  y = py-dy
  @zip.click(x,y)


start = () ->
  @zip = new Zipper()


window.onload = start


