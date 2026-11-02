/*
    Ceramic Layout Builder for Autodesk 3ds Max
    Version: 0.1.0
    License: MIT

    Creates a centered ceramic tile panel in the XY plane, facing +Z.
    Dimensions use the current 3ds Max system units.
*/

try (destroyDialog CeramicLayoutBuilderRollout) catch()

global CeramicLayoutBuilderRollout
global CeramicLayoutBuilderBuildNumber
if CeramicLayoutBuilderBuildNumber == undefined do CeramicLayoutBuilderBuildNumber = 0

rollout CeramicLayoutBuilderRollout "Ceramic Layout Builder" width:310
(
    group "Panel dimensions (system units)"
    (
        spinner spnPanelWidth "Panel width:" range:[1,50000,1200] type:#float fieldwidth:75 align:#right
        spinner spnPanelHeight "Panel height:" range:[1,50000,600] type:#float fieldwidth:75 align:#right
    )

    group "Tile module (system units)"
    (
        spinner spnTileWidth "Tile width:" range:[1,5000,300] type:#float fieldwidth:75 align:#right
        spinner spnTileHeight "Tile height:" range:[1,5000,300] type:#float fieldwidth:75 align:#right
        spinner spnGroutGap "Grout gap:" range:[0,500,3] type:#float fieldwidth:75 align:#right
        spinner spnTileDepth "Tile depth:" range:[0.1,500,10] type:#float fieldwidth:75 align:#right
        spinner spnGroutDepth "Grout backing depth:" range:[0.1,500,3] type:#float fieldwidth:75 align:#right
    )

    dropdownlist ddlPattern "Pattern:" items:#("Grid", "Brick / 50% offset") selection:1
    button btnCreate "Create tile layout" width:286 height:34
    label lblHelp "Creates new geometry at the world origin. Existing objects are left alone." height:32

    on btnCreate pressed do
    (
        local panelW = spnPanelWidth.value
        local panelH = spnPanelHeight.value
        local tileW = spnTileWidth.value
        local tileH = spnTileHeight.value
        local gap = spnGroutGap.value
        local tileD = spnTileDepth.value
        local groutD = spnGroutDepth.value

        if (panelW <= 0 or panelH <= 0 or tileW <= 0 or tileH <= 0 or tileD <= 0 or groutD <= 0) then
        (
            messageBox "Panel, tile, and depth values must be greater than zero." title:"Ceramic Layout Builder"
        )
        else
        (
            local moduleW = tileW + gap
            local moduleH = tileH + gap
            local colCount = (floor ((panelW + gap) / moduleW)) as integer
            local rowCount = (floor ((panelH + gap) / moduleH)) as integer
            if colCount < 1 do colCount = 1
            if rowCount < 1 do rowCount = 1

            if (colCount * rowCount > 2500) then
            (
                messageBox "This layout would create more than 2,500 tiles. Increase tile size or reduce the panel dimensions." title:"Ceramic Layout Builder"
            )
            else
            (
                local usedW = (colCount * tileW) + ((colCount - 1) * gap)
                local usedH = (rowCount * tileH) + ((rowCount - 1) * gap)
                local firstX = -usedW / 2.0
                local firstY = -usedH / 2.0
                local xMin = -panelW / 2.0
                local xMax = panelW / 2.0
                local yMin = -panelH / 2.0
                local yMax = panelH / 2.0

                CeramicLayoutBuilderBuildNumber += 1
                local prefix = "CeramicLayout_" + (CeramicLayoutBuilderBuildNumber as string)
                local createdNodes = #()
                local tileIndex = 0

                undo "Create Ceramic Tile Layout" on
                (
                    -- The backing sits behind the tile faces and represents the grout bed.
                    local groutObj = box name:(prefix + "_GroutBacking") width:panelW length:panelH height:groutD pos:[0, 0, -tileD - (groutD / 2.0)]
                    groutObj.wirecolor = color 105 105 105
                    append createdNodes groutObj

                    for r = 1 to rowCount do
                    (
                        local tileBottom = firstY + ((r - 1) * moduleH)
                        local tileTop = tileBottom + tileH
                        local clippedBottom = if tileBottom < yMin then yMin else tileBottom
                        local clippedTop = if tileTop > yMax then yMax else tileTop
                        local rowOffset = 0.0
                        if (ddlPattern.selection == 2 and (mod r 2) == 0) do rowOffset = -(moduleW / 2.0)

                        -- Extra columns are considered only for the offset pattern; boundary
                        -- pieces are clipped to the panel so the result never exceeds its width.
                        local cStart = if ddlPattern.selection == 2 then -1 else 1
                        local cEnd = if ddlPattern.selection == 2 then (colCount + 2) else colCount

                        for c = cStart to cEnd do
                        (
                            local tileLeft = firstX + rowOffset + ((c - 1) * moduleW)
                            local tileRight = tileLeft + tileW
                            local clippedLeft = if tileLeft < xMin then xMin else tileLeft
                            local clippedRight = if tileRight > xMax then xMax else tileRight

                            if (clippedRight > clippedLeft and clippedTop > clippedBottom) do
                            (
                                tileIndex += 1
                                local tileObj = box name:(prefix + "_Tile_" + (tileIndex as string)) width:(clippedRight - clippedLeft) length:(clippedTop - clippedBottom) height:tileD pos:[(clippedLeft + clippedRight) / 2.0, (clippedBottom + clippedTop) / 2.0, -tileD / 2.0]
                                tileObj.wirecolor = color 205 205 205
                                append createdNodes tileObj
                            )
                        )
                    )

                    clearSelection()
                    select createdNodes
                )

                format "Ceramic Layout Builder: created % tiles and one grout backing.\n" tileIndex
            )
        )
    )
)

createDialog CeramicLayoutBuilderRollout style:#(#style_titlebar, #style_sysmenu, #style_toolwindow)

