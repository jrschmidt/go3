#
#   * *  Go3 3-player hex shaped Go game client * *
#
#  This application uses a "very thin client" approach. The coffeescript client
#  script only does three things: draw the board on a canvas element, send the
#  game point clicked to the server if user clicks on a legal move, and receive
#  from the server a new set of legal moves.


class Zipper

  constructor: () ->
    @board = new Board(this)
    legal_points = new LegalPlayablePoints
    # @clickster = new ClickHandler(@lpo,@board.drawing_object)


  # click: (x,y) ->
  #   @clickster.click_handle(x,y)


  update: (points) ->
    @lpo.update_legal_moves(points)



class BoardStats

  constructor: (main_object) ->
    @controller = main_object

    @row_start = [1,1,1,1,1,1,2,3,4,5,6]
    @row_end = [6,7,8,9,10,11,11,11,11,11,11]

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

    # @drawing_object = new CanvasHelper(this)



class LegalPlayablePoints

  constructor: (main_object) ->
    @row_start = [1,1,1,1,1,1,2,3,4,5,6]
    @row_end = [6,7,8,9,10,11,11,11,11,11,11]
    @points = @get_init_legal_moves()


  get_init_legal_moves: () ->
    points = []
    for i in [0..10]
      for j in [@row_start[i]..@row_end[i]]
        pp = {}
        pp.a = j
        pp.b = i+1
        points.push(pp)
    return points


  legal_move: (point) ->
    console.log "legalmove()"
    console.log "  point = #{point[0]}, #{point[1]}"
    point_in = @points.some (p) -> p.a == point[0] and p.b == point[1]
    console.log "legal_move = #{point_in}"
    return point_in


  update_legal_moves: (points) ->
    console.log "LegalPlayablePoints#update_legal_moves()"
    console.log "  points.length = #{points.length}"
    console.log "  points[0] = #{points[0]}"
    console.log "  points[1] = #{points[1]}"
    console.log "  points[14] = #{points[14]}"
    console.log "  points[56] = #{points[56]}"
    console.log "  points[70] = #{points[70]}"
    console.log "  points[87] = #{points[87]}"
    @points = []
    @points.push(pt) for pt in points



class CanvasHelper

  constructor: () ->
    @canvas = document.getElementById('go-board')
    @context = @canvas.getContext('2d')
    @board = new BoardStats()
    @board_base = new BoardBase(this)
    @board_lines = new BoardLines(this)


  get_x: (ab) ->
    return 150 + 50*ab[0] - 25*ab[1]


  get_y: (ab) ->
    return 6 + 44*ab[1]


  get_point: (x,y) ->
    # First, use rectangular coordinates to determine which gameboard point to
    # check, then use the radius from the pixel at the center of the gameboard point
    # to see if it's close enough to map the mouse click to that point.

    point = []
    a = -1
    b = -1
    r2 = 999 # TODO Probably can drop initializations for a,b,r2
    in_bounds = true
    b = Math.floor((y-28)/44)+1
    a = Math.floor((x-125+25*b)/50)
    in_bounds = false if b<1
    in_bounds = false if b>11
    in_bounds = false if a<@board.row_start[b-1]
    in_bounds = false if a>@board.row_end[b-1]
    dx = Math.abs(x-@get_x([a,b]))
    dy = Math.abs(y-@get_y([a,b]))
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
    canvas = document.getElementById('go-board')
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
    canvas = document.getElementById('go-board')
    context = canvas.getContext('2d')
    context.strokeStyle = "#000000"
    context.lineWidth = 3
    context.beginPath()
    context.moveTo(@b_canvas.get_x(beg),@b_canvas.get_y(beg))
    context.lineTo(@b_canvas.get_x(end),@b_canvas.get_y(end))
    context.stroke()
    context.closePath()


# GLOBAL level (global to this document)



@mousedown = (e) ->
  @canvas = document.getElementById('go-board')
  dx = @canvas.offsetLeft
  dy = @canvas.offsetTop
  px = e.pageX
  py = e.pageY
  x = px-dx
  y = py-dy

  # @canvas_object = canvas_object
  # point = @canvas_object.get_point(x,y)
  point = @canvas_helper.get_point(x,y)
  if legal_move(point)
    console.log "click_handle: legal_move = true"
    @canvas_helper.draw_stone(point,"R")
    obj_out = {red: point}
    msg_out = JSON.stringify(obj_out)
    xhr = new XMLHttpRequest()
    url = "/legal-points"
    xhr.open('POST',url)
    xhr.onreadystatechange = ->
      if (xhr.readyState == 4 && xhr.status == 200)
        console.log ("ready state = #{xhr.readyState}")
        msg_in = xhr.responseText
        console.log ("msg_in = #{msg_in}")
        response = JSON.parse(msg_in)
        add_stones(response)
        points = response.red
        update(points)
    xhr.send(msg_out)
  else
    console.log "click_handle: legal_move = false"


legal_move = (point) ->
  console.log "legal_move() [GLOBAL]"
  console.log "  point = #{point[0]}, #{point[1]}"
  console.log "  before: points.length = #{points.length}"
  t = @points.some (p) -> p[0] == point[0] and p[1] == point[1]
  if t == true
    point_in = true
  else
    point_in = false
  # point_in = @points.some (p) -> p[0] == point[0] and p[1] == point[1]
  # point_in = @points.some (p) -> p.a == point[0] and p.b == point[1]
  console.log "  after: points.length = #{points.length}"
  console.log "  legal_move = #{point_in}"
  return point_in


get_init_legal_moves = () ->
  points = []
  for i in [0..10]
    for j in [@canvas_helper.board.row_start[i]..@canvas_helper.board.row_end[i]]
      pp = {}
      pp[0] = j
      pp[1] = i+1
      points.push(pp)
  return points


add_stones = (response) ->
  ww = response["white"]
  bb = response["blue"]
  @canvas_helper.draw_stone(ww, "W")
  @canvas_helper.draw_stone(bb, "B")


update = (points) ->
  console.log "Update()  [GLOBAL]"
  console.log "  before: points.length = #{points.length}"
  @points = points
  console.log "  after: points.length = #{points.length}"


start = () ->
  @canvas_helper = new CanvasHelper
  @points = get_init_legal_moves()



window.onload = start
