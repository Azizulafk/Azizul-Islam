# Ceramic Layout Builder for 3ds Max

A small MAXScript utility for blocking out ceramic tile panels in architectural visualization and product-design scenes.

## Features

- Creates a rectangular tile panel centered on the world origin in the XY plane, facing +Z.
- Supports grid and 50% brick-offset layouts.
- Clips boundary tiles to the panel dimensions.
- Creates a separate backing slab behind the tiles to represent the grout bed.
- Uses the current 3ds Max system units for all dimensions.
- Leaves existing scene objects untouched and selects the newly created geometry.

## Run

1. Save `CeramicLayoutBuilder.ms` locally.
2. In 3ds Max, choose **Scripting → Run Script...**.
3. Select the `.ms` file. The Ceramic Layout Builder window opens.
4. Enter panel, tile, gap, and depth dimensions in the current system units, choose a pattern, and click **Create tile layout**.

The front tile faces sit at Z = 0. The tile bodies extend in negative Z, with the grout backing behind them. Each run creates a new uniquely named set of objects; it does not replace earlier geometry.

## Scope

This first version creates base geometry only. It does not assign materials, add UVs, or make claims about adoption or usage. Those should be added only if they fit the real project workflow.

## License

MIT. See `LICENSE`.

