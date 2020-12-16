--Start of Global Scope---------------------------------------------------------
print('AppEngine Version: ' .. Engine.getVersion())

-- Delay in ms between visualization steps for demonstration purpose only
local DELAY = 100

-- Creating viewer
local viewer = View.create('viewer2D1')

-- Setting up graphical overlay attributes
local decoration = View.ShapeDecoration.create()
decoration:setLineColor(0, 255, 0)
decoration:setLineWidth(3)
local charDeco = View.TextDecoration.create()
charDeco:setSize(60)
charDeco:setColor(0, 255, 0)

-- Creating and setting up an OCR segmenter
local segmenter = Image.OCR.Halcon.ManualSegmenter.create()
segmenter:setParameter('POLARITY', 'dark_on_light')
segmenter:setParameter('CHAR_WIDTH', 58)
segmenter:setParameter('CHAR_HEIGHT', 65)
segmenter:setParameter('STROKE_WIDTH', 7)
segmenter:setParameter('IS_DOTPRINT', 'true')
segmenter:setParameter('RETURN_SEPARATORS', 'false')
segmenter:setParameter('UPPERCASE_ONLY', 'true')
segmenter:setParameter('ELIMINATE_HORIZONTAL_LINES', 'true')
segmenter:setParameter('BASE_LINE_TOLERANCE', 0.25)
segmenter:setParameter('TEXT_LINE_STRUCTURE_0', '10')
segmenter:setParameter('MAX_LINE_NUM', 1)
segmenter:setParameter('ADD_FRAGMENTS', true)
segmenter:setParameter('FRAGMENT_SIZE_MIN', 20)

-- Creating font classifier and set font
local fontClassifier = Image.OCR.Halcon.FontClassifier.create()
fontClassifier:setFont('UNIVERSAL_0_9A_Z_NOREJ')

--End of Global Scope-----------------------------------------------------------

--Start of Function and Event Scope---------------------------------------------

local function main()
  for i = 1, 6 do -- 6 images in test set
    -- Load image
    local im = Image.load('resources/gulasch_label_' .. i .. '.bmp')
    viewer:clear()
    viewer:addImage(im)
    viewer:present()

    -- Get the sub image where the text is
    local cropIm = Image.crop(im, 200, 1100, 1200, 550)
    -- Make the text dark on light background
    Image.invertInplace(cropIm)

    -- Find and segment text in rotated image
    local textLines = segmenter:findText(cropIm)
    local charRegions = textLines:getTextLine(0)
    Script.sleep(DELAY * 7)

    if charRegions ~= nil then
      -- Classify all found text regions
      local regExp = '(BF[0-9]{8})'
      local characters,
        _,
        _ = fontClassifier:classifyCharacters(charRegions, cropIm, regExp)

      -- Draw bounding boxes and print characters
      for j = 1, #charRegions do
        local box = charRegions[j]:getBoundingBox()
        box = box:translate(200, 1100)
        viewer:addShape(box, decoration)
        local CoG = box:getCenterOfGravity()
        charDeco:setPosition(CoG:getX() - 15, CoG:getY() - 80)
        viewer:addText(characters:sub(j, j), charDeco)
        viewer:present() -- can be put outside loop if not for demonstration
        Script.sleep(DELAY) -- for demonstration purpose only
      end
    end
  end

  print('App finished.')
end

Script.register('Engine.OnStarted', main)

--End of Function and Event Scope--------------------------------------------------
