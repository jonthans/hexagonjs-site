# global variables/constants
speed = 1
size = 32
spacing = 3.4
hexGridWidth = 25
hexGridHeight = 40

# set up the drawing
drawing = new hx.Drawing('#drawing')
drawing.enablePan()
drawing.enableZoom()
drawing.enablePerformanceGauge()
drawing.camera.zoomMin = 0.05
drawing.camera.zoomMax = 3
drawing.camera.zoom = 2 * drawing.dpr
drawing.camera.position.x = size * (hexGridWidth - 0.5) * spacing / 2
drawing.camera.position.y = size * (hexGridHeight - 0.5) / 2

# create the grid
hexagonCurve = ([Math.sin((2*i + 1) * Math.PI / 6) * size, Math.cos((2*i + 1) * Math.PI / 6) * size] for i in [0...6])

colors = [
  '#3D3D3D',
  '#74B06B',
  '#D89C4D',
  '#697584',
  '#C24563',
  '#98719D',
  '#D0D0D0'
]

hexGrid =
  for x in [0..hexGridWidth-1]
    for y in [0..hexGridHeight-1]
      hex = drawing.create('shape')
      hex.set('polygon', hexagonCurve)
      hex.set('position.x', size*spacing*x + size*spacing/2 * (y % 2))
      hex.set('position.y', size*1*y)
      hex.set('fill.enabled', true)
      hex.set('fill.color', colors[1])
      object =
        generationsAlive: 0
        drawingObject: hex
        alive: Math.random() > 0.5
        nextAlive: false
      object

# utility methods for the grid
getSurroundingCells = (x, y) ->
  xx = x + (y % 2) - 1
  [
    hexGrid[xx]?[y-1]
    hexGrid[x]?[y-2]
    hexGrid[xx+1]?[y-1]
    hexGrid[xx]?[y+1]
    hexGrid[x]?[y+2]
    hexGrid[xx+1]?[y+1]
  ].filter((d) -> d?)

getSecondarySurroundingCells = (x, y) ->
  xx = x + (y % 2) - 1
  [
    hexGrid[x-1]?[y]
    hexGrid[xx]?[y-3]
    hexGrid[xx]?[y+3]
    hexGrid[xx+1]?[y-3]
    hexGrid[xx+1]?[y+3]
    hexGrid[x+1]?[y]
  ].filter((d) -> d?)

iterateGrid = (f) ->
  for x in [0..hexGridWidth-1]
    for y in [0..hexGridHeight-1]
      f(x, y, hexGrid[x][y])

last = (new Date()).getTime()

# main loop
drawing.on 'update', ->

  # control the update rate
  if (new Date()).getTime() - last >= 100/speed
    last = (new Date()).getTime()

    #hexagonal game of life rules: http://www.well.com/~dgb/hexrules.html
    iterateGrid (x, y, cell) ->
      total = 0
      for c in getSurroundingCells(x, y)
        if c.alive then total+=1
      for c in getSecondarySurroundingCells(x, y)
        if c.alive then total+=0.3
      cell.nextAlive = total >= 2.0 && total < 3.3

    # draw
    iterateGrid (x, y, cell) ->
      cell.alive = cell.nextAlive
      cell.generationsAlive = if cell.alive then cell.generationsAlive+1 else 0
      color = colors[Math.min(cell.generationsAlive, 4)+1]
      cell.drawingObject.set('fill.color', color, 250)